--[[
FlexLove - UI Library for LÖVE Framework 'based' on flexbox
VERSION: 1.0.0
LICENSE: MIT
For full documentation, see README.md
]]

-- ====================
-- Module Imports (using relative paths)
-- ====================
local modulePath = (...):match("(.-)[^%.]+$") -- Get the module path prefix (e.g., "libs." or "")
local function req(name)
  return require(modulePath .. name)
end

local Blur = req("modules.Blur")
local Color = req("modules.Color")
local ImageDataReader = req("modules.ImageDataReader")
local NinePatchParser = req("modules.NinePatchParser")
local ImageScaler = req("modules.ImageScaler")
local ImageCache = req("modules.ImageCache")
local ImageRenderer = req("modules.ImageRenderer")
local Theme = req("modules.Theme")
local RoundedRect = req("modules.RoundedRect")
local NineSlice = req("modules.NineSlice")
local utils = req("modules.utils")
local Units = req("modules.Units")
local Animation = req("modules.Animation")
local GuiState = req("modules.GuiState")
local Grid = req("modules.Grid")
local InputEvent = req("modules.InputEvent")
local Element = req("modules.Element")

-- Extract from utils
local enums = utils.enums

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
-- Top level GUI manager
-- ====================

---@class Gui
local Gui = GuiState

--- Initialize FlexLove with configuration
---@param config {baseScale?: {width?:number, height?:number}, theme?: string|ThemeDefinition}
function Gui.init(config)
  if config.baseScale then
    Gui.baseScale = {
      width = config.baseScale.width or 1920,
      height = config.baseScale.height or 1080,
    }

    local currentWidth, currentHeight = Units.getViewport()
    Gui.scaleFactors.x = currentWidth / Gui.baseScale.width
    Gui.scaleFactors.y = currentHeight / Gui.baseScale.height
  end

  if config.theme then
    local success, err = pcall(function()
      if type(config.theme) == "string" then
        Theme.load(config.theme)
        Theme.setActive(config.theme)
        Gui.defaultTheme = config.theme
      elseif type(config.theme) == "table" then
        local theme = Theme.new(config.theme)
        Theme.setActive(theme)
        Gui.defaultTheme = theme.name
      end
    end)

    if not success then
      print("[FlexLove] Failed to load theme: " .. tostring(err))
    end
  end
end

function Gui.resize()
  local newWidth, newHeight = love.window.getMode()

  if Gui.baseScale then
    Gui.scaleFactors.x = newWidth / Gui.baseScale.width
    Gui.scaleFactors.y = newHeight / Gui.baseScale.height
  end

  Blur.clearCache()

  Gui._gameCanvas = nil
  Gui._backdropCanvas = nil
  Gui._canvasDimensions = { width = 0, height = 0 }

  for _, win in ipairs(Gui.topElements) do
    win:resize(newWidth, newHeight)
  end
end

-- Canvas cache for game rendering
Gui._gameCanvas = nil
Gui._backdropCanvas = nil
Gui._canvasDimensions = { width = 0, height = 0 }

---@param gameDrawFunc function|nil
---@param postDrawFunc function|nil
function Gui.draw(gameDrawFunc, postDrawFunc)
  local outerCanvas = love.graphics.getCanvas()
  local gameCanvas = nil

  if type(gameDrawFunc) == "function" then
    local width, height = love.graphics.getDimensions()

    if not Gui._gameCanvas or Gui._canvasDimensions.width ~= width or Gui._canvasDimensions.height ~= height then
      Gui._gameCanvas = love.graphics.newCanvas(width, height)
      Gui._backdropCanvas = love.graphics.newCanvas(width, height)
      Gui._canvasDimensions.width = width
      Gui._canvasDimensions.height = height
    end

    gameCanvas = Gui._gameCanvas

    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()
    gameDrawFunc()
    love.graphics.setCanvas(outerCanvas)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, 0, 0)
  end

  table.sort(Gui.topElements, function(a, b)
    return a.z < b.z
  end)

  local function hasBackdropBlur(element)
    if element.backdropBlur and element.backdropBlur.intensity > 0 then
      return true
    end
    for _, child in ipairs(element.children) do
      if hasBackdropBlur(child) then
        return true
      end
    end
    return false
  end

  local needsBackdropCanvas = false
  for _, win in ipairs(Gui.topElements) do
    if hasBackdropBlur(win) then
      needsBackdropCanvas = true
      break
    end
  end

  if needsBackdropCanvas and gameCanvas then
    local backdropCanvas = Gui._backdropCanvas
    local prevColor = { love.graphics.getColor() }

    love.graphics.setCanvas(backdropCanvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, 0, 0)

    love.graphics.setCanvas(outerCanvas)
    love.graphics.setColor(unpack(prevColor))

    for _, win in ipairs(Gui.topElements) do
      win:draw(backdropCanvas)

      love.graphics.setCanvas(backdropCanvas)
      love.graphics.setColor(1, 1, 1, 1)
      win:draw(nil)
      love.graphics.setCanvas(outerCanvas)
    end
  else
    for _, win in ipairs(Gui.topElements) do
      win:draw(nil)
    end
  end

  if type(postDrawFunc) == "function" then
    postDrawFunc()
  end

  love.graphics.setCanvas(outerCanvas)
end

--- Check if element is an ancestor of target
---@param element Element
---@param target Element
---@return boolean
local function isAncestor(element, target)
  local current = target.parent
  while current do
    if current == element then
      return true
    end
    current = current.parent
  end
  return false
end

--- Find the topmost element at given coordinates
---@param x number
---@param y number
---@return Element?
function Gui.getElementAtPosition(x, y)
  local candidates = {}
  local blockingElements = {}

  local function collectHits(element, scrollOffsetX, scrollOffsetY)
    scrollOffsetX = scrollOffsetX or 0
    scrollOffsetY = scrollOffsetY or 0

    local bx = element.x
    local by = element.y
    local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
    local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)

    -- Adjust mouse position by accumulated scroll offset for hit testing
    local adjustedX = x + scrollOffsetX
    local adjustedY = y + scrollOffsetY

    if adjustedX >= bx and adjustedX <= bx + bw and adjustedY >= by and adjustedY <= by + bh then
      -- Collect interactive elements (those with callbacks)
      if element.callback and not element.disabled then
        table.insert(candidates, element)
      end

      -- Collect all visible elements for input blocking
      -- Elements with opacity > 0 block input to elements below them
      if element.opacity > 0 then
        table.insert(blockingElements, element)
      end

      -- Check if this element has scrollable overflow
      local overflowX = element.overflowX or element.overflow
      local overflowY = element.overflowY or element.overflow
      local hasScrollableOverflow = (overflowX == "scroll" or overflowX == "auto" or overflowY == "scroll" or overflowY == "auto" or
                                     overflowX == "hidden" or overflowY == "hidden")

      -- Accumulate scroll offset for children if this element has overflow clipping
      local childScrollOffsetX = scrollOffsetX
      local childScrollOffsetY = scrollOffsetY
      if hasScrollableOverflow then
        childScrollOffsetX = childScrollOffsetX + (element._scrollX or 0)
        childScrollOffsetY = childScrollOffsetY + (element._scrollY or 0)
      end

      for _, child in ipairs(element.children) do
        collectHits(child, childScrollOffsetX, childScrollOffsetY)
      end
    end
  end

  for _, element in ipairs(Gui.topElements) do
    collectHits(element)
  end

  -- Sort both lists by z-index (highest first)
  table.sort(candidates, function(a, b)
    return a.z > b.z
  end)

  table.sort(blockingElements, function(a, b)
    return a.z > b.z
  end)

  -- If we have interactive elements, return the topmost one
  -- But only if there's no blocking element with higher z-index (that isn't an ancestor)
  if #candidates > 0 then
    local topCandidate = candidates[1]

    -- Check if any blocking element would prevent this interaction
    if #blockingElements > 0 then
      local topBlocker = blockingElements[1]
      -- If the top blocker has higher z-index than the top candidate,
      -- and the blocker is NOT an ancestor of the candidate,
      -- return the blocker (even though it has no callback, it blocks input)
      if topBlocker.z > topCandidate.z and not isAncestor(topBlocker, topCandidate) then
        return topBlocker
      end
    end

    return topCandidate
  end

  -- No interactive elements, but return topmost blocking element if any
  -- This prevents clicks from passing through non-interactive overlays
  return blockingElements[1]
end

function Gui.update(dt)
  local mx, my = love.mouse.getPosition()
  local topElement = Gui.getElementAtPosition(mx, my)

  Gui._activeEventElement = topElement

  for _, win in ipairs(Gui.topElements) do
    win:update(dt)
  end

  Gui._activeEventElement = nil
end

--- Forward text input to focused element
---@param text string
function Gui.textinput(text)
  if Gui._focusedElement then
    Gui._focusedElement:textinput(text)
  end
end

--- Forward key press to focused element
---@param key string
---@param scancode string
---@param isrepeat boolean
function Gui.keypressed(key, scancode, isrepeat)
  if Gui._focusedElement then
    Gui._focusedElement:keypressed(key, scancode, isrepeat)
  end
end

--- Handle mouse wheel scrolling
function Gui.wheelmoved(x, y)
  local mx, my = love.mouse.getPosition()

  local function findScrollableAtPosition(elements, mx, my)
    for i = #elements, 1, -1 do
      local element = elements[i]

      local bx = element.x
      local by = element.y
      local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
      local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)

      if mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
        if #element.children > 0 then
          local childResult = findScrollableAtPosition(element.children, mx, my)
          if childResult then
            return childResult
          end
        end

        local overflowX = element.overflowX or element.overflow
        local overflowY = element.overflowY or element.overflow
        if (overflowX == "scroll" or overflowX == "auto" or overflowY == "scroll" or overflowY == "auto") and (element._overflowX or element._overflowY) then
          return element
        end
      end
    end

    return nil
  end

  local scrollableElement = findScrollableAtPosition(Gui.topElements, mx, my)
  if scrollableElement then
    scrollableElement:_handleWheelScroll(x, y)
  end
end

--- Destroy all elements and their children
function Gui.destroy()
  for _, win in ipairs(Gui.topElements) do
    win:destroy()
  end
  Gui.topElements = {}
  Gui.baseScale = nil
  Gui.scaleFactors = { x = 1.0, y = 1.0 }
  Gui._cachedViewport = { width = 0, height = 0 }
  Gui._gameCanvas = nil
  Gui._backdropCanvas = nil
  Gui._canvasDimensions = { width = 0, height = 0 }
  Gui._focusedElement = nil
end

Gui.new = Element.new
Gui.Element = Element
Gui.Animation = Animation
Gui.Theme = Theme
Gui.ImageDataReader = ImageDataReader
Gui.NinePatchParser = NinePatchParser

return {
  -- Core
  Gui = Gui,
  GUI = Gui, -- Backward compatibility alias
  Element = Element,

  -- Submodules (exposed for direct access)
  Blur = Blur,
  Color = Color,
  ImageDataReader = ImageDataReader,
  NinePatchParser = NinePatchParser,
  ImageScaler = ImageScaler,
  ImageCache = ImageCache,
  ImageRenderer = ImageRenderer,
  Theme = Theme,
  RoundedRect = RoundedRect,
  NineSlice = NineSlice,
  Grid = Grid,
  InputEvent = InputEvent,

  -- Enums (individual)
  Positioning = Positioning,
  FlexDirection = FlexDirection,
  JustifyContent = JustifyContent,
  AlignContent = AlignContent,
  AlignItems = AlignItems,
  TextAlign = TextAlign,
  AlignSelf = AlignSelf,
  JustifySelf = JustifySelf,
  FlexWrap = FlexWrap,

  -- Enums (backward compatibility - grouped)
  enums = enums,
}
