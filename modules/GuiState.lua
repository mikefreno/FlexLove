-- ====================
-- GUI State Module
-- ====================
-- Shared state between Gui and Element to avoid circular dependencies

---@class GuiState
local GuiState = {
  -- Top-level elements
  topElements = {},

  -- Base scale configuration
  baseScale = nil, -- {width: number, height: number}

  -- Current scale factors
  scaleFactors = { x = 1.0, y = 1.0 },

  -- Default theme name
  defaultTheme = nil,

  -- Currently focused element (for keyboard input)
  _focusedElement = nil,

  -- Active event element (for current frame)
  _activeEventElement = nil,

  -- Cached viewport dimensions
  _cachedViewport = { width = 0, height = 0 },

  -- Immediate mode state
  _immediateMode = false,
  _frameNumber = 0,
  _currentFrameElements = {},
  _immediateModeState = nil, -- Will be initialized if immediate mode is enabled
  _frameStarted = false,
  _autoBeganFrame = false,
}

--- Get current scale factors
---@return number, number -- scaleX, scaleY
function GuiState.getScaleFactors()
  return GuiState.scaleFactors.x, GuiState.scaleFactors.y
end

return GuiState
