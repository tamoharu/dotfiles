# Local LLM client
#
# LLM ホストは MacBook-Pro-2023 (tailscale 経由)。
# 接続先 LLM_URL は .zshenv で定義する。
# opencode.json が {env:LLM_URL} で参照するため、非対話シェルにも必要。
#
# ホスト側のセットアップと運用は dotfiles の scripts/ を参照:
#   scripts/llm-host.sh   初期セットアップ
#   scripts/llm-fetch.sh  モデル取得
#   scripts/llm-serve.sh  llama-swap 起動

# opencode 起動前に LLM ホストの llama-swap を起こす
opencode() {
  if ! curl -sf -m2 "$LLM_URL/health" >/dev/null 2>&1; then
    if command -v llama-swap &>/dev/null; then
      # 自機が LLM ホスト
      nohup llama-swap --config "$HOME/.config/llama-swap/config.yaml" --listen :8080 \
        >/tmp/llama-swap.log 2>&1 &
      disown
    else
      ssh MacBook-Pro-2023 'nohup ~/.local/bin/llama-swap --config ~/.config/llama-swap/config.yaml --listen :8080 >/tmp/llama-swap.log 2>&1 & disown'
    fi
    curl -sf -m2 --retry 30 --retry-delay 1 --retry-connrefused --retry-all-errors \
      "$LLM_URL/health" >/dev/null 2>&1
  fi
  command opencode "$@"
}
