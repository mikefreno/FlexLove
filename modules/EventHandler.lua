-- ====================
-- EventHandler Module
-- ====================
-- Extracted event handling functionality from Element.lua
-- Handles all mouse, keyboard, touch, and drag events for interactive elements

-- Setup module path for relative requires
local modulePath = (...):match("(.-)[^%.]+$")
local function req(name)
  return require(modulePath .. name)
end

-- Module dependencies
local GuiState = req("GuiState")
local InputEvent = req("InputEvent")
local StateManager = req("StateManager")
local utils = req("utils")

-- Extract utilities
local getModifiers = utils.getModifiers

-- Reference to Gui (via GuiState)
local Gui = GuiState

---@class EventHandler
---@field onEvent fun(element:Element, event:InputEvent)?
---@field _pressed table<number, boolean> -- Track pressed state per mouse button
---@field _lastClickTime number? -- Timestamp of last click for double-click detection
---@field _lastClickButton number? -- Button of last click
---@field _clickCount number -- Current click count for multi-click detection
---@field _touchPressed table<any, boolean> -- Track touch pressed state
---@field _dragStartX table<number, number>? -- Track drag start X position per mouse button
---@field _dragStartY table<number, number>? -- Track drag start Y position per mouse button
---@field _lastMouseX table<number, number>? -- Last known mouse X position per button for drag tracking
---@field _lastMouseY table<number, number>? -- Last known mouse Y position per button for drag tracking
---@field _scrollbarPressHandled boolean? -- Track if scrollbar press was handled
---@field _element Element? -- Reference to parent element
local EventHandler = {}
EventHandler.__index = EventHandler

--- Create a new EventHandler instance
---@param config table Configuration options
---@return EventHandler
function EventHandler.new(config)
  local self = setmetatable({}, EventHandler)
  
  -- Configuration
  self.onEvent = config.onEvent
  
  -- Initialize click tracking for event system
  self._pressed = {} -- Track pressed state per mouse button
  self._lastClickTime = nil
  self._lastClickButton = nil
  self._clickCount = 0
  self._touchPressed = {}
  
  -- Initialize drag tracking for event system
  self._dragStartX = {} -- Track drag start X position per mouse button
  self._dragStartY = {} -- Track drag start Y position per mouse button
  self._lastMouseX = {} -- Track last mouse X position per button
  self._lastMouseY = {} -- Track last mouse Y position per button
  
  -- Scrollbar press tracking
  self._scrollbarPressHandled = false
  
  -- Element reference (set via initialize)
  self._element = nil
  
  return self
end

--- Initialize with parent element reference
---@param element Element The parent element
function EventHandler:initialize(element)
  self._element = element
  
  -- Restore state from StateManager in immediate mode
  if Gui._immediateMode and element._stateId then
    local state = StateManager.getState(element._stateId)
    if state then
      -- Restore pressed state
      if state._pressed then
        self._pressed = state._pressed
      end
      
      -- Restore click tracking
      if state._lastClickTime then
        self._lastClickTime = state._lastClickTime
      end
      if state._lastClickButton then
        self._lastClickButton = state._lastClickButton
      end
      if state._clickCount then
        self._clickCount = state._clickCount
      end
    end
  end
end

--- Update event handler state (called every frame)
---@param dt number Delta time
function EventHandler:update(dt)
  if not self._element then
    return
  end
  
  local element = self._element
  local mx, my = love.mouse.getPosition()
  
  -- Only process events if element has event handler, theme component, or is editable
  if not (element.onEvent or element.themeComponent or element.editable) then
    return
  end
  
  -- Get element bounds (border box)
  local bx = element.x
  local by = element.y
  local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
  local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)
  
  -- Account for scroll offsets from parent containers
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
  
  -- Adjust mouse position by accumulated scroll offset for hit testing
  local adjustedMx = mx + scrollOffsetX
  local adjustedMy = my + scrollOffsetY
  local isHovering = adjustedMx >= bx and adjustedMx <= bx + bw and adjustedMy >= by and adjustedMy <= by + bh
  
  -- Check if this is the topmost element at the mouse position (z-index ordering)
  local isActiveElement
  if Gui._immediateMode then
    -- In immediate mode, use z-index occlusion detection
    local topElement = GuiState.getTopElementAt(mx, my)
    isActiveElement = (topElement == element or topElement == nil)
  else
    -- In retained mode, use the old _activeEventElement mechanism
    isActiveElement = (Gui._activeEventElement == nil or Gui._activeEventElement == element)
  end
  
  -- Update theme state based on interaction
  if element.themeComponent then
    local newThemeState = "normal"
    
    -- Disabled state takes priority
    if element.disabled then
      newThemeState = "disabled"
    -- Active state (for inputs when focused/typing)
    elseif element.active then
      newThemeState = "active"
    -- Only show hover/pressed states if this element is active (not blocked)
    elseif isHovering and isActiveElement then
      -- Check if any button is pressed
      local anyPressed = false
      for _, pressed in pairs(self._pressed) do
        if pressed then
          anyPressed = true
          break
        end
      end
      
      if anyPressed then
        newThemeState = "pressed"
      else
        newThemeState = "hover"
      end
    end
    
    -- Update state (in StateManager if in immediate mode, otherwise locally)
    if element._stateId and Gui._immediateMode then
      -- Update in StateManager for immediate mode
      local hover = newThemeState == "hover"
      local pressed = newThemeState == "pressed"
      local focused = newThemeState == "active" or element._focused
      
      StateManager.updateState(element._stateId, {
        hover = hover,
        pressed = pressed,
        focused = focused,
        disabled = element.disabled,
        active = element.active,
      })
    end
    
    -- Always update local state for backward compatibility
    element._themeState = newThemeState
  end
  
  -- Only process button events if onEvent handler exists, element is not disabled,
  -- and this is the topmost element at the mouse position (z-index ordering)
  -- Exception: Allow drag continuation even if occluded (once drag starts, it continues)
  local isDragging = false
  for _, button in ipairs({ 1, 2, 3 }) do
    if self._pressed[button] and love.mouse.isDown(button) then
      isDragging = true
      break
    end
  end
  
  local canProcessEvents = (element.onEvent or element.editable) and not element.disabled and (isActiveElement or isDragging)
  
  if canProcessEvents then
    -- Check all three mouse buttons
    local buttons = { 1, 2, 3 } -- left, right, middle
    
    for _, button in ipairs(buttons) do
      if isHovering or isDragging then
        if love.mouse.isDown(button) then
          -- Button is pressed down
          if not self._pressed[button] then
            -- Check if press is on scrollbar first (skip if already handled)
            if button == 1 and not self._scrollbarPressHandled and element._handleScrollbarPress and element:_handleScrollbarPress(mx, my, button) then
              -- Scrollbar consumed the event, mark as pressed to prevent onEvent
              self._pressed[button] = true
              self._scrollbarPressHandled = true
            else
              -- Just pressed - fire press event and record drag start position
              local modifiers = getModifiers()
              if element.onEvent then
                local pressEvent = InputEvent.new({
                  type = "press",
                  button = button,
                  x = mx,
                  y = my,
                  modifiers = modifiers,
                  clickCount = 1,
                })
                element.onEvent(element, pressEvent)
              end
              self._pressed[button] = true
              
              -- Set mouse down position for text selection on left click
              if button == 1 and element.editable then
                element._mouseDownPosition = element:_mouseToTextPosition(mx, my)
                element._textDragOccurred = false -- Reset drag flag on press
              end
            end
            
            -- Record drag start position per button
            self._dragStartX[button] = mx
            self._dragStartY[button] = my
            self._lastMouseX[button] = mx
            self._lastMouseY[button] = my
          else
            -- Button is still pressed - check for mouse movement (drag)
            local lastX = self._lastMouseX[button] or mx
            local lastY = self._lastMouseY[button] or my
            
            if lastX ~= mx or lastY ~= my then
              -- Mouse has moved - fire drag event only if still hovering
              if element.onEvent and isHovering then
                local modifiers = getModifiers()
                local dx = mx - self._dragStartX[button]
                local dy = my - self._dragStartY[button]
                
                local dragEvent = InputEvent.new({
                  type = "drag",
                  button = button,
                  x = mx,
                  y = my,
                  dx = dx,
                  dy = dy,
                  modifiers = modifiers,
                  clickCount = 1,
                })
                element.onEvent(element, dragEvent)
              end
              
              -- Handle text selection drag for editable elements
              if button == 1 and element.editable and element._focused then
                element:_handleTextDrag(mx, my)
              end
              
              -- Update last known position for this button
              self._lastMouseX[button] = mx
              self._lastMouseY[button] = my
            end
          end
        elseif self._pressed[button] then
          -- Button was just released - fire click event
          local currentTime = love.timer.getTime()
          local modifiers = getModifiers()
          
          -- Determine click count (double-click detection)
          local clickCount = 1
          local doubleClickThreshold = 0.3 -- 300ms for double-click
          
          if self._lastClickTime and self._lastClickButton == button and (currentTime - self._lastClickTime) < doubleClickThreshold then
            clickCount = self._clickCount + 1
          else
            clickCount = 1
          end
          
          self._clickCount = clickCount
          self._lastClickTime = currentTime
          self._lastClickButton = button
          
          -- Determine event type based on button
          local eventType = "click"
          if button == 2 then
            eventType = "rightclick"
          elseif button == 3 then
            eventType = "middleclick"
          end
          
          if element.onEvent then
            local clickEvent = InputEvent.new({
              type = eventType,
              button = button,
              x = mx,
              y = my,
              modifiers = modifiers,
              clickCount = clickCount,
            })
            
            element.onEvent(element, clickEvent)
          end
          self._pressed[button] = false
          
          -- Clean up drag tracking
          self._dragStartX[button] = nil
          self._dragStartY[button] = nil
          
          -- Clean up text selection drag tracking
          if button == 1 then
            element._mouseDownPosition = nil
          end
          
          -- Focus editable elements on left click
          if button == 1 and element.editable then
            -- Only focus if not already focused (to avoid moving cursor to end)
            local wasFocused = element:isFocused()
            if not wasFocused then
              element:focus()
            end
            
            -- Handle text click for cursor positioning and word selection
            -- Only process click if no text drag occurred (to preserve drag selection)
            if not element._textDragOccurred then
              element:_handleTextClick(mx, my, clickCount)
            end
            
            -- Reset drag flag after release
            element._textDragOccurred = false
          end
          
          -- Fire release event
          if element.onEvent then
            local releaseEvent = InputEvent.new({
              type = "release",
              button = button,
              x = mx,
              y = my,
              modifiers = modifiers,
              clickCount = clickCount,
            })
            element.onEvent(element, releaseEvent)
          end
        end
      else
        -- Mouse left the element - reset pressed state and drag tracking
        if self._pressed[button] then
          self._pressed[button] = false
          self._dragStartX[button] = nil
          self._dragStartY[button] = nil
        end
      end
    end
  end
  
  -- Handle touch events (maintain backward compatibility)
  if element.onEvent then
    local touches = love.touch.getTouches()
    for _, id in ipairs(touches) do
      local tx, ty = love.touch.getPosition(id)
      if tx >= bx and tx <= bx + bw and ty >= by and ty <= by + bh then
        self._touchPressed[id] = true
      elseif self._touchPressed[id] then
        -- Create touch event (treat as left click)
        local touchEvent = InputEvent.new({
          type = "click",
          button = 1,
          x = tx,
          y = ty,
          modifiers = getModifiers(),
          clickCount = 1,
        })
        element.onEvent(element, touchEvent)
        self._touchPressed[id] = false
      end
    end
  end
  
  -- Save state to StateManager in immediate mode
  if element._stateId and Gui._immediateMode then
    StateManager.updateState(element._stateId, {
      _pressed = self._pressed,
      _lastClickTime = self._lastClickTime,
      _lastClickButton = self._lastClickButton,
      _clickCount = self._clickCount,
    })
  end
end

--- Handle mouse press event
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button (1=left, 2=right, 3=middle)
---@return boolean True if event was consumed
function EventHandler:handleMousePress(x, y, button)
  if not self._element then
    return false
  end
  
  local element = self._element
  
  -- Check if element is disabled
  if element.disabled then
    return false
  end
  
  -- Check if press is within bounds
  local bx = element.x
  local by = element.y
  local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
  local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)
  
  if x < bx or x > bx + bw or y < by or y > by + bh then
    return false
  end
  
  -- Fire press event
  if element.onEvent then
    local modifiers = getModifiers()
    local pressEvent = InputEvent.new({
      type = "press",
      button = button,
      x = x,
      y = y,
      modifiers = modifiers,
      clickCount = 1,
    })
    element.onEvent(element, pressEvent)
  end
  
  -- Mark as pressed
  self._pressed[button] = true
  
  -- Record drag start position
  self._dragStartX[button] = x
  self._dragStartY[button] = y
  self._lastMouseX[button] = x
  self._lastMouseY[button] = y
  
  return true
end

--- Handle mouse release event
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button (1=left, 2=right, 3=middle)
---@return boolean True if event was consumed
function EventHandler:handleMouseRelease(x, y, button)
  if not self._element then
    return false
  end
  
  local element = self._element
  
  -- Only handle if button was pressed
  if not self._pressed[button] then
    return false
  end
  
  -- Fire click event
  local currentTime = love.timer.getTime()
  local modifiers = getModifiers()
  
  -- Determine click count (double-click detection)
  local clickCount = 1
  local doubleClickThreshold = 0.3 -- 300ms for double-click
  
  if self._lastClickTime and self._lastClickButton == button and (currentTime - self._lastClickTime) < doubleClickThreshold then
    clickCount = self._clickCount + 1
  else
    clickCount = 1
  end
  
  self._clickCount = clickCount
  self._lastClickTime = currentTime
  self._lastClickButton = button
  
  -- Determine event type based on button
  local eventType = "click"
  if button == 2 then
    eventType = "rightclick"
  elseif button == 3 then
    eventType = "middleclick"
  end
  
  if element.onEvent then
    local clickEvent = InputEvent.new({
      type = eventType,
      button = button,
      x = x,
      y = y,
      modifiers = modifiers,
      clickCount = clickCount,
    })
    
    element.onEvent(element, clickEvent)
  end
  
  -- Mark as released
  self._pressed[button] = false
  
  -- Clean up drag tracking
  self._dragStartX[button] = nil
  self._dragStartY[button] = nil
  
  -- Fire release event
  if element.onEvent then
    local releaseEvent = InputEvent.new({
      type = "release",
      button = button,
      x = x,
      y = y,
      modifiers = modifiers,
      clickCount = clickCount,
    })
    element.onEvent(element, releaseEvent)
  end
  
  return true
end

--- Handle mouse move event
---@param x number Mouse X position
---@param y number Mouse Y position
---@param dx number Delta X
---@param dy number Delta Y
---@return boolean True if event was consumed
function EventHandler:handleMouseMove(x, y, dx, dy)
  if not self._element then
    return false
  end
  
  local element = self._element
  
  -- Check if any button is pressed (drag)
  for button, pressed in pairs(self._pressed) do
    if pressed then
      -- Fire drag event
      if element.onEvent then
        local modifiers = getModifiers()
        local dragDx = x - self._dragStartX[button]
        local dragDy = y - self._dragStartY[button]
        
        local dragEvent = InputEvent.new({
          type = "drag",
          button = button,
          x = x,
          y = y,
          dx = dragDx,
          dy = dragDy,
          modifiers = modifiers,
          clickCount = 1,
        })
        element.onEvent(element, dragEvent)
      end
      
      -- Update last mouse position
      self._lastMouseX[button] = x
      self._lastMouseY[button] = y
      
      return true
    end
  end
  
  return false
end

--- Handle key press event
---@param key string Key name
---@param scancode string Scancode
---@param isrepeat boolean Whether this is a key repeat
---@return boolean True if event was consumed
function EventHandler:handleKeyPress(key, scancode, isrepeat)
  if not self._element then
    return false
  end
  
  local element = self._element
  
  -- Only handle if element is focused (for editable elements)
  if element.editable and not element._focused then
    return false
  end
  
  -- Key events are handled by TextEditor for editable elements
  -- This is just a passthrough for custom key handling
  if element.onEvent then
    local modifiers = getModifiers()
    local keyEvent = InputEvent.new({
      type = "keypress",
      key = key,
      scancode = scancode,
      isrepeat = isrepeat,
      modifiers = modifiers,
      x = 0,
      y = 0,
      button = 0,
    })
    element.onEvent(element, keyEvent)
    return true
  end
  
  return false
end

--- Handle text input event
---@param text string Input text
---@return boolean True if event was consumed
function EventHandler:handleTextInput(text)
  if not self._element then
    return false
  end
  
  local element = self._element
  
  -- Only handle if element is focused (for editable elements)
  if element.editable and not element._focused then
    return false
  end
  
  -- Text input is handled by TextEditor for editable elements
  -- This is just a passthrough for custom text handling
  if element.onEvent then
    local modifiers = getModifiers()
    local textEvent = InputEvent.new({
      type = "textinput",
      text = text,
      modifiers = modifiers,
      x = 0,
      y = 0,
      button = 0,
    })
    element.onEvent(element, textEvent)
    return true
  end
  
  return false
end

--- Handle mouse wheel event
---@param x number Horizontal scroll amount
---@param y number Vertical scroll amount
---@return boolean True if event was consumed
function EventHandler:handleWheel(x, y)
  if not self._element then
    return false
  end
  
  local element = self._element
  
  -- Fire wheel event
  if element.onEvent then
    local mx, my = love.mouse.getPosition()
    local modifiers = getModifiers()
    local wheelEvent = InputEvent.new({
      type = "wheel",
      x = mx,
      y = my,
      dx = x,
      dy = y,
      modifiers = modifiers,
      button = 0,
    })
    element.onEvent(element, wheelEvent)
    return true
  end
  
  return false
end

--- Handle touch press event
---@param id any Touch ID
---@param x number Touch X position
---@param y number Touch Y position
---@return boolean True if event was consumed
function EventHandler:handleTouchPress(id, x, y)
  if not self._element then
    return false
  end
  
  local element = self._element
  
  -- Check if touch is within bounds
  local bx = element.x
  local by = element.y
  local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
  local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)
  
  if x < bx or x > bx + bw or y < by or y > by + bh then
    return false
  end
  
  -- Mark touch as pressed
  self._touchPressed[id] = true
  
  -- Fire touch press event (treat as left click)
  if element.onEvent then
    local modifiers = getModifiers()
    local touchEvent = InputEvent.new({
      type = "press",
      button = 1,
      x = x,
      y = y,
      modifiers = modifiers,
      clickCount = 1,
    })
    element.onEvent(element, touchEvent)
  end
  
  return true
end

--- Handle touch release event
---@param id any Touch ID
---@param x number Touch X position
---@param y number Touch Y position
---@return boolean True if event was consumed
function EventHandler:handleTouchRelease(id, x, y)
  if not self._element then
    return false
  end
  
  local element = self._element
  
  -- Only handle if touch was pressed
  if not self._touchPressed[id] then
    return false
  end
  
  -- Fire touch release event (treat as left click)
  if element.onEvent then
    local modifiers = getModifiers()
    local touchEvent = InputEvent.new({
      type = "click",
      button = 1,
      x = x,
      y = y,
      modifiers = modifiers,
      clickCount = 1,
    })
    element.onEvent(element, touchEvent)
  end
  
  -- Mark touch as released
  self._touchPressed[id] = false
  
  return true
end

--- Update hover state based on mouse position
---@param mouseX number Mouse X position
---@param mouseY number Mouse Y position
function EventHandler:updateHoverState(mouseX, mouseY)
  if not self._element then
    return
  end
  
  local element = self._element
  
  -- Check if mouse is hovering over element
  local bx = element.x
  local by = element.y
  local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
  local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)
  
  local isHovering = mouseX >= bx and mouseX <= bx + bw and mouseY >= by and mouseY <= by + bh
  
  -- Update hover state in element
  if element.themeComponent then
    if isHovering then
      element._themeState = "hover"
    else
      element._themeState = "normal"
    end
  end
end

--- Dispatch a custom event
---@param event InputEvent The event to dispatch
function EventHandler:dispatchEvent(event)
  if not self._element then
    return
  end
  
  local element = self._element
  
  if element.onEvent then
    element.onEvent(element, event)
  end
end

--- Check if a mouse button is currently pressed
---@param button number Mouse button (1=left, 2=right, 3=middle)
---@return boolean True if button is pressed
function EventHandler:isButtonPressed(button)
  return self._pressed[button] or false
end

--- Check if element is being dragged
---@return boolean True if element is being dragged
function EventHandler:isDragging()
  for _, pressed in pairs(self._pressed) do
    if pressed then
      return true
    end
  end
  return false
end

--- Get the current click count
---@return number Click count
function EventHandler:getClickCount()
  return self._clickCount
end

--- Reset all event state
function EventHandler:reset()
  self._pressed = {}
  self._lastClickTime = nil
  self._lastClickButton = nil
  self._clickCount = 0
  self._touchPressed = {}
  self._dragStartX = {}
  self._dragStartY = {}
  self._lastMouseX = {}
  self._lastMouseY = {}
  self._scrollbarPressHandled = false
end

return EventHandler
