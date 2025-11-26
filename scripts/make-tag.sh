#!/bin/bash

set -e

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

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

if [ ! -d .git ] && [ ! -f .git ]; then
  echo -e "${RED}Error: Not in a git repository${NC}"
  exit 1
fi

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

# Get current version from latest git tag
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
if [ -z "$CURRENT_VERSION" ]; then
  echo -e "${YELLOW}Warning: No existing git tags found${NC}"
  echo -e "${YELLOW}Attempting to read version from FlexLove.lua...${NC}"
  CURRENT_VERSION=$(grep -m 1 "_VERSION" FlexLove.lua | awk -F'"' '{print $2}')
  if [ -z "$CURRENT_VERSION" ]; then
    echo -e "${RED}Error: Could not extract version from git tags or FlexLove.lua${NC}"
    exit 1
  fi
  echo -e "${YELLOW}Using version from FlexLove.lua as fallback${NC}"
fi

echo -e "${CYAN}Current version:${NC} ${GREEN}v${CURRENT_VERSION}${NC}"
echo ""

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

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
echo "  2. Update docs/index.html → footer version"
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

echo -e "${CYAN}[1/3]${NC} Updating FlexLove.lua..."
sed -i.bak "s/flexlove\._VERSION = \".*\"/flexlove._VERSION = \"${NEW_VERSION}\"/" FlexLove.lua
rm -f FlexLove.lua.bak
echo -e "${GREEN}✓ FlexLove.lua updated${NC}"

echo -e "${CYAN}[2/3]${NC} Updating docs/index.html..."
if [ -f docs/index.html ]; then
  sed -i.bak -E "s/FlexLöve v[0-9]+\.[0-9]+\.[0-9]+/FlexLöve v${NEW_VERSION}/" docs/index.html
  rm -f docs/index.html.bak
  echo -e "${GREEN}✓ docs/index.html updated${NC}"
else
  echo -e "${YELLOW}⚠ docs/index.html not found, skipping${NC}"
fi

echo -e "${CYAN}[3/3]${NC} Staging changes..."
git add FlexLove.lua docs/index.html
echo -e "${GREEN}✓ Changes staged${NC}"

echo ""
echo -e "${CYAN}Changes to be committed:${NC}"
git diff --cached --stat
echo ""

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
  echo "  - Unstage: git restore --staged FlexLove.lua docs/index.html"
  exit 0
fi

# Commit changes
echo ""
echo -e "${YELLOW}Ready to commit and create tag${NC}"
echo -e "${CYAN}Default commit message:${NC} v${NEW_VERSION} release"
echo ""
read -p "Add a custom commit message? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -p "Enter commit message: " CUSTOM_COMMIT_MSG
  COMMIT_MSG="$CUSTOM_COMMIT_MSG"
else
  COMMIT_MSG="v${NEW_VERSION} release"
fi
echo ""
echo -e "${CYAN}Commit message:${NC} ${COMMIT_MSG}"
echo -e "${CYAN}Tag:${NC} v${NEW_VERSION}"
echo ""
read -p "Commit changes and create tag? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}Changes staged but not committed${NC}"
  echo "You can:"
  echo "  - Review changes: git diff --cached"
  echo "  - Commit manually: git commit -m 'v${NEW_VERSION} release'"
  echo "  - Unstage: git restore --staged FlexLove.lua docs/index.html"
  exit 0
fi

# Commit changes
echo ""
echo -e "${CYAN}[4/4]${NC} Committing and tagging..."
git commit -m "$COMMIT_MSG"
git tag -a "v${NEW_VERSION}" -m "Release version ${NEW_VERSION}"

echo -e "${CYAN}Pushing commits...${NC}"
if ! git push 2>&1; then
  echo ""
  echo -e "${RED}═══════════════════════════════════════${NC}"
  echo -e "${RED}✗ Push failed!${NC}"
  echo -e "${RED}═══════════════════════════════════════${NC}"
  echo ""
  echo -e "${YELLOW}Common reasons:${NC}"
  echo "  • No network connection"
  echo "  • Authentication failed (check credentials/SSH keys)"
  echo "  • Branch protection rules preventing direct push"
  echo "  • Remote branch diverged (pull needed first)"
  echo "  • No push permissions for this repository"
  echo ""
  echo -e "${YELLOW}The commit and tag were created locally but not pushed.${NC}"
  echo ""
  echo -e "${CYAN}To retry pushing:${NC}"
  echo "  git push"
  echo "  git push origin tag \"v${NEW_VERSION}\""
  echo ""
  echo -e "${CYAN}To undo the tag:${NC}"
  echo "  git tag -d \"v${NEW_VERSION}\""
  echo "  git reset --soft HEAD~1"
  echo ""
  exit 1
fi

echo -e "${CYAN}Pushing tags...${NC}"
if ! git push origin tag "v${NEW_VERSION}" 2>&1; then
  echo ""
  echo -e "${RED}═══════════════════════════════════════${NC}"
  echo -e "${RED}✗ Tag push failed!${NC}"
  echo -e "${RED}═══════════════════════════════════════${NC}"
  echo ""
  echo -e "${YELLOW}Common reasons:${NC}"
  echo "  • No network connection"
  echo "  • Authentication failed (check credentials/SSH keys)"
  echo "  • Tag already exists on remote"
  echo "  • No push permissions for this repository"
  echo ""
  echo -e "${GREEN}The commit was pushed successfully, but the tag was not.${NC}"
  echo ""
  echo -e "${CYAN}To retry pushing the tag:${NC}"
  echo "  git push origin tag \"v${NEW_VERSION}\""
  echo ""
  echo -e "${CYAN}To delete the local tag:${NC}"
  echo "  git tag -d \"v${NEW_VERSION}\""
  echo ""
  exit 1
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Version bump complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Version:${NC} ${CURRENT_VERSION} → ${GREEN}${NEW_VERSION}${NC}"
echo -e "${CYAN}Tag created:${NC} ${GREEN}v${NEW_VERSION}${NC}"
echo ""
echo -e "${BLUE}Release will be available at:${NC}"
echo "  https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/releases/tag/v${NEW_VERSION}"
echo ""
