#!/bin/bash -l
# 07C_gemma_lmm.sh
# Runs GWAS using GEMMA linear mixed model (LMM).
# Uses kinship matrix to control for population structure.
# Phenotype: AG=1 (black mottled), BG=0 (brown mottled)
# Run after 07B_kinship_matrix.sh
# Usage: qsub 07C_gemma_lmm.sh

## SCC job settings ##
#$ -P ceeglab
#$ -N gemma_lmm
#$ -l h_rt=24:00:00
#$ -l mem_per_core=8G
#$ -pe omp 8
#$ -j y
#$ -m a
#$ -M parkersa@bu.edu
#$ -cwd
#$ -o /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/project/07_Pop_Gen/logs

## Load config and modules ##
source /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/pipeline/config/config.sh

set -euo pipefail

## Directories ##
PLINK_DIR=$PROJECT_DIR/07_Pop_Gen/plink
KINSHIP_DIR=$PROJECT_DIR/07_Pop_Gen/kinship
OUT_DIR=$PROJECT_DIR/07_Pop_Gen/gemma
LOG_DIR=$PROJECT_DIR/07_Pop_Gen/logs
mkdir -p "$OUT_DIR" "$LOG_DIR"

echo "[$(date)] Running GEMMA LMM"

## Run GEMMA LMM ##
# -lmm 4 runs all four tests (Wald, likelihood ratio, score, BSLMM)
# -k kinship matrix
# -o output prefix
$GEMMA \
    -bfile "$PLINK_DIR/guttata_pruned" \
    -k "$KINSHIP_DIR/kinship.cXX.txt" \
    -lmm 4 \
    -o gemma_lmm \
    -outdir "$OUT_DIR"

echo "[$(date)] GEMMA LMM complete!"
echo "[$(date)] Results at $OUT_DIR/gemma_lmm.assoc.txt"
