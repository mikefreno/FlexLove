# FlexLove Theme System

## Overview

FlexLove supports a flexible 9-slice/9-patch theming system that allows you to create scalable UI components using texture atlases.

## Image Organization Options

You have **three ways** to organize your theme images:

### Option 1: Separate Images Per Component (Recommended for Beginners)

Each component gets its own image file:

```
themes/
  panel.png           (24x24 pixels - 9-slice for panels)
  button_normal.png   (24x24 pixels - 9-slice for buttons)
  button_hover.png    (24x24 pixels - hover state)
  button_pressed.png  (24x24 pixels - pressed state)
  input.png           (24x24 pixels - 9-slice for inputs)
```

**Theme definition:**
```lua
return {
  name = "My Theme",
  components = {
    panel = {
      atlas = "themes/panel.png",
      regions = { ... }
    },
    button = {
      atlas = "themes/button_normal.png",
      regions = { ... },
      states = {
        hover = {
          atlas = "themes/button_hover.png",
          regions = { ... }
        },
        pressed = {
          atlas = "themes/button_pressed.png",
          regions = { ... }
        }
      }
    }
  }
}
```

### Option 2: Single Atlas (Recommended for Performance)

All components in one texture atlas:

```
themes/
  default_atlas.png   (96x48 pixels containing all components)
```

**Theme definition:**
```lua
return {
  name = "My Theme",
  atlas = "themes/default_atlas.png",  -- Global atlas
  components = {
    panel = {
      regions = {
        topLeft = {x=0, y=0, w=8, h=8},
        -- ... regions reference positions in atlas
      }
    },
    button = {
      regions = {
        topLeft = {x=24, y=0, w=8, h=8},  -- Different position in same atlas
        -- ...
      }
    }
  }
}
```

### Option 3: Hybrid (Best of Both Worlds)

Mix global atlas with component-specific images:

```lua
return {
  name = "My Theme",
  atlas = "themes/global_atlas.png",  -- Fallback atlas
  components = {
    panel = {
      -- Uses global atlas
      regions = {x=0, y=0, ...}
    },
    button = {
      atlas = "themes/button.png",  -- Override with specific image
      regions = {x=0, y=0, ...}
    }
  }
}
```

## 9-Slice Structure

Each component image is divided into 9 regions:

```
┌─────┬──────────┬─────┐
│ TL  │   TC     │ TR  │  (Top: fixed height)
├─────┼──────────┼─────┤
│ ML  │   MC     │ MR  │  (Middle: stretches)
├─────┼──────────┼─────┤
│ BL  │   BC     │ BR  │  (Bottom: fixed height)
└─────┴──────────┴─────┘
 Fixed  Stretch  Fixed
```

- **Corners** (TL, TR, BL, BR): Fixed size, never stretched
- **Edges** (TC, BC, ML, MR): Stretched in one direction
- **Center** (MC): Stretched in both directions

## Creating Theme Images

### Minimum Image Size

For a 9-slice image, you need at least **24x24 pixels**:
- 8px for each corner
- 8px for stretchable middle section

### Image Requirements

1. **Format**: PNG with transparency
2. **Color Mode**: RGBA
3. **Border Style**: Draw borders in the corner/edge regions
4. **Center**: Can be solid color or transparent

## Example: Creating a Button Image

For a button with rounded corners and a border:

```
button_normal.png (24x24 pixels)

Pixel layout:
┌────────┬────────────┬────────┐
│ ●●●●●● │ ██████████ │ ●●●●●● │  8px
│ ●●●●●● │ ██████████ │ ●●●●●● │
├────────┼────────────┼────────┤
│ ██████ │ ░░░░░░░░░░ │ ██████ │  8px (stretch)
│ ██████ │ ░░░░░░░░░░ │ ██████ │
├────────┼────────────┼────────┤
│ ●●●●●● │ ██████████ │ ●●●●●● │  8px
│ ●●●●●● │ ██████████ │ ●●●●●● │
└────────┴────────────┴────────┘
  8px     8px(stretch)   8px

Legend:
● = Corner (fixed)
█ = Border edge (stretched)
░ = Fill/background (stretched both ways)
```

## Usage in Code

```lua
local FlexLove = require("FlexLove")
local Theme = FlexLove.Theme
local Gui = FlexLove.GUI

-- Load theme
Theme.load("my_theme")
Theme.setActive("my_theme")

-- Create themed button
local button = Gui.new({
  width = 150,
  height = 40,
  text = "Click Me",
  theme = "button",  -- Uses button component from active theme
  callback = function(element, event)
    print("Clicked!")
  end
})

-- Create themed panel
local panel = Gui.new({
  width = 300,
  height = 200,
  theme = "panel"
})
```

## Component States

Buttons automatically handle three states:
- **normal**: Default appearance
- **hover**: When mouse is over the button
- **pressed**: When button is being clicked

Define state-specific images in your theme:

```lua
button = {
  atlas = "themes/button_normal.png",
  regions = { ... },
  states = {
    hover = {
      atlas = "themes/button_hover.png",
      regions = { ... }
    },
    pressed = {
      atlas = "themes/button_pressed.png",
      regions = { ... }
    }
  }
}
```

## Tips

1. **Start Simple**: Begin with one component (button) before creating a full theme
2. **Test Scaling**: Make sure your 9-slice regions stretch properly at different sizes
3. **Consistent Style**: Keep corner sizes consistent across components
4. **State Variations**: For button states, change colors/brightness rather than structure
5. **Atlas Packing**: Use tools like TexturePacker or Aseprite to create efficient atlases

## Tools for Creating Atlases

- **TexturePacker**: Professional sprite sheet tool
- **Aseprite**: Pixel art editor with export options
- **Shoebox**: Free sprite sheet packer
- **GIMP/Photoshop**: Manual layout with guides

## See Also

- `default.lua` - Example theme with single atlas
- `separate_images_example.lua` - Example with separate images per component
- `ThemeSystemDemo.lua` - Interactive demo of theme system
