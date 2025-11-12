--[[
ThemeManager - Theme and State Management for FlexLove Elements
Extracts all theme-related functionality from Element.lua into a dedicated module.
Handles theme state management, component loading, 9-patch rendering, and property resolution.
]]

-- Setup module path for relative requires
local modulePath = (...):match("(.-)[^%.]+$")
local function req(name)
  return require(modulePath .. name)
end

-- Module dependencies
local Theme = req("Theme")
local NinePatch = req("NinePatch")
local StateManager = req("StateManager")

--- Standardized error message formatter
---@param module string -- Module name
---@param message string -- Error message
---@return string -- Formatted error message
local function formatError(module, message)
  return string.format("[FlexLove.%s] %s", module, message)
end

---@class ThemeManager
---@field theme string? -- Theme name to use
---@field themeComponent string? -- Component name from theme
---@field _themeState string -- Current theme state (normal, hover, pressed, active, disabled)
---@field disabled boolean -- Whether element is disabled
---@field active boolean -- Whether element is active/focused
---@field disableHighlight boolean -- Whether to disable pressed state highlight
---@field scaleCorners number? -- Scale multiplier for 9-patch corners
---@field scalingAlgorithm "nearest"|"bilinear"? -- Scaling algorithm for 9-patch
---@field contentAutoSizingMultiplier table? -- Multiplier for auto-sized content
---@field _element Element? -- Reference to parent element (set via initialize)
---@field _stateId string? -- State manager ID for immediate mode
local ThemeManager = {}
ThemeManager.__index = ThemeManager

--- Create a new ThemeManager instance
---@param config table -- Configuration options
---@return ThemeManager
function ThemeManager.new(config)
  local self = setmetatable({}, ThemeManager)
  
  -- Theme configuration
  self.theme = config.theme
  self.themeComponent = config.themeComponent
  
  -- State properties
  self._themeState = "normal"
  self.disabled = config.disabled or false
  self.active = config.active or false
  self.disableHighlight = config.disableHighlight
  
  -- 9-patch rendering properties
  self.scaleCorners = config.scaleCorners
  self.scalingAlgorithm = config.scalingAlgorithm
  
  -- Content sizing properties
  self.contentAutoSizingMultiplier = config.contentAutoSizingMultiplier
  
  -- Element reference (set via initialize)
  self._element = nil
  self._stateId = config.stateId
  
  return self
end

--- Initialize ThemeManager with parent element reference
--- This links the ThemeManager to its parent element for accessing dimensions and state
---@param element Element -- Parent element
function ThemeManager:initialize(element)
  self._element = element
  self._stateId = element._stateId or element.id
end

--- Update theme state based on interaction
--- State priority: disabled > pressed > active > hover > normal
---@param isHovered boolean -- Whether element is hovered
---@param isPressed boolean -- Whether element is pressed (any button)
---@param isFocused boolean -- Whether element is focused
---@param isDisabled boolean -- Whether element is disabled
function ThemeManager:updateState(isHovered, isPressed, isFocused, isDisabled)
  if not self.themeComponent then
    return
  end
  
  local newThemeState = "normal"
  
  -- State priority: disabled > active > pressed > hover > normal
  if isDisabled or self.disabled then
    newThemeState = "disabled"
  elseif self.active or isFocused then
    newThemeState = "active"
  elseif isPressed then
    newThemeState = "pressed"
  elseif isHovered then
    newThemeState = "hover"
  end
  
  -- Update local state
  self._themeState = newThemeState
  
  -- Update StateManager if in immediate mode
  if self._stateId then
    local GuiState = req("GuiState")
    if GuiState._immediateMode then
      StateManager.updateState(self._stateId, {
        hover = (newThemeState == "hover"),
        pressed = (newThemeState == "pressed"),
        focused = (newThemeState == "active" or isFocused),
        disabled = isDisabled or self.disabled,
        active = self.active,
      })
    end
  end
end

--- Get current theme state
---@return string -- Current state (normal, hover, pressed, active, disabled)
function ThemeManager:getState()
  return self._themeState
end

--- Get theme component for current state
--- Returns the component data with state-specific overrides applied
---@return table|nil -- Component data or nil if not found
function ThemeManager:getThemeComponent()
  if not self.themeComponent then
    return nil
  end
  
  -- Get the theme to use
  local themeToUse = self:_getTheme()
  if not themeToUse then
    return nil
  end
  
  -- Get the component from the theme
  local component = themeToUse.components[self.themeComponent]
  if not component then
    return nil
  end
  
  -- Check for state-specific override
  local state = self._themeState
  if state and state ~= "normal" and component.states and component.states[state] then
    component = component.states[state]
  end
  
  return component
end

--- Check if theme component exists
---@return boolean
function ThemeManager:hasThemeComponent()
  return self.themeComponent ~= nil and self:getThemeComponent() ~= nil
end

--- Get the theme to use (element theme or active theme)
---@return table|nil -- Theme data or nil if not found
function ThemeManager:_getTheme()
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
  
  return themeToUse
end

--- Get atlas image for current component
---@return love.Image|nil -- Atlas image or nil
function ThemeManager:_getAtlas()
  local component = self:getThemeComponent()
  if not component then
    return nil
  end
  
  local themeToUse = self:_getTheme()
  if not themeToUse then
    return nil
  end
  
  -- Use component-specific atlas if available, otherwise use theme atlas
  return component._loadedAtlas or themeToUse.atlas
end

--- Render theme component (9-patch or other)
---@param x number -- X position
---@param y number -- Y position
---@param width number -- Width (border-box)
---@param height number -- Height (border-box)
---@param opacity number? -- Opacity (0-1)
function ThemeManager:render(x, y, width, height, opacity)
  if not self.themeComponent then
    return
  end
  
  opacity = opacity or 1
  
  -- Get the theme to use
  local themeToUse = self:_getTheme()
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
  
  if atlasToUse and component.regions then
    -- Validate component has required structure for 9-patch
    local hasAllRegions = component.regions.topLeft
      and component.regions.topCenter
      and component.regions.topRight
      and component.regions.middleLeft
      and component.regions.middleCenter
      and component.regions.middleRight
      and component.regions.bottomLeft
      and component.regions.bottomCenter
      and component.regions.bottomRight
    
    if hasAllRegions then
      -- Render 9-patch with element-level overrides
      NinePatch.draw(
        component,
        atlasToUse,
        x,
        y,
        width,
        height,
        opacity,
        self.scaleCorners,
        self.scalingAlgorithm
      )
    else
      -- Silently skip drawing if component structure is invalid
    end
  end
end

--- Get styled property value from theme for current state
--- This allows theme components to provide default values for properties
---@param property string -- Property name (e.g., "backgroundColor", "textColor")
---@return any|nil -- Property value or nil if not found
function ThemeManager:getStyle(property)
  local component = self:getThemeComponent()
  if not component then
    return nil
  end
  
  -- Check if component has style properties
  if component.style and component.style[property] then
    return component.style[property]
  end
  
  return nil
end

--- Set theme and component
---@param themeName string? -- Theme name
---@param componentName string? -- Component name
function ThemeManager:setTheme(themeName, componentName)
  self.theme = themeName
  self.themeComponent = componentName
end

--- Get scale corners multiplier
---@return number|nil
function ThemeManager:getScaleCorners()
  -- Element-level override takes priority
  if self.scaleCorners ~= nil then
    return self.scaleCorners
  end
  
  -- Fall back to component setting
  local component = self:getThemeComponent()
  if component and component.scaleCorners then
    return component.scaleCorners
  end
  
  return nil
end

--- Get scaling algorithm
---@return "nearest"|"bilinear"
function ThemeManager:getScalingAlgorithm()
  -- Element-level override takes priority
  if self.scalingAlgorithm ~= nil then
    return self.scalingAlgorithm
  end
  
  -- Fall back to component setting
  local component = self:getThemeComponent()
  if component and component.scalingAlgorithm then
    return component.scalingAlgorithm
  end
  
  -- Default to bilinear
  return "bilinear"
end

--- Get the current state's scaled content padding
--- Returns the contentPadding for the current theme state, scaled to the element's size
---@param borderBoxWidth number -- Border-box width
---@param borderBoxHeight number -- Border-box height
---@return table|nil -- {left, top, right, bottom} or nil if no contentPadding
function ThemeManager:getScaledContentPadding(borderBoxWidth, borderBoxHeight)
  if not self.themeComponent then
    return nil
  end
  
  local themeToUse = self:_getTheme()
  if not themeToUse or not themeToUse.components[self.themeComponent] then
    return nil
  end
  
  local component = themeToUse.components[self.themeComponent]
  
  -- Check for state-specific override
  local state = self._themeState or "normal"
  if state and state ~= "normal" and component.states and component.states[state] then
    component = component.states[state]
  end
  
  if not component._ninePatchData or not component._ninePatchData.contentPadding then
    return nil
  end
  
  local contentPadding = component._ninePatchData.contentPadding
  
  -- Scale contentPadding to match the actual rendered size
  local atlasImage = component._loadedAtlas or themeToUse.atlas
  if atlasImage and type(atlasImage) ~= "string" then
    local originalWidth, originalHeight = atlasImage:getDimensions()
    local scaleX = borderBoxWidth / originalWidth
    local scaleY = borderBoxHeight / originalHeight
    
    return {
      left = contentPadding.left * scaleX,
      top = contentPadding.top * scaleY,
      right = contentPadding.right * scaleX,
      bottom = contentPadding.bottom * scaleY,
    }
  else
    -- Return unscaled values as fallback
    return {
      left = contentPadding.left,
      top = contentPadding.top,
      right = contentPadding.right,
      bottom = contentPadding.bottom,
    }
  end
end

--- Get content auto-sizing multiplier from theme
--- Priority: element config > theme component > theme default
---@return table -- {width, height} multipliers
function ThemeManager:getContentAutoSizingMultiplier()
  -- If explicitly set in config, use that
  if self.contentAutoSizingMultiplier then
    return self.contentAutoSizingMultiplier
  end
  
  -- Try to source from theme
  local themeToUse = self:_getTheme()
  if themeToUse then
    -- First check if themeComponent has a multiplier
    if self.themeComponent then
      local component = themeToUse.components[self.themeComponent]
      if component and component.contentAutoSizingMultiplier then
        return component.contentAutoSizingMultiplier
      elseif themeToUse.contentAutoSizingMultiplier then
        -- Fall back to theme default
        return themeToUse.contentAutoSizingMultiplier
      end
    elseif themeToUse.contentAutoSizingMultiplier then
      return themeToUse.contentAutoSizingMultiplier
    end
  end
  
  -- Default multiplier
  return { 1, 1 }
end

--- Update disabled state
---@param disabled boolean
function ThemeManager:setDisabled(disabled)
  self.disabled = disabled
end

--- Update active state
---@param active boolean
function ThemeManager:setActive(active)
  self.active = active
end

--- Get disabled state
---@return boolean
function ThemeManager:isDisabled()
  return self.disabled
end

--- Get active state
---@return boolean
function ThemeManager:isActive()
  return self.active
end

return ThemeManager
