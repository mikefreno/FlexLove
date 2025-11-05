-- ====================
-- State Manager Module
-- ====================
-- Provides centralized state management for immediate mode GUI elements
-- Handles hover, pressed, disabled, and other interactive states properly
-- Manages state change events and integrates with theme components

---@class StateManager
local StateManager = {}

-- State storage: ID -> state table
local stateStore = {}
local frameNumber = 0

-- Configuration
local config = {
    stateRetentionFrames = 60, -- Keep unused state for 60 frames (~1 second at 60fps)
    maxStateEntries = 1000,    -- Maximum state entries before forced GC
}

-- State change listeners
local stateChangeListeners = {}

--- Get or create a state object for an element ID
---@param id string Element ID
---@return table state State object for the element
function StateManager.getState(id)
    if not stateStore[id] then
        stateStore[id] = {
            hover = false,
            pressed = false,
            focused = false,
            disabled = false,
            active = false,
            lastHoverFrame = 0,
            lastPressedFrame = 0,
            lastFocusFrame = 0,
            lastUpdateFrame = 0,
        }
    end
    
    return stateStore[id]
end

--- Update state for an element ID
---@param id string Element ID
---@param newState table New state values to merge
function StateManager.updateState(id, newState)
    local state = StateManager.getState(id)
    
    -- Track which properties are changing
    local changedProperties = {}
    for key, value in pairs(newState) do
        if state[key] ~= value then
            changedProperties[key] = true
        end
        state[key] = value
    end
    
    -- Track frame numbers for state changes
    if newState.hover ~= nil then
        state.lastHoverFrame = frameNumber
    end
    if newState.pressed ~= nil then
        state.lastPressedFrame = frameNumber
    end
    if newState.focused ~= nil then
        state.lastFocusFrame = frameNumber
    end
    
    -- Track last update frame
    state.lastUpdateFrame = frameNumber
    
    -- Notify listeners of state changes (if any)
    if next(changedProperties) then
        StateManager.notifyStateChange(id, changedProperties, newState)
    end
end

--- Get the current state for an element ID
---@param id string Element ID
---@return table state State object for the element
function StateManager.getCurrentState(id)
    return stateStore[id] or {}
end

--- Clear state for a specific element ID
---@param id string Element ID
function StateManager.clearState(id)
    stateStore[id] = nil
end

--- Increment frame counter (called at frame start)
function StateManager.incrementFrame()
    frameNumber = frameNumber + 1
end

--- Get current frame number
---@return number
function StateManager.getFrameNumber()
    return frameNumber
end

--- Clean up stale states (not accessed recently)
---@return number count Number of states cleaned up
function StateManager.cleanup()
    local cleanedCount = 0
    local retentionFrames = config.stateRetentionFrames

    for id, state in pairs(stateStore) do
        -- Check if state is old (no updates in last N frames)
        local lastUpdateFrame = math.max(
            state.lastHoverFrame,
            state.lastPressedFrame,
            state.lastFocusFrame,
            state.lastUpdateFrame
        )
        
        if frameNumber - lastUpdateFrame > retentionFrames then
            stateStore[id] = nil
            cleanedCount = cleanedCount + 1
        end
    end

    return cleanedCount
end

--- Force cleanup if state count exceeds maximum
---@return number count Number of states cleaned up
function StateManager.forceCleanupIfNeeded()
    local stateCount = 0
    for _ in pairs(stateStore) do
        stateCount = stateCount + 1
    end
    
    if stateCount > config.maxStateEntries then
        -- Clean up states not accessed in last 10 frames (aggressive)
        local cleanedCount = 0
        
        for id, state in pairs(stateStore) do
            local lastUpdateFrame = math.max(
                state.lastHoverFrame,
                state.lastPressedFrame,
                state.lastFocusFrame,
                state.lastUpdateFrame
            )
            
            if frameNumber - lastUpdateFrame > 10 then
                stateStore[id] = nil
                cleanedCount = cleanedCount + 1
            end
        end
        
        return cleanedCount
    end
    
    return 0
end

--- Get total number of stored states
---@return number
function StateManager.getStateCount()
    local count = 0
    for _ in pairs(stateStore) do
        count = count + 1
    end
    return count
end

--- Clear all states
function StateManager.clearAllStates()
    stateStore = {}
end

--- Configure state management
---@param newConfig {stateRetentionFrames?: number, maxStateEntries?: number}
function StateManager.configure(newConfig)
    if newConfig.stateRetentionFrames then
        config.stateRetentionFrames = newConfig.stateRetentionFrames
    end
    if newConfig.maxStateEntries then
        config.maxStateEntries = newConfig.maxStateEntries
    end
end

--- Subscribe to state change events for an element ID
---@param id string Element ID
---@param callback fun(id: string, property: string, oldValue: any, newValue: any)
function StateManager.subscribe(id, callback)
    if not stateChangeListeners[id] then
        stateChangeListeners[id] = {}
    end
    table.insert(stateChangeListeners[id], callback)
end

--- Notify listeners of a state change
---@param id string Element ID
---@param changedProperties table Properties that have changed
---@param newState table The new state values
function StateManager.notifyStateChange(id, changedProperties, newState)
    if not stateChangeListeners[id] then return end
    
    local prevState = StateManager.getCurrentState(id)
    
    for property, _ in pairs(changedProperties) do
        local oldValue = prevState[property]
        local newValue = newState[property]
        
        for _, callback in ipairs(stateChangeListeners[id]) do
            callback(id, property, oldValue, newValue)
        end
    end
end

--- Unsubscribe a listener for an element ID
---@param id string Element ID
---@param callback fun(id: string, property: string, oldValue: any, newValue: any)
function StateManager.unsubscribe(id, callback)
    if not stateChangeListeners[id] then return end
    
    for i = #stateChangeListeners[id], 1, -1 do
        if stateChangeListeners[id][i] == callback then
            table.remove(stateChangeListeners[id], i)
        end
    end
end

--- Get all listeners for debugging
---@return table
function StateManager.getListeners()
    return stateChangeListeners
end

--- Get the active state values for an element
---@param id string Element ID
---@return table state Active state values
function StateManager.getActiveState(id)
    local state = StateManager.getState(id)
    
    -- Return only the active state properties (not tracking frames)
    return {
        hover = state.hover,
        pressed = state.pressed,
        focused = state.focused,
        disabled = state.disabled,
        active = state.active,
    }
end

--- Check if an element is currently hovered
---@param id string Element ID
---@return boolean
function StateManager.isHovered(id)
    local state = StateManager.getState(id)
    return state.hover or false
end

--- Check if an element is currently pressed
---@param id string Element ID
---@return boolean
function StateManager.isPressed(id)
    local state = StateManager.getState(id)
    return state.pressed or false
end

--- Check if an element is currently focused
---@param id string Element ID
---@return boolean
function StateManager.isFocused(id)
    local state = StateManager.getState(id)
    return state.focused or false
end

--- Check if an element is disabled
---@param id string Element ID
---@return boolean
function StateManager.isDisabled(id)
    local state = StateManager.getState(id)
    return state.disabled or false
end

--- Check if an element is active (e.g., input focused)
---@param id string Element ID
---@return boolean
function StateManager.isActive(id)
    local state = StateManager.getState(id)
    return state.active or false
end

--- Get the time since last hover event for an element
---@param id string Element ID
---@return number secondsSinceLastHover
function StateManager.getSecondsSinceLastHover(id)
    local state = StateManager.getState(id)
    return (frameNumber - state.lastHoverFrame) / 60 -- Assuming 60fps
end

--- Get the time since last press event for an element
---@param id string Element ID
---@return number secondsSinceLastPress
function StateManager.getSecondsSinceLastPress(id)
    local state = StateManager.getState(id)
    return (frameNumber - state.lastPressedFrame) / 60 -- Assuming 60fps
end

return StateManager