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
    local r = tonumber("0x" .. hex:sub(1, 2))
    local g = tonumber("0x" .. hex:sub(3, 4))
    local b = tonumber("0x" .. hex:sub(5, 6))
    return Color.new(r, g, b, 1)
  elseif #hex == 8 then
    local r = tonumber("0x" .. hex:sub(1, 2))
    local g = tonumber("0x" .. hex:sub(3, 4))
    local b = tonumber("0x" .. hex:sub(5, 6))
    local a = tonumber("0x" .. hex:sub(7, 8)) / 255
    return Color.new(r, g, b, a)
  else
    error("Invalid hex string")
  end
end

--- Convert color to hex string
---@return string
function Color:toHex()
  local r = math.floor(self.r * 255)
  local g = math.floor(self.g * 255)
  local b = math.floor(self.b * 255)
  local a = math.floor(self.a * 255)
  if self.a ~= 1 then
    return string.format("#%02X%02X%02X%02X", r, g, b, a)
  else
    return string.format("#%02X%02X%02X", r, g, b)
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
---@field topWindows table<integer, Window>
---@field resize fun(): nil
---@field draw fun(): nil
---@field update fun(dt:number): nil
---@field destroy fun(): nil
local Gui = { topWindows = {} }

function Gui.resize()
  local newWidth, newHeight = love.window.getMode()
  for _, win in ipairs(Gui.topWindows) do
    win:resize(newWidth, newHeight)
  end
end

function Gui.draw()
  -- Sort windows by z-index before drawing
  table.sort(Gui.topWindows, function(a, b)
    return a.z < b.z
  end)

  for _, win in ipairs(Gui.topWindows) do
    win:draw()
  end
end

function Gui.update(dt)
  for _, win in ipairs(Gui.topWindows) do
    win:update(dt)
  end
end

--- Destroy all windows and their children
function Gui.destroy()
  for _, win in ipairs(Gui.topWindows) do
    win:destroy()
  end
  Gui.topWindows = {}
end

-- Simple GUI library for LOVE2D
-- Provides window and button creation, drawing, and click handling.

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
---@param element Window|Button
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
-- Window Object
-- ====================
---@class Window
---@field autosizing boolean -- Whether the window should automatically size to fit its children
---@field x number -- X coordinate of the window
---@field y number -- Y coordinate of the window
---@field z number -- Z-index for layering (default: 0)
---@field width number -- Width of the window
---@field height number -- Height of the window
---@field children table<integer, Button|Window> -- Children of this window
---@field parent Window? -- Parent window (nil if top-level)
---@field border Border -- Border configuration for the window
---@field borderColor Color -- Color of the border
---@field background Color -- Background color of the window
---@field prevGameSize {width:number, height:number} -- Previous game size for resize calculations
---@field text string? -- Text content to display in the window
---@field textColor Color -- Color of the text content
---@field textAlign TextAlign -- Alignment of the text content
---@field gap number -- Space between children elements (default: 10)
---@field padding {top?:number, right?:number, bottom?:number, left?:number} -- Padding around children (default: {top=0, right=0, bottom=0, left=0})
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
local Window = {}
Window.__index = Window

---@class WindowProps
---@field parent Window? -- Parent window for hierarchical structure
---@field x number? -- X coordinate of the window (default: 0)
---@field y number? -- Y coordinate of the window (default: 0)
---@field z number? -- Z-index for layering (default: 0)
---@field w number? -- Width of the window (default: calculated automatically)
---@field h number? -- Height of the window (default: calculated automatically)
---@field border Border? -- Border configuration for the window
---@field borderColor Color? -- Color of the border (default: black)
---@field background Color? -- Background color (default: transparent)
---@field gap number? -- Space between children elements (default: 10)
---@field padding {top?:number, right?:number, bottom?:number, left?:number}? -- Padding around children (default: {top=0, right=0, bottom=0, left=0})
---@field margin {top?:number, right?:number, bottom?:number, left?:number}? -- Margin around children (default: {top=0, right=0, bottom=0, left=0})
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
---@field transform table? -- Transform properties for animations and styling
---@field transition table? -- Transition settings for animations
local WindowProps = {}

---@param props WindowProps
---@return Window
function Window.new(props)
  local self = setmetatable({}, Window)
  self.x = props.x or 0
  self.y = props.y or 0
  if props.w == nil or props.h == nil then
    self.autosizing = true
  else
    self.autosizing = false
  end
  self.width = props.w or 0
  self.height = props.h or 0
  self.parent = props.parent
  if props.parent then
    props.parent:addChild(self)
  end
  self.children = {}
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
  self.padding = props.padding or { top = 0, right = 0, bottom = 0, left = 0 }
  self.margin = props.margin or { top = 0, right = 0, bottom = 0, left = 0 }
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
  if self.positioning == nil then
    if props.parent then
      self.positioning = props.parent.positioning
    else
      self.positioning = Positioning.ABSOLUTE
    end
  end

  if self.positioning == Positioning.FLEX then
    self.positioning = props.positioning
    self.justifyContent = props.justifyContent or JustifyContent.FLEX_START
    self.alignItems = props.alignItems or AlignItems.STRETCH
    self.alignContent = props.alignContent or AlignContent.STRETCH
    self.justifySelf = props.justifySelf or AlignSelf.AUTO
    self.alignSelf = props.alignSelf or AlignSelf.AUTO
  end

  local gw, gh = love.window.getMode()
  self.prevGameSize = { width = gw, height = gh }

  self.z = props.z or 0

  -- Add transform and transition properties
  self.transform = props.transform or {}
  self.transition = props.transition or {}

  -- Initialize opacity for animations to work properly
  self.opacity = self.background.a

  if not props.parent then
    table.insert(Gui.topWindows, self)
  end
  return self
end

--- Get window bounds
---@return { x:number, y:number, width:number, height:number }
function Window:getBounds()
  return { x = self.x, y = self.y, width = self.width, height = self.height }
end

--- Add child to window
---@param child Button|Window
function Window:addChild(child)
  child.parent = self
  table.insert(self.children, child)
  self:layoutChildren()
end

function Window:layoutChildren()
  if self.positioning == Positioning.ABSOLUTE then
    return
  end
  self:calculateAutoWidth()
  self:calculateAutoHeight()

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
      goto continue
    end
    if self.flexDirection == FlexDirection.VERTICAL then
      child.x = currentPos + (self.margin.left or 0)
      child.y = 0

      -- Apply alignment to vertical axis (alignItems)
      if self.alignItems == AlignItems.FLEX_START then
        --nothing, currentPos is all
      elseif self.alignItems == AlignItems.CENTER then
        child.y = (self.height - (child.height or 0)) / 2
      elseif self.alignItems == AlignItems.FLEX_END then
        child.y = self.height - (child.height or 0)
      elseif self.alignItems == AlignItems.STRETCH then
        child.height = self.height
      end

      -- Apply self alignment to vertical axis (alignSelf)
      if child.alignSelf == AlignSelf.FLEX_START then
        --nothing, currentPos is all
      elseif child.alignSelf == AlignSelf.CENTER then
        child.y = (self.height - (child.height or 0)) / 2
      elseif child.alignSelf == AlignSelf.FLEX_END then
        child.y = self.height - (child.height or 0)
      elseif child.alignSelf == AlignSelf.STRETCH then
        child.height = self.height
      end

      currentPos = currentPos + (child.width or 0) + self.gap + (self.margin.left or 0) + (self.margin.right or 0)
    else
      child.y = currentPos + (self.margin.top or 0)
      -- Apply alignment to horizontal axis (alignItems)
      if self.alignItems == AlignItems.FLEX_START then
        --nothing, currentPos is all
      elseif self.alignItems == AlignItems.CENTER then
        child.x = (self.width - (child.width or 0)) / 2
      elseif self.alignItems == AlignItems.FLEX_END then
        child.x = self.width - (child.width or 0)
      elseif self.alignItems == AlignItems.STRETCH then
        child.width = self.width
      end

      -- Apply self alignment to horizontal axis (alignSelf)
      if child.alignSelf == AlignSelf.FLEX_START then
        --nothing, currentPos is all
      elseif child.alignSelf == AlignSelf.CENTER then
        child.x = (self.width - (child.width or 0)) / 2
      elseif child.alignSelf == AlignSelf.FLEX_END then
        child.x = self.width - (child.width or 0)
      elseif child.alignSelf == AlignSelf.STRETCH then
        child.width = self.width
      end

      currentPos = currentPos + (child.height or 0) + self.gap + (self.margin.top or 0) + (self.margin.bottom or 0)
    end
    ::continue::
  end
end

--- Destroy window and its children
function Window:destroy()
  -- Remove from global windows list
  for i, win in ipairs(Gui.topWindows) do
    if win == self then
      table.remove(Gui.topWindows, i)
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

--- Draw window and its children
function Window:draw()
  -- Handle opacity during animation
  local drawBackground = self.background
  if self.animation then
    local anim = self.animation:interpolate()
    if anim.opacity then
      drawBackground = Color.new(self.background.r, self.background.g, self.background.b, anim.opacity)
    end
  end

  love.graphics.setColor(drawBackground:toRGBA())
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  -- Draw borders based on border property
  love.graphics.setColor(self.borderColor:toRGBA())
  if self.border.top then
    love.graphics.line(
      self.x + (self.padding.left or 0),
      self.y + (self.padding.top or 0),
      self.x + self.width - (self.padding.right or 0),
      self.y + (self.padding.top or 0)
    )
  end
  if self.border.bottom then
    love.graphics.line(
      self.x + (self.padding.left or 0),
      self.y + self.height - (self.padding.bottom or 0),
      self.x + self.width - (self.padding.right or 0),
      self.y + self.height - (self.padding.bottom or 0)
    )
  end
  if self.border.left then
    love.graphics.line(
      self.x + (self.padding.left or 0),
      self.y + (self.padding.top or 0),
      self.x + (self.padding.left or 0),
      self.y + self.height - (self.padding.bottom or 0)
    )
  end
  if self.border.right then
    love.graphics.line(
      self.x + self.width - (self.padding.right or 0),
      self.y + (self.padding.top or 0),
      self.x + self.width - (self.padding.right or 0),
      self.y + self.height - (self.padding.bottom or 0)
    )
  end

  -- Draw window text if present
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

  for _, child in ipairs(self.children) do
    child:draw()
  end
end

--- Update window (propagate to children)
---@param dt number
function Window:update(dt)
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
end

--- Resize window and its children based on game window size change
---@param newGameWidth number
---@param newGameHeight number
function Window:resize(newGameWidth, newGameHeight)
  local prevW = self.prevGameSize.width
  local prevH = self.prevGameSize.height
  local ratioW = newGameWidth / prevW
  local ratioH = newGameHeight / prevH
  -- Update window size
  self.width = self.width * ratioW
  self.height = self.height * ratioH
  self.x = self.x * ratioW
  self.y = self.y * ratioH
  -- Update children positions and sizes
  for _, child in ipairs(self.children) do
    child:resize(ratioW, ratioH)
  end
  -- Re-layout children after resizing
  self:layoutChildren()
  self.prevGameSize.width = newGameWidth
  self.prevGameSize.height = newGameHeight
end

--- Calculate auto width based on children content size
function Window:calculateAutoWidth()
  if self.autosizing == false then
    return
  end
  if not self.children or #self.children == 0 then
    self.width = 0
  end
  Logger:debug("children count: " .. #self.children)

  local maxWidth = 0
  for _, child in ipairs(self.children) do
    -- Calculate content width based on child's actual content, not existing dimensions
    local contentWidth = 0
    if child.text then
      contentWidth = child:calculateTextWidth()
    elseif child.width and not child.autosizing then
      contentWidth = child.width
    else
      contentWidth = 0
    end
    
    local childX = child.x or 0
    local paddingAdjustment = (child.padding.left or 0) + (child.padding.right or 0)
    local totalWidth = childX + contentWidth + paddingAdjustment

    if totalWidth > maxWidth then
      maxWidth = totalWidth
    end
  end

  -- Add window's own padding and margin to the final width
  self.width = maxWidth
    + (self.padding.left or 0)
    + (self.padding.right or 0)
    + (self.margin.left or 0)
    + (self.margin.right or 0)
end

--- Calculate auto height based on children
function Window:calculateAutoHeight()
  if self.autosizing == false then
    return
  end
  if not self.children or #self.children == 0 then
    self.height = 0
  end

  local maxHeight = 0
  for _, child in ipairs(self.children) do
    -- Calculate content height based on child's actual content, not existing dimensions
    local contentHeight = 0
    if child.text then
      contentHeight = child:calculateTextHeight()
    elseif child.height and not child.autosizing then
      contentHeight = child.height
    else
      contentHeight = 0
    end
    
    local childY = child.y or 0
    local paddingAdjustment = (child.padding.top or 0) + (child.padding.bottom or 0)
    local totalHeight = childY + contentHeight + paddingAdjustment

    if totalHeight > maxHeight then
      maxHeight = totalHeight
    end
  end

  -- Add window's own padding and margin to the final height
  self.height = maxHeight
    + (self.padding.top or 0)
    + (self.padding.bottom or 0)
    + (self.margin.top or 0)
    + (self.margin.bottom or 0)
end

--- Update window size to fit children automatically
function Window:updateAutoSize()
  -- Store current dimensions for comparison
  local oldWidth, oldHeight = self.width, self.height
  if self.width == 0 then
    self.width = self:calculateAutoWidth() or 0
  end
  if self.height == 0 then
    self.height = self:calculateAutoHeight() or 0
  end
  -- Only re-layout children if dimensions changed
  if oldWidth ~= self.width or oldHeight ~= self.height then
    self:layoutChildren()
  end
end

--- Find a child element by name or id (if applicable)
---@param name string -- Name or id to search for
---@return Button|Window|nil
function Window:findChild(name)
  for _, child in ipairs(self.children) do
    if child.name == name or child.id == name then
      return child
    end
  end
  return nil
end

--- Get all children of a specific type
---@param type string -- "Button" or "Window"
---@return table<integer, Button|Window>
function Window:getChildrenOfType(type)
  local result = {}
  for _, child in ipairs(self.children) do
    if getmetatable(child).__name == type then
      table.insert(result, child)
    end
  end
  return result
end

--- Set the visibility of this window and its children
---@param visible boolean -- Whether to show or hide the window
function Window:setVisible(visible)
  self.visible = visible
  for _, child in ipairs(self.children) do
    if child.setVisible then
      child:setVisible(visible)
    end
  end
end

--- Get the absolute position of this window relative to screen
---@return number x, number y
function Window:getAbsolutePosition()
  local x, y = self.x, self.y
  local parent = self.parent
  while parent do
    x = x + parent.x
    y = y + parent.y
    parent = parent.parent
  end
  return x, y
end

--- Get the absolute bounds of this window
---@return {x:number, y:number, width:number, height:number}
function Window:getAbsoluteBounds()
  local x, y = self:getAbsolutePosition()
  return {
    x = x,
    y = y,
    width = self.width,
    height = self.height,
  }
end

--- Set the size of this window and all its children proportionally
---@param width number -- New width
---@param height number -- New height
function Window:setSize(width, height)
  local oldWidth = self.width
  local oldHeight = self.height
  if oldWidth > 0 and oldHeight > 0 then
    local ratioW = width / oldWidth
    local ratioH = height / oldHeight
    self.width = width
    self.height = height
    -- Resize children proportionally
    for _, child in ipairs(self.children) do
      if child.resize then
        child:resize(ratioW, ratioH)
      end
    end
  else
    self.width = width
    self.height = height
  end
end

--- Center this window within its parent or screen
---@param parent Window? -- Parent window to center within (optional)
function Window:center(parent)
  local parentWidth, parentHeight = love.window.getMode()
  if parent then
    parentWidth = parent.width
    parentHeight = parent.height
  end

  self.x = (parentWidth - self.width) / 2
  self.y = (parentHeight - self.height) / 2
end

---@class Button
---@field x number
---@field y number
---@field z number -- default: 0
---@field width number
---@field height number
---@field padding {top?:number, right?:number, bottom?:number, left?:number} -- Padding (default: {top=0, right=0, bottom=0, left=0})
---@field margin {top?:number, right?:number, bottom?:number, left?:number} -- Margin (default: {top=0, right=0, bottom=0, left=0})
---@field text string?
---@field border Border
---@field borderColor Color?
---@field background Color
---@field parent Window
---@field callback function
---@field textColor Color?
---@field _touchPressed table<number, boolean>
---@field positioning Positioning --default: ABSOLUTE (checks parent first)
---@field textSize number?
---@field justifySelf JustifySelf -- default: auto
---@field alignSelf AlignSelf -- default: auto
---@field transform TransformProps
---@field transition TransitionProps
---@field autosizing boolean
local Button = {}
Button.__index = Button

---@class ButtonProps
---@field parent Window? -- optional
---@field x number?
---@field y number?
---@field z number?
---@field w number?
---@field h number?
---@field padding {top?:number, right?:number, bottom?:number, left?:number}? -- Padding (default: {top=0, right=0, bottom=0, left=0})
---@field margin {top?:number, right?:number, bottom?:number, left?:number}? -- Margin (default: {top=0, right=0, bottom=0, left=0})
---@field text string?
---@field callback function?
---@field background Color?
---@field border Border?
---@field borderColor Color? -- default: black
---@field textColor Color? -- default: black,
---@field textSize number? -- default: nil
---@field positioning Positioning? --default: ABSOLUTE (checks parent first)
---@field justifySelf JustifySelf? -- default: AUTO
---@field alignSelf AlignSelf? -- default: AUTO
---@field transform table?
---@field transition table?
local ButtonProps = {}

---@param props ButtonProps
---@return Button
function Button.new(props)
  local self = setmetatable({}, Button)
  self.parent = props.parent
  self.textSize = props.textSize
  self.text = props.text or nil
  self.x = props.x or 0
  self.y = props.y or 0
  self.padding = props.padding or { top = 0, right = 0, bottom = 0, left = 0 }
  self.margin = props.margin or { top = 0, right = 0, bottom = 0, left = 0 }

  -- Add autosizing logic similar to Window class
  if props.w == nil or props.h == nil then
    self.autosizing = true
  else
    self.autosizing = false
  end

  self.width = props.w or self:calculateTextWidth()
  self.height = props.h or self:calculateTextHeight()
  self.border = props.border
      and {
        top = props.border.top or true,
        right = props.border.right or true,
        bottom = props.border.bottom or true,
        left = props.border.left or true,
      }
    or {
      top = true,
      right = true,
      bottom = true,
      left = true,
    }
  self.borderColor = props.borderColor or Color.new(0, 0, 0, 1)
  self.textColor = props.textColor
  self.background = props.background or Color.new(0, 0, 0, 0)

  self.positioning = props.positioning or props.parent.positioning
  self.justifySelf = props.justifySelf or AlignSelf.AUTO
  self.alignSelf = props.alignSelf or AlignSelf.AUTO

  self.z = props.z or 0

  self.callback = props.callback or function() end
  self._pressed = false
  self._touchPressed = {}

  -- Add transform and transition properties
  self.transform = props.transform or {}
  self.transition = props.transition or {}

  -- Initialize opacity for animations to work properly
  self.opacity = self.background.a

  -- If autosizing is enabled, calculate the size based on text
  if self.autosizing then
    self:autosize()
  end

  props.parent:addChild(self)
  return self
end

function Button:bounds()
  return { x = self.parent.x + self.x, y = self.parent.y + self.y, width = self.width, height = self.height }
end

---comment
---@param ratioW number?
---@param ratioH number?
function Button:resize(ratioW, ratioH)
  self.x = self.x * (ratioW or 1)
  self.y = self.y * (ratioH or 1)
  local textWidth = self:calculateTextWidth()
  local textHeight = self:calculateTextHeight()
  self.width = math.max(self.width * (ratioW or 1), textWidth)
  self.height = math.max(self.height * (ratioH or 1), textHeight)

  -- If autosizing is enabled, recalculate size after resize
  if self.autosizing then
    self:autosize()
  end
end

---@param newText string
---@param autoresize boolean? --default: false
function Button:updateText(newText, autoresize)
  self.text = newText or self.text
  if autoresize then
    self.width = self:calculateTextWidth() + (self.padding.left or 0) + (self.padding.right or 0)
    self.height = self:calculateTextHeight() + (self.padding.top or 0) + (self.padding.bottom or 0)
  end

  -- If autosizing is enabled, recalculate size after text update
  if self.autosizing then
    self:autosize()
  end
end

function Button:draw()
  love.graphics.setColor(self.background:toRGBA())
  love.graphics.rectangle("fill", self.parent.x + self.x, self.parent.y + self.y, self.width, self.height)
  -- Draw borders based on border property
  love.graphics.setColor(self.borderColor:toRGBA())
  if self.border.top then
    love.graphics.line(
      self.parent.x + self.x,
      self.parent.y + self.y,
      self.parent.x + self.x + self.width,
      self.parent.y + self.y
    )
  end
  if self.border.bottom then
    love.graphics.line(
      self.parent.x + self.x,
      self.parent.y + self.y + self.height,
      self.parent.x + self.x + self.width,
      self.parent.y + self.y + self.height
    )
  end
  if self.border.left then
    love.graphics.line(
      self.parent.x + self.x,
      self.parent.y + self.y,
      self.parent.x + self.x,
      self.parent.y + self.y + self.height
    )
  end
  if self.border.right then
    love.graphics.line(
      self.parent.x + self.x + self.width,
      self.parent.y + self.y,
      self.parent.x + self.x + self.width,
      self.parent.y + self.y + self.height
    )
  end

  local origFont = love.graphics.getFont()
  if self.textSize then
    local tempFont = love.graphics.newFont(self.textSize)
    love.graphics.setFont(tempFont)
  end
  local textColor = self.textColor or self.parent.textColor
  love.graphics.setColor(textColor:toRGBA())
  local tx = self.parent.x + self.x + (self.width - self:calculateTextWidth()) / 2
  local ty = self.parent.y + self.y + (self.height - self:calculateTextHeight()) / 3
  love.graphics.print(self.text, tx, ty)
  if self.textSize then
    love.graphics.setFont(origFont)
  end
end

--- Calculate text width for button
---@return number
function Button:calculateTextWidth()
  if self.text == nil then
    return 0
  end
  -- If textSize is specified, use that font size instead of default
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
function Button:calculateTextHeight()
  -- If textSize is specified, use that font size instead of default
  if self.textSize then
    local tempFont = FONT_CACHE.get(self.textSize)
    local height = tempFont:getHeight()
    return height
  end

  local font = love.graphics.getFont()
  local height = font:getHeight()
  return height
end

--- Set button dimensions based on text size plus padding (auto-sizing)
function Button:autosize()
  local textWidth = self:calculateTextWidth()
  local textHeight = self:calculateTextHeight()
  self.width = textWidth + (self.padding.left or 0) + (self.padding.right or 0)
  self.height = textHeight + (self.padding.top or 0) + (self.padding.bottom or 0)
end

--- Update button (propagate to children)
---@param dt number
function Button:update(dt)
  local mx, my = love.mouse.getPosition()
  local bx = self.parent.x + self.x
  local by = self.parent.y + self.y
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

  -- Update animation if exists (similar to Window:update)
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
end

--- Destroy button
function Button:destroy()
  -- Remove from parent's children list
  if self.parent then
    for i, child in ipairs(self.parent.children) do
      if child == self then
        table.remove(self.parent.children, i)
        break
      end
    end
    self.parent = nil
  end
  -- Clear callback reference
  self.callback = nil
  -- Clear touchPressed references
  self._touchPressed = nil
end

Gui.Button = Button
Gui.Window = Window
Gui.Animation = Animation
return { GUI = Gui, Color = Color, enums = enums }
