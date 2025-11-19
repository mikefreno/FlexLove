-- ============================================================================
-- EASING FUNCTIONS
-- ============================================================================

--- Easing function type
---@alias EasingFunction fun(t: number): number

local Easing = {}

-- Linear
---@type EasingFunction
function Easing.linear(t)
  return t
end

-- Quadratic (Quad)
---@type EasingFunction
function Easing.easeInQuad(t)
  return t * t
end

---@type EasingFunction
function Easing.easeOutQuad(t)
  return t * (2 - t)
end

---@type EasingFunction
function Easing.easeInOutQuad(t)
  return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
end

-- Cubic
---@type EasingFunction
function Easing.easeInCubic(t)
  return t * t * t
end

---@type EasingFunction
function Easing.easeOutCubic(t)
  local t1 = t - 1
  return t1 * t1 * t1 + 1
end

---@type EasingFunction
function Easing.easeInOutCubic(t)
  return t < 0.5 and 4 * t * t * t or (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
end

-- Quartic (Quart)
---@type EasingFunction
function Easing.easeInQuart(t)
  return t * t * t * t
end

---@type EasingFunction
function Easing.easeOutQuart(t)
  local t1 = t - 1
  return 1 - t1 * t1 * t1 * t1
end

---@type EasingFunction
function Easing.easeInOutQuart(t)
  if t < 0.5 then
    return 8 * t * t * t * t
  else
    local t1 = t - 1
    return 1 - 8 * t1 * t1 * t1 * t1
  end
end

-- Quintic (Quint)
---@type EasingFunction
function Easing.easeInQuint(t)
  return t * t * t * t * t
end

---@type EasingFunction
function Easing.easeOutQuint(t)
  local t1 = t - 1
  return 1 + t1 * t1 * t1 * t1 * t1
end

---@type EasingFunction
function Easing.easeInOutQuint(t)
  if t < 0.5 then
    return 16 * t * t * t * t * t
  else
    local t1 = t - 1
    return 1 + 16 * t1 * t1 * t1 * t1 * t1
  end
end

-- Exponential (Expo)
---@type EasingFunction
function Easing.easeInExpo(t)
  return t == 0 and 0 or math.pow(2, 10 * (t - 1))
end

---@type EasingFunction
function Easing.easeOutExpo(t)
  return t == 1 and 1 or 1 - math.pow(2, -10 * t)
end

---@type EasingFunction
function Easing.easeInOutExpo(t)
  if t == 0 then
    return 0
  end
  if t == 1 then
    return 1
  end

  if t < 0.5 then
    return 0.5 * math.pow(2, 20 * t - 10)
  else
    return 1 - 0.5 * math.pow(2, -20 * t + 10)
  end
end

-- Sine
---@type EasingFunction
function Easing.easeInSine(t)
  return 1 - math.cos(t * math.pi / 2)
end

---@type EasingFunction
function Easing.easeOutSine(t)
  return math.sin(t * math.pi / 2)
end

---@type EasingFunction
function Easing.easeInOutSine(t)
  return -(math.cos(math.pi * t) - 1) / 2
end

-- Circular (Circ)
---@type EasingFunction
function Easing.easeInCirc(t)
  return 1 - math.sqrt(1 - t * t)
end

---@type EasingFunction
function Easing.easeOutCirc(t)
  local t1 = t - 1
  return math.sqrt(1 - t1 * t1)
end

---@type EasingFunction
function Easing.easeInOutCirc(t)
  if t < 0.5 then
    return (1 - math.sqrt(1 - 4 * t * t)) / 2
  else
    local t1 = -2 * t + 2
    return (math.sqrt(1 - t1 * t1) + 1) / 2
  end
end

-- Back (Overshoot)
---@type EasingFunction
function Easing.easeInBack(t)
  local c1 = 1.70158
  local c3 = c1 + 1
  return c3 * t * t * t - c1 * t * t
end

---@type EasingFunction
function Easing.easeOutBack(t)
  local c1 = 1.70158
  local c3 = c1 + 1
  local t1 = t - 1
  return 1 + c3 * t1 * t1 * t1 + c1 * t1 * t1
end

---@type EasingFunction
function Easing.easeInOutBack(t)
  local c1 = 1.70158
  local c2 = c1 * 1.525

  if t < 0.5 then
    return (2 * t * 2 * t * ((c2 + 1) * 2 * t - c2)) / 2
  else
    local t1 = 2 * t - 2
    return (t1 * t1 * ((c2 + 1) * t1 + c2) + 2) / 2
  end
end

-- Elastic (Spring)
---@type EasingFunction
function Easing.easeInElastic(t)
  if t == 0 then
    return 0
  end
  if t == 1 then
    return 1
  end

  local c4 = (2 * math.pi) / 3
  return -math.pow(2, 10 * t - 10) * math.sin((t * 10 - 10.75) * c4)
end

---@type EasingFunction
function Easing.easeOutElastic(t)
  if t == 0 then
    return 0
  end
  if t == 1 then
    return 1
  end

  local c4 = (2 * math.pi) / 3
  return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1
end

---@type EasingFunction
function Easing.easeInOutElastic(t)
  if t == 0 then
    return 0
  end
  if t == 1 then
    return 1
  end

  local c5 = (2 * math.pi) / 4.5

  if t < 0.5 then
    return -(math.pow(2, 20 * t - 10) * math.sin((20 * t - 11.125) * c5)) / 2
  else
    return (math.pow(2, -20 * t + 10) * math.sin((20 * t - 11.125) * c5)) / 2 + 1
  end
end

-- Bounce
---@type EasingFunction
function Easing.easeOutBounce(t)
  local n1 = 7.5625
  local d1 = 2.75

  if t < 1 / d1 then
    return n1 * t * t
  elseif t < 2 / d1 then
    local t1 = t - 1.5 / d1
    return n1 * t1 * t1 + 0.75
  elseif t < 2.5 / d1 then
    local t1 = t - 2.25 / d1
    return n1 * t1 * t1 + 0.9375
  else
    local t1 = t - 2.625 / d1
    return n1 * t1 * t1 + 0.984375
  end
end

---@type EasingFunction
function Easing.easeInBounce(t)
  return 1 - Easing.easeOutBounce(1 - t)
end

---@type EasingFunction
function Easing.easeInOutBounce(t)
  if t < 0.5 then
    return (1 - Easing.easeOutBounce(1 - 2 * t)) / 2
  else
    return (1 + Easing.easeOutBounce(2 * t - 1)) / 2
  end
end

-- Configurable Easing Factories
--- Create a custom back easing function with configurable overshoot
---@param overshoot number? Overshoot amount (default: 1.70158)
---@return EasingFunction
function Easing.back(overshoot)
  overshoot = overshoot or 1.70158
  local c3 = overshoot + 1

  return function(t)
    return c3 * t * t * t - overshoot * t * t
  end
end

--- Create a custom elastic easing function
---@param amplitude number? Amplitude (default: 1)
---@param period number? Period (default: 0.3)
---@return EasingFunction
function Easing.elastic(amplitude, period)
  amplitude = amplitude or 1
  period = period or 0.3

  return function(t)
    if t == 0 then
      return 0
    end
    if t == 1 then
      return 1
    end

    local s = period / 4
    local a = amplitude

    if a < 1 then
      a = 1
      s = period / 4
    else
      s = period / (2 * math.pi) * math.asin(1 / a)
    end

    return a * math.pow(2, -10 * t) * math.sin((t - s) * (2 * math.pi) / period) + 1
  end
end

--- Get list of all available easing function names
---@return string[] names Array of easing function names
function Easing.list()
  return {
    "linear",
    "easeInQuad",
    "easeOutQuad",
    "easeInOutQuad",
    "easeInCubic",
    "easeOutCubic",
    "easeInOutCubic",
    "easeInQuart",
    "easeOutQuart",
    "easeInOutQuart",
    "easeInQuint",
    "easeOutQuint",
    "easeInOutQuint",
    "easeInExpo",
    "easeOutExpo",
    "easeInOutExpo",
    "easeInSine",
    "easeOutSine",
    "easeInOutSine",
    "easeInCirc",
    "easeOutCirc",
    "easeInOutCirc",
    "easeInBack",
    "easeOutBack",
    "easeInOutBack",
    "easeInElastic",
    "easeOutElastic",
    "easeInOutElastic",
    "easeInBounce",
    "easeOutBounce",
    "easeInOutBounce",
  }
end

--- Get an easing function by name
---@param name string Easing function name
---@return EasingFunction? easing The easing function, or nil if not found
function Easing.get(name)
  return Easing[name]
end

-- ============================================================================
-- TRANSFORM
-- ============================================================================

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
    t = 0
  elseif t == math.huge then
    t = 1
  elseif t == -math.huge then
    t = 0
  else
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

-- ============================================================================
-- ANIMATION
-- ============================================================================

---@class Keyframe
---@field at number Normalized time position (0-1)
---@field values table Property values at this keyframe
---@field easing string|EasingFunction? Easing to use between this and next keyframe

---@class AnimationProps
---@field duration number Duration in seconds
---@field start table Starting values (can contain: width, height, opacity, x, y, gap, imageOpacity, backgroundColor, borderColor, textColor, padding, margin, cornerRadius, etc.)
---@field final table Final values (same properties as start)
---@field easing string? Easing function name (default: "linear")
---@field keyframes Keyframe[]? Array of keyframes for complex animations
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
---@field keyframes Keyframe[]? Array of keyframes for complex animations
---@field transform table? Additional transform properties
---@field transition table? Transition properties
---@field _cachedResult table Cached interpolation result
---@field _resultDirty boolean Whether cached result needs recalculation
---@field _Color table? Reference to Color module (for lerp)
local Animation = {}
Animation.__index = Animation

--- Build smooth, timed transitions between visual states to create polished, professional UIs
--- Use this to animate position, size, opacity, colors, and other properties with customizable easing
---@param props AnimationProps Animation properties
---@return Animation animation The new animation instance
function Animation.new(props)
  -- Validate input
  if type(props) ~= "table" then
    Animation._ErrorHandler.warn("Animation", "Animation.new() requires a table argument. Using default values.")
    props = { duration = 1, start = {}, final = {} }
  end

  if type(props.duration) ~= "number" or props.duration <= 0 then
    Animation._ErrorHandler.warn("Animation", "Animation duration must be a positive number. Using 1 second.")
    props.duration = 1
  end

  if type(props.start) ~= "table" then
    Animation._ErrorHandler.warn("Animation", "Animation start must be a table. Using empty table.")
    props.start = {}
  end

  if type(props.final) ~= "table" then
    Animation._ErrorHandler.warn("Animation", "Animation final must be a table. Using empty table.")
    props.final = {}
  end

  local self = setmetatable({}, Animation)
  self.duration = props.duration
  self.start = props.start
  self.final = props.final
  self.keyframes = props.keyframes
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
  self._state = "pending"

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

--- Advance the animation timeline and calculate interpolated values for the current frame
--- Call this each frame to progress the animation; returns true when complete for cleanup
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

  -- Handle delay
  if self._delay and self._delayElapsed then
    if self._delayElapsed < self._delay then
      self._delayElapsed = self._delayElapsed + dt
      return false
    end
  end

  -- Call onStart on first update
  if not self._hasStarted then
    self._hasStarted = true
    self._state = "playing"
    if self.onStart and type(self.onStart) == "function" then
      local success, err = pcall(self.onStart, self, element)
      if not success then
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
      self._resultDirty = true

      -- Handle repeat and yoyo
      if self._repeatCount then
        self._repeatCurrent = (self._repeatCurrent or 0) + 1

        if self._repeatCount == 0 or self._repeatCurrent < self._repeatCount then
          if self._yoyo then
            self._reversed = not self._reversed
            if self._reversed then
              self.elapsed = self.duration
            else
              self.elapsed = 0
            end
          else
            self.elapsed = 0
          end
          return false
        end
      end

      -- Animation truly completed
      self._state = "completed"
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
  local CM = ColorModule or Color or Animation._ColorModule

  if not CM or not CM.parse or not CM.lerp then
    if Animation._ErrorHandler then
      Animation._ErrorHandler.warn("Animation", "Color module not properly initialized. Cannot interpolate colors.")
    end
    return startColor
  end

  local colorA = CM.parse(startColor)
  local colorB = CM.parse(finalColor)

  return CM.lerp(colorA, colorB, easedT)
end

--- Helper function to interpolate table values (padding, margin, cornerRadius)
---@param startTable table Starting table
---@param finalTable table Final table
---@param easedT number Eased time (0-1)
---@return table interpolated Interpolated table
local function lerpTable(startTable, finalTable, easedT)
  local result = {}

  local keys = {}
  for k in pairs(startTable) do
    keys[k] = true
  end
  for k in pairs(finalTable) do
    keys[k] = true
  end

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

--- Find the two keyframes surrounding the current progress
---@param progress number Current animation progress (0-1)
---@return Keyframe prevFrame The keyframe before current progress
---@return Keyframe nextFrame The keyframe after current progress
function Animation:findKeyframes(progress)
  if not self.keyframes or #self.keyframes < 2 then
    return nil, nil
  end

  local prevFrame = self.keyframes[1]
  local nextFrame = self.keyframes[#self.keyframes]

  for i = 1, #self.keyframes - 1 do
    if progress >= self.keyframes[i].at and progress <= self.keyframes[i + 1].at then
      prevFrame = self.keyframes[i]
      nextFrame = self.keyframes[i + 1]
      break
    end
  end

  return prevFrame, nextFrame
end

--- Interpolate between two keyframes
---@param prevFrame Keyframe Starting keyframe
---@param nextFrame Keyframe Ending keyframe
---@param easedT number Eased time (0-1) for interpolation
---@return table result Interpolated values
function Animation:lerpKeyframes(prevFrame, nextFrame, easedT)
  local result = {}

  local keys = {}
  for k in pairs(prevFrame.values) do
    keys[k] = true
  end
  for k in pairs(nextFrame.values) do
    keys[k] = true
  end

  local numericProperties = {
    "width",
    "height",
    "opacity",
    "x",
    "y",
    "gap",
    "imageOpacity",
    "scrollbarWidth",
    "borderWidth",
    "fontSize",
    "lineHeight",
  }

  local colorProperties = {
    "backgroundColor",
    "borderColor",
    "textColor",
    "scrollbarColor",
    "scrollbarBackgroundColor",
    "imageTint",
  }

  local tableProperties = {
    "padding",
    "margin",
    "cornerRadius",
  }

  local numericSet = {}
  for _, prop in ipairs(numericProperties) do
    numericSet[prop] = true
  end

  local colorSet = {}
  for _, prop in ipairs(colorProperties) do
    colorSet[prop] = true
  end

  local tableSet = {}
  for _, prop in ipairs(tableProperties) do
    tableSet[prop] = true
  end

  for key in pairs(keys) do
    local startVal = prevFrame.values[key]
    local finalVal = nextFrame.values[key]

    if numericSet[key] and type(startVal) == "number" and type(finalVal) == "number" then
      result[key] = lerpNumber(startVal, finalVal, easedT)
    elseif colorSet[key] and (self._Color or Animation._ColorModule) then
      if startVal ~= nil and finalVal ~= nil then
        result[key] = lerpColor(startVal, finalVal, easedT, self._Color or Animation._ColorModule)
      end
    elseif tableSet[key] and type(startVal) == "table" and type(finalVal) == "table" then
      result[key] = lerpTable(startVal, finalVal, easedT)
    elseif type(startVal) == type(finalVal) then
      if type(startVal) == "number" then
        result[key] = lerpNumber(startVal, finalVal, easedT)
      else
        result[key] = finalVal
      end
    end
  end

  return result
end

--- Calculate the current animated values between start and end states based on elapsed time
--- Use this to get the interpolated properties to apply to your element
---@return table result Interpolated values {width?, height?, opacity?, x?, y?, backgroundColor?, ...}
function Animation:interpolate()
  -- Return cached result if not dirty
  if not self._resultDirty then
    return self._cachedResult
  end

  local t = math.min(self.elapsed / self.duration, 1)

  -- Handle keyframe animations
  if self.keyframes and type(self.keyframes) == "table" and #self.keyframes >= 2 then
    local prevFrame, nextFrame = self:findKeyframes(t)

    if prevFrame and nextFrame then
      local localProgress = 0
      if nextFrame.at > prevFrame.at then
        localProgress = (t - prevFrame.at) / (nextFrame.at - prevFrame.at)
      end

      local easingFn = Easing.linear
      if prevFrame.easing then
        if type(prevFrame.easing) == "string" then
          easingFn = Easing[prevFrame.easing] or Easing.linear
        elseif type(prevFrame.easing) == "function" then
          easingFn = prevFrame.easing
        end
      end

      local success, easedT = pcall(easingFn, localProgress)
      if not success or type(easedT) ~= "number" or easedT ~= easedT or easedT == math.huge or easedT == -math.huge then
        easedT = localProgress
      end

      local keyframeResult = self:lerpKeyframes(prevFrame, nextFrame, easedT)

      local result = self._cachedResult
      for k in pairs(result) do
        result[k] = nil
      end
      for k, v in pairs(keyframeResult) do
        result[k] = v
      end

      self._resultDirty = false
      return result
    end
  end

  -- Standard interpolation (non-keyframe)
  local success, easedT = pcall(self.easing, t)
  if not success or type(easedT) ~= "number" or easedT ~= easedT or easedT == math.huge or easedT == -math.huge then
    easedT = t
  end

  local result = self._cachedResult

  for k in pairs(result) do
    result[k] = nil
  end

  local numericProperties = {
    "width",
    "height",
    "opacity",
    "x",
    "y",
    "gap",
    "imageOpacity",
    "scrollbarWidth",
    "borderWidth",
    "fontSize",
    "lineHeight",
  }

  local colorProperties = {
    "backgroundColor",
    "borderColor",
    "textColor",
    "scrollbarColor",
    "scrollbarBackgroundColor",
    "imageTint",
  }

  local tableProperties = {
    "padding",
    "margin",
    "cornerRadius",
  }

  for _, prop in ipairs(numericProperties) do
    local startVal = self.start[prop]
    local finalVal = self.final[prop]

    if type(startVal) == "number" and type(finalVal) == "number" then
      result[prop] = lerpNumber(startVal, finalVal, easedT)
    end
  end

  local ColorModule = self._Color or Animation._ColorModule
  if ColorModule then
    for _, prop in ipairs(colorProperties) do
      local startVal = self.start[prop]
      local finalVal = self.final[prop]

      if startVal ~= nil and finalVal ~= nil then
        result[prop] = lerpColor(startVal, finalVal, easedT, ColorModule)
      end
    end
  end

  for _, prop in ipairs(tableProperties) do
    local startVal = self.start[prop]
    local finalVal = self.final[prop]

    if type(startVal) == "table" and type(finalVal) == "table" then
      result[prop] = lerpTable(startVal, finalVal, easedT)
    end
  end

  if self._Transform and self.start.transform and self.final.transform then
    result.transform = self._Transform.lerp(self.start.transform, self.final.transform, easedT)
  end

  if self.transform and type(self.transform) == "table" then
    for key, value in pairs(self.transform) do
      result[key] = value
    end
  end

  self._resultDirty = false
  return result
end

--- Attach this animation to an element so it automatically updates and applies changes
--- Use this for hands-off animation that integrates with FlexLove's rendering system
---@param element Element The element to apply animation to
function Animation:apply(element)
  if not element or type(element) ~= "table" then
    Animation._ErrorHandler.warn("Animation", "Cannot apply animation to nil or non-table element. Animation not applied.")
    return
  end
  element.animation = self
end

--- Temporarily halt the animation without losing progress
--- Use this to freeze animations during pause menus or cutscenes
function Animation:pause()
  if self._state == "playing" or self._state == "pending" then
    self._paused = true
    self._state = "paused"
  end
end

--- Continue a paused animation from where it left off
--- Use this to unpause animations when returning from pause menus
function Animation:resume()
  if self._state == "paused" then
    self._paused = false
    self._state = "playing"
  end
end

--- Query pause state to conditionally handle animation logic
--- Use this to sync UI behavior with animation state
---@return boolean paused
function Animation:isPaused()
  return self._paused
end

--- Flip the animation to play backwards, creating smooth transitions in both directions
--- Use this for hover effects that reverse on mouse-out or toggleable UI elements
function Animation:reverse()
  self._reversed = not self._reversed
end

--- Determine current playback direction for conditional animation logic
--- Use this to track which direction the animation is playing
---@return boolean reversed
function Animation:isReversed()
  return self._reversed
end

--- Control animation tempo for slow-motion or fast-forward effects
--- Use this for bullet-time, game speed multipliers, or debugging
---@param speed number Speed multiplier (1.0 = normal, 2.0 = double speed, 0.5 = half speed)
function Animation:setSpeed(speed)
  if type(speed) == "number" and speed > 0 then
    self._speed = speed
  end
end

--- Check current playback speed for debugging or UI display
--- Use this to show animation speed in dev tools
---@return number speed Current speed multiplier
function Animation:getSpeed()
  return self._speed
end

--- Jump to any point in the animation timeline for previewing or state restoration
--- Use this to skip ahead, rewind, or restore saved animation states
---@param time number Time in seconds (clamped to 0-duration)
function Animation:seek(time)
  if type(time) == "number" then
    self.elapsed = math.max(0, math.min(time, self.duration))
    self._resultDirty = true
  end
end

--- Query animation lifecycle state for conditional logic and debugging
--- Use this to determine if cleanup is needed or to prevent duplicate animations
---@return string state Current state: "pending", "playing", "paused", "completed", "cancelled"
function Animation:getState()
  return self._state
end

--- Stop the animation immediately without completing, triggering the onCancel callback
--- Use this to abort animations when UI elements are removed or user cancels an action
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

--- Return the animation to the beginning for replay
--- Use this to reuse animation instances without recreating them
function Animation:reset()
  self.elapsed = 0
  self._hasStarted = false
  self._paused = false
  self._state = "pending"
  self._resultDirty = true
end

--- Get normalized animation progress for progress bars or synchronized effects
--- Use this to drive secondary animations or display completion percentage
---@return number progress Progress from 0 to 1
function Animation:getProgress()
  return math.min(self.elapsed / self.duration, 1)
end

--- Create sequential animation flows that play one after another
--- Use this to build complex multi-step animations like slide-in-then-fade
---@param nextAnimation Animation|function Animation instance or factory function that returns an animation
---@return Animation nextAnimation The chained animation (for further chaining)
function Animation:chain(nextAnimation)
  if type(nextAnimation) == "function" then
    self._nextFactory = nextAnimation
    return self
  elseif type(nextAnimation) == "table" then
    self._next = nextAnimation
    return nextAnimation
  else
    Animation._ErrorHandler.warn("Animation", "chain() requires an Animation or function. Chaining not applied.")
    return self
  end
end

--- Introduce a wait period before animation begins for staggered effects
--- Use this to create cascading animations or timed sequences
---@param seconds number Delay duration in seconds
---@return Animation self For chaining
function Animation:delay(seconds)
  if type(seconds) ~= "number" or seconds < 0 then
    Animation._ErrorHandler.warn("Animation", "delay() requires a non-negative number. Using 0.")
    seconds = 0
  end
  self._delay = seconds
  self._delayElapsed = 0
  return self
end

--- Loop the animation for pulsing effects, loading indicators, or continuous motion
--- Use this for idle animations and attention-grabbing elements
---@param count number Number of times to repeat (0 = infinite loop)
---@return Animation self For chaining
function Animation:repeatCount(count)
  if type(count) ~= "number" or count < 0 then
    Animation._ErrorHandler.warn("Animation", "repeatCount() requires a non-negative number. Using 0.")
    count = 0
  end
  self._repeatCount = count
  self._repeatCurrent = 0
  return self
end

--- Make repeating animations play forwards then backwards for smooth oscillation
--- Use this for breathing effects, pulsing highlights, or pendulum motions
---@param enabled boolean? Enable yoyo mode (default: true)
---@return Animation self For chaining
function Animation:yoyo(enabled)
  if enabled == nil then
    enabled = true
  end
  self._yoyo = enabled
  return self
end

--- Quickly create fade in/out effects without manually specifying start/end states
--- Use this convenience method for common opacity transitions in tooltips, notifications, and overlays
---@param duration number Duration in seconds
---@param fromOpacity number Starting opacity (0-1)
---@param toOpacity number Ending opacity (0-1)
---@param easing string? Easing function name (default: "linear")
---@return Animation animation The fade animation
function Animation.fade(duration, fromOpacity, toOpacity, easing)
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

--- Quickly create grow/shrink effects without manually specifying dimensions
--- Use this convenience method for bounce effects, pop-ups, and attention animations
---@param duration number Duration in seconds
---@param fromScale {width:number,height:number} Starting scale
---@param toScale {width:number,height:number} Ending scale
---@param easing string? Easing function name (default: "linear")
---@return Animation animation The scale animation
function Animation.scale(duration, fromScale, toScale, easing)
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

--- Create a keyframe-based animation with multiple waypoints and per-keyframe easing
--- Use this for complex multi-step animations like bounce-in effects or CSS-style @keyframes
---@param props {duration:number, keyframes:Keyframe[], onStart:function?, onUpdate:function?, onComplete:function?, onCancel:function?} Animation properties
---@return Animation animation The keyframe animation
function Animation.keyframes(props)
  if type(props) ~= "table" then
    Animation._ErrorHandler.warn("Animation", "Animation.keyframes() requires a table argument. Using default values.")
    props = { duration = 1, keyframes = {} }
  end

  if type(props.duration) ~= "number" or props.duration <= 0 then
    Animation._ErrorHandler.warn("Animation", "Keyframe animation duration must be a positive number. Using 1 second.")
    props.duration = 1
  end

  if type(props.keyframes) ~= "table" or #props.keyframes < 2 then
    Animation._ErrorHandler.warn("Animation", "Keyframe animation requires at least 2 keyframes. Using empty animation.")
    props.keyframes = {
      { at = 0, values = {} },
      { at = 1, values = {} },
    }
  end

  local sortedKeyframes = {}
  for i, kf in ipairs(props.keyframes) do
    if type(kf) == "table" and type(kf.at) == "number" and type(kf.values) == "table" then
      table.insert(sortedKeyframes, kf)
    end
  end

  table.sort(sortedKeyframes, function(a, b)
    return a.at < b.at
  end)

  if #sortedKeyframes > 0 then
    if sortedKeyframes[1].at > 0 then
      table.insert(sortedKeyframes, 1, { at = 0, values = sortedKeyframes[1].values })
    end
    if sortedKeyframes[#sortedKeyframes].at < 1 then
      table.insert(sortedKeyframes, { at = 1, values = sortedKeyframes[#sortedKeyframes].values })
    end
  end

  return Animation.new({
    duration = props.duration,
    start = {},
    final = {},
    keyframes = sortedKeyframes,
    onStart = props.onStart,
    onUpdate = props.onUpdate,
    onComplete = props.onComplete,
    onCancel = props.onCancel,
  })
end

--- Initialize dependencies
---@param deps table Dependencies: { ErrorHandler = ErrorHandler, Easing = Easing, Color = Color? }
function Animation.init(deps)
  if type(deps) == "table" then
    Animation._ErrorHandler = deps.ErrorHandler
    Animation._Easing = deps.Easing
    Animation._ColorModule = deps.Color
    Animation._Transform = Transform
  end
end

-- ============================================================================
-- ANIMATION GROUP
-- ============================================================================

---@class AnimationGroup
local AnimationGroup = {}
AnimationGroup.__index = AnimationGroup

local ErrorHandler = nil

---@class AnimationGroupProps
---@field animations table Array of Animation instances
---@field mode string? "parallel", "sequence", or "stagger" (default: "parallel")
---@field stagger number? Stagger delay in seconds (for stagger mode, default: 0.1)
---@field onComplete function? Called when all animations complete: (group)
---@field onStart function? Called when group starts: (group)

--- Coordinate multiple animations to play together, in sequence, or staggered for complex choreographed effects
--- Use this to synchronize related UI changes like simultaneous fades or sequential reveals
---@param props AnimationGroupProps
---@return AnimationGroup group
function AnimationGroup.new(props)
  if type(props) ~= "table" then
    ErrorHandler.warn("AnimationGroup", "AnimationGroup.new() requires a table argument. Using default values.")
    props = { animations = {} }
  end

  if type(props.animations) ~= "table" or #props.animations == 0 then
    ErrorHandler.warn("AnimationGroup", "AnimationGroup requires at least one animation. Creating empty group.")
    props.animations = {}
  end

  local self = setmetatable({}, AnimationGroup)

  self.animations = props.animations
  self.mode = props.mode or "parallel"
  self.stagger = props.stagger or 0.1
  self.onComplete = props.onComplete
  self.onStart = props.onStart

  if self.mode ~= "parallel" and self.mode ~= "sequence" and self.mode ~= "stagger" then
    ErrorHandler.warn("AnimationGroup", string.format("Invalid mode: %s. Using 'parallel'.", tostring(self.mode)))
    self.mode = "parallel"
  end

  self._currentIndex = 1
  self._staggerElapsed = 0
  self._startedAnimations = {}
  self._hasStarted = false
  self._paused = false
  self._state = "ready"

  return self
end

--- Update all animations in parallel
---@param dt number Delta time
---@param element table? Optional element reference for callbacks
---@return boolean finished True if all animations complete
function AnimationGroup:_updateParallel(dt, element)
  local allFinished = true

  for i, anim in ipairs(self.animations) do
    local isCompleted = false
    if type(anim.getState) == "function" then
      isCompleted = anim:getState() == "completed"
    elseif anim._state then
      isCompleted = anim._state == "completed"
    end

    if not isCompleted then
      local finished = anim:update(dt, element)
      if not finished then
        allFinished = false
      end
    end
  end

  return allFinished
end

--- Update animations in sequence (one after another)
---@param dt number Delta time
---@param element table? Optional element reference for callbacks
---@return boolean finished True if all animations complete
function AnimationGroup:_updateSequence(dt, element)
  if self._currentIndex > #self.animations then
    return true
  end

  local currentAnim = self.animations[self._currentIndex]
  local finished = currentAnim:update(dt, element)

  if finished then
    self._currentIndex = self._currentIndex + 1
    if self._currentIndex > #self.animations then
      return true
    end
  end

  return false
end

--- Update animations with stagger delay
---@param dt number Delta time
---@param element table? Optional element reference for callbacks
---@return boolean finished True if all animations complete
function AnimationGroup:_updateStagger(dt, element)
  self._staggerElapsed = self._staggerElapsed + dt

  for i, anim in ipairs(self.animations) do
    local startTime = (i - 1) * self.stagger

    if self._staggerElapsed >= startTime and not self._startedAnimations[i] then
      self._startedAnimations[i] = true
    end
  end

  local allFinished = true
  for i, anim in ipairs(self.animations) do
    if self._startedAnimations[i] then
      local isCompleted = false
      if type(anim.getState) == "function" then
        isCompleted = anim:getState() == "completed"
      elseif anim._state then
        isCompleted = anim._state == "completed"
      end

      if not isCompleted then
        local finished = anim:update(dt, element)
        if not finished then
          allFinished = false
        end
      end
    else
      allFinished = false
    end
  end

  return allFinished
end

--- Advance all animations in the group according to their coordination mode
--- Call this each frame to progress parallel, sequential, or staggered animations
---@param dt number Delta time
---@param element table? Optional element reference for callbacks
---@return boolean finished True if group is complete
function AnimationGroup:update(dt, element)
  if type(dt) ~= "number" or dt < 0 or dt ~= dt or dt == math.huge then
    dt = 0
  end

  if self._paused or self._state == "completed" or self._state == "cancelled" then
    return self._state == "completed"
  end

  if not self._hasStarted then
    self._hasStarted = true
    self._state = "playing"
    if self.onStart and type(self.onStart) == "function" then
      local success, err = pcall(self.onStart, self)
      if not success then
        print(string.format("[AnimationGroup] onStart error: %s", tostring(err)))
      end
    end
  end

  local finished = false

  if self.mode == "parallel" then
    finished = self:_updateParallel(dt, element)
  elseif self.mode == "sequence" then
    finished = self:_updateSequence(dt, element)
  elseif self.mode == "stagger" then
    finished = self:_updateStagger(dt, element)
  end

  if finished then
    self._state = "completed"
    if self.onComplete and type(self.onComplete) == "function" then
      local success, err = pcall(self.onComplete, self)
      if not success then
        print(string.format("[AnimationGroup] onComplete error: %s", tostring(err)))
      end
    end
  end

  return finished
end

--- Freeze the entire animation sequence in unison
--- Use this to pause complex multi-part animations during game pauses
function AnimationGroup:pause()
  self._paused = true
  for _, anim in ipairs(self.animations) do
    if type(anim.pause) == "function" then
      anim:pause()
    end
  end
end

--- Continue all paused animations simultaneously from their paused states
--- Use this to unpause coordinated animation sequences
function AnimationGroup:resume()
  self._paused = false
  for _, anim in ipairs(self.animations) do
    if type(anim.resume) == "function" then
      anim:resume()
    end
  end
end

--- Determine if the entire group is currently paused
--- Use this to sync other game logic with animation group state
---@return boolean paused
function AnimationGroup:isPaused()
  return self._paused
end

--- Flip all animations to play backwards together
--- Use this to reverse complex transitions like panel opens/closes
function AnimationGroup:reverse()
  for _, anim in ipairs(self.animations) do
    if type(anim.reverse) == "function" then
      anim:reverse()
    end
  end
end

--- Control the tempo of all animations simultaneously
--- Use this for slow-motion effects or debugging without adjusting individual animations
---@param speed number Speed multiplier
function AnimationGroup:setSpeed(speed)
  for _, anim in ipairs(self.animations) do
    if type(anim.setSpeed) == "function" then
      anim:setSpeed(speed)
    end
  end
end

--- Abort all animations in the group immediately without completion
--- Use this when UI is dismissed mid-animation or transitions are interrupted
---@param element table? Optional element reference for callbacks
function AnimationGroup:cancel(element)
  if self._state ~= "cancelled" and self._state ~= "completed" then
    self._state = "cancelled"
    for _, anim in ipairs(self.animations) do
      if type(anim.cancel) == "function" then
        anim:cancel(element)
      end
    end
  end
end

--- Restart the entire group from the beginning for reuse
--- Use this to replay animation sequences without recreating objects
function AnimationGroup:reset()
  self._currentIndex = 1
  self._staggerElapsed = 0
  self._startedAnimations = {}
  self._hasStarted = false
  self._paused = false
  self._state = "ready"

  for _, anim in ipairs(self.animations) do
    if type(anim.reset) == "function" then
      anim:reset()
    end
  end
end

--- Check the overall lifecycle state of the animation group
--- Use this to conditionally trigger follow-up actions or cleanup
---@return string state "ready", "playing", "completed", "cancelled"
function AnimationGroup:getState()
  return self._state
end

--- Calculate completion percentage across all animations in the group
--- Use this for progress bars or to synchronize other effects with the group
---@return number progress
function AnimationGroup:getProgress()
  if #self.animations == 0 then
    return 1
  end

  if self.mode == "sequence" then
    local completedAnims = self._currentIndex - 1
    local currentProgress = 0

    if self._currentIndex <= #self.animations then
      local currentAnim = self.animations[self._currentIndex]
      if type(currentAnim.getProgress) == "function" then
        currentProgress = currentAnim:getProgress()
      end
    end

    return (completedAnims + currentProgress) / #self.animations
  else
    local totalProgress = 0
    for _, anim in ipairs(self.animations) do
      if type(anim.getProgress) == "function" then
        totalProgress = totalProgress + anim:getProgress()
      else
        totalProgress = totalProgress + 1
      end
    end
    return totalProgress / #self.animations
  end
end

--- Attach this group to an element for automatic updates and integration
--- Use this for hands-off animation management within FlexLove's system
---@param element Element The element to apply animations to
function AnimationGroup:apply(element)
  if not element or type(element) ~= "table" then
    ErrorHandler.warn("AnimationGroup", "Cannot apply animation group to nil or non-table element. Group not applied.")
    return
  end
  element.animationGroup = self
end

--- Initialize dependencies
---@param deps table Dependencies: { ErrorHandler = ErrorHandler }
function AnimationGroup.init(deps)
  if type(deps) == "table" then
    ErrorHandler = deps.ErrorHandler
  end
end

Animation.Easing = Easing
Animation.Transform = Transform
Animation.AnimationGroup = AnimationGroup

return Animation
