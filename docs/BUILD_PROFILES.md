# FlexLöve Build Profiles

FlexLöve ships in four build profiles so you can trim bundle size to your use case. Optional modules (loaded via `ModuleLoader.safeRequire`) degrade gracefully to null-object stubs when absent, so excluding a module never crashes the library — it only disables that feature.

The profiles are defined by a **blacklist** in [`scripts/create-profile-packages.sh`](../scripts/create-profile-packages.sh): every module not in a profile's blacklist is included. New modules added to `modules/` automatically appear in all profiles unless they are blacklisted, and only `safeRequire`-loaded modules (plus the standalone `MemoryScanner` debug tool) can be blacklisted — core modules are hard-required.

## Available Profiles

| Profile | Modules | Approx. size | Description |
|---------|---------|--------------|-------------|
| **Minimal** | 28 | ~78% | Core functionality only — layouts, basic elements, text |
| **Slim** | 35 | ~88% | + animation, image support, keyboard nav and focus |
| **Default** | 38 | ~96% | + theme, blur and gesture |
| **Full** | 40 | 100% | Everything, including performance monitoring and memory scanning |

> Approximate sizes are measured against the full library by total `.lua` byte count; the `themes/` directory is additionally bundled in the **default** and **full** profile packages.

## Profile × Module Matrix

`✓` = included, `—` = excluded.

| Module | Tier | Minimal | Slim | Default | Full |
|--------|------|:-------:|:----:|:-------:|:----:|
| `Animation` | Optional | — | ✓ | ✓ | ✓ |
| `Behavior` | Core | ✓ | ✓ | ✓ | ✓ |
| `Blur` | Optional | — | — | ✓ | ✓ |
| `Calc` | Core | ✓ | ✓ | ✓ | ✓ |
| `Color` | Core | ✓ | ✓ | ✓ | ✓ |
| `Context` | Core | ✓ | ✓ | ✓ | ✓ |
| `Element` | Core | ✓ | ✓ | ✓ | ✓ |
| `Enums` | Core | ✓ | ✓ | ✓ | ✓ |
| `ErrorHandler` | Core | ✓ | ✓ | ✓ | ✓ |
| `EventHandler` | Core | ✓ | ✓ | ✓ | ✓ |
| `FocusIndicator` | Optional | — | ✓ | ✓ | ✓ |
| `FontCache` | Core | ✓ | ✓ | ✓ | ✓ |
| `GestureRecognizer` | Optional | — | — | ✓ | ✓ |
| `Grid` | Core | ✓ | ✓ | ✓ | ✓ |
| `ImageCache` | Optional | — | ✓ | ✓ | ✓ |
| `ImageRenderer` | Optional | — | ✓ | ✓ | ✓ |
| `ImageScaler` | Optional | — | ✓ | ✓ | ✓ |
| `InputEvent` | Core | ✓ | ✓ | ✓ | ✓ |
| `KeyboardNavigation` | Optional | — | ✓ | ✓ | ✓ |
| `LayoutEngine` | Core | ✓ | ✓ | ✓ | ✓ |
| `MemoryScanner` | Debug | — | — | — | ✓ |
| `ModuleLoader` | Core | ✓ | ✓ | ✓ | ✓ |
| `NinePatch` | Optional | — | ✓ | ✓ | ✓ |
| `NumberValidation` | Core | ✓ | ✓ | ✓ | ✓ |
| `PathValidator` | Core | ✓ | ✓ | ✓ | ✓ |
| `Performance` | Optional | — | — | — | ✓ |
| `PropertySchema` | Core | ✓ | ✓ | ✓ | ✓ |
| `Renderer` | Core | ✓ | ✓ | ✓ | ✓ |
| `RoundedRect` | Core | ✓ | ✓ | ✓ | ✓ |
| `ScrollManager` | Core | ✓ | ✓ | ✓ | ✓ |
| `Select` | Core | ✓ | ✓ | ✓ | ✓ |
| `StateManager` | Core | ✓ | ✓ | ✓ | ✓ |
| `TextEditor` | Core | ✓ | ✓ | ✓ | ✓ |
| `TextSanitizer` | Core | ✓ | ✓ | ✓ | ✓ |
| `Theme` | Optional | — | — | ✓ | ✓ |
| `UTF8` | Core | ✓ | ✓ | ✓ | ✓ |
| `Units` | Core | ✓ | ✓ | ✓ | ✓ |
| `ZIndex` | Core | ✓ | ✓ | ✓ | ✓ |
| `types` | Core | ✓ | ✓ | ✓ | ✓ |
| `utils` | Core | ✓ | ✓ | ✓ | ✓ |

In addition to the modules above, every profile package bundles the eight **behaviors** from `modules/behaviors/` (`Clickable`, `Themed`, `Imageable`, `Animated`, `Selectable`, `TextEditable`, `Scrollable`, `Persistable`) plus `FlexLove.lua` and `LICENSE`. The `themes/` directory is included only in the **default** and **full** packages.

## Choosing a Profile

- **Minimal** — Smallest bundle. Use when you only need layouts, basic elements and text, and don't use images, animations, theming, or gestures.
- **Slim** — Adds animation, image rendering/caching and 9-patch, plus opt-in keyboard navigation and the focus indicator. Good for games with rich media UI but no theming/gestures.
- **Default** — The recommended starting point. Adds theme support, backdrop blur and gesture recognition. Drops only the debugging tools.
- **Full** — Everything, including the `Performance` HUD and `MemoryScanner` debug tool. Use during development and profiling.

## Installation

Download your preferred profile package from the [releases page](https://github.com/mikefreno/FlexLove/releases) and extract it into your LÖVE2D project:

```bash
# Example: install the default profile
unzip flexlove-default-v0.14.0.zip
cp -r flexlove/modules ./
cp flexlove/FlexLove.lua ./
```

Verify download integrity with the bundled SHA256 checksum:

```bash
shasum -a 256 -c flexlove-default-v0.14.0.zip.sha256
```

## Creating a Custom Profile

Profiles are a build-time concept — there is no runtime API. To add a custom profile, add a case to `get_excluded_modules()` in [`scripts/create-profile-packages.sh`](../scripts/create-profile-packages.sh) and mirror it in the `PROFILES` table of [`testing/__tests__/release_variants_test.lua`](../testing/__tests__/release_variants_test.lua) so the profile is verified to initialize without crashing.

See [MODULE_DEPENDENCIES.md](./MODULE_DEPENDENCIES.md) for the full dependency graph and module loading order.

## Requirements

- LÖVE2D 11.0 or higher
- Lua 5.1 / LuaJIT (the library targets the LuaJIT runtime)
