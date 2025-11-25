# FlexLöve Module Dependencies

This document provides a comprehensive overview of module dependencies in FlexLöve, helping you understand which modules are required and which are optional.

## Dependency Graph

### Core Required Modules

These modules are **always required** and cannot be excluded:

```
FlexLove.lua
├── ErrorHandler        (error logging & handling)
├── ModuleLoader        (safe module loading)
├── BuildProfile        (profile management)
├── utils               (utility functions & enums)
├── Units               (unit parsing & resolution)
│   └── requires: Context, ErrorHandler
├── Context             (global state & viewport)
├── StateManager        (immediate mode state persistence)
├── Color               (color utilities)
│   └── requires: ErrorHandler
├── InputEvent          (input event abstraction)
├── TextEditor          (text input handling)
├── LayoutEngine        (flexbox layout calculations)
│   └── requires: ErrorHandler, Performance (optional)
├── Renderer            (canvas rendering)
├── EventHandler        (event routing & callbacks)
│   └── requires: ErrorHandler, Performance (optional), InputEvent, utils
├── ScrollManager       (scroll behavior)
├── Element             (UI element primitives)
│   └── requires: ALL core modules + optional modules
├── RoundedRect         (rounded rectangle rendering)
└── Grid                (grid layout utilities)
```

### Optional Modules

These modules can be excluded to reduce bundle size:

#### Animation Module
```
Animation
├── requires: ErrorHandler, Color
├── used by: Element (for animations)
└── size impact: ~15% of total
```

**What you lose:**
- `element.animation` property
- `FlexLove.Animation` API
- Transition effects
- Keyframe animations

#### Image Modules
```
ImageRenderer
├── requires: ErrorHandler, utils
└── used by: Element (for image rendering)

ImageScaler
├── requires: ErrorHandler
└── used by: ImageRenderer

ImageCache
└── used by: Element (for image caching)

NinePatch
├── requires: ErrorHandler
└── used by: Element (for 9-patch rendering)
```

**What you lose:**
- `element.image` property
- `element.imageFit` property
- `element.imageRepeat` property
- 9-patch image support
- Image caching

#### Theme Module
```
Theme
├── requires: ErrorHandler, Color, utils
└── used by: Element (for theming)
```

**What you lose:**
- `FlexLove.Theme` API
- `element.theme` property
- `element.themeComponent` property
- Preset theme styles
- Theme-based component styling

#### Blur Module
```
Blur
└── used by: Element (for backdrop blur effects)
```

**What you lose:**
- `element.backdropBlur` property
- Glassmorphic effects

#### Performance Module
```
Performance
├── requires: ErrorHandler
└── used by: LayoutEngine, EventHandler, FlexLove
```

**What you lose:**
- `FlexLove._Performance` API
- Performance HUD (F3 toggle)
- Performance monitoring
- Frame timing metrics
- Memory profiling

#### GestureRecognizer Module
```
GestureRecognizer
└── used by: Element (for gesture detection)
```

**What you lose:**
- Touch gesture recognition
- Swipe detection
- Pinch/zoom gestures
- Multi-touch support

## Module Loading Order

FlexLöve loads modules in this order:

1. **ErrorHandler** - Must be loaded first for error reporting
2. **ModuleLoader** - Loads modules safely with null-object fallbacks
3. **BuildProfile** - Registers and manages build profiles
4. **Core modules** - Required for basic functionality
5. **Optional modules** - Loaded with `ModuleLoader.safeRequire()`

## Profile-Specific Dependencies

### Minimal Profile (~70%)
Only includes core required modules. No optional dependencies.

### Slim Profile (~80%)
Adds image, animation, gesture support:
- Animation
- ImageRenderer
- ImageScaler
- ImageCache
- GestureRecognizer

### Default Profile (~95%)
Adds theme and visual effects:
- All Slim modules
- Theme
- NinePatch
- Blur

### Full Profile (100%)
Includes all modules:
- All Default modules
- Performance

## Checking Module Availability

You can check if a module is loaded at runtime:

```lua
local ModuleLoader = require("modules.ModuleLoader")

-- Check if Animation is available
if ModuleLoader.isModuleLoaded("modules.Animation") then
  -- Use Animation module
  local anim = FlexLove.Animation.new({ ... })
else
  -- Animation not available, use fallback
  print("Animation module not loaded")
end
```

## Dependency Injection Pattern

FlexLöve uses dependency injection to handle optional modules:

```lua
-- In Element.lua
function Element.init(deps)
  -- Core dependencies (required)
  Element._utils = deps.utils
  Element._ErrorHandler = deps.ErrorHandler
  
  -- Optional dependencies (may be null objects)
  Element._Animation = deps.Animation  -- May be a no-op stub
  Element._Theme = deps.Theme          -- May be a no-op stub
end
```

If a module is missing, `ModuleLoader` returns a **null object** that:
- Has the same method names as the real module
- Returns safe default values
- Prevents crashes from missing dependencies

## Custom Build Profiles

You can create custom profiles with specific module combinations:

```lua
local BuildProfile = require("modules.BuildProfile")

-- Register a custom profile
BuildProfile.register({
  name = "my-game",
  description = "Custom profile for my game",
  size = 75,
  modules = {
    -- Core modules (required)
    "utils", "Units", "Context", "StateManager",
    "ErrorHandler", "Color", "InputEvent", "TextEditor",
    "LayoutEngine", "Renderer", "EventHandler",
    "ScrollManager", "Element", "RoundedRect", "Grid",
    
    -- Optional: Add Animation but not Theme
    "Animation",
    "ImageRenderer",
    "ImageScaler",
    "ImageCache",
  }
})

-- Set active profile
BuildProfile.setActive("my-game")
```

## Best Practices

1. **Start with Default Profile** - Use the default profile unless you have specific bundle size requirements

2. **Profile Before Optimizing** - Measure your actual bundle size before excluding modules

3. **Test Without Optional Modules** - If excluding modules, test thoroughly to ensure no features break

4. **Use ModuleLoader Checks** - Always check if optional modules are loaded before using them

5. **Document Your Profile** - If creating a custom profile, document which features are disabled

## See Also

- [BUILD_PROFILES.md](./BUILD_PROFILES.md) - Detailed profile information
- [README.md](../README.md) - Getting started guide
- [ModuleLoader.lua](../modules/ModuleLoader.lua) - Source code for module loading
