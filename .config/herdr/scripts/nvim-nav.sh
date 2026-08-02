#!/usr/bin/env bash
set -euo pipefail

dir="${1:-}"
case "$dir" in
	h) dir_name=left ;;
	j) dir_name=down ;;
	k) dir_name=up ;;
	l) dir_name=right ;;
	*)
		echo "usage: nvim-nav.sh h|j|k|l" >&2
		exit 2
		;;
esac

herdr_bin="${HERDR_BIN_PATH:-herdr}"

# nvim pane ならキーを転送し、window 移動と端の判定は nvim 側の keymap に委ねる
info="$("$herdr_bin" pane process-info --current 2>/dev/null || true)"
if printf '%s' "$info" | grep -qE '"name":"n?vim"'; then
	pane_id="$(printf '%s' "$info" \
		| sed -n 's/.*"pane_id":"\([^"]*\)".*/\1/p' | head -1)"
	if [ -n "$pane_id" ]; then
		exec "$herdr_bin" pane send-keys "$pane_id" "ctrl+$dir"
	fi
fi

exec "$herdr_bin" pane focus --direction "$dir_name" --current
