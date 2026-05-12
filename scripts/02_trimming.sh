#!/bin/bash -l
# 02_trimming.sh
# Trims adapter sequences and low-quality bases from raw paired-end reads using fastp.
# Loops over all samples automatically based on R1 files in RAW_DIR.
# Run 01A_fastqc.sh and 01B_multiqc.sh on trimmed output after this.
# Usage: qsub 02_trimming.sh

## SCC job settings ##
#$ -P ceeglab
#$ -l h_rt=24:00:00
#$ -N fastp
#$ -j y
#$ -pe omp 8
#$ -M parkersa@bu.edu
#$ -m bea

## Load config and modules ##
source /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/pipeline/config/config.sh
module load fastp

echo "Job started at $(date)"

mkdir -p "$TRIM_DIR"

cd "$RAW_DIR" || exit 1

## Loop over all R1 files ##
for R1 in *_R1.fq.gz; do
    # Derive sample name and R2 filename
    SAMPLE=${R1%_R1.fq.gz}
    R2=${SAMPLE}_R2.fq.gz

    # Skip if R2 doesn't exist
    if [[ ! -f "$R2" ]]; then
        echo "WARNING: R2 not found for $SAMPLE, skipping"
        continue
    fi

    echo "Processing sample: $SAMPLE"

    fastp \
        -i "$R1" \
        -I "$R2" \
        -o "$TRIM_DIR/${SAMPLE}_R1.trimmed.fq.gz" \
        -O "$TRIM_DIR/${SAMPLE}_R2.trimmed.fq.gz" \
        -h "$TRIM_DIR/${SAMPLE}.html" \
        -j "$TRIM_DIR/${SAMPLE}.json" \
        -w $THREADS \
        -l 30

    echo "Finished sample: $SAMPLE at $(date)"
done

echo "All samples processed. Job finished at $(date)"
