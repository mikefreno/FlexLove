--- ThemeManager.lua
--- Manages theme application, state transitions, and property resolution for Elements
--- Extracted from Element.lua as part of element-refactor-modularization task 06
---
--- Dependencies (must be injected via deps parameter):
---   - Theme: Theme module for loading and accessing themes

---@class ThemeManager
---@field theme string? -- Theme name to use
---@field themeComponent string? -- Component name from theme (e.g., "button", "panel")
---@field _themeState string -- Current theme state (normal, hover, pressed, active, disabled)
---@field disabled boolean -- If true, element is disabled
---@field active boolean -- If true, element is in active state (e.g., focused input)
---@field disableHighlight boolean -- If true, disable pressed highlight overlay
---@field scaleCorners number? -- Scale multiplier for 9-patch corners/edges
---@field scalingAlgorithm string? -- "nearest" or "bilinear" scaling for 9-patch
---@field _element table? -- Reference to parent Element
local ThemeManager = {}
ThemeManager.__index = ThemeManager

--- Create new ThemeManager instance
---@param config table Configuration options
---@param deps table Dependencies {Theme: Theme module}
---@return ThemeManager
function ThemeManager.new(config, deps)
  local Theme = deps.Theme
  local self = setmetatable({}, ThemeManager)

  -- Store dependency for instance methods
  self._Theme = Theme

  -- Theme configuration
  self.theme = config.theme
  self.themeComponent = config.themeComponent
  self.disabled = config.disabled or false
  self.active = config.active or false
  self.disableHighlight = config.disableHighlight
  self.scaleCorners = config.scaleCorners
  self.scalingAlgorithm = config.scalingAlgorithm

  -- Internal state
  self._themeState = "normal"
  self._element = nil

  return self
end

--- Initialize ThemeManager with parent element reference
---@param element table The parent Element
function ThemeManager:initialize(element)
  self._element = element
end

--- Update theme state based on interaction state
---@param isHovered boolean Whether element is hovered
---@param isPressed boolean Whether element is pressed
---@param isFocused boolean Whether element is focused
---@param isDisabled boolean Whether element is disabled
---@return string The new theme state
function ThemeManager:updateState(isHovered, isPressed, isFocused, isDisabled)
  local newState = "normal"

  -- State priority: disabled > active > pressed > hover > normal
  if isDisabled or self.disabled then
    newState = "disabled"
  elseif self.active then
    newState = "active"
  elseif isPressed then
    newState = "pressed"
  elseif isHovered then
    newState = "hover"
  end

  self._themeState = newState
  return newState
end

--- Get current theme state
---@return string The current theme state
function ThemeManager:getState()
  return self._themeState
end

--- Set theme state directly
---@param state string The theme state to set
function ThemeManager:setState(state)
  self._themeState = state
end

--- Check if this ThemeManager has a theme component
---@return boolean
function ThemeManager:hasThemeComponent()
  return self.themeComponent ~= nil
end

--- Get the theme component name
---@return string?
function ThemeManager:getThemeComponent()
  return self.themeComponent
end

--- Get the theme to use (element-specific or active theme)
---@return table? The theme object or nil
function ThemeManager:getTheme()
  if self.theme then
    return self._Theme.get(self.theme)
  end
  return self._Theme.getActive()
end

--- Get the component definition from the theme
---@return table? The component definition or nil
function ThemeManager:getComponent()
  if not self.themeComponent then
    return nil
  end

  local themeToUse = self:getTheme()
  if not themeToUse or not themeToUse.components[self.themeComponent] then
    return nil
  end

  return themeToUse.components[self.themeComponent]
end

--- Get the current state's component definition (including state-specific overrides)
---@return table? The component definition for current state or nil
function ThemeManager:getStateComponent()
  local component = self:getComponent()
  if not component then
    return nil
  end

  -- Check for state-specific override
  local state = self._themeState
  if state and state ~= "normal" and component.states and component.states[state] then
    return component.states[state]
  end

  return component
end

--- Get property value from theme for current state
---@param property string The property name
---@return any? The property value or nil
function ThemeManager:getStyle(property)
  local stateComponent = self:getStateComponent()
  if not stateComponent then
    return nil
  end

  return stateComponent[property]
end

--- Get the scaled content padding for current theme state
---@param borderBoxWidth number The element's border box width
---@param borderBoxHeight number The element's border box height
---@return table? {left, top, right, bottom} or nil if no contentPadding
function ThemeManager:getScaledContentPadding(borderBoxWidth, borderBoxHeight)
  if not self.themeComponent then
    return nil
  end

  local themeToUse = self:getTheme()
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
  end

  return nil
end

--- Get contentAutoSizingMultiplier from theme
---@return number? The multiplier or nil
function ThemeManager:getContentAutoSizingMultiplier()
  if not self.themeComponent then
    return nil
  end

  local themeToUse = self:getTheme()
  if not themeToUse then
    return nil
  end

  -- First check if themeComponent has a multiplier
  if self.themeComponent then
    local component = themeToUse.components[self.themeComponent]
    if component and component.contentAutoSizingMultiplier then
      return component.contentAutoSizingMultiplier
    elseif themeToUse.contentAutoSizingMultiplier then
      -- Fall back to theme default
      return themeToUse.contentAutoSizingMultiplier
    end
  end

  -- Fall back to theme default
  if themeToUse.contentAutoSizingMultiplier then
    return themeToUse.contentAutoSizingMultiplier
  end

  return nil
end

--- Get default font family from theme
---@return string? The font name or path, or nil
function ThemeManager:getDefaultFontFamily()
  local themeToUse = self:getTheme()
  if themeToUse and themeToUse.fonts and themeToUse.fonts["default"] then
    return themeToUse.fonts["default"]
  end
  return nil
end

--- Set theme and component
---@param themeName string? The theme name
---@param componentName string? The component name
function ThemeManager:setTheme(themeName, componentName)
  self.theme = themeName
  self.themeComponent = componentName
end

--- Get scale corners multiplier
---@return number?
function ThemeManager:getScaleCorners()
  return self.scaleCorners
end

--- Get scaling algorithm
---@return string?
function ThemeManager:getScalingAlgorithm()
  return self.scalingAlgorithm
end

return ThemeManager
