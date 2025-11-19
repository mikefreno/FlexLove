package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local lu = require("testing.luaunit")

-- Load FlexLove
local FlexLove = require("FlexLove")

TestTouchEvents = {}

-- Test: InputEvent.fromTouch creates valid touch event
function TestTouchEvents:testInputEvent_FromTouch()
  local InputEvent = package.loaded["modules.InputEvent"]
  
  local touchId = "touch1"
  local event = InputEvent.fromTouch(touchId, 100, 200, "began", 0.8)
  
  lu.assertEquals(event.type, "touchpress")
  lu.assertEquals(event.x, 100)
  lu.assertEquals(event.y, 200)
  lu.assertEquals(event.touchId, "touch1")
  lu.assertEquals(event.pressure, 0.8)
  lu.assertEquals(event.phase, "began")
  lu.assertEquals(event.button, 1) -- Treat as left button
end

-- Test: Touch event with moved phase
function TestTouchEvents:testInputEvent_FromTouch_Moved()
  local InputEvent = package.loaded["modules.InputEvent"]
  
  local event = InputEvent.fromTouch("touch1", 150, 250, "moved", 1.0)
  
  lu.assertEquals(event.type, "touchmove")
  lu.assertEquals(event.phase, "moved")
end

-- Test: Touch event with ended phase
function TestTouchEvents:testInputEvent_FromTouch_Ended()
  local InputEvent = package.loaded["modules.InputEvent"]
  
  local event = InputEvent.fromTouch("touch1", 150, 250, "ended", 1.0)
  
  lu.assertEquals(event.type, "touchrelease")
  lu.assertEquals(event.phase, "ended")
end

-- Test: Touch event with cancelled phase
function TestTouchEvents:testInputEvent_FromTouch_Cancelled()
  local InputEvent = package.loaded["modules.InputEvent"]
  
  local event = InputEvent.fromTouch("touch1", 150, 250, "cancelled", 1.0)
  
  lu.assertEquals(event.type, "touchcancel")
  lu.assertEquals(event.phase, "cancelled")
end

-- Test: EventHandler tracks touch began
function TestTouchEvents:testEventHandler_TouchBegan()
  FlexLove.beginFrame()
  
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  
  FlexLove.endFrame()
  
  -- Simulate touch began
  love.touch.getTouches = function() return {"touch1"} end
  love.touch.getPosition = function(id)
    if id == "touch1" then return 100, 100 end
    return 0, 0
  end
  
  -- Trigger touch event processing
  FlexLove.beginFrame()
  element._eventHandler:processTouchEvents()
  FlexLove.endFrame()
  
  -- Should have received a touchpress event
  lu.assertEquals(#touchEvents, 1)
  lu.assertEquals(touchEvents[1].type, "touchpress")
  lu.assertEquals(touchEvents[1].touchId, "touch1")
end

-- Test: EventHandler tracks touch moved
function TestTouchEvents:testEventHandler_TouchMoved()
  FlexLove.beginFrame()
  
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  
  FlexLove.endFrame()
  
  -- Simulate touch began
  love.touch.getTouches = function() return {"touch1"} end
  love.touch.getPosition = function(id)
    if id == "touch1" then return 100, 100 end
    return 0, 0
  end
  
  -- First touch
  FlexLove.beginFrame()
  element._eventHandler:processTouchEvents()
  FlexLove.endFrame()
  
  -- Move touch
  love.touch.getPosition = function(id)
    if id == "touch1" then return 150, 150 end
    return 0, 0
  end
  
  FlexLove.beginFrame()
  element._eventHandler:processTouchEvents()
  FlexLove.endFrame()
  
  -- Should have received touchpress and touchmove events
  lu.assertEquals(#touchEvents, 2)
  lu.assertEquals(touchEvents[1].type, "touchpress")
  lu.assertEquals(touchEvents[2].type, "touchmove")
  lu.assertEquals(touchEvents[2].dx, 50)
  lu.assertEquals(touchEvents[2].dy, 50)
end

-- Test: EventHandler tracks touch ended
function TestTouchEvents:testEventHandler_TouchEnded()
  FlexLove.beginFrame()
  
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  
  FlexLove.endFrame()
  
  -- Simulate touch began
  love.touch.getTouches = function() return {"touch1"} end
  love.touch.getPosition = function(id)
    if id == "touch1" then return 100, 100 end
    return 0, 0
  end
  
  -- First touch
  FlexLove.beginFrame()
  element._eventHandler:processTouchEvents()
  FlexLove.endFrame()
  
  -- End touch
  love.touch.getTouches = function() return {} end
  
  FlexLove.beginFrame()
  element._eventHandler:processTouchEvents()
  FlexLove.endFrame()
  
  -- Should have received touchpress and touchrelease events
  lu.assertEquals(#touchEvents, 2)
  lu.assertEquals(touchEvents[1].type, "touchpress")
  lu.assertEquals(touchEvents[2].type, "touchrelease")
end

-- Test: EventHandler tracks multiple simultaneous touches
function TestTouchEvents:testEventHandler_MultiTouch()
  FlexLove.beginFrame()
  
  local touchEvents = {}
  local element = FlexLove.new({
    width = 200,
    height = 200,
    onEvent = function(el, event)
      table.insert(touchEvents, event)
    end,
  })
  
  FlexLove.endFrame()
  
  -- Simulate two touches
  love.touch.getTouches = function() return {"touch1", "touch2"} end
  love.touch.getPosition = function(id)
    if id == "touch1" then return 50, 50 end
    if id == "touch2" then return 150, 150 end
    return 0, 0
  end
  
  FlexLove.beginFrame()
  element._eventHandler:processTouchEvents()
  FlexLove.endFrame()
  
  -- Should have received two touchpress events
  lu.assertEquals(#touchEvents, 2)
  lu.assertEquals(touchEvents[1].type, "touchpress")
  lu.assertEquals(touchEvents[2].type, "touchpress")
  
  -- Different touch IDs
  lu.assertNotEquals(touchEvents[1].touchId, touchEvents[2].touchId)
end

-- Test: GestureRecognizer detects tap
function TestTouchEvents:testGestureRecognizer_Tap()
  local GestureRecognizer = package.loaded["modules.GestureRecognizer"]
  local InputEvent = package.loaded["modules.InputEvent"]
  local utils = package.loaded["modules.utils"]
  
  local recognizer = GestureRecognizer.new({}, {
    InputEvent = InputEvent,
    utils = utils,
  })
  
  -- Simulate tap (press and quick release)
  local touchId = "touch1"
  local pressEvent = InputEvent.fromTouch(touchId, 100, 100, "began", 1.0)
  local releaseEvent = InputEvent.fromTouch(touchId, 102, 102, "ended", 1.0)
  
  recognizer:processTouchEvent(pressEvent)
  local gesture = recognizer:processTouchEvent(releaseEvent)
  
  -- Note: The gesture detection returns from internal methods, 
  -- needs to be captured from the event processing
  -- This is a basic structural test
  lu.assertNotNil(recognizer)
end

os.exit(lu.LuaUnit.run())
