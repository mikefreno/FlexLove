--- Standardized error message formatter
---@param module string -- Module name (e.g., "Color", "Theme", "Units")
---@param message string -- Error message
---@return string -- Formatted error message
local function formatError(module, message)
  return string.format("[FlexLove.%s] %s", module, message)
end

-- ====================
-- Color System
-- ====================

--- Utility class for color handling
---@class Color
---@field r number -- Red component (0-1)
---@field g number -- Green component (0-1)
---@field b number -- Blue component (0-1)
---@field a number -- Alpha component (0-1)
local Color = {}
Color.__index = Color

--- Create a new color instance
---@param r number? -- Default: 0
---@param g number? -- Default: 0
---@param b number? -- Default: 0
---@param a number? -- Default: 1
---@return Color
function Color.new(r, g, b, a)
  local self = setmetatable({}, Color)
  self.r = r or 0
  self.g = g or 0
  self.b = b or 0
  self.a = a or 1
  return self
end

---@return number r, number g, number b, number a
function Color:toRGBA()
  return self.r, self.g, self.b, self.a
end

--- Convert hex string to color
--- Supports both 6-digit (#RRGGBB) and 8-digit (#RRGGBBAA) hex formats
---@param hexWithTag string -- e.g. "#RRGGBB" or "#RRGGBBAA"
---@return Color
---@throws Error if hex string format is invalid
function Color.fromHex(hexWithTag)
  local hex = hexWithTag:gsub("#", "")
  if #hex == 6 then
    local r = tonumber("0x" .. hex:sub(1, 2))
    local g = tonumber("0x" .. hex:sub(3, 4))
    local b = tonumber("0x" .. hex:sub(5, 6))
    if not r or not g or not b then
      error(formatError("Color", string.format("Invalid hex string format: '%s'. Contains invalid hex digits", hexWithTag)))
    end
    return Color.new(r / 255, g / 255, b / 255, 1)
  elseif #hex == 8 then
    local r = tonumber("0x" .. hex:sub(1, 2))
    local g = tonumber("0x" .. hex:sub(3, 4))
    local b = tonumber("0x" .. hex:sub(5, 6))
    local a = tonumber("0x" .. hex:sub(7, 8))
    if not r or not g or not b or not a then
      error(formatError("Color", string.format("Invalid hex string format: '%s'. Contains invalid hex digits", hexWithTag)))
    end
    return Color.new(r / 255, g / 255, b / 255, a / 255)
  else
    error(formatError("Color", string.format("Invalid hex string format: '%s'. Expected #RRGGBB or #RRGGBBAA", hexWithTag)))
  end
end

return Color
