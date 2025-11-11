-- Drag Event Tests
-- Tests for the new drag event functionality

package.path = package.path .. ";?.lua"

local lu = require("testing.luaunit")
require("testing.loveStub")
local FlexLove = require("FlexLove")
local Gui = FlexLove.Gui

TestDragEvent = {}

function TestDragEvent:setUp()
  -- Initialize GUI before each test
  Gui.init({ baseScale = { width = 1920, height = 1080 } })
  love.window.setMode(1920, 1080)
  Gui.resize(1920, 1080) -- Recalculate scale factors after setMode
end

function TestDragEvent:tearDown()
  -- Clean up after each test
  Gui.destroy()
end

-- Test 1: Drag event is fired when mouse moves while pressed
function TestDragEvent:test_drag_event_fired_on_mouse_movement()
  local dragEventReceived = false
  local dragEvent = nil

  local element = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    onEvent = function(el, event)
      if event.type == "drag" then
        dragEventReceived = true
        dragEvent = event
      end
    end,
  })

  -- Simulate mouse press
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  element:update(0.016)

  -- Move mouse while pressed (drag)
  love.mouse.setPosition(160, 155)
  element:update(0.016)

  lu.assertTrue(dragEventReceived, "Drag event should be fired when mouse moves while pressed")
  lu.assertNotNil(dragEvent, "Drag event object should exist")
end

-- Test 2: Drag event contains dx and dy fields
function TestDragEvent:test_drag_event_contains_delta_values()
  local dragEvent = nil

  local element = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    onEvent = function(el, event)
      if event.type == "drag" then
        dragEvent = event
      end
    end,
  })

  -- Simulate mouse press at (150, 150)
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  element:update(0.016)

  -- Move mouse to (160, 155) - delta should be (10, 5)
  love.mouse.setPosition(160, 155)
  element:update(0.016)

  lu.assertNotNil(dragEvent, "Drag event should be received")
  lu.assertNotNil(dragEvent.dx, "Drag event should have dx field")
  lu.assertNotNil(dragEvent.dy, "Drag event should have dy field")
  lu.assertEquals(dragEvent.dx, 10, "dx should be 10 (160 - 150)")
  lu.assertEquals(dragEvent.dy, 5, "dy should be 5 (155 - 150)")
end

-- Test 3: Drag event updates dx/dy as mouse continues to move
function TestDragEvent:test_drag_event_updates_delta_continuously()
  local dragEvents = {}

  local element = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    onEvent = function(el, event)
      if event.type == "drag" then
        table.insert(dragEvents, { dx = event.dx, dy = event.dy })
      end
    end,
  })

  -- Press at (150, 150)
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  element:update(0.016)

  -- Move to (160, 155)
  love.mouse.setPosition(160, 155)
  element:update(0.016)

  -- Move to (170, 160)
  love.mouse.setPosition(170, 160)
  element:update(0.016)

  lu.assertEquals(#dragEvents, 2, "Should receive 2 drag events")
  lu.assertEquals(dragEvents[1].dx, 10, "First drag dx should be 10")
  lu.assertEquals(dragEvents[1].dy, 5, "First drag dy should be 5")
  lu.assertEquals(dragEvents[2].dx, 20, "Second drag dx should be 20 (170 - 150)")
  lu.assertEquals(dragEvents[2].dy, 10, "Second drag dy should be 10 (160 - 150)")
end

-- Test 4: No drag event when mouse doesn't move
function TestDragEvent:test_no_drag_event_when_mouse_stationary()
  local dragEventCount = 0

  local element = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    onEvent = function(el, event)
      if event.type == "drag" then
        dragEventCount = dragEventCount + 1
      end
    end,
  })

  -- Press at (150, 150)
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  element:update(0.016)

  -- Update again without moving mouse
  element:update(0.016)
  element:update(0.016)

  lu.assertEquals(dragEventCount, 0, "Should not receive drag events when mouse doesn't move")
end

-- Test 5: Drag tracking is cleaned up on release
function TestDragEvent:test_drag_tracking_cleaned_up_on_release()
  local dragEvents = {}

  local element = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    onEvent = function(el, event)
      if event.type == "drag" then
        table.insert(dragEvents, { dx = event.dx, dy = event.dy })
      end
    end,
  })

  -- First drag sequence
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  element:update(0.016)

  love.mouse.setPosition(160, 155)
  element:update(0.016)

  -- Release
  love.mouse.setDown(1, false)
  element:update(0.016)

  -- Second drag sequence - should start fresh
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  element:update(0.016)

  love.mouse.setPosition(155, 152)
  element:update(0.016)

  lu.assertEquals(#dragEvents, 2, "Should receive 2 drag events total")
  lu.assertEquals(dragEvents[1].dx, 10, "First drag dx should be 10")
  lu.assertEquals(dragEvents[2].dx, 5, "Second drag dx should be 5 (new drag start)")
end

-- Test 6: Drag works with different mouse buttons
function TestDragEvent:test_drag_works_with_different_buttons()
  local dragEvents = {}

  local element = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    onEvent = function(el, event)
      if event.type == "drag" then
        table.insert(dragEvents, { button = event.button, dx = event.dx })
      end
    end,
  })

  -- Right button drag
  -- Make sure no other buttons are down
  love.mouse.setDown(1, false)
  love.mouse.setDown(3, false)

  love.mouse.setPosition(150, 150)
  love.mouse.setDown(2, true)
  element:update(0.016)

  love.mouse.setPosition(160, 150)
  element:update(0.016)

  lu.assertEquals(#dragEvents, 1, "Should receive drag event for right button")
  lu.assertEquals(dragEvents[1].button, 2, "Drag event should be for button 2")
  lu.assertEquals(dragEvents[1].dx, 10, "Drag dx should be 10")
end

-- Test 7: Drag event contains correct mouse position
function TestDragEvent:test_drag_event_contains_mouse_position()
  local dragEvent = nil

  local element = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    onEvent = function(el, event)
      if event.type == "drag" then
        dragEvent = event
      end
    end,
  })

  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  element:update(0.016)

  love.mouse.setPosition(175, 165)
  element:update(0.016)

  lu.assertNotNil(dragEvent, "Drag event should be received")
  lu.assertEquals(dragEvent.x, 175, "Drag event x should match current mouse x")
  lu.assertEquals(dragEvent.y, 165, "Drag event y should match current mouse y")
end

-- Test 8: No drag event when mouse leaves element
function TestDragEvent:test_no_drag_when_mouse_leaves_element()
  local dragEventCount = 0

  local element = Gui.new({
    x = 100,
    y = 100,
    width = 200,
    height = 100,
    onEvent = function(el, event)
      if event.type == "drag" then
        dragEventCount = dragEventCount + 1
      end
    end,
  })

  -- Press inside element
  love.mouse.setPosition(150, 150)
  love.mouse.setDown(1, true)
  element:update(0.016)

  -- Move outside element
  love.mouse.setPosition(50, 50)
  element:update(0.016)

  lu.assertEquals(dragEventCount, 0, "Should not receive drag events when mouse leaves element")
end

lu.LuaUnit.run()
