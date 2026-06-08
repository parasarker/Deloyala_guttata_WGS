#!/bin/bash -l
# 11_ld_analysis.sh
# Calculates linkage disequilibrium (r2) around Bonferroni-significant GWAS hits.
# Uses unpruned SNPs, r2 >= 0.2, 200kb window. Keeps output small.
# Usage: qsub 11_ld_analysis.sh

## SCC job settings ##
#$ -P ceeglab
#$ -N ld_analysis
#$ -l h_rt=12:00:00
#$ -l mem_per_core=8G
#$ -pe omp 8
#$ -j y
#$ -m a
#$ -M parkersa@bu.edu
#$ -cwd
#$ -o /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/project/07_Pop_Gen/logs

source /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/pipeline/config/config.sh
module load plink/1.90b6.27

set -euo pipefail

PLINK_DIR=$PROJECT_DIR/07_Pop_Gen/plink
POSITIONS=$PROJECT_DIR/07_Pop_Gen/bonferroni_positions.txt
OUT_DIR=$PROJECT_DIR/07_Pop_Gen/ld
mkdir -p "$OUT_DIR"

# 200 kb padding either side of the hit span
PAD=200000

echo "[$(date)] Starting LD analysis around Bonferroni hits"

SCAFFOLDS=$(cut -f1 "$POSITIONS" | sort -u)

for SCAFFOLD in $SCAFFOLDS; do
    MIN=$(awk -v s="$SCAFFOLD" '$1==s {print $2}' "$POSITIONS" | sort -n | head -1)
    MAX=$(awk -v s="$SCAFFOLD" '$1==s {print $2}' "$POSITIONS" | sort -n | tail -1)

    START=$((MIN - PAD))
    if [ "$START" -lt 1 ]; then START=1; fi
    END=$((MAX + PAD))

    echo "[$(date)] $SCAFFOLD: hits ${MIN}-${MAX}, window ${START}-${END}"

    plink \
        --bfile "$PLINK_DIR/guttata" \
        --allow-extra-chr \
        --chr "$SCAFFOLD" \
        --from-bp "$START" \
        --to-bp "$END" \
        --r2 \
        --ld-window 999999 \
        --ld-window-kb 500 \
        --ld-window-r2 0.2 \
        --out "$OUT_DIR/${SCAFFOLD}_ld"
done

echo "[$(date)] LD analysis complete! Results at $OUT_DIR"
