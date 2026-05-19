#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

TARGET=".volumes/seafile/data/seafile/conf/seahub_settings.py"
SNIPPET="conf/seafile/seahub_settings.oidc.py"
MARKER_BEGIN="# BEGIN DCU SEAFILE OIDC"
MARKER_END="# END DCU SEAFILE OIDC"

if [[ ! -f "$TARGET" ]]; then
  echo "Target not found: $TARGET" >&2
  echo "Start seafile once before applying OIDC." >&2
  exit 1
fi

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

awk -v begin="$MARKER_BEGIN" -v end="$MARKER_END" '
  $0 == begin { skip=1; next }
  $0 == end { skip=0; next }
  !skip { print }
' "$TARGET" > "$tmp_file"

{
  cat "$tmp_file"
  echo
  echo "$MARKER_BEGIN"
  cat "$SNIPPET"
  echo "$MARKER_END"
} > "$TARGET"

echo "OIDC block synced to $TARGET"
