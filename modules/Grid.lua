local modulePath = (...):match("(.-)[^%.]+$")
local utils = require(modulePath .. "utils")
local enums = utils.enums

local Positioning = enums.Positioning
local AlignItems = enums.AlignItems

--- Simple grid layout calculations
local Grid = {}

--- Layout grid items within a grid container using simple row/column counts
---@param element Element -- Grid container element
function Grid.layoutGridItems(element)
  -- Ensure valid row/column counts (must be at least 1 to avoid division by zero)
  local rows = element.gridRows and element.gridRows > 0 and element.gridRows or 1
  local columns = element.gridColumns and element.gridColumns > 0 and element.gridColumns or 1

  -- Calculate space reserved by absolutely positioned siblings
  local reservedLeft = 0
  local reservedRight = 0
  local reservedTop = 0
  local reservedBottom = 0

  for _, child in ipairs(element.children) do
    -- Only consider absolutely positioned children with explicit positioning
    if child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute then
      -- BORDER-BOX MODEL: Use border-box dimensions for space calculations
      local childBorderBoxWidth = child:getBorderBoxWidth()
      local childBorderBoxHeight = child:getBorderBoxHeight()

      if child.left then
        reservedLeft = math.max(reservedLeft, child.left + childBorderBoxWidth)
      end
      if child.right then
        reservedRight = math.max(reservedRight, child.right + childBorderBoxWidth)
      end
      if child.top then
        reservedTop = math.max(reservedTop, child.top + childBorderBoxHeight)
      end
      if child.bottom then
        reservedBottom = math.max(reservedBottom, child.bottom + childBorderBoxHeight)
      end
    end
  end

  -- Calculate available space (accounting for padding and reserved space)
  -- BORDER-BOX MODEL: element.width and element.height are already content dimensions
  local availableWidth = element.width - reservedLeft - reservedRight
  local availableHeight = element.height - reservedTop - reservedBottom

  -- Get gaps
  local columnGap = element.columnGap or 0
  local rowGap = element.rowGap or 0

  -- Calculate cell sizes (equal distribution)
  local totalColumnGaps = (columns - 1) * columnGap
  local totalRowGaps = (rows - 1) * rowGap
  local cellWidth = (availableWidth - totalColumnGaps) / columns
  local cellHeight = (availableHeight - totalRowGaps) / rows

  local gridChildren = {}
  for _, child in ipairs(element.children) do
    if not (child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute) then
      table.insert(gridChildren, child)
    end
  end

  for i, child in ipairs(gridChildren) do
    -- Calculate row and column (0-indexed for calculation)
    local index = i - 1
    local col = index % columns
    local row = math.floor(index / columns)

    if row >= rows then
      break
    end

    -- Calculate cell position (accounting for reserved space)
    local cellX = element.x + element.padding.left + reservedLeft + (col * (cellWidth + columnGap))
    local cellY = element.y + element.padding.top + reservedTop + (row * (cellHeight + rowGap))

    -- Apply alignment within grid cell (default to stretch)
    local effectiveAlignItems = element.alignItems or AlignItems.STRETCH

    -- BORDER-BOX MODEL: Set border-box dimensions, content area adjusts automatically
    if effectiveAlignItems == AlignItems.STRETCH or effectiveAlignItems == "stretch" then
      child.x = cellX
      child.y = cellY
      child._borderBoxWidth = cellWidth
      child._borderBoxHeight = cellHeight
      child.width = math.max(0, cellWidth - child.padding.left - child.padding.right)
      child.height = math.max(0, cellHeight - child.padding.top - child.padding.bottom)
      -- Disable auto-sizing when stretched by grid
      child.autosizing.width = false
      child.autosizing.height = false
    elseif effectiveAlignItems == AlignItems.CENTER or effectiveAlignItems == "center" then
      local childBorderBoxWidth = child:getBorderBoxWidth()
      local childBorderBoxHeight = child:getBorderBoxHeight()
      child.x = cellX + (cellWidth - childBorderBoxWidth) / 2
      child.y = cellY + (cellHeight - childBorderBoxHeight) / 2
    elseif effectiveAlignItems == AlignItems.FLEX_START or effectiveAlignItems == "flex-start" or effectiveAlignItems == "start" then
      child.x = cellX
      child.y = cellY
    elseif effectiveAlignItems == AlignItems.FLEX_END or effectiveAlignItems == "flex-end" or effectiveAlignItems == "end" then
      local childBorderBoxWidth = child:getBorderBoxWidth()
      local childBorderBoxHeight = child:getBorderBoxHeight()
      child.x = cellX + cellWidth - childBorderBoxWidth
      child.y = cellY + cellHeight - childBorderBoxHeight
    else
      child.x = cellX
      child.y = cellY
      child._borderBoxWidth = cellWidth
      child._borderBoxHeight = cellHeight
      child.width = math.max(0, cellWidth - child.padding.left - child.padding.right)
      child.height = math.max(0, cellHeight - child.padding.top - child.padding.bottom)
      -- Disable auto-sizing when stretched by grid
      child.autosizing.width = false
      child.autosizing.height = false
    end

    if #child.children > 0 then
      child:layoutChildren()
    end
  end
end

return Grid
