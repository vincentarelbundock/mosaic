#!/bin/sh
# Install the development version of Mosaic as @local/mosaic.
#
# Run from a clone of the repository (directly or via `make install`), it
# copies the working tree. Piped from the network, it fetches the repository
# tarball from GitHub first:
#
#   curl -fsSL https://raw.githubusercontent.com/vincentarelbundock/mosaic/main/install.sh | sh
#
# The development version installs into the `local` namespace, Typst's
# namespace for packages that come from somewhere other than Universe, and
# decks import it as @local/mosaic. The two namespaces keep the development
# and released versions apart with no shadowing: @preview/mosaic resolves the
# released package from Universe, and @local/mosaic resolves this snapshot.
# Installing an unpublished version under `preview` instead would claim a
# Universe version that does not exist, and would silently mask the real one
# once it did.
#
# Only one development version is ever installed: installing removes any other
# version under local/mosaic, so a deck still importing an old @local version
# fails loudly instead of compiling against a stale snapshot.
#
# Options:
#   --ref <ref>   Branch, tag, or commit to fetch in network mode (default: main).
#   --uninstall   Remove every installed @local/mosaic version instead.
#
# Environment:
#   TYPST                The typst binary to query for the package path.
#   TYPST_PACKAGE_PATH   Overrides package-path detection, as it does for Typst.

set -eu

REPO_SLUG="vincentarelbundock/mosaic"
PACKAGE_NAME="mosaic"
TYPST="${TYPST:-typst}"

REF="main"
REF_GIVEN=""
MODE="install"
while [ $# -gt 0 ]; do
  case "$1" in
    --ref)
      [ $# -ge 2 ] || { echo "install.sh: --ref needs an argument" >&2; exit 1; }
      REF="$2"
      REF_GIVEN="yes"
      shift 2
      ;;
    --uninstall)
      MODE="uninstall"
      shift
      ;;
    -h|--help)
      sed -n '2,30p' "$0" 2>/dev/null | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "install.sh: unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Typst's package root: the explicit override first, then what the binary
# itself reports (typst info prints to stderr), then the per-platform default
# Typst documents. sed rather than field splitting, because the macOS default
# ("~/Library/Application Support") contains a space.
resolve_package_path() {
  if [ -n "${TYPST_PACKAGE_PATH:-}" ]; then
    printf '%s\n' "$TYPST_PACKAGE_PATH"
    return
  fi
  reported=$("$TYPST" info 2>&1 | sed -n 's/^[[:space:]]*Package path[[:space:]]*//p' | head -n 1) || reported=""
  if [ -n "$reported" ]; then
    printf '%s\n' "$reported"
    return
  fi
  case "$(uname -s 2>/dev/null || echo unknown)" in
    Darwin)
      printf '%s\n' "$HOME/Library/Application Support/typst/packages"
      ;;
    MINGW*|MSYS*|CYGWIN*|Windows_NT)
      printf '%s\n' "${APPDATA:?install.sh: APPDATA is not set}/typst/packages"
      ;;
    *)
      printf '%s\n' "${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages"
      ;;
  esac
}

manifest_version() {
  awk -F'"' '/^version[[:space:]]*=/ { print $2; exit }' "$1"
}

manifest_name() {
  awk -F'"' '/^name[[:space:]]*=/ { print $2; exit }' "$1"
}

# A working tree next to this script means local mode; anything else means
# fetching the tarball. A piped script has no file of its own: $0 is the shell
# ("sh"), whose dirname is the current directory, so $0 must be a real file
# named install.sh before its directory counts. Otherwise the one-liner run
# from inside a clone would install that clone and ignore --ref. Checking the
# manifest's name guards against a stray mosaic/ directory that is not this
# package.
SCRIPT_DIR=""
if [ -f "$0" ] && [ "$(basename -- "$0")" = "install.sh" ]; then
  SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" 2>/dev/null && pwd) || SCRIPT_DIR=""
fi
SOURCE_DIR=""
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/$PACKAGE_NAME/typst.toml" ] &&
  [ "$(manifest_name "$SCRIPT_DIR/$PACKAGE_NAME/typst.toml")" = "$PACKAGE_NAME" ]; then
  SOURCE_DIR="$SCRIPT_DIR/$PACKAGE_NAME"
fi

if [ -n "$SOURCE_DIR" ] && [ -n "$REF_GIVEN" ] && [ "$MODE" = "install" ]; then
  echo "install.sh: --ref applies only when fetching from GitHub; this run installs the working tree at $SOURCE_DIR" >&2
  exit 1
fi

# Every version of the development package lives in this one directory, and
# nothing else does.
VERSIONS_DIR="$(resolve_package_path)/local/$PACKAGE_NAME"

# Remove every installed version except the one named. Only direct children
# whose names are dotted numbers (0.0.2, 1.10.0) are touched, so nothing that
# is not a package version can be removed from here.
remove_versions() {
  keep="$1"
  [ -d "$VERSIONS_DIR" ] || return 0
  for entry in "$VERSIONS_DIR"/*; do
    [ -d "$entry" ] || continue
    name=${entry##*/}
    [ "$name" != "$keep" ] || continue
    case "$name" in
      *[!0-9.]* | .* | *. | *..*) continue ;;
      *.*.*) ;;
      *) continue ;;
    esac
    rm -rf "$entry"
    echo "Removed $entry"
  done
}

if [ "$MODE" = "uninstall" ]; then
  remove_versions ""
  exit 0
fi

TMP_DIR=""
cleanup() { [ -z "$TMP_DIR" ] || rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM

if [ -z "$SOURCE_DIR" ]; then
  TMP_DIR=$(mktemp -d)
  echo "Fetching $REPO_SLUG at $REF ..."
  curl -fsSL "https://github.com/$REPO_SLUG/archive/$REF.tar.gz" |
    tar -xz -C "$TMP_DIR" --strip-components=1
  SOURCE_DIR="$TMP_DIR/$PACKAGE_NAME"
fi
MANIFEST="$SOURCE_DIR/typst.toml"

VERSION=$(manifest_version "$MANIFEST")
[ -n "$VERSION" ] || { echo "install.sh: no version in $MANIFEST" >&2; exit 1; }
TARGET_DIR="$VERSIONS_DIR/$VERSION"

# Copy into a temporary sibling directory first, then swap by renaming: the old
# install is moved aside, the new one renamed into place, and only then is the
# old one deleted. A failed or interrupted copy therefore never leaves a
# truncated package at $TARGET_DIR.
mkdir -p "$VERSIONS_DIR"
STAGE_DIR=$(mktemp -d "$VERSIONS_DIR/.mosaic-install.XXXXXX")
OLD_DIR=""
stage_cleanup() {
  [ -z "$STAGE_DIR" ] || rm -rf "$STAGE_DIR"
  [ -z "$OLD_DIR" ] || rm -rf "$OLD_DIR"
}
trap 'stage_cleanup; cleanup' EXIT INT TERM
cp -R "$SOURCE_DIR/." "$STAGE_DIR/"
# mktemp creates the stage with mode 700; the package is world-readable.
chmod 755 "$STAGE_DIR"
if [ -e "$TARGET_DIR" ]; then
  OLD_DIR=$(mktemp -d "$VERSIONS_DIR/.mosaic-old.XXXXXX")
  mv "$TARGET_DIR" "$OLD_DIR/previous"
fi
mv "$STAGE_DIR" "$TARGET_DIR"
STAGE_DIR=""
echo "Installed @local/$PACKAGE_NAME:$VERSION in $TARGET_DIR"
remove_versions "$VERSION"
