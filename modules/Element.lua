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
local TextEditor = req("TextEditor")
local LayoutEngine = req("LayoutEngine")
local Renderer = req("Renderer")

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

-- Reference to Gui (via GuiState)
local Gui = GuiState

-- UTF-8 support (available in LÖVE/Lua 5.3+)
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
Element.__index = Element

---@param props ElementProps
---@return Element
function Element.new(props)
  local self = setmetatable({}, Element)
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

  -- Initialize TextEditor for editable elements
  if self.editable then
    self._textEditor = TextEditor.new({
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
      text = props.text or "",
      onFocus = props.onFocus,
      onBlur = props.onBlur,
      onTextInput = props.onTextInput,
      onTextChange = props.onTextChange,
      onEnter = props.onEnter,
    })
    -- Initialize will be called after self is fully constructed
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
  if self.editable and Gui._immediateMode and self._textBuffer then
    self.text = self._textBuffer
  end

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

  -- Initialize Renderer module for visual rendering
  self._renderer = Renderer.new({
    backgroundColor = self.backgroundColor,
    borderColor = self.borderColor,
    opacity = self.opacity,
    border = self.border,
    cornerRadius = self.cornerRadius,
    theme = self.theme,
    themeComponent = self.themeComponent,
    scaleCorners = self.scaleCorners,
    scalingAlgorithm = self.scalingAlgorithm,
    imagePath = self.imagePath,
    image = self.image,
    _loadedImage = self._loadedImage,
    objectFit = self.objectFit,
    objectPosition = self.objectPosition,
    imageOpacity = self.imageOpacity,
    contentBlur = self.contentBlur,
    backdropBlur = self.backdropBlur,
    _themeState = self._themeState,
  })
  self._renderer:initialize(self)

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

  -- Initialize LayoutEngine for layout calculations
  self._layoutEngine = LayoutEngine.new({
    positioning = self.positioning,
    flexDirection = self.flexDirection,
    flexWrap = self.flexWrap,
    justifyContent = self.justifyContent,
    alignItems = self.alignItems,
    alignContent = self.alignContent,
    gap = self.gap,
    gridRows = self.gridRows,
    gridColumns = self.gridColumns,
    columnGap = self.columnGap,
    rowGap = self.rowGap,
  })
  -- Initialize immediately so it can be used for auto-sizing calculations
  self._layoutEngine:initialize(self)

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

  -- Register element in z-index tracking for immediate mode
  if Gui._immediateMode then
    GuiState.registerElement(self)
  end

  -- Initialize TextEditor after element is fully constructed
  if self._textEditor then
    self._textEditor:initialize(self)
  end

  return self
end

--- Get element bounds (content box)
---@return { x:number, y:number, width:number, height:number }
function Element:getBounds()
  return { x = self.x, y = self.y, width = self:getBorderBoxWidth(), height = self:getBorderBoxHeight() }
end

--- Check if point is inside element bounds
--- @param x number
--- @param y number
--- @return boolean
function Element:contains(x, y)
  local bounds = self:getBounds()
  return bounds.x <= x and bounds.y <= y and bounds.x + bounds.width >= x and bounds.y + bounds.height >= y
end

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

--- Detect if content overflows container bounds
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

--- Set scroll position with bounds clamping
---@param x number? -- X scroll position (nil to keep current)
---@param y number? -- Y scroll position (nil to keep current)
function Element:setScrollPosition(x, y)
  if x ~= nil then
    self._scrollX = math.max(0, math.min(x, self._maxScrollX))
  end
  if y ~= nil then
    self._scrollY = math.max(0, math.min(y, self._maxScrollY))
  end

  -- Note: Scroll position is saved to ImmediateModeState in Gui.endFrame()
  -- No need to save here
end

--- Calculate scrollbar dimensions and positions
---@return table -- {vertical: {visible, trackHeight, thumbHeight, thumbY}, horizontal: {visible, trackWidth, thumbWidth, thumbX}}
function Element:_calculateScrollbarDimensions()
  local result = {
    vertical = { visible = false, trackHeight = 0, thumbHeight = 0, thumbY = 0 },
    horizontal = { visible = false, trackWidth = 0, thumbWidth = 0, thumbX = 0 },
  }

  local overflowX = self.overflowX or self.overflow
  local overflowY = self.overflowY or self.overflow

  -- Vertical scrollbar
  -- Note: overflow="scroll" always shows scrollbar; overflow="auto" only when content overflows
  if overflowY == "scroll" then
    -- Always show scrollbar for "scroll" mode
    result.vertical.visible = true
    result.vertical.trackHeight = self.height - (self.scrollbarPadding * 2)

    if self._overflowY then
      -- Content overflows, calculate proper thumb size
      local contentRatio = self.height / math.max(self._contentHeight, self.height)
      result.vertical.thumbHeight = math.max(20, result.vertical.trackHeight * contentRatio)

      -- Calculate thumb position based on scroll ratio
      local scrollRatio = self._maxScrollY > 0 and (self._scrollY / self._maxScrollY) or 0
      local maxThumbY = result.vertical.trackHeight - result.vertical.thumbHeight
      result.vertical.thumbY = maxThumbY * scrollRatio
    else
      -- No overflow, thumb fills entire track
      result.vertical.thumbHeight = result.vertical.trackHeight
      result.vertical.thumbY = 0
    end
  elseif self._overflowY and overflowY == "auto" then
    -- Only show scrollbar when content actually overflows
    result.vertical.visible = true
    result.vertical.trackHeight = self.height - (self.scrollbarPadding * 2)

    -- Calculate thumb height based on content ratio
    local contentRatio = self.height / math.max(self._contentHeight, self.height)
    result.vertical.thumbHeight = math.max(20, result.vertical.trackHeight * contentRatio)

    -- Calculate thumb position based on scroll ratio
    local scrollRatio = self._maxScrollY > 0 and (self._scrollY / self._maxScrollY) or 0
    local maxThumbY = result.vertical.trackHeight - result.vertical.thumbHeight
    result.vertical.thumbY = maxThumbY * scrollRatio
  end

  -- Horizontal scrollbar
  -- Note: overflow="scroll" always shows scrollbar; overflow="auto" only when content overflows
  if overflowX == "scroll" then
    -- Always show scrollbar for "scroll" mode
    result.horizontal.visible = true
    result.horizontal.trackWidth = self.width - (self.scrollbarPadding * 2)

    if self._overflowX then
      -- Content overflows, calculate proper thumb size
      local contentRatio = self.width / math.max(self._contentWidth, self.width)
      result.horizontal.thumbWidth = math.max(20, result.horizontal.trackWidth * contentRatio)

      -- Calculate thumb position based on scroll ratio
      local scrollRatio = self._maxScrollX > 0 and (self._scrollX / self._maxScrollX) or 0
      local maxThumbX = result.horizontal.trackWidth - result.horizontal.thumbWidth
      result.horizontal.thumbX = maxThumbX * scrollRatio
    else
      -- No overflow, thumb fills entire track
      result.horizontal.thumbWidth = result.horizontal.trackWidth
      result.horizontal.thumbX = 0
    end
  elseif self._overflowX and overflowX == "auto" then
    -- Only show scrollbar when content actually overflows
    result.horizontal.visible = true
    result.horizontal.trackWidth = self.width - (self.scrollbarPadding * 2)

    -- Calculate thumb width based on content ratio
    local contentRatio = self.width / math.max(self._contentWidth, self.width)
    result.horizontal.thumbWidth = math.max(20, result.horizontal.trackWidth * contentRatio)

    -- Calculate thumb position based on scroll ratio
    local scrollRatio = self._maxScrollX > 0 and (self._scrollX / self._maxScrollX) or 0
    local maxThumbX = result.horizontal.trackWidth - result.horizontal.thumbWidth
    result.horizontal.thumbX = maxThumbX * scrollRatio
  end

  return result
end

--- Draw scrollbars

--- Get scrollbar at mouse position
---@param mouseX number
---@param mouseY number
---@return table|nil -- {component: "vertical"|"horizontal", region: "thumb"|"track"}
function Element:_getScrollbarAtPosition(mouseX, mouseY)
  local overflowX = self.overflowX or self.overflow
  local overflowY = self.overflowY or self.overflow

  if not (overflowX == "scroll" or overflowX == "auto" or overflowY == "scroll" or overflowY == "auto") then
    return nil
  end

  local dims = self:_calculateScrollbarDimensions()
  local x, y = self.x, self.y
  local w, h = self.width, self.height

  -- Check vertical scrollbar (only if not hidden)
  if dims.vertical.visible and not self.hideScrollbars.vertical then
    -- Position scrollbar within content area (x, y is border-box origin)
    local contentX = x + self.padding.left
    local contentY = y + self.padding.top
    local trackX = contentX + w - self.scrollbarWidth - self.scrollbarPadding
    local trackY = contentY + self.scrollbarPadding
    local trackW = self.scrollbarWidth
    local trackH = dims.vertical.trackHeight

    if mouseX >= trackX and mouseX <= trackX + trackW and mouseY >= trackY and mouseY <= trackY + trackH then
      -- Check if over thumb
      local thumbY = trackY + dims.vertical.thumbY
      local thumbH = dims.vertical.thumbHeight
      if mouseY >= thumbY and mouseY <= thumbY + thumbH then
        return { component = "vertical", region = "thumb" }
      else
        return { component = "vertical", region = "track" }
      end
    end
  end

  -- Check horizontal scrollbar (only if not hidden)
  if dims.horizontal.visible and not self.hideScrollbars.horizontal then
    -- Position scrollbar within content area (x, y is border-box origin)
    local contentX = x + self.padding.left
    local contentY = y + self.padding.top
    local trackX = contentX + self.scrollbarPadding
    local trackY = contentY + h - self.scrollbarWidth - self.scrollbarPadding
    local trackW = dims.horizontal.trackWidth
    local trackH = self.scrollbarWidth

    if mouseX >= trackX and mouseX <= trackX + trackW and mouseY >= trackY and mouseY <= trackY + trackH then
      -- Check if over thumb
      local thumbX = trackX + dims.horizontal.thumbX
      local thumbW = dims.horizontal.thumbWidth
      if mouseX >= thumbX and mouseX <= thumbX + thumbW then
        return { component = "horizontal", region = "thumb" }
      else
        return { component = "horizontal", region = "track" }
      end
    end
  end

  return nil
end

--- Handle scrollbar mouse press
---@param mouseX number
---@param mouseY number
---@param button number
---@return boolean -- True if event was consumed
function Element:_handleScrollbarPress(mouseX, mouseY, button)
  if button ~= 1 then
    return false
  end -- Only left click

  local scrollbar = self:_getScrollbarAtPosition(mouseX, mouseY)
  if not scrollbar then
    return false
  end

  if scrollbar.region == "thumb" then
    -- Start dragging thumb
    self._scrollbarDragging = true
    self._hoveredScrollbar = scrollbar.component
    local dims = self:_calculateScrollbarDimensions()

    if scrollbar.component == "vertical" then
      local contentY = self.y + self.padding.top
      local trackY = contentY + self.scrollbarPadding
      local thumbY = trackY + dims.vertical.thumbY
      self._scrollbarDragOffset = mouseY - thumbY
    elseif scrollbar.component == "horizontal" then
      local contentX = self.x + self.padding.left
      local trackX = contentX + self.scrollbarPadding
      local thumbX = trackX + dims.horizontal.thumbX
      self._scrollbarDragOffset = mouseX - thumbX
    end

    -- Update StateManager if in immediate mode
    if self._stateId and Gui._immediateMode then
      StateManager.updateState(self._stateId, {
        scrollbarDragging = self._scrollbarDragging,
        hoveredScrollbar = self._hoveredScrollbar,
        scrollbarDragOffset = self._scrollbarDragOffset,
      })
    end

    return true -- Event consumed
  elseif scrollbar.region == "track" then
    -- Click on track - jump to position
    self:_scrollToTrackPosition(mouseX, mouseY, scrollbar.component)
    return true
  end

  return false
end

--- Handle scrollbar drag
---@param mouseX number
---@param mouseY number
---@return boolean -- True if event was consumed
function Element:_handleScrollbarDrag(mouseX, mouseY)
  if not self._scrollbarDragging then
    return false
  end

  local dims = self:_calculateScrollbarDimensions()

  if self._hoveredScrollbar == "vertical" then
    local contentY = self.y + self.padding.top
    local trackY = contentY + self.scrollbarPadding
    local trackH = dims.vertical.trackHeight
    local thumbH = dims.vertical.thumbHeight

    -- Calculate new thumb position
    local newThumbY = mouseY - self._scrollbarDragOffset - trackY
    newThumbY = math.max(0, math.min(newThumbY, trackH - thumbH))

    -- Convert thumb position to scroll position
    local scrollRatio = (trackH - thumbH) > 0 and (newThumbY / (trackH - thumbH)) or 0
    local newScrollY = scrollRatio * self._maxScrollY

    self:setScrollPosition(nil, newScrollY)
    return true
  elseif self._hoveredScrollbar == "horizontal" then
    local contentX = self.x + self.padding.left
    local trackX = contentX + self.scrollbarPadding
    local trackW = dims.horizontal.trackWidth
    local thumbW = dims.horizontal.thumbWidth

    -- Calculate new thumb position
    local newThumbX = mouseX - self._scrollbarDragOffset - trackX
    newThumbX = math.max(0, math.min(newThumbX, trackW - thumbW))

    -- Convert thumb position to scroll position
    local scrollRatio = (trackW - thumbW) > 0 and (newThumbX / (trackW - thumbW)) or 0
    local newScrollX = scrollRatio * self._maxScrollX

    self:setScrollPosition(newScrollX, nil)
    return true
  end

  return false
end

--- Handle scrollbar release
---@param button number
---@return boolean -- True if event was consumed
function Element:_handleScrollbarRelease(button)
  if button ~= 1 then
    return false
  end

  if self._scrollbarDragging then
    self._scrollbarDragging = false

    -- Update StateManager if in immediate mode
    if self._stateId and Gui._immediateMode then
      StateManager.updateState(self._stateId, {
        scrollbarDragging = false,
      })
    end

    return true
  end

  return false
end

--- Scroll to track click position
---@param mouseX number
---@param mouseY number
---@param component string -- "vertical" or "horizontal"
function Element:_scrollToTrackPosition(mouseX, mouseY, component)
  local dims = self:_calculateScrollbarDimensions()

  if component == "vertical" then
    local contentY = self.y + self.padding.top
    local trackY = contentY + self.scrollbarPadding
    local trackH = dims.vertical.trackHeight
    local thumbH = dims.vertical.thumbHeight

    -- Calculate target thumb position (centered on click)
    local targetThumbY = mouseY - trackY - (thumbH / 2)
    targetThumbY = math.max(0, math.min(targetThumbY, trackH - thumbH))

    -- Convert to scroll position
    local scrollRatio = (trackH - thumbH) > 0 and (targetThumbY / (trackH - thumbH)) or 0
    local newScrollY = scrollRatio * self._maxScrollY

    self:setScrollPosition(nil, newScrollY)
  elseif component == "horizontal" then
    local contentX = self.x + self.padding.left
    local trackX = contentX + self.scrollbarPadding
    local trackW = dims.horizontal.trackWidth
    local thumbW = dims.horizontal.thumbWidth

    -- Calculate target thumb position (centered on click)
    local targetThumbX = mouseX - trackX - (thumbW / 2)
    targetThumbX = math.max(0, math.min(targetThumbX, trackW - thumbW))

    -- Convert to scroll position
    local scrollRatio = (trackW - thumbW) > 0 and (targetThumbX / (trackW - thumbW)) or 0
    local newScrollX = scrollRatio * self._maxScrollX

    self:setScrollPosition(newScrollX, nil)
  end
end

--- Handle mouse wheel scrolling
---@param x number -- Horizontal scroll amount
---@param y number -- Vertical scroll amount
---@return boolean -- True if scroll was handled
function Element:_handleWheelScroll(x, y)
  local overflowX = self.overflowX or self.overflow
  local overflowY = self.overflowY or self.overflow

  if not (overflowX == "scroll" or overflowX == "auto" or overflowY == "scroll" or overflowY == "auto") then
    return false
  end

  local hasVerticalOverflow = self._overflowY and self._maxScrollY > 0
  local hasHorizontalOverflow = self._overflowX and self._maxScrollX > 0

  local scrolled = false

  -- Vertical scrolling
  if y ~= 0 and hasVerticalOverflow then
    local delta = -y * self.scrollSpeed -- Negative because wheel up = scroll up
    local newScrollY = self._scrollY + delta
    self:setScrollPosition(nil, newScrollY)
    scrolled = true
  end

  -- Horizontal scrolling
  if x ~= 0 and hasHorizontalOverflow then
    local delta = -x * self.scrollSpeed
    local newScrollX = self._scrollX + delta
    self:setScrollPosition(newScrollX, nil)
    scrolled = true
  end

  -- Note: Scroll position is saved to ImmediateModeState in Gui.endFrame()
  return scrolled
end

--- Get current scroll position
---@return number scrollX, number scrollY
function Element:getScrollPosition()
  return self._scrollX, self._scrollY
end

--- Get maximum scroll bounds
---@return number maxScrollX, number maxScrollY
function Element:getMaxScroll()
  return self._maxScrollX, self._maxScrollY
end

--- Get scroll percentage (0-1)
---@return number percentX, number percentY
function Element:getScrollPercentage()
  local percentX = self._maxScrollX > 0 and (self._scrollX / self._maxScrollX) or 0
  local percentY = self._maxScrollY > 0 and (self._scrollY / self._maxScrollY) or 0
  return percentX, percentY
end

--- Check if element has overflow
---@return boolean hasOverflowX, boolean hasOverflowY
function Element:hasOverflow()
  return self._overflowX, self._overflowY
end

--- Get content dimensions (including overflow)
---@return number contentWidth, number contentHeight
function Element:getContentSize()
  return self._contentWidth, self._contentHeight
end

--- Scroll by delta amount
---@param dx number? -- X delta (nil for no change)
---@param dy number? -- Y delta (nil for no change)
function Element:scrollBy(dx, dy)
  if dx then
    self._scrollX = math.max(0, math.min(self._scrollX + dx, self._maxScrollX))
  end
  if dy then
    self._scrollY = math.max(0, math.min(self._scrollY + dy, self._maxScrollY))
  end
end

--- Scroll to top
function Element:scrollToTop()
  self:setScrollPosition(nil, 0)
end

--- Scroll to bottom
function Element:scrollToBottom()
  self:setScrollPosition(nil, self._maxScrollY)
end

--- Scroll to left
function Element:scrollToLeft()
  self:setScrollPosition(0, nil)
end

--- Scroll to right
function Element:scrollToRight()
  self:setScrollPosition(self._maxScrollX, nil)
end

--- Get the current state's scaled content padding
--- Returns the contentPadding for the current theme state, scaled to the element's size
---@return table|nil -- {left, top, right, bottom} or nil if no contentPadding
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

--- Get or create blur instance for this element
---@return table? -- Blur instance or nil if no blur configured
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

--- Get available content width for children (accounting for 9-patch content padding)
--- This is the width that children should use when calculating percentage widths
---@return number
function Element:getAvailableContentWidth()
  local availableWidth = self.width

  local scaledContentPadding = self:getScaledContentPadding()
  if scaledContentPadding then
    -- Check if the element is using the scaled 9-patch contentPadding as its padding
    -- Allow small floating point differences (within 0.1 pixels)
    local usingContentPaddingAsPadding = (
      math.abs(self.padding.left - scaledContentPadding.left) < 0.1 and math.abs(self.padding.right - scaledContentPadding.right) < 0.1
    )

    if not usingContentPaddingAsPadding then
      -- Element has explicit padding different from contentPadding
      -- Subtract scaled contentPadding to get the area children should use
      availableWidth = availableWidth - scaledContentPadding.left - scaledContentPadding.right
    end
  end

  return math.max(0, availableWidth)
end

--- Get available content height for children (accounting for 9-patch content padding)
--- This is the height that children should use when calculating percentage heights
---@return number
function Element:getAvailableContentHeight()
  local availableHeight = self.height

  local scaledContentPadding = self:getScaledContentPadding()
  if scaledContentPadding then
    -- Check if the element is using the scaled 9-patch contentPadding as its padding
    -- Allow small floating point differences (within 0.1 pixels)
    local usingContentPaddingAsPadding = (
      math.abs(self.padding.top - scaledContentPadding.top) < 0.1 and math.abs(self.padding.bottom - scaledContentPadding.bottom) < 0.1
    )

    if not usingContentPaddingAsPadding then
      -- Element has explicit padding different from contentPadding
      -- Subtract scaled contentPadding to get the area children should use
      availableHeight = availableHeight - scaledContentPadding.top - scaledContentPadding.bottom
    end
  end

  return math.max(0, availableHeight)
end

--- Add child to element
---@param child Element
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

--- Apply positioning offsets (top, right, bottom, left) to an element
-- @param element The element to apply offsets to
function Element:applyPositioningOffsets(element)
  -- Delegate to LayoutEngine
  self._layoutEngine:applyPositioningOffsets(element)
end

function Element:layoutChildren()
  -- Delegate layout to LayoutEngine
  self._layoutEngine:layoutChildren()
end

--- Destroy element and its children
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

  -- Clear onEvent to prevent closure leaks
  self.onEvent = nil
end

--- Draw element and its children
function Element:draw(backdropCanvas)
  -- Early exit if element is invisible (optimization)
  if self.opacity <= 0 then
    return
  end

  -- Handle opacity during animation
  local drawBackgroundColor = self.backgroundColor
  if self.animation then
    local anim = self.animation:interpolate()
    if anim.opacity then
      drawBackgroundColor = Color.new(self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b, anim.opacity)
    end
  end

  -- Cache border box dimensions for this draw call (optimization)
  local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
  local borderBoxHeight = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)

  -- LAYERS 0.5-3: Delegate visual rendering (backdrop blur, background, image, theme, borders) to Renderer module
  self._renderer:draw(backdropCanvas)

  -- LAYER 4: Delegate text rendering (text, cursor, selection, placeholder, password masking) to Renderer module
  self._renderer:drawText(self)

  -- Draw visual feedback when element is pressed (if it has an onEvent handler and highlight is not disabled)
  if self.onEvent and not self.disableHighlight then
    -- Check if any button is pressed
    local anyPressed = false
    for _, pressed in pairs(self._pressed) do
      if pressed then
        anyPressed = true
        break
      end
    end
    if anyPressed then
      -- BORDER-BOX MODEL: Use stored border-box dimensions for drawing
      local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
      local borderBoxHeight = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)
      self._renderer:drawPressedState(self.x, self.y, borderBoxWidth, borderBoxHeight)
    end
  end

  -- Sort children by z-index before drawing
  local sortedChildren = {}
  for _, child in ipairs(self.children) do
    table.insert(sortedChildren, child)
  end
  table.sort(sortedChildren, function(a, b)
    return a.z < b.z
  end)

  -- Check if we need to clip children to rounded corners
  local hasRoundedCorners = self.cornerRadius.topLeft > 0
    or self.cornerRadius.topRight > 0
    or self.cornerRadius.bottomLeft > 0
    or self.cornerRadius.bottomRight > 0

  -- Helper function to draw children (with or without clipping)
  local function drawChildren()
    -- Determine overflow behavior per axis (matches HTML/CSS behavior)
    -- Priority: axis-specific (overflowX/Y) > general (overflow) > default (hidden)
    local overflowX = self.overflowX or self.overflow
    local overflowY = self.overflowY or self.overflow
    local needsOverflowClipping = (overflowX ~= "visible" or overflowY ~= "visible") and (overflowX ~= nil or overflowY ~= nil)

    -- Apply scroll offset if overflow is not visible
    local hasScrollOffset = needsOverflowClipping and (self._scrollX ~= 0 or self._scrollY ~= 0)

    if hasRoundedCorners and #sortedChildren > 0 then
      -- Use stencil to clip children to rounded rectangle
      -- BORDER-BOX MODEL: Use stored border-box dimensions for clipping
      local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
      local borderBoxHeight = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)
      local stencilFunc = RoundedRect.stencilFunction(self.x, self.y, borderBoxWidth, borderBoxHeight, self.cornerRadius)

      -- Temporarily disable canvas for stencil operation (LÖVE 11.5 workaround)
      local currentCanvas = love.graphics.getCanvas()
      love.graphics.setCanvas()
      love.graphics.stencil(stencilFunc, "replace", 1)
      love.graphics.setCanvas(currentCanvas)

      love.graphics.setStencilTest("greater", 0)

      -- Apply scroll offset AFTER clipping is set
      if hasScrollOffset then
        love.graphics.push()
        love.graphics.translate(-self._scrollX, -self._scrollY)
      end

      for _, child in ipairs(sortedChildren) do
        child:draw(backdropCanvas)
      end

      if hasScrollOffset then
        love.graphics.pop()
      end

      love.graphics.setStencilTest()
    elseif needsOverflowClipping and #sortedChildren > 0 then
      -- Clip content for overflow hidden/scroll/auto without rounded corners
      local contentX = self.x + self.padding.left
      local contentY = self.y + self.padding.top
      local contentWidth = self.width
      local contentHeight = self.height

      love.graphics.setScissor(contentX, contentY, contentWidth, contentHeight)

      -- Apply scroll offset AFTER clipping is set
      if hasScrollOffset then
        love.graphics.push()
        love.graphics.translate(-self._scrollX, -self._scrollY)
      end

      for _, child in ipairs(sortedChildren) do
        child:draw(backdropCanvas)
      end

      if hasScrollOffset then
        love.graphics.pop()
      end

      love.graphics.setScissor()
    else
      -- No clipping needed
      for _, child in ipairs(sortedChildren) do
        child:draw(backdropCanvas)
      end
    end
  end

  -- Apply content blur if configured
  if self.contentBlur and self.contentBlur.intensity > 0 and #sortedChildren > 0 then
    local blurInstance = self:getBlurInstance()
    if blurInstance then
      Blur.applyToRegion(blurInstance, self.contentBlur.intensity, self.x, self.y, borderBoxWidth, borderBoxHeight, drawChildren)
    else
      drawChildren()
    end
  else
    drawChildren()
  end

  -- Draw scrollbars if overflow is scroll or auto
  -- IMPORTANT: Scrollbars must be drawn without parent clipping
  local overflowX = self.overflowX or self.overflow
  local overflowY = self.overflowY or self.overflow
  if overflowX == "scroll" or overflowX == "auto" or overflowY == "scroll" or overflowY == "auto" then
    local scrollbarDims = self:_calculateScrollbarDimensions()
    if scrollbarDims.vertical.visible or scrollbarDims.horizontal.visible then
      -- Clear any parent scissor clipping before drawing scrollbars
      love.graphics.setScissor()
      -- Delegate scrollbar rendering to Renderer module
      self._renderer:drawScrollbars(self, self.x, self.y, self.width, self.height, scrollbarDims)
    end
  end
end

--- Update element (propagate to children)
---@param dt number
function Element:update(dt)
  -- Restore scrollbar state from StateManager in immediate mode
  if self._stateId and Gui._immediateMode then
    local state = StateManager.getState(self._stateId)
    if state then
      self._scrollbarHoveredVertical = state.scrollbarHoveredVertical or false
      self._scrollbarHoveredHorizontal = state.scrollbarHoveredHorizontal or false
      self._scrollbarDragging = state.scrollbarDragging or false
      self._hoveredScrollbar = state.hoveredScrollbar
      self._scrollbarDragOffset = state.scrollbarDragOffset or 0
    end
  end

  for _, child in ipairs(self.children) do
    child:update(dt)
  end

  -- Update text editor cursor blink
  if self._textEditor then
    self._textEditor:update(dt)
  end

  -- Update animation if exists
  if self.animation then
    local finished = self.animation:update(dt)
    if finished then
      self.animation = nil -- remove finished animation
    else
      -- Apply animation interpolation during update
      local anim = self.animation:interpolate()
      self.width = anim.width or self.width
      self.height = anim.height or self.height
      self.opacity = anim.opacity or self.opacity
      -- Update background color with interpolated opacity
      if anim.opacity then
        self.backgroundColor.a = anim.opacity
      end
    end
  end

  local mx, my = love.mouse.getPosition()

  local scrollbar = self:_getScrollbarAtPosition(mx, my)

  -- Update independent hover states for vertical and horizontal scrollbars
  if scrollbar and scrollbar.component == "vertical" then
    self._scrollbarHoveredVertical = true
    self._hoveredScrollbar = "vertical"
  else
    if not (self._scrollbarDragging and self._hoveredScrollbar == "vertical") then
      self._scrollbarHoveredVertical = false
    end
  end

  if scrollbar and scrollbar.component == "horizontal" then
    self._scrollbarHoveredHorizontal = true
    self._hoveredScrollbar = "horizontal"
  else
    if not (self._scrollbarDragging and self._hoveredScrollbar == "horizontal") then
      self._scrollbarHoveredHorizontal = false
    end
  end

  -- Clear hoveredScrollbar if neither is hovered
  if not scrollbar and not self._scrollbarDragging then
    self._hoveredScrollbar = nil
  end

  -- Update scrollbar state in StateManager if in immediate mode
  if self._stateId and Gui._immediateMode then
    StateManager.updateState(self._stateId, {
      scrollbarHoveredVertical = self._scrollbarHoveredVertical,
      scrollbarHoveredHorizontal = self._scrollbarHoveredHorizontal,
      scrollbarDragging = self._scrollbarDragging,
      hoveredScrollbar = self._hoveredScrollbar,
    })
  end

  -- Handle scrollbar dragging
  if self._scrollbarDragging and love.mouse.isDown(1) then
    self:_handleScrollbarDrag(mx, my)
  elseif self._scrollbarDragging then
    -- Mouse button released
    self._scrollbarDragging = false

    -- Update StateManager if in immediate mode
    if self._stateId and Gui._immediateMode then
      StateManager.updateState(self._stateId, {
        scrollbarDragging = false,
      })
    end
  end

  -- Handle scrollbar click/press (independent of onEvent)
  -- Check if we should handle scrollbar press for elements with overflow
  local overflowX = self.overflowX or self.overflow
  local overflowY = self.overflowY or self.overflow
  local hasScrollableOverflow = (overflowX == "scroll" or overflowX == "auto" or overflowY == "scroll" or overflowY == "auto")

  if hasScrollableOverflow and not self._scrollbarDragging then
    -- Check for scrollbar press on left mouse button
    if love.mouse.isDown(1) and not self._scrollbarPressHandled then
      local scrollbarPressed = self:_handleScrollbarPress(mx, my, 1)
      if scrollbarPressed then
        self._scrollbarPressHandled = true
      end
    elseif not love.mouse.isDown(1) then
      -- Reset press handled flag when button is released
      self._scrollbarPressHandled = false
    end
  end

  if self.onEvent or self.themeComponent or self.editable then
    -- Clickable area is the border box (x, y already includes padding)
    -- BORDER-BOX MODEL: Use stored border-box dimensions for hit detection
    local bx = self.x
    local by = self.y
    local bw = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
    local bh = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)

    -- Account for scroll offsets from parent containers
    -- Walk up the parent chain and accumulate scroll offsets
    local scrollOffsetX = 0
    local scrollOffsetY = 0
    local current = self.parent
    while current do
      local overflowX = current.overflowX or current.overflow
      local overflowY = current.overflowY or current.overflow
      local hasScrollableOverflow = (
        overflowX == "scroll"
        or overflowX == "auto"
        or overflowY == "scroll"
        or overflowY == "auto"
        or overflowX == "hidden"
        or overflowY == "hidden"
      )
      if hasScrollableOverflow then
        scrollOffsetX = scrollOffsetX + (current._scrollX or 0)
        scrollOffsetY = scrollOffsetY + (current._scrollY or 0)
      end
      current = current.parent
    end

    -- Adjust mouse position by accumulated scroll offset for hit testing
    local adjustedMx = mx + scrollOffsetX
    local adjustedMy = my + scrollOffsetY
    local isHovering = adjustedMx >= bx and adjustedMx <= bx + bw and adjustedMy >= by and adjustedMy <= by + bh

    -- Check if this is the topmost element at the mouse position (z-index ordering)
    -- This prevents blocked elements from receiving interactions or visual feedback
    local isActiveElement
    if Gui._immediateMode then
      -- In immediate mode, use z-index occlusion detection
      local topElement = GuiState.getTopElementAt(mx, my)
      isActiveElement = (topElement == self or topElement == nil)
    else
      -- In retained mode, use the old _activeEventElement mechanism
      isActiveElement = (Gui._activeEventElement == nil or Gui._activeEventElement == self)
    end

    -- Update theme state based on interaction
    if self.themeComponent then
      local newThemeState = "normal"

      -- Disabled state takes priority
      if self.disabled then
        newThemeState = "disabled"
      -- Active state (for inputs when focused/typing)
      elseif self.active then
        newThemeState = "active"
      -- Only show hover/pressed states if this element is active (not blocked)
      elseif isHovering and isActiveElement then
        -- Check if any button is pressed
        local anyPressed = false
        for _, pressed in pairs(self._pressed) do
          if pressed then
            anyPressed = true
            break
          end
        end

        if anyPressed then
          newThemeState = "pressed"
        else
          newThemeState = "hover"
        end
      end

      -- Update state (in StateManager if in immediate mode, otherwise locally)
      if self._stateId and Gui._immediateMode then
        -- Update in StateManager for immediate mode
        local hover = newThemeState == "hover"
        local pressed = newThemeState == "pressed"
        local focused = newThemeState == "active" or self._focused

        StateManager.updateState(self._stateId, {
          hover = hover,
          pressed = pressed,
          focused = focused,
          disabled = self.disabled,
          active = self.active,
        })
      end

      -- Always update local state for backward compatibility
      self._themeState = newThemeState
      -- Sync theme state with Renderer module
      if self._renderer then
        self._renderer:setThemeState(newThemeState)
      end
    end

    -- Only process button events if onEvent handler exists, element is not disabled,
    -- and this is the topmost element at the mouse position (z-index ordering)
    -- Exception: Allow drag continuation even if occluded (once drag starts, it continues)
    local isDragging = false
    for _, button in ipairs({ 1, 2, 3 }) do
      if self._pressed[button] and love.mouse.isDown(button) then
        isDragging = true
        break
      end
    end

    local canProcessEvents = (self.onEvent or self.editable) and not self.disabled and (isActiveElement or isDragging)

    if canProcessEvents then
      -- Check all three mouse buttons
      local buttons = { 1, 2, 3 } -- left, right, middle

      for _, button in ipairs(buttons) do
        if isHovering or isDragging then
          if love.mouse.isDown(button) then
            -- Button is pressed down
            if not self._pressed[button] then
              -- Check if press is on scrollbar first (skip if already handled)
              if button == 1 and not self._scrollbarPressHandled and self:_handleScrollbarPress(mx, my, button) then
                -- Scrollbar consumed the event, mark as pressed to prevent onEvent
                self._pressed[button] = true
                self._scrollbarPressHandled = true
              else
                -- Just pressed - fire press event and record drag start position
                local modifiers = getModifiers()
                if self.onEvent then
                  local pressEvent = InputEvent.new({
                    type = "press",
                    button = button,
                    x = mx,
                    y = my,
                    modifiers = modifiers,
                    clickCount = 1,
                  })
                  self.onEvent(self, pressEvent)
                end
                self._pressed[button] = true

                -- Set mouse down position for text selection on left click
                if button == 1 and self._textEditor then
                  self._mouseDownPosition = self._textEditor:mouseToTextPosition(mx, my)
                  self._textDragOccurred = false -- Reset drag flag on press
                end
              end

              -- Record drag start position per button
              self._dragStartX[button] = mx
              self._dragStartY[button] = my
              self._lastMouseX[button] = mx
              self._lastMouseY[button] = my
            else
              -- Button is still pressed - check for mouse movement (drag)
              local lastX = self._lastMouseX[button] or mx
              local lastY = self._lastMouseY[button] or my

              if lastX ~= mx or lastY ~= my then
                -- Mouse has moved - fire drag event only if still hovering
                if self.onEvent and isHovering then
                  local modifiers = getModifiers()
                  local dx = mx - self._dragStartX[button]
                  local dy = my - self._dragStartY[button]

                  local dragEvent = InputEvent.new({
                    type = "drag",
                    button = button,
                    x = mx,
                    y = my,
                    dx = dx,
                    dy = dy,
                    modifiers = modifiers,
                    clickCount = 1,
                  })
                  self.onEvent(self, dragEvent)
                end

                -- Handle text selection drag for editable elements
                if button == 1 and self.editable and self._focused then
                  self:_handleTextDrag(mx, my)
                end

                -- Update last known position for this button
                self._lastMouseX[button] = mx
                self._lastMouseY[button] = my
              end
            end
          elseif self._pressed[button] then
            -- Button was just released - fire click event
            local currentTime = love.timer.getTime()
            local modifiers = getModifiers()

            -- Determine click count (double-click detection)
            local clickCount = 1
            local doubleClickThreshold = 0.3 -- 300ms for double-click

            if self._lastClickTime and self._lastClickButton == button and (currentTime - self._lastClickTime) < doubleClickThreshold then
              clickCount = self._clickCount + 1
            else
              clickCount = 1
            end

            self._clickCount = clickCount
            self._lastClickTime = currentTime
            self._lastClickButton = button

            -- Determine event type based on button
            local eventType = "click"
            if button == 2 then
              eventType = "rightclick"
            elseif button == 3 then
              eventType = "middleclick"
            end

            if self.onEvent then
              local clickEvent = InputEvent.new({
                type = eventType,
                button = button,
                x = mx,
                y = my,
                modifiers = modifiers,
                clickCount = clickCount,
              })

              self.onEvent(self, clickEvent)
            end
            self._pressed[button] = false

            -- Clean up drag tracking
            self._dragStartX[button] = nil
            self._dragStartY[button] = nil

            -- Clean up text selection drag tracking
            if button == 1 then
              self._mouseDownPosition = nil
            end

            -- Focus editable elements on left click
            if button == 1 and self.editable then
              -- Only focus if not already focused (to avoid moving cursor to end)
              local wasFocused = self:isFocused()
              if not wasFocused then
                self:focus()
              end

              -- Handle text click for cursor positioning and word selection
              -- Only process click if no text drag occurred (to preserve drag selection)
              if not self._textDragOccurred then
                self:_handleTextClick(mx, my, clickCount)
              end

              -- Reset drag flag after release
              self._textDragOccurred = false
            elseif button == 1 then
            end

            -- Fire release event
            if self.onEvent then
              local releaseEvent = InputEvent.new({
                type = "release",
                button = button,
                x = mx,
                y = my,
                modifiers = modifiers,
                clickCount = clickCount,
              })
              self.onEvent(self, releaseEvent)
            end
          end
        else
          -- Mouse left the element - reset pressed state and drag tracking
          if self._pressed[button] then
            self._pressed[button] = false
            self._dragStartX[button] = nil
            self._dragStartY[button] = nil
          end
        end
      end
    end -- end if self.onEvent

    -- Handle touch events (maintain backward compatibility)
    if self.onEvent then
      local touches = love.touch.getTouches()
      for _, id in ipairs(touches) do
        local tx, ty = love.touch.getPosition(id)
        if tx >= bx and tx <= bx + bw and ty >= by and ty <= by + bh then
          self._touchPressed[id] = true
        elseif self._touchPressed[id] then
          -- Create touch event (treat as left click)
          local touchEvent = InputEvent.new({
            type = "click",
            button = 1,
            x = tx,
            y = ty,
            modifiers = getModifiers(),
            clickCount = 1,
          })
          self.onEvent(self, touchEvent)
          self._touchPressed[id] = false
        end
      end
    end
  end
end

--- Recalculate units based on new viewport dimensions (for vw, vh, % units)
---@param newViewportWidth number
---@param newViewportHeight number
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

--- Resize element and its children based on game window size change
---@param newGameWidth number
---@param newGameHeight number
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

--- Calculate text width for button
---@return number
function Element:calculateTextWidth()
  if self.text == nil then
    return 0
  end

  if self.textSize then
    -- Resolve font path from font family (same logic as in draw)
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
    -- Apply contentAutoSizingMultiplier if set
    if self.contentAutoSizingMultiplier and self.contentAutoSizingMultiplier.width then
      width = width * self.contentAutoSizingMultiplier.width
    end
    return width
  end

  local font = love.graphics.getFont()
  local width = font:getWidth(self.text)
  -- Apply contentAutoSizingMultiplier if set
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

  -- Get the font
  local font
  if self.textSize then
    -- Resolve font path from font family (same logic as in draw)
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

  -- If text wrapping is enabled, calculate height based on wrapped lines
  if self.textWrap and (self.textWrap == "word" or self.textWrap == "char" or self.textWrap == true) then
    -- Calculate available width for wrapping
    local availableWidth = self.width

    -- If width is not set or is 0, try to use parent's content width
    if (not availableWidth or availableWidth <= 0) and self.parent then
      -- Use parent's content width (excluding padding)
      availableWidth = self.parent.width
    end

    if availableWidth and availableWidth > 0 then
      -- Get the wrapped text lines using getWrap (returns width and table of lines)
      local wrappedWidth, wrappedLines = font:getWrap(self.text, availableWidth)
      -- Height is line height * number of lines
      height = height * #wrappedLines
    end
  end

  -- Apply contentAutoSizingMultiplier if set
  if self.contentAutoSizingMultiplier and self.contentAutoSizingMultiplier.height then
    height = height * self.contentAutoSizingMultiplier.height
  end

  return height
end

function Element:calculateAutoWidth()
  -- During construction, LayoutEngine might not be initialized yet
  -- Fall back to text width calculation
  if not self._layoutEngine then
    return self:calculateTextWidth()
  end
  -- Delegate to LayoutEngine
  return self._layoutEngine:calculateAutoWidth()
end

--- Calculate auto height based on children
function Element:calculateAutoHeight()
  -- During construction, LayoutEngine might not be initialized yet
  -- Fall back to text height calculation
  if not self._layoutEngine then
    return self:calculateTextHeight()
  end
  -- Delegate to LayoutEngine
  return self._layoutEngine:calculateAutoHeight()
end

---@param newText string
---@param autoresize boolean? --default: false
function Element:updateText(newText, autoresize)
  self.text = newText or self.text
  if autoresize then
    self.width = self:calculateTextWidth()
    self.height = self:calculateTextHeight()
  end
end

---@param newOpacity number
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

-- ====================
-- Input Handling - Cursor Management
-- ====================

--- Set cursor position
---@param position number -- Character index (0-based)
function Element:setCursorPosition(position)
  if self._textEditor then
    self._textEditor:setCursorPosition(position)
  end
end

--- Get cursor position
---@return number -- Character index (0-based)
function Element:getCursorPosition()
  if self._textEditor then
    return self._textEditor:getCursorPosition()
  end
  return 0
end

--- Move cursor by delta characters
---@param delta number -- Number of characters to move (positive or negative)
function Element:moveCursorBy(delta)
  if self._textEditor then
    self._textEditor:moveCursorBy(delta)
  end
end

--- Move cursor to start of text
function Element:moveCursorToStart()
  if self._textEditor then
    self._textEditor:moveCursorToStart()
  end
end

--- Move cursor to end of text
function Element:moveCursorToEnd()
  if self._textEditor then
    self._textEditor:moveCursorToEnd()
  end
end

--- Move cursor to start of current line
function Element:moveCursorToLineStart()
  if self._textEditor then
    self._textEditor:moveCursorToLineStart()
  end
end

--- Move cursor to end of current line
function Element:moveCursorToLineEnd()
  if self._textEditor then
    self._textEditor:moveCursorToLineEnd()
  end
end

--- Move cursor to start of previous word
function Element:moveCursorToPreviousWord()
  if self._textEditor then
    self._textEditor:moveCursorToPreviousWord()
  end
end

--- Move cursor to start of next word
function Element:moveCursorToNextWord()
  if self._textEditor then
    self._textEditor:moveCursorToNextWord()
  end
end



-- ====================
-- Input Handling - Selection Management
-- ====================

--- Set selection range
---@param startPos number -- Start position (inclusive)
---@param endPos number -- End position (inclusive)
function Element:setSelection(startPos, endPos)
  if self._textEditor then
    self._textEditor:setSelection(startPos, endPos)
  end
end

--- Get selection range
---@return number?, number? -- Start and end positions, or nil if no selection
function Element:getSelection()
  if self._textEditor then
    return self._textEditor:getSelection()
  end
  return nil, nil
end

--- Check if there is an active selection
---@return boolean
function Element:hasSelection()
  if self._textEditor then
    return self._textEditor:hasSelection()
  end
  return false
end

--- Clear selection
function Element:clearSelection()
  if self._textEditor then
    self._textEditor:clearSelection()
  end
end

--- Select all text
function Element:selectAll()
  if self._textEditor then
    self._textEditor:selectAll()
  end
end

--- Get selected text
---@return string? -- Selected text or nil if no selection
function Element:getSelectedText()
  if self._textEditor then
    return self._textEditor:getSelectedText()
  end
  return nil
end

--- Delete selected text
---@return boolean -- True if text was deleted
function Element:deleteSelection()
  if self._textEditor then
    local result = self._textEditor:deleteSelection()
    if result then
      self.text = self._textEditor:getText() -- Sync display text
      self._textEditor:updateAutoGrowHeight()
    end
    return result
  end
  return false
end

-- ====================
-- Input Handling - Focus Management
-- ====================

--- Focus this element for keyboard input
function Element:focus()
  if self._textEditor then
    self._textEditor:focus()
  end
end

--- Remove focus from this element
function Element:blur()
  if self._textEditor then
    self._textEditor:blur()
  end
end

--- Check if this element is focused
---@return boolean
function Element:isFocused()
  if self._textEditor then
    return self._textEditor:isFocused()
  end
  return false
end

-- ====================
-- Input Handling - Text Buffer Management
-- ====================

--- Get current text buffer
---@return string
function Element:getText()
  if self._textEditor then
    return self._textEditor:getText()
  end
  return self.text or ""
end

--- Set text buffer and mark dirty
---@param text string
function Element:setText(text)
  if self._textEditor then
    self._textEditor:setText(text)
    self.text = self._textEditor:getText() -- Sync display text
    self._textEditor:updateAutoGrowHeight()
    return
  end
  self.text = text
end

--- Insert text at position
---@param text string -- Text to insert
---@param position number? -- Position to insert at (default: cursor position)
function Element:insertText(text, position)
  if self._textEditor then
    self._textEditor:insertText(text, position)
    self.text = self._textEditor:getText() -- Sync display text
    self._textEditor:updateAutoGrowHeight()
  end
end

---@param startPos number -- Start position (inclusive)
---@param endPos number -- End position (inclusive)
function Element:deleteText(startPos, endPos)
  if self._textEditor then
    self._textEditor:deleteText(startPos, endPos)
    self.text = self._textEditor:getText() -- Sync display text
    self._textEditor:updateAutoGrowHeight()
  end
end

--- Replace text in range
---@param startPos number -- Start position (inclusive)
---@param endPos number -- End position (inclusive)
---@param newText string -- Replacement text
function Element:replaceText(startPos, endPos, newText)
  if self._textEditor then
    self._textEditor:replaceText(startPos, endPos, newText)
    self.text = self._textEditor:getText() -- Sync display text
    self._textEditor:updateAutoGrowHeight()
  end
end

--- Split text into lines (for multi-line text)
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



-- ====================
-- Input Handling - Mouse Selection
-- ====================

--- Convert mouse coordinates to cursor position in text
---@param mouseX number -- Mouse X coordinate (absolute)
---@param mouseY number -- Mouse Y coordinate (absolute)
---@return number -- Cursor position (character index)
function Element:_mouseToTextPosition(mouseX, mouseY)
  if not self.editable or not self._textBuffer then
    return 0
  end

  -- Get content area bounds
  local contentX = (self._absoluteX or self.x) + self.padding.left
  local contentY = (self._absoluteY or self.y) + self.padding.top

  -- Calculate relative position within text area
  local relativeX = mouseX - contentX
  local relativeY = mouseY - contentY

  -- Get font for measuring text
  local font = self:_getFont()
  if not font then
    return 0
  end

  local text = self._textBuffer
  local textLength = utf8.len(text) or 0

  -- === SINGLE-LINE TEXT HANDLING ===
  if not self.multiline then
    -- Account for horizontal scroll offset in single-line inputs
    if self._textScrollX then
      relativeX = relativeX + self._textScrollX
    end

    -- Find the character position closest to the click
    local closestPos = 0
    local closestDist = math.huge

    -- Check each position in the text
    for i = 0, textLength do
      -- Get text up to this position
      local offset = utf8.offset(text, i + 1)
      local beforeText = offset and text:sub(1, offset - 1) or text
      local textWidth = font:getWidth(beforeText)

      -- Calculate distance from click to this position
      local dist = math.abs(relativeX - textWidth)

      if dist < closestDist then
        closestDist = dist
        closestPos = i
      end
    end

    return closestPos
  end

  -- === MULTILINE TEXT HANDLING ===

  -- Update text wrapping if dirty
  if self._textEditor then
    self._textEditor:_updateTextIfDirty()
  end

  -- Split text into lines
  local lines = {}
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(lines, line)
  end
  if #lines == 0 then
    lines = { "" }
  end

  local lineHeight = font:getHeight()

  -- Get text area width for wrapping calculations
  local textAreaWidth = self.width
  local scaledContentPadding = self:getScaledContentPadding()
  if scaledContentPadding then
    local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
    textAreaWidth = borderBoxWidth - scaledContentPadding.left - scaledContentPadding.right
  end

  -- Determine which line the click is on based on Y coordinate
  local clickedLineNum = math.floor(relativeY / lineHeight) + 1
  clickedLineNum = math.max(1, math.min(clickedLineNum, #lines))

  -- Calculate character offset for lines before the clicked line
  local charOffset = 0
  for i = 1, clickedLineNum - 1 do
    local lineLen = utf8.len(lines[i]) or 0
    charOffset = charOffset + lineLen + 1 -- +1 for newline character
  end

  -- Get the clicked line
  local clickedLine = lines[clickedLineNum]
  local lineLen = utf8.len(clickedLine) or 0

  -- If text wrapping is enabled, handle wrapped segments
  if self.textWrap and textAreaWidth > 0 then
    local wrappedSegments = self:_wrapLine(clickedLine, textAreaWidth)

    -- Determine which wrapped segment was clicked
    local lineYOffset = (clickedLineNum - 1) * lineHeight
    local segmentNum = math.floor((relativeY - lineYOffset) / lineHeight) + 1
    segmentNum = math.max(1, math.min(segmentNum, #wrappedSegments))

    local segment = wrappedSegments[segmentNum]

    -- Find closest position within the segment
    local segmentText = segment.text
    local segmentLen = utf8.len(segmentText) or 0
    local closestPos = segment.startIdx
    local closestDist = math.huge

    for i = 0, segmentLen do
      local offset = utf8.offset(segmentText, i + 1)
      local beforeText = offset and segmentText:sub(1, offset - 1) or segmentText
      local textWidth = font:getWidth(beforeText)
      local dist = math.abs(relativeX - textWidth)

      if dist < closestDist then
        closestDist = dist
        closestPos = segment.startIdx + i
      end
    end

    return charOffset + closestPos
  end

  -- No wrapping - find closest position in the clicked line
  local closestPos = 0
  local closestDist = math.huge

  for i = 0, lineLen do
    local offset = utf8.offset(clickedLine, i + 1)
    local beforeText = offset and clickedLine:sub(1, offset - 1) or clickedLine
    local textWidth = font:getWidth(beforeText)
    local dist = math.abs(relativeX - textWidth)

    if dist < closestDist then
      closestDist = dist
      closestPos = i
    end
  end

  return charOffset + closestPos
end

--- Handle mouse click on text (set cursor position or start selection)
---@param mouseX number -- Mouse X coordinate
---@param mouseY number -- Mouse Y coordinate
---@param clickCount number -- Number of clicks (1=single, 2=double, 3=triple)
function Element:_handleTextClick(mouseX, mouseY, clickCount)
  if self._textEditor then
    self._textEditor:handleTextClick(mouseX, mouseY, clickCount)
    -- Store mouse down position on element for drag tracking
    if clickCount == 1 then
      self._mouseDownPosition = self._textEditor:mouseToTextPosition(mouseX, mouseY)
    end
  end
end

--- Handle mouse drag for text selection
---@param mouseX number -- Mouse X coordinate
---@param mouseY number -- Mouse Y coordinate
function Element:_handleTextDrag(mouseX, mouseY)
  if self._textEditor then
    self._textEditor:handleTextDrag(mouseX, mouseY)
    self._textDragOccurred = self._textEditor._textDragOccurred
  end
end



-- ====================
-- Input Handling - Keyboard Input
-- ====================

--- Handle text input (character input)
---@param text string -- Character(s) to insert
function Element:textinput(text)
  if self._textEditor then
    self._textEditor:handleTextInput(text)
    self.text = self._textEditor:getText() -- Sync display text
    self._textEditor:updateAutoGrowHeight()
  end
end

--- Handle key press (special keys)
---@param key string -- Key name
---@param scancode string -- Scancode
---@param isrepeat boolean -- Whether this is a key repeat
function Element:keypressed(key, scancode, isrepeat)
  if self._textEditor then
    self._textEditor:handleKeyPress(key, scancode, isrepeat)
    self.text = self._textEditor:getText() -- Sync display text
    self._textEditor:updateAutoGrowHeight()
  end
end

return Element
