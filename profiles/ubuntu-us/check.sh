#!/usr/bin/env bash
set -euo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
KEYBOARD="${INPUT_REMAPPER_DEVICE:-}"
CUSTOM_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/caps-close-search/"
FAILED=0

usage() {
  echo "Usage: ./profiles/ubuntu-us/check.sh --keyboard DEVICE"
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

[[ -n "$KEYBOARD" ]] || {
  echo "Specify --keyboard DEVICE." >&2
  exit 2
}

pass() {
  echo "  ok: $1"
}

fail() {
  echo "  FAIL: $1" >&2
  FAILED=1
}

expect_setting() {
  local schema="$1" key="$2" expected="$3" actual
  actual="$(gsettings get "$schema" "$key")"
  if [[ "$actual" == "$expected" ]]; then
    pass "$schema $key"
  else
    fail "$schema $key (got: $actual)"
  fi
}

expect_setting_contains() {
  local schema="$1" key="$2" expected="$3" actual
  actual="$(gsettings get "$schema" "$key")"
  if [[ "$actual" == *"$expected"* ]]; then
    pass "$schema $key contains $expected"
  else
    fail "$schema $key is missing $expected (got: $actual)"
  fi
}

echo "==> Checking Ubuntu + US profile"

PRESET="$CONFIG_HOME/input-remapper-2/presets/$KEYBOARD/ubuntu-us.json"
if [[ -e "$PRESET" ]] && jq -e '
    length == 4 and
    .[0].output_symbol == "KEY_MUHENKAN" and
    .[1].output_symbol == "KEY_HENKAN" and
    .[2].output_symbol == "KEY_SEARCH" and
    .[3].output_symbol == "if_single(key(KEY_F14),None)"
  ' "$PRESET" >/dev/null; then
  pass "Input Remapper preset"
else
  fail "Input Remapper preset"
fi

if jq -e --arg device "$KEYBOARD" \
    '.autoload[$device] == "ubuntu-us"' \
    "$CONFIG_HOME/input-remapper-2/config.json" >/dev/null; then
  pass "Input Remapper autoload"
else
  fail "Input Remapper autoload"
fi

if systemctl is-active --quiet input-remapper-daemon.service; then
  pass "Input Remapper daemon"
else
  fail "Input Remapper daemon"
fi

expect_setting_contains org.gnome.desktop.wm.keybindings switch-applications \
  '<Super>Tab'
expect_setting_contains \
  org.gnome.desktop.wm.keybindings switch-applications-backward \
  '<Shift><Super>Tab'
expect_setting_contains \
  org.gnome.settings-daemon.plugins.media-keys search-static \
  'XF86Search'
expect_setting org.gnome.desktop.input-sources sources \
  "[('ibus', 'mozc-jp')]"
expect_setting org.freedesktop.ibus.general use-xmodmap 'false'
expect_setting \
  "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$CUSTOM_PATH" \
  binding "'XF86Launch5'"
expect_setting \
  "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$CUSTOM_PATH" \
  command "'$HOME/.local/bin/close-gnome-search'"

if [[ -x "$HOME/.local/bin/close-gnome-search" ]]; then
  pass "CapsLock close-search helper"
else
  fail "CapsLock close-search helper"
fi

if command -v ghostty >/dev/null 2>&1 && \
    ghostty +validate-config \
      --config-file="$CONFIG_HOME/ghostty/config.ghostty" >/dev/null; then
  pass "Ghostty configuration"
else
  fail "Ghostty configuration"
fi

EXTENSION_INFO="$(gnome-extensions info ghostty-herdr-shortcut@local 2>/dev/null || true)"
if [[ "$EXTENSION_INFO" == *'State: ACTIVE'* ]]; then
  pass "GNOME Shell extension is active"
elif [[ "$EXTENSION_INFO" == *'Enabled: Yes'* ]]; then
  echo "  note: GNOME Shell extension is enabled but needs logout/login"
else
  fail "GNOME Shell extension is not enabled"
fi

if ((FAILED)); then
  exit 1
fi

echo "==> All required configuration checks passed"
