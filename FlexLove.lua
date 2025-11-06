--[[
FlexLove - UI Library for LÖVE Framework 'based' on flexbox
VERSION: 1.0.0
LICENSE: MIT
For full documentation, see README.md
]]

local modulePath = (...):match("(.-)[^%.]+$") -- Get the module path prefix (e.g., "libs." or "")
local function req(name)
  return require(modulePath .. "modules." .. name)
end

-- internals
local Blur = req("Blur")
local ImageCache = req("ImageCache")
local ImageDataReader = req("ImageDataReader")
local ImageRenderer = req("ImageRenderer")
local ImageScaler = req("ImageScaler")
local NinePatchParser = req("NinePatchParser")
local utils = req("utils")
local Units = req("Units")
local GuiState = req("GuiState")
local StateManager = req("StateManager")

-- externals
---@type Theme
local Theme = req("Theme")
---@type Animation
local Animation = req("Animation")
---@type Color
local Color = req("Color")
---@type Element
local Element = req("Element")

local enums = utils.enums

local Positioning, FlexDirection, JustifyContent, AlignContent, AlignItems, TextAlign, AlignSelf, JustifySelf, FlexWrap =
  enums.Positioning,
  enums.FlexDirection,
  enums.JustifyContent,
  enums.AlignContent,
  enums.AlignItems,
  enums.TextAlign,
  enums.AlignSelf,
  enums.JustifySelf,
  enums.FlexWrap

-- ====================
-- Top level GUI manager
-- ====================

---@class Gui
local Gui = GuiState

--- Initialize FlexLove with configuration
---@param config {baseScale?: {width?:number, height?:number}, theme?: string|ThemeDefinition, immediateMode?: boolean, stateRetentionFrames?: number, maxStateEntries?: number, autoFrameManagement?: boolean}
function Gui.init(config)
  config = config or {}

  if config.baseScale then
    Gui.baseScale = {
      width = config.baseScale.width or 1920,
      height = config.baseScale.height or 1080,
    }

    local currentWidth, currentHeight = Units.getViewport()
    Gui.scaleFactors.x = currentWidth / Gui.baseScale.width
    Gui.scaleFactors.y = currentHeight / Gui.baseScale.height
  end

  if config.theme then
    local success, err = pcall(function()
      if type(config.theme) == "string" then
        Theme.load(config.theme)
        Theme.setActive(config.theme)
        Gui.defaultTheme = config.theme
      elseif type(config.theme) == "table" then
        local theme = Theme.new(config.theme)
        Theme.setActive(theme)
        Gui.defaultTheme = theme.name
      end
    end)

    if not success then
      print("[FlexLove] Failed to load theme: " .. tostring(err))
    end
  end

  local immediateMode = config.immediateMode or false
  Gui.setMode(immediateMode and "immediate" or "retained")

  -- Configure auto frame management (defaults to false for manual control)
  Gui._autoFrameManagement = config.autoFrameManagement or false

  -- Configure state management
  if config.stateRetentionFrames or config.maxStateEntries then
    StateManager.configure({
      stateRetentionFrames = config.stateRetentionFrames,
      maxStateEntries = config.maxStateEntries,
    })
  end
end

function Gui.resize()
  local newWidth, newHeight = love.window.getMode()

  if Gui.baseScale then
    Gui.scaleFactors.x = newWidth / Gui.baseScale.width
    Gui.scaleFactors.y = newHeight / Gui.baseScale.height
  end

  Blur.clearCache()

  Gui._gameCanvas = nil
  Gui._backdropCanvas = nil
  Gui._canvasDimensions = { width = 0, height = 0 }

  for _, win in ipairs(Gui.topElements) do
    win:resize(newWidth, newHeight)
  end
end

--- Set the rendering mode (immediate or retained)
---@param mode "immediate"|"retained" The rendering mode to use
function Gui.setMode(mode)
  if mode == "immediate" then
    Gui._immediateMode = true
    Gui._immediateModeState = StateManager
    -- Reset frame state
    Gui._frameStarted = false
    Gui._autoBeganFrame = false
  elseif mode == "retained" then
    Gui._immediateMode = false
    Gui._immediateModeState = nil
    -- Clear immediate mode state
    Gui._frameStarted = false
    Gui._autoBeganFrame = false
    Gui._currentFrameElements = {}
    Gui._frameNumber = 0
  else
    error("[FlexLove] Invalid mode: " .. tostring(mode) .. ". Expected 'immediate' or 'retained'")
  end
end

--- Get the current rendering mode
---@return "immediate"|"retained"
function Gui.getMode()
  return Gui._immediateMode and "immediate" or "retained"
end

--- Begin a new immediate mode frame
function Gui.beginFrame()
  if not Gui._immediateMode then
    return
  end

  -- Increment frame counter
  Gui._frameNumber = Gui._frameNumber + 1
  StateManager.incrementFrame()

  -- Clear current frame elements
  Gui._currentFrameElements = {}
  Gui._frameStarted = true

  -- Clear top elements (they will be recreated this frame)
  Gui.topElements = {}
  
  -- Clear z-index ordered elements from previous frame
  GuiState.clearFrameElements()
end

--- End the current immediate mode frame
function Gui.endFrame()
  if not Gui._immediateMode then
    return
  end

  -- Sort elements by z-index for occlusion detection
  GuiState.sortElementsByZIndex()

  -- Auto-update all top-level elements (triggers layout calculation and overflow detection)
  -- This must happen BEFORE saving state so that scroll positions and overflow are calculated
  for _, element in ipairs(Gui._currentFrameElements) do
    -- Only update top-level elements (those without parents in the current frame)
    -- Element:update() will recursively update children
    if not element.parent then
      element:update(0) -- dt=0 since we're not doing animation updates here
    end
  end

  -- Save state back for all elements created this frame
  for _, element in ipairs(Gui._currentFrameElements) do
    if element.id and element.id ~= "" then
      local state = StateManager.getState(element.id, {})

      -- Save stateful properties back to persistent state
      state._pressed = element._pressed
      state._lastClickTime = element._lastClickTime
      state._lastClickButton = element._lastClickButton
      state._clickCount = element._clickCount
      state._dragStartX = element._dragStartX
      state._dragStartY = element._dragStartY
      state._lastMouseX = element._lastMouseX
      state._lastMouseY = element._lastMouseY
      state._hovered = element._hovered
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

      StateManager.setState(element.id, state)
    end
  end

  -- Cleanup stale states
  StateManager.cleanup()

  -- Force cleanup if we have too many states
  StateManager.forceCleanupIfNeeded()

  -- Clear frame started flag
  Gui._frameStarted = false
end

-- Canvas cache for game rendering
Gui._gameCanvas = nil
Gui._backdropCanvas = nil
Gui._canvasDimensions = { width = 0, height = 0 }

---@param gameDrawFunc function|nil
---@param postDrawFunc function|nil
function Gui.draw(gameDrawFunc, postDrawFunc)
  -- Auto-end frame if it was auto-started in immediate mode
  if Gui._immediateMode and Gui._autoBeganFrame then
    Gui.endFrame()
    Gui._autoBeganFrame = false
  end

  local outerCanvas = love.graphics.getCanvas()
  local gameCanvas = nil

  if type(gameDrawFunc) == "function" then
    local width, height = love.graphics.getDimensions()

    if not Gui._gameCanvas or Gui._canvasDimensions.width ~= width or Gui._canvasDimensions.height ~= height then
      Gui._gameCanvas = love.graphics.newCanvas(width, height)
      Gui._backdropCanvas = love.graphics.newCanvas(width, height)
      Gui._canvasDimensions.width = width
      Gui._canvasDimensions.height = height
    end

    gameCanvas = Gui._gameCanvas

    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()
    gameDrawFunc()
    love.graphics.setCanvas(outerCanvas)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, 0, 0)
  end

  table.sort(Gui.topElements, function(a, b)
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
  for _, win in ipairs(Gui.topElements) do
    if hasBackdropBlur(win) then
      needsBackdropCanvas = true
      break
    end
  end

  if needsBackdropCanvas and gameCanvas then
    local backdropCanvas = Gui._backdropCanvas
    local prevColor = { love.graphics.getColor() }

    love.graphics.setCanvas(backdropCanvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, 0, 0)

    love.graphics.setCanvas(outerCanvas)
    love.graphics.setColor(unpack(prevColor))

    for _, win in ipairs(Gui.topElements) do
      -- Only draw with backdrop canvas if this element tree has backdrop blur
      local needsBackdrop = hasBackdropBlur(win)
      
      if needsBackdrop then
        -- Draw element with backdrop blur applied
        win:draw(backdropCanvas)

        -- Update backdrop canvas for next element
        love.graphics.setCanvas(backdropCanvas)
        love.graphics.setColor(1, 1, 1, 1)
        win:draw(nil)
        love.graphics.setCanvas(outerCanvas)
      else
        -- No backdrop blur needed, draw normally once
        win:draw(nil)
      end
    end
  else
    for _, win in ipairs(Gui.topElements) do
      win:draw(nil)
    end
  end

  if type(postDrawFunc) == "function" then
    postDrawFunc()
  end

  love.graphics.setCanvas(outerCanvas)
end

--- Check if element is an ancestor of target
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

--- Find the topmost element at given coordinates
---@param x number
---@param y number
---@return Element?
function Gui.getElementAtPosition(x, y)
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
      -- Collect interactive elements (those with callbacks)
      if element.callback and not element.disabled then
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

  for _, element in ipairs(Gui.topElements) do
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
      -- return the blocker (even though it has no callback, it blocks input)
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

function Gui.update(dt)
  local mx, my = love.mouse.getPosition()
  local topElement = Gui.getElementAtPosition(mx, my)

  Gui._activeEventElement = topElement

  for _, win in ipairs(Gui.topElements) do
    win:update(dt)
  end

  Gui._activeEventElement = nil
end

--- Forward text input to focused element
---@param text string
function Gui.textinput(text)
  if Gui._focusedElement then
    Gui._focusedElement:textinput(text)
  end
end

--- Forward key press to focused element
---@param key string
---@param scancode string
---@param isrepeat boolean
function Gui.keypressed(key, scancode, isrepeat)
  if Gui._focusedElement then
    Gui._focusedElement:keypressed(key, scancode, isrepeat)
  end
end

--- Handle mouse wheel scrolling
function Gui.wheelmoved(x, y)
  local mx, my = love.mouse.getPosition()
  
  local function findScrollableAtPosition(elements, mx, my)
    for i = #elements, 1, -1 do
      local element = elements[i]

      local bx = element.x
      local by = element.y
      local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
      local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)

      if mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
        if #element.children > 0 then
          local childResult = findScrollableAtPosition(element.children, mx, my)
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

  -- In immediate mode, use z-index ordered elements and respect occlusion
  if Gui._immediateMode then
    -- Find topmost scrollable element at mouse position using z-index ordering
    for i = #GuiState._zIndexOrderedElements, 1, -1 do
      local element = GuiState._zIndexOrderedElements[i]
      
      local bx = element.x
      local by = element.y
      local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
      local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)
      
      if mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
        local overflowX = element.overflowX or element.overflow
        local overflowY = element.overflowY or element.overflow
        if (overflowX == "scroll" or overflowX == "auto" or overflowY == "scroll" or overflowY == "auto") and (element._overflowX or element._overflowY) then
          element:_handleWheelScroll(x, y)
          return
        end
      end
    end
  else
    -- In retained mode, use the old tree traversal method
    local scrollableElement = findScrollableAtPosition(Gui.topElements, mx, my)
    if scrollableElement then
      scrollableElement:_handleWheelScroll(x, y)
    end
  end
end

--- Destroy all elements and their children
function Gui.destroy()
  for _, win in ipairs(Gui.topElements) do
    win:destroy()
  end
  Gui.topElements = {}
  Gui.baseScale = nil
  Gui.scaleFactors = { x = 1.0, y = 1.0 }
  Gui._cachedViewport = { width = 0, height = 0 }
  Gui._gameCanvas = nil
  Gui._backdropCanvas = nil
  Gui._canvasDimensions = { width = 0, height = 0 }
  Gui._focusedElement = nil
end

-- ====================
-- Immediate Mode API
-- ====================

--- Create a new element (supports both immediate and retained mode)
---@param props table
---@return Element
function Gui.new(props)
  props = props or {}

  -- If not in immediate mode, use standard Element.new
  if not Gui._immediateMode then
    return Element.new(props)
  end

  -- Auto-begin frame if not manually started (convenience feature)
  if not Gui._frameStarted then
    Gui.beginFrame()
    Gui._autoBeganFrame = true
  end

  -- Immediate mode: generate ID if not provided
  if not props.id then
    props.id = StateManager.generateID(props)
  end

  -- Get or create state for this element
  local state = StateManager.getState(props.id, {})

  -- Mark state as used this frame
  StateManager.markStateUsed(props.id)

  -- Create the element
  local element = Element.new(props)

  -- Bind persistent state to element (ImmediateModeState)
  -- Copy stateful properties from persistent state
  element._pressed = state._pressed or {}
  element._lastClickTime = state._lastClickTime
  element._lastClickButton = state._lastClickButton
  element._clickCount = state._clickCount or 0
  element._dragStartX = state._dragStartX or element._dragStartX or {}
  element._dragStartY = state._dragStartY or element._dragStartY or {}
  element._lastMouseX = state._lastMouseX or element._lastMouseX or {}
  element._lastMouseY = state._lastMouseY or element._lastMouseY or {}
  element._hovered = state._hovered
  element._focused = state._focused
  element._cursorPosition = state._cursorPosition
  element._selectionStart = state._selectionStart
  element._selectionEnd = state._selectionEnd
  element._textBuffer = state._textBuffer or element.text or ""
  element._scrollX = state._scrollX or element._scrollX or 0
  element._scrollY = state._scrollY or element._scrollY or 0
  element._scrollbarDragging = state._scrollbarDragging or false
  element._hoveredScrollbar = state._hoveredScrollbar
  element._scrollbarDragOffset = state._scrollbarDragOffset or 0

  -- Bind element to StateManager for interactive states
  -- Use the same ID for StateManager so state persists across frames
  element._stateId = props.id

  -- Load interactive state from StateManager (already loaded in 'state' variable above)
  element._scrollbarHoveredVertical = state.scrollbarHoveredVertical
  element._scrollbarHoveredHorizontal = state.scrollbarHoveredHorizontal
  element._scrollbarDragging = state.scrollbarDragging
  element._hoveredScrollbar = state.hoveredScrollbar
  element._scrollbarDragOffset = state.scrollbarDragOffset or 0

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

  -- Store element in current frame tracking
  table.insert(Gui._currentFrameElements, element)

  -- Save state back at end of frame (we'll do this in endFrame)
  -- For now, we need to update the state when properties change
  -- This is a simplified approach - a full implementation would use
  -- a more sophisticated state synchronization mechanism

  return element
end

--- Get state count (for debugging)
---@return number
function Gui.getStateCount()
  if not Gui._immediateMode then
    return 0
  end
  return StateManager.getStateCount()
end

--- Clear state for a specific element ID
---@param id string
function Gui.clearState(id)
  if not Gui._immediateMode then
    return
  end
  StateManager.clearState(id)
end

--- Clear all immediate mode states
function Gui.clearAllStates()
  if not Gui._immediateMode then
    return
  end
  StateManager.clearAllStates()
end

--- Get state statistics (for debugging)
---@return table
function Gui.getStateStats()
  if not Gui._immediateMode then
    return { stateCount = 0, frameNumber = 0 }
  end
  return StateManager.getStats()
end

--- Helper function: Create a button with default styling
---@param props table
---@return Element
function Gui.button(props)
  props = props or {}
  props.themeComponent = props.themeComponent or "button"
  return Gui.new(props)
end

--- Helper function: Create a panel/container
---@param props table
---@return Element
function Gui.panel(props)
  props = props or {}
  return Gui.new(props)
end

--- Helper function: Create a text label
---@param props table
---@return Element
function Gui.text(props)
  props = props or {}
  return Gui.new(props)
end

--- Helper function: Create an input field
---@param props table
---@return Element
function Gui.input(props)
  props = props or {}
  props.editable = true
  return Gui.new(props)
end

-- Export original Element.new for direct access if needed
Gui.Element = Element
Gui.Animation = Animation
Gui.Theme = Theme
Gui.ImageCache = ImageCache
Gui.ImageDataReader = ImageDataReader
Gui.ImageRenderer = ImageRenderer
Gui.ImageScaler = ImageScaler
Gui.NinePatchParser = NinePatchParser
Gui.StateManager = StateManager

return {
  Gui = Gui,
  Element = Element,
  Color = Color,
  Theme = Theme,
  Positioning = Positioning,
  FlexDirection = FlexDirection,
  JustifyContent = JustifyContent,
  AlignContent = AlignContent,
  AlignItems = AlignItems,
  TextAlign = TextAlign,
  AlignSelf = AlignSelf,
  JustifySelf = JustifySelf,
  FlexWrap = FlexWrap,
  enums = enums,
  -- generally should not be used directly, exported for testing, mainly
  ImageCache = ImageCache,
  ImageRenderer = ImageRenderer,
  ImageScaler = ImageScaler,
}
