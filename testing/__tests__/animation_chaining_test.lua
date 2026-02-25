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

-- Helper: create a simple animation
local function makeAnim(duration, startX, finalX)
  return Animation.new({
    duration = duration or 1,
    start = { x = startX or 0 },
    final = { x = finalX or 100 },
  })
end

-- Helper: create a retained-mode test element
local function makeElement(props)
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
  local el = FlexLove.new(props or { width = 100, height = 100 })
  FlexLove.endFrame()
  return el
end

-- ============================================================================
-- Test Suite: Animation Instance Chaining
-- ============================================================================

TestAnimationChaining = {}

function TestAnimationChaining:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationChaining:tearDown()
  FlexLove.endFrame()
end

function TestAnimationChaining:test_chain_links_two_animations()
  local anim1 = makeAnim(0.5, 0, 50)
  local anim2 = makeAnim(0.5, 50, 100)

  local returned = anim1:chain(anim2)

  luaunit.assertEquals(anim1._next, anim2)
  luaunit.assertEquals(returned, anim2)
end

function TestAnimationChaining:test_chain_with_factory_function()
  local factory = function(element)
    return makeAnim(0.5, 0, 100)
  end
  local anim1 = makeAnim(0.5)

  local returned = anim1:chain(factory)

  luaunit.assertEquals(anim1._nextFactory, factory)
  luaunit.assertEquals(returned, anim1) -- returns self when factory
end

function TestAnimationChaining:test_chained_animations_execute_in_order()
  local el = makeElement({ width = 100, height = 100, opacity = 1 })

  local order = {}
  local anim1 = Animation.new({
    duration = 0.2,
    start = { x = 0 },
    final = { x = 50 },
    onComplete = function() table.insert(order, 1) end,
  })
  local anim2 = Animation.new({
    duration = 0.2,
    start = { x = 50 },
    final = { x = 100 },
    onComplete = function() table.insert(order, 2) end,
  })

  anim1:chain(anim2)
  anim1:apply(el)

  -- Run anim1 to completion
  for i = 1, 20 do
    el:update(1 / 60)
  end

  -- anim1 should be done, anim2 should now be the active animation
  luaunit.assertEquals(order[1], 1)
  luaunit.assertEquals(el.animation, anim2)

  -- Run anim2 to completion
  for i = 1, 20 do
    el:update(1 / 60)
  end

  luaunit.assertEquals(order[2], 2)
  luaunit.assertNil(el.animation)
end

function TestAnimationChaining:test_chain_with_factory_creates_dynamic_animation()
  local el = makeElement({ width = 100, height = 100 })
  el.x = 0

  local anim1 = Animation.new({
    duration = 0.1,
    start = { x = 0 },
    final = { x = 50 },
  })

  local factoryCalled = false
  anim1:chain(function(element)
    factoryCalled = true
    return Animation.new({
      duration = 1.0,
      start = { x = 50 },
      final = { x = 200 },
    })
  end)

  anim1:apply(el)

  -- Run anim1 to completion (0.1s duration, ~7 frames at 1/60)
  for i = 1, 10 do
    el:update(1 / 60)
  end

  luaunit.assertTrue(factoryCalled)
  luaunit.assertNotNil(el.animation) -- Should have the factory-created animation (1s duration)
end

-- ============================================================================
-- Test Suite: Animation delay()
-- ============================================================================

TestAnimationDelay = {}

function TestAnimationDelay:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationDelay:tearDown()
  FlexLove.endFrame()
end

function TestAnimationDelay:test_delay_delays_animation_start()
  local anim = makeAnim(0.5)
  anim:delay(0.3)

  -- During delay period, animation should not progress
  local finished = anim:update(0.2)
  luaunit.assertFalse(finished)
  luaunit.assertEquals(anim.elapsed, 0)

  -- Still in delay (0.2 + 0.15 = 0.35 total delay elapsed, but the second
  -- call starts with _delayElapsed=0.2 < 0.3, so it adds 0.15 and returns false)
  finished = anim:update(0.15)
  luaunit.assertFalse(finished)
  luaunit.assertEquals(anim.elapsed, 0)

  -- Now delay is past (0.35 >= 0.3), animation should start progressing
  anim:update(0.1)
  luaunit.assertTrue(anim.elapsed > 0)
end

function TestAnimationDelay:test_delay_returns_self()
  local anim = makeAnim(1)
  local returned = anim:delay(0.5)
  luaunit.assertEquals(returned, anim)
end

function TestAnimationDelay:test_delay_with_invalid_value_defaults_to_zero()
  local anim = makeAnim(0.5)
  anim:delay(-1)
  luaunit.assertEquals(anim._delay, 0)

  local anim2 = makeAnim(0.5)
  anim2:delay("bad")
  luaunit.assertEquals(anim2._delay, 0)
end

-- ============================================================================
-- Test Suite: Animation repeatCount()
-- ============================================================================

TestAnimationRepeat = {}

function TestAnimationRepeat:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationRepeat:tearDown()
  FlexLove.endFrame()
end

function TestAnimationRepeat:test_repeat_n_times()
  local anim = Animation.new({
    duration = 0.2,
    start = { x = 0 },
    final = { x = 100 },
  })
  anim:repeatCount(3)

  local completions = 0
  -- Run through multiple cycles
  for i = 1, 300 do
    local finished = anim:update(1 / 60)
    if anim.elapsed == 0 or finished then
      completions = completions + 1
    end
    if finished then
      break
    end
  end

  luaunit.assertEquals(anim:getState(), "completed")
end

function TestAnimationRepeat:test_repeat_returns_self()
  local anim = makeAnim(1)
  local returned = anim:repeatCount(3)
  luaunit.assertEquals(returned, anim)
end

-- ============================================================================
-- Test Suite: Animation yoyo()
-- ============================================================================

TestAnimationYoyo = {}

function TestAnimationYoyo:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationYoyo:tearDown()
  FlexLove.endFrame()
end

function TestAnimationYoyo:test_yoyo_reverses_on_repeat()
  local anim = Animation.new({
    duration = 0.2,
    start = { x = 0 },
    final = { x = 100 },
  })
  anim:repeatCount(2):yoyo(true)

  -- First cycle
  for i = 1, 15 do
    anim:update(1 / 60)
  end

  -- After first cycle completes, it should be reversed
  luaunit.assertTrue(anim._reversed)
end

function TestAnimationYoyo:test_yoyo_returns_self()
  local anim = makeAnim(1)
  local returned = anim:yoyo(true)
  luaunit.assertEquals(returned, anim)
end

function TestAnimationYoyo:test_yoyo_default_true()
  local anim = makeAnim(1)
  anim:yoyo()
  luaunit.assertTrue(anim._yoyo)
end

function TestAnimationYoyo:test_yoyo_false_disables()
  local anim = makeAnim(1)
  anim:yoyo(false)
  luaunit.assertFalse(anim._yoyo)
end

-- ============================================================================
-- Test Suite: Animation.chainSequence() static helper
-- ============================================================================

TestAnimationChainSequence = {}

function TestAnimationChainSequence:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationChainSequence:tearDown()
  FlexLove.endFrame()
end

function TestAnimationChainSequence:test_chainSequence_links_all_animations()
  local a1 = makeAnim(0.2, 0, 50)
  local a2 = makeAnim(0.2, 50, 100)
  local a3 = makeAnim(0.2, 100, 150)

  local first = Animation.chainSequence({ a1, a2, a3 })

  luaunit.assertEquals(first, a1)
  luaunit.assertEquals(a1._next, a2)
  luaunit.assertEquals(a2._next, a3)
end

function TestAnimationChainSequence:test_chainSequence_single_animation()
  local a1 = makeAnim(0.2)
  local first = Animation.chainSequence({ a1 })

  luaunit.assertEquals(first, a1)
  luaunit.assertNil(a1._next)
end

function TestAnimationChainSequence:test_chainSequence_empty_array()
  local first = Animation.chainSequence({})
  luaunit.assertNotNil(first) -- should return a fallback animation
end

-- ============================================================================
-- Test Suite: Element Fluent API
-- ============================================================================

TestElementFluentAPI = {}

function TestElementFluentAPI:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestElementFluentAPI:tearDown()
  FlexLove.endFrame()
end

function TestElementFluentAPI:test_animateTo_creates_animation()
  local el = FlexLove.new({ width = 100, height = 100 })
  el.opacity = 0.5

  local returned = el:animateTo({ opacity = 1 }, 0.5, "easeOutQuad")

  luaunit.assertEquals(returned, el) -- returns self
  luaunit.assertNotNil(el.animation)
  luaunit.assertEquals(el.animation.duration, 0.5)
  luaunit.assertEquals(el.animation.start.opacity, 0.5)
  luaunit.assertEquals(el.animation.final.opacity, 1)
end

function TestElementFluentAPI:test_animateTo_with_defaults()
  local el = FlexLove.new({ width = 100, height = 100 })
  el.x = 10

  el:animateTo({ x = 200 })

  luaunit.assertNotNil(el.animation)
  luaunit.assertEquals(el.animation.duration, 0.3) -- default
end

function TestElementFluentAPI:test_fadeIn_sets_opacity_target_to_1()
  local el = FlexLove.new({ width = 100, height = 100 })
  el.opacity = 0

  local returned = el:fadeIn(0.5)

  luaunit.assertEquals(returned, el)
  luaunit.assertNotNil(el.animation)
  luaunit.assertEquals(el.animation.start.opacity, 0)
  luaunit.assertEquals(el.animation.final.opacity, 1)
end

function TestElementFluentAPI:test_fadeIn_default_duration()
  local el = FlexLove.new({ width = 100, height = 100 })
  el.opacity = 0

  el:fadeIn()

  luaunit.assertEquals(el.animation.duration, 0.3)
end

function TestElementFluentAPI:test_fadeOut_sets_opacity_target_to_0()
  local el = FlexLove.new({ width = 100, height = 100 })
  el.opacity = 1

  local returned = el:fadeOut(0.5)

  luaunit.assertEquals(returned, el)
  luaunit.assertNotNil(el.animation)
  luaunit.assertEquals(el.animation.start.opacity, 1)
  luaunit.assertEquals(el.animation.final.opacity, 0)
end

function TestElementFluentAPI:test_fadeOut_default_duration()
  local el = FlexLove.new({ width = 100, height = 100 })
  el:fadeOut()

  luaunit.assertEquals(el.animation.duration, 0.3)
end

function TestElementFluentAPI:test_scaleTo_creates_scale_animation()
  local el = FlexLove.new({ width = 100, height = 100 })

  local returned = el:scaleTo(2.0, 0.5)

  luaunit.assertEquals(returned, el)
  luaunit.assertNotNil(el.animation)
  luaunit.assertEquals(el.animation.final.scaleX, 2.0)
  luaunit.assertEquals(el.animation.final.scaleY, 2.0)
end

function TestElementFluentAPI:test_scaleTo_default_duration()
  local el = FlexLove.new({ width = 100, height = 100 })
  el:scaleTo(1.5)

  luaunit.assertEquals(el.animation.duration, 0.3)
end

function TestElementFluentAPI:test_scaleTo_initializes_transform()
  local el = FlexLove.new({ width = 100, height = 100 })
  -- Should not have a transform yet (or it has one from constructor)

  el:scaleTo(2.0)

  luaunit.assertNotNil(el.transform)
end

function TestElementFluentAPI:test_moveTo_creates_position_animation()
  local el = FlexLove.new({ width = 100, height = 100 })
  el.x = 0
  el.y = 0

  local returned = el:moveTo(200, 300, 0.5, "easeInOutCubic")

  luaunit.assertEquals(returned, el)
  luaunit.assertNotNil(el.animation)
  luaunit.assertEquals(el.animation.start.x, 0)
  luaunit.assertEquals(el.animation.start.y, 0)
  luaunit.assertEquals(el.animation.final.x, 200)
  luaunit.assertEquals(el.animation.final.y, 300)
end

function TestElementFluentAPI:test_moveTo_default_duration()
  local el = FlexLove.new({ width = 100, height = 100 })
  el:moveTo(100, 100)

  luaunit.assertEquals(el.animation.duration, 0.3)
end

function TestElementFluentAPI:test_animateTo_with_invalid_props_returns_self()
  local el = FlexLove.new({ width = 100, height = 100 })

  local returned = el:animateTo("invalid")

  luaunit.assertEquals(returned, el)
  luaunit.assertNil(el.animation)
end

-- ============================================================================
-- Test Suite: Integration - Chaining with Fluent API
-- ============================================================================

TestAnimationChainingIntegration = {}

function TestAnimationChainingIntegration:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationChainingIntegration:tearDown()
  FlexLove.endFrame()
end

function TestAnimationChainingIntegration:test_chained_delay_and_repeat()
  local anim = Animation.new({
    duration = 0.2,
    start = { x = 0 },
    final = { x = 100 },
  })
  local chained = anim:delay(0.1):repeatCount(2):yoyo(true)

  luaunit.assertEquals(chained, anim)
  luaunit.assertEquals(anim._delay, 0.1)
  luaunit.assertEquals(anim._repeatCount, 2)
  luaunit.assertTrue(anim._yoyo)
end

function TestAnimationChainingIntegration:test_complex_chain_executes_fully()
  local el = makeElement({ width = 100, height = 100, opacity = 1 })

  local a1 = Animation.new({
    duration = 0.1,
    start = { opacity = 1 },
    final = { opacity = 0 },
  })
  local a2 = Animation.new({
    duration = 0.1,
    start = { opacity = 0 },
    final = { opacity = 1 },
  })
  local a3 = Animation.new({
    duration = 0.1,
    start = { opacity = 1 },
    final = { opacity = 0.5 },
  })

  Animation.chainSequence({ a1, a2, a3 })
  a1:apply(el)

  -- Run all three animations
  for i = 1, 100 do
    el:update(1 / 60)
    if not el.animation then
      break
    end
  end

  -- All should have completed, no animation left
  luaunit.assertNil(el.animation)
end

-- Run all tests
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
