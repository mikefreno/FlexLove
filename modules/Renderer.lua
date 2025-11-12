--[[
Renderer.lua - Rendering module for FlexLove Element
Handles all visual rendering including backgrounds, borders, images, themes, and effects
]]

-- Setup module path for relative requires
local modulePath = (...):match("(.-)[^%.]+$")
local function req(name)
  return require(modulePath .. name)
end

-- Module dependencies
local Color = req("Color")
local RoundedRect = req("RoundedRect")
local NinePatch = req("NinePatch")
local ImageRenderer = req("ImageRenderer")
local Blur = req("Blur")
local Theme = req("Theme")
local utils = req("utils")

-- Extract utilities
local FONT_CACHE = utils.FONT_CACHE

-- ====================
-- Renderer Class
-- ====================

---@class Renderer
---@field element Element -- Reference to parent element
---@field backgroundColor Color -- Background color
---@field borderColor Color -- Border color
---@field opacity number -- Opacity (0-1)
---@field border {top:boolean, right:boolean, bottom:boolean, left:boolean} -- Border sides
---@field cornerRadius {topLeft:number, topRight:number, bottomLeft:number, bottomRight:number} -- Corner radii
---@field theme string? -- Theme name
---@field themeComponent string? -- Theme component name
---@field _themeState string -- Current theme state (normal, hover, pressed, active, disabled)
---@field imagePath string? -- Path to image file
---@field image love.Image? -- Image object
---@field _loadedImage love.Image? -- Cached loaded image
---@field objectFit string -- Image fit mode
---@field objectPosition string -- Image position
---@field imageOpacity number -- Image opacity
---@field contentBlur table? -- Content blur settings
---@field backdropBlur table? -- Backdrop blur settings
---@field _blurInstance table? -- Cached blur instance
---@field scaleCorners number? -- 9-patch corner scale multiplier
---@field scalingAlgorithm string? -- 9-patch scaling algorithm
---@field disableHighlight boolean -- Disable pressed state highlight
local Renderer = {}
Renderer.__index = Renderer

--- Create a new Renderer instance
---@param config table -- Configuration options
---@return Renderer
function Renderer.new(config)
  local self = setmetatable({}, Renderer)
  
  -- Initialize rendering state
  self.backgroundColor = config.backgroundColor or Color.new(0, 0, 0, 0)
  self.borderColor = config.borderColor or Color.new(0, 0, 0, 1)
  self.opacity = config.opacity or 1
  
  -- Border configuration
  self.border = config.border or {
    top = false,
    right = false,
    bottom = false,
    left = false,
  }
  
  -- Corner radius configuration
  self.cornerRadius = config.cornerRadius or {
    topLeft = 0,
    topRight = 0,
    bottomLeft = 0,
    bottomRight = 0,
  }
  
  -- Theme configuration
  self.theme = config.theme
  self.themeComponent = config.themeComponent
  self._themeState = config._themeState or "normal"
  
  -- Image configuration
  self.imagePath = config.imagePath
  self.image = config.image
  self._loadedImage = config._loadedImage
  self.objectFit = config.objectFit or "fill"
  self.objectPosition = config.objectPosition or "center center"
  self.imageOpacity = config.imageOpacity or 1
  
  -- Blur configuration
  self.contentBlur = config.contentBlur
  self.backdropBlur = config.backdropBlur
  self._blurInstance = config._blurInstance
  
  -- 9-patch configuration
  self.scaleCorners = config.scaleCorners
  self.scalingAlgorithm = config.scalingAlgorithm
  
  -- Visual feedback configuration
  self.disableHighlight = config.disableHighlight or false
  
  -- Element reference (set via initialize)
  self.element = nil
  
  return self
end

--- Initialize renderer with parent element reference
---@param element Element
function Renderer:initialize(element)
  self.element = element
end

--- Main draw method - orchestrates all rendering
---@param backdropCanvas love.Canvas? -- Canvas for backdrop blur
function Renderer:draw(backdropCanvas)
  -- Early exit if element is invisible (optimization)
  if self.opacity <= 0 then
    return
  end
  
  -- Get element reference for convenience
  local element = self.element
  if not element then
    return
  end
  
  -- Handle opacity during animation
  local drawBackgroundColor = self.backgroundColor
  if element.animation then
    local anim = element.animation:interpolate()
    if anim.opacity then
      drawBackgroundColor = Color.new(self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b, anim.opacity)
    end
  end
  
  -- Cache border box dimensions for this draw call (optimization)
  local borderBoxWidth = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
  local borderBoxHeight = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)
  
  -- LAYER 0.5: Draw backdrop blur if configured (before background)
  if self.backdropBlur and self.backdropBlur.intensity > 0 and backdropCanvas then
    local blurInstance = element:getBlurInstance()
    if blurInstance then
      Blur.applyBackdrop(blurInstance, self.backdropBlur.intensity, element.x, element.y, borderBoxWidth, borderBoxHeight, backdropCanvas)
    end
  end
  
  -- LAYER 1: Draw backgroundColor first (behind everything)
  self:drawBackground(element.x, element.y, borderBoxWidth, borderBoxHeight, drawBackgroundColor)
  
  -- LAYER 1.5: Draw image on top of backgroundColor (if image exists)
  if self._loadedImage then
    self:drawImage(element.x, element.y, borderBoxWidth, borderBoxHeight)
  end
  
  -- LAYER 2: Draw theme on top of backgroundColor (if theme exists)
  if self.themeComponent then
    self:drawTheme(element.x, element.y, borderBoxWidth, borderBoxHeight)
  end
  
  -- LAYER 3: Draw borders on top of theme (always render if specified)
  self:drawBorder(element.x, element.y, borderBoxWidth, borderBoxHeight)
end

--- Draw background with corner radius
---@param x number
---@param y number
---@param width number
---@param height number
---@param drawBackgroundColor Color? -- Optional override for background color
function Renderer:drawBackground(x, y, width, height, drawBackgroundColor)
  drawBackgroundColor = drawBackgroundColor or self.backgroundColor
  
  -- Apply opacity to background color
  local backgroundWithOpacity = Color.new(
    drawBackgroundColor.r,
    drawBackgroundColor.g,
    drawBackgroundColor.b,
    drawBackgroundColor.a * self.opacity
  )
  
  love.graphics.setColor(backgroundWithOpacity:toRGBA())
  RoundedRect.draw("fill", x, y, width, height, self.cornerRadius)
end

--- Draw image with object-fit modes
---@param x number
---@param y number
---@param borderBoxWidth number
---@param borderBoxHeight number
function Renderer:drawImage(x, y, borderBoxWidth, borderBoxHeight)
  if not self._loadedImage or not self.element then
    return
  end
  
  local element = self.element
  
  -- Calculate image bounds (content area - respects padding)
  local imageX = x + element.padding.left
  local imageY = y + element.padding.top
  local imageWidth = element.width
  local imageHeight = element.height
  
  -- Combine element opacity with imageOpacity
  local finalOpacity = self.opacity * self.imageOpacity
  
  -- Apply cornerRadius clipping if set
  local hasCornerRadius = self.cornerRadius.topLeft > 0
    or self.cornerRadius.topRight > 0
    or self.cornerRadius.bottomLeft > 0
    or self.cornerRadius.bottomRight > 0
  
  if hasCornerRadius then
    -- Use stencil to clip image to rounded corners
    love.graphics.stencil(function()
      RoundedRect.draw("fill", x, y, borderBoxWidth, borderBoxHeight, self.cornerRadius)
    end, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
  end
  
  -- Draw the image
  ImageRenderer.draw(self._loadedImage, imageX, imageY, imageWidth, imageHeight, self.objectFit, self.objectPosition, finalOpacity)
  
  -- Clear stencil if it was used
  if hasCornerRadius then
    love.graphics.setStencilTest()
  end
end

--- Draw theme component using 9-patch rendering
---@param x number
---@param y number
---@param borderBoxWidth number
---@param borderBoxHeight number
function Renderer:drawTheme(x, y, borderBoxWidth, borderBoxHeight)
  if not self.themeComponent or not self.element then
    return
  end
  
  -- Get the theme to use
  local themeToUse = nil
  if self.theme then
    -- Element specifies a specific theme - load it if needed
    if Theme.get(self.theme) then
      themeToUse = Theme.get(self.theme)
    else
      -- Try to load the theme
      pcall(function()
        Theme.load(self.theme)
      end)
      themeToUse = Theme.get(self.theme)
    end
  else
    -- Use active theme
    themeToUse = Theme.getActive()
  end
  
  if not themeToUse then
    return
  end
  
  -- Get the component from the theme
  local component = themeToUse.components[self.themeComponent]
  if not component then
    return
  end
  
  -- Check for state-specific override
  local state = self._themeState
  if state and component.states and component.states[state] then
    component = component.states[state]
  end
  
  -- Use component-specific atlas if available, otherwise use theme atlas
  local atlasToUse = component._loadedAtlas or themeToUse.atlas
  
  if not atlasToUse or not component.regions then
    return
  end
  
  -- Validate component has required structure
  local hasAllRegions = component.regions.topLeft
    and component.regions.topCenter
    and component.regions.topRight
    and component.regions.middleLeft
    and component.regions.middleCenter
    and component.regions.middleRight
    and component.regions.bottomLeft
    and component.regions.bottomCenter
    and component.regions.bottomRight
  
  if not hasAllRegions then
    return
  end
  
  -- Pass element-level overrides for scaleCorners and scalingAlgorithm
  NinePatch.draw(component, atlasToUse, x, y, borderBoxWidth, borderBoxHeight, self.opacity, self.scaleCorners, self.scalingAlgorithm)
end

--- Draw borders on specified sides
---@param x number
---@param y number
---@param width number
---@param height number
function Renderer:drawBorder(x, y, width, height)
  -- Apply opacity to border color
  local borderColorWithOpacity = Color.new(
    self.borderColor.r,
    self.borderColor.g,
    self.borderColor.b,
    self.borderColor.a * self.opacity
  )
  
  love.graphics.setColor(borderColorWithOpacity:toRGBA())
  
  -- Check if all borders are enabled
  local allBorders = self.border.top and self.border.bottom and self.border.left and self.border.right
  
  if allBorders then
    -- Draw complete rounded rectangle border
    RoundedRect.draw("line", x, y, width, height, self.cornerRadius)
  else
    -- Draw individual borders (without rounded corners for partial borders)
    if self.border.top then
      love.graphics.line(x, y, x + width, y)
    end
    if self.border.bottom then
      love.graphics.line(x, y + height, x + width, y + height)
    end
    if self.border.left then
      love.graphics.line(x, y, x, y + height)
    end
    if self.border.right then
      love.graphics.line(x + width, y, x + width, y + height)
    end
  end
end

--- Draw pressed state highlight overlay
---@param x number
---@param y number
---@param width number
---@param height number
function Renderer:drawPressedHighlight(x, y, width, height)
  if self.disableHighlight or not self.element then
    return
  end
  
  local element = self.element
  
  -- Check if element has onEvent handler
  if not element.onEvent then
    return
  end
  
  -- Check if any button is pressed
  local anyPressed = false
  for _, pressed in pairs(element._pressed) do
    if pressed then
      anyPressed = true
      break
    end
  end
  
  if anyPressed then
    love.graphics.setColor(0.5, 0.5, 0.5, 0.3 * self.opacity) -- Semi-transparent gray for pressed state with opacity
    RoundedRect.draw("fill", x, y, width, height, self.cornerRadius)
  end
end

--- Set background color
---@param color Color
function Renderer:setBackgroundColor(color)
  self.backgroundColor = color
end

--- Set border color
---@param color Color
function Renderer:setBorderColor(color)
  self.borderColor = color
end

--- Set opacity
---@param opacity number
function Renderer:setOpacity(opacity)
  self.opacity = opacity
end

--- Set theme state
---@param state string
function Renderer:setThemeState(state)
  self._themeState = state
end

--- Set loaded image
---@param image love.Image?
function Renderer:setLoadedImage(image)
  self._loadedImage = image
end

--- Get blur instance (delegates to element)
---@return table?
function Renderer:getBlurInstance()
  if not self.element then
    return nil
  end
  return self.element:getBlurInstance()
end

--- Update renderer state from element
--- Call this when element properties change
function Renderer:syncFromElement()
  if not self.element then
    return
  end
  
  local element = self.element
  
  -- Sync rendering properties
  self.backgroundColor = element.backgroundColor
  self.borderColor = element.borderColor
  self.opacity = element.opacity
  self.border = element.border
  self.cornerRadius = element.cornerRadius
  self.theme = element.theme
  self.themeComponent = element.themeComponent
  self._themeState = element._themeState
  self.imagePath = element.imagePath
  self.image = element.image
  self._loadedImage = element._loadedImage
  self.objectFit = element.objectFit
  self.objectPosition = element.objectPosition
  self.imageOpacity = element.imageOpacity
  self.contentBlur = element.contentBlur
  self.backdropBlur = element.backdropBlur
  self._blurInstance = element._blurInstance
  self.scaleCorners = element.scaleCorners
  self.scalingAlgorithm = element.scalingAlgorithm
  self.disableHighlight = element.disableHighlight
end

--- Update element state from renderer
--- Call this when renderer properties change
function Renderer:syncToElement()
  if not self.element then
    return
  end
  
  local element = self.element
  
  -- Sync rendering properties back to element
  element.backgroundColor = self.backgroundColor
  element.borderColor = self.borderColor
  element.opacity = self.opacity
  element.border = self.border
  element.cornerRadius = self.cornerRadius
  element.theme = self.theme
  element.themeComponent = self.themeComponent
  element._themeState = self._themeState
  element.imagePath = self.imagePath
  element.image = self.image
  element._loadedImage = self._loadedImage
  element.objectFit = self.objectFit
  element.objectPosition = self.objectPosition
  element.imageOpacity = self.imageOpacity
  element.contentBlur = self.contentBlur
  element.backdropBlur = self.backdropBlur
  element._blurInstance = self._blurInstance
  element.scaleCorners = self.scaleCorners
  element.scalingAlgorithm = self.scalingAlgorithm
  element.disableHighlight = self.disableHighlight
end

return Renderer
