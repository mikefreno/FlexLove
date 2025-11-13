--- Standardized error message formatter
---@param module string -- Module name (e.g., "Color", "Theme", "Units")
---@param message string -- Error message
---@return string -- Formatted error message
local function formatError(module, message)
  return string.format("[FlexLove.%s] %s", module, message)
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

return ImageDataReader
