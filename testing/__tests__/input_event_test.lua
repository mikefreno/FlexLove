-- Test suite for InputEvent module
package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local InputEvent = require("modules.InputEvent")

TestInputEvent = {}

-- Test: new() creates click event with all properties
function TestInputEvent:test_new_creates_click_event()
  local event = InputEvent.new({
    type = "click",
    button = 1,
    x = 100,
    y = 200,
    modifiers = { shift = false, ctrl = false, alt = false, super = false },
  })

  luaunit.assertNotNil(event, "new() should return event")
  luaunit.assertEquals(event.type, "click")
  luaunit.assertEquals(event.button, 1)
  luaunit.assertEquals(event.x, 100)
  luaunit.assertEquals(event.y, 200)
  luaunit.assertNotNil(event.modifiers)
  luaunit.assertEquals(event.modifiers.shift, false)
end

-- Test: new() creates press event
function TestInputEvent:test_new_creates_press_event()
  local event = InputEvent.new({
    type = "press",
    button = 1,
    x = 50,
    y = 75,
    modifiers = { shift = true, ctrl = false, alt = false, super = false },
  })

  luaunit.assertEquals(event.type, "press")
  luaunit.assertEquals(event.button, 1)
  luaunit.assertEquals(event.x, 50)
  luaunit.assertEquals(event.y, 75)
  luaunit.assertEquals(event.modifiers.shift, true)
end

-- Test: new() creates release event
function TestInputEvent:test_new_creates_release_event()
  local event = InputEvent.new({
    type = "release",
    button = 1,
    x = 150,
    y = 250,
    modifiers = { shift = false, ctrl = false, alt = false, super = false },
  })

  luaunit.assertEquals(event.type, "release")
end

-- Test: new() creates rightclick event with button 2
function TestInputEvent:test_new_creates_rightclick_event()
  local event = InputEvent.new({
    type = "rightclick",
    button = 2,
    x = 100,
    y = 100,
    modifiers = { shift = false, ctrl = true, alt = false, super = false },
  })

  luaunit.assertEquals(event.type, "rightclick")
  luaunit.assertEquals(event.button, 2)
  luaunit.assertEquals(event.modifiers.ctrl, true)
end

-- Test: new() creates middleclick event with button 3
function TestInputEvent:test_new_creates_middleclick_event()
  local event = InputEvent.new({
    type = "middleclick",
    button = 3,
    x = 200,
    y = 300,
    modifiers = { shift = false, ctrl = false, alt = true, super = false },
  })

  luaunit.assertEquals(event.type, "middleclick")
  luaunit.assertEquals(event.button, 3)
  luaunit.assertEquals(event.modifiers.alt, true)
end

-- Test: new() creates drag event with dx and dy
function TestInputEvent:test_new_creates_drag_event_with_deltas()
  local event = InputEvent.new({
    type = "drag",
    button = 1,
    x = 100,
    y = 100,
    dx = 20,
    dy = -15,
    modifiers = { shift = false, ctrl = false, alt = false, super = false },
  })

  luaunit.assertEquals(event.type, "drag")
  luaunit.assertEquals(event.dx, 20)
  luaunit.assertEquals(event.dy, -15)
end

-- Test: new() defaults clickCount to 1 if not provided
function TestInputEvent:test_new_defaults_clickCount_to_one()
  local event = InputEvent.new({
    type = "click",
    button = 1,
    x = 0,
    y = 0,
    modifiers = { shift = false, ctrl = false, alt = false, super = false },
  })

  luaunit.assertEquals(event.clickCount, 1)
end

-- Test: new() accepts custom clickCount for double-click
function TestInputEvent:test_new_accepts_custom_clickCount()
  local event = InputEvent.new({
    type = "click",
    button = 1,
    x = 0,
    y = 0,
    clickCount = 2,
    modifiers = { shift = false, ctrl = false, alt = false, super = false },
  })

  luaunit.assertEquals(event.clickCount, 2)
end

-- Test: new() accepts custom clickCount for triple-click
function TestInputEvent:test_new_accepts_triple_click()
  local event = InputEvent.new({
    type = "click",
    button = 1,
    x = 0,
    y = 0,
    clickCount = 3,
    modifiers = { shift = false, ctrl = false, alt = false, super = false },
  })

  luaunit.assertEquals(event.clickCount, 3)
end

-- Test: new() defaults timestamp to current time if not provided
function TestInputEvent:test_new_defaults_timestamp()
  local before = love.timer.getTime()
  local event = InputEvent.new({
    type = "click",
    button = 1,
    x = 0,
    y = 0,
    modifiers = { shift = false, ctrl = false, alt = false, super = false },
  })
  local after = love.timer.getTime()

  luaunit.assertNotNil(event.timestamp)
  luaunit.assertTrue(event.timestamp >= before)
  luaunit.assertTrue(event.timestamp <= after)
end

-- Test: new() accepts custom timestamp
function TestInputEvent:test_new_accepts_custom_timestamp()
  local customTime = 12345.678
  local event = InputEvent.new({
    type = "click",
    button = 1,
    x = 0,
    y = 0,
    timestamp = customTime,
    modifiers = { shift = false, ctrl = false, alt = false, super = false },
  })

  luaunit.assertEquals(event.timestamp, customTime)
end

-- Test: new() handles all modifier keys
function TestInputEvent:test_new_handles_all_modifier_keys()
  local event = InputEvent.new({
    type = "click",
    button = 1,
    x = 0,
    y = 0,
    modifiers = { shift = true, ctrl = true, alt = true, super = true },
  })

  luaunit.assertEquals(event.modifiers.shift, true)
  luaunit.assertEquals(event.modifiers.ctrl, true)
  luaunit.assertEquals(event.modifiers.alt, true)
  luaunit.assertEquals(event.modifiers.super, true)
end

-- Test: new() handles nil dx/dy for non-drag events
function TestInputEvent:test_new_handles_nil_deltas()
  local event = InputEvent.new({
    type = "click",
    button = 1,
    x = 100,
    y = 100,
    modifiers = { shift = false, ctrl = false, alt = false, super = false },
  })

  luaunit.assertNil(event.dx)
  luaunit.assertNil(event.dy)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
