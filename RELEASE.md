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
5. Update `README.md` first line with the new version
6. Create a git commit: `v{version} release`
7. Create a git tag: `v{version}`
8. Prompt you to push the changes

After pushing the tag, GitHub Actions automatically:
- Archives previous documentation
- Generates new documentation  
- Creates release package with SHA256 checksums
- Publishes GitHub release with download assets

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

## Local Release Package (Optional)

To create a local release package without GitHub Actions:

```bash
./scripts/create-release.sh
```

Output files:
- `releases/flexlove-v{version}.zip`
- `releases/flexlove-v{version}.zip.sha256`

### Verify Local Package

```bash
cd releases
shasum -a 256 -c flexlove-v0.3.0.zip.sha256
# Expected: flexlove-v0.3.0.zip: OK
```

## Release Checklist

- [ ] Version updated in `FlexLove.lua`
- [ ] Documentation regenerated (`./scripts/generate_docs.sh`)
- [ ] Changes committed and pushed
- [ ] Release package created (`./scripts/create-release.sh`)
- [ ] Checksum verified (`shasum -a 256 -c *.sha256`)
- [ ] Release package tested
- [ ] Git tag created and pushed
- [ ] GitHub release published with zip and checksum files

## Versioning

FlexLöve follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version: Incompatible API changes
- **MINOR** version: New functionality (backwards-compatible)
- **PATCH** version: Bug fixes (backwards-compatible)

Example: `0.2.0` → `0.2.1` (bug fix) or `0.3.0` (new feature)

## What Gets Released

The release package includes **only** the files needed to use FlexLöve:

✅ **Included:**
- `FlexLove.lua` - Main library
- `modules/` - All module files
- `LICENSE` - License terms
- `README.txt` - Installation instructions

❌ **Not included:**
- `docs/` - Documentation (hosted on GitHub Pages)
- `examples/` - Example code (available in repository)
- `testing/` - Test suite
- `themes/` - Theme examples
- Development tools

Users who want examples, documentation source, or development tools should clone the full repository.

## Checksum Verification

Every release includes a SHA256 checksum file for security verification.

### For Developers (Creating Release)

The checksum is automatically generated when running `./scripts/create-release.sh`:

```bash
./scripts/create-release.sh
# Creates:
# - releases/flexlove-v0.3.0.zip
# - releases/flexlove-v0.3.0.zip.sha256

# Verify before publishing
cd releases
shasum -a 256 -c flexlove-v0.3.0.zip.sha256
# Output: flexlove-v0.3.0.zip: OK
```

### For End Users (Downloading Release)

After downloading a release from GitHub:

```bash
# Download both files:
# - flexlove-v0.3.0.zip
# - flexlove-v0.3.0.zip.sha256

# Verify integrity
shasum -a 256 -c flexlove-v0.3.0.zip.sha256

# If OK, safe to use
unzip flexlove-v0.3.0.zip
```

**macOS/Linux:** Use `shasum -a 256 -c`  
**Windows:** Use `certutil -hashfile flexlove-v0.3.0.zip SHA256` and compare manually

## Automated Releases (Future)

Consider adding GitHub Actions workflow to automate:
- Version extraction
- Release package creation
- Documentation deployment
- GitHub release creation

See `.github/workflows/release.yml` (to be created)
