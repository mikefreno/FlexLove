local modulePath = (...):match("(.-)[^%.]+$") -- Get the module path prefix (e.g., "libs." or "")
local function req(name)
  return require(modulePath .. "modules." .. name)
end

-- internals
local Blur = req("Blur")
local utils = req("utils")
local Units = req("Units")
local Context = req("Context")
---@type StateManager
local StateManager = req("StateManager")
local Performance = req("Performance")
local ImageRenderer = req("ImageRenderer")
local ImageScaler = req("ImageScaler")
local NinePatch = req("NinePatch")
local RoundedRect = req("RoundedRect")
local ImageCache = req("ImageCache")
local Grid = req("Grid")
local InputEvent = req("InputEvent")
local GestureRecognizer = req("GestureRecognizer")
local TextEditor = req("TextEditor")
local LayoutEngine = req("LayoutEngine")
local Renderer = req("Renderer")
local EventHandler = req("EventHandler")
local ScrollManager = req("ScrollManager")
local ImageDataReader = req("ImageDataReader")
---@type ErrorHandler
local ErrorHandler = req("ErrorHandler")
---@type Element
local Element = req("Element")

-- externals
---@type Animation
local Animation = req("Animation")
---@type Color
local Color = req("Color")
---@type Theme
local Theme = req("Theme")
local enums = utils.enums

---@class FlexLove
local flexlove = Context
flexlove._VERSION = "0.3.0"
flexlove._DESCRIPTION = "UI Library for LÖVE Framework based on flexbox"
flexlove._URL = "https://github.com/mikefreno/FlexLove"
flexlove._LICENSE = [[
  MIT License

  Copyright (c) 2025 Mike Freno

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
]]

-- GC (Garbage Collection) configuration
flexlove._gcConfig = {
  strategy = "auto", -- "auto", "periodic", "manual", "disabled"
  memoryThreshold = 100, -- MB before forcing GC
  interval = 60, -- Frames between GC steps (for periodic mode)
  stepSize = 200, -- Work units per GC step (higher = more aggressive)
}
flexlove._gcState = {
  framesSinceLastGC = 0,
  lastMemory = 0,
  gcCount = 0,
}

-- Deferred callback queue for operations that cannot run while Canvas is active
flexlove._deferredCallbacks = {}

--- Set up FlexLove for your application's specific needs - configure responsive scaling, theming, rendering mode, and debugging tools
--- Use this to establish a consistent UI foundation that adapts to different screen sizes and provides performance insights
---@param config {baseScale?: {width?:number, height?:number}, theme?: string|ThemeDefinition, immediateMode?: boolean, stateRetentionFrames?: number, maxStateEntries?: number, autoFrameManagement?: boolean, errorLogFile?: string, enableErrorLogging?: boolean, performanceMonitoring?: boolean, performanceWarnings?: boolean, performanceHudKey?: string, performanceHudPosition?: {x: number, y: number} }
function flexlove.init(config)
  config = config or {}

  flexlove._ErrorHandler = ErrorHandler.init({
    includeStackTrace = config.includeStackTrace,
    logLevel = config.reportingLogLevel,
    logTarget = config.errorLogTarget,
    logFile = config.errorLogFile,
    maxLogSize = config.errorLogMaxSize,
    maxLogFiles = config.maxErrorLogFiles,
    enableRotation = config.errorLogRotateEnabled,
  })

  ImageRenderer.init({ ErrorHandler = flexlove._ErrorHandler })

  ImageScaler.init({ ErrorHandler = flexlove._ErrorHandler })

  NinePatch.init({ ErrorHandler = flexlove._ErrorHandler })
  ImageDataReader.init({ ErrorHandler = flexlove._ErrorHandler })

  Units.init({ Context = Context, ErrorHandler = flexlove._ErrorHandler })
  Color.init({ ErrorHandler = flexlove._ErrorHandler })
  utils.init({ ErrorHandler = flexlove._ErrorHandler })
  Animation.init({ ErrorHandler = flexlove._ErrorHandler, Color = Color })

  flexlove._defaultDependencies = {
    Context = Context,
    Theme = Theme,
    Color = Color,
    Units = Units,
    Blur = Blur,
    ImageRenderer = ImageRenderer,
    ImageScaler = ImageScaler,
    NinePatch = NinePatch,
    RoundedRect = RoundedRect,
    ImageCache = ImageCache,
    utils = utils,
    Grid = Grid,
    InputEvent = InputEvent,
    GestureRecognizer = GestureRecognizer,
    StateManager = StateManager,
    TextEditor = TextEditor,
    LayoutEngine = LayoutEngine,
    Renderer = Renderer,
    EventHandler = EventHandler,
    ScrollManager = ScrollManager,
    ErrorHandler = flexlove._ErrorHandler,
  }

  local enablePerfMonitoring = config.performanceMonitoring
  if enablePerfMonitoring == nil then
    enablePerfMonitoring = true
  end
  if enablePerfMonitoring then
    Performance.enable()
  else
    Performance.disable()
  end

  local enablePerfWarnings = config.performanceWarnings or true

  Performance.setConfig("warningsEnabled", enablePerfWarnings)
  if enablePerfWarnings then
    Performance.setConfig("logWarnings", true)
  end

  -- Configure performance HUD toggle key (default: "f3")
  if config.performanceHudKey then
    Performance.setConfig("hudToggleKey", config.performanceHudKey)
  end

  -- Configure performance HUD position (default: {x = 10, y = 10})
  if config.performanceHudPosition then
    Performance.setConfig("hudPosition", config.performanceHudPosition)
  end

  -- Configure memory profiling (default: false)
  if config.memoryProfiling then
    Performance.enableMemoryProfiling()
    -- Register key tables for leak detection
    Performance.registerTableForMonitoring("StateManager.stateStore", StateManager._getInternalState().stateStore)
    Performance.registerTableForMonitoring("StateManager.stateMetadata", StateManager._getInternalState().stateMetadata)
    Performance.registerTableForMonitoring("FONT_CACHE", utils.FONT_CACHE)
  end

  if config.baseScale then
    flexlove.baseScale = {
      width = config.baseScale.width or 1920,
      height = config.baseScale.height or 1080,
    }

    local currentWidth, currentHeight = Units.getViewport()
    flexlove.scaleFactors.x = currentWidth / flexlove.baseScale.width
    flexlove.scaleFactors.y = currentHeight / flexlove.baseScale.height
  end

  if config.theme then
    local success, err = pcall(function()
      if type(config.theme) == "string" then
        Theme.load(config.theme)
        Theme.setActive(config.theme)
        flexlove.defaultTheme = config.theme
      elseif type(config.theme) == "table" then
        local theme = Theme.new(config.theme)
        Theme.setActive(theme)
        flexlove.defaultTheme = theme.name
      end
    end)

    if not success then
      print("[FlexLove] Failed to load theme: " .. tostring(err))
    end
  end

  local immediateMode = config.immediateMode or false
  flexlove.setMode(immediateMode and "immediate" or "retained")

  flexlove._autoFrameManagement = config.autoFrameManagement or false

  -- Configure GC strategy
  if config.gcStrategy then
    flexlove._gcConfig.strategy = config.gcStrategy
  end
  if config.gcMemoryThreshold then
    flexlove._gcConfig.memoryThreshold = config.gcMemoryThreshold
  end
  if config.gcInterval then
    flexlove._gcConfig.interval = config.gcInterval
  end
  if config.gcStepSize then
    flexlove._gcConfig.stepSize = config.gcStepSize
  end

  if config.stateRetentionFrames or config.maxStateEntries then
    StateManager.configure({
      stateRetentionFrames = config.stateRetentionFrames,
      maxStateEntries = config.maxStateEntries,
    })
  end
end

--- Safely schedule operations that modify LÖVE's rendering state (like window mode changes) to execute after all canvas operations complete
--- Prevents crashes from attempting canvas-incompatible operations during rendering
---@param callback function The callback to execute
function flexlove.deferCallback(callback)
  if type(callback) ~= "function" then
    ErrorHandler.warn("FlexLove", "deferCallback expects a function")
    return
  end
  table.insert(flexlove._deferredCallbacks, callback)
end

--- Execute deferred operations at the safest point in the render cycle - after all canvas operations are complete
--- Call this at the end of love.draw() to enable window resizing and other state-modifying operations without crashes
--- @usage
--- function love.draw()
---   love.graphics.setCanvas(myCanvas)
---   FlexLove.draw()
---   love.graphics.setCanvas() -- Release ALL canvases
---   FlexLove.executeDeferredCallbacks() -- Now safe to execute
--- end
function flexlove.executeDeferredCallbacks()
  if #flexlove._deferredCallbacks == 0 then
    return
  end

  -- Copy callbacks and clear queue before execution
  -- This prevents infinite loops if callbacks defer more callbacks
  local callbacks = flexlove._deferredCallbacks
  flexlove._deferredCallbacks = {}

  for _, callback in ipairs(callbacks) do
    local success, err = xpcall(callback, debug.traceback)
    if not success then
      ErrorHandler.warn("FlexLove", string.format("Deferred callback failed: %s", tostring(err)))
    end
  end
end

--- Recalculate all UI layouts when the window size changes - ensures your interface adapts seamlessly to new dimensions
--- Hook this to love.resize() to maintain proper scaling and positioning across window size changes
function flexlove.resize()
  local newWidth, newHeight = love.window.getMode()

  if flexlove.baseScale then
    flexlove.scaleFactors.x = newWidth / flexlove.baseScale.width
    flexlove.scaleFactors.y = newHeight / flexlove.baseScale.height
  end

  Blur.clearCache()

  -- Release old canvases explicitly
  if flexlove._gameCanvas then
    flexlove._gameCanvas:release()
  end
  if flexlove._backdropCanvas then
    flexlove._backdropCanvas:release()
  end

  flexlove._gameCanvas = nil
  flexlove._backdropCanvas = nil
  flexlove._canvasDimensions = { width = 0, height = 0 }

  for _, win in ipairs(flexlove.topElements) do
    win:resize(newWidth, newHeight)
  end
end

--- Switch between immediate mode (React-like, recreates UI each frame) and retained mode (persistent elements) to match your architectural needs
--- Use immediate for simpler state management and declarative UIs, retained for performance-critical applications with complex state
---@param mode "immediate"|"retained"
function flexlove.setMode(mode)
  if mode == "immediate" then
    flexlove._immediateMode = true
    flexlove._immediateModeState = StateManager
    flexlove._frameStarted = false
    flexlove._autoBeganFrame = false
  elseif mode == "retained" then
    flexlove._immediateMode = false
    flexlove._immediateModeState = nil
    flexlove._frameStarted = false
    flexlove._autoBeganFrame = false
    flexlove._currentFrameElements = {}
    flexlove._frameNumber = 0
  else
    error("[FlexLove] Invalid mode: " .. tostring(mode) .. ". Expected 'immediate' or 'retained'")
  end
end

--- Check which rendering mode is active to conditionally handle state management logic
--- Useful for libraries and reusable components that need to adapt to different rendering strategies
---@return "immediate"|"retained"
function flexlove.getMode()
  return flexlove._immediateMode and "immediate" or "retained"
end

--- Manually start a new frame in immediate mode for precise control over the UI lifecycle
--- Only needed when you want explicit frame boundaries; otherwise FlexLove auto-manages frames
function flexlove.beginFrame()
  if not flexlove._immediateMode then
    return
  end

  -- Start performance frame timing
  Performance.startFrame()

  flexlove._frameNumber = flexlove._frameNumber + 1
  StateManager.incrementFrame()
  flexlove._currentFrameElements = {}
  flexlove._frameStarted = true
  flexlove.topElements = {}

  Context.clearFrameElements()
end

--- Finalize the frame in immediate mode, triggering layout calculations and state persistence
--- Only needed when manually controlling frames with beginFrame(); otherwise handled automatically
function flexlove.endFrame()
  if not flexlove._immediateMode then
    return
  end

  Context.sortElementsByZIndex()

  -- Layout all top-level elements now that all children have been added
  -- This ensures overflow detection happens with complete child lists
  for _, element in ipairs(flexlove._currentFrameElements) do
    if not element.parent then
      element:layoutChildren() -- Layout with all children present
    end
  end

  -- Auto-update all top-level elements created this frame
  -- This happens AFTER layout so positions are correct
  for _, element in ipairs(flexlove._currentFrameElements) do
    if not element.parent then
      element:update(0) -- dt=0 since we're not doing animation updates here
    end
  end

  -- Save state back for all elements created this frame
  for _, element in ipairs(flexlove._currentFrameElements) do
    if element.id and element.id ~= "" then
      local state = StateManager.getState(element.id, {})

      -- Save stateful properties back to persistent state
      -- Get event handler state
      if element._eventHandler then
        local eventState = element._eventHandler:getState()
        for k, v in pairs(eventState) do
          state[k] = v
        end
      end
      state._focused = element._focused
      state._focused = element._focused
      state._cursorPosition = element._cursorPosition
      state._selectionStart = element._selectionStart
      state._selectionEnd = element._selectionEnd
      state._textBuffer = element._textBuffer
      state._scrollX = element._scrollX
      state._scrollY = element._scrollY
      state._scrollbarDragging = element._scrollbarDragging
      state._hoveredScrollbar = element._hoveredScrollbar
      state._scrollbarDragOffset = element._scrollbarDragOffset
      state._cursorBlinkTimer = element._cursorBlinkTimer
      state._cursorVisible = element._cursorVisible
      state._cursorBlinkPaused = element._cursorBlinkPaused
      state._cursorBlinkPauseTimer = element._cursorBlinkPauseTimer

      StateManager.setState(element.id, state)
    end
  end

  StateManager.cleanup()
  StateManager.forceCleanupIfNeeded()
  flexlove._frameStarted = false

  -- End performance frame timing
  Performance.endFrame()
  Performance.resetFrameCounters()
end

flexlove._gameCanvas = nil
flexlove._backdropCanvas = nil
flexlove._canvasDimensions = { width = 0, height = 0 }

--- Render all UI elements with optional backdrop blur support for glassmorphic effects
--- Place your game scene in gameDrawFunc to enable backdrop blur on UI elements; use postDrawFunc for overlays
---@param gameDrawFunc function|nil pass component draws that should be affected by a backdrop blur
---@param postDrawFunc function|nil pass component draws that should NOT be affected by a backdrop blur
function flexlove.draw(gameDrawFunc, postDrawFunc)
  if flexlove._immediateMode and flexlove._autoBeganFrame then
    flexlove.endFrame()
    flexlove._autoBeganFrame = false
  end

  local outerCanvas = love.graphics.getCanvas()
  local gameCanvas = nil

  if type(gameDrawFunc) == "function" then
    local width, height = love.graphics.getDimensions()

    if not flexlove._gameCanvas or flexlove._canvasDimensions.width ~= width or flexlove._canvasDimensions.height ~= height then
      -- Release old canvases before creating new ones
      if flexlove._gameCanvas then
        flexlove._gameCanvas:release()
      end
      if flexlove._backdropCanvas then
        flexlove._backdropCanvas:release()
      end

      flexlove._gameCanvas = love.graphics.newCanvas(width, height)
      flexlove._backdropCanvas = love.graphics.newCanvas(width, height)
      flexlove._canvasDimensions.width = width
      flexlove._canvasDimensions.height = height
    end

    gameCanvas = flexlove._gameCanvas

    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()
    gameDrawFunc()
    love.graphics.setCanvas(outerCanvas)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, 0, 0)
  end

  table.sort(flexlove.topElements, function(a, b)
    return a.z < b.z
  end)

  local function hasBackdropBlur(element)
    if element.backdropBlur and element.backdropBlur.intensity > 0 then
      return true
    end
    for _, child in ipairs(element.children) do
      if hasBackdropBlur(child) then
        return true
      end
    end
    return false
  end

  local needsBackdropCanvas = false
  for _, win in ipairs(flexlove.topElements) do
    if hasBackdropBlur(win) then
      needsBackdropCanvas = true
      break
    end
  end

  if needsBackdropCanvas and gameCanvas then
    local backdropCanvas = flexlove._backdropCanvas
    local prevColor = { love.graphics.getColor() }

    love.graphics.setCanvas(backdropCanvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, 0, 0)

    love.graphics.setCanvas(outerCanvas)
    love.graphics.setColor(unpack(prevColor))

    for _, win in ipairs(flexlove.topElements) do
      -- Check if this element tree has backdrop blur
      local needsBackdrop = hasBackdropBlur(win)

      -- Draw element with backdrop blur applied if needed
      if needsBackdrop then
        win:draw(backdropCanvas)
      else
        win:draw(nil)
      end

      -- IMPORTANT: Update backdrop canvas for EVERY element (respecting z-index order)
      -- This ensures that lower z-index elements are visible in the backdrop blur
      -- of higher z-index elements
      love.graphics.setCanvas(backdropCanvas)
      love.graphics.setColor(1, 1, 1, 1)
      win:draw(nil)
      love.graphics.setCanvas(outerCanvas)
    end
  else
    for _, win in ipairs(flexlove.topElements) do
      win:draw(nil)
    end
  end

  if type(postDrawFunc) == "function" then
    postDrawFunc()
  end

  -- Render performance HUD if enabled
  Performance.renderHUD()

  love.graphics.setCanvas(outerCanvas)

  -- NOTE: Deferred callbacks are NOT executed here because the calling code
  -- (e.g., main.lua) might still have a canvas active. Callbacks must be
  -- executed by calling FlexLove.executeDeferredCallbacks() at the very end
  -- of love.draw() after ALL canvases have been released.
end

---@param element Element
---@param target Element
---@return boolean
local function isAncestor(element, target)
  local current = target.parent
  while current do
    if current == element then
      return true
    end
    current = current.parent
  end
  return false
end

--- Determine which UI element the user is interacting with at a specific screen position
--- Essential for custom input handling, tooltips, or debugging click targets in complex layouts
---@param x number
---@param y number
---@return Element?
function flexlove.getElementAtPosition(x, y)
  local candidates = {}
  local blockingElements = {}

  local function collectHits(element, scrollOffsetX, scrollOffsetY)
    scrollOffsetX = scrollOffsetX or 0
    scrollOffsetY = scrollOffsetY or 0

    local bx = element.x
    local by = element.y
    local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
    local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)

    -- Adjust mouse position by accumulated scroll offset for hit testing
    local adjustedX = x + scrollOffsetX
    local adjustedY = y + scrollOffsetY

    if adjustedX >= bx and adjustedX <= bx + bw and adjustedY >= by and adjustedY <= by + bh then
      -- Collect interactive elements (those with onEvent handlers)
      if element.onEvent and not element.disabled then
        table.insert(candidates, element)
      end

      -- Collect all visible elements for input blocking
      -- Elements with opacity > 0 block input to elements below them
      if element.opacity > 0 then
        table.insert(blockingElements, element)
      end

      -- Check if this element has scrollable overflow
      local overflowX = element.overflowX or element.overflow
      local overflowY = element.overflowY or element.overflow
      local hasScrollableOverflow = (
        overflowX == "scroll"
        or overflowX == "auto"
        or overflowY == "scroll"
        or overflowY == "auto"
        or overflowX == "hidden"
        or overflowY == "hidden"
      )

      -- Accumulate scroll offset for children if this element has overflow clipping
      local childScrollOffsetX = scrollOffsetX
      local childScrollOffsetY = scrollOffsetY
      if hasScrollableOverflow then
        childScrollOffsetX = childScrollOffsetX + (element._scrollX or 0)
        childScrollOffsetY = childScrollOffsetY + (element._scrollY or 0)
      end

      for _, child in ipairs(element.children) do
        collectHits(child, childScrollOffsetX, childScrollOffsetY)
      end
    end
  end

  for _, element in ipairs(flexlove.topElements) do
    collectHits(element)
  end

  -- Sort both lists by z-index (highest first)
  table.sort(candidates, function(a, b)
    return a.z > b.z
  end)

  table.sort(blockingElements, function(a, b)
    return a.z > b.z
  end)

  -- If we have interactive elements, return the topmost one
  -- But only if there's no blocking element with higher z-index (that isn't an ancestor)
  if #candidates > 0 then
    local topCandidate = candidates[1]

    -- Check if any blocking element would prevent this interaction
    if #blockingElements > 0 then
      local topBlocker = blockingElements[1]
      -- If the top blocker has higher z-index than the top candidate,
      -- and the blocker is NOT an ancestor of the candidate,
      -- return the blocker (even though it has no onEvent, it blocks input)
      if topBlocker.z > topCandidate.z and not isAncestor(topBlocker, topCandidate) then
        return topBlocker
      end
    end

    return topCandidate
  end

  -- No interactive elements, but return topmost blocking element if any
  -- This prevents clicks from passing through non-interactive overlays
  return blockingElements[1]
end

--- Update all UI animations, interactions, and state changes each frame
--- Hook this to love.update() to enable hover effects, animations, text cursors, and scrolling
---@param dt number
function flexlove.update(dt)
  -- Update Performance module with actual delta time for accurate FPS
  Performance.updateDeltaTime(dt)

  -- Garbage collection management
  flexlove._manageGC()

  local mx, my = love.mouse.getPosition()
  local topElement = flexlove.getElementAtPosition(mx, my)

  flexlove._activeEventElement = topElement

  -- In immediate mode, skip updating here - elements will be updated in endFrame after layout
  if not flexlove._immediateMode then
    for _, win in ipairs(flexlove.topElements) do
      win:update(dt)
    end
  end

  flexlove._activeEventElement = nil

  -- In immediate mode, save state after update so that cursor blink timer changes persist
  if flexlove._immediateMode and flexlove._currentFrameElements then
    for _, element in ipairs(flexlove._currentFrameElements) do
      if element.id and element.id ~= "" and element.editable and element._focused then
        local state = StateManager.getState(element.id, {})

        -- Save cursor blink state (updated during element:update())
        state._cursorBlinkTimer = element._cursorBlinkTimer
        state._cursorVisible = element._cursorVisible
        state._cursorBlinkPaused = element._cursorBlinkPaused
        state._cursorBlinkPauseTimer = element._cursorBlinkPauseTimer

        StateManager.setState(element.id, state)
      end
    end
  end
end

--- Internal GC management function (called from update)
function flexlove._manageGC()
  local strategy = flexlove._gcConfig.strategy

  if strategy == "disabled" then
    return
  end

  local currentMemory = collectgarbage("count") / 1024 -- Convert to MB
  flexlove._gcState.lastMemory = currentMemory
  flexlove._gcState.framesSinceLastGC = flexlove._gcState.framesSinceLastGC + 1

  -- Check memory threshold (applies to all strategies except disabled)
  if currentMemory > flexlove._gcConfig.memoryThreshold then
    -- Force full GC when exceeding threshold
    collectgarbage("collect")
    flexlove._gcState.gcCount = flexlove._gcState.gcCount + 1
    flexlove._gcState.framesSinceLastGC = 0
    return
  end

  -- Strategy-specific GC
  if strategy == "periodic" then
    -- Run incremental GC step every N frames
    if flexlove._gcState.framesSinceLastGC >= flexlove._gcConfig.interval then
      collectgarbage("step", flexlove._gcConfig.stepSize)
      flexlove._gcState.gcCount = flexlove._gcState.gcCount + 1
      flexlove._gcState.framesSinceLastGC = 0
    end
  elseif strategy == "auto" then
    -- Let Lua's automatic GC handle it, but help with incremental steps
    -- Run a small step every frame to keep memory under control
    if flexlove._gcState.framesSinceLastGC >= 5 then
      collectgarbage("step", 50) -- Small steps to avoid frame drops
      flexlove._gcState.framesSinceLastGC = 0
    end
  end
  -- "manual" strategy: no automatic GC, user must call flexlove.collectGarbage()
end

--- Manually trigger garbage collection to prevent frame drops during critical gameplay moments
--- Use this to control when memory cleanup happens rather than letting it occur unpredictably
---@param mode? string "collect" for full GC, "step" for incremental (default: "collect")
---@param stepSize? number Work units for step mode (default: 200)
function flexlove.collectGarbage(mode, stepSize)
  mode = mode or "collect"
  stepSize = stepSize or 200

  if mode == "collect" then
    collectgarbage("collect")
    flexlove._gcState.gcCount = flexlove._gcState.gcCount + 1
    flexlove._gcState.framesSinceLastGC = 0
  elseif mode == "step" then
    collectgarbage("step", stepSize)
  elseif mode == "count" then
    return collectgarbage("count") / 1024 -- Return memory in MB
  end
end

--- Choose how FlexLove manages memory cleanup to balance performance and memory usage for your app's needs
--- Use "manual" for tight control in performance-critical sections, "auto" for hands-off operation
---@param strategy string "auto", "periodic", "manual", or "disabled"
function flexlove.setGCStrategy(strategy)
  if strategy == "auto" or strategy == "periodic" or strategy == "manual" or strategy == "disabled" then
    flexlove._gcConfig.strategy = strategy
  else
    ErrorHandler.warn("FlexLove", "Invalid GC strategy: " .. tostring(strategy))
  end
end

--- Monitor memory management behavior to diagnose performance issues and tune GC settings
--- Use this to identify memory leaks or optimize garbage collection timing
---@return table stats {gcCount, framesSinceLastGC, currentMemoryMB, strategy}
function flexlove.getGCStats()
  return {
    gcCount = flexlove._gcState.gcCount,
    framesSinceLastGC = flexlove._gcState.framesSinceLastGC,
    currentMemoryMB = flexlove._gcState.lastMemory,
    strategy = flexlove._gcConfig.strategy,
    threshold = flexlove._gcConfig.memoryThreshold,
  }
end

--- Forward text input to focused editable elements like text fields and text areas
--- Hook this to love.textinput() to enable text entry in your UI
---@param text string
function flexlove.textinput(text)
  if flexlove._focusedElement then
    flexlove._focusedElement:textinput(text)
  end
end

--- Handle keyboard input for text editing, navigation, and performance overlay toggling
--- Hook this to love.keypressed() to enable text selection, cursor movement, and the performance HUD
---@param key string
---@param scancode string
---@param isrepeat boolean
function flexlove.keypressed(key, scancode, isrepeat)
  -- Handle performance HUD toggle
  Performance.keypressed(key)
  if flexlove._focusedElement then
    flexlove._focusedElement:keypressed(key, scancode, isrepeat)
  end
end

--- Enable mouse wheel scrolling in scrollable containers and lists
--- Hook this to love.wheelmoved() to allow users to scroll through content naturally
---@param dx number
---@param dy number
function flexlove.wheelmoved(dx, dy)
  local mx, my = love.mouse.getPosition()

  local function findScrollableAtPosition(elements, x, y)
    for i = #elements, 1, -1 do
      local element = elements[i]

      local bx = element.x
      local by = element.y
      local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
      local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)

      if x >= bx and x <= bx + bw and y >= by and y <= by + bh then
        if #element.children > 0 then
          local childResult = findScrollableAtPosition(element.children, x, y)
          if childResult then
            return childResult
          end
        end

        local overflowX = element.overflowX or element.overflow
        local overflowY = element.overflowY or element.overflow
        if (overflowX == "scroll" or overflowX == "auto" or overflowY == "scroll" or overflowY == "auto") and (element._overflowX or element._overflowY) then
          return element
        end
      end
    end

    return nil
  end

  if flexlove._immediateMode then
    -- Find topmost scrollable element at mouse position using z-index ordering
    for i = #Context._zIndexOrderedElements, 1, -1 do
      local element = Context._zIndexOrderedElements[i]

      local bx = element.x
      local by = element.y
      local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
      local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)

      -- Calculate scroll offset from parent chain
      local scrollOffsetX = 0
      local scrollOffsetY = 0
      local current = element.parent
      while current do
        local overflowX = current.overflowX or current.overflow
        local overflowY = current.overflowY or current.overflow
        local hasScrollableOverflow = (
          overflowX == "scroll"
          or overflowX == "auto"
          or overflowY == "scroll"
          or overflowY == "auto"
          or overflowX == "hidden"
          or overflowY == "hidden"
        )
        if hasScrollableOverflow then
          scrollOffsetX = scrollOffsetX + (current._scrollX or 0)
          scrollOffsetY = scrollOffsetY + (current._scrollY or 0)
        end
        current = current.parent
      end

      -- Adjust mouse position by scroll offset
      local adjustedMx = mx + scrollOffsetX
      local adjustedMy = my + scrollOffsetY

      -- Check if mouse is within element bounds
      if adjustedMx >= bx and adjustedMx <= bx + bw and adjustedMy >= by and adjustedMy <= by + bh then
        -- Check if mouse position is clipped by any parent
        local isClipped = false
        local parentCheck = element.parent
        while parentCheck do
          local parentOverflowX = parentCheck.overflowX or parentCheck.overflow
          local parentOverflowY = parentCheck.overflowY or parentCheck.overflow

          if
            parentOverflowX == "hidden"
            or parentOverflowX == "scroll"
            or parentOverflowX == "auto"
            or parentOverflowY == "hidden"
            or parentOverflowY == "scroll"
            or parentOverflowY == "auto"
          then
            local parentX = parentCheck.x + parentCheck.padding.left
            local parentY = parentCheck.y + parentCheck.padding.top
            local parentW = parentCheck.width
            local parentH = parentCheck.height

            if mx < parentX or mx > parentX + parentW or my < parentY or my > parentY + parentH then
              isClipped = true
              break
            end
          end
          parentCheck = parentCheck.parent
        end

        if not isClipped then
          local overflowX = element.overflowX or element.overflow
          local overflowY = element.overflowY or element.overflow
          if (overflowX == "scroll" or overflowX == "auto" or overflowY == "scroll" or overflowY == "auto") and (element._overflowX or element._overflowY) then
            element:_handleWheelScroll(dx, dy)

            -- Save scroll position to StateManager immediately in immediate mode
            if element._stateId then
              StateManager.updateState(element._stateId, {
                _scrollX = element._scrollX,
                _scrollY = element._scrollY,
              })
            end
            return
          end
        end
      end
    end
  else
    -- In retained mode, use the old tree traversal method
    local scrollableElement = findScrollableAtPosition(flexlove.topElements, mx, my)
    if scrollableElement then
      scrollableElement:_handleWheelScroll(dx, dy)
    end
  end
end

--- Clean up all UI elements and reset FlexLove to initial state when changing scenes or shutting down
--- Use this to prevent memory leaks when transitioning between game states or menus
function flexlove.destroy()
  for _, win in ipairs(flexlove.topElements) do
    win:destroy()
  end
  flexlove.topElements = {}
  flexlove.baseScale = nil
  flexlove.scaleFactors = { x = 1.0, y = 1.0 }
  flexlove._cachedViewport = { width = 0, height = 0 }

  -- Release canvases explicitly before destroying
  if flexlove._gameCanvas then
    flexlove._gameCanvas:release()
  end
  if flexlove._backdropCanvas then
    flexlove._backdropCanvas:release()
  end

  flexlove._gameCanvas = nil
  flexlove._backdropCanvas = nil
  flexlove._canvasDimensions = { width = 0, height = 0 }
  flexlove._focusedElement = nil
  StateManager:reset()
end

--- Create a new UI element with flexbox layout, styling, and interaction capabilities
--- This is your primary API for building interfaces - buttons, panels, text, images, and containers
---@param props ElementProps
---@return Element
function flexlove.new(props)
  props = props or {}

  -- If not in immediate mode, use standard Element.new
  if not flexlove._immediateMode then
    return Element.new(props, flexlove._defaultDependencies)
  end

  -- Auto-begin frame if not manually started (convenience feature)
  if not flexlove._frameStarted then
    flexlove.beginFrame()
    flexlove._autoBeganFrame = true
  end

  -- Immediate mode: generate ID if not provided
  if not props.id then
    props.id = StateManager.generateID(props, props.parent)
  end

  -- Get or create state for this element
  local state = StateManager.getState(props.id, {})

  -- Mark state as used this frame
  StateManager.markStateUsed(props.id)

  -- Inject scroll state into props BEFORE creating element
  -- This ensures scroll position is set before layoutChildren/detectOverflow is called
  props._scrollX = state._scrollX or 0
  props._scrollY = state._scrollY or 0

  local element = Element.new(props, flexlove._defaultDependencies)

  -- Bind persistent state to element (ImmediateModeState)
  -- Restore event handler state
  if element._eventHandler then
    element._eventHandler:setState(state)
  end
  element._focused = state._focused
  element._focused = state._focused
  element._cursorPosition = state._cursorPosition
  element._selectionStart = state._selectionStart
  element._selectionEnd = state._selectionEnd
  element._textBuffer = state._textBuffer or element.text or ""
  -- Note: scroll position already set from props during Element.new()
  -- element._scrollX and element._scrollY already restored
  element._scrollbarDragging = state._scrollbarDragging ~= nil and state._scrollbarDragging or false
  element._hoveredScrollbar = state._hoveredScrollbar
  element._scrollbarDragOffset = state._scrollbarDragOffset ~= nil and state._scrollbarDragOffset or 0

  -- Sync scrollbar drag state to ScrollManager if it exists
  if element._scrollManager then
    element._scrollManager._scrollbarDragging = element._scrollbarDragging
    element._scrollManager._hoveredScrollbar = element._hoveredScrollbar
    element._scrollManager._scrollbarDragOffset = element._scrollbarDragOffset
  end

  -- Restore cursor blink state
  element._cursorBlinkTimer = state._cursorBlinkTimer or element._cursorBlinkTimer or 0
  if state._cursorVisible ~= nil then
    element._cursorVisible = state._cursorVisible
  elseif element._cursorVisible == nil then
    element._cursorVisible = true
  end
  element._cursorBlinkPaused = state._cursorBlinkPaused or false
  element._cursorBlinkPauseTimer = state._cursorBlinkPauseTimer or 0

  -- Bind element to StateManager for interactive states
  -- Use the same ID for StateManager so state persists across frames
  element._stateId = props.id

  -- Load interactive state from StateManager (already loaded in 'state' variable above)
  element._scrollbarHoveredVertical = state.scrollbarHoveredVertical
  element._scrollbarHoveredHorizontal = state.scrollbarHoveredHorizontal
  element._scrollbarDragging = state.scrollbarDragging
  element._hoveredScrollbar = state.hoveredScrollbar
  element._scrollbarDragOffset = state.scrollbarDragOffset or 0

  -- Sync interactive scroll state to ScrollManager if it exists
  if element._scrollManager then
    element._scrollManager._scrollbarHoveredVertical = element._scrollbarHoveredVertical or false
    element._scrollManager._scrollbarHoveredHorizontal = element._scrollbarHoveredHorizontal or false
  end

  -- Set initial theme state based on StateManager state
  -- This will be updated in Element:update() but we need an initial value
  if element.themeComponent then
    if element.disabled or state.disabled then
      element._themeState = "disabled"
    elseif element.active or state.active then
      element._themeState = "active"
    elseif state.pressed then
      element._themeState = "pressed"
    elseif state.hover then
      element._themeState = "hover"
    else
      element._themeState = "normal"
    end
  end

  table.insert(flexlove._currentFrameElements, element)

  return element
end

--- Check how many UI element states are being tracked in immediate mode to detect memory leaks
--- Use this during development to ensure states are properly cleaned up
---@return number
function flexlove.getStateCount()
  if not flexlove._immediateMode then
    return 0
  end
  return StateManager.getStateCount()
end

--- Remove stored state for a specific element when you know it won't be rendered again
--- Use this to immediately free memory for elements you've removed from your UI
---@param id string
function flexlove.clearState(id)
  if not flexlove._immediateMode then
    return
  end
  StateManager.clearState(id)
end

--- Wipe all element state when transitioning between completely different UI screens
--- Use this for scene transitions to start with a clean slate and prevent state pollution
function flexlove.clearAllStates()
  if not flexlove._immediateMode then
    return
  end
  StateManager.clearAllStates()
end

--- Inspect state management metrics to diagnose performance issues and optimize immediate mode usage
--- Use this to understand state lifecycle and identify unexpected state accumulation
---@return { stateCount: number, frameNumber: number, oldestState: number|nil, newestState: number|nil }
function flexlove.getStateStats()
  if not flexlove._immediateMode then
    return { stateCount = 0, frameNumber = 0 }
  end
  return StateManager.getStats()
end

flexlove.Animation = Animation
flexlove.Color = Color
flexlove.Theme = Theme
flexlove.enums = enums

return flexlove
