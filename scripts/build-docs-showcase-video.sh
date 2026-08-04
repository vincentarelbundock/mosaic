#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="$repo_dir/docs/assets/images/showcase.webm"
poster="$repo_dir/docs/assets/images/showcase-poster.webp"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

# On-screen dwell per frame, in seconds. Steps of an incremental build play
# fast so the reveal reads as one animation; beats rest long enough to read.
beat_seconds=1.7
step_seconds=0.5
fade_seconds=0.35
width=1280
height=720
fps=25

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

# The reel is a crossfade chain. Every clip is held for its dwell plus one
# fade, so the fades overlap the neighbouring holds instead of eating them.
# A final clip repeating frame 0 for exactly one fade makes the loop seamless.
inputs=()
chain=""
for index in "${!frames[@]}"; do
  clip=$(awk "BEGIN { print ${dwells[$index]} + $fade_seconds }")
  inputs+=(-loop 1 -framerate "$fps" -t "$clip" -i "${frames[$index]}")
  chain+="[$index:v]fps=$fps,format=yuv420p,setsar=1,settb=AVTB[v$index];"
done
loop_index="${#frames[@]}"
inputs+=(-loop 1 -framerate "$fps" -t "$fade_seconds" -i "${frames[0]}")
chain+="[$loop_index:v]fps=$fps,format=yuv420p,setsar=1,settb=AVTB[v$loop_index];"

# Track the running length so each crossfade starts one fade before the end.
length="${dwells[0]}"
length=$(awk "BEGIN { print $length + $fade_seconds }")
previous="[v0]"
for ((index = 1; index <= loop_index; index += 1)); do
  offset=$(awk "BEGIN { printf \"%.3f\", $length - $fade_seconds }")
  label="[x$index]"
  chain+="${previous}[v$index]xfade=transition=fade:duration=$fade_seconds:offset=$offset$label;"
  previous="$label"
  clip="$fade_seconds"
  if ((index < loop_index)); then
    clip=$(awk "BEGIN { print ${dwells[$index]} + $fade_seconds }")
  fi
  length=$(awk "BEGIN { print $length + $clip - $fade_seconds }")
done
chain+="${previous}format=yuv420p[out]"

mkdir -p "$(dirname "$output")"
ffmpeg -hide_banner -loglevel error -y \
  "${inputs[@]}" \
  -filter_complex "$chain" \
  -map "[out]" \
  -an \
  -c:v libvpx-vp9 \
  -crf 34 \
  -b:v 0 \
  -pix_fmt yuv420p \
  -row-mt 1 \
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
