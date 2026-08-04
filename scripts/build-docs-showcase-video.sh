#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="$repo_dir/docs/assets/images/showcase.webm"
poster="$repo_dir/docs/assets/images/showcase-poster.webp"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

# On-screen dwell per frame, in seconds. Steps of an incremental build play
# fast so the reveal reads as one animation; beats rest long enough to read.
beat_seconds=1.4
step_seconds=0.5
width=1280
height=720
fps=20

if [[ "$#" -gt 0 ]]; then
  python_cmd=("$@")
else
  python_cmd=(uv run python)
fi

slides_file="$work_dir/slides.txt"
"${python_cmd[@]}" "$repo_dir/scripts/deck_metadata.py" showcase >"$slides_file"
mapfile -t slides <"$slides_file"
if [[ "${#slides[@]}" -lt 2 ]]; then
  echo "showcase: deck manifest selected fewer than two slides" >&2
  exit 1
fi

for tool in ffmpeg pdftoppm; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "showcase: $tool is required" >&2
    exit 1
  fi
done

frames=()
dwells=()
for index in "${!slides[@]}"; do
  IFS="|" read -r relative page kind <<<"${slides[$index]}"
  source="$repo_dir/$relative"
  frame="$work_dir/frame-$(printf '%02d' "$index").png"

  if [[ ! -f "$source" ]]; then
    echo "showcase: missing slide: $relative" >&2
    exit 1
  fi

  case "$kind" in
    step) dwells+=("$step_seconds") ;;
    beat) dwells+=("$beat_seconds") ;;
    *)
      echo "showcase: unknown frame kind: $kind" >&2
      exit 1
      ;;
  esac

  # Render above the target size, then downsample with lanczos so small type
  # in dense slides survives the scale.
  pdftoppm -f "$page" -l "$page" -singlefile -png -r 192 "$source" "${frame%.png}-full"
  ffmpeg -hide_banner -loglevel error -y \
    -i "${frame%.png}-full.png" \
    -vf "scale=$width:$height:flags=lanczos,setsar=1,format=rgb24" \
    -frames:v 1 \
    "$frame"
  frames+=("$frame")
done

# Slides cut straight from one to the next: no fades, no motion, just a hold
# per frame. The concat demuxer needs the final frame repeated to honor its
# duration.
manifest="$work_dir/frames.txt"
length=0
for index in "${!frames[@]}"; do
  printf "file '%s'\nduration %s\n" "${frames[$index]}" "${dwells[$index]}" >>"$manifest"
  length=$(awk "BEGIN { print $length + ${dwells[$index]} }")
done
printf "file '%s'\n" "${frames[-1]}" >>"$manifest"

mkdir -p "$(dirname "$output")"
ffmpeg -hide_banner -loglevel error -y \
  -f concat \
  -safe 0 \
  -i "$manifest" \
  -vf "fps=$fps,format=yuv420p" \
  -an \
  -c:v libvpx-vp9 \
  -crf 40 \
  -b:v 0 \
  -pix_fmt yuv420p \
  -row-mt 1 \
  -auto-alt-ref 1 \
  -lag-in-frames 20 \
  "$output"

# The poster is the first frame itself, so the still shown before playback and
# under prefers-reduced-motion matches where the reel starts.
ffmpeg -hide_banner -loglevel error -y \
  -i "${frames[0]}" \
  -frames:v 1 \
  -quality 82 \
  "$poster"

echo "showcase: wrote ${output#"$repo_dir/"} ($(awk "BEGIN { printf \"%.1f\", $length }")s, ${#frames[@]} frames)"
echo "showcase: wrote ${poster#"$repo_dir/"}"
