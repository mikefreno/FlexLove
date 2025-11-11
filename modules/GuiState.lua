-- ====================
-- GUI State Module
-- ====================
-- Shared state between Gui and Element to avoid circular dependencies

---@class GuiState
local GuiState = {
  -- Top-level elements
  topElements = {},

  -- Base scale configuration
  baseScale = nil, -- {width: number, height: number}

  -- Current scale factors
  scaleFactors = { x = 1.0, y = 1.0 },

  -- Default theme name
  defaultTheme = nil,

  -- Currently focused element (for keyboard input)
  _focusedElement = nil,

  -- Active event element (for current frame)
  _activeEventElement = nil,

  -- Cached viewport dimensions
  _cachedViewport = { width = 0, height = 0 },

  -- Immediate mode state
  _immediateMode = false,
  _frameNumber = 0,
  _currentFrameElements = {},
  _immediateModeState = nil, -- Will be initialized if immediate mode is enabled
  _frameStarted = false,
  _autoBeganFrame = false,

  -- Z-index ordered element tracking for immediate mode
  _zIndexOrderedElements = {}, -- Array of elements sorted by z-index (lowest to highest)
}

--- Get current scale factors
---@return number, number -- scaleX, scaleY
function GuiState.getScaleFactors()
  return GuiState.scaleFactors.x, GuiState.scaleFactors.y
end

--- Register an element in the z-index ordered tree (for immediate mode)
---@param element Element The element to register
function GuiState.registerElement(element)
  if not GuiState._immediateMode then
    return
  end

  -- Add element to the z-index ordered list
  table.insert(GuiState._zIndexOrderedElements, element)
end

--- Clear frame elements (called at start of each immediate mode frame)
function GuiState.clearFrameElements()
  GuiState._zIndexOrderedElements = {}
end

--- Sort elements by z-index (called after all elements are registered)
function GuiState.sortElementsByZIndex()
  -- Sort elements by z-index (lowest to highest)
  -- We need to consider parent-child relationships and z-index
  table.sort(GuiState._zIndexOrderedElements, function(a, b)
    -- Calculate effective z-index considering parent hierarchy
    local function getEffectiveZIndex(elem)
      local z = elem.z or 0
      local parent = elem.parent
      while parent do
        z = z + (parent.z or 0) * 1000 -- Parent z-index has much higher weight
        parent = parent.parent
      end
      return z
    end

    return getEffectiveZIndex(a) < getEffectiveZIndex(b)
  end)
end

--- Check if a point is inside an element's bounds, respecting scroll and clipping
---@param element Element The element to check
---@param x number Screen X coordinate
---@param y number Screen Y coordinate
---@return boolean True if point is inside element bounds
local function isPointInElement(element, x, y)
  -- Get element bounds
  local bx = element.x
  local by = element.y
  local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
  local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)

  -- Walk up parent chain to check clipping and apply scroll offsets
  local current = element.parent
  while current do
    local overflowX = current.overflowX or current.overflow
    local overflowY = current.overflowY or current.overflow

    -- Check if parent clips content (overflow: hidden, scroll, auto)
    if overflowX == "hidden" or overflowX == "scroll" or overflowX == "auto" or overflowY == "hidden" or overflowY == "scroll" or overflowY == "auto" then
      -- Check if point is outside parent's clipping region
      local parentX = current.x + current.padding.left
      local parentY = current.y + current.padding.top
      local parentW = current.width
      local parentH = current.height

      if x < parentX or x > parentX + parentW or y < parentY or y > parentY + parentH then
        return false -- Point is clipped by parent
      end
    end

    current = current.parent
  end

  -- Check if point is inside element bounds
  return x >= bx and x <= bx + bw and y >= by and y <= by + bh
end

--- Get the topmost element at a screen position
---@param x number Screen X coordinate
---@param y number Screen Y coordinate
---@return Element|nil The topmost element at the position, or nil if none
function GuiState.getTopElementAt(x, y)
  if not GuiState._immediateMode then
    return nil
  end

  -- Helper function to find the first interactive ancestor (including self)
  local function findInteractiveAncestor(elem)
    local current = elem
    while current do
      -- An element is interactive if it has an onEvent handler, themeComponent, or is editable
      if current.onEvent or current.themeComponent or current.editable then
        return current
      end
      current = current.parent
    end
    return nil
  end

  -- Traverse from highest to lowest z-index (reverse order)
  for i = #GuiState._zIndexOrderedElements, 1, -1 do
    local element = GuiState._zIndexOrderedElements[i]

    -- Check if point is inside this element
    if isPointInElement(element, x, y) then
      -- Return the first interactive ancestor (or the element itself if interactive)
      local interactive = findInteractiveAncestor(element)
      if interactive then
        return interactive
      end
      -- If no interactive ancestor, return the element itself
      -- This preserves backward compatibility for non-interactive overlays
      return element
    end
  end

  return nil
end

return GuiState
