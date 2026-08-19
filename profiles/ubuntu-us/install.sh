#!/usr/bin/env bash
set -euo pipefail

PROFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
BIN_HOME="$HOME/.local/bin"
KEYBOARD="${INPUT_REMAPPER_DEVICE:-}"
PRESET_NAME="ubuntu-us"
STAMP="$(date +%Y%m%d%H%M%S)"

usage() {
  cat <<'EOF'
Usage: ./profiles/ubuntu-us/install.sh --keyboard DEVICE

Options:
  --keyboard DEVICE  Input Remapper device name
  -h, --help         Show this help

The INPUT_REMAPPER_DEVICE environment variable may be used instead.
EOF
}

while (($#)); do
  case "$1" in
    --keyboard)
      (($# >= 2)) || { echo "--keyboard requires a value" >&2; exit 2; }
      KEYBOARD="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[[ "$(uname -s)" == Linux ]] || {
  echo "This profile supports Ubuntu Linux only." >&2
  exit 1
}

[[ -n "$KEYBOARD" ]] || {
  echo "Specify the Input Remapper keyboard with --keyboard DEVICE." >&2
  echo "Run: input-remapper-control --list-devices" >&2
  exit 2
}

if [[ "$KEYBOARD" == "." || "$KEYBOARD" == ".." || "$KEYBOARD" == */* ||
      "$KEYBOARD" == *$'\n'* ]]; then
  echo "Invalid Input Remapper device name: $KEYBOARD" >&2
  exit 2
fi

for command in gdbus gsettings input-remapper-control jq python3 systemctl; do
  command -v "$command" >/dev/null 2>&1 || {
    echo "Required command not found: $command" >&2
    exit 1
  }
done

backup_path() {
  local target="$1"
  local backup="${target}.backup.${STAMP}"
  mv "$target" "$backup"
  echo "    backed up: $target -> $backup"
}

link_path() {
  local source="$1"
  local target="$2"
  local current

  mkdir -p "$(dirname "$target")"
  if [[ -L "$target" ]]; then
    current="$(readlink -f "$target" 2>/dev/null || true)"
    if [[ "$current" == "$(readlink -f "$source")" ]]; then
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

configure_input_remapper() {
  local config_dir="$CONFIG_HOME/input-remapper-2"
  local config_file="$config_dir/config.json"
  local preset_source="$PROFILE_DIR/files/input-remapper/ubuntu-us.json"
  local preset_target="$config_dir/presets/$KEYBOARD/$PRESET_NAME.json"
  local temporary

  link_path "$preset_source" "$preset_target"
  mkdir -p "$config_dir"
  temporary="$(mktemp "$config_dir/config.json.tmp.XXXXXX")"

  if [[ -f "$config_file" ]]; then
    jq --arg device "$KEYBOARD" --arg preset "$PRESET_NAME" '
      .version //= "2.0.1" |
      .autoload = (.autoload // {}) |
      .autoload[$device] = $preset
    ' "$config_file" > "$temporary"
  else
    jq -n --arg device "$KEYBOARD" --arg preset "$PRESET_NAME" '
      {version: "2.0.1", autoload: {($device): $preset}}
    ' > "$temporary"
  fi

  chmod 0644 "$temporary"
  mv "$temporary" "$config_file"

  if systemctl is-active --quiet input-remapper-daemon.service; then
    input-remapper-control --command autoload
  else
    echo "    input-remapper daemon is inactive; enable it before reboot." >&2
    echo "    sudo systemctl enable --now input-remapper-daemon.service" >&2
  fi
}

echo "==> Linking Ubuntu + US profile"
link_path \
  "$PROFILE_DIR/files/ghostty/config.ghostty" \
  "$CONFIG_HOME/ghostty/config.ghostty"
link_path \
  "$PROFILE_DIR/files/ghostty/ubuntu.ghostty" \
  "$CONFIG_HOME/ghostty/ubuntu.ghostty"
link_path \
  "$PROFILE_DIR/files/systemd/app-com.mitchellh.ghostty.service.d/override.conf" \
  "$CONFIG_HOME/systemd/user/app-com.mitchellh.ghostty.service.d/override.conf"
link_path \
  "$PROFILE_DIR/files/gnome-shell/ghostty-herdr-shortcut@local" \
  "$DATA_HOME/gnome-shell/extensions/ghostty-herdr-shortcut@local"
link_path \
  "$PROFILE_DIR/files/bin/close-gnome-search" \
  "$BIN_HOME/close-gnome-search"
link_path \
  "$PROFILE_DIR/files/mozc/ibus_config.textproto" \
  "$CONFIG_HOME/mozc/ibus_config.textproto"

echo "==> Configuring Input Remapper for: $KEYBOARD"
configure_input_remapper

echo "==> Applying GNOME and IBus settings"
"$PROFILE_DIR/apply-gnome.sh"

systemctl --user daemon-reload

echo "==> Ubuntu + US profile installed"
echo "Log out and back in once, then fully restart Ghostty."
echo "Configure the Mozc custom keys described in:"
echo "  $PROFILE_DIR/README.md"
