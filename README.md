# FlexLöve

**A comprehensive UI library providing flexbox/grid layouts, theming, animations, and event handling for LÖVE2D games.**

FlexLöve is a lightweight, flexible GUI library for Löve2D that implements a flexbox-based layout system. It provides a simple way to create and manage UI elements with automatic layout calculations, animations, theming, and responsive design. Immediate mode support is now included (retained is default). 

## ⚠️ Development Status

This library is under active development. While many features are functional, some aspects may change or have incomplete/broken implementations.

### Coming Soon
The following features are currently being actively developed:
- **Input Fields**: Text input, password fields, and text areas
- **Generic Image Support**: Enhanced image rendering capabilities and utilities

## Features

- **Flexbox Layout**: Modern flexbox layouts for UI elements with full flex properties
- **Grid Layout**: CSS-like (but simplified) grid system for structured layouts
- **Element Management**: Hierarchical element structures with automatic sizing
- **Interactive Elements**: Buttons with click detection, event system, and callbacks
- **Theme System**: 9-slice/9-patch theming with state support (normal, hover, pressed, disabled)
- **Android 9-Patch Auto-Parsing**: Automatic parsing of *.9.png files with multi-region support
- **Animations**: Built-in animation support for transitions and effects
- **Responsive Design**: Automatic resizing with viewport units (vw, vh, %)
- **Color Handling**: Utility classes for managing colors in various formats
- **Text Rendering**: Flexible text display with alignment and auto-scaling
- **Corner Radius**: Rounded corners with individual corner control
- **Advanced Positioning**: Absolute, relative, flex, and grid positioning modes

## Installation

Add the `modules` directory and `FlexLove.lua` into your project and require it:

```lua
local FlexLove = require("FlexLove")
local Gui = FlexLove.Gui
local Color = FlexLove.Color
```

## Quick Start

```lua
local FlexLove = require("FlexLove")

-- Initialize with base scaling and theme
FlexLove.Gui.init({
  baseScale = { width = 1920, height = 1080 },
  theme = "space"
  immediateMode = true -- Optional: enable immediate mode (default: false)
})

-- Create a button with flexbox layout
local button = FlexLove.Element.new({
  width = "20vw",
  height = "10vh",
  backgroundColor = FlexLove.Color.new(0.2, 0.2, 0.8, 1),
  text = "Click Me",
  textSize = "md",
  themeComponent = "button",
  callback = function(element, event)
    print("Button clicked!")
  end
})

-- In your love.update and love.draw:
function love.update(dt)
  FlexLove.Gui.update(dt)
end

function love.draw()
  FlexLove.Gui.draw()
end
```

## API Conventions

### Method Patterns
- **Constructors**: `ClassName.new(props)` → instance
- **Static Methods**: `ClassName.methodName(args)` → result
- **Instance Methods**: `instance:methodName(args)` → result
- **Getters**: `instance:getPropertyName()` → value
- **Internal Fields**: `_fieldName` (private, do not access directly)
- **Error Handling**: Constructors throw errors, utility functions return nil + error string

### Return Value Patterns
- **Single Success**: return value
- **Success/Failure**: return result, errorMessage (nil on success for error)
- **Multiple Values**: return value1, value2 (documented in @return)
- **Constructors**: Always return instance (never nil)

## Core Concepts

### Immediate Mode vs Retained Mode

FlexLöve supports both **immediate mode** and **retained mode** UI paradigms, giving you flexibility in how you structure your UI code:

#### Retained Mode (Default)
In retained mode, you create elements once and they persist across frames. The library manages the element hierarchy and state automatically.

```lua
-- Create elements once (e.g., in love.load)
local button = FlexLove.Element.new({
  text = "Click Me",
  callback = function() print("Clicked!") end
})

-- Elements automatically update and draw each frame
function love.update(dt)
  FlexLove.Gui.update(dt)
end

function love.draw()
  FlexLove.Gui.draw()
end
```

**Best for:**
- Complex UIs with many persistent elements
- Elements that maintain state over time
- UIs that don't change frequently

#### Immediate Mode
In immediate mode, you recreate UI elements every frame based on your application state. This approach can be simpler for dynamic UIs that change frequently.

```lua
-- Recreate UI every frame
function love.draw()
  FlexLove.ImmediateMode.begin()
  
  if FlexLove.ImmediateMode.button("myButton", {
    x = 100, y = 100,
    text = "Click Me"
  }) then
    print("Clicked!")
  end
  
  FlexLove.ImmediateMode.finish()
end
```

**Best for:**
- Simple UIs that change frequently
- Procedurally generated interfaces
- Debugging and development tools
- UIs driven directly by application state

You can mix both modes in the same application - use retained mode for your main UI and immediate mode for debug overlays or dynamic elements.

### Element Properties

Common properties for all elements:

```lua
{
  -- Positioning & Size
  x = 0,                    -- X position (number or string with units)
  y = 0,                    -- Y position
  width = 100,              -- Width (number, string, or "auto")
  height = 100,             -- Height
  z = 0,                    -- Z-index for layering
  
  -- Visual Styling
  backgroundColor = Color.new(0, 0, 0, 0),  -- Background color
  cornerRadius = 0,         -- Uniform radius or {topLeft, topRight, bottomLeft, bottomRight}
  border = {},              -- {top, right, bottom, left} boolean flags
  borderColor = Color.new(0, 0, 0, 1),
  opacity = 1,              -- 0 to 1
  
  -- Layout
  positioning = "flex",     -- "absolute", "relative", "flex", or "grid"
  padding = {},             -- {top, right, bottom, left} or shortcuts
  margin = {},              -- {top, right, bottom, left} or shortcuts
  gap = 10,                 -- Space between children
  
  -- Flexbox Properties
  flexDirection = "horizontal",  -- "horizontal" or "vertical"
  justifyContent = "flex-start", -- Main axis alignment
  alignItems = "stretch",        -- Cross axis alignment
  flexWrap = "nowrap",           -- "nowrap" or "wrap"
  
  -- Grid Properties
  gridRows = 1,
  gridColumns = 1,
  rowGap = 10,
  columnGap = 10,
  
  -- Text
  text = "Hello",
  textColor = Color.new(1, 1, 1, 1),
  textAlign = "start",      -- "start", "center", "end"
  textSize = "md",          -- Number or preset ("xs", "sm", "md", "lg", "xl", etc.)
  
  -- Theming
  theme = "space",          -- Theme name
  themeComponent = "button", -- Component type from theme
  
  -- Interaction
  callback = function(element, event) end,
  disabled = false,
  disableHighlight = false, -- Disable pressed overlay (auto-true for themed elements)
  
  -- Hierarchy
  parent = nil,             -- Parent element
}
```

### Layout Modes

#### Absolute Positioning
```lua
local element = Gui.new({
  positioning = "absolute",
  x = 100,
  y = 50,
  width = 200,
  height = 100
})
```

#### Flexbox Layout
```lua
local container = Gui.new({
  positioning = "flex",
  flexDirection = "horizontal",
  justifyContent = "center",
  alignItems = "center",
  gap = 10
})
```

#### Grid Layout
```lua
local grid = Gui.new({
  positioning = "grid",
  gridRows = 3,
  gridColumns = 3,
  rowGap = 10,
  columnGap = 10
})
```

### Corner Radius

Supports uniform or individual corner radii:

```lua
-- Uniform radius
cornerRadius = 15

-- Individual corners
cornerRadius = {
  topLeft = 20,
  topRight = 10,
  bottomLeft = 10,
  bottomRight = 20
}
```

### Theme System
 
To create a theme explore themes/space.lua as a reference

Load and apply themes for consistent styling:

```lua
local Theme = FlexLove.Theme

-- Load a theme
Theme.load("space")
Theme.setActive("space")

-- Use theme on elements
local button = Gui.new({
  width = 200,
  height = 60,
  text = "Themed Button",
  themeComponent = "button",  -- Uses "button" component from active theme
  backgroundColor = Color.new(0.5, 0.5, 1, 0.3)  -- Renders behind theme
})
```

#### Android 9-Patch Support

FlexLove automatically parses Android 9-patch (*.9.png) files:

```lua
-- Theme definition with auto-parsed 9-patch
{
  name = "My Theme",
  components = {
    button = {
      atlas = "themes/mytheme/button.9.png"
      -- insets automatically extracted from 9-patch borders
      -- supports multiple stretch regions for complex scaling
    },
    panel = {
      atlas = "themes/mytheme/panel.png",
      insets = { left = 20, top = 20, right = 20, bottom = 20 }
      -- manual insets still supported (overrides auto-parsing)
    }
  }
}
```

**9-Patch Format:**
- Files ending in `.9.png` are automatically detected and parsed
- **Guide pixels are automatically removed** - the 1px border is stripped during loading
- Top/left borders define stretchable regions (black pixels)
- Bottom/right borders define content padding (optional) - **automatically applied to child positioning**
- Supports multiple non-contiguous stretch regions
- Manual insets override auto-parsing when specified

**Scaling Corners:**
```lua
{
  button = {
    atlas = "themes/mytheme/button.9.png",
    scaleCorners = 2  -- Scale corners by 2x (number = direct multiplier)
  }
}
```
- `scaleCorners` accepts a number (e.g., 2 = 2x size, 0.5 = half size)
- Default: `nil` (no scaling, 1:1 pixel perfect)
- Corners scale uniformly while edges stretch as defined by guides

Themes support state-based rendering:
- `normal` - Default state
- `hover` - Mouse over element
- `pressed` - Element being clicked
- `disabled` - Element is disabled
- `active` - Element is active/focused

### Event System

Enhanced event handling with detailed event information:

```lua
callback = function(element, event)
  -- event.type: "click", "press", "release", "rightclick", "middleclick"
  -- event.button: 1 (left), 2 (right), 3 (middle)
  -- event.x, event.y: Mouse position
  -- event.clickCount: Number of clicks (for double-click detection)
  -- event.modifiers: { shift, ctrl, alt, gui }
  
  if event.type == "click" and event.modifiers.shift then
    print("Shift-clicked!")
  end
end
```

### Responsive Units

Support for viewport-relative units:

```lua
local element = Gui.new({
  width = "50vw",   -- 50% of viewport width
  height = "30vh",  -- 30% of viewport height
  x = "25%",        -- 25% of parent width
  textSize = "3vh"  -- 3% of viewport height
})
```

### Animations

Create smooth transitions:

```lua
local Animation = FlexLove.Animation

-- Fade animation
local fadeIn = FlexLove.Animation.fade(1.0, 0, 1)
fadeIn:apply(element)

-- Scale animation
local scaleUp = FlexLove.Animation.scale(0.5,
  { width = 100, height = 50 },
  { width = 200, height = 100 }
)
scaleUp:apply(element)

-- Custom animation with easing
local customAnim = FlexLove.Animation.new({
  duration = 1.0,
  start = { opacity = 0, width = 100 },
  final = { opacity = 1, width = 200 },
  easing = "easeInOutCubic"
})
customAnim:apply(element)
```

### Creating Colors

```lua
-- From RGB values (0-1 range)
local red = FlexLove.Color.new(1, 0, 0, 1)

-- From hex string
local blue = FlexLove.Color.fromHex("#0000FF")
local semiTransparent = FlexLove.Color.fromHex("#FF000080")
```

## API Reference

### Gui (Main Module)

- `Gui.init(props)` - Initialize GUI system with base scale
- `Gui.new(props)` - Create a new element
- `Gui.update(dt)` - Update all elements
- `Gui.draw()` - Draw all elements
- `Gui.resize()` - Handle window resize

### Color

- `Color.new(r, g, b, a)` - Create color (values 0-1)
- `Color.fromHex(hex)` - Create from hex string
- `Color:toHex()` - Convert to hex string
- `Color:toRGBA()` - Get RGBA values

### Theme

- `Theme.load(name)` - Load theme by name
- `Theme.setActive(name)` - Set active theme
- `Theme.getActive()` - Get current active theme

### Animation

- `Animation.new(props)` - Create custom animation
- `Animation.fade(duration, from, to)` - Fade animation
- `Animation.scale(duration, from, to)` - Scale animation

## Enums

### TextAlign
- `START` - Align to start
- `CENTER` - Center align
- `END` - Align to end
- `JUSTIFY` - Justify text

### Positioning
- `ABSOLUTE` - Absolute positioning
- `RELATIVE` - Relative positioning
- `FLEX` - Flexbox layout
- `GRID` - Grid layout

### FlexDirection
- `HORIZONTAL` - Horizontal flex
- `VERTICAL` - Vertical flex

### JustifyContent
- `FLEX_START` - Align to start
- `CENTER` - Center align
- `FLEX_END` - Align to end
- `SPACE_AROUND` - Space around items
- `SPACE_BETWEEN` - Space between items
- `SPACE_EVENLY` - Even spacing

### AlignItems / AlignSelf
- `STRETCH` - Stretch to fill
- `FLEX_START` - Align to start
- `FLEX_END` - Align to end
- `CENTER` - Center align
- `BASELINE` - Baseline align

### FlexWrap
- `NOWRAP` - No wrapping
- `WRAP` - Wrap items

## Examples

The `examples/` directory contains comprehensive demos:

- `EventSystemDemo.lua` - Event handling and callbacks
- `CornerRadiusDemo.lua` - Rounded corners showcase
- `ThemeLayeringDemo.lua` - Theme system with layering
- `DisableHighlightDemo.lua` - Highlight control
- `SimpleGrid.lua` - Grid layout examples
- `TextSizePresets.lua` - Text sizing options
- `OnClickAnimations.lua` - Animation examples
- `ZIndexDemo.lua` - Layering demonstration

## Testing

Run tests with:
```bash
lua testing/runAll.lua
# or a specific test:
lua testing/__tests__/<specific_test>
```

## Version & Compatibility

**Current Version**: 1.0.0

**Compatibility:**
- **Lua**: 5.1+
- **LÖVE**: 11.x (tested)
- **LuaJIT**: Compatible

## License

MIT License - see LICENSE file for details.

## Contributing

This library is under active development. Contributions, bug reports, and feature requests are welcome!
