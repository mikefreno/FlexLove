-- ====================
-- LayoutEngine Module
-- ====================
-- Extracted layout calculation functionality from Element.lua
-- Handles flexbox, grid, absolute/relative positioning, and auto-sizing

-- Setup module path for relative requires
local modulePath = (...):match("(.-)[^%.]+$")
local function req(name)
  return require(modulePath .. name)
end

-- Module dependencies
local Grid = req("Grid")
local utils = req("utils")

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
---@field element Element -- Reference to parent element
---@field positioning Positioning -- Layout positioning mode
---@field flexDirection FlexDirection -- Direction of flex layout
---@field justifyContent JustifyContent -- Alignment of items along main axis
---@field alignItems AlignItems -- Alignment of items along cross axis
---@field alignContent AlignContent -- Alignment of lines in multi-line flex containers
---@field flexWrap FlexWrap -- Whether children wrap to multiple lines
---@field gridRows number? -- Number of rows in the grid
---@field gridColumns number? -- Number of columns in the grid
---@field columnGap number? -- Gap between grid columns
---@field rowGap number? -- Gap between grid rows
local LayoutEngine = {}
LayoutEngine.__index = LayoutEngine

--- Create a new LayoutEngine instance
---@param config table -- Configuration options
---@return LayoutEngine
function LayoutEngine.new(config)
  local self = setmetatable({}, LayoutEngine)
  
  -- Store layout configuration
  self.positioning = config.positioning or Positioning.RELATIVE
  self.flexDirection = config.flexDirection or FlexDirection.HORIZONTAL
  self.justifyContent = config.justifyContent or JustifyContent.FLEX_START
  self.alignItems = config.alignItems or AlignItems.STRETCH
  self.alignContent = config.alignContent or AlignContent.STRETCH
  self.flexWrap = config.flexWrap or FlexWrap.NOWRAP
  self.gridRows = config.gridRows
  self.gridColumns = config.gridColumns
  self.columnGap = config.columnGap
  self.rowGap = config.rowGap
  
  -- Element reference (set via initialize)
  self.element = nil
  
  return self
end

--- Initialize the layout engine with a reference to the parent element
---@param element Element -- The element this layout engine belongs to
function LayoutEngine:initialize(element)
  self.element = element
end

--- Apply positioning offsets (top, right, bottom, left) to an element
---@param child Element -- The child element to apply offsets to
function LayoutEngine:applyPositioningOffsets(child)
  if not child or not self.element then
    return
  end

  local parent = self.element

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
      local childBorderBoxHeight = child:getBorderBoxHeight()
      child.y = parent.y + parent.padding.top + parent.height - child.bottom - childBorderBoxHeight
    end

    -- Apply left offset (distance from parent's content box left edge)
    if child.left then
      child.x = parent.x + parent.padding.left + child.left
    end

    -- Apply right offset (distance from parent's content box right edge)
    -- BORDER-BOX MODEL: Use border-box dimensions for positioning
    if child.right then
      local childBorderBoxWidth = child:getBorderBoxWidth()
      child.x = parent.x + parent.padding.left + parent.width - child.right - childBorderBoxWidth
    end
  end
end

--- Calculate auto-width based on children and text content
---@return number -- Calculated content width
function LayoutEngine:calculateAutoWidth()
  if not self.element then
    return 0
  end

  -- BORDER-BOX MODEL: Calculate content width, caller will add padding to get border-box
  local contentWidth = self.element:calculateTextWidth()
  if not self.element.children or #self.element.children == 0 then
    return contentWidth
  end

  -- For HORIZONTAL flex: sum children widths + gaps
  -- For VERTICAL flex: max of children widths
  local isHorizontal = self.flexDirection == FlexDirection.HORIZONTAL
  local totalWidth = contentWidth
  local maxWidth = contentWidth
  local participatingChildren = 0

  for _, child in ipairs(self.element.children) do
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
    return totalWidth + (self.element.gap * gapCount)
  else
    return maxWidth
  end
end

--- Calculate auto-height based on children and text content
---@return number -- Calculated content height
function LayoutEngine:calculateAutoHeight()
  if not self.element then
    return 0
  end

  local height = self.element:calculateTextHeight()
  if not self.element.children or #self.element.children == 0 then
    return height
  end

  -- For VERTICAL flex: sum children heights + gaps
  -- For HORIZONTAL flex: max of children heights
  local isVertical = self.flexDirection == FlexDirection.VERTICAL
  local totalHeight = height
  local maxHeight = height
  local participatingChildren = 0

  for _, child in ipairs(self.element.children) do
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
    return totalHeight + (self.element.gap * gapCount)
  else
    return maxHeight
  end
end

--- Main layout calculation - positions all children according to layout mode
function LayoutEngine:layoutChildren()
  if not self.element then
    return
  end

  -- Handle different positioning modes
  if self.positioning == Positioning.ABSOLUTE or self.positioning == Positioning.RELATIVE then
    -- Absolute/Relative positioned containers don't layout their children according to flex rules,
    -- but they should still apply CSS positioning offsets to their children
    for _, child in ipairs(self.element.children) do
      if child.top or child.right or child.bottom or child.left then
        self:applyPositioningOffsets(child)
      end
    end
    return
  end

  -- Handle grid layout
  if self.positioning == Positioning.GRID then
    self:calculateGridLayout()
    return
  end

  -- Handle flex layout
  self:calculateFlexLayout()
end

--- Calculate grid layout for children
function LayoutEngine:calculateGridLayout()
  if not self.element then
    return
  end

  -- Delegate to Grid module
  Grid.layoutGridItems(self.element)
end

--- Calculate flexbox layout for children
function LayoutEngine:calculateFlexLayout()
  if not self.element then
    return
  end

  local childCount = #self.element.children

  if childCount == 0 then
    return
  end

  -- Get flex children (children that participate in flex layout)
  local flexChildren = {}
  for _, child in ipairs(self.element.children) do
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

  for _, child in ipairs(self.element.children) do
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
  -- BORDER-BOX MODEL: self.element.width and self.element.height are already content dimensions (padding subtracted)
  local availableMainSize = 0
  local availableCrossSize = 0
  if self.flexDirection == FlexDirection.HORIZONTAL then
    availableMainSize = self.element.width - reservedMainStart - reservedMainEnd
    availableCrossSize = self.element.height - reservedCrossStart - reservedCrossEnd
  else
    availableMainSize = self.element.height - reservedMainStart - reservedMainEnd
    availableCrossSize = self.element.width - reservedCrossStart - reservedCrossEnd
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
      local lineSpacing = #currentLine > 0 and self.element.gap or 0
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
  local lineGaps = math.max(0, #lines - 1) * self.element.gap
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
  local lineSpacing = self.element.gap
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
      lineSpacing = self.element.gap + (freeLineSpace / (#lines - 1))
    end
  elseif self.alignContent == AlignContent.SPACE_AROUND then
    local spaceAroundEach = freeLineSpace / #lines
    lineStartPos = spaceAroundEach / 2
    lineSpacing = self.element.gap + spaceAroundEach
  elseif self.alignContent == AlignContent.STRETCH then
    lineStartPos = 0
    if #lines > 1 and freeLineSpace > 0 then
      lineSpacing = self.element.gap + (freeLineSpace / #lines)
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

    local totalGapSize = math.max(0, #line - 1) * self.element.gap
    local totalContentSize = totalChildrenSize + totalGapSize
    local freeSpace = availableMainSize - totalContentSize

    -- Calculate initial position and spacing based on justifyContent
    local startPos = 0
    local itemSpacing = self.element.gap

    if self.justifyContent == JustifyContent.FLEX_START then
      startPos = 0
    elseif self.justifyContent == JustifyContent.CENTER then
      startPos = freeSpace / 2
    elseif self.justifyContent == JustifyContent.FLEX_END then
      startPos = freeSpace
    elseif self.justifyContent == JustifyContent.SPACE_BETWEEN then
      startPos = 0
      if #line > 1 then
        itemSpacing = self.element.gap + (freeSpace / (#line - 1))
      end
    elseif self.justifyContent == JustifyContent.SPACE_AROUND then
      local spaceAroundEach = freeSpace / #line
      startPos = spaceAroundEach / 2
      itemSpacing = self.element.gap + spaceAroundEach
    elseif self.justifyContent == JustifyContent.SPACE_EVENLY then
      local spaceBetween = freeSpace / (#line + 1)
      startPos = spaceBetween
      itemSpacing = self.element.gap + spaceBetween
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
        child.x = self.element.x + self.element.padding.left + reservedMainStart + currentMainPos + child.margin.left

        -- BORDER-BOX MODEL: Use border-box dimensions for alignment calculations
        local childBorderBoxHeight = child:getBorderBoxHeight()
        local childTotalCrossSize = childBorderBoxHeight + child.margin.top + child.margin.bottom

        if effectiveAlign == AlignItems.FLEX_START then
          child.y = self.element.y + self.element.padding.top + reservedCrossStart + currentCrossPos + child.margin.top
        elseif effectiveAlign == AlignItems.CENTER then
          child.y = self.element.y + self.element.padding.top + reservedCrossStart + currentCrossPos + ((lineHeight - childTotalCrossSize) / 2) + child.margin.top
        elseif effectiveAlign == AlignItems.FLEX_END then
          child.y = self.element.y + self.element.padding.top + reservedCrossStart + currentCrossPos + lineHeight - childTotalCrossSize + child.margin.top
        elseif effectiveAlign == AlignItems.STRETCH then
          -- STRETCH: Only apply if height was not explicitly set
          if child.autosizing and child.autosizing.height then
            -- STRETCH: Set border-box height to lineHeight minus margins, content area shrinks to fit
            local availableHeight = lineHeight - child.margin.top - child.margin.bottom
            child._borderBoxHeight = availableHeight
            child.height = math.max(0, availableHeight - child.padding.top - child.padding.bottom)
          end
          child.y = self.element.y + self.element.padding.top + reservedCrossStart + currentCrossPos + child.margin.top
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
        child.y = self.element.y + self.element.padding.top + reservedMainStart + currentMainPos + child.margin.top

        -- BORDER-BOX MODEL: Use border-box dimensions for alignment calculations
        local childBorderBoxWidth = child:getBorderBoxWidth()
        local childTotalCrossSize = childBorderBoxWidth + child.margin.left + child.margin.right

        if effectiveAlign == AlignItems.FLEX_START then
          child.x = self.element.x + self.element.padding.left + reservedCrossStart + currentCrossPos + child.margin.left
        elseif effectiveAlign == AlignItems.CENTER then
          child.x = self.element.x + self.element.padding.left + reservedCrossStart + currentCrossPos + ((lineHeight - childTotalCrossSize) / 2) + child.margin.left
        elseif effectiveAlign == AlignItems.FLEX_END then
          child.x = self.element.x + self.element.padding.left + reservedCrossStart + currentCrossPos + lineHeight - childTotalCrossSize + child.margin.left
        elseif effectiveAlign == AlignItems.STRETCH then
          -- STRETCH: Only apply if width was not explicitly set
          if child.autosizing and child.autosizing.width then
            -- STRETCH: Set border-box width to lineHeight minus margins, content area shrinks to fit
            local availableWidth = lineHeight - child.margin.left - child.margin.right
            child._borderBoxWidth = availableWidth
            child.width = math.max(0, availableWidth - child.padding.left - child.padding.right)
          end
          child.x = self.element.x + self.element.padding.left + reservedCrossStart + currentCrossPos + child.margin.left
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
  for _, child in ipairs(self.element.children) do
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
  self.element:_detectOverflow()
end

--- Get content bounds (position and dimensions of content area)
---@return table -- {x, y, width, height}
function LayoutEngine:getContentBounds()
  if not self.element then
    return { x = 0, y = 0, width = 0, height = 0 }
  end

  return {
    x = self.element.x + self.element.padding.left,
    y = self.element.y + self.element.padding.top,
    width = self.element.width,
    height = self.element.height,
  }
end

return LayoutEngine
