---@class ThemeManager
---@field theme string?
---@field themeComponent string?
---@field _themeState string -- Current theme state (normal, hover, pressed, active, disabled)
---@field disabled boolean
---@field active boolean
---@field disableHighlight boolean -- If true, disable pressed highlight overlay
---@field scaleCorners number? -- Scale multiplier for 9-patch corners/edges
---@field scalingAlgorithm string? -- "nearest" or "bilinear" scaling for 9-patch
---@field _element Element? -- Reference to parent Element
---@field _Theme table
local ThemeManager = {}
ThemeManager.__index = ThemeManager

---@param config table Configuration options
---@param deps table Dependencies {Theme: Theme module}
---@return ThemeManager
function ThemeManager.new(config, deps)
  local Theme = deps.Theme
  local self = setmetatable({}, ThemeManager)

  self._Theme = Theme

  self.theme = config.theme
  self.themeComponent = config.themeComponent
  self.disabled = config.disabled or false
  self.active = config.active or false
  self.disableHighlight = config.disableHighlight
  self.scaleCorners = config.scaleCorners
  self.scalingAlgorithm = config.scalingAlgorithm

  self._themeState = "normal"
  self._element = nil

  return self
end

---@param element table The parent Element
function ThemeManager:initialize(element)
  self._element = element
end

---@param isHovered boolean Whether element is hovered
---@param isPressed boolean Whether element is pressed
---@param isFocused boolean Whether element is focused
---@param isDisabled boolean Whether element is disabled
---@return string The new theme state
function ThemeManager:updateState(isHovered, isPressed, isFocused, isDisabled)
  local newState = "normal"

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

---@return string The current theme state
function ThemeManager:getState()
  return self._themeState
end

---@param state string The theme state to set
function ThemeManager:setState(state)
  self._themeState = state
end

---@return boolean
function ThemeManager:hasThemeComponent()
  return self.themeComponent ~= nil
end

---@return table? The theme object or nil
function ThemeManager:getTheme()
  if self.theme then
    return self._Theme.get(self.theme)
  end
  return self._Theme.getActive()
end

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

---@return table? The component definition for current state or nil
function ThemeManager:getStateComponent()
  local component = self:getComponent()
  if not component then
    return nil
  end

  local state = self._themeState
  if state and state ~= "normal" and component.states and component.states[state] then
    return component.states[state]
  end

  return component
end

---@param property string The property name
---@return any? The property value or nil
function ThemeManager:getStyle(property)
  local stateComponent = self:getStateComponent()
  if not stateComponent then
    return nil
  end

  return stateComponent[property]
end

---@param borderBoxWidth number
---@param borderBoxHeight number
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

  local state = self._themeState or "normal"
  if state and state ~= "normal" and component.states and component.states[state] then
    component = component.states[state]
  end

  if not component._ninePatchData or not component._ninePatchData.contentPadding then
    return nil
  end

  local contentPadding = component._ninePatchData.contentPadding

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

---@return number? The multiplier or nil
function ThemeManager:getContentAutoSizingMultiplier()
  if not self.themeComponent then
    return nil
  end

  local themeToUse = self:getTheme()
  if not themeToUse then
    return nil
  end

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

---@param themeName string? The theme name
---@param componentName string? The component name
function ThemeManager:setTheme(themeName, componentName)
  self.theme = themeName
  self.themeComponent = componentName
end

return ThemeManager
