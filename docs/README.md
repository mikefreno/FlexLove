# FlexLöve Documentation

This directory contains auto-generated API documentation from LuaLS annotations.

## Regenerating Documentation

To regenerate the documentation after making changes:

```bash
./scripts/generate_docs.sh
```

This will:
1. Extract version from `FlexLove.lua` (single source of truth)
2. Generate markdown from LuaLS annotations
3. Convert to searchable HTML with syntax highlighting
4. Create navigation sidebar with search functionality
5. Display version in page titles and headers
