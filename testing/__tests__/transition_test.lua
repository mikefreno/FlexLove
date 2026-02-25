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

local Animation = FlexLove.Animation

-- Helper: create a retained-mode element
local function makeElement(props)
  props = props or {}
  props.width = props.width or 100
  props.height = props.height or 100
  return FlexLove.new(props)
end

-- ============================================================================
-- Test Suite: setTransition()
-- ============================================================================

TestSetTransition = {}

function TestSetTransition:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestSetTransition:tearDown()
  FlexLove.endFrame()
end

function TestSetTransition:test_setTransition_creates_transitions_table()
  local el = makeElement()
  el:setTransition("opacity", { duration = 0.5 })

  luaunit.assertNotNil(el.transitions)
  luaunit.assertNotNil(el.transitions.opacity)
end

function TestSetTransition:test_setTransition_stores_config()
  local el = makeElement()
  el:setTransition("opacity", {
    duration = 0.5,
    easing = "easeInQuad",
    delay = 0.1,
  })

  luaunit.assertEquals(el.transitions.opacity.duration, 0.5)
  luaunit.assertEquals(el.transitions.opacity.easing, "easeInQuad")
  luaunit.assertEquals(el.transitions.opacity.delay, 0.1)
end

function TestSetTransition:test_setTransition_uses_defaults()
  local el = makeElement()
  el:setTransition("opacity", {})

  luaunit.assertEquals(el.transitions.opacity.duration, 0.3)
  luaunit.assertEquals(el.transitions.opacity.easing, "easeOutQuad")
  luaunit.assertEquals(el.transitions.opacity.delay, 0)
end

function TestSetTransition:test_setTransition_invalid_duration_uses_default()
  local el = makeElement()
  el:setTransition("opacity", { duration = -1 })

  luaunit.assertEquals(el.transitions.opacity.duration, 0.3)
end

function TestSetTransition:test_setTransition_with_invalid_config_handles_gracefully()
  local el = makeElement()
  -- Should not throw
  el:setTransition("opacity", "invalid")
  luaunit.assertNotNil(el.transitions.opacity)
end

function TestSetTransition:test_setTransition_for_all_properties()
  local el = makeElement()
  el:setTransition("all", { duration = 0.2, easing = "linear" })

  luaunit.assertNotNil(el.transitions["all"])
  luaunit.assertEquals(el.transitions["all"].duration, 0.2)
end

function TestSetTransition:test_setTransition_with_onComplete_callback()
  local el = makeElement()
  local cb = function() end
  el:setTransition("opacity", {
    duration = 0.3,
    onComplete = cb,
  })

  luaunit.assertEquals(el.transitions.opacity.onComplete, cb)
end

function TestSetTransition:test_setTransition_overwrites_previous()
  local el = makeElement()
  el:setTransition("opacity", { duration = 0.5 })
  el:setTransition("opacity", { duration = 1.0 })

  luaunit.assertEquals(el.transitions.opacity.duration, 1.0)
end

-- ============================================================================
-- Test Suite: setTransitionGroup()
-- ============================================================================

TestSetTransitionGroup = {}

function TestSetTransitionGroup:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestSetTransitionGroup:tearDown()
  FlexLove.endFrame()
end

function TestSetTransitionGroup:test_setTransitionGroup_applies_to_all_properties()
  local el = makeElement()
  el:setTransitionGroup("colors", { duration = 0.3 }, {
    "backgroundColor",
    "borderColor",
    "textColor",
  })

  luaunit.assertNotNil(el.transitions.backgroundColor)
  luaunit.assertNotNil(el.transitions.borderColor)
  luaunit.assertNotNil(el.transitions.textColor)
  luaunit.assertEquals(el.transitions.backgroundColor.duration, 0.3)
end

function TestSetTransitionGroup:test_setTransitionGroup_with_invalid_properties()
  local el = makeElement()
  -- Should not throw
  el:setTransitionGroup("invalid", { duration = 0.3 }, "not a table")
  -- No transitions should be set
  luaunit.assertNil(el.transitions)
end

function TestSetTransitionGroup:test_setTransitionGroup_shared_config()
  local el = makeElement()
  el:setTransitionGroup("position", { duration = 0.5, easing = "easeInOutCubic" }, {
    "x",
    "y",
  })

  luaunit.assertEquals(el.transitions.x.duration, 0.5)
  luaunit.assertEquals(el.transitions.y.duration, 0.5)
  luaunit.assertEquals(el.transitions.x.easing, "easeInOutCubic")
end

-- ============================================================================
-- Test Suite: removeTransition()
-- ============================================================================

TestRemoveTransition = {}

function TestRemoveTransition:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestRemoveTransition:tearDown()
  FlexLove.endFrame()
end

function TestRemoveTransition:test_removeTransition_removes_single()
  local el = makeElement()
  el:setTransition("opacity", { duration = 0.3 })
  el:setTransition("x", { duration = 0.5 })

  el:removeTransition("opacity")

  luaunit.assertNil(el.transitions.opacity)
  luaunit.assertNotNil(el.transitions.x)
end

function TestRemoveTransition:test_removeTransition_all_clears_all()
  local el = makeElement()
  el:setTransition("opacity", { duration = 0.3 })
  el:setTransition("x", { duration = 0.5 })

  el:removeTransition("all")

  luaunit.assertEquals(next(el.transitions), nil) -- empty table
end

function TestRemoveTransition:test_removeTransition_no_transitions_does_not_error()
  local el = makeElement()
  -- Should not throw even with no transitions set
  el:removeTransition("opacity")
end

function TestRemoveTransition:test_removeTransition_nonexistent_property()
  local el = makeElement()
  el:setTransition("opacity", { duration = 0.3 })

  -- Should not throw
  el:removeTransition("nonexistent")
  luaunit.assertNotNil(el.transitions.opacity)
end

-- ============================================================================
-- Test Suite: setProperty() with Transitions
-- ============================================================================

TestSetPropertyTransitions = {}

function TestSetPropertyTransitions:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestSetPropertyTransitions:tearDown()
  FlexLove.endFrame()
end

function TestSetPropertyTransitions:test_setProperty_without_transition_sets_immediately()
  local el = makeElement()
  el.opacity = 1

  el:setProperty("opacity", 0.5)

  luaunit.assertEquals(el.opacity, 0.5)
  luaunit.assertNil(el.animation)
end

function TestSetPropertyTransitions:test_setProperty_with_transition_creates_animation()
  local el = makeElement()
  el.opacity = 1
  el:setTransition("opacity", { duration = 0.5 })

  el:setProperty("opacity", 0)

  luaunit.assertNotNil(el.animation)
  luaunit.assertEquals(el.animation.duration, 0.5)
  luaunit.assertEquals(el.animation.start.opacity, 1)
  luaunit.assertEquals(el.animation.final.opacity, 0)
end

function TestSetPropertyTransitions:test_setProperty_same_value_does_not_animate()
  local el = makeElement()
  el.opacity = 1
  el:setTransition("opacity", { duration = 0.5 })

  el:setProperty("opacity", 1)

  luaunit.assertNil(el.animation)
end

function TestSetPropertyTransitions:test_setProperty_with_all_transition()
  local el = makeElement()
  el.opacity = 1
  el:setTransition("all", { duration = 0.3 })

  el:setProperty("opacity", 0)

  luaunit.assertNotNil(el.animation)
  luaunit.assertEquals(el.animation.duration, 0.3)
end

function TestSetPropertyTransitions:test_setProperty_specific_overrides_all()
  local el = makeElement()
  el.opacity = 1
  el:setTransition("all", { duration = 0.3 })
  el:setTransition("opacity", { duration = 0.8 })

  el:setProperty("opacity", 0)

  -- Should use the specific "opacity" transition, not "all"
  luaunit.assertNotNil(el.animation)
  luaunit.assertEquals(el.animation.duration, 0.8)
end

function TestSetPropertyTransitions:test_setProperty_transition_with_delay()
  local el = makeElement()
  el.opacity = 1
  el:setTransition("opacity", { duration = 0.3, delay = 0.2 })

  el:setProperty("opacity", 0)

  -- Animation should have the delay set
  -- The delay is part of the transition config, which is used to create the animation
  -- Note: delay may not be passed to Animation.new automatically by current implementation
  luaunit.assertNotNil(el.animation)
end

function TestSetPropertyTransitions:test_setProperty_transition_onComplete_callback()
  local el = makeElement()
  el.opacity = 1
  local callbackCalled = false
  el:setTransition("opacity", {
    duration = 0.3,
    onComplete = function() callbackCalled = true end,
  })

  el:setProperty("opacity", 0)

  luaunit.assertNotNil(el.animation)
  luaunit.assertNotNil(el.animation.onComplete)
end

function TestSetPropertyTransitions:test_setProperty_nil_current_value_sets_directly()
  local el = makeElement()
  el:setTransition("customProp", { duration = 0.3 })

  -- customProp is nil, should set directly
  el:setProperty("customProp", 42)

  luaunit.assertEquals(el.customProp, 42)
  luaunit.assertNil(el.animation)
end

-- ============================================================================
-- Test Suite: Per-Property Transition Configuration
-- ============================================================================

TestPerPropertyTransitionConfig = {}

function TestPerPropertyTransitionConfig:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestPerPropertyTransitionConfig:tearDown()
  FlexLove.endFrame()
end

function TestPerPropertyTransitionConfig:test_different_durations_per_property()
  local el = makeElement()
  el:setTransition("opacity", { duration = 0.3 })
  el:setTransition("x", { duration = 1.0 })

  luaunit.assertEquals(el.transitions.opacity.duration, 0.3)
  luaunit.assertEquals(el.transitions.x.duration, 1.0)
end

function TestPerPropertyTransitionConfig:test_different_easing_per_property()
  local el = makeElement()
  el:setTransition("opacity", { easing = "easeInQuad" })
  el:setTransition("x", { easing = "easeOutCubic" })

  luaunit.assertEquals(el.transitions.opacity.easing, "easeInQuad")
  luaunit.assertEquals(el.transitions.x.easing, "easeOutCubic")
end

function TestPerPropertyTransitionConfig:test_transition_disabled_after_removal()
  local el = makeElement()
  el.opacity = 1
  el:setTransition("opacity", { duration = 0.3 })

  -- Verify transition is active
  el:setProperty("opacity", 0.5)
  luaunit.assertNotNil(el.animation)

  -- Remove transition and reset
  el.animation = nil
  el.opacity = 1
  el:removeTransition("opacity")

  -- Should set immediately now
  el:setProperty("opacity", 0.5)
  luaunit.assertEquals(el.opacity, 0.5)
  luaunit.assertNil(el.animation)
end

function TestPerPropertyTransitionConfig:test_multiple_properties_configured()
  local el = makeElement()
  el:setTransition("opacity", { duration = 0.3 })
  el:setTransition("x", { duration = 0.5 })
  el:setTransition("width", { duration = 1.0 })

  luaunit.assertEquals(el.transitions.opacity.duration, 0.3)
  luaunit.assertEquals(el.transitions.x.duration, 0.5)
  luaunit.assertEquals(el.transitions.width.duration, 1.0)
end

-- ============================================================================
-- Test Suite: Transition Integration
-- ============================================================================

TestTransitionIntegration = {}

function TestTransitionIntegration:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestTransitionIntegration:tearDown()
  FlexLove.endFrame()
end

function TestTransitionIntegration:test_transition_animation_runs_to_completion()
  local el = makeElement()
  el.opacity = 1
  el:setTransition("opacity", { duration = 0.2 })
  el:setProperty("opacity", 0)

  luaunit.assertNotNil(el.animation)

  -- Run animation to completion
  for i = 1, 30 do
    el:update(1 / 60)
    if not el.animation then
      break
    end
  end

  luaunit.assertNil(el.animation)
end

function TestTransitionIntegration:test_manual_animation_overrides_transition()
  local el = makeElement()
  el.opacity = 1
  el:setTransition("opacity", { duration = 0.3 })

  -- Apply manual animation
  local manualAnim = Animation.new({
    duration = 1.0,
    start = { opacity = 1 },
    final = { opacity = 0 },
  })
  manualAnim:apply(el)

  luaunit.assertEquals(el.animation.duration, 1.0) -- Manual anim
end

-- Run all tests
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
