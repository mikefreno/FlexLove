local modulePath = (...):match("(.-)[^%.]+$") -- Get the module path prefix (e.g., "libs." or "")
local function req(name)
  return require(modulePath .. "modules." .. name)
end

-- internals
local Blur = req("Blur")
local utils = req("utils")
local Units = req("Units")
local Context = req("Context")
local StateManager = req("StateManager")
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

-- Initialize Units module with Context dependency
Units.initialize(Context)
Units.initializeErrorHandler(ErrorHandler)

-- Add version and metadata
flexlove._VERSION = "0.1.0"
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

---@param config {baseScale?: {width?:number, height?:number}, theme?: string|ThemeDefinition, immediateMode?: boolean, stateRetentionFrames?: number, maxStateEntries?: number, autoFrameManagement?: boolean}
function flexlove.init(config)
  config = config or {}

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

  if config.stateRetentionFrames or config.maxStateEntries then
    StateManager.configure({
      stateRetentionFrames = config.stateRetentionFrames,
      maxStateEntries = config.maxStateEntries,
    })
  end
end

function flexlove.resize()
  local newWidth, newHeight = love.window.getMode()

  if flexlove.baseScale then
    flexlove.scaleFactors.x = newWidth / flexlove.baseScale.width
    flexlove.scaleFactors.y = newHeight / flexlove.baseScale.height
  end

  Blur.clearCache()

  flexlove._gameCanvas = nil
  flexlove._backdropCanvas = nil
  flexlove._canvasDimensions = { width = 0, height = 0 }

  for _, win in ipairs(flexlove.topElements) do
    win:resize(newWidth, newHeight)
  end
end

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

---@return "immediate"|"retained"
function flexlove.getMode()
  return flexlove._immediateMode and "immediate" or "retained"
end

--- Begin a new immediate mode frame
function flexlove.beginFrame()
  if not flexlove._immediateMode then
    return
  end

  flexlove._frameNumber = flexlove._frameNumber + 1
  StateManager.incrementFrame()
  flexlove._currentFrameElements = {}
  flexlove._frameStarted = true
  flexlove.topElements = {}

  Context.clearFrameElements()
end

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

  -- Auto-update all top-level elements (triggers additional state updates)
  -- This must happen BEFORE saving state so that scroll positions and overflow are calculated
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
end

flexlove._gameCanvas = nil
flexlove._backdropCanvas = nil
flexlove._canvasDimensions = { width = 0, height = 0 }

---@param gameDrawFunc function|nil
---@param postDrawFunc function|nil
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

  love.graphics.setCanvas(outerCanvas)
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

--- Find the topmost element at given coordinates
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

function flexlove.update(dt)
  local mx, my = love.mouse.getPosition()
  local topElement = flexlove.getElementAtPosition(mx, my)

  flexlove._activeEventElement = topElement

  for _, win in ipairs(flexlove.topElements) do
    win:update(dt)
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

---@param text string
function flexlove.textinput(text)
  if flexlove._focusedElement then
    flexlove._focusedElement:textinput(text)
  end
end

---@param key string
---@param scancode string
---@param isrepeat boolean
function flexlove.keypressed(key, scancode, isrepeat)
  if flexlove._focusedElement then
    flexlove._focusedElement:keypressed(key, scancode, isrepeat)
  end
end

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
          
          if parentOverflowX == "hidden" or parentOverflowX == "scroll" or parentOverflowX == "auto" or 
             parentOverflowY == "hidden" or parentOverflowY == "scroll" or parentOverflowY == "auto" then
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

function flexlove.destroy()
  for _, win in ipairs(flexlove.topElements) do
    win:destroy()
  end
  flexlove.topElements = {}
  flexlove.baseScale = nil
  flexlove.scaleFactors = { x = 1.0, y = 1.0 }
  flexlove._cachedViewport = { width = 0, height = 0 }
  flexlove._gameCanvas = nil
  flexlove._backdropCanvas = nil
  flexlove._canvasDimensions = { width = 0, height = 0 }
  flexlove._focusedElement = nil
end

---@param props ElementProps
---@return Element
function flexlove.new(props)
  props = props or {}

  -- If not in immediate mode, use standard Element.new
  if not flexlove._immediateMode then
    return Element.new(props)
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

  -- Create the element
  local element = Element.new(props)

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

---@return number
function flexlove.getStateCount()
  if not flexlove._immediateMode then
    return 0
  end
  return StateManager.getStateCount()
end

--- Clear state for a specific element ID
---@param id string
function flexlove.clearState(id)
  if not flexlove._immediateMode then
    return
  end
  StateManager.clearState(id)
end

--- Clear all immediate mode states
function flexlove.clearAllStates()
  if not flexlove._immediateMode then
    return
  end
  StateManager.clearAllStates()
end

--- Get state statistics (for debugging)
---@return table
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
