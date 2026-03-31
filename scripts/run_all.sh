#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/00_config.sh"

echo "=== ctDNA pipeline: full run ==="
echo "Checking required inputs..."

if [ ! -f "$TARGET_BED" ]; then
  echo "ERROR: TARGET_BED not found at $TARGET_BED"
  echo "Download from:"
  echo "https://support.illumina.com/content/dam/illumina-support/documents/downloads/productfiles/trusight/trusight-tumor-170/tst170-dna-targets.zip"
  exit 1
fi

if [ ! -f "$KNOWN_POSITIVES_VCF" ]; then
  echo "ERROR: Known positives VCF not found at $KNOWN_POSITIVES_VCF"
  echo "Download from:"
  echo "https://doi.org/10.6084/m9.figshare.13511829"
  exit 1
fi

bash "$DIR/01_setup_env.sh"
bash "$DIR/02_download_data.sh"
bash "$DIR/03_subsample_fastq.sh"
bash "$DIR/04_prepare_reference.sh"
bash "$DIR/05_fastqc_multiqc.sh"
bash "$DIR/06_align_and_qc.sh"
bash "$DIR/07_call_mutect_tumor_only.sh"
bash "$DIR/08_coverage_and_truth.sh"
bash "$DIR/09_call_mutect_tumor_normal.sh"
bash "$DIR/10_compare_results.sh"

echo "=== Pipeline complete ==="
echo "Key outputs:"
echo " - results/qc/multiqc_report.html"
echo " - results/vcf/*summary*.tsv"
