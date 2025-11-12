-- ====================
-- Element Object
-- ====================

-- Setup module path for relative requires
local modulePath = (...):match("(.-)[^%.]+$")
local function req(name)
  return require(modulePath .. name)
end

-- Module dependencies
local GuiState = req("GuiState")
local Theme = req("Theme")
local Color = req("Color")
local Units = req("Units")
local Blur = req("Blur")
local ImageRenderer = req("ImageRenderer")
local NinePatch = req("NinePatch")
local RoundedRect = req("RoundedRect")
--local Animation = req("Animation")
local ImageCache = req("ImageCache")
local utils = req("utils")
local Grid = req("Grid")
local InputEvent = req("InputEvent")
local StateManager = req("StateManager")

-- Manager modules for composition architecture
local TextEditor = req("TextEditor")
local LayoutEngine = req("LayoutEngine")
local Renderer = req("Renderer")
local EventHandler = req("EventHandler")
local ScrollManager = req("ScrollManager")
local ThemeManager = req("ThemeManager")
-- Extract utilities
local enums = utils.enums
local FONT_CACHE = utils.FONT_CACHE
local resolveTextSizePreset = utils.resolveTextSizePreset
local getModifiers = utils.getModifiers

-- Extract enum values
local Positioning = enums.Positioning
local FlexDirection = enums.FlexDirection
local JustifyContent = enums.JustifyContent
local AlignContent = enums.AlignContent
local AlignItems = enums.AlignItems
local TextAlign = enums.TextAlign
local AlignSelf = enums.AlignSelf
local JustifySelf = enums.JustifySelf
local FlexWrap = enums.FlexWrap

local Gui = GuiState

local utf8 = utf8 or require("utf8")

--[[
INTERNAL FIELD NAMING CONVENTIONS:
---------------------------------
Fields prefixed with underscore (_) are internal/private and should not be accessed directly:

- _pressed: Internal state tracking for mouse button presses
- _lastClickTime: Internal timestamp for double-click detection
- _lastClickButton: Internal button tracking for click events
- _clickCount: Internal counter for multi-click detection
- _touchPressed: Internal touch state tracking
- _themeState: Internal current theme state (managed automatically)
- _borderBoxWidth: Internal cached border-box width (optimization)
- _borderBoxHeight: Internal cached border-box height (optimization)
- _explicitlyAbsolute: Internal flag for positioning logic
- _originalPositioning: Internal original positioning value
- _cachedResult: Internal animation cache (Animation class)
- _resultDirty: Internal animation dirty flag (Animation class)
- _loadedAtlas: Internal cached atlas image (ThemeComponent)
- _cachedViewport: Internal viewport cache (Gui class)

Public API methods to access internal state:
- Element:getBorderBoxWidth() - Get border-box width
- Element:getBorderBoxHeight() - Get border-box height
- Element:getBounds() - Get element bounds
]]

---@class Element
---@field id string
---@field autosizing {width:boolean, height:boolean} -- Whether the element should automatically size to fit its children
---@field x number|string -- X coordinate of the element
---@field y number|string -- Y coordinate of the element
---@field z number -- Z-index for layering (default: 0)
---@field width number|string -- Width of the element
---@field height number|string -- Height of the element
---@field top number? -- Offset from top edge (CSS-style positioning)
---@field right number? -- Offset from right edge (CSS-style positioning)
---@field bottom number? -- Offset from bottom edge (CSS-style positioning)
---@field left number? -- Offset from left edge (CSS-style positioning)
---@field children table<integer, Element> -- Children of this element
---@field parent Element? -- Parent element (nil if top-level)
---@field border Border -- Border configuration for the element
---@field opacity number
---@field borderColor Color -- Color of the border
---@field backgroundColor Color -- Background color of the element
---@field cornerRadius number|{topLeft:number?, topRight:number?, bottomLeft:number?, bottomRight:number?}? -- Corner radius for rounded corners (default: 0)
---@field prevGameSize {width:number, height:number} -- Previous game size for resize calculations
---@field text string? -- Text content to display in the element
---@field textColor Color -- Color of the text content
---@field textAlign TextAlign -- Alignment of the text content
---@field gap number|string -- Space between children elements (default: 10)
---@field padding {top?:number, right?:number, bottom?:number, left?:number}? -- Padding around children (default: {top=0, right=0, bottom=0, left=0})
---@field margin {top?:number, right?:number, bottom?:number, left?:number} -- Margin around children (default: {top=0, right=0, bottom=0, left=0})
---@field positioning Positioning -- Layout positioning mode (default: RELATIVE)
---@field flexDirection FlexDirection -- Direction of flex layout (default: HORIZONTAL)
---@field justifyContent JustifyContent -- Alignment of items along main axis (default: FLEX_START)
---@field alignItems AlignItems -- Alignment of items along cross axis (default: STRETCH)
---@field alignContent AlignContent -- Alignment of lines in multi-line flex containers (default: STRETCH)
---@field flexWrap FlexWrap -- Whether children wrap to multiple lines (default: NOWRAP)
---@field justifySelf JustifySelf -- Alignment of the item itself along main axis (default: AUTO)
---@field alignSelf AlignSelf -- Alignment of the item itself along cross axis (default: AUTO)
---@field textSize number? -- Resolved font size for text content in pixels
---@field minTextSize number?
---@field maxTextSize number?
---@field fontFamily string? -- Font family name from theme or path to font file
---@field autoScaleText boolean -- Whether text should auto-scale with window size (default: true)
---@field transform TransformProps -- Transform properties for animations and styling
---@field transition TransitionProps -- Transition settings for animations
---@field onEvent fun(element:Element, event:InputEvent)? -- Callback function for interaction events
---@field units table -- Original unit specifications for responsive behavior
---@field _pressed table<number, boolean> -- Track pressed state per mouse button
---@field _lastClickTime number? -- Timestamp of last click for double-click detection
---@field _lastClickButton number? -- Button of last click
---@field _clickCount number -- Current click count for multi-click detection
---@field _touchPressed table<any, boolean> -- Track touch pressed state
---@field _dragStartX table<number, number>? -- Track drag start X position per mouse button
---@field _dragStartY table<number, number>? -- Track drag start Y position per mouse button
---@field _lastMouseX table<number, number>? -- Last known mouse X position per button for drag tracking
---@field _lastMouseY table<number, number>? -- Last known mouse Y position per button for drag tracking
---@field _explicitlyAbsolute boolean?
---@field gridRows number? -- Number of rows in the grid
---@field gridColumns number? -- Number of columns in the grid
---@field columnGap number|string? -- Gap between grid columns
---@field rowGap number|string? -- Gap between grid rows
---@field theme string? -- Theme component to use for rendering
---@field themeComponent string?
---@field _themeState string? -- Current theme state (normal, hover, pressed, active, disabled)
---@field _stateId string? -- State manager ID for this element
---@field disabled boolean? -- Whether the element is disabled (default: false)
---@field active boolean? -- Whether the element is active/focused (for inputs, default: false)
---@field disableHighlight boolean? -- Whether to disable the pressed state highlight overlay (default: false)
---@field contentAutoSizingMultiplier {width:number?, height:number?}? -- Multiplier for auto-sized content dimensions
---@field scaleCorners number? -- Scale multiplier for 9-patch corners/edges. E.g., 2 = 2x size (overrides theme setting)
---@field scalingAlgorithm "nearest"|"bilinear"? -- Scaling algorithm for 9-patch corners: "nearest" (sharp/pixelated) or "bilinear" (smooth) (overrides theme setting)
---@field contentBlur {intensity:number, quality:number}? -- Blur the element's content including children (intensity: 0-100, quality: 1-10)
---@field backdropBlur {intensity:number, quality:number}? -- Blur content behind the element (intensity: 0-100, quality: 1-10)
---@field _blurInstance table? -- Internal: cached blur effect instance
---@field editable boolean -- Whether the element is editable (default: false)
---@field multiline boolean -- Whether the element supports multiple lines (default: false)
---@field textWrap boolean|"word"|"char" -- Text wrapping mode (default: false for single-line, "word" for multi-line)
---@field maxLines number? -- Maximum number of lines (default: nil)
---@field maxLength number? -- Maximum text length in characters (default: nil)
---@field placeholder string? -- Placeholder text when empty (default: nil)
---@field passwordMode boolean -- Whether to display text as password (default: false)
---@field inputType "text"|"number"|"email"|"url" -- Input type for validation (default: "text")
---@field textOverflow "clip"|"ellipsis"|"scroll" -- Text overflow behavior (default: "clip")
---@field scrollable boolean -- Whether text is scrollable (default: false for single-line, true for multi-line)
---@field autoGrow boolean -- Whether element auto-grows with text (default: false)
---@field selectOnFocus boolean -- Whether to select all text on focus (default: false)
---@field cursorColor Color? -- Cursor color (default: nil, uses textColor)
---@field selectionColor Color? -- Selection background color (default: nil, uses theme or default)
---@field cursorBlinkRate number -- Cursor blink rate in seconds (default: 0.5)
---@field _cursorPosition number? -- Internal: cursor character position (0-based)
---@field _cursorLine number? -- Internal: cursor line number (1-based)
---@field _cursorColumn number? -- Internal: cursor column within line
---@field _cursorBlinkTimer number? -- Internal: cursor blink timer
---@field _cursorVisible boolean? -- Internal: cursor visibility state
---@field _cursorBlinkPaused boolean? -- Internal: whether cursor blink is paused (e.g., while typing)
---@field _cursorBlinkPauseTimer number? -- Internal: timer for how long cursor blink has been paused
---@field _selectionStart number? -- Internal: selection start position
---@field _selectionEnd number? -- Internal: selection end position
---@field _selectionAnchor number? -- Internal: selection anchor point
---@field _focused boolean? -- Internal: focus state
---@field _textBuffer string? -- Internal: text buffer for editable elements
---@field _lines table? -- Internal: split lines for multi-line text
---@field _wrappedLines table? -- Internal: wrapped line data
---@field _textDirty boolean? -- Internal: flag to recalculate lines/wrapping
---@field imagePath string? -- Path to image file (auto-loads via ImageCache)
---@field image love.Image? -- Image object to display
---@field objectFit "fill"|"contain"|"cover"|"scale-down"|"none"? -- Image fit mode (default: "fill")
---@field objectPosition string? -- Image position like "center center", "top left", "50% 50%" (default: "center center")
---@field imageOpacity number? -- Image opacity 0-1 (default: 1, combines with element opacity)
---@field _loadedImage love.Image? -- Internal: cached loaded image
---@field hideScrollbars boolean|{vertical:boolean, horizontal:boolean}? -- Hide scrollbars (boolean for both, or table for individual control)
---@field userdata table?
local Element = {}

-- Custom __index to proxy TextEditor properties for backward compatibility
local Element_mt = {
  __index = function(t, k)
    -- First check if it's an Element method/property
    local v = Element[k]
    if v ~= nil then
      return v
    end

    -- Proxy TextEditor internal fields for backward compatibility
    local textEditor = rawget(t, "_textEditor")
    if textEditor then
      if k == "_textBuffer" then
        return textEditor._textBuffer
      elseif k == "_cursorPosition" then
        return textEditor._cursorPosition
      elseif k == "_selectionStart" then
        return textEditor._selectionStart
      elseif k == "_selectionEnd" then
        return textEditor._selectionEnd
      elseif k == "_cursorLine" then
        return textEditor._cursorLine
      elseif k == "_cursorColumn" then
        return textEditor._cursorColumn
      elseif k == "_textScrollX" then
        return textEditor._textScrollX
      elseif k == "_focused" then
        return textEditor._focused
      end
    end

    return nil
  end,

  __newindex = function(t, k, v)
    -- Proxy TextEditor internal fields for backward compatibility
    local textEditor = rawget(t, "_textEditor")
    if textEditor then
      if k == "_textBuffer" then
        textEditor._textBuffer = v
        return
      elseif k == "_cursorPosition" then
        textEditor._cursorPosition = v
        return
      elseif k == "_selectionStart" then
        textEditor._selectionStart = v
        return
      elseif k == "_selectionEnd" then
        textEditor._selectionEnd = v
        return
      elseif k == "_cursorLine" then
        textEditor._cursorLine = v
        return
      elseif k == "_cursorColumn" then
        textEditor._cursorColumn = v
        return
      elseif k == "_textScrollX" then
        textEditor._textScrollX = v
        return
      elseif k == "_focused" then
        textEditor._focused = v
        return
      end
    end

    -- Default behavior: set the field directly
    rawset(t, k, v)
  end,
}

Element.__index = Element

-- ============================================
-- Element Methods (Must be defined before Element.new)
-- ============================================

--- Get border-box width (including padding)
---@return number
function Element:getBorderBoxWidth()
  return self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
end
--- Get border-box height (including padding)
---@return number
function Element:getBorderBoxHeight()
  return self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)
end
--- Get element bounds
---@return { x:number, y:number, width:number, height:number }
function Element:getBounds()
  return { x = self.x, y = self.y, width = self:getBorderBoxWidth(), height = self:getBorderBoxHeight() }
end
--- Check if point is inside element bounds
---@param x number
---@param y number
---@return boolean
function Element:contains(x, y)
  local bounds = self:getBounds()
  return bounds.x <= x and bounds.y <= y and bounds.x + bounds.width >= x and bounds.y + bounds.height >= y
end
--- Calculate text width
---@return number
function Element:calculateTextWidth()
  if self.text == nil then
    return 0
  end
  if self.textSize then
    local fontPath = nil
    if self.fontFamily then
      local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
      if themeToUse and themeToUse.fonts and themeToUse.fonts[self.fontFamily] then
        fontPath = themeToUse.fonts[self.fontFamily]
      else
        fontPath = self.fontFamily
      end
    elseif self.themeComponent then
      local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
      if themeToUse and themeToUse.fonts and themeToUse.fonts.default then
        fontPath = themeToUse.fonts.default
      end
    end
    local tempFont = FONT_CACHE.get(self.textSize, fontPath)
    local width = tempFont:getWidth(self.text)
    if self.contentAutoSizingMultiplier and self.contentAutoSizingMultiplier.width then
      width = width * self.contentAutoSizingMultiplier.width
    end
    return width
  end
  local font = love.graphics.getFont()
  local width = font:getWidth(self.text)
  if self.contentAutoSizingMultiplier and self.contentAutoSizingMultiplier.width then
    width = width * self.contentAutoSizingMultiplier.width
  end
  return width
end
---@return number
function Element:calculateTextHeight()
  if self.text == nil then
    return 0
  end
  local font
  if self.textSize then
    local fontPath = nil
    if self.fontFamily then
      local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
      if themeToUse and themeToUse.fonts and themeToUse.fonts[self.fontFamily] then
        fontPath = themeToUse.fonts[self.fontFamily]
      else
        fontPath = self.fontFamily
      end
    elseif self.themeComponent then
      local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
      if themeToUse and themeToUse.fonts and themeToUse.fonts.default then
        fontPath = themeToUse.fonts.default
      end
    end
    font = FONT_CACHE.get(self.textSize, fontPath)
  else
    font = love.graphics.getFont()
  end
  local height = font:getHeight()
  if self.textWrap and (self.textWrap == "word" or self.textWrap == "char" or self.textWrap == true) then
    local availableWidth = self.width
    if (not availableWidth or availableWidth <= 0) and self.parent then
      availableWidth = self.parent.width
    end
    if availableWidth and availableWidth > 0 then
      local wrappedWidth, wrappedLines = font:getWrap(self.text, availableWidth)
      height = height * #wrappedLines
    end
  end
  if self.contentAutoSizingMultiplier and self.contentAutoSizingMultiplier.height then
    height = height * self.contentAutoSizingMultiplier.height
  end
  return height
end
-- Delegate auto-size calculations to LayoutEngine
function Element:calculateAutoWidth()
  if self._layoutEngine then
    return self._layoutEngine:calculateAutoWidth()
  end
  return self:calculateTextWidth()
end
function Element:calculateAutoHeight()
  if self._layoutEngine then
    return self._layoutEngine:calculateAutoHeight()
  end
  return self:calculateTextHeight()
end

-- ============================================
-- Element Constructor
-- ============================================

---@return Element
function Element.new(props)
  local self = setmetatable({}, Element_mt)
  self.children = {}
  self.onEvent = props.onEvent

  -- Auto-generate ID in immediate mode if not provided
  if Gui._immediateMode and (not props.id or props.id == "") then
    self.id = StateManager.generateID(props, props.parent)
  else
    self.id = props.id or ""
  end

  self.userdata = props.userdata

  -- Input event callbacks
  self.onFocus = props.onFocus
  self.onBlur = props.onBlur
  self.onTextInput = props.onTextInput
  self.onTextChange = props.onTextChange
  self.onEnter = props.onEnter

  -- Initialize click tracking for event system
  self._pressed = {} -- Track pressed state per mouse button
  self._lastClickTime = nil
  self._lastClickButton = nil
  self._clickCount = 0
  self._touchPressed = {}

  -- Initialize drag tracking for event system
  self._dragStartX = {} -- Track drag start X position per mouse button
  self._dragStartY = {} -- Track drag start Y position per mouse button
  self._lastMouseX = {} -- Track last mouse X position per button
  self._lastMouseY = {} -- Track last mouse Y position per button

  -- Initialize theme state (will be managed by StateManager in immediate mode)
  self._themeState = "normal"

  -- Initialize state manager ID for immediate mode (use self.id which may be auto-generated)
  self._stateId = self.id

  -- Handle theme property:
  -- - theme: which theme to use (defaults to Gui.defaultTheme if not specified)
  -- - themeComponent: which component from the theme (e.g., "panel", "button", "input")
  -- If themeComponent is nil, no theme is applied (manual styling)
  self.theme = props.theme or Gui.defaultTheme
  self.themeComponent = props.themeComponent or nil

  -- Initialize state properties
  self.disabled = props.disabled or false
  self.active = props.active or false

  -- disableHighlight defaults to true when using themeComponent (themes handle their own visual feedback)
  -- Can be explicitly overridden by setting props.disableHighlight
  if props.disableHighlight ~= nil then
    self.disableHighlight = props.disableHighlight
  else
    self.disableHighlight = self.themeComponent ~= nil
  end

  -- Initialize contentAutoSizingMultiplier after theme is set
  -- Priority: element props > theme component > theme default
  if props.contentAutoSizingMultiplier then
    -- Explicitly set on element
    self.contentAutoSizingMultiplier = props.contentAutoSizingMultiplier
  else
    -- Try to source from theme
    local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
    if themeToUse then
      -- First check if themeComponent has a multiplier
      if self.themeComponent then
        local component = themeToUse.components[self.themeComponent]
        if component and component.contentAutoSizingMultiplier then
          self.contentAutoSizingMultiplier = component.contentAutoSizingMultiplier
        elseif themeToUse.contentAutoSizingMultiplier then
          -- Fall back to theme default
          self.contentAutoSizingMultiplier = themeToUse.contentAutoSizingMultiplier
        else
          self.contentAutoSizingMultiplier = { 1, 1 }
        end
      elseif themeToUse.contentAutoSizingMultiplier then
        self.contentAutoSizingMultiplier = themeToUse.contentAutoSizingMultiplier
      else
        self.contentAutoSizingMultiplier = { 1, 1 }
      end
    else
      self.contentAutoSizingMultiplier = { 1, 1 }
    end
  end

  -- Initialize 9-patch corner scaling properties
  -- These override theme component settings when specified
  self.scaleCorners = props.scaleCorners
  self.scalingAlgorithm = props.scalingAlgorithm

  -- Initialize blur properties
  self.contentBlur = props.contentBlur
  self.backdropBlur = props.backdropBlur
  self._blurInstance = nil

  -- Initialize input control properties
  self.editable = props.editable or false
  self.multiline = props.multiline or false
  self.passwordMode = props.passwordMode or false

  -- Validate property combinations: passwordMode disables multiline
  if self.passwordMode then
    self.multiline = false
  end

  self.textWrap = props.textWrap
  if self.textWrap == nil then
    self.textWrap = self.multiline and "word" or false
  end

  self.maxLines = props.maxLines
  self.maxLength = props.maxLength
  self.placeholder = props.placeholder
  self.inputType = props.inputType or "text"

  -- Text behavior properties
  self.textOverflow = props.textOverflow or "clip"
  self.scrollable = props.scrollable
  if self.scrollable == nil then
    self.scrollable = self.multiline
  end
  -- autoGrow defaults to true for multiline, false for single-line
  if props.autoGrow ~= nil then
    self.autoGrow = props.autoGrow
  else
    self.autoGrow = self.multiline
  end
  self.selectOnFocus = props.selectOnFocus or false

  -- Cursor and selection properties
  self.cursorColor = props.cursorColor
  self.selectionColor = props.selectionColor
  self.cursorBlinkRate = props.cursorBlinkRate or 0.5

  -- Initialize cursor and selection state (only if editable)
  -- NOTE: This is now handled by TextEditor module
  if self.editable then
    -- These fields are now managed by TextEditor and proxied through __index/__newindex
    -- Keeping minimal state for backward compatibility with non-TextEditor code paths
  end

  -- Set parent first so it's available for size calculations
  self.parent = props.parent

  ------ add non-hereditary ------
  --- self drawing---
  self.border = props.border
      and {
        top = props.border.top or false,
        right = props.border.right or false,
        bottom = props.border.bottom or false,
        left = props.border.left or false,
      }
    or {
      top = false,
      right = false,
      bottom = false,
      left = false,
    }
  self.borderColor = props.borderColor or Color.new(0, 0, 0, 1)
  self.backgroundColor = props.backgroundColor or Color.new(0, 0, 0, 0)
  self.opacity = props.opacity or 1

  -- Handle cornerRadius (can be number or table)
  if props.cornerRadius then
    if type(props.cornerRadius) == "number" then
      self.cornerRadius = {
        topLeft = props.cornerRadius,
        topRight = props.cornerRadius,
        bottomLeft = props.cornerRadius,
        bottomRight = props.cornerRadius,
      }
    else
      self.cornerRadius = {
        topLeft = props.cornerRadius.topLeft or 0,
        topRight = props.cornerRadius.topRight or 0,
        bottomLeft = props.cornerRadius.bottomLeft or 0,
        bottomRight = props.cornerRadius.bottomRight or 0,
      }
    end
  else
    self.cornerRadius = {
      topLeft = 0,
      topRight = 0,
      bottomLeft = 0,
      bottomRight = 0,
    }
  end

  -- For editable elements, default text to empty string if not provided
  if self.editable and props.text == nil then
    self.text = ""
  else
    self.text = props.text
  end

  -- Sync self.text with restored _textBuffer for editable elements in immediate mode
  -- NOTE: This is now handled by TextEditor module after initialization
  -- if self.editable and Gui._immediateMode and self._textBuffer then
  --   self.text = self._textBuffer
  -- end

  self.textAlign = props.textAlign or TextAlign.START

  -- Image properties
  self.imagePath = props.imagePath
  self.image = props.image
  self.objectFit = props.objectFit or "fill"
  self.objectPosition = props.objectPosition or "center center"
  self.imageOpacity = props.imageOpacity or 1

  -- Auto-load image if imagePath is provided
  if self.imagePath and not self.image then
    local loadedImage, err = ImageCache.load(self.imagePath)
    if loadedImage then
      self._loadedImage = loadedImage
    else
      -- Silently fail - image will just not render
      self._loadedImage = nil
    end
  elseif self.image then
    self._loadedImage = self.image
  else
    self._loadedImage = nil
  end

  --- self positioning ---
  local viewportWidth, viewportHeight = Units.getViewport()

  ---- Sizing ----
  local gw, gh = love.window.getMode()
  self.prevGameSize = { width = gw, height = gh }
  self.autosizing = { width = false, height = false }

  -- Store unit specifications for responsive behavior
  self.units = {
    width = { value = nil, unit = "px" },
    height = { value = nil, unit = "px" },
    x = { value = nil, unit = "px" },
    y = { value = nil, unit = "px" },
    textSize = { value = nil, unit = "px" },
    gap = { value = nil, unit = "px" },
    padding = {
      top = { value = nil, unit = "px" },
      right = { value = nil, unit = "px" },
      bottom = { value = nil, unit = "px" },
      left = { value = nil, unit = "px" },
      horizontal = { value = nil, unit = "px" }, -- Shorthand for left/right
      vertical = { value = nil, unit = "px" }, -- Shorthand for top/bottom
    },
    margin = {
      top = { value = nil, unit = "px" },
      right = { value = nil, unit = "px" },
      bottom = { value = nil, unit = "px" },
      left = { value = nil, unit = "px" },
      horizontal = { value = nil, unit = "px" }, -- Shorthand for left/right
      vertical = { value = nil, unit = "px" }, -- Shorthand for top/bottom
    },
  }

  -- Get scale factors from Gui (will be used later)
  local scaleX, scaleY = Gui.getScaleFactors()

  -- Store original textSize units and constraints
  self.minTextSize = props.minTextSize
  self.maxTextSize = props.maxTextSize

  -- Set autoScaleText BEFORE textSize processing (needed for correct initialization)
  if props.autoScaleText == nil then
    self.autoScaleText = true
  else
    self.autoScaleText = props.autoScaleText
  end

  -- Handle fontFamily (can be font name from theme or direct path to font file)
  -- Priority: explicit props.fontFamily > parent fontFamily > theme default
  if props.fontFamily then
    -- Explicitly set fontFamily takes highest priority
    self.fontFamily = props.fontFamily
  elseif self.parent and self.parent.fontFamily then
    -- Inherit from parent if parent has fontFamily set
    self.fontFamily = self.parent.fontFamily
  elseif props.themeComponent then
    -- If using themeComponent, try to get default from theme
    local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
    if themeToUse and themeToUse.fonts and themeToUse.fonts["default"] then
      self.fontFamily = "default"
    else
      self.fontFamily = nil
    end
  else
    self.fontFamily = nil
  end

  -- Handle textSize BEFORE width/height calculation (needed for auto-sizing)
  if props.textSize then
    if type(props.textSize) == "string" then
      -- Check if it's a preset first
      local presetValue, presetUnit = resolveTextSizePreset(props.textSize)
      local value, unit

      if presetValue then
        -- It's a preset, use the preset value and unit
        value, unit = presetValue, presetUnit
        self.units.textSize = { value = value, unit = unit }
      else
        -- Not a preset, parse normally
        value, unit = Units.parse(props.textSize)
        self.units.textSize = { value = value, unit = unit }
      end

      -- Resolve textSize based on unit type
      if unit == "%" or unit == "vh" then
        -- Percentage and vh are relative to viewport height
        self.textSize = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
      elseif unit == "vw" then
        -- vw is relative to viewport width
        self.textSize = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
      elseif unit == "ew" then
        -- ew is relative to element width (use viewport width as fallback during initialization)
        -- Will be re-resolved after width is set
        self.textSize = (value / 100) * viewportWidth
      elseif unit == "eh" then
        -- eh is relative to element height (use viewport height as fallback during initialization)
        -- Will be re-resolved after height is set
        self.textSize = (value / 100) * viewportHeight
      elseif unit == "px" then
        -- Pixel units
        self.textSize = value
      else
        error("Unknown textSize unit: " .. unit)
      end
    else
      -- Validate pixel textSize value
      if props.textSize <= 0 then
        error("textSize must be greater than 0, got: " .. tostring(props.textSize))
      end

      -- Pixel textSize value
      if self.autoScaleText and Gui.baseScale then
        -- With base scaling: store original pixel value and scale relative to base resolution
        self.units.textSize = { value = props.textSize, unit = "px" }
        self.textSize = props.textSize * scaleY
      elseif self.autoScaleText then
        -- Without base scaling: convert to viewport units for auto-scaling
        -- Calculate what percentage of viewport height this represents
        local vhValue = (props.textSize / viewportHeight) * 100
        self.units.textSize = { value = vhValue, unit = "vh" }
        self.textSize = props.textSize -- Initial size is the specified pixel value
      else
        -- No auto-scaling: apply base scaling if set, otherwise use raw value
        self.textSize = Gui.baseScale and (props.textSize * scaleY) or props.textSize
        self.units.textSize = { value = props.textSize, unit = "px" }
      end
    end
  else
    -- No textSize specified - use auto-scaling default
    if self.autoScaleText and Gui.baseScale then
      -- With base scaling: use 12px as default and scale
      self.units.textSize = { value = 12, unit = "px" }
      self.textSize = 12 * scaleY
    elseif self.autoScaleText then
      -- Without base scaling: default to 1.5vh (1.5% of viewport height)
      self.units.textSize = { value = 1.5, unit = "vh" }
      self.textSize = (1.5 / 100) * viewportHeight
    else
      -- No auto-scaling: use 12px with optional base scaling
      self.textSize = Gui.baseScale and (12 * scaleY) or 12
      self.units.textSize = { value = nil, unit = "px" }
    end
  end

  -- Handle width (both w and width properties, prefer w if both exist)
  local widthProp = props.width
  local tempWidth = 0 -- Temporary width for padding resolution
  if widthProp then
    if type(widthProp) == "string" then
      local value, unit = Units.parse(widthProp)
      self.units.width = { value = value, unit = unit }
      local parentWidth = self.parent and self.parent.width or viewportWidth
      tempWidth = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
    else
      -- Apply base scaling to pixel values
      tempWidth = Gui.baseScale and (widthProp * scaleX) or widthProp
      self.units.width = { value = widthProp, unit = "px" }
    end
    self.width = tempWidth
  else
    self.autosizing.width = true
    -- Special case: if textWrap is enabled and parent exists, constrain width to parent
    -- Text wrapping requires a width constraint, so use parent's content width
    if props.textWrap and self.parent and self.parent.width then
      tempWidth = self.parent.width
      self.width = tempWidth
      self.units.width = { value = 100, unit = "%" } -- Mark as parent-constrained
      self.autosizing.width = false -- Not truly autosizing, constrained by parent
    else
      -- Calculate auto-width without padding first
      tempWidth = self:calculateAutoWidth()
      self.width = tempWidth
      self.units.width = { value = nil, unit = "auto" } -- Mark as auto-sized
    end
  end

  -- Handle height (both h and height properties, prefer h if both exist)
  local heightProp = props.height
  local tempHeight = 0 -- Temporary height for padding resolution
  if heightProp then
    if type(heightProp) == "string" then
      local value, unit = Units.parse(heightProp)
      self.units.height = { value = value, unit = unit }
      local parentHeight = self.parent and self.parent.height or viewportHeight
      tempHeight = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
    else
      -- Apply base scaling to pixel values
      tempHeight = Gui.baseScale and (heightProp * scaleY) or heightProp
      self.units.height = { value = heightProp, unit = "px" }
    end
    self.height = tempHeight
  else
    self.autosizing.height = true
    -- Calculate auto-height without padding first
    tempHeight = self:calculateAutoHeight()
    self.height = tempHeight
    self.units.height = { value = nil, unit = "auto" } -- Mark as auto-sized
  end

  --- child positioning ---
  if props.gap then
    if type(props.gap) == "string" then
      local value, unit = Units.parse(props.gap)
      self.units.gap = { value = value, unit = unit }
      -- Gap percentages should be relative to the element's own size, not parent
      -- For horizontal flex, gap is based on width; for vertical flex, based on height
      local flexDir = props.flexDirection or FlexDirection.HORIZONTAL
      local containerSize = (flexDir == FlexDirection.HORIZONTAL) and self.width or self.height
      self.gap = Units.resolve(value, unit, viewportWidth, viewportHeight, containerSize)
    else
      self.gap = props.gap
      self.units.gap = { value = props.gap, unit = "px" }
    end
  else
    self.gap = 0
    self.units.gap = { value = 0, unit = "px" }
  end

  -- BORDER-BOX MODEL: For auto-sizing, we need to add padding to content dimensions
  -- For explicit sizing, width/height already include padding (border-box)

  -- Check if we should use 9-patch content padding for auto-sizing
  local use9PatchPadding = false
  local ninePatchContentPadding = nil
  if self.themeComponent then
    local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
    if themeToUse and themeToUse.components[self.themeComponent] then
      local component = themeToUse.components[self.themeComponent]
      if component._ninePatchData and component._ninePatchData.contentPadding then
        -- Only use 9-patch padding if no explicit padding was provided
        if
          not props.padding
          or (
            not props.padding.top
            and not props.padding.right
            and not props.padding.bottom
            and not props.padding.left
            and not props.padding.horizontal
            and not props.padding.vertical
          )
        then
          use9PatchPadding = true
          ninePatchContentPadding = component._ninePatchData.contentPadding
        end
      end
    end
  end

  -- First, resolve padding using temporary dimensions
  -- For auto-sized elements, this is content width; for explicit sizing, this is border-box width
  local tempPadding
  if use9PatchPadding then
    -- Scale 9-patch content padding to match the actual rendered size
    -- The contentPadding values are in the original image's pixel coordinates,
    -- but we need to scale them proportionally to the element's actual size
    local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
    if themeToUse and themeToUse.components[self.themeComponent] then
      local component = themeToUse.components[self.themeComponent]
      local atlasImage = component._loadedAtlas or themeToUse.atlas

      if atlasImage and type(atlasImage) ~= "string" then
        local originalWidth, originalHeight = atlasImage:getDimensions()

        -- Calculate the scale factor based on the element's border-box size vs original image size
        -- For explicit sizing, tempWidth/tempHeight represent the border-box dimensions
        local scaleX = tempWidth / originalWidth
        local scaleY = tempHeight / originalHeight

        tempPadding = {
          left = ninePatchContentPadding.left * scaleX,
          top = ninePatchContentPadding.top * scaleY,
          right = ninePatchContentPadding.right * scaleX,
          bottom = ninePatchContentPadding.bottom * scaleY,
        }
      else
        -- Fallback if atlas image not available
        tempPadding = {
          left = ninePatchContentPadding.left,
          top = ninePatchContentPadding.top,
          right = ninePatchContentPadding.right,
          bottom = ninePatchContentPadding.bottom,
        }
      end
    else
      -- Fallback if theme not found
      tempPadding = {
        left = ninePatchContentPadding.left,
        top = ninePatchContentPadding.top,
        right = ninePatchContentPadding.right,
        bottom = ninePatchContentPadding.bottom,
      }
    end
  else
    tempPadding = Units.resolveSpacing(props.padding, self.width, self.height)
  end

  -- Margin percentages are relative to parent's dimensions (CSS spec)
  local parentWidth = self.parent and self.parent.width or viewportWidth
  local parentHeight = self.parent and self.parent.height or viewportHeight
  self.margin = Units.resolveSpacing(props.margin, parentWidth, parentHeight)

  -- For auto-sized elements, add padding to get border-box dimensions
  if self.autosizing.width then
    self._borderBoxWidth = self.width + tempPadding.left + tempPadding.right
  else
    -- For explicit sizing, width is already border-box
    self._borderBoxWidth = self.width
  end

  if self.autosizing.height then
    self._borderBoxHeight = self.height + tempPadding.top + tempPadding.bottom
  else
    -- For explicit sizing, height is already border-box
    self._borderBoxHeight = self.height
  end

  -- Set final padding
  if use9PatchPadding then
    -- Use 9-patch content padding
    self.padding = {
      left = ninePatchContentPadding.left,
      top = ninePatchContentPadding.top,
      right = ninePatchContentPadding.right,
      bottom = ninePatchContentPadding.bottom,
    }
  else
    -- Re-resolve padding based on final border-box dimensions (important for percentage padding)
    self.padding = Units.resolveSpacing(props.padding, self._borderBoxWidth, self._borderBoxHeight)
  end

  -- Calculate final content dimensions by subtracting padding from border-box
  self.width = math.max(0, self._borderBoxWidth - self.padding.left - self.padding.right)
  self.height = math.max(0, self._borderBoxHeight - self.padding.top - self.padding.bottom)

  -- Re-resolve ew/eh textSize units now that width/height are set
  if props.textSize and type(props.textSize) == "string" then
    local value, unit = Units.parse(props.textSize)
    if unit == "ew" then
      -- Element width relative (now that width is set)
      self.textSize = (value / 100) * self.width
    elseif unit == "eh" then
      -- Element height relative (now that height is set)
      self.textSize = (value / 100) * self.height
    end
  end

  -- Apply min/max constraints (also scaled)
  local minSize = self.minTextSize and (Gui.baseScale and (self.minTextSize * scaleY) or self.minTextSize)
  local maxSize = self.maxTextSize and (Gui.baseScale and (self.maxTextSize * scaleY) or self.maxTextSize)

  if minSize and self.textSize < minSize then
    self.textSize = minSize
  end
  if maxSize and self.textSize > maxSize then
    self.textSize = maxSize
  end

  -- Protect against too-small text sizes (minimum 1px)
  if self.textSize < 1 then
    self.textSize = 1 -- Minimum 1px
  end

  -- Store original spacing values for proper resize handling
  -- Store shorthand properties first (horizontal/vertical)
  if props.padding then
    if props.padding.horizontal then
      if type(props.padding.horizontal) == "string" then
        local value, unit = Units.parse(props.padding.horizontal)
        self.units.padding.horizontal = { value = value, unit = unit }
      else
        self.units.padding.horizontal = { value = props.padding.horizontal, unit = "px" }
      end
    end
    if props.padding.vertical then
      if type(props.padding.vertical) == "string" then
        local value, unit = Units.parse(props.padding.vertical)
        self.units.padding.vertical = { value = value, unit = unit }
      else
        self.units.padding.vertical = { value = props.padding.vertical, unit = "px" }
      end
    end
  end

  -- Initialize all padding sides
  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    if props.padding and props.padding[side] then
      if type(props.padding[side]) == "string" then
        local value, unit = Units.parse(props.padding[side])
        self.units.padding[side] = { value = value, unit = unit, explicit = true }
      else
        self.units.padding[side] = { value = props.padding[side], unit = "px", explicit = true }
      end
    else
      -- Mark as derived from shorthand (will use shorthand during resize if available)
      self.units.padding[side] = { value = self.padding[side], unit = "px", explicit = false }
    end
  end

  -- Store margin shorthand properties
  if props.margin then
    if props.margin.horizontal then
      if type(props.margin.horizontal) == "string" then
        local value, unit = Units.parse(props.margin.horizontal)
        self.units.margin.horizontal = { value = value, unit = unit }
      else
        self.units.margin.horizontal = { value = props.margin.horizontal, unit = "px" }
      end
    end
    if props.margin.vertical then
      if type(props.margin.vertical) == "string" then
        local value, unit = Units.parse(props.margin.vertical)
        self.units.margin.vertical = { value = value, unit = unit }
      else
        self.units.margin.vertical = { value = props.margin.vertical, unit = "px" }
      end
    end
  end

  -- Initialize all margin sides
  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    if props.margin and props.margin[side] then
      if type(props.margin[side]) == "string" then
        local value, unit = Units.parse(props.margin[side])
        self.units.margin[side] = { value = value, unit = unit, explicit = true }
      else
        self.units.margin[side] = { value = props.margin[side], unit = "px", explicit = true }
      end
    else
      -- Mark as derived from shorthand (will use shorthand during resize if available)
      self.units.margin[side] = { value = self.margin[side], unit = "px", explicit = false }
    end
  end

  -- Grid properties are set later in the constructor

  ------ add hereditary ------
  if props.parent == nil then
    table.insert(Gui.topElements, self)

    -- Handle x position with units
    if props.x then
      if type(props.x) == "string" then
        local value, unit = Units.parse(props.x)
        self.units.x = { value = value, unit = unit }
        self.x = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
      else
        -- Apply base scaling to pixel positions
        self.x = Gui.baseScale and (props.x * scaleX) or props.x
        self.units.x = { value = props.x, unit = "px" }
      end
    else
      self.x = 0
      self.units.x = { value = 0, unit = "px" }
    end

    -- Handle y position with units
    if props.y then
      if type(props.y) == "string" then
        local value, unit = Units.parse(props.y)
        self.units.y = { value = value, unit = unit }
        self.y = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
      else
        -- Apply base scaling to pixel positions
        self.y = Gui.baseScale and (props.y * scaleY) or props.y
        self.units.y = { value = props.y, unit = "px" }
      end
    else
      self.y = 0
      self.units.y = { value = 0, unit = "px" }
    end

    self.z = props.z or 0

    -- Set textColor with priority: props > theme text color > black
    if props.textColor then
      self.textColor = props.textColor
    else
      -- Try to get text color from theme
      local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
      if themeToUse and themeToUse.colors and themeToUse.colors.text then
        self.textColor = themeToUse.colors.text
      else
        -- Fallback to black
        self.textColor = Color.new(0, 0, 0, 1)
      end
    end

    -- Track if positioning was explicitly set
    if props.positioning then
      self.positioning = props.positioning
      self._originalPositioning = props.positioning
      self._explicitlyAbsolute = (props.positioning == Positioning.ABSOLUTE)
    else
      self.positioning = Positioning.RELATIVE
      self._originalPositioning = nil -- No explicit positioning
      self._explicitlyAbsolute = false
    end
  else
    -- Set positioning first and track if explicitly set
    self._originalPositioning = props.positioning -- Track original intent
    if props.positioning == Positioning.ABSOLUTE then
      self.positioning = Positioning.ABSOLUTE
      self._explicitlyAbsolute = true -- Explicitly set to absolute by user
    elseif props.positioning == Positioning.FLEX then
      self.positioning = Positioning.FLEX
      self._explicitlyAbsolute = false
    elseif props.positioning == Positioning.GRID then
      self.positioning = Positioning.GRID
      self._explicitlyAbsolute = false
    else
      -- Default: children in flex/grid containers participate in parent's layout
      -- children in relative/absolute containers default to relative
      if self.parent.positioning == Positioning.FLEX or self.parent.positioning == Positioning.GRID then
        self.positioning = Positioning.ABSOLUTE -- They are positioned BY flex/grid, not AS flex/grid
        self._explicitlyAbsolute = false -- Participate in parent's layout
      else
        self.positioning = Positioning.RELATIVE
        self._explicitlyAbsolute = false -- Default for relative/absolute containers
      end
    end

    -- Set initial position
    if self.positioning == Positioning.ABSOLUTE then
      -- Handle x position with units
      if props.x then
        if type(props.x) == "string" then
          local value, unit = Units.parse(props.x)
          self.units.x = { value = value, unit = unit }
          local parentWidth = self.parent.width
          self.x = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
        else
          -- Apply base scaling to pixel positions
          self.x = Gui.baseScale and (props.x * scaleX) or props.x
          self.units.x = { value = props.x, unit = "px" }
        end
      else
        self.x = 0
        self.units.x = { value = 0, unit = "px" }
      end

      -- Handle y position with units
      if props.y then
        if type(props.y) == "string" then
          local value, unit = Units.parse(props.y)
          self.units.y = { value = value, unit = unit }
          local parentHeight = self.parent.height
          self.y = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
        else
          -- Apply base scaling to pixel positions
          self.y = Gui.baseScale and (props.y * scaleY) or props.y
          self.units.y = { value = props.y, unit = "px" }
        end
      else
        self.y = 0
        self.units.y = { value = 0, unit = "px" }
      end

      self.z = props.z or 0
    else
      -- Children in flex containers start at parent position but will be repositioned by layoutChildren
      local baseX = self.parent.x
      local baseY = self.parent.y

      if props.x then
        if type(props.x) == "string" then
          local value, unit = Units.parse(props.x)
          self.units.x = { value = value, unit = unit }
          local parentWidth = self.parent.width
          local offsetX = Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
          self.x = baseX + offsetX
        else
          -- Apply base scaling to pixel offsets
          local scaledOffset = Gui.baseScale and (props.x * scaleX) or props.x
          self.x = baseX + scaledOffset
          self.units.x = { value = props.x, unit = "px" }
        end
      else
        self.x = baseX
        self.units.x = { value = 0, unit = "px" }
      end

      if props.y then
        if type(props.y) == "string" then
          local value, unit = Units.parse(props.y)
          self.units.y = { value = value, unit = unit }
          local parentHeight = self.parent.height
          local offsetY = Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
          self.y = baseY + offsetY
        else
          -- Apply base scaling to pixel offsets
          local scaledOffset = Gui.baseScale and (props.y * scaleY) or props.y
          self.y = baseY + scaledOffset
          self.units.y = { value = props.y, unit = "px" }
        end
      else
        self.y = baseY
        self.units.y = { value = 0, unit = "px" }
      end

      self.z = props.z or self.parent.z or 0
    end

    -- Set textColor with priority: props > parent > theme text color > black
    if props.textColor then
      self.textColor = props.textColor
    elseif self.parent.textColor then
      self.textColor = self.parent.textColor
    else
      -- Try to get text color from theme
      local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
      if themeToUse and themeToUse.colors and themeToUse.colors.text then
        self.textColor = themeToUse.colors.text
      else
        -- Fallback to black
        self.textColor = Color.new(0, 0, 0, 1)
      end
    end

    props.parent:addChild(self)
  end

  -- Handle positioning properties for ALL elements (with or without parent)
  -- Handle top positioning with units
  if props.top then
    if type(props.top) == "string" then
      local value, unit = Units.parse(props.top)
      self.units.top = { value = value, unit = unit }
      self.top = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
    else
      self.top = props.top
      self.units.top = { value = props.top, unit = "px" }
    end
  else
    self.top = nil
    self.units.top = nil
  end

  -- Handle right positioning with units
  if props.right then
    if type(props.right) == "string" then
      local value, unit = Units.parse(props.right)
      self.units.right = { value = value, unit = unit }
      self.right = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
    else
      self.right = props.right
      self.units.right = { value = props.right, unit = "px" }
    end
  else
    self.right = nil
    self.units.right = nil
  end

  -- Handle bottom positioning with units
  if props.bottom then
    if type(props.bottom) == "string" then
      local value, unit = Units.parse(props.bottom)
      self.units.bottom = { value = value, unit = unit }
      self.bottom = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
    else
      self.bottom = props.bottom
      self.units.bottom = { value = props.bottom, unit = "px" }
    end
  else
    self.bottom = nil
    self.units.bottom = nil
  end

  -- Handle left positioning with units
  if props.left then
    if type(props.left) == "string" then
      local value, unit = Units.parse(props.left)
      self.units.left = { value = value, unit = unit }
      self.left = Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
    else
      self.left = props.left
      self.units.left = { value = props.left, unit = "px" }
    end
  else
    self.left = nil
    self.units.left = nil
  end

  if self.positioning == Positioning.FLEX then
    self.flexDirection = props.flexDirection or FlexDirection.HORIZONTAL
    self.flexWrap = props.flexWrap or FlexWrap.NOWRAP
    self.justifyContent = props.justifyContent or JustifyContent.FLEX_START
    self.alignItems = props.alignItems or AlignItems.STRETCH
    self.alignContent = props.alignContent or AlignContent.STRETCH
    self.justifySelf = props.justifySelf or JustifySelf.AUTO
  end

  -- Grid container properties
  if self.positioning == Positioning.GRID then
    self.gridRows = props.gridRows or 1
    self.gridColumns = props.gridColumns or 1
    self.alignItems = props.alignItems or AlignItems.STRETCH

    -- Handle columnGap and rowGap
    if props.columnGap then
      if type(props.columnGap) == "string" then
        local value, unit = Units.parse(props.columnGap)
        self.columnGap = Units.resolve(value, unit, viewportWidth, viewportHeight, self.width)
      else
        self.columnGap = props.columnGap
      end
    else
      self.columnGap = 0
    end

    if props.rowGap then
      if type(props.rowGap) == "string" then
        local value, unit = Units.parse(props.rowGap)
        self.rowGap = Units.resolve(value, unit, viewportWidth, viewportHeight, self.height)
      else
        self.rowGap = props.rowGap
      end
    else
      self.rowGap = 0
    end
  end

  self.alignSelf = props.alignSelf or AlignSelf.AUTO

  ---animation
  self.transform = props.transform or {}
  self.transition = props.transition or {}

  -- Overflow and scroll properties
  self.overflow = props.overflow or "hidden"
  self.overflowX = props.overflowX
  self.overflowY = props.overflowY

  -- Scrollbar configuration
  self.scrollbarWidth = props.scrollbarWidth or 12
  self.scrollbarColor = props.scrollbarColor or Color.new(0.5, 0.5, 0.5, 0.8)
  self.scrollbarTrackColor = props.scrollbarTrackColor or Color.new(0.2, 0.2, 0.2, 0.5)
  self.scrollbarRadius = props.scrollbarRadius or 6
  self.scrollbarPadding = props.scrollbarPadding or 2
  self.scrollSpeed = props.scrollSpeed or 20

  -- hideScrollbars can be boolean or table {vertical: boolean, horizontal: boolean}
  if props.hideScrollbars ~= nil then
    if type(props.hideScrollbars) == "boolean" then
      self.hideScrollbars = { vertical = props.hideScrollbars, horizontal = props.hideScrollbars }
    elseif type(props.hideScrollbars) == "table" then
      self.hideScrollbars = {
        vertical = props.hideScrollbars.vertical ~= nil and props.hideScrollbars.vertical or false,
        horizontal = props.hideScrollbars.horizontal ~= nil and props.hideScrollbars.horizontal or false,
      }
    else
      self.hideScrollbars = { vertical = false, horizontal = false }
    end
  else
    self.hideScrollbars = { vertical = false, horizontal = false }
  end

  -- Internal overflow state
  self._overflowX = false
  self._overflowY = false
  self._contentWidth = 0
  self._contentHeight = 0

  -- Scroll state (can be restored from props in immediate mode)
  self._scrollX = props._scrollX or 0
  self._scrollY = props._scrollY or 0
  self._maxScrollX = 0
  self._maxScrollY = 0

  -- Scrollbar interaction state
  self._scrollbarHoveredVertical = false
  self._scrollbarHoveredHorizontal = false
  self._scrollbarDragging = false
  self._hoveredScrollbar = nil -- "vertical" or "horizontal"
  self._scrollbarDragOffset = 0 -- Offset from thumb top when drag started
  self._scrollbarPressHandled = false -- Track if scrollbar press was handled this frame

  -- ============================================
  -- Initialize Manager Modules
  -- ============================================

  -- Initialize ThemeManager if using theme component
  if self.themeComponent then
    self._themeManager = ThemeManager.new({
      theme = self.theme,
      themeComponent = self.themeComponent,
      scaleCorners = self.scaleCorners,
      scalingAlgorithm = self.scalingAlgorithm,
    })
    self._themeManager:initialize(self)
  end

  -- Initialize LayoutEngine
  self._layoutEngine = LayoutEngine.new({
    positioning = self.positioning,
    flexDirection = self.flexDirection,
    justifyContent = self.justifyContent,
    alignItems = self.alignItems,
    alignContent = self.alignContent,
    flexWrap = self.flexWrap,
    gridRows = self.gridRows,
    gridColumns = self.gridColumns,
    columnGap = self.columnGap,
    rowGap = self.rowGap,
  })
  self._layoutEngine:initialize(self)

  -- Initialize Renderer
  self._renderer = Renderer.new({
    backgroundColor = self.backgroundColor,
    borderColor = self.borderColor,
    cornerRadius = self.cornerRadius,
    imagePath = self.imagePath,
    image = self.image,
    objectFit = self.objectFit,
    objectPosition = self.objectPosition,
    imageOpacity = self.imageOpacity,
  })
  self._renderer:initialize(self)

  -- Initialize ScrollManager if needed
  if self.overflow ~= "visible" or self.overflowX or self.overflowY then
    self._scrollManager = ScrollManager.new({
      overflow = self.overflow,
      overflowX = self.overflowX,
      overflowY = self.overflowY,
      scrollbarWidth = self.scrollbarWidth,
      scrollbarColor = self.scrollbarColor,
      scrollbarTrackColor = self.scrollbarTrackColor,
      scrollbarRadius = self.scrollbarRadius,
      scrollbarPadding = self.scrollbarPadding,
      scrollSpeed = self.scrollSpeed,
      hideScrollbars = self.hideScrollbars,
    })
    self._scrollManager:initialize(self)
  end

  -- Initialize TextEditor if editable
  if self.editable then
    self._textEditor = TextEditor.new({
      text = props.text or "",
      editable = self.editable,
      multiline = self.multiline,
      passwordMode = self.passwordMode,
      textWrap = self.textWrap,
      maxLines = self.maxLines,
      maxLength = self.maxLength,
      placeholder = self.placeholder,
      inputType = self.inputType,
      textOverflow = self.textOverflow,
      scrollable = self.scrollable,
      autoGrow = self.autoGrow,
      selectOnFocus = self.selectOnFocus,
      cursorColor = self.cursorColor,
      selectionColor = self.selectionColor,
      cursorBlinkRate = self.cursorBlinkRate,
    })
    self._textEditor:initialize(self)
  end

  -- Initialize EventHandler
  self._eventHandler = EventHandler.new({})
  self._eventHandler:initialize(self)

  -- Register element in z-index tracking for immediate mode
  if Gui._immediateMode then
    GuiState.registerElement(self)
  end

  return self
end

-- ============================================
-- Delegation Methods (Auto-generated)
-- ============================================

function Element:_detectOverflow()
  -- Reset overflow state
  self._overflowX = false
  self._overflowY = false
  self._contentWidth = self.width
  self._contentHeight = self.height

  -- Skip detection if overflow is visible (no clipping needed)
  local overflowX = self.overflowX or self.overflow
  local overflowY = self.overflowY or self.overflow
  if overflowX == "visible" and overflowY == "visible" then
    return
  end

  -- Calculate content bounds based on children
  if #self.children == 0 then
    return -- No children, no overflow
  end

  local minX, minY = 0, 0
  local maxX, maxY = 0, 0

  -- Content area starts after padding
  local contentX = self.x + self.padding.left
  local contentY = self.y + self.padding.top

  for _, child in ipairs(self.children) do
    -- Skip absolutely positioned children (they don't contribute to overflow)
    if not child._explicitlyAbsolute then
      -- Calculate child position relative to content area
      local childLeft = child.x - contentX
      local childTop = child.y - contentY
      local childRight = childLeft + child:getBorderBoxWidth() + child.margin.right
      local childBottom = childTop + child:getBorderBoxHeight() + child.margin.bottom

      maxX = math.max(maxX, childRight)
      maxY = math.max(maxY, childBottom)
    end
  end

  -- Calculate content dimensions
  self._contentWidth = maxX
  self._contentHeight = maxY

  -- Detect overflow
  local containerWidth = self.width
  local containerHeight = self.height

  self._overflowX = self._contentWidth > containerWidth
  self._overflowY = self._contentHeight > containerHeight

  -- Calculate maximum scroll bounds
  self._maxScrollX = math.max(0, self._contentWidth - containerWidth)
  self._maxScrollY = math.max(0, self._contentHeight - containerHeight)

  -- Clamp current scroll position to new bounds
  -- Note: Scroll position is already restored in Gui.new() from ImmediateModeState
  self._scrollX = math.max(0, math.min(self._scrollX, self._maxScrollX))
  self._scrollY = math.max(0, math.min(self._scrollY, self._maxScrollY))
end

function Element:setScrollPosition(x, y)
  if self._scrollManager then
    self._scrollManager:setScroll(x, y)
  end
end

function Element:_calculateScrollbarDimensions()
  if self._scrollManager then
    return self._scrollManager:calculateScrollbarDimensions()
  end
  return {
    vertical = { visible = false, trackHeight = 0, thumbHeight = 0, thumbY = 0 },
    horizontal = { visible = false, trackWidth = 0, thumbWidth = 0, thumbX = 0 },
  }
end

function Element:_drawScrollbars(dims)
  if self._scrollManager then
    return self._scrollManager:_drawScrollbars(dims)
  end
end

function Element:_getScrollbarAtPosition(mouseX, mouseY)
  if self._scrollManager then
    return self._scrollManager:_getScrollbarAtPosition(mouseX, mouseY)
  end
end

function Element:_handleScrollbarPress(mouseX, mouseY, button)
  if self._scrollManager then
    return self._scrollManager:handleMousePress(mouseX, mouseY, button)
  end
  return false
end

function Element:_handleScrollbarDrag(mouseX, mouseY)
  if self._scrollManager then
    return self._scrollManager:handleMouseMove(mouseX, mouseY)
  end
  return false
end

function Element:_handleScrollbarRelease(button)
  if self._scrollManager then
    return self._scrollManager:handleMouseRelease(nil, nil, button)
  end
  return false
end

function Element:_scrollToTrackPosition(mouseX, mouseY, component)
  if self._scrollManager then
    return self._scrollManager:_scrollToTrackPosition(mouseX, mouseY, component)
  end
end

function Element:_handleWheelScroll(x, y)
  if self._scrollManager then
    return self._scrollManager:handleWheel(x, y)
  end
  return false
end

function Element:getScrollPosition()
  if self._scrollManager then
    return self._scrollManager:getScroll()
  end
  return 0, 0
end

function Element:getMaxScroll()
  if self._scrollManager then
    local _, _, maxScrollX, maxScrollY = self._scrollManager:getContentBounds()
    return maxScrollX, maxScrollY
  end
  return 0, 0
end

function Element:getScrollPercentage()
  if self._scrollManager then
    local scrollX, scrollY = self._scrollManager:getScroll()
    local _, _, maxScrollX, maxScrollY = self._scrollManager:getContentBounds()
    local percentX = maxScrollX > 0 and (scrollX / maxScrollX) or 0
    local percentY = maxScrollY > 0 and (scrollY / maxScrollY) or 0
    return percentX, percentY
  end
  return 0, 0
end

function Element:hasOverflow()
  return self._overflowX, self._overflowY
end

function Element:getContentSize()
  if self._scrollManager then
    local contentWidth, contentHeight = self._scrollManager:getContentBounds()
    return contentWidth, contentHeight
  end
  return self.width, self.height
end

function Element:scrollBy(dx, dy)
  if self._scrollManager then
    self._scrollManager:scroll(dx, dy)
  end
end

function Element:scrollToTop()
  self:setScrollPosition(nil, 0)
end

function Element:scrollToBottom()
  if self._scrollManager then
    local _, _, _, maxScrollY = self._scrollManager:getContentBounds()
    self:setScrollPosition(nil, maxScrollY)
  end
end

function Element:scrollToLeft()
  self:setScrollPosition(0, nil)
end

function Element:scrollToRight()
  if self._scrollManager then
    local _, _, maxScrollX = self._scrollManager:getContentBounds()
    self:setScrollPosition(maxScrollX, nil)
  end
end

function Element:getScaledContentPadding()
  if not self.themeComponent then
    return nil
  end

  local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
  if not themeToUse or not themeToUse.components[self.themeComponent] then
    return nil
  end

  local component = themeToUse.components[self.themeComponent]

  -- Check for state-specific override
  local state = self._themeState or "normal"
  if state and state ~= "normal" and component.states and component.states[state] then
    component = component.states[state]
  end

  if not component._ninePatchData or not component._ninePatchData.contentPadding then
    return nil
  end

  local contentPadding = component._ninePatchData.contentPadding

  -- Scale contentPadding to match the actual rendered size
  local atlasImage = component._loadedAtlas or themeToUse.atlas
  if atlasImage and type(atlasImage) ~= "string" then
    local originalWidth, originalHeight = atlasImage:getDimensions()
    local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
    local borderBoxHeight = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)
    local scaleX = borderBoxWidth / originalWidth
    local scaleY = borderBoxHeight / originalHeight

    return {
      left = contentPadding.left * scaleX,
      top = contentPadding.top * scaleY,
      right = contentPadding.right * scaleX,
      bottom = contentPadding.bottom * scaleY,
    }
  else
    -- Return unscaled values as fallback
    return {
      left = contentPadding.left,
      top = contentPadding.top,
      right = contentPadding.right,
      bottom = contentPadding.bottom,
    }
  end
end

function Element:getBlurInstance()
  -- Determine quality from contentBlur or backdropBlur
  local quality = 5 -- Default quality
  if self.contentBlur and self.contentBlur.quality then
    quality = self.contentBlur.quality
  elseif self.backdropBlur and self.backdropBlur.quality then
    quality = self.backdropBlur.quality
  end

  -- Create blur instance if needed
  if not self._blurInstance or self._blurInstance.quality ~= quality then
    self._blurInstance = Blur.new(quality)
  end

  return self._blurInstance
end

function Element:getAvailableContentWidth()
  if self._layoutEngine then
    return self._layoutEngine:getAvailableContentWidth()
  end
end

function Element:getAvailableContentHeight()
  if self._layoutEngine then
    return self._layoutEngine:getAvailableContentHeight()
  end
end

function Element:addChild(child)
  child.parent = self

  -- Re-evaluate positioning now that we have a parent
  -- If child was created without explicit positioning, inherit from parent
  if child._originalPositioning == nil then
    -- No explicit positioning was set during construction
    if self.positioning == Positioning.FLEX or self.positioning == Positioning.GRID then
      child.positioning = Positioning.ABSOLUTE -- They are positioned BY flex/grid, not AS flex/grid
      child._explicitlyAbsolute = false -- Participate in parent's layout
    else
      child.positioning = Positioning.RELATIVE
      child._explicitlyAbsolute = false -- Default for relative/absolute containers
    end
  end
  -- If child._originalPositioning is set, it means explicit positioning was provided
  -- and _explicitlyAbsolute was already set correctly during construction

  table.insert(self.children, child)

  -- Only recalculate auto-sizing if the child participates in layout
  -- (CSS: absolutely positioned children don't affect parent auto-sizing)
  if not child._explicitlyAbsolute then
    local sizeChanged = false

    if self.autosizing.height then
      local oldHeight = self.height
      local contentHeight = self:calculateAutoHeight()
      -- BORDER-BOX MODEL: Add padding to get border-box, then subtract to get content
      self._borderBoxHeight = contentHeight + self.padding.top + self.padding.bottom
      self.height = contentHeight
      if oldHeight ~= self.height then
        sizeChanged = true
      end
    end
    if self.autosizing.width then
      local oldWidth = self.width
      local contentWidth = self:calculateAutoWidth()
      -- BORDER-BOX MODEL: Add padding to get border-box, then subtract to get content
      self._borderBoxWidth = contentWidth + self.padding.left + self.padding.right
      self.width = contentWidth
      if oldWidth ~= self.width then
        sizeChanged = true
      end
    end

    -- Propagate size change up the tree
    if sizeChanged and self.parent and (self.parent.autosizing.width or self.parent.autosizing.height) then
      -- Trigger parent to recalculate its size by re-adding this child's contribution
      -- This ensures grandparents are notified of size changes
      if self.parent.autosizing.height then
        local contentHeight = self.parent:calculateAutoHeight()
        self.parent._borderBoxHeight = contentHeight + self.parent.padding.top + self.parent.padding.bottom
        self.parent.height = contentHeight
      end
      if self.parent.autosizing.width then
        local contentWidth = self.parent:calculateAutoWidth()
        self.parent._borderBoxWidth = contentWidth + self.parent.padding.left + self.parent.padding.right
        self.parent.width = contentWidth
      end
    end
  end

  -- In immediate mode, defer layout until endFrame() when all elements are created
  -- This prevents premature overflow detection with incomplete children
  if not Gui._immediateMode then
    self:layoutChildren()
  end
end

function Element:applyPositioningOffsets(element)
  if self._layoutEngine then
    return self._layoutEngine:applyPositioningOffsets(element)
  end
end

function Element:layoutChildren()
  if self._layoutEngine then
    return self._layoutEngine:layoutChildren()
  end
end

function Element:destroy()
  -- Remove from global elements list
  for i, win in ipairs(Gui.topElements) do
    if win == self then
      table.remove(Gui.topElements, i)
      break
    end
  end

  if self.parent then
    for i, child in ipairs(self.parent.children) do
      if child == self then
        table.remove(self.parent.children, i)
        break
      end
    end
    self.parent = nil
  end

  -- Destroy all children
  for _, child in ipairs(self.children) do
    child:destroy()
  end

  -- Clear children table
  self.children = {}

  -- Clear parent reference
  if self.parent then
    self.parent = nil
  end

  -- Clear animation reference
  self.animation = nil
end

function Element:draw(backdropCanvas)
  if self._renderer then
    return self._renderer:draw(backdropCanvas)
  end
end

function Element:update(dt)
  if self._eventHandler then
    return self._eventHandler:update(dt)
  end
end

function Element:recalculateUnits(newViewportWidth, newViewportHeight)
  -- Get updated scale factors
  local scaleX, scaleY = Gui.getScaleFactors()

  -- Recalculate border-box width if using viewport or percentage units (skip auto-sized)
  -- Store in _borderBoxWidth temporarily, will calculate content width after padding is resolved
  if self.units.width.unit ~= "px" and self.units.width.unit ~= "auto" then
    local parentWidth = self.parent and self.parent.width or newViewportWidth
    self._borderBoxWidth = Units.resolve(self.units.width.value, self.units.width.unit, newViewportWidth, newViewportHeight, parentWidth)
  elseif self.units.width.unit == "px" and self.units.width.value and Gui.baseScale then
    -- Reapply base scaling to pixel widths (border-box)
    self._borderBoxWidth = self.units.width.value * scaleX
  end

  -- Recalculate border-box height if using viewport or percentage units (skip auto-sized)
  -- Store in _borderBoxHeight temporarily, will calculate content height after padding is resolved
  if self.units.height.unit ~= "px" and self.units.height.unit ~= "auto" then
    local parentHeight = self.parent and self.parent.height or newViewportHeight
    self._borderBoxHeight = Units.resolve(self.units.height.value, self.units.height.unit, newViewportWidth, newViewportHeight, parentHeight)
  elseif self.units.height.unit == "px" and self.units.height.value and Gui.baseScale then
    -- Reapply base scaling to pixel heights (border-box)
    self._borderBoxHeight = self.units.height.value * scaleY
  end

  -- Recalculate position if using viewport or percentage units
  if self.units.x.unit ~= "px" then
    local parentWidth = self.parent and self.parent.width or newViewportWidth
    local baseX = self.parent and self.parent.x or 0
    local offsetX = Units.resolve(self.units.x.value, self.units.x.unit, newViewportWidth, newViewportHeight, parentWidth)
    self.x = baseX + offsetX
  else
    -- For pixel units, update position relative to parent's new position (with base scaling)
    if self.parent then
      local baseX = self.parent.x
      local scaledOffset = Gui.baseScale and (self.units.x.value * scaleX) or self.units.x.value
      self.x = baseX + scaledOffset
    elseif Gui.baseScale then
      -- Top-level element with pixel position - apply base scaling
      self.x = self.units.x.value * scaleX
    end
  end

  if self.units.y.unit ~= "px" then
    local parentHeight = self.parent and self.parent.height or newViewportHeight
    local baseY = self.parent and self.parent.y or 0
    local offsetY = Units.resolve(self.units.y.value, self.units.y.unit, newViewportWidth, newViewportHeight, parentHeight)
    self.y = baseY + offsetY
  else
    -- For pixel units, update position relative to parent's new position (with base scaling)
    if self.parent then
      local baseY = self.parent.y
      local scaledOffset = Gui.baseScale and (self.units.y.value * scaleY) or self.units.y.value
      self.y = baseY + scaledOffset
    elseif Gui.baseScale then
      -- Top-level element with pixel position - apply base scaling
      self.y = self.units.y.value * scaleY
    end
  end

  -- Recalculate textSize if auto-scaling is enabled or using viewport/element-relative units
  if self.autoScaleText and self.units.textSize.value then
    local unit = self.units.textSize.unit
    local value = self.units.textSize.value

    if unit == "px" and Gui.baseScale then
      -- With base scaling: scale pixel values relative to base resolution
      self.textSize = value * scaleY
    elseif unit == "px" then
      -- Without base scaling but auto-scaling enabled: text doesn't scale
      self.textSize = value
    elseif unit == "%" or unit == "vh" then
      -- Percentage and vh are relative to viewport height
      self.textSize = Units.resolve(value, unit, newViewportWidth, newViewportHeight, newViewportHeight)
    elseif unit == "vw" then
      -- vw is relative to viewport width
      self.textSize = Units.resolve(value, unit, newViewportWidth, newViewportHeight, newViewportWidth)
    elseif unit == "ew" then
      -- Element width relative
      self.textSize = (value / 100) * self.width
    elseif unit == "eh" then
      -- Element height relative
      self.textSize = (value / 100) * self.height
    else
      self.textSize = Units.resolve(value, unit, newViewportWidth, newViewportHeight, nil)
    end

    -- Apply min/max constraints (with base scaling)
    local minSize = self.minTextSize and (Gui.baseScale and (self.minTextSize * scaleY) or self.minTextSize)
    local maxSize = self.maxTextSize and (Gui.baseScale and (self.maxTextSize * scaleY) or self.maxTextSize)

    if minSize and self.textSize < minSize then
      self.textSize = minSize
    end
    if maxSize and self.textSize > maxSize then
      self.textSize = maxSize
    end

    -- Protect against too-small text sizes (minimum 1px)
    if self.textSize < 1 then
      self.textSize = 1 -- Minimum 1px
    end
  elseif self.units.textSize.unit == "px" and self.units.textSize.value and Gui.baseScale then
    -- No auto-scaling but base scaling is set: reapply base scaling to pixel text sizes
    self.textSize = self.units.textSize.value * scaleY

    -- Protect against too-small text sizes (minimum 1px)
    if self.textSize < 1 then
      self.textSize = 1 -- Minimum 1px
    end
  end

  -- Final protection: ensure textSize is always at least 1px (catches all edge cases)
  if self.text and self.textSize and self.textSize < 1 then
    self.textSize = 1 -- Minimum 1px
  end

  -- Recalculate gap if using viewport or percentage units
  if self.units.gap.unit ~= "px" then
    local containerSize = (self.flexDirection == FlexDirection.HORIZONTAL) and (self.parent and self.parent.width or newViewportWidth)
      or (self.parent and self.parent.height or newViewportHeight)
    self.gap = Units.resolve(self.units.gap.value, self.units.gap.unit, newViewportWidth, newViewportHeight, containerSize)
  end

  -- Recalculate spacing (padding/margin) if using viewport or percentage units
  -- For percentage-based padding:
  -- - If element has a parent: use parent's border-box dimensions (CSS spec for child elements)
  -- - If element has no parent: use element's own border-box dimensions (CSS spec for root elements)
  local parentBorderBoxWidth = self.parent and self.parent._borderBoxWidth or self._borderBoxWidth or newViewportWidth
  local parentBorderBoxHeight = self.parent and self.parent._borderBoxHeight or self._borderBoxHeight or newViewportHeight

  -- Handle shorthand properties first (horizontal/vertical)
  local resolvedHorizontalPadding = nil
  local resolvedVerticalPadding = nil

  if self.units.padding.horizontal and self.units.padding.horizontal.unit ~= "px" then
    resolvedHorizontalPadding =
      Units.resolve(self.units.padding.horizontal.value, self.units.padding.horizontal.unit, newViewportWidth, newViewportHeight, parentBorderBoxWidth)
  elseif self.units.padding.horizontal and self.units.padding.horizontal.value then
    resolvedHorizontalPadding = self.units.padding.horizontal.value
  end

  if self.units.padding.vertical and self.units.padding.vertical.unit ~= "px" then
    resolvedVerticalPadding =
      Units.resolve(self.units.padding.vertical.value, self.units.padding.vertical.unit, newViewportWidth, newViewportHeight, parentBorderBoxHeight)
  elseif self.units.padding.vertical and self.units.padding.vertical.value then
    resolvedVerticalPadding = self.units.padding.vertical.value
  end

  -- Resolve individual padding sides (with fallback to shorthand)
  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    -- Check if this side was explicitly set or if we should use shorthand
    local useShorthand = false
    if not self.units.padding[side].explicit then
      -- Not explicitly set, check if we have shorthand
      if side == "left" or side == "right" then
        useShorthand = resolvedHorizontalPadding ~= nil
      elseif side == "top" or side == "bottom" then
        useShorthand = resolvedVerticalPadding ~= nil
      end
    end

    if useShorthand then
      -- Use shorthand value
      if side == "left" or side == "right" then
        self.padding[side] = resolvedHorizontalPadding
      else
        self.padding[side] = resolvedVerticalPadding
      end
    elseif self.units.padding[side].unit ~= "px" then
      -- Recalculate non-pixel units
      local parentSize = (side == "top" or side == "bottom") and parentBorderBoxHeight or parentBorderBoxWidth
      self.padding[side] = Units.resolve(self.units.padding[side].value, self.units.padding[side].unit, newViewportWidth, newViewportHeight, parentSize)
    end
    -- If unit is "px" and not using shorthand, value stays the same
  end

  -- Handle margin shorthand properties
  local resolvedHorizontalMargin = nil
  local resolvedVerticalMargin = nil

  if self.units.margin.horizontal and self.units.margin.horizontal.unit ~= "px" then
    resolvedHorizontalMargin =
      Units.resolve(self.units.margin.horizontal.value, self.units.margin.horizontal.unit, newViewportWidth, newViewportHeight, parentBorderBoxWidth)
  elseif self.units.margin.horizontal and self.units.margin.horizontal.value then
    resolvedHorizontalMargin = self.units.margin.horizontal.value
  end

  if self.units.margin.vertical and self.units.margin.vertical.unit ~= "px" then
    resolvedVerticalMargin =
      Units.resolve(self.units.margin.vertical.value, self.units.margin.vertical.unit, newViewportWidth, newViewportHeight, parentBorderBoxHeight)
  elseif self.units.margin.vertical and self.units.margin.vertical.value then
    resolvedVerticalMargin = self.units.margin.vertical.value
  end

  -- Resolve individual margin sides (with fallback to shorthand)
  for _, side in ipairs({ "top", "right", "bottom", "left" }) do
    -- Check if this side was explicitly set or if we should use shorthand
    local useShorthand = false
    if not self.units.margin[side].explicit then
      -- Not explicitly set, check if we have shorthand
      if side == "left" or side == "right" then
        useShorthand = resolvedHorizontalMargin ~= nil
      elseif side == "top" or side == "bottom" then
        useShorthand = resolvedVerticalMargin ~= nil
      end
    end

    if useShorthand then
      -- Use shorthand value
      if side == "left" or side == "right" then
        self.margin[side] = resolvedHorizontalMargin
      else
        self.margin[side] = resolvedVerticalMargin
      end
    elseif self.units.margin[side].unit ~= "px" then
      -- Recalculate non-pixel units
      local parentSize = (side == "top" or side == "bottom") and parentBorderBoxHeight or parentBorderBoxWidth
      self.margin[side] = Units.resolve(self.units.margin[side].value, self.units.margin[side].unit, newViewportWidth, newViewportHeight, parentSize)
    end
    -- If unit is "px" and not using shorthand, value stays the same
  end

  -- BORDER-BOX MODEL: Calculate content dimensions from border-box dimensions
  -- For explicitly-sized elements (non-auto), _borderBoxWidth/_borderBoxHeight were set earlier
  -- Now we calculate content width/height by subtracting padding
  -- Only recalculate if using viewport/percentage units (where _borderBoxWidth actually changed)
  if self.units.width.unit ~= "auto" and self.units.width.unit ~= "px" then
    -- _borderBoxWidth was recalculated for viewport/percentage units
    -- Calculate content width by subtracting padding
    self.width = math.max(0, self._borderBoxWidth - self.padding.left - self.padding.right)
  elseif self.units.width.unit == "auto" then
    -- For auto-sized elements, width is content width (calculated in resize method)
    -- Update border-box to include padding
    self._borderBoxWidth = self.width + self.padding.left + self.padding.right
  end
  -- For pixel units, width stays as-is (may have been manually modified)

  if self.units.height.unit ~= "auto" and self.units.height.unit ~= "px" then
    -- _borderBoxHeight was recalculated for viewport/percentage units
    -- Calculate content height by subtracting padding
    self.height = math.max(0, self._borderBoxHeight - self.padding.top - self.padding.bottom)
  elseif self.units.height.unit == "auto" then
    -- For auto-sized elements, height is content height (calculated in resize method)
    -- Update border-box to include padding
    self._borderBoxHeight = self.height + self.padding.top + self.padding.bottom
  end
  -- For pixel units, height stays as-is (may have been manually modified)

  -- Detect overflow after layout calculations
  self:_detectOverflow()
end

function Element:resize(newGameWidth, newGameHeight)
  self:recalculateUnits(newGameWidth, newGameHeight)

  -- For non-auto-sized elements with viewport/percentage units, update content dimensions from border-box
  if not self.autosizing.width and self._borderBoxWidth and self.units.width.unit ~= "px" then
    self.width = math.max(0, self._borderBoxWidth - self.padding.left - self.padding.right)
  end
  if not self.autosizing.height and self._borderBoxHeight and self.units.height.unit ~= "px" then
    self.height = math.max(0, self._borderBoxHeight - self.padding.top - self.padding.bottom)
  end

  -- Update children
  for _, child in ipairs(self.children) do
    child:resize(newGameWidth, newGameHeight)
  end

  -- Recalculate auto-sized dimensions after children are resized
  if self.autosizing.width then
    local contentWidth = self:calculateAutoWidth()
    -- BORDER-BOX MODEL: Add padding to get border-box, then subtract to get content
    self._borderBoxWidth = contentWidth + self.padding.left + self.padding.right
    self.width = contentWidth
  end
  if self.autosizing.height then
    local contentHeight = self:calculateAutoHeight()
    -- BORDER-BOX MODEL: Add padding to get border-box, then subtract to get content
    self._borderBoxHeight = contentHeight + self.padding.top + self.padding.bottom
    self.height = contentHeight
  end

  -- Re-resolve ew/eh textSize units after all dimensions are finalized
  -- This ensures textSize updates based on current width/height (whether calculated or manually set)
  if self.units.textSize.value then
    local unit = self.units.textSize.unit
    local value = self.units.textSize.value
    local _, scaleY = Gui.getScaleFactors()

    if unit == "ew" then
      -- Element width relative (use current width)
      self.textSize = (value / 100) * self.width

      -- Apply min/max constraints
      local minSize = self.minTextSize and (Gui.baseScale and (self.minTextSize * scaleY) or self.minTextSize)
      local maxSize = self.maxTextSize and (Gui.baseScale and (self.maxTextSize * scaleY) or self.maxTextSize)
      if minSize and self.textSize < minSize then
        self.textSize = minSize
      end
      if maxSize and self.textSize > maxSize then
        self.textSize = maxSize
      end
      if self.textSize < 1 then
        self.textSize = 1
      end
    elseif unit == "eh" then
      -- Element height relative (use current height)
      self.textSize = (value / 100) * self.height

      -- Apply min/max constraints
      local minSize = self.minTextSize and (Gui.baseScale and (self.minTextSize * scaleY) or self.minTextSize)
      local maxSize = self.maxTextSize and (Gui.baseScale and (self.maxTextSize * scaleY) or self.maxTextSize)
      if minSize and self.textSize < minSize then
        self.textSize = minSize
      end
      if maxSize and self.textSize > maxSize then
        self.textSize = maxSize
      end
      if self.textSize < 1 then
        self.textSize = 1
      end
    end
  end

  self:layoutChildren()
  self.prevGameSize.width = newGameWidth
  self.prevGameSize.height = newGameHeight
end

function Element:updateText(newText, autoresize)
  self.text = newText
  if self._textEditor then
    self._textEditor:setText(newText)
  end
  -- TODO: Handle autoresize parameter if needed
end

function Element:updateOpacity(newOpacity)
  self.opacity = newOpacity
  for _, child in ipairs(self.children) do
    child:updateOpacity(newOpacity)
  end
end

--- same as calling updateOpacity(0)
function Element:hide()
  self:updateOpacity(0)
end

--- same as calling updateOpacity(1)
function Element:show()
  self:updateOpacity(1)
end

function Element:setCursorPosition(position)
  if self._textEditor then
    return self._textEditor:setCursorPosition(position)
  end
end

function Element:getCursorPosition()
  if self._textEditor then
    return self._textEditor:getCursorPosition()
  end
end

function Element:moveCursorBy(delta)
  if self._textEditor then
    return self._textEditor:moveCursorBy(delta)
  end
end

function Element:moveCursorToStart()
  if self._textEditor then
    return self._textEditor:moveCursorToStart()
  end
end

function Element:moveCursorToEnd()
  if self._textEditor then
    return self._textEditor:moveCursorToEnd()
  end
end

function Element:moveCursorToLineStart()
  if self._textEditor then
    return self._textEditor:moveCursorToLineStart()
  end
end

function Element:moveCursorToLineEnd()
  if self._textEditor then
    return self._textEditor:moveCursorToLineEnd()
  end
end

function Element:moveCursorToPreviousWord()
  if self._textEditor then
    return self._textEditor:moveCursorToPreviousWord()
  end
end

function Element:moveCursorToNextWord()
  if self._textEditor then
    return self._textEditor:moveCursorToNextWord()
  end
end

function Element:_validateCursorPosition()
  if self._textEditor then
    return self._textEditor:_validateCursorPosition()
  end
end

function Element:_resetCursorBlink(pauseBlink)
  if self._textEditor then
    return self._textEditor:_resetCursorBlink(pauseBlink)
  end
end

function Element:_updateTextScroll()
  if self._textEditor then
    return self._textEditor:_updateTextScroll()
  end
end

function Element:setSelection(startPos, endPos)
  if self._textEditor then
    return self._textEditor:setSelection(startPos, endPos)
  end
end

function Element:getSelection()
  if self._textEditor then
    return self._textEditor:getSelection()
  end
end

function Element:hasSelection()
  if self._textEditor then
    return self._textEditor:hasSelection()
  end
end

function Element:clearSelection()
  if self._textEditor then
    return self._textEditor:clearSelection()
  end
end

function Element:selectAll()
  if self._textEditor then
    return self._textEditor:selectAll()
  end
end

function Element:getSelectedText()
  if self._textEditor then
    return self._textEditor:getSelectedText()
  end
end

function Element:deleteSelection()
  if self._textEditor then
    return self._textEditor:deleteSelection()
  end
end

function Element:focus()
  if self._textEditor then
    return self._textEditor:focus()
  end
end

function Element:blur()
  if self._textEditor then
    return self._textEditor:blur()
  end
end

function Element:isFocused()
  if self._textEditor then
    return self._textEditor:isFocused()
  end
end

function Element:_saveEditableState()
  if self._themeManager then
    return self._themeManager:_saveEditableState()
  end
end

function Element:getText()
  if self._textEditor then
    return self._textEditor:getText()
  end
end

function Element:setText(text)
  if self._textEditor then
    return self._textEditor:setText(text)
  end
end

function Element:insertText(text, position)
  if self._textEditor then
    return self._textEditor:insertText(text, position)
  end
end

function Element:deleteText(startPos, endPos)
  if self._textEditor then
    return self._textEditor:deleteText(startPos, endPos)
  end
end

function Element:replaceText(startPos, endPos, newText)
  if self._textEditor then
    return self._textEditor:replaceText(startPos, endPos, newText)
  end
end

function Element:_markTextDirty()
  if self._textEditor then
    return self._textEditor:_markTextDirty()
  end
end

function Element:_updateTextIfDirty()
  if self._textEditor then
    return self._textEditor:_updateTextIfDirty()
  end
end

function Element:_splitLines()
  if not self.editable then
    return
  end

  if not self.multiline then
    self._lines = { self._textBuffer or "" }
    return
  end

  self._lines = {}
  local text = self._textBuffer or ""

  -- Split on newlines
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(self._lines, line)
  end

  -- Ensure at least one line
  if #self._lines == 0 then
    self._lines = { "" }
  end
end

--- Calculate text wrapping
function Element:_calculateWrapping()
  if not self.editable or not self.textWrap then
    self._wrappedLines = nil
    return
  end

  self._wrappedLines = {}
  local availableWidth = self.width - self.padding.left - self.padding.right

  for lineNum, line in ipairs(self._lines or {}) do
    if line == "" then
      table.insert(self._wrappedLines, {
        text = "",
        startIdx = 0,
        endIdx = 0,
        lineNum = lineNum,
      })
    else
      local wrappedParts = self:_wrapLine(line, availableWidth)
      for _, part in ipairs(wrappedParts) do
        part.lineNum = lineNum
        table.insert(self._wrappedLines, part)
      end
    end
  end
end

--- Wrap a single line of text
---@param line string -- Line to wrap
---@param maxWidth number -- Maximum width in pixels
---@return table -- Array of wrapped line parts
function Element:_wrapLine(line, maxWidth)
  if not self.editable then
    return { { text = line, startIdx = 0, endIdx = utf8.len(line) } }
  end

  local font = self:_getFont()
  local wrappedParts = {}
  local currentLine = ""
  local startIdx = 0

  -- Helper function to extract a UTF-8 character by character index
  local function getUtf8Char(str, charIndex)
    local byteStart = utf8.offset(str, charIndex)
    if not byteStart then
      return ""
    end
    local byteEnd = utf8.offset(str, charIndex + 1)
    if byteEnd then
      return str:sub(byteStart, byteEnd - 1)
    else
      return str:sub(byteStart)
    end
  end

  if self.textWrap == "word" then
    -- Tokenize into words and whitespace, preserving exact spacing
    local tokens = {}
    local pos = 1
    local lineLen = utf8.len(line)

    while pos <= lineLen do
      -- Check if current position is whitespace
      local char = getUtf8Char(line, pos)
      if char:match("%s") then
        -- Collect whitespace sequence
        local wsStart = pos
        while pos <= lineLen and getUtf8Char(line, pos):match("%s") do
          pos = pos + 1
        end
        table.insert(tokens, {
          type = "space",
          text = line:sub(utf8.offset(line, wsStart), utf8.offset(line, pos) and utf8.offset(line, pos) - 1 or #line),
          startPos = wsStart - 1,
          length = pos - wsStart,
        })
      else
        -- Collect word (non-whitespace sequence)
        local wordStart = pos
        while pos <= lineLen and not getUtf8Char(line, pos):match("%s") do
          pos = pos + 1
        end
        table.insert(tokens, {
          type = "word",
          text = line:sub(utf8.offset(line, wordStart), utf8.offset(line, pos) and utf8.offset(line, pos) - 1 or #line),
          startPos = wordStart - 1,
          length = pos - wordStart,
        })
      end
    end

    -- Process tokens and wrap
    local charPos = 0 -- Track our position in the original line
    for i, token in ipairs(tokens) do
      if token.type == "word" then
        local testLine = currentLine .. token.text
        local width = font:getWidth(testLine)

        if width > maxWidth and currentLine ~= "" then
          -- Current line is full, wrap before this word
          local currentLineLen = utf8.len(currentLine)
          table.insert(wrappedParts, {
            text = currentLine,
            startIdx = startIdx,
            endIdx = startIdx + currentLineLen,
          })
          startIdx = charPos
          currentLine = token.text
          charPos = charPos + token.length

          -- Check if the word itself is too long - if so, break it with character wrapping
          if font:getWidth(token.text) > maxWidth then
            local wordLen = utf8.len(token.text)
            local charLine = ""
            local charStartIdx = startIdx

            for j = 1, wordLen do
              local char = getUtf8Char(token.text, j)
              local testCharLine = charLine .. char
              local charWidth = font:getWidth(testCharLine)

              if charWidth > maxWidth and charLine ~= "" then
                table.insert(wrappedParts, {
                  text = charLine,
                  startIdx = charStartIdx,
                  endIdx = charStartIdx + utf8.len(charLine),
                })
                charStartIdx = charStartIdx + utf8.len(charLine)
                charLine = char
              else
                charLine = testCharLine
              end
            end

            currentLine = charLine
            startIdx = charStartIdx
          end
        elseif width > maxWidth and currentLine == "" then
          -- Word is too long to fit on a line by itself - use character wrapping
          local wordLen = utf8.len(token.text)
          local charLine = ""
          local charStartIdx = startIdx

          for j = 1, wordLen do
            local char = getUtf8Char(token.text, j)
            local testCharLine = charLine .. char
            local charWidth = font:getWidth(testCharLine)

            if charWidth > maxWidth and charLine ~= "" then
              table.insert(wrappedParts, {
                text = charLine,
                startIdx = charStartIdx,
                endIdx = charStartIdx + utf8.len(charLine),
              })
              charStartIdx = charStartIdx + utf8.len(charLine)
              charLine = char
            else
              charLine = testCharLine
            end
          end

          currentLine = charLine
          startIdx = charStartIdx
          charPos = charPos + token.length
        else
          currentLine = testLine
          charPos = charPos + token.length
        end
      else
        -- It's whitespace - add to current line
        currentLine = currentLine .. token.text
        charPos = charPos + token.length
      end
    end
  else
    -- Character wrapping
    local lineLength = utf8.len(line)
    for i = 1, lineLength do
      local char = getUtf8Char(line, i)
      local testLine = currentLine .. char
      local width = font:getWidth(testLine)

      if width > maxWidth and currentLine ~= "" then
        table.insert(wrappedParts, {
          text = currentLine,
          startIdx = startIdx,
          endIdx = startIdx + utf8.len(currentLine),
        })
        currentLine = char
        startIdx = i - 1
      else
        currentLine = testLine
      end
    end
  end

  -- Add remaining text
  if currentLine ~= "" then
    table.insert(wrappedParts, {
      text = currentLine,
      startIdx = startIdx,
      endIdx = startIdx + utf8.len(currentLine),
    })
  end

  -- Ensure at least one part
  if #wrappedParts == 0 then
    table.insert(wrappedParts, {
      text = "",
      startIdx = 0,
      endIdx = 0,
    })
  end

  return wrappedParts
end

---@return love.Font
function Element:_getFont()
  -- Get font path from theme or element
  local fontPath = nil
  if self.fontFamily then
    local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
    if themeToUse and themeToUse.fonts and themeToUse.fonts[self.fontFamily] then
      fontPath = themeToUse.fonts[self.fontFamily]
    else
      fontPath = self.fontFamily
    end
  end

  return FONT_CACHE.getFont(self.textSize, fontPath)
end

function Element:_getCursorScreenPosition()
  if self._textEditor then
    return self._textEditor:_getCursorScreenPosition()
  end
end

function Element:_getSelectionRects(selStart, selEnd)
  if self._textEditor then
    return self._textEditor:_getSelectionRects(selStart, selEnd)
  end
end

function Element:_updateAutoGrowHeight()
  if not self.editable or not self.multiline or not self.autoGrow then
    return
  end

  local font = self:_getFont()
  if not font then
    return
  end

  local text = self._textBuffer or ""
  local lineHeight = font:getHeight()

  -- Get text area width for wrapping
  local textAreaWidth = self.width
  local scaledContentPadding = self:getScaledContentPadding()
  if scaledContentPadding then
    local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
    textAreaWidth = borderBoxWidth - scaledContentPadding.left - scaledContentPadding.right
  end

  -- Split text by actual newlines
  local lines = {}
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(lines, line)
  end
  if #lines == 0 then
    lines = { "" }
  end

  -- Count total wrapped lines
  local totalWrappedLines = 0
  if self.textWrap and textAreaWidth > 0 then
    for _, line in ipairs(lines) do
      if line == "" then
        totalWrappedLines = totalWrappedLines + 1
      else
        local wrappedSegments = self:_wrapLine(line, textAreaWidth)
        totalWrappedLines = totalWrappedLines + #wrappedSegments
      end
    end
  else
    totalWrappedLines = #lines
  end

  totalWrappedLines = math.max(1, totalWrappedLines)

  local newContentHeight = totalWrappedLines * lineHeight

  if self.height ~= newContentHeight then
    self.height = newContentHeight
    self._borderBoxHeight = self.height + self.padding.top + self.padding.bottom
    if self.parent and not self._explicitlyAbsolute then
      self.parent:layoutChildren()
    end
  end
end

function Element:_mouseToTextPosition(mouseX, mouseY)
  if self._textEditor then
    return self._textEditor:_mouseToTextPosition(mouseX, mouseY)
  end
end

function Element:_handleTextClick(mouseX, mouseY, clickCount)
  if not self.editable or not self._focused then
    return
  end

  if clickCount == 1 then
    -- Single click: Set cursor position
    local pos = self:_mouseToTextPosition(mouseX, mouseY)
    self:setCursorPosition(pos)
    self:clearSelection()

    -- Store position for potential drag selection
    self._mouseDownPosition = pos
  elseif clickCount == 2 then
    -- Double click: Select word
    self:_selectWordAtPosition(self:_mouseToTextPosition(mouseX, mouseY))
  elseif clickCount >= 3 then
    -- Triple click: Select all (or line in multi-line mode)
    self:selectAll()
  end

  self:_resetCursorBlink()
end

--- Handle mouse drag for text selection
---@param mouseX number -- Mouse X coordinate
---@param mouseY number -- Mouse Y coordinate
function Element:_handleTextDrag(mouseX, mouseY)
  if not self.editable or not self._focused or not self._mouseDownPosition then
    return
  end

  local currentPos = self:_mouseToTextPosition(mouseX, mouseY)

  -- Create selection from mouse down position to current position
  if currentPos ~= self._mouseDownPosition then
    self:setSelection(self._mouseDownPosition, currentPos)
    self._cursorPosition = currentPos
    self._textDragOccurred = true -- Mark that a text drag occurred
  else
    self:clearSelection()
  end

  self:_resetCursorBlink()
end

function Element:_selectWordAtPosition(position)
  if not self.editable or not self._textBuffer then
    return
  end

  local text = self._textBuffer
  local textLength = utf8.len(text) or 0

  if position < 0 or position > textLength then
    return
  end

  -- Find word boundaries
  local wordStart = position
  local wordEnd = position

  -- Find start of word (move left while alphanumeric)
  while wordStart > 0 do
    local offset = utf8.offset(text, wordStart)
    local char = offset and text:sub(offset, utf8.offset(text, wordStart + 1) - 1) or ""
    if char:match("[%w]") then
      wordStart = wordStart - 1
    else
      break
    end
  end

  -- Find end of word (move right while alphanumeric)
  while wordEnd < textLength do
    local offset = utf8.offset(text, wordEnd + 1)
    local char = offset and text:sub(offset, utf8.offset(text, wordEnd + 2) - 1) or ""
    if char:match("[%w]") then
      wordEnd = wordEnd + 1
    else
      break
    end
  end

  -- Select the word
  if wordEnd > wordStart then
    self:setSelection(wordStart, wordEnd)
    self._cursorPosition = wordEnd
  end
end

function Element:textinput(text)
  if not self.editable or not self._focused then
    return
  end

  -- Trigger onTextInput callback if defined
  if self.onTextInput then
    local result = self.onTextInput(self, text)
    -- If callback returns false, cancel the input
    if result == false then
      return
    end
  end

  -- Capture old text for callback
  local oldText = self._textBuffer

  -- Delete selection if exists
  local hadSelection = self:hasSelection()
  if hadSelection then
    self:deleteSelection()
  end

  -- Insert text at cursor position
  self:insertText(text)

  -- Trigger onTextChange callback if text changed
  if self.onTextChange and self._textBuffer ~= oldText then
    self.onTextChange(self, self._textBuffer, oldText)
  end

  -- Save state to StateManager in immediate mode
  self:_saveEditableState()
end

function Element:keypressed(key, scancode, isrepeat)
  if not self.editable or not self._focused then
    return
  end

  local modifiers = getModifiers()
  local ctrl = modifiers.ctrl or modifiers.super

  -- Handle cursor movement with selection
  if key == "left" or key == "right" or key == "home" or key == "end" or key == "up" or key == "down" then
    -- Set selection anchor if Shift is pressed and no anchor exists
    if modifiers.shift and not self._selectionAnchor then
      self._selectionAnchor = self._cursorPosition
    end

    -- Store old cursor position
    local oldCursorPos = self._cursorPosition

    -- Move cursor based on key
    if key == "left" then
      if modifiers.super then
        -- Cmd/Super+Left: Move to start
        self:moveCursorToStart()
        if not modifiers.shift then
          self:clearSelection()
        end
      elseif modifiers.alt then
        -- Alt+Left: Move to previous word
        self:moveCursorToPreviousWord()
      elseif self:hasSelection() and not modifiers.shift then
        -- Move to start of selection
        local startPos, _ = self:getSelection()
        self._cursorPosition = startPos
        self:clearSelection()
      else
        self:moveCursorBy(-1)
      end
    elseif key == "right" then
      if modifiers.super then
        -- Cmd/Super+Right: Move to end
        self:moveCursorToEnd()
        if not modifiers.shift then
          self:clearSelection()
        end
      elseif modifiers.alt then
        -- Alt+Right: Move to next word
        self:moveCursorToNextWord()
      elseif self:hasSelection() and not modifiers.shift then
        -- Move to end of selection
        local _, endPos = self:getSelection()
        self._cursorPosition = endPos
        self:clearSelection()
      else
        self:moveCursorBy(1)
      end
    elseif key == "home" then
      -- Home: Move to start (or line start for multiline)
      if not self.multiline then
        self:moveCursorToStart()
      else
        self:moveCursorToLineStart()
      end
      if not modifiers.shift then
        self:clearSelection()
      end
    elseif key == "end" then
      -- End: Move to end (or line end for multiline)
      if not self.multiline then
        self:moveCursorToEnd()
      else
        self:moveCursorToLineEnd()
      end
      if not modifiers.shift then
        self:clearSelection()
      end
    elseif key == "up" then
      -- TODO: Implement up/down for multi-line
      if not modifiers.shift then
        self:clearSelection()
      end
    elseif key == "down" then
      -- TODO: Implement up/down for multi-line
      if not modifiers.shift then
        self:clearSelection()
      end
    end

    -- Update selection if Shift is pressed
    if modifiers.shift and self._selectionAnchor then
      self:setSelection(self._selectionAnchor, self._cursorPosition)
    elseif not modifiers.shift then
      -- Clear anchor when Shift is released
      self._selectionAnchor = nil
    end

    self:_resetCursorBlink()

  -- Handle backspace and delete
  elseif key == "backspace" then
    local oldText = self._textBuffer
    if self:hasSelection() then
      -- Delete selection
      self:deleteSelection()
    elseif ctrl then
      -- Ctrl/Cmd+Backspace: Delete all text from start to cursor
      if self._cursorPosition > 0 then
        self:deleteText(0, self._cursorPosition)
        self._cursorPosition = 0
        self:_validateCursorPosition()
      end
    elseif self._cursorPosition > 0 then
      -- Delete character before cursor
      -- Update cursor position BEFORE deleteText so updates use correct position
      local deleteStart = self._cursorPosition - 1
      local deleteEnd = self._cursorPosition
      self._cursorPosition = deleteStart
      self:deleteText(deleteStart, deleteEnd)
      self:_validateCursorPosition()
    end

    -- Trigger onTextChange callback
    if self.onTextChange and self._textBuffer ~= oldText then
      self.onTextChange(self, self._textBuffer, oldText)
    end
    self:_resetCursorBlink(true)
  elseif key == "delete" then
    local oldText = self._textBuffer
    if self:hasSelection() then
      -- Delete selection
      self:deleteSelection()
    else
      -- Delete character after cursor
      local textLength = utf8.len(self._textBuffer or "")
      if self._cursorPosition < textLength then
        self:deleteText(self._cursorPosition, self._cursorPosition + 1)
      end
    end

    -- Trigger onTextChange callback
    if self.onTextChange and self._textBuffer ~= oldText then
      self.onTextChange(self, self._textBuffer, oldText)
    end
    self:_resetCursorBlink(true)

  -- Handle return/enter
  elseif key == "return" or key == "kpenter" then
    if self.multiline then
      -- Insert newline
      local oldText = self._textBuffer
      if self:hasSelection() then
        self:deleteSelection()
      end
      self:insertText("\n")

      -- Trigger onTextChange callback
      if self.onTextChange and self._textBuffer ~= oldText then
        self.onTextChange(self, self._textBuffer, oldText)
      end
    else
      -- Trigger onEnter callback for single-line
      if self.onEnter then
        self.onEnter(self)
      end
    end
    self:_resetCursorBlink(true)

  -- Handle Ctrl/Cmd+A (select all)
  elseif ctrl and key == "a" then
    self:selectAll()
    self:_resetCursorBlink()

  -- Handle Ctrl/Cmd+C (copy)
  elseif ctrl and key == "c" then
    if self:hasSelection() then
      local selectedText = self:getSelectedText()
      if selectedText then
        love.system.setClipboardText(selectedText)
      end
    end
    self:_resetCursorBlink()

  -- Handle Ctrl/Cmd+X (cut)
  elseif ctrl and key == "x" then
    if self:hasSelection() then
      local selectedText = self:getSelectedText()
      if selectedText then
        love.system.setClipboardText(selectedText)

        -- Delete the selected text
        local oldText = self._textBuffer
        self:deleteSelection()

        -- Trigger onTextChange callback
        if self.onTextChange and self._textBuffer ~= oldText then
          self.onTextChange(self, self._textBuffer, oldText)
        end
      end
    end
    self:_resetCursorBlink(true)

  -- Handle Ctrl/Cmd+V (paste)
  elseif ctrl and key == "v" then
    local clipboardText = love.system.getClipboardText()
    if clipboardText and clipboardText ~= "" then
      local oldText = self._textBuffer

      -- Delete selection if exists
      if self:hasSelection() then
        self:deleteSelection()
      end

      -- Insert clipboard text
      self:insertText(clipboardText)

      -- Trigger onTextChange callback
      if self.onTextChange and self._textBuffer ~= oldText then
        self.onTextChange(self, self._textBuffer, oldText)
      end
    end
    self:_resetCursorBlink(true)

  -- Handle Escape
  elseif key == "escape" then
    if self:hasSelection() then
      -- Clear selection
      self:clearSelection()
    else
      -- Blur element
      self:blur()
    end
    self:_resetCursorBlink()
  end

  -- Save state to StateManager in immediate mode
  self:_saveEditableState()
end

return Element
