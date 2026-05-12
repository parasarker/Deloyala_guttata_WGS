#!/bin/bash -l
# 03B_alignment.sh
# Aligns trimmed paired-end reads to the D01 reference genome using BWA MEM.
# Runs as a task array (one task per sample). Skips samples with complete BAMs,
# removes and reruns samples with truncated/incomplete BAMs.
# Usage: qsub -t 1-N 03B_alignment.sh  (replace N with number of samples)
# Note: if jobs are timing out, increase h_rt or split the task array:
#   e.g. qsub -t 1-25 03B_alignment.sh, then qsub -t 26-50 03B_alignment.sh

## SCC job settings ##
#$ -P ceeglab
#$ -N bwa_alignment
#$ -l h_rt=96:00:00
#$ -l mem_per_core=8G
#$ -pe omp 16
#$ -j y
#$ -m bea
#$ -M parkersa@bu.edu
#$ -cwd

## Load config and modules ##
source /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/pipeline/config/config.sh
module load bwa
module load htslib
module load samtools

set -euo pipefail

## Directories ##
OUT_DIR=$PROJECT_DIR/03_Alignment/D01
LOG_DIR=$PROJECT_DIR/03_Alignment/logs
mkdir -p "$OUT_DIR" "$LOG_DIR"

## Get sample for this task ##
FILES=($(ls "$TRIM_DIR"/*_R1.trimmed.fq.gz | sort))
SAMPLE=${FILES[$((SGE_TASK_ID-1))]}
BASE=$(basename "$SAMPLE" _R1.trimmed.fq.gz)

READ1=$TRIM_DIR/${BASE}_R1.trimmed.fq.gz
READ2=$TRIM_DIR/${BASE}_R2.trimmed.fq.gz
OUT_BAM=$OUT_DIR/${BASE}.bam

echo "[$(date)] Task $SGE_TASK_ID — Sample: $BASE"

## Skip if BAM already complete, remove and rerun if truncated ##
if [[ -f "$OUT_BAM" && -f "${OUT_BAM}.bai" ]]; then
    echo "[$(date)] $BASE already complete, skipping"
    exit 0
elif [[ -f "$OUT_BAM" ]]; then
    echo "[$(date)] $BASE has incomplete BAM, removing and rerunning"
    rm -f "$OUT_BAM" "${OUT_BAM}.bai"
fi

## Align, sort, and index ##
bwa mem -t 16 "$REF_GENOME" "$READ1" "$READ2" \
    2> "$LOG_DIR/${BASE}_bwa.log" | \
samtools sort -@ 16 -m 2G -o "$OUT_BAM" \
    2> "$LOG_DIR/${BASE}_samtools.log"

samtools index "$OUT_BAM"

echo "[$(date)] Finished: $BASE"
