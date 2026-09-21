# Bacterial WGS Workflow

This document explains the main steps used in this repository for bacterial whole-genome sequencing analysis.

## 1. Raw read quality control

Paired-end FASTQ files are first assessed using FastQC.

The main features reviewed include:

- Per-base sequence quality
- GC content
- Sequence duplication
- Adapter contamination
- Overrepresented sequences

## 2. Read trimming

fastp is used to remove low-quality bases and unwanted sequence content.

The cleaned paired-end reads are saved as:

- `sample_R1_trimmed.fastq.gz`
- `sample_R2_trimmed.fastq.gz`

FastQC is run again after trimming to check the quality of the cleaned reads.

## 3. Genome assembly

SPAdes is used for de novo bacterial genome assembly.

The main assembly file used for downstream analysis is:

```text
scaffolds.fasta
```

## 4. Assembly quality assessment

QUAST is used to evaluate the assembled genome.

Important statistics include:

- Total assembly length
- Number of contigs
- Largest contig
- N50
- L50
- GC content

These values help assess the continuity and overall quality of the genome assembly.

## 5. Genome annotation

Prokka is used to predict and annotate genomic features.

Important output files include:

- `.gff` — genomic features and coordinates
- `.gbk` — annotated genome in GenBank format
- `.faa` — predicted protein sequences
- `.ffn` — nucleotide sequences of predicted genes
- `.fna` — genome sequence
- `.tsv` — tabular annotation summary

## 6. Biological interpretation

After annotation, downstream analyses may include:

- Comparative genomics
- Antimicrobial-resistance gene analysis
- Virulence gene analysis
- Phylogenetic analysis
- Functional interpretation of predicted genes

## Note

This repository provides a general workflow for research and educational documentation. Analysis parameters may need to be adjusted depending on sequencing quality, bacterial species, sequencing platform, and study objectives.
