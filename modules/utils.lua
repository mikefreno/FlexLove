local enums = {
  ---@enum TextAlign
  TextAlign = { START = "start", CENTER = "center", END = "end", JUSTIFY = "justify" },
  ---@enum Positioning
  Positioning = { ABSOLUTE = "absolute", RELATIVE = "relative", FLEX = "flex", GRID = "grid" },
  ---@enum FlexDirection
  FlexDirection = { HORIZONTAL = "horizontal", VERTICAL = "vertical" },
  ---@enum JustifyContent
  JustifyContent = {
    FLEX_START = "flex-start",
    CENTER = "center",
    SPACE_AROUND = "space-around",
    FLEX_END = "flex-end",
    SPACE_EVENLY = "space-evenly",
    SPACE_BETWEEN = "space-between",
  },
  ---@enum JustifySelf
  JustifySelf = {
    AUTO = "auto",
    FLEX_START = "flex-start",
    CENTER = "center",
    FLEX_END = "flex-end",
    SPACE_AROUND = "space-around",
    SPACE_EVENLY = "space-evenly",
    SPACE_BETWEEN = "space-between",
  },
  ---@enum AlignItems
  AlignItems = {
    STRETCH = "stretch",
    FLEX_START = "flex-start",
    FLEX_END = "flex-end",
    CENTER = "center",
    BASELINE = "baseline",
  },
  ---@enum AlignSelf
  AlignSelf = {
    AUTO = "auto",
    STRETCH = "stretch",
    FLEX_START = "flex-start",
    FLEX_END = "flex-end",
    CENTER = "center",
    BASELINE = "baseline",
  },
  ---@enum AlignContent
  AlignContent = {
    STRETCH = "stretch",
    FLEX_START = "flex-start",
    FLEX_END = "flex-end",
    CENTER = "center",
    SPACE_BETWEEN = "space-between",
    SPACE_AROUND = "space-around",
  },
  ---@enum FlexWrap
  FlexWrap = { NOWRAP = "nowrap", WRAP = "wrap", WRAP_REVERSE = "wrap-reverse" },
  ---@enum TextSize
  TextSize = {
    XXS = "xxs",
    XS = "xs",
    SM = "sm",
    MD = "md",
    LG = "lg",
    XL = "xl",
    XXL = "xxl",
    XL3 = "3xl",
    XL4 = "4xl",
  },
}

--- Get current keyboard modifiers state
---@return {shift:boolean, ctrl:boolean, alt:boolean, super:boolean}
local function getModifiers()
  return {
    shift = love.keyboard.isDown("lshift", "rshift"),
    ctrl = love.keyboard.isDown("lctrl", "rctrl"),
    alt = love.keyboard.isDown("lalt", "ralt"),
    ---@diagnostic disable-next-line
    super = love.keyboard.isDown("lgui", "rgui"), -- cmd/windows key
  }
end

local TEXT_SIZE_PRESETS = {
  ["2xs"] = 0.75,
  xxs = 0.75,
  xs = 1.25,
  sm = 1.75,
  md = 2.25,
  lg = 2.75,
  xl = 3.5,
  xxl = 4.5,
  ["2xl"] = 4.5,
  ["3xl"] = 5.0,
  ["4xl"] = 7.0,
}

--- Resolve text size preset to viewport units
---@param sizeValue string|number
---@return number?, string?
local function resolveTextSizePreset(sizeValue)
  if type(sizeValue) == "string" then
    local preset = TEXT_SIZE_PRESETS[sizeValue]
    if preset then
      return preset, "vh"
    end
  end
  return nil, nil
end

--- Auto-detect the base path where FlexLove is located
---@return string filesystemPath
local function getFlexLoveBasePath()
  local info = debug.getinfo(1, "S")
  if info and info.source then
    local source = info.source
    if source:sub(1, 1) == "@" then
      source = source:sub(2)
    end

    local filesystemPath = source:match("(.*/)")
    if filesystemPath then
      local fsPath = filesystemPath
      fsPath = fsPath:gsub("^%./", "")
      fsPath = fsPath:gsub("/$", "")
      fsPath = fsPath:gsub("/modules$", "")
      return fsPath
    end
  end
  return "libs"
end

local FLEXLOVE_FILESYSTEM_PATH = getFlexLoveBasePath()

--- Helper function to resolve paths relative to FlexLove
---@param path string
---@return string
local function resolveImagePath(path)
  if path:match("^/") or path:match("^[A-Z]:") then
    return path
  end
  return FLEXLOVE_FILESYSTEM_PATH .. "/" .. path
end

local FONT_CACHE = {}
local FONT_CACHE_MAX_SIZE = 50
local FONT_CACHE_ORDER = {}

--- Create or get a font from cache
---@param size number
---@param fontPath string?
---@return love.Font
function FONT_CACHE.get(size, fontPath)
  local cacheKey = fontPath and (fontPath .. "_" .. tostring(size)) or tostring(size)

  if not FONT_CACHE[cacheKey] then
    if fontPath then
      local resolvedPath = resolveImagePath(fontPath)
      local success, font = pcall(love.graphics.newFont, resolvedPath, size)
      if success then
        FONT_CACHE[cacheKey] = font
      else
        print("[FlexLove] Failed to load font: " .. fontPath .. " - using default font")
        FONT_CACHE[cacheKey] = love.graphics.newFont(size)
      end
    else
      FONT_CACHE[cacheKey] = love.graphics.newFont(size)
    end

    table.insert(FONT_CACHE_ORDER, cacheKey)

    if #FONT_CACHE_ORDER > FONT_CACHE_MAX_SIZE then
      local oldestKey = table.remove(FONT_CACHE_ORDER, 1)
      FONT_CACHE[oldestKey] = nil
    end
  end
  return FONT_CACHE[cacheKey]
end

--- Get font for text size (cached)
---@param textSize number?
---@param fontPath string?
---@return love.Font
function FONT_CACHE.getFont(textSize, fontPath)
  if textSize then
    return FONT_CACHE.get(textSize, fontPath)
  else
    return love.graphics.getFont()
  end
end

-- Font resolution utilities

--- Resolve font path from fontFamily and theme
---@param fontFamily string? Font family name or direct path
---@param themeComponent string? Theme component name
---@param themeManager table? ThemeManager instance
---@return string? Resolved font path or nil
local function resolveFontPath(fontFamily, themeComponent, themeManager)
  if fontFamily then
    -- Check if fontFamily is a theme font name
    local themeToUse = themeManager and themeManager:getTheme()
    if themeToUse and themeToUse.fonts and themeToUse.fonts[fontFamily] then
      return themeToUse.fonts[fontFamily]
    else
      -- Treat as direct path to font file
      return fontFamily
    end
  elseif themeComponent and themeManager then
    -- If using themeComponent but no fontFamily specified, check for default font in theme
    return themeManager:getDefaultFontFamily()
  end
  return nil
end

--- Get font for element (resolves from theme or fontFamily)
---@param textSize number? Text size in pixels
---@param fontFamily string? Font family name or direct path
---@param themeComponent string? Theme component name
---@param themeManager table? ThemeManager instance
---@return love.Font
local function getFont(textSize, fontFamily, themeComponent, themeManager)
  local fontPath = resolveFontPath(fontFamily, themeComponent, themeManager)
  return FONT_CACHE.getFont(textSize, fontPath)
end

--- Apply content auto-sizing multiplier to a dimension
---@param value number The dimension value
---@param multiplier table? The contentAutoSizingMultiplier table {width:number?, height:number?}
---@param axis "width"|"height" Which axis to apply
---@return number The multiplied value
local function applyContentMultiplier(value, multiplier, axis)
  if multiplier and multiplier[axis] then
    return value * multiplier[axis]
  end
  return value
end

-- Validation utilities
local ErrorHandler = nil

--- Initialize ErrorHandler dependency for validation utilities
---@param errorHandler table The ErrorHandler module
local function initializeErrorHandler(errorHandler)
  ErrorHandler = errorHandler
end

--- Validate that a value is in an enum table
---@param value any Value to validate
---@param enumTable table Enum table with valid values
---@param propName string Property name for error messages
---@param moduleName string? Module name for error messages (default: "Element")
---@return boolean True if valid
local function validateEnum(value, enumTable, propName, moduleName)
  if value == nil then
    return true
  end

  for _, validValue in pairs(enumTable) do
    if value == validValue then
      return true
    end
  end

  -- Build list of valid options
  local validOptions = {}
  for _, v in pairs(enumTable) do
    table.insert(validOptions, "'" .. v .. "'")
  end
  table.sort(validOptions)

  if ErrorHandler then
    ErrorHandler.error(moduleName or "Element", string.format("%s must be one of: %s. Got: '%s'", propName, table.concat(validOptions, ", "), tostring(value)))
  else
    error(string.format("%s must be one of: %s. Got: '%s'", propName, table.concat(validOptions, ", "), tostring(value)))
  end
end

--- Validate that a numeric value is within a range
---@param value any Value to validate
---@param min number Minimum allowed value
---@param max number Maximum allowed value
---@param propName string Property name for error messages
---@param moduleName string? Module name for error messages (default: "Element")
---@return boolean True if valid
local function validateRange(value, min, max, propName, moduleName)
  if value == nil then
    return true
  end
  if type(value) ~= "number" then
    if ErrorHandler then
      ErrorHandler.error(moduleName or "Element", string.format("%s must be a number, got %s", propName, type(value)))
    else
      error(string.format("%s must be a number, got %s", propName, type(value)))
    end
  end
  if value < min or value > max then
    if ErrorHandler then
      ErrorHandler.error(moduleName or "Element", string.format("%s must be between %s and %s, got %s", propName, tostring(min), tostring(max), tostring(value)))
    else
      error(string.format("%s must be between %s and %s, got %s", propName, tostring(min), tostring(max), tostring(value)))
    end
  end
  return true
end

--- Validate that a value is of the expected type
---@param value any Value to validate
---@param expectedType string Expected type name
---@param propName string Property name for error messages
---@param moduleName string? Module name for error messages (default: "Element")
---@return boolean True if valid
local function validateType(value, expectedType, propName, moduleName)
  if value == nil then
    return true
  end
  local actualType = type(value)
  if actualType ~= expectedType then
    if ErrorHandler then
      ErrorHandler.error(moduleName or "Element", string.format("%s must be %s, got %s", propName, expectedType, actualType))
    else
      error(string.format("%s must be %s, got %s", propName, expectedType, actualType))
    end
  end
  return true
end

-- Math utilities

--- Clamp a value between min and max
---@param value number Value to clamp
---@param min number Minimum value
---@param max number Maximum value
---@return number Clamped value
local function clamp(value, min, max)
  return math.max(min, math.min(value, max))
end

--- Linear interpolation between two values
---@param a number Start value
---@param b number End value
---@param t number Interpolation factor (0-1)
---@return number Interpolated value
local function lerp(a, b, t)
  return a + (b - a) * t
end

--- Round a number to the nearest integer
---@param value number Value to round
---@return number Rounded value
local function round(value)
  return math.floor(value + 0.5)
end

-- Path and Image utilities

--- Normalize a file path for consistent cache keys
---@param path string File path to normalize
---@return string Normalized path
local function normalizePath(path)
  path = path:match("^%s*(.-)%s*$")
  path = path:gsub("\\", "/")
  path = path:gsub("/+", "/")
  return path
end

--- Safely load an image with error handling
--- Returns both Image and ImageData to avoid deprecated getData() API
---@param imagePath string Path to image file
---@return love.Image?, love.ImageData?, string? Returns image, imageData, or nil with error message
local function safeLoadImage(imagePath)
  local success, imageData = pcall(function()
    return love.image.newImageData(imagePath)
  end)

  if not success then
    local errorMsg = string.format("[FlexLove] Failed to load image data: %s - %s", imagePath, tostring(imageData))
    print(errorMsg)
    return nil, nil, errorMsg
  end

  local imageSuccess, image = pcall(function()
    return love.graphics.newImage(imageData)
  end)

  if imageSuccess then
    return image, imageData, nil
  else
    local errorMsg = string.format("[FlexLove] Failed to create image: %s - %s", imagePath, tostring(image))
    print(errorMsg)
    return nil, nil, errorMsg
  end
end

-- Color manipulation utilities

--- Brighten a color by a factor
---@param r number Red component (0-1)
---@param g number Green component (0-1)
---@param b number Blue component (0-1)
---@param a number Alpha component (0-1)
---@param factor number Brightness factor (e.g., 1.2 for 20% brighter)
---@return number, number, number, number Brightened color components
local function brightenColor(r, g, b, a, factor)
  return math.min(1, r * factor), math.min(1, g * factor), math.min(1, b * factor), a
end

-- Property normalization utilities

--- Normalize a boolean or table property with vertical/horizontal fields
---@param value boolean|table|nil Input value (boolean applies to both, table for individual control)
---@param defaultValue boolean Default value if nil (default: false)
---@return table Normalized table with vertical and horizontal fields
local function normalizeBooleanTable(value, defaultValue)
  defaultValue = defaultValue or false
  
  if value == nil then
    return { vertical = defaultValue, horizontal = defaultValue }
  end
  
  if type(value) == "boolean" then
    return { vertical = value, horizontal = value }
  end
  
  if type(value) == "table" then
    return {
      vertical = value.vertical ~= nil and value.vertical or defaultValue,
      horizontal = value.horizontal ~= nil and value.horizontal or defaultValue,
    }
  end
  
  return { vertical = defaultValue, horizontal = defaultValue }
end

return {
  enums = enums,
  FONT_CACHE = FONT_CACHE,
  resolveTextSizePreset = resolveTextSizePreset,
  getModifiers = getModifiers,
  TEXT_SIZE_PRESETS = TEXT_SIZE_PRESETS,
  initializeErrorHandler = initializeErrorHandler,
  validateEnum = validateEnum,
  validateRange = validateRange,
  validateType = validateType,
  clamp = clamp,
  lerp = lerp,
  round = round,
  normalizePath = normalizePath,
  safeLoadImage = safeLoadImage,
  brightenColor = brightenColor,
  resolveImagePath = resolveImagePath,
  normalizeBooleanTable = normalizeBooleanTable,
  resolveFontPath = resolveFontPath,
  getFont = getFont,
  applyContentMultiplier = applyContentMultiplier,
}
