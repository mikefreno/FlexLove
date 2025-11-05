-- ====================
-- Immediate Mode State Module
-- ====================
-- ID-based state persistence system for immediate mode rendering
-- Stores element state externally to persist across frame recreation

---@class ImmediateModeState
local ImmediateModeState = {}

-- State storage: ID -> state table
local stateStore = {}

-- Frame tracking metadata
local frameNumber = 0
local stateMetadata = {} -- ID -> {lastFrame, createdFrame, accessCount}

-- Configuration
local config = {
  stateRetentionFrames = 60, -- Keep unused state for 60 frames (~1 second at 60fps)
  maxStateEntries = 1000,    -- Maximum state entries before forced GC
}

--- Generate a hash from a table of properties
---@param props table
---@param visited table|nil Tracking table to prevent circular references
---@param depth number|nil Current recursion depth
---@return string
local function hashProps(props, visited, depth)
  if not props then return "" end

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
    callback = true,
    parent = true,
    children = true,
    onFocus = true,
    onBlur = true,
    onTextInput = true,
    onTextChange = true,
    onEnter = true,
    userdata = true,
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

-- Counter to track multiple elements created at the same source location (e.g., in loops)
local callSiteCounters = {} -- {source_line -> counter}

--- Generate a unique ID from call site and properties
---@param props table|nil Optional properties to include in ID generation
---@return string
function ImmediateModeState.generateID(props)
  -- Get call stack information
  local info = debug.getinfo(3, "Sl") -- Level 3: caller of Element.new -> caller of generateID

  if not info then
    -- Fallback to random ID if debug info unavailable
    return "auto_" .. tostring(math.random(1000000, 9999999))
  end

  local source = info.source or "unknown"
  local line = info.currentline or 0

  -- Create ID from source file and line number
  local baseID = source:match("([^/\\]+)$") or source -- Get filename
  baseID = baseID:gsub("%.lua$", "") -- Remove .lua extension
  local locationKey = baseID .. "_L" .. line
  
  -- Track how many elements have been created at this location
  callSiteCounters[locationKey] = (callSiteCounters[locationKey] or 0) + 1
  local instanceNum = callSiteCounters[locationKey]
  
  baseID = locationKey
  
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

--- Get state for an element ID, creating if it doesn't exist
---@param id string Element ID
---@param defaultState table|nil Default state if creating new
---@return table state State table for the element
function ImmediateModeState.getState(id, defaultState)
  if not id then
    error("ImmediateModeState.getState: id is required")
  end

  -- Create state if it doesn't exist
  if not stateStore[id] then
    stateStore[id] = defaultState or {}
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

--- Set state for an element ID
---@param id string Element ID
---@param state table State to store
function ImmediateModeState.setState(id, state)
  if not id then
    error("ImmediateModeState.setState: id is required")
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

--- Clear state for a specific element ID
---@param id string Element ID
function ImmediateModeState.clearState(id)
  stateStore[id] = nil
  stateMetadata[id] = nil
end

--- Mark state as used this frame (updates last accessed frame)
---@param id string Element ID
function ImmediateModeState.markStateUsed(id)
  if stateMetadata[id] then
    stateMetadata[id].lastFrame = frameNumber
  end
end

--- Get the last frame number when state was accessed
---@param id string Element ID
---@return number|nil frameNumber Last accessed frame, or nil if not found
function ImmediateModeState.getLastAccessedFrame(id)
  if stateMetadata[id] then
    return stateMetadata[id].lastFrame
  end
  return nil
end

--- Increment frame counter (called at frame start)
function ImmediateModeState.incrementFrame()
  frameNumber = frameNumber + 1
  -- Reset call site counters for new frame
  callSiteCounters = {}
end

--- Get current frame number
---@return number
function ImmediateModeState.getFrameNumber()
  return frameNumber
end

--- Clean up stale states (not accessed recently)
---@return number count Number of states cleaned up
function ImmediateModeState.cleanup()
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
function ImmediateModeState.forceCleanupIfNeeded()
  local stateCount = ImmediateModeState.getStateCount()

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
function ImmediateModeState.getStateCount()
  local count = 0
  for _ in pairs(stateStore) do
    count = count + 1
  end
  return count
end

--- Clear all states
function ImmediateModeState.clearAllStates()
  stateStore = {}
  stateMetadata = {}
end

--- Configure state management
---@param newConfig {stateRetentionFrames?: number, maxStateEntries?: number}
function ImmediateModeState.configure(newConfig)
  if newConfig.stateRetentionFrames then
    config.stateRetentionFrames = newConfig.stateRetentionFrames
  end
  if newConfig.maxStateEntries then
    config.maxStateEntries = newConfig.maxStateEntries
  end
end

--- Get state statistics for debugging
---@return {stateCount: number, frameNumber: number, oldestState: number|nil, newestState: number|nil}
function ImmediateModeState.getStats()
  local stateCount = ImmediateModeState.getStateCount()
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

  return {
    stateCount = stateCount,
    frameNumber = frameNumber,
    oldestState = oldest,
    newestState = newest,
  }
end

--- Dump all states for debugging
---@return table states Copy of all states with metadata
function ImmediateModeState.dumpStates()
  local dump = {}

  for id, state in pairs(stateStore) do
    dump[id] = {
      state = state,
      metadata = stateMetadata[id],
    }
  end

  return dump
end

--- Reset the entire state system (for testing)
function ImmediateModeState.reset()
  stateStore = {}
  stateMetadata = {}
  frameNumber = 0
  callSiteCounters = {}
end

return ImmediateModeState
