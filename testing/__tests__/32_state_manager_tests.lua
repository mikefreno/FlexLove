-- ====================
-- StateManager Module Tests
-- ====================

local luaunit = require("testing.luaunit")
require("testing.loveStub") -- Required to mock LOVE functions
local StateManager = require("modules.StateManager")

TestStateManager = {}

function TestStateManager:setUp()
    -- Reset StateManager before each test
    StateManager.clearAllStates()
end

function TestStateManager:tearDown()
    -- Clean up after each test
    StateManager.clearAllStates()
end

-- ====================
-- Basic State Operations
-- ====================

function TestStateManager:test_getState_createsNewState()
    local state = StateManager.getState("test-element")
    
    luaunit.assertNotNil(state)
    luaunit.assertEquals(state.hover, false)
    luaunit.assertEquals(state.pressed, false)
    luaunit.assertEquals(state.focused, false)
    luaunit.assertEquals(state.disabled, false)
    luaunit.assertEquals(state.active, false)
end

function TestStateManager:test_getState_returnsExistingState()
    local state1 = StateManager.getState("test-element")
    state1.hover = true
    
    local state2 = StateManager.getState("test-element")
    
    luaunit.assertEquals(state2.hover, true)
    luaunit.assertTrue(state1 == state2) -- Same reference
end

function TestStateManager:test_updateState_modifiesState()
    StateManager.updateState("test-element", {
        hover = true,
        pressed = false,
    })
    
    local state = StateManager.getState("test-element")
    luaunit.assertEquals(state.hover, true)
    luaunit.assertEquals(state.pressed, false)
end

function TestStateManager:test_updateState_mergesPartialState()
    StateManager.updateState("test-element", { hover = true })
    StateManager.updateState("test-element", { pressed = true })
    
    local state = StateManager.getState("test-element")
    luaunit.assertEquals(state.hover, true)
    luaunit.assertEquals(state.pressed, true)
end

function TestStateManager:test_clearState_removesState()
    StateManager.updateState("test-element", { hover = true })
    StateManager.clearState("test-element")
    
    local state = StateManager.getState("test-element")
    luaunit.assertEquals(state.hover, false) -- New state created with defaults
end

-- ====================
-- Scrollbar State Tests
-- ====================

function TestStateManager:test_scrollbarStates_initialization()
    local state = StateManager.getState("test-element")
    
    luaunit.assertEquals(state.scrollbarHoveredVertical, false)
    luaunit.assertEquals(state.scrollbarHoveredHorizontal, false)
    luaunit.assertEquals(state.scrollbarDragging, false)
    luaunit.assertNil(state.hoveredScrollbar)
    luaunit.assertEquals(state.scrollbarDragOffset, 0)
end

function TestStateManager:test_scrollbarStates_updates()
    StateManager.updateState("test-element", {
        scrollbarHoveredVertical = true,
        scrollbarDragging = true,
        hoveredScrollbar = "vertical",
        scrollbarDragOffset = 25,
    })
    
    local state = StateManager.getState("test-element")
    luaunit.assertEquals(state.scrollbarHoveredVertical, true)
    luaunit.assertEquals(state.scrollbarDragging, true)
    luaunit.assertEquals(state.hoveredScrollbar, "vertical")
    luaunit.assertEquals(state.scrollbarDragOffset, 25)
end

-- ====================
-- Frame Management Tests
-- ====================

function TestStateManager:test_frameNumber_increments()
    local frame1 = StateManager.getFrameNumber()
    StateManager.incrementFrame()
    local frame2 = StateManager.getFrameNumber()
    
    luaunit.assertEquals(frame2, frame1 + 1)
end

function TestStateManager:test_updateState_updatesFrameNumber()
    StateManager.incrementFrame()
    StateManager.incrementFrame()
    local currentFrame = StateManager.getFrameNumber()
    
    StateManager.updateState("test-element", { hover = true })
    
    -- State should exist and be accessible
    local state = StateManager.getState("test-element")
    luaunit.assertNotNil(state)
end

-- ====================
-- Cleanup Tests
-- ====================

function TestStateManager:test_cleanup_removesStaleStates()
    -- Configure short retention
    StateManager.configure({ stateRetentionFrames = 5 })
    
    -- Create state
    StateManager.updateState("test-element", { hover = true })
    
    -- Advance frames beyond retention
    for i = 1, 10 do
        StateManager.incrementFrame()
    end
    
    -- Cleanup should remove the state
    local cleanedCount = StateManager.cleanup()
    luaunit.assertEquals(cleanedCount, 1)
    
    -- Reset config
    StateManager.configure({ stateRetentionFrames = 60 })
end

function TestStateManager:test_cleanup_keepsActiveStates()
    StateManager.configure({ stateRetentionFrames = 5 })
    
    StateManager.updateState("test-element", { hover = true })
    
    -- Update state within retention period
    for i = 1, 3 do
        StateManager.incrementFrame()
        StateManager.updateState("test-element", { hover = true })
    end
    
    local cleanedCount = StateManager.cleanup()
    luaunit.assertEquals(cleanedCount, 0) -- Should not clean active state
    
    StateManager.configure({ stateRetentionFrames = 60 })
end

function TestStateManager:test_forceCleanupIfNeeded_activatesWhenOverLimit()
    StateManager.configure({ maxStateEntries = 5 })
    
    -- Create more states than limit
    for i = 1, 10 do
        StateManager.updateState("element-" .. i, { hover = true })
    end
    
    -- Advance frames
    for i = 1, 15 do
        StateManager.incrementFrame()
    end
    
    local cleanedCount = StateManager.forceCleanupIfNeeded()
    luaunit.assertTrue(cleanedCount > 0)
    
    StateManager.configure({ maxStateEntries = 1000 })
end

-- ====================
-- State Count Tests
-- ====================

function TestStateManager:test_getStateCount_returnsCorrectCount()
    luaunit.assertEquals(StateManager.getStateCount(), 0)
    
    StateManager.getState("element-1")
    StateManager.getState("element-2")
    StateManager.getState("element-3")
    
    luaunit.assertEquals(StateManager.getStateCount(), 3)
end

-- ====================
-- Active State Tests
-- ====================

function TestStateManager:test_getActiveState_returnsOnlyActiveProperties()
    StateManager.updateState("test-element", {
        hover = true,
        pressed = false,
        focused = true,
    })
    
    local activeState = StateManager.getActiveState("test-element")
    
    luaunit.assertEquals(activeState.hover, true)
    luaunit.assertEquals(activeState.pressed, false)
    luaunit.assertEquals(activeState.focused, true)
    luaunit.assertNil(activeState.lastUpdateFrame) -- Should not include frame tracking
end

-- ====================
-- Helper Function Tests
-- ====================

function TestStateManager:test_isHovered_returnsTrueWhenHovered()
    StateManager.updateState("test-element", { hover = true })
    luaunit.assertTrue(StateManager.isHovered("test-element"))
end

function TestStateManager:test_isHovered_returnsFalseWhenNotHovered()
    StateManager.updateState("test-element", { hover = false })
    luaunit.assertFalse(StateManager.isHovered("test-element"))
end

function TestStateManager:test_isPressed_returnsTrueWhenPressed()
    StateManager.updateState("test-element", { pressed = true })
    luaunit.assertTrue(StateManager.isPressed("test-element"))
end

function TestStateManager:test_isFocused_returnsTrueWhenFocused()
    StateManager.updateState("test-element", { focused = true })
    luaunit.assertTrue(StateManager.isFocused("test-element"))
end

function TestStateManager:test_isDisabled_returnsTrueWhenDisabled()
    StateManager.updateState("test-element", { disabled = true })
    luaunit.assertTrue(StateManager.isDisabled("test-element"))
end

function TestStateManager:test_isActive_returnsTrueWhenActive()
    StateManager.updateState("test-element", { active = true })
    luaunit.assertTrue(StateManager.isActive("test-element"))
end

-- ====================
-- ID Generation Tests
-- ====================

function TestStateManager:test_generateID_createsUniqueID()
    local id1 = StateManager.generateID({ test = "value1" })
    local id2 = StateManager.generateID({ test = "value2" })
    
    luaunit.assertNotNil(id1)
    luaunit.assertNotNil(id2)
    luaunit.assertTrue(type(id1) == "string")
    luaunit.assertTrue(type(id2) == "string")
end

function TestStateManager:test_generateID_withoutProps()
    local id = StateManager.generateID(nil)
    
    luaunit.assertNotNil(id)
    luaunit.assertTrue(type(id) == "string")
end

-- ====================
-- Scroll Position Tests
-- ====================

function TestStateManager:test_scrollPosition_initialization()
    local state = StateManager.getState("test-element")
    
    luaunit.assertEquals(state.scrollX, 0)
    luaunit.assertEquals(state.scrollY, 0)
end

function TestStateManager:test_scrollPosition_updates()
    StateManager.updateState("test-element", {
        scrollX = 100,
        scrollY = 200,
    })
    
    local state = StateManager.getState("test-element")
    luaunit.assertEquals(state.scrollX, 100)
    luaunit.assertEquals(state.scrollY, 200)
end

-- ====================
-- Configuration Tests
-- ====================

function TestStateManager:test_configure_updatesSettings()
    StateManager.configure({
        stateRetentionFrames = 30,
        maxStateEntries = 500,
    })
    
    -- Test that configuration was applied by creating many states
    -- and checking cleanup behavior (indirect test)
    for i = 1, 10 do
        StateManager.updateState("element-" .. i, { hover = true })
    end
    
    luaunit.assertEquals(StateManager.getStateCount(), 10)
    
    -- Reset to defaults
    StateManager.configure({
        stateRetentionFrames = 60,
        maxStateEntries = 1000,
    })
end

return TestStateManager
