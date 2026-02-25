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

TestElementTouch = {}

function TestElementTouch:setUp()
  FlexLove.setMode("immediate")
  love.window.setMode(800, 600)
end

function TestElementTouch:tearDown()
  FlexLove.destroy()
end

-- ============================================
-- Touch Property Tests
-- ============================================

function TestElementTouch:test_touchEnabled_defaults_true()
  FlexLove.beginFrame()
  local element = FlexLove.new({ width = 100, height = 100 })
  FlexLove.endFrame()

  luaunit.assertTrue(element.touchEnabled)
end

function TestElementTouch:test_touchEnabled_can_be_set_false()
  FlexLove.beginFrame()
  local element = FlexLove.new({ width = 100, height = 100, touchEnabled = false })
  FlexLove.endFrame()

  luaunit.assertFalse(element.touchEnabled)
end

function TestElementTouch:test_multiTouchEnabled_defaults_false()
  FlexLove.beginFrame()
  local element = FlexLove.new({ width = 100, height = 100 })
  FlexLove.endFrame()

  luaunit.assertFalse(element.multiTouchEnabled)
end

function TestElementTouch:test_multiTouchEnabled_can_be_set_true()
  FlexLove.beginFrame()
  local element = FlexLove.new({ width = 100, height = 100, multiTouchEnabled = true })
  FlexLove.endFrame()

  luaunit.assertTrue(element.multiTouchEnabled)
end

-- ============================================
-- Touch Callback Tests
-- ============================================

function TestElementTouch:test_onTouchEvent_callback()
  FlexLove.beginFrame()
  local receivedEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function(el, event)
      table.insert(receivedEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("t1", 100, 100, 0, 0, 1.0)

  luaunit.assertTrue(#receivedEvents >= 1)
  luaunit.assertEquals(receivedEvents[1].type, "touchpress")
end

function TestElementTouch:test_onGesture_callback()
  FlexLove.beginFrame()
  local receivedGestures = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function() end,
    onGesture = function(el, gesture)
      table.insert(receivedGestures, gesture)
    end,
  })
  FlexLove.endFrame()

  -- Quick tap
  FlexLove.touchpressed("t1", 100, 100, 0, 0, 1.0)
  love.timer.step(0.05)
  FlexLove.touchreleased("t1", 100, 100, 0, 0, 1.0)

  local tapGestures = {}
  for _, g in ipairs(receivedGestures) do
    if g.type == "tap" then
      table.insert(tapGestures, g)
    end
  end
  luaunit.assertTrue(#tapGestures >= 1, "Should receive tap gesture callback")
end

function TestElementTouch:test_onEvent_also_receives_touch()
  FlexLove.beginFrame()
  local receivedEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onEvent = function(el, event)
      table.insert(receivedEvents, event)
    end,
  })
  FlexLove.endFrame()

  FlexLove.touchpressed("t1", 100, 100, 0, 0, 1.0)

  local touchEvents = {}
  for _, e in ipairs(receivedEvents) do
    if e.type == "touchpress" then
      table.insert(touchEvents, e)
    end
  end
  luaunit.assertTrue(#touchEvents >= 1, "onEvent should receive touch events")
end

-- ============================================
-- handleTouchEvent direct tests
-- ============================================

function TestElementTouch:test_handleTouchEvent_disabled_element()
  FlexLove.beginFrame()
  local receivedEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    disabled = true,
    onTouchEvent = function(el, event)
      table.insert(receivedEvents, event)
    end,
  })
  FlexLove.endFrame()

  local InputEvent = package.loaded["modules.InputEvent"]
  local touchEvent = InputEvent.fromTouch("t1", 100, 100, "began", 1.0)
  element:handleTouchEvent(touchEvent)

  luaunit.assertEquals(#receivedEvents, 0, "Disabled element should not receive touch events")
end

function TestElementTouch:test_handleTouchEvent_touchEnabled_false()
  FlexLove.beginFrame()
  local receivedEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    touchEnabled = false,
    onTouchEvent = function(el, event)
      table.insert(receivedEvents, event)
    end,
  })
  FlexLove.endFrame()

  local InputEvent = package.loaded["modules.InputEvent"]
  local touchEvent = InputEvent.fromTouch("t1", 100, 100, "began", 1.0)
  element:handleTouchEvent(touchEvent)

  luaunit.assertEquals(#receivedEvents, 0, "touchEnabled=false should prevent events")
end

-- ============================================
-- handleGesture direct tests
-- ============================================

function TestElementTouch:test_handleGesture_fires_callback()
  FlexLove.beginFrame()
  local receivedGestures = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onGesture = function(el, gesture)
      table.insert(receivedGestures, gesture)
    end,
  })
  FlexLove.endFrame()

  element:handleGesture({ type = "tap", state = "ended", x = 100, y = 100 })

  luaunit.assertEquals(#receivedGestures, 1)
  luaunit.assertEquals(receivedGestures[1].type, "tap")
end

function TestElementTouch:test_handleGesture_disabled_element()
  FlexLove.beginFrame()
  local receivedGestures = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    disabled = true,
    onGesture = function(el, gesture)
      table.insert(receivedGestures, gesture)
    end,
  })
  FlexLove.endFrame()

  element:handleGesture({ type = "tap", state = "ended", x = 100, y = 100 })

  luaunit.assertEquals(#receivedGestures, 0, "Disabled element should not receive gestures")
end

function TestElementTouch:test_handleGesture_touchEnabled_false()
  FlexLove.beginFrame()
  local receivedGestures = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    touchEnabled = false,
    onGesture = function(el, gesture)
      table.insert(receivedGestures, gesture)
    end,
  })
  FlexLove.endFrame()

  element:handleGesture({ type = "tap", state = "ended", x = 100, y = 100 })

  luaunit.assertEquals(#receivedGestures, 0, "touchEnabled=false should prevent gestures")
end

-- ============================================
-- getTouches tests
-- ============================================

function TestElementTouch:test_getTouches_returns_table()
  FlexLove.beginFrame()
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEvent = function() end,
  })
  FlexLove.endFrame()

  local touches = element:getTouches()
  luaunit.assertEquals(type(touches), "table")
end

-- ============================================
-- Touch + Gesture combined lifecycle
-- ============================================

function TestElementTouch:test_touch_pan_lifecycle()
  FlexLove.beginFrame()
  local touchEvents = {}
  local gestureEvents = {}
  local element = FlexLove.new({
    width = 400,
    height = 400,
    onTouchEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
    onGesture = function(el, gesture)
      table.insert(gestureEvents, gesture)
    end,
  })
  FlexLove.endFrame()

  -- Simulate a pan gesture: press, move significantly, release
  FlexLove.touchpressed("t1", 100, 100, 0, 0, 1.0)
  love.timer.step(0.05)
  FlexLove.touchmoved("t1", 150, 150, 50, 50, 1.0)
  love.timer.step(0.05)
  FlexLove.touchmoved("t1", 200, 200, 50, 50, 1.0)
  love.timer.step(0.05)
  FlexLove.touchreleased("t1", 200, 200, 0, 0, 1.0)

  -- Should have received touch events
  luaunit.assertTrue(#touchEvents >= 3, "Should receive press + move + release touch events")

  -- Should have received pan gestures from GestureRecognizer
  local panGestures = {}
  for _, g in ipairs(gestureEvents) do
    if g.type == "pan" then
      table.insert(panGestures, g)
    end
  end
  luaunit.assertTrue(#panGestures >= 1, "Should receive pan gesture events")
end

-- ============================================
-- Deferred callbacks
-- ============================================

function TestElementTouch:test_onTouchEventDeferred_prop_accepted()
  FlexLove.beginFrame()
  -- Just test that the prop is accepted without error
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onTouchEventDeferred = function() end,
  })
  FlexLove.endFrame()

  luaunit.assertNotNil(element, "Element with onTouchEventDeferred should be created")
end

function TestElementTouch:test_onGestureDeferred_prop_accepted()
  FlexLove.beginFrame()
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onGestureDeferred = function() end,
  })
  FlexLove.endFrame()

  luaunit.assertNotNil(element, "Element with onGestureDeferred should be created")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
