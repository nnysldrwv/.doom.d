#!/usr/bin/env bash
# Migrate org-mode TODO keywords to new scheme:
#   DOING     -> PROG
#   WAITING   -> TODO
#   HOLD      -> TODO
#   DROPPED   -> FAIL
#   CANCELLED -> FAIL
#   TODO/NEXT/DONE/PROG/FAIL stay as-is

set -euo pipefail

# Use Git for Windows GNU find to avoid Windows FIND.EXE hijack
GNU_FIND="/usr/bin/find"
if [[ ! -x "$GNU_FIND" ]]; then
  echo "ERROR: GNU find not found at $GNU_FIND" >&2
  exit 1
fi

# Directories to scan (add more as needed)
# Derive home dir from script location (~/.doom.d/../)
DOOM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$(dirname "$DOOM_DIR")"

echo "Detected home: $HOME_DIR"

DIRS=(
  "$HOME_DIR/org"
  "$DOOM_DIR"
)

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "[DRY RUN] no files will be modified"
fi

echo "Scanning directories:"
for dir in "${DIRS[@]}"; do
  if [[ -d "$dir" ]]; then
    echo "  [found] $dir"
  else
    echo "  [skip]  $dir (not found)"
  fi
done

find_org_files() {
  for dir in "${DIRS[@]}"; do
    [[ -d "$dir" ]] || continue
    "$GNU_FIND" "$dir" -name "*.org" -type f
  done
}

migrate_file() {
  local file="$1"

  if ! grep -qP '^\*+ (DOING|WAITING|HOLD|DROPPED|CANCELLED)\b' "$file" 2>/dev/null; then
    return 0
  fi

  if $DRY_RUN; then
    echo "[would modify] $file"
    grep -nP '^\*+ (DOING|WAITING|HOLD|DROPPED|CANCELLED)\b' "$file" | head -5
    return 0
  fi

  perl -i -pe '
    s/^(\*+ )CANCELLED\b/$1FAIL/g;
    s/^(\*+ )DROPPED\b/$1FAIL/g;
    s/^(\*+ )WAITING\b/$1TODO/g;
    s/^(\*+ )HOLD\b/$1TODO/g;
    s/^(\*+ )DOING\b/$1PROG/g;
  ' "$file"

  echo "[migrated] $file"
}

count=0
while IFS= read -r f; do
  migrate_file "$f"
  ((count++)) || true
done < <(find_org_files)

echo "Scanned $count org files."
