local Units = {}

local Context = nil
local ErrorHandler = nil

--- Initialize Units module with Context dependency
---@param context table The Context module
function Units.initialize(context)
  Context = context
end

--- Initialize ErrorHandler dependency
---@param errorHandler table The ErrorHandler module
function Units.initializeErrorHandler(errorHandler)
  ErrorHandler = errorHandler
end

---@param value string|number
---@return number, string -- Returns numeric value and unit type ("px", "%", "vw", "vh")
function Units.parse(value)
  if type(value) == "number" then
    return value, "px"
  end

  if type(value) ~= "string" then
    if ErrorHandler then
      ErrorHandler.warn("Units", "VAL_001", "Invalid property type", {
        property = "unit value",
        expected = "string or number",
        got = type(value)
      }, "Using fallback: 0px")
    else
      print(string.format("[FlexLove - Units] Warning: Invalid unit value type. Expected string or number, got %s. Using fallback: 0px", type(value)))
    end
    return 0, "px"
  end

  -- Check for unit-only input (e.g., "px", "%", "vw" without a number)
  local validUnits = { px = true, ["%"] = true, vw = true, vh = true, ew = true, eh = true }
  if validUnits[value] then
    if ErrorHandler then
      ErrorHandler.warn("Units", "VAL_005", "Invalid unit format", {
        input = value,
        expected = "number + unit (e.g., '50" .. value .. "')"
      }, string.format("Add a numeric value before '%s', like '50%s'. Using fallback: 0px", value, value))
    else
      print(string.format("[FlexLove - Units] Warning: Missing numeric value before unit '%s'. Use format like '50%s'. Using fallback: 0px", value, value))
    end
    return 0, "px"
  end

  -- Check for invalid format (space between number and unit)
  if value:match("%d%s+%a") then
    if ErrorHandler then
      ErrorHandler.warn("Units", "VAL_005", "Invalid unit format", {
        input = value,
        issue = "contains space between number and unit"
      }, "Remove spaces: use '50px' not '50 px'. Using fallback: 0px")
    else
      print(string.format("[FlexLove - Units] Warning: Invalid unit string '%s' (contains space). Use format like '50px' or '50%%'. Using fallback: 0px", value))
    end
    return 0, "px"
  end

  -- Match number followed by optional unit
  local numStr, unit = value:match("^([%-]?[%d%.]+)(.*)$")
  if not numStr then
    if ErrorHandler then
      ErrorHandler.warn("Units", "VAL_005", "Invalid unit format", {
        input = value
      }, "Expected format: number + unit (e.g., '50px', '10%', '2vw'). Using fallback: 0px")
    else
      print(string.format("[FlexLove - Units] Warning: Invalid unit format '%s'. Expected format: number + unit (e.g., '50px', '10%%', '2vw'). Using fallback: 0px", value))
    end
    return 0, "px"
  end

  local num = tonumber(numStr)
  if not num then
    if ErrorHandler then
      ErrorHandler.warn("Units", "VAL_005", "Invalid unit format", {
        input = value,
        issue = "numeric value cannot be parsed"
      }, "Using fallback: 0px")
    else
      print(string.format("[FlexLove - Units] Warning: Invalid numeric value in '%s'. Using fallback: 0px", value))
    end
    return 0, "px"
  end

  -- Default to pixels if no unit specified
  if unit == "" then
    unit = "px"
  end

  -- validUnits is already defined at the top of the function
  if not validUnits[unit] then
    if ErrorHandler then
      ErrorHandler.warn("Units", "VAL_005", "Invalid unit format", {
        input = value,
        unit = unit,
        validUnits = "px, %, vw, vh, ew, eh"
      }, string.format("Treating '%s' as pixels", value))
    else
      print(string.format("[FlexLove - Units] Warning: Unknown unit '%s' in '%s'. Valid units: px, %%, vw, vh, ew, eh. Treating as pixels", unit, value))
    end
    return num, "px"
  end

  return num, unit
end

--- Convert relative units to pixels based on viewport and parent dimensions
---@param value number -- Numeric value to convert
---@param unit string -- Unit type ("px", "%", "vw", "vh", "ew", "eh")
---@param viewportWidth number -- Current viewport width in pixels
---@param viewportHeight number -- Current viewport height in pixels
---@param parentSize number? -- Required for percentage units (parent dimension)
---@return number -- Resolved pixel value
---@throws Error if unit type is unknown or percentage used without parent size
function Units.resolve(value, unit, viewportWidth, viewportHeight, parentSize)
  if unit == "px" then
    return value
  elseif unit == "%" then
    if not parentSize then
      if ErrorHandler then
        ErrorHandler.error("Units", "LAY_003", "Invalid dimensions", {
          unit = "%",
          issue = "parent dimension not available"
        }, "Percentage units require a parent element with explicit dimensions")
      else
        error("Percentage units require parent dimension")
      end
    end
    return (value / 100) * parentSize
  elseif unit == "vw" then
    return (value / 100) * viewportWidth
  elseif unit == "vh" then
    return (value / 100) * viewportHeight
  else
    if ErrorHandler then
      ErrorHandler.error("Units", "VAL_005", "Invalid unit format", {
        unit = unit,
        validUnits = "px, %, vw, vh, ew, eh"
      })
    else
      error(string.format("Unknown unit type: '%s'", unit))
    end
  end
end

---@return number, number -- width, height
function Units.getViewport()
  -- Return cached viewport if available (only during resize operations)
  if Context and Context._cachedViewport and Context._cachedViewport.width > 0 then
    return Context._cachedViewport.width, Context._cachedViewport.height
  end

  if love.graphics and love.graphics.getDimensions then
    return love.graphics.getDimensions()
  else
    local w, h = love.window.getMode()
    return w, h
  end
end

---@param value number
---@param axis "x"|"y"
---@param scaleFactors {x:number, y:number}
---@return number
function Units.applyBaseScale(value, axis, scaleFactors)
  if axis == "x" then
    return value * scaleFactors.x
  else
    return value * scaleFactors.y
  end
end

---@param spacingProps table?
---@param parentWidth number
---@param parentHeight number
---@return table -- Resolved spacing with top, right, bottom, left in pixels
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

---@param unitStr string
---@return boolean
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

---@param value string|number -- Value to parse and resolve
---@param viewportWidth number -- Current viewport width
---@param viewportHeight number -- Current viewport height
---@param parentSize number? -- Parent dimension for percentage units
---@return number -- Resolved pixel value
function Units.parseAndResolve(value, viewportWidth, viewportHeight, parentSize)
  local numValue, unit = Units.parse(value)
  return Units.resolve(numValue, unit, viewportWidth, viewportHeight, parentSize)
end

return Units
