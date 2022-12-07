<i>Etheostoma cragini</i> behavioral RNAseq pipeline
================
Coby McDonald
Last updated: 2022-12-06

  - [Overview](#overview)
  - [Step 1: check read quality](#step-1-check-read-quality)
  - [Step 2: trim low-quality reads, repeat
    QC](#step-2-trim-low-quality-reads-repeat-qc)
  - [Step 3: Read alignment and
    quantification](#step-3-read-alignment-and-quantification)
  - [Step 5: GO enrichment analyses](#step-5-go-enrichment-analyses)

# Overview

  - Project: Chris Kopack, 3rd PhD chapter
  - Main questions: Does behavioral enrichment improve predator
    avoidance behavior in the Arkansas darter (<i>Etheostoma
    cragini</i>)? If so, what genes are involved in avoidance and
    learned avoidance?
  - Approach: predator avoidance behavioral trial, followed by 3’
    RNA-seq of neural tissue

The main pipeline we’ll use is:

1.  QC: `FastQC`+ `MultiQC`
2.  \+/- read trimming: `trimgalore` and repeat QC
3.  Alignment and quantification: `STAR`
4.  Differential expression analysis: `DESeq2`
5.  Functional enrichment testing: `emapper` and `topGO`

# Step 1: check read quality

**Programs:** `FastQC` and `MultiQC`

**Explanation:** First, we visually examine our sequencing results.
`FastQC` generates standard QC metrics on a per file basis. `MultiQC`
aggregates these results to make it easier to visually check hundreds of
files at once.

**Code:** [fastqc\_multiqc\_raw.sh](scripts/fastqc_multiqc_raw_slurm.sh)

**Results:** See `MultiQC` report
[here.](results/multiqc/raw/multiqc_report.html)

# Step 2: trim low-quality reads, repeat QC

**Programs:** TrimGalore, FastQC, MultiQC

**Explanation:** For the purposes of counting applications (e.g. RNA-seq
differential gene expression), read trimming is not required. This is
because modern aligners (like STAR) perform local alignment and
automatically soft-clip any non-matching sequences (e.g. adapter
content).

Note: if you want to do transcriptome assembly, you *should* trim reads
for both quality and adapter content.

**Code:** [trimgalore.sh](scripts/trimgalore_slurm.sh)

**Results:** See multiqc report
[here.](results/multiqc/trimmed/multiqc_report.html)

Following trimming, read quality is marginally improved.

# Step 3: Read alignment and quantification

**Program:** STAR

**Explanation:** Provided you have a genome, STAR is by far the most
commonly used RNA-seq aligner. It’s super fast and has the added benefit
of being able to perform quantification as well. STAR consists of two
steps: first, generating genome indexes, then mapping reads to the
indexed genome. There are a variety of parameters to fiddle with, but
the few teleost RNA-seq papers I found tended to use default parameters.

**Code:** [starquant\_slurm\_etheo.sh](scripts/starquant_slurm_etheo.sh)

**Results:** Running STAR in quantification mode outputs a number of
\*ReadsPerGene.out.tab files. These output files have a row for each
gene and four columns: gene ID, counts for unstranded RNA-seq, counts
for 1st strand aligned to RNA, counts for 2nd strand aligned. I believe
Chris did an unstranded library prep. Thus, we can extract the second
column from each file and create a counts matrix.

This [counts matrix](results/star_raw/readcounts_raw.txt) can then be
imported into DESeq2.

**% uniquely mapped reads for each sample is on the low side (\~60-70%).
Typically we shoot for 70-90%.**

To troubleshoot this, I subset 1000 unmapped sequences from one of the
samples and blasted them against the nr database. Sequences generally
seem to align to: ribosomal RNA, mitochondrial RNA, and random genes in
other fish species. This suggests to me that perhaps ribosomal depletion
was not optimal during library prep, and that the <i>E. cragini</i>
genome is incompletely annotated. Neither are huge issues.

We can confirm that this low-ish mapping rate isn’t a big issue by
re-running STAR with trimmed reads instead of raw reads. This increases
our mapping percentages to be (mostly) ≥ 70%.

# Step 5: GO enrichment analyses

**Programs:** eggnog-mapper, topGO

**Explanation:** Although *E. cragini* has a published genome, it does
not have gene ontology annotation. Thus, before we can perform GO
enrichment, we must first retrieve all GO terms associated with our
genes. We can do this with the functional annotation program eggNOG
mapper. eggNOG mapper can take a fasta file of query sequences (either
proteins or genes), run a Diamond blastp (or blastx) search, and carry
out functional annotation for the queries with hits to eggNOG proteins.

I ran the emapper function against a taxonomy-restricted Diamond
database, searching only Teleostei sequences. Restricting to a
particular taxon makes the search much faster.

Basic steps:

1.  Run emapper.py function (see
    [eggnog\_annot.sh](scripts/eggnog_annot.sh))
2.  Add GO IDs to gene IDs from *E. cragini* gtf file (see
    [add\_annotations.R](scripts/add_annotations.R))
3.  Run topGO (see [topGO\_new.R](scripts/topGO_new.R))
