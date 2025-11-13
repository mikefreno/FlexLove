--- ScrollManager.lua
--- Handles scrolling, overflow detection, and scrollbar rendering/interaction for Elements
--- Extracted from Element.lua as part of element-refactor-modularization task 05
---
--- Dependencies (must be injected via deps parameter):
---   - Color: Color module for creating color instances

---@class ScrollManager
---@field overflow string -- "visible"|"hidden"|"auto"|"scroll"
---@field overflowX string? -- X-axis specific overflow (overrides overflow)
---@field overflowY string? -- Y-axis specific overflow (overrides overflow)
---@field scrollbarWidth number -- Width/height of scrollbar track
---@field scrollbarColor Color -- Scrollbar thumb color
---@field scrollbarTrackColor Color -- Scrollbar track background color
---@field scrollbarRadius number -- Border radius for scrollbars
---@field scrollbarPadding number -- Padding around scrollbar
---@field scrollSpeed number -- Scroll speed for wheel events (pixels per wheel unit)
---@field hideScrollbars table -- {vertical: boolean, horizontal: boolean}
---@field _element table? -- Reference to parent Element (set via initialize)
---@field _overflowX boolean -- True if content overflows horizontally
---@field _overflowY boolean -- True if content overflows vertically
---@field _contentWidth number -- Total content width (including overflow)
---@field _contentHeight number -- Total content height (including overflow)
---@field _scrollX number -- Current horizontal scroll position
---@field _scrollY number -- Current vertical scroll position
---@field _maxScrollX number -- Maximum horizontal scroll (contentWidth - containerWidth)
---@field _maxScrollY number -- Maximum vertical scroll (contentHeight - containerHeight)
---@field _scrollbarHoveredVertical boolean -- True if mouse is over vertical scrollbar
---@field _scrollbarHoveredHorizontal boolean -- True if mouse is over horizontal scrollbar
---@field _scrollbarDragging boolean -- True if currently dragging a scrollbar
---@field _hoveredScrollbar string? -- "vertical" or "horizontal" when dragging
---@field _scrollbarDragOffset number -- Offset from thumb top when drag started
---@field _scrollbarPressHandled boolean -- Track if scrollbar press was handled this frame
local ScrollManager = {}
ScrollManager.__index = ScrollManager

--- Create a new ScrollManager instance
---@param config table Configuration options
---@param deps table Dependencies {Color: Color module}
---@return ScrollManager
function ScrollManager.new(config, deps)
  local Color = deps.Color
  local self = setmetatable({}, ScrollManager)
  
  -- Store dependency for instance methods
  self._Color = Color
  
  -- Configuration
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
  
  -- Internal overflow state
  self._overflowX = false
  self._overflowY = false
  self._contentWidth = 0
  self._contentHeight = 0
  
  -- Scroll state (can be restored from config in immediate mode)
  self._scrollX = config._scrollX or 0
  self._scrollY = config._scrollY or 0
  self._maxScrollX = 0
  self._maxScrollY = 0
  
  -- Scrollbar interaction state
  self._scrollbarHoveredVertical = false
  self._scrollbarHoveredHorizontal = false
  self._scrollbarDragging = false
  self._hoveredScrollbar = nil -- "vertical" or "horizontal"
  self._scrollbarDragOffset = 0
  self._scrollbarPressHandled = false
  
  -- Element reference (set via initialize)
  self._element = nil
  
  return self
end

--- Initialize with parent element reference
---@param element table The parent Element instance
function ScrollManager:initialize(element)
  self._element = element
end

--- Detect if content overflows container bounds
function ScrollManager:detectOverflow()
  if not self._element then
    error("ScrollManager:detectOverflow() called before initialize()")
  end
  
  local element = self._element
  
  -- Reset overflow state
  self._overflowX = false
  self._overflowY = false
  self._contentWidth = element.width
  self._contentHeight = element.height
  
  -- Skip detection if overflow is visible (no clipping needed)
  local overflowX = self.overflowX or self.overflow
  local overflowY = self.overflowY or self.overflow
  if overflowX == "visible" and overflowY == "visible" then
    return
  end
  
  -- Calculate content bounds based on children
  if #element.children == 0 then
    return -- No children, no overflow
  end
  
  local minX, minY = 0, 0
  local maxX, maxY = 0, 0
  
  -- Content area starts after padding
  local contentX = element.x + element.padding.left
  local contentY = element.y + element.padding.top
  
  for _, child in ipairs(element.children) do
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
  local containerWidth = element.width
  local containerHeight = element.height
  
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
    self._scrollX = math.max(0, math.min(x, self._maxScrollX))
  end
  if y ~= nil then
    self._scrollY = math.max(0, math.min(y, self._maxScrollY))
  end
end

--- Get current scroll position
---@return number scrollX, number scrollY
function ScrollManager:getScroll()
  return self._scrollX, self._scrollY
end

--- Scroll by delta amount
---@param dx number? -- X delta (nil for no change)
---@param dy number? -- Y delta (nil for no change)
function ScrollManager:scrollBy(dx, dy)
  if dx then
    self._scrollX = math.max(0, math.min(self._scrollX + dx, self._maxScrollX))
  end
  if dy then
    self._scrollY = math.max(0, math.min(self._scrollY + dy, self._maxScrollY))
  end
end

--- Get maximum scroll bounds
---@return number maxScrollX, number maxScrollY
function ScrollManager:getMaxScroll()
  return self._maxScrollX, self._maxScrollY
end

--- Get scroll percentage (0-1)
---@return number percentX, number percentY
function ScrollManager:getScrollPercentage()
  local percentX = self._maxScrollX > 0 and (self._scrollX / self._maxScrollX) or 0
  local percentY = self._maxScrollY > 0 and (self._scrollY / self._maxScrollY) or 0
  return percentX, percentY
end

--- Check if element has overflow
---@return boolean hasOverflowX, boolean hasOverflowY
function ScrollManager:hasOverflow()
  return self._overflowX, self._overflowY
end

--- Get content dimensions (including overflow)
---@return number contentWidth, number contentHeight
function ScrollManager:getContentSize()
  return self._contentWidth, self._contentHeight
end

--- Calculate scrollbar dimensions and positions
---@return table -- {vertical: {visible, trackHeight, thumbHeight, thumbY}, horizontal: {visible, trackWidth, thumbWidth, thumbX}}
function ScrollManager:calculateScrollbarDimensions()
  if not self._element then
    error("ScrollManager:calculateScrollbarDimensions() called before initialize()")
  end
  
  local element = self._element
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
    result.vertical.trackHeight = element.height - (self.scrollbarPadding * 2)
    
    if self._overflowY then
      -- Content overflows, calculate proper thumb size
      local contentRatio = element.height / math.max(self._contentHeight, element.height)
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
    result.vertical.trackHeight = element.height - (self.scrollbarPadding * 2)
    
    -- Calculate thumb height based on content ratio
    local contentRatio = element.height / math.max(self._contentHeight, element.height)
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
    result.horizontal.trackWidth = element.width - (self.scrollbarPadding * 2)
    
    if self._overflowX then
      -- Content overflows, calculate proper thumb size
      local contentRatio = element.width / math.max(self._contentWidth, element.width)
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
    result.horizontal.trackWidth = element.width - (self.scrollbarPadding * 2)
    
    -- Calculate thumb width based on content ratio
    local contentRatio = element.width / math.max(self._contentWidth, element.width)
    result.horizontal.thumbWidth = math.max(20, result.horizontal.trackWidth * contentRatio)
    
    -- Calculate thumb position based on scroll ratio
    local scrollRatio = self._maxScrollX > 0 and (self._scrollX / self._maxScrollX) or 0
    local maxThumbX = result.horizontal.trackWidth - result.horizontal.thumbWidth
    result.horizontal.thumbX = maxThumbX * scrollRatio
  end
  
  return result
end

--- Get scrollbar at mouse position
---@param mouseX number
---@param mouseY number
---@return table|nil -- {component: "vertical"|"horizontal", region: "thumb"|"track"}
function ScrollManager:getScrollbarAtPosition(mouseX, mouseY)
  if not self._element then
    error("ScrollManager:getScrollbarAtPosition() called before initialize()")
  end
  
  local element = self._element
  local overflowX = self.overflowX or self.overflow
  local overflowY = self.overflowY or self.overflow
  
  if not (overflowX == "scroll" or overflowX == "auto" or overflowY == "scroll" or overflowY == "auto") then
    return nil
  end
  
  local dims = self:calculateScrollbarDimensions()
  local x, y = element.x, element.y
  local w, h = element.width, element.height
  
  -- Check vertical scrollbar (only if not hidden)
  if dims.vertical.visible and not self.hideScrollbars.vertical then
    -- Position scrollbar within content area (x, y is border-box origin)
    local contentX = x + element.padding.left
    local contentY = y + element.padding.top
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
    local contentX = x + element.padding.left
    local contentY = y + element.padding.top
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
  if not self._element then
    error("ScrollManager:handleMousePress() called before initialize()")
  end
  
  if button ~= 1 then
    return false
  end -- Only left click
  
  local scrollbar = self:getScrollbarAtPosition(mouseX, mouseY)
  if not scrollbar then
    return false
  end
  
  if scrollbar.region == "thumb" then
    -- Start dragging thumb
    self._scrollbarDragging = true
    self._hoveredScrollbar = scrollbar.component
    local dims = self:calculateScrollbarDimensions()
    local element = self._element
    
    if scrollbar.component == "vertical" then
      local contentY = element.y + element.padding.top
      local trackY = contentY + self.scrollbarPadding
      local thumbY = trackY + dims.vertical.thumbY
      self._scrollbarDragOffset = mouseY - thumbY
    elseif scrollbar.component == "horizontal" then
      local contentX = element.x + element.padding.left
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

--- Handle scrollbar drag
---@param mouseX number
---@param mouseY number
---@return boolean -- True if event was consumed
function ScrollManager:handleMouseMove(mouseX, mouseY)
  if not self._element then
    return false
  end
  
  if not self._scrollbarDragging then
    return false
  end
  
  local dims = self:calculateScrollbarDimensions()
  local element = self._element
  
  if self._hoveredScrollbar == "vertical" then
    local contentY = element.y + element.padding.top
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
    local contentX = element.x + element.padding.left
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

--- Handle scrollbar release
---@param button number
---@return boolean -- True if event was consumed
function ScrollManager:handleMouseRelease(button)
  if button ~= 1 then
    return false
  end
  
  if self._scrollbarDragging then
    self._scrollbarDragging = false
    return true
  end
  
  return false
end

--- Scroll to track click position (internal helper)
---@param mouseX number
---@param mouseY number
---@param component string -- "vertical" or "horizontal"
function ScrollManager:_scrollToTrackPosition(mouseX, mouseY, component)
  if not self._element then
    return
  end
  
  local dims = self:calculateScrollbarDimensions()
  local element = self._element
  
  if component == "vertical" then
    local contentY = element.y + element.padding.top
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
    local contentX = element.x + element.padding.left
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

--- Update scrollbar hover state based on mouse position
---@param mouseX number
---@param mouseY number
function ScrollManager:updateHoverState(mouseX, mouseY)
  local scrollbar = self:getScrollbarAtPosition(mouseX, mouseY)
  
  if scrollbar then
    if scrollbar.component == "vertical" then
      self._scrollbarHoveredVertical = true
      self._scrollbarHoveredHorizontal = false
    elseif scrollbar.component == "horizontal" then
      self._scrollbarHoveredVertical = false
      self._scrollbarHoveredHorizontal = true
    end
  else
    self._scrollbarHoveredVertical = false
    self._scrollbarHoveredHorizontal = false
  end
end

--- Reset scrollbar press handled flag (call at start of frame)
function ScrollManager:resetScrollbarPressFlag()
  self._scrollbarPressHandled = false
end

--- Check if scrollbar press was handled this frame
---@return boolean
function ScrollManager:wasScrollbarPressHandled()
  return self._scrollbarPressHandled
end

--- Set scrollbar press handled flag
function ScrollManager:setScrollbarPressHandled()
  self._scrollbarPressHandled = true
end

--- Get state for immediate mode persistence
---@return table State data
function ScrollManager:getState()
  return {
    scrollX = self._scrollX,
    scrollY = self._scrollY,
    scrollbarDragging = self._scrollbarDragging,
    hoveredScrollbar = self._hoveredScrollbar,
    scrollbarDragOffset = self._scrollbarDragOffset,
  }
end

--- Set state from immediate mode persistence
---@param state table State data
function ScrollManager:setState(state)
  if not state then
    return
  end
  
  if state.scrollX then
    self._scrollX = state.scrollX
  end
  if state.scrollY then
    self._scrollY = state.scrollY
  end
  if state.scrollbarDragging ~= nil then
    self._scrollbarDragging = state.scrollbarDragging
  end
  if state.hoveredScrollbar then
    self._hoveredScrollbar = state.hoveredScrollbar
  end
  if state.scrollbarDragOffset then
    self._scrollbarDragOffset = state.scrollbarDragOffset
  end
end

return ScrollManager
