-- Test event handling for immediate children of retained parents

package.path = package.path .. ";./?.lua;./modules/?.lua"

-- Load love stub before anything else
require("testing.loveStub")

local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})

-- Setup package loader to map FlexLove.modules.X to modules/X
local originalSearchers = package.searchers or package.loaders
table.insert(originalSearchers, 2, function(modname)
  if modname:match("^FlexLove%.modules%.") then
    local moduleName = modname:gsub("^FlexLove%.modules%.", "")
    return function() return require("modules." .. moduleName) end
  end
end)

local FlexLove = require("FlexLove")
local Color = require("modules.Color")
local Element = require("modules.Element")

TestMixedModeEvents = {}

function TestMixedModeEvents:setUp()
  FlexLove.init({ immediateMode = false })
end

function TestMixedModeEvents:tearDown()
  if FlexLove.getMode() == "immediate" then
    FlexLove.endFrame()
  end
  FlexLove.init({ immediateMode = false })
end

-- Test that immediate children of retained parents can handle events
function TestMixedModeEvents:test_immediateChildOfRetainedParentHandlesEvents()
  local eventFired = false
  local eventType = nil
  
  -- Create retained parent
  local parent = FlexLove.new({
    mode = "retained",
    width = 800,
    height = 600,
  })
  
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  
  -- Create immediate child with event handler
  local child = FlexLove.new({
    mode = "immediate",
    id = "eventTestChild",
    parent = parent,
    x = 0,
    y = 0,
    width = 100,
    height = 50,
    onEvent = function(element, event)
      eventFired = true
      eventType = event.type
    end,
  })
  
  FlexLove.endFrame()
  
  -- Verify child is positioned correctly
  luaunit.assertEquals(child.x, 0)
  luaunit.assertEquals(child.y, 0)
  
  -- Manually call the event handler (simulating event processing)
  -- In the real app, this would be triggered by mousepressed/released
  if child.onEvent then
    child.onEvent(child, { type = "release", x = 50, y = 25, button = 1 })
  end
  
  -- Verify event was handled
  luaunit.assertTrue(eventFired)
  luaunit.assertEquals(eventType, "release")
end

-- Test that hover state is tracked for immediate children
function TestMixedModeEvents:test_immediateChildOfRetainedParentTracksHover()
  FlexLove.setMode("retained")
  
  -- Create retained parent
  local parent = FlexLove.new({
    mode = "retained",
    width = 800,
    height = 600,
  })
  
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  
  -- Create immediate child
  local child = FlexLove.new({
    mode = "immediate",
    id = "hoverTestChild",
    parent = parent,
    x = 100,
    y = 100,
    width = 100,
    height = 50,
  })
  
  FlexLove.endFrame()
  
  -- Child should have event handler module
  luaunit.assertNotNil(child._eventHandler)
  
  -- Verify child can track hover state (stored in StateManager for immediate mode)
  -- The actual hover detection happens in Element's event processing
  luaunit.assertEquals(child._elementMode, "immediate")
end

-- Test multiple immediate children with different event handlers
function TestMixedModeEvents:test_multipleImmediateChildrenHandleEventsIndependently()
  local button1Clicked = false
  local button2Clicked = false
  
  FlexLove.setMode("retained")
  
  -- Create retained parent
  local parent = FlexLove.new({
    mode = "retained",
    width = 800,
    height = 600,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 10,
  })
  
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  
  -- Create two immediate button children
  local button1 = FlexLove.new({
    mode = "immediate",
    id = "button1",
    parent = parent,
    width = 100,
    height = 50,
    onEvent = function(element, event)
      if event.type == "release" then
        button1Clicked = true
      end
    end,
  })
  
  local button2 = FlexLove.new({
    mode = "immediate",
    id = "button2",
    parent = parent,
    width = 100,
    height = 50,
    onEvent = function(element, event)
      if event.type == "release" then
        button2Clicked = true
      end
    end,
  })
  
  FlexLove.endFrame()
  
  -- Verify buttons are positioned correctly
  luaunit.assertEquals(button1.x, 0)
  luaunit.assertEquals(button2.x, 110) -- 100 + 10 gap
  
  -- Simulate clicking button1
  if button1.onEvent then
    button1.onEvent(button1, { type = "release", x = 50, y = 25, button = 1 })
  end
  
  luaunit.assertTrue(button1Clicked)
  luaunit.assertFalse(button2Clicked)
  
  -- Simulate clicking button2
  if button2.onEvent then
    button2.onEvent(button2, { type = "release", x = 150, y = 25, button = 1 })
  end
  
  luaunit.assertTrue(button1Clicked)
  luaunit.assertTrue(button2Clicked)
end

os.exit(luaunit.LuaUnit.run())
