#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
INSTALL_PACKAGES=true
LINK_CONFIG=true

usage() {
  cat <<'EOF'
Usage: ./install.sh [--links-only | --packages-only]

  --links-only     Link configuration without installing Homebrew packages
  --packages-only  Install packages without changing configuration links
EOF
}

for arg in "$@"; do
  case "$arg" in
    --links-only) INSTALL_PACKAGES=false ;;
    --packages-only) LINK_CONFIG=false ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  if [[ "$(uname -s)" != Darwin ]]; then
    echo "Homebrew is required. Install it first: https://brew.sh" >&2
    exit 1
  fi

  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_packages() {
  install_homebrew
  echo "==> Installing Ghostty, Herdr, Neovim, and dependencies"
  brew bundle --file "$DOTFILES/Brewfile"
}

backup_path() {
  local path="$1"
  local backup
  backup="${path}.backup.$(date +%Y%m%d%H%M%S)"
  mv "$path" "$backup"
  echo "    backed up: $path -> $backup"
}

link_one() {
  local name="$1"
  local source="$DOTFILES/.config/$name"
  local target="$CONFIG_HOME/$name"

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    echo "    already linked: $target"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    backup_path "$target"
  fi

  ln -s "$source" "$target"
  echo "    linked: $target -> $source"
}

link_config() {
  echo "==> Linking configuration"
  mkdir -p "$CONFIG_HOME"
  link_one ghostty
  link_one herdr
  link_one nvim
}

$INSTALL_PACKAGES && install_packages
$LINK_CONFIG && link_config

echo "==> Done"
echo "Open Ghostty, then run: herdr"

