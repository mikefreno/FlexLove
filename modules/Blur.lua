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

return Blur
