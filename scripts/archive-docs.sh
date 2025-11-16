#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}FlexLöve Documentation Archival${NC}"
echo ""

VERSION=$(grep -m 1 "_VERSION" FlexLove.lua | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$VERSION" ]; then
  echo -e "${RED}Error: Could not extract version from FlexLove.lua${NC}"
  exit 1
fi

echo -e "${GREEN}Version detected: ${VERSION}${NC}"

if [ ! -f "docs/api.html" ]; then
  echo -e "${RED}Error: docs/api.html not found${NC}"
  echo "Please run ./scripts/generate_docs.sh first"
  exit 1
fi

VERSION_DIR="docs/versions/v${VERSION}"
if [ -d "$VERSION_DIR" ]; then
  echo -e "${YELLOW}Warning: $VERSION_DIR already exists${NC}"
  read -p "Overwrite? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted${NC}"
    exit 1
  fi
else
  echo -e "${YELLOW}Creating version directory...${NC}"
  mkdir -p "$VERSION_DIR"
fi

echo -e "${YELLOW}Archiving documentation...${NC}"
cp docs/api.html "$VERSION_DIR/api.html"

if [ ! -f "$VERSION_DIR/api.html" ]; then
  echo -e "${RED}Error: Failed to copy documentation${NC}"
  exit 1
fi

FILE_SIZE=$(du -h "$VERSION_DIR/api.html" | cut -f1)

echo ""
echo -e "${GREEN}✓ Documentation archived successfully!${NC}"
echo ""
echo -e "  ${BLUE}Version:${NC} v${VERSION}"
echo -e "  ${BLUE}Location:${NC} $VERSION_DIR/api.html"
echo -e "  ${BLUE}Size:${NC} $FILE_SIZE"
echo ""
