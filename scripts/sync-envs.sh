#!/bin/bash
#
# Usage:
# - ./scripts/sync-envs.sh backup    # ghq → iCloud
# - ./scripts/sync-envs.sh restore   # iCloud → ghq

set -euo pipefail

GHQ_ROOT="${GHQ_ROOT:-$HOME/ghq}"
SYNC_ROOT="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Documents/.envs"

find_env_files() {
  local root="$1"
  find "$root" -type f \
    \( -name '.env' -o -name '.env.*' -o -name '.envrc' \) \
    ! -name '*.example' \
    ! -path '*/node_modules/*' \
    ! -path '*/.git/*'
}

backup() {
  [ -d "$GHQ_ROOT" ] || { echo "ghq root not found: $GHQ_ROOT" >&2; exit 1; }
  mkdir -p "$SYNC_ROOT"
  local count=0
  while IFS= read -r src; do
    local rel="${src#"$GHQ_ROOT"/}"
    local dst="$SYNC_ROOT/$rel"
    mkdir -p "$(dirname "$dst")"
    cp -p "$src" "$dst"
    echo "backed up: $rel"
    count=$((count + 1))
  done < <(find_env_files "$GHQ_ROOT")
  echo "---"
  echo "Total: $count files → $SYNC_ROOT"
}

restore() {
  [ -d "$SYNC_ROOT" ] || { echo "sync root not found: $SYNC_ROOT" >&2; exit 1; }
  mkdir -p "$GHQ_ROOT"
  local restored=0 skipped=0
  while IFS= read -r src; do
    local rel="${src#"$SYNC_ROOT"/}"
    local dst="$GHQ_ROOT/$rel"
    local proj_dir
    proj_dir="$(dirname "$dst")"
    if [ -d "$proj_dir" ]; then
      cp -p "$src" "$dst"
      echo "restored: $rel"
      restored=$((restored + 1))
    else
      echo "skip (no project dir): $rel"
      skipped=$((skipped + 1))
    fi
  done < <(find_env_files "$SYNC_ROOT")
  echo "---"
  echo "Restored: $restored, Skipped: $skipped"
  [ "$skipped" -eq 0 ] || echo "→ run \`ghq get\` to clone the missing projects, then re-run restore"
}

case "${1:-}" in
  backup)  backup ;;
  restore) restore ;;
  *) echo "Usage: $0 {backup|restore}" >&2; exit 1 ;;
esac
