#!/bin/bash

# ====================
# Fetch GGUF models
# ====================
# LLM ホスト (MacBook-Pro-2023) でのみ実行する。install.sh からは呼ばれない。
#
#   ./scripts/llm-fetch.sh
#
# モデルは ~/models/<subdir>/<file> に配置する。
# 配置先は .config/llama-swap/config.yaml の model-dir と対応する。
# 中断しても再実行でレジューム (curl -C -) する。

set -e

MODELS=(
  "unsloth/Qwen3.6-35B-A3B-GGUF Qwen3.6-35B-A3B-Q8_0.gguf Qwen3.6-35B-A3B"
  "unsloth/Qwen3.6-35B-A3B-GGUF mmproj-F16.gguf Qwen3.6-35B-A3B"
  "HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q8_K_P.gguf Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive"
  "HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive mmproj-Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-f16.gguf Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive"
)

echo "=== Fetching models into $HOME/models ==="

for m in "${MODELS[@]}"; do
  read -r repo file subdir <<< "$m"
  echo "  [fetch] $subdir/$file"
  curl -L -C - --retry 1000 --retry-delay 3 --retry-all-errors --speed-limit 500000 --speed-time 30 \
    --create-dirs -o "$HOME/models/$subdir/$file" "https://huggingface.co/$repo/resolve/main/$file"
done

echo ""
echo "=== Fetch complete! ==="
