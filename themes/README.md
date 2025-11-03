# FlexLove Theme System

## Overview

FlexLove supports a flexible 9-slice/9-patch theming system that allows you to create scalable UI components using texture atlases. Themes provide state-based visual feedback and automatically handle element sizing.

## Key Features

- **9-Slice Scaling**: Images scale properly to any size without distortion
- **State Management**: Automatic visual feedback for hover, pressed, disabled, and active states
- **Layered Rendering**: Themes render on top of backgroundColor, with borders on top
- **Flexible Organization**: Use separate images, single atlas, or hybrid approach
- **Automatic Highlight Disable**: Elements with themes automatically disable the pressed overlay

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
local Gui = FlexLove.Gui
local Color = FlexLove.Color

-- Load theme
Theme.load("my_theme")
Theme.setActive("my_theme")

-- Create themed button
local button = Gui.new({
  width = 150,
  height = 40,
  text = "Click Me",
  textAlign = "center",
  textColor = Color.new(1, 1, 1, 1),
  backgroundColor = Color.new(0.2, 0.4, 0.8, 0.3),  -- Shows behind theme
  themeComponent = "button",  -- Uses button component from active theme
  callback = function(element, event)
    if event.type == "click" then
      print("Clicked!")
    end
  end
})

-- Create themed panel
local panel = Gui.new({
  width = 300,
  height = 200,
  backgroundColor = Color.new(0.1, 0.1, 0.2, 0.5),  -- Background tint
  themeComponent = "panel"
})
```

## Rendering Layers

Elements with themes render in this order:

1. **backgroundColor** - Rendered first (behind everything)
2. **Theme 9-slice** - Rendered on top of backgroundColor
3. **Borders** - Rendered on top of theme (if specified)
4. **Text** - Rendered last (on top of everything)

This allows you to:
- Tint themed elements with backgroundColor
- Add custom borders on top of themes
- Layer visual effects

## Component States

Themes automatically handle visual states for interactive elements:

- **normal**: Default appearance
- **hover**: When mouse is over the element
- **pressed**: When element is being clicked
- **disabled**: When element.disabled = true
- **active**: When element.active = true (for inputs/focused elements)

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
    },
    disabled = {
      atlas = "themes/button_disabled.png",
      regions = { ... }
    }
  }
}
```

## Theme Definition Example

```lua
-- themes/my_theme.lua
return {
  name = "My Theme",
  atlas = "themes/my_theme/atlas.png",
  
  components = {
    panel = {
      regions = {
        topLeft = {x=0, y=0, w=8, h=8},
        topCenter = {x=8, y=0, w=8, h=8},
        topRight = {x=16, y=0, w=8, h=8},
        middleLeft = {x=0, y=8, w=8, h=8},
        middleCenter = {x=8, y=8, w=8, h=8},
        middleRight = {x=16, y=8, w=8, h=8},
        bottomLeft = {x=0, y=16, w=8, h=8},
        bottomCenter = {x=8, y=16, w=8, h=8},
        bottomRight = {x=16, y=16, w=8, h=8}
      }
    },
    
    button = {
      regions = {
        topLeft = {x=24, y=0, w=8, h=8},
        topCenter = {x=32, y=0, w=8, h=8},
        topRight = {x=40, y=0, w=8, h=8},
        middleLeft = {x=24, y=8, w=8, h=8},
        middleCenter = {x=32, y=8, w=8, h=8},
        middleRight = {x=40, y=8, w=8, h=8},
        bottomLeft = {x=24, y=16, w=8, h=8},
        bottomCenter = {x=32, y=16, w=8, h=8},
        bottomRight = {x=40, y=16, w=8, h=8}
      },
      states = {
        hover = {
          regions = {
            -- Different region coordinates for hover state
            topLeft = {x=48, y=0, w=8, h=8},
            -- ... etc
          }
        },
        pressed = {
          regions = {
            -- Different region coordinates for pressed state
            topLeft = {x=72, y=0, w=8, h=8},
            -- ... etc
          }
        }
      }
    }
  }
}
```

## Advanced Features

### Automatic Highlight Disable

Elements with `themeComponent` automatically set `disableHighlight = true` to prevent the default gray pressed overlay from interfering with theme visuals. You can override this:

```lua
Gui.new({
  themeComponent = "button",
  disableHighlight = false,  -- Force enable highlight overlay
  -- ...
})
```

### Combining with Corner Radius

You can use cornerRadius with themed elements:

```lua
Gui.new({
  themeComponent = "button",
  cornerRadius = 10,  -- Clips theme to rounded corners
  -- ...
})
```

### Border Overlay

Add custom borders on top of themes:

```lua
Gui.new({
  themeComponent = "panel",
  border = { top = true, bottom = true, left = true, right = true },
  borderColor = Color.new(1, 1, 0, 1),  -- Yellow border on top of theme
  -- ...
})
```

## Corner Scaling

By default, 9-slice corners and non-stretched edges are rendered at their original pixel size (1:1). You can scale corners using a numeric multiplier:

### Corner Scaling

```lua
-- themes/my_theme.lua
return {
  name = "My Theme",
  components = {
    button = {
      atlas = "themes/button.png",
      insets = { left = 8, top = 8, right = 8, bottom = 8 },
      scaleCorners = 2,                 -- Scale corners by 2x (numeric multiplier)
      scalingAlgorithm = "bilinear"     -- "bilinear" (smooth) or "nearest" (sharp/pixelated)
    }
  }
}
```

**`scaleCorners` values:**
- Number (e.g., `2`, `1.5`, `0.5`) - Direct scale multiplier
  - `2` = double size
  - `0.5` = half size
  - `1` = original size
- `nil` (default) - No scaling, 1:1 pixel perfect

### Scaling Algorithms

- **`bilinear`** (default): Smooth interpolation between pixels. Best for most use cases.
- **`nearest`**: Nearest-neighbor sampling. Best for pixel art that should maintain sharp edges.

### When to Use Corner Scaling

- **Pixel art themes**: Use `scaleCorners = 2` with `scalingAlgorithm = "nearest"` to maintain crisp pixel boundaries
- **High DPI displays**: Use `scaleCorners = 1.5` or `2` with `scalingAlgorithm = "bilinear"` for smooth scaling
- **Fixed-size UI**: Keep `scaleCorners = nil` (default) for pixel-perfect rendering at original size

### Per-State Scaling

You can also set scaling per-state:

```lua
button = {
  atlas = "themes/button_normal.png",
  scaleCorners = 2,
  scalingAlgorithm = "bilinear",
  states = {
    hover = {
      atlas = "themes/button_hover.png",
      scaleCorners = 2.5,              -- Can override per state
      scalingAlgorithm = "nearest"     -- Different algorithm for this state
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
6. **Transparency**: Use semi-transparent backgroundColor to tint themed elements
7. **Corner Scaling**: Enable for pixel art or responsive UIs; disable for pixel-perfect rendering

## Tools for Creating Atlases

- **TexturePacker**: Professional sprite sheet tool
- **Aseprite**: Pixel art editor with export options
- **Shoebox**: Free sprite sheet packer
- **GIMP/Photoshop**: Manual layout with guides

## Example Themes

See the `space/` directory for a complete theme example with:
- Panel component
- Button component with states (normal, hover, pressed, disabled)
- Compressed and uncompressed versions

## See Also

- `space.lua` - Complete theme definition example
- `ThemeSystemDemo.lua` - Interactive demo of theme system
- `ThemeLayeringDemo.lua` - Demo of backgroundColor/theme/border layering
