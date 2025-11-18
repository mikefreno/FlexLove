--- Easing function type
---@alias EasingFunction fun(t: number): number

-- ErrorHandler dependency (injected via initializeErrorHandler)
local ErrorHandler = nil

-- Easing module for easing functions
local Easing = require("modules.Easing")
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
    ErrorHandler.warn("Animation", "Animation.new() requires a table argument. Using default values.")
    props = {duration = 1, start = {}, final = {}}
  end
  
  if type(props.duration) ~= "number" or props.duration <= 0 then
    ErrorHandler.warn("Animation", "Animation duration must be a positive number. Using 1 second.")
    props.duration = 1
  end
  
  if type(props.start) ~= "table" then
    ErrorHandler.warn("Animation", "Animation start must be a table. Using empty table.")
    props.start = {}
  end
  
  if type(props.final) ~= "table" then
    ErrorHandler.warn("Animation", "Animation final must be a table. Using empty table.")
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
      self._resultDirty = true
      
      -- Handle repeat and yoyo
      if self._repeatCount then
        self._repeatCurrent = (self._repeatCurrent or 0) + 1
        
        if self._repeatCount == 0 or self._repeatCurrent < self._repeatCount then
          -- Continue repeating
          if self._yoyo then
            -- Reverse direction for yoyo
            self._reversed = not self._reversed
            if self._reversed then
              self.elapsed = self.duration
            else
              self.elapsed = 0
            end
          else
            -- Reset to beginning
            self.elapsed = 0
          end
          return false
        end
      end
      
      -- Animation truly completed
      self._state = "completed"
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

--- Find the two keyframes surrounding the current progress
---@param progress number Current animation progress (0-1)
---@return Keyframe prevFrame The keyframe before current progress
---@return Keyframe nextFrame The keyframe after current progress
function Animation:findKeyframes(progress)
  if not self.keyframes or #self.keyframes < 2 then
    return nil, nil
  end
  
  -- Find surrounding keyframes
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
  
  -- Get all unique property keys
  local keys = {}
  for k in pairs(prevFrame.values) do keys[k] = true end
  for k in pairs(nextFrame.values) do keys[k] = true end
  
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
  
  -- Create lookup sets for faster property type checking
  local numericSet = {}
  for _, prop in ipairs(numericProperties) do numericSet[prop] = true end
  
  local colorSet = {}
  for _, prop in ipairs(colorProperties) do colorSet[prop] = true end
  
  local tableSet = {}
  for _, prop in ipairs(tableProperties) do tableSet[prop] = true end
  
  -- Interpolate each property
  for key in pairs(keys) do
    local startVal = prevFrame.values[key]
    local finalVal = nextFrame.values[key]
    
    if numericSet[key] and type(startVal) == "number" and type(finalVal) == "number" then
      result[key] = lerpNumber(startVal, finalVal, easedT)
    elseif colorSet[key] and self._Color then
      if startVal ~= nil and finalVal ~= nil then
        result[key] = lerpColor(startVal, finalVal, easedT, self._Color)
      end
    elseif tableSet[key] and type(startVal) == "table" and type(finalVal) == "table" then
      result[key] = lerpTable(startVal, finalVal, easedT)
    elseif type(startVal) == type(finalVal) then
      -- For unknown types, try numeric interpolation if they're numbers
      if type(startVal) == "number" then
        result[key] = lerpNumber(startVal, finalVal, easedT)
      else
        -- Otherwise use the final value
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
  -- Return cached result if not dirty (avoids recalculation)
  if not self._resultDirty then
    return self._cachedResult
  end

  local t = math.min(self.elapsed / self.duration, 1)
  
  -- Handle keyframe animations
  if self.keyframes and #self.keyframes >= 2 then
    local prevFrame, nextFrame = self:findKeyframes(t)
    
    if prevFrame and nextFrame then
      -- Calculate local progress between keyframes
      local localProgress = 0
      if nextFrame.at > prevFrame.at then
        localProgress = (t - prevFrame.at) / (nextFrame.at - prevFrame.at)
      end
      
      -- Apply per-keyframe easing
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
      
      -- Interpolate between keyframes
      local keyframeResult = self:lerpKeyframes(prevFrame, nextFrame, easedT)
      
      -- Copy to cached result
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

--- Attach this animation to an element so it automatically updates and applies changes
--- Use this for hands-off animation that integrates with FlexLove's rendering system
---@param element Element The element to apply animation to
function Animation:apply(element)
  if not ErrorHandler then
    ErrorHandler = require("modules.ErrorHandler")
  end
  
  if not element or type(element) ~= "table" then
    ErrorHandler.warn("Animation", "Cannot apply animation to nil or non-table element. Animation not applied.")
    return
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
  if not ErrorHandler then
    ErrorHandler = require("modules.ErrorHandler")
  end
  
  if type(nextAnimation) == "function" then
    self._nextFactory = nextAnimation
    return self
  elseif type(nextAnimation) == "table" then
    self._next = nextAnimation
    return nextAnimation
  else
    ErrorHandler.warn("Animation", "chain() requires an Animation or function. Chaining not applied.")
    return self
  end
end

--- Introduce a wait period before animation begins for staggered effects
--- Use this to create cascading animations or timed sequences
---@param seconds number Delay duration in seconds
---@return Animation self For chaining
function Animation:delay(seconds)
  if not ErrorHandler then
    ErrorHandler = require("modules.ErrorHandler")
  end
  
  if type(seconds) ~= "number" or seconds < 0 then
    ErrorHandler.warn("Animation", "delay() requires a non-negative number. Using 0.")
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
  if not ErrorHandler then
    ErrorHandler = require("modules.ErrorHandler")
  end
  
  if type(count) ~= "number" or count < 0 then
    ErrorHandler.warn("Animation", "repeatCount() requires a non-negative number. Using 0.")
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

--- Quickly create grow/shrink effects without manually specifying dimensions
--- Use this convenience method for bounce effects, pop-ups, and attention animations
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

--- Create a keyframe-based animation with multiple waypoints and per-keyframe easing
--- Use this for complex multi-step animations like bounce-in effects or CSS-style @keyframes
---@param props {duration:number, keyframes:Keyframe[], onStart:function?, onUpdate:function?, onComplete:function?, onCancel:function?} Animation properties
---@return Animation animation The keyframe animation
function Animation.keyframes(props)
  if not ErrorHandler then
    ErrorHandler = require("modules.ErrorHandler")
  end
  
  -- Validate input
  if type(props) ~= "table" then
    ErrorHandler.warn("Animation", "Animation.keyframes() requires a table argument. Using default values.")
    props = {duration = 1, keyframes = {}}
  end
  
  if type(props.duration) ~= "number" or props.duration <= 0 then
    ErrorHandler.warn("Animation", "Keyframe animation duration must be a positive number. Using 1 second.")
    props.duration = 1
  end
  
  if type(props.keyframes) ~= "table" or #props.keyframes < 2 then
    ErrorHandler.warn("Animation", "Keyframe animation requires at least 2 keyframes. Using empty animation.")
    props.keyframes = {
      {at = 0, values = {}},
      {at = 1, values = {}}
    }
  end
  
  -- Sort keyframes by 'at' position
  local sortedKeyframes = {}
  for i, kf in ipairs(props.keyframes) do
    if type(kf) == "table" and type(kf.at) == "number" and type(kf.values) == "table" then
      table.insert(sortedKeyframes, kf)
    end
  end
  
  table.sort(sortedKeyframes, function(a, b) return a.at < b.at end)
  
  -- Ensure keyframes start at 0 and end at 1
  if #sortedKeyframes > 0 then
    if sortedKeyframes[1].at > 0 then
      table.insert(sortedKeyframes, 1, {at = 0, values = sortedKeyframes[1].values})
    end
    if sortedKeyframes[#sortedKeyframes].at < 1 then
      table.insert(sortedKeyframes, {at = 1, values = sortedKeyframes[#sortedKeyframes].values})
    end
  end
  
  -- Create animation with keyframes
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

--- Initialize ErrorHandler dependency
---@param errorHandler table The ErrorHandler module
local function initializeErrorHandler(errorHandler)
  ErrorHandler = errorHandler
end

-- Export ErrorHandler initializer
Animation.initializeErrorHandler = initializeErrorHandler

return Animation
