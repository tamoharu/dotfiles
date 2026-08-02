#!/usr/bin/env bash

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CODEX_CONFIG_DIR="${CODEX_HOME:-$HOME/.codex}"

backup_path() {
  local path="$1"
  local backup="${path}.backup.$(date +%Y%m%d%H%M%S)"
  mv "$path" "$backup"
  echo "    backed up: $path -> $backup"
}

link_path() {
  local source="$1"
  local target="$2"
  local current_source

  mkdir -p "$(dirname "$target")"
  if [[ -L "$target" ]]; then
    current_source="$(readlink "$target")"
    if [[ "${current_source%/}" == "${source%/}" ]]; then
      echo "    already linked: $target"
      return
    fi
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    backup_path "$target"
  fi
  ln -s "$source" "$target"
  echo "    linked: $target -> $source"
}

is_linux_gui_config() {
  case "$1" in
    espanso|ghostty|hammerspoon|karabiner) return 0 ;;
    *) return 1 ;;
  esac
}

migrate_runtime_file() {
  local relative="$1"
  local current="$CONFIG_HOME/$relative"
  local destination="$DOTFILES/.config/$relative"

  # Runtime data may currently live behind a symlink to the legacy repository.
  # Preserve it in the new (gitignored) location before switching the link.
  if [[ -f "$current" && ! -e "$destination" ]]; then
    mkdir -p "$(dirname "$destination")"
    cp -p "$current" "$destination"
    echo "    migrated runtime data: $relative"
  fi
}

materialize_state_dir() {
  local name="$1"
  local target="$CONFIG_HOME/$name"
  local source

  # Some legacy app-state directories were symlinked into the old repository.
  # They contain credentials rather than portable config, so detach them from
  # dotfiles while preserving their contents in a normal local directory.
  if [[ -L "$target" ]]; then
    source="$(readlink "$target")"
    [[ "$source" == /* ]] || source="$(dirname "$target")/$source"
    backup_path "$target"
    mkdir -p "$target"
    cp -pR "$source"/. "$target"/
    echo "    materialized local state: $name"
  fi
}

link_config() {
  local dir name

  echo "==> Linking configuration"
  mkdir -p "$CONFIG_HOME"
  materialize_state_dir github-copilot
  migrate_runtime_file gh/hosts.yml
  migrate_runtime_file hunk/state.json
  migrate_runtime_file zsh/.zsh_history
  migrate_runtime_file zsh/local.zsh
  if [[ "$OS" == Darwin ]]; then
    migrate_runtime_file espanso/match/private.yml
  fi

  for dir in "$DOTFILES"/.config/*/; do
    [[ -d "$dir" ]] || continue
    name="$(basename "$dir")"

    # Codex contains credentials and sessions beside config.toml, so only link
    # that one file. Headless Linux does not need desktop-only configuration.
    if [[ "$name" == codex ]]; then
      continue
    fi
    if [[ "$OS" == Linux ]] && is_linux_gui_config "$name"; then
      echo "    skipped on Linux: $name"
      continue
    fi
    link_path "$dir" "$CONFIG_HOME/$name"
  done

  link_path "$DOTFILES/.config/zsh/.zshenv" "$HOME/.zshenv"
  link_path "$DOTFILES/.config/codex/config.toml" "$CODEX_CONFIG_DIR/config.toml"

  if [[ "$OS" == Darwin && -d "$DOTFILES/.config/espanso" ]]; then
    link_path "$DOTFILES/.config/espanso" "$HOME/Library/Application Support/espanso"
  fi
}

install_nvm() {
  export NVM_DIR="$HOME/.nvm"
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    echo "==> Installing nvm"
    PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh)"
  fi

  # shellcheck disable=SC1090
  source "$NVM_DIR/nvm.sh"
  nvm install 24
  nvm alias default 24
  npm install --global tree-sitter-cli
}

setup_zsh_plugins() {
  local plugin_root="$HOME/.local/share/zsh/plugins"
  mkdir -p "$plugin_root"
  if [[ ! -d "$plugin_root/pure/.git" ]]; then
    git clone https://github.com/sindresorhus/pure.git "$plugin_root/pure"
  fi
  if [[ ! -d "$plugin_root/zsh-completions/.git" ]]; then
    git clone https://github.com/zsh-users/zsh-completions.git "$plugin_root/zsh-completions"
  fi
}

post_install() {
  setup_zsh_plugins
}
