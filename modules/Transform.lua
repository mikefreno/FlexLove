--- Transform module for 2D transformations (rotate, scale, translate, skew)
---@class Transform
---@field rotate number? Rotation in radians (default: 0)
---@field scaleX number? X-axis scale (default: 1)
---@field scaleY number? Y-axis scale (default: 1)
---@field translateX number? X translation in pixels (default: 0)
---@field translateY number? Y translation in pixels (default: 0)
---@field skewX number? X-axis skew in radians (default: 0)
---@field skewY number? Y-axis skew in radians (default: 0)
---@field originX number? Transform origin X (0-1, default: 0.5)
---@field originY number? Transform origin Y (0-1, default: 0.5)
local Transform = {}
Transform.__index = Transform

--- Create a new transform instance
---@param props TransformProps?
---@return Transform transform
function Transform.new(props)
  props = props or {}

  local self = setmetatable({}, Transform)

  self.rotate = props.rotate or 0
  self.scaleX = props.scaleX or 1
  self.scaleY = props.scaleY or 1
  self.translateX = props.translateX or 0
  self.translateY = props.translateY or 0
  self.skewX = props.skewX or 0
  self.skewY = props.skewY or 0
  self.originX = props.originX or 0.5
  self.originY = props.originY or 0.5

  return self
end

--- Apply transform to LÖVE graphics context
---@param transform Transform Transform instance
---@param x number Element x position
---@param y number Element y position
---@param width number Element width
---@param height number Element height
function Transform.apply(transform, x, y, width, height)
  if not transform then
    return
  end

  -- Calculate transform origin
  local ox = x + width * transform.originX
  local oy = y + height * transform.originY

  -- Apply transform in correct order: translate → rotate → scale → skew
  love.graphics.push()
  love.graphics.translate(ox, oy)

  if transform.rotate ~= 0 then
    love.graphics.rotate(transform.rotate)
  end

  if transform.scaleX ~= 1 or transform.scaleY ~= 1 then
    love.graphics.scale(transform.scaleX, transform.scaleY)
  end

  if transform.skewX ~= 0 or transform.skewY ~= 0 then
    love.graphics.shear(transform.skewX, transform.skewY)
  end

  love.graphics.translate(-ox, -oy)
  love.graphics.translate(transform.translateX, transform.translateY)
end

--- Remove transform from LÖVE graphics context
function Transform.unapply()
  love.graphics.pop()
end

--- Interpolate between two transforms
---@param from Transform Starting transform
---@param to Transform Ending transform
---@param t number Interpolation factor (0-1)
---@return Transform interpolated
function Transform.lerp(from, to, t)
  -- Sanitize inputs
  if type(from) ~= "table" then
    from = Transform.new()
  end
  if type(to) ~= "table" then
    to = Transform.new()
  end
  if type(t) ~= "number" or t ~= t then
    -- NaN or invalid type
    t = 0
  elseif t == math.huge then
    -- Positive infinity
    t = 1
  elseif t == -math.huge then
    -- Negative infinity
    t = 0
  else
    -- Clamp t to 0-1 range
    t = math.max(0, math.min(1, t))
  end

  return Transform.new({
    rotate = (from.rotate or 0) * (1 - t) + (to.rotate or 0) * t,
    scaleX = (from.scaleX or 1) * (1 - t) + (to.scaleX or 1) * t,
    scaleY = (from.scaleY or 1) * (1 - t) + (to.scaleY or 1) * t,
    translateX = (from.translateX or 0) * (1 - t) + (to.translateX or 0) * t,
    translateY = (from.translateY or 0) * (1 - t) + (to.translateY or 0) * t,
    skewX = (from.skewX or 0) * (1 - t) + (to.skewX or 0) * t,
    skewY = (from.skewY or 0) * (1 - t) + (to.skewY or 0) * t,
    originX = (from.originX or 0.5) * (1 - t) + (to.originX or 0.5) * t,
    originY = (from.originY or 0.5) * (1 - t) + (to.originY or 0.5) * t,
  })
end

--- Check if transform is identity (no transformation)
---@param transform Transform
---@return boolean isIdentity
function Transform.isIdentity(transform)
  if not transform then
    return true
  end

  return transform.rotate == 0
    and transform.scaleX == 1
    and transform.scaleY == 1
    and transform.translateX == 0
    and transform.translateY == 0
    and transform.skewX == 0
    and transform.skewY == 0
end

--- Clone a transform
---@param transform Transform
---@return Transform clone
function Transform.clone(transform)
  if not transform then
    return Transform.new()
  end

  return Transform.new({
    rotate = transform.rotate,
    scaleX = transform.scaleX,
    scaleY = transform.scaleY,
    translateX = transform.translateX,
    translateY = transform.translateY,
    skewX = transform.skewX,
    skewY = transform.skewY,
    originX = transform.originX,
    originY = transform.originY,
  })
end

return Transform
