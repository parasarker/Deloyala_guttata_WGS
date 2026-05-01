#!/bin/bash -l
# 01B_multiqc.sh
# Summarizes FastQC results across all samples using MultiQC.
# Must be run AFTER 01A_fastqc.sh for the corresponding stage.
# Usage: qsub 01B_multiqc.sh raw
#        qsub 01B_multiqc.sh trimmed

## SCC job settings ##
#$ -P ceeglab
#$ -l h_rt=24:00:00
#$ -N multiqc
#$ -j y
#$ -pe omp 8
#$ -M parkersa@bu.edu
#$ -m bea

## Load config and modules ##
source /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/pipeline/config/config.sh
module load multiqc

echo "Job started at $(date)"
echo "Running MultiQC on: $1"

## Set input/output based on argument ##
if [ "$1" == "raw" ]; then
    IN=$QC_DIR/raw/fastqc
    OUT=$QC_DIR/raw/multiqc
elif [ "$1" == "trimmed" ]; then
    IN=$QC_DIR/trimmed/fastqc
    OUT=$QC_DIR/trimmed/multiqc
else
    echo "ERROR: Please specify 'raw' or 'trimmed' as argument"
    exit 1
fi

mkdir -p "$OUT"

multiqc "$IN" -o "$OUT"

echo "Job finished at $(date)"

