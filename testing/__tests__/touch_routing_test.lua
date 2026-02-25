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

TestTouchRouting = {}

function TestTouchRouting:setUp()
  FlexLove.setMode("immediate")
  love.window.setMode(800, 600)
end

function TestTouchRouting:tearDown()
  FlexLove.destroy()
  love.touch.getTouches = function() return {} end
  love.touch.getPosition = function() return 0, 0 end
end

-- Test: touchpressed routes to element at position
function TestTouchRouting:test_touchpressed_routes_to_element()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  luaunit.assertTrue(#touchEvents >= 1, "Should receive touchpress event")
  luaunit.assertEquals(touchEvents[1].type, "touchpress")
  luaunit.assertEquals(touchEvents[1].touchId, "touch1")
  luaunit.assertEquals(touchEvents[1].x, 100)
  luaunit.assertEquals(touchEvents[1].y, 100)
end

-- Test: touchmoved routes to owning element
function TestTouchRouting:test_touchmoved_routes_to_owner()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  FlexLove.touchmoved("touch1", 150, 150, 50, 50, 1.0)

  -- Filter for move events
  local moveEvents = {}
  for _, e in ipairs(touchEvents) do
    if e.type == "touchmove" then
      table.insert(moveEvents, e)
    end
  end

  luaunit.assertTrue(#moveEvents >= 1, "Should receive touchmove event")
  luaunit.assertEquals(moveEvents[1].x, 150)
  luaunit.assertEquals(moveEvents[1].y, 150)
end

-- Test: touchreleased routes to owning element and cleans up
function TestTouchRouting:test_touchreleased_routes_and_cleans_up()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertNotNil(FlexLove.getTouchOwner("touch1"), "Touch should be owned")

  FlexLove.touchreleased("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertNil(FlexLove.getTouchOwner("touch1"), "Touch ownership should be cleaned up")

  -- Filter for release events
  local releaseEvents = {}
  for _, e in ipairs(touchEvents) do
    if e.type == "touchrelease" then
      table.insert(releaseEvents, e)
    end
  end

  luaunit.assertTrue(#releaseEvents >= 1, "Should receive touchrelease event")
end

-- Test: Touch ownership persists — move events route even outside element bounds
function TestTouchRouting:test_touch_ownership_persists_outside_bounds()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  -- Press inside element
  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  -- Move far outside element bounds
  FlexLove.touchmoved("touch1", 500, 500, 400, 400, 1.0)

  -- Should still receive the move event due to ownership
  local moveEvents = {}
  for _, e in ipairs(touchEvents) do
    if e.type == "touchmove" then
      table.insert(moveEvents, e)
    end
  end

  luaunit.assertTrue(#moveEvents >= 1, "Move event should route to owner even outside bounds")
  luaunit.assertEquals(moveEvents[1].x, 500)
  luaunit.assertEquals(moveEvents[1].y, 500)
end

-- Test: Touch outside all elements creates no ownership
function TestTouchRouting:test_touch_outside_elements_no_ownership()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 100,
    height = 100,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  -- Press outside element bounds
  FlexLove.touchpressed("touch1", 500, 500, 0, 0, 1.0)

  luaunit.assertNil(FlexLove.getTouchOwner("touch1"), "No element should own touch outside bounds")
  luaunit.assertEquals(#touchEvents, 0, "No events should fire for touch outside bounds")
end

-- Test: Multiple touches route to different elements
function TestTouchRouting:test_multi_touch_different_elements()
  FlexLove.beginFrame()
  local events1 = {}
  local events2 = {}
  -- Two elements side by side (default row layout)
  local container = FlexLove.new({
    width = 400,
    height = 200,
  })
  local element1 = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(events1, event)
    end,
    parent = container,
  })
  local element2 = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(events2, event)
    end,
    parent = container,
  })
  FlexLove.endFrame()

  -- Touch element1 (at x=0..200, y=0..200)
  FlexLove.touchpressed("touch1", 50, 100, 0, 0, 1.0)
  -- Touch element2 (at x=200..400, y=0..200)
  FlexLove.touchpressed("touch2", 300, 100, 0, 0, 1.0)

  luaunit.assertTrue(#events1 >= 1, "Element1 should receive touch event")
  luaunit.assertTrue(#events2 >= 1, "Element2 should receive touch event")
  luaunit.assertEquals(events1[1].touchId, "touch1")
  luaunit.assertEquals(events2[1].touchId, "touch2")
end

-- Test: Z-index ordering — higher z element receives touch
function TestTouchRouting:test_z_index_ordering()
  FlexLove.beginFrame()
  local eventsLow = {}
  local eventsHigh = {}
  -- Lower z element
  local low = FlexLove.new({
    width = 200,
    height = 200,
    z = 1,
    onTouchEvent = function(el, event)
      table.insert(eventsLow, event)
    end,
  })
  -- Higher z element overlapping
  local high = FlexLove.new({
    width = 200,
    height = 200,
    z = 10,
    onTouchEvent = function(el, event)
      table.insert(eventsHigh, event)
    end,
  })
  FlexLove.endFrame()

  -- Touch overlapping area
  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  luaunit.assertTrue(#eventsHigh >= 1, "Higher z element should receive touch")
  luaunit.assertEquals(#eventsLow, 0, "Lower z element should NOT receive touch")
end

-- Test: Disabled element does not receive touch
function TestTouchRouting:test_disabled_element_no_touch()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    disabled = true,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  luaunit.assertEquals(#touchEvents, 0, "Disabled element should not receive touch events")
  luaunit.assertNil(FlexLove.getTouchOwner("touch1"))
end

-- Test: getActiveTouchCount tracks active touches
function TestTouchRouting:test_getActiveTouchCount()
  FlexLove.beginFrame()
  local element = FlexLove.new({
    width = 800,
    height = 600,
    onTouchEvent = function() end,
  })
  FlexLove.endFrame()

  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 0)

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 1)

  FlexLove.touchpressed("touch2", 200, 200, 0, 0, 1.0)
  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 2)

  FlexLove.touchreleased("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 1)

  FlexLove.touchreleased("touch2", 200, 200, 0, 0, 1.0)
  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 0)
end

-- Test: getTouchOwner returns correct element
function TestTouchRouting:test_getTouchOwner()
  FlexLove.beginFrame()
  local element = FlexLove.new({
    id = "owner-test",
    width = 200,
    height = 200,
    onTouchEvent = function() end,
  })
  FlexLove.endFrame()

  luaunit.assertNil(FlexLove.getTouchOwner("touch1"))

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  local owner = FlexLove.getTouchOwner("touch1")
  luaunit.assertNotNil(owner)
  luaunit.assertEquals(owner.id, "owner-test")
end

-- Test: destroy() cleans up touch state
function TestTouchRouting:test_destroy_cleans_touch_state()
  FlexLove.beginFrame()
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function() end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 1)

  FlexLove.destroy()
  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 0)
end

-- Test: Touch routing with onEvent (not just onTouchEvent)
function TestTouchRouting:test_onEvent_receives_touch_events()
  FlexLove.beginFrame()
  local allEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onEvent = function(el, event)
      table.insert(allEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  -- onEvent should receive touch events via handleTouchEvent -> _invokeCallback
  local touchPressEvents = {}
  for _, e in ipairs(allEvents) do
    if e.type == "touchpress" then
      table.insert(touchPressEvents, e)
    end
  end

  luaunit.assertTrue(#touchPressEvents >= 1, "onEvent should receive touchpress events")
end

-- Test: Touch routing with onGesture callback
function TestTouchRouting:test_gesture_routing()
  FlexLove.beginFrame()
  local gestureEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function() end,
    onGesture = function(el, gesture)
      table.insert(gestureEvents, gesture)
    end,
  })
  FlexLove.endFrame()

  -- Simulate a quick tap (press and release at same position within threshold)
  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  -- Small time step to avoid zero dt
  love.timer.step(0.05)
  FlexLove.touchreleased("touch1", 100, 100, 0, 0, 1.0)

  -- GestureRecognizer should detect a tap gesture
  local tapGestures = {}
  for _, g in ipairs(gestureEvents) do
    if g.type == "tap" then
      table.insert(tapGestures, g)
    end
  end

  luaunit.assertTrue(#tapGestures >= 1, "Should detect tap gesture from press+release")
end

-- Test: touchpressed with no onTouchEvent but onGesture — should still find element
function TestTouchRouting:test_element_with_only_onGesture()
  FlexLove.beginFrame()
  local gestureEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onGesture = function(el, gesture)
      table.insert(gestureEvents, gesture)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertNotNil(FlexLove.getTouchOwner("touch1"), "Element with onGesture should be found")
end

-- Test: touchEnabled=false prevents touch routing
function TestTouchRouting:test_touchEnabled_false_prevents_routing()
  FlexLove.beginFrame()
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    touchEnabled = false,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  luaunit.assertNil(FlexLove.getTouchOwner("touch1"), "touchEnabled=false should prevent ownership")
  luaunit.assertEquals(#touchEvents, 0, "touchEnabled=false should prevent events")
end

-- Test: Complete touch lifecycle (press, move, release)
function TestTouchRouting:test_full_lifecycle()
  FlexLove.beginFrame()
  local phases = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(phases, event.type)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  FlexLove.touchmoved("touch1", 110, 110, 10, 10, 1.0)
  FlexLove.touchmoved("touch1", 120, 120, 10, 10, 1.0)
  FlexLove.touchreleased("touch1", 120, 120, 0, 0, 1.0)

  luaunit.assertEquals(phases[1], "touchpress")
  luaunit.assertEquals(phases[2], "touchmove")
  luaunit.assertEquals(phases[3], "touchmove")
  luaunit.assertEquals(phases[4], "touchrelease")
  luaunit.assertEquals(#phases, 4)
end

-- Test: Orphaned move/release with no owner (no crash)
function TestTouchRouting:test_orphaned_move_release_no_crash()
  -- Move and release events with no prior press should not crash
  FlexLove.touchmoved("ghost_touch", 100, 100, 0, 0, 1.0)
  FlexLove.touchreleased("ghost_touch", 100, 100, 0, 0, 1.0)

  luaunit.assertEquals(FlexLove.getActiveTouchCount(), 0)
end

-- Test: Pressure value is passed through
function TestTouchRouting:test_pressure_passthrough()
  FlexLove.beginFrame()
  local receivedPressure = nil
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      if event.type == "touchpress" then
        receivedPressure = event.pressure
      end
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 0.75)
  luaunit.assertAlmostEquals(receivedPressure, 0.75, 0.01)
end

-- Test: Retained mode touch routing
function TestTouchRouting:test_retained_mode_routing()
  FlexLove.setMode("retained")

  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  luaunit.assertTrue(#touchEvents >= 1, "Touch routing should work in retained mode")
  luaunit.assertEquals(touchEvents[1].type, "touchpress")
end

-- Test: Child element receives touch over parent
function TestTouchRouting:test_child_receives_touch_over_parent()
  FlexLove.beginFrame()
  local parentEvents = {}
  local childEvents = {}
  local parent = FlexLove.new({
    width = 400,
    height = 400,
    onTouchEvent = function(el, event)
      table.insert(parentEvents, event)
    end,
  })
  local child = FlexLove.new({
    width = 200,
    height = 200,
    z = 1, -- Ensure child has higher z than parent
    onTouchEvent = function(el, event)
      table.insert(childEvents, event)
    end,
    parent = parent,
  })
  FlexLove.endFrame()

  -- Touch within child area (which is also within parent)
  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)

  -- Child has explicit higher z, should receive touch
  luaunit.assertTrue(#childEvents >= 1,
    string.format("Child should receive touch (child=%d, parent=%d, topElements=%d)",
      #childEvents, #parentEvents, #FlexLove.topElements))
end

-- Test: Element with no callbacks not found by touch routing
function TestTouchRouting:test_non_interactive_element_ignored()
  FlexLove.beginFrame()
  -- Element with no onEvent, onTouchEvent, or onGesture
  local element = FlexLove.new({
    width = 200,
    height = 200,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("touch1", 100, 100, 0, 0, 1.0)
  luaunit.assertNil(FlexLove.getTouchOwner("touch1"), "Non-interactive element should not capture touch")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
