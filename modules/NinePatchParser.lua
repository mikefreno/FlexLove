--[[
NinePatchParser.lua - 9-patch PNG parser for FlexLove
Parses Android-style 9-patch images to extract stretch regions and content padding
]]

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

-- ====================
-- Dependencies
-- ====================

local ImageDataReader = require((...):match("(.-)[^%.]+$") .. "ImageDataReader")

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

return NinePatchParser
