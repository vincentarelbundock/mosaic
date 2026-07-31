#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="$repo_dir/docs/assets/images/showcase.webm"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

# Keep this list explicit: it is the editorial selection shown on the home page.
slides=(
  # Getting started: title and rounded-grid slides of the first slideshow.
  "docs/assets/tutorials/basic/single.pdf|1"
  "docs/assets/tutorials/basic/single.pdf|4"
  # Cream example: title, agenda, team, gallery.
  "docs/examples/cream/cream.pdf|1"
  "docs/examples/cream/cream.pdf|2"
  "docs/examples/cream/cream.pdf|11"
  "docs/examples/cream/cream.pdf|17"
  # Metropolis example: title, then Bellman incremental math, every reveal frame.
  "docs/examples/metropolis/metropolis.pdf|1"
  "docs/examples/metropolis/metropolis.pdf|5"
  "docs/examples/metropolis/metropolis.pdf|6"
  "docs/examples/metropolis/metropolis.pdf|7"
  "docs/examples/metropolis/metropolis.pdf|8"
  # Metropolis example: Bloch-sphere geometry diagram, every reveal frame.
  "docs/examples/metropolis/metropolis.pdf|18"
  "docs/examples/metropolis/metropolis.pdf|19"
  "docs/examples/metropolis/metropolis.pdf|20"
  "docs/examples/metropolis/metropolis.pdf|21"
  # Minimalist example: title, portrait, history, statistics.
  "docs/examples/minimalist/minimalist.pdf|1"
  "docs/examples/minimalist/minimalist.pdf|5"
  "docs/examples/minimalist/minimalist.pdf|8"
  "docs/examples/minimalist/minimalist.pdf|16"
)

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "showcase: FFmpeg is required" >&2
  exit 1
fi

if ! command -v pdftoppm >/dev/null 2>&1; then
  echo "showcase: Poppler's 'pdftoppm' command is required" >&2
  exit 1
fi

# FFmpeg has no SVG decoder, so slides exported as SVG are rasterized first.
# resvg is preferred because it is the same renderer Typst uses internally.
if command -v resvg >/dev/null 2>&1; then
  svg_raster="resvg"
elif command -v rsvg-convert >/dev/null 2>&1; then
  svg_raster="rsvg-convert"
elif command -v magick >/dev/null 2>&1; then
  svg_raster="magick"
elif command -v convert >/dev/null 2>&1; then
  svg_raster="convert"
else
  echo "showcase: an SVG rasterizer is required (resvg, rsvg-convert, or ImageMagick)" >&2
  exit 1
fi

# Rasterize an SVG to PNG at 1920px wide for a crisp downscale to 960px.
rasterize_svg() {
  case "$svg_raster" in
    resvg) resvg -w 1920 "$1" "$2" ;;
    rsvg-convert) rsvg-convert -w 1920 "$1" -o "$2" ;;
    magick) magick -density 192 -background none "$1" "$2" ;;
    convert) convert -density 192 -background none "$1" "$2" ;;
  esac
}

frames=()
for index in "${!slides[@]}"; do
  IFS="|" read -r relative page <<<"${slides[$index]}"
  source="$repo_dir/$relative"
  frame="$work_dir/frame-$(printf '%02d' "$index").png"

  if [[ ! -f "$source" ]]; then
    echo "showcase: missing slide: $relative" >&2
    exit 1
  fi

  render_source="$source"
  if [[ -n "$page" ]]; then
    page_prefix="$work_dir/pdf-page-$(printf '%02d' "$index")"
    pdftoppm -f "$page" -l "$page" -singlefile -png -r 144 \
      "$source" "$page_prefix"
    render_source="$page_prefix.png"
  elif [[ "$source" == *.svg ]]; then
    raster="$work_dir/svg-$(printf '%02d' "$index").png"
    rasterize_svg "$source" "$raster"
    render_source="$raster"
  fi

  ffmpeg -hide_banner -loglevel error -y \
    -i "$render_source" \
    -vf 'scale=960:540:flags=lanczos,format=rgb24' \
    -frames:v 1 \
    "$frame"
  frames+=("$frame")
done

manifest="$work_dir/frames.txt"
for frame in "${frames[@]}"; do
  printf "file '%s'\nduration 1.8\n" "$frame" >>"$manifest"
done
# The concat demuxer needs the final frame repeated to honor its duration.
printf "file '%s'\n" "${frames[-1]}" >>"$manifest"

mkdir -p "$(dirname "$output")"
ffmpeg -hide_banner -loglevel error -y \
  -f concat \
  -safe 0 \
  -i "$manifest" \
  -an \
  -c:v libvpx-vp9 \
  -crf 32 \
  -b:v 0 \
  -pix_fmt yuv420p \
  -row-mt 1 \
  "$output"

echo "showcase: wrote ${output#"$repo_dir/"}"
