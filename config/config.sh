#!/bin/bash
# config.sh
# Central configuration file for the Deloyala guttata WGS pipeline.
# All scripts source this file at the top with: source config/config.sh
# Edit paths here if running on a different system or project directory.

## Project ##
# Top-level directory containing both project data and pipeline code
BASE_DIR=/projectnb/ceeglab/saraparker/Deloyala_guttata_WGS
# Raw data, results, and intermediate files
PROJECT_DIR=$BASE_DIR/project
# Scripts and pipeline code (this repository)
PIPELINE_DIR=$BASE_DIR/pipeline

## Data ##
# Raw FASTQ files (pre-trimming)
RAW_DIR=$PROJECT_DIR/00_Raw
# Trimmed FASTQ files output by fastp (input to alignment)
TRIM_DIR=$PROJECT_DIR/02_Trimming/fastp/data

## Results ##
# FastQC and MultiQC output directories
QC_DIR=$PROJECT_DIR/01_QC

## Reference ##
# Reference genome FASTA — uncomment and set when available
# REF_GENOME=$PROJECT_DIR/ref/genome.fa
## Reference Genomes ##
# Two different assemblies tested for alignment; D01 selected as primary
REF_DIR=$PROJECT_DIR/03_Alignment
REF_B01=$REF_DIR/mottled_B01_hap1.decontaminated.fasta
REF_D01=$REF_DIR/mottled_D01_hap1.decontaminated.fasta  # primary reference

# D01 selected as primary reference based on alignment statistics
REF_GENOME=$REF_D01

## Alignment ##
# Sorted, indexed BAM files for all samples (post-alignment)
BAM_DIR=$PROJECT_DIR/03_Alignment/D01
# Memory per core for alignment jobs — increase if jobs are failing
MEM_PER_CORE=8GBAM_DIR=$PROJECT_DIR/03_Alignment/bam


## Cluster ##
# BU SCC project code for job scheduling
PROJECT_CODE=ceeglab
# Email for job notifications
EMAIL=parkersa@bu.edu
# Number of threads for parallel tools
THREADS=8
