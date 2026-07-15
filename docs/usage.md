# Authoring UIs with FlexLöve

Use this guide when calling FlexLöve from game code or examples: initializing,
building UIs, using enums/units/colors, and handling the frame lifecycle. If
you're modifying the library itself, read [`repo.md`](repo.md) instead.

## Orientation

- **What it is**: A CSS-familiar flexbox/grid UI library for LÖVE2D — theming, animations, events, text, images.
- **Full docs**: <https://mikefreno.github.io/FlexLove/> (API reference, examples)
- **Local reference**: `README.md` (quick start, features, keyboard nav) and `docs/`
- **Only `FlexLove.lua` uses `require()`** — you import through the top-level `FlexLove` table, not internal modules.

## Frame lifecycle

1. **Init once**: `FlexLove.init({ theme = "...", keyboardNavigation = true, ... })`
2. **Per frame**: hook `flexlove.update(dt)` to `love.update()` and `flexlove.draw(gameDrawFunc, postDrawFunc)` to `love.draw()`. FlexLöve auto-manages the frame begin/end boundaries for you.
3. **On viewport change**: `FlexLove.resize(w, h)` (triggers relayout)
4. **On shutdown**: `FlexLove.destroy()`

`beginFrame()` / `endFrame()` are **optional** — they're only needed when you want explicit frame boundaries in immediate mode (e.g. tests). In normal use, `draw()` calls `endFrame()` internally.

## Rendering modes

- **Retained mode** (default): Elements persist across frames; update their properties manually between frames.
- **Immediate mode**: Set with `FlexLove.setMode("immediate")` in `love.load()` (or before your first draw); elements are recreated each frame inside `love.draw()`. `draw()` calls `endFrame()` internally, which triggers `layoutChildren()` on top-level elements.

Choose immediate for rapid prototyping, retained for production performance.

> `beginFrame()` / `endFrame()` are **optional** and rarely needed — they exist for explicit frame control (e.g. tests). In normal use, hook `love.update`/`love.draw` (below) and FlexLöve handles the rest.

## LÖVE hooks you must wire

Wire the corresponding `FlexLove.*` function to each LÖVE callback. Every one is safe to call even if the feature is unused; omitting a hook just disables the related capability.

```lua
function love.load()
  FlexLove.init({
    theme = "space",
    immediateMode = false,
    keyboardNavigation = true,
  })
  love.keyboard.setKeyRepeat(true)  -- needed for text editing (arrows, backspace, etc.)
end

-- Per frame
function love.update(dt)    FlexLove.update(dt) end   -- animations, hover, scroll, text cursors
function love.draw()        FlexLove.draw() end        -- render (auto-calls endFrame in immediate mode)

-- Layout / viewport
function love.resize(w, h)  FlexLove.resize(w, h) end  -- relayout on window res/e

-- Input — each enables a specific capability:
function love.textinput(t)                FlexLove.textinput(t) end            -- text entry into editable elements
function love.keypressed(k, sc, rep)      FlexLove.keypressed(k, sc, rep) end -- text selection/keys, keyboard nav, debug HUD toggle
function love.wheelmoved(dx, dy)          FlexLove.wheelmoved(dx, dy) end     -- mouse-wheel scrolling
function love.touchpressed(id,x,y,dx,dy,p)  FlexLove.touchpressed(id,x,y,dx,dy,p) end   -- touch press
function love.touchmoved(id,x,y,dx,dy,p)    FlexLove.touchmoved(id,x,y,dx,dy,p) end     -- touch drag / gesture tracking
function love.touchreleased(id,x,y,dx,dy,p) FlexLove.touchreleased(id,x,y,dx,dy,p) end  -- touch release

-- Shutdown / scene change
FlexLove.destroy()  -- call when you tear down the UI to release element state
```

> `keypressed` also toggles the debug overlay if you passed `debugDrawKey = "F3"` (or similar) to `init`. The overlay is also controllable via `FlexLove.setDebugDraw(bool)` / `FlexLove.getDebugDraw()`.

## Common Patterns

- **Return values**: Single value OR `value, errorString` (nil on success for error). Check for error strings when a call can fail.
- **Enums**: `utils.enums.EnumName.VALUE` (e.g., `Positioning.FLEX`)
- **Units**: `Units.parse(value)` → `value, unit`; `Units.resolve(value, unit, viewportW, viewportH, parentSize)`
- **Colors**: `Color.new(r, g, b, a)` (0–1 range) or `Color.fromHex("#RRGGBB")`
- **Auto-sizing**: Omit `width`/`height` entirely (NOT `"auto"`) to let the element size to its content.

## Typical call surface

- **Lifecycle**: `FlexLove.init(opts)`, `FlexLove.destroy()`
- **Per frame**: `FlexLove.update(dt)`, `FlexLove.draw(gameDrawFunc?, postDrawFunc?)`
- **Layout/viewport**: `FlexLove.resize(w, h)`, `FlexLove.setMode("immediate"|"retained")`, `FlexLove.getMode()`
- **Frame control (optional)**: `FlexLove.beginFrame()`, `FlexLove.endFrame()` — see note above
- **Input hooks** (wire to the matching `love.*` callbacks): `textinput`, `keypressed`, `wheelmoved`, `touchpressed`, `touchmoved`, `touchreleased`
- **Elements**: `FlexLove.new(props, callback?)`, `FlexLove.getById(id)`, `FlexLove.getElementAtPosition(x, y)`
- **Focus**: `FlexLove.getFocusedElement()`, `FlexLove.setFocusedElement(el)`, `FlexLove.clearFocus()`
- **Keyboard nav**: `FlexLove.enableKeyboardNavigation(opts)` (also `init({ keyboardNavigation = opts })`) — or pass `true` for defaults
- **Debug**: `FlexLove.setDebugDraw(bool)`, `FlexLove.getDebugDraw()`
- **Deferred (canvas-safe) ops**: `FlexLove.deferCallback(fn)`, `FlexLove.executeDeferredCallbacks()`
- **Calc/units**: `FlexLove.calc("50% - 10vw")`

See the [API reference](https://mikefreno.github.io/FlexLove/api.html) for the full list including touch, GC, and state utilities.
