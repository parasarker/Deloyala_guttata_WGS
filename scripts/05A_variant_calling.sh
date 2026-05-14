#!/bin/bash -l
# 05A_variant_calling.sh
# Calls variants per scaffold using bcftools mpileup + call.
# Runs as a task array, one task per scaffold (84 total).
# All samples are called jointly to produce a single VCF per scaffold.
# Run 05B_merge_vcf.sh after all tasks complete to merge into one VCF.
# Usage: qsub -t 1-84 05A_variant_calling.sh

## SCC job settings ##
#$ -P ceeglab
#$ -N variant_calling
#$ -l h_rt=96:00:00
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
BAM_DIR=$PROJECT_DIR/04_Post_Alignment/markdup
OUT_DIR=$PROJECT_DIR/05_Variant_Calling/per_scaffold
LOG_DIR=$PROJECT_DIR/05_Variant_Calling/logs
mkdir -p "$OUT_DIR" "$LOG_DIR"

## Get scaffold for this task ##
SCAFFOLD=$(sed -n "${SGE_TASK_ID}p" "$PIPELINE_DIR/config/scaffolds.txt")

echo "[$(date)] Task $SGE_TASK_ID - Scaffold: $SCAFFOLD"

## Build BAM list and sample names file ##
BAMS=$(ls "$BAM_DIR"/*.markdup.bam | tr '\n' ' ')
ls "$BAM_DIR"/*.markdup.bam | xargs -I{} basename {} .markdup.bam > "$LOG_DIR/sample_names.txt"

## Run mpileup + call ##
bcftools mpileup \
    -f "$REF_GENOME" \
    -r "$SCAFFOLD" \
    -a AD,DP \
    -q 20 \
    -Q 30 \
    -d 500 \
    --threads $THREADS \
    --samples-file "$LOG_DIR/sample_names.txt" \
    $BAMS | \
bcftools call \
    -m \
    -v \
    --ploidy 2 \
    -o "$OUT_DIR/${SCAFFOLD}.vcf.gz" \
    -O z

## Index the VCF ##
bcftools index "$OUT_DIR/${SCAFFOLD}.vcf.gz"

echo "[$(date)] Finished scaffold: $SCAFFOLD"
