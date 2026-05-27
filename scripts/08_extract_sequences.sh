#!/bin/bash -l
# 08_extract_sequences.sh
# Extracts 5kb windows around significant GWAS SNPs for BLAST annotation.
# Input: sig_positions.txt (scaffold, position)
# Output: sig_sequences.fasta
# Usage: qsub 08_extract_sequences.sh

## SCC job settings ##
#$ -P ceeglab
#$ -N extract_sequences
#$ -l h_rt=1:00:00
#$ -l mem_per_core=4G
#$ -pe omp 4
#$ -j y
#$ -m a
#$ -M parkersa@bu.edu
#$ -o /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/project/07_Pop_Gen/logs

## Load config and modules ##
source /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/pipeline/config/config.sh
module load samtools

set -euo pipefail

## Files ##
POSITIONS=$PROJECT_DIR/07_Pop_Gen/sig_positions.txt
OUT=$PROJECT_DIR/07_Pop_Gen/sig_sequences.fasta
REF=$REF_GENOME

echo "[$(date)] Extracting sequences around significant SNPs"

## Extract 5kb windows ##
while read scaffold pos; do
    START=$((pos-2500))
    END=$((pos+2500))
    # Make sure start isn't negative
    if [ $START -lt 1 ]; then START=1; fi
    samtools faidx "$REF" "${scaffold}:${START}-${END}"
done < "$POSITIONS" > "$OUT"

echo "[$(date)] Done! $(grep -c '>' $OUT) sequences extracted"
echo "[$(date)] Output: $OUT"
