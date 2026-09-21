#!/usr/bin/env bash

# Bacterial whole-genome sequencing workflow
# Author: Rida Kazim
#
# Usage:
# bash bacterial_wgs_pipeline.sh sample_R1.fastq.gz sample_R2.fastq.gz
#
# Optional:
# bash bacterial_wgs_pipeline.sh sample_R1.fastq.gz sample_R2.fastq.gz output_folder 8

set -euo pipefail

# -----------------------------
# Input
# -----------------------------

if [ "$#" -lt 2 ]; then
    echo "Usage:"
    echo "bash bacterial_wgs_pipeline.sh R1.fastq.gz R2.fastq.gz [output_directory] [threads]"
    exit 1
fi

R1="$1"
R2="$2"
OUTDIR="${3:-wgs_results}"
THREADS="${4:-8}"

echo "--------------------------------------"
echo "Bacterial WGS analysis"
echo "--------------------------------------"
echo "Forward reads: $R1"
echo "Reverse reads: $R2"
echo "Output folder: $OUTDIR"
echo "Threads: $THREADS"
echo "--------------------------------------"

# -----------------------------
# Check input files
# -----------------------------

if [ ! -f "$R1" ]; then
    echo "Error: $R1 was not found."
    exit 1
fi

if [ ! -f "$R2" ]; then
    echo "Error: $R2 was not found."
    exit 1
fi

# -----------------------------
# Check required software
# -----------------------------

for tool in fastqc fastp spades.py quast.py prokka
do
    if ! command -v "$tool" >/dev/null 2>&1
    then
        echo "Error: $tool is not installed or not available in PATH."
        exit 1
    fi
done

# -----------------------------
# Create output directories
# -----------------------------

mkdir -p "$OUTDIR/fastqc_raw"
mkdir -p "$OUTDIR/trimmed"
mkdir -p "$OUTDIR/fastqc_trimmed"
mkdir -p "$OUTDIR/spades"
mkdir -p "$OUTDIR/quast"
mkdir -p "$OUTDIR/prokka"

# -----------------------------
# Step 1: Raw read quality check
# -----------------------------

echo
echo "Step 1: Running FastQC on raw reads..."

fastqc \
    "$R1" \
    "$R2" \
    -t "$THREADS" \
    -o "$OUTDIR/fastqc_raw"

echo "Raw-read FastQC completed."

# -----------------------------
# Step 2: Read trimming
# -----------------------------

echo
echo "Step 2: Running fastp..."

fastp \
    -i "$R1" \
    -I "$R2" \
    -o "$OUTDIR/trimmed/sample_R1_trimmed.fastq.gz" \
    -O "$OUTDIR/trimmed/sample_R2_trimmed.fastq.gz" \
    --html "$OUTDIR/trimmed/fastp_report.html" \
    --json "$OUTDIR/trimmed/fastp_report.json" \
    --thread "$THREADS"

echo "Read trimming completed."

# -----------------------------
# Step 3: Check trimmed reads
# -----------------------------

echo
echo "Step 3: Running FastQC on trimmed reads..."

fastqc \
    "$OUTDIR/trimmed/sample_R1_trimmed.fastq.gz" \
    "$OUTDIR/trimmed/sample_R2_trimmed.fastq.gz" \
    -t "$THREADS" \
    -o "$OUTDIR/fastqc_trimmed"

echo "Trimmed-read FastQC completed."

# -----------------------------
# Step 4: Genome assembly
# -----------------------------

echo
echo "Step 4: Running SPAdes..."

spades.py \
    -1 "$OUTDIR/trimmed/sample_R1_trimmed.fastq.gz" \
    -2 "$OUTDIR/trimmed/sample_R2_trimmed.fastq.gz" \
    -o "$OUTDIR/spades" \
    -t "$THREADS"

echo "Genome assembly completed."

# -----------------------------
# Step 5: Assembly quality
# -----------------------------

echo
echo "Step 5: Running QUAST..."

quast.py \
    "$OUTDIR/spades/scaffolds.fasta" \
    -o "$OUTDIR/quast" \
    -t "$THREADS"

echo "Assembly quality assessment completed."

# -----------------------------
# Step 6: Genome annotation
# -----------------------------

echo
echo "Step 6: Running Prokka..."

prokka \
    "$OUTDIR/spades/scaffolds.fasta" \
    --outdir "$OUTDIR/prokka" \
    --prefix sample \
    --cpus "$THREADS"

echo "Genome annotation completed."

# -----------------------------
# Finish
# -----------------------------

echo
echo "--------------------------------------"
echo "Analysis completed successfully."
echo "--------------------------------------"
echo
echo "Important results:"
echo "Assembly:   $OUTDIR/spades/scaffolds.fasta"
echo "QUAST:      $OUTDIR/quast/report.html"
echo "Annotation: $OUTDIR/prokka/"
echo
