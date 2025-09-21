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

-- Unit parsing and viewport calculations
local Units = {}

--- Parse a unit value (string or number) into value and unit type
---@param value string|number
---@return number, string -- Returns numeric value and unit type ("px", "%", "vw", "vh", "vmin", "vmax")
function Units.parse(value)
  if type(value) == "number" then
    return value, "px"
  end

  if type(value) ~= "string" then
    error("Unit value must be a string or number, got " .. type(value))
  end

  -- Match number followed by optional unit
  local numStr, unit = value:match("^([%-]?[%d%.]+)(.*)$")
  if not numStr then
    error("Invalid unit format: " .. value)
  end

  local num = tonumber(numStr)
  if not num then
    error("Invalid numeric value: " .. numStr)
  end

  -- Default to pixels if no unit specified
  if unit == "" then
    unit = "px"
  end

  -- Validate unit type
  local validUnits = { px = true, ["%"] = true, vw = true, vh = true, vmin = true, vmax = true }
  if not validUnits[unit] then
    error("Unsupported unit type: " .. unit)
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
  elseif unit == "vmin" then
    return (value / 100) * math.min(viewportWidth, viewportHeight)
  elseif unit == "vmax" then
    return (value / 100) * math.max(viewportWidth, viewportHeight)
  else
    error("Unknown unit type: " .. unit)
  end
end

--- Cache viewport dimensions for performance
local ViewportCache = {
  width = 0,
  height = 0,
  lastUpdate = 0,
}

-- Performance optimization: Resize state management
local ResizeState = {
  isResizing = false,
  batchedElements = {},
  resizeDebounceTime = 0.016, -- 16ms for 60fps
  lastResizeTime = 0,
  resizeTimer = nil,
}

--- Get current viewport dimensions (cached for performance)
---@return number, number -- width, height
function Units.getViewport()
  -- Update cache every frame to detect window resize
  local currentTime = love.timer.getTime()
  if currentTime ~= ViewportCache.lastUpdate then
    ViewportCache.width, ViewportCache.height = love.window.getMode()
    ViewportCache.lastUpdate = currentTime
  end
  return ViewportCache.width, ViewportCache.height
end

--- Performance: Start batch resize operation
---@param newGameWidth number
---@param newGameHeight number
function Units.startBatchResize(newGameWidth, newGameHeight)
  ResizeState.isResizing = true
  ResizeState.batchedElements = {}
  ResizeState.lastResizeTime = love.timer.getTime()

  -- Update viewport cache once for the entire batch
  ViewportCache.width = newGameWidth
  ViewportCache.height = newGameHeight
  ViewportCache.lastUpdate = ResizeState.lastResizeTime
end

--- Performance: Add element to batch resize
---@param element table
function Units.addToBatchResize(element)
  if ResizeState.isResizing then
    table.insert(ResizeState.batchedElements, element)
    element.isDirty = true
  end
end

--- Performance: Complete batch resize operation
function Units.completeBatchResize()
  if not ResizeState.isResizing then
    return
  end

  -- Process all batched elements in a single pass
  for _, element in ipairs(ResizeState.batchedElements) do
    if element.isDirty then
      element:recalculateUnits()
      element.needsLayout = true
      element.isDirty = false
    end
  end

  -- Perform layout updates in a second pass to avoid redundant calculations
  for _, element in ipairs(ResizeState.batchedElements) do
    if element.needsLayout then
      element:layoutChildren()
      element.needsLayout = false
    end
  end

  -- Reset batch state
  ResizeState.isResizing = false
  ResizeState.batchedElements = {}
end

--- Performance: Check if resize should be debounced
---@return boolean
function Units.shouldDebounceResize()
  local currentTime = love.timer.getTime()
  return (currentTime - ResizeState.lastResizeTime) < ResizeState.resizeDebounceTime
end

--- Resolve units for spacing properties (padding, margin) that can have top, right, bottom, left, vertical, horizontal
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
    else
      -- Numeric value, use as-is
      vertical = vertical
    end
  end

  if horizontal then
    if type(horizontal) == "string" then
      local value, unit = Units.parse(horizontal)
      horizontal = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
    else
      -- Numeric value, use as-is
      horizontal = horizontal
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
        -- Numeric value, use as-is
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
  self.textSize = props.textSize or 12
  self.textAlign = props.textAlign or TextAlign.START

  --- self positioning ---
  local viewportWidth, viewportHeight = Units.getViewport()
  local containerWidth = self.parent and self.parent.width or viewportWidth
  local containerHeight = self.parent and self.parent.height or viewportHeight

  self.padding = Units.resolveSpacing(props.padding, containerWidth, containerHeight)
  self.margin = Units.resolveSpacing(props.margin, containerWidth, containerHeight)

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

  -- Performance optimization: dirty flag for resize operations
  self.isDirty = false
  self.needsLayout = false

  if props.w then
    if type(props.w) == "string" then
      -- Handle units for string values
      local value, unit = Units.parse(props.w)
      self.units.width = { value = value, unit = unit }

      -- Resolve to pixels immediately
      local viewportWidth, viewportHeight = Units.getViewport()
      local parentWidth = self.parent and self.parent.width or viewportWidth
      self.width = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
    else
      -- Handle numeric values (backward compatibility)
      self.width = props.w
      self.units.width = { value = props.w, unit = "px" }
    end
  else
    self.autosizing.width = true
    self.width = self:calculateAutoWidth()
  end

  if props.h then
    if type(props.h) == "string" then
      -- Handle units for string values
      local value, unit = Units.parse(props.h)
      self.units.height = { value = value, unit = unit }

      -- Resolve to pixels immediately
      local viewportWidth, viewportHeight = Units.getViewport()
      local parentHeight = self.parent and self.parent.height or viewportHeight
      self.height = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
    else
      -- Handle numeric values (backward compatibility)
      self.height = props.h
      self.units.height = { value = props.h, unit = "px" }
    end
  else
    self.autosizing.height = true
    self.height = self:calculateAutoHeight()
  end

  --- child positioning ---
  if props.gap then
    if type(props.gap) == "string" then
      -- Handle units for string values
      local value, unit = Units.parse(props.gap)
      self.units.gap = { value = value, unit = unit }
      local viewportWidth, viewportHeight = Units.getViewport()
      local containerSize = (self.flexDirection == FlexDirection.HORIZONTAL)
          and (self.parent and self.parent.width or viewportWidth)
        or (self.parent and self.parent.height or viewportHeight)
      self.gap = Units.resolve(value, unit, viewportWidth, viewportHeight, containerSize)
    else
      -- Handle numeric values (backward compatibility)
      self.gap = props.gap
      self.units.gap = { value = props.gap, unit = "px" }
    end
  else
    self.gap = 10
    self.units.gap = { value = 10, unit = "px" }
  end

  -- Store original values for responsive scaling
  if props.textSize then
    if type(props.textSize) == "string" then
      local value, unit = Units.parse(props.textSize)
      self.units.textSize = { value = value, unit = unit }
    else
      self.units.textSize = { value = props.textSize, unit = "px" }
    end
  end

  -- Store original spacing values for scaling
  if props.padding then
    for _, side in ipairs({ "top", "right", "bottom", "left" }) do
      if props.padding[side] then
        if type(props.padding[side]) == "string" then
          local value, unit = Units.parse(props.padding[side])
          self.units.padding[side] = { value = value, unit = unit }
        else
          self.units.padding[side] = { value = props.padding[side], unit = "px" }
        end
      end
    end
  end

  if props.margin then
    for _, side in ipairs({ "top", "right", "bottom", "left" }) do
      if props.margin[side] then
        if type(props.margin[side]) == "string" then
          local value, unit = Units.parse(props.margin[side])
          self.units.margin[side] = { value = value, unit = unit }
        else
          self.units.margin[side] = { value = props.margin[side], unit = "px" }
        end
      end
    end
  end

  ------ add hereditary ------
  if props.parent == nil then
    table.insert(Gui.topElements, self)

    -- Handle x position with units
    if props.x then
      if type(props.x) == "string" then
        -- Handle units for string values
        local value, unit = Units.parse(props.x)
        self.units.x = { value = value, unit = unit }
        local viewportWidth, viewportHeight = Units.getViewport()
        self.x = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
      else
        -- Handle numeric values (backward compatibility)
        self.x = props.x
        self.units.x = { value = props.x, unit = "px" }
      end
    else
      self.x = 0
    end

    -- Handle y position with units
    if props.y then
      if type(props.y) == "string" then
        -- Handle units for string values
        local value, unit = Units.parse(props.y)
        self.units.y = { value = value, unit = unit }
        local viewportWidth, viewportHeight = Units.getViewport()
        self.y = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
      else
        -- Handle numeric values (backward compatibility)
        self.y = props.y
        self.units.y = { value = props.y, unit = "px" }
      end
    else
      self.y = 0
    end

    self.z = props.z or 0

    self.textColor = props.textColor or Color.new(0, 0, 0, 1)

    -- Set positioning - top level elements are always absolute
    self.positioning = props.positioning or Positioning.ABSOLUTE
    -- Set explicitlyAbsolute flag for top-level elements
    if props.positioning == Positioning.ABSOLUTE then
      self.explicitlyAbsolute = true -- User explicitly requested absolute positioning
    elseif props.positioning == Positioning.FLEX then
      self.explicitlyAbsolute = false -- User explicitly requested flex container
    else
      self.explicitlyAbsolute = false -- Default positioning, not explicitly requested
    end
  else
    self.parent = props.parent

    -- Set positioning based on user's explicit choice or default
    if props.positioning == Positioning.ABSOLUTE then
      self.positioning = Positioning.ABSOLUTE
      self.explicitlyAbsolute = true -- User explicitly requested absolute positioning
    elseif props.positioning == Positioning.FLEX then
      self.positioning = Positioning.FLEX
      self.explicitlyAbsolute = false -- User explicitly requested flex container
    else
      -- Default: absolute positioning (most common case)
      self.positioning = Positioning.ABSOLUTE
      self.explicitlyAbsolute = false -- Default positioning, not explicitly requested
    end

    -- Set initial position
    if self.positioning == Positioning.ABSOLUTE then
      -- Handle x position with units
      if props.x then
        if type(props.x) == "string" then
          -- Handle units for string values
          local value, unit = Units.parse(props.x)
          self.units.x = { value = value, unit = unit }
          local viewportWidth, viewportHeight = Units.getViewport()
          local parentWidth = self.parent.width
          self.x = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
        else
          -- Handle numeric values (backward compatibility)
          self.x = props.x
          self.units.x = { value = props.x, unit = "px" }
        end
      else
        self.x = 0
      end

      -- Handle y position with units
      if props.y then
        if type(props.y) == "string" then
          -- Handle units for string values
          local value, unit = Units.parse(props.y)
          self.units.y = { value = value, unit = unit }
          local viewportWidth, viewportHeight = Units.getViewport()
          local parentHeight = self.parent.height
          self.y = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
        else
          -- Handle numeric values (backward compatibility)
          self.y = props.y
          self.units.y = { value = props.y, unit = "px" }
        end
      else
        self.y = 0
      end

      self.z = props.z or 0
    else
      -- Children in flex containers start at parent position but will be repositioned by layoutChildren
      -- For flex children, relative units are resolved relative to parent
      local baseX = self.parent.x
      local baseY = self.parent.y

      if props.x then
        if type(props.x) == "string" then
          -- Handle units for string values
          local value, unit = Units.parse(props.x)
          self.units.x = { value = value, unit = unit }
          local viewportWidth, viewportHeight = Units.getViewport()
          local parentWidth = self.parent.width
          local offsetX = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
          self.x = baseX + offsetX
        else
          -- Handle numeric values (backward compatibility)
          self.x = baseX + props.x
          self.units.x = { value = props.x, unit = "px" }
        end
      else
        self.x = baseX
      end

      if props.y then
        if type(props.y) == "string" then
          -- Handle units for string values
          local value, unit = Units.parse(props.y)
          self.units.y = { value = value, unit = unit }
          local viewportWidth, viewportHeight = Units.getViewport()
          local parentHeight = self.parent.height
          local offsetY = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
          self.y = baseY + offsetY
        else
          -- Handle numeric values (backward compatibility)
          self.y = baseY + props.y
          self.units.y = { value = props.y, unit = "px" }
        end
      else
        self.y = baseY
      end

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

  -- Interactive state for callbacks
  self.pressed = false
  self.touchPressed = {}

  return self
end

--- Recalculate all unit-based dimensions and positions
--- Should be called when viewport changes or parent dimensions change
function Element:recalculateUnits()
  -- Use cached viewport if available and current, otherwise get fresh values
  local viewportWidth, viewportHeight
  if ViewportCache.lastUpdate == love.timer.getTime() then
    viewportWidth, viewportHeight = ViewportCache.width, ViewportCache.height
  else
    viewportWidth, viewportHeight = Units.getViewport()
  end

  -- Recalculate width if it uses units
  if not self.autosizing.width and self.units.width.value then
    local parentWidth = self.parent and self.parent.width or viewportWidth
    self.width =
      Units.resolve(self.units.width.value, self.units.width.unit, viewportWidth, viewportHeight, parentWidth)
  end

  -- Recalculate height if it uses units
  if not self.autosizing.height and self.units.height.value then
    local parentHeight = self.parent and self.parent.height or viewportHeight
    self.height =
      Units.resolve(self.units.height.value, self.units.height.unit, viewportWidth, viewportHeight, parentHeight)
  end

  -- Recalculate position if it uses units
  if self.units.x.value then
    local parentWidth = self.parent and self.parent.width or viewportWidth
    local baseX = (self.parent and self.positioning ~= Positioning.ABSOLUTE) and self.parent.x or 0
    local offsetX = Units.resolve(self.units.x.value, self.units.x.unit, viewportWidth, viewportHeight, parentWidth)
    self.x = baseX + offsetX
  end

  if self.units.y.value then
    local parentHeight = self.parent and self.parent.height or viewportHeight
    local baseY = (self.parent and self.positioning ~= Positioning.ABSOLUTE) and self.parent.y or 0
    local offsetY = Units.resolve(self.units.y.value, self.units.y.unit, viewportWidth, viewportHeight, parentHeight)
    self.y = baseY + offsetY
  end

  -- Recalculate gap if it uses units
  if self.units.gap and self.units.gap.value then
    local containerSize = (self.flexDirection == FlexDirection.HORIZONTAL)
        and (self.parent and self.parent.width or viewportWidth)
      or (self.parent and self.parent.height or viewportHeight)
    self.gap = Units.resolve(self.units.gap.value, self.units.gap.unit, viewportWidth, viewportHeight, containerSize)
  end

  -- Recalculate textSize if it uses units
  if self.units.textSize and self.units.textSize.value then
    -- For textSize, we don't need a parent size context - use viewport directly
    self.textSize =
      Units.resolve(self.units.textSize.value, self.units.textSize.unit, viewportWidth, viewportHeight, nil)
  end

  -- NOTE: Children recalculation is now handled by the batch resize system
  -- This avoids recursive calls during resize operations for better performance
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

  table.insert(self.children, child)

  -- Recalculate child dimensions now that parent relationship is established
  -- This is important for percentage-based units that depend on parent dimensions
  child:recalculateUnits()

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
    -- Children participate in flex layout if:
    -- 1. Parent is a flex container AND
    -- 2. Child is NOT explicitly positioned absolute
    local shouldParticipateInFlex = (self.positioning == Positioning.FLEX) and not child.explicitlyAbsolute
    if shouldParticipateInFlex then
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
          -- In horizontal layout, cross-axis is height
          -- CSS flexbox stretch behavior: always stretch unless explicitly marked as non-stretchable
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
          -- In vertical layout, cross-axis is width
          -- CSS flexbox stretch behavior: always stretch unless explicitly marked as non-stretchable
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
  if self.callback and self.pressed then
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
        self.pressed = true
      elseif not love.mouse.isDown(1) and self.pressed then
        Logger:debug("calling callback")
        self.callback(self)
        self.pressed = false
      end
    else
      self.pressed = false
    end

    local touches = love.touch.getTouches()
    for _, id in ipairs(touches) do
      local tx, ty = love.touch.getPosition(id)
      if tx >= bx and tx <= bx + self.width and ty >= by and ty <= by + self.height then
        self.touchPressed[id] = true
      elseif self.touchPressed[id] then
        self.callback(self)
        self.touchPressed[id] = false
      end
    end
  end
end

--- Resize element and its children based on game window size change (Performance Optimized)
---@param newGameWidth number
---@param newGameHeight number
function Element:resize(newGameWidth, newGameHeight)
  -- Early return if dimensions haven't changed
  if self.prevGameSize.width == newGameWidth and self.prevGameSize.height == newGameHeight then
    return
  end

  -- Performance: batch operations at root level
  local isRootResize = not self.parent
  if isRootResize then
    -- Update viewport cache once for entire operation
    ViewportCache.width = newGameWidth
    ViewportCache.height = newGameHeight
    ViewportCache.lastUpdate = love.timer.getTime()
  end

  -- Calculate scale factors for proportional scaling
  local scaleX = newGameWidth / self.prevGameSize.width
  local scaleY = newGameHeight / self.prevGameSize.height

  -- Apply proportional scaling to pixel-based properties
  if self.units.width.unit == "px" and not self.autosizing.width then
    self.width = self.width * scaleX
    self.units.width.value = self.width
  end

  if self.units.height.unit == "px" and not self.autosizing.height then
    self.height = self.height * scaleY
    self.units.height.value = self.height
  end

  if self.units.x.unit == "px" then
    self.x = self.x * scaleX
    self.units.x.value = self.x
  end

  if self.units.y.unit == "px" then
    self.y = self.y * scaleY
    self.units.y.value = self.y
  end

  if self.units.gap and self.units.gap.unit == "px" then
    self.gap = self.gap * ((scaleX + scaleY) / 2)
    self.units.gap.value = self.gap
  end

  if self.units.textSize and self.units.textSize.unit == "px" and self.textSize then
    local avgScale = (scaleX + scaleY) / 2
    self.textSize = self.textSize * avgScale
    self.units.textSize.value = self.textSize
  end

  -- Scale padding and margin
  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    if self.units.padding[side] and self.units.padding[side].unit == "px" and self.padding[side] then
      local scale = (side == "top" or side == "bottom") and scaleY or scaleX
      self.padding[side] = self.padding[side] * scale
      self.units.padding[side].value = self.padding[side]
    end

    if self.units.margin[side] and self.units.margin[side].unit == "px" and self.margin[side] then
      local scale = (side == "top" or side == "bottom") and scaleY or scaleX
      self.margin[side] = self.margin[side] * scale
      self.units.margin[side].value = self.margin[side]
    end
  end

  -- Update stored game size
  self.prevGameSize.width = newGameWidth
  self.prevGameSize.height = newGameHeight

  -- Recalculate units for viewport/percentage units
  self:recalculateUnits()

  -- Recursively resize children
  for _, child in ipairs(self.children) do
    child:resize(newGameWidth, newGameHeight)
  end

  -- Re-layout children after resizing
  self:layoutChildren()
end

--- Check if element uses viewport units (performance helper)
---@return boolean
function Element:hasViewportUnits()
  return (self.units.width.unit == "vw" or self.units.width.unit == "vh")
    or (self.units.height.unit == "vw" or self.units.height.unit == "vh")
    or (self.units.x.unit == "vw" or self.units.x.unit == "vh")
    or (self.units.y.unit == "vw" or self.units.y.unit == "vh")
    or (self.units.gap and (self.units.gap.unit == "vw" or self.units.gap.unit == "vh"))
    or (self.units.textSize and (self.units.textSize.unit == "vw" or self.units.textSize.unit == "vh"))
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
    local participatesInLayout = (self.positioning == Positioning.FLEX) and not child.explicitlyAbsolute
    if participatesInLayout then
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
    local participatesInLayout = (self.positioning == Positioning.FLEX) and not child.explicitlyAbsolute
    if participatesInLayout then
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
