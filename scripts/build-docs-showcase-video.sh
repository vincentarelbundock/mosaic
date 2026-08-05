#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="$repo_dir/docs/assets/images/showcase.webm"
poster="$repo_dir/docs/assets/images/showcase-poster.webp"
# One still holding every slide the reel visits, three across. Incremental
# builds contribute only their completed frame, so the sheet reads as one
# slide per beat.
sheet="$repo_dir/docs/assets/images/showcase-contact-sheet.webp"
# Records what the committed reel was encoded from. Slide PDFs are rebuilt with
# fresh metadata on every docs build, so their bytes cannot answer "did the
# slides change?"; the rendered frames can, and they are what the reel shows.
fingerprint_file="$repo_dir/docs/assets/images/showcase.fingerprint"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

# On-screen dwell per frame, in seconds. Steps of an incremental build play
# fast so the reveal reads as one animation; beats rest long enough to read.
beat_seconds=1.4
step_seconds=0.5
width=1280
height=720
fps=20
crf=40

# Contact-sheet geometry: three columns of half-size frames, separated and
# framed by the same gap so no slide edge touches another.
sheet_columns=3
sheet_cell_width=640
sheet_cell_height=360
sheet_gap=12
sheet_quality=80

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
beats=()
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
    beat)
      dwells+=("$beat_seconds")
      beats+=("$frame")
      ;;
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

# Everything that can change a pixel of the encoded reel or the contact sheet:
# the frames themselves, how long each is held, and the encoder and sheet
# settings.
fingerprint="$(
  {
    printf 'v2 %s %s %s %s\n' "$width" "$height" "$fps" "$crf"
    printf 'sheet %s %s %s %s %s\n' \
      "$sheet_columns" "$sheet_cell_width" "$sheet_cell_height" "$sheet_gap" "$sheet_quality"
    for index in "${!frames[@]}"; do
      printf '%s %s\n' "${dwells[$index]}" "$(sha256sum <"${frames[$index]}" | cut -d' ' -f1)"
    done
  } | sha256sum | cut -d' ' -f1
)"

if [[ -f "$fingerprint_file" && -f "$output" && -f "$poster" && -f "$sheet" ]] &&
  [[ "$(cat "$fingerprint_file")" == "$fingerprint" ]]; then
  # Bump the mtimes so Make stops asking, but leave the bytes alone: an
  # identical re-encode would still differ byte for byte and dirty the tree.
  touch "$output" "$poster" "$sheet" "$fingerprint_file"
  echo "showcase: slides unchanged, kept ${output#"$repo_dir/"}"
  exit 0
fi

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
  -crf "$crf" \
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

# The contact sheet holds one cell per beat: a step of an incremental build is
# an unfinished slide, so only the frame the reel rests on earns a cell. The
# tile filter fills any short trailing row with transparent padding, so the
# sheet sits on the page background whatever its polarity.
sheet_rows=$(((${#beats[@]} + sheet_columns - 1) / sheet_columns))
sheet_dir="$work_dir/sheet"
mkdir -p "$sheet_dir"
for index in "${!beats[@]}"; do
  cp "${beats[$index]}" "$sheet_dir/beat-$(printf '%03d' "$index").png"
done

ffmpeg -hide_banner -loglevel error -y \
  -start_number 0 \
  -i "$sheet_dir/beat-%03d.png" \
  -vf "scale=$sheet_cell_width:$sheet_cell_height:flags=lanczos,setsar=1,format=rgba,tile=${sheet_columns}x${sheet_rows}:margin=$sheet_gap:padding=$sheet_gap:color=#00000000" \
  -frames:v 1 \
  -quality "$sheet_quality" \
  "$sheet"

printf '%s\n' "$fingerprint" >"$fingerprint_file"

echo "showcase: wrote ${output#"$repo_dir/"} ($(awk "BEGIN { printf \"%.1f\", $length }")s, ${#frames[@]} frames)"
echo "showcase: wrote ${poster#"$repo_dir/"}"
echo "showcase: wrote ${sheet#"$repo_dir/"} (${#beats[@]} slides, ${sheet_columns}x${sheet_rows})"
