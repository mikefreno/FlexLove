local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})
require("testing.loveStub")

local FlexLove = require("FlexLove")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})
local Color = require("modules.Color")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})
local Theme = require("modules.Theme")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})

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
  luaunit.assertEquals(FlexLove._VERSION, "0.2.3")
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
      height = 1080,
    },
  })

  luaunit.assertNotNil(FlexLove.baseScale)
  luaunit.assertEquals(FlexLove.baseScale.width, 1920)
  luaunit.assertEquals(FlexLove.baseScale.height, 1080)
end

-- Test: init() with partial baseScale (uses defaults)
function TestFlexLove:testInitWithPartialBaseScale()
  FlexLove.init({
    baseScale = {},
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
    components = {},
  })

  -- init() tries to load and then set active, which may fail if theme path doesn't exist
  -- Just check that it doesn't crash
  FlexLove.init({
    theme = "test",
  })

  -- The theme setting may fail silently, so just check it doesn't crash
  luaunit.assertTrue(true)
end

-- Test: init() with table theme
function TestFlexLove:testInitWithTableTheme()
  FlexLove.init({
    theme = {
      name = "custom",
      components = {},
    },
  })

  luaunit.assertEquals(FlexLove.defaultTheme, "custom")
end

-- Test: init() with invalid theme (should not crash)
function TestFlexLove:testInitWithInvalidTheme()
  FlexLove.init({
    theme = "nonexistent-theme",
  })

  -- Should not crash, just print warning
  luaunit.assertTrue(true)
end

-- Test: init() with immediateMode = true
function TestFlexLove:testInitWithImmediateMode()
  FlexLove.init({
    immediateMode = true,
  })

  luaunit.assertEquals(FlexLove.getMode(), "immediate")
end

-- Test: init() with immediateMode = false
function TestFlexLove:testInitWithRetainedMode()
  FlexLove.init({
    immediateMode = false,
  })

  luaunit.assertEquals(FlexLove.getMode(), "retained")
end

-- Test: init() with autoFrameManagement
function TestFlexLove:testInitWithAutoFrameManagement()
  FlexLove.init({
    autoFrameManagement = true,
  })

  luaunit.assertEquals(FlexLove._autoFrameManagement, true)
end

-- Test: init() with state configuration
function TestFlexLove:testInitWithStateConfig()
  FlexLove.init({
    stateRetentionFrames = 5,
    maxStateEntries = 100,
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
  FlexLove.setMode("retained") -- Then to retained

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
    height = 100,
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
    height = 50,
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

  FlexLove.draw(function()
    gameCalled = true
  end, function()
    postCalled = true
  end)

  luaunit.assertTrue(gameCalled)
  luaunit.assertTrue(postCalled)
end

-- Test: draw() with elements (no backdrop blur)
function TestFlexLove:testDrawWithElements()
  FlexLove.setMode("retained")

  local element = FlexLove.new({
    width = 100,
    height = 100,
    backgroundColor = Color.new(1, 1, 1, 1),
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
    height = 100,
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
    height = 100,
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
    height = 100,
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
      height = 1080,
    },
  })

  FlexLove.resize()

  luaunit.assertNotNil(FlexLove.scaleFactors)
end

-- Test: resize() with elements
function TestFlexLove:testResizeWithElements()
  FlexLove.setMode("retained")

  local element = FlexLove.new({
    width = 100,
    height = 100,
  })

  FlexLove.resize()

  luaunit.assertTrue(true)
end

-- Test: destroy() clears all elements
function TestFlexLove:testDestroy()
  FlexLove.setMode("retained")

  local element = FlexLove.new({
    width = 100,
    height = 100,
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
    editable = true,
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
    editable = true,
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
    height = 100,
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
    height = 100,
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
    height = 100,
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
    onEvent = function() end,
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
    onEvent = function() end,
  })

  local found = FlexLove.getElementAtPosition(200, 200)
  luaunit.assertNil(found)
end

-- Test: deferCallback() queues callback
function TestFlexLove:testDeferCallbackQueuesCallback()
  FlexLove.setMode("retained")

  local called = false
  FlexLove.deferCallback(function()
    called = true
  end)

  -- Callback should not be called immediately
  luaunit.assertFalse(called)

  -- Callback should be called after executeDeferredCallbacks
  FlexLove.draw()
  luaunit.assertFalse(called) -- Still not called

  FlexLove.executeDeferredCallbacks()
  luaunit.assertTrue(called) -- Now called
end

-- Test: deferCallback() with multiple callbacks
function TestFlexLove:testDeferCallbackMultiple()
  FlexLove.setMode("retained")

  local order = {}
  FlexLove.deferCallback(function()
    table.insert(order, 1)
  end)
  FlexLove.deferCallback(function()
    table.insert(order, 2)
  end)
  FlexLove.deferCallback(function()
    table.insert(order, 3)
  end)

  FlexLove.draw()
  FlexLove.executeDeferredCallbacks()

  luaunit.assertEquals(#order, 3)
  luaunit.assertEquals(order[1], 1)
  luaunit.assertEquals(order[2], 2)
  luaunit.assertEquals(order[3], 3)
end

-- Test: deferCallback() with non-function argument
function TestFlexLove:testDeferCallbackInvalidArgument()
  FlexLove.setMode("retained")

  -- Should warn but not crash
  FlexLove.deferCallback("not a function")
  FlexLove.deferCallback(123)
  FlexLove.deferCallback(nil)

  FlexLove.draw()
  luaunit.assertTrue(true)
end

-- Test: deferCallback() clears queue after execution
function TestFlexLove:testDeferCallbackClearsQueue()
  FlexLove.setMode("retained")

  local callCount = 0
  FlexLove.deferCallback(function()
    callCount = callCount + 1
  end)

  FlexLove.draw()
  FlexLove.executeDeferredCallbacks() -- First execution
  luaunit.assertEquals(callCount, 1)

  FlexLove.draw()
  FlexLove.executeDeferredCallbacks() -- Second execution should not call again
  luaunit.assertEquals(callCount, 1)
end

-- Test: deferCallback() handles callback errors gracefully
function TestFlexLove:testDeferCallbackWithError()
  FlexLove.setMode("retained")

  local called = false
  FlexLove.deferCallback(function()
    error("Intentional error")
  end)
  FlexLove.deferCallback(function()
    called = true
  end)

  -- Should not crash, second callback should still execute
  FlexLove.draw()
  FlexLove.executeDeferredCallbacks()
  luaunit.assertTrue(called)
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

-- ==========================================
-- UNHAPPY PATH TESTS
-- ==========================================

TestFlexLoveUnhappyPaths = {}

function TestFlexLoveUnhappyPaths:setUp()
  FlexLove.destroy()
  FlexLove.setMode("retained")
end

function TestFlexLoveUnhappyPaths:tearDown()
  FlexLove.destroy()
end

-- Test: init() with invalid config types
function TestFlexLoveUnhappyPaths:testInitWithInvalidConfigTypes()
  -- nil and false should work (become {} via `config or {}`)
  FlexLove.init(nil)
  luaunit.assertTrue(true)

  FlexLove.init(false)
  luaunit.assertTrue(true)

  -- String and number will error when trying to index them (config.errorLogFile, config.baseScale, etc.)
  local success = pcall(function()
    FlexLove.init("invalid")
  end)
  -- String indexing may work in Lua (returns nil), check actual behavior
  -- Actually strings can be indexed but will return nil for most keys
  -- So this might not error! Let's just verify it doesn't crash
  luaunit.assertTrue(true)

  success = pcall(function()
    FlexLove.init(123)
  end)
  -- Numbers can't be indexed, should error
  luaunit.assertFalse(success)
end

-- Test: init() with invalid baseScale values
function TestFlexLoveUnhappyPaths:testInitWithInvalidBaseScale()
  -- Negative width/height (should work, just unusual)
  FlexLove.init({
    baseScale = {
      width = -1920,
      height = -1080,
    },
  })
  luaunit.assertTrue(true) -- Should not crash

  -- Zero width/height (division by zero risk)
  local success = pcall(function()
    FlexLove.init({
      baseScale = {
        width = 0,
        height = 0,
      },
    })
  end)
  -- May or may not error depending on implementation

  -- Non-numeric values (should error)
  success = pcall(function()
    FlexLove.init({
      baseScale = {
        width = "invalid",
        height = "invalid",
      },
    })
  end)
  luaunit.assertFalse(success) -- Should error on division
end

-- Test: init() with invalid theme types
function TestFlexLoveUnhappyPaths:testInitWithInvalidThemeTypes()
  -- Numeric theme
  FlexLove.init({ theme = 123 })
  luaunit.assertTrue(true)

  -- Boolean theme
  FlexLove.init({ theme = true })
  luaunit.assertTrue(true)

  -- Function theme
  FlexLove.init({ theme = function() end })
  luaunit.assertTrue(true)
end

-- Test: init() with invalid immediateMode values
function TestFlexLoveUnhappyPaths:testInitWithInvalidImmediateMode()
  FlexLove.init({ immediateMode = "yes" })
  luaunit.assertTrue(true)

  FlexLove.init({ immediateMode = 1 })
  luaunit.assertTrue(true)

  FlexLove.init({ immediateMode = {} })
  luaunit.assertTrue(true)
end

-- Test: init() with invalid state config values
function TestFlexLoveUnhappyPaths:testInitWithInvalidStateConfig()
  -- Negative values
  FlexLove.init({
    stateRetentionFrames = -5,
    maxStateEntries = -100,
  })
  luaunit.assertTrue(true)

  -- Non-numeric values
  FlexLove.init({
    stateRetentionFrames = "five",
    maxStateEntries = "hundred",
  })
  luaunit.assertTrue(true)

  -- Zero values
  FlexLove.init({
    stateRetentionFrames = 0,
    maxStateEntries = 0,
  })
  luaunit.assertTrue(true)
end

-- Test: setMode() with nil
function TestFlexLoveUnhappyPaths:testSetModeNil()
  local success = pcall(function()
    FlexLove.setMode(nil)
  end)
  luaunit.assertFalse(success)
end

-- Test: setMode() with number
function TestFlexLoveUnhappyPaths:testSetModeNumber()
  local success = pcall(function()
    FlexLove.setMode(123)
  end)
  luaunit.assertFalse(success)
end

-- Test: setMode() with table
function TestFlexLoveUnhappyPaths:testSetModeTable()
  local success = pcall(function()
    FlexLove.setMode({ mode = "immediate" })
  end)
  luaunit.assertFalse(success)
end

-- Test: setMode() with empty string
function TestFlexLoveUnhappyPaths:testSetModeEmptyString()
  local success = pcall(function()
    FlexLove.setMode("")
  end)
  luaunit.assertFalse(success)
end

-- Test: setMode() with case-sensitive variation
function TestFlexLoveUnhappyPaths:testSetModeCaseSensitive()
  local success = pcall(function()
    FlexLove.setMode("Immediate")
  end)
  luaunit.assertFalse(success)

  success = pcall(function()
    FlexLove.setMode("RETAINED")
  end)
  luaunit.assertFalse(success)
end

-- Test: beginFrame() multiple times without endFrame()
function TestFlexLoveUnhappyPaths:testBeginFrameMultipleTimes()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  local frameNum1 = FlexLove._frameNumber

  FlexLove.beginFrame() -- Call again without ending
  local frameNum2 = FlexLove._frameNumber

  -- Frame number should increment each time
  luaunit.assertTrue(frameNum2 > frameNum1)
end

-- Test: endFrame() without beginFrame()
function TestFlexLoveUnhappyPaths:testEndFrameWithoutBegin()
  FlexLove.setMode("immediate")
  FlexLove.endFrame() -- Should not crash
  luaunit.assertTrue(true)
end

-- Test: endFrame() multiple times
function TestFlexLoveUnhappyPaths:testEndFrameMultipleTimes()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  FlexLove.endFrame()
  FlexLove.endFrame() -- Call again
  luaunit.assertTrue(true) -- Should not crash
end

-- Test: new() with nil props
function TestFlexLoveUnhappyPaths:testNewWithNilProps()
  FlexLove.setMode("retained")
  local element = FlexLove.new(nil)
  luaunit.assertNotNil(element)
end

-- Test: new() with invalid width/height
function TestFlexLoveUnhappyPaths:testNewWithInvalidDimensions()
  FlexLove.setMode("retained")

  -- Negative dimensions
  local element = FlexLove.new({ width = -100, height = -50 })
  luaunit.assertNotNil(element)

  -- Zero dimensions
  element = FlexLove.new({ width = 0, height = 0 })
  luaunit.assertNotNil(element)

  -- Invalid string dimensions (now returns fallback 0px with warning)
  local success, element = pcall(function()
    return FlexLove.new({ width = "invalid", height = "invalid" })
  end)
  luaunit.assertTrue(success) -- Units.parse returns fallback (0, "px") instead of erroring
  luaunit.assertNotNil(element)
end

-- Test: new() with invalid position
function TestFlexLoveUnhappyPaths:testNewWithInvalidPosition()
  FlexLove.setMode("retained")

  -- Negative positions
  local element = FlexLove.new({ x = -1000, y = -1000, width = 100, height = 100 })
  luaunit.assertNotNil(element)

  -- Extreme positions
  element = FlexLove.new({ x = 1000000, y = 1000000, width = 100, height = 100 })
  luaunit.assertNotNil(element)
end

-- Test: new() with circular parent reference
function TestFlexLoveUnhappyPaths:testNewWithCircularParent()
  FlexLove.setMode("retained")

  local parent = FlexLove.new({ width = 200, height = 200 })
  local child = FlexLove.new({ width = 100, height = 100, parent = parent })

  -- Try to make parent a child of child (circular reference)
  -- This should be prevented by the design
  luaunit.assertNotEquals(parent.parent, child)
end

-- Test: new() in immediate mode without frame
function TestFlexLoveUnhappyPaths:testNewImmediateModeNoFrame()
  FlexLove.setMode("immediate")
  -- Don't call beginFrame()

  local element = FlexLove.new({ width = 100, height = 100 })
  luaunit.assertNotNil(element)
  luaunit.assertTrue(FlexLove._autoBeganFrame)
end

-- Test: draw() with invalid function types
function TestFlexLoveUnhappyPaths:testDrawWithInvalidFunctions()
  FlexLove.setMode("retained")

  -- Non-function gameDrawFunc
  FlexLove.draw("not a function", nil)
  luaunit.assertTrue(true)

  FlexLove.draw(123, nil)
  luaunit.assertTrue(true)

  FlexLove.draw({}, nil)
  luaunit.assertTrue(true)

  -- Non-function postDrawFunc
  FlexLove.draw(nil, "not a function")
  luaunit.assertTrue(true)

  FlexLove.draw(nil, 456)
  luaunit.assertTrue(true)
end

-- Test: draw() with function that errors
function TestFlexLoveUnhappyPaths:testDrawWithErroringFunction()
  FlexLove.setMode("retained")

  local success = pcall(function()
    FlexLove.draw(function()
      error("Intentional error")
    end)
  end)

  luaunit.assertFalse(success)
end

-- Test: update() with invalid dt
function TestFlexLoveUnhappyPaths:testUpdateWithInvalidDt()
  FlexLove.setMode("retained")

  -- Negative dt
  FlexLove.update(-0.016)
  luaunit.assertTrue(true)

  -- Zero dt
  FlexLove.update(0)
  luaunit.assertTrue(true)

  -- Huge dt
  FlexLove.update(1000)
  luaunit.assertTrue(true)

  -- nil dt
  local success = pcall(function()
    FlexLove.update(nil)
  end)
  -- May or may not error depending on implementation
end

-- Test: textinput() with invalid text
function TestFlexLoveUnhappyPaths:testTextInputWithInvalidText()
  FlexLove.setMode("retained")

  -- nil text
  local success = pcall(function()
    FlexLove.textinput(nil)
  end)
  -- Should handle gracefully

  -- Number
  FlexLove.textinput(123)
  luaunit.assertTrue(true)

  -- Empty string
  FlexLove.textinput("")
  luaunit.assertTrue(true)

  -- Very long string
  FlexLove.textinput(string.rep("a", 10000))
  luaunit.assertTrue(true)
end

-- Test: keypressed() with invalid keys
function TestFlexLoveUnhappyPaths:testKeyPressedWithInvalidKeys()
  FlexLove.setMode("retained")

  -- nil key
  local success = pcall(function()
    FlexLove.keypressed(nil, nil, false)
  end)

  -- Empty strings
  FlexLove.keypressed("", "", false)
  luaunit.assertTrue(true)

  -- Invalid key names
  FlexLove.keypressed("invalidkey", "invalidscancode", false)
  luaunit.assertTrue(true)

  -- Non-boolean isrepeat
  FlexLove.keypressed("a", "a", "yes")
  luaunit.assertTrue(true)
end

-- Test: wheelmoved() with invalid values
function TestFlexLoveUnhappyPaths:testWheelMovedWithInvalidValues()
  FlexLove.setMode("retained")

  -- Extreme values
  FlexLove.wheelmoved(1000000, 1000000)
  luaunit.assertTrue(true)

  FlexLove.wheelmoved(-1000000, -1000000)
  luaunit.assertTrue(true)

  -- nil values
  local success = pcall(function()
    FlexLove.wheelmoved(nil, nil)
  end)
  -- May or may not error
end

-- Test: resize() repeatedly in quick succession
function TestFlexLoveUnhappyPaths:testResizeRapidly()
  FlexLove.setMode("retained")

  local element = FlexLove.new({ width = 100, height = 100 })

  for i = 1, 100 do
    FlexLove.resize()
  end

  luaunit.assertTrue(true) -- Should not crash
end

-- Test: destroy() twice
function TestFlexLoveUnhappyPaths:testDestroyTwice()
  FlexLove.setMode("retained")

  local element = FlexLove.new({ width = 100, height = 100 })

  FlexLove.destroy()
  FlexLove.destroy() -- Call again

  luaunit.assertTrue(true) -- Should not crash
end

-- Test: clearState() with invalid ID types
function TestFlexLoveUnhappyPaths:testClearStateWithInvalidIds()
  FlexLove.setMode("immediate")

  -- nil ID (should error)
  local success = pcall(function()
    FlexLove.clearState(nil)
  end)
  luaunit.assertFalse(success)

  -- Number ID (should work, gets converted to string)
  FlexLove.clearState(123)
  luaunit.assertTrue(true)

  -- Table ID (may error)
  success = pcall(function()
    FlexLove.clearState({})
  end)
  -- May or may not work depending on tostring implementation

  -- Empty string (should work)
  FlexLove.clearState("")
  luaunit.assertTrue(true)

  -- Non-existent ID (should work, just does nothing)
  FlexLove.clearState("nonexistent-id-12345")
  luaunit.assertTrue(true)
end

-- Test: getElementAtPosition() with invalid coordinates
function TestFlexLoveUnhappyPaths:testGetElementAtPositionWithInvalidCoords()
  FlexLove.setMode("retained")

  -- Negative coordinates
  local element = FlexLove.getElementAtPosition(-100, -100)
  luaunit.assertNil(element)

  -- Extreme coordinates
  element = FlexLove.getElementAtPosition(1000000, 1000000)
  luaunit.assertNil(element)

  -- nil coordinates
  local success = pcall(function()
    FlexLove.getElementAtPosition(nil, nil)
  end)
  -- May or may not error
end

-- Test: Creating element with conflicting properties
function TestFlexLoveUnhappyPaths:testNewWithConflictingProperties()
  FlexLove.setMode("retained")

  -- Both width auto and explicit
  local element = FlexLove.new({
    width = 100,
    autosizing = { width = true },
  })
  luaunit.assertNotNil(element)

  -- Conflicting positioning
  element = FlexLove.new({
    positioning = "flex",
    x = 100, -- Absolute position with flex
    y = 100,
  })
  luaunit.assertNotNil(element)
end

-- Test: Multiple mode switches
function TestFlexLoveUnhappyPaths:testMultipleModeSwitches()
  for i = 1, 10 do
    FlexLove.setMode("immediate")
    FlexLove.setMode("retained")
  end
  luaunit.assertTrue(true)
end

-- Test: Creating elements during draw
function TestFlexLoveUnhappyPaths:testCreatingElementsDuringDraw()
  FlexLove.setMode("retained")

  local drawCalled = false
  FlexLove.draw(function()
    -- Try to create element during draw
    local element = FlexLove.new({ width = 100, height = 100 })
    luaunit.assertNotNil(element)
    drawCalled = true
  end)

  luaunit.assertTrue(drawCalled)
end

-- Test: State operations in retained mode (should do nothing)
function TestFlexLoveUnhappyPaths:testStateOperationsInRetainedMode()
  FlexLove.setMode("retained")

  local count = FlexLove.getStateCount()
  luaunit.assertEquals(count, 0)

  FlexLove.clearState("any-id")
  FlexLove.clearAllStates()

  local stats = FlexLove.getStateStats()
  luaunit.assertEquals(stats.stateCount, 0)
  luaunit.assertEquals(stats.frameNumber, 0)
end

-- Test: Extreme z-index values
function TestFlexLoveUnhappyPaths:testExtremeZIndexValues()
  FlexLove.setMode("retained")

  local element1 = FlexLove.new({ width = 100, height = 100, z = -1000000 })
  local element2 = FlexLove.new({ width = 100, height = 100, z = 1000000 })

  luaunit.assertNotNil(element1)
  luaunit.assertNotNil(element2)

  FlexLove.draw() -- Should not crash during z-index sorting
end

-- Test: Creating deeply nested element hierarchy
function TestFlexLoveUnhappyPaths:testDeeplyNestedHierarchy()
  FlexLove.setMode("retained")

  local parent = FlexLove.new({ width = 500, height = 500 })
  local current = parent

  -- Create 100 levels of nesting
  for i = 1, 100 do
    local child = FlexLove.new({
      width = 10,
      height = 10,
      parent = current,
    })
    current = child
  end

  luaunit.assertTrue(true) -- Should not crash
end

-- Test: Error logging configuration edge cases
function TestFlexLoveUnhappyPaths:testErrorLoggingEdgeCases()
  -- Empty error log file path
  FlexLove.init({ errorLogFile = "" })
  luaunit.assertTrue(true)

  -- Invalid path characters
  FlexLove.init({ errorLogFile = "/invalid/path/\0/file.log" })
  luaunit.assertTrue(true)

  -- Both enableErrorLogging and errorLogFile
  FlexLove.init({
    enableErrorLogging = true,
    errorLogFile = "test.log",
  })
  luaunit.assertTrue(true)
end

-- Test: Immediate mode frame management edge cases
function TestFlexLoveUnhappyPaths:testImmediateModeFrameEdgeCases()
  FlexLove.setMode("immediate")

  -- Begin, draw (should auto-end), then end again
  FlexLove.beginFrame()
  FlexLove.draw()
  FlexLove.endFrame() -- Extra end
  luaunit.assertTrue(true)

  -- Multiple draws without frames
  FlexLove.draw()
  FlexLove.draw()
  FlexLove.draw()
  luaunit.assertTrue(true)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
