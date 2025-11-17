--- Easing function type
---@alias EasingFunction fun(t: number): number

--- Easing functions for animations
---@type table<string, EasingFunction>
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
---@class AnimationProps
---@field duration number Duration in seconds
---@field start {width?:number, height?:number, opacity?:number} Starting values
---@field final {width?:number, height?:number, opacity?:number} Final values
---@field easing string? Easing function name (default: "linear")
---@field transform table? Additional transform properties
---@field transition table? Transition properties

---@class Animation
---@field duration number Duration in seconds
---@field start {width?:number, height?:number, opacity?:number} Starting values
---@field final {width?:number, height?:number, opacity?:number} Final values
---@field elapsed number Elapsed time in seconds
---@field easing EasingFunction Easing function
---@field transform table? Additional transform properties
---@field transition table? Transition properties
---@field _cachedResult table Cached interpolation result
---@field _resultDirty boolean Whether cached result needs recalculation
local Animation = {}
Animation.__index = Animation

---Create a new animation instance
---@param props AnimationProps Animation properties
---@return Animation animation The new animation instance
function Animation.new(props)
  -- Validate input
  if type(props) ~= "table" then
    error("[FlexLove.Animation] Animation.new() requires a table argument")
  end
  
  if type(props.duration) ~= "number" or props.duration <= 0 then
    error("[FlexLove.Animation] Animation duration must be a positive number")
  end
  
  if type(props.start) ~= "table" then
    error("[FlexLove.Animation] Animation start must be a table")
  end
  
  if type(props.final) ~= "table" then
    error("[FlexLove.Animation] Animation final must be a table")
  end

  local self = setmetatable({}, Animation)
  self.duration = props.duration
  self.start = props.start
  self.final = props.final
  self.transform = props.transform
  self.transition = props.transition
  self.elapsed = 0

  -- Validate and set easing function
  local easingName = props.easing or "linear"
  if type(easingName) == "string" then
    self.easing = Easing[easingName] or Easing.linear
  elseif type(easingName) == "function" then
    self.easing = easingName
  else
    self.easing = Easing.linear
  end

  -- Pre-allocate result table to avoid GC pressure
  self._cachedResult = {}
  self._resultDirty = true

  return self
end

---Update the animation with delta time
---@param dt number Delta time in seconds
---@return boolean completed True if animation is complete
function Animation:update(dt)
  -- Sanitize dt
  if type(dt) ~= "number" or dt < 0 or dt ~= dt or dt == math.huge then
    dt = 0
  end
  
  self.elapsed = self.elapsed + dt
  self._resultDirty = true
  if self.elapsed >= self.duration then
    return true
  else
    return false
  end
end

---Interpolate animation values at current time
---@return table result Interpolated values {width?, height?, opacity?, ...}
function Animation:interpolate()
  -- Return cached result if not dirty (avoids recalculation)
  if not self._resultDirty then
    return self._cachedResult
  end

  local t = math.min(self.elapsed / self.duration, 1)
  
  -- Apply easing function with protection
  local success, easedT = pcall(self.easing, t)
  if not success or type(easedT) ~= "number" or easedT ~= easedT or easedT == math.huge or easedT == -math.huge then
    easedT = t -- Fallback to linear if easing fails
  end
  
  local result = self._cachedResult -- Reuse existing table

  result.width = nil
  result.height = nil
  result.opacity = nil

  -- Interpolate width if both start and final are valid numbers
  if type(self.start.width) == "number" and type(self.final.width) == "number" then
    result.width = self.start.width * (1 - easedT) + self.final.width * easedT
  end

  -- Interpolate height if both start and final are valid numbers
  if type(self.start.height) == "number" and type(self.final.height) == "number" then
    result.height = self.start.height * (1 - easedT) + self.final.height * easedT
  end

  -- Interpolate opacity if both start and final are valid numbers
  if type(self.start.opacity) == "number" and type(self.final.opacity) == "number" then
    result.opacity = self.start.opacity * (1 - easedT) + self.final.opacity * easedT
  end

  -- Copy transform properties
  if self.transform and type(self.transform) == "table" then
    for key, value in pairs(self.transform) do
      result[key] = value
    end
  end

  self._resultDirty = false
  return result
end

---Apply this animation to an element
---@param element Element The element to apply animation to
function Animation:apply(element)
  if not element or type(element) ~= "table" then
    error("[FlexLove.Animation] Cannot apply animation to nil or non-table element")
  end
  element.animation = self
end

--- Create a simple fade animation
---@param duration number Duration in seconds
---@param fromOpacity number Starting opacity (0-1)
---@param toOpacity number Ending opacity (0-1)
---@param easing string? Easing function name (default: "linear")
---@return Animation animation The fade animation
function Animation.fade(duration, fromOpacity, toOpacity, easing)
  -- Sanitize inputs
  if type(duration) ~= "number" or duration <= 0 then
    duration = 1
  end
  if type(fromOpacity) ~= "number" then
    fromOpacity = 1
  end
  if type(toOpacity) ~= "number" then
    toOpacity = 0
  end
  
  return Animation.new({
    duration = duration,
    start = { opacity = fromOpacity },
    final = { opacity = toOpacity },
    easing = easing,
    transform = {},
    transition = {},
  })
end

--- Create a simple scale animation
---@param duration number Duration in seconds
---@param fromScale {width:number,height:number} Starting scale
---@param toScale {width:number,height:number} Ending scale
---@param easing string? Easing function name (default: "linear")
---@return Animation animation The scale animation
function Animation.scale(duration, fromScale, toScale, easing)
  -- Sanitize inputs
  if type(duration) ~= "number" or duration <= 0 then
    duration = 1
  end
  if type(fromScale) ~= "table" then
    fromScale = { width = 1, height = 1 }
  end
  if type(toScale) ~= "table" then
    toScale = { width = 1, height = 1 }
  end
  
  return Animation.new({
    duration = duration,
    start = { width = fromScale.width or 0, height = fromScale.height or 0 },
    final = { width = toScale.width or 0, height = toScale.height or 0 },
    easing = easing,
    transform = {},
    transition = {},
  })
end

return Animation
