#!/usr/bin/env bash

GHQ_VERSION="1.10.1"
HERDR_VERSION="0.7.5"
HUNK_VERSION="0.17.0"
LAZYGIT_VERSION="0.63.1"
NEOVIM_VERSION="0.12.4"
OPENCODE_VERSION="1.18.11"
TAILSPIN_VERSION="7.0.0"
YAZI_VERSION="26.5.6"

linux_arch() {
  case "$(uname -m)" in
    x86_64) echo x64 ;;
    aarch64|arm64) echo arm64 ;;
    *) echo "Unsupported Linux architecture: $(uname -m)" >&2; return 1 ;;
  esac
}

github_arch() {
  [[ "$(linux_arch)" == x64 ]] && echo x86_64 || echo aarch64
}

install_file() {
  local url="$1" target="$2" tmp
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/download"
  install -m 755 "$tmp/download" "$target"
  rm -rf "$tmp"
}

install_tar_binary() {
  local url="$1" binary="$2" target_name="${3:-$2}" tmp source
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/archive.tar.gz"
  tar -xzf "$tmp/archive.tar.gz" -C "$tmp"
  source="$(find "$tmp" -type f -name "$binary" -perm -u+x -print -quit)"
  [[ -n "$source" ]] || { echo "Binary $binary not found in $url" >&2; return 1; }
  install -m 755 "$source" "$HOME/.local/bin/$target_name"
  rm -rf "$tmp"
}

install_neovim() {
  local arch archive_dir tmp install_dir
  arch="$(linux_arch)"
  [[ "$arch" == x64 ]] && arch=x86_64
  archive_dir="nvim-linux-$arch"
  install_dir="$HOME/.local/opt/nvim-$NEOVIM_VERSION"
  if [[ -x "$install_dir/bin/nvim" ]]; then
    ln -sfn "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"
    return
  fi

  tmp="$(mktemp -d)"
  curl -fsSL \
    "https://github.com/neovim/neovim/releases/download/v$NEOVIM_VERSION/$archive_dir.tar.gz" \
    -o "$tmp/nvim.tar.gz"
  tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"
  mkdir -p "$HOME/.local/opt"
  mv "$tmp/$archive_dir" "$install_dir"
  ln -sfn "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$tmp"
}

install_yazi() {
  local arch deb tmp
  arch="$(github_arch)"
  tmp="$(mktemp -d)"
  deb="$tmp/yazi.deb"
  curl -fsSL \
    "https://github.com/sxyazi/yazi/releases/download/v$YAZI_VERSION/yazi-$arch-unknown-linux-gnu.deb" \
    -o "$deb"
  sudo apt-get install -y "$deb"
  rm -rf "$tmp"
}

install_linux_binaries() {
  local arch ghq_arch
  arch="$(linux_arch)"
  ghq_arch="$arch"
  [[ "$ghq_arch" == x64 ]] && ghq_arch=amd64

  install_file \
    "https://github.com/herdrdev/herdr/releases/download/v$HERDR_VERSION/herdr-linux-$(github_arch)" \
    "$HOME/.local/bin/herdr"
  install_tar_binary \
    "https://github.com/modem-dev/hunk/releases/download/v$HUNK_VERSION/hunkdiff-linux-$arch.tar.gz" \
    hunk
  install_tar_binary \
    "https://github.com/jesseduffield/lazygit/releases/download/v$LAZYGIT_VERSION/lazygit_${LAZYGIT_VERSION}_linux_$([[ "$arch" == x64 ]] && echo x86_64 || echo arm64).tar.gz" \
    lazygit
  install_tar_binary \
    "https://github.com/anomalyco/opencode/releases/download/v$OPENCODE_VERSION/opencode-linux-$arch.tar.gz" \
    opencode

  local tailspin_arch
  [[ "$arch" == x64 ]] && tailspin_arch=x86_64 || tailspin_arch=aarch64
  install_tar_binary \
    "https://github.com/bensadeh/tailspin/releases/download/$TAILSPIN_VERSION/tailspin-$tailspin_arch-unknown-linux-musl.tar.gz" \
    tspin

  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL \
    "https://github.com/x-motemen/ghq/releases/download/v$GHQ_VERSION/ghq_linux_${ghq_arch}.zip" \
    -o "$tmp/ghq.zip"
  unzip -q "$tmp/ghq.zip" -d "$tmp"
  install -m 755 "$tmp/ghq_linux_${ghq_arch}/ghq" "$HOME/.local/bin/ghq"
  rm -rf "$tmp"
}

install_codex() {
  command -v codex >/dev/null 2>&1 && return
  echo "==> Installing Codex CLI"
  curl -fsSL https://chatgpt.com/codex/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
}

install_packages() {
  echo "==> Installing Ubuntu packages"
  sudo apt-get update
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    autoconf bison btop build-essential curl direnv fd-find ffmpeg file fzf \
    gh git git-lfs imagemagick jq libffi-dev libgdbm-dev libncurses-dev \
    libreadline-dev libssl-dev libyaml-dev locales p7zip-full poppler-utils \
    ripgrep trash-cli tree unzip wget xclip zlib1g-dev zoxide zsh \
    zsh-autosuggestions zsh-syntax-highlighting
  sudo locale-gen en_US.UTF-8

  mkdir -p "$HOME/.local/bin" "$HOME/.local/opt"
  [[ -x "$HOME/.local/bin/fd" ]] || ln -sfn /usr/bin/fdfind "$HOME/.local/bin/fd"
  export PATH="$HOME/.local/bin:$PATH"

  install_neovim
  install_yazi
  install_linux_binaries
  install_codex
  install_nvm

  if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    sudo chsh -s "$(command -v zsh)" "$USER"
  fi
}
