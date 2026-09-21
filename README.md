# Bacterial Whole-Genome Sequencing Analysis

This repository contains a simple and reproducible workflow for the analysis of bacterial whole-genome sequencing data.

The workflow covers the main steps from raw paired-end FASTQ files to genome assembly, quality assessment, and genome annotation.

## Workflow

1. Raw read quality assessment using FastQC
2. Read trimming and quality filtering using fastp
3. Genome assembly using SPAdes
4. Assembly quality assessment using QUAST
5. Genome annotation using Prokka
6. Review and interpretation of annotation outputs

## Tools

- FastQC
- fastp
- SPAdes
- QUAST
- Prokka
- Linux / Bash

## Input data

The workflow is designed for paired-end Illumina FASTQ files:

- `sample_R1.fastq.gz`
- `sample_R2.fastq.gz`

Public sequencing datasets can be used to reproduce the workflow.

## 1. Quality control

```bash
fastqc sample_R1.fastq.gz sample_R2.fastq.gz
```

FastQC is used to inspect read quality, GC content, sequence duplication, adapter content, and other quality indicators before downstream analysis.

## 2. Read trimming

```bash
fastp \
  -i sample_R1.fastq.gz \
  -I sample_R2.fastq.gz \
  -o sample_R1_trimmed.fastq.gz \
  -O sample_R2_trimmed.fastq.gz \
  --html fastp_report.html \
  --json fastp_report.json
```

The cleaned reads can then be checked again using FastQC.

## 3. Genome assembly

```bash
spades.py \
  -1 sample_R1_trimmed.fastq.gz \
  -2 sample_R2_trimmed.fastq.gz \
  -o spades_output \
  -t 8
```

The main assembled genome file produced by SPAdes is:

```text
spades_output/scaffolds.fasta
```

## 4. Assembly quality assessment

```bash
quast.py \
  spades_output/scaffolds.fasta \
  -o quast_results
```

Important assembly statistics include:

- Total assembly length
- Number of contigs
- N50
- L50
- GC content
- Largest contig

These statistics help evaluate the continuity and overall quality of the assembled genome.

## 5. Genome annotation

```bash
prokka \
  spades_output/scaffolds.fasta \
  --outdir prokka_results \
  --prefix sample \
  --cpus 8
```

Prokka generates several useful output files:

- `.gff` — genomic features and coordinates
- `.gbk` — annotated genome in GenBank format
- `.faa` — predicted protein sequences
- `.ffn` — nucleotide sequences of predicted genes
- `.fna` — genome sequence
- `.tsv` — tabular annotation summary

## Project purpose

This repository demonstrates a basic bacterial genomics workflow that I use to organize and document whole-genome sequencing analysis.

My research interests include microbial genomics, genome annotation, comparative genomics, antimicrobial resistance, and biological interpretation of sequencing data.

## Author

**Rida Kazim**

Biosciences researcher interested in molecular biology, microbial genomics, NGS, and bioinformatics.
