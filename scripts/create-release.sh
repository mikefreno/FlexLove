#!/bin/bash

# FlexLöve Release Builder
# Creates a distributable zip file containing only necessary files

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}FlexLöve Release Builder${NC}"
echo ""

# Extract version from FlexLove.lua
VERSION=$(grep -m 1 "_VERSION" FlexLove.lua | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$VERSION" ]; then
  echo -e "${RED}Error: Could not extract version from FlexLove.lua${NC}"
  exit 1
fi

echo -e "${GREEN}Version detected: ${VERSION}${NC}"

# Create releases directory if it doesn't exist
RELEASE_DIR="releases"
if [ ! -d "$RELEASE_DIR" ]; then
  echo -e "${YELLOW}Creating releases directory...${NC}"
  mkdir -p "$RELEASE_DIR"
fi

# Define output filename
OUTPUT_FILE="${RELEASE_DIR}/flexlove-v${VERSION}.zip"

# Check if release already exists
CHECKSUM_FILE="${OUTPUT_FILE}.sha256"
if [ -f "$OUTPUT_FILE" ] || [ -f "$CHECKSUM_FILE" ]; then
  echo -e "${YELLOW}Warning: Release files already exist${NC}"
  [ -f "$OUTPUT_FILE" ] && echo "  - $OUTPUT_FILE"
  [ -f "$CHECKSUM_FILE" ] && echo "  - $CHECKSUM_FILE"
  read -p "Overwrite? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted${NC}"
    exit 1
  fi
  [ -f "$OUTPUT_FILE" ] && rm "$OUTPUT_FILE"
  [ -f "$CHECKSUM_FILE" ] && rm "$CHECKSUM_FILE"
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
BUILD_DIR="${TEMP_DIR}/flexlove"

echo -e "${YELLOW}Creating release package...${NC}"

# Create build directory structure
mkdir -p "$BUILD_DIR"

# Copy necessary files
echo "  → Copying FlexLove.lua"
cp FlexLove.lua "$BUILD_DIR/"

echo "  → Copying modules/"
cp -r modules "$BUILD_DIR/"

echo "  → Copying LICENSE"
cp LICENSE "$BUILD_DIR/"

# Create a minimal README for the release
echo "  → Creating README.txt"
cat > "$BUILD_DIR/README.txt" << EOF
FlexLöve v${VERSION}
==================

A flexible, powerful UI library for LÖVE2D with CSS-like layout and styling.

Installation
------------
1. Copy the 'modules' folder and 'FlexLove.lua' to your project
2. Require FlexLove in your code:
   local FlexLove = require("FlexLove")

Documentation
-------------
Visit: https://github.com/[your-repo]/flexlove (update with actual URL)

License
-------
See LICENSE file for details.

EOF

# Create the zip file
echo -e "${YELLOW}Creating zip archive...${NC}"

# Get absolute path to output file before changing directory
ABS_OUTPUT_FILE="$(cd "$(dirname "$OUTPUT_FILE")" && pwd)/$(basename "$OUTPUT_FILE")"

cd "$TEMP_DIR"
zip -r -q "flexlove-v${VERSION}.zip" flexlove/

# Move to releases directory
mv "flexlove-v${VERSION}.zip" "$ABS_OUTPUT_FILE"
cd - > /dev/null

# Generate SHA256 checksum
echo -e "${YELLOW}Generating SHA256 checksum...${NC}"
CHECKSUM_FILE="${OUTPUT_FILE}.sha256"
cd "$RELEASE_DIR"
shasum -a 256 "flexlove-v${VERSION}.zip" > "flexlove-v${VERSION}.zip.sha256"
cd - > /dev/null

# Extract checksum hash for display
CHECKSUM=$(cat "$CHECKSUM_FILE" | cut -d ' ' -f 1)

# Clean up
echo -e "${YELLOW}Cleaning up...${NC}"
rm -rf "$TEMP_DIR"

# Calculate file size
FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)

echo ""
echo -e "${GREEN}✓ Release created successfully!${NC}"
echo ""
echo -e "  ${BLUE}File:${NC} $OUTPUT_FILE"
echo -e "  ${BLUE}Size:${NC} $FILE_SIZE"
echo -e "  ${BLUE}Version:${NC} $VERSION"
echo -e "  ${BLUE}SHA256:${NC} $CHECKSUM"
echo ""
echo -e "Contents:"
echo "  - FlexLove.lua"
echo "  - modules/ (27 files)"
echo "  - LICENSE"
echo "  - README.txt"
echo ""
echo -e "Files created:"
echo "  - $OUTPUT_FILE"
echo "  - $CHECKSUM_FILE"
echo ""
echo -e "${YELLOW}Verify checksum:${NC}"
echo "  cd releases && shasum -a 256 -c flexlove-v${VERSION}.zip.sha256"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Test the release: unzip $OUTPUT_FILE"
echo "  2. Verify checksum (command above)"
echo "  3. Create a GitHub release with zip and checksum files"
echo "  4. Tag the release: git tag v${VERSION}"
echo ""
