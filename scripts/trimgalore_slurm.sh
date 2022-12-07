#!/bin/bash

#SBATCH --mem 40GB
#SBATCH --time=4:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=coby.mcdonald@colostate.edu
#SBATCH --output=logs/trimgalore/output-%j
#SBATCH --error=logs/trimgalore/error-%j

## load envs
# source ~/.bashrc
# conda activate qctrim #not working for some reason???



# get time
d1=$(date +%s)

# Make directories, set relative paths
export WORK=/home/camcd/fish_2022/data/raw/etheo
mkdir -p /home/camcd/fish_2022/results/trim_galore
export OUTDIR=/home/camcd/fish_2022/results/trim_galore

cd $WORK

for i in $(ls *.fastq.gz); do
  trim_galore --cores 1 --phred33 --length 20 -q 20 --stringency 1 -e 0.1 -o $OUTDIR $i
done

# check runtime
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)
