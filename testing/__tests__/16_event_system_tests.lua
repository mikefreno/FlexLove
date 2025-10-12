-- Event System Tests
-- Tests for the enhanced callback system with InputEvent objects

package.path = package.path .. ";?.lua"

local lu = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

local Gui = FlexLove.GUI
local Color = FlexLove.Color

TestEventSystem = {}

function TestEventSystem:setUp()
  -- Initialize GUI before each test
  Gui.init({ baseScale = { width = 1920, height = 1080 } })
  love.window.setMode(1920, 1080)
end

function TestEventSystem:tearDown()
  -- Clean up after each test
  Gui.destroy()
end

-- Test 1: Event object structure
function TestEventSystem:test_event_object_has_required_fields()
  local eventReceived = nil
  
  local button = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    callback = function(element, event)
      eventReceived = event
    end,
  })
  
  -- Simulate mouse press and release
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  button:update(0.016)
  
  love.mouse.setDown(1, false)
  button:update(0.016)
  
  -- Verify event object structure
  lu.assertNotNil(eventReceived, "Event should be received")
  lu.assertNotNil(eventReceived.type, "Event should have type field")
  lu.assertNotNil(eventReceived.button, "Event should have button field")
  lu.assertNotNil(eventReceived.x, "Event should have x field")
  lu.assertNotNil(eventReceived.y, "Event should have y field")
  lu.assertNotNil(eventReceived.modifiers, "Event should have modifiers field")
  lu.assertNotNil(eventReceived.clickCount, "Event should have clickCount field")
  lu.assertNotNil(eventReceived.timestamp, "Event should have timestamp field")
end

-- Test 2: Left click event
function TestEventSystem:test_left_click_generates_click_event()
  local eventsReceived = {}
  
  local button = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    callback = function(element, event)
      table.insert(eventsReceived, {type = event.type, button = event.button})
    end,
  })
  
  -- Simulate left click
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  button:update(0.016)
  
  love.mouse.setDown(1, false)
  button:update(0.016)
  
  -- Should receive press, click, and release events
  lu.assertTrue(#eventsReceived >= 2, "Should receive at least 2 events")
  
  -- Check for click event
  local hasClickEvent = false
  for _, evt in ipairs(eventsReceived) do
    if evt.type == "click" and evt.button == 1 then
      hasClickEvent = true
      break
    end
  end
  lu.assertTrue(hasClickEvent, "Should receive click event for left button")
end

-- Test 3: Right click event
function TestEventSystem:test_right_click_generates_rightclick_event()
  local eventsReceived = {}
  
  local button = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    callback = function(element, event)
      table.insert(eventsReceived, {type = event.type, button = event.button})
    end,
  })
  
  -- Simulate right click
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(2, true)
  button:update(0.016)
  
  love.mouse.setDown(2, false)
  button:update(0.016)
  
  -- Check for rightclick event
  local hasRightClickEvent = false
  for _, evt in ipairs(eventsReceived) do
    if evt.type == "rightclick" and evt.button == 2 then
      hasRightClickEvent = true
      break
    end
  end
  lu.assertTrue(hasRightClickEvent, "Should receive rightclick event for right button")
end

-- Test 4: Middle click event
function TestEventSystem:test_middle_click_generates_middleclick_event()
  local eventsReceived = {}
  
  local button = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    callback = function(element, event)
      table.insert(eventsReceived, {type = event.type, button = event.button})
    end,
  })
  
  -- Simulate middle click
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(3, true)
  button:update(0.016)
  
  love.mouse.setDown(3, false)
  button:update(0.016)
  
  -- Check for middleclick event
  local hasMiddleClickEvent = false
  for _, evt in ipairs(eventsReceived) do
    if evt.type == "middleclick" and evt.button == 3 then
      hasMiddleClickEvent = true
      break
    end
  end
  lu.assertTrue(hasMiddleClickEvent, "Should receive middleclick event for middle button")
end

-- Test 5: Modifier keys detection
function TestEventSystem:test_modifier_keys_are_detected()
  local eventReceived = nil
  
  local button = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    callback = function(element, event)
      if event.type == "click" then
        eventReceived = event
      end
    end,
  })
  
  -- Simulate shift + click
  love.keyboard.setDown("lshift", true)
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  button:update(0.016)
  
  love.mouse.setDown(1, false)
  button:update(0.016)
  
  lu.assertNotNil(eventReceived, "Should receive click event")
  lu.assertTrue(eventReceived.modifiers.shift, "Shift modifier should be detected")
end

-- Test 6: Double click detection
function TestEventSystem:test_double_click_increments_click_count()
  local clickEvents = {}
  
  local button = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    callback = function(element, event)
      if event.type == "click" then
        table.insert(clickEvents, event.clickCount)
      end
    end,
  })
  
  -- Simulate first click
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  button:update(0.016)
  love.mouse.setDown(1, false)
  button:update(0.016)
  
  -- Simulate second click quickly (double-click)
  love.timer.setTime(love.timer.getTime() + 0.1) -- 100ms later
  love.mouse.setDown(1, true)
  button:update(0.016)
  love.mouse.setDown(1, false)
  button:update(0.016)
  
  lu.assertEquals(#clickEvents, 2, "Should receive 2 click events")
  lu.assertEquals(clickEvents[1], 1, "First click should have clickCount = 1")
  lu.assertEquals(clickEvents[2], 2, "Second click should have clickCount = 2")
end

-- Test 7: Press and release events
function TestEventSystem:test_press_and_release_events_are_fired()
  local eventsReceived = {}
  
  local button = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    callback = function(element, event)
      table.insert(eventsReceived, event.type)
    end,
  })
  
  -- Simulate click
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  button:update(0.016)
  
  love.mouse.setDown(1, false)
  button:update(0.016)
  
  -- Should receive press, click, and release
  lu.assertTrue(#eventsReceived >= 2, "Should receive multiple events")
  
  local hasPress = false
  local hasRelease = false
  for _, eventType in ipairs(eventsReceived) do
    if eventType == "press" then hasPress = true end
    if eventType == "release" then hasRelease = true end
  end
  
  lu.assertTrue(hasPress, "Should receive press event")
  lu.assertTrue(hasRelease, "Should receive release event")
end

-- Test 8: Mouse position in event
function TestEventSystem:test_event_contains_mouse_position()
  local eventReceived = nil
  
  local button = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    callback = function(element, event)
      if event.type == "click" then
        eventReceived = event
      end
    end,
  })
  
  -- Simulate click at specific position
  local mouseX, mouseY = 175, 125
  love.mouse.setPosition(mouseX, mouseY)
  love.mouse.setDown(1, true)
  button:update(0.016)
  
  love.mouse.setDown(1, false)
  button:update(0.016)
  
  lu.assertNotNil(eventReceived, "Should receive click event")
  lu.assertEquals(eventReceived.x, mouseX, "Event should contain correct mouse X position")
  lu.assertEquals(eventReceived.y, mouseY, "Event should contain correct mouse Y position")
end

-- Test 9: No callback when mouse outside element
function TestEventSystem:test_no_callback_when_clicking_outside_element()
  local callbackCalled = false
  
  local button = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    callback = function(element, event)
      callbackCalled = true
    end,
  })
  
  -- Click outside element
  love.mouse.setPosition(50, 50)
  love.mouse.setDown(1, true)
  button:update(0.016)
  
  love.mouse.setDown(1, false)
  button:update(0.016)
  
  lu.assertFalse(callbackCalled, "Callback should not be called when clicking outside element")
end

-- Test 10: Multiple modifiers
function TestEventSystem:test_multiple_modifiers_detected()
  local eventReceived = nil
  
  local button = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    callback = function(element, event)
      if event.type == "click" then
        eventReceived = event
      end
    end,
  })
  
  -- Simulate shift + ctrl + click
  love.keyboard.setDown("lshift", true)
  love.keyboard.setDown("lctrl", true)
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  button:update(0.016)
  
  love.mouse.setDown(1, false)
  button:update(0.016)
  
  lu.assertNotNil(eventReceived, "Should receive click event")
  lu.assertTrue(eventReceived.modifiers.shift, "Shift modifier should be detected")
  lu.assertTrue(eventReceived.modifiers.ctrl, "Ctrl modifier should be detected")
end

return TestEventSystem
