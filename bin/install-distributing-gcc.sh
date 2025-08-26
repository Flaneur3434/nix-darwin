#!/usr/bin/env bash
set -euo pipefail

# install-distributing-gcc.sh
# Usage: install-distributing-gcc.sh <pkg-url>
# If no URL is provided, the script will read $DISTR_GCC_PKG_URL.

PKG_URL="${1:-${DISTR_GCC_PKG_URL:-}}"

if [ -z "$PKG_URL" ]; then
  echo "Usage: $0 <pkg-url>" >&2
  echo "Or set DISTR_GCC_PKG_URL in the environment." >&2
  exit 2
fi

DOWNLOAD_DIR="$HOME/Downloads"
mkdir -p "$DOWNLOAD_DIR"
PKG_PATH="$DOWNLOAD_DIR/$(basename "$PKG_URL")"

echo "Fetching $PKG_URL -> $PKG_PATH"
if command -v wget >/dev/null 2>&1; then
  wget -O "$PKG_PATH" "$PKG_URL"
else
  curl -L -o "$PKG_PATH" "$PKG_URL"
fi

echo "Removing com.apple.quarantine if present..."
xattr -d com.apple.quarantine "$PKG_PATH" 2>/dev/null || true

echo "Running macOS installer (this will ask for your password)..."
sudo installer -pkg "$PKG_PATH" -target /

echo "Done. If necessary, open a new terminal or source your shell rc to pick up /opt/gcc-*/bin on PATH."
