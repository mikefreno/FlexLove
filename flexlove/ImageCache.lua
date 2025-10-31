--[[
ImageCache.lua - Image caching system for FlexLove
Provides efficient image loading and caching with memory management
]]

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
    imageData = imgData,
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
    memoryEstimate = memoryEstimate,
  }
end

return ImageCache
