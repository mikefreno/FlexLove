-- Test: Immediate Mode Basic Functionality
package.path = package.path .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua"

local luaunit = require("testing.luaunit")
require("testing.loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

local Gui = FlexLove.Gui

TestImmediateModeBasic = {}

function TestImmediateModeBasic:setUp()
  -- Reset GUI state
  if Gui.destroy then
    Gui.destroy()
  end

  -- Initialize with immediate mode enabled
  Gui.init({
    baseScale = { width = 1920, height = 1080 },
    immediateMode = true,
  })
end

function TestImmediateModeBasic:tearDown()
  -- Clear all states
  if Gui.clearAllStates then
    Gui.clearAllStates()
  end

  -- Reset immediate mode state
  if Gui._immediateModeState then
    Gui._immediateModeState.reset()
  end

  if Gui.destroy then
    Gui.destroy()
  end

  -- Reset immediate mode flag
  Gui._immediateMode = false
  Gui._frameNumber = 0
end

function TestImmediateModeBasic:test_immediate_mode_enabled()
  luaunit.assertTrue(Gui._immediateMode, "Immediate mode should be enabled")
  luaunit.assertNotNil(Gui._immediateModeState, "Immediate mode state should be initialized")
end

function TestImmediateModeBasic:test_frame_lifecycle()
  -- Begin frame
  Gui.beginFrame()

  luaunit.assertEquals(Gui._frameNumber, 1, "Frame number should increment to 1")
  luaunit.assertEquals(#Gui.topElements, 0, "Top elements should be empty at frame start")

  -- Create an element
  local button = Gui.new({
    id = "test_button",
    width = 100,
    height = 50,
    text = "Click me",
  })

  luaunit.assertNotNil(button, "Button should be created")
  luaunit.assertEquals(button.id, "test_button", "Button should have correct ID")

  -- End frame
  Gui.endFrame()

  -- State should persist
  luaunit.assertEquals(Gui.getStateCount(), 1, "Should have 1 state entry")
end

function TestImmediateModeBasic:test_auto_id_generation()
  Gui.beginFrame()

  -- Create element without explicit ID
  local element1 = Gui.new({
    width = 100,
    height = 50,
  })

  luaunit.assertNotNil(element1.id, "Element should have auto-generated ID")
  luaunit.assertNotEquals(element1.id, "", "Auto-generated ID should not be empty")

  Gui.endFrame()
end

function TestImmediateModeBasic:test_state_persistence()
  -- Frame 1: Create button and simulate click
  Gui.beginFrame()

  local button = Gui.new({
    id = "persistent_button",
    width = 100,
    height = 50,
    text = "Click me",
  })

  -- Simulate some state
  button._clickCount = 5
  button._lastClickTime = 123.45

  Gui.endFrame()

  -- Frame 2: Recreate button - state should persist
  Gui.beginFrame()

  local button2 = Gui.new({
    id = "persistent_button",
    width = 100,
    height = 50,
    text = "Click me",
  })

  luaunit.assertEquals(button2._clickCount, 5, "Click count should persist")
  luaunit.assertEquals(button2._lastClickTime, 123.45, "Last click time should persist")

  Gui.endFrame()
end

function TestImmediateModeBasic:test_helper_functions()
  Gui.beginFrame()

  -- Test button helper
  local button = Gui.button({
    id = "helper_button",
    width = 100,
    height = 50,
    text = "Button",
  })

  luaunit.assertNotNil(button, "Button helper should create element")
  luaunit.assertEquals(button.themeComponent, "button", "Button should have theme component")

  -- Test panel helper
  local panel = Gui.panel({
    id = "helper_panel",
    width = 200,
    height = 200,
  })

  luaunit.assertNotNil(panel, "Panel helper should create element")

  -- Test text helper
  local text = Gui.text({
    id = "helper_text",
    text = "Hello",
  })

  luaunit.assertNotNil(text, "Text helper should create element")

  -- Test input helper
  local input = Gui.input({
    id = "helper_input",
    width = 150,
    height = 30,
  })

  luaunit.assertNotNil(input, "Input helper should create element")
  luaunit.assertTrue(input.editable, "Input should be editable")

  Gui.endFrame()
end

function TestImmediateModeBasic:test_state_cleanup()
  Gui.init({
    immediateMode = true,
    stateRetentionFrames = 2, -- Very short retention for testing
  })

  -- Frame 1: Create temporary element
  Gui.beginFrame()
  Gui.new({
    id = "temp_element",
    width = 100,
    height = 50,
  })
  Gui.endFrame()

  luaunit.assertEquals(Gui.getStateCount(), 1, "Should have 1 state after frame 1")

  -- Frame 2: Don't create the element
  Gui.beginFrame()
  Gui.endFrame()

  luaunit.assertEquals(Gui.getStateCount(), 1, "Should still have 1 state after frame 2")

  -- Frame 3: Still don't create it
  Gui.beginFrame()
  Gui.endFrame()

  luaunit.assertEquals(Gui.getStateCount(), 1, "Should still have 1 state after frame 3")

  -- Frame 4: Should be cleaned up now (retention = 2 frames)
  Gui.beginFrame()
  Gui.endFrame()

  luaunit.assertEquals(Gui.getStateCount(), 0, "State should be cleaned up after retention period")
end

function TestImmediateModeBasic:test_manual_state_management()
  Gui.beginFrame()

  Gui.new({
    id = "element1",
    width = 100,
    height = 50,
  })

  Gui.new({
    id = "element2",
    width = 100,
    height = 50,
  })

  Gui.endFrame()

  luaunit.assertEquals(Gui.getStateCount(), 2, "Should have 2 states")

  -- Clear specific state
  Gui.clearState("element1")
  luaunit.assertEquals(Gui.getStateCount(), 1, "Should have 1 state after clearing element1")

  -- Clear all states
  Gui.clearAllStates()
  luaunit.assertEquals(Gui.getStateCount(), 0, "Should have 0 states after clearing all")
end

function TestImmediateModeBasic:test_retained_mode_still_works()
  -- Reinitialize without immediate mode
  Gui.destroy()
  Gui.init({
    baseScale = { width = 1920, height = 1080 },
    immediateMode = false, -- Explicitly disable
  })

  luaunit.assertFalse(Gui._immediateMode, "Immediate mode should be disabled")

  -- Create element in retained mode
  local element = Gui.new({
    width = 100,
    height = 50,
    text = "Retained",
  })

  luaunit.assertNotNil(element, "Element should be created in retained mode")
  luaunit.assertEquals(#Gui.topElements, 1, "Should have 1 top element")

  -- Element should persist without beginFrame/endFrame
  luaunit.assertEquals(#Gui.topElements, 1, "Element should still exist")
end

function TestImmediateModeBasic:test_state_stats()
  Gui.beginFrame()

  Gui.new({
    id = "stats_test",
    width = 100,
    height = 50,
  })

  Gui.endFrame()

  local stats = Gui.getStateStats()

  luaunit.assertNotNil(stats, "Stats should be returned")
  luaunit.assertEquals(stats.stateCount, 1, "Stats should show 1 state")
  luaunit.assertNotNil(stats.frameNumber, "Stats should include frame number")
end

luaunit.LuaUnit.run()
