#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

TARGET=".volumes/seafile/data/seafile/conf/seahub_settings.py"
SNIPPET="conf/seafile/seahub_settings.oidc.py"
MARKER="# BEGIN DCU SEAFILE OIDC"

if [[ ! -f "$TARGET" ]]; then
  echo "Target not found: $TARGET" >&2
  echo "Start seafile once before applying OIDC." >&2
  exit 1
fi

if grep -Fq "$MARKER" "$TARGET"; then
  echo "OIDC block already present in $TARGET"
  exit 0
fi

{
  echo
  echo "$MARKER"
  cat "$SNIPPET"
  echo "# END DCU SEAFILE OIDC"
} >> "$TARGET"

echo "OIDC block appended to $TARGET"
