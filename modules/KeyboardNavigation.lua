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
      activate = { "return", "space" },
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
      highlightColor = { 1, 0.8, 0, 0.5 },
    },

    -- Focus indicator style
    focusIndicator = {
      color = { 0.2, 0.6, 1.0, 0.8 },
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

  -- Spatial index for directional navigation (performance optimization)
  _spatialIndex = {
    enabled = false,
    cellSize = 100, -- Grid cell size in pixels
    grid = {}, -- Grid storing element references
    elementPositions = {}, -- Cache of element positions {element = {x, y, w, h}}
    lastUpdateFrame = 0,
  },
}

--- Initialize KeyboardNavigation module
---@param deps table {Context, Element, ErrorHandler, utils, InputEvent}
function KeyboardNavigation.init(deps)
  -- Validate required dependencies
  local required = { Context = true, Element = true, ErrorHandler = true, utils = true, InputEvent = true }
  for depName, _ in pairs(required) do
    if not deps[depName] then
      error(string.format("KeyboardNavigation.init: Missing required dependency: %s", depName))
    end
  end

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
  -- Debug logging
  if KeyboardNavigation.config.debugMode then
    print(string.format("[KeyboardNavigation] Key pressed: %s (scancode: %s, repeat: %s)", key, scancode, tostring(isrepeat)))
    print(string.format("[KeyboardNavigation] Enabled: %s", tostring(KeyboardNavigation.config.enabled)))
  end

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
  if KeyboardNavigation.config.debugMode then
    print(string.format("[KeyboardNavigation] Tab pressed - Current focus: %s", tostring(current and current.id or "nil")))
  end

  local nextElem
  if Context._immediateMode then
    nextElem = self:_findNextInZIndexOrder(current)
  else
    local container = Context.getNavigationContainer() or Context.topElements[1]
    if not container then
      return false
    end
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

  local prevElem
  if Context._immediateMode then
    prevElem = self:_findPreviousInZIndexOrder(current)
  else
    local container = Context.getNavigationContainer() or Context.topElements[1]
    if not container then
      return false
    end
    prevElem = Element.getPreviousFocusable(container, current, KeyboardNavigation.config.wrapAround)
  end

  if prevElem then
    self:_focusElement(prevElem)
    return true
  end

  return false
end

--- Get the highest z-index top-level root element (no parent) for navigation scoping.
--- Keyboard navigation is restricted to the topmost visible screen.
---@return Element?
function KeyboardNavigation:_getNavigationRoot()
  local Context = KeyboardNavigation._Context

  -- Gather all top-level elements (no parent) from the z-index ordered list
  local topRoots = {}
  local seen = {}
  for _, elem in ipairs(Context._zIndexOrderedElements) do
    -- Walk to the true root
    local root = elem
    while root.parent do
      root = root.parent
    end
    if not seen[root] then
      seen[root] = true
      table.insert(topRoots, root)
    end
  end

  if #topRoots == 0 then
    return nil
  end

  -- Return the root with the highest z-index (last one when sorted ascending)
  local best = topRoots[1]
  for i = 2, #topRoots do
    if (topRoots[i].z or 0) >= (best.z or 0) then
      best = topRoots[i]
    end
  end
  return best
end

--- Collect focusable elements in document/flex-flow order from a root element.
--- Respects tabIndex: elements with tabIndex are sorted by that value first,
--- elements without tabIndex follow in natural document order after those with tabIndex.
---@param root Element
---@return Element[]
function KeyboardNavigation:_collectFocusablesInOrder(root)
  local withTabIndex = {}
  local withoutTabIndex = {}

  local function collect(elem)
    if elem:isFocusable() then
      if elem.tabIndex ~= nil then
        table.insert(withTabIndex, elem)
      else
        table.insert(withoutTabIndex, elem)
      end
    end
    for _, child in ipairs(elem.children) do
      collect(child)
    end
  end

  collect(root)

  -- Sort elements with explicit tabIndex by their tabIndex value
  table.sort(withTabIndex, function(a, b)
    return (a.tabIndex or 0) < (b.tabIndex or 0)
  end)

  -- Merge: tabIndex elements first, then document-order elements
  local result = {}
  for _, elem in ipairs(withTabIndex) do
    table.insert(result, elem)
  end
  for _, elem in ipairs(withoutTabIndex) do
    table.insert(result, elem)
  end

  return result
end

--- Find next focusable in document/flex-flow order (immediate mode)
---@param current Element?
---@return Element?
function KeyboardNavigation:_findNextInZIndexOrder(current)
  local root = self:_getNavigationRoot()
  if not root then
    return nil
  end

  local elements = self:_collectFocusablesInOrder(root)
  local startIndex = 0

  if current then
    for i, elem in ipairs(elements) do
      if elem.id == current.id then
        startIndex = i
        break
      end
    end
  end

  -- Search forward
  for i = startIndex + 1, #elements do
    return elements[i]
  end

  -- Wrap around
  if KeyboardNavigation.config.wrapAround and startIndex > 0 then
    if #elements > 0 then
      return elements[1]
    end
  elseif KeyboardNavigation.config.wrapAround and startIndex == 0 then
    if #elements > 0 then
      return elements[1]
    end
  end

  return nil
end

--- Find previous focusable in document/flex-flow order (immediate mode)
---@param current Element?
---@return Element?
function KeyboardNavigation:_findPreviousInZIndexOrder(current)
  local root = self:_getNavigationRoot()
  if not root then
    return nil
  end

  local elements = self:_collectFocusablesInOrder(root)
  local startIndex = #elements + 1

  if current then
    for i, elem in ipairs(elements) do
      if elem.id == current.id then
        startIndex = i
        break
      end
    end
  end

  -- Search backward
  if startIndex - 1 >= 1 then
    return elements[startIndex - 1]
  end

  -- Wrap around
  if KeyboardNavigation.config.wrapAround and #elements > 0 then
    return elements[#elements]
  end

  return nil
end

--- Check if element is within container tree
---@param element Element
---@param container Element
---@return boolean
function KeyboardNavigation:_isInContainer(element, container)
  -- Direct match: element IS the container's child at some depth
  local current = element.parent
  while current do
    if current == container then
      return true
    end
    current = current.parent
  end
  -- Also accept elements that share the same top-level ancestor as container
  -- (handles immediate mode where container is a top-level element)
  local function getRoot(elem)
    local e = elem
    while e.parent do
      e = e.parent
    end
    return e
  end
  return getRoot(element) == getRoot(container)
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
  -- Try spatial index first if enabled
  if KeyboardNavigation._spatialIndex.enabled then
    local spatialResult = self:_findDirectionalNeighborSpatial(current, direction)
    if spatialResult then
      return spatialResult
    end
  end

  -- Collect all focusable elements visible this frame
  local Context = KeyboardNavigation._Context
  local focusable = {}

  local function collectFocusable(elem)
    if elem:isFocusable() and elem ~= current then
      table.insert(focusable, elem)
    end
    for _, child in ipairs(elem.children) do
      collectFocusable(child)
    end
  end

  if Context._immediateMode and Context._zIndexOrderedElements then
    -- In immediate mode: only consider focusables within the highest-z-index root
    local root = self:_getNavigationRoot()
    if root then
      local function collectFocusable(elem)
        if elem ~= current and elem:isFocusable() then
          table.insert(focusable, elem)
        end
        for _, child in ipairs(elem.children) do
          collectFocusable(child)
        end
      end
      collectFocusable(root)
    end
  else
    -- Retained mode: walk element trees
    local container = Context.getNavigationContainer()
    local roots = container and { container } or Context.topElements
    for _, root in ipairs(roots) do
      collectFocusable(root)
    end
  end

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
    local elemRect = {
      x = elem.x,
      y = elem.y,
      width = elem.width or 0,
      height = elem.height or 0,
    }

    local distance, isInDirection = self:_calculateDirectionalDistance(currentRect, elemRect, direction)

    if isInDirection and distance < closestDistance then
      closest = elem
      closestDistance = distance
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
    if KeyboardNavigation.config.debugMode then
      print(string.format("[KeyboardNavigation] Focusing element: %s (id: %s)", element.themeComponent or "unknown", tostring(element.id)))
    end
    Context.setFocused(element)

    -- Update focus indicator
    if KeyboardNavigation.FocusIndicator then
      KeyboardNavigation.FocusIndicator.setFocused(element)
    end

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

    return true -- Handler took care of dismissal
  end

  -- Default behavior: blur the element (only if no onDismiss handler)
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

-- ====================
-- Spatial Index (Performance Optimization)
-- ====================

--- Enable spatial index for faster directional navigation
---@param enabled boolean
function KeyboardNavigation.enableSpatialIndex(enabled)
  KeyboardNavigation._spatialIndex.enabled = enabled
  if not enabled then
    KeyboardNavigation:_clearSpatialIndex()
  end
end

--- Set spatial index cell size (larger = fewer cells, faster lookup but less precision)
---@param cellSize number
function KeyboardNavigation.setSpatialCellSize(cellSize)
  KeyboardNavigation._spatialIndex.cellSize = cellSize
  KeyboardNavigation:_clearSpatialIndex()
end

--- Update spatial index (call when layout changes)
function KeyboardNavigation:updateSpatialIndex()
  local Context = KeyboardNavigation._Context
  if not Context then
    return
  end

  local index = KeyboardNavigation._spatialIndex
  local cellSize = index.cellSize

  -- Clear old index
  KeyboardNavigation:_clearSpatialIndex()

  -- Collect all focusable elements and their positions
  local function collectElements(elem)
    if elem and elem:isFocusable() then
      local w = elem.width or 0
      local h = elem.height or 0
      index.elementPositions[elem] = { x = elem.x, y = elem.y, w = w, h = h }

      -- Add to grid cells (element can span multiple cells)
      local leftCell = math.floor(elem.x / cellSize)
      local rightCell = math.floor((elem.x + w - 1) / cellSize)
      local topCell = math.floor(elem.y / cellSize)
      local bottomCell = math.floor((elem.y + h - 1) / cellSize)

      for gx = leftCell, rightCell do
        for gy = topCell, bottomCell do
          local cellKey = string.format("%d,%d", gx, gy)
          if not index.grid[cellKey] then
            index.grid[cellKey] = {}
          end
          table.insert(index.grid[cellKey], elem)
        end
      end
    end

    -- Recurse into children
    if elem and elem.children then
      for _, child in ipairs(elem.children) do
        collectElements(child)
      end
    end
  end

  -- Collect from top-level elements
  if Context._immediateMode and Context._zIndexOrderedElements then
    for _, elem in ipairs(Context._zIndexOrderedElements) do
      collectElements(elem)
    end
  elseif Context.topElements then
    for _, elem in ipairs(Context.topElements) do
      collectElements(elem)
    end
  end
end

--- Clear spatial index
function KeyboardNavigation:_clearSpatialIndex()
  KeyboardNavigation._spatialIndex.grid = {}
  KeyboardNavigation._spatialIndex.elementPositions = {}
end

--- Find directional neighbor using spatial index
---@param current Element
---@param direction "up"|"down"|"left"|"right"
---@return Element?
function KeyboardNavigation:_findDirectionalNeighborSpatial(current, direction)
  local index = KeyboardNavigation._spatialIndex
  local cellSize = index.cellSize

  -- Get current element's grid position
  local currentPos = index.elementPositions[current]
  if not currentPos then
    return nil
  end

  local centerX = currentPos.x + currentPos.w / 2
  local centerY = currentPos.y + currentPos.h / 2
  local currentCellX = math.floor(centerX / cellSize)
  local currentCellY = math.floor(centerY / cellSize)

  -- Search in direction, expanding outward
  local maxSearchRadius = 20 -- Maximum cells to search
  local visited = {}

  for radius = 1, maxSearchRadius do
    local candidates = {}

    -- Get cells in the search ring
    if direction == "up" then
      table.insert(candidates, { currentCellX, currentCellY - radius })
      if radius > 1 then
        table.insert(candidates, { currentCellX - 1, currentCellY - radius })
        table.insert(candidates, { currentCellX + 1, currentCellY - radius })
      end
    elseif direction == "down" then
      table.insert(candidates, { currentCellX, currentCellY + radius })
      if radius > 1 then
        table.insert(candidates, { currentCellX - 1, currentCellY + radius })
        table.insert(candidates, { currentCellX + 1, currentCellY + radius })
      end
    elseif direction == "left" then
      table.insert(candidates, { currentCellX - radius, currentCellY })
      if radius > 1 then
        table.insert(candidates, { currentCellX - radius, currentCellY - 1 })
        table.insert(candidates, { currentCellX - radius, currentCellY + 1 })
      end
    elseif direction == "right" then
      table.insert(candidates, { currentCellX + radius, currentCellY })
      if radius > 1 then
        table.insert(candidates, { currentCellX + radius, currentCellY - 1 })
        table.insert(candidates, { currentCellX + radius, currentCellY + 1 })
      end
    end

    -- Check each candidate cell
    for _, cell in ipairs(candidates) do
      local cellKey = string.format("%d,%d", cell[1], cell[2])
      local cellElements = index.grid[cellKey]

      if cellElements then
        for _, elem in ipairs(cellElements) do
          if elem ~= current and not visited[elem] then
            visited[elem] = true
            local elemPos = index.elementPositions[elem]
            if elemPos then
              local elemCenterX = elemPos.x + elemPos.w / 2
              local elemCenterY = elemPos.y + elemPos.h / 2

              -- Check if element is in the correct direction
              local isInDirection = false
              if direction == "up" and elemCenterY < centerY then
                isInDirection = true
              elseif direction == "down" and elemCenterY > centerY then
                isInDirection = true
              elseif direction == "left" and elemCenterX < centerX then
                isInDirection = true
              elseif direction == "right" and elemCenterX > centerX then
                isInDirection = true
              end

              if isInDirection then
                return elem
              end
            end
          end
        end
      end
    end
  end

  return nil
end

return KeyboardNavigation
