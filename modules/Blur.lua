-- Lua 5.2+ compatibility for unpack
local unpack = table.unpack or unpack

local Cache = {
  canvases = {},
  quads = {},
  blurInstances = {}, -- Cache blur instances by quality
  MAX_CANVAS_SIZE = 20,
  MAX_QUAD_SIZE = 20,
  INTENSITY_THRESHOLD = 5, -- Skip blur below this intensity
}

--- Round canvas size to nearest bucket for better reuse
---@param size number Size to bucket
---@return number bucketSize Bucketed size
local function bucketSize(size)
  if size <= 128 then
    return math.ceil(size / 32) * 32
  elseif size <= 512 then
    return math.ceil(size / 64) * 64
  elseif size <= 1024 then
    return math.ceil(size / 128) * 128
  else
    return math.ceil(size / 256) * 256
  end
end

--- Get or create a canvas from cache
---@param width number Canvas width
---@param height number Canvas height
---@return love.Canvas canvas The cached or new canvas
function Cache.getCanvas(width, height)
  -- Use bucketed sizes for better cache reuse
  local bucketedWidth = bucketSize(width)
  local bucketedHeight = bucketSize(height)
  local key = string.format("%dx%d", bucketedWidth, bucketedHeight)

  if not Cache.canvases[key] then
    Cache.canvases[key] = {}
  end

  local cache = Cache.canvases[key]

  for i, entry in ipairs(cache) do
    if not entry.inUse then
      entry.inUse = true
      return entry.canvas
    end
  end

  local canvas = love.graphics.newCanvas(bucketedWidth, bucketedHeight)
  table.insert(cache, { canvas = canvas, inUse = true })

  if #cache > Cache.MAX_CANVAS_SIZE then
    local removed = table.remove(cache, 1)
    if removed and removed.canvas then
      removed.canvas:release()
    end
  end

  return canvas
end

--- Release a canvas back to the cache
---@param canvas love.Canvas Canvas to release
function Cache.releaseCanvas(canvas)
  for _, sizeCache in pairs(Cache.canvases) do
    for _, entry in ipairs(sizeCache) do
      if entry.canvas == canvas then
        entry.inUse = false
        return
      end
    end
  end
end

--- Get or create a quad from cache
---@param x number X position
---@param y number Y position
---@param width number Quad width
---@param height number Quad height
---@param sw number Source width
---@param sh number Source height
---@return love.Quad quad The cached or new quad
function Cache.getQuad(x, y, width, height, sw, sh)
  local key = string.format("%d,%d,%d,%d,%d,%d", x, y, width, height, sw, sh)

  if not Cache.quads[key] then
    Cache.quads[key] = {}
  end

  local cache = Cache.quads[key]

  for i, entry in ipairs(cache) do
    if not entry.inUse then
      entry.inUse = true
      return entry.quad
    end
  end

  local quad = love.graphics.newQuad(x, y, width, height, sw, sh)
  table.insert(cache, { quad = quad, inUse = true })

  if #cache > Cache.MAX_QUAD_SIZE then
    table.remove(cache, 1)
  end

  return quad
end

--- Release a quad back to the cache
---@param quad love.Quad Quad to release
function Cache.releaseQuad(quad)
  for _, keyCache in pairs(Cache.quads) do
    for _, entry in ipairs(keyCache) do
      if entry.quad == quad then
        entry.inUse = false
        return
      end
    end
  end
end

--- Clear all caches
function Cache.clear()
  Cache.canvases = {}
  Cache.quads = {}
  Cache.blurInstances = {}
end

-- ============================================================================
-- SHADER BUILDER
-- ============================================================================

local ShaderBuilder = {}

--- Build Gaussian blur shader with given parameters
---@param taps number Number of samples (must be odd, >= 3)
---@param offset number Offset value
---@param offsetType string "weighted" or "center"
---@param sigma number Sigma value for Gaussian distribution
---@return love.Shader shader The compiled blur shader
function ShaderBuilder.build(taps, offset, offsetType, sigma)
  taps = math.floor(taps)
  sigma = sigma >= 1 and sigma or (taps - 1) * offset / 6
  sigma = math.max(sigma, 1)

  local steps = (taps + 1) / 2

  local gOffsets = {}
  local gWeights = {}
  for i = 1, steps do
    gOffsets[i] = offset * (i - 1)
    gWeights[i] = math.exp(-0.5 * (gOffsets[i] - 0) ^ 2 * 1 / sigma ^ 2)
  end

  local offsets = {}
  local weights = {}
  for i = #gWeights, 2, -2 do
    local oA, oB = gOffsets[i], gOffsets[i - 1]
    local wA, wB = gWeights[i], gWeights[i - 1]
    wB = oB == 0 and wB / 2 or wB
    local weight = wA + wB
    offsets[#offsets + 1] = offsetType == "center" and (oA + oB) / 2 or (oA * wA + oB * wB) / weight
    weights[#weights + 1] = weight
  end

  local code = {
    [[
    extern vec2 direction;
    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {]],
  }

  local norm = 0
  if #gWeights % 2 == 0 then
    code[#code + 1] = "vec4 c = vec4( 0.0 );"
  else
    local weight = gWeights[1]
    norm = norm + weight
    code[#code + 1] = string.format("vec4 c = %f * texture2D(tex, tc);", weight)
  end

  local template = "c += %f * ( texture2D(tex, tc + %f * direction)+ texture2D(tex, tc - %f * direction));\n"
  for i = 1, #offsets do
    local offset = offsets[i]
    local weight = weights[i]
    norm = norm + weight * 2
    code[#code + 1] = string.format(template, weight, offset, offset)
  end
  code[#code + 1] = string.format("return c * vec4(%f) * color; }", 1 / norm)

  local shaderCode = table.concat(code)
  return love.graphics.newShader(shaderCode)
end

--- Get or create a blur instance from cache
---@param quality number Quality level (1-10)
---@return table blurData Cached blur data {shader, taps}
function Cache.getBlurInstance(quality)
  if not Cache.blurInstances[quality] then
    local taps = 3 + (quality - 1) * 1.5
    taps = math.floor(taps)
    if taps % 2 == 0 then
      taps = taps + 1
    end
    
    local shader = ShaderBuilder.build(taps, 1.0, "weighted", -1)
    Cache.blurInstances[quality] = {
      shader = shader,
      taps = taps,
    }
  end
  
  return Cache.blurInstances[quality]
end

---@class BlurProps
---@field quality number? Quality level (1-10, default: 5)

---@class Blur
---@field shader love.Shader The blur shader
---@field quality number Quality level (1-10)
---@field taps number Number of shader taps
---@field _ErrorHandler table? Reference to ErrorHandler module
local Blur = {}
Blur.__index = Blur

--- Create a new blur effect instance
---@param props BlurProps? Blur configuration
---@return Blur blur The new blur instance
function Blur.new(props)
  props = props or {}

  local quality = props.quality or 5
  quality = math.max(1, math.min(10, quality))

  -- Get cached blur instance for this quality level
  local blurData = Cache.getBlurInstance(quality)

  local self = setmetatable({}, Blur)
  self.shader = blurData.shader
  self.quality = quality
  self.taps = blurData.taps

  return self
end

--- Apply blur to a region of the screen
---@param intensity number Blur intensity (0-100)
---@param x number X position
---@param y number Y position
---@param width number Width of region
---@param height number Height of region
---@param drawFunc function Function to draw content to be blurred
function Blur:applyToRegion(intensity, x, y, width, height, drawFunc)
  if type(drawFunc) ~= "function" then
    if Blur._ErrorHandler then
      Blur._ErrorHandler:warn("Blur", "applyToRegion requires a draw function.")
    end
    return
  end

  if intensity <= 0 or width <= 0 or height <= 0 then
    drawFunc()
    return
  end

  -- Early exit for very low intensity (optimization)
  if intensity < Cache.INTENSITY_THRESHOLD then
    drawFunc()
    return
  end

  intensity = math.max(0, math.min(100, intensity))

  -- Intensity 0-100 maps to 0-5 passes
  local passes = math.ceil(intensity / 20)
  passes = math.max(1, math.min(5, passes))

  local canvas1 = Cache.getCanvas(width, height)
  local canvas2 = Cache.getCanvas(width, height)

  local prevCanvas = love.graphics.getCanvas()
  local prevShader = love.graphics.getShader()
  local prevColor = { love.graphics.getColor() }
  local prevBlendMode = love.graphics.getBlendMode()

  love.graphics.setCanvas(canvas1)
  love.graphics.clear()
  love.graphics.push()
  love.graphics.origin()
  love.graphics.translate(-x, -y)
  drawFunc()
  love.graphics.pop()

  love.graphics.setShader(self.shader)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setBlendMode("alpha", "premultiplied")

  for i = 1, passes do
    love.graphics.setCanvas(canvas2)
    love.graphics.clear()
    self.shader:send("direction", { 1 / width, 0 })
    love.graphics.draw(canvas1, 0, 0)

    love.graphics.setCanvas(canvas1)
    love.graphics.clear()
    self.shader:send("direction", { 0, 1 / height })
    love.graphics.draw(canvas2, 0, 0)
  end

  love.graphics.setCanvas(prevCanvas)
  love.graphics.setShader()
  love.graphics.setBlendMode(prevBlendMode)
  love.graphics.draw(canvas1, x, y)

  love.graphics.setShader(prevShader)
  love.graphics.setColor(unpack(prevColor))

  Cache.releaseCanvas(canvas1)
  Cache.releaseCanvas(canvas2)
end

--- Apply backdrop blur effect (blur content behind a region)
---@param intensity number Blur intensity (0-100)
---@param x number X position
---@param y number Y position
---@param width number Width of region
---@param height number Height of region
---@param backdropCanvas love.Canvas Canvas containing the backdrop content
function Blur:applyBackdrop(intensity, x, y, width, height, backdropCanvas)
  if not backdropCanvas then
    if Blur._ErrorHandler then
      Blur._ErrorHandler:warn("Blur", "applyBackdrop requires a backdrop canvas.")
    end
    return
  end

  if intensity <= 0 or width <= 0 or height <= 0 then
    return
  end

  -- Early exit for very low intensity (optimization)
  if intensity < Cache.INTENSITY_THRESHOLD then
    return
  end

  intensity = math.max(0, math.min(100, intensity))

  local passes = math.ceil(intensity / 20)
  passes = math.max(1, math.min(5, passes))

  local canvas1 = Cache.getCanvas(width, height)
  local canvas2 = Cache.getCanvas(width, height)

  local prevCanvas = love.graphics.getCanvas()
  local prevShader = love.graphics.getShader()
  local prevColor = { love.graphics.getColor() }
  local prevBlendMode = love.graphics.getBlendMode()

  love.graphics.setCanvas(canvas1)
  love.graphics.clear()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setBlendMode("alpha", "premultiplied")

  local backdropWidth, backdropHeight = backdropCanvas:getDimensions()
  local quad = Cache.getQuad(x, y, width, height, backdropWidth, backdropHeight)
  love.graphics.draw(backdropCanvas, quad, 0, 0)

  love.graphics.setShader(self.shader)

  for i = 1, passes do
    love.graphics.setCanvas(canvas2)
    love.graphics.clear()
    self.shader:send("direction", { 1 / width, 0 })
    love.graphics.draw(canvas1, 0, 0)

    love.graphics.setCanvas(canvas1)
    love.graphics.clear()
    self.shader:send("direction", { 0, 1 / height })
    love.graphics.draw(canvas2, 0, 0)
  end

  love.graphics.setCanvas(prevCanvas)
  love.graphics.setShader()
  love.graphics.setBlendMode(prevBlendMode)
  love.graphics.draw(canvas1, x, y)

  love.graphics.setShader(prevShader)
  love.graphics.setColor(unpack(prevColor))

  Cache.releaseCanvas(canvas1)
  Cache.releaseCanvas(canvas2)
  Cache.releaseQuad(quad)
end

--- Get the current quality level
---@return number quality Quality level (1-10)
function Blur:getQuality()
  return self.quality
end

--- Get the number of shader taps
---@return number taps Number of shader taps
function Blur:getTaps()
  return self.taps
end

--- Clear all caches (call on window resize or memory cleanup)
function Blur.clearCache()
  Cache.clear()
end

--- Initialize Blur module with dependencies
---@param deps table Dependencies: { ErrorHandler = ErrorHandler? }
function Blur.init(deps)
  if type(deps) == "table" then
    Blur._ErrorHandler = deps.ErrorHandler
  end
end

Blur.Cache = Cache
Blur.ShaderBuilder = ShaderBuilder

return Blur
