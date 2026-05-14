#!/bin/bash -l
# 07A_vcf_to_plink.sh
# Converts filtered VCF to PLINK binary format (.bed/.bim/.fam) for GEMMA.
# Also performs LD pruning to reduce SNP redundancy before GWAS.
# Run after 06_variant_filtering.sh
# Usage: qsub 07A_vcf_to_plink.sh

## SCC job settings ##
#$ -P ceeglab
#$ -N vcf_to_plink
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
module load plink/1.90b6.27

set -euo pipefail

## Directories ##
IN_DIR=$PROJECT_DIR/06_Variant_Filtering
OUT_DIR=$PROJECT_DIR/07_Pop_Gen/plink
LOG_DIR=$PROJECT_DIR/07_Pop_Gen/logs
mkdir -p "$OUT_DIR" "$LOG_DIR"

echo "[$(date)] Converting VCF to PLINK format"

## Convert VCF to PLINK binary ##
plink \
    --vcf "$IN_DIR/filtered.recode.vcf.gz" \
    --make-bed \
    --allow-extra-chr \
    --set-missing-var-ids @:# \
    --double-id \
    --out "$OUT_DIR/guttata"

echo "[$(date)] VCF to PLINK conversion complete"
echo "[$(date)] Running LD pruning"

## LD pruning ##
# Window of 50 SNPs, step of 10, r2 threshold of 0.2
plink \
    --bfile "$OUT_DIR/guttata" \
    --allow-extra-chr \
    --indep-pairwise 50 10 0.2 \
    --out "$OUT_DIR/guttata_ld"

## Extract pruned SNPs ##
plink \
    --bfile "$OUT_DIR/guttata" \
    --allow-extra-chr \
    --extract "$OUT_DIR/guttata_ld.prune.in" \
    --make-bed \
    --out "$OUT_DIR/guttata_pruned"

echo "[$(date)] LD pruning complete"
echo "[$(date)] Done! PLINK files at $OUT_DIR/guttata_pruned"
