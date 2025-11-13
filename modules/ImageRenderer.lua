--- Standardized error message formatter
---@param module string -- Module name (e.g., "Color", "Theme", "Units")
---@param message string -- Error message
---@return string -- Formatted error message
local function formatError(module, message)
  return string.format("[FlexLove.%s] %s", module, message)
end

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

  if imageWidth <= 0 or imageHeight <= 0 or boundsWidth <= 0 or boundsHeight <= 0 then
    error(formatError("ImageRenderer", "Dimensions must be positive"))
  end

  local result = {
    sx = 0, -- Source X
    sy = 0, -- Source Y
    sw = imageWidth, -- Source width
    sh = imageHeight, -- Source height
    dx = 0, -- Destination X
    dy = 0, -- Destination Y
    dw = boundsWidth, -- Destination width
    dh = boundsHeight, -- Destination height
    scaleX = 1, -- Scale factor X
    scaleY = 1, -- Scale factor Y
  }

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
      parts = { val, "center" }
    elseif val == "top" or val == "bottom" then
      parts = { "center", val }
    else
      parts = { val, val }
    end
  elseif #parts == 0 then
    return 0.5, 0.5 -- Default to center
  end

  local function parseValue(val)
    -- Handle keywords
    if val == "center" then
      return 0.5
    elseif val == "left" or val == "top" then
      return 0
    elseif val == "right" or val == "bottom" then
      return 1
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

return ImageRenderer
