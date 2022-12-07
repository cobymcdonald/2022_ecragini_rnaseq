#!/bin/bash

#SBATCH --mem 70GB
#SBATCH --time=12:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=coby.mcdonald@colostate.edu
#SBATCH --output=logs/star/output-%j
#SBATCH --error=logs/star/error-%j

## Set relative paths
export WORK=/home/camcd/fish_2022
export STARDIR=$WORK/resources/genome_star/etheo
export FASTA=$WORK/resources/genome_ncbi/etheo

# mkdir $WORK/results/star_etheo

# export SAMPLES=$WORK/data/raw/etheo
export SAMPLES=$WORK/results/trim_galore
# export OUTDIR=$WORK/results/star_etheo
export OUTDIR=$WORK/results/star_etheo_rerun


## Get genomes
# cd $FASTA
# wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/013/103/735/GCF_013103735.1_CSU_Ecrag_1.0/GCF_013103735.1_CSU_Ecrag_1.0_genomic.fna.gz
# wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/013/103/735/GCF_013103735.1_CSU_Ecrag_1.0/GCF_013103735.1_CSU_Ecrag_1.0_genomic.gtf.gz
# wget GCF_013265735.2_USDA_OmykA_1.1_genomic.gff.gz

# gunzip *.gz

# get time
d1=$(date +%s)

## Run STAR with quant mode
cd $WORK
eval "$(conda shell.bash hook)"
conda activate star_quant

# Build genome index, default sjdbOverhang
STAR --runThreadN 22 --runMode genomeGenerate --genomeSAindexNbases 13 --genomeDir $STARDIR --genomeFastaFiles $FASTA/GCF_013103735.1_CSU_Ecrag_1.0_genomic.fna --sjdbGTFfile $FASTA/GCF_013103735.1_CSU_Ecrag_1.0_genomic.gtf --sjdbOverhang 100

# Load genome index
STAR --genomeLoad LoadAndExit --genomeDir $STARDIR

## Loop over all read files
cd $SAMPLES

for i in $(ls *.fq.gz); do STAR --runThreadN 15 --genomeDir $STARDIR --readFilesIn $i --readFilesCommand zcat --outSAMtype BAM SortedByCoordinate --outFilterType BySJout  --outReadsUnmapped Fastx --quantMode TranscriptomeSAM GeneCounts --outFileNamePrefix $OUTDIR/$i;
done

#--quantMode TranscriptomeSAM GeneCounts will return aligned bams and gene counts

## Remove genome index from memory
STAR --genomeLoad Remove --genomeDir $STARDIR

# check runtime
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)
