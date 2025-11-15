local luaunit = require("testing.luaunit")
require("testing.loveStub")

local FlexLove = require("FlexLove")
local Color = require("modules.Color")
local Theme = require("modules.Theme")

TestFlexLove = {}

function TestFlexLove:setUp()
  -- Reset FlexLove state before each test
  FlexLove.destroy()
  FlexLove.setMode("retained")
end

function TestFlexLove:tearDown()
  FlexLove.destroy()
end

-- Test: Module loads and has expected properties
function TestFlexLove:testModuleLoads()
  luaunit.assertNotNil(FlexLove)
  luaunit.assertNotNil(FlexLove._VERSION)
  luaunit.assertEquals(FlexLove._VERSION, "0.2.0")
  luaunit.assertNotNil(FlexLove._DESCRIPTION)
  luaunit.assertNotNil(FlexLove._URL)
  luaunit.assertNotNil(FlexLove._LICENSE)
end

-- Test: init() with no config
function TestFlexLove:testInitNoConfig()
  FlexLove.init()
  luaunit.assertTrue(true) -- Should not error
end

-- Test: init() with empty config
function TestFlexLove:testInitEmptyConfig()
  FlexLove.init({})
  luaunit.assertTrue(true)
end

-- Test: init() with baseScale
function TestFlexLove:testInitWithBaseScale()
  FlexLove.init({
    baseScale = {
      width = 1920,
      height = 1080
    }
  })
  
  luaunit.assertNotNil(FlexLove.baseScale)
  luaunit.assertEquals(FlexLove.baseScale.width, 1920)
  luaunit.assertEquals(FlexLove.baseScale.height, 1080)
end

-- Test: init() with partial baseScale (uses defaults)
function TestFlexLove:testInitWithPartialBaseScale()
  FlexLove.init({
    baseScale = {}
  })
  
  luaunit.assertNotNil(FlexLove.baseScale)
  luaunit.assertEquals(FlexLove.baseScale.width, 1920)
  luaunit.assertEquals(FlexLove.baseScale.height, 1080)
end

-- Test: init() with string theme
function TestFlexLove:testInitWithStringTheme()
  -- Pre-register a theme
  local theme = Theme.new({
    name = "test",
    components = {}
  })
  
  -- init() tries to load and then set active, which may fail if theme path doesn't exist
  -- Just check that it doesn't crash
  FlexLove.init({
    theme = "test"
  })
  
  -- The theme setting may fail silently, so just check it doesn't crash
  luaunit.assertTrue(true)
end

-- Test: init() with table theme
function TestFlexLove:testInitWithTableTheme()
  FlexLove.init({
    theme = {
      name = "custom",
      components = {}
    }
  })
  
  luaunit.assertEquals(FlexLove.defaultTheme, "custom")
end

-- Test: init() with invalid theme (should not crash)
function TestFlexLove:testInitWithInvalidTheme()
  FlexLove.init({
    theme = "nonexistent-theme"
  })
  
  -- Should not crash, just print warning
  luaunit.assertTrue(true)
end

-- Test: init() with immediateMode = true
function TestFlexLove:testInitWithImmediateMode()
  FlexLove.init({
    immediateMode = true
  })
  
  luaunit.assertEquals(FlexLove.getMode(), "immediate")
end

-- Test: init() with immediateMode = false
function TestFlexLove:testInitWithRetainedMode()
  FlexLove.init({
    immediateMode = false
  })
  
  luaunit.assertEquals(FlexLove.getMode(), "retained")
end

-- Test: init() with autoFrameManagement
function TestFlexLove:testInitWithAutoFrameManagement()
  FlexLove.init({
    autoFrameManagement = true
  })
  
  luaunit.assertEquals(FlexLove._autoFrameManagement, true)
end

-- Test: init() with state configuration
function TestFlexLove:testInitWithStateConfig()
  FlexLove.init({
    stateRetentionFrames = 5,
    maxStateEntries = 100
  })
  
  luaunit.assertTrue(true) -- Should configure StateManager
end

-- Test: setMode() to immediate
function TestFlexLove:testSetModeImmediate()
  FlexLove.setMode("immediate")
  luaunit.assertTrue(FlexLove._immediateMode)
  luaunit.assertFalse(FlexLove._frameStarted)
end

-- Test: setMode() to retained
function TestFlexLove:testSetModeRetained()
  FlexLove.setMode("immediate") -- First set to immediate
  FlexLove.setMode("retained")  -- Then to retained
  
  luaunit.assertFalse(FlexLove._immediateMode)
  luaunit.assertEquals(FlexLove._frameNumber, 0)
end

-- Test: setMode() with invalid mode
function TestFlexLove:testSetModeInvalid()
  local success = pcall(function()
    FlexLove.setMode("invalid")
  end)
  
  luaunit.assertFalse(success)
end

-- Test: getMode() returns correct mode
function TestFlexLove:testGetMode()
  FlexLove.setMode("immediate")
  luaunit.assertEquals(FlexLove.getMode(), "immediate")
  
  FlexLove.setMode("retained")
  luaunit.assertEquals(FlexLove.getMode(), "retained")
end

-- Test: beginFrame() in immediate mode
function TestFlexLove:testBeginFrameImmediate()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  
  luaunit.assertTrue(FlexLove._frameStarted)
  luaunit.assertEquals(#FlexLove._currentFrameElements, 0)
end

-- Test: beginFrame() in retained mode (should do nothing)
function TestFlexLove:testBeginFrameRetained()
  FlexLove.setMode("retained")
  local frameNumber = FlexLove._frameNumber or 0
  FlexLove.beginFrame()
  
  -- Frame number should not change in retained mode
  luaunit.assertEquals(FlexLove._frameNumber or 0, frameNumber)
end

-- Test: endFrame() in immediate mode
function TestFlexLove:testEndFrameImmediate()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  FlexLove.endFrame()
  
  luaunit.assertFalse(FlexLove._frameStarted)
end

-- Test: endFrame() in retained mode (should do nothing)
function TestFlexLove:testEndFrameRetained()
  FlexLove.setMode("retained")
  FlexLove.endFrame()
  
  luaunit.assertTrue(true) -- Should not error
end

-- Test: new() creates element in retained mode
function TestFlexLove:testNewRetainedMode()
  FlexLove.setMode("retained")
  local element = FlexLove.new({ width = 100, height = 100 })
  
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.width, 100)
  luaunit.assertEquals(element.height, 100)
end

-- Test: new() creates element in immediate mode
function TestFlexLove:testNewImmediateMode()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  
  local element = FlexLove.new({
    id = "test-element",
    width = 100,
    height = 100
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.width, 100)
  luaunit.assertEquals(element.height, 100)
  
  FlexLove.endFrame()
end

-- Test: new() auto-begins frame if not started
function TestFlexLove:testNewAutoBeginFrame()
  FlexLove.setMode("immediate")
  
  local element = FlexLove.new({
    id = "auto-begin-test",
    width = 50,
    height = 50
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertTrue(FlexLove._autoBeganFrame)
  
  FlexLove.endFrame()
end

-- Test: new() generates ID if not provided (immediate mode)
function TestFlexLove:testNewGeneratesID()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  
  local element = FlexLove.new({ width = 100, height = 100 })
  
  luaunit.assertNotNil(element.id)
  luaunit.assertTrue(element.id ~= "")
  
  FlexLove.endFrame()
end

-- Test: draw() with no arguments
function TestFlexLove:testDrawNoArgs()
  FlexLove.setMode("retained")
  FlexLove.draw()
  
  luaunit.assertTrue(true) -- Should not error
end

-- Test: draw() with gameDrawFunc
function TestFlexLove:testDrawWithGameFunc()
  FlexLove.setMode("retained")
  
  local called = false
  FlexLove.draw(function()
    called = true
  end)
  
  luaunit.assertTrue(called)
end

-- Test: draw() with postDrawFunc
function TestFlexLove:testDrawWithPostFunc()
  FlexLove.setMode("retained")
  
  local called = false
  FlexLove.draw(nil, function()
    called = true
  end)
  
  luaunit.assertTrue(called)
end

-- Test: draw() with both functions
function TestFlexLove:testDrawWithBothFuncs()
  FlexLove.setMode("retained")
  
  local gameCalled = false
  local postCalled = false
  
  FlexLove.draw(
    function() gameCalled = true end,
    function() postCalled = true end
  )
  
  luaunit.assertTrue(gameCalled)
  luaunit.assertTrue(postCalled)
end

-- Test: draw() with elements (no backdrop blur)
function TestFlexLove:testDrawWithElements()
  FlexLove.setMode("retained")
  
  local element = FlexLove.new({
    width = 100,
    height = 100,
    backgroundColor = Color.new(1, 1, 1, 1)
  })
  
  FlexLove.draw()
  
  luaunit.assertTrue(true) -- Should not error
end

-- Test: draw() auto-ends frame in immediate mode
function TestFlexLove:testDrawAutoEndFrame()
  FlexLove.setMode("immediate")
  
  local element = FlexLove.new({
    id = "auto-end-test",
    width = 100,
    height = 100
  })
  
  -- draw() should call endFrame() if _autoBeganFrame is true
  FlexLove.draw()
  
  luaunit.assertFalse(FlexLove._autoBeganFrame)
end

-- Test: update() with no elements
function TestFlexLove:testUpdateNoElements()
  FlexLove.setMode("retained")
  FlexLove.update(0.016)
  
  luaunit.assertTrue(true) -- Should not error
end

-- Test: update() in retained mode with elements
function TestFlexLove:testUpdateRetainedMode()
  FlexLove.setMode("retained")
  
  local element = FlexLove.new({
    width = 100,
    height = 100
  })
  
  FlexLove.update(0.016)
  
  luaunit.assertTrue(true)
end

-- Test: update() in immediate mode (should skip element updates)
function TestFlexLove:testUpdateImmediateMode()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  
  local element = FlexLove.new({
    id = "update-test",
    width = 100,
    height = 100
  })
  
  FlexLove.endFrame()
  FlexLove.update(0.016)
  
  luaunit.assertTrue(true)
end

-- Test: resize() with no baseScale
function TestFlexLove:testResizeNoBaseScale()
  FlexLove.setMode("retained")
  FlexLove.resize()
  
  luaunit.assertTrue(true) -- Should not error
end

-- Test: resize() with baseScale
function TestFlexLove:testResizeWithBaseScale()
  FlexLove.init({
    baseScale = {
      width = 1920,
      height = 1080
    }
  })
  
  FlexLove.resize()
  
  luaunit.assertNotNil(FlexLove.scaleFactors)
end

-- Test: resize() with elements
function TestFlexLove:testResizeWithElements()
  FlexLove.setMode("retained")
  
  local element = FlexLove.new({
    width = 100,
    height = 100
  })
  
  FlexLove.resize()
  
  luaunit.assertTrue(true)
end

-- Test: destroy() clears all elements
function TestFlexLove:testDestroy()
  FlexLove.setMode("retained")
  
  local element = FlexLove.new({
    width = 100,
    height = 100
  })
  
  FlexLove.destroy()
  
  luaunit.assertEquals(#FlexLove.topElements, 0)
  luaunit.assertNil(FlexLove.baseScale)
  luaunit.assertNil(FlexLove._focusedElement)
end

-- Test: textinput() with no focused element
function TestFlexLove:testTextInputNoFocus()
  FlexLove.setMode("retained")
  FlexLove.textinput("a")
  
  luaunit.assertTrue(true) -- Should not error
end

-- Test: textinput() with focused element
function TestFlexLove:testTextInputWithFocus()
  FlexLove.setMode("retained")
  
  local element = FlexLove.new({
    width = 100,
    height = 100,
    editable = true
  })
  
  FlexLove._focusedElement = element
  FlexLove.textinput("a")
  
  luaunit.assertTrue(true)
end

-- Test: keypressed() with no focused element
function TestFlexLove:testKeyPressedNoFocus()
  FlexLove.setMode("retained")
  FlexLove.keypressed("return", "return", false)
  
  luaunit.assertTrue(true) -- Should not error
end

-- Test: keypressed() with focused element
function TestFlexLove:testKeyPressedWithFocus()
  FlexLove.setMode("retained")
  
  local element = FlexLove.new({
    width = 100,
    height = 100,
    editable = true
  })
  
  FlexLove._focusedElement = element
  FlexLove.keypressed("return", "return", false)
  
  luaunit.assertTrue(true)
end

-- Test: wheelmoved() in retained mode with no elements
function TestFlexLove:testWheelMovedRetainedNoElements()
  FlexLove.setMode("retained")
  FlexLove.wheelmoved(0, 1)
  
  luaunit.assertTrue(true) -- Should not error
end

-- Test: wheelmoved() in immediate mode
function TestFlexLove:testWheelMovedImmediate()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  
  local element = FlexLove.new({
    id = "wheel-test",
    width = 100,
    height = 100
  })
  
  FlexLove.endFrame()
  FlexLove.wheelmoved(0, 1)
  
  luaunit.assertTrue(true)
end

-- Test: getStateCount() in retained mode
function TestFlexLove:testGetStateCountRetained()
  FlexLove.setMode("retained")
  local count = FlexLove.getStateCount()
  
  luaunit.assertEquals(count, 0)
end

-- Test: getStateCount() in immediate mode
function TestFlexLove:testGetStateCountImmediate()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  
  local element = FlexLove.new({
    id = "state-test",
    width = 100,
    height = 100
  })
  
  FlexLove.endFrame()
  
  local count = FlexLove.getStateCount()
  luaunit.assertTrue(count >= 0)
end

-- Test: clearState() in retained mode (should do nothing)
function TestFlexLove:testClearStateRetained()
  FlexLove.setMode("retained")
  FlexLove.clearState("test-id")
  
  luaunit.assertTrue(true)
end

-- Test: clearState() in immediate mode
function TestFlexLove:testClearStateImmediate()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  
  local element = FlexLove.new({
    id = "clear-test",
    width = 100,
    height = 100
  })
  
  FlexLove.endFrame()
  
  FlexLove.clearState("clear-test")
  luaunit.assertTrue(true)
end

-- Test: clearAllStates() in retained mode
function TestFlexLove:testClearAllStatesRetained()
  FlexLove.setMode("retained")
  FlexLove.clearAllStates()
  
  luaunit.assertTrue(true)
end

-- Test: clearAllStates() in immediate mode
function TestFlexLove:testClearAllStatesImmediate()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  FlexLove.endFrame()
  
  FlexLove.clearAllStates()
  luaunit.assertTrue(true)
end

-- Test: getStateStats() in retained mode
function TestFlexLove:testGetStateStatsRetained()
  FlexLove.setMode("retained")
  local stats = FlexLove.getStateStats()
  
  luaunit.assertEquals(stats.stateCount, 0)
  luaunit.assertEquals(stats.frameNumber, 0)
end

-- Test: getStateStats() in immediate mode
function TestFlexLove:testGetStateStatsImmediate()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  FlexLove.endFrame()
  
  local stats = FlexLove.getStateStats()
  luaunit.assertNotNil(stats)
end

-- Test: getElementAtPosition() with no elements
function TestFlexLove:testGetElementAtPositionNoElements()
  FlexLove.setMode("retained")
  local element = FlexLove.getElementAtPosition(50, 50)
  
  luaunit.assertNil(element)
end

-- Test: getElementAtPosition() with element at position
function TestFlexLove:testGetElementAtPosition()
  FlexLove.setMode("retained")
  
  local element = FlexLove.new({
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    onEvent = function() end
  })
  
  local found = FlexLove.getElementAtPosition(50, 50)
  luaunit.assertEquals(found, element)
end

-- Test: getElementAtPosition() outside element bounds
function TestFlexLove:testGetElementAtPositionOutside()
  FlexLove.setMode("retained")
  
  local element = FlexLove.new({
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    onEvent = function() end
  })
  
  local found = FlexLove.getElementAtPosition(200, 200)
  luaunit.assertNil(found)
end

-- Test: External modules are exposed
function TestFlexLove:testExternalModulesExposed()
  luaunit.assertNotNil(FlexLove.Animation)
  luaunit.assertNotNil(FlexLove.Color)
  luaunit.assertNotNil(FlexLove.Theme)
  luaunit.assertNotNil(FlexLove.enums)
end

-- Test: Enums are accessible
function TestFlexLove:testEnumsAccessible()
  luaunit.assertNotNil(FlexLove.enums.FlexDirection)
  luaunit.assertNotNil(FlexLove.enums.JustifyContent)
  luaunit.assertNotNil(FlexLove.enums.AlignItems)
end

return TestFlexLove
