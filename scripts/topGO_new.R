###

#### GO term enrichment using topGO ####

# Goal: topGO takes GO hierarchy into account when calculating enrichment, leading to fewer false positives.

# This code will do the following:
  # 1. Load significant results of interest, remove empty dataframes
  # 2. Run topGO on all files
  # 3. Write output files of: a) enriched GO terms, b) significant genes associated with those GO terms

# tutorials/links: 
# http://avrilomics.blogspot.com/2015/07/using-topgo-to-test-for-go-term.html 
# looped based on: https://github.com/PBR/scripts/blob/master/topGO.R 

# Preconditions: dataframe of genes of interest, dataframe of GO terms associated with each gene

###


### load packages
library("topGO")
library("BiocGenerics")
library("AnnotationDbi")
library("S4Vectors")
library("data.table")
library(here)
library(tidyverse)


# setwd("bp07_wgcna/modules_0.66/remaining/")
# setwd("bp08_topGO/edgeR_comp_with_genes/up/")
# setwd("~/github/bpit_master/bp05_edgeR/bpit_DGE_LRT_0.66/separate/unions_complements/")
setwd("~/github/bpit_master/scratch/new_edgeR/")


#### 1. Load files of interest ####
list_files.0=dir(pattern='.*txt')
# list_files.0=dir(pattern='int')
# list_files.0=dir(pattern='.*csv')
list_files <- lapply(list_files.0, function(i){read_delim(i, delim="\t")})
names(list_files) <- c(tools::file_path_sans_ext(basename(list_files.0)))
list_files <- Filter(function(x) dim(x)[1] > 0, list_files) #remove empty dataframes


#### 2. Run topGO on all files in list ####
# generate output files: 1) significantly enriched terms for BP GO category, 2) list of genes related to those sig enriched terms

sig_enr <- list() #final output of significantly enriched GO terms
sig_genetogo <- list() #final output of genes in dataset linked to those GO terms

for (i in 1:length(list_files))
{
  # Required 1: gene-to-GO mapping (tab-delimited with first column gene name, second column list of GO terms separated by comma and space, e.g. all genes in your transcriptome with GO annotation) ##
  geneID2GO <- readMappings(file= "~/github/bpit_master/bp03_trinotate/gene_to_GO.txt")

  # Required 2: list of all genes in genome/transcriptome with GO annotation. Use names from the gene-to-GO mapping file. ##
  geneUniverse <- names(geneID2GO)
  
  # Required #3: list of genes of interest, optionally with a gene-wise score (e.g. DGE significance p-value from edgeR) ##
  tableOfInterest=list_files[[i]]
  genesOfInterest=tableOfInterest$gene_id
  geneList <- factor(as.integer(geneUniverse %in% genesOfInterest))
  names(geneList) <- geneUniverse
  
  # Create topGOdata objects for BP GO category
  myGOdata_BP <- new("topGOdata", description="My project", ontology="BP", allGenes=geneList,  annot = annFUN.gene2GO, gene2GO = geneID2GO, nodeSize=5)

  # Perform analysis: BP
  resultFisher <- runTest(myGOdata_BP, algorithm="weight01", statistic="fisher")
  if(sum(resultFisher@score==1)==length(resultFisher@score)){
    sig_enr[[i]] <- data.frame()
    sig_genetogo[[i]] <- data.frame()
  } else {
    enriched <- GenTable(myGOdata_BP, weight01Fisher = resultFisher, topNodes = length(resultFisher@score)) 
    sig_enr[[i]]=enriched[as.numeric(enriched$weight01Fisher)<0.05,] #subset only significant enrichment
    myterms=sig_enr[[i]][,1]
    mygenes=genesInTerm(myGOdata_BP, myterms)
    gtg=data.frame(GOs = rep(names(mygenes), lapply(mygenes, length)), Genes = unlist(mygenes), stringsAsFactors=FALSE) #generate table of genes linked to sig enriched terms
    if (nrow(gtg)>0){
      sig_genetogo[[i]] <- gtg %>% dplyr::filter(Genes %in% genesOfInterest) #subset to only genes in initial tableofinterest
    } else {
      sig_genetogo[[i]] <- data.frame()
    }
  }
  rm(resultFisher)
}

# # write tables
setwd("~/github/bpit_master/scratch/new_edgeR/")
# setwd("~/github/bpit_master/bp08_topGO/results_edger_0.66/unions_complements/")

lapply(1:length(sig_enr),
       function(i) write.table(sig_enr[[i]],
                               file = paste0(names(list_files[i]),"_BP_enriched.txt"),
                               row.names=F, quote=F, sep="\t"))

lapply(1:length(sig_genetogo),
       function(i) write.table(sig_genetogo[[i]],
                               file = paste0(names(list_files[i]),"_sig_genes_to_BP_GO.txt"),
                               row.names=F, quote=F, sep="\t"))

