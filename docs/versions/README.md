# FlexLöve Documentation Versions

This directory stores versioned snapshots of the FlexLöve API documentation.

## Purpose

Each time a new version of FlexLöve is released, the documentation is archived here so users can reference docs for specific versions they're using.

## Structure

```
docs/
├── api.html              # Latest/current version documentation
├── index.html            # Landing page with version selector
└── versions/
    ├── v0.2.0/
    │   └── api.html      # Documentation for v0.2.0
    ├── v0.3.0/
    │   └── api.html      # Documentation for v0.3.0
    └── v1.0.0/
        └── api.html      # Documentation for v1.0.0
```

## Naming Convention

- Version directories follow the pattern: `v{major}.{minor}.{patch}`
- Examples: `v0.2.0`, `v1.0.0`, `v2.1.3`
- Each directory contains `api.html` (the full API documentation for that version)

## Access

### Via GitHub Pages

Once deployed, versions are accessible at:
- Latest: `https://{user}.github.io/{repo}/api.html`
- Specific version: `https://{user}.github.io/{repo}/versions/v0.2.0/api.html`

### Via Repository

Browse directly in the repository:
- `docs/api.html` - Always shows latest
- `docs/versions/v0.2.0/api.html` - Specific version

## Automation

Documentation versions are automatically archived when:
1. A new git tag is pushed (e.g., `git push origin v0.3.0`)
2. GitHub Actions workflow runs
3. Documentation is generated and archived
4. Version is committed back to the repository

See `.github/workflows/release.yml` for implementation details.

## Manual Archival

To manually archive a version:

```bash
# Generate docs for current version
./scripts/generate_docs.sh

# Create version directory
VERSION="0.2.0"
mkdir -p "docs/versions/v${VERSION}"

# Copy documentation
cp docs/api.html "docs/versions/v${VERSION}/api.html"

# Commit
git add docs/versions/
git commit -m "Archive documentation for v${VERSION}"
git push
```

## Storage Considerations

- Each `api.html` file is approximately 200-300KB
- Storing 10-20 versions = 2-6MB total
- GitHub has a 1GB repository soft limit (we're well within it)
- Old versions are kept indefinitely for reference

## Version Dropdown

The main documentation pages (`api.html` and `index.html`) include a version dropdown that automatically detects and lists all available versions from this directory.

Users can switch between versions without leaving the documentation.
