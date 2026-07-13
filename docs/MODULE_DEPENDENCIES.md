# FlexLöve Module Dependencies

This document provides a comprehensive overview of module dependencies in FlexLöve, helping you understand which modules are required, which are optional, and how the build profiles are assembled.

## Module Loading Mechanism

`FlexLove.lua` loads modules through two helpers backed by [`ModuleLoader`](../modules/ModuleLoader.lua):

- **`req(name)`** — a hard `require("modules." .. name)`. The module **must** be present or the library will error on load. These are core modules.
- **`safeReq(name, true)`** — delegates to `ModuleLoader.safeRequire(...)`. If the module file is absent, `ModuleLoader` returns a **null-object stub** (a table whose `__index` metatable returns safe no-op defaults), and `safeReq` normalizes that stub to `nil`. These are optional modules.

Because `req()` is a hard `require`, any module transitively reached from a core module is also mandatory and **cannot** be excluded. Only the modules loaded via `safeReq` (plus the standalone `MemoryScanner` debug tool, which the library never loads itself) are eligible for exclusion in a build profile.

## Dependency Graph

### Core Required Modules

These modules are loaded via `req()` (or are transitively required by a core module) and are **always present** in every profile. They cannot be excluded.

```
FlexLove.lua
├── ErrorHandler          (error logging & handling)
├── ModuleLoader           (safe module loading + null-object stubs)
├── utils                  (shared utilities, validation, font cache, path/text sanitizers)
│   ├── requires: Enums, FontCache, NumberValidation, PathValidator, TextSanitizer
│   └── injected: ErrorHandler
├── Calc                   (expression/calc() evaluation for lengths)
├── Units                  (unit parsing & resolution)
├── Context                (global state & viewport)
├── StateManager           (immediate-mode state persistence)
├── RoundedRect            (rounded rectangle rendering)
├── Grid                   (grid layout utilities)
├── InputEvent             (input event abstraction)
├── TextEditor             (text input/caret handling)
│   └── requires: UTF8
├── LayoutEngine           (flexbox layout calculations)
├── Renderer               (canvas rendering)
│   └── requires: UTF8
├── EventHandler           (event routing & callbacks)
├── ScrollManager          (scroll behavior)
├── ZIndex                 (z-index stacking management)
├── Element                (UI element primitives — the central type)
├── Color                  (color utilities)
├── Select                 (select/dropdown element)
└── PropertySchema         (property definition/validation)
```

Supporting files pulled in transitively by the core modules above:

```
Enums                     (enum tables, required by utils)
FontCache                 (font loading/caching, required by utils)
NumberValidation          (numeric validation, required by utils)
PathValidator             (path sanitization, required by utils)
TextSanitizer             (text input sanitization, required by utils)
                          └── requires: utf8 (standard library)
UTF8                      (UTF-8 helpers, required by Renderer & TextEditor)
types                    (LuaDoc type definitions — editor/LSP only, not required at runtime)
```

#### Behaviors Subsystem

FlexLöve uses a pluggable behavior system. All behaviors live in `modules/behaviors/` and require the base `Behavior` module. They are hard-required (core) and ships in every profile:

```
Behavior                  (base behavior factory: Behavior.new(spec))
├── behaviors.Clickable    (mouse/touch press, hit-testing)
├── behaviors.Themed       (renderer ownership + theme-state rendering)
├── behaviors.Imageable    (image loading + image render config)
├── behaviors.Animated     (animation update, interpolation, chaining)
├── behaviors.Selectable  (selection state for Select options)
├── behaviors.TextEditable(text editing state ownership)
├── behaviors.Scrollable  (scroll manager attachment for overflow elements)
└── behaviors.Persistable  (public-property persistence across immediate-mode recreation)
```

### Optional Modules

These modules are loaded via `safeReq()` and can be excluded to reduce bundle size. Excluding them yields a graceful null-object stub (no crashes):

#### Animation

```
Animation  →  element.animation, FlexLove.Animation API, transitions, keyframes
```

**What you lose:** animated properties, transitions, `FlexLove.Animation.Transform`.

#### Image Modules

```
ImageRenderer  →  image rendering for elements
ImageScaler    →  image scaling utilities (used by ImageRenderer)
ImageCache     →  image caching/eviction
NinePatch      →  9-patch image rendering
```

**What you lose:** `element.image`, `element.imageFit`, `element.imageRepeat`, 9-patch support, image caching.

#### Theme

```
Theme  →  FlexLove.Theme API, element.theme, preset theme styles
```

**What you lose:** theming API, theme-based component styling, `themes/` directory (only shipped in default/full profiles).

#### Blur

```
Blur  →  element.backdropBlur, glassmorphic effects
```

**What you lose:** backdrop blur, glassmorphism.

#### GestureRecognizer

```
GestureRecognizer  →  touch gesture recognition, swipe/pinch/zoom, multi-touch
```

**What you lose:** touch gestures, swipe detection, pinch/zoom.

#### Keyboard Navigation

```
KeyboardNavigation  →  Tab/Shift+Tab + arrow-key spatial focus navigation
FocusIndicator      →  visible focus ring drawn for the focused element
```

**What you lose:** opt-in keyboard navigation, focus indicator rendering.

#### Performance

```
Performance  →  FlexLove._Performance API, performance HUD (F3), frame timing
```

**What you lose:** performance monitoring, HUD, frame/memory metrics.

#### MemoryScanner (Debug Tool)

```
MemoryScanner  →  runtime memory/circular-reference scanning (standalone script)
```

`MemoryScanner` is not loaded by `FlexLove.lua` at all — it is a standalone debugging utility users invoke manually. It ships only in the **full** profile.

## Module Loading Order

`FlexLove.lua` wires modules in this order:

1. **ErrorHandler** — loaded first (via `req`) so all later modules can log errors.
2. **ModuleLoader** — initialized with `ErrorHandler`, providing `safeRequire`.
3. **Core modules** — the `req()` group above, in declaration order (utils, Calc, Units, Context, … Element, Color, Select, PropertySchema).
4. **Behaviors** — the `behaviors/*.lua` set, each requiring `Behavior`.
5. **Optional modules** — the `safeReq()` group (Blur, Performance, KeyboardNavigation, FocusIndicator, image modules, GestureRecognizer, Animation, Theme), each degrading to a null-object stub if absent.

## Profile-Specific Dependencies

The four profiles are defined by a **blacklist** in [`scripts/create-profile-packages.sh`](../scripts/create-profile-packages.sh). All modules not in a profile's blacklist ship in that profile. Sizes below are approximate, measured against the full library (see [`BUILD_PROFILES.md`](./BUILD_PROFILES.md) for the full matrix).

### Minimal (~78%)

Core only — excludes all optional modules and the debug tool.

Exclude: `Animation`, `NinePatch`, `ImageRenderer`, `ImageScaler`, `ImageCache`, `Theme`, `Blur`, `GestureRecognizer`, `Performance`, `MemoryScanner`, `KeyboardNavigation`, `FocusIndicator`.

### Slim (~88%)

Minimal + animation, image support, keyboard nav and focus.

Exclude: `Theme`, `Blur`, `GestureRecognizer`, `Performance`, `MemoryScanner`.

### Default (~96%)

Slim + theme, blur and gesture. Excludes only debug tools.

Exclude: `Performance`, `MemoryScanner`.

### Full (100%)

Everything, including `Performance` and `MemoryScanner`.

## Checking Module Availability

You can check at runtime whether a module was loaded or stubbed:

```lua
local ModuleLoader = require("modules.ModuleLoader")

-- Returns true for a real module, false for a null-object stub
if ModuleLoader.isModuleLoaded("modules.Animation") then
  local anim = FlexLove.Animation.new({ ... })
else
  print("Animation not available in this build profile")
end

-- List what was loaded vs stubbed
print("loaded:", ModuleLoader.getLoadedModules())
print("stubbed:", ModuleLoader.getStubModules())
```

## Dependency Injection Pattern

Core modules receive their collaborators through a `deps` table passed to an `init(deps)` constructor (rather than reaching for globals), which is what allows optional modules to be swapped for null-object stubs:

```lua
-- Example: an element receives both required and optional collaborators
function SomeModule.init(deps)
  SomeModule._utils = deps.utils            -- required
  SomeModule._ErrorHandler = deps.ErrorHandler -- required
  SomeModule._Animation = deps.Animation    -- optional; may be nil (stubbed)
  SomeModule._Theme = deps.Theme           -- optional; may be nil (stubbed)
end
```

When `safeReq()` returns `nil` for a missing optional module, `ModuleLoader` has already registered a null-object stub in its place so that downstream `.init(deps)` calls and property accesses never crash.

## Custom Build Profiles

FlexLöve does **not** expose a runtime profile-registration API — profiles are a **build-time** concept. To create a custom profile, add an entry to the `get_excluded_modules` case statement in [`scripts/create-profile-packages.sh`](../scripts/create-profile-packages.sh):

```bash
get_excluded_modules() {
  case "$1" in
    # ... existing profiles ...
    my-game)
      # Add Animation + Image, but drop Theme, Blur, gestures, debug tools
      echo "Theme.lua Blur.lua GestureRecognizer.lua Performance.lua MemoryScanner.lua"
      ;;
  esac
}
```

New modules added to `modules/` are included in **all** profiles unless they appear in a profile's blacklist. Only modules loaded via `safeReq()` (plus the standalone `MemoryScanner`) can be blacklisted — core modules are hard-required and will crash if omitted.

> **Note:** Whatever you change in `create-profile-packages.sh`, mirror it in [`testing/__tests__/release_variants_test.lua`](../testing/__tests__/release_variants_test.lua), whose `PROFILES` table asserts that every profile initializes FlexLöve without crashing.

## Best Practices

1. **Start with the default profile** unless you have specific bundle-size requirements.
2. **Measure before optimizing** — check the actual size delta, not module count.
3. **Run the release-variants test** after changing a profile blacklist: `lua testing/__tests__/release_variants_test.lua`.
4. **Check availability at runtime** with `ModuleLoader.isModuleLoaded(...)` before calling optional-module APIs.
5. **Document your profile** — if you maintain a custom profile, note which features are disabled.

## See Also

- [BUILD_PROFILES.md](./BUILD_PROFILES.md) — full profile × module matrix
- [RELEASE.md](../RELEASE.md) — release process, profile packages and checksums
- [ModuleLoader.lua](../modules/ModuleLoader.lua) — source for safe module loading
- [create-profile-packages.sh](../scripts/create-profile-packages.sh) — profile blacklist source of truth
