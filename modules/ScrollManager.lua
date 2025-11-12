--[[
ScrollManager.lua - Scrolling and overflow management for FlexLove
Handles overflow detection, scrollbar rendering, and scrollbar interaction
Extracted from Element.lua for better modularity and testability
]]

-- ====================
-- Module Setup
-- ====================

-- Setup module path for relative requires
local modulePath = (...):match("(.-)[^%.]+$")
local function req(name)
  return require(modulePath .. name)
end

-- Module dependencies
local Color = req("Color")

-- ====================
-- Error Handling Utilities
-- ====================

--- Standardized error message formatter
---@param module string -- Module name
---@param message string -- Error message
---@return string -- Formatted error message
local function formatError(module, message)
  return string.format("[FlexLove.%s] %s", module, message)
end

-- ====================
-- ScrollManager Class
-- ====================

---@class ScrollManager
---@field overflow string -- Overflow mode for both axes ("visible"|"hidden"|"scroll"|"auto")
---@field overflowX string? -- Overflow mode for X axis (overrides overflow)
---@field overflowY string? -- Overflow mode for Y axis (overrides overflow)
---@field scrollbarWidth number -- Width of scrollbar track/thumb
---@field scrollbarColor Color -- Color of scrollbar thumb
---@field scrollbarTrackColor Color -- Color of scrollbar track
---@field scrollbarRadius number -- Corner radius of scrollbar
---@field scrollbarPadding number -- Padding around scrollbar from container edge
---@field scrollSpeed number -- Scroll speed multiplier for wheel events
---@field hideScrollbars {vertical:boolean, horizontal:boolean} -- Hide scrollbars
---@field _element Element? -- Reference to parent element
---@field _overflowX boolean -- Whether content overflows horizontally
---@field _overflowY boolean -- Whether content overflows vertically
---@field _contentWidth number -- Total content width (including overflow)
---@field _contentHeight number -- Total content height (including overflow)
---@field _scrollX number -- Current horizontal scroll position
---@field _scrollY number -- Current vertical scroll position
---@field _maxScrollX number -- Maximum horizontal scroll position
---@field _maxScrollY number -- Maximum vertical scroll position
---@field _scrollbarHoveredVertical boolean -- Whether vertical scrollbar is hovered
---@field _scrollbarHoveredHorizontal boolean -- Whether horizontal scrollbar is hovered
---@field _scrollbarDragging boolean -- Whether a scrollbar is being dragged
---@field _hoveredScrollbar string? -- Which scrollbar is hovered ("vertical"|"horizontal")
---@field _scrollbarDragOffset number -- Offset from thumb top when drag started
---@field _scrollbarPressHandled boolean -- Track if scrollbar press was handled
local ScrollManager = {}
ScrollManager.__index = ScrollManager

--- Create a new ScrollManager instance
---@param config table -- Configuration options
---@return ScrollManager
function ScrollManager.new(config)
  if not config then
    error(formatError("ScrollManager", "Configuration table is required"))
  end

  local self = setmetatable({}, ScrollManager)

  -- Overflow configuration
  self.overflow = config.overflow or "hidden"
  self.overflowX = config.overflowX
  self.overflowY = config.overflowY

  -- Scrollbar appearance
  self.scrollbarWidth = config.scrollbarWidth or 12
  self.scrollbarColor = config.scrollbarColor or Color.new(0.5, 0.5, 0.5, 0.8)
  self.scrollbarTrackColor = config.scrollbarTrackColor or Color.new(0.2, 0.2, 0.2, 0.5)
  self.scrollbarRadius = config.scrollbarRadius or 6
  self.scrollbarPadding = config.scrollbarPadding or 2
  self.scrollSpeed = config.scrollSpeed or 20

  -- Validate Color objects
  if type(self.scrollbarColor) ~= "table" or not self.scrollbarColor.toRGBA then
    error(formatError("ScrollManager", "scrollbarColor must be a Color object"))
  end
  if type(self.scrollbarTrackColor) ~= "table" or not self.scrollbarTrackColor.toRGBA then
    error(formatError("ScrollManager", "scrollbarTrackColor must be a Color object"))
  end

  -- hideScrollbars can be boolean or table {vertical: boolean, horizontal: boolean}
  if config.hideScrollbars ~= nil then
    if type(config.hideScrollbars) == "boolean" then
      self.hideScrollbars = { vertical = config.hideScrollbars, horizontal = config.hideScrollbars }
    elseif type(config.hideScrollbars) == "table" then
      self.hideScrollbars = {
        vertical = config.hideScrollbars.vertical ~= nil and config.hideScrollbars.vertical or false,
        horizontal = config.hideScrollbars.horizontal ~= nil and config.hideScrollbars.horizontal or false,
      }
    else
      self.hideScrollbars = { vertical = false, horizontal = false }
    end
  else
    self.hideScrollbars = { vertical = false, horizontal = false }
  end

  -- Internal state
  self._element = nil
  self._overflowX = false
  self._overflowY = false
  self._contentWidth = 0
  self._contentHeight = 0
  self._scrollX = config._scrollX or 0
  self._scrollY = config._scrollY or 0
  self._maxScrollX = 0
  self._maxScrollY = 0

  -- Scrollbar interaction state
  self._scrollbarHoveredVertical = false
  self._scrollbarHoveredHorizontal = false
  self._scrollbarDragging = false
  self._hoveredScrollbar = nil
  self._scrollbarDragOffset = 0
  self._scrollbarPressHandled = false

  return self
end

--- Initialize ScrollManager with parent element reference
---@param element Element -- Parent element
function ScrollManager:initialize(element)
  if not element then
    error(formatError("ScrollManager", "Element reference is required"))
  end
  self._element = element
end

--- Detect if content overflows container bounds
--- Calculates content dimensions and overflow state based on children
function ScrollManager:detectOverflow()
  if not self._element then
    error(formatError("ScrollManager", "ScrollManager not initialized with element"))
  end

  -- Reset overflow state
  self._overflowX = false
  self._overflowY = false
  self._contentWidth = self._element.width
  self._contentHeight = self._element.height

  -- Skip detection if overflow is visible (no clipping needed)
  local overflowX = self.overflowX or self.overflow
  local overflowY = self.overflowY or self.overflow
  if overflowX == "visible" and overflowY == "visible" then
    return
  end

  -- Calculate content bounds based on children
  if #self._element.children == 0 then
    return -- No children, no overflow
  end

  local minX, minY = 0, 0
  local maxX, maxY = 0, 0

  -- Content area starts after padding
  local contentX = self._element.x + self._element.padding.left
  local contentY = self._element.y + self._element.padding.top

  for _, child in ipairs(self._element.children) do
    -- Skip absolutely positioned children (they don't contribute to overflow)
    if not child._explicitlyAbsolute then
      -- Calculate child position relative to content area
      local childLeft = child.x - contentX
      local childTop = child.y - contentY
      local childRight = childLeft + child:getBorderBoxWidth() + child.margin.right
      local childBottom = childTop + child:getBorderBoxHeight() + child.margin.bottom

      maxX = math.max(maxX, childRight)
      maxY = math.max(maxY, childBottom)
    end
  end

  -- Calculate content dimensions
  self._contentWidth = maxX
  self._contentHeight = maxY

  -- Detect overflow
  local containerWidth = self._element.width
  local containerHeight = self._element.height

  self._overflowX = self._contentWidth > containerWidth
  self._overflowY = self._contentHeight > containerHeight

  -- Calculate maximum scroll bounds
  self._maxScrollX = math.max(0, self._contentWidth - containerWidth)
  self._maxScrollY = math.max(0, self._contentHeight - containerHeight)

  -- Clamp current scroll position to new bounds
  self._scrollX = math.max(0, math.min(self._scrollX, self._maxScrollX))
  self._scrollY = math.max(0, math.min(self._scrollY, self._maxScrollY))
end

--- Set scroll position with bounds clamping
---@param x number? -- X scroll position (nil to keep current)
---@param y number? -- Y scroll position (nil to keep current)
function ScrollManager:setScroll(x, y)
  if x ~= nil then
    if type(x) ~= "number" then
      error(formatError("ScrollManager", "Scroll X position must be a number"))
    end
    self._scrollX = math.max(0, math.min(x, self._maxScrollX))
  end
  if y ~= nil then
    if type(y) ~= "number" then
      error(formatError("ScrollManager", "Scroll Y position must be a number"))
    end
    self._scrollY = math.max(0, math.min(y, self._maxScrollY))
  end
end

--- Get current scroll position
---@return number scrollX, number scrollY
function ScrollManager:getScroll()
  return self._scrollX, self._scrollY
end

--- Scroll by delta amount (relative scrolling)
---@param dx number? -- X delta (nil for no change)
---@param dy number? -- Y delta (nil for no change)
function ScrollManager:scroll(dx, dy)
  if dx ~= nil then
    if type(dx) ~= "number" then
      error(formatError("ScrollManager", "Scroll delta X must be a number"))
    end
    self._scrollX = math.max(0, math.min(self._scrollX + dx, self._maxScrollX))
  end
  if dy ~= nil then
    if type(dy) ~= "number" then
      error(formatError("ScrollManager", "Scroll delta Y must be a number"))
    end
    self._scrollY = math.max(0, math.min(self._scrollY + dy, self._maxScrollY))
  end
end

--- Calculate scrollbar dimensions and positions
---@return table -- {vertical: {visible, trackHeight, thumbHeight, thumbY}, horizontal: {visible, trackWidth, thumbWidth, thumbX}}
function ScrollManager:calculateScrollbarDimensions()
  if not self._element then
    error(formatError("ScrollManager", "ScrollManager not initialized with element"))
  end

  local result = {
    vertical = { visible = false, trackHeight = 0, thumbHeight = 0, thumbY = 0 },
    horizontal = { visible = false, trackWidth = 0, thumbWidth = 0, thumbX = 0 },
  }

  local overflowX = self.overflowX or self.overflow
  local overflowY = self.overflowY or self.overflow

  -- Vertical scrollbar
  -- Note: overflow="scroll" always shows scrollbar; overflow="auto" only when content overflows
  if overflowY == "scroll" then
    -- Always show scrollbar for "scroll" mode
    result.vertical.visible = true
    result.vertical.trackHeight = self._element.height - (self.scrollbarPadding * 2)

    if self._overflowY then
      -- Content overflows, calculate proper thumb size
      local contentRatio = self._element.height / math.max(self._contentHeight, self._element.height)
      result.vertical.thumbHeight = math.max(20, result.vertical.trackHeight * contentRatio)

      -- Calculate thumb position based on scroll ratio
      local scrollRatio = self._maxScrollY > 0 and (self._scrollY / self._maxScrollY) or 0
      local maxThumbY = result.vertical.trackHeight - result.vertical.thumbHeight
      result.vertical.thumbY = maxThumbY * scrollRatio
    else
      -- No overflow, thumb fills entire track
      result.vertical.thumbHeight = result.vertical.trackHeight
      result.vertical.thumbY = 0
    end
  elseif self._overflowY and overflowY == "auto" then
    -- Only show scrollbar when content actually overflows
    result.vertical.visible = true
    result.vertical.trackHeight = self._element.height - (self.scrollbarPadding * 2)

    -- Calculate thumb height based on content ratio
    local contentRatio = self._element.height / math.max(self._contentHeight, self._element.height)
    result.vertical.thumbHeight = math.max(20, result.vertical.trackHeight * contentRatio)

    -- Calculate thumb position based on scroll ratio
    local scrollRatio = self._maxScrollY > 0 and (self._scrollY / self._maxScrollY) or 0
    local maxThumbY = result.vertical.trackHeight - result.vertical.thumbHeight
    result.vertical.thumbY = maxThumbY * scrollRatio
  end

  -- Horizontal scrollbar
  -- Note: overflow="scroll" always shows scrollbar; overflow="auto" only when content overflows
  if overflowX == "scroll" then
    -- Always show scrollbar for "scroll" mode
    result.horizontal.visible = true
    result.horizontal.trackWidth = self._element.width - (self.scrollbarPadding * 2)

    if self._overflowX then
      -- Content overflows, calculate proper thumb size
      local contentRatio = self._element.width / math.max(self._contentWidth, self._element.width)
      result.horizontal.thumbWidth = math.max(20, result.horizontal.trackWidth * contentRatio)

      -- Calculate thumb position based on scroll ratio
      local scrollRatio = self._maxScrollX > 0 and (self._scrollX / self._maxScrollX) or 0
      local maxThumbX = result.horizontal.trackWidth - result.horizontal.thumbWidth
      result.horizontal.thumbX = maxThumbX * scrollRatio
    else
      -- No overflow, thumb fills entire track
      result.horizontal.thumbWidth = result.horizontal.trackWidth
      result.horizontal.thumbX = 0
    end
  elseif self._overflowX and overflowX == "auto" then
    -- Only show scrollbar when content actually overflows
    result.horizontal.visible = true
    result.horizontal.trackWidth = self._element.width - (self.scrollbarPadding * 2)

    -- Calculate thumb width based on content ratio
    local contentRatio = self._element.width / math.max(self._contentWidth, self._element.width)
    result.horizontal.thumbWidth = math.max(20, result.horizontal.trackWidth * contentRatio)

    -- Calculate thumb position based on scroll ratio
    local scrollRatio = self._maxScrollX > 0 and (self._scrollX / self._maxScrollX) or 0
    local maxThumbX = result.horizontal.trackWidth - result.horizontal.thumbWidth
    result.horizontal.thumbX = maxThumbX * scrollRatio
  end

  return result
end

--- Draw scrollbars
---@param x number -- Element X position
---@param y number -- Element Y position
---@param width number -- Element width
---@param height number -- Element height
function ScrollManager:drawScrollbars(x, y, width, height)
  if not self._element then
    error(formatError("ScrollManager", "ScrollManager not initialized with element"))
  end

  local dims = self:calculateScrollbarDimensions()

  -- Vertical scrollbar
  if dims.vertical.visible and not self.hideScrollbars.vertical then
    -- Position scrollbar within content area (x, y is border-box origin)
    local contentX = x + self._element.padding.left
    local contentY = y + self._element.padding.top
    local trackX = contentX + width - self.scrollbarWidth - self.scrollbarPadding
    local trackY = contentY + self.scrollbarPadding

    -- Determine thumb color based on state (independent for vertical)
    local thumbColor = self.scrollbarColor
    if self._scrollbarDragging and self._hoveredScrollbar == "vertical" then
      -- Active state: brighter
      thumbColor = Color.new(math.min(1, thumbColor.r * 1.4), math.min(1, thumbColor.g * 1.4), math.min(1, thumbColor.b * 1.4), thumbColor.a)
    elseif self._scrollbarHoveredVertical then
      -- Hover state: slightly brighter
      thumbColor = Color.new(math.min(1, thumbColor.r * 1.2), math.min(1, thumbColor.g * 1.2), math.min(1, thumbColor.b * 1.2), thumbColor.a)
    end

    -- Draw track
    love.graphics.setColor(self.scrollbarTrackColor:toRGBA())
    love.graphics.rectangle("fill", trackX, trackY, self.scrollbarWidth, dims.vertical.trackHeight, self.scrollbarRadius)

    -- Draw thumb with state-based color
    love.graphics.setColor(thumbColor:toRGBA())
    love.graphics.rectangle("fill", trackX, trackY + dims.vertical.thumbY, self.scrollbarWidth, dims.vertical.thumbHeight, self.scrollbarRadius)
  end

  -- Horizontal scrollbar
  if dims.horizontal.visible and not self.hideScrollbars.horizontal then
    -- Position scrollbar within content area (x, y is border-box origin)
    local contentX = x + self._element.padding.left
    local contentY = y + self._element.padding.top
    local trackX = contentX + self.scrollbarPadding
    local trackY = contentY + height - self.scrollbarWidth - self.scrollbarPadding

    -- Determine thumb color based on state (independent for horizontal)
    local thumbColor = self.scrollbarColor
    if self._scrollbarDragging and self._hoveredScrollbar == "horizontal" then
      -- Active state: brighter
      thumbColor = Color.new(math.min(1, thumbColor.r * 1.4), math.min(1, thumbColor.g * 1.4), math.min(1, thumbColor.b * 1.4), thumbColor.a)
    elseif self._scrollbarHoveredHorizontal then
      -- Hover state: slightly brighter
      thumbColor = Color.new(math.min(1, thumbColor.r * 1.2), math.min(1, thumbColor.g * 1.2), math.min(1, thumbColor.b * 1.2), thumbColor.a)
    end

    -- Draw track
    love.graphics.setColor(self.scrollbarTrackColor:toRGBA())
    love.graphics.rectangle("fill", trackX, trackY, dims.horizontal.trackWidth, self.scrollbarWidth, self.scrollbarRadius)

    -- Draw thumb with state-based color
    love.graphics.setColor(thumbColor:toRGBA())
    love.graphics.rectangle("fill", trackX + dims.horizontal.thumbX, trackY, dims.horizontal.thumbWidth, self.scrollbarWidth, self.scrollbarRadius)
  end

  -- Reset color
  love.graphics.setColor(1, 1, 1, 1)
end

--- Get scrollbar at mouse position
---@param mouseX number
---@param mouseY number
---@return table|nil -- {component: "vertical"|"horizontal", region: "thumb"|"track"}
function ScrollManager:_getScrollbarAtPosition(mouseX, mouseY)
  if not self._element then
    return nil
  end

  local overflowX = self.overflowX or self.overflow
  local overflowY = self.overflowY or self.overflow

  if not (overflowX == "scroll" or overflowX == "auto" or overflowY == "scroll" or overflowY == "auto") then
    return nil
  end

  local dims = self:calculateScrollbarDimensions()
  local x, y = self._element.x, self._element.y
  local w, h = self._element.width, self._element.height

  -- Check vertical scrollbar (only if not hidden)
  if dims.vertical.visible and not self.hideScrollbars.vertical then
    -- Position scrollbar within content area (x, y is border-box origin)
    local contentX = x + self._element.padding.left
    local contentY = y + self._element.padding.top
    local trackX = contentX + w - self.scrollbarWidth - self.scrollbarPadding
    local trackY = contentY + self.scrollbarPadding
    local trackW = self.scrollbarWidth
    local trackH = dims.vertical.trackHeight

    if mouseX >= trackX and mouseX <= trackX + trackW and mouseY >= trackY and mouseY <= trackY + trackH then
      -- Check if over thumb
      local thumbY = trackY + dims.vertical.thumbY
      local thumbH = dims.vertical.thumbHeight
      if mouseY >= thumbY and mouseY <= thumbY + thumbH then
        return { component = "vertical", region = "thumb" }
      else
        return { component = "vertical", region = "track" }
      end
    end
  end

  -- Check horizontal scrollbar (only if not hidden)
  if dims.horizontal.visible and not self.hideScrollbars.horizontal then
    -- Position scrollbar within content area (x, y is border-box origin)
    local contentX = x + self._element.padding.left
    local contentY = y + self._element.padding.top
    local trackX = contentX + self.scrollbarPadding
    local trackY = contentY + h - self.scrollbarWidth - self.scrollbarPadding
    local trackW = dims.horizontal.trackWidth
    local trackH = self.scrollbarWidth

    if mouseX >= trackX and mouseX <= trackX + trackW and mouseY >= trackY and mouseY <= trackY + trackH then
      -- Check if over thumb
      local thumbX = trackX + dims.horizontal.thumbX
      local thumbW = dims.horizontal.thumbWidth
      if mouseX >= thumbX and mouseX <= thumbX + thumbW then
        return { component = "horizontal", region = "thumb" }
      else
        return { component = "horizontal", region = "track" }
      end
    end
  end

  return nil
end

--- Handle scrollbar mouse press
---@param mouseX number
---@param mouseY number
---@param button number
---@return boolean -- True if event was consumed
function ScrollManager:handleMousePress(mouseX, mouseY, button)
  if button ~= 1 then
    return false
  end -- Only left click

  local scrollbar = self:_getScrollbarAtPosition(mouseX, mouseY)
  if not scrollbar then
    return false
  end

  if scrollbar.region == "thumb" then
    -- Start dragging thumb
    self._scrollbarDragging = true
    self._hoveredScrollbar = scrollbar.component
    local dims = self:calculateScrollbarDimensions()

    if scrollbar.component == "vertical" then
      local contentY = self._element.y + self._element.padding.top
      local trackY = contentY + self.scrollbarPadding
      local thumbY = trackY + dims.vertical.thumbY
      self._scrollbarDragOffset = mouseY - thumbY
    elseif scrollbar.component == "horizontal" then
      local contentX = self._element.x + self._element.padding.left
      local trackX = contentX + self.scrollbarPadding
      local thumbX = trackX + dims.horizontal.thumbX
      self._scrollbarDragOffset = mouseX - thumbX
    end

    return true -- Event consumed
  elseif scrollbar.region == "track" then
    -- Click on track - jump to position
    self:_scrollToTrackPosition(mouseX, mouseY, scrollbar.component)
    return true
  end

  return false
end

--- Handle scrollbar release
---@param mouseX number
---@param mouseY number
---@param button number
---@return boolean -- True if event was consumed
function ScrollManager:handleMouseRelease(mouseX, mouseY, button)
  if button ~= 1 then
    return false
  end

  if self._scrollbarDragging then
    self._scrollbarDragging = false
    return true
  end

  return false
end

--- Handle scrollbar drag
---@param mouseX number
---@param mouseY number
---@return boolean -- True if event was consumed
function ScrollManager:handleMouseMove(mouseX, mouseY)
  if not self._scrollbarDragging then
    return false
  end

  local dims = self:calculateScrollbarDimensions()

  if self._hoveredScrollbar == "vertical" then
    local contentY = self._element.y + self._element.padding.top
    local trackY = contentY + self.scrollbarPadding
    local trackH = dims.vertical.trackHeight
    local thumbH = dims.vertical.thumbHeight

    -- Calculate new thumb position
    local newThumbY = mouseY - self._scrollbarDragOffset - trackY
    newThumbY = math.max(0, math.min(newThumbY, trackH - thumbH))

    -- Convert thumb position to scroll position
    local scrollRatio = (trackH - thumbH) > 0 and (newThumbY / (trackH - thumbH)) or 0
    local newScrollY = scrollRatio * self._maxScrollY

    self:setScroll(nil, newScrollY)
    return true
  elseif self._hoveredScrollbar == "horizontal" then
    local contentX = self._element.x + self._element.padding.left
    local trackX = contentX + self.scrollbarPadding
    local trackW = dims.horizontal.trackWidth
    local thumbW = dims.horizontal.thumbWidth

    -- Calculate new thumb position
    local newThumbX = mouseX - self._scrollbarDragOffset - trackX
    newThumbX = math.max(0, math.min(newThumbX, trackW - thumbW))

    -- Convert thumb position to scroll position
    local scrollRatio = (trackW - thumbW) > 0 and (newThumbX / (trackW - thumbW)) or 0
    local newScrollX = scrollRatio * self._maxScrollX

    self:setScroll(newScrollX, nil)
    return true
  end

  return false
end

--- Handle mouse wheel scrolling
---@param x number -- Horizontal scroll amount
---@param y number -- Vertical scroll amount
---@return boolean -- True if scroll was handled
function ScrollManager:handleWheel(x, y)
  local overflowX = self.overflowX or self.overflow
  local overflowY = self.overflowY or self.overflow

  if not (overflowX == "scroll" or overflowX == "auto" or overflowY == "scroll" or overflowY == "auto") then
    return false
  end

  local hasVerticalOverflow = self._overflowY and self._maxScrollY > 0
  local hasHorizontalOverflow = self._overflowX and self._maxScrollX > 0

  local scrolled = false

  -- Vertical scrolling
  if y ~= 0 and hasVerticalOverflow then
    local delta = -y * self.scrollSpeed -- Negative because wheel up = scroll up
    local newScrollY = self._scrollY + delta
    self:setScroll(nil, newScrollY)
    scrolled = true
  end

  -- Horizontal scrolling
  if x ~= 0 and hasHorizontalOverflow then
    local delta = -x * self.scrollSpeed
    local newScrollX = self._scrollX + delta
    self:setScroll(newScrollX, nil)
    scrolled = true
  end

  return scrolled
end

--- Check if scrollbar is hovered at position
---@param mouseX number
---@param mouseY number
---@return boolean vertical, boolean horizontal
function ScrollManager:isScrollbarHovered(mouseX, mouseY)
  local scrollbar = self:_getScrollbarAtPosition(mouseX, mouseY)
  if not scrollbar then
    return false, false
  end
  return scrollbar.component == "vertical", scrollbar.component == "horizontal"
end

--- Get content bounds and scroll limits
---@return number contentWidth, number contentHeight, number maxScrollX, number maxScrollY
function ScrollManager:getContentBounds()
  return self._contentWidth, self._contentHeight, self._maxScrollX, self._maxScrollY
end

--- Update scrollbar state (called each frame)
---@param dt number -- Delta time
---@param mouseX number -- Current mouse X position
---@param mouseY number -- Current mouse Y position
function ScrollManager:update(dt, mouseX, mouseY)
  local scrollbar = self:_getScrollbarAtPosition(mouseX, mouseY)

  -- Update independent hover states for vertical and horizontal scrollbars
  if scrollbar and scrollbar.component == "vertical" then
    self._scrollbarHoveredVertical = true
    self._hoveredScrollbar = "vertical"
  else
    if not (self._scrollbarDragging and self._hoveredScrollbar == "vertical") then
      self._scrollbarHoveredVertical = false
    end
  end

  if scrollbar and scrollbar.component == "horizontal" then
    self._scrollbarHoveredHorizontal = true
    self._hoveredScrollbar = "horizontal"
  else
    if not (self._scrollbarDragging and self._hoveredScrollbar == "horizontal") then
      self._scrollbarHoveredHorizontal = false
    end
  end

  -- Clear hoveredScrollbar if neither is hovered
  if not scrollbar and not self._scrollbarDragging then
    self._hoveredScrollbar = nil
  end
end

--- Scroll to track click position (jump to position)
---@param mouseX number
---@param mouseY number
---@param component string -- "vertical" or "horizontal"
function ScrollManager:_scrollToTrackPosition(mouseX, mouseY, component)
  local dims = self:calculateScrollbarDimensions()

  if component == "vertical" then
    local contentY = self._element.y + self._element.padding.top
    local trackY = contentY + self.scrollbarPadding
    local trackH = dims.vertical.trackHeight
    local thumbH = dims.vertical.thumbHeight

    -- Calculate target thumb position (centered on click)
    local targetThumbY = mouseY - trackY - (thumbH / 2)
    targetThumbY = math.max(0, math.min(targetThumbY, trackH - thumbH))

    -- Convert to scroll position
    local scrollRatio = (trackH - thumbH) > 0 and (targetThumbY / (trackH - thumbH)) or 0
    local newScrollY = scrollRatio * self._maxScrollY

    self:setScroll(nil, newScrollY)
  elseif component == "horizontal" then
    local contentX = self._element.x + self._element.padding.left
    local trackX = contentX + self.scrollbarPadding
    local trackW = dims.horizontal.trackWidth
    local thumbW = dims.horizontal.thumbWidth

    -- Calculate target thumb position (centered on click)
    local targetThumbX = mouseX - trackX - (thumbW / 2)
    targetThumbX = math.max(0, math.min(targetThumbX, trackW - thumbW))

    -- Convert to scroll position
    local scrollRatio = (trackW - thumbW) > 0 and (targetThumbX / (trackW - thumbW)) or 0
    local newScrollX = scrollRatio * self._maxScrollX

    self:setScroll(newScrollX, nil)
  end
end

--- Get current scrollbar dragging state
---@return boolean dragging, string? component
function ScrollManager:getDraggingState()
  return self._scrollbarDragging, self._hoveredScrollbar
end

--- Set scrollbar dragging state (for state restoration)
---@param dragging boolean
---@param component string? -- "vertical" or "horizontal"
---@param dragOffset number?
function ScrollManager:setDraggingState(dragging, component, dragOffset)
  self._scrollbarDragging = dragging
  self._hoveredScrollbar = component
  self._scrollbarDragOffset = dragOffset or 0
end

--- Get scrollbar hover state
---@return boolean vertical, boolean horizontal
function ScrollManager:getHoverState()
  return self._scrollbarHoveredVertical, self._scrollbarHoveredHorizontal
end

--- Set scrollbar hover state (for state restoration)
---@param vertical boolean
---@param horizontal boolean
function ScrollManager:setHoverState(vertical, horizontal)
  self._scrollbarHoveredVertical = vertical
  self._scrollbarHoveredHorizontal = horizontal
end

--- Check if element has overflow
---@return boolean hasOverflowX, boolean hasOverflowY
function ScrollManager:hasOverflow()
  return self._overflowX, self._overflowY
end

--- Get scroll percentage (0-1)
---@return number percentX, number percentY
function ScrollManager:getScrollPercentage()
  local percentX = self._maxScrollX > 0 and (self._scrollX / self._maxScrollX) or 0
  local percentY = self._maxScrollY > 0 and (self._scrollY / self._maxScrollY) or 0
  return percentX, percentY
end

--- Scroll to top
function ScrollManager:scrollToTop()
  self:setScroll(nil, 0)
end

--- Scroll to bottom
function ScrollManager:scrollToBottom()
  self:setScroll(nil, self._maxScrollY)
end

--- Scroll to left
function ScrollManager:scrollToLeft()
  self:setScroll(0, nil)
end

--- Scroll to right
function ScrollManager:scrollToRight()
  self:setScroll(self._maxScrollX, nil)
end

return ScrollManager
