#!/bin/bash

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "Generating FlexLöve documentation..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

if [ -f "docs/api.html" ]; then
    echo -e "${YELLOW}Checking for previous documentation version...${NC}"
    OLD_VERSION=$(grep -o 'FlexLöve v[0-9.]*' docs/api.html | head -1 | sed 's/FlexLöve v//')
    CURRENT_VERSION=$(grep -m 1 "_VERSION" FlexLove.lua | awk -F'"' '{print $2}')

    if [ -n "$OLD_VERSION" ] && [ "$OLD_VERSION" != "$CURRENT_VERSION" ]; then
        echo -e "${YELLOW}Found previous version v${OLD_VERSION}, archiving before generating new docs...${NC}"
        mkdir -p "docs/versions/v${OLD_VERSION}"
        cp docs/api.html "docs/versions/v${OLD_VERSION}/api.html"
        echo -e "${GREEN}✓ Archived previous documentation to docs/versions/v${OLD_VERSION}/${NC}"
    elif [ -n "$OLD_VERSION" ] && [ "$OLD_VERSION" = "$CURRENT_VERSION" ]; then
        echo -e "${YELLOW}Same version (v${OLD_VERSION}), will overwrite current documentation${NC}"
    fi
fi

if ! command -v lua-language-server &> /dev/null; then
    echo "Error: lua-language-server not found. Please install it first."
    echo "  macOS: brew install lua-language-server"
    echo "  Linux: See https://github.com/LuaLS/lua-language-server"
    exit 1
fi

mkdir -p docs

echo "Running lua-language-server documentation export..."
lua-language-server \
    --doc="$PROJECT_ROOT" \
    --doc_out_path="$PROJECT_ROOT/docs"

if [ $? -eq 0 ]; then
    echo "✓ Markdown documentation generated"

    echo "Building beautiful HTML documentation..."
    cd "$PROJECT_ROOT/docs"

    if [ ! -d "node_modules" ]; then
        echo "Installing Node.js dependencies..."
        npm install --silent
    fi

    npm run build --silent

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ HTML documentation built successfully!${NC}"
        echo ""
        echo "Generated files:"
        echo "  - docs/api.html (Beautiful, searchable API reference)"
        echo "  - docs/index.html (Landing page)"
        echo "  - docs/doc.md (Raw markdown)"
        if [ -n "$OLD_VERSION" ] && [ "$OLD_VERSION" != "$CURRENT_VERSION" ]; then
            echo "  - docs/versions/v${OLD_VERSION}/api.html (Previous version archived)"
        fi
    else
        echo "✗ HTML build failed, but markdown docs are available"
        exit 1
    fi
else
    echo "✗ Documentation generation failed"
    exit 1
fi
