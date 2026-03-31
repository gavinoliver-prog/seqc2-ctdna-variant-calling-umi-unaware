#!/usr/bin/env bash
set -euo pipefail

sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  build-essential \
  git \
  curl \
  wget \
  unzip \
  htop \
  tmux \
  nvtop \
  python3 \
  python3-pip \
  python3-venv \
  openjdk-17-jdk \
  pigz \
  cloud-guest-utils

if [[ ! -d "$HOME/miniconda3" ]]; then
  wget -O "$HOME/Miniconda3-latest-Linux-x86_64.sh" https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
  bash "$HOME/Miniconda3-latest-Linux-x86_64.sh" -b -p "$HOME/miniconda3"
fi

export PATH="$HOME/miniconda3/bin:$PATH"
eval "$("$HOME/miniconda3/bin/conda" shell.bash hook)"

conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true

if ! conda env list | awk '{print $1}' | grep -qx ctdna; then
  conda create -n ctdna -y
fi

conda activate ctdna
conda config --add channels conda-forge || true
conda config --add channels bioconda || true

conda install -y \
  fastqc \
  multiqc \
  samtools \
  bcftools \
  bwa \
  bedtools \
  gatk4 \
  picard \
  sra-tools \
  entrez-direct \
  seqtk \
  mosdepth

echo "Environment ready. Activate with: conda activate ctdna"
