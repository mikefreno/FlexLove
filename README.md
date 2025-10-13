# FlexLöve

A Löve GUI library based on Flexbox with theming and animation support

FlexLöve is a lightweight, flexible GUI library for Löve2D that implements a flexbox-based layout system. It provides a simple way to create and manage UI elements with automatic layout calculations, animations, theming, and responsive design.

## ⚠️ Development Status

This library is under active development. While many features are functional, some aspects may change or have incomplete/broken implementations.

## Features

- **Flexbox Layout**: Modern flexbox layouts for UI elements with full flex properties
- **Grid Layout**: CSS-like (but simplified) grid system for structured layouts
- **Element Management**: Hierarchical element structures with automatic sizing
- **Interactive Elements**: Buttons with click detection, event system, and callbacks
- **Theme System**: 9-slice/9-patch theming with state support (normal, hover, pressed, disabled)
- **Animations**: Built-in animation support for transitions and effects
- **Responsive Design**: Automatic resizing with viewport units (vw, vh, %)
- **Color Handling**: Utility classes for managing colors in various formats
- **Text Rendering**: Flexible text display with alignment and auto-scaling
- **Corner Radius**: Rounded corners with individual corner control
- **Advanced Positioning**: Absolute, relative, flex, and grid positioning modes

## Installation

Copy the `FlexLove.lua` file into your project and require it:

```lua
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color
```

## Quick Start

```lua
local FlexLove = require("FlexLove")
local Gui = FlexLove.GUI
local Color = FlexLove.Color

function love.load()
  -- Initialize GUI system
  Gui.init({
    baseScale = { width = 1920, height = 1080 }
  })
  
  -- Create a container
  local container = Gui.new({
    x = 100,
    y = 100,
    width = 400,
    height = 300,
    backgroundColor = Color.new(0.2, 0.2, 0.2, 1),
    cornerRadius = 10,
    border = { top = true, bottom = true, left = true, right = true },
    borderColor = Color.new(0.8, 0.8, 0.8, 1),
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    padding = { top = 20, right = 20, bottom = 20, left = 20 }
  })
  
  -- Create a button
  local button = Gui.new({
    parent = container,
    width = 200,
    height = 50,
    text = "Click Me",
    textAlign = "center",
    textColor = Color.new(1, 1, 1, 1),
    backgroundColor = Color.new(0.2, 0.6, 0.9, 1),
    cornerRadius = 8,
    callback = function(element, event)
      if event.type == "click" then
        print("Button clicked!")
      end
    end
  })
end

function love.update(dt)
  Gui.update(dt)
end

function love.draw()
  Gui.draw()
end

function love.resize(w, h)
  Gui.resize()
end
```

## Core Concepts

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
element.animation = Animation.fade(1.0, 0, 1)

-- Scale animation
element.animation = Animation.scale(0.5, 1, 1.2)

-- Custom animation
element.animation = Animation.new({
  duration = 1.0,
  from = { width = 100, height = 50 },
  to = { width = 200, height = 100 },
  easing = "easeInOut"
})
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
cd testing
lua runAll.lua
```

## License

MIT License - see LICENSE file for details.

## Contributing

This library is under active development. Contributions, bug reports, and feature requests are welcome!
