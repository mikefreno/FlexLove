# Changelog

All notable changes to FlexLove will be documented in this file.

## [Unreleased]

### Added
- **Android 9-Patch Auto-Parsing**: Automatic parsing of *.9.png files
  - Automatically detects and parses Android 9-patch files based on .9.png extension
  - Extracts stretch regions and content padding from 1-pixel border markers
  - Supports multiple non-contiguous stretch regions on both axes
  - Manual insets override auto-parsing for backward compatibility
  - Console logging for transparency ("[FlexLove] Auto-parsed 9-patch: ...")
  - Added `ImageDataReader` module for pixel data extraction
  - Added `NinePatchParser` module with `parse()` function
  - Theme system automatically processes 9-patch files during theme loading
  - Space theme updated to use button.9.png with auto-parsing

- **Corner Radius Support**: Added `cornerRadius` property for rounded corners
  - Supports uniform radius (single number) or individual corners (table)
  - Automatically clips children to parent's rounded corners using stencil buffer
  - Works with backgroundColor, borders, and themes
  - Added `CornerRadiusDemo.lua` example

- **Disable Highlight Property**: Added `disableHighlight` property to control pressed overlay
  - Automatically defaults to `true` when `themeComponent` is set
  - Can be explicitly overridden for custom behavior
  - Added `DisableHighlightDemo.lua` example

- **Theme Layering System**: Improved rendering order for better visual control
  - Layer 1: backgroundColor (behind everything)
  - Layer 2: Theme 9-slice (on top of backgroundColor)
  - Layer 3: Borders (on top of theme)
  - Layer 4: Text (on top of everything)
  - Added `ThemeLayeringDemo.lua` example

- **Rounded Rectangle Helper**: Added `RoundedRect` module for smooth corner rendering
  - `RoundedRect.draw()` - Draw filled or outlined rounded rectangles
  - `RoundedRect.getPoints()` - Generate polygon points for rounded shapes
  - `RoundedRect.stencilFunction()` - Create stencil functions for clipping

### Changed
- **Property Rename**: `background` → `backgroundColor` (breaking change)
  - More explicit and consistent with CSS naming
  - All examples and tests updated

- **Theme Rendering**: Themes now render on top of backgroundColor instead of replacing it
  - Allows tinting themed elements with semi-transparent backgrounds
  - Borders always render on top of themes when specified

- **9-Slice Scaling**: Improved scaling algorithm for theme images
  - Properly handles elements smaller than corner sizes
  - Proportional corner scaling prevents overlap
  - Better handling of edge cases

### Fixed
- Theme images now scale correctly to any element size
- Corner regions no longer overlap when element is too small
- Stencil clipping properly contains children within rounded corners

## Previous Changes

### Theme System
- 9-slice/9-patch theming with state support
- State-based rendering (normal, hover, pressed, disabled, active)
- Flexible atlas organization (separate images, single atlas, or hybrid)
- Theme loading and activation system

### Layout System
- Flexbox layout with full flex properties
- Grid layout system
- Absolute and relative positioning
- Automatic sizing and responsive design

### Event System
- Enhanced event handling with detailed event information
- Support for click, press, release, right-click, middle-click
- Modifier key detection (shift, ctrl, alt, gui)
- Double-click and multi-click detection

### Styling
- Color utilities with hex support
- Text rendering with alignment and auto-scaling
- Text size presets (xs, sm, md, lg, xl, etc.)
- Viewport-relative units (vw, vh, %)
- Border control (individual sides)
- Opacity support

### Animation
- Built-in animation system
- Fade and scale animations
- Custom animation support with easing
- Smooth transitions

## Migration Guide

### Using Android 9-Patch Files

FlexLove now automatically parses Android 9-patch (*.9.png) files. Simply rename your files to include the `.9.png` extension and remove manual insets:

```lua
-- Old (manual insets)
components = {
  button = {
    atlas = "themes/space/button.png",
    insets = { left = 14, top = 14, right = 14, bottom = 14 }
  }
}

-- New (auto-parsed from .9.png file)
components = {
  button = {
    atlas = "themes/space/button.9.png"
    -- insets automatically extracted from 9-patch borders
  }
}

-- Manual override still works
components = {
  button = {
    atlas = "themes/space/button.9.png",
    insets = { left = 20, top = 20, right = 20, bottom = 20 }  -- Overrides auto-parsing
  }
}
```

**9-Patch Format:**
- Top border (row 0): Horizontal stretch regions (black pixels = stretchable)
- Left border (column 0): Vertical stretch regions (black pixels = stretchable)
- Bottom border: Horizontal content padding (optional)
- Right border: Vertical content padding (optional)
- Supports multiple non-contiguous stretch regions for complex scaling patterns

### From `background` to `backgroundColor`

If you're updating existing code, replace all instances of `background` with `backgroundColor`:

```lua
-- Old
Gui.new({
  background = Color.new(0.2, 0.2, 0.2, 1)
})

-- New
Gui.new({
  backgroundColor = Color.new(0.2, 0.2, 0.2, 1)
})
```

### Using Corner Radius

```lua
-- Uniform radius
Gui.new({
  cornerRadius = 10,
  -- ...
})

-- Individual corners
Gui.new({
  cornerRadius = {
    topLeft = 20,
    topRight = 10,
    bottomLeft = 10,
    bottomRight = 20
  },
  -- ...
})
```

### Controlling Highlight Overlay

```lua
-- Regular button (highlight enabled by default)
Gui.new({
  callback = function(element, event) end
})

-- Themed button (highlight disabled by default)
Gui.new({
  themeComponent = "button",
  callback = function(element, event) end
})

-- Override default behavior
Gui.new({
  themeComponent = "button",
  disableHighlight = false,  -- Force enable
  callback = function(element, event) end
})
```

## Compatibility

- **Lua**: 5.1+
- **LÖVE**: 11.x (tested)
- **LuaJIT**: Compatible

## Known Issues

- Some type annotations show warnings in Lua language servers (cosmetic only)
- Theme system requires proper atlas setup for visual feedback
- Very small elements may have visual artifacts with complex corner radii

## Future Plans

- Input field components
- Scrollable containers
- Dropdown menus
- Tooltip system
- More built-in themes
- Performance optimizations
- Additional layout modes
