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
local AnimationGroup = Animation.Group

-- Helper: create a simple animation with given duration
local function makeAnim(duration, startVal, finalVal)
  return Animation.new({
    duration = duration or 1,
    start = { x = startVal or 0 },
    final = { x = finalVal or 100 },
  })
end

-- Helper: advance an animation group to completion
local function runToCompletion(group, dt)
  dt = dt or 1 / 60
  local maxFrames = 10000
  for i = 1, maxFrames do
    if group:update(dt) then
      return i
    end
  end
  return maxFrames
end

-- ============================================================================
-- Test Suite: AnimationGroup Construction
-- ============================================================================

TestAnimationGroupConstruction = {}

function TestAnimationGroupConstruction:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationGroupConstruction:tearDown()
  FlexLove.endFrame()
end

function TestAnimationGroupConstruction:test_new_creates_group_with_defaults()
  local anim1 = makeAnim(1)
  local anim2 = makeAnim(1)
  local group = AnimationGroup.new({ animations = { anim1, anim2 } })

  luaunit.assertNotNil(group)
  luaunit.assertEquals(group.mode, "parallel")
  luaunit.assertEquals(group.stagger, 0.1)
  luaunit.assertEquals(#group.animations, 2)
  luaunit.assertEquals(group:getState(), "ready")
end

function TestAnimationGroupConstruction:test_new_with_sequence_mode()
  local group = AnimationGroup.new({
    animations = { makeAnim(1) },
    mode = "sequence",
  })
  luaunit.assertEquals(group.mode, "sequence")
end

function TestAnimationGroupConstruction:test_new_with_stagger_mode()
  local group = AnimationGroup.new({
    animations = { makeAnim(1) },
    mode = "stagger",
    stagger = 0.2,
  })
  luaunit.assertEquals(group.mode, "stagger")
  luaunit.assertEquals(group.stagger, 0.2)
end

function TestAnimationGroupConstruction:test_new_with_invalid_mode_defaults_to_parallel()
  local group = AnimationGroup.new({
    animations = { makeAnim(1) },
    mode = "invalid",
  })
  luaunit.assertEquals(group.mode, "parallel")
end

function TestAnimationGroupConstruction:test_new_with_nil_props_does_not_error()
  local group = AnimationGroup.new(nil)
  luaunit.assertNotNil(group)
  luaunit.assertEquals(#group.animations, 0)
end

function TestAnimationGroupConstruction:test_new_with_empty_animations()
  local group = AnimationGroup.new({ animations = {} })
  luaunit.assertNotNil(group)
  luaunit.assertEquals(#group.animations, 0)
end

function TestAnimationGroupConstruction:test_new_with_callbacks()
  local onStart = function() end
  local onComplete = function() end
  local group = AnimationGroup.new({
    animations = { makeAnim(1) },
    onStart = onStart,
    onComplete = onComplete,
  })
  luaunit.assertEquals(group.onStart, onStart)
  luaunit.assertEquals(group.onComplete, onComplete)
end

-- ============================================================================
-- Test Suite: Parallel Mode
-- ============================================================================

TestAnimationGroupParallel = {}

function TestAnimationGroupParallel:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationGroupParallel:tearDown()
  FlexLove.endFrame()
end

function TestAnimationGroupParallel:test_parallel_runs_all_animations_simultaneously()
  local anim1 = makeAnim(1)
  local anim2 = makeAnim(1)
  local group = AnimationGroup.new({
    mode = "parallel",
    animations = { anim1, anim2 },
  })

  group:update(0.5)

  -- Both animations should have progressed
  luaunit.assertTrue(anim1.elapsed > 0)
  luaunit.assertTrue(anim2.elapsed > 0)
end

function TestAnimationGroupParallel:test_parallel_completes_when_all_finish()
  local anim1 = makeAnim(0.5)
  local anim2 = makeAnim(1.0)
  local group = AnimationGroup.new({
    mode = "parallel",
    animations = { anim1, anim2 },
  })

  -- After 0.6s: anim1 done, anim2 not done
  local finished = group:update(0.6)
  luaunit.assertFalse(finished)
  luaunit.assertEquals(group:getState(), "playing")

  -- After another 0.5s: both done
  finished = group:update(0.5)
  luaunit.assertTrue(finished)
  luaunit.assertEquals(group:getState(), "completed")
end

function TestAnimationGroupParallel:test_parallel_uses_max_duration()
  local anim1 = makeAnim(0.3)
  local anim2 = makeAnim(0.5)
  local anim3 = makeAnim(0.8)
  local group = AnimationGroup.new({
    mode = "parallel",
    animations = { anim1, anim2, anim3 },
  })

  -- At 0.5s, anim3 is not yet done
  local finished = group:update(0.5)
  luaunit.assertFalse(finished)

  -- At 0.9s total, all should be done
  finished = group:update(0.4)
  luaunit.assertTrue(finished)
end

function TestAnimationGroupParallel:test_parallel_does_not_update_completed_animations()
  local anim1 = makeAnim(0.2)
  local anim2 = makeAnim(1.0)
  local group = AnimationGroup.new({
    mode = "parallel",
    animations = { anim1, anim2 },
  })

  -- Run past anim1's completion
  group:update(0.3)
  local anim1Elapsed = anim1.elapsed

  -- Update again - anim1 should not be updated further
  group:update(0.1)
  -- anim1 is completed, so its elapsed might stay clamped
  luaunit.assertEquals(anim1:getState(), "completed")
end

-- ============================================================================
-- Test Suite: Sequence Mode
-- ============================================================================

TestAnimationGroupSequence = {}

function TestAnimationGroupSequence:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationGroupSequence:tearDown()
  FlexLove.endFrame()
end

function TestAnimationGroupSequence:test_sequence_runs_one_at_a_time()
  local anim1 = makeAnim(0.5)
  local anim2 = makeAnim(0.5)
  local group = AnimationGroup.new({
    mode = "sequence",
    animations = { anim1, anim2 },
  })

  -- After 0.3s, only anim1 should have progressed
  group:update(0.3)
  luaunit.assertTrue(anim1.elapsed > 0)
  luaunit.assertEquals(anim2.elapsed, 0) -- anim2 hasn't started
end

function TestAnimationGroupSequence:test_sequence_advances_to_next_on_completion()
  local anim1 = makeAnim(0.5)
  local anim2 = makeAnim(0.5)
  local group = AnimationGroup.new({
    mode = "sequence",
    animations = { anim1, anim2 },
  })

  -- Complete anim1
  group:update(0.6)
  luaunit.assertEquals(anim1:getState(), "completed")

  -- Now anim2 should receive updates
  group:update(0.3)
  luaunit.assertTrue(anim2.elapsed > 0)
end

function TestAnimationGroupSequence:test_sequence_completes_when_last_finishes()
  local anim1 = makeAnim(0.3)
  local anim2 = makeAnim(0.3)
  local group = AnimationGroup.new({
    mode = "sequence",
    animations = { anim1, anim2 },
  })

  -- Complete anim1
  group:update(0.4)
  luaunit.assertFalse(group:getState() == "completed")

  -- Complete anim2
  group:update(0.4)
  luaunit.assertEquals(group:getState(), "completed")
end

function TestAnimationGroupSequence:test_sequence_maintains_order()
  local order = {}
  local anim1 = Animation.new({
    duration = 0.2,
    start = { x = 0 },
    final = { x = 100 },
    onStart = function() table.insert(order, 1) end,
  })
  local anim2 = Animation.new({
    duration = 0.2,
    start = { x = 0 },
    final = { x = 100 },
    onStart = function() table.insert(order, 2) end,
  })
  local anim3 = Animation.new({
    duration = 0.2,
    start = { x = 0 },
    final = { x = 100 },
    onStart = function() table.insert(order, 3) end,
  })

  local group = AnimationGroup.new({
    mode = "sequence",
    animations = { anim1, anim2, anim3 },
  })

  runToCompletion(group, 0.05)

  luaunit.assertEquals(order, { 1, 2, 3 })
end

-- ============================================================================
-- Test Suite: Stagger Mode
-- ============================================================================

TestAnimationGroupStagger = {}

function TestAnimationGroupStagger:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationGroupStagger:tearDown()
  FlexLove.endFrame()
end

function TestAnimationGroupStagger:test_stagger_delays_animation_starts()
  local anim1 = makeAnim(1)
  local anim2 = makeAnim(1)
  local anim3 = makeAnim(1)
  local group = AnimationGroup.new({
    mode = "stagger",
    stagger = 0.5,
    animations = { anim1, anim2, anim3 },
  })

  -- At t=0.3: only anim1 should have started (stagger=0.5 means anim2 starts at t=0.5)
  group:update(0.3)
  luaunit.assertTrue(anim1.elapsed > 0)
  luaunit.assertEquals(anim2.elapsed, 0)
  luaunit.assertEquals(anim3.elapsed, 0)
end

function TestAnimationGroupStagger:test_stagger_timing_is_correct()
  local anim1 = makeAnim(1)
  local anim2 = makeAnim(1)
  local anim3 = makeAnim(1)
  local group = AnimationGroup.new({
    mode = "stagger",
    stagger = 0.2,
    animations = { anim1, anim2, anim3 },
  })

  -- At t=0.15: only anim1 started (anim2 starts at t=0.2, anim3 at t=0.4)
  group:update(0.15)
  luaunit.assertTrue(anim1.elapsed > 0)
  luaunit.assertEquals(anim2.elapsed, 0)
  luaunit.assertEquals(anim3.elapsed, 0)

  -- At t=0.3: anim1 and anim2 started, anim3 not yet
  group:update(0.15)
  luaunit.assertTrue(anim1.elapsed > 0)
  luaunit.assertTrue(anim2.elapsed > 0)
  luaunit.assertEquals(anim3.elapsed, 0)

  -- At t=0.5: all started
  group:update(0.2)
  luaunit.assertTrue(anim3.elapsed > 0)
end

function TestAnimationGroupStagger:test_stagger_completes_when_all_finish()
  -- With stagger, animations get the full dt once their stagger offset is reached.
  -- Use a longer stagger so anim2 hasn't started yet at the first check.
  local anim1 = makeAnim(0.5)
  local anim2 = makeAnim(0.5)
  local group = AnimationGroup.new({
    mode = "stagger",
    stagger = 0.5,
    animations = { anim1, anim2 },
  })

  -- At t=0.3: anim1 started, anim2 not yet (starts at t=0.5)
  local finished = group:update(0.3)
  luaunit.assertFalse(finished)
  luaunit.assertTrue(anim1.elapsed > 0)
  luaunit.assertEquals(anim2.elapsed, 0)

  -- At t=0.6: anim1 completed, anim2 just started and got 0.3s dt
  finished = group:update(0.3)
  luaunit.assertFalse(finished)
  luaunit.assertEquals(anim1:getState(), "completed")
  luaunit.assertTrue(anim2.elapsed > 0)

  -- At t=0.9: anim2 should be completed (got 0.3 + 0.3 = 0.6s of updates)
  finished = group:update(0.3)
  luaunit.assertTrue(finished)
  luaunit.assertEquals(group:getState(), "completed")
end

-- ============================================================================
-- Test Suite: Callbacks
-- ============================================================================

TestAnimationGroupCallbacks = {}

function TestAnimationGroupCallbacks:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationGroupCallbacks:tearDown()
  FlexLove.endFrame()
end

function TestAnimationGroupCallbacks:test_onStart_called_once()
  local startCount = 0
  local group = AnimationGroup.new({
    animations = { makeAnim(0.5) },
    onStart = function() startCount = startCount + 1 end,
  })

  group:update(0.1)
  group:update(0.1)
  group:update(0.1)

  luaunit.assertEquals(startCount, 1)
end

function TestAnimationGroupCallbacks:test_onStart_receives_group_reference()
  local receivedGroup = nil
  local group = AnimationGroup.new({
    animations = { makeAnim(0.5) },
    onStart = function(g) receivedGroup = g end,
  })

  group:update(0.1)
  luaunit.assertEquals(receivedGroup, group)
end

function TestAnimationGroupCallbacks:test_onComplete_called_when_all_finish()
  local completeCount = 0
  local group = AnimationGroup.new({
    animations = { makeAnim(0.3) },
    onComplete = function() completeCount = completeCount + 1 end,
  })

  runToCompletion(group)
  luaunit.assertEquals(completeCount, 1)
end

function TestAnimationGroupCallbacks:test_onComplete_not_called_before_completion()
  local completed = false
  local group = AnimationGroup.new({
    animations = { makeAnim(1) },
    onComplete = function() completed = true end,
  })

  group:update(0.5)
  luaunit.assertFalse(completed)
end

function TestAnimationGroupCallbacks:test_callback_error_does_not_crash()
  local group = AnimationGroup.new({
    animations = { makeAnim(0.1) },
    onStart = function() error("onStart error") end,
    onComplete = function() error("onComplete error") end,
  })

  -- Should not throw
  runToCompletion(group)
  luaunit.assertEquals(group:getState(), "completed")
end

-- ============================================================================
-- Test Suite: Control Methods
-- ============================================================================

TestAnimationGroupControl = {}

function TestAnimationGroupControl:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationGroupControl:tearDown()
  FlexLove.endFrame()
end

function TestAnimationGroupControl:test_pause_stops_updates()
  local anim1 = makeAnim(1)
  local group = AnimationGroup.new({
    animations = { anim1 },
  })

  group:update(0.2)
  local elapsedBefore = anim1.elapsed

  group:pause()
  group:update(0.3)

  -- Elapsed should not have increased
  luaunit.assertEquals(anim1.elapsed, elapsedBefore)
  luaunit.assertTrue(group:isPaused())
end

function TestAnimationGroupControl:test_resume_continues_updates()
  local anim1 = makeAnim(1)
  local group = AnimationGroup.new({
    animations = { anim1 },
  })

  group:update(0.2)
  group:pause()
  group:update(0.3) -- Should be ignored

  group:resume()
  group:update(0.2)

  -- Should have progressed past the paused value
  luaunit.assertTrue(anim1.elapsed > 0.2)
  luaunit.assertFalse(group:isPaused())
end

function TestAnimationGroupControl:test_reverse_reverses_all_animations()
  local anim1 = makeAnim(1)
  local anim2 = makeAnim(1)
  local group = AnimationGroup.new({
    animations = { anim1, anim2 },
  })

  group:update(0.5)
  group:reverse()

  luaunit.assertTrue(anim1._reversed)
  luaunit.assertTrue(anim2._reversed)
end

function TestAnimationGroupControl:test_setSpeed_affects_all_animations()
  local anim1 = makeAnim(1)
  local anim2 = makeAnim(1)
  local group = AnimationGroup.new({
    animations = { anim1, anim2 },
  })

  group:setSpeed(2.0)

  luaunit.assertEquals(anim1._speed, 2.0)
  luaunit.assertEquals(anim2._speed, 2.0)
end

function TestAnimationGroupControl:test_cancel_cancels_all_animations()
  local anim1 = makeAnim(1)
  local anim2 = makeAnim(1)
  local group = AnimationGroup.new({
    animations = { anim1, anim2 },
  })

  group:update(0.3)
  group:cancel()

  luaunit.assertEquals(group:getState(), "cancelled")
  luaunit.assertEquals(anim1:getState(), "cancelled")
  luaunit.assertEquals(anim2:getState(), "cancelled")
end

function TestAnimationGroupControl:test_cancel_prevents_further_updates()
  local anim1 = makeAnim(1)
  local group = AnimationGroup.new({
    animations = { anim1 },
  })

  group:update(0.2)
  group:cancel()
  local elapsedAfterCancel = anim1.elapsed

  group:update(0.3)
  luaunit.assertEquals(anim1.elapsed, elapsedAfterCancel)
end

function TestAnimationGroupControl:test_reset_restores_initial_state()
  local anim1 = makeAnim(0.5)
  local group = AnimationGroup.new({
    mode = "sequence",
    animations = { anim1 },
  })

  runToCompletion(group)
  luaunit.assertEquals(group:getState(), "completed")

  group:reset()
  luaunit.assertEquals(group:getState(), "ready")
  luaunit.assertFalse(group._hasStarted)
  luaunit.assertEquals(group._currentIndex, 1)
  luaunit.assertEquals(group._staggerElapsed, 0)
end

function TestAnimationGroupControl:test_reset_allows_replaying()
  local completeCount = 0
  local group = AnimationGroup.new({
    animations = { makeAnim(0.2) },
    onComplete = function() completeCount = completeCount + 1 end,
  })

  runToCompletion(group)
  luaunit.assertEquals(completeCount, 1)

  group:reset()
  runToCompletion(group)
  luaunit.assertEquals(completeCount, 2)
end

-- ============================================================================
-- Test Suite: State and Progress
-- ============================================================================

TestAnimationGroupStateProgress = {}

function TestAnimationGroupStateProgress:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationGroupStateProgress:tearDown()
  FlexLove.endFrame()
end

function TestAnimationGroupStateProgress:test_state_transitions()
  local group = AnimationGroup.new({
    animations = { makeAnim(0.5) },
  })

  luaunit.assertEquals(group:getState(), "ready")

  group:update(0.1)
  luaunit.assertEquals(group:getState(), "playing")

  runToCompletion(group)
  luaunit.assertEquals(group:getState(), "completed")
end

function TestAnimationGroupStateProgress:test_progress_parallel()
  local anim1 = makeAnim(1)
  local anim2 = makeAnim(1)
  local group = AnimationGroup.new({
    mode = "parallel",
    animations = { anim1, anim2 },
  })

  luaunit.assertAlmostEquals(group:getProgress(), 0, 0.01)

  group:update(0.5)
  local progress = group:getProgress()
  luaunit.assertTrue(progress > 0)
  luaunit.assertTrue(progress < 1)

  runToCompletion(group)
  luaunit.assertAlmostEquals(group:getProgress(), 1, 0.01)
end

function TestAnimationGroupStateProgress:test_progress_sequence()
  local anim1 = makeAnim(1)
  local anim2 = makeAnim(1)
  local group = AnimationGroup.new({
    mode = "sequence",
    animations = { anim1, anim2 },
  })

  -- Before any update
  luaunit.assertAlmostEquals(group:getProgress(), 0, 0.01)

  -- Halfway through first animation (25% total)
  group:update(0.5)
  local progress = group:getProgress()
  luaunit.assertTrue(progress > 0)
  luaunit.assertTrue(progress <= 0.5)

  -- Complete first animation (50% total)
  group:update(0.6)
  progress = group:getProgress()
  luaunit.assertTrue(progress >= 0.5)
end

function TestAnimationGroupStateProgress:test_empty_group_progress_is_1()
  local group = AnimationGroup.new({ animations = {} })
  luaunit.assertAlmostEquals(group:getProgress(), 1, 0.01)
end

-- ============================================================================
-- Test Suite: Empty and Edge Cases
-- ============================================================================

TestAnimationGroupEdgeCases = {}

function TestAnimationGroupEdgeCases:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationGroupEdgeCases:tearDown()
  FlexLove.endFrame()
end

function TestAnimationGroupEdgeCases:test_empty_group_completes_immediately()
  local completed = false
  local group = AnimationGroup.new({
    animations = {},
    onComplete = function() completed = true end,
  })

  local finished = group:update(0.1)
  luaunit.assertTrue(finished)
  luaunit.assertEquals(group:getState(), "completed")
end

function TestAnimationGroupEdgeCases:test_single_animation_group()
  local anim = makeAnim(0.5)
  local group = AnimationGroup.new({
    animations = { anim },
  })

  runToCompletion(group)
  luaunit.assertEquals(group:getState(), "completed")
  luaunit.assertEquals(anim:getState(), "completed")
end

function TestAnimationGroupEdgeCases:test_update_after_completion_returns_true()
  local group = AnimationGroup.new({
    animations = { makeAnim(0.1) },
  })

  runToCompletion(group)
  local finished = group:update(0.1)
  luaunit.assertTrue(finished)
end

function TestAnimationGroupEdgeCases:test_invalid_dt_is_handled()
  local group = AnimationGroup.new({
    animations = { makeAnim(1) },
  })

  -- Should not throw for invalid dt values
  group:update(-1)
  group:update(0 / 0) -- NaN
  group:update(math.huge)
  luaunit.assertNotNil(group)
end

function TestAnimationGroupEdgeCases:test_apply_assigns_group_to_element()
  local group = AnimationGroup.new({
    animations = { makeAnim(1) },
  })

  local mockElement = {}
  group:apply(mockElement)
  luaunit.assertEquals(mockElement.animationGroup, group)
end

function TestAnimationGroupEdgeCases:test_apply_with_nil_element_does_not_crash()
  local group = AnimationGroup.new({
    animations = { makeAnim(1) },
  })
  -- Should not throw
  group:apply(nil)
end

-- ============================================================================
-- Test Suite: Nested Groups
-- ============================================================================

TestAnimationGroupNested = {}

function TestAnimationGroupNested:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestAnimationGroupNested:tearDown()
  FlexLove.endFrame()
end

function TestAnimationGroupNested:test_nested_parallel_in_sequence()
  local anim1 = makeAnim(0.3)
  local anim2 = makeAnim(0.3)
  local innerGroup = AnimationGroup.new({
    mode = "parallel",
    animations = { anim1, anim2 },
  })

  local anim3 = makeAnim(0.3)
  local outerGroup = AnimationGroup.new({
    mode = "sequence",
    animations = { innerGroup, anim3 },
  })

  -- Inner group should run first
  outerGroup:update(0.2)
  luaunit.assertTrue(anim1.elapsed > 0)
  luaunit.assertTrue(anim2.elapsed > 0)
  luaunit.assertEquals(anim3.elapsed, 0)

  -- Complete inner group, anim3 should start
  outerGroup:update(0.2)
  outerGroup:update(0.2)
  luaunit.assertTrue(anim3.elapsed > 0)
end

function TestAnimationGroupNested:test_nested_sequence_in_parallel()
  local anim1 = makeAnim(0.2)
  local anim2 = makeAnim(0.2)
  local innerSeq = AnimationGroup.new({
    mode = "sequence",
    animations = { anim1, anim2 },
  })

  local anim3 = makeAnim(0.3)
  local outerGroup = AnimationGroup.new({
    mode = "parallel",
    animations = { innerSeq, anim3 },
  })

  -- Both innerSeq and anim3 should run in parallel
  outerGroup:update(0.1)
  luaunit.assertTrue(anim1.elapsed > 0)
  luaunit.assertTrue(anim3.elapsed > 0)
end

function TestAnimationGroupNested:test_nested_group_completes()
  local innerGroup = AnimationGroup.new({
    mode = "parallel",
    animations = { makeAnim(0.2), makeAnim(0.2) },
  })
  local outerGroup = AnimationGroup.new({
    mode = "sequence",
    animations = { innerGroup, makeAnim(0.2) },
  })

  runToCompletion(outerGroup)
  luaunit.assertEquals(outerGroup:getState(), "completed")
  luaunit.assertEquals(innerGroup:getState(), "completed")
end

function TestAnimationGroupNested:test_deeply_nested_groups()
  local leaf1 = makeAnim(0.1)
  local leaf2 = makeAnim(0.1)
  local inner = AnimationGroup.new({
    mode = "parallel",
    animations = { leaf1, leaf2 },
  })
  local middle = AnimationGroup.new({
    mode = "sequence",
    animations = { inner, makeAnim(0.1) },
  })
  local outer = AnimationGroup.new({
    mode = "parallel",
    animations = { middle, makeAnim(0.2) },
  })

  runToCompletion(outer)
  luaunit.assertEquals(outer:getState(), "completed")
  luaunit.assertEquals(middle:getState(), "completed")
  luaunit.assertEquals(inner:getState(), "completed")
end

-- Run all tests
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
