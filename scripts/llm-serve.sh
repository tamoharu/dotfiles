#!/bin/bash

# ====================
# Start llama-swap
# ====================
# LLM ホスト (MacBook-Pro-2023) でのみ実行する。install.sh からは呼ばれない。
#
#   ./scripts/llm-serve.sh
#
# フォアグラウンドで起動する。
# クライアント (opencode) からの自動起動は .config/zsh/conf.d/llm.zsh が行う。

set -e

if ! command -v llama-swap &>/dev/null; then
  echo "llama-swap not found. Run ./scripts/llm-host.sh first."
  exit 1
fi

exec llama-swap --config "$HOME/.config/llama-swap/config.yaml" --listen :8080 "$@"
