-- Utility class for color handling
---@class Color
---@field r number -- Red component (0-1)
---@field g number -- Green component (0-1)
---@field b number -- Blue component (0-1)
---@field a number -- Alpha component (0-1)
local Color = {}
Color.__index = Color

--- Create a new color instance
---@param r number? -- Default: 0
---@param g number? -- Default: 0
---@param b number? -- Default: 0
---@param a number? -- Default: 1
---@return Color
function Color.new(r, g, b, a)
  local self = setmetatable({}, Color)
  self.r = r or 0
  self.g = g or 0
  self.b = b or 0
  self.a = a or 1
  return self
end

---@return number r, number g, number b, number a
function Color:toRGBA()
  return self.r, self.g, self.b, self.a
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

local enums = {
  ---@enum TextAlign
  TextAlign = { START = "start", CENTER = "center", END = "end", JUSTIFY = "justify" },
  ---@enum Positioning
  Positioning = { ABSOLUTE = "absolute", RELATIVE = "relative", FLEX = "flex", GRID = "grid" },
  ---@enum FlexDirection
  FlexDirection = { HORIZONTAL = "horizontal", VERTICAL = "vertical" },
  ---@enum JustifyContent
  JustifyContent = {
    FLEX_START = "flex-start",
    CENTER = "center",
    SPACE_AROUND = "space-around",
    FLEX_END = "flex-end",
    SPACE_EVENLY = "space-evenly",
    SPACE_BETWEEN = "space-between",
  },
  ---@enum JustifySelf
  JustifySelf = {
    AUTO = "auto",
    FLEX_START = "flex-start",
    CENTER = "center",
    FLEX_END = "flex-end",
    SPACE_AROUND = "space-around",
    SPACE_EVENLY = "space-evenly",
    SPACE_BETWEEN = "space-between",
  },
  ---@enum AlignItems
  AlignItems = {
    STRETCH = "stretch",
    FLEX_START = "flex-start",
    FLEX_END = "flex-end",
    CENTER = "center",
    BASELINE = "baseline",
  },
  ---@enum AlignSelf
  AlignSelf = {
    AUTO = "auto",
    STRETCH = "stretch",
    FLEX_START = "flex-start",
    FLEX_END = "flex-end",
    CENTER = "center",
    BASELINE = "baseline",
  },
  ---@enum AlignContent
  AlignContent = {
    STRETCH = "stretch",
    FLEX_START = "flex-start",
    FLEX_END = "flex-end",
    CENTER = "center",
    SPACE_BETWEEN = "space-between",
    SPACE_AROUND = "space-around",
  },
  ---@enum FlexWrap
  FlexWrap = { NOWRAP = "nowrap", WRAP = "wrap", WRAP_REVERSE = "wrap-reverse" },
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

-- ====================
-- Units System
-- ====================

--- Unit parsing and viewport calculations
local Units = {}

--- Parse a unit value (string or number) into value and unit type
---@param value string|number
---@return number, string -- Returns numeric value and unit type ("px", "%", "vw", "vh")
function Units.parse(value)
  if type(value) == "number" then
    return value, "px"
  end

  if type(value) ~= "string" then
    -- Fallback to 0px for invalid types
    return 0, "px"
  end

  -- Match number followed by optional unit
  local numStr, unit = value:match("^([%-]?[%d%.]+)(.*)$")
  if not numStr then
    -- Fallback to 0px for invalid format
    return 0, "px"
  end

  local num = tonumber(numStr)
  if not num then
    -- Fallback to 0px for invalid numeric value
    return 0, "px"
  end

  -- Default to pixels if no unit specified
  if unit == "" then
    unit = "px"
  end

  local validUnits = { px = true, ["%"] = true, vw = true, vh = true, ew = true, eh = true }
  if not validUnits[unit] then
    return num, "px"
  end

  return num, unit
end

--- Convert relative units to pixels based on viewport and parent dimensions
---@param value number
---@param unit string
---@param viewportWidth number
---@param viewportHeight number
---@param parentSize number? -- Required for percentage units
---@return number -- Pixel value
function Units.resolve(value, unit, viewportWidth, viewportHeight, parentSize)
  if unit == "px" then
    return value
  elseif unit == "%" then
    if not parentSize then
      error("Percentage units require parent dimension")
    end
    return (value / 100) * parentSize
  elseif unit == "vw" then
    return (value / 100) * viewportWidth
  elseif unit == "vh" then
    return (value / 100) * viewportHeight
  else
    error("Unknown unit type: " .. unit)
  end
end

---@return number, number -- width, height
function Units.getViewport()
  -- Try both functions to be compatible with different love versions and test environments
  if love.graphics and love.graphics.getDimensions then
    return love.graphics.getDimensions()
  else
    local w, h = love.window.getMode()
    return w, h
  end
end

--- Apply base scaling to a value
---@param value number
---@param axis "x"|"y" -- Which axis to scale on
---@param scaleFactors {x:number, y:number}
---@return number
function Units.applyBaseScale(value, axis, scaleFactors)
  if axis == "x" then
    return value * scaleFactors.x
  else
    return value * scaleFactors.y
  end
end

--- Resolve units for spacing properties (padding, margin)
---@param spacingProps table?
---@param parentWidth number
---@param parentHeight number
---@return table -- Resolved spacing with top, right, bottom, left in pixels
function Units.resolveSpacing(spacingProps, parentWidth, parentHeight)
  if not spacingProps then
    return { top = 0, right = 0, bottom = 0, left = 0 }
  end

  local viewportWidth, viewportHeight = Units.getViewport()
  local result = {}

  -- Handle shorthand properties first
  local vertical = spacingProps.vertical
  local horizontal = spacingProps.horizontal

  if vertical then
    if type(vertical) == "string" then
      local value, unit = Units.parse(vertical)
      vertical = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
    end
  end

  if horizontal then
    if type(horizontal) == "string" then
      local value, unit = Units.parse(horizontal)
      horizontal = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
    end
  end

  -- Handle individual sides
  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    local value = spacingProps[side]
    if value then
      if type(value) == "string" then
        local numValue, unit = Units.parse(value)
        local parentSize = (side == "top" or side == "bottom") and parentHeight or parentWidth
        result[side] = Units.resolve(numValue, unit, viewportWidth, viewportHeight, parentSize)
      else
        result[side] = value
      end
    else
      -- Use fallbacks
      if side == "top" or side == "bottom" then
        result[side] = vertical or 0
      else
        result[side] = horizontal or 0
      end
    end
  end

  return result
end

-- ====================
-- Grid System
-- ====================

--- Simple grid layout calculations
local Grid = {}

--- Layout grid items within a grid container using simple row/column counts
---@param element Element -- Grid container element
function Grid.layoutGridItems(element)
  local rows = element.gridRows or 1
  local columns = element.gridColumns or 1
  
  -- Calculate available space
  local availableWidth = element.width - element.padding.left - element.padding.right
  local availableHeight = element.height - element.padding.top - element.padding.bottom
  
  -- Get gaps
  local columnGap = element.columnGap or 0
  local rowGap = element.rowGap or 0
  
  -- Calculate cell sizes (equal distribution)
  local totalColumnGaps = (columns - 1) * columnGap
  local totalRowGaps = (rows - 1) * rowGap
  local cellWidth = (availableWidth - totalColumnGaps) / columns
  local cellHeight = (availableHeight - totalRowGaps) / rows
  
  -- Get children that participate in grid layout
  local gridChildren = {}
  for _, child in ipairs(element.children) do
    if not (child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute) then
      table.insert(gridChildren, child)
    end
  end
  
  -- Place children in grid cells
  for i, child in ipairs(gridChildren) do
    -- Calculate row and column (0-indexed for calculation)
    local index = i - 1
    local col = index % columns
    local row = math.floor(index / columns)
    
    -- Skip if we've exceeded the grid
    if row >= rows then
      break
    end
    
    -- Calculate cell position
    local cellX = element.x + element.padding.left + (col * (cellWidth + columnGap))
    local cellY = element.y + element.padding.top + (row * (cellHeight + rowGap))
    
    -- Apply alignment within grid cell (default to stretch)
    local effectiveAlignItems = element.alignItems or AlignItems.STRETCH
    
    -- Stretch child to fill cell by default
    if effectiveAlignItems == AlignItems.STRETCH or effectiveAlignItems == "stretch" then
      child.x = cellX + child.padding.left
      child.y = cellY + child.padding.top
      child.width = cellWidth - child.padding.left - child.padding.right
      child.height = cellHeight - child.padding.top - child.padding.bottom
      -- Disable auto-sizing when stretched by grid
      child.autosizing.width = false
      child.autosizing.height = false
    elseif effectiveAlignItems == AlignItems.CENTER or effectiveAlignItems == "center" then
      child.x = cellX + (cellWidth - child.width) / 2
      child.y = cellY + (cellHeight - child.height) / 2
    elseif effectiveAlignItems == AlignItems.FLEX_START or effectiveAlignItems == "flex-start" or effectiveAlignItems == "start" then
      child.x = cellX + child.padding.left
      child.y = cellY + child.padding.top
    elseif effectiveAlignItems == AlignItems.FLEX_END or effectiveAlignItems == "flex-end" or effectiveAlignItems == "end" then
      child.x = cellX + cellWidth - child.width - child.padding.right
      child.y = cellY + cellHeight - child.height - child.padding.bottom
    else
      -- Default to stretch
      child.x = cellX + child.padding.left
      child.y = cellY + child.padding.top
      child.width = cellWidth - child.padding.left - child.padding.right
      child.height = cellHeight - child.padding.top - child.padding.bottom
      -- Disable auto-sizing when stretched by grid
      child.autosizing.width = false
      child.autosizing.height = false
    end
    
    -- Layout child's children if it has any
    if #child.children > 0 then
      child:layoutChildren()
    end
  end
end

--- Top level GUI manager
---@class Gui
---@field topElements table<integer, Element>
---@field baseScale {width:number, height:number}?
---@field scaleFactors {x:number, y:number}
---@field init fun(config: {baseScale: {width:number, height:number}}): nil
---@field resize fun(): nil
---@field draw fun(): nil
---@field update fun(dt:number): nil
---@field destroy fun(): nil
local Gui = {
  topElements = {},
  baseScale = nil,
  scaleFactors = { x = 1.0, y = 1.0 },
}

--- Initialize FlexLove with configuration
---@param config {baseScale?: {width?:number, height?:number}} --Default: {width: 1920, height: 1080}
function Gui.init(config)
  if config.baseScale then
    Gui.baseScale = {
      width = config.baseScale.width or 1920,
      height = config.baseScale.height or 1080,
    }

    -- Calculate initial scale factors
    local currentWidth, currentHeight = Units.getViewport()
    Gui.scaleFactors.x = currentWidth / Gui.baseScale.width
    Gui.scaleFactors.y = currentHeight / Gui.baseScale.height
  end
end

--- Get current scale factors
---@return number, number -- scaleX, scaleY
function Gui.getScaleFactors()
  return Gui.scaleFactors.x, Gui.scaleFactors.y
end

function Gui.resize()
  local newWidth, newHeight = love.window.getMode()

  -- Update scale factors if base scale is set
  if Gui.baseScale then
    Gui.scaleFactors.x = newWidth / Gui.baseScale.width
    Gui.scaleFactors.y = newHeight / Gui.baseScale.height
  end

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
---@field id string
---@field autosizing {width:boolean, height:boolean} -- Whether the element should automatically size to fit its children
---@field x number|string -- X coordinate of the element
---@field y number|string -- Y coordinate of the element
---@field z number -- Z-index for layering (default: 0)
---@field width number|string -- Width of the element
---@field height number|string -- Height of the element
---@field top number? -- Offset from top edge (CSS-style positioning)
---@field right number? -- Offset from right edge (CSS-style positioning)
---@field bottom number? -- Offset from bottom edge (CSS-style positioning)
---@field left number? -- Offset from left edge (CSS-style positioning)
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
---@field gap number|string -- Space between children elements (default: 10)
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
---@field autoScaleText boolean -- Whether text should auto-scale with window size (default: true)
---@field transform TransformProps -- Transform properties for animations and styling
---@field transition TransitionProps -- Transition settings for animations
---@field callback function? -- Callback function for click events
---@field units table -- Original unit specifications for responsive behavior
---@field gridRows number? -- Number of rows in the grid
---@field gridColumns number? -- Number of columns in the grid
---@field columnGap number|string? -- Gap between grid columns
---@field rowGap number|string? -- Gap between grid rows
local Element = {}
Element.__index = Element

---@class ElementProps
---@field id string?
---@field parent Element? -- Parent element for hierarchical structure
---@field x number|string? -- X coordinate of the element (default: 0)
---@field y number|string? -- Y coordinate of the element (default: 0)
---@field z number? -- Z-index for layering (default: 0)
---@field width number|string? -- Width of the element (default: calculated automatically)
---@field height number|string? -- Height of the element (default: calculated automatically)
---@field top number|string? -- Offset from top edge (CSS-style positioning)
---@field right number|string? -- Offset from right edge (CSS-style positioning)
---@field bottom number|string? -- Offset from bottom edge (CSS-style positioning)
---@field left number|string? -- Offset from left edge (CSS-style positioning)
---@field border Border? -- Border configuration for the element
---@field borderColor Color? -- Color of the border (default: black)
---@field opacity number?
---@field background Color? -- Background color (default: transparent)
---@field gap number|string? -- Space between children elements (default: 10)
---@field padding {top:number|string?, right:number|string?, bottom:number|string?, left:number|string?, horizontal: number|string?, vertical:number|string?}? -- Padding around children (default: {top=0, right=0, bottom=0, left=0})
---@field margin {top:number|string?, right:number|string?, bottom:number|string?, left:number|string?, horizontal: number|string?, vertical:number|string?}? -- Margin around children (default: {top=0, right=0, bottom=0, left=0})
---@field text string? -- Text content to display (default: nil)
---@field titleColor Color? -- Color of the text content (default: black)
---@field textAlign TextAlign? -- Alignment of the text content (default: START)
---@field textColor Color? -- Color of the text content (default: black)
---@field textSize number|string? -- Font size for text content (default: auto-scaled)
---@field autoScaleText boolean? -- Whether text should auto-scale with window size (default: true)
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
---@field gridRows number? -- Number of rows in the grid (default: 1)
---@field gridColumns number? -- Number of columns in the grid (default: 1)
---@field columnGap number|string? -- Gap between grid columns
---@field rowGap number|string? -- Gap between grid rows
local ElementProps = {}

---@param props ElementProps
---@return Element
function Element.new(props)
  local self = setmetatable({}, Element)
  self.children = {}
  self.callback = props.callback
  self.id = props.id or ""

  -- Set parent first so it's available for size calculations
  self.parent = props.parent

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
  self.textSize = props.textSize or 12
  self.textAlign = props.textAlign or TextAlign.START

  --- self positioning ---
  local viewportWidth, viewportHeight = Units.getViewport()

  ---- Sizing ----
  local gw, gh = love.window.getMode()
  self.prevGameSize = { width = gw, height = gh }
  self.autosizing = { width = false, height = false }

  -- Store unit specifications for responsive behavior
  self.units = {
    width = { value = nil, unit = "px" },
    height = { value = nil, unit = "px" },
    x = { value = nil, unit = "px" },
    y = { value = nil, unit = "px" },
    textSize = { value = nil, unit = "px" },
    gap = { value = nil, unit = "px" },
    padding = {
      top = { value = nil, unit = "px" },
      right = { value = nil, unit = "px" },
      bottom = { value = nil, unit = "px" },
      left = { value = nil, unit = "px" },
    },
    margin = {
      top = { value = nil, unit = "px" },
      right = { value = nil, unit = "px" },
      bottom = { value = nil, unit = "px" },
      left = { value = nil, unit = "px" },
    },
  }

  -- Get scale factors from Gui (will be used later)
  local scaleX, scaleY = Gui.getScaleFactors()

  -- Handle width (both w and width properties, prefer w if both exist)
  local widthProp = props.width
  if widthProp then
    if type(widthProp) == "string" then
      local value, unit = Units.parse(widthProp)
      self.units.width = { value = value, unit = unit }
      local parentWidth = self.parent and self.parent.width or viewportWidth
      self.width = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
    else
      -- Apply base scaling to pixel values
      self.width = Gui.baseScale and (widthProp * scaleX) or widthProp
      self.units.width = { value = widthProp, unit = "px" }
    end
  else
    self.autosizing.width = true
    self.width = self:calculateAutoWidth()
    self.units.width = { value = nil, unit = "auto" } -- Mark as auto-sized
  end

  -- Handle height (both h and height properties, prefer h if both exist)
  local heightProp = props.height
  if heightProp then
    if type(heightProp) == "string" then
      local value, unit = Units.parse(heightProp)
      self.units.height = { value = value, unit = unit }
      local parentHeight = self.parent and self.parent.height or viewportHeight
      self.height = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
    else
      -- Apply base scaling to pixel values
      self.height = Gui.baseScale and (heightProp * scaleY) or heightProp
      self.units.height = { value = heightProp, unit = "px" }
    end
  else
    self.autosizing.height = true
    self.height = self:calculateAutoHeight()
    self.units.height = { value = nil, unit = "auto" } -- Mark as auto-sized
  end

  --- child positioning ---
  if props.gap then
    if type(props.gap) == "string" then
      local value, unit = Units.parse(props.gap)
      self.units.gap = { value = value, unit = unit }
      -- Gap percentages should be relative to the element's own size, not parent
      -- For horizontal flex, gap is based on width; for vertical flex, based on height
      local flexDir = props.flexDirection or FlexDirection.HORIZONTAL
      local containerSize = (flexDir == FlexDirection.HORIZONTAL) and self.width or self.height
      self.gap = Units.resolve(value, unit, viewportWidth, viewportHeight, containerSize)
    else
      self.gap = props.gap
      self.units.gap = { value = props.gap, unit = "px" }
    end
  else
    self.gap = 10
    self.units.gap = { value = 10, unit = "px" }
  end

  -- Resolve padding and margin based on element's own size (after width/height are set)
  self.padding = Units.resolveSpacing(props.padding, self.width, self.height)
  self.margin = Units.resolveSpacing(props.margin, self.width, self.height)

  -- Store original textSize units and constraints
  self.minTextSize = props.minTextSize
  self.maxTextSize = props.maxTextSize

  -- Auto-scale text by default (can be disabled with autoScaleText = false)
  if props.autoScaleText == nil then
    self.autoScaleText = true
  else
    self.autoScaleText = props.autoScaleText
  end

  if props.textSize then
    if type(props.textSize) == "string" then
      local value, unit = Units.parse(props.textSize)
      self.units.textSize = { value = value, unit = unit }

      -- Resolve textSize based on unit type
      if unit == "%" or unit == "vh" then
        -- Percentage and vh are relative to viewport height
        self.textSize = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
      elseif unit == "vw" then
        -- vw is relative to viewport width
        self.textSize = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
      elseif unit == "ew" then
        -- Element width relative (will be resolved after width is set)
        self.textSize = (value / 100) * self.width
      elseif unit == "eh" then
        -- Element height relative (will be resolved after height is set)
        self.textSize = (value / 100) * self.height
      else
        self.textSize = Units.resolve(value, unit, viewportWidth, viewportHeight, nil)
      end
    else
      -- Validate pixel textSize value
      if props.textSize <= 0 then
        error("textSize must be greater than 0, got: " .. tostring(props.textSize))
      end

      -- Pixel textSize value
      if self.autoScaleText then
        -- Convert pixel value to viewport units for auto-scaling
        -- Calculate what percentage of viewport height this represents
        local vhValue = (props.textSize / viewportHeight) * 100
        self.units.textSize = { value = vhValue, unit = "vh" }
        self.textSize = props.textSize -- Initial size is the specified pixel value
      else
        -- Apply base scaling to pixel text sizes (no auto-scaling)
        self.textSize = Gui.baseScale and (props.textSize * scaleY) or props.textSize
        self.units.textSize = { value = props.textSize, unit = "px" }
      end
    end
  else
    -- No textSize specified - use auto-scaling default
    if self.autoScaleText then
      -- Default to 1.5vh (1.5% of viewport height) for auto-scaling
      self.textSize = (1.5 / 100) * viewportHeight
      self.units.textSize = { value = 1.5, unit = "vh" }
    else
      -- Fixed 12px when auto-scaling is disabled (with base scaling if set)
      self.textSize = Gui.baseScale and (12 * scaleY) or 12
      self.units.textSize = { value = nil, unit = "px" }
    end
  end

  -- Apply min/max constraints (also scaled)
  local minSize = self.minTextSize and (Gui.baseScale and (self.minTextSize * scaleY) or self.minTextSize)
  local maxSize = self.maxTextSize and (Gui.baseScale and (self.maxTextSize * scaleY) or self.maxTextSize)

  if minSize and self.textSize < minSize then
    self.textSize = minSize
  end
  if maxSize and self.textSize > maxSize then
    self.textSize = maxSize
  end

  -- Protect against too-small text sizes (minimum 1px)
  if self.textSize < 1 then
    self.textSize = 1 -- Minimum 1px
  end

  -- Store original spacing values for proper resize handling
  -- Initialize all padding sides
  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    if props.padding and props.padding[side] then
      if type(props.padding[side]) == "string" then
        local value, unit = Units.parse(props.padding[side])
        self.units.padding[side] = { value = value, unit = unit }
      else
        self.units.padding[side] = { value = props.padding[side], unit = "px" }
      end
    else
      -- Use resolved padding values from Units.resolveSpacing
      self.units.padding[side] = { value = self.padding[side], unit = "px" }
    end
  end

  -- Initialize all margin sides
  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    if props.margin and props.margin[side] then
      if type(props.margin[side]) == "string" then
        local value, unit = Units.parse(props.margin[side])
        self.units.margin[side] = { value = value, unit = unit }
      else
        self.units.margin[side] = { value = props.margin[side], unit = "px" }
      end
    else
      -- Use resolved margin values from Units.resolveSpacing
      self.units.margin[side] = { value = self.margin[side], unit = "px" }
    end
  end

  -- Grid properties are set later in the constructor

  ------ add hereditary ------
  if props.parent == nil then
    table.insert(Gui.topElements, self)

    -- Handle x position with units
    if props.x then
      if type(props.x) == "string" then
        local value, unit = Units.parse(props.x)
        self.units.x = { value = value, unit = unit }
        self.x = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
      else
        -- Apply base scaling to pixel positions
        self.x = Gui.baseScale and (props.x * scaleX) or props.x
        self.units.x = { value = props.x, unit = "px" }
      end
    else
      self.x = 0
      self.units.x = { value = 0, unit = "px" }
    end

    -- Handle y position with units
    if props.y then
      if type(props.y) == "string" then
        local value, unit = Units.parse(props.y)
        self.units.y = { value = value, unit = unit }
        self.y = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
      else
        -- Apply base scaling to pixel positions
        self.y = Gui.baseScale and (props.y * scaleY) or props.y
        self.units.y = { value = props.y, unit = "px" }
      end
    else
      self.y = 0
      self.units.y = { value = 0, unit = "px" }
    end

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
    -- Set positioning first and track if explicitly set
    self._originalPositioning = props.positioning -- Track original intent
    if props.positioning == Positioning.ABSOLUTE then
      self.positioning = Positioning.ABSOLUTE
      self._explicitlyAbsolute = true -- Explicitly set to absolute by user
    elseif props.positioning == Positioning.FLEX then
      self.positioning = Positioning.FLEX
      self._explicitlyAbsolute = false
    elseif props.positioning == Positioning.GRID then
      self.positioning = Positioning.GRID
      self._explicitlyAbsolute = false
    else
      -- Default: children in flex/grid containers participate in parent's layout
      -- children in absolute containers default to absolute
      if self.parent.positioning == Positioning.FLEX or self.parent.positioning == Positioning.GRID then
        self.positioning = Positioning.ABSOLUTE -- They are positioned BY flex/grid, not AS flex/grid
        self._explicitlyAbsolute = false -- Participate in parent's layout
      else
        self.positioning = Positioning.ABSOLUTE
        self._explicitlyAbsolute = false -- Default for absolute containers
      end
    end

    -- Set initial position
    if self.positioning == Positioning.ABSOLUTE then
      -- Handle x position with units
      if props.x then
        if type(props.x) == "string" then
          local value, unit = Units.parse(props.x)
          self.units.x = { value = value, unit = unit }
          local parentWidth = self.parent.width
          self.x = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
        else
          -- Apply base scaling to pixel positions
          self.x = Gui.baseScale and (props.x * scaleX) or props.x
          self.units.x = { value = props.x, unit = "px" }
        end
      else
        self.x = 0
        self.units.x = { value = 0, unit = "px" }
      end

      -- Handle y position with units
      if props.y then
        if type(props.y) == "string" then
          local value, unit = Units.parse(props.y)
          self.units.y = { value = value, unit = unit }
          local parentHeight = self.parent.height
          self.y = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
        else
          -- Apply base scaling to pixel positions
          self.y = Gui.baseScale and (props.y * scaleY) or props.y
          self.units.y = { value = props.y, unit = "px" }
        end
      else
        self.y = 0
        self.units.y = { value = 0, unit = "px" }
      end

      self.z = props.z or 0
    else
      -- Children in flex containers start at parent position but will be repositioned by layoutChildren
      local baseX = self.parent.x
      local baseY = self.parent.y

      if props.x then
        if type(props.x) == "string" then
          local value, unit = Units.parse(props.x)
          self.units.x = { value = value, unit = unit }
          local parentWidth = self.parent.width
          local offsetX = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
          self.x = baseX + offsetX
        else
          -- Apply base scaling to pixel offsets
          local scaledOffset = Gui.baseScale and (props.x * scaleX) or props.x
          self.x = baseX + scaledOffset
          self.units.x = { value = props.x, unit = "px" }
        end
      else
        self.x = baseX
        self.units.x = { value = 0, unit = "px" }
      end

      if props.y then
        if type(props.y) == "string" then
          local value, unit = Units.parse(props.y)
          self.units.y = { value = value, unit = unit }
          local parentHeight = self.parent.height
          local offsetY = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
          self.y = baseY + offsetY
        else
          -- Apply base scaling to pixel offsets
          local scaledOffset = Gui.baseScale and (props.y * scaleY) or props.y
          self.y = baseY + scaledOffset
          self.units.y = { value = props.y, unit = "px" }
        end
      else
        self.y = baseY
        self.units.y = { value = 0, unit = "px" }
      end

      self.z = props.z or self.parent.z or 0
    end

    self.textColor = props.textColor or self.parent.textColor

    props.parent:addChild(self)
  end

  -- Handle positioning properties for ALL elements (with or without parent)
  -- Handle top positioning with units
  if props.top then
    if type(props.top) == "string" then
      local value, unit = Units.parse(props.top)
      self.units.top = { value = value, unit = unit }
      self.top = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
    else
      self.top = props.top
      self.units.top = { value = props.top, unit = "px" }
    end
  else
    self.top = nil
    self.units.top = nil
  end

  -- Handle right positioning with units
  if props.right then
    if type(props.right) == "string" then
      local value, unit = Units.parse(props.right)
      self.units.right = { value = value, unit = unit }
      self.right = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
    else
      self.right = props.right
      self.units.right = { value = props.right, unit = "px" }
    end
  else
    self.right = nil
    self.units.right = nil
  end

  -- Handle bottom positioning with units
  if props.bottom then
    if type(props.bottom) == "string" then
      local value, unit = Units.parse(props.bottom)
      self.units.bottom = { value = value, unit = unit }
      self.bottom = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
    else
      self.bottom = props.bottom
      self.units.bottom = { value = props.bottom, unit = "px" }
    end
  else
    self.bottom = nil
    self.units.bottom = nil
  end

  -- Handle left positioning with units
  if props.left then
    if type(props.left) == "string" then
      local value, unit = Units.parse(props.left)
      self.units.left = { value = value, unit = unit }
      self.left = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
    else
      self.left = props.left
      self.units.left = { value = props.left, unit = "px" }
    end
  else
    self.left = nil
    self.units.left = nil
  end

  if self.positioning == Positioning.FLEX then
    self.flexDirection = props.flexDirection or FlexDirection.HORIZONTAL
    self.flexWrap = props.flexWrap or FlexWrap.NOWRAP
    self.justifyContent = props.justifyContent or JustifyContent.FLEX_START
    self.alignItems = props.alignItems or AlignItems.STRETCH
    self.alignContent = props.alignContent or AlignContent.STRETCH
    self.justifySelf = props.justifySelf or JustifySelf.AUTO
  end

  -- Grid container properties
  if self.positioning == Positioning.GRID then
    self.gridRows = props.gridRows or 1
    self.gridColumns = props.gridColumns or 1
    self.alignItems = props.alignItems or AlignItems.STRETCH

    -- Handle columnGap and rowGap
    if props.columnGap then
      if type(props.columnGap) == "string" then
        local value, unit = Units.parse(props.columnGap)
        self.columnGap = Units.resolve(value, unit, viewportWidth, viewportHeight, self.width)
      else
        self.columnGap = props.columnGap
      end
    else
      self.columnGap = 0
    end

    if props.rowGap then
      if type(props.rowGap) == "string" then
        local value, unit = Units.parse(props.rowGap)
        self.rowGap = Units.resolve(value, unit, viewportWidth, viewportHeight, self.height)
      else
        self.rowGap = props.rowGap
      end
    else
      self.rowGap = 0
    end
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
    if self.positioning == Positioning.FLEX or self.positioning == Positioning.GRID then
      child.positioning = Positioning.ABSOLUTE -- They are positioned BY flex/grid, not AS flex/grid
      child._explicitlyAbsolute = false -- Participate in parent's layout
    else
      child.positioning = Positioning.ABSOLUTE
      child._explicitlyAbsolute = false -- Default for absolute containers
    end
  end
  -- If child._originalPositioning is set, it means explicit positioning was provided
  -- and _explicitlyAbsolute was already set correctly during construction

  table.insert(self.children, child)

  -- Only recalculate auto-sizing if the child participates in layout
  -- (CSS: absolutely positioned children don't affect parent auto-sizing)
  if not child._explicitlyAbsolute then
    if self.autosizing.height then
      self.height = self:calculateAutoHeight()
    end
    if self.autosizing.width then
      self.width = self:calculateAutoWidth()
    end
  end

  self:layoutChildren()
end

--- Apply positioning offsets (top, right, bottom, left) to an element
-- @param element The element to apply offsets to
function Element:applyPositioningOffsets(element)
  if not element then
    return
  end

  -- For CSS-style positioning, we need the parent's bounds
  local parent = element.parent
  if not parent then
    return
  end

  -- Apply top offset (distance from parent's top edge)
  if element.top then
    element.y = parent.y + parent.padding.top + element.top
  end

  -- Apply bottom offset (distance from parent's bottom edge)
  if element.bottom then
    element.y = parent.y + parent.height - parent.padding.bottom - element.height - element.bottom
  end

  -- Apply left offset (distance from parent's left edge)
  if element.left then
    element.x = parent.x + parent.padding.left + element.left
  end

  -- Apply right offset (distance from parent's right edge)
  if element.right then
    element.x = parent.x + parent.width - parent.padding.right - element.width - element.right
  end
end

function Element:layoutChildren()
  if self.positioning == Positioning.ABSOLUTE then
    -- Absolute positioned containers don't layout their children according to flex rules,
    -- but they should still apply CSS positioning offsets to their children
    for _, child in ipairs(self.children) do
      if child.top or child.right or child.bottom or child.left then
        self:applyPositioningOffsets(child)
      end
    end
    return
  end

  -- Handle grid layout
  if self.positioning == Positioning.GRID then
    Grid.layoutGridItems(self)
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
        childMainSize = (child.width or 0) + child.padding.left + child.padding.right
      else
        childMainSize = (child.height or 0) + child.padding.top + child.padding.bottom
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

  -- Calculate line positions and heights (including child padding)
  local lineHeights = {}
  local totalLinesHeight = 0

  for lineIndex, line in ipairs(lines) do
    local maxCrossSize = 0
    for _, child in ipairs(line) do
      local childCrossSize = 0
      if self.flexDirection == FlexDirection.HORIZONTAL then
        childCrossSize = (child.height or 0) + child.padding.top + child.padding.bottom
      else
        childCrossSize = (child.width or 0) + child.padding.left + child.padding.right
      end
      maxCrossSize = math.max(maxCrossSize, childCrossSize)
    end
    lineHeights[lineIndex] = maxCrossSize
    totalLinesHeight = totalLinesHeight + maxCrossSize
  end

  -- Account for gaps between lines
  local lineGaps = math.max(0, #lines - 1) * self.gap
  totalLinesHeight = totalLinesHeight + lineGaps

  -- For single line layouts, CENTER, FLEX_END and STRETCH should use full cross size
  if #lines == 1 then
    if
      self.alignItems == AlignItems.STRETCH
      or self.alignItems == AlignItems.CENTER
      or self.alignItems == AlignItems.FLEX_END
    then
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

    -- Calculate total size of children in this line (including padding)
    local totalChildrenSize = 0
    for _, child in ipairs(line) do
      if self.flexDirection == FlexDirection.HORIZONTAL then
        local childTotalWidth = (child.width or 0) + child.padding.left + child.padding.right
        totalChildrenSize = totalChildrenSize + childTotalWidth
      else
        local childTotalHeight = (child.height or 0) + child.padding.top + child.padding.bottom
        totalChildrenSize = totalChildrenSize + childTotalHeight
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
        -- Position child accounting for its left padding
        child.x = self.x + self.padding.left + currentMainPos + child.padding.left

        if effectiveAlign == AlignItems.FLEX_START then
          child.y = self.y + self.padding.top + currentCrossPos + child.padding.top
        elseif effectiveAlign == AlignItems.CENTER then
          local childTotalHeight = (child.height or 0) + child.padding.top + child.padding.bottom
          child.y = self.y
            + self.padding.top
            + currentCrossPos
            + ((lineHeight - childTotalHeight) / 2)
            + child.padding.top
        elseif effectiveAlign == AlignItems.FLEX_END then
          local childTotalHeight = (child.height or 0) + child.padding.top + child.padding.bottom
          child.y = self.y + self.padding.top + currentCrossPos + lineHeight - childTotalHeight + child.padding.top
        elseif effectiveAlign == AlignItems.STRETCH then
          -- STRETCH always stretches children in cross-axis direction
          child.height = lineHeight - child.padding.top - child.padding.bottom
          child.y = self.y + self.padding.top + currentCrossPos + child.padding.top
        end

        -- Apply positioning offsets (top, right, bottom, left)
        self:applyPositioningOffsets(child)

        -- Final position DEBUG for elements with debugId
        if child.debugId then
          print(string.format("DEBUG [%s]: Final Y position: %.2f", child.debugId, child.y))
        end

        -- If child has children, re-layout them after position change
        if #child.children > 0 then
          child:layoutChildren()
        end

        -- Advance position by child's total width (width + padding)
        local childTotalWidth = (child.width or 0) + child.padding.left + child.padding.right
        currentMainPos = currentMainPos + childTotalWidth + itemSpacing
      else
        -- Vertical layout: main axis is Y, cross axis is X
        -- Position child accounting for its top padding
        child.y = self.y + self.padding.top + currentMainPos + child.padding.top

        if effectiveAlign == AlignItems.FLEX_START then
          child.x = self.x + self.padding.left + currentCrossPos + child.padding.left
        elseif effectiveAlign == AlignItems.CENTER then
          local childTotalWidth = (child.width or 0) + child.padding.left + child.padding.right
          child.x = self.x
            + self.padding.left
            + currentCrossPos
            + ((lineHeight - childTotalWidth) / 2)
            + child.padding.left
        elseif effectiveAlign == AlignItems.FLEX_END then
          local childTotalWidth = (child.width or 0) + child.padding.left + child.padding.right
          child.x = self.x + self.padding.left + currentCrossPos + lineHeight - childTotalWidth + child.padding.left
        elseif effectiveAlign == AlignItems.STRETCH then
          -- STRETCH always stretches children in cross-axis direction
          child.width = lineHeight - child.padding.left - child.padding.right
          child.x = self.x + self.padding.left + currentCrossPos + child.padding.left
        end

        -- Apply positioning offsets (top, right, bottom, left)
        self:applyPositioningOffsets(child)

        -- If child has children, re-layout them after position change
        if #child.children > 0 then
          child:layoutChildren()
        end

        -- Advance position by child's total height (height + padding)
        local childTotalHeight = (child.height or 0) + child.padding.top + child.padding.bottom
        currentMainPos = currentMainPos + childTotalHeight + itemSpacing
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
    if self.textSize then
      -- Use cached font instead of creating new one every frame
      local font = FONT_CACHE.get(self.textSize)
      love.graphics.setFont(font)
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
    -- Include padding in clickable area to match visual bounds
    local bx = self.x - self.padding.left
    local by = self.y - self.padding.top
    local bw = self.width + self.padding.left + self.padding.right
    local bh = self.height + self.padding.top + self.padding.bottom
    if mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
      if love.mouse.isDown(1) then
        -- set pressed flag
        self._pressed = true
      elseif not love.mouse.isDown(1) and self._pressed then
        self.callback(self)
        self._pressed = false
      end
    else
      self._pressed = false
    end

    local touches = love.touch.getTouches()
    for _, id in ipairs(touches) do
      local tx, ty = love.touch.getPosition(id)
      if tx >= bx and tx <= bx + bw and ty >= by and ty <= by + bh then
        self._touchPressed[id] = true
      elseif self._touchPressed[id] then
        self.callback(self)
        self._touchPressed[id] = false
      end
    end
  end
end

--- Recalculate units based on new viewport dimensions (for vw, vh, % units)
---@param newViewportWidth number
---@param newViewportHeight number
function Element:recalculateUnits(newViewportWidth, newViewportHeight)
  -- Get updated scale factors
  local scaleX, scaleY = Gui.getScaleFactors()

  -- Recalculate width if using viewport or percentage units (skip auto-sized)
  if self.units.width.unit ~= "px" and self.units.width.unit ~= "auto" then
    local parentWidth = self.parent and self.parent.width or newViewportWidth
    self.width =
      Units.resolve(self.units.width.value, self.units.width.unit, newViewportWidth, newViewportHeight, parentWidth)
  elseif self.units.width.unit == "px" and self.units.width.value and Gui.baseScale then
    -- Reapply base scaling to pixel widths
    self.width = self.units.width.value * scaleX
  end

  -- Recalculate height if using viewport or percentage units (skip auto-sized)
  if self.units.height.unit ~= "px" and self.units.height.unit ~= "auto" then
    local parentHeight = self.parent and self.parent.height or newViewportHeight
    self.height =
      Units.resolve(self.units.height.value, self.units.height.unit, newViewportWidth, newViewportHeight, parentHeight)
  elseif self.units.height.unit == "px" and self.units.height.value and Gui.baseScale then
    -- Reapply base scaling to pixel heights
    self.height = self.units.height.value * scaleY
  end

  -- Recalculate position if using viewport or percentage units
  if self.units.x.unit ~= "px" then
    local parentWidth = self.parent and self.parent.width or newViewportWidth
    local baseX = self.parent and self.parent.x or 0
    local offsetX =
      Units.resolve(self.units.x.value, self.units.x.unit, newViewportWidth, newViewportHeight, parentWidth)
    self.x = baseX + offsetX
  else
    -- For pixel units, update position relative to parent's new position (with base scaling)
    if self.parent then
      local baseX = self.parent.x
      local scaledOffset = Gui.baseScale and (self.units.x.value * scaleX) or self.units.x.value
      self.x = baseX + scaledOffset
    elseif Gui.baseScale then
      -- Top-level element with pixel position - apply base scaling
      self.x = self.units.x.value * scaleX
    end
  end

  if self.units.y.unit ~= "px" then
    local parentHeight = self.parent and self.parent.height or newViewportHeight
    local baseY = self.parent and self.parent.y or 0
    local offsetY =
      Units.resolve(self.units.y.value, self.units.y.unit, newViewportWidth, newViewportHeight, parentHeight)
    self.y = baseY + offsetY
  else
    -- For pixel units, update position relative to parent's new position (with base scaling)
    if self.parent then
      local baseY = self.parent.y
      local scaledOffset = Gui.baseScale and (self.units.y.value * scaleY) or self.units.y.value
      self.y = baseY + scaledOffset
    elseif Gui.baseScale then
      -- Top-level element with pixel position - apply base scaling
      self.y = self.units.y.value * scaleY
    end
  end

  -- Recalculate textSize if auto-scaling is enabled or using viewport/element-relative units
  if self.autoScaleText and self.units.textSize.value and self.units.textSize.unit ~= "px" then
    local unit = self.units.textSize.unit
    local value = self.units.textSize.value

    if unit == "%" or unit == "vh" then
      -- Percentage and vh are relative to viewport height
      self.textSize = Units.resolve(value, unit, newViewportWidth, newViewportHeight, newViewportHeight)
    elseif unit == "vw" then
      -- vw is relative to viewport width
      self.textSize = Units.resolve(value, unit, newViewportWidth, newViewportHeight, newViewportWidth)
    elseif unit == "ew" then
      -- Element width relative
      self.textSize = (value / 100) * self.width
    elseif unit == "eh" then
      -- Element height relative
      self.textSize = (value / 100) * self.height
    else
      self.textSize = Units.resolve(value, unit, newViewportWidth, newViewportHeight, nil)
    end

    -- Apply min/max constraints (with base scaling)
    local minSize = self.minTextSize and (Gui.baseScale and (self.minTextSize * scaleY) or self.minTextSize)
    local maxSize = self.maxTextSize and (Gui.baseScale and (self.maxTextSize * scaleY) or self.maxTextSize)

    if minSize and self.textSize < minSize then
      self.textSize = minSize
    end
    if maxSize and self.textSize > maxSize then
      self.textSize = maxSize
    end

    -- Protect against too-small text sizes (minimum 1px)
    if self.textSize < 1 then
      self.textSize = 1 -- Minimum 1px
    end
  elseif self.units.textSize.unit == "px" and self.units.textSize.value and Gui.baseScale then
    -- Reapply base scaling to pixel text sizes
    self.textSize = self.units.textSize.value * scaleY

    -- Protect against too-small text sizes (minimum 1px)
    if self.textSize < 1 then
      self.textSize = 1 -- Minimum 1px
    end
  end

  -- Final protection: ensure textSize is always at least 1px (catches all edge cases)
  if self.text and self.textSize and self.textSize < 1 then
    self.textSize = 1 -- Minimum 1px
  end

  -- Recalculate gap if using viewport or percentage units
  if self.units.gap.unit ~= "px" then
    local containerSize = (self.flexDirection == FlexDirection.HORIZONTAL)
        and (self.parent and self.parent.width or newViewportWidth)
      or (self.parent and self.parent.height or newViewportHeight)
    self.gap =
      Units.resolve(self.units.gap.value, self.units.gap.unit, newViewportWidth, newViewportHeight, containerSize)
  end

  -- Recalculate spacing (padding/margin) if using viewport or percentage units
  local containerWidth = self.parent and self.parent.width or newViewportWidth
  local containerHeight = self.parent and self.parent.height or newViewportHeight

  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    if self.units.padding[side].unit ~= "px" then
      local parentSize = (side == "top" or side == "bottom") and containerHeight or containerWidth
      self.padding[side] = Units.resolve(
        self.units.padding[side].value,
        self.units.padding[side].unit,
        newViewportWidth,
        newViewportHeight,
        parentSize
      )
    end

    if self.units.margin[side].unit ~= "px" then
      local parentSize = (side == "top" or side == "bottom") and containerHeight or containerWidth
      self.margin[side] = Units.resolve(
        self.units.margin[side].value,
        self.units.margin[side].unit,
        newViewportWidth,
        newViewportHeight,
        parentSize
      )
    end
  end
end

--- Resize element and its children based on game window size change
---@param newGameWidth number
---@param newGameHeight number
function Element:resize(newGameWidth, newGameHeight)
  self:recalculateUnits(newGameWidth, newGameHeight)

  -- Update children
  for _, child in ipairs(self.children) do
    child:resize(newGameWidth, newGameHeight)
  end

  -- Recalculate auto-sized dimensions after children are resized
  if self.autosizing.width then
    self.width = self:calculateAutoWidth()
  end
  if self.autosizing.height then
    self.height = self:calculateAutoHeight()
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
      local childHeight = child.height or child:calculateAutoHeight()
      local childOffset = childHeight + paddingAdjustment

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
