-- ====================
-- LayoutEngine Module
-- ====================
-- Handles all layout calculations for Element including:
-- - Flexbox layout algorithm
-- - Grid layout delegation
-- - Auto-sizing calculations
-- - CSS positioning offsets

-- Setup module path for relative requires
local modulePath = (...):match("(.-)[^%.]+$")
local function req(name)
  return require(modulePath .. name)
end

-- Module dependencies
local utils = req("utils")
local Grid = req("Grid")

-- Extract enum values
local enums = utils.enums
local Positioning = enums.Positioning
local FlexDirection = enums.FlexDirection
local JustifyContent = enums.JustifyContent
local AlignContent = enums.AlignContent
local AlignItems = enums.AlignItems
local AlignSelf = enums.AlignSelf
local FlexWrap = enums.FlexWrap

---@class LayoutEngine
---@field element Element Reference to the parent element
---@field positioning Positioning Layout positioning mode
---@field flexDirection FlexDirection Direction of flex layout
---@field justifyContent JustifyContent Alignment of items along main axis
---@field alignItems AlignItems Alignment of items along cross axis
---@field alignContent AlignContent Alignment of lines in multi-line flex containers
---@field flexWrap FlexWrap Whether children wrap to multiple lines
---@field gap number Space between children elements
---@field gridRows number? Number of rows in the grid
---@field gridColumns number? Number of columns in the grid
---@field columnGap number? Gap between grid columns
---@field rowGap number? Gap between grid rows
local LayoutEngine = {}
LayoutEngine.__index = LayoutEngine

---@class LayoutEngineProps
---@field positioning Positioning? Layout positioning mode (default: RELATIVE)
---@field flexDirection FlexDirection? Direction of flex layout (default: HORIZONTAL)
---@field justifyContent JustifyContent? Alignment of items along main axis (default: FLEX_START)
---@field alignItems AlignItems? Alignment of items along cross axis (default: STRETCH)
---@field alignContent AlignContent? Alignment of lines in multi-line flex containers (default: STRETCH)
---@field flexWrap FlexWrap? Whether children wrap to multiple lines (default: NOWRAP)
---@field gap number? Space between children elements (default: 10)
---@field gridRows number? Number of rows in the grid
---@field gridColumns number? Number of columns in the grid
---@field columnGap number? Gap between grid columns
---@field rowGap number? Gap between grid rows

--- Create a new LayoutEngine instance
---@param props LayoutEngineProps
---@return LayoutEngine
function LayoutEngine.new(props)
  local self = setmetatable({}, LayoutEngine)
  
  -- Layout configuration
  self.positioning = props.positioning or Positioning.FLEX
  self.flexDirection = props.flexDirection or FlexDirection.HORIZONTAL
  self.justifyContent = props.justifyContent or JustifyContent.FLEX_START
  self.alignItems = props.alignItems or AlignItems.STRETCH
  self.alignContent = props.alignContent or AlignContent.STRETCH
  self.flexWrap = props.flexWrap or FlexWrap.NOWRAP
  self.gap = props.gap or 10
  
  -- Grid layout configuration
  self.gridRows = props.gridRows
  self.gridColumns = props.gridColumns
  self.columnGap = props.columnGap
  self.rowGap = props.rowGap
  
  -- Element reference (will be set via initialize)
  self.element = nil
  
  return self
end

--- Initialize the LayoutEngine with its parent element
---@param element Element The parent element
function LayoutEngine:initialize(element)
  self.element = element
end

--- Apply CSS positioning offsets (top, right, bottom, left) to a child element
---@param child Element The element to apply offsets to
function LayoutEngine:applyPositioningOffsets(child)
  if not child then
    return
  end

  -- For CSS-style positioning, we need the parent's bounds
  local parent = child.parent
  if not parent then
    return
  end

  -- Only apply offsets to explicitly absolute children or children in relative/absolute containers
  -- Flex/grid children ignore positioning offsets as they participate in layout
  local isFlexChild = child.positioning == Positioning.FLEX
    or child.positioning == Positioning.GRID
    or (child.positioning == Positioning.ABSOLUTE and not child._explicitlyAbsolute)

  if not isFlexChild then
    -- Apply absolute positioning for explicitly absolute children
    -- Apply top offset (distance from parent's content box top edge)
    if child.top then
      child.y = parent.y + parent.padding.top + child.top
    end

    -- Apply bottom offset (distance from parent's content box bottom edge)
    -- BORDER-BOX MODEL: Use border-box dimensions for positioning
    if child.bottom then
      local elementBorderBoxHeight = child:getBorderBoxHeight()
      child.y = parent.y + parent.padding.top + parent.height - child.bottom - elementBorderBoxHeight
    end

    -- Apply left offset (distance from parent's content box left edge)
    if child.left then
      child.x = parent.x + parent.padding.left + child.left
    end

    -- Apply right offset (distance from parent's content box right edge)
    -- BORDER-BOX MODEL: Use border-box dimensions for positioning
    if child.right then
      local elementBorderBoxWidth = child:getBorderBoxWidth()
      child.x = parent.x + parent.padding.left + parent.width - child.right - elementBorderBoxWidth
    end
  end
end

--- Layout children within this element according to positioning mode
function LayoutEngine:layoutChildren()
  local element = self.element
  
  if self.positioning == Positioning.ABSOLUTE or self.positioning == Positioning.RELATIVE then
    -- Absolute/Relative positioned containers don't layout their children according to flex rules,
    -- but they should still apply CSS positioning offsets to their children
    for _, child in ipairs(element.children) do
      if child.top or child.right or child.bottom or child.left then
        self:applyPositioningOffsets(child)
      end
    end
    return
  end

  -- Handle grid layout
  if self.positioning == Positioning.GRID then
    Grid.layoutGridItems(element)
    return
  end

  local childCount = #element.children

  if childCount == 0 then
    return
  end

  -- Get flex children (children that participate in flex layout)
  local flexChildren = {}
  for _, child in ipairs(element.children) do
    local isFlexChild = not (child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute)
    if isFlexChild then
      table.insert(flexChildren, child)
    end
  end

  if #flexChildren == 0 then
    return
  end

  -- Calculate space reserved by absolutely positioned siblings with explicit positioning
  local reservedMainStart = 0 -- Space reserved at the start of main axis (left for horizontal, top for vertical)
  local reservedMainEnd = 0 -- Space reserved at the end of main axis (right for horizontal, bottom for vertical)
  local reservedCrossStart = 0 -- Space reserved at the start of cross axis (top for horizontal, left for vertical)
  local reservedCrossEnd = 0 -- Space reserved at the end of cross axis (bottom for horizontal, right for vertical)

  for _, child in ipairs(element.children) do
    -- Only consider absolutely positioned children with explicit positioning
    if child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute then
      -- BORDER-BOX MODEL: Use border-box dimensions for space calculations
      local childBorderBoxWidth = child:getBorderBoxWidth()
      local childBorderBoxHeight = child:getBorderBoxHeight()

      if self.flexDirection == FlexDirection.HORIZONTAL then
        -- Horizontal layout: main axis is X, cross axis is Y
        -- Check for left positioning (reserves space at main axis start)
        if child.left then
          local spaceNeeded = child.left + childBorderBoxWidth
          reservedMainStart = math.max(reservedMainStart, spaceNeeded)
        end
        -- Check for right positioning (reserves space at main axis end)
        if child.right then
          local spaceNeeded = child.right + childBorderBoxWidth
          reservedMainEnd = math.max(reservedMainEnd, spaceNeeded)
        end
        -- Check for top positioning (reserves space at cross axis start)
        if child.top then
          local spaceNeeded = child.top + childBorderBoxHeight
          reservedCrossStart = math.max(reservedCrossStart, spaceNeeded)
        end
        -- Check for bottom positioning (reserves space at cross axis end)
        if child.bottom then
          local spaceNeeded = child.bottom + childBorderBoxHeight
          reservedCrossEnd = math.max(reservedCrossEnd, spaceNeeded)
        end
      else
        -- Vertical layout: main axis is Y, cross axis is X
        -- Check for top positioning (reserves space at main axis start)
        if child.top then
          local spaceNeeded = child.top + childBorderBoxHeight
          reservedMainStart = math.max(reservedMainStart, spaceNeeded)
        end
        -- Check for bottom positioning (reserves space at main axis end)
        if child.bottom then
          local spaceNeeded = child.bottom + childBorderBoxHeight
          reservedMainEnd = math.max(reservedMainEnd, spaceNeeded)
        end
        -- Check for left positioning (reserves space at cross axis start)
        if child.left then
          local spaceNeeded = child.left + childBorderBoxWidth
          reservedCrossStart = math.max(reservedCrossStart, spaceNeeded)
        end
        -- Check for right positioning (reserves space at cross axis end)
        if child.right then
          local spaceNeeded = child.right + childBorderBoxWidth
          reservedCrossEnd = math.max(reservedCrossEnd, spaceNeeded)
        end
      end
    end
  end

  -- Calculate available space (accounting for padding and reserved space)
  -- BORDER-BOX MODEL: element.width and element.height are already content dimensions (padding subtracted)
  local availableMainSize = 0
  local availableCrossSize = 0
  if self.flexDirection == FlexDirection.HORIZONTAL then
    availableMainSize = element.width - reservedMainStart - reservedMainEnd
    availableCrossSize = element.height - reservedCrossStart - reservedCrossEnd
  else
    availableMainSize = element.height - reservedMainStart - reservedMainEnd
    availableCrossSize = element.width - reservedCrossStart - reservedCrossEnd
  end

  -- Handle flex wrap: create lines of children
  local lines = {}

  if self.flexWrap == FlexWrap.NOWRAP then
    -- All children go on one line
    lines[1] = flexChildren
  else
    -- Wrap children into multiple lines
    local currentLine = {}
    local currentLineSize = 0

    for _, child in ipairs(flexChildren) do
      -- BORDER-BOX MODEL: Use border-box dimensions for layout calculations
      -- Include margins in size calculations
      local childMainSize = 0
      local childMainMargin = 0
      if self.flexDirection == FlexDirection.HORIZONTAL then
        childMainSize = child:getBorderBoxWidth()
        childMainMargin = child.margin.left + child.margin.right
      else
        childMainSize = child:getBorderBoxHeight()
        childMainMargin = child.margin.top + child.margin.bottom
      end
      local childTotalMainSize = childMainSize + childMainMargin

      -- Check if adding this child would exceed the available space
      local lineSpacing = #currentLine > 0 and self.gap or 0
      if #currentLine > 0 and currentLineSize + lineSpacing + childTotalMainSize > availableMainSize then
        -- Start a new line
        if #currentLine > 0 then
          table.insert(lines, currentLine)
        end
        currentLine = { child }
        currentLineSize = childTotalMainSize
      else
        -- Add to current line
        table.insert(currentLine, child)
        currentLineSize = currentLineSize + lineSpacing + childTotalMainSize
      end
    end

    -- Add the last line if it has children
    if #currentLine > 0 then
      table.insert(lines, currentLine)
    end

    -- Handle wrap-reverse: reverse the order of lines
    if self.flexWrap == FlexWrap.WRAP_REVERSE then
      local reversedLines = {}
      for i = #lines, 1, -1 do
        table.insert(reversedLines, lines[i])
      end
      lines = reversedLines
    end
  end

  -- Calculate line positions and heights (including child padding)
  local lineHeights = {}
  local totalLinesHeight = 0

  for lineIndex, line in ipairs(lines) do
    local maxCrossSize = 0
    for _, child in ipairs(line) do
      -- BORDER-BOX MODEL: Use border-box dimensions for layout calculations
      -- Include margins in cross-axis size calculations
      local childCrossSize = 0
      local childCrossMargin = 0
      if self.flexDirection == FlexDirection.HORIZONTAL then
        childCrossSize = child:getBorderBoxHeight()
        childCrossMargin = child.margin.top + child.margin.bottom
      else
        childCrossSize = child:getBorderBoxWidth()
        childCrossMargin = child.margin.left + child.margin.right
      end
      local childTotalCrossSize = childCrossSize + childCrossMargin
      maxCrossSize = math.max(maxCrossSize, childTotalCrossSize)
    end
    lineHeights[lineIndex] = maxCrossSize
    totalLinesHeight = totalLinesHeight + maxCrossSize
  end

  -- Account for gaps between lines
  local lineGaps = math.max(0, #lines - 1) * self.gap
  totalLinesHeight = totalLinesHeight + lineGaps

  -- For single line layouts, CENTER, FLEX_END and STRETCH should use full cross size
  if #lines == 1 then
    if self.alignItems == AlignItems.STRETCH or self.alignItems == AlignItems.CENTER or self.alignItems == AlignItems.FLEX_END then
      -- STRETCH, CENTER, and FLEX_END should use full available cross size
      lineHeights[1] = availableCrossSize
      totalLinesHeight = availableCrossSize
    end
    -- CENTER and FLEX_END should preserve natural child dimensions
    -- and only affect positioning within the available space
  end

  -- Calculate starting position for lines based on alignContent
  local lineStartPos = 0
  local lineSpacing = self.gap
  local freeLineSpace = availableCrossSize - totalLinesHeight

  -- Apply AlignContent logic for both single and multiple lines
  if self.alignContent == AlignContent.FLEX_START then
    lineStartPos = 0
  elseif self.alignContent == AlignContent.CENTER then
    lineStartPos = freeLineSpace / 2
  elseif self.alignContent == AlignContent.FLEX_END then
    lineStartPos = freeLineSpace
  elseif self.alignContent == AlignContent.SPACE_BETWEEN then
    lineStartPos = 0
    if #lines > 1 then
      lineSpacing = self.gap + (freeLineSpace / (#lines - 1))
    end
  elseif self.alignContent == AlignContent.SPACE_AROUND then
    local spaceAroundEach = freeLineSpace / #lines
    lineStartPos = spaceAroundEach / 2
    lineSpacing = self.gap + spaceAroundEach
  elseif self.alignContent == AlignContent.STRETCH then
    lineStartPos = 0
    if #lines > 1 and freeLineSpace > 0 then
      lineSpacing = self.gap + (freeLineSpace / #lines)
      -- Distribute extra space to line heights (only if positive)
      local extraPerLine = freeLineSpace / #lines
      for i = 1, #lineHeights do
        lineHeights[i] = lineHeights[i] + extraPerLine
      end
    end
  end

  -- Position children within each line
  local currentCrossPos = lineStartPos

  for lineIndex, line in ipairs(lines) do
    local lineHeight = lineHeights[lineIndex]

    -- Calculate total size of children in this line (including padding and margins)
    -- BORDER-BOX MODEL: Use border-box dimensions for layout calculations
    local totalChildrenSize = 0
    for _, child in ipairs(line) do
      if self.flexDirection == FlexDirection.HORIZONTAL then
        totalChildrenSize = totalChildrenSize + child:getBorderBoxWidth() + child.margin.left + child.margin.right
      else
        totalChildrenSize = totalChildrenSize + child:getBorderBoxHeight() + child.margin.top + child.margin.bottom
      end
    end

    local totalGapSize = math.max(0, #line - 1) * self.gap
    local totalContentSize = totalChildrenSize + totalGapSize
    local freeSpace = availableMainSize - totalContentSize

    -- Calculate initial position and spacing based on justifyContent
    local startPos = 0
    local itemSpacing = self.gap

    if self.justifyContent == JustifyContent.FLEX_START then
      startPos = 0
    elseif self.justifyContent == JustifyContent.CENTER then
      startPos = freeSpace / 2
    elseif self.justifyContent == JustifyContent.FLEX_END then
      startPos = freeSpace
    elseif self.justifyContent == JustifyContent.SPACE_BETWEEN then
      startPos = 0
      if #line > 1 then
        itemSpacing = self.gap + (freeSpace / (#line - 1))
      end
    elseif self.justifyContent == JustifyContent.SPACE_AROUND then
      local spaceAroundEach = freeSpace / #line
      startPos = spaceAroundEach / 2
      itemSpacing = self.gap + spaceAroundEach
    elseif self.justifyContent == JustifyContent.SPACE_EVENLY then
      local spaceBetween = freeSpace / (#line + 1)
      startPos = spaceBetween
      itemSpacing = self.gap + spaceBetween
    end

    -- Position children in this line
    local currentMainPos = startPos

    for _, child in ipairs(line) do
      -- Determine effective cross-axis alignment
      local effectiveAlign = child.alignSelf
      if effectiveAlign == nil or effectiveAlign == AlignSelf.AUTO then
        effectiveAlign = self.alignItems
      end

      if self.flexDirection == FlexDirection.HORIZONTAL then
        -- Horizontal layout: main axis is X, cross axis is Y
        -- Position child at border box (x, y represents top-left including padding)
        -- Add reservedMainStart and left margin to account for absolutely positioned siblings and margins
        child.x = element.x + element.padding.left + reservedMainStart + currentMainPos + child.margin.left

        -- BORDER-BOX MODEL: Use border-box dimensions for alignment calculations
        local childBorderBoxHeight = child:getBorderBoxHeight()
        local childTotalCrossSize = childBorderBoxHeight + child.margin.top + child.margin.bottom

        if effectiveAlign == AlignItems.FLEX_START then
          child.y = element.y + element.padding.top + reservedCrossStart + currentCrossPos + child.margin.top
        elseif effectiveAlign == AlignItems.CENTER then
          child.y = element.y + element.padding.top + reservedCrossStart + currentCrossPos + ((lineHeight - childTotalCrossSize) / 2) + child.margin.top
        elseif effectiveAlign == AlignItems.FLEX_END then
          child.y = element.y + element.padding.top + reservedCrossStart + currentCrossPos + lineHeight - childTotalCrossSize + child.margin.top
        elseif effectiveAlign == AlignItems.STRETCH then
          -- STRETCH: Only apply if height was not explicitly set
          if child.autosizing and child.autosizing.height then
            -- STRETCH: Set border-box height to lineHeight minus margins, content area shrinks to fit
            local availableHeight = lineHeight - child.margin.top - child.margin.bottom
            child._borderBoxHeight = availableHeight
            child.height = math.max(0, availableHeight - child.padding.top - child.padding.bottom)
          end
          child.y = element.y + element.padding.top + reservedCrossStart + currentCrossPos + child.margin.top
        end

        -- Apply positioning offsets (top, right, bottom, left)
        self:applyPositioningOffsets(child)

        -- If child has children, re-layout them after position change
        if #child.children > 0 then
          child:layoutChildren()
        end

        -- Advance position by child's border-box width plus margins
        currentMainPos = currentMainPos + child:getBorderBoxWidth() + child.margin.left + child.margin.right + itemSpacing
      else
        -- Vertical layout: main axis is Y, cross axis is X
        -- Position child at border box (x, y represents top-left including padding)
        -- Add reservedMainStart and top margin to account for absolutely positioned siblings and margins
        child.y = element.y + element.padding.top + reservedMainStart + currentMainPos + child.margin.top

        -- BORDER-BOX MODEL: Use border-box dimensions for alignment calculations
        local childBorderBoxWidth = child:getBorderBoxWidth()
        local childTotalCrossSize = childBorderBoxWidth + child.margin.left + child.margin.right

        if effectiveAlign == AlignItems.FLEX_START then
          child.x = element.x + element.padding.left + reservedCrossStart + currentCrossPos + child.margin.left
        elseif effectiveAlign == AlignItems.CENTER then
          child.x = element.x + element.padding.left + reservedCrossStart + currentCrossPos + ((lineHeight - childTotalCrossSize) / 2) + child.margin.left
        elseif effectiveAlign == AlignItems.FLEX_END then
          child.x = element.x + element.padding.left + reservedCrossStart + currentCrossPos + lineHeight - childTotalCrossSize + child.margin.left
        elseif effectiveAlign == AlignItems.STRETCH then
          -- STRETCH: Only apply if width was not explicitly set
          if child.autosizing and child.autosizing.width then
            -- STRETCH: Set border-box width to lineHeight minus margins, content area shrinks to fit
            local availableWidth = lineHeight - child.margin.left - child.margin.right
            child._borderBoxWidth = availableWidth
            child.width = math.max(0, availableWidth - child.padding.left - child.padding.right)
          end
          child.x = element.x + element.padding.left + reservedCrossStart + currentCrossPos + child.margin.left
        end

        -- Apply positioning offsets (top, right, bottom, left)
        self:applyPositioningOffsets(child)

        -- If child has children, re-layout them after position change
        if #child.children > 0 then
          child:layoutChildren()
        end

        -- Advance position by child's border-box height plus margins
        currentMainPos = currentMainPos + child:getBorderBoxHeight() + child.margin.top + child.margin.bottom + itemSpacing
      end
    end

    -- Move to next line position
    currentCrossPos = currentCrossPos + lineHeight + lineSpacing
  end

  -- Position explicitly absolute children after flex layout
  for _, child in ipairs(element.children) do
    if child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute then
      -- Apply positioning offsets (top, right, bottom, left)
      self:applyPositioningOffsets(child)

      -- If child has children, layout them after position change
      if #child.children > 0 then
        child:layoutChildren()
      end
    end
  end

  -- Detect overflow after children are laid out
  if element._detectOverflow then
    element:_detectOverflow()
  end
end

--- Calculate text width
---@return number The calculated text width
function LayoutEngine:calculateTextWidth()
  local element = self.element
  
  if element.text == nil then
    return 0
  end

  if element.textSize then
    -- Get font from Renderer (Phase 1 integration)
    local font = element._renderer:getFont(element)
    local width = font:getWidth(element.text)
    -- Apply contentAutoSizingMultiplier if set
    if element.contentAutoSizingMultiplier and element.contentAutoSizingMultiplier.width then
      width = width * element.contentAutoSizingMultiplier.width
    end
    return width
  end

  local font = love.graphics.getFont()
  local width = font:getWidth(element.text)
  -- Apply contentAutoSizingMultiplier if set
  if element.contentAutoSizingMultiplier and element.contentAutoSizingMultiplier.width then
    width = width * element.contentAutoSizingMultiplier.width
  end
  return width
end

--- Calculate text height
---@return number The calculated text height
function LayoutEngine:calculateTextHeight()
  local element = self.element
  
  if element.text == nil then
    return 0
  end

  -- Get the font
  local font
  if element.textSize then
    -- Get font from Renderer (Phase 1 integration)
    font = element._renderer:getFont(element)
  else
    font = love.graphics.getFont()
  end

  local height = font:getHeight()

  -- If text wrapping is enabled, calculate height based on wrapped lines
  if element.textWrap and (element.textWrap == "word" or element.textWrap == "char" or element.textWrap == true) then
    -- Calculate available width for wrapping
    local availableWidth = element.width

    -- If width is not set or is 0, try to use parent's content width
    if (not availableWidth or availableWidth <= 0) and element.parent then
      -- Use parent's content width (excluding padding)
      availableWidth = element.parent.width
    end

    if availableWidth and availableWidth > 0 then
      -- Get the wrapped text lines using getWrap (returns width and table of lines)
      local wrappedWidth, wrappedLines = font:getWrap(element.text, availableWidth)
      -- Height is line height * number of lines
      height = height * #wrappedLines
    end
  end

  -- Apply contentAutoSizingMultiplier if set
  if element.contentAutoSizingMultiplier and element.contentAutoSizingMultiplier.height then
    height = height * element.contentAutoSizingMultiplier.height
  end

  return height
end

--- Calculate auto width based on children
---@return number The calculated width
function LayoutEngine:calculateAutoWidth()
  local element = self.element
  
  -- BORDER-BOX MODEL: Calculate content width, caller will add padding to get border-box
  local contentWidth = self:calculateTextWidth()
  if not element.children or #element.children == 0 then
    return contentWidth
  end

  -- For HORIZONTAL flex: sum children widths + gaps
  -- For VERTICAL flex: max of children widths
  local isHorizontal = self.flexDirection == FlexDirection.HORIZONTAL
  local totalWidth = contentWidth
  local maxWidth = contentWidth
  local participatingChildren = 0

  for _, child in ipairs(element.children) do
    -- Skip explicitly absolute positioned children as they don't affect parent auto-sizing
    if not child._explicitlyAbsolute then
      -- BORDER-BOX MODEL: Use border-box width for auto-sizing calculations
      local childBorderBoxWidth = child:getBorderBoxWidth()
      if isHorizontal then
        totalWidth = totalWidth + childBorderBoxWidth
      else
        maxWidth = math.max(maxWidth, childBorderBoxWidth)
      end
      participatingChildren = participatingChildren + 1
    end
  end

  if isHorizontal then
    -- Add gaps between children (n-1 gaps for n children)
    local gapCount = math.max(0, participatingChildren - 1)
    return totalWidth + (self.gap * gapCount)
  else
    return maxWidth
  end
end

--- Calculate auto height based on children
---@return number The calculated height
function LayoutEngine:calculateAutoHeight()
  local element = self.element
  
  local height = self:calculateTextHeight()
  if not element.children or #element.children == 0 then
    return height
  end

  -- For VERTICAL flex: sum children heights + gaps
  -- For HORIZONTAL flex: max of children heights
  local isVertical = self.flexDirection == FlexDirection.VERTICAL
  local totalHeight = height
  local maxHeight = height
  local participatingChildren = 0

  for _, child in ipairs(element.children) do
    -- Skip explicitly absolute positioned children as they don't affect parent auto-sizing
    if not child._explicitlyAbsolute then
      -- BORDER-BOX MODEL: Use border-box height for auto-sizing calculations
      local childBorderBoxHeight = child:getBorderBoxHeight()
      if isVertical then
        totalHeight = totalHeight + childBorderBoxHeight
      else
        maxHeight = math.max(maxHeight, childBorderBoxHeight)
      end
      participatingChildren = participatingChildren + 1
    end
  end

  if isVertical then
    -- Add gaps between children (n-1 gaps for n children)
    local gapCount = math.max(0, participatingChildren - 1)
    return totalHeight + (self.gap * gapCount)
  else
    return maxHeight
  end
end

return LayoutEngine
