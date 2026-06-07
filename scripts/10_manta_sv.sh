#!/bin/bash -l
# 10_manta_sv.sh
# Calls structural variants (SVs) across all 47 samples using Manta.
# Detects deletions, insertions, inversions, and translocations.
# Run after 04_post_alignment.sh
# Usage: qsub 10_manta_sv.sh

## SCC job settings ##
#$ -P ceeglab
#$ -N manta_sv
#$ -l h_rt=48:00:00
#$ -l mem_per_core=8G
#$ -pe omp 16
#$ -j y
#$ -m a
#$ -M parkersa@bu.edu
#$ -cwd
#$ -o /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/project/08_SV/logs

## Load config and modules ##
source /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/pipeline/config/config.sh
module load manta/1.6.0

set -euo pipefail

## Directories ##
BAM_DIR=$PROJECT_DIR/04_Post_Alignment/markdup
OUT_DIR=$PROJECT_DIR/08_SV/manta
LOG_DIR=$PROJECT_DIR/08_SV/logs
mkdir -p "$OUT_DIR" "$LOG_DIR"

echo "[$(date)] Configuring Manta"

## Build BAM input string ##
BAM_INPUTS=$(ls "$BAM_DIR"/*.markdup.bam | while read f; do echo "--bam $f"; done | tr '\n' ' ')

## Step 1: Configure Manta ##
configManta.py \
    $BAM_INPUTS \
    --referenceFasta "$REF_GENOME" \
    --runDir "$OUT_DIR"

echo "[$(date)] Running Manta workflow"

## Step 2: Run Manta ##
"$OUT_DIR"/runWorkflow.py \
    -m local \
    -j 16

echo "[$(date)] Manta complete!"
echo "[$(date)] Results at $OUT_DIR/results/variants/"
