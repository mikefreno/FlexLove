---@class EventHandler
---@field onEvent fun(element:Element, event:InputEvent)?
---@field onEventDeferred boolean?
---@field _pressed table<number, boolean>
---@field _lastClickTime number?
---@field _lastClickButton number?
---@field _clickCount number
---@field _dragStartX table<number, number>
---@field _dragStartY table<number, number>
---@field _lastMouseX table<number, number>
---@field _lastMouseY table<number, number>
---@field _touchPressed table<number, boolean>
---@field _hovered boolean
---@field _element Element?
---@field _scrollbarPressHandled boolean
---@field _InputEvent table
---@field _Context table
---@field _utils table
local EventHandler = {}
EventHandler.__index = EventHandler

--- Create a new EventHandler instance
---@param config table Configuration options
---@param deps table Dependencies {InputEvent, Context, utils}
---@return EventHandler
function EventHandler.new(config, deps)
  config = config or {}

  local self = setmetatable({}, EventHandler)

  self._InputEvent = deps.InputEvent
  self._Context = deps.Context
  self._utils = deps.utils

  self.onEvent = config.onEvent
  self.onEventDeferred = config.onEventDeferred

  self._pressed = config._pressed or {}

  self._lastClickTime = config._lastClickTime
  self._lastClickButton = config._lastClickButton
  self._clickCount = config._clickCount or 0

  self._dragStartX = config._dragStartX or {}
  self._dragStartY = config._dragStartY or {}
  self._lastMouseX = config._lastMouseX or {}
  self._lastMouseY = config._lastMouseY or {}

  self._touchPressed = config._touchPressed or {}

  self._hovered = config._hovered or false

  self._element = nil

  self._scrollbarPressHandled = false

  return self
end

--- Initialize EventHandler with parent element reference
---@param element Element The parent element
function EventHandler:initialize(element)
  self._element = element
end

--- Get state for persistence (for immediate mode)
---@return table State data
function EventHandler:getState()
  return {
    _pressed = self._pressed,
    _lastClickTime = self._lastClickTime,
    _lastClickButton = self._lastClickButton,
    _clickCount = self._clickCount,
    _dragStartX = self._dragStartX,
    _dragStartY = self._dragStartY,
    _lastMouseX = self._lastMouseX,
    _lastMouseY = self._lastMouseY,
    _hovered = self._hovered,
  }
end

--- Restore state from persistence (for immediate mode)
---@param state table State data
function EventHandler:setState(state)
  if not state then
    return
  end

  self._pressed = state._pressed or {}
  self._lastClickTime = state._lastClickTime
  self._lastClickButton = state._lastClickButton
  self._clickCount = state._clickCount or 0
  self._dragStartX = state._dragStartX or {}
  self._dragStartY = state._dragStartY or {}
  self._lastMouseX = state._lastMouseX or {}
  self._lastMouseY = state._lastMouseY or {}
  self._hovered = state._hovered or false
end

--- Process mouse button events in the update cycle
---@param mx number Mouse X position
---@param my number Mouse Y position
---@param isHovering boolean Whether mouse is over element
---@param isActiveElement boolean Whether this is the top element at mouse position
function EventHandler:processMouseEvents(mx, my, isHovering, isActiveElement)
  -- Start performance timing
  local Performance = package.loaded["modules.Performance"] or package.loaded["libs.modules.Performance"]
  if Performance and Performance.isEnabled() then
    Performance.startTimer("event_mouse")
  end

  if not self._element then
    if Performance and Performance.isEnabled() then
      Performance.stopTimer("event_mouse")
    end
    return
  end

  local element = self._element

  -- Check if currently dragging (allows drag continuation even if occluded)
  local isDragging = false
  for _, button in ipairs({ 1, 2, 3 }) do
    if self._pressed[button] and love.mouse.isDown(button) then
      isDragging = true
      break
    end
  end

  -- Check if any button is currently pressed (tracked state)
  local hasTrackedPress = false
  for _, button in ipairs({ 1, 2, 3 }) do
    if self._pressed[button] then
      hasTrackedPress = true
      break
    end
  end

  -- Can only process events if we have handler, element is enabled, and is active or dragging or has tracked press
  local canProcessEvents = (self.onEvent or element.editable) and not element.disabled and (isActiveElement or isDragging or hasTrackedPress)

  if not canProcessEvents then
    -- If not hovering and no buttons are physically pressed, reset all pressed states
    -- This ensures the pressed state is cleared when mouse leaves without button held
    if not isHovering and not isDragging then
      for _, button in ipairs({ 1, 2, 3 }) do
        if self._pressed[button] and not love.mouse.isDown(button) then
          self._pressed[button] = false
          self._dragStartX[button] = nil
          self._dragStartY[button] = nil
        end
      end
    end
    if Performance and Performance.isEnabled() then
      Performance.stopTimer("event_mouse")
    end
    return
  end

  -- Process all three mouse buttons
  local buttons = { 1, 2, 3 } -- left, right, middle

  for _, button in ipairs(buttons) do
    -- Check if this button was tracked as pressed
    local wasPressed = self._pressed[button]
    local isPhysicallyPressed = love.mouse.isDown(button)

    if isHovering or isDragging or wasPressed then
      if isPhysicallyPressed then
        -- Button is pressed down
        if not wasPressed then
          -- Just pressed - fire press event (only if hovering)
          if isHovering then
            self:_handleMousePress(mx, my, button)
          end
        else
          -- Button is still pressed - check for drag
          self:_handleMouseDrag(mx, my, button, isHovering)
        end
      elseif wasPressed then
        -- Button was just released
        -- Only fire click and release events if mouse is still hovering AND element is active
        -- (not occluded by another element)
        if isHovering and isActiveElement then
          self:_handleMouseRelease(mx, my, button)
        else
          -- Mouse left before release OR element is occluded - just clear the pressed state without firing events
          self._pressed[button] = false
          self._dragStartX[button] = nil
          self._dragStartY[button] = nil
        end
      end
    end
  end

  -- After processing events, reset pressed states for buttons that are no longer held
  -- This handles the case where mouse leaves while button is held, then released
  if not isHovering and not isDragging then
    for _, button in ipairs({ 1, 2, 3 }) do
      if self._pressed[button] and not love.mouse.isDown(button) then
        self._pressed[button] = false
        self._dragStartX[button] = nil
        self._dragStartY[button] = nil
      end
    end
  end
  
  -- Stop performance timing
  if Performance and Performance.isEnabled() then
    Performance.stopTimer("event_mouse")
  end
end

--- Handle mouse button press
---@param mx number Mouse X position
---@param my number Mouse Y position
---@param button number Mouse button (1=left, 2=right, 3=middle)
function EventHandler:_handleMousePress(mx, my, button)
  if not self._element then
    return
  end

  local element = self._element

  -- Check if press is on scrollbar first (skip if already handled)
  if button == 1 and not self._scrollbarPressHandled and element._handleScrollbarPress then
    if element:_handleScrollbarPress(mx, my, button) then
      -- Scrollbar consumed the event, mark as pressed to prevent onEvent
      self._pressed[button] = true
      self._scrollbarPressHandled = true
      return
    end
  end

  -- Fire press event
  local modifiers = self._utils.getModifiers()
  local pressEvent = self._InputEvent.new({
    type = "press",
    button = button,
    x = mx,
    y = my,
    modifiers = modifiers,
    clickCount = 1,
  })
  self:_invokeCallback(element, pressEvent)

  self._pressed[button] = true

  -- Set mouse down position for text selection on left click
  if button == 1 and element._textEditor then
    element._mouseDownPosition = element._textEditor:mouseToTextPosition(mx, my)
    element._textDragOccurred = false -- Reset drag flag on press
  end

  -- Record drag start position per button
  self._dragStartX[button] = mx
  self._dragStartY[button] = my
  self._lastMouseX[button] = mx
  self._lastMouseY[button] = my
end

--- Handle mouse drag (while button is pressed and mouse moves)
---@param mx number Mouse X position
---@param my number Mouse Y position
---@param button number Mouse button
---@param isHovering boolean Whether mouse is over element
function EventHandler:_handleMouseDrag(mx, my, button, isHovering)
  if not self._element then
    return
  end

  local element = self._element

  local lastX = self._lastMouseX[button] or mx
  local lastY = self._lastMouseY[button] or my

  if lastX ~= mx or lastY ~= my then
    -- Mouse has moved - fire drag event only if still hovering
    if isHovering then
      local modifiers = self._utils.getModifiers()
      local dx = mx - self._dragStartX[button]
      local dy = my - self._dragStartY[button]

      local dragEvent = self._InputEvent.new({
        type = "drag",
        button = button,
        x = mx,
        y = my,
        dx = dx,
        dy = dy,
        modifiers = modifiers,
        clickCount = 1,
      })
      self:_invokeCallback(element, dragEvent)
    end

    -- Handle text selection drag for editable elements
    if button == 1 and element.editable and element._focused and element._handleTextDrag then
      element:_handleTextDrag(mx, my)
    end

    -- Update last known position for this button
    self._lastMouseX[button] = mx
    self._lastMouseY[button] = my
  end
end

--- Handle mouse button release
---@param mx number Mouse X position
---@param my number Mouse Y position
---@param button number Mouse button
function EventHandler:_handleMouseRelease(mx, my, button)
  if not self._element then
    return
  end

  local element = self._element

  local currentTime = love.timer.getTime()
  local modifiers = self._utils.getModifiers()

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

  -- Fire click event
  local clickEvent = self._InputEvent.new({
    type = eventType,
    button = button,
    x = mx,
    y = my,
    modifiers = modifiers,
    clickCount = clickCount,
  })
  self:_invokeCallback(element, clickEvent)

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
    if element._handleTextClick and not element._textDragOccurred then
      element:_handleTextClick(mx, my, clickCount)
    end

    -- Reset drag flag after release
    element._textDragOccurred = false
  end

  -- Fire release event
  local releaseEvent = self._InputEvent.new({
    type = "release",
    button = button,
    x = mx,
    y = my,
    modifiers = modifiers,
    clickCount = clickCount,
  })
  self:_invokeCallback(element, releaseEvent)
end

--- Process touch events in the update cycle
function EventHandler:processTouchEvents()
  if not self._element then
    return
  end

  local element = self._element

  local bx = element.x
  local by = element.y
  local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
  local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)

  local touches = love.touch.getTouches()
  for _, id in ipairs(touches) do
    local tx, ty = love.touch.getPosition(id)
    if tx >= bx and tx <= bx + bw and ty >= by and ty <= by + bh then
      self._touchPressed[id] = true
    elseif self._touchPressed[id] then
      -- Create touch event (treat as left click)
      local touchEvent = self._InputEvent.new({
        type = "click",
        button = 1,
        x = tx,
        y = ty,
        modifiers = self._utils.getModifiers(),
        clickCount = 1,
      })
      self:_invokeCallback(element, touchEvent)
      self._touchPressed[id] = false
    end
  end
end

--- Reset scrollbar press flag (called each frame)
function EventHandler:resetScrollbarPressFlag()
  self._scrollbarPressHandled = false
end

--- Check if any mouse button is pressed
---@return boolean True if any button is pressed
function EventHandler:isAnyButtonPressed()
  for _, pressed in pairs(self._pressed) do
    if pressed then
      return true
    end
  end
  return false
end

--- Check if a specific button is pressed
---@param button number Mouse button (1=left, 2=right, 3=middle)
---@return boolean True if button is pressed
function EventHandler:isButtonPressed(button)
  return self._pressed[button] == true
end

--- Invoke the onEvent callback, optionally deferring it if onEventDeferred is true
---@param element Element The element that triggered the event
---@param event InputEvent The event data
function EventHandler:_invokeCallback(element, event)
  if not self.onEvent then
    return
  end

  if self.onEventDeferred then
    -- Get FlexLove module to defer the callback
    local FlexLove = package.loaded["FlexLove"] or package.loaded["libs.FlexLove"]
    if FlexLove and FlexLove.deferCallback then
      FlexLove.deferCallback(function()
        self.onEvent(element, event)
      end)
    else
      -- Fallback: execute immediately if FlexLove not available
      self.onEvent(element, event)
    end
  else
    -- Execute immediately
    self.onEvent(element, event)
  end
end

return EventHandler
