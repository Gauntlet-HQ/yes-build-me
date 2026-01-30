#!/usr/bin/env bash
set -euo pipefail

# Render all SVGs in the business deck assets directory to PNG
# Usage: scripts/bash/render-png-assets.sh [assets-dir]

ASSETS_DIR=${1:-docs/presentations/gobuildme-business-deck/assets}
OUT_DIR="$ASSETS_DIR/png"
mkdir -p "$OUT_DIR"

have() { command -v "$1" >/dev/null 2>&1; }

render_svg() {
  local in=$1
  local out=$2
  if have rsvg-convert; then
    rsvg-convert -w 1600 "$in" -o "$out"
  elif have inkscape; then
    inkscape "$in" --export-type=png -o "$out" -w 1600 >/dev/null 2>&1
  elif have magick; then
    magick -density 300 "$in" -resize 1600x "$out"
  else
    echo "No renderer found. Install one of: librsvg (rsvg-convert), Inkscape, or ImageMagick (magick)." >&2
    exit 1
  fi
}

shopt -s nullglob
for svg in "$ASSETS_DIR"/*.svg; do
  base=$(basename "$svg" .svg)
  out="$OUT_DIR/$base.png"
  echo "Rendering $svg -> $out"
  render_svg "$svg" "$out"
done
echo "Done. PNGs at $OUT_DIR"

