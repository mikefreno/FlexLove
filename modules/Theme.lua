--[[
Theme - Theme System for FlexLove
Manages theme loading, registration, and component/color/font access.
Supports 9-patch images, component states, and dynamic theme switching.
]]

local modulePath = (...):match("(.-)[^%.]+$")
local function req(name)
  return require(modulePath .. name)
end

local NinePatchParser = req("NinePatchParser")
local ImageScaler = req("ImageScaler")

--- Standardized error message formatter
---@param module string -- Module name (e.g., "Color", "Theme", "Units")
---@param message string -- Error message
---@return string -- Formatted error message
local function formatError(module, message)
  return string.format("[FlexLove.%s] %s", module, message)
end

--- Auto-detect the base path where FlexLove is located
---@return string modulePath, string filesystemPath
local function getFlexLoveBasePath()
  -- Get debug info to find where this file is loaded from
  local info = debug.getinfo(1, "S")
  if info and info.source then
    local source = info.source
    -- Remove leading @ if present
    if source:sub(1, 1) == "@" then
      source = source:sub(2)
    end

    -- Extract the directory path (remove Theme.lua and modules/)
    local filesystemPath = source:match("(.*/)")
    if filesystemPath then
      -- Store the original filesystem path for loading assets
      local fsPath = filesystemPath
      -- Remove leading ./ if present
      fsPath = fsPath:gsub("^%./", "")
      -- Remove trailing /
      fsPath = fsPath:gsub("/$", "")
      -- Remove the flexlove subdirectory to get back to base
      fsPath = fsPath:gsub("/modules$", "")

      -- Convert filesystem path to Lua module path
      local modulePath = fsPath:gsub("/", ".")

      return modulePath, fsPath
    end
  end

  -- Fallback: try common paths
  return "libs", "libs"
end

-- Store the base paths when module loads
local FLEXLOVE_BASE_PATH, FLEXLOVE_FILESYSTEM_PATH = getFlexLoveBasePath()

--- Helper function to resolve image paths relative to FlexLove
---@param imagePath string
---@return string
local function resolveImagePath(imagePath)
  -- If path is already absolute or starts with known LÖVE paths, use as-is
  if imagePath:match("^/") or imagePath:match("^[A-Z]:") then
    return imagePath
  end

  -- Otherwise, make it relative to FlexLove's location
  return FLEXLOVE_FILESYSTEM_PATH .. "/" .. imagePath
end

--- Safely load an image with error handling
--- Returns both Image and ImageData to avoid deprecated getData() API
---@param imagePath string
---@return love.Image?, love.ImageData?, string? -- Returns image, imageData, or nil with error message
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

--- Validate theme definition structure
---@param definition ThemeDefinition
---@return boolean, string? -- Returns true if valid, or false with error message
local function validateThemeDefinition(definition)
  if not definition then
    return false, "Theme definition is nil"
  end

  if type(definition) ~= "table" then
    return false, "Theme definition must be a table"
  end

  if not definition.name or type(definition.name) ~= "string" then
    return false, "Theme must have a 'name' field (string)"
  end

  if definition.components and type(definition.components) ~= "table" then
    return false, "Theme 'components' must be a table"
  end

  if definition.colors and type(definition.colors) ~= "table" then
    return false, "Theme 'colors' must be a table"
  end

  if definition.fonts and type(definition.fonts) ~= "table" then
    return false, "Theme 'fonts' must be a table"
  end

  return true, nil
end

---@class ThemeRegion
---@field x number -- X position in atlas
---@field y number -- Y position in atlas
---@field w number -- Width in atlas
---@field h number -- Height in atlas

---@class ThemeComponent
---@field atlas string|love.Image? -- Optional: component-specific atlas (overrides theme atlas). Files ending in .9.png are auto-parsed
---@field insets {left:number, top:number, right:number, bottom:number}? -- Optional: 9-patch insets (auto-extracted from .9.png files or manually defined)
---@field regions {topLeft:ThemeRegion, topCenter:ThemeRegion, topRight:ThemeRegion, middleLeft:ThemeRegion, middleCenter:ThemeRegion, middleRight:ThemeRegion, bottomLeft:ThemeRegion, bottomCenter:ThemeRegion, bottomRight:ThemeRegion}
---@field stretch {horizontal:table<integer, string>, vertical:table<integer, string>}
---@field states table<string, ThemeComponent>?
---@field contentAutoSizingMultiplier {width:number?, height:number?}? -- Optional: multiplier for auto-sized content dimensions
---@field scaleCorners number? -- Optional: scale multiplier for non-stretched regions (corners/edges). E.g., 2 = 2x size. Default: nil (no scaling)
---@field scalingAlgorithm "nearest"|"bilinear"? -- Optional: scaling algorithm for non-stretched regions. Default: "bilinear"
---@field _loadedAtlas string|love.Image? -- Internal: cached loaded atlas image
---@field _loadedAtlasData love.ImageData? -- Internal: cached loaded atlas ImageData for pixel access
---@field _ninePatchData {insets:table, contentPadding:table, stretchX:table, stretchY:table}? -- Internal: parsed 9-patch data with stretch regions and content padding
---@field _scaledRegionCache table<string, love.Image>? -- Internal: cache for scaled corner/edge images

---@class FontFamily
---@field path string -- Path to the font file (relative to FlexLove or absolute)
---@field _loadedFont love.Font? -- Internal: cached loaded font

---@class ThemeDefinition
---@field name string
---@field atlas string|love.Image? -- Optional: global atlas (can be overridden per component)
---@field components table<string, ThemeComponent>
---@field colors table<string, Color>?
---@field fonts table<string, string>? -- Optional: font family definitions (name -> path)
---@field contentAutoSizingMultiplier {width:number?, height:number?}? -- Optional: default multiplier for auto-sized content dimensions

---@class Theme
---@field name string
---@field atlas love.Image? -- Optional: global atlas
---@field atlasData love.ImageData?
---@field components table<string, ThemeComponent>
---@field colors table<string, Color>
---@field fonts table<string, string> -- Font family definitions
---@field contentAutoSizingMultiplier {width:number?, height:number?}? -- Optional: default multiplier for auto-sized content dimensions
local Theme = {}
Theme.__index = Theme

-- Global theme registry
local themes = {}
local activeTheme = nil

function Theme.new(definition)
  -- Validate theme definition
  local valid, err = validateThemeDefinition(definition)
  if not valid then
    error("[FlexLove] Invalid theme definition: " .. tostring(err))
  end

  local self = setmetatable({}, Theme)
  self.name = definition.name

  -- Load global atlas if it's a string path
  if definition.atlas then
    if type(definition.atlas) == "string" then
      local resolvedPath = resolveImagePath(definition.atlas)
      local image, imageData, loaderr = safeLoadImage(resolvedPath)
      if image then
        self.atlas = image
        self.atlasData = imageData
      else
        print("[FlexLove] Warning: Failed to load global atlas for theme '" .. definition.name .. "'" .. "(" .. loaderr .. ")")
      end
    else
      self.atlas = definition.atlas
    end
  end

  self.components = definition.components or {}
  self.colors = definition.colors or {}
  self.fonts = definition.fonts or {}
  self.contentAutoSizingMultiplier = definition.contentAutoSizingMultiplier or nil

  -- Helper function to strip 1-pixel guide border from 9-patch ImageData
  ---@param sourceImageData love.ImageData
  ---@return love.ImageData -- New ImageData without guide border
  local function stripNinePatchBorder(sourceImageData)
    local srcWidth = sourceImageData:getWidth()
    local srcHeight = sourceImageData:getHeight()

    -- Content dimensions (excluding 1px border on all sides)
    local contentWidth = srcWidth - 2
    local contentHeight = srcHeight - 2

    if contentWidth <= 0 or contentHeight <= 0 then
      error(formatError("NinePatch", "Image too small to strip border"))
    end

    -- Create new ImageData for content only
    local strippedImageData = love.image.newImageData(contentWidth, contentHeight)

    -- Copy pixels from source (1,1) to (width-2, height-2)
    for y = 0, contentHeight - 1 do
      for x = 0, contentWidth - 1 do
        local r, g, b, a = sourceImageData:getPixel(x + 1, y + 1)
        strippedImageData:setPixel(x, y, r, g, b, a)
      end
    end

    return strippedImageData
  end

  -- Helper function to load atlas with 9-patch support
  local function loadAtlasWithNinePatch(comp, atlasPath, errorContext)
    ---@diagnostic disable-next-line
    local resolvedPath = resolveImagePath(atlasPath)
    ---@diagnostic disable-next-line
    local is9Patch = not comp.insets and atlasPath:match("%.9%.png$")

    if is9Patch then
      local parseResult, parseErr = NinePatchParser.parse(resolvedPath)
      if parseResult then
        comp.insets = parseResult.insets
        comp._ninePatchData = parseResult
      else
        print("[FlexLove] Warning: Failed to parse 9-patch " .. errorContext .. ": " .. tostring(parseErr))
      end
    end

    local image, imageData, loaderr = safeLoadImage(resolvedPath)
    if image then
      -- Strip guide border for 9-patch images
      if is9Patch and imageData then
        local strippedImageData = stripNinePatchBorder(imageData)
        local strippedImage = love.graphics.newImage(strippedImageData)
        comp._loadedAtlas = strippedImage
        comp._loadedAtlasData = strippedImageData
      else
        comp._loadedAtlas = image
        comp._loadedAtlasData = imageData
      end
    else
      print("[FlexLove] Warning: Failed to load atlas " .. errorContext .. ": " .. tostring(loaderr))
    end
  end

  -- Helper function to create regions from insets
  local function createRegionsFromInsets(comp, fallbackAtlas)
    local atlasImage = comp._loadedAtlas or fallbackAtlas
    if not atlasImage or type(atlasImage) == "string" then
      return
    end

    local imgWidth, imgHeight = atlasImage:getDimensions()
    local left = comp.insets.left or 0
    local top = comp.insets.top or 0
    local right = comp.insets.right or 0
    local bottom = comp.insets.bottom or 0

    -- No offsets needed - guide border has been stripped for 9-patch images
    local centerWidth = imgWidth - left - right
    local centerHeight = imgHeight - top - bottom

    comp.regions = {
      topLeft = { x = 0, y = 0, w = left, h = top },
      topCenter = { x = left, y = 0, w = centerWidth, h = top },
      topRight = { x = left + centerWidth, y = 0, w = right, h = top },
      middleLeft = { x = 0, y = top, w = left, h = centerHeight },
      middleCenter = { x = left, y = top, w = centerWidth, h = centerHeight },
      middleRight = { x = left + centerWidth, y = top, w = right, h = centerHeight },
      bottomLeft = { x = 0, y = top + centerHeight, w = left, h = bottom },
      bottomCenter = { x = left, y = top + centerHeight, w = centerWidth, h = bottom },
      bottomRight = { x = left + centerWidth, y = top + centerHeight, w = right, h = bottom },
    }
  end

  -- Load component-specific atlases and process 9-patch definitions
  for componentName, component in pairs(self.components) do
    if component.atlas then
      if type(component.atlas) == "string" then
        loadAtlasWithNinePatch(component, component.atlas, "for component '" .. componentName .. "'")
      else
        -- Direct Image object (no ImageData available - scaleCorners won't work)
        component._loadedAtlas = component.atlas
      end
    end

    if component.insets then
      createRegionsFromInsets(component, self.atlas)
    end

    if component.states then
      for stateName, stateComponent in pairs(component.states) do
        if stateComponent.atlas then
          if type(stateComponent.atlas) == "string" then
            loadAtlasWithNinePatch(stateComponent, stateComponent.atlas, "for state '" .. stateName .. "'")
          else
            -- Direct Image object (no ImageData available - scaleCorners won't work)
            stateComponent._loadedAtlas = stateComponent.atlas
          end
        end

        if stateComponent.insets then
          createRegionsFromInsets(stateComponent, component._loadedAtlas or self.atlas)
        end
      end
    end
  end

  return self
end

--- Load a theme from a Lua file
---@param path string -- Path to theme definition file (e.g., "space" or "mytheme")
---@return Theme
function Theme.load(path)
  local definition

  -- Build the theme module path relative to FlexLove
  local themePath = FLEXLOVE_BASE_PATH .. ".themes." .. path

  local success, result = pcall(function()
    return require(themePath)
  end)

  if success then
    definition = result
  else
    -- Fallback: try as direct path
    success, result = pcall(function()
      return require(path)
    end)

    if success then
      definition = result
    else
      error("Failed to load theme '" .. path .. "'\nTried: " .. themePath .. "\nError: " .. tostring(result))
    end
  end

  local theme = Theme.new(definition)
  -- Register theme by both its display name and load path
  themes[theme.name] = theme
  themes[path] = theme

  return theme
end

--- Set the active theme
---@param themeOrName Theme|string
function Theme.setActive(themeOrName)
  if type(themeOrName) == "string" then
    -- Try to load if not already loaded
    if not themes[themeOrName] then
      Theme.load(themeOrName)
    end
    activeTheme = themes[themeOrName]
  else
    activeTheme = themeOrName
  end

  if not activeTheme then
    error("Failed to set active theme: " .. tostring(themeOrName))
  end
end

--- Get the active theme
---@return Theme?
function Theme.getActive()
  return activeTheme
end

--- Get a component from the active theme
---@param componentName string -- Name of the component (e.g., "button", "panel")
---@param state string? -- Optional state (e.g., "hover", "pressed", "disabled")
---@return ThemeComponent? -- Returns component or nil if not found
function Theme.getComponent(componentName, state)
  if not activeTheme then
    return nil
  end

  local component = activeTheme.components[componentName]
  if not component then
    return nil
  end

  -- Check for state-specific override
  if state and component.states and component.states[state] then
    return component.states[state]
  end

  return component
end

--- Get a font from the active theme
---@param fontName string -- Name of the font family (e.g., "default", "heading")
---@return string? -- Returns font path or nil if not found
function Theme.getFont(fontName)
  if not activeTheme then
    return nil
  end

  return activeTheme.fonts and activeTheme.fonts[fontName]
end

--- Get a color from the active theme
---@param colorName string -- Name of the color (e.g., "primary", "secondary")
---@return Color? -- Returns Color instance or nil if not found
function Theme.getColor(colorName)
  if not activeTheme then
    return nil
  end

  return activeTheme.colors and activeTheme.colors[colorName]
end

--- Check if a theme is currently active
---@return boolean -- Returns true if a theme is active
function Theme.hasActive()
  return activeTheme ~= nil
end

--- Get all registered theme names
---@return table<string> -- Array of theme names
function Theme.getRegisteredThemes()
  local themeNames = {}
  for name, _ in pairs(themes) do
    table.insert(themeNames, name)
  end
  return themeNames
end

--- Get all available color names from the active theme
---@return table<string>|nil -- Array of color names, or nil if no theme active
function Theme.getColorNames()
  if not activeTheme or not activeTheme.colors then
    return nil
  end

  local colorNames = {}
  for name, _ in pairs(activeTheme.colors) do
    table.insert(colorNames, name)
  end
  return colorNames
end

--- Get all colors from the active theme
---@return table<string, Color>|nil -- Table of all colors, or nil if no theme active
function Theme.getAllColors()
  if not activeTheme then
    return nil
  end

  return activeTheme.colors
end

--- Get a color with a fallback if not found
---@param colorName string -- Name of the color to retrieve
---@param fallback Color|nil -- Fallback color if not found (default: white)
---@return Color -- The color or fallback
function Theme.getColorOrDefault(colorName, fallback)
  local color = Theme.getColor(colorName)
  if color then
    return color
  end

  return fallback or Color.new(1, 1, 1, 1)
end

--- Get a theme by name
---@param themeName string -- Name of the theme
---@return Theme|nil -- Returns theme or nil if not found
function Theme.get(themeName)
  return themes[themeName]
end

return Theme
