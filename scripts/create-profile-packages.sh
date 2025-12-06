#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}FlexLöve Profile Package Builder${NC}"
echo ""

# Debug: Show current directory and verify files exist
echo -e "${YELLOW}Working directory: $(pwd)${NC}"
if [ ! -f "FlexLove.lua" ]; then
  echo -e "${RED}Error: FlexLove.lua not found in current directory${NC}"
  echo "Contents of current directory:"
  ls -la
  exit 1
fi
if [ ! -d "modules" ]; then
  echo -e "${RED}Error: modules/ directory not found${NC}"
  echo "Contents of current directory:"
  ls -la
  exit 1
fi

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

# Function to get profile description
get_description() {
  case "$1" in
    minimal) echo "Core modules only - smallest bundle size (~60%)" ;;
    slim) echo "Minimal + Animation and Image support (~80%)" ;;
    default) echo "Slim + Theme and Blur (~95%)" ;;
    full) echo "All modules including debugging tools (100%)" ;;
  esac
}

# Function to get modules for a profile
get_modules() {
  case "$1" in
    minimal)
      echo "utils.lua Units.lua Context.lua StateManager.lua ErrorHandler.lua Color.lua InputEvent.lua TextEditor.lua LayoutEngine.lua Renderer.lua EventHandler.lua ScrollManager.lua Element.lua RoundedRect.lua Grid.lua ModuleLoader.lua types.lua FFI.lua"
      ;;
    slim)
      echo "utils.lua Units.lua Context.lua StateManager.lua ErrorHandler.lua Color.lua InputEvent.lua TextEditor.lua LayoutEngine.lua Renderer.lua EventHandler.lua ScrollManager.lua Element.lua RoundedRect.lua Grid.lua ModuleLoader.lua types.lua FFI.lua Animation.lua NinePatch.lua ImageRenderer.lua ImageScaler.lua ImageCache.lua"
      ;;
    default)
      echo "utils.lua Units.lua Context.lua StateManager.lua ErrorHandler.lua Color.lua InputEvent.lua TextEditor.lua LayoutEngine.lua Renderer.lua EventHandler.lua ScrollManager.lua Element.lua RoundedRect.lua Grid.lua ModuleLoader.lua types.lua FFI.lua Animation.lua NinePatch.lua ImageRenderer.lua ImageScaler.lua ImageCache.lua Theme.lua Blur.lua GestureRecognizer.lua"
      ;;
    full)
      echo "utils.lua Units.lua Context.lua StateManager.lua ErrorHandler.lua Color.lua InputEvent.lua TextEditor.lua LayoutEngine.lua Renderer.lua EventHandler.lua ScrollManager.lua Element.lua RoundedRect.lua Grid.lua ModuleLoader.lua types.lua FFI.lua Animation.lua NinePatch.lua ImageRenderer.lua ImageScaler.lua ImageCache.lua Theme.lua Blur.lua GestureRecognizer.lua Performance.lua MemoryScanner.lua"
      ;;
  esac
}

# Build each profile
for profile in minimal slim default full; do
  echo ""
  echo -e "${YELLOW}Building ${profile} profile...${NC}"
  description=$(get_description "$profile")
  echo -e "${BLUE}${description}${NC}"

  OUTPUT_FILE="${RELEASE_DIR}/flexlove-${profile}-v${VERSION}.zip"
  CHECKSUM_FILE="${OUTPUT_FILE}.sha256"

  # Remove existing files
  if [ -f "$OUTPUT_FILE" ] || [ -f "$CHECKSUM_FILE" ]; then
    echo -e "${YELLOW}Removing existing files...${NC}"
    [ -f "$OUTPUT_FILE" ] && rm "$OUTPUT_FILE"
    [ -f "$CHECKSUM_FILE" ] && rm "$CHECKSUM_FILE"
  fi

  # Create temp directory
  TEMP_DIR=$(mktemp -d)
  BUILD_DIR="${TEMP_DIR}/flexlove"

  echo "  → Creating build directory: $BUILD_DIR"
  mkdir -p "$BUILD_DIR/modules" || {
    echo -e "${RED}Error: Failed to create build directory${NC}"
    exit 1
  }

  echo "  → Copying FlexLove.lua"
  cp FlexLove.lua "$BUILD_DIR/"

  echo "  → Copying LICENSE"
  cp LICENSE "$BUILD_DIR/"

  echo "  → Creating README.md"
  # Create profile-specific README
  profile_upper=$(echo "${profile}" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
  cat > "$BUILD_DIR/README.md" << EOF
# FlexLöve v${VERSION} - ${profile_upper} Profile

${description}

This package contains the **${profile}** build profile of FlexLöve.

## Installation

\`\`\`bash
unzip flexlove-${profile}-v${VERSION}.zip
cp -r flexlove/modules ./
cp flexlove/FlexLove.lua ./
\`\`\`

## What's Included

- **FlexLove.lua** - Main library file
- **modules/** - ${profile_upper} profile modules
- **LICENSE** - MIT License

## Requirements

- LÖVE2D 11.0 or higher

## Documentation

📚 [View Full Documentation](https://mikefreno.github.io/FlexLove/)

## Build Profile

This is the **${profile}** profile. Other profiles available:

- **minimal** - Core functionality only (~60%)
- **slim** - Adds animations and image support (~80%)
- **default** - Adds themes and blur effects (~95%)
- **full** - All modules including debugging tools (100%)

Visit the [releases page](https://github.com/mikefreno/FlexLove/releases) to download other profiles.

## License

MIT License - see LICENSE file for details.
EOF

  # Copy only the modules for this profile
  echo "  → Copying modules for ${profile} profile"
  module_list=$(get_modules "$profile")
  module_count=0
  for module in $module_list; do
    if [ -f "modules/$module" ]; then
      cp "modules/$module" "$BUILD_DIR/modules/" || {
        echo -e "${RED}Error: Failed to copy modules/$module${NC}"
        exit 1
      }
      module_count=$((module_count + 1))
    else
      echo -e "${RED}Error: Module not found: modules/$module${NC}"
      echo "Available modules:"
      ls -la modules/ || echo "modules/ directory not found"
      exit 1
    fi
  done
  echo "     Copied ${module_count} modules"

  # Copy themes for default and full profiles
  if [ "$profile" == "default" ] || [ "$profile" == "full" ]; then
    echo "  → Copying themes/"
    mkdir -p "$BUILD_DIR/themes"

    # Copy README
    if [ -f "themes/README.md" ]; then
      cp "themes/README.md" "$BUILD_DIR/themes/"
    fi

    # Copy theme files as .example.lua
    if [ -f "themes/metal.lua" ]; then
      cp "themes/metal.lua" "$BUILD_DIR/themes/metal.example.lua"
    fi
    if [ -f "themes/space.lua" ]; then
      cp "themes/space.lua" "$BUILD_DIR/themes/space.example.lua"
    fi
  fi

  # Create zip archive
  echo "  → Creating zip archive"
  ABS_OUTPUT_FILE="$(cd "$(dirname "$OUTPUT_FILE")" && pwd)/$(basename "$OUTPUT_FILE")"

  cd "$TEMP_DIR"
  zip -r -q "flexlove-${profile}-v${VERSION}.zip" flexlove/
  mv "flexlove-${profile}-v${VERSION}.zip" "$ABS_OUTPUT_FILE"
  cd - > /dev/null

  # Generate checksum
  echo "  → Generating SHA256 checksum"
  cd "$RELEASE_DIR"
  shasum -a 256 "flexlove-${profile}-v${VERSION}.zip" > "flexlove-${profile}-v${VERSION}.zip.sha256"
  cd - > /dev/null

  # Cleanup
  rm -rf "$TEMP_DIR"

  # Report
  FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
  CHECKSUM=$(cat "$CHECKSUM_FILE" | cut -d ' ' -f 1)

  echo -e "${GREEN}✓ ${profile} profile created${NC}"
  echo -e "  ${BLUE}File:${NC} $OUTPUT_FILE"
  echo -e "  ${BLUE}Size:${NC} $FILE_SIZE"
  echo -e "  ${BLUE}Modules:${NC} ${module_count}"
  echo -e "  ${BLUE}SHA256:${NC} ${CHECKSUM:0:16}..."
done

echo ""
echo -e "${GREEN}✓ All profile packages created successfully!${NC}"
echo ""
echo -e "${BLUE}Created packages:${NC}"
for profile in minimal slim default full; do
  FILE_SIZE=$(du -h "${RELEASE_DIR}/flexlove-${profile}-v${VERSION}.zip" | cut -f1)
  echo "  - flexlove-${profile}-v${VERSION}.zip (${FILE_SIZE})"
done
echo ""
echo -e "${YELLOW}Verify checksums:${NC}"
echo "  cd releases && shasum -a 256 -c flexlove-*-v${VERSION}.zip.sha256"
