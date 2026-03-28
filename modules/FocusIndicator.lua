local packageName = ... or "FocusIndicator"
local modulePath = packageName:match("(.-)[^%.]+$")

local function req(name)
  return require(modulePath .. name)
end

--- FocusIndicator Module
--- Renders a visual indicator around the focused element
local FocusIndicator = {}

--- Configuration
FocusIndicator.config = {
  enabled = true,
  
  -- Appearance
  color = {0.2, 0.6, 1.0, 0.8},  -- Blue with 80% opacity
  lineWidth = 2,
  inset = -3,                    -- Negative value extends beyond element
  borderRadius = 4,
  
  -- Animation
  animationDuration = 0.15,       -- Seconds for focus animation
  pulseEnabled = false,          -- Enable pulsing animation
  pulseDuration = 1.0,           -- Seconds per pulse cycle
  pulseScaleMin = 0.95,          -- Minimum scale during pulse
  pulseScaleMax = 1.05,          -- Maximum scale during pulse
}

--- State
FocusIndicator._focusedElement = nil
FocusIndicator._animationProgress = 0
FocusIndicator._pulsePhase = 0
FocusIndicator._deps = nil

--- Initialize FocusIndicator module
---@param deps table {Context, Color}
function FocusIndicator.init(deps)
  FocusIndicator._deps = deps
  FocusIndicator._Context = deps.Context
  FocusIndicator._Color = deps.Color
end

--- Update animation state
---@param dt number Delta time in seconds
function FocusIndicator:update(dt)
  if not FocusIndicator.config.enabled then
    return
  end

  -- Update focus entrance animation
  if FocusIndicator._animationProgress < 1 then
    FocusIndicator._animationProgress = math.min(
      1,
      FocusIndicator._animationProgress + (dt / FocusIndicator.config.animationDuration)
    )
  end

  -- Update pulse animation
  if FocusIndicator.config.pulseEnabled then
    FocusIndicator._pulsePhase = (
      FocusIndicator._pulsePhase + dt
    ) % FocusIndicator.config.pulseDuration
  end
end

--- Set the focused element
---@param element Element?
function FocusIndicator.setFocused(element)
  FocusIndicator._focusedElement = element
  -- Reset animation when focus changes
  if element then
    FocusIndicator._animationProgress = 0
  end
end

--- Get the current scale factor (for animation)
---@return number
function FocusIndicator:getScale()
  local scale = 1

  -- Apply entrance animation (scale up from 0.8)
  local entranceScale = 0.8 + (0.2 * FocusIndicator._animationProgress)
  scale = scale * entranceScale

  -- Apply pulse animation
  if FocusIndicator.config.pulseEnabled then
    local pulseProgress = FocusIndicator._pulsePhase / FocusIndicator.config.pulseDuration
    -- Smooth sine wave pulse
    local pulseScale = FocusIndicator.config.pulseScaleMin +
      (FocusIndicator.config.pulseScaleMax - FocusIndicator.config.pulseScaleMin) *
      (0.5 + 0.5 * math.sin(2 * math.pi * pulseProgress))
    scale = scale * pulseScale
  end

  return scale
end

--- Get the current opacity (for animation)
---@return number
function FocusIndicator:getOpacity()
  -- Fade in on focus
  return FocusIndicator.config.color[4] * FocusIndicator._animationProgress
end

--- Draw the focus indicator
--- Should be called from within love.draw() or a custom draw function
function FocusIndicator:draw()
  if not FocusIndicator.config.enabled then
    return
  end

  local element = FocusIndicator._focusedElement
  if not element then
    return
  end

  -- Get element dimensions
  local x = element.x or 0
  local y = element.y or 0
  local w = element.width or 0
  local h = element.height or 0

  if w == 0 or h == 0 then
    return
  end

  -- Calculate indicator dimensions with inset and scale
  local inset = FocusIndicator.config.inset
  local scale = self:getScale()
  
  local indicatorX = x + inset
  local indicatorY = y + inset
  local indicatorW = w - 2 * inset
  local indicatorH = h - 2 * inset

  -- Center the scale around the element
  local offsetX = (indicatorW * (1 - scale)) / 2
  local offsetY = (indicatorH * (1 - scale)) / 2
  
  indicatorX = indicatorX + offsetX
  indicatorY = indicatorY + offsetY
  indicatorW = indicatorW * scale
  indicatorH = indicatorH * scale

  -- Get color with animated opacity
  local r, g, b = FocusIndicator.config.color[1], FocusIndicator.config.color[2], FocusIndicator.config.color[3]
  local a = self:getOpacity()

  -- Save current love.graphics state
  local previousLove = love.graphics.getScissor()
  local previousBlend = love.graphics.getBlendMode()

  -- Set blend mode for transparency
  love.graphics.setBlendMode("alpha")

  -- Draw rounded rectangle border
  love.graphics.setColor(r, g, b, a)
  love.graphics.setLineWidth(FocusIndicator.config.lineWidth)
  
  -- Draw the border (filled rectangle with hole)
  local borderRadius = FocusIndicator.config.borderRadius
  
  -- Outer rectangle (filled)
  love.graphics.rectangle("fill", indicatorX, indicatorY, indicatorW, indicatorH, borderRadius)
  
  -- Inner rectangle (cutout) - draw with background color or use stencil
  -- For simplicity, we'll just draw the border using line
  love.graphics.setLineWidth(FocusIndicator.config.lineWidth)
  love.graphics.setLineJoin("round")
  love.graphics.setLineCap("round")
  love.graphics.rectangle("line", indicatorX, indicatorY, indicatorW, indicatorH, borderRadius)

  -- Restore love.graphics state
  love.graphics.setBlendMode(previousBlend)
  if previousLove then
    love.graphics.setScissor(previousLove)
  end
  love.graphics.setColor(1, 1, 1, 1) -- Reset color
end

--- Enable/disable focus indicator
---@param enabled boolean
function FocusIndicator.setEnabled(enabled)
  FocusIndicator.config.enabled = enabled
end

--- Set focus indicator color
---@param r number Red component (0-1)
---@param g number Green component (0-1)
---@param b number Blue component (0-1)
---@param a number Alpha component (0-1, optional)
function FocusIndicator.setColor(r, g, b, a)
  FocusIndicator.config.color = {r, g, b, a or FocusIndicator.config.color[4]}
end

--- Set focus indicator line width
---@param width number
function FocusIndicator.setLineWidth(width)
  FocusIndicator.config.lineWidth = width
end

--- Enable/disable pulse animation
---@param enabled boolean
function FocusIndicator.setPulseEnabled(enabled)
  FocusIndicator.config.pulseEnabled = enabled
end

return FocusIndicator
