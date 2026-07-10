-- testing/__tests__/setproperty_dispatch_test.lua
--
-- Task 05 (registry-driven setProperty dispatch) parity tests.
--
-- Locks in that Element:setProperty — now driven by PropertySchema flags and a
-- small explicit handler map — preserves baseline behavior for:
--   * dimension props with unit strings (resolve to pixels + invalidate layout)
--   * layout props (invalidate layout)
--   * non-layout props (do NOT invalidate layout)
--   * transitions (fire when configured; "all" + specific both honored)
--   * theme sync (disabled/active reach setThemeState even when unchanged)
--   * the two genuinely-special props (parent -> setParent, themeComponent sync)

package.path = package.path .. ";./?.lua;./modules/?.lua"
local originalSearchers = package.searchers or package.loaders
table.insert(originalSearchers, 2, function(modname)
  if modname:match("^FlexLove%.modules%.") then
    local moduleName = modname:gsub("^FlexLove%.modules%.", "")
    return function()
      return require("modules." .. moduleName)
    end
  end
end)

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local FlexLove = require("FlexLove")

FlexLove.init()

local function makeElement(props)
  props = props or {}
  props.width = props.width or 100
  props.height = props.height or 100
  return FlexLove.new(props)
end

-- Set self._dirty back to a known state so the test only observes the effect of
-- the single setProperty call under test.
local function clearDirty(el)
  el._dirty = false
  el._childrenDirty = false
end

-- ============================================================================
-- Test Suite: Dimension unit resolution + layout invalidation
-- ============================================================================

TestSetPropertyDimensionDispatch = {}

function TestSetPropertyDimensionDispatch:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestSetPropertyDimensionDispatch:tearDown()
  FlexLove.endFrame()
end

function TestSetPropertyDimensionDispatch:test_dimension_unit_string_resolves_to_pixels()
  local el = makeElement({ id = "dim_resolve", width = 100, height = 50 })

  el:setProperty("width", "50%")

  luaunit.assertEquals(type(el.width), "number")
  luaunit.assertNotEquals(el.width, "50%")
  luaunit.assertNotNil(el.units.width)
  luaunit.assertEquals(el.units.width.unit, "%")
end

function TestSetPropertyDimensionDispatch:test_dimension_unit_string_invalidates_layout()
  local el = makeElement({ id = "dim_invalidate", width = 100, height = 50 })
  clearDirty(el)

  luaunit.assertFalse(el._dirty)
  el:setProperty("width", "50%")
  luaunit.assertTrue(el._dirty, "dimension setProperty must invalidate layout")
end

function TestSetPropertyDimensionDispatch:test_dimension_unit_unchanged_short_circuits()
  -- Re-setting the same unit spec must return early without re-resolving.
  local el = makeElement({ id = "dim_same", width = "50%", height = 50 })
  clearDirty(el)

  el:setProperty("width", "50%")

  luaunit.assertFalse(el._dirty, "identical unit value must short-circuit")
end

function TestSetPropertyDimensionDispatch:test_dimension_with_transition_animates_pixel_value()
  local el = makeElement({ id = "dim_transition", width = 100, height = 50 })
  el:setTransition("width", { duration = 0.4 })

  el:setProperty("width", "80%")

  -- Transition path animates the resolved pixel value, not the raw string.
  luaunit.assertNotNil(el.animation)
  luaunit.assertEquals(el.animation.duration, 0.4)
  luaunit.assertEquals(type(el.animation.final.width), "number")
  luaunit.assertNotEquals(el.animation.final.width, "80%")
end

-- ============================================================================
-- Test Suite: Layout-flag dispatch (affectsLayout)
-- ============================================================================

TestSetPropertyLayoutFlag = {}

function TestSetPropertyLayoutFlag:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestSetPropertyLayoutFlag:tearDown()
  FlexLove.endFrame()
end

function TestSetPropertyLayoutFlag:test_layout_prop_invalidates()
  local el = makeElement({ id = "layout_invalidate", padding = 4, gap = 2 })
  clearDirty(el)

  el:setProperty("padding", 8)
  luaunit.assertTrue(el._dirty, "padding (affectsLayout) must invalidate layout")
end

function TestSetPropertyLayoutFlag:test_gap_prop_invalidates()
  local el = makeElement({ id = "gap_invalidate", gap = 2 })
  clearDirty(el)

  el:setProperty("gap", 4)
  luaunit.assertTrue(el._dirty, "gap (affectsLayout) must invalidate layout")
end

function TestSetPropertyLayoutFlag:test_non_layout_prop_does_not_invalidate()
  local el = makeElement({ id = "nolayout", opacity = 1, visibility = "visible" })
  clearDirty(el)

  el:setProperty("opacity", 0.5)
  luaunit.assertFalse(el._dirty, "opacity must NOT invalidate layout")
end

function TestSetPropertyLayoutFlag:test_visibility_does_not_invalidate()
  local el = makeElement({ id = "vis", visibility = "visible" })
  clearDirty(el)

  el:setProperty("visibility", "hidden")
  luaunit.assertFalse(el._dirty, "visibility must NOT invalidate layout")
end

function TestSetPropertyLayoutFlag:test_unchanged_value_skips_layout_invalidation()
  -- gap is stored as-is (no normalization) so a repeat value compares equal and
  -- the write/layout path is correctly skipped.
  local el = makeElement({ id = "unchanged_layout", gap = 8 })
  clearDirty(el)

  el:setProperty("gap", 8) -- same value
  luaunit.assertFalse(el._dirty, "unchanged value must not re-invalidate layout")
end

-- ============================================================================
-- Test Suite: Transition dispatch (generic path)
-- ============================================================================

TestSetPropertyTransitionDispatch = {}

function TestSetPropertyTransitionDispatch:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestSetPropertyTransitionDispatch:tearDown()
  FlexLove.endFrame()
end

function TestSetPropertyTransitionDispatch:test_specific_transition_fires()
  local el = makeElement({ id = "trans_specific" })
  el.opacity = 1
  el:setTransition("opacity", { duration = 0.5 })

  el:setProperty("opacity", 0)

  luaunit.assertNotNil(el.animation)
  luaunit.assertEquals(el.animation.duration, 0.5)
  luaunit.assertEquals(el.animation.start.opacity, 1)
  luaunit.assertEquals(el.animation.final.opacity, 0)
end

function TestSetPropertyTransitionDispatch:test_all_transition_fires_for_unlisted_prop()
  local el = makeElement({ id = "trans_all" })
  el.opacity = 1
  el:setTransition("all", { duration = 0.3 })

  el:setProperty("opacity", 0)

  luaunit.assertNotNil(el.animation)
  luaunit.assertEquals(el.animation.duration, 0.3)
end

function TestSetPropertyTransitionDispatch:test_specific_overrides_all()
  local el = makeElement({ id = "trans_override" })
  el.opacity = 1
  el:setTransition("all", { duration = 0.3 })
  el:setTransition("opacity", { duration = 0.8 })

  el:setProperty("opacity", 0)

  luaunit.assertNotNil(el.animation)
  luaunit.assertEquals(el.animation.duration, 0.8)
end

function TestSetPropertyTransitionDispatch:test_same_value_does_not_animate()
  local el = makeElement({ id = "trans_same" })
  el.opacity = 1
  el:setTransition("opacity", { duration = 0.5 })

  el:setProperty("opacity", 1)

  luaunit.assertNil(el.animation)
end

function TestSetPropertyTransitionDispatch:test_no_transition_sets_directly()
  local el = makeElement({ id = "trans_direct" })
  el.opacity = 1

  el:setProperty("opacity", 0.4)

  luaunit.assertEquals(el.opacity, 0.4)
  luaunit.assertNil(el.animation)
end

-- ============================================================================
-- Test Suite: Theme sync dispatch (syncsTheme)
-- ============================================================================

TestSetPropertyThemeSyncDispatch = {}

function TestSetPropertyThemeSyncDispatch:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestSetPropertyThemeSyncDispatch:tearDown()
  FlexLove.endFrame()
end

function TestSetPropertyThemeSyncDispatch:test_disabled_setProperty_syncs_theme_state()
  local el = makeElement({ id = "sync_disabled", disabled = false })
  local calls = {}
  local orig = el._renderer.setThemeState
  el._renderer.setThemeState = function(_, state)
    table.insert(calls, state)
  end

  el:setProperty("disabled", true)

  luaunit.assertEquals(el.disabled, true)
  luaunit.assertEquals(#calls, 1)
  luaunit.assertEquals(calls[1], "disabled")
  el._renderer.setThemeState = orig
end

function TestSetPropertyThemeSyncDispatch:test_active_setProperty_syncs_theme_state()
  local el = makeElement({ id = "sync_active", active = false })
  local calls = {}
  local orig = el._renderer.setThemeState
  el._renderer.setThemeState = function(_, state)
    table.insert(calls, state)
  end

  el:setProperty("active", true)

  luaunit.assertEquals(el.active, true)
  luaunit.assertEquals(#calls, 1)
  luaunit.assertEquals(calls[1], "active")
  el._renderer.setThemeState = orig
end

function TestSetPropertyThemeSyncDispatch:test_unchanged_disabled_still_syncs()
  -- disabled must reach setThemeState even when the value is unchanged.
  local el = makeElement({ id = "sync_unchanged", disabled = true })
  local calls = {}
  local orig = el._renderer.setThemeState
  el._renderer.setThemeState = function(_, state)
    table.insert(calls, state)
  end

  el:setProperty("disabled", true) -- same value

  luaunit.assertEquals(#calls, 1)
  luaunit.assertEquals(calls[1], "disabled")
  el._renderer.setThemeState = orig
end

function TestSetPropertyThemeSyncDispatch:test_non_theme_prop_does_not_call_sync()
  -- opacity has syncsTheme=false: the renderer's setThemeState must NOT be hit.
  local el = makeElement({ id = "sync_none", opacity = 1 })
  local calls = {}
  local orig = el._renderer.setThemeState
  el._renderer.setThemeState = function(_, state)
    table.insert(calls, state)
  end

  el:setProperty("opacity", 0.5)

  luaunit.assertEquals(#calls, 0, "non-theme prop must not trigger setThemeState")
  el._renderer.setThemeState = orig
end

-- ============================================================================
-- Test Suite: Explicit special-handler dispatch
-- ============================================================================

TestSetPropertySpecialHandlers = {}

function TestSetPropertySpecialHandlers:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestSetPropertySpecialHandlers:tearDown()
  FlexLove.endFrame()
end

function TestSetPropertySpecialHandlers:test_themeComponent_syncs_theme_manager()
  local el = makeElement({ id = "theme_comp" })
  -- Ensure a themeManager is attached so we can observe the propagate.
  luaunit.assertNotNil(el._themeManager)
  el:setProperty("themeComponent", "primaryButton")

  luaunit.assertEquals(el.themeComponent, "primaryButton")
  luaunit.assertEquals(el._themeManager.themeComponent, "primaryButton")
end

function TestSetPropertySpecialHandlers:test_parent_routes_through_setParent()
  local parent = makeElement({ id = "sp_parent_target" })
  local child = makeElement({ id = "sp_child" })

  child:setProperty("parent", parent)

  luaunit.assertEquals(child.parent, parent)
  -- children is an array; verify membership by identity.
  local found = false
  for _, c in ipairs(parent.children) do
    if c == child then
      found = true
      break
    end
  end
  luaunit.assertTrue(found, "parent reparenting must route through setParent (hierarchy mgmt)")
end

-- Run tests
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
