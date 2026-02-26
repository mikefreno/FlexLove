#!/bin/bash

# Local test script for release workflow
# This simulates the key steps of .github/workflows/release.yml

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}Local Release Workflow Test${NC}"
echo -e "${BLUE}==================================${NC}"
echo ""

# Step 1: Extract version
echo -e "${YELLOW}Step 1: Extract version from FlexLove.lua${NC}"
VERSION=$(grep -m 1 "_VERSION" FlexLove.lua | awk -F'"' '{print $2}')
if [ -z "$VERSION" ]; then
  echo -e "${RED}Error: Could not extract version${NC}"
  exit 1
fi
echo -e "${GREEN}✓ Version: ${VERSION}${NC}"
echo ""

# Step 2: Make scripts executable
echo -e "${YELLOW}Step 2: Make scripts executable${NC}"
chmod +x scripts/generate_docs.sh
chmod +x scripts/create-release.sh
chmod +x scripts/create-profile-packages.sh
chmod +x scripts/archive-docs.sh
echo -e "${GREEN}✓ Scripts are executable${NC}"
echo ""

# Step 3: Create release packages
echo -e "${YELLOW}Step 3: Create release packages${NC}"
./scripts/create-profile-packages.sh
echo ""

# Step 4: Verify all packages were created
echo -e "${YELLOW}Step 4: Verify all packages${NC}"
for profile in minimal slim default full; do
  if [ ! -f "releases/flexlove-${profile}-v${VERSION}.zip" ]; then
    echo -e "${RED}✗ Error: ${profile} profile package was not created${NC}"
    exit 1
  fi
  if [ ! -f "releases/flexlove-${profile}-v${VERSION}.zip.sha256" ]; then
    echo -e "${RED}✗ Error: ${profile} checksum file was not created${NC}"
    exit 1
  fi
  SIZE=$(du -h "releases/flexlove-${profile}-v${VERSION}.zip" | cut -f1)
  echo -e "${GREEN}✓ ${profile} package verified (${SIZE})${NC}"
done
echo ""

# Step 5: Verify checksums
echo -e "${YELLOW}Step 5: Verify checksums${NC}"
cd releases
if shasum -a 256 -c flexlove-*-v${VERSION}.zip.sha256 2>&1 | grep -q "OK"; then
  shasum -a 256 -c flexlove-*-v${VERSION}.zip.sha256
  echo -e "${GREEN}✓ All checksums verified${NC}"
else
  echo -e "${RED}✗ Checksum verification failed${NC}"
  exit 1
fi
cd ..
echo ""

# Step 6: Extract checksums for display
echo -e "${YELLOW}Step 6: Extract checksums for release notes${NC}"
MINIMAL_CHECKSUM=$(cat "releases/flexlove-minimal-v${VERSION}.zip.sha256" | cut -d ' ' -f 1)
SLIM_CHECKSUM=$(cat "releases/flexlove-slim-v${VERSION}.zip.sha256" | cut -d ' ' -f 1)
DEFAULT_CHECKSUM=$(cat "releases/flexlove-default-v${VERSION}.zip.sha256" | cut -d ' ' -f 1)
FULL_CHECKSUM=$(cat "releases/flexlove-full-v${VERSION}.zip.sha256" | cut -d ' ' -f 1)

echo -e "${BLUE}Minimal:  ${MINIMAL_CHECKSUM}${NC}"
echo -e "${BLUE}Slim:     ${SLIM_CHECKSUM}${NC}"
echo -e "${BLUE}Default:  ${DEFAULT_CHECKSUM}${NC}"
echo -e "${BLUE}Full:     ${FULL_CHECKSUM}${NC}"
echo ""

# Step 7: Check if pre-release
echo -e "${YELLOW}Step 7: Check if pre-release${NC}"
if [[ "$VERSION" =~ (alpha|beta|rc|dev) ]]; then
  echo -e "${BLUE}This is a pre-release version${NC}"
else
  echo -e "${GREEN}This is a stable release${NC}"
fi
echo ""

# Step 8: Verify package contents
echo -e "${YELLOW}Step 8: Verify package contents${NC}"
TEMP_DIR=$(mktemp -d)
for profile in minimal slim default full; do
  unzip -q "releases/flexlove-${profile}-v${VERSION}.zip" -d "${TEMP_DIR}/${profile}"
  
  # Check FlexLove.lua exists
  if [ ! -f "${TEMP_DIR}/${profile}/flexlove/FlexLove.lua" ]; then
    echo -e "${RED}✗ ${profile}: Missing FlexLove.lua${NC}"
    exit 1
  fi
  
  # Check LICENSE exists
  if [ ! -f "${TEMP_DIR}/${profile}/flexlove/LICENSE" ]; then
    echo -e "${RED}✗ ${profile}: Missing LICENSE${NC}"
    exit 1
  fi
  
  # Check README exists
  if [ ! -f "${TEMP_DIR}/${profile}/flexlove/README.md" ]; then
    echo -e "${RED}✗ ${profile}: Missing README.md${NC}"
    exit 1
  fi
  
  # Count modules
  MODULE_COUNT=$(find "${TEMP_DIR}/${profile}/flexlove/modules" -name "*.lua" | wc -l | tr -d ' ')
  
  # Check themes for default and full
  if [ "$profile" == "default" ] || [ "$profile" == "full" ]; then
    if [ ! -d "${TEMP_DIR}/${profile}/flexlove/themes" ]; then
      echo -e "${RED}✗ ${profile}: Missing themes directory${NC}"
      exit 1
    fi
    
    # Verify theme files
    if [ ! -f "${TEMP_DIR}/${profile}/flexlove/themes/metal.lua" ]; then
      echo -e "${RED}✗ ${profile}: Missing metal.lua${NC}"
      exit 1
    fi
    if [ ! -d "${TEMP_DIR}/${profile}/flexlove/themes/metal" ]; then
      echo -e "${RED}✗ ${profile}: Missing metal/ assets directory${NC}"
      exit 1
    fi
    if [ -f "${TEMP_DIR}/${profile}/flexlove/themes/space.example.lua" ]; then
      echo -e "${GREEN}  space.example.lua present${NC}"
    fi
    if [ ! -f "${TEMP_DIR}/${profile}/flexlove/themes/README.md" ]; then
      echo -e "${RED}✗ ${profile}: Missing themes/README.md${NC}"
      exit 1
    fi
    
    # Verify metal assets directory has content
    METAL_ASSET_COUNT=$(find "${TEMP_DIR}/${profile}/flexlove/themes/metal" -type f -name "*.png" | wc -l | tr -d ' ')
    if [ "$METAL_ASSET_COUNT" -lt "1" ]; then
      echo -e "${RED}✗ ${profile}: No .png assets found in themes/metal/${NC}"
      exit 1
    fi
    
    echo -e "${GREEN}✓ ${profile}: ${MODULE_COUNT} modules + themes (${METAL_ASSET_COUNT} metal assets) verified${NC}"
  else
    # Verify no themes for minimal and slim
    if [ -d "${TEMP_DIR}/${profile}/flexlove/themes" ]; then
      echo -e "${RED}✗ ${profile}: Should not have themes directory${NC}"
      exit 1
    fi
    echo -e "${GREEN}✓ ${profile}: ${MODULE_COUNT} modules verified${NC}"
  fi
done
rm -rf "$TEMP_DIR"
echo ""

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}✓ All tests passed!${NC}"
echo -e "${GREEN}==================================${NC}"
echo ""
echo -e "${BLUE}Release packages are ready in: releases/${NC}"
echo -e "${BLUE}Version: v${VERSION}${NC}"
echo ""
