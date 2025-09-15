-- Utility class for color handling
---@class Color
---@field r number
---@field g number
---@field b number
---@field a number
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
---@param hex string -- e.g. "#RRGGBB" or "#RRGGBBAA"
---@return Color
function Color.fromHex(hex)
  local hex = hex:gsub("#", "")
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

--- @enum AlignItems
enums.AlignItems = {
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

local Positioning, FlexDirection, JustifyContent, AlignContent, AlignItems, TextAlign =
  enums.Positioning, enums.FlexDirection, enums.JustifyContent, enums.AlignContent, enums.AlignItems, enums.TextAlign

--- Top level GUI manager
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
---@field start table{width:number,height:number}
---@field final table{width:number,height:number}
---@field elapsed number
local Animation = {}
Animation.__index = Animation

---@class AnimationProps
---@field duration number
---@field start table{width:number,height:number}
---@field final table{width:number,height:number}
local AnimationProps = {}

---@param props AnimationProps
function Animation.new(props)
  local self = setmetatable({}, Animation)
  self.duration = props.duration
  self.start = props.start
  self.final = props.final
  self.elapsed = 0
  return self
end

function Animation:update(dt)
  self.elapsed = self.elapsed + dt
  if self.elapsed >= self.duration then
    return true -- finished
  else
    return false
  end
end

function Animation:interpolate()
  local t = math.min(self.elapsed / self.duration, 1)
  return {
    width = self.start.width * (1 - t) + self.final.width * t,
    height = self.start.height * (1 - t) + self.final.height * t,
  }
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
---@field autosizing boolean
---@field x number
---@field y number
---@field z number -- default: 0
---@field width number
---@field height number
---@field children table<integer, Button|Window>
---@field parent Window?
---@field border Border
---@field borderColor Color
---@field background Color
---@field prevGameSize {width:number, height:number}
---@field text string?
---@field textColor Color
---@field textAlign TextAlign
---@field gap number
---@field px number
---@field py number
---@field positioning Positioning -- default: ABSOLUTE
---@field flexDirection FlexDirection -- default: horizontal
---@field justifyContent JustifyContent -- default: start
---@field alignItems AlignItems -- default: start
---@field alignContent AlignContent -- default: start
---@field textSize number?
local Window = {}
Window.__index = Window

---@class WindowProps
---@field parent Window?
---@field x number?
---@field y number?
---@field z number? -- default: 0
---@field w number?
---@field h number?
---@field border Border?
---@field borderColor Color? -- default: black? -- default: none
---@field background Color?  --default: transparent
---@field gap number? -- default: 10
---@field px number? -- default: 0
---@field py number? -- default: 0
---@field text string? -- default: nil
---@field titleColor Color? -- default: black
---@field textAlign TextAlign?
---@field textColor Color? -- default: black
---@field textSize number? -- default: nil
---@field positioning Positioning? -- default: ABSOLUTE
---@field flexDirection FlexDirection? -- default: HORIZONTAL
---@field justifyContent JustifyContent? -- default: FLEX_START
---@field alignItems AlignItems? -- default: STRETCH
---@field alignContent AlignContent? -- default: STRETCH
local WindowProps = {}

---@param props WindowProps
---@return Window
function Window.new(props)
  local self = setmetatable({}, Window)
  self.x = props.x or 0
  self.y = props.y or 0
  if props.w == nil and props.h == nil then
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
  self.px = props.px or 0
  self.py = props.py or 0
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
  end

  local gw, gh = love.window.getMode()
  self.prevGameSize = { width = gw, height = gh }

  self.z = props.z or 0

  if not props.parent then
    table.insert(Gui.topWindows, self)
  end
  return self
end

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
      child.x = currentPos
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
      currentPos = currentPos + (child.width or 0) + self.gap
    else
      child.y = currentPos
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

      currentPos = currentPos + (child.height or 0) + self.gap
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
  love.graphics.setColor(self.background:toRGBA())
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  -- Draw borders based on border property
  love.graphics.setColor(self.borderColor:toRGBA())
  if self.border.top then
    love.graphics.line(self.x, self.y, self.x + self.width, self.y)
  end
  if self.border.bottom then
    love.graphics.line(self.x, self.y + self.height, self.x + self.width, self.y + self.height)
  end
  if self.border.left then
    love.graphics.line(self.x, self.y, self.x, self.y + self.height)
  end
  if self.border.right then
    love.graphics.line(self.x + self.width, self.y, self.x + self.width, self.y + self.height)
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
      self.width = anim.width
      self.height = anim.height
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

--- Calculate auto width based on children
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
    local childWidth = child.width or 0
    local childX = child.x or 0
    local paddingAdjustment = child.px * 2
    local totalWidth = childX + childWidth + paddingAdjustment

    if totalWidth > maxWidth then
      maxWidth = totalWidth
    end
  end

  self.width = maxWidth
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
    local childHeight = child.height or 0
    local childY = child.y or 0
    local paddingAdjustment = child.py * 2
    local totalHeight = childY + childHeight + paddingAdjustment

    if totalHeight > maxHeight then
      maxHeight = totalHeight
    end
  end

  self.height = maxHeight
end

--- Update window size to fit children automatically
function Window:updateAutoSize()
  -- Store current dimensions for comparison
  local oldWidth, oldHeight = self.width, self.height
  if self.width == 0 then
    self.width = self:calculateAutoWidth()
  end
  if self.height == 0 then
    self.height = self:calculateAutoHeight()
  end
  -- Only re-layout children if dimensions changed
  if oldWidth ~= self.width or oldHeight ~= self.height then
    self:layoutChildren()
  end
end

---@class Button
---@field x number
---@field y number
---@field z number -- default: 0
---@field width number
---@field height number
---@field px number
---@field py number
---@field text string?
---@field border Border
---@field borderColor Color?
---@field background Color
---@field parent Window
---@field callback function
---@field textColor Color?
---@field _touchPressed boolean
---@field positioning Positioning --default: ABSOLUTE (checks parent first)
---@field textSize number?
local Button = {}
Button.__index = Button

---@class ButtonProps
---@field parent Window? -- optional
---@field x number?
---@field y number?
---@field z number?
---@field w number?
---@field h number?
---@field px number?
---@field py number?
---@field text string?
---@field callback function?
---@field background Color?
---@field border Border?
---@field borderColor Color? -- default: black
---@field textColor Color? -- default: black,
---@field textSize number? -- default: nil
---@field positioning Positioning? --default: ABSOLUTE (checks parent first)
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
  self.px = props.px or 0
  self.py = props.py or 0
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

  self.z = props.z or 0

  self.callback = props.callback or function() end
  self._pressed = false
  self._touchPressed = false

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
end

---@param newText string
---@param autoresize boolean? --default: false
function Button:updateText(newText, autoresize)
  self.text = newText or self.text
  if autoresize then
    self.width = self:calculateTextWidth() + self.px
    self.height = self:calculateTextHeight() + self.py
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

--- Check if mouse is over button and handle click
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
return { GUI = Gui, Color = Color, enums = enums }
