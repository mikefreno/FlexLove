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
---@field start table Starting values (can contain: width, height, opacity, x, y, gap, imageOpacity, backgroundColor, borderColor, textColor, padding, margin, cornerRadius, etc.)
---@field final table Final values (same properties as start)
---@field easing string? Easing function name (default: "linear")
---@field transform table? Additional transform properties
---@field transition table? Transition properties
---@field onStart function? Called when animation starts: (animation, element)
---@field onUpdate function? Called each frame: (animation, element, progress)
---@field onComplete function? Called when animation completes: (animation, element)
---@field onCancel function? Called when animation is cancelled: (animation, element)

---@class Animation
---@field duration number Duration in seconds
---@field start table Starting values
---@field final table Final values
---@field elapsed number Elapsed time in seconds
---@field easing EasingFunction Easing function
---@field transform table? Additional transform properties
---@field transition table? Transition properties
---@field _cachedResult table Cached interpolation result
---@field _resultDirty boolean Whether cached result needs recalculation
---@field _Color table? Reference to Color module (for lerp)
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

  -- Lifecycle callbacks
  self.onStart = props.onStart
  self.onUpdate = props.onUpdate
  self.onComplete = props.onComplete
  self.onCancel = props.onCancel
  self._hasStarted = false

  -- Control state
  self._paused = false
  self._reversed = false
  self._speed = 1.0
  self._state = "pending" -- "pending", "playing", "paused", "completed", "cancelled"

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
---@param element table? Optional element reference for callbacks
---@return boolean completed True if animation is complete
function Animation:update(dt, element)
  -- Sanitize dt
  if type(dt) ~= "number" or dt < 0 or dt ~= dt or dt == math.huge then
    dt = 0
  end
  
  -- Don't update if paused
  if self._paused then
    return false
  end
  
  -- Call onStart on first update
  if not self._hasStarted then
    self._hasStarted = true
    self._state = "playing"
    if self.onStart and type(self.onStart) == "function" then
      local success, err = pcall(self.onStart, self, element)
      if not success then
        -- Log error but don't crash
        print(string.format("[Animation] onStart error: %s", tostring(err)))
      end
    end
  end
  
  -- Apply speed multiplier
  dt = dt * self._speed
  
  -- Update elapsed time (reversed if needed)
  if self._reversed then
    self.elapsed = self.elapsed - dt
    if self.elapsed <= 0 then
      self.elapsed = 0
      self._state = "completed"
      self._resultDirty = true
      -- Call onComplete callback
      if self.onComplete and type(self.onComplete) == "function" then
        local success, err = pcall(self.onComplete, self, element)
        if not success then
          print(string.format("[Animation] onComplete error: %s", tostring(err)))
        end
      end
      return true
    end
  else
    self.elapsed = self.elapsed + dt
    if self.elapsed >= self.duration then
      self.elapsed = self.duration
      self._state = "completed"
      self._resultDirty = true
      -- Call onComplete callback
      if self.onComplete and type(self.onComplete) == "function" then
        local success, err = pcall(self.onComplete, self, element)
        if not success then
          print(string.format("[Animation] onComplete error: %s", tostring(err)))
        end
      end
      return true
    end
  end
  
  self._resultDirty = true
  
  -- Call onUpdate callback
  if self.onUpdate and type(self.onUpdate) == "function" then
    local progress = self.elapsed / self.duration
    local success, err = pcall(self.onUpdate, self, element, progress)
    if not success then
      print(string.format("[Animation] onUpdate error: %s", tostring(err)))
    end
  end
  
  return false
end

--- Helper function to interpolate numeric values
---@param startValue number Starting value
---@param finalValue number Final value
---@param easedT number Eased time (0-1)
---@return number interpolated Interpolated value
local function lerpNumber(startValue, finalValue, easedT)
  return startValue * (1 - easedT) + finalValue * easedT
end

--- Helper function to interpolate Color values
---@param startColor any Starting color (Color instance or parseable color)
---@param finalColor any Final color (Color instance or parseable color)
---@param easedT number Eased time (0-1)
---@param ColorModule table Color module reference
---@return any interpolated Interpolated Color instance
local function lerpColor(startColor, finalColor, easedT, ColorModule)
  if not ColorModule then
    return nil
  end
  
  -- Parse colors if needed
  local colorA = ColorModule.parse(startColor)
  local colorB = ColorModule.parse(finalColor)
  
  return ColorModule.lerp(colorA, colorB, easedT)
end

--- Helper function to interpolate table values (padding, margin, cornerRadius)
---@param startTable table Starting table
---@param finalTable table Final table
---@param easedT number Eased time (0-1)
---@return table interpolated Interpolated table
local function lerpTable(startTable, finalTable, easedT)
  local result = {}
  
  -- Iterate through all keys in both tables
  local keys = {}
  for k in pairs(startTable) do keys[k] = true end
  for k in pairs(finalTable) do keys[k] = true end
  
  for key in pairs(keys) do
    local startVal = startTable[key]
    local finalVal = finalTable[key]
    
    if type(startVal) == "number" and type(finalVal) == "number" then
      result[key] = lerpNumber(startVal, finalVal, easedT)
    elseif startVal ~= nil then
      result[key] = startVal
    else
      result[key] = finalVal
    end
  end
  
  return result
end

---Interpolate animation values at current time
---@return table result Interpolated values {width?, height?, opacity?, x?, y?, backgroundColor?, ...}
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
  
  -- Clear previous results
  for k in pairs(result) do
    result[k] = nil
  end
  
  -- Define properties that should be animated as numbers
  local numericProperties = {
    "width", "height", "opacity", "x", "y", 
    "gap", "imageOpacity", "scrollbarWidth",
    "borderWidth", "fontSize", "lineHeight"
  }
  
  -- Define properties that should be animated as Colors
  local colorProperties = {
    "backgroundColor", "borderColor", "textColor",
    "scrollbarColor", "scrollbarBackgroundColor", "imageTint"
  }
  
  -- Define properties that should be animated as tables
  local tableProperties = {
    "padding", "margin", "cornerRadius"
  }
  
  -- Interpolate numeric properties
  for _, prop in ipairs(numericProperties) do
    local startVal = self.start[prop]
    local finalVal = self.final[prop]
    
    if type(startVal) == "number" and type(finalVal) == "number" then
      result[prop] = lerpNumber(startVal, finalVal, easedT)
    end
  end
  
  -- Interpolate color properties (if Color module is available)
  if self._Color then
    for _, prop in ipairs(colorProperties) do
      local startVal = self.start[prop]
      local finalVal = self.final[prop]
      
      if startVal ~= nil and finalVal ~= nil then
        result[prop] = lerpColor(startVal, finalVal, easedT, self._Color)
      end
    end
  end
  
  -- Interpolate table properties
  for _, prop in ipairs(tableProperties) do
    local startVal = self.start[prop]
    local finalVal = self.final[prop]
    
    if type(startVal) == "table" and type(finalVal) == "table" then
      result[prop] = lerpTable(startVal, finalVal, easedT)
    end
  end

  -- Interpolate transform property (if Transform module is available)
  if self._Transform and self.start.transform and self.final.transform then
    result.transform = self._Transform.lerp(self.start.transform, self.final.transform, easedT)
  end

  -- Copy transform properties (legacy support)
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

--- Set Color module reference for color interpolation
---@param ColorModule table Color module
function Animation:setColorModule(ColorModule)
  self._Color = ColorModule
end

--- Set Transform module reference for transform interpolation
---@param TransformModule table Transform module
function Animation:setTransformModule(TransformModule)
  self._Transform = TransformModule
end

---Pause the animation
function Animation:pause()
  if self._state == "playing" or self._state == "pending" then
    self._paused = true
    self._state = "paused"
  end
end

---Resume the animation
function Animation:resume()
  if self._state == "paused" then
    self._paused = false
    self._state = "playing"
  end
end

---Check if animation is paused
---@return boolean paused
function Animation:isPaused()
  return self._paused
end

---Reverse the animation direction
function Animation:reverse()
  self._reversed = not self._reversed
end

---Check if animation is reversed
---@return boolean reversed
function Animation:isReversed()
  return self._reversed
end

---Set animation playback speed
---@param speed number Speed multiplier (1.0 = normal, 2.0 = double speed, 0.5 = half speed)
function Animation:setSpeed(speed)
  if type(speed) == "number" and speed > 0 then
    self._speed = speed
  end
end

---Get animation playback speed
---@return number speed Current speed multiplier
function Animation:getSpeed()
  return self._speed
end

---Seek to a specific time in the animation
---@param time number Time in seconds (clamped to 0-duration)
function Animation:seek(time)
  if type(time) == "number" then
    self.elapsed = math.max(0, math.min(time, self.duration))
    self._resultDirty = true
  end
end

---Get current animation state
---@return string state Current state: "pending", "playing", "paused", "completed", "cancelled"
function Animation:getState()
  return self._state
end

---Cancel the animation
---@param element table? Optional element reference for callback
function Animation:cancel(element)
  if self._state ~= "cancelled" and self._state ~= "completed" then
    self._state = "cancelled"
    if self.onCancel and type(self.onCancel) == "function" then
      local success, err = pcall(self.onCancel, self, element)
      if not success then
        print(string.format("[Animation] onCancel error: %s", tostring(err)))
      end
    end
  end
end

---Reset the animation to its initial state
function Animation:reset()
  self.elapsed = 0
  self._hasStarted = false
  self._paused = false
  self._state = "pending"
  self._resultDirty = true
end

---Get the current progress of the animation
---@return number progress Progress from 0 to 1
function Animation:getProgress()
  return math.min(self.elapsed / self.duration, 1)
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
