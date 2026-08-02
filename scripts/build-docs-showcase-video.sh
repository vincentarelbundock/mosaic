#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="$repo_dir/docs/assets/images/showcase.webm"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

if [[ "$#" -gt 0 ]]; then
  python_cmd=("$@")
else
  python_cmd=(uv run python)
fi

slides_file="$work_dir/slides.txt"
"${python_cmd[@]}" "$repo_dir/scripts/deck_metadata.py" showcase >"$slides_file"
mapfile -t slides <"$slides_file"
if [[ "${#slides[@]}" -eq 0 ]]; then
  echo "showcase: deck manifest selected no slides" >&2
  exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "showcase: FFmpeg is required" >&2
  exit 1
fi

if ! command -v pdftoppm >/dev/null 2>&1; then
  echo "showcase: Poppler's 'pdftoppm' command is required" >&2
  exit 1
fi

frames=()
for index in "${!slides[@]}"; do
  IFS="|" read -r relative page <<<"${slides[$index]}"
  source="$repo_dir/$relative"
  frame="$work_dir/frame-$(printf '%02d' "$index").png"

  if [[ ! -f "$source" ]]; then
    echo "showcase: missing slide: $relative" >&2
    exit 1
  fi

  page_prefix="$work_dir/pdf-page-$(printf '%02d' "$index")"
  pdftoppm -f "$page" -l "$page" -singlefile -png -r 144 \
    "$source" "$page_prefix"
  render_source="$page_prefix.png"

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
