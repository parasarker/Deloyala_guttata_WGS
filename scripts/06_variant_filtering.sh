#!/bin/bash -l
# 06_variant_filtering.sh
# Filters merged VCF using vcftools.
# Filters applied:
#   - Biallelic SNPs only (required for GEMMA)
#   - Site missingness 50% (--max-missing 0.5)
#   - Sample missingness 70% (--mind 0.7)
#   - MAF 0.02 (--maf 0.02)
#   - Min depth 5 (--minDP 5)
#   - Max depth 100 (--maxDP 100)
#   - Min quality 30 (--minQ 30)
# Run after 05B_merge_vcf.sh
# Usage: qsub 06_variant_filtering.sh

## SCC job settings ##
#$ -P ceeglab
#$ -N variant_filtering
#$ -l h_rt=24:00:00
#$ -l mem_per_core=8G
#$ -pe omp 8
#$ -j y
#$ -m a
#$ -M parkersa@bu.edu
#$ -cwd
#$ -o /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/project/06_Variant_Filtering/logs

## Load config and modules ##
source /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/pipeline/config/config.sh
module load htslib/1.16
module load bcftools/1.16
module load vcftools

set -euo pipefail

## Directories ##
IN_DIR=$PROJECT_DIR/05_Variant_Calling
OUT_DIR=$PROJECT_DIR/06_Variant_Filtering
LOG_DIR=$PROJECT_DIR/06_Variant_Filtering/logs
mkdir -p "$OUT_DIR" "$LOG_DIR"

echo "[$(date)] Starting variant filtering"

## Filter VCF ##
vcftools \
    --gzvcf "$IN_DIR/all_samples.vcf.gz" \
    --remove-indels \
    --min-alleles 2 \
    --max-alleles 2 \
    --max-missing 0.5 \
    --mind 0.7 \
    --maf 0.02 \
    --minDP 5 \
    --maxDP 100 \
    --minQ 30 \
    --recode \
    --recode-INFO-all \
    --out "$OUT_DIR/filtered"

## Compress and index ##
bgzip "$OUT_DIR/filtered.recode.vcf"
bcftools index "$OUT_DIR/filtered.recode.vcf.gz"

## Summary stats ##
echo "[$(date)] Running stats on filtered VCF"
bcftools stats "$OUT_DIR/filtered.recode.vcf.gz" > "$OUT_DIR/filtered.stats.txt"

echo "[$(date)] Done! Check $OUT_DIR/filtered.stats.txt for summary"
echo "[$(date)] Filtered VCF: $OUT_DIR/filtered.recode.vcf.gz"

