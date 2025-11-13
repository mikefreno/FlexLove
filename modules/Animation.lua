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
---@class Animation
---@field duration number
---@field start {width?:number, height?:number, opacity?:number}
---@field final {width?:number, height?:number, opacity?:number}
---@field elapsed number
---@field transform table?
---@field transition table?
local Animation = {}
Animation.__index = Animation

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
  self._resultDirty = true
  if self.elapsed >= self.duration then
    return true
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
  t = self.easing(t)
  local result = self._cachedResult -- Reuse existing table

  result.width = nil
  result.height = nil
  result.opacity = nil

  if self.start.width and self.final.width then
    result.width = self.start.width * (1 - t) + self.final.width * t
  end

  if self.start.height and self.final.height then
    result.height = self.start.height * (1 - t) + self.final.height * t
  end

  if self.start.opacity and self.final.opacity then
    result.opacity = self.start.opacity * (1 - t) + self.final.opacity * t
  end

  if self.transform then
    for key, value in pairs(self.transform) do
      result[key] = value
    end
  end

  self._resultDirty = false
  return result
end

---@param element Element
function Animation:apply(element)
  element.animation = self
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

return Animation
