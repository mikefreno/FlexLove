--- Utility module for parsing and resolving CSS-like units (px, %, vw, vh, ew, eh)
--- Provides unit parsing, validation, and conversion to pixel values
---@class Units
---@field _Context table? Context module dependency
---@field _ErrorHandler table? ErrorHandler module dependency
local Units = {}

--- Initialize Units module with dependencies
---@param deps table Dependencies: { Context = table?, ErrorHandler = table? }
function Units.init(deps)
  Units._Context = deps.Context
  Units._ErrorHandler = deps.ErrorHandler
end

--- Parse a unit value into numeric value and unit type
--- Supports: px (pixels), % (percentage), vw/vh (viewport), ew/eh (element)
---@param value string|number The value to parse (e.g., "50px", "10%", "2vw", 100)
---@return number numericValue The numeric portion of the value
---@return string unitType The unit type ("px", "%", "vw", "vh", "ew", "eh")
function Units.parse(value)
  if type(value) == "number" then
    return value, "px"
  end

  if type(value) ~= "string" then
    Units._ErrorHandler:warn("Units", "VAL_001", "Invalid property type", {
      property = "unit value",
      expected = "string or number",
      got = type(value),
    }, "Using fallback: 0px")
    return 0, "px"
  end

  -- Check for unit-only input (e.g., "px", "%", "vw" without a number)
  local validUnits = { px = true, ["%"] = true, vw = true, vh = true, ew = true, eh = true }
  if validUnits[value] then
    Units._ErrorHandler:warn("Units", "VAL_005", "Invalid unit format", {
      input = value,
      expected = "number + unit (e.g., '50" .. value .. "')",
    }, string.format("Add a numeric value before '%s', like '50%s'. Using fallback: 0px", value, value))
    return 0, "px"
  end

  -- Check for invalid format (space between number and unit)
  if value:match("%d%s+%a") then
    Units._ErrorHandler:warn("Units", "VAL_005", "Invalid unit format", {
      input = value,
      issue = "contains space between number and unit",
    }, "Remove spaces: use '50px' not '50 px'. Using fallback: 0px")
    return 0, "px"
  end

  -- Match number followed by optional unit
  local numStr, unit = value:match("^([%-]?[%d%.]+)(.*)$")
  if not numStr then
    Units._ErrorHandler:warn("Units", "VAL_005", "Invalid unit format", {
      input = value,
    }, "Expected format: number + unit (e.g., '50px', '10%', '2vw'). Using fallback: 0px")
    return 0, "px"
  end

  local num = tonumber(numStr)
  if not num then
    Units._ErrorHandler:warn("Units", "VAL_005", "Invalid unit format", {
      input = value,
      issue = "numeric value cannot be parsed",
    }, "Using fallback: 0px")
    return 0, "px"
  end

  -- Default to pixels if no unit specified
  if unit == "" then
    unit = "px"
  end

  -- validUnits is already defined at the top of the function
  if not validUnits[unit] then
    Units._ErrorHandler:warn("Units", "VAL_005", "Invalid unit format", {
      input = value,
      unit = unit,
      validUnits = "px, %, vw, vh, ew, eh",
    }, string.format("Treating '%s' as pixels", value))
    return num, "px"
  end

  return num, unit
end

--- Convert relative units to absolute pixel values
--- Resolves %, vw, vh units based on viewport and parent dimensions
---@param value number Numeric value to convert
---@param unit string Unit type ("px", "%", "vw", "vh", "ew", "eh")
---@param viewportWidth number Current viewport width in pixels
---@param viewportHeight number Current viewport height in pixels
---@param parentSize number? Required for percentage units (parent dimension in pixels)
---@return number resolvedValue Resolved pixel value
function Units.resolve(value, unit, viewportWidth, viewportHeight, parentSize)
  if unit == "px" then
    return value
  elseif unit == "%" then
    if not parentSize then
      Units._ErrorHandler:warn("Units", "LAY_003", "Invalid dimensions", {
        unit = "%",
        issue = "parent dimension not available",
      }, "Percentage units require a parent element with explicit dimensions. Using fallback: 0px")
      return 0
    end
    return (value / 100) * parentSize
  elseif unit == "vw" then
    return (value / 100) * viewportWidth
  elseif unit == "vh" then
    return (value / 100) * viewportHeight
  else
    Units._ErrorHandler:warn("Units", "VAL_005", "Invalid unit format", {
      unit = unit,
      validUnits = "px, %, vw, vh, ew, eh",
    }, string.format("Unknown unit type: '%s'. Using fallback: 0px", unit))
    return 0
  end
end

--- Get current viewport dimensions
--- Uses cached viewport during resize operations, otherwise queries LÖVE graphics
---@return number width Viewport width in pixels
---@return number height Viewport height in pixels
function Units.getViewport()
  -- Return cached viewport if available (only during resize operations)
  if Units._Context._cachedViewport and Units._Context._cachedViewport.width > 0 then
    return Units._Context._cachedViewport.width, Units._Context._cachedViewport.height
  end

  if love.graphics and love.graphics.getDimensions then
    return love.graphics.getDimensions()
  else
    local w, h = love.window.getMode()
    return w, h
  end
end

--- Apply base scale factor to a value based on axis
--- Used for responsive scaling of UI elements
---@param value number The value to scale
---@param axis "x"|"y" The axis to scale on
---@param scaleFactors {x:number, y:number} Scale factors for each axis
---@return number scaledValue The scaled value
function Units.applyBaseScale(value, axis, scaleFactors)
  if axis == "x" then
    return value * scaleFactors.x
  else
    return value * scaleFactors.y
  end
end

--- Resolve spacing properties (margin, padding) to pixel values
--- Supports individual sides (top, right, bottom, left) and shortcuts (vertical, horizontal)
---@param spacingProps table? Spacing properties with top/right/bottom/left/vertical/horizontal
---@param parentWidth number Parent element width in pixels
---@param parentHeight number Parent element height in pixels
---@return table resolvedSpacing Table with top, right, bottom, left in pixels
function Units.resolveSpacing(spacingProps, parentWidth, parentHeight)
  if not spacingProps then
    return { top = 0, right = 0, bottom = 0, left = 0 }
  end

  local viewportWidth, viewportHeight = Units.getViewport()
  local result = {}

  local vertical = spacingProps.vertical
  local horizontal = spacingProps.horizontal

  if vertical then
    if type(vertical) == "string" then
      local value, unit = Units.parse(vertical)
      vertical = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
    end
  end

  if horizontal then
    if type(horizontal) == "string" then
      local value, unit = Units.parse(horizontal)
      horizontal = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
    end
  end

  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    local value = spacingProps[side]
    if value then
      if type(value) == "string" then
        local numValue, unit = Units.parse(value)
        local parentSize = (side == "top" or side == "bottom") and parentHeight or parentWidth
        result[side] = Units.resolve(numValue, unit, viewportWidth, viewportHeight, parentSize)
      else
        result[side] = value
      end
    else
      if side == "top" or side == "bottom" then
        result[side] = vertical or 0
      else
        result[side] = horizontal or 0
      end
    end
  end

  return result
end

--- Validate a unit string format
--- Checks if the string can be successfully parsed as a valid unit
---@param unitStr string The unit string to validate (e.g., "50px", "10%")
---@return boolean isValid True if the unit string is valid, false otherwise
function Units.isValid(unitStr)
  if type(unitStr) ~= "string" then
    return false
  end

  -- Check for invalid format (space between number and unit)
  if unitStr:match("%d%s+%a") then
    return false
  end

  -- Match number followed by optional unit
  local numStr, unit = unitStr:match("^([%-]?[%d%.]+)(.*)$")
  if not numStr then
    return false
  end

  -- Check if numeric part is valid
  local num = tonumber(numStr)
  if not num then
    return false
  end

  -- Default to pixels if no unit specified
  if unit == "" then
    unit = "px"
  end

  -- Check if unit is valid
  local validUnits = { px = true, ["%"] = true, vw = true, vh = true, ew = true, eh = true }
  return validUnits[unit] == true
end

return Units
