# Editing FlexLöve

Use this guide when modifying the library itself: `modules/`, `FlexLove.lua`,
`testing/`, `scripts/`, config files, or the release pipeline. If you're only
using FlexLöve from game code, read [`usage.md`](usage.md) instead.

## Testing

- **Run all tests**: `lua testing/runAll.lua --no-coverage`
- **Run single test**: `lua testing/__tests__/<test_file>.lua`
- **Coverage**: Requires `luacov` luarocks module; opt-out with `--no-coverage`
- **Test lifecycle**: `setUp()` → `FlexLove.init(); FlexLove.beginFrame()` — `tearDown()` → `FlexLove.endFrame(); FlexLove.destroy()`
- **Immediate mode**: Call `FlexLove.setMode("immediate")` in `setUp()` before `beginFrame()`
- **New test files require**: `package.path` extension, custom searcher for `FlexLove.modules.*`, `require("testing.loveStub")`, and the top-level `FlexLove.init()` call (see `testing/__tests__/flexlove_test.lua` for template)
- **Assertions**: Use `luaunit` (bundled in `testing/luaunit.lua`)

## Lint & Format

- **Lint**: `luacheck modules/ FlexLove.lua` (config: `.luacheckrc`)
- **Format**: `stylua modules/ FlexLove.lua` (config: `stylua.toml` — 120 cols, 2-space indent, double quotes)
- **LSP**: Config in `.luarc.json` (LuaJIT runtime, love2d library)

## Code Style

- **Modules**: `local ModuleName = {}`, return table; constructors `ClassName.new(props)` → instance (never nil)
- **Methods**: instance with colon (`:methodName`), static with dot (`.methodName`)
- **Private fields**: prefix `_`
- **LuaDoc**: `---@param`, `---@return`, `---@class`, `---@field` for all public APIs
- **Errors**: `ErrorHandler.error(module, msg)` for critical, `ErrorHandler.warn(module, msg)` for warnings
- **Strings**: `string.format()` over concatenation
- **Auto-sizing**: Omit `width`/`height` (NOT `"auto"`) — see `usage.md` for the consumer-facing rule

## Architecture

- **Immediate mode**: Elements recreated each frame; `endFrame()` → `layoutChildren()` on top-level elements
- **Retained mode** (default): Elements persist; update properties manually
- **Dependencies**: Passed via `deps` table in constructors (`{utils, ErrorHandler, Units}`). Only `FlexLove.lua` uses `require()`.
- **Layout flow**: `Element.new()` → `layoutChildren()` on construction → `resize()` on viewport change → `layoutChildren()` again
- **Optional modules**: Loaded via `ModuleLoader.safeRequire()`; modules can be excluded for build profiles (minimal/slim/default/full). See `BUILD_PROFILES.md`.
- **Module dependency graph**: See `MODULE_DEPENDENCIES.md` before reordering or removing modules.
- **Release**: `scripts/make-tag.sh` → push tag → CI builds 4 profile packages + docs (see `../RELEASE.md`, `VERSIONING.md`, `WORKFLOW.md`)
