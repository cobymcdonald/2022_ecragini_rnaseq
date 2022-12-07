###

#### Adding annotation data to E. cragini genes ####

## Goal: to run topGO functional annotation, we need a gene to GO id map with:
    # a) one column which is the 'gene id' in the .gtf file
    # b) one column with all GO terms (comma-separated) associated with that gene id

## Preconditions: emapper.annotations file, genome .gtf file

###


## Load libs
library(here)
library(tidyverse)
library(rtracklayer)

#### Load data ####

## e-mapper results
annot0 <- read_delim("results/emapper/emapper_teleostei.emapper.annotations", delim="\t", skip = 4) %>% filter(!row_number() %in% c(44429:44431)) %>% dplyr::rename("protein_id"="#query") #remove hashed rows with emapper metadata 

## genome gtf file
gtf0 <- as.data.frame(rtracklayer::import('resources/GCF_013103735.1_CSU_Ecrag_1.0_genomic.gtf')) #omg i freaking love rtracklayer


#### Filter to data of interest ####

## more extensive annotation results
# annot_full <- annot0 %>%
#   select(protein_id, Description, Preferred_name, GOs, EC, KEGG_ko, KEGG_Pathway, KEGG_Module, KEGG_TC, PFAMs)

## e-mapper annotations are by protein ID, so to join GOs to genes, first join emapper results and gtf, then join by gene
annot4go <- annot0 %>% 
  select(protein_id, GOs)

gtf <- gtf0 %>% 
  select(gene, protein_id) %>% 
  filter(!is.na(protein_id)) %>%
  distinct()

gene_and_GO <- left_join(gtf, annot4go) %>% 
  select(-protein_id)

## Because there are multiple protein isoforms per gene, there are duplicate gene rows. Some of these have identical GO ids, some don't. To make sure we retain all GO ids for each gene, regardless of protein isoform, first separate each comma-separated GO id into its own row, filter out NA and - values, and de-duplicate. Then collapse the long format back to comma-separated.
GO_long <- gene_and_GO %>% 
  separate_rows(GOs, sep=",") %>% 
  filter(GOs!="-") %>% 
  filter(!is.na(GOs)) %>% 
  distinct()

GO_undup <- GO_long %>% 
  group_by(gene) %>% 
  mutate(GOs_all=paste0(GOs, collapse=", ")) %>% 
  select(-GOs) %>% 
  distinct() #%>% 
  # write_delim(GO_undup, "results/gene_to_GO/ecrag_gene_to_GO_map.txt", delim="\t")
