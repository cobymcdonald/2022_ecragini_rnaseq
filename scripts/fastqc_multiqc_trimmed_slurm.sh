#!/bin/bash

#SBATCH --mem 5GB
#SBATCH --time=04:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=coby.mcdonald@colostate.edu
#SBATCH --output=logs/qc/trimmed/output-%j
#SBATCH --error=logs/qc/trimmed/error-%j


## load envs
eval "$(conda shell.bash hook)" #this
conda activate qctrim

## Make directories, set relative paths
export WORK=/home/camcd/fish_2022
mkdir -p $WORK/results/fastqc/trimmed
mkdir -p $WORK/results/multiqc/trimmed

## run fastqc
fastqc -t 12 $WORK/results/trim_galore/*.fq.gz -o $WORK/results/fastqc/trimmed

## run multiqc
multiqc $WORK/results/fastqc/trimmed -o $WORK/results/multiqc/trimmed
