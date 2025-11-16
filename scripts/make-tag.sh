#!/bin/bash

# FlexLöve Version Bump and Tag Creator
# Automates version updates and git tag creation

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}   FlexLöve Version Bump & Tag Tool   ${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Get the project root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

# Check if we're in a git repository (handles both .git directory and submodules)
if [ ! -d .git ] && [ ! -f .git ]; then
  echo -e "${RED}Error: Not in a git repository${NC}"
  exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
  echo -e "${YELLOW}Warning: You have uncommitted changes${NC}"
  git status --short
  echo ""
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted${NC}"
    exit 1
  fi
  echo ""
fi

# Extract current version from FlexLove.lua
CURRENT_VERSION=$(grep -m 1 "_VERSION" FlexLove.lua | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$CURRENT_VERSION" ]; then
  echo -e "${RED}Error: Could not extract version from FlexLove.lua${NC}"
  exit 1
fi

echo -e "${CYAN}Current version:${NC} ${GREEN}v${CURRENT_VERSION}${NC}"
echo ""

# Parse current version into components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Remove any non-numeric suffixes (e.g., "1.0.0-beta" -> "1.0.0")
MAJOR=$(echo "$MAJOR" | sed 's/[^0-9].*//')
MINOR=$(echo "$MINOR" | sed 's/[^0-9].*//')
PATCH=$(echo "$PATCH" | sed 's/[^0-9].*//')

echo -e "${CYAN}Select version bump type:${NC}"
echo "  1) Major (breaking changes)     ${MAJOR}.${MINOR}.${PATCH} → $((MAJOR+1)).0.0"
echo "  2) Minor (new features)          ${MAJOR}.${MINOR}.${PATCH} → ${MAJOR}.$((MINOR+1)).0"
echo "  3) Patch (bug fixes)             ${MAJOR}.${MINOR}.${PATCH} → ${MAJOR}.${MINOR}.$((PATCH+1))"
echo "  4) Custom version"
echo "  5) Cancel"
echo ""
read -p "Enter choice (1-5): " -n 1 -r CHOICE
echo ""
echo ""

case $CHOICE in
  1)
    NEW_MAJOR=$((MAJOR+1))
    NEW_MINOR=0
    NEW_PATCH=0
    BUMP_TYPE="major"
    ;;
  2)
    NEW_MAJOR=$MAJOR
    NEW_MINOR=$((MINOR+1))
    NEW_PATCH=0
    BUMP_TYPE="minor"
    ;;
  3)
    NEW_MAJOR=$MAJOR
    NEW_MINOR=$MINOR
    NEW_PATCH=$((PATCH+1))
    BUMP_TYPE="patch"
    ;;
  4)
    read -p "Enter custom version (e.g., 1.0.0-beta): " CUSTOM_VERSION
    NEW_VERSION="$CUSTOM_VERSION"
    BUMP_TYPE="custom"
    ;;
  5)
    echo -e "${RED}Cancelled${NC}"
    exit 0
    ;;
  *)
    echo -e "${RED}Invalid choice${NC}"
    exit 1
    ;;
esac

# Construct new version (unless custom)
if [ "$BUMP_TYPE" != "custom" ]; then
  NEW_VERSION="${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}"
fi

echo -e "${CYAN}New version:${NC} ${GREEN}v${NEW_VERSION}${NC}"
echo ""
echo -e "${YELLOW}This will:${NC}"
echo "  1. Update FlexLove.lua → flexlove._VERSION = \"${NEW_VERSION}\""
echo "  2. Update README.md → first line version"
echo "  3. Stage changes for commit"
echo "  4. Create git tag v${NEW_VERSION}"
echo ""
read -p "Proceed? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${RED}Aborted${NC}"
  exit 1
fi
echo ""

# Update FlexLove.lua
echo -e "${CYAN}[1/4]${NC} Updating FlexLove.lua..."
sed -i.bak "s/flexlove\._VERSION = \".*\"/flexlove._VERSION = \"${NEW_VERSION}\"/" FlexLove.lua
rm -f FlexLove.lua.bak
echo -e "${GREEN}✓ FlexLove.lua updated${NC}"

# Update README.md (first line)
echo -e "${CYAN}[2/4]${NC} Updating README.md..."
FIRST_LINE=$(head -1 README.md)
if [[ "$FIRST_LINE" =~ ^#.*FlexLöve.*v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
  # Replace version in first line (using -E for extended regex)
  sed -i.bak -E "1s/v[0-9]+\.[0-9]+\.[0-9]+/v${NEW_VERSION}/" README.md
  rm -f README.md.bak
  echo -e "${GREEN}✓ README.md updated${NC}"
else
  echo -e "${YELLOW}⚠ README.md first line doesn't match expected format, skipping${NC}"
  echo -e "${YELLOW}Expected: # FlexLöve v0.0.0${NC}"
  echo -e "${YELLOW}Found: $FIRST_LINE${NC}"
fi

# Stage changes
echo -e "${CYAN}[3/4]${NC} Staging changes..."
git add FlexLove.lua README.md
echo -e "${GREEN}✓ Changes staged${NC}"

# Show what's about to be committed
echo ""
echo -e "${CYAN}Changes to be committed:${NC}"
git diff --cached --stat
echo ""

# Confirm commit and tag
echo -e "${YELLOW}Ready to commit and create tag${NC}"
echo -e "${CYAN}Commit message:${NC} v${NEW_VERSION} release"
echo -e "${CYAN}Tag:${NC} v${NEW_VERSION}"
echo ""
read -p "Commit changes and create tag? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}Changes staged but not committed${NC}"
  echo "You can:"
  echo "  - Review changes: git diff --cached"
  echo "  - Commit manually: git commit -m 'v${NEW_VERSION} release'"
  echo "  - Unstage: git restore --staged FlexLove.lua README.md"
  exit 0
fi

# Commit changes
echo ""
echo -e "${CYAN}[4/4]${NC} Committing and tagging..."
git commit -m "v${NEW_VERSION} release"
git tag -a "v${NEW_VERSION}" -m "Release version ${NEW_VERSION}"

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Version bump complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Version:${NC} ${CURRENT_VERSION} → ${GREEN}${NEW_VERSION}${NC}"
echo -e "${CYAN}Tag created:${NC} ${GREEN}v${NEW_VERSION}${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Push commit and tag:"
echo -e "     ${CYAN}git push && git push origin v${NEW_VERSION}${NC}"
echo ""
echo "  2. GitHub Actions will automatically:"
echo "     • Archive previous documentation"
echo "     • Generate new documentation"
echo "     • Create release package with checksums"
echo "     • Publish GitHub release"
echo ""
echo -e "${BLUE}Release will be available at:${NC}"
echo "  https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/releases/tag/v${NEW_VERSION}"
echo ""
