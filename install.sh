#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES
OS="$(uname -s)"
INSTALL_PACKAGES=true
LINK_CONFIG=true

usage() {
  cat <<'EOF'
Usage: ./install.sh [--links-only | --packages-only]

  --links-only     Link configuration without installing packages
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

# shellcheck source=scripts/common.sh
source "$DOTFILES/scripts/common.sh"
case "$OS" in
  Darwin)
    # shellcheck source=scripts/darwin.sh
    source "$DOTFILES/scripts/darwin.sh"
    ;;
  Linux)
    # shellcheck source=scripts/linux.sh
    source "$DOTFILES/scripts/linux.sh"
    ;;
  *)
    echo "Unsupported OS: $OS" >&2
    exit 1
    ;;
esac

$INSTALL_PACKAGES && install_packages
$LINK_CONFIG && link_config
$INSTALL_PACKAGES && post_install

echo "==> Setup complete"
if [[ "$OS" == Linux ]]; then
  echo "Reconnect to SSH (or run: exec zsh), then authenticate tools as needed:"
  echo "  codex login --device-auth"
  echo "  gh auth login"
else
  echo "Open Ghostty, then run: herdr"
fi
