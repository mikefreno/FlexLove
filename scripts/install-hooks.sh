#!/usr/bin/env bash
# Install FlexLöve git hooks
# Usage: bash scripts/install-hooks.sh

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
HOOKS_SRC="$REPO_ROOT/scripts/hooks"
HOOKS_DEST=$(git rev-parse --git-dir)/hooks

echo "Installing FlexLöve git hooks..."

for hook in "$HOOKS_SRC"/*; do
  name=$(basename "$hook")
  dest="$HOOKS_DEST/$name"
  cp "$hook" "$dest"
  chmod +x "$dest"
  echo "  ✓ Installed $name"
done

echo ""
echo "Hooks installed to: $HOOKS_DEST"
echo ""
echo "Optional tools for full coverage:"
echo "  stylua  — Lua formatter   (cargo install stylua)"
echo "  luacheck — Lua linter     (luarocks install luacheck)"
