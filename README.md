# FlexLöve

A Löve Gui based on Flexbox

FlexLöve is a lightweight, flexible GUI library for Löve2D that implements a flexbox-based layout system. It provides a simple way to create and manage UI elements like windows and buttons with automatic layout calculations, animations, and responsive design.

# This library is no where near ready for sane use, there are many broken, incomplete and missing features. 

## Features

- **Flexbox Layout**: Implement modern flexbox layouts for UI elements
- **Window Management**: Create hierarchical window structures with automatic sizing
- **Button System**: Interactive buttons with click detection and callbacks
- **Animations**: Built-in animation support for transitions and effects
- **Responsive Design**: Automatic resizing based on window dimensions
- **Color Handling**: Utility classes for managing colors in various formats
- **Text Rendering**: Flexible text display with alignment options

## Installation

To use FlexLove, simply copy the `FlexLove.lua` file into your project's `libs` directory and require it in your main application:

```lua
local FlexLove = require("libs.FlexLove")
```

## Basic Usage

```lua
-- Create a main window
local mainWindow = FlexLove.GUI.Window.new({
    x = 100,
    y = 100,
    w = 400,
    h = 300,
    background = FlexLove.Color.new(0.2, 0.2, 0.2, 1),
    text = "Main Window",
})

-- Create a button inside the window
local button = FlexLove.GUI.Button.new({
    parent = mainWindow,
    x = 50,
    y = 50,
    w = 100,
    h = 40,
    text = "Click Me",
    callback = function(button)
        print("Button clicked!")
    end,
})

-- In your love.update function
function love.update(dt)
    FlexLove.GUI.update(dt)
end

-- In your love.draw function
function love.draw()
    FlexLove.GUI.draw()
end
```

## API Reference

### Color

Utility class for color handling with RGB and RGBA components.

- `Color.new(r, g, b, a)` - Create new color instance
- `Color.fromHex(hex)` - Convert hex string to color
- `Color:toHex()` - Convert color to hex string
- `Color:toRGBA()` - Get RGBA values

### Window

Main window class for creating UI containers.

- `Window.new(props)` - Create a new window
- `Window:addChild(child)` - Add child elements to the window
- `Window:draw()` - Draw the window and all its children
- `Window:update(dt)` - Update window state (propagates to children)
- `Window:resize(newWidth, newHeight)` - Resize window based on game size change

### Button

Interactive button element.

- `Button.new(props)` - Create a new button
- `Button:draw()` - Draw the button
- `Button:update(dt)` - Update button state (handles click detection)
- `Button:updateText(newText, autoresize)` - Update button text

### Animation

Animation system for UI transitions.

- `Animation.new(props)` - Create a new animation
- `Animation:interpolate()` - Get interpolated values during animation
- `Animation:apply(element)` - Apply animation to a GUI element
- `Animation.fade(duration, fromOpacity, toOpacity)` - Create a fade animation
- `Animation.scale(duration, fromScale, toScale)` - Create a scale animation

## Enums

Predefined enums for various layout and styling options:

- TextAlign: START, CENTER, END, JUSTIFY
- Positioning: ABSOLUTE, FLEX
- FlexDirection: HORIZONTAL, VERTICAL
- JustifyContent: FLEX_START, CENTER, SPACE_AROUND, FLEX_END, SPACE_EVENLY, SPACE_BETWEEN
- AlignItems: STRETCH, FLEX_START, FLEX_END, CENTER, BASELINE
- AlignSelf: AUTO, STRETCH, FLEX_START, FLEX_END, CENTER, BASELINE
- AlignContent: STRETCH, FLEX_START, FLEX_END, CENTER, SPACE_BETWEEN, SPACE_AROUND

## Examples

See the `examples/` directory for complete usage examples.

## License

MIT License - see LICENSE file for details.
