#!/bin/bash -l
# 06_variant_filtering.sh
# Filters merged VCF using vcftools.
# Filters applied:
#   - Biallelic SNPs only (required for GEMMA)
#   - Site missingness 50% (--max-missing 0.5)
#   - Sample missingness 70% (--missing-indv + --remove)
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

## Step 1: Filter sites ##
echo "[$(date)] Filtering sites"
vcftools \
    --gzvcf "$IN_DIR/all_samples.vcf.gz" \
    --remove-indels \
    --min-alleles 2 \
    --max-alleles 2 \
    --max-missing 0.5 \
    --maf 0.02 \
    --minDP 5 \
    --maxDP 100 \
    --minQ 30 \
    --recode \
    --recode-INFO-all \
    --out "$OUT_DIR/site_filtered"

## Step 2: Identify high-missingness individuals ##
echo "[$(date)] Calculating individual missingness"
vcftools \
    --vcf "$OUT_DIR/site_filtered.recode.vcf" \
    --missing-indv \
    --out "$OUT_DIR/missingness"

## Remove individuals missing more than 70% of sites ##
echo "[$(date)] Removing high-missingness individuals"
awk '$5 > 0.7' "$OUT_DIR/missingness.imiss" | cut -f1 > "$OUT_DIR/remove_individuals.txt"
echo "Individuals to remove:"
cat "$OUT_DIR/remove_individuals.txt"

vcftools \
    --vcf "$OUT_DIR/site_filtered.recode.vcf" \
    --remove "$OUT_DIR/remove_individuals.txt" \
    --recode \
    --recode-INFO-all \
    --out "$OUT_DIR/filtered"

## Compress and index ##
echo "[$(date)] Compressing and indexing"
bgzip "$OUT_DIR/filtered.recode.vcf"
bcftools index "$OUT_DIR/filtered.recode.vcf.gz"

## Summary stats ##
echo "[$(date)] Running stats on filtered VCF"
bcftools stats "$OUT_DIR/filtered.recode.vcf.gz" > "$OUT_DIR/filtered.stats.txt"

echo "[$(date)] Done!"
echo "[$(date)] Filtered VCF: $OUT_DIR/filtered.recode.vcf.gz"
echo "[$(date)] Check $OUT_DIR/filtered.stats.txt for summary"
