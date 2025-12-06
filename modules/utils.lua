local enums = {
  ---@enum TextAlign
  TextAlign = { START = "start", CENTER = "center", END = "end", JUSTIFY = "justify" },
  ---@enum Positioning
  Positioning = { ABSOLUTE = "absolute", RELATIVE = "relative", FLEX = "flex", GRID = "grid" },
  ---@enum FlexDirection
  FlexDirection = { HORIZONTAL = "horizontal", VERTICAL = "vertical", ROW = "row", COLUMN = "column" },
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
  ---@enum ImageRepeat
  ImageRepeat = {
    NO_REPEAT = "no-repeat",
    REPEAT = "repeat",
    REPEAT_X = "repeat-x",
    REPEAT_Y = "repeat-y",
    SPACE = "space",
    ROUND = "round",
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

-- Font cache with LRU eviction
local FONT_CACHE = {}
local FONT_CACHE_MAX_SIZE = 50
local FONT_CACHE_STATS = {
  hits = 0,
  misses = 0,
  evictions = 0,
  size = 0,
}

-- LRU tracking: each entry has {font, lastUsed, accessCount}
local function updateCacheAccess(cacheKey)
  local entry = FONT_CACHE[cacheKey]
  if entry then
    entry.lastUsed = love.timer.getTime()
    entry.accessCount = entry.accessCount + 1
  end
end

local function evictLRU()
  local oldestKey = nil
  local oldestTime = math.huge

  for key, entry in pairs(FONT_CACHE) do
    -- Skip methods (get, getFont) - only evict cache entries (tables with lastUsed)
    if type(entry) == "table" and entry.lastUsed then
      if entry.lastUsed < oldestTime then
        oldestTime = entry.lastUsed
        oldestKey = key
      end
    end
  end

  if oldestKey then
    FONT_CACHE[oldestKey] = nil
    FONT_CACHE_STATS.evictions = FONT_CACHE_STATS.evictions + 1
    FONT_CACHE_STATS.size = FONT_CACHE_STATS.size - 1
  end
end

--- Create or get a font from cache
---@param size number
---@param fontPath string?
---@return love.Font
function FONT_CACHE.get(size, fontPath)
  -- Bucket font sizes for better cache reuse (reduces unique cache entries)
  -- Small sizes (< 20): round to nearest 2
  -- Medium sizes (20-40): round to nearest 4
  -- Large sizes (> 40): round to nearest 8
  if size < 20 then
    size = math.floor((size + 1) / 2) * 2
  elseif size < 40 then
    size = math.floor((size + 2) / 4) * 4
  else
    size = math.floor((size + 4) / 8) * 8
  end

  local cacheKey = fontPath and (fontPath .. ":" .. tostring(size)) or ("default:" .. tostring(size))

  if FONT_CACHE[cacheKey] then
    -- Cache hit
    FONT_CACHE_STATS.hits = FONT_CACHE_STATS.hits + 1
    updateCacheAccess(cacheKey)
    return FONT_CACHE[cacheKey].font
  end

  -- Cache miss
  FONT_CACHE_STATS.misses = FONT_CACHE_STATS.misses + 1

  local font
  if fontPath then
    local resolvedPath = resolveImagePath(fontPath)
    local success, result = pcall(love.graphics.newFont, resolvedPath, size)
    if success then
      font = result
    else
      -- Use ErrorHandler if available, otherwise fall back to print
      if ErrorHandler then
        ErrorHandler:warn("utils", "RES_004", {
          resourceType = "font",
          path = fontPath,
        })
      else
        print("[FlexLove] Failed to load font: " .. fontPath .. " - using default font")
      end
      font = love.graphics.newFont(size)
    end
  else
    font = love.graphics.newFont(size)
  end

  -- Add to cache with LRU metadata
  FONT_CACHE[cacheKey] = {
    font = font,
    lastUsed = love.timer.getTime(),
    accessCount = 1,
  }
  FONT_CACHE_STATS.size = FONT_CACHE_STATS.size + 1

  -- Evict if cache is full
  if FONT_CACHE_STATS.size > FONT_CACHE_MAX_SIZE then
    evictLRU()
  end

  return font
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

--- Initialize dependencies
---@param deps table Dependencies: { ErrorHandler = ErrorHandler }
local function init(deps)
  if type(deps) == "table" then
    ErrorHandler = deps.ErrorHandler
  end
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
    ErrorHandler:error(moduleName or "Element", "VAL_007", {
      property = propName,
      expected = table.concat(validOptions, ", "),
      got = tostring(value),
    })
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
      ErrorHandler:error(moduleName or "Element", "VAL_001", {
        property = propName,
        expected = "number",
        got = type(value),
      })
    else
      error(string.format("%s must be a number, got %s", propName, type(value)))
    end
  elseif value < min or value > max then
    if ErrorHandler then
      ErrorHandler:error(moduleName or "Element", "VAL_002", {
        property = propName,
        min = tostring(min),
        max = tostring(max),
        value = tostring(value),
      })
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
      ErrorHandler:error(moduleName or "Element", "VAL_001", {
        property = propName,
        expected = expectedType,
        got = actualType,
      })
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
    local errorMsg = string.format("Failed to load image data: %s - %s", imagePath, tostring(imageData))
    -- Use ErrorHandler if available, otherwise fall back to print
    if ErrorHandler then
      ErrorHandler:warn("utils", "RES_004", {
        resourceType = "image data",
        path = imagePath,
        error = tostring(imageData),
      })
    else
      print("[FlexLove] " .. errorMsg)
    end
    return nil, nil, errorMsg
  end

  local imageSuccess, image = pcall(function()
    return love.graphics.newImage(imageData)
  end)

  if imageSuccess then
    return image, imageData, nil
  else
    local errorMsg = string.format("Failed to create image: %s - %s", imagePath, tostring(image))
    -- Use ErrorHandler if available, otherwise fall back to print
    if ErrorHandler then
      ErrorHandler:warn("utils", "RES_004", {
        resourceType = "image",
        path = imagePath,
        error = tostring(image),
      })
    else
      print("[FlexLove] " .. errorMsg)
    end
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

-- Text sanitization utilities

--- Sanitize text to prevent security vulnerabilities
--- @param text string? Text to sanitize
--- @param options table? Sanitization options
--- @return string Sanitized text
local function sanitizeText(text, options)
  local utf8 = require("utf8")
  -- Handle nil or non-string inputs
  if text == nil then
    return ""
  end
  if type(text) ~= "string" then
    text = tostring(text)
  end

  -- Default options
  options = options or {}
  local maxLength = options.maxLength or 10000
  local allowNewlines = options.allowNewlines ~= false -- default true
  local allowTabs = options.allowTabs ~= false -- default true
  local stripControls = options.stripControls ~= false -- default true
  local trimWhitespace = options.trimWhitespace ~= false -- default true

  -- Remove null bytes (critical security risk)
  text = text:gsub("%z", "")

  -- Strip control characters except allowed ones
  if stripControls then
    local pattern = "[\1-\31\127]" -- All control characters
    if allowNewlines and allowTabs then
      pattern = "[\1-\8\11\12\14-\31\127]" -- Exclude \t (9), \n (10), \r (13)
    elseif allowNewlines then
      pattern = "[\1-\9\11\12\14-\31\127]" -- Exclude \n (10), \r (13)
    elseif allowTabs then
      pattern = "[\1-\8\10\12-\31\127]" -- Exclude \t (9)
    end
    text = text:gsub(pattern, "")
  end

  -- Trim leading/trailing whitespace
  if trimWhitespace then
    text = text:match("^%s*(.-)%s*$") or ""
  end

  -- Limit string length (use UTF-8 character count, not byte count)
  local charCount = utf8.len(text)
  if charCount and charCount > maxLength then
    if ErrorHandler then
      ErrorHandler:warn("utils", "UTIL_001", {
        original = charCount,
        truncated = maxLength,
      })
    end
    -- Truncate to maxLength UTF-8 characters
    local bytePos = utf8.offset(text, maxLength + 1)
    if bytePos then
      text = text:sub(1, bytePos - 1)
    end
    if ErrorHandler then
      ErrorHandler:warn("utils", string.format("Text truncated from %d to %d characters", charCount, maxLength))
    end
  end

  return text
end

--- Validate text input against rules
--- @param text string Text to validate
--- @param rules table Validation rules
--- @return boolean, string? Returns true if valid, or false with error message
local function validateTextInput(text, rules)
  rules = rules or {}

  -- Check minimum length
  if rules.minLength and #text < rules.minLength then
    return false, string.format("Text must be at least %d characters", rules.minLength)
  end

  -- Check maximum length
  if rules.maxLength and #text > rules.maxLength then
    return false, string.format("Text must be at most %d characters", rules.maxLength)
  end

  -- Check pattern match
  if rules.pattern and not text:match(rules.pattern) then
    return false, rules.patternError or "Text does not match required pattern"
  end

  -- Check character whitelist
  if rules.allowedChars then
    local pattern = "[^" .. rules.allowedChars .. "]"
    if text:match(pattern) then
      return false, "Text contains invalid characters"
    end
  end

  -- Check character blacklist
  if rules.forbiddenChars then
    local pattern = "[" .. rules.forbiddenChars .. "]"
    if text:match(pattern) then
      return false, "Text contains forbidden characters"
    end
  end

  return true, nil
end

--- Escape HTML special characters
--- @param text string Text to escape
--- @return string Escaped text
local function escapeHtml(text)
  if text == nil then
    return ""
  end
  text = tostring(text)
  text = text:gsub("&", "&amp;")
  text = text:gsub("<", "&lt;")
  text = text:gsub(">", "&gt;")
  text = text:gsub('"', "&quot;")
  text = text:gsub("'", "&#39;")
  return text
end

--- Escape Lua pattern special characters
--- @param text string Text to escape
--- @return string Escaped text
local function escapeLuaPattern(text)
  if text == nil then
    return ""
  end
  text = tostring(text)
  -- Escape all Lua pattern special characters
  text = text:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
  return text
end

--- Strip all non-printable characters from text
--- @param text string Text to clean
--- @return string Cleaned text
local function stripNonPrintable(text)
  if text == nil then
    return ""
  end
  text = tostring(text)
  -- Keep printable ASCII (32-126), newline (10), tab (9), and carriage return (13)
  text = text:gsub("[^\9\10\13\32-\126]", "")
  return text
end

-- Path validation utilities

--- Sanitize a file path
--- @param path string Path to sanitize
--- @return string Sanitized path
local function sanitizePath(path)
  if path == nil then
    return ""
  end
  path = tostring(path)

  -- Trim whitespace
  path = path:match("^%s*(.-)%s*$") or ""

  -- Normalize separators to forward slash
  path = path:gsub("\\", "/")

  -- Remove duplicate slashes
  path = path:gsub("/+", "/")

  -- Remove trailing slash (except for root)
  if #path > 1 and path:sub(-1) == "/" then
    path = path:sub(1, -2)
  end

  return path
end

--- Check if a path is safe (no traversal attacks)
--- @param path string Path to check
--- @param baseDir string? Base directory to check against (optional)
--- @return boolean, string? Returns true if safe, or false with reason
local function isPathSafe(path, baseDir)
  if path == nil or path == "" then
    return false, "Path is empty"
  end

  -- Sanitize the path
  path = sanitizePath(path)

  -- Check for suspicious patterns
  if path:match("%.%.") then
    return false, "Path contains '..' (parent directory reference)"
  end

  -- Check for null bytes
  if path:match("%z") then
    return false, "Path contains null bytes"
  end

  -- Check for encoded traversal attempts (including double-encoding)
  local lowerPath = path:lower()
  if
    lowerPath:match("%%2e")
    or lowerPath:match("%%2f")
    or lowerPath:match("%%5c")
    or lowerPath:match("%%252e")
    or lowerPath:match("%%252f")
    or lowerPath:match("%%255c")
  then
    return false, "Path contains URL-encoded directory separators"
  end

  -- If baseDir is provided, ensure path is within it
  if baseDir then
    baseDir = sanitizePath(baseDir)

    -- For relative paths, prepend baseDir
    local fullPath = path
    if not path:match("^/") and not path:match("^%a:") then
      fullPath = baseDir .. "/" .. path
    end
    fullPath = sanitizePath(fullPath)

    -- Check if fullPath starts with baseDir
    if not fullPath:match("^" .. baseDir:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")) then
      return false, "Path is outside allowed directory"
    end
  end

  return true, nil
end

--- Validate a file path with comprehensive checks
--- @param path string Path to validate
--- @param options table? Validation options
--- @return boolean, string? Returns true if valid, or false with error message
local function validatePath(path, options)
  options = options or {}

  -- Check path is not nil/empty
  if path == nil or path == "" then
    return false, "Path is empty"
  end

  path = tostring(path)

  -- Check maximum length
  local maxLength = options.maxLength or 4096
  if #path > maxLength then
    return false, string.format("Path exceeds maximum length of %d characters", maxLength)
  end

  -- Sanitize path
  path = sanitizePath(path)

  -- Check for safety (traversal attacks)
  local safe, reason = isPathSafe(path, options.baseDir)
  if not safe then
    return false, reason
  end

  -- Check allowed extensions
  if options.allowedExtensions then
    local ext = path:match("%.([^%.]+)$")
    if not ext then
      return false, "Path has no file extension"
    end

    ext = ext:lower()
    local allowed = false
    for _, allowedExt in ipairs(options.allowedExtensions) do
      if ext == allowedExt:lower() then
        allowed = true
        break
      end
    end

    if not allowed then
      return false, string.format("File extension '%s' is not allowed", ext)
    end
  end

  -- Check if file must exist
  if options.mustExist and love and love.filesystem then
    local info = love.filesystem.getInfo(path)
    if not info then
      return false, "File does not exist"
    end
  end

  return true, nil
end

--- Get file extension from path
--- @param path string File path
--- @return string? extension File extension (lowercase) or nil
local function getFileExtension(path)
  if not path then
    return nil
  end
  local ext = path:match("%.([^%.]+)$")
  return ext and ext:lower() or nil
end

--- Check if path has allowed extension
--- @param path string File path
--- @param allowedExtensions table Array of allowed extensions
--- @return boolean
local function hasAllowedExtension(path, allowedExtensions)
  local ext = getFileExtension(path)
  if not ext then
    return false
  end

  for _, allowedExt in ipairs(allowedExtensions) do
    if ext == allowedExt:lower() then
      return true
    end
  end

  return false
end

-- Numeric validation utilities

--- Check if a value is NaN (not-a-number)
--- @param value any Value to check
--- @return boolean
local function isNaN(value)
  return type(value) == "number" and value ~= value
end

--- Check if a value is Infinity
--- @param value any Value to check
--- @return boolean
local function isInfinity(value)
  return type(value) == "number" and (value == math.huge or value == -math.huge)
end

--- Validate a numeric value with comprehensive checks
--- @param value any Value to validate
--- @param options table? Validation options
--- @return boolean, string?, number? Returns valid, errorMessage, sanitizedValue
local function validateNumber(value, options)
  options = options or {}

  -- Check if value is a number type
  if type(value) ~= "number" then
    if options.default ~= nil then
      return true, nil, options.default
    end
    return false, string.format("Value must be a number, got %s", type(value)), nil
  end

  -- Check for NaN
  if isNaN(value) then
    if not options.allowNaN then
      if options.default ~= nil then
        return true, nil, options.default
      end
      return false, "Value is NaN (not-a-number)", nil
    end
  end

  -- Check for Infinity
  if isInfinity(value) then
    if not options.allowInfinity then
      if options.default ~= nil then
        return true, nil, options.default
      end
      return false, "Value is Infinity", nil
    end
  end

  -- Check for integer requirement
  if options.integer and math.floor(value) ~= value then
    return false, string.format("Value must be an integer, got %s", value), nil
  end

  -- Check for positive requirement
  if options.positive and value <= 0 then
    return false, string.format("Value must be positive, got %s", value), nil
  end

  -- Check bounds
  if options.min and value < options.min then
    return false, string.format("Value %s is below minimum %s", value, options.min), nil
  end

  if options.max and value > options.max then
    return false, string.format("Value %s is above maximum %s", value, options.max), nil
  end

  return true, nil, value
end

--- Sanitize a numeric value (never errors, always returns valid number)
--- @param value any Value to sanitize
--- @param min number? Minimum value
--- @param max number? Maximum value
--- @param default number? Default value for invalid inputs
--- @return number Sanitized value
local function sanitizeNumber(value, min, max, default)
  default = default or 0
  min = min or -math.huge
  max = max or math.huge

  -- Convert to number if possible
  if type(value) == "string" then
    value = tonumber(value)
  end

  -- Handle non-numeric
  if type(value) ~= "number" then
    return default
  end

  -- Handle NaN
  if isNaN(value) then
    return default
  end

  -- Handle Infinity
  if value == math.huge then
    return max
  end
  if value == -math.huge then
    return min
  end

  -- Clamp to range
  return clamp(value, min, max)
end

--- Validate and convert to integer
--- @param value any Value to validate
--- @param min number? Minimum value
--- @param max number? Maximum value
--- @return boolean, string?, number? Returns valid, errorMessage, integerValue
local function validateInteger(value, min, max)
  local valid, err, sanitized = validateNumber(value, {
    min = min,
    max = max,
    integer = true,
  })

  if not valid then
    return false, err, nil
  end

  return true, nil, math.floor(sanitized or value)
end

--- Validate and normalize percentage value
--- @param value any Value to validate (can be "50%", 0.5, or 50)
--- @return boolean, string?, number? Returns valid, errorMessage, normalizedValue (0-1)
local function validatePercentage(value)
  -- Handle string percentage
  if type(value) == "string" then
    local num = value:match("^(%d+%.?%d*)%%$")
    if num then
      value = tonumber(num)
      if value then
        value = value / 100
      end
    else
      value = tonumber(value)
    end
  end

  if type(value) ~= "number" then
    return false, "Percentage must be a number", nil
  end

  if isNaN(value) or isInfinity(value) then
    return false, "Percentage cannot be NaN or Infinity", nil
  end

  -- If value is > 1, assume it's 0-100 range
  if value > 1 then
    value = value / 100
  end

  -- Clamp to 0-1
  value = clamp(value, 0, 1)

  return true, nil, value
end

--- Validate opacity value (0-1)
--- @param value any Value to validate
--- @return boolean, string?, number? Returns valid, errorMessage, opacityValue
local function validateOpacity(value)
  return validateNumber(value, { min = 0, max = 1, default = 1 })
end

--- Validate degree value (0-360)
--- @param value any Value to validate
--- @return boolean, string?, number? Returns valid, errorMessage, degreeValue
local function validateDegrees(value)
  local valid, err, sanitized = validateNumber(value)
  if not valid then
    return false, err, nil
  end

  -- Normalize to 0-360 range
  local degrees = sanitized or value
  degrees = degrees % 360
  if degrees < 0 then
    degrees = degrees + 360
  end

  return true, nil, degrees
end

--- Validate coordinate value (pixel position)
--- @param value any Value to validate
--- @return boolean, string?, number? Returns valid, errorMessage, coordinateValue
local function validateCoordinate(value)
  return validateNumber(value, {
    allowNaN = false,
    allowInfinity = false,
  })
end

--- Validate dimension value (width/height, must be non-negative)
--- @param value any Value to validate
--- @return boolean, string?, number? Returns valid, errorMessage, dimensionValue
local function validateDimension(value)
  return validateNumber(value, {
    min = 0,
    allowNaN = false,
    allowInfinity = false,
  })
end

-- Font cache management

--- Get font cache statistics
---@return table stats {hits, misses, evictions, size, hitRate}
local function getFontCacheStats()
  local total = FONT_CACHE_STATS.hits + FONT_CACHE_STATS.misses
  local hitRate = total > 0 and (FONT_CACHE_STATS.hits / total) or 0
  return {
    hits = FONT_CACHE_STATS.hits,
    misses = FONT_CACHE_STATS.misses,
    evictions = FONT_CACHE_STATS.evictions,
    size = FONT_CACHE_STATS.size,
    hitRate = hitRate,
  }
end

--- Set maximum font cache size
---@param maxSize number Maximum number of fonts to cache
local function setFontCacheSize(maxSize)
  FONT_CACHE_MAX_SIZE = math.max(1, maxSize)

  -- Evict entries if cache is now over limit
  while FONT_CACHE_STATS.size > FONT_CACHE_MAX_SIZE do
    evictLRU()
  end
end

--- Clear font cache
local function clearFontCache()
  -- Clear cache entries but preserve methods (get, getFont)
  for key, entry in pairs(FONT_CACHE) do
    if type(entry) == "table" and entry.lastUsed then
      FONT_CACHE[key] = nil
    end
  end
  FONT_CACHE_STATS.size = 0
  FONT_CACHE_STATS.evictions = 0
end

--- Preload font at multiple sizes
---@param fontPath string? Path to font file (nil for default font)
---@param sizes table Array of font sizes to preload
local function preloadFont(fontPath, sizes)
  for _, size in ipairs(sizes) do
    -- Round size to reduce cache entries
    size = math.floor(size + 0.5)

    local cacheKey = fontPath and (fontPath .. ":" .. tostring(size)) or ("default:" .. tostring(size))

    if not FONT_CACHE[cacheKey] then
      local font
      if fontPath then
        local resolvedPath = resolveImagePath(fontPath)
        local success, result = pcall(love.graphics.newFont, resolvedPath, size)
        if success then
          font = result
        else
          font = love.graphics.newFont(size)
        end
      else
        font = love.graphics.newFont(size)
      end

      FONT_CACHE[cacheKey] = {
        font = font,
        lastUsed = love.timer.getTime(),
        accessCount = 1,
      }
      FONT_CACHE_STATS.size = FONT_CACHE_STATS.size + 1
      FONT_CACHE_STATS.misses = FONT_CACHE_STATS.misses + 1

      -- Evict if cache is full
      if FONT_CACHE_STATS.size > FONT_CACHE_MAX_SIZE then
        evictLRU()
      end
    end
  end
end

--- Reset font cache statistics
local function resetFontCacheStats()
  FONT_CACHE_STATS.hits = 0
  FONT_CACHE_STATS.misses = 0
  FONT_CACHE_STATS.evictions = 0
end

return {
  enums = enums,
  FONT_CACHE = FONT_CACHE,
  resolveTextSizePreset = resolveTextSizePreset,
  getModifiers = getModifiers,
  TEXT_SIZE_PRESETS = TEXT_SIZE_PRESETS,
  init = init,
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
  -- Text sanitization
  sanitizeText = sanitizeText,
  validateTextInput = validateTextInput,
  escapeHtml = escapeHtml,
  escapeLuaPattern = escapeLuaPattern,
  stripNonPrintable = stripNonPrintable,
  -- Path validation
  sanitizePath = sanitizePath,
  isPathSafe = isPathSafe,
  validatePath = validatePath,
  getFileExtension = getFileExtension,
  hasAllowedExtension = hasAllowedExtension,
  -- Font cache management
  getFontCacheStats = getFontCacheStats,
  setFontCacheSize = setFontCacheSize,
  clearFontCache = clearFontCache,
  preloadFont = preloadFont,
  resetFontCacheStats = resetFontCacheStats,
  -- Numeric validation
  isNaN = isNaN,
  isInfinity = isInfinity,
  validateNumber = validateNumber,
  sanitizeNumber = sanitizeNumber,
  validateInteger = validateInteger,
  validatePercentage = validatePercentage,
  validateOpacity = validateOpacity,
  validateDegrees = validateDegrees,
  validateCoordinate = validateCoordinate,
  validateDimension = validateDimension,
}
