local Units = {}

--- Parse a unit value (string or number) into value and unit type
---@param value string|number
---@return number, string -- Returns numeric value and unit type ("px", "%", "vw", "vh")
function Units.parse(value)
  if type(value) == "number" then
    return value, "px"
  end

  if type(value) ~= "string" then
    -- Fallback to 0px for invalid types
    return 0, "px"
  end

  -- Match number followed by optional unit
  local numStr, unit = value:match("^([%-]?[%d%.]+)(.*)$")
  if not numStr then
    -- Fallback to 0px for invalid format
    return 0, "px"
  end

  local num = tonumber(numStr)
  if not num then
    -- Fallback to 0px for invalid numeric value
    return 0, "px"
  end

  -- Default to pixels if no unit specified
  if unit == "" then
    unit = "px"
  end

  local validUnits = { px = true, ["%"] = true, vw = true, vh = true, ew = true, eh = true }
  if not validUnits[unit] then
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
      error(formatError("Units", "Percentage units require parent dimension"))
    end
    return (value / 100) * parentSize
  elseif unit == "vw" then
    return (value / 100) * viewportWidth
  elseif unit == "vh" then
    return (value / 100) * viewportHeight
  else
    error(formatError("Units", string.format("Unknown unit type: '%s'. Valid units: px, %%, vw, vh, ew, eh", unit)))
  end
end

---@return number, number -- width, height
function Units.getViewport()
  -- Return cached viewport if available (only during resize operations)
  if Gui and Gui._cachedViewport and Gui._cachedViewport.width > 0 then
    return Gui._cachedViewport.width, Gui._cachedViewport.height
  end

  -- Query viewport dimensions normally
  if love.graphics and love.graphics.getDimensions then
    return love.graphics.getDimensions()
  else
    local w, h = love.window.getMode()
    return w, h
  end
end

--- Apply base scaling to a value
---@param value number
---@param axis "x"|"y" -- Which axis to scale on
---@param scaleFactors {x:number, y:number}
---@return number
function Units.applyBaseScale(value, axis, scaleFactors)
  if axis == "x" then
    return value * scaleFactors.x
  else
    return value * scaleFactors.y
  end
end

--- Resolve units for spacing properties (padding, margin)
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

  -- Handle shorthand properties first
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

  -- Handle individual sides
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
      -- Use fallbacks
      if side == "top" or side == "bottom" then
        result[side] = vertical or 0
      else
        result[side] = horizontal or 0
      end
    end
  end

  return result
end

--- Check if a unit string is valid
---@param unitStr string -- Unit string to validate (e.g., "10px", "50%", "20vw")
---@return boolean -- Returns true if unit string is valid
function Units.isValid(unitStr)
  if type(unitStr) ~= "string" then
    return false
  end

  local _, unit = Units.parse(unitStr)
  local validUnits = { px = true, ["%"] = true, vw = true, vh = true, ew = true, eh = true }
  return validUnits[unit] == true
end

--- Parse and resolve a unit value in one call
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
