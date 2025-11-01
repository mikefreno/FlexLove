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
      fsPath = fsPath:gsub("/flexlove$", "")
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

return {
  enums = enums,
  FONT_CACHE = FONT_CACHE,
  resolveTextSizePreset = resolveTextSizePreset,
  getModifiers = getModifiers,
}
