#!/bin/bash -l
# 11_ld_analysis.sh
# Computes LD (r2) of every SNP against a single focal lead SNP per scaffold
# An extended block of high r2 around the lead SNP suggests an inversion / sweep
## Usage: qsub 11_ld_analysis.sh

## SCC job settings ##
#$ -P ceeglab
#$ -N ld_analysis
#$ -l h_rt=6:00:00
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
OUT_DIR=$PROJECT_DIR/07_Pop_Gen/ld
mkdir -p "$OUT_DIR"

# Lead SNP per scaffold: "scaffold:position"
# Scaffold 11 = Manhattan peak; Scaffold 27 = densest suggestive cluster + Bonferroni hit
LEAD_SNPS=("ptg000011l_1:43289589" "ptg000027l_1:28020652")

# Window around the lead SNP to report LD over (1 Mb each side)
WINDOW_KB=1000

for LEAD in "${LEAD_SNPS[@]}"; do
    SCAFFOLD=${LEAD%%:*}
    echo "[$(date)] LD around focal SNP $LEAD"

    plink \
        --bfile "$PLINK_DIR/guttata" \
        --allow-extra-chr \
        --ld-snp "$LEAD" \
        --r2 \
        --ld-window 999999 \
        --ld-window-kb "$WINDOW_KB" \
        --ld-window-r2 0 \
        --out "$OUT_DIR/${SCAFFOLD}_focal_ld"
done

echo "[$(date)] Focal-SNP LD complete! Results at $OUT_DIR"
