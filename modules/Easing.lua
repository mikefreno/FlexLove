--- Easing functions for animations
--- Provides 30+ easing functions for smooth animation transitions
---
--- Easing function type
---@alias EasingFunction fun(t: number): number
---
---@class Easing
local Easing = {}

-- ============================================================================
-- Linear
-- ============================================================================

---@type EasingFunction
function Easing.linear(t)
  return t
end

-- ============================================================================
-- Quadratic (Quad)
-- ============================================================================

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

-- ============================================================================
-- Cubic
-- ============================================================================

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

-- ============================================================================
-- Quartic (Quart)
-- ============================================================================

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

-- ============================================================================
-- Quintic (Quint)
-- ============================================================================

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

-- ============================================================================
-- Exponential (Expo)
-- ============================================================================

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
  if t == 0 then return 0 end
  if t == 1 then return 1 end
  
  if t < 0.5 then
    return 0.5 * math.pow(2, 20 * t - 10)
  else
    return 1 - 0.5 * math.pow(2, -20 * t + 10)
  end
end

-- ============================================================================
-- Sine
-- ============================================================================

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

-- ============================================================================
-- Circular (Circ)
-- ============================================================================

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

-- ============================================================================
-- Back (Overshoot)
-- ============================================================================

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

-- ============================================================================
-- Elastic (Spring)
-- ============================================================================

---@type EasingFunction
function Easing.easeInElastic(t)
  if t == 0 then return 0 end
  if t == 1 then return 1 end
  
  local c4 = (2 * math.pi) / 3
  return -math.pow(2, 10 * t - 10) * math.sin((t * 10 - 10.75) * c4)
end

---@type EasingFunction
function Easing.easeOutElastic(t)
  if t == 0 then return 0 end
  if t == 1 then return 1 end
  
  local c4 = (2 * math.pi) / 3
  return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1
end

---@type EasingFunction
function Easing.easeInOutElastic(t)
  if t == 0 then return 0 end
  if t == 1 then return 1 end
  
  local c5 = (2 * math.pi) / 4.5
  
  if t < 0.5 then
    return -(math.pow(2, 20 * t - 10) * math.sin((20 * t - 11.125) * c5)) / 2
  else
    return (math.pow(2, -20 * t + 10) * math.sin((20 * t - 11.125) * c5)) / 2 + 1
  end
end

-- ============================================================================
-- Bounce
-- ============================================================================

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

-- ============================================================================
-- Configurable Easing Factories
-- ============================================================================

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
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    
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
    -- Linear
    "linear",
    -- Quad
    "easeInQuad", "easeOutQuad", "easeInOutQuad",
    -- Cubic
    "easeInCubic", "easeOutCubic", "easeInOutCubic",
    -- Quart
    "easeInQuart", "easeOutQuart", "easeInOutQuart",
    -- Quint
    "easeInQuint", "easeOutQuint", "easeInOutQuint",
    -- Expo
    "easeInExpo", "easeOutExpo", "easeInOutExpo",
    -- Sine
    "easeInSine", "easeOutSine", "easeInOutSine",
    -- Circ
    "easeInCirc", "easeOutCirc", "easeInOutCirc",
    -- Back
    "easeInBack", "easeOutBack", "easeInOutBack",
    -- Elastic
    "easeInElastic", "easeOutElastic", "easeInOutElastic",
    -- Bounce
    "easeInBounce", "easeOutBounce", "easeInOutBounce",
  }
end

--- Get an easing function by name
---@param name string Easing function name
---@return EasingFunction? easing The easing function, or nil if not found
function Easing.get(name)
  return Easing[name]
end

return Easing
