# FlexLöve Release Process

This document describes how to create and publish a new release of FlexLöve.

## Automated Release (Recommended)

The easiest way to create a release is using the automated script:

```bash
./scripts/make-tag.sh
```

This interactive script will:
1. Show your current version
2. Ask you to select: Major / Minor / Patch / Custom version bump
3. Calculate the new version (resetting lower components to 0)
4. Update `FlexLove.lua` with the new version
5. Update `docs/index.html` footer version
6. Create/update rockspec file: `flexlove-{version}-1.rockspec`
7. Create a git commit: `v{version} release`
8. Create a git tag: `v{version}`
9. Push changes and tag to GitHub

After pushing the tag, GitHub Actions automatically:
- Archives previous documentation
- Generates new documentation  
- Creates 4 build profile packages (minimal, slim, default, full) with SHA256 checksums
- Publishes GitHub release with all profile packages

The script will display next steps for publishing to LuaRocks (see [LUAROCKS_PUBLISHING.md](LUAROCKS_PUBLISHING.md)).

### Example Usage

```bash
$ ./scripts/make-tag.sh

═══════════════════════════════════════
   FlexLöve Version Bump & Tag Tool   
═══════════════════════════════════════

Current version: v0.2.0

Select version bump type:
  1) Major (breaking changes)     0.2.0 → 1.0.0
  2) Minor (new features)          0.2.0 → 0.3.0
  3) Patch (bug fixes)             0.2.0 → 0.2.1
  4) Custom version
  5) Cancel

Enter choice (1-5): 2

New version: v0.3.0

This will:
  1. Update FlexLove.lua → flexlove._VERSION = "0.3.0"
  2. Update README.md → first line version
  3. Stage changes for commit
  4. Create git tag v0.3.0

Proceed? (y/n) y

✓ Version bump complete!

Next steps:
  1. Push commit and tag:
     git push && git push origin v0.3.0

  2. GitHub Actions will automatically:
     • Archive previous documentation
     • Generate new documentation
     • Create release package with checksums
     • Publish GitHub release
```

## Manual Release Workflow

If you need more control, follow these steps:

### 1. Update Version

Edit `FlexLove.lua` and update the version:

```lua
flexlove._VERSION = "0.3.0"  -- Update this line
```

Also update `README.md` first line:
```markdown
# FlexLöve v0.3.0
```

### 2. Commit and Tag

```bash
git add FlexLove.lua README.md
git commit -m "v0.3.0 release"
git tag -a v0.3.0 -m "Release version 0.3.0"
git push && git push origin v0.3.0
```

### 3. GitHub Actions Takes Over

Once you push the tag, the automated workflow handles everything else.

## Local Release Packages (Optional)

To create local release packages without GitHub Actions:

```bash
./scripts/create-profile-packages.sh
```

Output files (for version 0.3.0):
- `releases/flexlove-minimal-v0.3.0.zip` + `.sha256`
- `releases/flexlove-slim-v0.3.0.zip` + `.sha256`
- `releases/flexlove-default-v0.3.0.zip` + `.sha256`
- `releases/flexlove-full-v0.3.0.zip` + `.sha256`

### Verify Local Packages

```bash
cd releases
shasum -a 256 -c flexlove-*-v0.3.0.zip.sha256
# Expected: All packages report OK
```

## Release Checklist

- [ ] Version updated in `FlexLove.lua`
- [ ] Rockspec created/updated (automated by `make-tag.sh`)
- [ ] Documentation regenerated (`./scripts/generate_docs.sh`)
- [ ] Changes committed and pushed
- [ ] Profile packages created (`./scripts/create-profile-packages.sh`)
- [ ] All checksums verified (`cd releases && shasum -a 256 -c *.sha256`)
- [ ] All profile packages tested
- [ ] Git tag created and pushed
- [ ] GitHub release published with all 4 profile packages and checksums
- [ ] Published to LuaRocks (`luarocks upload flexlove-{version}-1.rockspec`)

## Versioning

FlexLöve follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version: Incompatible API changes
- **MINOR** version: New functionality (backwards-compatible)
- **PATCH** version: Bug fixes (backwards-compatible)

Example: `0.2.0` → `0.2.1` (bug fix) or `0.3.0` (new feature)

## What Gets Released

FlexLöve is released as **4 separate profile packages**, each optimized for different use cases:

### Profile Packages

Each profile package includes:

✅ **Included:**
- `FlexLove.lua` - Main library
- `modules/` - Profile-specific module files only
- `LICENSE` - License terms
- `README.md` - Profile-specific installation instructions
- `themes/` - (default and full profiles only)

❌ **Not included:**
- `docs/` - Documentation (hosted on GitHub Pages)
- `examples/` - Example code (available in repository)
- `testing/` - Test suite
- Development tools

### Package Sizes

| Profile | Modules | Approximate Size |
|---------|---------|------------------|
| **Minimal** | 19 core modules | ~70% of full |
| **Slim** | 24 modules | ~80% of full |
| **Default** | 27 modules + themes | ~95% of full |
| **Full** | 29 modules + themes | 100% |

**Note:** All profiles now include UTF8.lua for Lua 5.1+ compatibility.

Users who want examples, documentation source, or development tools should clone the full repository.

## Checksum Verification

Every profile package includes a SHA256 checksum file for security verification.

### For Developers (Creating Release)

The checksums are automatically generated when running `./scripts/create-profile-packages.sh`:

```bash
./scripts/create-profile-packages.sh
# Creates 4 profile packages with checksums:
# - releases/flexlove-minimal-v0.3.0.zip + .sha256
# - releases/flexlove-slim-v0.3.0.zip + .sha256
# - releases/flexlove-default-v0.3.0.zip + .sha256
# - releases/flexlove-full-v0.3.0.zip + .sha256

# Verify all packages before publishing
cd releases
shasum -a 256 -c flexlove-*-v0.3.0.zip.sha256
# Output: All packages report OK
```

### For End Users (Downloading Release)

After downloading your chosen profile from GitHub:

```bash
# Example: Verify the default profile
shasum -a 256 -c flexlove-default-v0.3.0.zip.sha256

# If OK, safe to use
unzip flexlove-default-v0.3.0.zip
```

**macOS/Linux:** Use `shasum -a 256 -c`  
**Windows:** Use `certutil -hashfile flexlove-<profile>-v0.3.0.zip SHA256` and compare manually

## Publishing to LuaRocks

After creating a GitHub release, publish to LuaRocks for easy installation:

### First-Time Setup

1. Create a LuaRocks account at [https://luarocks.org/register](https://luarocks.org/register)
2. Get your API key from [https://luarocks.org/settings/api-keys](https://luarocks.org/settings/api-keys)
3. Configure it locally:
   ```bash
   luarocks config api-key YOUR_API_KEY_HERE
   ```

### Publishing a Release

The `make-tag.sh` script automatically creates the rockspec file. After the tag is pushed:

```bash
# Upload to LuaRocks
luarocks upload flexlove-{version}-1.rockspec

# Example for version 0.5.5:
luarocks upload flexlove-0.5.5-1.rockspec
```

### Verifying Publication

```bash
# Search for your package
luarocks search flexlove

# Test installation
luarocks install flexlove
```

For detailed instructions, see [LUAROCKS_PUBLISHING.md](LUAROCKS_PUBLISHING.md).

## Automated Releases (Future)

Consider adding GitHub Actions workflow to automate:
- Version extraction
- Release package creation
- Documentation deployment
- GitHub release creation
- LuaRocks publishing

See `.github/workflows/release.yml` (to be created)
