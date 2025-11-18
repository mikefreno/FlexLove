--- AnimationGroup module for running multiple animations together
---@class AnimationGroup
local AnimationGroup = {}
AnimationGroup.__index = AnimationGroup

-- ErrorHandler dependency (injected via initializeErrorHandler)
local ErrorHandler = nil

---@class AnimationGroupProps
---@field animations table Array of Animation instances
---@field mode string? "parallel", "sequence", or "stagger" (default: "parallel")
---@field stagger number? Stagger delay in seconds (for stagger mode, default: 0.1)
---@field onComplete function? Called when all animations complete: (group)
---@field onStart function? Called when group starts: (group)

--- Create a new animation group
---@param props AnimationGroupProps
---@return AnimationGroup group
function AnimationGroup.new(props)
  if type(props) ~= "table" then
    ErrorHandler.warn("AnimationGroup", "AnimationGroup.new() requires a table argument. Using default values.")
    props = {animations = {}}
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
  
  -- Validate mode
  if self.mode ~= "parallel" and self.mode ~= "sequence" and self.mode ~= "stagger" then
    ErrorHandler.warn("AnimationGroup", string.format("Invalid mode: %s. Using 'parallel'.", tostring(self.mode)))
    self.mode = "parallel"
  end

  -- Internal state
  self._currentIndex = 1
  self._staggerElapsed = 0
  self._startedAnimations = {}
  self._hasStarted = false
  self._paused = false
  self._state = "ready" -- "ready", "playing", "completed", "cancelled"

  return self
end

--- Update all animations in parallel
---@param dt number Delta time
---@param element table? Optional element reference for callbacks
---@return boolean finished True if all animations complete
function AnimationGroup:_updateParallel(dt, element)
  local allFinished = true

  for i, anim in ipairs(self.animations) do
    -- Check if animation has isCompleted method or check state
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

  -- Start animations based on stagger timing
  for i, anim in ipairs(self.animations) do
    local startTime = (i - 1) * self.stagger

    if self._staggerElapsed >= startTime and not self._startedAnimations[i] then
      self._startedAnimations[i] = true
    end
  end

  -- Update started animations
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

--- Update the animation group
---@param dt number Delta time
---@param element table? Optional element reference for callbacks
---@return boolean finished True if group is complete
function AnimationGroup:update(dt, element)
  -- Sanitize dt
  if type(dt) ~= "number" or dt < 0 or dt ~= dt or dt == math.huge then
    dt = 0
  end

  if self._paused or self._state == "completed" or self._state == "cancelled" then
    return self._state == "completed"
  end

  -- Call onStart on first update
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

--- Pause all animations in the group
function AnimationGroup:pause()
  self._paused = true
  for _, anim in ipairs(self.animations) do
    if type(anim.pause) == "function" then
      anim:pause()
    end
  end
end

--- Resume all animations in the group
function AnimationGroup:resume()
  self._paused = false
  for _, anim in ipairs(self.animations) do
    if type(anim.resume) == "function" then
      anim:resume()
    end
  end
end

--- Check if group is paused
---@return boolean paused
function AnimationGroup:isPaused()
  return self._paused
end

--- Reverse all animations in the group
function AnimationGroup:reverse()
  for _, anim in ipairs(self.animations) do
    if type(anim.reverse) == "function" then
      anim:reverse()
    end
  end
end

--- Set speed for all animations in the group
---@param speed number Speed multiplier
function AnimationGroup:setSpeed(speed)
  for _, anim in ipairs(self.animations) do
    if type(anim.setSpeed) == "function" then
      anim:setSpeed(speed)
    end
  end
end

--- Cancel all animations in the group
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

--- Reset the animation group to initial state
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

--- Get the current state of the group
---@return string state "ready", "playing", "completed", "cancelled"
function AnimationGroup:getState()
  return self._state
end

--- Get the overall progress of the group (0-1)
---@return number progress
function AnimationGroup:getProgress()
  if #self.animations == 0 then
    return 1
  end

  if self.mode == "sequence" then
    -- For sequence, progress is based on current animation index + current animation progress
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
    -- For parallel and stagger, average progress of all animations
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

--- Apply this animation group to an element
---@param element Element The element to apply animations to
function AnimationGroup:apply(element)
  if not element or type(element) ~= "table" then
    ErrorHandler.warn("AnimationGroup", "Cannot apply animation group to nil or non-table element. Group not applied.")
    return
  end
  element.animationGroup = self
end

--- Initialize ErrorHandler dependency
---@param errorHandler table The ErrorHandler module
local function initializeErrorHandler(errorHandler)
  ErrorHandler = errorHandler
end

-- Export ErrorHandler initializer
AnimationGroup.initializeErrorHandler = initializeErrorHandler

return AnimationGroup
