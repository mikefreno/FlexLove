local modulePath = (...):match("(.-)[^%.]+$")
local function req(name)
  return require(modulePath .. name)
end

local NinePatchParser = req("NinePatchParser")
local Color = req("Color")
local utils = req("utils")
local ErrorHandler = req("ErrorHandler")

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

  -- Fallback: try a common path
  return "libs", "libs"
end

-- Store the base paths when module loads
local FLEXLOVE_BASE_PATH, FLEXLOVE_FILESYSTEM_PATH = getFlexLoveBasePath()

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
    ErrorHandler.error("Theme", "THM_001", "Invalid theme definition", {
      error = tostring(err)
    })
  end

  local self = setmetatable({}, Theme)
  self.name = definition.name

  -- Load global atlas if it's a string path
  if definition.atlas then
    if type(definition.atlas) == "string" then
      local resolvedPath = utils.resolveImagePath(definition.atlas)
      local image, imageData, loaderr = utils.safeLoadImage(resolvedPath)
      if image then
        self.atlas = image
        self.atlasData = imageData
      else
        ErrorHandler.warn("Theme", "RES_001", "Failed to load global atlas", {
          theme = definition.name,
          path = resolvedPath,
          error = loaderr
        })
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
      ErrorHandler.error("Theme", "RES_002", "Nine-patch image too small", {
        width = srcWidth,
        height = srcHeight,
        reason = "Image must be larger than 2x2 pixels to have content after stripping 1px border"
      })
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
    local resolvedPath = utils.resolveImagePath(atlasPath)
    ---@diagnostic disable-next-line
    local is9Patch = not comp.insets and atlasPath:match("%.9%.png$")

    if is9Patch then
      local parseResult, parseErr = NinePatchParser.parse(resolvedPath)
      if parseResult then
        comp.insets = parseResult.insets
        comp._ninePatchData = parseResult
      else
        ErrorHandler.warn("Theme", "RES_003", "Failed to parse nine-patch image", {
          context = errorContext,
          path = resolvedPath,
          error = tostring(parseErr)
        })
      end
    end

    local image, imageData, loaderr = utils.safeLoadImage(resolvedPath)
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
      ErrorHandler.warn("Theme", "RES_001", "Failed to load atlas", {
        context = errorContext,
        path = resolvedPath,
        error = tostring(loaderr)
      })
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
  local themePath = FLEXLOVE_BASE_PATH .. ".themes." .. path

  local success, result = pcall(function()
    return require(themePath)
  end)
  if success then
    definition = result
  else
    success, result = pcall(function()
      return require(path)
    end)
    if success then
      definition = result
    else
      ErrorHandler.warn("Theme", "RES_004", "Failed to load theme file", {
        theme = path,
        tried = themePath,
        error = tostring(result),
        fallback = "nil (no theme loaded)"
      }, "Check that the theme file exists in the themes/ directory or provide a valid module path")
      return nil
    end
  end

  local theme = Theme.new(definition)
  themes[theme.name] = theme
  themes[path] = theme

  return theme
end

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
    ErrorHandler.warn("Theme", "THM_002", "Failed to set active theme", {
      theme = tostring(themeOrName),
      reason = "Theme not found or not loaded",
      fallback = "current theme unchanged"
    }, "Ensure the theme is loaded with Theme.load() before setting it active")
    -- Keep current activeTheme unchanged (fallback behavior)
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

--------------------------------------------------------------------------------
-- ThemeManager: Instance-level theme state management
--------------------------------------------------------------------------------

---@class ThemeManager
---@field theme string? -- Override theme name
---@field themeComponent string? -- Component to use from theme
---@field _themeState string -- Current theme state (normal, hover, pressed, active, disabled)
---@field disabled boolean
---@field active boolean
---@field disableHighlight boolean -- If true, disable pressed highlight overlay
---@field scaleCorners number? -- Scale multiplier for 9-patch corners/edges
---@field scalingAlgorithm string? -- "nearest" or "bilinear" scaling for 9-patch
---@field _element Element? -- Reference to parent Element
local ThemeManager = {}
ThemeManager.__index = ThemeManager

---@param config table Configuration options
---@return ThemeManager
function ThemeManager.new(config)
  local self = setmetatable({}, ThemeManager)

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

---@return table?
function ThemeManager:getTheme()
  if self.theme then
    return Theme.get(self.theme)
  end
  return Theme.getActive()
end

---@return table?
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

---@return table?
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

---@param property string
---@return any?
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

---@return number?
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
      return themeToUse.contentAutoSizingMultiplier
    end
  end

  if themeToUse.contentAutoSizingMultiplier then
    return themeToUse.contentAutoSizingMultiplier
  end

  return nil
end

---@return string?
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

-- Export both Theme and ThemeManager
Theme.Manager = ThemeManager

---Validate a theme definition for structural correctness (non-aggressive)
---@param theme table? The theme to validate
---@param options table? Optional validation options {strict: boolean}
---@return boolean valid, table errors List of validation errors
function Theme.validateTheme(theme, options)
  local errors = {}
  options = options or {}

  -- Basic structure validation
  if theme == nil then
    table.insert(errors, "Theme is nil")
    return false, errors
  end

  if type(theme) ~= "table" then
    table.insert(errors, "Theme must be a table")
    return false, errors
  end

  -- Name validation (only required field)
  if not theme.name then
    table.insert(errors, "Theme must have a 'name' field")
  elseif type(theme.name) ~= "string" then
    table.insert(errors, "Theme 'name' must be a string")
  elseif theme.name == "" then
    table.insert(errors, "Theme 'name' cannot be empty")
  end

  -- Colors validation (optional, but if present must be valid)
  if theme.colors ~= nil then
    if type(theme.colors) ~= "table" then
      table.insert(errors, "Theme 'colors' must be a table")
    else
      for colorName, colorValue in pairs(theme.colors) do
        if type(colorName) ~= "string" then
          table.insert(errors, "Color name must be a string, got " .. type(colorName))
        else
          -- Accept Color objects, hex strings, or named colors
          local colorType = type(colorValue)
          if colorType == "table" then
            -- Assume it's a Color object if it has r,g,b fields
            if not (colorValue.r and colorValue.g and colorValue.b) then
              table.insert(errors, "Color '" .. colorName .. "' is not a valid Color object")
            end
          elseif colorType == "string" then
            -- Validate color string
            local isValid, err = Color.validateColor(colorValue)
            if not isValid then
              table.insert(errors, "Color '" .. colorName .. "': " .. err)
            end
          else
            table.insert(errors, "Color '" .. colorName .. "' must be a Color object or string")
          end
        end
      end
    end
  end

  -- Fonts validation (optional)
  if theme.fonts ~= nil then
    if type(theme.fonts) ~= "table" then
      table.insert(errors, "Theme 'fonts' must be a table")
    else
      for fontName, fontPath in pairs(theme.fonts) do
        if type(fontName) ~= "string" then
          table.insert(errors, "Font name must be a string, got " .. type(fontName))
        elseif type(fontPath) ~= "string" then
          table.insert(errors, "Font '" .. fontName .. "' path must be a string")
        end
      end
    end
  end

  -- Components validation (optional)
  if theme.components ~= nil then
    if type(theme.components) ~= "table" then
      table.insert(errors, "Theme 'components' must be a table")
    else
      for componentName, component in pairs(theme.components) do
        if type(component) == "table" then
          -- Validate atlas if present
          if component.atlas ~= nil and type(component.atlas) ~= "string" then
            table.insert(errors, "Component '" .. componentName .. "' atlas must be a string")
          end

          -- Validate insets if present
          if component.insets ~= nil then
            if type(component.insets) ~= "table" then
              table.insert(errors, "Component '" .. componentName .. "' insets must be a table")
            else
              -- If insets are provided, all 4 sides must be present
              for _, side in ipairs({ "left", "top", "right", "bottom" }) do
                if component.insets[side] == nil then
                  table.insert(errors, "Component '" .. componentName .. "' insets must have '" .. side .. "' field")
                elseif type(component.insets[side]) ~= "number" then
                  table.insert(errors, "Component '" .. componentName .. "' insets." .. side .. " must be a number")
                elseif component.insets[side] < 0 then
                  table.insert(errors, "Component '" .. componentName .. "' insets." .. side .. " must be non-negative")
                end
              end
            end
          end

          -- Validate states if present
          if component.states ~= nil then
            if type(component.states) ~= "table" then
              table.insert(errors, "Component '" .. componentName .. "' states must be a table")
            else
              for stateName, stateComponent in pairs(component.states) do
                if type(stateComponent) ~= "table" then
                  table.insert(errors, "Component '" .. componentName .. "' state '" .. stateName .. "' must be a table")
                end
              end
            end
          end

          -- Validate scaleCorners if present
          if component.scaleCorners ~= nil then
            if type(component.scaleCorners) ~= "number" then
              table.insert(errors, "Component '" .. componentName .. "' scaleCorners must be a number")
            elseif component.scaleCorners <= 0 then
              table.insert(errors, "Component '" .. componentName .. "' scaleCorners must be positive")
            end
          end

          -- Validate scalingAlgorithm if present
          if component.scalingAlgorithm ~= nil then
            if type(component.scalingAlgorithm) ~= "string" then
              table.insert(errors, "Component '" .. componentName .. "' scalingAlgorithm must be a string")
            elseif component.scalingAlgorithm ~= "nearest" and component.scalingAlgorithm ~= "bilinear" then
              table.insert(errors, "Component '" .. componentName .. "' scalingAlgorithm must be 'nearest' or 'bilinear'")
            end
          end
        end
      end
    end
  end

  -- contentAutoSizingMultiplier validation (optional)
  if theme.contentAutoSizingMultiplier ~= nil then
    if type(theme.contentAutoSizingMultiplier) ~= "table" then
      table.insert(errors, "Theme 'contentAutoSizingMultiplier' must be a table")
    else
      if theme.contentAutoSizingMultiplier.width ~= nil then
        if type(theme.contentAutoSizingMultiplier.width) ~= "number" then
          table.insert(errors, "contentAutoSizingMultiplier.width must be a number")
        elseif theme.contentAutoSizingMultiplier.width <= 0 then
          table.insert(errors, "contentAutoSizingMultiplier.width must be positive")
        end
      end
      if theme.contentAutoSizingMultiplier.height ~= nil then
        if type(theme.contentAutoSizingMultiplier.height) ~= "number" then
          table.insert(errors, "contentAutoSizingMultiplier.height must be a number")
        elseif theme.contentAutoSizingMultiplier.height <= 0 then
          table.insert(errors, "contentAutoSizingMultiplier.height must be positive")
        end
      end
    end
  end

  -- Global atlas validation (optional)
  if theme.atlas ~= nil then
    if type(theme.atlas) ~= "string" then
      table.insert(errors, "Theme 'atlas' must be a string")
    end
  end

  -- Strict mode: warn about unknown fields
  if options.strict then
    local knownFields = {
      name = true,
      atlas = true,
      components = true,
      colors = true,
      fonts = true,
      contentAutoSizingMultiplier = true,
    }
    for field in pairs(theme) do
      if not knownFields[field] then
        table.insert(errors, "Unknown field '" .. field .. "' in theme")
      end
    end
  end

  return #errors == 0, errors
end

---Sanitize a theme definition by removing invalid values and providing defaults
---@param theme table? The theme to sanitize
---@return table sanitized The sanitized theme
function Theme.sanitizeTheme(theme)
  local sanitized = {}

  -- Handle nil theme
  if theme == nil then
    return { name = "Invalid Theme" }
  end

  -- Handle non-table theme
  if type(theme) ~= "table" then
    return { name = "Invalid Theme" }
  end

  -- Sanitize name
  if type(theme.name) == "string" and theme.name ~= "" then
    sanitized.name = theme.name
  else
    sanitized.name = "Unnamed Theme"
  end

  -- Sanitize colors
  if type(theme.colors) == "table" then
    sanitized.colors = {}
    for colorName, colorValue in pairs(theme.colors) do
      if type(colorName) == "string" then
        local colorType = type(colorValue)
        if colorType == "table" and colorValue.r and colorValue.g and colorValue.b then
          -- Valid Color object
          sanitized.colors[colorName] = colorValue
        elseif colorType == "string" then
          -- Try to validate color string
          local isValid = Color.validateColor(colorValue)
          if isValid then
            sanitized.colors[colorName] = colorValue
          else
            -- Provide fallback color
            sanitized.colors[colorName] = Color.new(0, 0, 0, 1)
          end
        end
      end
    end
  end

  -- Sanitize fonts
  if type(theme.fonts) == "table" then
    sanitized.fonts = {}
    for fontName, fontPath in pairs(theme.fonts) do
      if type(fontName) == "string" and type(fontPath) == "string" then
        sanitized.fonts[fontName] = fontPath
      end
    end
  end

  -- Sanitize components (preserve as-is, they're complex)
  if type(theme.components) == "table" then
    sanitized.components = theme.components
  end

  -- Sanitize contentAutoSizingMultiplier
  if type(theme.contentAutoSizingMultiplier) == "table" then
    sanitized.contentAutoSizingMultiplier = {}
    if type(theme.contentAutoSizingMultiplier.width) == "number" and theme.contentAutoSizingMultiplier.width > 0 then
      sanitized.contentAutoSizingMultiplier.width = theme.contentAutoSizingMultiplier.width
    end
    if type(theme.contentAutoSizingMultiplier.height) == "number" and theme.contentAutoSizingMultiplier.height > 0 then
      sanitized.contentAutoSizingMultiplier.height = theme.contentAutoSizingMultiplier.height
    end
  end

  -- Sanitize atlas
  if type(theme.atlas) == "string" then
    sanitized.atlas = theme.atlas
  end

  return sanitized
end

return Theme
