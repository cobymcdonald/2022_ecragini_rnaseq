#!/bin/bash

#SBATCH --mem 5GB
#SBATCH --time=04:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=coby.mcdonald@colostate.edu
#SBATCH --output=logs/qc/raw/output-%j
#SBATCH --error=logs/qc/raw/error-%j


## load envs
source ~/.bashrc
conda activate qctrim

## Make directories, set relative paths
export WORK=/home/camcd/fish_2022
mkdir -p $WORK/results/fastqc/raw
mkdir -p $WORK/results/multiqc/raw

## run fastqc
fastqc -t 12 $WORK/data/raw/*.fastq.gz -o $WORK/results/fastqc/raw

## run multiqc
multiqc $WORK/results/fastqc/raw -o $WORK/results/multiqc/raw
