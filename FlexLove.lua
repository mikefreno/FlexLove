--[[
FlexLove - UI Library for LÖVE Framework 'based' on flexbox
VERSION: 1.0.0
LICENSE: MIT
For full documentation, see README.md
]]

-- ====================
-- Module Imports
-- ====================
local Blur = require("flexlove.Blur")
local Color = require("flexlove.Color")
local ImageDataReader = require("flexlove.ImageDataReader")
local NinePatchParser = require("flexlove.NinePatchParser")
local ImageScaler = require("flexlove.ImageScaler")
local ImageCache = require("flexlove.ImageCache")
local ImageRenderer = require("flexlove.ImageRenderer")
local Theme = require("flexlove.Theme")
local RoundedRect = require("flexlove.RoundedRect")
local NineSlice = require("flexlove.NineSlice")
local enums = require("flexlove.types")
local constants = require("flexlove.constants")

-- ====================
-- Error Handling Utilities
-- ====================

--- Standardized error message formatter
---@param module string -- Module name (e.g., "Color", "Theme", "Units")
---@param message string -- Error message
---@return string -- Formatted error message
local function formatError(module, message)
  return string.format("[FlexLove.%s] %s", module, message)
end

-- ====================
-- Top level GUI manager
-- ====================

---
---@class Gui
---@field topElements table<integer, Element>
---@field baseScale {width:number, height:number}?
---@field scaleFactors {x:number, y:number}
---@field defaultTheme string? -- Default theme name to use for elements
local Gui = {
  topElements = {},
  baseScale = nil,
  scaleFactors = { x = 1.0, y = 1.0 },
  defaultTheme = nil,
  _cachedViewport = { width = 0, height = 0 }, -- Cached viewport dimensions
  _focusedElement = nil, -- Currently focused element for keyboard input
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
-- Grid System
-- ====================

--- Simple grid layout calculations
local Grid = {}

--- Layout grid items within a grid container using simple row/column counts
---@param element Element -- Grid container element
function Grid.layoutGridItems(element)
  local rows = element.gridRows or 1
  local columns = element.gridColumns or 1

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

    -- Calculate cell position (accounting for reserved space)
    local cellX = element.x + element.padding.left + reservedLeft + (col * (cellWidth + columnGap))
    local cellY = element.y + element.padding.top + reservedTop + (row * (cellHeight + rowGap))

    -- Apply alignment within grid cell (default to stretch)
    local effectiveAlignItems = element.alignItems or AlignItems.STRETCH

    -- Stretch child to fill cell by default
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
      -- Default to stretch
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

    -- Layout child's children if it has any
    if #child.children > 0 then
      child:layoutChildren()
    end
  end
end

--- Initialize FlexLove with configuration
---@param config {baseScale?: {width?:number, height?:number}, theme?: string|ThemeDefinition} --Default: {width: 1920, height: 1080}
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

  -- Load and set theme if specified
  if config.theme then
    local success, err = pcall(function()
      if type(config.theme) == "string" then
        -- Load theme by name
        Theme.load(config.theme)
        Theme.setActive(config.theme)
        Gui.defaultTheme = config.theme
      elseif type(config.theme) == "table" then
        -- Load theme from definition
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

--- Check for Z-index coverage (occlusion)
---@param elem Element
---@param clickX number
---@param clickY number
---@return boolean
function Gui.isOccluded(elem, clickX, clickY)
  for _, element in ipairs(Gui.topElements) do
    if element.z > elem.z and element:contains(clickX, clickY) then
      return true
    end
    --TODO: check if walking the children tree is necessary here - might only need to check for absolute positioned
    --children
    for _, child in ipairs(element.children) do
      if child.positioning == "absolute" then
        if child.z > elem.z and child:contains(clickX, clickY) then
          return true
        end
      end
    end
  end
  return false
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

  -- Clear scaled region caches for all themes
  for _, theme in pairs(themes) do
    if theme.components then
      for _, component in pairs(theme.components) do
        if component._scaledRegionCache then
          component._scaledRegionCache = {}
        end
      end
    end
  end

  -- Clear blur canvas cache on resize
  Blur.clearCache()

  -- Clear game/backdrop canvas cache on resize (will be recreated with new dimensions)
  Gui._gameCanvas = nil
  Gui._backdropCanvas = nil
  Gui._canvasDimensions = { width = 0, height = 0 }

  for _, win in ipairs(Gui.topElements) do
    win:resize(newWidth, newHeight)
  end
end

-- Canvas cache for game rendering (reused across frames)
Gui._gameCanvas = nil
Gui._backdropCanvas = nil
Gui._canvasDimensions = { width = 0, height = 0 }

---@param gameDrawFunc function|nil -- Function to draw game content, needed for backdrop blur
---@param postDrawFunc function|nil -- Optional function to draw after GUI (for top-level shaders/effects)
---function love.draw()
---  FlexLove.Gui.draw(function()
---    --Game rendering logic
---    RenderSystem:update()
---  end, function()
---    -- Layers on top of GUI - blurs will not extend to this
---    overlayStats.draw()
---  end)
---end
function Gui.draw(gameDrawFunc, postDrawFunc)
  -- Save the current canvas state to support nested rendering
  local outerCanvas = love.graphics.getCanvas()

  local gameCanvas = nil

  -- Render game content to a canvas if function provided
  if type(gameDrawFunc) == "function" then
    local width, height = love.graphics.getDimensions()

    -- Recreate canvases only if dimensions changed or canvas doesn't exist
    if not Gui._gameCanvas or Gui._canvasDimensions.width ~= width or Gui._canvasDimensions.height ~= height then
      Gui._gameCanvas = love.graphics.newCanvas(width, height)
      Gui._backdropCanvas = love.graphics.newCanvas(width, height)
      Gui._canvasDimensions.width = width
      Gui._canvasDimensions.height = height
    end

    gameCanvas = Gui._gameCanvas

    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()
    gameDrawFunc() -- Call the drawing function
    love.graphics.setCanvas(outerCanvas)

    -- Draw game canvas to the outer canvas (or screen if none)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, 0, 0)
  end

  -- Sort elements by z-index before drawing
  table.sort(Gui.topElements, function(a, b)
    return a.z < b.z
  end)

  -- Check if any element (recursively) needs backdrop blur
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

  -- If backdrop blur is needed, render to a progressive canvas
  if needsBackdropCanvas and gameCanvas then
    local backdropCanvas = Gui._backdropCanvas
    local prevColor = { love.graphics.getColor() }

    -- Initialize backdrop canvas with game content
    love.graphics.setCanvas(backdropCanvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, 0, 0)

    -- Reset to outer canvas (screen or parent canvas)
    love.graphics.setCanvas(outerCanvas)
    love.graphics.setColor(unpack(prevColor))

    -- Draw each element, updating backdrop canvas progressively
    for _, win in ipairs(Gui.topElements) do
      -- Draw element with current backdrop state to outer canvas
      win:draw(backdropCanvas)

      -- Update backdrop canvas to include this element (for next elements)
      love.graphics.setCanvas(backdropCanvas)
      love.graphics.setColor(1, 1, 1, 1)
      win:draw(nil) -- Draw without backdrop blur to the backdrop canvas
      love.graphics.setCanvas(outerCanvas) -- Reset to outer canvas
    end
  else
    -- No backdrop blur needed, draw normally
    for _, win in ipairs(Gui.topElements) do
      win:draw(nil)
    end
  end

  -- Call post-draw function if provided (for top-level shaders/effects)
  if type(postDrawFunc) == "function" then
    postDrawFunc()
  end

  -- Restore the original canvas state
  love.graphics.setCanvas(outerCanvas)
end

--- Find the topmost element at given coordinates (considering z-index)
---@param x number
---@param y number
---@return Element? -- Returns the topmost element or nil
function Gui.getElementAtPosition(x, y)
  local candidates = {}

  -- Recursively collect all elements that contain the point
  local function collectHits(element)
    -- Check if point is within element bounds
    local bx = element.x
    local by = element.y
    local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
    local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)

    if x >= bx and x <= bx + bw and y >= by and y <= by + bh then
      -- Only consider elements with callbacks (interactive elements)
      if element.callback and not element.disabled then
        table.insert(candidates, element)
      end

      -- Check children
      for _, child in ipairs(element.children) do
        collectHits(child)
      end
    end
  end

  -- Collect hits from all top-level elements
  for _, element in ipairs(Gui.topElements) do
    collectHits(element)
  end

  -- Sort by z-index (highest first)
  table.sort(candidates, function(a, b)
    return a.z > b.z
  end)

  -- Return the topmost element (highest z-index)
  return candidates[1]
end

function Gui.update(dt)
  -- Reset event handling flags for new frame
  local mx, my = love.mouse.getPosition()
  local topElement = Gui.getElementAtPosition(mx, my)

  -- Mark which element should handle events this frame
  Gui._activeEventElement = topElement

  -- Update all elements
  for _, win in ipairs(Gui.topElements) do
    win:update(dt)
  end

  -- Clear active element for next frame
  Gui._activeEventElement = nil
end

--- Forward text input to focused element
---@param text string -- Character input
function Gui.textinput(text)
  if Gui._focusedElement then
    Gui._focusedElement:textinput(text)
  end
end

--- Forward key press to focused element
---@param key string -- Key name
---@param scancode string -- Scancode
---@param isrepeat boolean -- Whether this is a key repeat
function Gui.keypressed(key, scancode, isrepeat)
  if Gui._focusedElement then
    Gui._focusedElement:keypressed(key, scancode, isrepeat)
  end
end

--- Handle mouse wheel scrolling
function Gui.wheelmoved(x, y)
  -- Get mouse position
  local mx, my = love.mouse.getPosition()

  -- Find the deepest scrollable element at mouse position
  local function findScrollableAtPosition(elements, mx, my)
    -- Check in reverse z-order (top to bottom)
    for i = #elements, 1, -1 do
      local element = elements[i]

      -- Check if mouse is over element
      local bx = element.x
      local by = element.y
      local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
      local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)

      if mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
        -- Check children first (depth-first)
        if #element.children > 0 then
          local childResult = findScrollableAtPosition(element.children, mx, my)
          if childResult then
            return childResult
          end
        end

        -- Check if this element is scrollable
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
  -- Reset base scale and scale factors
  Gui.baseScale = nil
  Gui.scaleFactors = { x = 1.0, y = 1.0 }
  -- Reset cached viewport
  Gui._cachedViewport = { width = 0, height = 0 }
  -- Clear game/backdrop canvas cache
  Gui._gameCanvas = nil
  Gui._backdropCanvas = nil
  Gui._canvasDimensions = { width = 0, height = 0 }
  -- Clear focused element
  Gui._focusedElement = nil
end

-- Simple GUI library for LOVE2D
-- Provides element and button creation, drawing, and click handling.

-- ====================
-- Event System
-- ====================

---@class InputEvent
---@field type "click"|"press"|"release"|"rightclick"|"middleclick"|"drag"
---@field button number -- Mouse button: 1 (left), 2 (right), 3 (middle)
---@field x number -- Mouse X position
---@field y number -- Mouse Y position
---@field dx number? -- Delta X from drag start (only for drag events)
---@field dy number? -- Delta Y from drag start (only for drag events)
---@field modifiers {shift:boolean, ctrl:boolean, alt:boolean, super:boolean}
---@field clickCount number -- Number of clicks (for double/triple click detection)
---@field timestamp number -- Time when event occurred
local InputEvent = {}
InputEvent.__index = InputEvent

---@class InputEventProps
---@field type "click"|"press"|"release"|"rightclick"|"middleclick"|"drag"
---@field button number
---@field x number
---@field y number
---@field dx number?
---@field dy number?
---@field modifiers {shift:boolean, ctrl:boolean, alt:boolean, super:boolean}
---@field clickCount number?
---@field timestamp number?

--- Create a new input event
---@param props InputEventProps
---@return InputEvent
function InputEvent.new(props)
  local self = setmetatable({}, InputEvent)
  self.type = props.type
  self.button = props.button
  self.x = props.x
  self.y = props.y
  self.dx = props.dx
  self.dy = props.dy
  self.modifiers = props.modifiers
  self.clickCount = props.clickCount or 1
  self.timestamp = props.timestamp or love.timer.getTime()
  return self
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
