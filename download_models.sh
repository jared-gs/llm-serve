#!/usr/bin/env bash
# download_models.sh
# Usage (local tests):
# HF_TOKEN=xxxxx ./download_models.sh
# Usage (Docker):
# docker build --build-arg HF_TOKEN=xxxxx . 

set -euo pipefail

export HF_HOME=${HF_HOME:-/opt/hf-cache}
mkdir -p "$HF_HOME"

if [[ -n "${HF_TOKEN:-}" ]]; then
  huggingface-cli login --token "${HF_TOKEN}"
fi

# Download Llama-3.1-8B model
huggingface-cli download meta-llama/Llama-3.1-8B \
  --local-dir "$HF_HOME/models--meta-llama--Llama-3.1-8B" \
  --local-dir-use-symlinks False # forces real files instead of LFS pointers

# Download Phi-4-mini-instruct model
# huggingface-cli download microsoft/Phi-4-mini-instruct \
#   --local-dir "$HF_HOME/models--microsoft--Phi-4-mini-instruct" \
#   --local-dir-use-symlinks False # forces real files instead of LFS pointers

# Example extras (uncomment if you need them)
# huggingface-cli download distilbert/distilgpt2 \
#   --local-dir "$HF_HOME/models--distilbert--distilgpt2" \
#   --local-dir-use-symlinks False
