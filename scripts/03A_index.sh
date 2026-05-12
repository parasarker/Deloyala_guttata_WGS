#!/bin/bash -l
# 03A_index.sh
# Indexes the D01 reference genome using BWA.
# Only needs to be run ONCE before alignment.
# Usage: qsub 03A_index.sh

## SCC job settings ##
#$ -P ceeglab
#$ -l h_rt=96:00:00
#$ -l mem_per_core=8G
#$ -pe omp 16
#$ -N bwa_index
#$ -j y
#$ -M parkersa@bu.edu
#$ -m bea

## Load config and modules ##
source /projectnb/ceeglab/saraparker/Deloyala_guttata_WGS/pipeline/config/config.sh
module load bwa

echo "Job started at $(date)"
echo "Indexing reference genome: $REF_GENOME"

bwa index $REF_GENOME

echo "Indexing complete at $(date)"

