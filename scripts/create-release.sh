#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}FlexLöve Release Builder${NC}"
echo ""

VERSION=$(grep -m 1 "_VERSION" FlexLove.lua | awk -F'"' '{print $2}')
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

OUTPUT_FILE="${RELEASE_DIR}/flexlove-v${VERSION}.zip"

CHECKSUM_FILE="${OUTPUT_FILE}.sha256"
if [ -f "$OUTPUT_FILE" ] || [ -f "$CHECKSUM_FILE" ]; then
  echo -e "${YELLOW}Warning: Release files already exist - overwriting${NC}"
  [ -f "$OUTPUT_FILE" ] && echo "  - $OUTPUT_FILE" && rm "$OUTPUT_FILE"
  [ -f "$CHECKSUM_FILE" ] && echo "  - $CHECKSUM_FILE" && rm "$CHECKSUM_FILE"
fi

TEMP_DIR=$(mktemp -d)
BUILD_DIR="${TEMP_DIR}/flexlove"

echo -e "${YELLOW}Creating release package...${NC}"

mkdir -p "$BUILD_DIR"

echo "  → Copying FlexLove.lua"
cp FlexLove.lua "$BUILD_DIR/"

echo "  → Copying modules/"
cp -r modules "$BUILD_DIR/"

echo "  → Copying LICENSE"
cp LICENSE "$BUILD_DIR/"

echo "  → Creating README.md"
cp README.md "$BUILD_DIR/"

echo -e "${YELLOW}Creating zip archive...${NC}"

ABS_OUTPUT_FILE="$(cd "$(dirname "$OUTPUT_FILE")" && pwd)/$(basename "$OUTPUT_FILE")"

cd "$TEMP_DIR"
zip -r -q "flexlove-v${VERSION}.zip" flexlove/

mv "flexlove-v${VERSION}.zip" "$ABS_OUTPUT_FILE"
cd - > /dev/null

echo -e "${YELLOW}Generating SHA256 checksum...${NC}"
CHECKSUM_FILE="${OUTPUT_FILE}.sha256"
cd "$RELEASE_DIR"
shasum -a 256 "flexlove-v${VERSION}.zip" > "flexlove-v${VERSION}.zip.sha256"
cd - > /dev/null

CHECKSUM=$(cat "$CHECKSUM_FILE" | cut -d ' ' -f 1)

echo -e "${YELLOW}Cleaning up...${NC}"
rm -rf "$TEMP_DIR"

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
echo "  - README.md"
echo ""
echo -e "Files created:"
echo "  - $OUTPUT_FILE"
echo "  - $CHECKSUM_FILE"
echo ""
echo -e "${YELLOW}Verify checksum:${NC}"
echo "  cd releases && shasum -a 256 -c flexlove-v${VERSION}.zip.sha256"
