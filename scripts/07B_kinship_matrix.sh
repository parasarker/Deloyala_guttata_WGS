#!/bin/bash -l
# 07B_kinship_matrix.sh
# Builds a centered relatedness matrix using GEMMA.
# Uses LD-pruned PLINK files to avoid bias from correlated SNPs.
# Run after 07A_vcf_to_plink.sh, before 07C_gemma_lmm.sh
# Usage: qsub 07B_kinship_matrix.sh

## SCC job settings ##
#$ -P ceeglab
#$ -N kinship_matrix
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
OUT_DIR=$PROJECT_DIR/07_Pop_Gen/kinship
mkdir -p "$OUT_DIR"

echo "[$(date)] Building centered relatedness matrix"

## Build kinship matrix ##
# -gk 1 = centered relatedness matrix (recommended for LMM)
# -gk 2 = standardized relatedness matrix
$GEMMA \
    -bfile "$PLINK_DIR/guttata_pruned" \
    -gk 1 \
    -o kinship \
    -outdir "$OUT_DIR"

echo "[$(date)] Kinship matrix complete: $OUT_DIR/kinship.cXX.txt"
