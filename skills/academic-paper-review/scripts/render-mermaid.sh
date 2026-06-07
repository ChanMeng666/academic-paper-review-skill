#!/usr/bin/env bash
# Render every Mermaid (.mmd) source in a folder to a high-res PNG with the
# review document's standard settings (white background, 3× scale).
#
# Usage:   bash render-mermaid.sh [SRC_DIR] [OUT_DIR]
# Default: SRC_DIR=assets/mermaid  OUT_DIR=assets/figures
# Requires the Mermaid CLI:  npm i -g @mermaid-js/mermaid-cli   (provides `mmdc`)

set -euo pipefail
SRC="${1:-assets/mermaid}"
OUT="${2:-assets/figures}"
mkdir -p "$OUT"

shopt -s nullglob
files=("$SRC"/*.mmd)
if [ ${#files[@]} -eq 0 ]; then
  echo "No .mmd files in $SRC" >&2
  exit 1
fi

for f in "${files[@]}"; do
  name="$(basename "$f" .mmd)"
  mmdc -i "$f" -o "$OUT/$name.png" -b white -s 3
  echo "rendered  $name.png"
done
echo "Done → $OUT"

# PowerShell equivalent (one diagram):
#   mmdc -i assets/mermaid/review-methodology.mmd -o assets/figures/review-methodology.png -b white -s 3
