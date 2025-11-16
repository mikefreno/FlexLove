# FlexLöve Documentation

This directory contains auto-generated API documentation from LuaLS annotations.

## Files

- **api.html** - Beautiful, searchable API documentation (2.2MB)
- **index.html** - GitHub Pages landing page
- **build-docs.js** - Node.js script to convert markdown to HTML
- **package.json** - Node.js dependencies for HTML generation
- **.nojekyll** - Tells GitHub Pages to bypass Jekyll processing
- **doc.md** - Raw markdown (gitignored, 960KB)
- **doc.json** - Raw JSON (gitignored, 11MB)

## Regenerating Documentation

To regenerate the documentation after making changes:

```bash
./scripts/generate_docs.sh
```

This will:
1. Extract version from `FlexLove.lua` (single source of truth)
2. Generate markdown from LuaLS annotations
3. Convert to beautiful, searchable HTML with syntax highlighting
4. Create navigation sidebar with search functionality
5. Display version in page titles and headers

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

- **lua-language-server** - For generating markdown from annotations
  - macOS: `brew install lua-language-server`
  - Linux: See https://github.com/LuaLS/lua-language-server
  
- **Node.js** - For converting markdown to beautiful HTML
  - macOS: `brew install node`
  - Linux: Use your package manager or https://nodejs.org

## Features

The generated HTML documentation includes:
- 🔍 **Live search** - Find classes and methods instantly
- 📱 **Responsive design** - Works on all devices
- 🌙 **Dark theme** - Easy on the eyes
- 🎨 **Syntax highlighting** - Code examples are beautifully formatted
- 🗂️ **Collapsible navigation** - Organized class/method structure
- ⚡ **Fast** - Single-page application, no page reloads
- 🎯 **Filtered** - Only user-facing classes, no internal implementation
- 🏷️ **Versioned** - Auto-displays version from `FlexLove.lua`

## Customizing Documentation

Edit `doc-filter.js` to control which classes appear in the documentation:

```javascript
module.exports = {
  // Whitelist mode: Only these classes will be included
  include: [
    'Animation',
    'Color',
    'Element',
    'Theme',
    // ... add more
  ],
  
  // Blacklist mode: These classes will be excluded
  exclude: [
    'Context',
    'Performance',
    // ... add more
  ],
  
  // Which mode to use
  mode: 'whitelist'  // or 'blacklist'
};
```

**Current filter:** Whitelist mode with 20 classes (down from 33)

## Version Management

The documentation automatically pulls the version from `FlexLove.lua`:

```lua
flexlove._VERSION = "0.2.0"  -- Single source of truth
```

To update the version:
1. Change `_VERSION` in `FlexLove.lua`
2. Run `./scripts/generate_docs.sh`
3. Version appears in page titles, sidebar, and footer

See `VERSIONING.md` for detailed version management workflow.
