#!/bin/bash -l
# 04_post_alignment.sh
# Marks and removes PCR duplicates using samtools fixmate + markdup.
# Runs alignment QC with samtools flagstat and stats.
# Run after 03B_alignment.sh, before variant calling.
# Usage: qsub -t 1-47 04_post_alignment.sh

## SCC job settings ##
#$ -P ceeglab
#$ -N post_alignment
#$ -l h_rt=24:00:00
#$ -l mem_per_core=8G
#$ -pe omp 8
#$ -j y
#$ -m a
#$ -M parkersa@bu.edu
#$ -cwd

## Load config and modules ##
source /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/pipeline/config/config.sh
module load samtools

set -euo pipefail

## Directories ##
IN_DIR=$PROJECT_DIR/03_Alignment/D01
OUT_DIR=$PROJECT_DIR/04_Post_Alignment/markdup
QC_DIR=$PROJECT_DIR/04_Post_Alignment/qc
LOG_DIR=$PROJECT_DIR/04_Post_Alignment/logs
mkdir -p "$OUT_DIR" "$QC_DIR" "$LOG_DIR"

## Get sample for this task ##
BASE=$(sed -n "${SGE_TASK_ID}p" "$PIPELINE_DIR/config/samples.txt")

echo "[$(date)] Task $SGE_TASK_ID — Sample: $BASE"

## Sanity check input BAM ##
echo "[$(date)] Checking input BAM integrity for $BASE"
samtools quickcheck "$IN_DIR/${BASE}.bam" || {
    echo "ERROR: BAM file failed quickcheck for $BASE, exiting"
    exit 1
}

## Fix mate information (required by markdup) ##
echo "[$(date)] Running fixmate for $BASE"
samtools fixmate \
    -m \
    -@ $THREADS \
    "$IN_DIR/${BASE}.bam" \
    "$OUT_DIR/${BASE}.fixmate.bam"

## Mark and remove duplicates ##
echo "[$(date)] Running markdup for $BASE"
samtools markdup \
    -r \
    -S \
    -@ $THREADS \
    "$OUT_DIR/${BASE}.fixmate.bam" \
    "$OUT_DIR/${BASE}.markdup.bam"

## Remove intermediate fixmate BAM ##
rm "$OUT_DIR/${BASE}.fixmate.bam"

## Index the markdup BAM ##
samtools index "$OUT_DIR/${BASE}.markdup.bam"

## Alignment QC ##
echo "[$(date)] Running flagstat for $BASE"
samtools flagstat \
    -@ $THREADS \
    "$OUT_DIR/${BASE}.markdup.bam" \
    > "$QC_DIR/${BASE}.flagstat.txt"

echo "[$(date)] Running stats for $BASE"
samtools stats \
    -@ $THREADS \
    -r "$REF_GENOME" \
    "$OUT_DIR/${BASE}.markdup.bam" \
    > "$QC_DIR/${BASE}.stats.txt"

echo "[$(date)] Finished: $BASE"
