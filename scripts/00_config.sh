#!/usr/bin/env bash
set -euo pipefail

export PROJECT_ROOT="${PROJECT_ROOT:-$HOME/projects/ctdna}"

export DATA_DIR="${DATA_DIR:-$PROJECT_ROOT/data}"
export FASTQ_DIR="${FASTQ_DIR:-$DATA_DIR/fastq}"
export SRA_DIR="${SRA_DIR:-$DATA_DIR/sra}"
export TMP_DIR="${TMP_DIR:-$DATA_DIR/tmp}"

export REF_DIR="${REF_DIR:-$PROJECT_ROOT/ref}"
export TST170_DIR="${TST170_DIR:-$REF_DIR/IlluminaTST170_ref}"
export SAMPLEA_DIR="${SAMPLEA_DIR:-$REF_DIR/SampleA_ref}"

export RESULTS_DIR="${RESULTS_DIR:-$PROJECT_ROOT/results}"
export BAM_DIR="${BAM_DIR:-$RESULTS_DIR/bam}"
export QC_DIR="${QC_DIR:-$RESULTS_DIR/qc}"
export VCF_DIR="${VCF_DIR:-$RESULTS_DIR/vcf}"

export THREADS="${THREADS:-8}"
export JAVA_XMX="${JAVA_XMX:-24g}"

export REF_FASTA="${REF_FASTA:-$REF_DIR/Homo_sapiens_assembly38.fasta}"
export TARGET_BED="${TARGET_BED:-$TST170_DIR/TST170_DNA_target_hg38_liftover.bed}"
export GNOMAD_RESOURCE="${GNOMAD_RESOURCE:-$REF_DIR/af-only-gnomad.hg38.vcf.gz}"
export PON_RESOURCE="${PON_RESOURCE:-$REF_DIR/1000g_pon.hg38.vcf.gz}"
export KNOWN_POSITIVES_VCF="${KNOWN_POSITIVES_VCF:-$SAMPLEA_DIR/KnownPositives_hg19ToHg38.vcf.gz}"
export ON_TARGET_TRUTH_VCF="${ON_TARGET_TRUTH_VCF:-$SAMPLEA_DIR/KnownPositives_hg38.on_target.vcf.gz}"

export MIX01_RUN="${MIX01_RUN:-SRR13385590}"
export MIX124_RUN="${MIX124_RUN:-SRR13385577}"

mkdir -p "$DATA_DIR" "$FASTQ_DIR" "$SRA_DIR" "$TMP_DIR"          "$REF_DIR" "$TST170_DIR" "$SAMPLEA_DIR"          "$RESULTS_DIR" "$BAM_DIR" "$QC_DIR" "$VCF_DIR"          "$PROJECT_ROOT/scripts" 

require_cmd() {
  local c="$1"
  command -v "$c" >/dev/null 2>&1 || { echo "Missing command: $c" >&2; exit 1; }
}

require_file() {
  local f="$1"
  [[ -f "$f" ]] || { echo "Missing file: $f" >&2; exit 1; }
}
