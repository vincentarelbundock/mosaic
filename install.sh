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
# Options:
#   --ref <ref>   Branch, tag, or commit to fetch in network mode (default: main).
#   --uninstall   Remove the installed @local/mosaic version instead.
#
# Environment:
#   TYPST                The typst binary to query for the package path.
#   TYPST_PACKAGE_PATH   Overrides package-path detection, as it does for Typst.

set -eu

REPO_SLUG="vincentarelbundock/mosaic"
PACKAGE_NAME="mosaic"
TYPST="${TYPST:-typst}"

REF="main"
MODE="install"
while [ $# -gt 0 ]; do
  case "$1" in
    --ref)
      [ $# -ge 2 ] || { echo "install.sh: --ref needs an argument" >&2; exit 1; }
      REF="$2"
      shift 2
      ;;
    --uninstall)
      MODE="uninstall"
      shift
      ;;
    -h|--help)
      sed -n '2,26p' "$0" 2>/dev/null | sed 's/^# \{0,1\}//'
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

# A working tree next to this script means local mode; anything else (a piped
# script has no useful $0) means fetching the tarball. Checking the manifest's
# name guards against a stray mosaic/ directory that is not this package.
SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" 2>/dev/null && pwd) || SCRIPT_DIR=""
SOURCE_DIR=""
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/$PACKAGE_NAME/typst.toml" ] &&
  [ "$(manifest_name "$SCRIPT_DIR/$PACKAGE_NAME/typst.toml")" = "$PACKAGE_NAME" ]; then
  SOURCE_DIR="$SCRIPT_DIR/$PACKAGE_NAME"
fi

TMP_DIR=""
cleanup() { [ -z "$TMP_DIR" ] || rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM

if [ "$MODE" = "uninstall" ] && [ -z "$SOURCE_DIR" ]; then
  # Uninstalling needs only the version number, not the whole tarball.
  TMP_DIR=$(mktemp -d)
  curl -fsSL "https://raw.githubusercontent.com/$REPO_SLUG/$REF/$PACKAGE_NAME/typst.toml" \
    -o "$TMP_DIR/typst.toml"
  MANIFEST="$TMP_DIR/typst.toml"
elif [ -z "$SOURCE_DIR" ]; then
  TMP_DIR=$(mktemp -d)
  echo "Fetching $REPO_SLUG at $REF ..."
  curl -fsSL "https://github.com/$REPO_SLUG/archive/$REF.tar.gz" |
    tar -xz -C "$TMP_DIR" --strip-components=1
  SOURCE_DIR="$TMP_DIR/$PACKAGE_NAME"
  MANIFEST="$SOURCE_DIR/typst.toml"
else
  MANIFEST="$SOURCE_DIR/typst.toml"
fi

VERSION=$(manifest_version "$MANIFEST")
[ -n "$VERSION" ] || { echo "install.sh: no version in $MANIFEST" >&2; exit 1; }
TARGET_DIR="$(resolve_package_path)/local/$PACKAGE_NAME/$VERSION"

if [ "$MODE" = "uninstall" ]; then
  rm -rf "$TARGET_DIR"
  echo "Removed $TARGET_DIR"
else
  rm -rf "$TARGET_DIR"
  mkdir -p "$TARGET_DIR"
  cp -R "$SOURCE_DIR/." "$TARGET_DIR/"
  echo "Installed @local/$PACKAGE_NAME:$VERSION in $TARGET_DIR"
fi
