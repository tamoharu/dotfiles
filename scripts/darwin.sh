#!/usr/bin/env bash

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
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
  echo "==> Installing macOS packages"
  brew bundle --file "$DOTFILES/Brewfile"
  install_nvm
}
