#!/bin/bash

# FlexLöve Documentation Generator
# This script generates HTML documentation from LuaLS annotations

echo "Generating FlexLöve documentation..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if lua-language-server is installed
if ! command -v lua-language-server &> /dev/null; then
    echo "Error: lua-language-server not found. Please install it first."
    echo "  macOS: brew install lua-language-server"
    echo "  Linux: See https://github.com/LuaLS/lua-language-server"
    exit 1
fi

# Create docs directory if it doesn't exist
mkdir -p docs

# Generate documentation using lua-language-server
echo "Running lua-language-server documentation export..."
lua-language-server \
    --doc="$SCRIPT_DIR" \
    --doc_out_path="$SCRIPT_DIR/docs"

if [ $? -eq 0 ]; then
    echo "✓ Documentation generated successfully!"
    echo "  - docs/doc.md (Markdown format)"
    echo "  - docs/doc.json (JSON format)"
    echo "  - docs/index.html (GitHub Pages)"
    echo ""
    echo "To view locally, open: file://$SCRIPT_DIR/docs/index.html"
    echo "To publish, commit the docs/ directory and enable GitHub Pages."
else
    echo "✗ Documentation generation failed"
    exit 1
fi
