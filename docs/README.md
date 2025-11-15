# FlexLöve Documentation

This directory contains auto-generated API documentation from LuaLS annotations.

## Files

- **index.html** - GitHub Pages landing page
- **doc.md** - Markdown API reference (47,000+ lines)
- **doc.json** - JSON API reference for tooling (11MB)

## Regenerating Documentation

To regenerate the documentation after making changes:

```bash
./generate_docs.sh
```

Or manually:

```bash
lua-language-server --doc=. --doc_out_path=./docs
```

## Viewing Locally

Open `index.html` in your browser:

```bash
open docs/index.html  # macOS
xdg-open docs/index.html  # Linux
start docs/index.html  # Windows
```

## Publishing to GitHub Pages

1. Commit the docs/ directory:
   ```bash
   git add docs/
   git commit -m "Update documentation"
   git push
   ```

2. Enable GitHub Pages in repository settings:
   - Go to Settings > Pages
   - Source: Deploy from a branch
   - Branch: `main` (or your default branch)
   - Folder: `/docs`
   - Save

3. Your documentation will be available at:
   `https://[username].github.io/[repository]/`

## Documentation Format

The documentation is generated from LuaLS (Lua Language Server) annotations using the `lua-language-server` CLI tool. This ensures 100% compatibility with your IDE autocomplete and type checking.

### Supported Annotations

- `---@class` - Class definitions
- `---@field` - Class fields
- `---@param` - Function parameters
- `---@return` - Return values
- `---@type` - Variable types
- And all other LuaLS annotations

## Requirements

- lua-language-server (install via `brew install lua-language-server` on macOS)
