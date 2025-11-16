# Version Management for FlexLöve Documentation

The documentation automatically pulls the version from `FlexLove.lua` and displays it throughout the docs.

## How It Works

1. **Version Source**: `FlexLove.lua` contains the authoritative version:
   ```lua
   flexlove._VERSION = "0.2.0"
   ```

2. **Automatic Detection**: The build script reads this value and injects it into:
   - Page title: `FlexLöve v0.2.0 - API Reference`
   - Sidebar header: `FlexLöve v0.2.0`
   - Landing page: `FlexLöve v0.2.0`

3. **Single Source of Truth**: Update the version in ONE place (`FlexLove.lua`) and docs auto-update

## Updating the Version

### Option 1: Manual Update
Edit `FlexLove.lua`:
```lua
flexlove._VERSION = "0.3.0"  -- Change here
```

Then regenerate docs:
```bash
./scripts/generate_docs.sh
```

### Option 2: Script-Based (Recommended for Releases)
Create a release script that:
1. Updates version in `FlexLove.lua`
2. Regenerates documentation
3. Commits changes
4. Tags release

Example `release.sh`:
```bash
#!/bin/bash
NEW_VERSION=$1

if [ -z "$NEW_VERSION" ]; then
  echo "Usage: ./release.sh <version>"
  echo "Example: ./release.sh 0.3.0"
  exit 1
fi

# Update version in FlexLove.lua
sed -i '' "s/flexlove._VERSION = \".*\"/flexlove._VERSION = \"$NEW_VERSION\"/" FlexLove.lua

# Regenerate docs
./scripts/generate_docs.sh

# Commit and tag
git add FlexLove.lua docs/
git commit -m "Release v$NEW_VERSION"
git tag "v$NEW_VERSION"

echo "✓ Released v$NEW_VERSION"
echo "Don't forget to: git push && git push --tags"
```

## Version Display Locations

- **API Reference** (`api.html`):
  - Browser tab title
  - Sidebar header (smaller, grayed out)
  
- **Landing Page** (`index.html`):
  - Footer: "FlexLöve v0.2.0 | MIT License"

## Future Enhancements

Consider adding:
- **CHANGELOG.md** - Track changes between versions
- **Version dropdown** - View docs for older versions
- **GitHub Releases link** - Link to release notes
- **Breaking changes banner** - Warn users about API changes
