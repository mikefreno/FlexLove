# FlexLöve Agent Guidelines

## Testing
- **Run all tests**: `lua testing/runAll.lua` (coverage report in `luacov.report.out`)
- **Run single test**: `lua testing/__tests__/<test_file>.lua`
- **Test immediate mode**: Call `FlexLove.setMode("immediate")` in `setUp()`, then `FlexLove.beginFrame()`/`FlexLove.endFrame()` to trigger layout

## Code Style
- **Modules**: Use `local ModuleName = {}` pattern, return table at end
- **Constructors**: `ClassName.new(props)` → instance (always returns, never nil)
- **Instance methods**: `instance:methodName()` with colon syntax
- **Static methods**: `ClassName.methodName()` with dot syntax
- **Private fields**: Prefix with `_` (e.g., `self._internalState`)
- **LuaDoc annotations**: Use `---@param`, `---@return`, `---@class`, `---@field` for all public APIs
- **Error handling**: Use `ErrorHandler.error(module, message)` for critical errors, `ErrorHandler.warn(module, message)` for warnings
- **String format**: Use `string.format()` for complex strings, avoid concatenation
- **Auto-sizing**: Omit `width`/`height` properties (NOT `width = "auto"`)

## Architecture
- **Immediate mode**: Elements recreated each frame, layout triggered by `endFrame()` → `layoutChildren()` called on top-level elements
- **Retained mode**: Elements persist, must manually update properties (default)
- **Dependencies**: Pass via `deps` table parameter in constructors (e.g., `{utils, ErrorHandler, Units}`)
- **Layout flow**: `Element.new()` → `layoutChildren()` on construction → `resize()` on viewport change → `layoutChildren()` again
- **CSS positioning**: `top/right/bottom/left` applied via `LayoutEngine:applyPositioningOffsets()` for absolute/relative containers

## Common Patterns
- **Return values**: Single value OR `value, errorString` (nil on success for error)
- **Enums**: Access via `utils.enums.EnumName.VALUE` (e.g., `Positioning.FLEX`)
- **Units**: Parse with `Units.parse(value)` → `value, unit`, resolve with `Units.resolve(value, unit, viewportW, viewportH, parentSize)`
- **Colors**: Use `Color.new(r, g, b, a)` (0-1 range) or `Color.fromHex("#RRGGBB")`
