--[[
FlexLove - UI Library for LÖVE Framework 'based' on flexbox
VERSION: 1.0.0
LICENSE: MIT
For full documentation, see README.md
]]

-- ====================
-- fast Gaussian blur
-- ====================

local Blur = {}

-- Canvas cache to avoid recreating canvases every frame
local canvasCache = {}
local MAX_CACHE_SIZE = 20

--- Build Gaussian blur shader with given parameters
---@param taps number -- Number of samples (must be odd, >= 3)
---@param offset number -- Offset multiplier for sampling
---@param offset_type string -- "weighted" or "center"
---@param sigma number -- Gaussian sigma value
---@return love.Shader
local function buildShader(taps, offset, offset_type, sigma)
  taps = math.floor(taps)
  sigma = sigma >= 1 and sigma or (taps - 1) * offset / 6
  sigma = math.max(sigma, 1)

  local steps = (taps + 1) / 2

  -- Calculate gaussian function
  local g_offsets = {}
  local g_weights = {}
  for i = 1, steps, 1 do
    g_offsets[i] = offset * (i - 1)
    g_weights[i] = math.exp(-0.5 * (g_offsets[i] - 0) ^ 2 * 1 / sigma ^ 2)
  end

  -- Calculate offsets and weights for sub-pixel samples
  local offsets = {}
  local weights = {}
  for i = #g_weights, 2, -2 do
    local oA, oB = g_offsets[i], g_offsets[i - 1]
    local wA, wB = g_weights[i], g_weights[i - 1]
    wB = oB == 0 and wB / 2 or wB
    local weight = wA + wB
    offsets[#offsets + 1] = offset_type == "center" and (oA + oB) / 2 or (oA * wA + oB * wB) / weight
    weights[#weights + 1] = weight
  end

  local code = { [[
    extern vec2 direction;
    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {]] }

  local norm = 0
  if #g_weights % 2 == 0 then
    code[#code + 1] = "vec4 c = vec4( 0.0 );"
  else
    local weight = g_weights[1]
    norm = norm + weight
    code[#code + 1] = ("vec4 c = %f * texture2D(tex, tc);"):format(weight)
  end

  local tmpl = "c += %f * ( texture2D(tex, tc + %f * direction)+ texture2D(tex, tc - %f * direction));\n"
  for i = 1, #offsets, 1 do
    local offset = offsets[i]
    local weight = weights[i]
    norm = norm + weight * 2
    code[#code + 1] = tmpl:format(weight, offset, offset)
  end
  code[#code + 1] = ("return c * vec4(%f) * color; }"):format(1 / norm)

  local shader = table.concat(code)
  return love.graphics.newShader(shader)
end

--- Get or create a canvas from cache
---@param width number
---@param height number
---@return love.Canvas
local function getCanvas(width, height)
  local key = string.format("%dx%d", width, height)

  if not canvasCache[key] then
    canvasCache[key] = {}
  end

  local cache = canvasCache[key]

  -- Try to reuse existing canvas
  for i, canvas in ipairs(cache) do
    if not canvas.inUse then
      canvas.inUse = true
      return canvas.canvas
    end
  end

  -- Create new canvas if none available
  local canvas = love.graphics.newCanvas(width, height)
  table.insert(cache, { canvas = canvas, inUse = true })

  -- Limit cache size
  if #cache > MAX_CACHE_SIZE then
    table.remove(cache, 1)
  end

  return canvas
end

--- Release a canvas back to the cache
---@param canvas love.Canvas
local function releaseCanvas(canvas)
  for _, sizeCache in pairs(canvasCache) do
    for _, entry in ipairs(sizeCache) do
      if entry.canvas == canvas then
        entry.inUse = false
        return
      end
    end
  end
end

--- Create a blur effect instance
---@param quality number -- Quality level (1-10, higher = better quality but slower)
---@return table -- Blur effect instance
function Blur.new(quality)
  quality = math.max(1, math.min(10, quality or 5))

  -- Map quality to shader parameters
  -- Quality 1: 3 taps (fastest, lowest quality)
  -- Quality 5: 7 taps (balanced)
  -- Quality 10: 15 taps (slowest, highest quality)
  local taps = 3 + (quality - 1) * 1.5
  taps = math.floor(taps)
  if taps % 2 == 0 then
    taps = taps + 1 -- Ensure odd number
  end

  local offset = 1.0
  local offset_type = "weighted"
  local sigma = -1

  local shader = buildShader(taps, offset, offset_type, sigma)

  local instance = {
    shader = shader,
    quality = quality,
    taps = taps,
  }

  return instance
end

--- Apply blur to a region of the screen
---@param blurInstance table -- Blur effect instance from Blur.new()
---@param intensity number -- Blur intensity (0-100)
---@param x number -- X position
---@param y number -- Y position
---@param width number -- Width
---@param height number -- Height
---@param drawFunc function -- Function to draw content to be blurred
function Blur.applyToRegion(blurInstance, intensity, x, y, width, height, drawFunc)
  if intensity <= 0 or width <= 0 or height <= 0 then
    -- No blur, just draw normally
    drawFunc()
    return
  end

  -- Clamp intensity
  intensity = math.max(0, math.min(100, intensity))

  -- Calculate blur passes based on intensity
  -- Intensity 0-100 maps to 0-5 passes
  local passes = math.ceil(intensity / 20)
  passes = math.max(1, math.min(5, passes))

  -- Get canvases for ping-pong rendering
  local canvas1 = getCanvas(width, height)
  local canvas2 = getCanvas(width, height)

  -- Save graphics state
  local prevCanvas = love.graphics.getCanvas()
  local prevShader = love.graphics.getShader()
  local prevColor = { love.graphics.getColor() }
  local prevBlendMode = love.graphics.getBlendMode()

  -- Render content to first canvas
  love.graphics.setCanvas(canvas1)
  love.graphics.clear()
  love.graphics.push()
  love.graphics.origin()
  love.graphics.translate(-x, -y)
  drawFunc()
  love.graphics.pop()

  -- Apply blur passes
  love.graphics.setShader(blurInstance.shader)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setBlendMode("alpha", "premultiplied")

  for i = 1, passes do
    -- Horizontal pass
    love.graphics.setCanvas(canvas2)
    love.graphics.clear()
    blurInstance.shader:send("direction", { 1 / width, 0 })
    love.graphics.draw(canvas1, 0, 0)

    -- Vertical pass
    love.graphics.setCanvas(canvas1)
    love.graphics.clear()
    blurInstance.shader:send("direction", { 0, 1 / height })
    love.graphics.draw(canvas2, 0, 0)
  end

  -- Draw blurred result to screen
  love.graphics.setCanvas(prevCanvas)
  love.graphics.setShader()
  love.graphics.setBlendMode(prevBlendMode)
  love.graphics.draw(canvas1, x, y)

  -- Restore graphics state
  love.graphics.setShader(prevShader)
  love.graphics.setColor(unpack(prevColor))

  -- Release canvases back to cache
  releaseCanvas(canvas1)
  releaseCanvas(canvas2)
end

--- Apply backdrop blur effect (blur content behind a region)
---@param blurInstance table -- Blur effect instance from Blur.new()
---@param intensity number -- Blur intensity (0-100)
---@param x number -- X position
---@param y number -- Y position
---@param width number -- Width
---@param height number -- Height
---@param backdropCanvas love.Canvas -- Canvas containing the backdrop content
function Blur.applyBackdrop(blurInstance, intensity, x, y, width, height, backdropCanvas)
  if intensity <= 0 or width <= 0 or height <= 0 then
    return
  end

  -- Clamp intensity
  intensity = math.max(0, math.min(100, intensity))

  -- Calculate blur passes based on intensity
  local passes = math.ceil(intensity / 20)
  passes = math.max(1, math.min(5, passes))

  -- Get canvases for ping-pong rendering
  local canvas1 = getCanvas(width, height)
  local canvas2 = getCanvas(width, height)

  -- Save graphics state
  local prevCanvas = love.graphics.getCanvas()
  local prevShader = love.graphics.getShader()
  local prevColor = { love.graphics.getColor() }
  local prevBlendMode = love.graphics.getBlendMode()

  -- Extract the region from backdrop
  love.graphics.setCanvas(canvas1)
  love.graphics.clear()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setBlendMode("alpha", "premultiplied")

  -- Create a quad for the region
  local backdropWidth, backdropHeight = backdropCanvas:getDimensions()
  local quad = love.graphics.newQuad(x, y, width, height, backdropWidth, backdropHeight)
  love.graphics.draw(backdropCanvas, quad, 0, 0)

  -- Apply blur passes
  love.graphics.setShader(blurInstance.shader)

  for i = 1, passes do
    -- Horizontal pass
    love.graphics.setCanvas(canvas2)
    love.graphics.clear()
    blurInstance.shader:send("direction", { 1 / width, 0 })
    love.graphics.draw(canvas1, 0, 0)

    -- Vertical pass
    love.graphics.setCanvas(canvas1)
    love.graphics.clear()
    blurInstance.shader:send("direction", { 0, 1 / height })
    love.graphics.draw(canvas2, 0, 0)
  end

  -- Draw blurred result to screen
  love.graphics.setCanvas(prevCanvas)
  love.graphics.setShader()
  love.graphics.setBlendMode(prevBlendMode)
  love.graphics.draw(canvas1, x, y)

  -- Restore graphics state
  love.graphics.setShader(prevShader)
  love.graphics.setColor(unpack(prevColor))

  -- Release canvases back to cache
  releaseCanvas(canvas1)
  releaseCanvas(canvas2)
end

--- Clear canvas cache (call on window resize)
function Blur.clearCache()
  canvasCache = {}
end

-- ====================
-- Error Handling Utilities
-- ====================

--- Standardized error message formatter
---@param module string -- Module name (e.g., "Color", "Theme", "Units")
---@param message string -- Error message
---@return string -- Formatted error message
local function formatError(module, message)
  return string.format("[FlexLove.%s] %s", module, message)
end

--- Top level GUI manager
---@class Gui
---@field topElements table<integer, Element>
---@field baseScale {width:number, height:number}?
---@field scaleFactors {x:number, y:number}
---@field defaultTheme string? -- Default theme name to use for elements
local Gui = {
  topElements = {},
  baseScale = nil,
  scaleFactors = { x = 1.0, y = 1.0 },
  defaultTheme = nil,
  _cachedViewport = { width = 0, height = 0 }, -- Cached viewport dimensions
  _focusedElement = nil, -- Currently focused element for keyboard input
}

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
    return Color.new(r, g, b, 1)
  elseif #hex == 8 then
    local r = tonumber("0x" .. hex:sub(1, 2))
    local g = tonumber("0x" .. hex:sub(3, 4))
    local b = tonumber("0x" .. hex:sub(5, 6))
    local a = tonumber("0x" .. hex:sub(7, 8))
    if not r or not g or not b or not a then
      error(formatError("Color", string.format("Invalid hex string format: '%s'. Contains invalid hex digits", hexWithTag)))
    end
    return Color.new(r, g, b, a / 255)
  else
    error(formatError("Color", string.format("Invalid hex string format: '%s'. Expected #RRGGBB or #RRGGBBAA", hexWithTag)))
  end
end

-- ====================
-- ImageDataReader
-- ====================

local ImageDataReader = {}

--- Load ImageData from a file path
---@param imagePath string
---@return love.ImageData
function ImageDataReader.loadImageData(imagePath)
  if not imagePath then
    error(formatError("ImageDataReader", "Image path cannot be nil"))
  end

  local success, result = pcall(function()
    return love.image.newImageData(imagePath)
  end)

  if not success then
    error(formatError("ImageDataReader", "Failed to load image data from '" .. imagePath .. "': " .. tostring(result)))
  end

  return result
end

--- Extract all pixels from a specific row
---@param imageData love.ImageData
---@param rowIndex number -- 0-based row index
---@return table -- Array of {r, g, b, a} values (0-255 range)
function ImageDataReader.getRow(imageData, rowIndex)
  if not imageData then
    error(formatError("ImageDataReader", "ImageData cannot be nil"))
  end

  local width = imageData:getWidth()
  local height = imageData:getHeight()

  if rowIndex < 0 or rowIndex >= height then
    error(formatError("ImageDataReader", string.format("Row index %d out of bounds (height: %d)", rowIndex, height)))
  end

  local pixels = {}
  for x = 0, width - 1 do
    local r, g, b, a = imageData:getPixel(x, rowIndex)
    table.insert(pixels, {
      r = math.floor(r * 255 + 0.5),
      g = math.floor(g * 255 + 0.5),
      b = math.floor(b * 255 + 0.5),
      a = math.floor(a * 255 + 0.5),
    })
  end

  return pixels
end

--- Extract all pixels from a specific column
---@param imageData love.ImageData
---@param colIndex number -- 0-based column index
---@return table -- Array of {r, g, b, a} values (0-255 range)
function ImageDataReader.getColumn(imageData, colIndex)
  if not imageData then
    error(formatError("ImageDataReader", "ImageData cannot be nil"))
  end

  local width = imageData:getWidth()
  local height = imageData:getHeight()

  if colIndex < 0 or colIndex >= width then
    error(formatError("ImageDataReader", string.format("Column index %d out of bounds (width: %d)", colIndex, width)))
  end

  local pixels = {}
  for y = 0, height - 1 do
    local r, g, b, a = imageData:getPixel(colIndex, y)
    table.insert(pixels, {
      r = math.floor(r * 255 + 0.5),
      g = math.floor(g * 255 + 0.5),
      b = math.floor(b * 255 + 0.5),
      a = math.floor(a * 255 + 0.5),
    })
  end

  return pixels
end

--- Check if a pixel is black with full alpha (9-patch marker)
---@param r number -- Red (0-255)
---@param g number -- Green (0-255)
---@param b number -- Blue (0-255)
---@param a number -- Alpha (0-255)
---@return boolean
function ImageDataReader.isBlackPixel(r, g, b, a)
  return r == 0 and g == 0 and b == 0 and a == 255
end

-- ====================
-- NinePatchParser
-- ====================

local NinePatchParser = {}

--- Find all continuous runs of black pixels in a pixel array
---@param pixels table -- Array of {r, g, b, a} pixel values
---@return table -- Array of {start, end} pairs (1-based indices, inclusive)
local function findBlackPixelRuns(pixels)
  local runs = {}
  local inRun = false
  local runStart = nil

  for i = 1, #pixels do
    local pixel = pixels[i]
    local isBlack = ImageDataReader.isBlackPixel(pixel.r, pixel.g, pixel.b, pixel.a)

    if isBlack and not inRun then
      -- Start of a new run
      inRun = true
      runStart = i
    elseif not isBlack and inRun then
      -- End of current run
      table.insert(runs, { start = runStart, ["end"] = i - 1 })
      inRun = false
      runStart = nil
    end
  end

  -- Handle case where run extends to end of array
  if inRun then
    table.insert(runs, { start = runStart, ["end"] = #pixels })
  end

  return runs
end

--- Parse a 9-patch PNG image to extract stretch regions and content padding
---@param imagePath string -- Path to the 9-patch image file
---@return table|nil, string|nil -- Returns {insets, stretchX, stretchY} or nil, error message
function NinePatchParser.parse(imagePath)
  if not imagePath then
    return nil, "Image path cannot be nil"
  end

  local success, imageData = pcall(function()
    return ImageDataReader.loadImageData(imagePath)
  end)

  if not success then
    return nil, "Failed to load image data: " .. tostring(imageData)
  end

  local width = imageData:getWidth()
  local height = imageData:getHeight()

  -- Validate minimum size (must be at least 3x3 with 1px border)
  if width < 3 or height < 3 then
    return nil, string.format("Invalid 9-patch dimensions: %dx%d (minimum 3x3)", width, height)
  end

  -- Extract border pixels (0-based indexing, but we convert to 1-based for processing)
  local topBorder = ImageDataReader.getRow(imageData, 0)
  local leftBorder = ImageDataReader.getColumn(imageData, 0)
  local bottomBorder = ImageDataReader.getRow(imageData, height - 1)
  local rightBorder = ImageDataReader.getColumn(imageData, width - 1)

  -- Remove corner pixels from borders (they're not part of the stretch/content markers)
  -- Top and bottom borders: remove first and last pixel
  local topStretchPixels = {}
  local bottomContentPixels = {}
  for i = 2, #topBorder - 1 do
    table.insert(topStretchPixels, topBorder[i])
  end
  for i = 2, #bottomBorder - 1 do
    table.insert(bottomContentPixels, bottomBorder[i])
  end

  -- Left and right borders: remove first and last pixel
  local leftStretchPixels = {}
  local rightContentPixels = {}
  for i = 2, #leftBorder - 1 do
    table.insert(leftStretchPixels, leftBorder[i])
  end
  for i = 2, #rightBorder - 1 do
    table.insert(rightContentPixels, rightBorder[i])
  end

  -- Find stretch regions (top and left borders)
  local stretchX = findBlackPixelRuns(topStretchPixels)
  local stretchY = findBlackPixelRuns(leftStretchPixels)

  -- Find content padding regions (bottom and right borders)
  local contentX = findBlackPixelRuns(bottomContentPixels)
  local contentY = findBlackPixelRuns(rightContentPixels)

  -- Validate that we have at least one stretch region
  if #stretchX == 0 or #stretchY == 0 then
    return nil, "No stretch regions found (top or left border has no black pixels)"
  end

  -- Calculate stretch insets from stretch regions (top/left guides)
  -- Use the first stretch region's start and last stretch region's end
  local firstStretchX = stretchX[1]
  local lastStretchX = stretchX[#stretchX]
  local firstStretchY = stretchY[1]
  local lastStretchY = stretchY[#stretchY]

  -- Stretch insets define the 9-slice regions
  local stretchLeft = firstStretchX.start
  local stretchRight = #topStretchPixels - lastStretchX["end"]
  local stretchTop = firstStretchY.start
  local stretchBottom = #leftStretchPixels - lastStretchY["end"]

  -- Calculate content padding from content guides (bottom/right guides)
  -- If content padding is defined, use it; otherwise use stretch regions
  local contentLeft, contentRight, contentTop, contentBottom

  if #contentX > 0 then
    contentLeft = contentX[1].start
    contentRight = #topStretchPixels - contentX[#contentX]["end"]
  else
    contentLeft = stretchLeft
    contentRight = stretchRight
  end

  if #contentY > 0 then
    contentTop = contentY[1].start
    contentBottom = #leftStretchPixels - contentY[#contentY]["end"]
  else
    contentTop = stretchTop
    contentBottom = stretchBottom
  end

  return {
    insets = {
      left = stretchLeft,
      top = stretchTop,
      right = stretchRight,
      bottom = stretchBottom,
    },
    contentPadding = {
      left = contentLeft,
      top = contentTop,
      right = contentRight,
      bottom = contentBottom,
    },
    stretchX = stretchX,
    stretchY = stretchY,
  }
end

-- ====================
-- ImageScaler
-- ====================

local ImageScaler = {}

--- Scale an ImageData region using nearest-neighbor sampling
--- Produces sharp, pixelated scaling - ideal for pixel art
---@param sourceImageData love.ImageData -- Source image data
---@param srcX number -- Source region X (0-based)
---@param srcY number -- Source region Y (0-based)
---@param srcW number -- Source region width
---@param srcH number -- Source region height
---@param destW number -- Destination width
---@param destH number -- Destination height
---@return love.ImageData -- Scaled image data
function ImageScaler.scaleNearest(sourceImageData, srcX, srcY, srcW, srcH, destW, destH)
  if not sourceImageData then
    error(formatError("ImageScaler", "Source ImageData cannot be nil"))
  end

  if srcW <= 0 or srcH <= 0 or destW <= 0 or destH <= 0 then
    error(formatError("ImageScaler", "Dimensions must be positive"))
  end

  -- Create destination ImageData
  local destImageData = love.image.newImageData(destW, destH)

  -- Calculate scale ratios (cached outside loops for performance)
  local scaleX = srcW / destW
  local scaleY = srcH / destH

  -- Nearest-neighbor sampling
  for destY = 0, destH - 1 do
    for destX = 0, destW - 1 do
      -- Calculate source pixel coordinates using floor (nearest-neighbor)
      local srcPixelX = math.floor(destX * scaleX) + srcX
      local srcPixelY = math.floor(destY * scaleY) + srcY

      -- Clamp to source bounds (safety check)
      srcPixelX = math.min(srcPixelX, srcX + srcW - 1)
      srcPixelY = math.min(srcPixelY, srcY + srcH - 1)

      -- Sample source pixel
      local r, g, b, a = sourceImageData:getPixel(srcPixelX, srcPixelY)

      -- Write to destination
      destImageData:setPixel(destX, destY, r, g, b, a)
    end
  end

  return destImageData
end

--- Linear interpolation helper
--- Blends between two values based on interpolation factor
---@param a number -- Start value
---@param b number -- End value
---@param t number -- Interpolation factor [0, 1]
---@return number -- Interpolated value
local function lerp(a, b, t)
  return a + (b - a) * t
end

--- Scale an ImageData region using bilinear interpolation
--- Produces smooth, filtered scaling - ideal for high-quality upscaling
---@param sourceImageData love.ImageData -- Source image data
---@param srcX number -- Source region X (0-based)
---@param srcY number -- Source region Y (0-based)
---@param srcW number -- Source region width
---@param srcH number -- Source region height
---@param destW number -- Destination width
---@param destH number -- Destination height
---@return love.ImageData -- Scaled image data
function ImageScaler.scaleBilinear(sourceImageData, srcX, srcY, srcW, srcH, destW, destH)
  if not sourceImageData then
    error(formatError("ImageScaler", "Source ImageData cannot be nil"))
  end

  if srcW <= 0 or srcH <= 0 or destW <= 0 or destH <= 0 then
    error(formatError("ImageScaler", "Dimensions must be positive"))
  end

  -- Create destination ImageData
  local destImageData = love.image.newImageData(destW, destH)

  -- Calculate scale ratios
  local scaleX = srcW / destW
  local scaleY = srcH / destH

  -- Bilinear interpolation
  for destY = 0, destH - 1 do
    for destX = 0, destW - 1 do
      -- Calculate fractional source position
      local srcXf = destX * scaleX
      local srcYf = destY * scaleY

      -- Get integer coordinates for 2x2 sampling grid
      local x0 = math.floor(srcXf)
      local y0 = math.floor(srcYf)
      local x1 = math.min(x0 + 1, srcW - 1)
      local y1 = math.min(y0 + 1, srcH - 1)

      -- Get fractional parts for interpolation
      local fx = srcXf - x0
      local fy = srcYf - y0

      -- Sample 4 neighboring pixels (with source offset)
      local r00, g00, b00, a00 = sourceImageData:getPixel(srcX + x0, srcY + y0)
      local r10, g10, b10, a10 = sourceImageData:getPixel(srcX + x1, srcY + y0)
      local r01, g01, b01, a01 = sourceImageData:getPixel(srcX + x0, srcY + y1)
      local r11, g11, b11, a11 = sourceImageData:getPixel(srcX + x1, srcY + y1)

      -- Interpolate horizontally (top and bottom rows)
      local rTop = lerp(r00, r10, fx)
      local gTop = lerp(g00, g10, fx)
      local bTop = lerp(b00, b10, fx)
      local aTop = lerp(a00, a10, fx)

      local rBottom = lerp(r01, r11, fx)
      local gBottom = lerp(g01, g11, fx)
      local bBottom = lerp(b01, b11, fx)
      local aBottom = lerp(a01, a11, fx)

      -- Interpolate vertically (final result)
      local r = lerp(rTop, rBottom, fy)
      local g = lerp(gTop, gBottom, fy)
      local b = lerp(bTop, bBottom, fy)
      local a = lerp(aTop, aBottom, fy)

      -- Write to destination
      destImageData:setPixel(destX, destY, r, g, b, a)
    end
  end

  return destImageData
end

-- ====================
-- ImageCache
-- ====================

---@class ImageCache
---@field _cache table<string, {image: love.Image, imageData: love.ImageData?}>
local ImageCache = {}
ImageCache._cache = {}

--- Normalize a file path for consistent cache keys
---@param path string -- File path to normalize
---@return string -- Normalized path
local function normalizePath(path)
  -- Remove leading/trailing whitespace
  path = path:match("^%s*(.-)%s*$")
  -- Convert backslashes to forward slashes
  path = path:gsub("\\", "/")
  -- Remove redundant slashes
  path = path:gsub("/+", "/")
  return path
end

--- Load an image from file path with caching
--- Returns cached image if already loaded, otherwise loads and caches it
---@param imagePath string -- Path to image file
---@param loadImageData boolean? -- Optional: also load ImageData for pixel access (default: false)
---@return love.Image|nil -- Image object or nil on error
---@return string|nil -- Error message if loading failed
function ImageCache.load(imagePath, loadImageData)
  if not imagePath or type(imagePath) ~= "string" or imagePath == "" then
    return nil, "Invalid image path: path must be a non-empty string"
  end

  local normalizedPath = normalizePath(imagePath)
  
  -- Check if already cached
  if ImageCache._cache[normalizedPath] then
    return ImageCache._cache[normalizedPath].image, nil
  end

  -- Try to load the image
  local success, imageOrError = pcall(love.graphics.newImage, normalizedPath)
  if not success then
    return nil, string.format("Failed to load image '%s': %s", imagePath, tostring(imageOrError))
  end

  local image = imageOrError
  local imgData = nil

  -- Load ImageData if requested
  if loadImageData then
    local dataSuccess, dataOrError = pcall(love.image.newImageData, normalizedPath)
    if dataSuccess then
      imgData = dataOrError
    end
  end

  -- Cache the image
  ImageCache._cache[normalizedPath] = {
    image = image,
    imageData = imgData
  }

  return image, nil
end

--- Get a cached image without loading
---@param imagePath string -- Path to image file
---@return love.Image|nil -- Cached image or nil if not found
function ImageCache.get(imagePath)
  if not imagePath or type(imagePath) ~= "string" then
    return nil
  end

  local normalizedPath = normalizePath(imagePath)
  local cached = ImageCache._cache[normalizedPath]
  return cached and cached.image or nil
end

--- Get cached ImageData for an image
---@param imagePath string -- Path to image file
---@return love.ImageData|nil -- Cached ImageData or nil if not found
function ImageCache.getImageData(imagePath)
  if not imagePath or type(imagePath) ~= "string" then
    return nil
  end

  local normalizedPath = normalizePath(imagePath)
  local cached = ImageCache._cache[normalizedPath]
  return cached and cached.imageData or nil
end

--- Remove a specific image from cache
---@param imagePath string -- Path to image file to remove
---@return boolean -- True if image was removed, false if not found
function ImageCache.remove(imagePath)
  if not imagePath or type(imagePath) ~= "string" then
    return false
  end

  local normalizedPath = normalizePath(imagePath)
  if ImageCache._cache[normalizedPath] then
    -- Release the image
    local cached = ImageCache._cache[normalizedPath]
    if cached.image then
      cached.image:release()
    end
    if cached.imageData then
      cached.imageData:release()
    end
    ImageCache._cache[normalizedPath] = nil
    return true
  end
  return false
end

--- Clear all cached images
function ImageCache.clear()
  -- Release all images
  for path, cached in pairs(ImageCache._cache) do
    if cached.image then
      cached.image:release()
    end
    if cached.imageData then
      cached.imageData:release()
    end
  end
  ImageCache._cache = {}
end

--- Get cache statistics
---@return {count: number, memoryEstimate: number} -- Cache stats
function ImageCache.getStats()
  local count = 0
  local memoryEstimate = 0

  for path, cached in pairs(ImageCache._cache) do
    count = count + 1
    if cached.image then
      local w, h = cached.image:getDimensions()
      -- Estimate: 4 bytes per pixel (RGBA)
      memoryEstimate = memoryEstimate + (w * h * 4)
    end
  end

  return {
    count = count,
    memoryEstimate = memoryEstimate
  }
end

-- ====================
-- ImageRenderer
-- ====================

---@class ImageRenderer
local ImageRenderer = {}

--- Calculate rendering parameters for object-fit modes
--- Returns source and destination rectangles for rendering
---@param imageWidth number -- Natural width of the image
---@param imageHeight number -- Natural height of the image
---@param boundsWidth number -- Width of the bounds to fit within
---@param boundsHeight number -- Height of the bounds to fit within
---@param fitMode string? -- One of: "fill", "contain", "cover", "scale-down", "none" (default: "fill")
---@param objectPosition string? -- Position like "center center", "top left", "50% 50%" (default: "center center")
---@return {sx: number, sy: number, sw: number, sh: number, dx: number, dy: number, dw: number, dh: number, scaleX: number, scaleY: number}
function ImageRenderer.calculateFit(imageWidth, imageHeight, boundsWidth, boundsHeight, fitMode, objectPosition)
  fitMode = fitMode or "fill"
  objectPosition = objectPosition or "center center"

  -- Validate inputs
  if imageWidth <= 0 or imageHeight <= 0 or boundsWidth <= 0 or boundsHeight <= 0 then
    error(formatError("ImageRenderer", "Dimensions must be positive"))
  end

  local result = {
    sx = 0,        -- Source X
    sy = 0,        -- Source Y
    sw = imageWidth,   -- Source width
    sh = imageHeight,  -- Source height
    dx = 0,        -- Destination X
    dy = 0,        -- Destination Y
    dw = boundsWidth,  -- Destination width
    dh = boundsHeight, -- Destination height
    scaleX = 1,    -- Scale factor X
    scaleY = 1     -- Scale factor Y
  }

  -- Calculate based on fit mode
  if fitMode == "fill" then
    -- Stretch to fill bounds (may distort)
    result.scaleX = boundsWidth / imageWidth
    result.scaleY = boundsHeight / imageHeight
    result.dw = boundsWidth
    result.dh = boundsHeight

  elseif fitMode == "contain" then
    -- Scale to fit within bounds (preserves aspect ratio)
    local scale = math.min(boundsWidth / imageWidth, boundsHeight / imageHeight)
    result.scaleX = scale
    result.scaleY = scale
    result.dw = imageWidth * scale
    result.dh = imageHeight * scale

    -- Apply object-position for letterbox alignment
    local posX, posY = ImageRenderer._parsePosition(objectPosition)
    result.dx = (boundsWidth - result.dw) * posX
    result.dy = (boundsHeight - result.dh) * posY

  elseif fitMode == "cover" then
    -- Scale to cover bounds (preserves aspect ratio, may crop)
    local scale = math.max(boundsWidth / imageWidth, boundsHeight / imageHeight)
    result.scaleX = scale
    result.scaleY = scale
    
    local scaledWidth = imageWidth * scale
    local scaledHeight = imageHeight * scale

    -- Apply object-position for crop alignment
    local posX, posY = ImageRenderer._parsePosition(objectPosition)
    
    -- Calculate which part of the scaled image to show
    local cropX = (scaledWidth - boundsWidth) * posX
    local cropY = (scaledHeight - boundsHeight) * posY

    -- Convert back to source coordinates
    result.sx = cropX / scale
    result.sy = cropY / scale
    result.sw = boundsWidth / scale
    result.sh = boundsHeight / scale
    
    result.dx = 0
    result.dy = 0
    result.dw = boundsWidth
    result.dh = boundsHeight

  elseif fitMode == "none" then
    -- Use natural size (no scaling)
    result.scaleX = 1
    result.scaleY = 1
    result.dw = imageWidth
    result.dh = imageHeight

    -- Apply object-position
    local posX, posY = ImageRenderer._parsePosition(objectPosition)
    result.dx = (boundsWidth - imageWidth) * posX
    result.dy = (boundsHeight - imageHeight) * posY

  elseif fitMode == "scale-down" then
    -- Use none or contain, whichever is smaller
    if imageWidth <= boundsWidth and imageHeight <= boundsHeight then
      -- Image fits naturally, use "none"
      return ImageRenderer.calculateFit(imageWidth, imageHeight, boundsWidth, boundsHeight, "none", objectPosition)
    else
      -- Image too large, use "contain"
      return ImageRenderer.calculateFit(imageWidth, imageHeight, boundsWidth, boundsHeight, "contain", objectPosition)
    end

  else
    error(formatError("ImageRenderer", string.format("Invalid fit mode: '%s'. Must be one of: fill, contain, cover, scale-down, none", tostring(fitMode))))
  end

  return result
end

--- Parse object-position string into normalized coordinates (0-1)
--- Supports keywords (center, top, bottom, left, right) and percentages
---@param position string -- Position string like "center center", "top left", "50% 50%"
---@return number, number -- Normalized X and Y positions (0-1)
function ImageRenderer._parsePosition(position)
  if not position or type(position) ~= "string" then
    return 0.5, 0.5 -- Default to center
  end

  -- Split into X and Y components
  local parts = {}
  for part in position:gmatch("%S+") do
    table.insert(parts, part:lower())
  end

  -- If only one value, use it for both axes (with special handling)
  if #parts == 1 then
    local val = parts[1]
    if val == "left" or val == "right" then
      parts = {val, "center"}
    elseif val == "top" or val == "bottom" then
      parts = {"center", val}
    else
      parts = {val, val}
    end
  elseif #parts == 0 then
    return 0.5, 0.5 -- Default to center
  end

  local function parseValue(val)
    -- Handle keywords
    if val == "center" then return 0.5
    elseif val == "left" or val == "top" then return 0
    elseif val == "right" or val == "bottom" then return 1
    end

    -- Handle percentages
    local percent = val:match("^([%d%.]+)%%$")
    if percent then
      return tonumber(percent) / 100
    end

    -- Handle plain numbers (treat as percentage)
    local num = tonumber(val)
    if num then
      return num / 100
    end

    -- Invalid value, default to center
    return 0.5
  end

  local x = parseValue(parts[1])
  local y = parseValue(parts[2] or parts[1])

  -- Clamp to 0-1 range
  x = math.max(0, math.min(1, x))
  y = math.max(0, math.min(1, y))

  return x, y
end

--- Draw an image with specified object-fit mode
---@param image love.Image -- Image to draw
---@param x number -- X position of bounds
---@param y number -- Y position of bounds
---@param width number -- Width of bounds
---@param height number -- Height of bounds
---@param fitMode string? -- Object-fit mode (default: "fill")
---@param objectPosition string? -- Object-position (default: "center center")
---@param opacity number? -- Opacity 0-1 (default: 1)
function ImageRenderer.draw(image, x, y, width, height, fitMode, objectPosition, opacity)
  if not image then
    return -- Nothing to draw
  end

  opacity = opacity or 1
  fitMode = fitMode or "fill"
  objectPosition = objectPosition or "center center"

  local imgWidth, imgHeight = image:getDimensions()
  local params = ImageRenderer.calculateFit(imgWidth, imgHeight, width, height, fitMode, objectPosition)

  -- Save current color
  local r, g, b, a = love.graphics.getColor()

  -- Apply opacity
  love.graphics.setColor(1, 1, 1, opacity)

  -- Draw image
  if params.sx ~= 0 or params.sy ~= 0 or params.sw ~= imgWidth or params.sh ~= imgHeight then
    -- Need to use a quad for cropping
    local quad = love.graphics.newQuad(params.sx, params.sy, params.sw, params.sh, imgWidth, imgHeight)
    love.graphics.draw(image, quad, x + params.dx, y + params.dy, 0, params.dw / params.sw, params.dh / params.sh)
  else
    -- Simple draw with scaling
    love.graphics.draw(image, x + params.dx, y + params.dy, 0, params.scaleX, params.scaleY)
  end

  -- Restore color
  love.graphics.setColor(r, g, b, a)
end

-- ====================
-- Theme System
-- ====================

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

    -- Extract the directory path (remove FlexLove.lua)
    local filesystemPath = source:match("(.*/)")
    if filesystemPath then
      -- Store the original filesystem path for loading assets
      local fsPath = filesystemPath
      -- Remove leading ./ if present
      fsPath = fsPath:gsub("^%./", "")
      -- Remove trailing /
      fsPath = fsPath:gsub("/$", "")

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

-- ====================
-- Rounded Rectangle Helper
-- ====================

local RoundedRect = {}

--- Generate points for a rounded rectangle
---@param x number
---@param y number
---@param width number
---@param height number
---@param cornerRadius {topLeft:number, topRight:number, bottomLeft:number, bottomRight:number}
---@param segments number? -- Number of segments per corner arc (default: 10)
---@return table -- Array of vertices for love.graphics.polygon
function RoundedRect.getPoints(x, y, width, height, cornerRadius, segments)
  segments = segments or 10
  local points = {}

  -- Helper to add arc points
  local function addArc(cx, cy, radius, startAngle, endAngle)
    if radius <= 0 then
      table.insert(points, cx)
      table.insert(points, cy)
      return
    end

    for i = 0, segments do
      local angle = startAngle + (endAngle - startAngle) * (i / segments)
      table.insert(points, cx + math.cos(angle) * radius)
      table.insert(points, cy + math.sin(angle) * radius)
    end
  end

  local r1 = math.min(cornerRadius.topLeft, width / 2, height / 2)
  local r2 = math.min(cornerRadius.topRight, width / 2, height / 2)
  local r3 = math.min(cornerRadius.bottomRight, width / 2, height / 2)
  local r4 = math.min(cornerRadius.bottomLeft, width / 2, height / 2)

  -- Top-right corner
  addArc(x + width - r2, y + r2, r2, -math.pi / 2, 0)

  -- Bottom-right corner
  addArc(x + width - r3, y + height - r3, r3, 0, math.pi / 2)

  -- Bottom-left corner
  addArc(x + r4, y + height - r4, r4, math.pi / 2, math.pi)

  -- Top-left corner
  addArc(x + r1, y + r1, r1, math.pi, math.pi * 1.5)

  return points
end

--- Draw a filled rounded rectangle
---@param mode string -- "fill" or "line"
---@param x number
---@param y number
---@param width number
---@param height number
---@param cornerRadius {topLeft:number, topRight:number, bottomLeft:number, bottomRight:number}
function RoundedRect.draw(mode, x, y, width, height, cornerRadius)
  -- Check if any corners are rounded
  local hasRoundedCorners = cornerRadius.topLeft > 0 or cornerRadius.topRight > 0 or cornerRadius.bottomLeft > 0 or cornerRadius.bottomRight > 0

  if not hasRoundedCorners then
    -- No rounded corners, use regular rectangle
    love.graphics.rectangle(mode, x, y, width, height)
    return
  end

  local points = RoundedRect.getPoints(x, y, width, height, cornerRadius)

  if mode == "fill" then
    love.graphics.polygon("fill", points)
  else
    -- For line mode, draw the outline
    love.graphics.polygon("line", points)
  end
end

--- Create a stencil function for rounded rectangle clipping
---@param x number
---@param y number
---@param width number
---@param height number
---@param cornerRadius {topLeft:number, topRight:number, bottomLeft:number, bottomRight:number}
---@return function
function RoundedRect.stencilFunction(x, y, width, height, cornerRadius)
  return function()
    RoundedRect.draw("fill", x, y, width, height, cornerRadius)
  end
end

-- ====================
-- NineSlice Renderer
-- ====================

local NineSlice = {}

--- Draw a 9-patch component using Android-style rendering
--- Corners are scaled by scaleCorners multiplier, edges stretch in one dimension only
---@param component ThemeComponent
---@param atlas love.Image
---@param x number -- X position (top-left corner)
---@param y number -- Y position (top-left corner)
---@param width number -- Total width (border-box)
---@param height number -- Total height (border-box)
---@param opacity number?
---@param elementScaleCorners number? -- Element-level override for scaleCorners (scale multiplier)
---@param elementScalingAlgorithm "nearest"|"bilinear"? -- Element-level override for scalingAlgorithm
function NineSlice.draw(component, atlas, x, y, width, height, opacity, elementScaleCorners, elementScalingAlgorithm)
  if not component or not atlas then
    return
  end

  opacity = opacity or 1
  love.graphics.setColor(1, 1, 1, opacity)

  local regions = component.regions

  -- Extract border dimensions from regions (in pixels)
  local left = regions.topLeft.w
  local right = regions.topRight.w
  local top = regions.topLeft.h
  local bottom = regions.bottomLeft.h
  local centerW = regions.middleCenter.w
  local centerH = regions.middleCenter.h

  -- Calculate content area (space remaining after borders)
  local contentWidth = width - left - right
  local contentHeight = height - top - bottom

  -- Clamp to prevent negative dimensions
  contentWidth = math.max(0, contentWidth)
  contentHeight = math.max(0, contentHeight)

  -- Calculate stretch scales for edges and center
  local scaleX = contentWidth / centerW
  local scaleY = contentHeight / centerH

  -- Create quads for each region
  local atlasWidth, atlasHeight = atlas:getDimensions()

  local function makeQuad(region)
    return love.graphics.newQuad(region.x, region.y, region.w, region.h, atlasWidth, atlasHeight)
  end

  -- Get corner scale multiplier
  -- Priority: element-level override > component setting > default (nil = no scaling)
  local scaleCorners = elementScaleCorners
  if scaleCorners == nil then
    scaleCorners = component.scaleCorners
  end

  -- Priority: element-level override > component setting > default ("bilinear")
  local scalingAlgorithm = elementScalingAlgorithm
  if scalingAlgorithm == nil then
    scalingAlgorithm = component.scalingAlgorithm or "bilinear"
  end

  if scaleCorners and type(scaleCorners) == "number" and scaleCorners > 0 then
    -- Initialize cache if needed
    if not component._scaledRegionCache then
      component._scaledRegionCache = {}
    end

    -- Use the numeric scale multiplier directly
    local scaleFactor = scaleCorners

    -- Helper to get or create scaled region
    local function getScaledRegion(regionName, region, targetWidth, targetHeight)
      local cacheKey = string.format("%s_%.2f_%s", regionName, scaleFactor, scalingAlgorithm)

      if component._scaledRegionCache[cacheKey] then
        return component._scaledRegionCache[cacheKey]
      end

      -- Get ImageData from component (stored during theme loading)
      local atlasData = component._loadedAtlasData
      if not atlasData then
        error(formatError("NineSlice", "No ImageData available for atlas. Image must be loaded with safeLoadImage."))
      end

      local scaledData

      if scalingAlgorithm == "nearest" then
        scaledData = ImageScaler.scaleNearest(atlasData, region.x, region.y, region.w, region.h, targetWidth, targetHeight)
      else
        scaledData = ImageScaler.scaleBilinear(atlasData, region.x, region.y, region.w, region.h, targetWidth, targetHeight)
      end

      -- Convert to image and cache
      local scaledImage = love.graphics.newImage(scaledData)
      component._scaledRegionCache[cacheKey] = scaledImage

      return scaledImage
    end

    -- Calculate scaled dimensions for corners
    local scaledLeft = math.floor(left * scaleFactor + 0.5)
    local scaledRight = math.floor(right * scaleFactor + 0.5)
    local scaledTop = math.floor(top * scaleFactor + 0.5)
    local scaledBottom = math.floor(bottom * scaleFactor + 0.5)

    -- CORNERS (scaled using algorithm)
    local topLeftScaled = getScaledRegion("topLeft", regions.topLeft, scaledLeft, scaledTop)
    local topRightScaled = getScaledRegion("topRight", regions.topRight, scaledRight, scaledTop)
    local bottomLeftScaled = getScaledRegion("bottomLeft", regions.bottomLeft, scaledLeft, scaledBottom)
    local bottomRightScaled = getScaledRegion("bottomRight", regions.bottomRight, scaledRight, scaledBottom)

    love.graphics.draw(topLeftScaled, x, y)
    love.graphics.draw(topRightScaled, x + width - scaledRight, y)
    love.graphics.draw(bottomLeftScaled, x, y + height - scaledBottom)
    love.graphics.draw(bottomRightScaled, x + width - scaledRight, y + height - scaledBottom)

    -- Update content dimensions to account for scaled borders
    local adjustedContentWidth = width - scaledLeft - scaledRight
    local adjustedContentHeight = height - scaledTop - scaledBottom
    adjustedContentWidth = math.max(0, adjustedContentWidth)
    adjustedContentHeight = math.max(0, adjustedContentHeight)

    -- Recalculate stretch scales
    local adjustedScaleX = adjustedContentWidth / centerW
    local adjustedScaleY = adjustedContentHeight / centerH

    -- TOP/BOTTOM EDGES (stretch horizontally, scale vertically)
    if adjustedContentWidth > 0 then
      local topCenterScaled = getScaledRegion("topCenter", regions.topCenter, regions.topCenter.w, scaledTop)
      local bottomCenterScaled = getScaledRegion("bottomCenter", regions.bottomCenter, regions.bottomCenter.w, scaledBottom)

      love.graphics.draw(topCenterScaled, x + scaledLeft, y, 0, adjustedScaleX, 1)
      love.graphics.draw(bottomCenterScaled, x + scaledLeft, y + height - scaledBottom, 0, adjustedScaleX, 1)
    end

    -- LEFT/RIGHT EDGES (stretch vertically, scale horizontally)
    if adjustedContentHeight > 0 then
      local middleLeftScaled = getScaledRegion("middleLeft", regions.middleLeft, scaledLeft, regions.middleLeft.h)
      local middleRightScaled = getScaledRegion("middleRight", regions.middleRight, scaledRight, regions.middleRight.h)

      love.graphics.draw(middleLeftScaled, x, y + scaledTop, 0, 1, adjustedScaleY)
      love.graphics.draw(middleRightScaled, x + width - scaledRight, y + scaledTop, 0, 1, adjustedScaleY)
    end

    -- CENTER (stretch both dimensions, no scaling)
    if adjustedContentWidth > 0 and adjustedContentHeight > 0 then
      love.graphics.draw(atlas, makeQuad(regions.middleCenter), x + scaledLeft, y + scaledTop, 0, adjustedScaleX, adjustedScaleY)
    end
  else
    -- Original rendering logic (no scaling)
    -- CORNERS (no scaling - 1:1 pixel perfect)
    love.graphics.draw(atlas, makeQuad(regions.topLeft), x, y)
    love.graphics.draw(atlas, makeQuad(regions.topRight), x + left + contentWidth, y)
    love.graphics.draw(atlas, makeQuad(regions.bottomLeft), x, y + top + contentHeight)
    love.graphics.draw(atlas, makeQuad(regions.bottomRight), x + left + contentWidth, y + top + contentHeight)

    -- TOP/BOTTOM EDGES (stretch horizontally only)
    if contentWidth > 0 then
      love.graphics.draw(atlas, makeQuad(regions.topCenter), x + left, y, 0, scaleX, 1)
      love.graphics.draw(atlas, makeQuad(regions.bottomCenter), x + left, y + top + contentHeight, 0, scaleX, 1)
    end

    -- LEFT/RIGHT EDGES (stretch vertically only)
    if contentHeight > 0 then
      love.graphics.draw(atlas, makeQuad(regions.middleLeft), x, y + top, 0, 1, scaleY)
      love.graphics.draw(atlas, makeQuad(regions.middleRight), x + left + contentWidth, y + top, 0, 1, scaleY)
    end

    -- CENTER (stretch both dimensions)
    if contentWidth > 0 and contentHeight > 0 then
      love.graphics.draw(atlas, makeQuad(regions.middleCenter), x + left, y + top, 0, scaleX, scaleY)
    end
  end

  -- Reset color
  love.graphics.setColor(1, 1, 1, 1)
end

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

-- Text size preset mappings (in vh units for auto-scaling)
local TEXT_SIZE_PRESETS = {
  ["2xs"] = 0.75, -- 0.75vh
  xxs = 0.75, -- 0.75vh
  xs = 1.25, -- 1.25vh
  sm = 1.75, -- 1.75vh
  md = 2.25, -- 2.25vh (default)
  lg = 2.75, -- 2.75vh
  xl = 3.5, -- 3.5vh
  xxl = 4.5, -- 4.5vh
  ["2xl"] = 4.5, -- 4.5vh
  ["3xl"] = 5.0, -- 5vh
  ["4xl"] = 7.0, -- 7vh
}

local Positioning, FlexDirection, JustifyContent, AlignContent, AlignItems, TextAlign, AlignSelf, JustifySelf, FlexWrap =
  enums.Positioning,
  enums.FlexDirection,
  enums.JustifyContent,
  enums.AlignContent,
  enums.AlignItems,
  enums.TextAlign,
  enums.AlignSelf,
  enums.JustifySelf,
  enums.FlexWrap

-- ====================
-- Units System
-- ====================

--- Unit parsing and viewport calculations
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

-- ====================
-- Grid System
-- ====================

--- Simple grid layout calculations
local Grid = {}

--- Layout grid items within a grid container using simple row/column counts
---@param element Element -- Grid container element
function Grid.layoutGridItems(element)
  local rows = element.gridRows or 1
  local columns = element.gridColumns or 1

  -- Calculate space reserved by absolutely positioned siblings
  local reservedLeft = 0
  local reservedRight = 0
  local reservedTop = 0
  local reservedBottom = 0

  for _, child in ipairs(element.children) do
    -- Only consider absolutely positioned children with explicit positioning
    if child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute then
      -- BORDER-BOX MODEL: Use border-box dimensions for space calculations
      local childBorderBoxWidth = child:getBorderBoxWidth()
      local childBorderBoxHeight = child:getBorderBoxHeight()

      if child.left then
        reservedLeft = math.max(reservedLeft, child.left + childBorderBoxWidth)
      end
      if child.right then
        reservedRight = math.max(reservedRight, child.right + childBorderBoxWidth)
      end
      if child.top then
        reservedTop = math.max(reservedTop, child.top + childBorderBoxHeight)
      end
      if child.bottom then
        reservedBottom = math.max(reservedBottom, child.bottom + childBorderBoxHeight)
      end
    end
  end

  -- Calculate available space (accounting for padding and reserved space)
  -- BORDER-BOX MODEL: element.width and element.height are already content dimensions
  local availableWidth = element.width - reservedLeft - reservedRight
  local availableHeight = element.height - reservedTop - reservedBottom

  -- Get gaps
  local columnGap = element.columnGap or 0
  local rowGap = element.rowGap or 0

  -- Calculate cell sizes (equal distribution)
  local totalColumnGaps = (columns - 1) * columnGap
  local totalRowGaps = (rows - 1) * rowGap
  local cellWidth = (availableWidth - totalColumnGaps) / columns
  local cellHeight = (availableHeight - totalRowGaps) / rows

  -- Get children that participate in grid layout
  local gridChildren = {}
  for _, child in ipairs(element.children) do
    if not (child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute) then
      table.insert(gridChildren, child)
    end
  end

  -- Place children in grid cells
  for i, child in ipairs(gridChildren) do
    -- Calculate row and column (0-indexed for calculation)
    local index = i - 1
    local col = index % columns
    local row = math.floor(index / columns)

    -- Skip if we've exceeded the grid
    if row >= rows then
      break
    end

    -- Calculate cell position (accounting for reserved space)
    local cellX = element.x + element.padding.left + reservedLeft + (col * (cellWidth + columnGap))
    local cellY = element.y + element.padding.top + reservedTop + (row * (cellHeight + rowGap))

    -- Apply alignment within grid cell (default to stretch)
    local effectiveAlignItems = element.alignItems or AlignItems.STRETCH

    -- Stretch child to fill cell by default
    -- BORDER-BOX MODEL: Set border-box dimensions, content area adjusts automatically
    if effectiveAlignItems == AlignItems.STRETCH or effectiveAlignItems == "stretch" then
      child.x = cellX
      child.y = cellY
      child._borderBoxWidth = cellWidth
      child._borderBoxHeight = cellHeight
      child.width = math.max(0, cellWidth - child.padding.left - child.padding.right)
      child.height = math.max(0, cellHeight - child.padding.top - child.padding.bottom)
      -- Disable auto-sizing when stretched by grid
      child.autosizing.width = false
      child.autosizing.height = false
    elseif effectiveAlignItems == AlignItems.CENTER or effectiveAlignItems == "center" then
      local childBorderBoxWidth = child:getBorderBoxWidth()
      local childBorderBoxHeight = child:getBorderBoxHeight()
      child.x = cellX + (cellWidth - childBorderBoxWidth) / 2
      child.y = cellY + (cellHeight - childBorderBoxHeight) / 2
    elseif effectiveAlignItems == AlignItems.FLEX_START or effectiveAlignItems == "flex-start" or effectiveAlignItems == "start" then
      child.x = cellX
      child.y = cellY
    elseif effectiveAlignItems == AlignItems.FLEX_END or effectiveAlignItems == "flex-end" or effectiveAlignItems == "end" then
      local childBorderBoxWidth = child:getBorderBoxWidth()
      local childBorderBoxHeight = child:getBorderBoxHeight()
      child.x = cellX + cellWidth - childBorderBoxWidth
      child.y = cellY + cellHeight - childBorderBoxHeight
    else
      -- Default to stretch
      child.x = cellX
      child.y = cellY
      child._borderBoxWidth = cellWidth
      child._borderBoxHeight = cellHeight
      child.width = math.max(0, cellWidth - child.padding.left - child.padding.right)
      child.height = math.max(0, cellHeight - child.padding.top - child.padding.bottom)
      -- Disable auto-sizing when stretched by grid
      child.autosizing.width = false
      child.autosizing.height = false
    end

    -- Layout child's children if it has any
    if #child.children > 0 then
      child:layoutChildren()
    end
  end
end

--- Initialize FlexLove with configuration
---@param config {baseScale?: {width?:number, height?:number}, theme?: string|ThemeDefinition} --Default: {width: 1920, height: 1080}
function Gui.init(config)
  if config.baseScale then
    Gui.baseScale = {
      width = config.baseScale.width or 1920,
      height = config.baseScale.height or 1080,
    }

    -- Calculate initial scale factors
    local currentWidth, currentHeight = Units.getViewport()
    Gui.scaleFactors.x = currentWidth / Gui.baseScale.width
    Gui.scaleFactors.y = currentHeight / Gui.baseScale.height
  end

  -- Load and set theme if specified
  if config.theme then
    local success, err = pcall(function()
      if type(config.theme) == "string" then
        -- Load theme by name
        Theme.load(config.theme)
        Theme.setActive(config.theme)
        Gui.defaultTheme = config.theme
      elseif type(config.theme) == "table" then
        -- Load theme from definition
        local theme = Theme.new(config.theme)
        Theme.setActive(theme)
        Gui.defaultTheme = theme.name
      end
    end)

    if not success then
      print("[FlexLove] Failed to load theme: " .. tostring(err))
    end
  end
end

--- Get current scale factors
---@return number, number -- scaleX, scaleY
function Gui.getScaleFactors()
  return Gui.scaleFactors.x, Gui.scaleFactors.y
end

function Gui.resize()
  local newWidth, newHeight = love.window.getMode()

  -- Update scale factors if base scale is set
  if Gui.baseScale then
    Gui.scaleFactors.x = newWidth / Gui.baseScale.width
    Gui.scaleFactors.y = newHeight / Gui.baseScale.height
  end

  -- Clear scaled region caches for all themes
  for _, theme in pairs(themes) do
    if theme.components then
      for _, component in pairs(theme.components) do
        if component._scaledRegionCache then
          component._scaledRegionCache = {}
        end
      end
    end
  end

  -- Clear blur canvas cache on resize
  Blur.clearCache()

  -- Clear game/backdrop canvas cache on resize (will be recreated with new dimensions)
  Gui._gameCanvas = nil
  Gui._backdropCanvas = nil
  Gui._canvasDimensions = { width = 0, height = 0 }

  for _, win in ipairs(Gui.topElements) do
    win:resize(newWidth, newHeight)
  end
end

-- Canvas cache for game rendering (reused across frames)
Gui._gameCanvas = nil
Gui._backdropCanvas = nil
Gui._canvasDimensions = { width = 0, height = 0 }

---@param gameDrawFunc function|nil -- Function to draw game content, needed for backdrop blur
---function love.draw()
---  FlexLove.Gui.draw(function()
---    --Game rendering logic
---    RenderSystem:update()
---  end)
--- -- Layers on top of GUI - blurs will not extend to this
--- overlayStats.draw()
---end
function Gui.draw(gameDrawFunc)
  local gameCanvas = nil

  -- Render game content to a canvas if function provided
  if type(gameDrawFunc) == "function" then
    local width, height = love.graphics.getDimensions()

    -- Recreate canvases only if dimensions changed or canvas doesn't exist
    if not Gui._gameCanvas or Gui._canvasDimensions.width ~= width or Gui._canvasDimensions.height ~= height then
      Gui._gameCanvas = love.graphics.newCanvas(width, height)
      Gui._backdropCanvas = love.graphics.newCanvas(width, height)
      Gui._canvasDimensions.width = width
      Gui._canvasDimensions.height = height
    end

    gameCanvas = Gui._gameCanvas

    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()
    gameDrawFunc() -- Call the drawing function
    love.graphics.setCanvas()

    -- Draw game canvas to screen
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, 0, 0)
  end

  -- Sort elements by z-index before drawing
  table.sort(Gui.topElements, function(a, b)
    return a.z < b.z
  end)

  -- Check if any element (recursively) needs backdrop blur
  local function hasBackdropBlur(element)
    if element.backdropBlur and element.backdropBlur.intensity > 0 then
      return true
    end
    for _, child in ipairs(element.children) do
      if hasBackdropBlur(child) then
        return true
      end
    end
    return false
  end

  local needsBackdropCanvas = false
  for _, win in ipairs(Gui.topElements) do
    if hasBackdropBlur(win) then
      needsBackdropCanvas = true
      break
    end
  end

  -- If backdrop blur is needed, render to a progressive canvas
  if needsBackdropCanvas and gameCanvas then
    local backdropCanvas = Gui._backdropCanvas
    local prevColor = { love.graphics.getColor() }

    -- Initialize backdrop canvas with game content
    love.graphics.setCanvas(backdropCanvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, 0, 0)

    -- Reset to screen
    love.graphics.setCanvas()
    love.graphics.setColor(unpack(prevColor))

    -- Draw each element, updating backdrop canvas progressively
    for _, win in ipairs(Gui.topElements) do
      -- Draw element with current backdrop state
      win:draw(backdropCanvas)

      -- Update backdrop canvas to include this element (for next elements)
      love.graphics.setCanvas(backdropCanvas)
      love.graphics.setColor(1, 1, 1, 1)
      win:draw(nil) -- Draw without backdrop blur to the backdrop canvas
      love.graphics.setCanvas() -- Always reset to screen
    end
  else
    -- No backdrop blur needed, draw normally
    for _, win in ipairs(Gui.topElements) do
      win:draw(nil)
    end
  end

  -- Ensure canvas is reset to screen at the end
  love.graphics.setCanvas()
end

--- Find the topmost element at given coordinates (considering z-index)
---@param x number
---@param y number
---@return Element? -- Returns the topmost element or nil
function Gui.getElementAtPosition(x, y)
  local candidates = {}

  -- Recursively collect all elements that contain the point
  local function collectHits(element)
    -- Check if point is within element bounds
    local bx = element.x
    local by = element.y
    local bw = element._borderBoxWidth or (element.width + element.padding.left + element.padding.right)
    local bh = element._borderBoxHeight or (element.height + element.padding.top + element.padding.bottom)

    if x >= bx and x <= bx + bw and y >= by and y <= by + bh then
      -- Only consider elements with callbacks (interactive elements)
      if element.callback and not element.disabled then
        table.insert(candidates, element)
      end

      -- Check children
      for _, child in ipairs(element.children) do
        collectHits(child)
      end
    end
  end

  -- Collect hits from all top-level elements
  for _, element in ipairs(Gui.topElements) do
    collectHits(element)
  end

  -- Sort by z-index (highest first)
  table.sort(candidates, function(a, b)
    return a.z > b.z
  end)

  -- Return the topmost element (highest z-index)
  return candidates[1]
end

function Gui.update(dt)
  -- Reset event handling flags for new frame
  local mx, my = love.mouse.getPosition()
  local topElement = Gui.getElementAtPosition(mx, my)

  -- Mark which element should handle events this frame
  Gui._activeEventElement = topElement

  -- Update all elements
  for _, win in ipairs(Gui.topElements) do
    win:update(dt)
  end

  -- Clear active element for next frame
  Gui._activeEventElement = nil
end

--- Forward text input to focused element
---@param text string -- Character input
function Gui.textinput(text)
  if Gui._focusedElement then
    Gui._focusedElement:textinput(text)
  end
end

--- Forward key press to focused element
---@param key string -- Key name
---@param scancode string -- Scancode
---@param isrepeat boolean -- Whether this is a key repeat
function Gui.keypressed(key, scancode, isrepeat)
  if Gui._focusedElement then
    Gui._focusedElement:keypressed(key, scancode, isrepeat)
  end
end

--- Destroy all elements and their children
function Gui.destroy()
  for _, win in ipairs(Gui.topElements) do
    win:destroy()
  end
  Gui.topElements = {}
  -- Reset base scale and scale factors
  Gui.baseScale = nil
  Gui.scaleFactors = { x = 1.0, y = 1.0 }
  -- Reset cached viewport
  Gui._cachedViewport = { width = 0, height = 0 }
  -- Clear game/backdrop canvas cache
  Gui._gameCanvas = nil
  Gui._backdropCanvas = nil
  Gui._canvasDimensions = { width = 0, height = 0 }
  -- Clear focused element
  Gui._focusedElement = nil
end

-- Simple GUI library for LOVE2D
-- Provides element and button creation, drawing, and click handling.

-- ====================
-- Event System
-- ====================

---@class InputEvent
---@field type "click"|"press"|"release"|"rightclick"|"middleclick"
---@field button number -- Mouse button: 1 (left), 2 (right), 3 (middle)
---@field x number -- Mouse X position
---@field y number -- Mouse Y position
---@field modifiers {shift:boolean, ctrl:boolean, alt:boolean, super:boolean}
---@field clickCount number -- Number of clicks (for double/triple click detection)
---@field timestamp number -- Time when event occurred
local InputEvent = {}
InputEvent.__index = InputEvent

---@class InputEventProps
---@field type "click"|"press"|"release"|"rightclick"|"middleclick"
---@field button number
---@field x number
---@field y number
---@field modifiers {shift:boolean, ctrl:boolean, alt:boolean, super:boolean}
---@field clickCount number?
---@field timestamp number?

--- Create a new input event
---@param props InputEventProps
---@return InputEvent
function InputEvent.new(props)
  local self = setmetatable({}, InputEvent)
  self.type = props.type
  self.button = props.button
  self.x = props.x
  self.y = props.y
  self.modifiers = props.modifiers
  self.clickCount = props.clickCount or 1
  self.timestamp = props.timestamp or love.timer.getTime()
  return self
end

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

---@class Animation
---@field duration number
---@field start {width?:number, height?:number, opacity?:number}
---@field final {width?:number, height?:number, opacity?:number}
---@field elapsed number
---@field transform table?
---@field transition table?
--- Easing functions for animations
local Easing = {
  linear = function(t)
    return t
  end,

  easeInQuad = function(t)
    return t * t
  end,
  easeOutQuad = function(t)
    return t * (2 - t)
  end,
  easeInOutQuad = function(t)
    return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
  end,

  easeInCubic = function(t)
    return t * t * t
  end,
  easeOutCubic = function(t)
    local t1 = t - 1
    return t1 * t1 * t1 + 1
  end,
  easeInOutCubic = function(t)
    return t < 0.5 and 4 * t * t * t or (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
  end,

  easeInQuart = function(t)
    return t * t * t * t
  end,
  easeOutQuart = function(t)
    local t1 = t - 1
    return 1 - t1 * t1 * t1 * t1
  end,

  easeInExpo = function(t)
    return t == 0 and 0 or math.pow(2, 10 * (t - 1))
  end,
  easeOutExpo = function(t)
    return t == 1 and 1 or 1 - math.pow(2, -10 * t)
  end,
}

local Animation = {}
Animation.__index = Animation

---@class AnimationProps
---@field duration number
---@field start {width?:number, height?:number, opacity?:number}
---@field final {width?:number, height?:number, opacity?:number}
---@field transform table?
---@field transition table?
local AnimationProps = {}

---@class TransformProps
---@field scale {x?:number, y?:number}?
---@field rotate number?
---@field translate {x?:number, y?:number}?
---@field skew {x?:number, y?:number}?

---@class TransitionProps
---@field duration number?
---@field easing string?

---@param props AnimationProps
---@return Animation
function Animation.new(props)
  local self = setmetatable({}, Animation)
  self.duration = props.duration
  self.start = props.start
  self.final = props.final
  self.transform = props.transform
  self.transition = props.transition
  self.elapsed = 0

  -- Set easing function (default to linear)
  local easingName = props.easing or "linear"
  self.easing = Easing[easingName] or Easing.linear

  -- Pre-allocate result table to avoid GC pressure
  self._cachedResult = {}
  self._resultDirty = true

  return self
end

---@param dt number
---@return boolean
function Animation:update(dt)
  self.elapsed = self.elapsed + dt
  self._resultDirty = true -- Mark cached result as dirty
  if self.elapsed >= self.duration then
    return true -- finished
  else
    return false
  end
end

---@return table
function Animation:interpolate()
  -- Return cached result if not dirty (avoids recalculation)
  if not self._resultDirty then
    return self._cachedResult
  end

  local t = math.min(self.elapsed / self.duration, 1)
  t = self.easing(t) -- Apply easing function
  local result = self._cachedResult -- Reuse existing table

  -- Clear previous values
  result.width = nil
  result.height = nil
  result.opacity = nil

  -- Handle width and height if present
  if self.start.width and self.final.width then
    result.width = self.start.width * (1 - t) + self.final.width * t
  end

  if self.start.height and self.final.height then
    result.height = self.start.height * (1 - t) + self.final.height * t
  end

  -- Handle other properties like opacity
  if self.start.opacity and self.final.opacity then
    result.opacity = self.start.opacity * (1 - t) + self.final.opacity * t
  end

  -- Apply transform if present
  if self.transform then
    for key, value in pairs(self.transform) do
      result[key] = value
    end
  end

  self._resultDirty = false -- Mark as clean
  return result
end

--- Apply animation to a GUI element
---@param element Element
function Animation:apply(element)
  if element.animation then
    -- If there's an existing animation, we should probably stop it or replace it
    element.animation = self
  else
    element.animation = self
  end
end

--- Create a simple fade animation
---@param duration number
---@param fromOpacity number
---@param toOpacity number
---@return Animation
function Animation.fade(duration, fromOpacity, toOpacity)
  return Animation.new({
    duration = duration,
    start = { opacity = fromOpacity },
    final = { opacity = toOpacity },
    transform = {},
    transition = {},
  })
end

--- Create a simple scale animation
---@param duration number
---@param fromScale table{width:number,height:number}
---@param toScale table{width:number,height:number}
---@return Animation
function Animation.scale(duration, fromScale, toScale)
  return Animation.new({
    duration = duration,
    start = { width = fromScale.width, height = fromScale.height },
    final = { width = toScale.width, height = toScale.height },
    transform = {},
    transition = {},
  })
end

local FONT_CACHE = {}
local FONT_CACHE_MAX_SIZE = 50 -- Limit cache size to prevent unbounded growth
local FONT_CACHE_ORDER = {} -- Track access order for LRU eviction

--- Create or get a font from cache
---@param size number
---@param fontPath string? -- Optional: path to font file
---@return love.Font
function FONT_CACHE.get(size, fontPath)
  -- Create cache key from size and font path
  local cacheKey = fontPath and (fontPath .. "_" .. tostring(size)) or tostring(size)

  if not FONT_CACHE[cacheKey] then
    if fontPath then
      -- Load custom font
      local resolvedPath = resolveImagePath(fontPath)
      -- Note: love.graphics.newFont signature is (path, size) for custom fonts
      local success, font = pcall(love.graphics.newFont, resolvedPath, size)
      if success then
        FONT_CACHE[cacheKey] = font
      else
        -- Fallback to default font if custom font fails to load
        print("[FlexLove] Failed to load font: " .. fontPath .. " - using default font")
        FONT_CACHE[cacheKey] = love.graphics.newFont(size)
      end
    else
      -- Load default font
      FONT_CACHE[cacheKey] = love.graphics.newFont(size)
    end

    -- Add to access order for LRU tracking
    table.insert(FONT_CACHE_ORDER, cacheKey)

    -- Evict oldest entry if cache is full (LRU eviction)
    if #FONT_CACHE_ORDER > FONT_CACHE_MAX_SIZE then
      local oldestKey = table.remove(FONT_CACHE_ORDER, 1)
      FONT_CACHE[oldestKey] = nil
    end
  end
  return FONT_CACHE[cacheKey]
end

--- Get font for text size (cached)
---@param textSize number?
---@param fontPath string? -- Optional: path to font file
---@return love.Font
function FONT_CACHE.getFont(textSize, fontPath)
  if textSize then
    return FONT_CACHE.get(textSize, fontPath)
  else
    return love.graphics.getFont()
  end
end

-- ====================
-- Text Size Utilities
-- ====================

--- Resolve text size preset to viewport units
---@param sizeValue string|number
---@return number?, string? -- Returns value and unit ("vh" for presets, original unit otherwise)
local function resolveTextSizePreset(sizeValue)
  if type(sizeValue) == "string" then
    -- Check if it's a preset
    local preset = TEXT_SIZE_PRESETS[sizeValue]
    if preset then
      return preset, "vh"
    end
  end
  -- Not a preset, return nil to indicate normal parsing should occur
  return nil, nil
end

---@class Border
---@field top boolean?
---@field right boolean?
---@field bottom boolean?
---@field left boolean?

-- ====================
-- Element Object
-- ====================

--[[
INTERNAL FIELD NAMING CONVENTIONS:
---------------------------------
Fields prefixed with underscore (_) are internal/private and should not be accessed directly:

- _pressed: Internal state tracking for mouse button presses
- _lastClickTime: Internal timestamp for double-click detection
- _lastClickButton: Internal button tracking for click events
- _clickCount: Internal counter for multi-click detection
- _touchPressed: Internal touch state tracking
- _themeState: Internal current theme state (managed automatically)
- _borderBoxWidth: Internal cached border-box width (optimization)
- _borderBoxHeight: Internal cached border-box height (optimization)
- _explicitlyAbsolute: Internal flag for positioning logic
- _originalPositioning: Internal original positioning value
- _cachedResult: Internal animation cache (Animation class)
- _resultDirty: Internal animation dirty flag (Animation class)
- _loadedAtlas: Internal cached atlas image (ThemeComponent)
- _cachedViewport: Internal viewport cache (Gui class)

Public API methods to access internal state:
- Element:getBorderBoxWidth() - Get border-box width
- Element:getBorderBoxHeight() - Get border-box height
- Element:getBounds() - Get element bounds
]]

---@class Element
---@field id string
---@field autosizing {width:boolean, height:boolean} -- Whether the element should automatically size to fit its children
---@field x number|string -- X coordinate of the element
---@field y number|string -- Y coordinate of the element
---@field z number -- Z-index for layering (default: 0)
---@field width number|string -- Width of the element
---@field height number|string -- Height of the element
---@field top number? -- Offset from top edge (CSS-style positioning)
---@field right number? -- Offset from right edge (CSS-style positioning)
---@field bottom number? -- Offset from bottom edge (CSS-style positioning)
---@field left number? -- Offset from left edge (CSS-style positioning)
---@field children table<integer, Element> -- Children of this element
---@field parent Element? -- Parent element (nil if top-level)
---@field border Border -- Border configuration for the element
---@field opacity number
---@field borderColor Color -- Color of the border
---@field backgroundColor Color -- Background color of the element
---@field cornerRadius number|{topLeft:number?, topRight:number?, bottomLeft:number?, bottomRight:number?}? -- Corner radius for rounded corners (default: 0)
---@field prevGameSize {width:number, height:number} -- Previous game size for resize calculations
---@field text string? -- Text content to display in the element
---@field textColor Color -- Color of the text content
---@field textAlign TextAlign -- Alignment of the text content
---@field gap number|string -- Space between children elements (default: 10)
---@field padding {top?:number, right?:number, bottom?:number, left?:number}? -- Padding around children (default: {top=0, right=0, bottom=0, left=0})
---@field margin {top?:number, right?:number, bottom?:number, left?:number} -- Margin around children (default: {top=0, right=0, bottom=0, left=0})
---@field positioning Positioning -- Layout positioning mode (default: RELATIVE)
---@field flexDirection FlexDirection -- Direction of flex layout (default: HORIZONTAL)
---@field justifyContent JustifyContent -- Alignment of items along main axis (default: FLEX_START)
---@field alignItems AlignItems -- Alignment of items along cross axis (default: STRETCH)
---@field alignContent AlignContent -- Alignment of lines in multi-line flex containers (default: STRETCH)
---@field flexWrap FlexWrap -- Whether children wrap to multiple lines (default: NOWRAP)
---@field justifySelf JustifySelf -- Alignment of the item itself along main axis (default: AUTO)
---@field alignSelf AlignSelf -- Alignment of the item itself along cross axis (default: AUTO)
---@field textSize number? -- Resolved font size for text content in pixels
---@field minTextSize number?
---@field maxTextSize number?
---@field fontFamily string? -- Font family name from theme or path to font file
---@field autoScaleText boolean -- Whether text should auto-scale with window size (default: true)
---@field transform TransformProps -- Transform properties for animations and styling
---@field transition TransitionProps -- Transition settings for animations
---@field callback fun(element:Element, event:InputEvent)? -- Callback function for interaction events
---@field units table -- Original unit specifications for responsive behavior
---@field _pressed table<number, boolean> -- Track pressed state per mouse button
---@field _lastClickTime number? -- Timestamp of last click for double-click detection
---@field _lastClickButton number? -- Button of last click
---@field _clickCount number -- Current click count for multi-click detection
---@field _touchPressed table<any, boolean> -- Track touch pressed state
---@field _explicitlyAbsolute boolean?
---@field gridRows number? -- Number of rows in the grid
---@field gridColumns number? -- Number of columns in the grid
---@field columnGap number|string? -- Gap between grid columns
---@field rowGap number|string? -- Gap between grid rows
---@field theme string? -- Theme component to use for rendering
---@field themeComponent string?
---@field _themeState string? -- Current theme state (normal, hover, pressed, active, disabled)
---@field disabled boolean? -- Whether the element is disabled (default: false)
---@field active boolean? -- Whether the element is active/focused (for inputs, default: false)
---@field disableHighlight boolean? -- Whether to disable the pressed state highlight overlay (default: false)
---@field contentAutoSizingMultiplier {width:number?, height:number?}? -- Multiplier for auto-sized content dimensions
---@field scaleCorners number? -- Scale multiplier for 9-slice corners/edges. E.g., 2 = 2x size (overrides theme setting)
---@field scalingAlgorithm "nearest"|"bilinear"? -- Scaling algorithm for 9-slice corners: "nearest" (sharp/pixelated) or "bilinear" (smooth) (overrides theme setting)
---@field contentBlur {intensity:number, quality:number}? -- Blur the element's content including children (intensity: 0-100, quality: 1-10)
---@field backdropBlur {intensity:number, quality:number}? -- Blur content behind the element (intensity: 0-100, quality: 1-10)
---@field _blurInstance table? -- Internal: cached blur effect instance
---@field editable boolean -- Whether the element is editable (default: false)
---@field multiline boolean -- Whether the element supports multiple lines (default: false)
---@field textWrap boolean|"word"|"char" -- Text wrapping mode (default: false for single-line, "word" for multi-line)
---@field maxLines number? -- Maximum number of lines (default: nil)
---@field maxLength number? -- Maximum text length in characters (default: nil)
---@field placeholder string? -- Placeholder text when empty (default: nil)
---@field passwordMode boolean -- Whether to display text as password (default: false)
---@field inputType "text"|"number"|"email"|"url" -- Input type for validation (default: "text")
---@field textOverflow "clip"|"ellipsis"|"scroll" -- Text overflow behavior (default: "clip")
---@field scrollable boolean -- Whether text is scrollable (default: false for single-line, true for multi-line)
---@field autoGrow boolean -- Whether element auto-grows with text (default: false)
---@field selectOnFocus boolean -- Whether to select all text on focus (default: false)
---@field cursorColor Color? -- Cursor color (default: nil, uses textColor)
---@field selectionColor Color? -- Selection background color (default: nil, uses theme or default)
---@field cursorBlinkRate number -- Cursor blink rate in seconds (default: 0.5)
---@field _cursorPosition number? -- Internal: cursor character position (0-based)
---@field _cursorLine number? -- Internal: cursor line number (1-based)
---@field _cursorColumn number? -- Internal: cursor column within line
---@field _cursorBlinkTimer number? -- Internal: cursor blink timer
---@field _cursorVisible boolean? -- Internal: cursor visibility state
---@field _selectionStart number? -- Internal: selection start position
---@field _selectionEnd number? -- Internal: selection end position
---@field _selectionAnchor number? -- Internal: selection anchor point
---@field _focused boolean? -- Internal: focus state
---@field _textBuffer string? -- Internal: text buffer for editable elements
---@field _lines table? -- Internal: split lines for multi-line text
---@field _wrappedLines table? -- Internal: wrapped line data
---@field _textDirty boolean? -- Internal: flag to recalculate lines/wrapping
---@field imagePath string? -- Path to image file (auto-loads via ImageCache)
---@field image love.Image? -- Image object to display
---@field objectFit "fill"|"contain"|"cover"|"scale-down"|"none"? -- Image fit mode (default: "fill")
---@field objectPosition string? -- Image position like "center center", "top left", "50% 50%" (default: "center center")
---@field imageOpacity number? -- Image opacity 0-1 (default: 1, combines with element opacity)
---@field _loadedImage love.Image? -- Internal: cached loaded image
local Element = {}
Element.__index = Element

---@class ElementProps
---@field id string?
---@field parent Element? -- Parent element for hierarchical structure
---@field x number|string? -- X coordinate of the element (default: 0)
---@field y number|string? -- Y coordinate of the element (default: 0)
---@field z number? -- Z-index for layering (default: 0)
---@field width number|string? -- Width of the element (default: calculated automatically)
---@field height number|string? -- Height of the element (default: calculated automatically)
---@field top number|string? -- Offset from top edge (CSS-style positioning)
---@field right number|string? -- Offset from right edge (CSS-style positioning)
---@field bottom number|string? -- Offset from bottom edge (CSS-style positioning)
---@field left number|string? -- Offset from left edge (CSS-style positioning)
---@field border Border? -- Border configuration for the element
---@field borderColor Color? -- Color of the border (default: black)
---@field opacity number?
---@field backgroundColor Color? -- Background color (default: transparent)
---@field cornerRadius number|{topLeft:number?, topRight:number?, bottomLeft:number?, bottomRight:number?}? -- Corner radius: number (all corners) or table for individual corners (default: 0)
---@field gap number|string? -- Space between children elements (default: 10)
---@field padding {top:number|string?, right:number|string?, bottom:number|string?, left:number|string?, horizontal: number|string?, vertical:number|string?}? -- Padding around children (default: {top=0, right=0, bottom=0, left=0})
---@field margin {top:number|string?, right:number|string?, bottom:number|string?, left:number|string?, horizontal: number|string?, vertical:number|string?}? -- Margin around children (default: {top=0, right=0, bottom=0, left=0})
---@field text string? -- Text content to display (default: nil)
---@field titleColor Color? -- Color of the text content (default: black)
---@field textAlign TextAlign? -- Alignment of the text content (default: START)
---@field textColor Color? -- Color of the text content (default: black)
---@field textSize number|string? -- Font size: number (px), string with units ("2vh", "10%"), or preset ("xxs"|"xs"|"sm"|"md"|"lg"|"xl"|"xxl"|"3xl"|"4xl") (default: "md")
---@field minTextSize number?
---@field maxTextSize number?
---@field fontFamily string? -- Font family name from theme or path to font file (default: theme default or system default)
---@field autoScaleText boolean? -- Whether text should auto-scale with window size (default: true)
---@field positioning Positioning? -- Layout positioning mode (default: RELATIVE)
---@field flexDirection FlexDirection? -- Direction of flex layout (default: HORIZONTAL)
---@field justifyContent JustifyContent? -- Alignment of items along main axis (default: FLEX_START)
---@field alignItems AlignItems? -- Alignment of items along cross axis (default: STRETCH)
---@field alignContent AlignContent? -- Alignment of lines in multi-line flex containers (default: STRETCH)
---@field flexWrap FlexWrap? -- Whether children wrap to multiple lines (default: NOWRAP)
---@field justifySelf JustifySelf? -- Alignment of the item itself along main axis (default: AUTO)
---@field alignSelf AlignSelf? -- Alignment of the item itself along cross axis (default: AUTO)
---@field callback fun(element:Element, event:InputEvent)? -- Callback function for interaction events
---@field transform table? -- Transform properties for animations and styling
---@field transition table? -- Transition settings for animations
---@field gridRows number? -- Number of rows in the grid (default: 1)
---@field gridColumns number? -- Number of columns in the grid (default: 1)
---@field columnGap number|string? -- Gap between grid columns
---@field rowGap number|string? -- Gap between grid rows
---@field theme string? -- Theme name to use (e.g., "space", "dark"). Defaults to theme from Gui.init()
---@field themeComponent string? -- Theme component to use (e.g., "panel", "button", "input"). If nil, no theme is applied
---@field disabled boolean? -- Whether the element is disabled (default: false)
---@field active boolean? -- Whether the element is active/focused (for inputs, default: false)
---@field disableHighlight boolean? -- Whether to disable the pressed state highlight overlay (default: false)
---@field contentAutoSizingMultiplier {width:number?, height:number?}? -- Multiplier for auto-sized content dimensions (default: sourced from theme)
---@field scaleCorners number? -- Scale multiplier for 9-slice corners/edges. E.g., 2 = 2x size (overrides theme setting)
---@field scalingAlgorithm "nearest"|"bilinear"? -- Scaling algorithm for 9-slice corners: "nearest" (sharp/pixelated) or "bilinear" (smooth) (overrides theme setting)
---@field contentBlur {intensity:number, quality:number}? -- Blur the element's content including children (intensity: 0-100, quality: 1-10, default: nil)
---@field backdropBlur {intensity:number, quality:number}? -- Blur content behind the element (intensity: 0-100, quality: 1-10, default: nil)
---@field editable boolean? -- Whether the element is editable (default: false)
---@field multiline boolean? -- Whether the element supports multiple lines (default: false)
---@field textWrap boolean|"word"|"char"? -- Text wrapping mode (default: false for single-line, "word" for multi-line)
---@field maxLines number? -- Maximum number of lines (default: nil)
---@field maxLength number? -- Maximum text length in characters (default: nil)
---@field placeholder string? -- Placeholder text when empty (default: nil)
---@field passwordMode boolean? -- Whether to display text as password (default: false)
---@field inputType "text"|"number"|"email"|"url"? -- Input type for validation (default: "text")
---@field textOverflow "clip"|"ellipsis"|"scroll"? -- Text overflow behavior (default: "clip")
---@field scrollable boolean? -- Whether text is scrollable (default: false for single-line, true for multi-line)
---@field autoGrow boolean? -- Whether element auto-grows with text (default: false)
---@field selectOnFocus boolean? -- Whether to select all text on focus (default: false)
---@field cursorColor Color? -- Cursor color (default: nil, uses textColor)
---@field selectionColor Color? -- Selection background color (default: nil, uses theme or default)
---@field cursorBlinkRate number? -- Cursor blink rate in seconds (default: 0.5)
local ElementProps = {}

---@param props ElementProps
---@return Element
function Element.new(props)
  local self = setmetatable({}, Element)
  self.children = {}
  self.callback = props.callback
  self.id = props.id or ""

  -- Input event callbacks
  self.onFocus = props.onFocus
  self.onBlur = props.onBlur
  self.onTextInput = props.onTextInput
  self.onTextChange = props.onTextChange
  self.onEnter = props.onEnter

  -- Initialize click tracking for event system
  self._pressed = {} -- Track pressed state per mouse button
  self._lastClickTime = nil
  self._lastClickButton = nil
  self._clickCount = 0
  self._touchPressed = {}

  -- Initialize theme
  self._themeState = "normal"

  -- Handle theme property:
  -- - theme: which theme to use (defaults to Gui.defaultTheme if not specified)
  -- - themeComponent: which component from the theme (e.g., "panel", "button", "input")
  -- If themeComponent is nil, no theme is applied (manual styling)
  self.theme = props.theme or Gui.defaultTheme
  self.themeComponent = props.themeComponent or nil

  -- Initialize state properties
  self.disabled = props.disabled or false
  self.active = props.active or false

  -- disableHighlight defaults to true when using themeComponent (themes handle their own visual feedback)
  -- Can be explicitly overridden by setting props.disableHighlight
  if props.disableHighlight ~= nil then
    self.disableHighlight = props.disableHighlight
  else
    self.disableHighlight = self.themeComponent ~= nil
  end

  -- Initialize contentAutoSizingMultiplier after theme is set
  -- Priority: element props > theme component > theme default
  if props.contentAutoSizingMultiplier then
    -- Explicitly set on element
    self.contentAutoSizingMultiplier = props.contentAutoSizingMultiplier
  else
    -- Try to source from theme
    local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
    if themeToUse then
      -- First check if themeComponent has a multiplier
      if self.themeComponent then
        local component = themeToUse.components[self.themeComponent]
        if component and component.contentAutoSizingMultiplier then
          self.contentAutoSizingMultiplier = component.contentAutoSizingMultiplier
        elseif themeToUse.contentAutoSizingMultiplier then
          -- Fall back to theme default
          self.contentAutoSizingMultiplier = themeToUse.contentAutoSizingMultiplier
        else
          self.contentAutoSizingMultiplier = { 1, 1 }
        end
      elseif themeToUse.contentAutoSizingMultiplier then
        self.contentAutoSizingMultiplier = themeToUse.contentAutoSizingMultiplier
      else
        self.contentAutoSizingMultiplier = { 1, 1 }
      end
    else
      self.contentAutoSizingMultiplier = { 1, 1 }
    end
  end

  -- Initialize 9-slice corner scaling properties
  -- These override theme component settings when specified
  self.scaleCorners = props.scaleCorners
  self.scalingAlgorithm = props.scalingAlgorithm

  -- Initialize blur properties
  self.contentBlur = props.contentBlur
  self.backdropBlur = props.backdropBlur
  self._blurInstance = nil

  -- Initialize input control properties
  self.editable = props.editable or false
  self.multiline = props.multiline or false
  self.passwordMode = props.passwordMode or false

  -- Validate property combinations: passwordMode disables multiline
  if self.passwordMode then
    self.multiline = false
  end

  self.textWrap = props.textWrap
  if self.textWrap == nil then
    self.textWrap = self.multiline and "word" or false
  end

  self.maxLines = props.maxLines
  self.maxLength = props.maxLength
  self.placeholder = props.placeholder
  self.inputType = props.inputType or "text"

  -- Text behavior properties
  self.textOverflow = props.textOverflow or "clip"
  self.scrollable = props.scrollable
  if self.scrollable == nil then
    self.scrollable = self.multiline
  end
  self.autoGrow = props.autoGrow or false
  self.selectOnFocus = props.selectOnFocus or false

  -- Cursor and selection properties
  self.cursorColor = props.cursorColor
  self.selectionColor = props.selectionColor
  self.cursorBlinkRate = props.cursorBlinkRate or 0.5

  -- Initialize cursor and selection state (only if editable)
  if self.editable then
    self._cursorPosition = 0 -- Character index (0 = before first char)
    self._cursorLine = 1 -- Current line number (1-based)
    self._cursorColumn = 0 -- Column within current line
    self._cursorBlinkTimer = 0
    self._cursorVisible = true

    -- Selection state
    self._selectionStart = nil -- nil = no selection
    self._selectionEnd = nil
    self._selectionAnchor = nil -- Anchor point for shift+arrow selection

    -- Focus state
    self._focused = false

    -- Text buffer state (initialized after self.text is set below)
    self._textBuffer = props.text or "" -- Actual text content
    self._lines = nil -- Split lines (for multiline)
    self._wrappedLines = nil -- Wrapped line data
    self._textDirty = true -- Flag to recalculate lines/wrapping
  end

  -- Set parent first so it's available for size calculations
  self.parent = props.parent

  ------ add non-hereditary ------
  --- self drawing---
  self.border = props.border
      and {
        top = props.border.top or false,
        right = props.border.right or false,
        bottom = props.border.bottom or false,
        left = props.border.left or false,
      }
    or {
      top = false,
      right = false,
      bottom = false,
      left = false,
    }
  self.borderColor = props.borderColor or Color.new(0, 0, 0, 1)
  self.backgroundColor = props.backgroundColor or Color.new(0, 0, 0, 0)
  self.opacity = props.opacity or 1

  -- Handle cornerRadius (can be number or table)
  if props.cornerRadius then
    if type(props.cornerRadius) == "number" then
      self.cornerRadius = {
        topLeft = props.cornerRadius,
        topRight = props.cornerRadius,
        bottomLeft = props.cornerRadius,
        bottomRight = props.cornerRadius,
      }
    else
      self.cornerRadius = {
        topLeft = props.cornerRadius.topLeft or 0,
        topRight = props.cornerRadius.topRight or 0,
        bottomLeft = props.cornerRadius.bottomLeft or 0,
        bottomRight = props.cornerRadius.bottomRight or 0,
      }
    end
  else
    self.cornerRadius = {
      topLeft = 0,
      topRight = 0,
      bottomLeft = 0,
      bottomRight = 0,
    }
  end

  self.text = props.text
  self.textAlign = props.textAlign or TextAlign.START

  -- Image properties
  self.imagePath = props.imagePath
  self.image = props.image
  self.objectFit = props.objectFit or "fill"
  self.objectPosition = props.objectPosition or "center center"
  self.imageOpacity = props.imageOpacity or 1
  
  -- Auto-load image if imagePath is provided
  if self.imagePath and not self.image then
    local loadedImage, err = ImageCache.load(self.imagePath)
    if loadedImage then
      self._loadedImage = loadedImage
    else
      -- Silently fail - image will just not render
      self._loadedImage = nil
    end
  elseif self.image then
    self._loadedImage = self.image
  else
    self._loadedImage = nil
  end

  --- self positioning ---
  local viewportWidth, viewportHeight = Units.getViewport()

  ---- Sizing ----
  local gw, gh = love.window.getMode()
  self.prevGameSize = { width = gw, height = gh }
  self.autosizing = { width = false, height = false }

  -- Store unit specifications for responsive behavior
  self.units = {
    width = { value = nil, unit = "px" },
    height = { value = nil, unit = "px" },
    x = { value = nil, unit = "px" },
    y = { value = nil, unit = "px" },
    textSize = { value = nil, unit = "px" },
    gap = { value = nil, unit = "px" },
    padding = {
      top = { value = nil, unit = "px" },
      right = { value = nil, unit = "px" },
      bottom = { value = nil, unit = "px" },
      left = { value = nil, unit = "px" },
      horizontal = { value = nil, unit = "px" }, -- Shorthand for left/right
      vertical = { value = nil, unit = "px" }, -- Shorthand for top/bottom
    },
    margin = {
      top = { value = nil, unit = "px" },
      right = { value = nil, unit = "px" },
      bottom = { value = nil, unit = "px" },
      left = { value = nil, unit = "px" },
      horizontal = { value = nil, unit = "px" }, -- Shorthand for left/right
      vertical = { value = nil, unit = "px" }, -- Shorthand for top/bottom
    },
  }

  -- Get scale factors from Gui (will be used later)
  local scaleX, scaleY = Gui.getScaleFactors()

  -- Store original textSize units and constraints
  self.minTextSize = props.minTextSize
  self.maxTextSize = props.maxTextSize

  -- Set autoScaleText BEFORE textSize processing (needed for correct initialization)
  if props.autoScaleText == nil then
    self.autoScaleText = true
  else
    self.autoScaleText = props.autoScaleText
  end

  -- Handle fontFamily (can be font name from theme or direct path to font file)
  -- Priority: explicit props.fontFamily > parent fontFamily > theme default
  if props.fontFamily then
    -- Explicitly set fontFamily takes highest priority
    self.fontFamily = props.fontFamily
  elseif self.parent and self.parent.fontFamily then
    -- Inherit from parent if parent has fontFamily set
    self.fontFamily = self.parent.fontFamily
  elseif props.themeComponent then
    -- If using themeComponent, try to get default from theme
    local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
    if themeToUse and themeToUse.fonts and themeToUse.fonts["default"] then
      self.fontFamily = "default"
    else
      self.fontFamily = nil
    end
  else
    self.fontFamily = nil
  end

  -- Handle textSize BEFORE width/height calculation (needed for auto-sizing)
  if props.textSize then
    if type(props.textSize) == "string" then
      -- Check if it's a preset first
      local presetValue, presetUnit = resolveTextSizePreset(props.textSize)
      local value, unit

      if presetValue then
        -- It's a preset, use the preset value and unit
        value, unit = presetValue, presetUnit
        self.units.textSize = { value = value, unit = unit }
      else
        -- Not a preset, parse normally
        value, unit = Units.parse(props.textSize)
        self.units.textSize = { value = value, unit = unit }
      end

      -- Resolve textSize based on unit type
      if unit == "%" or unit == "vh" then
        -- Percentage and vh are relative to viewport height
        self.textSize = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
      elseif unit == "vw" then
        -- vw is relative to viewport width
        self.textSize = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
      elseif unit == "ew" then
        -- ew is relative to element width (use viewport width as fallback during initialization)
        -- Will be re-resolved after width is set
        self.textSize = (value / 100) * viewportWidth
      elseif unit == "eh" then
        -- eh is relative to element height (use viewport height as fallback during initialization)
        -- Will be re-resolved after height is set
        self.textSize = (value / 100) * viewportHeight
      elseif unit == "px" then
        -- Pixel units
        self.textSize = value
      else
        error("Unknown textSize unit: " .. unit)
      end
    else
      -- Validate pixel textSize value
      if props.textSize <= 0 then
        error("textSize must be greater than 0, got: " .. tostring(props.textSize))
      end

      -- Pixel textSize value
      if self.autoScaleText and Gui.baseScale then
        -- With base scaling: store original pixel value and scale relative to base resolution
        self.units.textSize = { value = props.textSize, unit = "px" }
        self.textSize = props.textSize * scaleY
      elseif self.autoScaleText then
        -- Without base scaling: convert to viewport units for auto-scaling
        -- Calculate what percentage of viewport height this represents
        local vhValue = (props.textSize / viewportHeight) * 100
        self.units.textSize = { value = vhValue, unit = "vh" }
        self.textSize = props.textSize -- Initial size is the specified pixel value
      else
        -- No auto-scaling: apply base scaling if set, otherwise use raw value
        self.textSize = Gui.baseScale and (props.textSize * scaleY) or props.textSize
        self.units.textSize = { value = props.textSize, unit = "px" }
      end
    end
  else
    -- No textSize specified - use auto-scaling default
    if self.autoScaleText and Gui.baseScale then
      -- With base scaling: use 12px as default and scale
      self.units.textSize = { value = 12, unit = "px" }
      self.textSize = 12 * scaleY
    elseif self.autoScaleText then
      -- Without base scaling: default to 1.5vh (1.5% of viewport height)
      self.units.textSize = { value = 1.5, unit = "vh" }
      self.textSize = (1.5 / 100) * viewportHeight
    else
      -- No auto-scaling: use 12px with optional base scaling
      self.textSize = Gui.baseScale and (12 * scaleY) or 12
      self.units.textSize = { value = nil, unit = "px" }
    end
  end

  -- Handle width (both w and width properties, prefer w if both exist)
  local widthProp = props.width
  local tempWidth = 0 -- Temporary width for padding resolution
  if widthProp then
    if type(widthProp) == "string" then
      local value, unit = Units.parse(widthProp)
      self.units.width = { value = value, unit = unit }
      local parentWidth = self.parent and self.parent.width or viewportWidth
      tempWidth = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
    else
      -- Apply base scaling to pixel values
      tempWidth = Gui.baseScale and (widthProp * scaleX) or widthProp
      self.units.width = { value = widthProp, unit = "px" }
    end
    self.width = tempWidth
  else
    self.autosizing.width = true
    -- Calculate auto-width without padding first
    tempWidth = self:calculateAutoWidth()
    self.width = tempWidth
    self.units.width = { value = nil, unit = "auto" } -- Mark as auto-sized
  end

  -- Handle height (both h and height properties, prefer h if both exist)
  local heightProp = props.height
  local tempHeight = 0 -- Temporary height for padding resolution
  if heightProp then
    if type(heightProp) == "string" then
      local value, unit = Units.parse(heightProp)
      self.units.height = { value = value, unit = unit }
      local parentHeight = self.parent and self.parent.height or viewportHeight
      tempHeight = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
    else
      -- Apply base scaling to pixel values
      tempHeight = Gui.baseScale and (heightProp * scaleY) or heightProp
      self.units.height = { value = heightProp, unit = "px" }
    end
    self.height = tempHeight
  else
    self.autosizing.height = true
    -- Calculate auto-height without padding first
    tempHeight = self:calculateAutoHeight()
    self.height = tempHeight
    self.units.height = { value = nil, unit = "auto" } -- Mark as auto-sized
  end

  --- child positioning ---
  if props.gap then
    if type(props.gap) == "string" then
      local value, unit = Units.parse(props.gap)
      self.units.gap = { value = value, unit = unit }
      -- Gap percentages should be relative to the element's own size, not parent
      -- For horizontal flex, gap is based on width; for vertical flex, based on height
      local flexDir = props.flexDirection or FlexDirection.HORIZONTAL
      local containerSize = (flexDir == FlexDirection.HORIZONTAL) and self.width or self.height
      self.gap = Units.resolve(value, unit, viewportWidth, viewportHeight, containerSize)
    else
      self.gap = props.gap
      self.units.gap = { value = props.gap, unit = "px" }
    end
  else
    self.gap = 0
    self.units.gap = { value = 0, unit = "px" }
  end

  -- BORDER-BOX MODEL: For auto-sizing, we need to add padding to content dimensions
  -- For explicit sizing, width/height already include padding (border-box)

  -- Check if we should use 9-patch content padding for auto-sizing
  local use9PatchPadding = false
  local ninePatchContentPadding = nil
  if self.themeComponent then
    local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
    if themeToUse and themeToUse.components[self.themeComponent] then
      local component = themeToUse.components[self.themeComponent]
      if component._ninePatchData and component._ninePatchData.contentPadding then
        -- Only use 9-patch padding if no explicit padding was provided
        if
          not props.padding
          or (
            not props.padding.top
            and not props.padding.right
            and not props.padding.bottom
            and not props.padding.left
            and not props.padding.horizontal
            and not props.padding.vertical
          )
        then
          use9PatchPadding = true
          ninePatchContentPadding = component._ninePatchData.contentPadding
        end
      end
    end
  end

  -- First, resolve padding using temporary dimensions
  -- For auto-sized elements, this is content width; for explicit sizing, this is border-box width
  local tempPadding
  if use9PatchPadding then
    -- Scale 9-patch content padding to match the actual rendered size
    -- The contentPadding values are in the original image's pixel coordinates,
    -- but we need to scale them proportionally to the element's actual size
    local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
    if themeToUse and themeToUse.components[self.themeComponent] then
      local component = themeToUse.components[self.themeComponent]
      local atlasImage = component._loadedAtlas or themeToUse.atlas

      if atlasImage and type(atlasImage) ~= "string" then
        local originalWidth, originalHeight = atlasImage:getDimensions()

        -- Calculate the scale factor based on the element's border-box size vs original image size
        -- For explicit sizing, tempWidth/tempHeight represent the border-box dimensions
        local scaleX = tempWidth / originalWidth
        local scaleY = tempHeight / originalHeight

        tempPadding = {
          left = ninePatchContentPadding.left * scaleX,
          top = ninePatchContentPadding.top * scaleY,
          right = ninePatchContentPadding.right * scaleX,
          bottom = ninePatchContentPadding.bottom * scaleY,
        }
      else
        -- Fallback if atlas image not available
        tempPadding = {
          left = ninePatchContentPadding.left,
          top = ninePatchContentPadding.top,
          right = ninePatchContentPadding.right,
          bottom = ninePatchContentPadding.bottom,
        }
      end
    else
      -- Fallback if theme not found
      tempPadding = {
        left = ninePatchContentPadding.left,
        top = ninePatchContentPadding.top,
        right = ninePatchContentPadding.right,
        bottom = ninePatchContentPadding.bottom,
      }
    end
  else
    tempPadding = Units.resolveSpacing(props.padding, self.width, self.height)
  end

  -- Margin percentages are relative to parent's dimensions (CSS spec)
  local parentWidth = self.parent and self.parent.width or viewportWidth
  local parentHeight = self.parent and self.parent.height or viewportHeight
  self.margin = Units.resolveSpacing(props.margin, parentWidth, parentHeight)

  -- For auto-sized elements, add padding to get border-box dimensions
  if self.autosizing.width then
    self._borderBoxWidth = self.width + tempPadding.left + tempPadding.right
  else
    -- For explicit sizing, width is already border-box
    self._borderBoxWidth = self.width
  end

  if self.autosizing.height then
    self._borderBoxHeight = self.height + tempPadding.top + tempPadding.bottom
  else
    -- For explicit sizing, height is already border-box
    self._borderBoxHeight = self.height
  end

  -- Set final padding
  if use9PatchPadding then
    -- Use 9-patch content padding
    self.padding = {
      left = ninePatchContentPadding.left,
      top = ninePatchContentPadding.top,
      right = ninePatchContentPadding.right,
      bottom = ninePatchContentPadding.bottom,
    }
  else
    -- Re-resolve padding based on final border-box dimensions (important for percentage padding)
    self.padding = Units.resolveSpacing(props.padding, self._borderBoxWidth, self._borderBoxHeight)
  end

  -- Calculate final content dimensions by subtracting padding from border-box
  self.width = math.max(0, self._borderBoxWidth - self.padding.left - self.padding.right)
  self.height = math.max(0, self._borderBoxHeight - self.padding.top - self.padding.bottom)

  -- Re-resolve ew/eh textSize units now that width/height are set
  if props.textSize and type(props.textSize) == "string" then
    local value, unit = Units.parse(props.textSize)
    if unit == "ew" then
      -- Element width relative (now that width is set)
      self.textSize = (value / 100) * self.width
    elseif unit == "eh" then
      -- Element height relative (now that height is set)
      self.textSize = (value / 100) * self.height
    end
  end

  -- Apply min/max constraints (also scaled)
  local minSize = self.minTextSize and (Gui.baseScale and (self.minTextSize * scaleY) or self.minTextSize)
  local maxSize = self.maxTextSize and (Gui.baseScale and (self.maxTextSize * scaleY) or self.maxTextSize)

  if minSize and self.textSize < minSize then
    self.textSize = minSize
  end
  if maxSize and self.textSize > maxSize then
    self.textSize = maxSize
  end

  -- Protect against too-small text sizes (minimum 1px)
  if self.textSize < 1 then
    self.textSize = 1 -- Minimum 1px
  end

  -- Store original spacing values for proper resize handling
  -- Store shorthand properties first (horizontal/vertical)
  if props.padding then
    if props.padding.horizontal then
      if type(props.padding.horizontal) == "string" then
        local value, unit = Units.parse(props.padding.horizontal)
        self.units.padding.horizontal = { value = value, unit = unit }
      else
        self.units.padding.horizontal = { value = props.padding.horizontal, unit = "px" }
      end
    end
    if props.padding.vertical then
      if type(props.padding.vertical) == "string" then
        local value, unit = Units.parse(props.padding.vertical)
        self.units.padding.vertical = { value = value, unit = unit }
      else
        self.units.padding.vertical = { value = props.padding.vertical, unit = "px" }
      end
    end
  end

  -- Initialize all padding sides
  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    if props.padding and props.padding[side] then
      if type(props.padding[side]) == "string" then
        local value, unit = Units.parse(props.padding[side])
        self.units.padding[side] = { value = value, unit = unit, explicit = true }
      else
        self.units.padding[side] = { value = props.padding[side], unit = "px", explicit = true }
      end
    else
      -- Mark as derived from shorthand (will use shorthand during resize if available)
      self.units.padding[side] = { value = self.padding[side], unit = "px", explicit = false }
    end
  end

  -- Store margin shorthand properties
  if props.margin then
    if props.margin.horizontal then
      if type(props.margin.horizontal) == "string" then
        local value, unit = Units.parse(props.margin.horizontal)
        self.units.margin.horizontal = { value = value, unit = unit }
      else
        self.units.margin.horizontal = { value = props.margin.horizontal, unit = "px" }
      end
    end
    if props.margin.vertical then
      if type(props.margin.vertical) == "string" then
        local value, unit = Units.parse(props.margin.vertical)
        self.units.margin.vertical = { value = value, unit = unit }
      else
        self.units.margin.vertical = { value = props.margin.vertical, unit = "px" }
      end
    end
  end

  -- Initialize all margin sides
  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    if props.margin and props.margin[side] then
      if type(props.margin[side]) == "string" then
        local value, unit = Units.parse(props.margin[side])
        self.units.margin[side] = { value = value, unit = unit, explicit = true }
      else
        self.units.margin[side] = { value = props.margin[side], unit = "px", explicit = true }
      end
    else
      -- Mark as derived from shorthand (will use shorthand during resize if available)
      self.units.margin[side] = { value = self.margin[side], unit = "px", explicit = false }
    end
  end

  -- Grid properties are set later in the constructor

  ------ add hereditary ------
  if props.parent == nil then
    table.insert(Gui.topElements, self)

    -- Handle x position with units
    if props.x then
      if type(props.x) == "string" then
        local value, unit = Units.parse(props.x)
        self.units.x = { value = value, unit = unit }
        self.x = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
      else
        -- Apply base scaling to pixel positions
        self.x = Gui.baseScale and (props.x * scaleX) or props.x
        self.units.x = { value = props.x, unit = "px" }
      end
    else
      self.x = 0
      self.units.x = { value = 0, unit = "px" }
    end

    -- Handle y position with units
    if props.y then
      if type(props.y) == "string" then
        local value, unit = Units.parse(props.y)
        self.units.y = { value = value, unit = unit }
        self.y = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
      else
        -- Apply base scaling to pixel positions
        self.y = Gui.baseScale and (props.y * scaleY) or props.y
        self.units.y = { value = props.y, unit = "px" }
      end
    else
      self.y = 0
      self.units.y = { value = 0, unit = "px" }
    end

    self.z = props.z or 0

    -- Set textColor with priority: props > theme text color > black
    if props.textColor then
      self.textColor = props.textColor
    else
      -- Try to get text color from theme
      local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
      if themeToUse and themeToUse.colors and themeToUse.colors.text then
        self.textColor = themeToUse.colors.text
      else
        -- Fallback to black
        self.textColor = Color.new(0, 0, 0, 1)
      end
    end

    -- Track if positioning was explicitly set
    if props.positioning then
      self.positioning = props.positioning
      self._originalPositioning = props.positioning
      self._explicitlyAbsolute = (props.positioning == Positioning.ABSOLUTE)
    else
      self.positioning = Positioning.RELATIVE
      self._originalPositioning = nil -- No explicit positioning
      self._explicitlyAbsolute = false
    end
  else
    -- Set positioning first and track if explicitly set
    self._originalPositioning = props.positioning -- Track original intent
    if props.positioning == Positioning.ABSOLUTE then
      self.positioning = Positioning.ABSOLUTE
      self._explicitlyAbsolute = true -- Explicitly set to absolute by user
    elseif props.positioning == Positioning.FLEX then
      self.positioning = Positioning.FLEX
      self._explicitlyAbsolute = false
    elseif props.positioning == Positioning.GRID then
      self.positioning = Positioning.GRID
      self._explicitlyAbsolute = false
    else
      -- Default: children in flex/grid containers participate in parent's layout
      -- children in relative/absolute containers default to relative
      if self.parent.positioning == Positioning.FLEX or self.parent.positioning == Positioning.GRID then
        self.positioning = Positioning.ABSOLUTE -- They are positioned BY flex/grid, not AS flex/grid
        self._explicitlyAbsolute = false -- Participate in parent's layout
      else
        self.positioning = Positioning.RELATIVE
        self._explicitlyAbsolute = false -- Default for relative/absolute containers
      end
    end

    -- Set initial position
    if self.positioning == Positioning.ABSOLUTE then
      -- Handle x position with units
      if props.x then
        if type(props.x) == "string" then
          local value, unit = Units.parse(props.x)
          self.units.x = { value = value, unit = unit }
          local parentWidth = self.parent.width
          self.x = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
        else
          -- Apply base scaling to pixel positions
          self.x = Gui.baseScale and (props.x * scaleX) or props.x
          self.units.x = { value = props.x, unit = "px" }
        end
      else
        self.x = 0
        self.units.x = { value = 0, unit = "px" }
      end

      -- Handle y position with units
      if props.y then
        if type(props.y) == "string" then
          local value, unit = Units.parse(props.y)
          self.units.y = { value = value, unit = unit }
          local parentHeight = self.parent.height
          self.y = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
        else
          -- Apply base scaling to pixel positions
          self.y = Gui.baseScale and (props.y * scaleY) or props.y
          self.units.y = { value = props.y, unit = "px" }
        end
      else
        self.y = 0
        self.units.y = { value = 0, unit = "px" }
      end

      self.z = props.z or 0
    else
      -- Children in flex containers start at parent position but will be repositioned by layoutChildren
      local baseX = self.parent.x
      local baseY = self.parent.y

      if props.x then
        if type(props.x) == "string" then
          local value, unit = Units.parse(props.x)
          self.units.x = { value = value, unit = unit }
          local parentWidth = self.parent.width
          local offsetX = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
          self.x = baseX + offsetX
        else
          -- Apply base scaling to pixel offsets
          local scaledOffset = Gui.baseScale and (props.x * scaleX) or props.x
          self.x = baseX + scaledOffset
          self.units.x = { value = props.x, unit = "px" }
        end
      else
        self.x = baseX
        self.units.x = { value = 0, unit = "px" }
      end

      if props.y then
        if type(props.y) == "string" then
          local value, unit = Units.parse(props.y)
          self.units.y = { value = value, unit = unit }
          local parentHeight = self.parent.height
          local offsetY = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
          self.y = baseY + offsetY
        else
          -- Apply base scaling to pixel offsets
          local scaledOffset = Gui.baseScale and (props.y * scaleY) or props.y
          self.y = baseY + scaledOffset
          self.units.y = { value = props.y, unit = "px" }
        end
      else
        self.y = baseY
        self.units.y = { value = 0, unit = "px" }
      end

      self.z = props.z or self.parent.z or 0
    end

    -- Set textColor with priority: props > parent > theme text color > black
    if props.textColor then
      self.textColor = props.textColor
    elseif self.parent.textColor then
      self.textColor = self.parent.textColor
    else
      -- Try to get text color from theme
      local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
      if themeToUse and themeToUse.colors and themeToUse.colors.text then
        self.textColor = themeToUse.colors.text
      else
        -- Fallback to black
        self.textColor = Color.new(0, 0, 0, 1)
      end
    end

    props.parent:addChild(self)
  end

  -- Handle positioning properties for ALL elements (with or without parent)
  -- Handle top positioning with units
  if props.top then
    if type(props.top) == "string" then
      local value, unit = Units.parse(props.top)
      self.units.top = { value = value, unit = unit }
      self.top = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
    else
      self.top = props.top
      self.units.top = { value = props.top, unit = "px" }
    end
  else
    self.top = nil
    self.units.top = nil
  end

  -- Handle right positioning with units
  if props.right then
    if type(props.right) == "string" then
      local value, unit = Units.parse(props.right)
      self.units.right = { value = value, unit = unit }
      self.right = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
    else
      self.right = props.right
      self.units.right = { value = props.right, unit = "px" }
    end
  else
    self.right = nil
    self.units.right = nil
  end

  -- Handle bottom positioning with units
  if props.bottom then
    if type(props.bottom) == "string" then
      local value, unit = Units.parse(props.bottom)
      self.units.bottom = { value = value, unit = unit }
      self.bottom = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
    else
      self.bottom = props.bottom
      self.units.bottom = { value = props.bottom, unit = "px" }
    end
  else
    self.bottom = nil
    self.units.bottom = nil
  end

  -- Handle left positioning with units
  if props.left then
    if type(props.left) == "string" then
      local value, unit = Units.parse(props.left)
      self.units.left = { value = value, unit = unit }
      self.left = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
    else
      self.left = props.left
      self.units.left = { value = props.left, unit = "px" }
    end
  else
    self.left = nil
    self.units.left = nil
  end

  if self.positioning == Positioning.FLEX then
    self.flexDirection = props.flexDirection or FlexDirection.HORIZONTAL
    self.flexWrap = props.flexWrap or FlexWrap.NOWRAP
    self.justifyContent = props.justifyContent or JustifyContent.FLEX_START
    self.alignItems = props.alignItems or AlignItems.STRETCH
    self.alignContent = props.alignContent or AlignContent.STRETCH
    self.justifySelf = props.justifySelf or JustifySelf.AUTO
  end

  -- Grid container properties
  if self.positioning == Positioning.GRID then
    self.gridRows = props.gridRows or 1
    self.gridColumns = props.gridColumns or 1
    self.alignItems = props.alignItems or AlignItems.STRETCH

    -- Handle columnGap and rowGap
    if props.columnGap then
      if type(props.columnGap) == "string" then
        local value, unit = Units.parse(props.columnGap)
        self.columnGap = Units.resolve(value, unit, viewportWidth, viewportHeight, self.width)
      else
        self.columnGap = props.columnGap
      end
    else
      self.columnGap = 0
    end

    if props.rowGap then
      if type(props.rowGap) == "string" then
        local value, unit = Units.parse(props.rowGap)
        self.rowGap = Units.resolve(value, unit, viewportWidth, viewportHeight, self.height)
      else
        self.rowGap = props.rowGap
      end
    else
      self.rowGap = 0
    end
  end

  self.alignSelf = props.alignSelf or AlignSelf.AUTO

  ---animation
  self.transform = props.transform or {}
  self.transition = props.transition or {}

  return self
end

--- Get element bounds (content box)
---@return { x:number, y:number, width:number, height:number }
function Element:getBounds()
  return { x = self.x, y = self.y, width = self:getBorderBoxWidth(), height = self:getBorderBoxHeight() }
end

--- Get border-box width (including padding)
---@return number
function Element:getBorderBoxWidth()
  return self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
end

--- Get border-box height (including padding)
---@return number
function Element:getBorderBoxHeight()
  return self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)
end

--- Get the current state's scaled content padding
--- Returns the contentPadding for the current theme state, scaled to the element's size
---@return table|nil -- {left, top, right, bottom} or nil if no contentPadding
function Element:getScaledContentPadding()
  if not self.themeComponent then
    return nil
  end

  local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
  if not themeToUse or not themeToUse.components[self.themeComponent] then
    return nil
  end

  local component = themeToUse.components[self.themeComponent]

  -- Check for state-specific override
  local state = self._themeState or "normal"
  if state and state ~= "normal" and component.states and component.states[state] then
    component = component.states[state]
  end

  if not component._ninePatchData or not component._ninePatchData.contentPadding then
    return nil
  end

  local contentPadding = component._ninePatchData.contentPadding

  -- Scale contentPadding to match the actual rendered size
  local atlasImage = component._loadedAtlas or themeToUse.atlas
  if atlasImage and type(atlasImage) ~= "string" then
    local originalWidth, originalHeight = atlasImage:getDimensions()
    local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
    local borderBoxHeight = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)
    local scaleX = borderBoxWidth / originalWidth
    local scaleY = borderBoxHeight / originalHeight

    return {
      left = contentPadding.left * scaleX,
      top = contentPadding.top * scaleY,
      right = contentPadding.right * scaleX,
      bottom = contentPadding.bottom * scaleY,
    }
  else
    -- Return unscaled values as fallback
    return {
      left = contentPadding.left,
      top = contentPadding.top,
      right = contentPadding.right,
      bottom = contentPadding.bottom,
    }
  end
end

--- Get or create blur instance for this element
---@return table? -- Blur instance or nil if no blur configured
function Element:getBlurInstance()
  -- Determine quality from contentBlur or backdropBlur
  local quality = 5 -- Default quality
  if self.contentBlur and self.contentBlur.quality then
    quality = self.contentBlur.quality
  elseif self.backdropBlur and self.backdropBlur.quality then
    quality = self.backdropBlur.quality
  end

  -- Create blur instance if needed
  if not self._blurInstance or self._blurInstance.quality ~= quality then
    self._blurInstance = Blur.new(quality)
  end

  return self._blurInstance
end

--- Get available content width for children (accounting for 9-slice content padding)
--- This is the width that children should use when calculating percentage widths
---@return number
function Element:getAvailableContentWidth()
  local availableWidth = self.width

  local scaledContentPadding = self:getScaledContentPadding()
  if scaledContentPadding then
    -- Check if the element is using the scaled 9-patch contentPadding as its padding
    -- Allow small floating point differences (within 0.1 pixels)
    local usingContentPaddingAsPadding = (
      math.abs(self.padding.left - scaledContentPadding.left) < 0.1 and math.abs(self.padding.right - scaledContentPadding.right) < 0.1
    )

    if not usingContentPaddingAsPadding then
      -- Element has explicit padding different from contentPadding
      -- Subtract scaled contentPadding to get the area children should use
      availableWidth = availableWidth - scaledContentPadding.left - scaledContentPadding.right
    end
  end

  return math.max(0, availableWidth)
end

--- Get available content height for children (accounting for 9-slice content padding)
--- This is the height that children should use when calculating percentage heights
---@return number
function Element:getAvailableContentHeight()
  local availableHeight = self.height

  local scaledContentPadding = self:getScaledContentPadding()
  if scaledContentPadding then
    -- Check if the element is using the scaled 9-patch contentPadding as its padding
    -- Allow small floating point differences (within 0.1 pixels)
    local usingContentPaddingAsPadding = (
      math.abs(self.padding.top - scaledContentPadding.top) < 0.1 and math.abs(self.padding.bottom - scaledContentPadding.bottom) < 0.1
    )

    if not usingContentPaddingAsPadding then
      -- Element has explicit padding different from contentPadding
      -- Subtract scaled contentPadding to get the area children should use
      availableHeight = availableHeight - scaledContentPadding.top - scaledContentPadding.bottom
    end
  end

  return math.max(0, availableHeight)
end

--- Add child to element
---@param child Element
function Element:addChild(child)
  child.parent = self

  -- Re-evaluate positioning now that we have a parent
  -- If child was created without explicit positioning, inherit from parent
  if child._originalPositioning == nil then
    -- No explicit positioning was set during construction
    if self.positioning == Positioning.FLEX or self.positioning == Positioning.GRID then
      child.positioning = Positioning.ABSOLUTE -- They are positioned BY flex/grid, not AS flex/grid
      child._explicitlyAbsolute = false -- Participate in parent's layout
    else
      child.positioning = Positioning.RELATIVE
      child._explicitlyAbsolute = false -- Default for relative/absolute containers
    end
  end
  -- If child._originalPositioning is set, it means explicit positioning was provided
  -- and _explicitlyAbsolute was already set correctly during construction

  table.insert(self.children, child)

  -- Only recalculate auto-sizing if the child participates in layout
  -- (CSS: absolutely positioned children don't affect parent auto-sizing)
  if not child._explicitlyAbsolute then
    if self.autosizing.height then
      local contentHeight = self:calculateAutoHeight()
      -- BORDER-BOX MODEL: Add padding to get border-box, then subtract to get content
      self._borderBoxHeight = contentHeight + self.padding.top + self.padding.bottom
      self.height = contentHeight
    end
    if self.autosizing.width then
      local contentWidth = self:calculateAutoWidth()
      -- BORDER-BOX MODEL: Add padding to get border-box, then subtract to get content
      self._borderBoxWidth = contentWidth + self.padding.left + self.padding.right
      self.width = contentWidth
    end
  end

  self:layoutChildren()
end

--- Apply positioning offsets (top, right, bottom, left) to an element
-- @param element The element to apply offsets to
function Element:applyPositioningOffsets(element)
  if not element then
    return
  end

  -- For CSS-style positioning, we need the parent's bounds
  local parent = element.parent
  if not parent then
    return
  end

  -- Only apply offsets to explicitly absolute children or children in relative/absolute containers
  -- Flex/grid children ignore positioning offsets as they participate in layout
  local isFlexChild = element.positioning == Positioning.FLEX
    or element.positioning == Positioning.GRID
    or (element.positioning == Positioning.ABSOLUTE and not element._explicitlyAbsolute)

  if not isFlexChild then
    -- Apply absolute positioning for explicitly absolute children
    -- Apply top offset (distance from parent's content box top edge)
    if element.top then
      element.y = parent.y + parent.padding.top + element.top
    end

    -- Apply bottom offset (distance from parent's content box bottom edge)
    -- BORDER-BOX MODEL: Use border-box dimensions for positioning
    if element.bottom then
      local elementBorderBoxHeight = element:getBorderBoxHeight()
      element.y = parent.y + parent.padding.top + parent.height - element.bottom - elementBorderBoxHeight
    end

    -- Apply left offset (distance from parent's content box left edge)
    if element.left then
      element.x = parent.x + parent.padding.left + element.left
    end

    -- Apply right offset (distance from parent's content box right edge)
    -- BORDER-BOX MODEL: Use border-box dimensions for positioning
    if element.right then
      local elementBorderBoxWidth = element:getBorderBoxWidth()
      element.x = parent.x + parent.padding.left + parent.width - element.right - elementBorderBoxWidth
    end
  end
end

function Element:layoutChildren()
  if self.positioning == Positioning.ABSOLUTE or self.positioning == Positioning.RELATIVE then
    -- Absolute/Relative positioned containers don't layout their children according to flex rules,
    -- but they should still apply CSS positioning offsets to their children
    for _, child in ipairs(self.children) do
      if child.top or child.right or child.bottom or child.left then
        self:applyPositioningOffsets(child)
      end
    end
    return
  end

  -- Handle grid layout
  if self.positioning == Positioning.GRID then
    Grid.layoutGridItems(self)
    return
  end

  local childCount = #self.children

  if childCount == 0 then
    return
  end

  -- Get flex children (children that participate in flex layout)
  local flexChildren = {}
  for _, child in ipairs(self.children) do
    local isFlexChild = not (child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute)
    if isFlexChild then
      table.insert(flexChildren, child)
    end
  end

  if #flexChildren == 0 then
    return
  end

  -- Calculate space reserved by absolutely positioned siblings with explicit positioning
  local reservedMainStart = 0 -- Space reserved at the start of main axis (left for horizontal, top for vertical)
  local reservedMainEnd = 0 -- Space reserved at the end of main axis (right for horizontal, bottom for vertical)
  local reservedCrossStart = 0 -- Space reserved at the start of cross axis (top for horizontal, left for vertical)
  local reservedCrossEnd = 0 -- Space reserved at the end of cross axis (bottom for horizontal, right for vertical)

  for _, child in ipairs(self.children) do
    -- Only consider absolutely positioned children with explicit positioning
    if child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute then
      -- BORDER-BOX MODEL: Use border-box dimensions for space calculations
      local childBorderBoxWidth = child:getBorderBoxWidth()
      local childBorderBoxHeight = child:getBorderBoxHeight()

      if self.flexDirection == FlexDirection.HORIZONTAL then
        -- Horizontal layout: main axis is X, cross axis is Y
        -- Check for left positioning (reserves space at main axis start)
        if child.left then
          local spaceNeeded = child.left + childBorderBoxWidth
          reservedMainStart = math.max(reservedMainStart, spaceNeeded)
        end
        -- Check for right positioning (reserves space at main axis end)
        if child.right then
          local spaceNeeded = child.right + childBorderBoxWidth
          reservedMainEnd = math.max(reservedMainEnd, spaceNeeded)
        end
        -- Check for top positioning (reserves space at cross axis start)
        if child.top then
          local spaceNeeded = child.top + childBorderBoxHeight
          reservedCrossStart = math.max(reservedCrossStart, spaceNeeded)
        end
        -- Check for bottom positioning (reserves space at cross axis end)
        if child.bottom then
          local spaceNeeded = child.bottom + childBorderBoxHeight
          reservedCrossEnd = math.max(reservedCrossEnd, spaceNeeded)
        end
      else
        -- Vertical layout: main axis is Y, cross axis is X
        -- Check for top positioning (reserves space at main axis start)
        if child.top then
          local spaceNeeded = child.top + childBorderBoxHeight
          reservedMainStart = math.max(reservedMainStart, spaceNeeded)
        end
        -- Check for bottom positioning (reserves space at main axis end)
        if child.bottom then
          local spaceNeeded = child.bottom + childBorderBoxHeight
          reservedMainEnd = math.max(reservedMainEnd, spaceNeeded)
        end
        -- Check for left positioning (reserves space at cross axis start)
        if child.left then
          local spaceNeeded = child.left + childBorderBoxWidth
          reservedCrossStart = math.max(reservedCrossStart, spaceNeeded)
        end
        -- Check for right positioning (reserves space at cross axis end)
        if child.right then
          local spaceNeeded = child.right + childBorderBoxWidth
          reservedCrossEnd = math.max(reservedCrossEnd, spaceNeeded)
        end
      end
    end
  end

  -- Calculate available space (accounting for padding and reserved space)
  -- BORDER-BOX MODEL: self.width and self.height are already content dimensions (padding subtracted)
  local availableMainSize = 0
  local availableCrossSize = 0
  if self.flexDirection == FlexDirection.HORIZONTAL then
    availableMainSize = self.width - reservedMainStart - reservedMainEnd
    availableCrossSize = self.height - reservedCrossStart - reservedCrossEnd
  else
    availableMainSize = self.height - reservedMainStart - reservedMainEnd
    availableCrossSize = self.width - reservedCrossStart - reservedCrossEnd
  end

  -- Handle flex wrap: create lines of children
  local lines = {}

  if self.flexWrap == FlexWrap.NOWRAP then
    -- All children go on one line
    lines[1] = flexChildren
  else
    -- Wrap children into multiple lines
    local currentLine = {}
    local currentLineSize = 0

    for _, child in ipairs(flexChildren) do
      -- BORDER-BOX MODEL: Use border-box dimensions for layout calculations
      -- Include margins in size calculations
      local childMainSize = 0
      local childMainMargin = 0
      if self.flexDirection == FlexDirection.HORIZONTAL then
        childMainSize = child:getBorderBoxWidth()
        childMainMargin = child.margin.left + child.margin.right
      else
        childMainSize = child:getBorderBoxHeight()
        childMainMargin = child.margin.top + child.margin.bottom
      end
      local childTotalMainSize = childMainSize + childMainMargin

      -- Check if adding this child would exceed the available space
      local lineSpacing = #currentLine > 0 and self.gap or 0
      if #currentLine > 0 and currentLineSize + lineSpacing + childTotalMainSize > availableMainSize then
        -- Start a new line
        if #currentLine > 0 then
          table.insert(lines, currentLine)
        end
        currentLine = { child }
        currentLineSize = childTotalMainSize
      else
        -- Add to current line
        table.insert(currentLine, child)
        currentLineSize = currentLineSize + lineSpacing + childTotalMainSize
      end
    end

    -- Add the last line if it has children
    if #currentLine > 0 then
      table.insert(lines, currentLine)
    end

    -- Handle wrap-reverse: reverse the order of lines
    if self.flexWrap == FlexWrap.WRAP_REVERSE then
      local reversedLines = {}
      for i = #lines, 1, -1 do
        table.insert(reversedLines, lines[i])
      end
      lines = reversedLines
    end
  end

  -- Calculate line positions and heights (including child padding)
  local lineHeights = {}
  local totalLinesHeight = 0

  for lineIndex, line in ipairs(lines) do
    local maxCrossSize = 0
    for _, child in ipairs(line) do
      -- BORDER-BOX MODEL: Use border-box dimensions for layout calculations
      -- Include margins in cross-axis size calculations
      local childCrossSize = 0
      local childCrossMargin = 0
      if self.flexDirection == FlexDirection.HORIZONTAL then
        childCrossSize = child:getBorderBoxHeight()
        childCrossMargin = child.margin.top + child.margin.bottom
      else
        childCrossSize = child:getBorderBoxWidth()
        childCrossMargin = child.margin.left + child.margin.right
      end
      local childTotalCrossSize = childCrossSize + childCrossMargin
      maxCrossSize = math.max(maxCrossSize, childTotalCrossSize)
    end
    lineHeights[lineIndex] = maxCrossSize
    totalLinesHeight = totalLinesHeight + maxCrossSize
  end

  -- Account for gaps between lines
  local lineGaps = math.max(0, #lines - 1) * self.gap
  totalLinesHeight = totalLinesHeight + lineGaps

  -- For single line layouts, CENTER, FLEX_END and STRETCH should use full cross size
  if #lines == 1 then
    if self.alignItems == AlignItems.STRETCH or self.alignItems == AlignItems.CENTER or self.alignItems == AlignItems.FLEX_END then
      -- STRETCH, CENTER, and FLEX_END should use full available cross size
      lineHeights[1] = availableCrossSize
      totalLinesHeight = availableCrossSize
    end
    -- CENTER and FLEX_END should preserve natural child dimensions
    -- and only affect positioning within the available space
  end

  -- Calculate starting position for lines based on alignContent
  local lineStartPos = 0
  local lineSpacing = self.gap
  local freeLineSpace = availableCrossSize - totalLinesHeight

  -- Apply AlignContent logic for both single and multiple lines
  if self.alignContent == AlignContent.FLEX_START then
    lineStartPos = 0
  elseif self.alignContent == AlignContent.CENTER then
    lineStartPos = freeLineSpace / 2
  elseif self.alignContent == AlignContent.FLEX_END then
    lineStartPos = freeLineSpace
  elseif self.alignContent == AlignContent.SPACE_BETWEEN then
    lineStartPos = 0
    if #lines > 1 then
      lineSpacing = self.gap + (freeLineSpace / (#lines - 1))
    end
  elseif self.alignContent == AlignContent.SPACE_AROUND then
    local spaceAroundEach = freeLineSpace / #lines
    lineStartPos = spaceAroundEach / 2
    lineSpacing = self.gap + spaceAroundEach
  elseif self.alignContent == AlignContent.STRETCH then
    lineStartPos = 0
    if #lines > 1 and freeLineSpace > 0 then
      lineSpacing = self.gap + (freeLineSpace / #lines)
      -- Distribute extra space to line heights (only if positive)
      local extraPerLine = freeLineSpace / #lines
      for i = 1, #lineHeights do
        lineHeights[i] = lineHeights[i] + extraPerLine
      end
    end
  end

  -- Position children within each line
  local currentCrossPos = lineStartPos

  for lineIndex, line in ipairs(lines) do
    local lineHeight = lineHeights[lineIndex]

    -- Calculate total size of children in this line (including padding and margins)
    -- BORDER-BOX MODEL: Use border-box dimensions for layout calculations
    local totalChildrenSize = 0
    for _, child in ipairs(line) do
      if self.flexDirection == FlexDirection.HORIZONTAL then
        totalChildrenSize = totalChildrenSize + child:getBorderBoxWidth() + child.margin.left + child.margin.right
      else
        totalChildrenSize = totalChildrenSize + child:getBorderBoxHeight() + child.margin.top + child.margin.bottom
      end
    end

    local totalGapSize = math.max(0, #line - 1) * self.gap
    local totalContentSize = totalChildrenSize + totalGapSize
    local freeSpace = availableMainSize - totalContentSize

    -- Calculate initial position and spacing based on justifyContent
    local startPos = 0
    local itemSpacing = self.gap

    if self.justifyContent == JustifyContent.FLEX_START then
      startPos = 0
    elseif self.justifyContent == JustifyContent.CENTER then
      startPos = freeSpace / 2
    elseif self.justifyContent == JustifyContent.FLEX_END then
      startPos = freeSpace
    elseif self.justifyContent == JustifyContent.SPACE_BETWEEN then
      startPos = 0
      if #line > 1 then
        itemSpacing = self.gap + (freeSpace / (#line - 1))
      end
    elseif self.justifyContent == JustifyContent.SPACE_AROUND then
      local spaceAroundEach = freeSpace / #line
      startPos = spaceAroundEach / 2
      itemSpacing = self.gap + spaceAroundEach
    elseif self.justifyContent == JustifyContent.SPACE_EVENLY then
      local spaceBetween = freeSpace / (#line + 1)
      startPos = spaceBetween
      itemSpacing = self.gap + spaceBetween
    end

    -- Position children in this line
    local currentMainPos = startPos

    for _, child in ipairs(line) do
      -- Determine effective cross-axis alignment
      local effectiveAlign = child.alignSelf
      if effectiveAlign == nil or effectiveAlign == AlignSelf.AUTO then
        effectiveAlign = self.alignItems
      end

      if self.flexDirection == FlexDirection.HORIZONTAL then
        -- Horizontal layout: main axis is X, cross axis is Y
        -- Position child at border box (x, y represents top-left including padding)
        -- Add reservedMainStart and left margin to account for absolutely positioned siblings and margins
        child.x = self.x + self.padding.left + reservedMainStart + currentMainPos + child.margin.left

        -- BORDER-BOX MODEL: Use border-box dimensions for alignment calculations
        local childBorderBoxHeight = child:getBorderBoxHeight()
        local childTotalCrossSize = childBorderBoxHeight + child.margin.top + child.margin.bottom

        if effectiveAlign == AlignItems.FLEX_START then
          child.y = self.y + self.padding.top + reservedCrossStart + currentCrossPos + child.margin.top
        elseif effectiveAlign == AlignItems.CENTER then
          child.y = self.y + self.padding.top + reservedCrossStart + currentCrossPos + ((lineHeight - childTotalCrossSize) / 2) + child.margin.top
        elseif effectiveAlign == AlignItems.FLEX_END then
          child.y = self.y + self.padding.top + reservedCrossStart + currentCrossPos + lineHeight - childTotalCrossSize + child.margin.top
        elseif effectiveAlign == AlignItems.STRETCH then
          -- STRETCH: Only apply if height was not explicitly set
          if child.autosizing and child.autosizing.height then
            -- STRETCH: Set border-box height to lineHeight minus margins, content area shrinks to fit
            local availableHeight = lineHeight - child.margin.top - child.margin.bottom
            child._borderBoxHeight = availableHeight
            child.height = math.max(0, availableHeight - child.padding.top - child.padding.bottom)
          end
          child.y = self.y + self.padding.top + reservedCrossStart + currentCrossPos + child.margin.top
        end

        -- Apply positioning offsets (top, right, bottom, left)
        self:applyPositioningOffsets(child)

        -- If child has children, re-layout them after position change
        if #child.children > 0 then
          child:layoutChildren()
        end

        -- Advance position by child's border-box width plus margins
        currentMainPos = currentMainPos + child:getBorderBoxWidth() + child.margin.left + child.margin.right + itemSpacing
      else
        -- Vertical layout: main axis is Y, cross axis is X
        -- Position child at border box (x, y represents top-left including padding)
        -- Add reservedMainStart and top margin to account for absolutely positioned siblings and margins
        child.y = self.y + self.padding.top + reservedMainStart + currentMainPos + child.margin.top

        -- BORDER-BOX MODEL: Use border-box dimensions for alignment calculations
        local childBorderBoxWidth = child:getBorderBoxWidth()
        local childTotalCrossSize = childBorderBoxWidth + child.margin.left + child.margin.right

        if effectiveAlign == AlignItems.FLEX_START then
          child.x = self.x + self.padding.left + reservedCrossStart + currentCrossPos + child.margin.left
        elseif effectiveAlign == AlignItems.CENTER then
          child.x = self.x + self.padding.left + reservedCrossStart + currentCrossPos + ((lineHeight - childTotalCrossSize) / 2) + child.margin.left
        elseif effectiveAlign == AlignItems.FLEX_END then
          child.x = self.x + self.padding.left + reservedCrossStart + currentCrossPos + lineHeight - childTotalCrossSize + child.margin.left
        elseif effectiveAlign == AlignItems.STRETCH then
          -- STRETCH: Only apply if width was not explicitly set
          if child.autosizing and child.autosizing.width then
            -- STRETCH: Set border-box width to lineHeight minus margins, content area shrinks to fit
            local availableWidth = lineHeight - child.margin.left - child.margin.right
            child._borderBoxWidth = availableWidth
            child.width = math.max(0, availableWidth - child.padding.left - child.padding.right)
          end
          child.x = self.x + self.padding.left + reservedCrossStart + currentCrossPos + child.margin.left
        end

        -- Apply positioning offsets (top, right, bottom, left)
        self:applyPositioningOffsets(child)

        -- If child has children, re-layout them after position change
        if #child.children > 0 then
          child:layoutChildren()
        end

        -- Advance position by child's border-box height plus margins
        currentMainPos = currentMainPos + child:getBorderBoxHeight() + child.margin.top + child.margin.bottom + itemSpacing
      end
    end

    -- Move to next line position
    currentCrossPos = currentCrossPos + lineHeight + lineSpacing
  end

  -- Position explicitly absolute children after flex layout
  for _, child in ipairs(self.children) do
    if child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute then
      -- Apply positioning offsets (top, right, bottom, left)
      self:applyPositioningOffsets(child)

      -- If child has children, layout them after position change
      if #child.children > 0 then
        child:layoutChildren()
      end
    end
  end
end

--- Destroy element and its children
function Element:destroy()
  -- Remove from global elements list
  for i, win in ipairs(Gui.topElements) do
    if win == self then
      table.remove(Gui.topElements, i)
      break
    end
  end

  if self.parent then
    for i, child in ipairs(self.parent.children) do
      if child == self then
        table.remove(self.parent.children, i)
        break
      end
    end
    self.parent = nil
  end

  -- Destroy all children
  for _, child in ipairs(self.children) do
    child:destroy()
  end

  -- Clear children table
  self.children = {}

  -- Clear parent reference
  if self.parent then
    self.parent = nil
  end

  -- Clear animation reference
  self.animation = nil

  -- Clear callback to prevent closure leaks
  self.callback = nil
end

--- Draw element and its children
function Element:draw(backdropCanvas)
  -- Early exit if element is invisible (optimization)
  if self.opacity <= 0 then
    return
  end

  -- Handle opacity during animation
  local drawBackgroundColor = self.backgroundColor
  if self.animation then
    local anim = self.animation:interpolate()
    if anim.opacity then
      drawBackgroundColor = Color.new(self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b, anim.opacity)
    end
  end

  -- Cache border box dimensions for this draw call (optimization)
  local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
  local borderBoxHeight = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)

  -- LAYER 0.5: Draw backdrop blur if configured (before background)
  if self.backdropBlur and self.backdropBlur.intensity > 0 and backdropCanvas then
    local blurInstance = self:getBlurInstance()
    if blurInstance then
      Blur.applyBackdrop(blurInstance, self.backdropBlur.intensity, self.x, self.y, borderBoxWidth, borderBoxHeight, backdropCanvas)
    end
  end

  -- LAYER 1: Draw backgroundColor first (behind everything)
  -- Apply opacity to all drawing operations
  -- (x, y) represents border box, so draw background from (x, y)
  -- BORDER-BOX MODEL: Use stored border-box dimensions for drawing
  local backgroundWithOpacity = Color.new(drawBackgroundColor.r, drawBackgroundColor.g, drawBackgroundColor.b, drawBackgroundColor.a * self.opacity)
  love.graphics.setColor(backgroundWithOpacity:toRGBA())
  RoundedRect.draw("fill", self.x, self.y, borderBoxWidth, borderBoxHeight, self.cornerRadius)

  -- LAYER 1.5: Draw image on top of backgroundColor (if image exists)
  if self._loadedImage then
    -- Calculate image bounds (content area - respects padding)
    local imageX = self.x + self.padding.left
    local imageY = self.y + self.padding.top
    local imageWidth = self.width
    local imageHeight = self.height
    
    -- Combine element opacity with imageOpacity
    local finalOpacity = self.opacity * self.imageOpacity
    
    -- Apply cornerRadius clipping if set
    local hasCornerRadius = self.cornerRadius.topLeft > 0 or self.cornerRadius.topRight > 0 
                         or self.cornerRadius.bottomLeft > 0 or self.cornerRadius.bottomRight > 0
    
    if hasCornerRadius then
      -- Use stencil to clip image to rounded corners
      love.graphics.stencil(function()
        RoundedRect.draw("fill", self.x, self.y, borderBoxWidth, borderBoxHeight, self.cornerRadius)
      end, "replace", 1)
      love.graphics.setStencilTest("greater", 0)
    end
    
    -- Draw the image
    ImageRenderer.draw(
      self._loadedImage,
      imageX,
      imageY,
      imageWidth,
      imageHeight,
      self.objectFit,
      self.objectPosition,
      finalOpacity
    )
    
    -- Clear stencil if it was used
    if hasCornerRadius then
      love.graphics.setStencilTest()
    end
  end

  -- LAYER 2: Draw theme on top of backgroundColor (if theme exists)
  if self.themeComponent then
    -- Get the theme to use
    local themeToUse = nil
    if self.theme then
      -- Element specifies a specific theme - load it if needed
      if themes[self.theme] then
        themeToUse = themes[self.theme]
      else
        -- Try to load the theme
        pcall(function()
          Theme.load(self.theme)
        end)
        themeToUse = themes[self.theme]
      end
    else
      -- Use active theme
      themeToUse = Theme.getActive()
    end

    if themeToUse then
      -- Get the component from the theme
      local component = themeToUse.components[self.themeComponent]
      if component then
        -- Check for state-specific override
        local state = self._themeState
        if state and component.states and component.states[state] then
          component = component.states[state]
        end

        -- Use component-specific atlas if available, otherwise use theme atlas
        local atlasToUse = component._loadedAtlas or themeToUse.atlas

        if atlasToUse and component.regions then
          -- Validate component has required structure
          local hasAllRegions = component.regions.topLeft
            and component.regions.topCenter
            and component.regions.topRight
            and component.regions.middleLeft
            and component.regions.middleCenter
            and component.regions.middleRight
            and component.regions.bottomLeft
            and component.regions.bottomCenter
            and component.regions.bottomRight
          if hasAllRegions then
            -- Calculate border-box dimensions (content + padding)
            local borderBoxWidth = self.width + self.padding.left + self.padding.right
            local borderBoxHeight = self.height + self.padding.top + self.padding.bottom
            -- Pass element-level overrides for scaleCorners and scalingAlgorithm
            NineSlice.draw(component, atlasToUse, self.x, self.y, borderBoxWidth, borderBoxHeight, self.opacity, self.scaleCorners, self.scalingAlgorithm)
          else
            -- Silently skip drawing if component structure is invalid
          end
        end
      else
        print("[FlexLove] Component not found: " .. self.themeComponent .. " in theme: " .. themeToUse.name)
      end
    else
      print("[FlexLove] No theme available for themeComponent: " .. self.themeComponent)
    end
  end

  -- LAYER 3: Draw borders on top of theme (always render if specified)
  local borderColorWithOpacity = Color.new(self.borderColor.r, self.borderColor.g, self.borderColor.b, self.borderColor.a * self.opacity)
  love.graphics.setColor(borderColorWithOpacity:toRGBA())

  -- Check if all borders are enabled
  local allBorders = self.border.top and self.border.bottom and self.border.left and self.border.right

  if allBorders then
    -- Draw complete rounded rectangle border
    RoundedRect.draw("line", self.x, self.y, borderBoxWidth, borderBoxHeight, self.cornerRadius)
  else
    -- Draw individual borders (without rounded corners for partial borders)
    if self.border.top then
      love.graphics.line(self.x, self.y, self.x + borderBoxWidth, self.y)
    end
    if self.border.bottom then
      love.graphics.line(self.x, self.y + borderBoxHeight, self.x + borderBoxWidth, self.y + borderBoxHeight)
    end
    if self.border.left then
      love.graphics.line(self.x, self.y, self.x, self.y + borderBoxHeight)
    end
    if self.border.right then
      love.graphics.line(self.x + borderBoxWidth, self.y, self.x + borderBoxWidth, self.y + borderBoxHeight)
    end
  end

  -- Draw element text if present
  if self.text then
    local textColorWithOpacity = Color.new(self.textColor.r, self.textColor.g, self.textColor.b, self.textColor.a * self.opacity)
    love.graphics.setColor(textColorWithOpacity:toRGBA())

    local origFont = love.graphics.getFont()
    if self.textSize then
      -- Resolve font path from font family
      local fontPath = nil
      if self.fontFamily then
        -- Check if fontFamily is a theme font name
        local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
        if themeToUse and themeToUse.fonts and themeToUse.fonts[self.fontFamily] then
          fontPath = themeToUse.fonts[self.fontFamily]
        else
          -- Treat as direct path to font file
          fontPath = self.fontFamily
        end
      elseif self.themeComponent then
        -- If using themeComponent but no fontFamily specified, check for default font in theme
        local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
        if themeToUse and themeToUse.fonts and themeToUse.fonts.default then
          fontPath = themeToUse.fonts.default
        end
      end

      -- Use cached font instead of creating new one every frame
      local font = FONT_CACHE.get(self.textSize, fontPath)
      love.graphics.setFont(font)
    end
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    local tx, ty

    -- Text is drawn in the content box (inside padding)
    -- For 9-slice components, use contentPadding if available
    local textPaddingLeft = self.padding.left
    local textPaddingTop = self.padding.top
    local textAreaWidth = self.width
    local textAreaHeight = self.height

    -- Check if we should use 9-slice contentPadding for text positioning
    local scaledContentPadding = self:getScaledContentPadding()
    if scaledContentPadding then
      local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
      local borderBoxHeight = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)

      textPaddingLeft = scaledContentPadding.left
      textPaddingTop = scaledContentPadding.top
      textAreaWidth = borderBoxWidth - scaledContentPadding.left - scaledContentPadding.right
      textAreaHeight = borderBoxHeight - scaledContentPadding.top - scaledContentPadding.bottom
    end

    local contentX = self.x + textPaddingLeft
    local contentY = self.y + textPaddingTop

    if self.textAlign == TextAlign.START then
      tx = contentX
      ty = contentY
    elseif self.textAlign == TextAlign.CENTER then
      tx = contentX + (textAreaWidth - textWidth) / 2
      ty = contentY + (textAreaHeight - textHeight) / 2
    elseif self.textAlign == TextAlign.END then
      tx = contentX + textAreaWidth - textWidth - 10
      ty = contentY + textAreaHeight - textHeight - 10
    elseif self.textAlign == TextAlign.JUSTIFY then
      --- need to figure out spreading
      tx = contentX
      ty = contentY
    end
    love.graphics.print(self.text, tx, ty)
    if self.textSize then
      love.graphics.setFont(origFont)
    end
  end

  -- Draw visual feedback when element is pressed (if it has a callback and highlight is not disabled)
  if self.callback and not self.disableHighlight then
    -- Check if any button is pressed
    local anyPressed = false
    for _, pressed in pairs(self._pressed) do
      if pressed then
        anyPressed = true
        break
      end
    end
    if anyPressed then
      -- BORDER-BOX MODEL: Use stored border-box dimensions for drawing
      local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
      local borderBoxHeight = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)
      love.graphics.setColor(0.5, 0.5, 0.5, 0.3 * self.opacity) -- Semi-transparent gray for pressed state with opacity
      RoundedRect.draw("fill", self.x, self.y, borderBoxWidth, borderBoxHeight, self.cornerRadius)
    end
  end

  -- Sort children by z-index before drawing
  local sortedChildren = {}
  for _, child in ipairs(self.children) do
    table.insert(sortedChildren, child)
  end
  table.sort(sortedChildren, function(a, b)
    return a.z < b.z
  end)

  -- Check if we need to clip children to rounded corners
  local hasRoundedCorners = self.cornerRadius.topLeft > 0
    or self.cornerRadius.topRight > 0
    or self.cornerRadius.bottomLeft > 0
    or self.cornerRadius.bottomRight > 0

  -- Helper function to draw children (with or without clipping)
  local function drawChildren()
    if hasRoundedCorners and #sortedChildren > 0 then
      -- Use stencil to clip children to rounded rectangle
      -- BORDER-BOX MODEL: Use stored border-box dimensions for clipping
      local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
      local borderBoxHeight = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)
      local stencilFunc = RoundedRect.stencilFunction(self.x, self.y, borderBoxWidth, borderBoxHeight, self.cornerRadius)

      love.graphics.stencil(stencilFunc, "replace", 1)
      love.graphics.setStencilTest("greater", 0)

      for _, child in ipairs(sortedChildren) do
        child:draw(backdropCanvas)
      end

      love.graphics.setStencilTest()
    else
      -- No clipping needed
      for _, child in ipairs(sortedChildren) do
        child:draw(backdropCanvas)
      end
    end
  end

  -- Apply content blur if configured
  if self.contentBlur and self.contentBlur.intensity > 0 and #sortedChildren > 0 then
    local blurInstance = self:getBlurInstance()
    if blurInstance then
      Blur.applyToRegion(blurInstance, self.contentBlur.intensity, self.x, self.y, borderBoxWidth, borderBoxHeight, drawChildren)
    else
      drawChildren()
    end
  else
    drawChildren()
  end
end

--- Update element (propagate to children)
---@param dt number
function Element:update(dt)
  for _, child in ipairs(self.children) do
    child:update(dt)
  end

  -- Update cursor blink timer (only if editable and focused)
  if self.editable and self._focused then
    self._cursorBlinkTimer = self._cursorBlinkTimer + dt
    if self._cursorBlinkTimer >= self.cursorBlinkRate then
      self._cursorBlinkTimer = 0
      self._cursorVisible = not self._cursorVisible
    end
  end

  -- Update animation if exists
  if self.animation then
    local finished = self.animation:update(dt)
    if finished then
      self.animation = nil -- remove finished animation
    else
      -- Apply animation interpolation during update
      local anim = self.animation:interpolate()
      self.width = anim.width or self.width
      self.height = anim.height or self.height
      self.opacity = anim.opacity or self.opacity
      -- Update background color with interpolated opacity
      if anim.opacity then
        self.backgroundColor.a = anim.opacity
      end
    end
  end

  -- Handle click detection for element with enhanced event system
  if self.callback or self.themeComponent then
    local mx, my = love.mouse.getPosition()
    -- Clickable area is the border box (x, y already includes padding)
    -- BORDER-BOX MODEL: Use stored border-box dimensions for hit detection
    local bx = self.x
    local by = self.y
    local bw = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
    local bh = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)
    local isHovering = mx >= bx and mx <= bx + bw and my >= by and my <= by + bh

    -- Update theme state based on interaction
    if self.themeComponent then
      -- Disabled state takes priority
      if self.disabled then
        self._themeState = "disabled"
      -- Active state (for inputs when focused/typing)
      elseif self.active then
        self._themeState = "active"
      elseif isHovering then
        -- Check if any button is pressed
        local anyPressed = false
        for _, pressed in pairs(self._pressed) do
          if pressed then
            anyPressed = true
            break
          end
        end

        if anyPressed then
          self._themeState = "pressed"
        else
          self._themeState = "hover"
        end
      else
        self._themeState = "normal"
      end
    end

    -- Only process button events if callback exists, element is not disabled,
    -- and this is the topmost element at the mouse position (z-index ordering)
    local isActiveElement = (Gui._activeEventElement == nil or Gui._activeEventElement == self)
    if self.callback and not self.disabled and isActiveElement then
      -- Check all three mouse buttons
      local buttons = { 1, 2, 3 } -- left, right, middle

      for _, button in ipairs(buttons) do
        if isHovering then
          if love.mouse.isDown(button) then
            -- Button is pressed down
            if not self._pressed[button] then
              -- Just pressed - fire press event
              local modifiers = getModifiers()
              local pressEvent = InputEvent.new({
                type = "press",
                button = button,
                x = mx,
                y = my,
                modifiers = modifiers,
                clickCount = 1,
              })
              self.callback(self, pressEvent)
              self._pressed[button] = true
            end
          elseif self._pressed[button] then
            -- Button was just released - fire click event
            local currentTime = love.timer.getTime()
            local modifiers = getModifiers()

            -- Determine click count (double-click detection)
            local clickCount = 1
            local doubleClickThreshold = 0.3 -- 300ms for double-click

            if self._lastClickTime and self._lastClickButton == button and (currentTime - self._lastClickTime) < doubleClickThreshold then
              clickCount = self._clickCount + 1
            else
              clickCount = 1
            end

            self._clickCount = clickCount
            self._lastClickTime = currentTime
            self._lastClickButton = button

            -- Determine event type based on button
            local eventType = "click"
            if button == 2 then
              eventType = "rightclick"
            elseif button == 3 then
              eventType = "middleclick"
            end

            local clickEvent = InputEvent.new({
              type = eventType,
              button = button,
              x = mx,
              y = my,
              modifiers = modifiers,
              clickCount = clickCount,
            })

            self.callback(self, clickEvent)
            self._pressed[button] = false

            -- Focus editable elements on left click
            if button == 1 and self.editable then
              self:focus()
            end

            -- Fire release event
            local releaseEvent = InputEvent.new({
              type = "release",
              button = button,
              x = mx,
              y = my,
              modifiers = modifiers,
              clickCount = clickCount,
            })
            self.callback(self, releaseEvent)
          end
        else
          -- Mouse left the element - reset pressed state
          self._pressed[button] = false
        end
      end
    end -- end if self.callback

    -- Handle touch events (maintain backward compatibility)
    if self.callback then
      local touches = love.touch.getTouches()
      for _, id in ipairs(touches) do
        local tx, ty = love.touch.getPosition(id)
        if tx >= bx and tx <= bx + bw and ty >= by and ty <= by + bh then
          self._touchPressed[id] = true
        elseif self._touchPressed[id] then
          -- Create touch event (treat as left click)
          local touchEvent = InputEvent.new({
            type = "click",
            button = 1,
            x = tx,
            y = ty,
            modifiers = getModifiers(),
            clickCount = 1,
          })
          self.callback(self, touchEvent)
          self._touchPressed[id] = false
        end
      end
    end
  end
end

--- Recalculate units based on new viewport dimensions (for vw, vh, % units)
---@param newViewportWidth number
---@param newViewportHeight number
function Element:recalculateUnits(newViewportWidth, newViewportHeight)
  -- Get updated scale factors
  local scaleX, scaleY = Gui.getScaleFactors()

  -- Recalculate border-box width if using viewport or percentage units (skip auto-sized)
  -- Store in _borderBoxWidth temporarily, will calculate content width after padding is resolved
  if self.units.width.unit ~= "px" and self.units.width.unit ~= "auto" then
    local parentWidth = self.parent and self.parent.width or newViewportWidth
    self._borderBoxWidth = Units.resolve(self.units.width.value, self.units.width.unit, newViewportWidth, newViewportHeight, parentWidth)
  elseif self.units.width.unit == "px" and self.units.width.value and Gui.baseScale then
    -- Reapply base scaling to pixel widths (border-box)
    self._borderBoxWidth = self.units.width.value * scaleX
  end

  -- Recalculate border-box height if using viewport or percentage units (skip auto-sized)
  -- Store in _borderBoxHeight temporarily, will calculate content height after padding is resolved
  if self.units.height.unit ~= "px" and self.units.height.unit ~= "auto" then
    local parentHeight = self.parent and self.parent.height or newViewportHeight
    self._borderBoxHeight = Units.resolve(self.units.height.value, self.units.height.unit, newViewportWidth, newViewportHeight, parentHeight)
  elseif self.units.height.unit == "px" and self.units.height.value and Gui.baseScale then
    -- Reapply base scaling to pixel heights (border-box)
    self._borderBoxHeight = self.units.height.value * scaleY
  end

  -- Recalculate position if using viewport or percentage units
  if self.units.x.unit ~= "px" then
    local parentWidth = self.parent and self.parent.width or newViewportWidth
    local baseX = self.parent and self.parent.x or 0
    local offsetX = Units.resolve(self.units.x.value, self.units.x.unit, newViewportWidth, newViewportHeight, parentWidth)
    self.x = baseX + offsetX
  else
    -- For pixel units, update position relative to parent's new position (with base scaling)
    if self.parent then
      local baseX = self.parent.x
      local scaledOffset = Gui.baseScale and (self.units.x.value * scaleX) or self.units.x.value
      self.x = baseX + scaledOffset
    elseif Gui.baseScale then
      -- Top-level element with pixel position - apply base scaling
      self.x = self.units.x.value * scaleX
    end
  end

  if self.units.y.unit ~= "px" then
    local parentHeight = self.parent and self.parent.height or newViewportHeight
    local baseY = self.parent and self.parent.y or 0
    local offsetY = Units.resolve(self.units.y.value, self.units.y.unit, newViewportWidth, newViewportHeight, parentHeight)
    self.y = baseY + offsetY
  else
    -- For pixel units, update position relative to parent's new position (with base scaling)
    if self.parent then
      local baseY = self.parent.y
      local scaledOffset = Gui.baseScale and (self.units.y.value * scaleY) or self.units.y.value
      self.y = baseY + scaledOffset
    elseif Gui.baseScale then
      -- Top-level element with pixel position - apply base scaling
      self.y = self.units.y.value * scaleY
    end
  end

  -- Recalculate textSize if auto-scaling is enabled or using viewport/element-relative units
  if self.autoScaleText and self.units.textSize.value then
    local unit = self.units.textSize.unit
    local value = self.units.textSize.value

    if unit == "px" and Gui.baseScale then
      -- With base scaling: scale pixel values relative to base resolution
      self.textSize = value * scaleY
    elseif unit == "px" then
      -- Without base scaling but auto-scaling enabled: text doesn't scale
      self.textSize = value
    elseif unit == "%" or unit == "vh" then
      -- Percentage and vh are relative to viewport height
      self.textSize = Units.resolve(value, unit, newViewportWidth, newViewportHeight, newViewportHeight)
    elseif unit == "vw" then
      -- vw is relative to viewport width
      self.textSize = Units.resolve(value, unit, newViewportWidth, newViewportHeight, newViewportWidth)
    elseif unit == "ew" then
      -- Element width relative
      self.textSize = (value / 100) * self.width
    elseif unit == "eh" then
      -- Element height relative
      self.textSize = (value / 100) * self.height
    else
      self.textSize = Units.resolve(value, unit, newViewportWidth, newViewportHeight, nil)
    end

    -- Apply min/max constraints (with base scaling)
    local minSize = self.minTextSize and (Gui.baseScale and (self.minTextSize * scaleY) or self.minTextSize)
    local maxSize = self.maxTextSize and (Gui.baseScale and (self.maxTextSize * scaleY) or self.maxTextSize)

    if minSize and self.textSize < minSize then
      self.textSize = minSize
    end
    if maxSize and self.textSize > maxSize then
      self.textSize = maxSize
    end

    -- Protect against too-small text sizes (minimum 1px)
    if self.textSize < 1 then
      self.textSize = 1 -- Minimum 1px
    end
  elseif self.units.textSize.unit == "px" and self.units.textSize.value and Gui.baseScale then
    -- No auto-scaling but base scaling is set: reapply base scaling to pixel text sizes
    self.textSize = self.units.textSize.value * scaleY

    -- Protect against too-small text sizes (minimum 1px)
    if self.textSize < 1 then
      self.textSize = 1 -- Minimum 1px
    end
  end

  -- Final protection: ensure textSize is always at least 1px (catches all edge cases)
  if self.text and self.textSize and self.textSize < 1 then
    self.textSize = 1 -- Minimum 1px
  end

  -- Recalculate gap if using viewport or percentage units
  if self.units.gap.unit ~= "px" then
    local containerSize = (self.flexDirection == FlexDirection.HORIZONTAL) and (self.parent and self.parent.width or newViewportWidth)
      or (self.parent and self.parent.height or newViewportHeight)
    self.gap = Units.resolve(self.units.gap.value, self.units.gap.unit, newViewportWidth, newViewportHeight, containerSize)
  end

  -- Recalculate spacing (padding/margin) if using viewport or percentage units
  -- For percentage-based padding:
  -- - If element has a parent: use parent's border-box dimensions (CSS spec for child elements)
  -- - If element has no parent: use element's own border-box dimensions (CSS spec for root elements)
  local parentBorderBoxWidth = self.parent and self.parent._borderBoxWidth or self._borderBoxWidth or newViewportWidth
  local parentBorderBoxHeight = self.parent and self.parent._borderBoxHeight or self._borderBoxHeight or newViewportHeight

  -- Handle shorthand properties first (horizontal/vertical)
  local resolvedHorizontalPadding = nil
  local resolvedVerticalPadding = nil

  if self.units.padding.horizontal and self.units.padding.horizontal.unit ~= "px" then
    resolvedHorizontalPadding =
      Units.resolve(self.units.padding.horizontal.value, self.units.padding.horizontal.unit, newViewportWidth, newViewportHeight, parentBorderBoxWidth)
  elseif self.units.padding.horizontal and self.units.padding.horizontal.value then
    resolvedHorizontalPadding = self.units.padding.horizontal.value
  end

  if self.units.padding.vertical and self.units.padding.vertical.unit ~= "px" then
    resolvedVerticalPadding =
      Units.resolve(self.units.padding.vertical.value, self.units.padding.vertical.unit, newViewportWidth, newViewportHeight, parentBorderBoxHeight)
  elseif self.units.padding.vertical and self.units.padding.vertical.value then
    resolvedVerticalPadding = self.units.padding.vertical.value
  end

  -- Resolve individual padding sides (with fallback to shorthand)
  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    -- Check if this side was explicitly set or if we should use shorthand
    local useShorthand = false
    if not self.units.padding[side].explicit then
      -- Not explicitly set, check if we have shorthand
      if side == "left" or side == "right" then
        useShorthand = resolvedHorizontalPadding ~= nil
      elseif side == "top" or side == "bottom" then
        useShorthand = resolvedVerticalPadding ~= nil
      end
    end

    if useShorthand then
      -- Use shorthand value
      if side == "left" or side == "right" then
        self.padding[side] = resolvedHorizontalPadding
      else
        self.padding[side] = resolvedVerticalPadding
      end
    elseif self.units.padding[side].unit ~= "px" then
      -- Recalculate non-pixel units
      local parentSize = (side == "top" or side == "bottom") and parentBorderBoxHeight or parentBorderBoxWidth
      self.padding[side] = Units.resolve(self.units.padding[side].value, self.units.padding[side].unit, newViewportWidth, newViewportHeight, parentSize)
    end
    -- If unit is "px" and not using shorthand, value stays the same
  end

  -- Handle margin shorthand properties
  local resolvedHorizontalMargin = nil
  local resolvedVerticalMargin = nil

  if self.units.margin.horizontal and self.units.margin.horizontal.unit ~= "px" then
    resolvedHorizontalMargin =
      Units.resolve(self.units.margin.horizontal.value, self.units.margin.horizontal.unit, newViewportWidth, newViewportHeight, parentBorderBoxWidth)
  elseif self.units.margin.horizontal and self.units.margin.horizontal.value then
    resolvedHorizontalMargin = self.units.margin.horizontal.value
  end

  if self.units.margin.vertical and self.units.margin.vertical.unit ~= "px" then
    resolvedVerticalMargin =
      Units.resolve(self.units.margin.vertical.value, self.units.margin.vertical.unit, newViewportWidth, newViewportHeight, parentBorderBoxHeight)
  elseif self.units.margin.vertical and self.units.margin.vertical.value then
    resolvedVerticalMargin = self.units.margin.vertical.value
  end

  -- Resolve individual margin sides (with fallback to shorthand)
  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    -- Check if this side was explicitly set or if we should use shorthand
    local useShorthand = false
    if not self.units.margin[side].explicit then
      -- Not explicitly set, check if we have shorthand
      if side == "left" or side == "right" then
        useShorthand = resolvedHorizontalMargin ~= nil
      elseif side == "top" or side == "bottom" then
        useShorthand = resolvedVerticalMargin ~= nil
      end
    end

    if useShorthand then
      -- Use shorthand value
      if side == "left" or side == "right" then
        self.margin[side] = resolvedHorizontalMargin
      else
        self.margin[side] = resolvedVerticalMargin
      end
    elseif self.units.margin[side].unit ~= "px" then
      -- Recalculate non-pixel units
      local parentSize = (side == "top" or side == "bottom") and parentBorderBoxHeight or parentBorderBoxWidth
      self.margin[side] = Units.resolve(self.units.margin[side].value, self.units.margin[side].unit, newViewportWidth, newViewportHeight, parentSize)
    end
    -- If unit is "px" and not using shorthand, value stays the same
  end

  -- BORDER-BOX MODEL: Calculate content dimensions from border-box dimensions
  -- For explicitly-sized elements (non-auto), _borderBoxWidth/_borderBoxHeight were set earlier
  -- Now we calculate content width/height by subtracting padding
  -- Only recalculate if using viewport/percentage units (where _borderBoxWidth actually changed)
  if self.units.width.unit ~= "auto" and self.units.width.unit ~= "px" then
    -- _borderBoxWidth was recalculated for viewport/percentage units
    -- Calculate content width by subtracting padding
    self.width = math.max(0, self._borderBoxWidth - self.padding.left - self.padding.right)
  elseif self.units.width.unit == "auto" then
    -- For auto-sized elements, width is content width (calculated in resize method)
    -- Update border-box to include padding
    self._borderBoxWidth = self.width + self.padding.left + self.padding.right
  end
  -- For pixel units, width stays as-is (may have been manually modified)

  if self.units.height.unit ~= "auto" and self.units.height.unit ~= "px" then
    -- _borderBoxHeight was recalculated for viewport/percentage units
    -- Calculate content height by subtracting padding
    self.height = math.max(0, self._borderBoxHeight - self.padding.top - self.padding.bottom)
  elseif self.units.height.unit == "auto" then
    -- For auto-sized elements, height is content height (calculated in resize method)
    -- Update border-box to include padding
    self._borderBoxHeight = self.height + self.padding.top + self.padding.bottom
  end
  -- For pixel units, height stays as-is (may have been manually modified)
end

--- Resize element and its children based on game window size change
---@param newGameWidth number
---@param newGameHeight number
function Element:resize(newGameWidth, newGameHeight)
  self:recalculateUnits(newGameWidth, newGameHeight)

  -- For non-auto-sized elements with viewport/percentage units, update content dimensions from border-box
  if not self.autosizing.width and self._borderBoxWidth and self.units.width.unit ~= "px" then
    self.width = math.max(0, self._borderBoxWidth - self.padding.left - self.padding.right)
  end
  if not self.autosizing.height and self._borderBoxHeight and self.units.height.unit ~= "px" then
    self.height = math.max(0, self._borderBoxHeight - self.padding.top - self.padding.bottom)
  end

  -- Update children
  for _, child in ipairs(self.children) do
    child:resize(newGameWidth, newGameHeight)
  end

  -- Recalculate auto-sized dimensions after children are resized
  if self.autosizing.width then
    local contentWidth = self:calculateAutoWidth()
    -- BORDER-BOX MODEL: Add padding to get border-box, then subtract to get content
    self._borderBoxWidth = contentWidth + self.padding.left + self.padding.right
    self.width = contentWidth
  end
  if self.autosizing.height then
    local contentHeight = self:calculateAutoHeight()
    -- BORDER-BOX MODEL: Add padding to get border-box, then subtract to get content
    self._borderBoxHeight = contentHeight + self.padding.top + self.padding.bottom
    self.height = contentHeight
  end

  -- Re-resolve ew/eh textSize units after all dimensions are finalized
  -- This ensures textSize updates based on current width/height (whether calculated or manually set)
  if self.units.textSize.value then
    local unit = self.units.textSize.unit
    local value = self.units.textSize.value
    local _, scaleY = Gui.getScaleFactors()

    if unit == "ew" then
      -- Element width relative (use current width)
      self.textSize = (value / 100) * self.width

      -- Apply min/max constraints
      local minSize = self.minTextSize and (Gui.baseScale and (self.minTextSize * scaleY) or self.minTextSize)
      local maxSize = self.maxTextSize and (Gui.baseScale and (self.maxTextSize * scaleY) or self.maxTextSize)
      if minSize and self.textSize < minSize then
        self.textSize = minSize
      end
      if maxSize and self.textSize > maxSize then
        self.textSize = maxSize
      end
      if self.textSize < 1 then
        self.textSize = 1
      end
    elseif unit == "eh" then
      -- Element height relative (use current height)
      self.textSize = (value / 100) * self.height

      -- Apply min/max constraints
      local minSize = self.minTextSize and (Gui.baseScale and (self.minTextSize * scaleY) or self.minTextSize)
      local maxSize = self.maxTextSize and (Gui.baseScale and (self.maxTextSize * scaleY) or self.maxTextSize)
      if minSize and self.textSize < minSize then
        self.textSize = minSize
      end
      if maxSize and self.textSize > maxSize then
        self.textSize = maxSize
      end
      if self.textSize < 1 then
        self.textSize = 1
      end
    end
  end

  self:layoutChildren()
  self.prevGameSize.width = newGameWidth
  self.prevGameSize.height = newGameHeight
end

--- Calculate text width for button
---@return number
function Element:calculateTextWidth()
  if self.text == nil then
    return 0
  end

  if self.textSize then
    -- Resolve font path from font family (same logic as in draw)
    local fontPath = nil
    if self.fontFamily then
      local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
      if themeToUse and themeToUse.fonts and themeToUse.fonts[self.fontFamily] then
        fontPath = themeToUse.fonts[self.fontFamily]
      else
        fontPath = self.fontFamily
      end
    elseif self.themeComponent then
      local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
      if themeToUse and themeToUse.fonts and themeToUse.fonts.default then
        fontPath = themeToUse.fonts.default
      end
    end

    local tempFont = FONT_CACHE.get(self.textSize, fontPath)
    local width = tempFont:getWidth(self.text)
    -- Apply contentAutoSizingMultiplier if set
    if self.contentAutoSizingMultiplier and self.contentAutoSizingMultiplier.width then
      width = width * self.contentAutoSizingMultiplier.width
    end
    return width
  end

  local font = love.graphics.getFont()
  local width = font:getWidth(self.text)
  -- Apply contentAutoSizingMultiplier if set
  if self.contentAutoSizingMultiplier and self.contentAutoSizingMultiplier.width then
    width = width * self.contentAutoSizingMultiplier.width
  end
  return width
end

---@return number
function Element:calculateTextHeight()
  if self.text == nil then
    return 0
  end

  if self.textSize then
    -- Resolve font path from font family (same logic as in draw)
    local fontPath = nil
    if self.fontFamily then
      local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
      if themeToUse and themeToUse.fonts and themeToUse.fonts[self.fontFamily] then
        fontPath = themeToUse.fonts[self.fontFamily]
      else
        fontPath = self.fontFamily
      end
    elseif self.themeComponent then
      local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
      if themeToUse and themeToUse.fonts and themeToUse.fonts.default then
        fontPath = themeToUse.fonts.default
      end
    end

    local tempFont = FONT_CACHE.get(self.textSize, fontPath)
    local height = tempFont:getHeight()
    -- Apply contentAutoSizingMultiplier if set
    if self.contentAutoSizingMultiplier and self.contentAutoSizingMultiplier.height then
      height = height * self.contentAutoSizingMultiplier.height
    end
    return height
  end

  local font = love.graphics.getFont()
  local height = font:getHeight()
  -- Apply contentAutoSizingMultiplier if set
  if self.contentAutoSizingMultiplier and self.contentAutoSizingMultiplier.height then
    height = height * self.contentAutoSizingMultiplier.height
  end
  return height
end

function Element:calculateAutoWidth()
  -- BORDER-BOX MODEL: Calculate content width, caller will add padding to get border-box
  local contentWidth = self:calculateTextWidth()
  if not self.children or #self.children == 0 then
    return contentWidth
  end

  -- For HORIZONTAL flex: sum children widths + gaps
  -- For VERTICAL flex: max of children widths
  local isHorizontal = self.flexDirection == "horizontal"
  local totalWidth = contentWidth
  local maxWidth = contentWidth
  local participatingChildren = 0

  for _, child in ipairs(self.children) do
    -- Skip explicitly absolute positioned children as they don't affect parent auto-sizing
    if not child._explicitlyAbsolute then
      -- BORDER-BOX MODEL: Use border-box width for auto-sizing calculations
      local childBorderBoxWidth = child:getBorderBoxWidth()
      if isHorizontal then
        totalWidth = totalWidth + childBorderBoxWidth
      else
        maxWidth = math.max(maxWidth, childBorderBoxWidth)
      end
      participatingChildren = participatingChildren + 1
    end
  end

  if isHorizontal then
    -- Add gaps between children (n-1 gaps for n children)
    local gapCount = math.max(0, participatingChildren - 1)
    return totalWidth + (self.gap * gapCount)
  else
    return maxWidth
  end
end

--- Calculate auto height based on children
function Element:calculateAutoHeight()
  local height = self:calculateTextHeight()
  if not self.children or #self.children == 0 then
    return height
  end

  -- For VERTICAL flex: sum children heights + gaps
  -- For HORIZONTAL flex: max of children heights
  local isVertical = self.flexDirection == "vertical"
  local totalHeight = height
  local maxHeight = height
  local participatingChildren = 0

  for _, child in ipairs(self.children) do
    -- Skip explicitly absolute positioned children as they don't affect parent auto-sizing
    if not child._explicitlyAbsolute then
      -- BORDER-BOX MODEL: Use border-box height for auto-sizing calculations
      local childBorderBoxHeight = child:getBorderBoxHeight()
      if isVertical then
        totalHeight = totalHeight + childBorderBoxHeight
      else
        maxHeight = math.max(maxHeight, childBorderBoxHeight)
      end
      participatingChildren = participatingChildren + 1
    end
  end

  if isVertical then
    -- Add gaps between children (n-1 gaps for n children)
    local gapCount = math.max(0, participatingChildren - 1)
    return totalHeight + (self.gap * gapCount)
  else
    return maxHeight
  end
end

---@param newText string
---@param autoresize boolean? --default: false
function Element:updateText(newText, autoresize)
  self.text = newText or self.text
  if autoresize then
    self.width = self:calculateTextWidth()
    self.height = self:calculateTextHeight()
  end
end

---@param newOpacity number
function Element:updateOpacity(newOpacity)
  self.opacity = newOpacity
  for _, child in ipairs(self.children) do
    child:updateOpacity(newOpacity)
  end
end

--- same as calling updateOpacity(0)
function Element:hide()
  self:updateOpacity(0)
end

--- same as calling updateOpacity(1)
function Element:show()
  self:updateOpacity(1)
end

-- ====================
-- Input Handling - Cursor Management
-- ====================

--- Set cursor position
---@param position number -- Character index (0-based)
function Element:setCursorPosition(position)
  if not self.editable then
    return
  end
  self._cursorPosition = position
  self:_validateCursorPosition()
  self:_resetCursorBlink()
end

--- Get cursor position
---@return number -- Character index (0-based)
function Element:getCursorPosition()
  if not self.editable then
    return 0
  end
  return self._cursorPosition
end

--- Move cursor by delta characters
---@param delta number -- Number of characters to move (positive or negative)
function Element:moveCursorBy(delta)
  if not self.editable then
    return
  end
  self._cursorPosition = self._cursorPosition + delta
  self:_validateCursorPosition()
  self:_resetCursorBlink()
end

--- Move cursor to start of text
function Element:moveCursorToStart()
  if not self.editable then
    return
  end
  self._cursorPosition = 0
  self:_resetCursorBlink()
end

--- Move cursor to end of text
function Element:moveCursorToEnd()
  if not self.editable then
    return
  end
  local textLength = utf8.len(self._textBuffer or "")
  self._cursorPosition = textLength
  self:_resetCursorBlink()
end

--- Move cursor to start of current line
function Element:moveCursorToLineStart()
  if not self.editable then
    return
  end
  -- For now, just move to start (will be enhanced for multi-line)
  self:moveCursorToStart()
end

--- Move cursor to end of current line
function Element:moveCursorToLineEnd()
  if not self.editable then
    return
  end
  -- For now, just move to end (will be enhanced for multi-line)
  self:moveCursorToEnd()
end

--- Validate cursor position (ensure it's within text bounds)
function Element:_validateCursorPosition()
  if not self.editable then
    return
  end
  local textLength = utf8.len(self._textBuffer or "")
  self._cursorPosition = math.max(0, math.min(self._cursorPosition, textLength))
end

--- Reset cursor blink (show cursor immediately)
function Element:_resetCursorBlink()
  if not self.editable then
    return
  end
  self._cursorBlinkTimer = 0
  self._cursorVisible = true
end

-- ====================
-- Input Handling - Selection Management
-- ====================

--- Set selection range
---@param startPos number -- Start position (inclusive)
---@param endPos number -- End position (inclusive)
function Element:setSelection(startPos, endPos)
  if not self.editable then
    return
  end
  local textLength = utf8.len(self._textBuffer or "")
  self._selectionStart = math.max(0, math.min(startPos, textLength))
  self._selectionEnd = math.max(0, math.min(endPos, textLength))

  -- Ensure start <= end
  if self._selectionStart > self._selectionEnd then
    self._selectionStart, self._selectionEnd = self._selectionEnd, self._selectionStart
  end

  self:_resetCursorBlink()
end

--- Get selection range
---@return number?, number? -- Start and end positions, or nil if no selection
function Element:getSelection()
  if not self.editable then
    return nil, nil
  end
  if not self:hasSelection() then
    return nil, nil
  end
  return self._selectionStart, self._selectionEnd
end

--- Check if there is an active selection
---@return boolean
function Element:hasSelection()
  if not self.editable then
    return false
  end
  return self._selectionStart ~= nil and self._selectionEnd ~= nil and self._selectionStart ~= self._selectionEnd
end

--- Clear selection
function Element:clearSelection()
  if not self.editable then
    return
  end
  self._selectionStart = nil
  self._selectionEnd = nil
  self._selectionAnchor = nil
end

--- Select all text
function Element:selectAll()
  if not self.editable then
    return
  end
  local textLength = utf8.len(self._textBuffer or "")
  self._selectionStart = 0
  self._selectionEnd = textLength
  self:_resetCursorBlink()
end

--- Get selected text
---@return string? -- Selected text or nil if no selection
function Element:getSelectedText()
  if not self.editable or not self:hasSelection() then
    return nil
  end
  local startPos, endPos = self:getSelection()
  if not startPos or not endPos then
    return nil
  end

  -- Convert character indices to byte offsets for utf8.sub
  local text = self._textBuffer or ""
  return utf8.sub(text, startPos + 1, endPos)
end

--- Delete selected text
---@return boolean -- True if text was deleted
function Element:deleteSelection()
  if not self.editable or not self:hasSelection() then
    return false
  end
  local startPos, endPos = self:getSelection()
  if not startPos or not endPos then
    return false
  end

  self:deleteText(startPos, endPos)
  self:clearSelection()
  self._cursorPosition = startPos
  self:_validateCursorPosition()
  return true
end

-- ====================
-- Input Handling - Focus Management
-- ====================

--- Focus this element for keyboard input
function Element:focus()
  if not self.editable then
    return
  end

  -- Blur previously focused element
  if Gui._focusedElement and Gui._focusedElement ~= self then
    Gui._focusedElement:blur()
  end

  -- Set focus state
  self._focused = true
  Gui._focusedElement = self

  -- Reset cursor blink
  self:_resetCursorBlink()

  -- Select all text if selectOnFocus is enabled
  if self.selectOnFocus then
    self:selectAll()
  else
    -- Move cursor to end of text
    self:moveCursorToEnd()
  end

  -- Trigger onFocus callback if defined
  if self.onFocus then
    self.onFocus(self)
  end
end

--- Remove focus from this element
function Element:blur()
  if not self.editable then
    return
  end

  self._focused = false

  -- Clear global focused element if it's this element
  if Gui._focusedElement == self then
    Gui._focusedElement = nil
  end

  -- Trigger onBlur callback if defined
  if self.onBlur then
    self.onBlur(self)
  end
end

--- Check if this element is focused
---@return boolean
function Element:isFocused()
  if not self.editable then
    return false
  end
  return self._focused == true
end

-- ====================
-- Input Handling - Text Buffer Management
-- ====================

--- Get current text buffer
---@return string
function Element:getText()
  if not self.editable then
    return self.text or ""
  end
  return self._textBuffer or ""
end

--- Set text buffer and mark dirty
---@param text string
function Element:setText(text)
  if not self.editable then
    self.text = text
    return
  end

  self._textBuffer = text or ""
  self.text = self._textBuffer -- Sync display text
  self:_markTextDirty()
  self:_validateCursorPosition()
end

--- Insert text at position
---@param text string -- Text to insert
---@param position number? -- Position to insert at (default: cursor position)
function Element:insertText(text, position)
  if not self.editable then
    return
  end

  position = position or self._cursorPosition
  local buffer = self._textBuffer or ""

  -- Convert character position to byte offset
  local byteOffset = utf8.offset(buffer, position + 1) or (#buffer + 1)

  -- Insert text
  local before = buffer:sub(1, byteOffset - 1)
  local after = buffer:sub(byteOffset)
  self._textBuffer = before .. text .. after
  self.text = self._textBuffer -- Sync display text

  -- Update cursor position
  self._cursorPosition = position + utf8.len(text)

  self:_markTextDirty()
  self:_validateCursorPosition()
end

--- Delete text in range
---@param startPos number -- Start position (inclusive)
---@param endPos number -- End position (inclusive)
function Element:deleteText(startPos, endPos)
  if not self.editable then
    return
  end

  local buffer = self._textBuffer or ""

  -- Ensure valid range
  local textLength = utf8.len(buffer)
  startPos = math.max(0, math.min(startPos, textLength))
  endPos = math.max(0, math.min(endPos, textLength))

  if startPos > endPos then
    startPos, endPos = endPos, startPos
  end

  -- Convert character positions to byte offsets
  local startByte = utf8.offset(buffer, startPos + 1) or 1
  local endByte = utf8.offset(buffer, endPos + 1) or (#buffer + 1)

  -- Delete text
  local before = buffer:sub(1, startByte - 1)
  local after = buffer:sub(endByte)
  self._textBuffer = before .. after
  self.text = self._textBuffer -- Sync display text

  self:_markTextDirty()
end

--- Replace text in range
---@param startPos number -- Start position (inclusive)
---@param endPos number -- End position (inclusive)
---@param newText string -- Replacement text
function Element:replaceText(startPos, endPos, newText)
  if not self.editable then
    return
  end

  self:deleteText(startPos, endPos)
  self:insertText(newText, startPos)
end

--- Mark text as dirty (needs recalculation)
function Element:_markTextDirty()
  if not self.editable then
    return
  end
  self._textDirty = true
end

--- Update text if dirty (recalculate lines and wrapping)
function Element:_updateTextIfDirty()
  if not self.editable or not self._textDirty then
    return
  end

  self:_splitLines()
  self:_calculateWrapping()
  self:_validateCursorPosition()
  self._textDirty = false
end

--- Split text into lines (for multi-line text)
function Element:_splitLines()
  if not self.editable then
    return
  end

  if not self.multiline then
    self._lines = { self._textBuffer or "" }
    return
  end

  self._lines = {}
  local text = self._textBuffer or ""

  -- Split on newlines
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(self._lines, line)
  end

  -- Ensure at least one line
  if #self._lines == 0 then
    self._lines = { "" }
  end
end

--- Calculate text wrapping
function Element:_calculateWrapping()
  if not self.editable or not self.textWrap then
    self._wrappedLines = nil
    return
  end

  self._wrappedLines = {}
  local availableWidth = self.width - self.padding.left - self.padding.right

  for lineNum, line in ipairs(self._lines or {}) do
    if line == "" then
      table.insert(self._wrappedLines, {
        text = "",
        startIdx = 0,
        endIdx = 0,
        lineNum = lineNum,
      })
    else
      local wrappedParts = self:_wrapLine(line, availableWidth)
      for _, part in ipairs(wrappedParts) do
        part.lineNum = lineNum
        table.insert(self._wrappedLines, part)
      end
    end
  end
end

--- Wrap a single line of text
---@param line string -- Line to wrap
---@param maxWidth number -- Maximum width in pixels
---@return table -- Array of wrapped line parts
function Element:_wrapLine(line, maxWidth)
  if not self.editable then
    return { { text = line, startIdx = 0, endIdx = utf8.len(line) } }
  end

  local font = self:_getFont()
  local wrappedParts = {}
  local currentLine = ""
  local startIdx = 0

  if self.textWrap == "word" then
    -- Word wrapping
    local words = {}
    for word in line:gmatch("%S+") do
      table.insert(words, word)
    end

    for i, word in ipairs(words) do
      local testLine = currentLine == "" and word or (currentLine .. " " .. word)
      local width = font:getWidth(testLine)

      if width > maxWidth and currentLine ~= "" then
        -- Current line is full, start new line
        table.insert(wrappedParts, {
          text = currentLine,
          startIdx = startIdx,
          endIdx = startIdx + utf8.len(currentLine),
        })
        currentLine = word
        startIdx = startIdx + utf8.len(currentLine) + 1
      else
        currentLine = testLine
      end
    end
  else
    -- Character wrapping
    local lineLength = utf8.len(line)
    for i = 1, lineLength do
      local char = utf8.sub(line, i, i)
      local testLine = currentLine .. char
      local width = font:getWidth(testLine)

      if width > maxWidth and currentLine ~= "" then
        table.insert(wrappedParts, {
          text = currentLine,
          startIdx = startIdx,
          endIdx = startIdx + utf8.len(currentLine),
        })
        currentLine = char
        startIdx = i - 1
      else
        currentLine = testLine
      end
    end
  end

  -- Add remaining text
  if currentLine ~= "" then
    table.insert(wrappedParts, {
      text = currentLine,
      startIdx = startIdx,
      endIdx = startIdx + utf8.len(currentLine),
    })
  end

  -- Ensure at least one part
  if #wrappedParts == 0 then
    table.insert(wrappedParts, {
      text = "",
      startIdx = 0,
      endIdx = 0,
    })
  end

  return wrappedParts
end

--- Get font for text rendering
---@return love.Font
function Element:_getFont()
  -- Get font path from theme or element
  local fontPath = nil
  if self.fontFamily then
    local themeToUse = self.theme and themes[self.theme] or Theme.getActive()
    if themeToUse and themeToUse.fonts and themeToUse.fonts[self.fontFamily] then
      fontPath = themeToUse.fonts[self.fontFamily]
    else
      -- Assume fontFamily is a direct path
      fontPath = self.fontFamily
    end
  end

  return FONT_CACHE.getFont(self.textSize, fontPath)
end

-- ====================
-- Input Handling - Keyboard Input
-- ====================

--- Handle text input (character input)
---@param text string -- Character(s) to insert
function Element:textinput(text)
  if not self.editable or not self._focused then
    return
  end

  -- Trigger onTextInput callback if defined
  if self.onTextInput then
    local result = self.onTextInput(self, text)
    -- If callback returns false, cancel the input
    if result == false then
      return
    end
  end

  -- Capture old text for callback
  local oldText = self._textBuffer

  -- Delete selection if exists
  local hadSelection = self:hasSelection()
  if hadSelection then
    self:deleteSelection()
  end

  -- Insert text at cursor position
  self:insertText(text)

  -- Trigger onTextChange callback if text changed
  if self.onTextChange and self._textBuffer ~= oldText then
    self.onTextChange(self, self._textBuffer, oldText)
  end
end

--- Handle key press (special keys)
---@param key string -- Key name
---@param scancode string -- Scancode
---@param isrepeat boolean -- Whether this is a key repeat
function Element:keypressed(key, scancode, isrepeat)
  if not self.editable or not self._focused then
    return
  end

  local modifiers = getModifiers()
  local ctrl = modifiers.ctrl or modifiers.super -- Support both Ctrl and Cmd

  -- Handle cursor movement
  if key == "left" then
    if self:hasSelection() and not modifiers.shift then
      -- Move to start of selection
      local startPos, _ = self:getSelection()
      self._cursorPosition = startPos
      self:clearSelection()
    else
      self:moveCursorBy(-1)
    end
    self:_resetCursorBlink()
  elseif key == "right" then
    if self:hasSelection() and not modifiers.shift then
      -- Move to end of selection
      local _, endPos = self:getSelection()
      self._cursorPosition = endPos
      self:clearSelection()
    else
      self:moveCursorBy(1)
    end
    self:_resetCursorBlink()
  elseif key == "home" or (ctrl and key == "a" and not self.multiline) then
    -- Move to line start (or document start for single-line)
    if ctrl or not self.multiline then
      self:moveCursorToStart()
    else
      self:moveCursorToLineStart()
    end
    if key == "home" then
      self:clearSelection()
    end
    self:_resetCursorBlink()
  elseif key == "end" or (ctrl and key == "e" and not self.multiline) then
    -- Move to line end (or document end for single-line)
    if ctrl or not self.multiline then
      self:moveCursorToEnd()
    else
      self:moveCursorToLineEnd()
    end
    if key == "end" then
      self:clearSelection()
    end
    self:_resetCursorBlink()

  -- Handle backspace and delete
  elseif key == "backspace" then
    local oldText = self._textBuffer
    if self:hasSelection() then
      -- Delete selection
      self:deleteSelection()
    elseif self._cursorPosition > 0 then
      -- Delete character before cursor
      self:deleteText(self._cursorPosition - 1, self._cursorPosition)
      self._cursorPosition = self._cursorPosition - 1
      self:_validateCursorPosition()
    end

    -- Trigger onTextChange callback
    if self.onTextChange and self._textBuffer ~= oldText then
      self.onTextChange(self, self._textBuffer, oldText)
    end
    self:_resetCursorBlink()
  elseif key == "delete" then
    local oldText = self._textBuffer
    if self:hasSelection() then
      -- Delete selection
      self:deleteSelection()
    else
      -- Delete character after cursor
      local textLength = utf8.len(self._textBuffer or "")
      if self._cursorPosition < textLength then
        self:deleteText(self._cursorPosition, self._cursorPosition + 1)
      end
    end

    -- Trigger onTextChange callback
    if self.onTextChange and self._textBuffer ~= oldText then
      self.onTextChange(self, self._textBuffer, oldText)
    end
    self:_resetCursorBlink()

  -- Handle return/enter
  elseif key == "return" or key == "kpenter" then
    if self.multiline then
      -- Insert newline
      local oldText = self._textBuffer
      if self:hasSelection() then
        self:deleteSelection()
      end
      self:insertText("\n")

      -- Trigger onTextChange callback
      if self.onTextChange and self._textBuffer ~= oldText then
        self.onTextChange(self, self._textBuffer, oldText)
      end
    else
      -- Trigger onEnter callback for single-line
      if self.onEnter then
        self.onEnter(self)
      end
    end
    self:_resetCursorBlink()

  -- Handle Ctrl/Cmd+A (select all)
  elseif ctrl and key == "a" then
    self:selectAll()
    self:_resetCursorBlink()

  -- Handle Escape
  elseif key == "escape" then
    if self:hasSelection() then
      -- Clear selection
      self:clearSelection()
    else
      -- Blur element
      self:blur()
    end
    self:_resetCursorBlink()
  end
end

Gui.new = Element.new
Gui.Element = Element
Gui.Animation = Animation
Gui.Theme = Theme
Gui.ImageDataReader = ImageDataReader
Gui.NinePatchParser = NinePatchParser

return {
  GUI = Gui,
  Gui = Gui,
  Element = Element,
  Color = Color,
  Theme = Theme,
  Animation = Animation,
  ImageScaler = ImageScaler,
  ImageCache = ImageCache,
  ImageRenderer = ImageRenderer,
  ImageDataReader = ImageDataReader,
  NinePatchParser = NinePatchParser,
  enums = enums,
}
