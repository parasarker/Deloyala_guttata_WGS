#!/bin/bash -l
# 05B_merge_vcf.sh
# Merges per-scaffold VCFs into a single genome-wide VCF using bcftools concat.
# Run AFTER all 05A_variant_calling.sh tasks have completed successfully.
# Outputs all_samples.vcf.gz and a summary stats file for QC.
# Check ts/tv ratio in stats — expect ~2.0-2.5 for a well-called WGS dataset.
# Usage: qsub 05B_merge_vcf.sh

## SCC job settings ##
#$ -P ceeglab
#$ -N merge_vcf
#$ -l h_rt=24:00:00
#$ -l mem_per_core=8G
#$ -pe omp 8
#$ -j y
#$ -m a
#$ -M parkersa@bu.edu
#$ -cwd
#$ -o /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/project/05_Variant_Calling/logs

## Load config and modules ##
source /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/pipeline/config/config.sh
module load htslib/1.16
module load bcftools/1.16

set -euo pipefail

## Directories ##
IN_DIR=$PROJECT_DIR/05_Variant_Calling/per_scaffold
OUT_DIR=$PROJECT_DIR/05_Variant_Calling
QC_DIR=$PROJECT_DIR/05_Variant_Calling/qc
mkdir -p "$OUT_DIR" "$QC_DIR"

echo "[$(date)] Starting VCF merge"

## Build ordered VCF list from scaffold order ##
VCF_LIST=$(while read SCAFFOLD; do
    echo "$IN_DIR/${SCAFFOLD}.vcf.gz"
done < "$PIPELINE_DIR/config/scaffolds.txt")

## Check all scaffold VCFs exist before merging ##
while read SCAFFOLD; do
    if [[ ! -f "$IN_DIR/${SCAFFOLD}.vcf.gz" ]]; then
        echo "ERROR: Missing VCF for scaffold $SCAFFOLD"
        exit 1
    fi
done < "$PIPELINE_DIR/config/scaffolds.txt"

## Merge all scaffold VCFs ##
bcftools concat \
    --threads $THREADS \
    -O z \
    -o "$OUT_DIR/all_samples.vcf.gz" \
    $VCF_LIST

## Index the merged VCF ##
bcftools index "$OUT_DIR/all_samples.vcf.gz"

echo "[$(date)] Merge complete: all_samples.vcf.gz"

## Post-merge QC stats ##
echo "[$(date)] Running bcftools stats for QC"
bcftools stats \
    --threads $THREADS \
    "$OUT_DIR/all_samples.vcf.gz" \
    > "$QC_DIR/all_samples.stats.txt"

echo "[$(date)] Done! Check $QC_DIR/all_samples.stats.txt for ts/tv ratio and summary stats"
