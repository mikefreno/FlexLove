-- Utility class for color handling
---@class Color
---@field r number -- Red component (0-1)
---@field g number -- Green component (0-1)
---@field b number -- Blue component (0-1)
---@field a number -- Alpha component (0-1)
local Color = {}
Color.__index = Color

--- Create a new color instance
---@param r number
---@param g number
---@param b number
---@param a number? -- default 1
---@return Color
function Color.new(r, g, b, a)
  local self = setmetatable({}, Color)
  self.r = r or 0
  self.g = g or 0
  self.b = b or 0
  self.a = a or 1
  return self
end

--- Convert hex string to color
---@param hexWithTag string -- e.g. "#RRGGBB" or "#RRGGBBAA"
---@return Color
function Color.fromHex(hexWithTag)
  local hex = hexWithTag:gsub("#", "")
  if #hex == 6 then
    local r = tonumber("0x" .. hex:sub(1, 2)) or 0
    local g = tonumber("0x" .. hex:sub(3, 4)) or 0
    local b = tonumber("0x" .. hex:sub(5, 6)) or 0
    return Color.new(r, g, b, 1)
  elseif #hex == 8 then
    local r = tonumber("0x" .. hex:sub(1, 2)) or 0
    local g = tonumber("0x" .. hex:sub(3, 4)) or 0
    local b = tonumber("0x" .. hex:sub(5, 6)) or 0
    local a = tonumber("0x" .. hex:sub(7, 8)) / 255
    return Color.new(r, g, b, a)
  else
    error("Invalid hex string")
  end
end

---@return number r, number g, number b, number a
function Color:toRGBA()
  return self.r, self.g, self.b, self.a
end

local enums = {}

--- @enum TextAlign
enums.TextAlign = {
  START = "start",
  CENTER = "center",
  END = "end",
  JUSTIFY = "justify",
}

--- @enum Positioning
enums.Positioning = {
  ABSOLUTE = "absolute",
  FLEX = "flex",
}

--- @enum FlexDirection
enums.FlexDirection = {
  HORIZONTAL = "horizontal",
  VERTICAL = "vertical",
}

--- @enum JustifyContent
enums.JustifyContent = {
  FLEX_START = "flex-start",
  CENTER = "center",
  SPACE_AROUND = "space-around",
  FLEX_END = "flex-end",
  SPACE_EVENLY = "space-evenly",
  SPACE_BETWEEN = "space-between",
}

--- @enum JustifySelf
enums.JustifySelf = {
  AUTO = "auto",
  FLEX_START = "flex-start",
  CENTER = "center",
  FLEX_END = "flex-end",
  SPACE_AROUND = "space-around",
  SPACE_EVENLY = "space-evenly",
  SPACE_BETWEEN = "space-between",
}

--- @enum AlignItems
enums.AlignItems = {
  STRETCH = "stretch",
  FLEX_START = "flex-start",
  FLEX_END = "flex-end",
  CENTER = "center",
  BASELINE = "baseline",
}

--- @enum AlignSelf
enums.AlignSelf = {
  AUTO = "auto",
  STRETCH = "stretch",
  FLEX_START = "flex-start",
  FLEX_END = "flex-end",
  CENTER = "center",
  BASELINE = "baseline",
}

--- @enum AlignContent
enums.AlignContent = {
  STRETCH = "stretch",
  FLEX_START = "flex-start",
  FLEX_END = "flex-end",
  CENTER = "center",
  SPACE_BETWEEN = "space-between",
  SPACE_AROUND = "space-around",
}

--- @enum FlexWrap
enums.FlexWrap = {
  NOWRAP = "nowrap",
  WRAP = "wrap",
  WRAP_REVERSE = "wrap-reverse",
}

local Positioning, FlexDirection, JustifyContent, AlignContent, AlignItems, TextAlign, AlignSelf, JustifySelf, FlexWrap =
  enums.Positioning,
  enums.FlexDirection,
  enums.JustifyContent,
  enums.AlignContent,
  enums.AlignItems,
  enums.TextAlign,
  enums.AlignSelf,
  enums.JustifySelf,
  enums.FlexWrap

--- Top level GUI manager
---@class Gui
---@field topElements table<integer, Element>
---@field resize fun(): nil
---@field draw fun(): nil
---@field update fun(dt:number): nil
---@field destroy fun(): nil
local Gui = { topElements = {} }

function Gui.resize()
  local newWidth, newHeight = love.window.getMode()
  for _, win in ipairs(Gui.topElements) do
    win:resize(newWidth, newHeight)
  end
end

function Gui.draw()
  -- Sort elements by z-index before drawing
  table.sort(Gui.topElements, function(a, b)
    return a.z < b.z
  end)

  for _, win in ipairs(Gui.topElements) do
    win:draw()
  end
end

function Gui.update(dt)
  for _, win in ipairs(Gui.topElements) do
    win:update(dt)
  end
end

--- Destroy all elements and their children
function Gui.destroy()
  for _, win in ipairs(Gui.topElements) do
    win:destroy()
  end
  Gui.topElements = {}
end

-- Simple GUI library for LOVE2D
-- Provides element and button creation, drawing, and click handling.

---@class Animation
---@field duration number
---@field start {width?:number, height?:number, opacity?:number}
---@field final {width?:number, height?:number, opacity?:number}
---@field elapsed number
---@field transform table?
---@field transition table?
local Animation = {}
Animation.__index = Animation

---@class AnimationProps
---@field duration number
---@field start {width?:number, height?:number, opacity?:number}
---@field final {width?:number, height?:number, opacity?:number}
---@field transform table?
---@field transition table?
local AnimationProps = {}

---@class TransformProps
---@field scale {x?:number, y?:number}?
---@field rotate number?
---@field translate {x?:number, y?:number}?
---@field skew {x?:number, y?:number}?

---@class TransitionProps
---@field duration number?
---@field easing string?

---@param props AnimationProps
---@return Animation
function Animation.new(props)
  local self = setmetatable({}, Animation)
  self.duration = props.duration
  self.start = props.start
  self.final = props.final
  self.transform = props.transform
  self.transition = props.transition
  self.elapsed = 0
  return self
end

---@param dt number
---@return boolean
function Animation:update(dt)
  self.elapsed = self.elapsed + dt
  if self.elapsed >= self.duration then
    return true -- finished
  else
    return false
  end
end

---@return table
function Animation:interpolate()
  local t = math.min(self.elapsed / self.duration, 1)
  local result = {}

  -- Handle width and height if present
  if self.start.width and self.final.width then
    result.width = self.start.width * (1 - t) + self.final.width * t
  end

  if self.start.height and self.final.height then
    result.height = self.start.height * (1 - t) + self.final.height * t
  end

  -- Handle other properties like opacity
  if self.start.opacity and self.final.opacity then
    result.opacity = self.start.opacity * (1 - t) + self.final.opacity * t
  end

  -- Apply transform if present
  if self.transform then
    for key, value in pairs(self.transform) do
      result[key] = value
    end
  end

  return result
end

--- Apply animation to a GUI element
---@param element Element
function Animation:apply(element)
  if element.animation then
    -- If there's an existing animation, we should probably stop it or replace it
    element.animation = self
  else
    element.animation = self
  end
end

--- Create a simple fade animation
---@param duration number
---@param fromOpacity number
---@param toOpacity number
---@return Animation
function Animation.fade(duration, fromOpacity, toOpacity)
  return Animation.new({
    duration = duration,
    start = { opacity = fromOpacity },
    final = { opacity = toOpacity },
    transform = {},
    transition = {},
  })
end

--- Create a simple scale animation
---@param duration number
---@param fromScale table{width:number,height:number}
---@param toScale table{width:number,height:number}
---@return Animation
function Animation.scale(duration, fromScale, toScale)
  return Animation.new({
    duration = duration,
    start = { width = fromScale.width, height = fromScale.height },
    final = { width = toScale.width, height = toScale.height },
    transform = {},
    transition = {},
  })
end

local FONT_CACHE = {}

--- Create or get a font from cache
---@param size number
---@return love.Font
function FONT_CACHE.get(size)
  if not FONT_CACHE[size] then
    FONT_CACHE[size] = love.graphics.newFont(size)
  end
  return FONT_CACHE[size]
end

--- Get font for text size (cached)
---@param textSize number?
---@return love.Font
function FONT_CACHE.getFont(textSize)
  if textSize then
    return FONT_CACHE.get(textSize)
  else
    return love.graphics.getFont()
  end
end

---@class Border
---@field top boolean?
---@field right boolean?
---@field bottom boolean?
---@field left boolean?

-- ====================
-- Element Object
-- ====================
---@class Element
---@field id string?
---@field autosizing {width:boolean, height:boolean} -- Whether the element should automatically size to fit its children
---@field x number -- X coordinate of the element
---@field y number -- Y coordinate of the element
---@field z number -- Z-index for layering (default: 0)
---@field width number -- Width of the element
---@field height number -- Height of the element
---@field children table<integer, Element> -- Children of this element
---@field parent Element? -- Parent element (nil if top-level)
---@field border Border -- Border configuration for the element
---@field opacity number
---@field borderColor Color -- Color of the border
---@field background Color -- Background color of the element
---@field prevGameSize {width:number, height:number} -- Previous game size for resize calculations
---@field text string? -- Text content to display in the element
---@field textColor Color -- Color of the text content
---@field textAlign TextAlign -- Alignment of the text content
---@field gap number -- Space between children elements (default: 10)
---@field padding {top?:number, right?:number, bottom?:number, left?:number}? -- Padding around children (default: {top=0, right=0, bottom=0, left=0})
---@field margin {top?:number, right?:number, bottom?:number, left?:number} -- Margin around children (default: {top=0, right=0, bottom=0, left=0})
---@field positioning Positioning -- Layout positioning mode (default: ABSOLUTE)
---@field flexDirection FlexDirection -- Direction of flex layout (default: HORIZONTAL)
---@field justifyContent JustifyContent -- Alignment of items along main axis (default: FLEX_START)
---@field alignItems AlignItems -- Alignment of items along cross axis (default: STRETCH)
---@field alignContent AlignContent -- Alignment of lines in multi-line flex containers (default: STRETCH)
---@field flexWrap FlexWrap -- Whether children wrap to multiple lines (default: NOWRAP)
---@field justifySelf JustifySelf -- Alignment of the item itself along main axis (default: AUTO)
---@field alignSelf AlignSelf -- Alignment of the item itself along cross axis (default: AUTO)
---@field textSize number? -- Font size for text content
---@field transform TransformProps -- Transform properties for animations and styling
---@field transition TransitionProps -- Transition settings for animations
---@field callback function? -- Callback function for click events
local Element = {}
Element.__index = Element

---@class ElementProps
---@field parent Element? -- Parent element for hierarchical structure
---@field id string?
---@field x number? -- X coordinate of the element (default: 0)
---@field y number? -- Y coordinate of the element (default: 0)
---@field z number? -- Z-index for layering (default: 0)
---@field w number? -- Width of the element (default: calculated automatically)
---@field h number? -- Height of the element (default: calculated automatically)
---@field border Border? -- Border configuration for the element
---@field borderColor Color? -- Color of the border (default: black)
---@field opacity number?
---@field background Color? -- Background color (default: transparent)
---@field gap number? -- Space between children elements (default: 10)
---@field padding {top:number?, right:number?, bottom:number?, left:number?, horizontal: number?, vertical:number?}? -- Padding around children (default: {top=0, right=0, bottom=0, left=0})
---@field margin {top:number?, right:number?, bottom:number?, left:number?, horizontal: number?, vertical:number?}? -- Margin around children (default: {top=0, right=0, bottom=0, left=0})
---@field text string? -- Text content to display (default: nil)
---@field titleColor Color? -- Color of the text content (default: black)
---@field textAlign TextAlign? -- Alignment of the text content (default: START)
---@field textColor Color? -- Color of the text content (default: black)
---@field textSize number? -- Font size for text content (default: nil)
---@field positioning Positioning? -- Layout positioning mode (default: ABSOLUTE)
---@field flexDirection FlexDirection? -- Direction of flex layout (default: HORIZONTAL)
---@field justifyContent JustifyContent? -- Alignment of items along main axis (default: FLEX_START)
---@field alignItems AlignItems? -- Alignment of items along cross axis (default: STRETCH)
---@field alignContent AlignContent? -- Alignment of lines in multi-line flex containers (default: STRETCH)
---@field flexWrap FlexWrap? -- Whether children wrap to multiple lines (default: NOWRAP)
---@field justifySelf JustifySelf? -- Alignment of the item itself along main axis (default: AUTO)
---@field alignSelf AlignSelf? -- Alignment of the item itself along cross axis (default: AUTO)
---@field callback function? -- Callback function for click events
---@field transform table? -- Transform properties for animations and styling
---@field transition table? -- Transition settings for animations
local ElementProps = {}

---@param props ElementProps
---@return Element
function Element.new(props)
  local self = setmetatable({}, Element)
  self.children = {}
  self.id = props.id or ""
  self.callback = props.callback

  ------ add non-hereditary ------
  --- self drawing---
  self.border = props.border
      and {
        top = props.border.top or false,
        right = props.border.right or false,
        bottom = props.border.bottom or false,
        left = props.border.left or false,
      }
    or {
      top = false,
      right = false,
      bottom = false,
      left = false,
    }
  self.borderColor = props.borderColor or Color.new(0, 0, 0, 1)
  self.background = props.background or Color.new(0, 0, 0, 0)
  self.opacity = props.opacity or 1

  self.text = props.text
  self.textSize = props.textSize
  self.textAlign = props.textAlign or TextAlign.START

  --- self positioning ---
  self.padding = props.padding
      and {
        top = props.padding.top or props.padding.vertical or 0,
        right = props.padding.right or props.padding.horizontal or 0,
        bottom = props.padding.bottom or props.padding.vertical or 0,
        left = props.padding.left or props.padding.horizontal or 0,
      }
    or {
      top = 0,
      right = 0,
      bottom = 0,
      left = 0,
    }

  self.margin = props.margin
      and {
        top = props.margin.top or props.margin.vertical or 0,
        right = props.margin.right or props.margin.horizontal or 0,
        bottom = props.margin.bottom or props.margin.vertical or 0,
        left = props.margin.left or props.margin.horizontal or 0,
      }
    or {
      top = 0,
      right = 0,
      bottom = 0,
      left = 0,
    }

  ---- Sizing ----
  local gw, gh = love.window.getMode()
  self.prevGameSize = { width = gw, height = gh }
  self.autosizing = { width = false, height = false }

  if props.w then
    self.width = props.w
  else
    self.autosizing.width = true
    self.width = self:calculateAutoWidth()
  end
  if props.h then
    self.height = props.h
  else
    self.autosizing.height = true
    self.height = self:calculateAutoHeight()
  end

  --- child positioning ---
  self.gap = props.gap or 10

  ------ add hereditary ------
  if props.parent == nil then
    table.insert(Gui.topElements, self)

    self.x = props.x or 0
    self.y = props.y or 0
    self.z = props.z or 0

    self.textColor = props.textColor or Color.new(0, 0, 0, 1)

    -- Track if positioning was explicitly set
    if props.positioning then
      self.positioning = props.positioning
      self._originalPositioning = props.positioning
      self._explicitlyAbsolute = (props.positioning == Positioning.ABSOLUTE)
    else
      self.positioning = Positioning.ABSOLUTE
      self._originalPositioning = nil -- No explicit positioning
      self._explicitlyAbsolute = false
    end
  else
    self.parent = props.parent

    -- Set positioning first and track if explicitly set
    self._originalPositioning = props.positioning -- Track original intent
    if props.positioning == Positioning.ABSOLUTE then
      self.positioning = Positioning.ABSOLUTE
      self._explicitlyAbsolute = true -- Explicitly set to absolute by user
    elseif props.positioning == Positioning.FLEX then
      self.positioning = Positioning.FLEX
      self._explicitlyAbsolute = false
    else
      -- Default: children in flex containers participate in flex layout
      -- children in absolute containers default to absolute
      if self.parent.positioning == Positioning.FLEX then
        self.positioning = Positioning.ABSOLUTE -- They are positioned BY flex, not AS flex
        self._explicitlyAbsolute = false -- Participate in parent's flex layout
      else
        self.positioning = Positioning.ABSOLUTE
        self._explicitlyAbsolute = false -- Default for absolute containers
      end
    end

    -- Set initial position
    if self.positioning == Positioning.ABSOLUTE then
      self.x = props.x or 0
      self.y = props.y or 0
      self.z = props.z or 0
    else
      -- Children in flex containers start at parent position but will be repositioned by layoutChildren
      self.x = self.parent.x + (props.x or 0)
      self.y = self.parent.y + (props.y or 0)
      self.z = props.z or self.parent.z or 0
    end

    self.textColor = props.textColor or self.parent.textColor

    props.parent:addChild(self)
  end

  if self.positioning == Positioning.FLEX then
    self.flexDirection = props.flexDirection or FlexDirection.HORIZONTAL
    self.flexWrap = props.flexWrap or FlexWrap.NOWRAP
    self.justifyContent = props.justifyContent or JustifyContent.FLEX_START
    self.alignItems = props.alignItems or AlignItems.STRETCH
    self.alignContent = props.alignContent or AlignContent.STRETCH
    self.justifySelf = props.justifySelf or JustifySelf.AUTO
  end

  self.alignSelf = props.alignSelf or AlignSelf.AUTO

  ---animation
  self.transform = props.transform or {}
  self.transition = props.transition or {}

  return self
end

--- Get element bounds
---@return { x:number, y:number, width:number, height:number }
function Element:getBounds()
  return { x = self.x, y = self.y, width = self.width, height = self.height }
end

--- Add child to element
---@param child Element
function Element:addChild(child)
  child.parent = self

  -- Re-evaluate positioning now that we have a parent
  -- If child was created without explicit positioning, inherit from parent
  if child._originalPositioning == nil then
    -- No explicit positioning was set during construction
    if self.positioning == Positioning.FLEX then
      child.positioning = Positioning.ABSOLUTE -- They are positioned BY flex, not AS flex
      child._explicitlyAbsolute = false -- Participate in parent's flex layout
    else
      child.positioning = Positioning.ABSOLUTE
      child._explicitlyAbsolute = false -- Default for absolute containers
    end
  end
  -- If child._originalPositioning is set, it means explicit positioning was provided
  -- and _explicitlyAbsolute was already set correctly during construction

  table.insert(self.children, child)

  if self.autosizing.height then
    self.height = self:calculateAutoHeight()
  end
  if self.autosizing.width then
    self.width = self:calculateAutoWidth()
  end

  self:layoutChildren()
end

function Element:layoutChildren()
  if self.positioning == Positioning.ABSOLUTE then
    -- Absolute positioned containers don't layout their children according to flex rules
    return
  end

  local childCount = #self.children

  if childCount == 0 then
    return
  end

  -- Get flex children (children that participate in flex layout)
  local flexChildren = {}
  for _, child in ipairs(self.children) do
    local isFlexChild = not (child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute)
    if isFlexChild then
      table.insert(flexChildren, child)
    end
  end

  if #flexChildren == 0 then
    return
  end

  -- Calculate available space (accounting for padding)
  local availableMainSize = 0
  local availableCrossSize = 0
  if self.flexDirection == FlexDirection.HORIZONTAL then
    availableMainSize = self.width - self.padding.left - self.padding.right
    availableCrossSize = self.height - self.padding.top - self.padding.bottom
  else
    availableMainSize = self.height - self.padding.top - self.padding.bottom
    availableCrossSize = self.width - self.padding.left - self.padding.right
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
      local childMainSize = 0
      if self.flexDirection == FlexDirection.HORIZONTAL then
        childMainSize = child.width or 0
      else
        childMainSize = child.height or 0
      end

      -- Check if adding this child would exceed the available space
      local lineSpacing = #currentLine > 0 and self.gap or 0
      if #currentLine > 0 and currentLineSize + lineSpacing + childMainSize > availableMainSize then
        -- Start a new line
        if #currentLine > 0 then
          table.insert(lines, currentLine)
        end
        currentLine = { child }
        currentLineSize = childMainSize
      else
        -- Add to current line
        table.insert(currentLine, child)
        currentLineSize = currentLineSize + lineSpacing + childMainSize
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

  -- Calculate line positions and heights
  local lineHeights = {}
  local totalLinesHeight = 0

  for lineIndex, line in ipairs(lines) do
    local maxCrossSize = 0
    for _, child in ipairs(line) do
      local childCrossSize = 0
      if self.flexDirection == FlexDirection.HORIZONTAL then
        childCrossSize = child.height or 0
      else
        childCrossSize = child.width or 0
      end
      maxCrossSize = math.max(maxCrossSize, childCrossSize)
    end
    lineHeights[lineIndex] = maxCrossSize
    totalLinesHeight = totalLinesHeight + maxCrossSize
  end

  -- Account for gaps between lines
  local lineGaps = math.max(0, #lines - 1) * self.gap
  totalLinesHeight = totalLinesHeight + lineGaps

  -- For single line layouts, adjust line height based on align-items
  if #lines == 1 then
    if
      self.alignItems == AlignItems.CENTER
      or self.alignItems == AlignItems.STRETCH
      or self.alignItems == AlignItems.FLEX_END
    then
      lineHeights[1] = availableCrossSize
      totalLinesHeight = availableCrossSize
    end
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

    -- Calculate total size of children in this line
    local totalChildrenSize = 0
    for _, child in ipairs(line) do
      if self.flexDirection == FlexDirection.HORIZONTAL then
        totalChildrenSize = totalChildrenSize + (child.width or 0)
      else
        totalChildrenSize = totalChildrenSize + (child.height or 0)
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
        child.x = self.x + self.padding.left + currentMainPos

        if effectiveAlign == AlignItems.FLEX_START then
          child.y = self.y + self.padding.top + currentCrossPos
        elseif effectiveAlign == AlignItems.CENTER then
          child.y = self.y + self.padding.top + currentCrossPos + ((lineHeight - (child.height or 0)) / 2)
        elseif effectiveAlign == AlignItems.FLEX_END then
          child.y = self.y + self.padding.top + currentCrossPos + lineHeight - (child.height or 0)
        elseif effectiveAlign == AlignItems.STRETCH then
          child.height = lineHeight
          child.y = self.y + self.padding.top + currentCrossPos
        end

        -- Final position DEBUG for elements with debugId
        if child.debugId then
          print(string.format("DEBUG [%s]: Final Y position: %.2f", child.debugId, child.y))
        end

        currentMainPos = currentMainPos + (child.width or 0) + itemSpacing
      else
        -- Vertical layout: main axis is Y, cross axis is X
        child.y = self.y + self.padding.top + currentMainPos

        if effectiveAlign == AlignItems.FLEX_START then
          child.x = self.x + self.padding.left + currentCrossPos
        elseif effectiveAlign == AlignItems.CENTER then
          child.x = self.x + self.padding.left + currentCrossPos + ((lineHeight - (child.width or 0)) / 2)
        elseif effectiveAlign == AlignItems.FLEX_END then
          child.x = self.x + self.padding.left + currentCrossPos + lineHeight - (child.width or 0)
        elseif effectiveAlign == AlignItems.STRETCH then
          child.width = lineHeight
          child.x = self.x + self.padding.left + currentCrossPos
        end

        currentMainPos = currentMainPos + (child.height or 0) + itemSpacing
      end
    end

    -- After positioning all children in this line, recursively layout their children
    for _, child in ipairs(line) do
      -- Only layout children of flex containers to update positions relative to new parent position
      if child.positioning == Positioning.FLEX and #child.children > 0 then
        child:layoutChildren()
      end
    end

    -- Move to next line position
    currentCrossPos = currentCrossPos + lineHeight + lineSpacing
  end
end

--- Destroy element and its children
function Element:destroy()
  -- Remove from global elements list
  for i, win in ipairs(Gui.topElements) do
    if win == self then
      table.remove(Gui.topElements, i)
      break
    end
  end

  if self.parent then
    for i, child in ipairs(self.parent.children) do
      if child == self then
        table.remove(self.parent.children, i)
        break
      end
    end
    self.parent = nil
  end

  -- Destroy all children
  for _, child in ipairs(self.children) do
    child:destroy()
  end

  -- Clear children table
  self.children = {}

  -- Clear parent reference
  if self.parent then
    self.parent = nil
  end

  -- Clear animation reference
  self.animation = nil
end

--- Draw element and its children
function Element:draw()
  -- Handle opacity during animation
  local drawBackground = self.background
  if self.animation then
    local anim = self.animation:interpolate()
    if anim.opacity then
      drawBackground = Color.new(self.background.r, self.background.g, self.background.b, anim.opacity)
    end
  end

  -- Apply opacity to all drawing operations
  local backgroundWithOpacity =
    Color.new(drawBackground.r, drawBackground.g, drawBackground.b, drawBackground.a * self.opacity)
  love.graphics.setColor(backgroundWithOpacity:toRGBA())
  love.graphics.rectangle(
    "fill",
    self.x - self.padding.left,
    self.y - self.padding.top,
    self.width + self.padding.left + self.padding.right,
    self.height + self.padding.top + self.padding.bottom
  )
  -- Draw borders based on border property
  local borderColorWithOpacity =
    Color.new(self.borderColor.r, self.borderColor.g, self.borderColor.b, self.borderColor.a * self.opacity)
  love.graphics.setColor(borderColorWithOpacity:toRGBA())
  if self.border.top then
    love.graphics.line(
      self.x - self.padding.left,
      self.y - self.padding.top,
      self.x + self.width + (self.padding.right or 0),
      self.y - self.padding.top
    )
  end
  if self.border.bottom then
    love.graphics.line(
      self.x - self.padding.left,
      self.y + self.height + self.padding.bottom,
      self.x + self.width + self.padding.right,
      self.y + self.height + self.padding.bottom
    )
  end
  if self.border.left then
    love.graphics.line(
      self.x - self.padding.left,
      self.y - self.padding.top,
      self.x - self.padding.left,
      self.y + self.height + self.padding.bottom
    )
  end
  if self.border.right then
    love.graphics.line(
      self.x + self.width + self.padding.right,
      self.y - self.padding.top,
      self.x + self.width + self.padding.right,
      self.y + self.height + self.padding.bottom
    )
  end

  -- Draw element text if present
  if self.text then
    local textColorWithOpacity =
      Color.new(self.textColor.r, self.textColor.g, self.textColor.b, self.textColor.a * self.opacity)
    love.graphics.setColor(textColorWithOpacity:toRGBA())

    local origFont = love.graphics.getFont()
    local tempFont
    if self.textSize then
      tempFont = love.graphics.newFont(self.textSize)
      love.graphics.setFont(tempFont)
    end
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    local tx, ty
    if self.textAlign == TextAlign.START then
      tx = self.x
      ty = self.y
    elseif self.textAlign == TextAlign.CENTER then
      tx = self.x + (self.width - textWidth) / 2
      ty = self.y + (self.height - textHeight) / 2
    elseif self.textAlign == TextAlign.END then
      tx = self.x + self.width - textWidth - 10
      ty = self.y + self.height - textHeight - 10
    elseif self.textAlign == TextAlign.JUSTIFY then
      --- need to figure out spreading
      tx = self.x
      ty = self.y
    end
    love.graphics.print(self.text, tx, ty)
    if self.textSize then
      love.graphics.setFont(origFont)
    end
  end

  -- Draw visual feedback when element is pressed (if it has a callback)
  if self.callback and self._pressed then
    love.graphics.setColor(0.5, 0.5, 0.5, 0.3 * self.opacity) -- Semi-transparent gray for pressed state with opacity
    love.graphics.rectangle(
      "fill",
      self.x - self.padding.left,
      self.y - self.padding.top,
      self.width + self.padding.left + self.padding.right,
      self.height + self.padding.top + self.padding.bottom
    )
  end

  for _, child in ipairs(self.children) do
    child:draw()
  end
end

--- Update element (propagate to children)
---@param dt number
function Element:update(dt)
  for _, child in ipairs(self.children) do
    child:update(dt)
  end

  -- Update animation if exists
  if self.animation then
    local finished = self.animation:update(dt)
    if finished then
      self.animation = nil -- remove finished animation
    else
      -- Apply animation interpolation during update
      local anim = self.animation:interpolate()
      self.width = anim.width or self.width
      self.height = anim.height or self.height
      self.opacity = anim.opacity or self.opacity
      -- Update background color with interpolated opacity
      if anim.opacity then
        self.background.a = anim.opacity
      end
    end
  end

  -- Handle click detection for element
  if self.callback then
    local mx, my = love.mouse.getPosition()
    local bx = self.x
    local by = self.y
    if mx >= bx and mx <= bx + self.width and my >= by and my <= by + self.height then
      if love.mouse.isDown(1) then
        -- set pressed flag
        self._pressed = true
      elseif not love.mouse.isDown(1) and self._pressed then
        Logger:debug("calling callback")
        self.callback(self)
        self._pressed = false
      end
    else
      self._pressed = false
    end

    local touches = love.touch.getTouches()
    for _, id in ipairs(touches) do
      local tx, ty = love.touch.getPosition(id)
      if tx >= bx and tx <= bx + self.width and ty >= by and ty <= by + self.height then
        self._touchPressed[id] = true
      elseif self._touchPressed[id] then
        self.callback(self)
        self._touchPressed[id] = false
      end
    end
  end
end

--- Resize element and its children based on game window size change
---@param newGameWidth number
---@param newGameHeight number
function Element:resize(newGameWidth, newGameHeight)
  local prevW = self.prevGameSize.width
  local prevH = self.prevGameSize.height
  local ratioW = newGameWidth / prevW
  local ratioH = newGameHeight / prevH
  -- Update element size
  self.width = self.width * ratioW
  self.height = self.height * ratioH
  self.x = self.x * ratioW
  self.y = self.y * ratioH
  -- Update children positions and sizes
  for _, child in ipairs(self.children) do
    child:resize(newGameWidth, newGameHeight)
  end

  self:layoutChildren()
  self.prevGameSize.width = newGameWidth
  self.prevGameSize.height = newGameHeight
end

--- Calculate text width for button
---@return number
function Element:calculateTextWidth()
  if self.text == nil then
    return 0
  end

  if self.textSize then
    local tempFont = FONT_CACHE.get(self.textSize)
    local width = tempFont:getWidth(self.text)
    return width
  end

  local font = love.graphics.getFont()
  local width = font:getWidth(self.text)
  return width
end

---@return number
function Element:calculateTextHeight()
  if self.textSize then
    local tempFont = FONT_CACHE.get(self.textSize)
    local height = tempFont:getHeight()
    return height
  end

  local font = love.graphics.getFont()
  local height = font:getHeight()
  return height
end

function Element:calculateAutoWidth()
  local width = self:calculateTextWidth()
  if not self.children or #self.children == 0 then
    return width
  end

  local totalWidth = width
  local participatingChildren = 0
  for _, child in ipairs(self.children) do
    -- Skip explicitly absolute positioned children as they don't affect parent auto-sizing
    if not child._explicitlyAbsolute then
      local paddingAdjustment = (child.padding.left or 0) + (child.padding.right or 0)
      local childWidth = child.width or child:calculateAutoWidth()
      local childOffset = childWidth + paddingAdjustment

      totalWidth = totalWidth + childOffset
      participatingChildren = participatingChildren + 1
    end
  end

  return totalWidth + (self.gap * participatingChildren)
end

--- Calculate auto height based on children
function Element:calculateAutoHeight()
  local height = self:calculateTextHeight()
  if not self.children or #self.children == 0 then
    return height
  end

  local totalHeight = height
  local participatingChildren = 0
  for _, child in ipairs(self.children) do
    -- Skip explicitly absolute positioned children as they don't affect parent auto-sizing
    if not child._explicitlyAbsolute then
      local paddingAdjustment = (child.padding.top or 0) + (child.padding.bottom or 0)
      local childOffset = child.height + paddingAdjustment

      totalHeight = totalHeight + childOffset
      participatingChildren = participatingChildren + 1
    end
  end

  return totalHeight + (self.gap * participatingChildren)
end

---@param newText string
---@param autoresize boolean? --default: false
function Element:updateText(newText, autoresize)
  self.text = newText or self.text
  if autoresize then
    self.width = self:calculateTextWidth()
    self.height = self:calculateTextHeight()
  end
end

---@param newOpacity number
function Element:updateOpacity(newOpacity)
  self.opacity = newOpacity
  for _, child in ipairs(self.children) do
    child:updateOpacity(newOpacity)
  end
end

Gui.new = Element.new
Gui.Element = Element
Gui.Animation = Animation
return { GUI = Gui, Color = Color, enums = enums }
