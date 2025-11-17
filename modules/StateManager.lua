---@class StateManager
local StateManager = {}

-- Load error handler (loaded lazily since it's in a sibling module)
local ErrorHandler

-- State storage: ID -> state table
local stateStore = {}

-- Frame tracking metadata: ID -> {lastFrame, createdFrame, accessCount}
local stateMetadata = {}

-- Frame counter
local frameNumber = 0

-- Counter to track multiple elements created at the same source location (e.g., in loops)
local callSiteCounters = {}

-- Configuration
local config = {
  stateRetentionFrames = 60, -- Keep unused state for 60 frames (~1 second at 60fps)
  maxStateEntries = 1000, -- Maximum state entries before forced GC
}

-- ====================
-- ID Generation
-- ====================

--- Generate a hash from a table of properties
---@param props table
---@param visited table|nil Tracking table to prevent circular references
---@param depth number|nil Current recursion depth
---@return string
local function hashProps(props, visited, depth)
  if not props then
    return ""
  end

  -- Initialize visited table on first call
  visited = visited or {}
  depth = depth or 0

  -- Limit recursion depth to prevent deep nesting issues
  if depth > 3 then
    return "[deep]"
  end

  -- Check if we've already visited this table (circular reference)
  if visited[props] then
    return "[circular]"
  end

  -- Mark this table as visited
  visited[props] = true

  local parts = {}
  local keys = {}

  -- Properties to skip (they cause issues or aren't relevant for ID generation)
  local skipKeys = {
    onEvent = true,
    parent = true,
    children = true,
    onFocus = true,
    onBlur = true,
    onTextInput = true,
    onTextChange = true,
    onEnter = true,
    userdata = true,
    -- Dynamic input/state properties that should not affect ID stability
    text = true, -- Text content changes as user types
    placeholder = true, -- Placeholder text is presentational
    editable = true, -- Editable state can be toggled dynamically
    selectOnFocus = true, -- Input behavior flag
    autoGrow = true, -- Auto-grow behavior flag
    passwordMode = true, -- Password mode can be toggled
  }

  -- Collect and sort keys for consistent ordering
  for k in pairs(props) do
    if not skipKeys[k] then
      table.insert(keys, k)
    end
  end
  table.sort(keys)

  -- Build hash string from sorted key-value pairs
  for _, k in ipairs(keys) do
    local v = props[k]
    local vtype = type(v)

    if vtype == "string" or vtype == "number" or vtype == "boolean" then
      table.insert(parts, k .. "=" .. tostring(v))
    elseif vtype == "table" then
      table.insert(parts, k .. "={" .. hashProps(v, visited, depth + 1) .. "}")
    end
  end

  return table.concat(parts, ";")
end

--- Generate a unique ID from call site and properties
---@param props table|nil Optional properties to include in ID generation
---@param parent table|nil Optional parent element for tree-based ID generation
---@return string
function StateManager.generateID(props, parent)
  -- Get call stack information
  local info = debug.getinfo(3, "Sl") -- Level 3: caller of Element.new -> caller of generateID

  if not info then
    -- Fallback to random ID if debug info unavailable
    return "auto_" .. tostring(math.random(1000000, 9999999))
  end

  local source = info.source or "unknown"
  local line = info.currentline or 0

  -- Create base location key from source file and line number
  local filename = source:match("([^/\\]+)$") or source -- Get filename
  filename = filename:gsub("%.lua$", "") -- Remove .lua extension
  local locationKey = filename .. "_L" .. line

  -- If we have a parent, use tree-based ID generation for stability
  if parent and parent.id and parent.id ~= "" then
    -- Count how many children the parent currently has
    -- This gives us a stable sibling index
    local siblingIndex = #(parent.children or {})

    -- Generate ID based on parent ID + sibling position (NO line number for stability)
    -- This ensures the same position in the tree always gets the same ID
    local baseID = parent.id .. "_child" .. siblingIndex

    -- Add property hash if provided (for additional differentiation at same position)
    if props then
      local propHash = hashProps(props)
      if propHash ~= "" then
        -- Use first 8 chars of a simple hash
        local hash = 0
        for i = 1, #propHash do
          hash = (hash * 31 + string.byte(propHash, i)) % 1000000
        end
        baseID = baseID .. "_" .. hash
      end
    end

    return baseID
  end

  -- No parent (top-level element): use call-site counter approach
  -- Track how many elements have been created at this location
  callSiteCounters[locationKey] = (callSiteCounters[locationKey] or 0) + 1
  local instanceNum = callSiteCounters[locationKey]

  local baseID = locationKey

  -- Add instance number if multiple elements created at same location (e.g., in loops)
  if instanceNum > 1 then
    baseID = baseID .. "_" .. instanceNum
  end

  -- Add property hash if provided (for additional differentiation)
  if props then
    local propHash = hashProps(props)
    if propHash ~= "" then
      -- Use first 8 chars of a simple hash
      local hash = 0
      for i = 1, #propHash do
        hash = (hash * 31 + string.byte(propHash, i)) % 1000000
      end
      baseID = baseID .. "_" .. hash
    end
  end

  return baseID
end

-- ====================
-- State Management
-- ====================

--- Get state for an element ID, creating if it doesn't exist
---@param id string Element ID
---@param defaultState table|nil Default state if creating new
---@return table state State table for the element
function StateManager.getState(id, defaultState)
  if not id then
    -- Lazy load ErrorHandler
    if not ErrorHandler then
      ErrorHandler = require("modules.ErrorHandler")
    end
    ErrorHandler.error("StateManager", "SYS_001", "Invalid state ID", {
      parameter = "id",
      value = "nil"
    }, "Provide a valid non-nil ID string to getState()")
  end

  -- Create state if it doesn't exist
  if not stateStore[id] then
    -- Merge default state with standard structure
    stateStore[id] = defaultState or {}

    -- Ensure all standard properties exist with defaults
    local state = stateStore[id]

    -- Interaction states
    if state.hover == nil then
      state.hover = false
    end
    if state.pressed == nil then
      state.pressed = false
    end
    if state.focused == nil then
      state.focused = false
    end
    if state.disabled == nil then
      state.disabled = false
    end
    if state.active == nil then
      state.active = false
    end

    -- Scrollbar states
    if state.scrollbarHoveredVertical == nil then
      state.scrollbarHoveredVertical = false
    end
    if state.scrollbarHoveredHorizontal == nil then
      state.scrollbarHoveredHorizontal = false
    end
    if state.scrollbarDragging == nil then
      state.scrollbarDragging = false
    end
    if state.hoveredScrollbar == nil then
      state.hoveredScrollbar = nil
    end
    if state.scrollbarDragOffset == nil then
      state.scrollbarDragOffset = 0
    end

    -- Scroll position
    if state.scrollX == nil then
      state.scrollX = 0
    end
    if state.scrollY == nil then
      state.scrollY = 0
    end

    -- Click tracking
    if state._pressed == nil then
      state._pressed = {}
    end
    if state._lastClickTime == nil then
      state._lastClickTime = nil
    end
    if state._lastClickButton == nil then
      state._lastClickButton = nil
    end
    if state._clickCount == nil then
      state._clickCount = 0
    end

    -- Drag tracking
    if state._dragStartX == nil then
      state._dragStartX = {}
    end
    if state._dragStartY == nil then
      state._dragStartY = {}
    end
    if state._lastMouseX == nil then
      state._lastMouseX = {}
    end
    if state._lastMouseY == nil then
      state._lastMouseY = {}
    end

    -- Input/focus state
    if state._hovered == nil then
      state._hovered = nil
    end
    if state._focused == nil then
      state._focused = nil
    end
    if state._cursorPosition == nil then
      state._cursorPosition = nil
    end
    if state._selectionStart == nil then
      state._selectionStart = nil
    end
    if state._selectionEnd == nil then
      state._selectionEnd = nil
    end
    if state._textBuffer == nil then
      state._textBuffer = ""
    end

    -- Create metadata
    stateMetadata[id] = {
      lastFrame = frameNumber,
      createdFrame = frameNumber,
      accessCount = 0,
    }
  end

  -- Update metadata
  local meta = stateMetadata[id]
  meta.lastFrame = frameNumber
  meta.accessCount = meta.accessCount + 1

  return stateStore[id]
end

--- Set state for an element ID (replaces entire state)
---@param id string Element ID
---@param state table State to store
function StateManager.setState(id, state)
  if not id then
    -- Lazy load ErrorHandler
    if not ErrorHandler then
      ErrorHandler = require("modules.ErrorHandler")
    end
    ErrorHandler.error("StateManager", "SYS_001", "Invalid state ID", {
      parameter = "id",
      value = "nil"
    }, "Provide a valid non-nil ID string to setState()")
  end

  stateStore[id] = state

  -- Update or create metadata
  if not stateMetadata[id] then
    stateMetadata[id] = {
      lastFrame = frameNumber,
      createdFrame = frameNumber,
      accessCount = 1,
    }
  else
    stateMetadata[id].lastFrame = frameNumber
  end
end

--- Update state for an element ID (merges with existing state)
---@param id string Element ID
---@param newState table New state values to merge
function StateManager.updateState(id, newState)
  local state = StateManager.getState(id)

  -- Merge new state into existing state
  for key, value in pairs(newState) do
    state[key] = value
  end

  -- Update metadata
  stateMetadata[id].lastFrame = frameNumber
end

--- Clear state for a specific element ID
---@param id string Element ID
function StateManager.clearState(id)
  stateStore[id] = nil
  stateMetadata[id] = nil
end

--- Mark state as used this frame (updates last accessed frame)
---@param id string Element ID
function StateManager.markStateUsed(id)
  if stateMetadata[id] then
    stateMetadata[id].lastFrame = frameNumber
  end
end

--- Get the last frame number when state was accessed
---@param id string Element ID
---@return number|nil frameNumber Last accessed frame, or nil if not found
function StateManager.getLastAccessedFrame(id)
  if stateMetadata[id] then
    return stateMetadata[id].lastFrame
  end
  return nil
end

-- ====================
-- Frame Management
-- ====================

--- Increment frame counter (called at frame start)
function StateManager.incrementFrame()
  frameNumber = frameNumber + 1
  -- Reset call site counters for new frame
  callSiteCounters = {}
end

--- Get current frame number
---@return number
function StateManager.getFrameNumber()
  return frameNumber
end

-- ====================
-- Cleanup & Maintenance
-- ====================

--- Clean up stale states (not accessed recently)
---@return number count Number of states cleaned up
function StateManager.cleanup()
  local cleanedCount = 0
  local retentionFrames = config.stateRetentionFrames

  for id, meta in pairs(stateMetadata) do
    local framesSinceAccess = frameNumber - meta.lastFrame

    if framesSinceAccess > retentionFrames then
      stateStore[id] = nil
      stateMetadata[id] = nil
      cleanedCount = cleanedCount + 1
    end
  end

  return cleanedCount
end

--- Force cleanup if state count exceeds maximum
---@return number count Number of states cleaned up
function StateManager.forceCleanupIfNeeded()
  local stateCount = StateManager.getStateCount()

  if stateCount > config.maxStateEntries then
    -- Clean up states not accessed in last 10 frames (aggressive)
    local cleanedCount = 0

    for id, meta in pairs(stateMetadata) do
      local framesSinceAccess = frameNumber - meta.lastFrame

      if framesSinceAccess > 10 then
        stateStore[id] = nil
        stateMetadata[id] = nil
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
  stateMetadata = {}
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

--- Get state statistics for debugging
---@return table stats State usage statistics
function StateManager.getStats()
  local stateCount = StateManager.getStateCount()
  local oldest = nil
  local newest = nil

  for _, meta in pairs(stateMetadata) do
    if not oldest or meta.createdFrame < oldest then
      oldest = meta.createdFrame
    end
    if not newest or meta.createdFrame > newest then
      newest = meta.createdFrame
    end
  end

  -- Count callSiteCounters
  local callSiteCount = 0
  for _ in pairs(callSiteCounters) do
    callSiteCount = callSiteCount + 1
  end

  -- Warn if callSiteCounters is unexpectedly large
  if callSiteCount > 1000 then
    if ErrorHandler then
      local message = string.format("callSiteCounters has %d entries (expected near 0 per frame)", callSiteCount)
      ErrorHandler.warn("StateManager", "STATE_001", message, {
        count = callSiteCount,
        expected = "near 0",
        frameNumber = frameNumber,
      }, "This indicates incrementFrame() may not be called properly or counters aren't being reset. Check immediate mode frame management.")
    else
      print(string.format("[StateManager] WARNING: callSiteCounters has %d entries", callSiteCount))
    end
  end

  return {
    stateCount = stateCount,
    frameNumber = frameNumber,
    oldestState = oldest,
    newestState = newest,
    callSiteCounterCount = callSiteCount,
  }
end

--- Dump all states for debugging
---@return table states Copy of all states with metadata
function StateManager.dumpStates()
  local dump = {}

  for id, state in pairs(stateStore) do
    dump[id] = {
      state = state,
      metadata = stateMetadata[id],
    }
  end

  return dump
end

--- Get internal state (for debugging/profiling only)
---@return table internal {stateStore, stateMetadata, callSiteCounters}
function StateManager._getInternalState()
  return {
    stateStore = stateStore,
    stateMetadata = stateMetadata,
    callSiteCounters = callSiteCounters,
  }
end

--- Reset the entire state system (for testing)
function StateManager.reset()
  stateStore = {}
  stateMetadata = {}
  frameNumber = 0
  callSiteCounters = {}
end

-- ====================
-- Convenience Functions (for backward compatibility)
-- ====================

--- Get the current state for an element ID (alias for getState)
---@param id string Element ID
---@return table state State object for the element
function StateManager.getCurrentState(id)
  return stateStore[id] or {}
end

--- Get the active state values for an element (interaction states only)
---@param id string Element ID
---@return table state Active state values
function StateManager.getActiveState(id)
  local state = StateManager.getState(id)

  -- Return only the active state properties (not tracking frames or internal state)
  return {
    hover = state.hover,
    pressed = state.pressed,
    focused = state.focused,
    disabled = state.disabled,
    active = state.active,
    scrollbarHoveredVertical = state.scrollbarHoveredVertical,
    scrollbarHoveredHorizontal = state.scrollbarHoveredHorizontal,
    scrollbarDragging = state.scrollbarDragging,
    hoveredScrollbar = state.hoveredScrollbar,
    scrollbarDragOffset = state.scrollbarDragOffset,
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

return StateManager
