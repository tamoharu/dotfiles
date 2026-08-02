#!/usr/bin/env bash
set -euo pipefail

if (( $# == 0 )); then
  echo "Usage: open-bottom-pane.sh <command> [args...]" >&2
  exit 2
fi

: "${HERDR_BIN_PATH:?HERDR_BIN_PATH is not set}"
: "${HERDR_ACTIVE_PANE_ID:?HERDR_ACTIVE_PANE_ID is not set}"

split_json="$("$HERDR_BIN_PATH" pane split \
  --pane "$HERDR_ACTIVE_PANE_ID" \
  --direction down \
  --ratio 0.3 \
  --focus)"
pane_id="$(jq -er '.result.pane.pane_id' <<<"$split_json")"

"$HERDR_BIN_PATH" pane run "$pane_id" "$@"
