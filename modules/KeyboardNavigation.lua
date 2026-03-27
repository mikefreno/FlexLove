local packageName = ... or "KeyboardNavigation"
local modulePath = packageName:match("(.-)[^%.]+$")

local function req(name)
  return require(modulePath .. name)
end

---@class KeyboardNavigation
---@field config KeyboardNavigationConfig
local KeyboardNavigation = {
  config = {
    -- Global settings
    enabled = true,
    debugMode = false,

    -- Key bindings
    keys = {
      next = "tab",
      previous = "shifttab",
      up = "up",
      down = "down",
      left = "left",
      right = "right",
      activate = {"return", "space"},
      dismiss = "escape",
      toggleDebug = "f12",
      inspect = "i",
    },

    -- Navigation behavior
    wrapAround = true,
    directionalNavigation = true,
    focusVisible = true,
    autofocusOnCreate = false,

    -- Developer tools
    developerTools = {
      enabled = true,
      showProperties = true,
      highlightColor = {1, 0.8, 0, 0.5},
    },

    -- Focus indicator style
    focusIndicator = {
      color = {0.2, 0.6, 1.0, 0.8},
      lineWidth = 2,
      inset = -3,
      borderRadius = 4,
      animationDuration = 0.15,
    },
  },

  -- State
  _navigationStack = {},
  _lastNavigationTime = 0,
  _inspectMode = false,
  _deps = nil,
}

--- Initialize KeyboardNavigation module
---@param deps table {Context, Element, ErrorHandler, utils, InputEvent}
function KeyboardNavigation.init(deps)
  KeyboardNavigation._deps = deps
  KeyboardNavigation._ErrorHandler = deps.ErrorHandler
  KeyboardNavigation._InputEvent = deps.InputEvent
  KeyboardNavigation._Context = deps.Context
  KeyboardNavigation._Element = deps.Element
  KeyboardNavigation._utils = deps.utils
end

--- Handle keyboard press for navigation
---@param key string
---@param scancode string
---@param isrepeat boolean
---@return boolean handled
function KeyboardNavigation:handleKeyPress(key, scancode, isrepeat)
  local config = KeyboardNavigation.config
  local keys = config.keys

  -- Check for activation keys
  for _, activateKey in ipairs(keys.activate) do
    if key == activateKey then
      return self:activateElement()
    end
  end

  -- Check for dismiss key
  if key == keys.dismiss then
    return self:dismissElement()
  end

  -- Check for next/previous navigation
  if key == keys.next then
    return self:nextFocusable()
  end

  if key == keys.previous then
    return self:previousFocusable()
  end

  -- Check for directional navigation
  if config.directionalNavigation then
    if key == keys.up then
      return self:navigateDirectional("up")
    elseif key == keys.down then
      return self:navigateDirectional("down")
    elseif key == keys.left then
      return self:navigateDirectional("left")
    elseif key == keys.right then
      return self:navigateDirectional("right")
    end
  end

  return false
end

--- Navigate to next focusable element (Tab)
---@return boolean success
function KeyboardNavigation:nextFocusable()
  local Context = KeyboardNavigation._Context
  local Element = KeyboardNavigation._Element

  local current = Context.getFocused()
  local container = Context.getNavigationContainer()

  -- Fallback to top-level elements
  if not container then
    if Context._immediateMode then
      container = Context._zIndexOrderedElements[1]
    else
      container = Context.topElements[1]
    end
  end

  if not container then
    return false
  end

  -- Find next focusable element
  local nextElem
  if Context._immediateMode then
    nextElem = self:_findNextInZIndexOrder(current, container)
  else
    nextElem = Element.getNextFocusable(container, current, KeyboardNavigation.config.wrapAround)
  end

  if nextElem then
    self:_focusElement(nextElem)
    return true
  end

  return false
end

--- Navigate to previous focusable element (Shift+Tab)
---@return boolean success
function KeyboardNavigation:previousFocusable()
  local Context = KeyboardNavigation._Context
  local Element = KeyboardNavigation._Element

  local current = Context.getFocused()
  local container = Context.getNavigationContainer()

  -- Fallback to top-level elements
  if not container then
    if Context._immediateMode then
      container = Context._zIndexOrderedElements[1]
    else
      container = Context.topElements[1]
    end
  end

  if not container then
    return false
  end

  -- Find previous focusable element
  local prevElem
  if Context._immediateMode then
    prevElem = self:_findPreviousInZIndexOrder(current, container)
  else
    prevElem = Element.getPreviousFocusable(container, current, KeyboardNavigation.config.wrapAround)
  end

  if prevElem then
    self:_focusElement(prevElem)
    return true
  end

  return false
end

--- Find next focusable in z-index order (immediate mode)
---@param current Element?
---@param container Element
---@return Element?
function KeyboardNavigation:_findNextInZIndexOrder(current, container)
  local Context = KeyboardNavigation._Context
  local elements = Context._zIndexOrderedElements
  local startIndex = 0

  if current then
    for i, elem in ipairs(elements) do
      if elem == current then
        startIndex = i
        break
      end
    end
  end

  -- Search forward
  for i = startIndex + 1, #elements do
    local elem = elements[i]
    if self:_isInContainer(elem, container) and elem:isFocusable() then
      return elem
    end
  end

  -- Wrap around
  if KeyboardNavigation.config.wrapAround then
    for i = 1, startIndex do
      local elem = elements[i]
      if self:_isInContainer(elem, container) and elem:isFocusable() then
        return elem
      end
    end
  end

  return nil
end

--- Find previous focusable in z-index order (immediate mode)
---@param current Element?
---@param container Element
---@return Element?
function KeyboardNavigation:_findPreviousInZIndexOrder(current, container)
  local Context = KeyboardNavigation._Context
  local elements = Context._zIndexOrderedElements
  local startIndex = #elements + 1

  if current then
    for i, elem in ipairs(elements) do
      if elem == current then
        startIndex = i
        break
      end
    end
  end

  -- Search backward
  for i = startIndex - 1, 1, -1 do
    local elem = elements[i]
    if self:_isInContainer(elem, container) and elem:isFocusable() then
      return elem
    end
  end

  -- Wrap around
  if KeyboardNavigation.config.wrapAround then
    for i = #elements, startIndex, -1 do
      local elem = elements[i]
      if self:_isInContainer(elem, container) and elem:isFocusable() then
        return elem
      end
    end
  end

  return nil
end

--- Check if element is within container tree
---@param element Element
---@param container Element
---@return boolean
function KeyboardNavigation:_isInContainer(element, container)
  local current = element.parent
  while current do
    if current == container then
      return true
    end
    current = current.parent
  end
  return false
end

--- Navigate using arrow keys
---@param direction "up"|"down"|"left"|"right"
---@return boolean success
function KeyboardNavigation:navigateDirectional(direction)
  local Context = KeyboardNavigation._Context
  local current = Context.getFocused()

  if not current then
    return false
  end

  local nextElem = KeyboardNavigation:_findDirectionalNeighbor(current, direction)

  if nextElem then
    self:_focusElement(nextElem)
    return true
  end

  return false
end

--- Find closest focusable element in the given direction
---@param current Element
---@param direction "up"|"down"|"left"|"right"
---@return Element?
function KeyboardNavigation:_findDirectionalNeighbor(current, direction)
  local Context = KeyboardNavigation._Context
  local container = Context.getNavigationContainer() or current.parent

  if not container then
    return nil
  end

  -- Get all focusable elements in container
  local focusable = container:getFocusableChildren()
  if #focusable == 0 then
    return nil
  end

  local currentRect = {
    x = current.x,
    y = current.y,
    width = current.width or 0,
    height = current.height or 0,
  }

  local closest = nil
  local closestDistance = math.huge

  for _, elem in ipairs(focusable) do
    if elem ~= current then
      local elemRect = {
        x = elem.x,
        y = elem.y,
        width = elem.width or 0,
        height = elem.height or 0,
      }

      local distance, isInDirection = self:_calculateDirectionalDistance(
        currentRect, elemRect, direction
      )

      if isInDirection and distance < closestDistance then
        closest = elem
        closestDistance = distance
      end
    end
  end

  -- If no element found in exact direction, try with looser criteria
  if not closest then
    closest = self:_findClosestInDirection(current, focusable, direction)
  end

  return closest
end

--- Calculate distance and direction between elements
---@param from table {x, y, width, height}
---@param to table {x, y, width, height}
---@param direction string
---@return number distance, boolean isInDirection
function KeyboardNavigation:_calculateDirectionalDistance(from, to, direction)
  -- Calculate bounding box edges
  local fromLeft = from.x
  local fromRight = from.x + from.width
  local fromTop = from.y
  local fromBottom = from.y + from.height

  local toLeft = to.x
  local toRight = to.x + to.width
  local toTop = to.y
  local toBottom = to.y + to.height

  local distance = math.huge
  local isInDirection = false

  if direction == "up" then
    if toBottom < fromTop then
      isInDirection = true
      distance = fromTop - toBottom
    end
  elseif direction == "down" then
    if toTop > fromBottom then
      isInDirection = true
      distance = toTop - fromBottom
    end
  elseif direction == "left" then
    if toRight < fromLeft then
      isInDirection = true
      distance = fromLeft - toRight
    end
  elseif direction == "right" then
    if toLeft > fromRight then
      isInDirection = true
      distance = toLeft - fromRight
    end
  end

  return distance, isInDirection
end

--- Find closest element in direction using center-to-center distance
---@param current Element
---@param focusable Element[]
---@param direction string
---@return Element?
function KeyboardNavigation:_findClosestInDirection(current, focusable, direction)
  local currentCenterX = current.x + (current.width or 0) / 2
  local currentCenterY = current.y + (current.height or 0) / 2

  local closest = nil
  local closestDistance = math.huge

  for _, elem in ipairs(focusable) do
    if elem ~= current then
      local elemCenterX = elem.x + (elem.width or 0) / 2
      local elemCenterY = elem.y + (elem.height or 0) / 2

      local dx = elemCenterX - currentCenterX
      local dy = elemCenterY - currentCenterY

      -- Check if element is generally in the right direction
      local isInDirection = false

      if direction == "up" and dy < 0 then
        isInDirection = true
      elseif direction == "down" and dy > 0 then
        isInDirection = true
      elseif direction == "left" and dx < 0 then
        isInDirection = true
      elseif direction == "right" and dx > 0 then
        isInDirection = true
      end

      if isInDirection then
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance < closestDistance then
          closest = elem
          closestDistance = distance
        end
      end
    end
  end

  return closest
end

--- Focus an element
---@param element Element
function KeyboardNavigation:_focusElement(element)
  local Context = KeyboardNavigation._Context

  if element and element:isFocusable() then
    Context.setFocused(element)

    -- Call onFocus callback if it exists
    if element.onFocus then
      local success, err = pcall(function()
        if element.onFocusDeferred then
          table.insert(Context._deferredCallbacks or {}, function()
            element:onFocus(element)
          end)
        else
          element:onFocus(element)
        end
      end)

      if not success then
        KeyboardNavigation._ErrorHandler:warn("KeyboardNavigation", "FOCUS_001", {
          elementId = element.id or "unknown",
          error = tostring(err),
        })
      end
    end
  end
end

--- Activate currently focused element
---@return boolean success
function KeyboardNavigation:activateElement()
  local Context = KeyboardNavigation._Context
  local focused = Context.getFocused()

  if not focused then
    return false
  end

  -- Fire press and release events
  if focused.onEvent then
    local modifiers = KeyboardNavigation._utils.getModifiers()
    local pressEvent = KeyboardNavigation._InputEvent.new({
      type = "press",
      button = 1,
      x = focused.x,
      y = focused.y,
      modifiers = modifiers,
      clickCount = 1,
    })

    local releaseEvent = KeyboardNavigation._InputEvent.new({
      type = "release",
      button = 1,
      x = focused.x,
      y = focused.y,
      modifiers = modifiers,
      clickCount = 1,
    })

    local success, err = pcall(function()
      focused.onEvent(focused, pressEvent)
      focused.onEvent(focused, releaseEvent)
    end)

    if not success then
      KeyboardNavigation._ErrorHandler:warn("KeyboardNavigation", "ACTIVATE_001", {
        elementId = focused.id or "unknown",
        error = tostring(err),
      })
    end

    return true
  end

  return false
end

--- Dismiss currently focused element
---@return boolean success
function KeyboardNavigation:dismissElement()
  local Context = KeyboardNavigation._Context
  local focused = Context.getFocused()

  if not focused then
    return false
  end

  -- Check if element has a dismiss handler
  if focused.onDismiss then
    local success, err = pcall(function()
      if focused.onDismissDeferred then
        table.insert(Context._deferredCallbacks or {}, function()
          focused:onDismiss(focused)
        end)
      else
        focused:onDismiss(focused)
      end
    end)

    if not success then
      KeyboardNavigation._ErrorHandler:warn("KeyboardNavigation", "DISMISS_001", {
        elementId = focused.id or "unknown",
        error = tostring(err),
      })
    end

    return true
  end

  -- Default behavior: blur the element
  Context.clearFocus()
  return true
end

--- Update keyboard navigation (for animations, etc.)
---@param dt number
function KeyboardNavigation:update(dt)
  -- Update focus indicator if it exists
  if KeyboardNavigation.FocusIndicator then
    KeyboardNavigation.FocusIndicator:update(dt)
  end
end

--- Push current focus onto stack (for modals/dialogs)
---@param element Element?
function KeyboardNavigation:pushFocus(element)
  local Context = KeyboardNavigation._Context

  table.insert(KeyboardNavigation._navigationStack, Context.getFocused())
  Context.pushFocusStack(element)
end

--- Pop focus from stack (return from modal)
---@return Element?
function KeyboardNavigation:popFocus()
  local Context = KeyboardNavigation._Context

  local previous = Context.popFocusStack()
  if #KeyboardNavigation._navigationStack > 0 then
    previous = table.remove(KeyboardNavigation._navigationStack)
  end

  return previous
end

--- Set key binding
---@param keyName string
---@param keyBinding string|table
function KeyboardNavigation.setKeyBinding(keyName, keyBinding)
  KeyboardNavigation.config.keys[keyName] = keyBinding
end

--- Enable/disable directional navigation
---@param enabled boolean
function KeyboardNavigation.setDirectionalNavigation(enabled)
  KeyboardNavigation.config.directionalNavigation = enabled
end

--- Enable/disable tab wrapping
---@param enabled boolean
function KeyboardNavigation.setWrapAround(enabled)
  KeyboardNavigation.config.wrapAround = enabled
end

return KeyboardNavigation
