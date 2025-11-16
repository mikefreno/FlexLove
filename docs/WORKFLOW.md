# Documentation Workflow

## Overview

FlexLöve's documentation system automatically manages versioning and archival. When you generate new documentation, the previous version is automatically archived.

## How It Works

### 1. Manual Documentation Updates (No Version Change)

When you update annotations without bumping the version:

```bash
./scripts/generate_docs.sh
```

**What happens:**
- Script detects current version (e.g., v0.2.0) from `docs/api.html`
- Compares with `FlexLove.lua` version
- If versions match: **Overwrites** `docs/api.html` (same version)
- Previous archived version remains unchanged

**Use case:** You added better documentation, fixed typos, or improved examples without releasing a new version.

### 2. Version Bump (New Release)

When you bump the version in `FlexLove.lua`:

```bash
# 1. Update version in FlexLove.lua
# flexlove._VERSION = "0.3.0"

# 2. Generate documentation
./scripts/generate_docs.sh
```

**What happens:**
- Script detects old version (v0.2.0) from `docs/api.html`
- Compares with new version (v0.3.0) from `FlexLove.lua`
- **Archives** old `docs/api.html` → `docs/versions/v0.2.0/api.html`
- Generates new `docs/api.html` for v0.3.0

### 3. Automated Release (via GitHub Actions)

When you push a git tag:

```bash
git tag v0.3.0
git push origin v0.3.0
```

**What happens:**
1. GitHub Actions workflow triggers
2. Archives previous documentation version
3. Generates new documentation for v0.3.0
4. Commits both archived and new docs to repository
5. Creates release package with checksums
6. Creates GitHub release with assets

## Directory Structure

```
docs/
├── api.html                    # Always the LATEST version
├── index.html                  # Landing page
└── versions/
    ├── v0.1.0/
    │   └── api.html           # Documentation for v0.1.0
    ├── v0.2.0/
    │   └── api.html           # Documentation for v0.2.0
    └── v0.3.0/
        └── api.html           # Documentation for v0.3.0
```

## Version Detection

The system automatically detects versions by:
1. **Current docs version**: Reads from `docs/api.html` header (`FlexLöve v0.2.0`)
2. **Code version**: Reads from `FlexLove.lua` (`flexlove._VERSION = "0.2.0"`)

### Behavior Matrix

| Old Version | New Version | Action |
|-------------|-------------|--------|
| v0.2.0      | v0.2.0      | Overwrite current (same version update) |
| v0.2.0      | v0.3.0      | Archive v0.2.0, generate v0.3.0 |
| None        | v0.2.0      | Generate v0.2.0 (first time) |

## Examples

### Scenario 1: Fix Documentation Typo

```bash
# Fix typo in annotations
# Version still 0.2.0 in FlexLove.lua

./scripts/generate_docs.sh
# Output: "Same version (v0.2.0), will overwrite current documentation"
# Result: docs/api.html updated, no archival
```

### Scenario 2: Release New Version

```bash
# Update FlexLove.lua
# flexlove._VERSION = "0.3.0"

./scripts/generate_docs.sh
# Output: "Found previous version v0.2.0, archiving before generating new docs..."
# Output: "✓ Archived previous documentation to docs/versions/v0.2.0/"
# Result: 
#   - docs/versions/v0.2.0/api.html (archived)
#   - docs/api.html (new v0.3.0)
```

### Scenario 3: Automated Release

```bash
# Tag and push
git tag v0.3.0
git push origin v0.3.0

# GitHub Actions will:
# 1. Archive v0.2.0 automatically
# 2. Generate v0.3.0 docs
# 3. Commit both to repository
# 4. Create GitHub release
```

## Benefits

✅ **No manual archival needed** - Automatically handled  
✅ **Safe overwrites** - Same version updates won't create duplicate archives  
✅ **Version history preserved** - All previous versions accessible  
✅ **Seamless workflow** - Just run `./scripts/generate_docs.sh`  
✅ **Automated releases** - Tag and forget

## Version Dropdown

Users can access any version via the dropdown in the documentation header:
- Current version shows "(Latest)" badge
- Previous versions listed chronologically
- Click to navigate to archived documentation

## Manual Archival (If Needed)

If you ever need to manually archive a version:

```bash
./scripts/archive-docs.sh
```

This creates `docs/versions/v{version}/api.html` based on the current `FlexLove.lua` version.
