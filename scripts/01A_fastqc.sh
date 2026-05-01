#!/bin/bash -l
# 01_fastqc.sh
# Runs FastQC on raw and trimmed FASTQ files to assess read quality.
# Run multiqc (02_multiqc.sh) after this to summarize results.
# Usage: qsub 01_fastqc.sh

## SCC job settings ##
#$ -P ceeglab
#$ -l h_rt=24:00:00
#$ -N fastqc
#$ -j y
#$ -pe omp 8
#$ -M parkersa@bu.edu
#$ -m bea

## Load config and modules ##
source /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/pipeline/config/config.sh
module load fastqc

echo "Job started at $(date)"
echo "Running FastQC on: $1"   # raw or trimmed

## Set input/output based on argument ##
# Usage: qsub 01_fastqc.sh raw   → runs QC on raw reads
#        qsub 01_fastqc.sh trimmed → runs QC on trimmed reads
if [ "$1" == "raw" ]; then
    IN=$RAW_DIR
    OUT=$QC_DIR/raw/fastqc
elif [ "$1" == "trimmed" ]; then
    IN=$TRIM_DIR
    OUT=$QC_DIR/trimmed/fastqc
else
    echo "ERROR: Please specify 'raw' or 'trimmed' as argument"
    exit 1
fi

mkdir -p "$OUT"

fastqc \
    -t $THREADS \
    -o "$OUT" \
    "$IN"/*.fq.gz

echo "Job finished at $(date)"

