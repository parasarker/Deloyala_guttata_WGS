#!/bin/bash -l
# 09_blast.sh
# BLASTx of significant GWAS sequences against NCBI nr database (remote)
# Usage: qsub 09_blast.sh

## SCC job settings ##
#$ -P ceeglab
#$ -N blast
#$ -l h_rt=24:00:00
#$ -j y
#$ -m a
#$ -M parkersa@bu.edu
#$ -o /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/project/07_Pop_Gen/logs

## Load modules ##
module load blast+/2.12.0

## Files ##
OUT_DIR=/projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/project/07_Pop_Gen/blast
mkdir -p $OUT_DIR

## Run blastx on suggestive SNPs ##
echo "[$(date)] Running blastx on suggestive SNPs"
blastx \
    -query /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/project/07_Pop_Gen/sig_sequences.fasta \
    -db nr \
    -remote \
    -entrez_query "Insecta[Organism]" \
    -outfmt "6 qseqid sseqid pident length evalue bitscore stitle" \
    -evalue 1e-5 \
    -max_target_seqs 5 \
    -out $OUT_DIR/suggestive_blast.txt

## Run blastx on Bonferroni SNPs ##
echo "[$(date)] Running blastx on Bonferroni SNPs"
blastx \
    -query /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/project/07_Pop_Gen/bonferroni_sequences.fasta \
    -db nr \
    -remote \
    -entrez_query "Insecta[Organism]" \
    -outfmt "6 qseqid sseqid pident length evalue bitscore stitle" \
    -evalue 1e-5 \
    -max_target_seqs 5 \
    -out $OUT_DIR/bonferroni_blast.txt

echo "[$(date)] Done!"
