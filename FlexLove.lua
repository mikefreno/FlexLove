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

local Positioning, FlexDirection, JustifyContent, AlignContent, AlignItems, TextAlign, AlignSelf, JustifySelf =
  enums.Positioning,
  enums.FlexDirection,
  enums.JustifyContent,
  enums.AlignContent,
  enums.AlignItems,
  enums.TextAlign,
  enums.AlignSelf,
  enums.JustifySelf

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
---@field autosizing {width:boolean, height:boolean} -- Whether the element should automatically size to fit its children
---@field x number -- X coordinate of the element
---@field y number -- Y coordinate of the element
---@field z number -- Z-index for layering (default: 0)
---@field width number -- Width of the element
---@field height number -- Height of the element
---@field children table<integer, Element> -- Children of this element
---@field parent Element? -- Parent element (nil if top-level)
---@field border Border -- Border configuration for the element
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
---@field x number? -- X coordinate of the element (default: 0)
---@field y number? -- Y coordinate of the element (default: 0)
---@field z number? -- Z-index for layering (default: 0)
---@field w number? -- Width of the element (default: calculated automatically)
---@field h number? -- Height of the element (default: calculated automatically)
---@field border Border? -- Border configuration for the element
---@field borderColor Color? -- Color of the border (default: black)
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
  self.x = props.x or 0
  self.y = props.y or 0

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

  self.background = props.background or Color.new(0, 0, 0, 0)
  self.borderColor = props.borderColor or Color.new(0, 0, 0, 1)

  if props.textColor then
    self.textColor = props.textColor
  elseif props.parent then
    self.textColor = props.parent.textColor
  else
    self.textColor = Color.new(0, 0, 0, 1)
  end

  self.gap = props.gap or 10
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

  self.text = props.text

  self.textColor = props.textColor
  if self.textColor == nil then
    if props.parent then
      self.textColor = props.parent.textColor
    else
      self.textColor = Color.new(0, 0, 0, 1)
    end
  end
  self.textAlign = props.textAlign or TextAlign.START
  self.textSize = props.textSize

  self.positioning = props.positioning
  if props.positioning == nil then
    if props.parent then
      self.positioning = props.parent.positioning
    else
      self.positioning = Positioning.ABSOLUTE
    end
  end

  if self.positioning == Positioning.FLEX then
    self.flexDirection = props.flexDirection or FlexDirection.HORIZONTAL
    self.justifyContent = props.justifyContent or JustifyContent.FLEX_START
    self.alignItems = props.alignItems or AlignItems.STRETCH
    self.alignContent = props.alignContent or AlignContent.STRETCH
    self.justifySelf = props.justifySelf or AlignSelf.AUTO
    self.alignSelf = props.alignSelf or AlignSelf.AUTO
  end

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

  self.parent = props.parent
  if self.parent then
    -- Only add parent position to child coordinates if parent is not absolutely positioned
    if self.parent.positioning ~= Positioning.ABSOLUTE then
      self.x = self.x + self.parent.x
      self.y = self.y + self.parent.y
    end
  end
  self.children = {}
  if props.parent then
    props.parent:addChild(self)
  end
  local gw, gh = love.window.getMode()

  self.prevGameSize = { width = gw, height = gh }

  self.z = props.z or 0

  -- Add transform and transition properties
  self.transform = props.transform or {}
  self.transition = props.transition or {}

  -- Initialize opacity for animations to work properly
  self.opacity = self.background.a

  -- Store callback function for click events
  self.callback = props.callback or nil

  if not props.parent then
    table.insert(Gui.topElements, self)
  end
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

  local totalSize = 0
  local childCount = #self.children

  if childCount == 0 then
    return
  end

  for _, child in ipairs(self.children) do
    if self.flexDirection == FlexDirection.HORIZONTAL then
      totalSize = totalSize + (child.width or 0)
    else
      totalSize = totalSize + (child.height or 0)
    end
  end

  -- Add gaps between children
  totalSize = totalSize + (childCount - 1) * self.gap

  -- Calculate available space
  local availableSpace = self.flexDirection == FlexDirection.HORIZONTAL and self.width or self.height
  local freeSpace = availableSpace - totalSize

  -- Calculate spacing based on self.justifyContent
  local spacing = 0
  if self.justifyContent == JustifyContent.FLEX_START then
    spacing = 0
  elseif self.justifyContent == JustifyContent.CENTER then
    spacing = freeSpace / 2
  elseif self.justifyContent == JustifyContent.FLEX_END then
    spacing = freeSpace
  elseif self.justifyContent == JustifyContent.SPACE_AROUND then
    spacing = freeSpace / (childCount + 1)
  elseif self.justifyContent == JustifyContent.SPACE_EVENLY then
    spacing = freeSpace / (childCount + 1)
  elseif self.justifyContent == JustifyContent.SPACE_BETWEEN then
    if childCount > 1 then
      spacing = freeSpace / (childCount - 1)
    else
      spacing = 0
    end
  end

  -- Position children
  local currentPos = spacing
  for _, child in ipairs(self.children) do
    if child.positioning == Positioning.ABSOLUTE then
      -- Skip positioning for absolute children as they should maintain their own coordinates
      goto continue
    end
    if self.flexDirection == FlexDirection.VERTICAL then
      child.x = self.margin.left or 0
      child.y = currentPos + (self.margin.top or 0)

      -- Apply alignment to vertical axis (alignItems)
      if self.alignItems == AlignItems.FLEX_START then
        --nothing, currentPos is all
      elseif self.alignItems == AlignItems.CENTER then
        child.x = (self.width - (child.width or 0)) / 2
      elseif self.alignItems == AlignItems.FLEX_END then
        child.x = self.width - (child.width or 0)
      elseif self.alignItems == AlignItems.STRETCH then
        child.width = self.width
      end

      -- Apply self alignment to cross axis (alignSelf)
      local effectiveAlignSelf = child.alignSelf
      if child.alignSelf == AlignSelf.AUTO then
        effectiveAlignSelf = self.alignItems
      end

      if effectiveAlignSelf == AlignSelf.FLEX_START then
        -- nothing, currentPos is all - position should be at the beginning of cross axis
        -- For VERTICAL flex, this means X = 0
        child.x = 0
      elseif effectiveAlignSelf == AlignSelf.CENTER then
        if self.flexDirection == FlexDirection.VERTICAL then
          child.x = (self.width - (child.width or 0)) / 2
        else
          child.y = (self.height - (child.height or 0)) / 2
        end
      elseif effectiveAlignSelf == AlignSelf.FLEX_END then
        if self.flexDirection == FlexDirection.VERTICAL then
          child.x = self.width - (child.width or 0)
        else
          child.y = self.height - (child.height or 0)
        end
      elseif effectiveAlignSelf == AlignSelf.STRETCH then
        if self.flexDirection == FlexDirection.VERTICAL then
          child.width = self.width
        else
          child.height = self.height
        end
      end

      currentPos = currentPos + (child.height or 0) + self.gap + (self.margin.top or 0) + (self.margin.bottom or 0)
    else
      child.x = currentPos + (self.margin.left or 0)
      child.y = self.margin.top or 0

      -- Apply alignment to horizontal axis (alignItems)
      if self.alignItems == AlignItems.FLEX_START then
        --nothing, currentPos is all
      elseif self.alignItems == AlignItems.CENTER then
        child.y = (self.height - (child.height or 0)) / 2
      elseif self.alignItems == AlignItems.FLEX_END then
        child.y = self.height - (child.height or 0)
      elseif self.alignItems == AlignItems.STRETCH then
        child.height = self.height
      end

      -- Apply self alignment to horizontal axis (alignSelf)
      if child.alignSelf == AlignSelf.FLEX_START then
        -- nothing, currentPos is all - position should be at the beginning of cross axis
        -- For HORIZONTAL flex, this means Y = 0
        child.y = 0
      elseif child.alignSelf == AlignSelf.CENTER then
        child.y = (self.height - (child.height or 0)) / 2
      elseif child.alignSelf == AlignSelf.FLEX_END then
        child.y = self.height - (child.height or 0)
      elseif child.alignSelf == AlignSelf.STRETCH then
        child.height = self.height
      end

      currentPos = currentPos + (child.width or 0) + self.gap + (self.margin.left or 0) + (self.margin.right or 0)
    end
    ::continue::
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

  love.graphics.setColor(drawBackground:toRGBA())
  love.graphics.rectangle(
    "fill",
    self.x - self.padding.left,
    self.y - self.padding.top,
    self.width + self.padding.left + self.padding.right,
    self.height + self.padding.top + self.padding.bottom
  )
  -- Draw borders based on border property
  love.graphics.setColor(self.borderColor:toRGBA())
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
    love.graphics.setColor(self.textColor:toRGBA())

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
    love.graphics.setColor(0.5, 0.5, 0.5, 0.3) -- Semi-transparent gray for pressed state
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
    child:resize(ratioW, ratioH)
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
  for _, child in ipairs(self.children) do
    local paddingAdjustment = (child.padding.left or 0) + (child.padding.right or 0)
    local childWidth = child.width or child:calculateAutoWidth()
    local childOffset = childWidth + paddingAdjustment

    totalWidth = totalWidth + childOffset
  end

  return totalWidth + (self.gap * #self.children)
end

--- Calculate auto height based on children
function Element:calculateAutoHeight()
  local height = self:calculateTextHeight()
  if not self.children or #self.children == 0 then
    return height
  end

  local totalHeight = height
  for _, child in ipairs(self.children) do
    local paddingAdjustment = (child.padding.top or 0) + (child.padding.bottom or 0)
    local childOffset = child.height + paddingAdjustment

    totalHeight = totalHeight + childOffset
  end

  return totalHeight + (self.gap * #self.children)
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

Gui.new = Element.new
Gui.Element = Element
Gui.Animation = Animation
return { GUI = Gui, Color = Color, enums = enums }
