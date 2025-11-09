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
---@field callback fun(element:Element, event:InputEvent)? -- Callback function for interaction events
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
  self.callback = props.callback

  -- Auto-generate ID in immediate mode if not provided
  if Gui._immediateMode and (not props.id or props.id == "") then
    self.id = StateManager.generateID(props)
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
  if self.editable then
    self._cursorPosition = 0 -- Character index (0 = before first char)
    self._cursorLine = 1 -- Current line number (1-based)
    self._cursorColumn = 0 -- Column within current line
    self._cursorBlinkTimer = 0
    self._cursorVisible = true

    -- Selection state
    self._selectionStart = nil -- nil = no selection
    self._selectionEnd = nil
    self._selectionAnchor = nil -- Anchor point for shift+arrow selection

    -- Focus state
    self._focused = false

    -- Text buffer state (initialized after self.text is set below)
    self._textBuffer = props.text or "" -- Actual text content
    self._lines = nil -- Split lines (for multiline)
    self._wrappedLines = nil -- Wrapped line data
    self._textDirty = true -- Flag to recalculate lines/wrapping

    -- Scroll state for text overflow
    self._textScrollX = 0 -- Horizontal scroll offset in pixels
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

  self.text = props.text
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
    -- Calculate auto-width without padding first
    tempWidth = self:calculateAutoWidth()
    self.width = tempWidth
    self.units.width = { value = nil, unit = "auto" } -- Mark as auto-sized
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

  -- Register element in z-index tracking for immediate mode
  if Gui._immediateMode then
    GuiState.registerElement(self)
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
---@param dims table -- Scrollbar dimensions from _calculateScrollbarDimensions()
function Element:_drawScrollbars(dims)
  local x, y = self.x, self.y
  local w, h = self.width, self.height

  -- Vertical scrollbar
  if dims.vertical.visible and not self.hideScrollbars.vertical then
    -- Position scrollbar within content area (x, y is border-box origin)
    local contentX = x + self.padding.left
    local contentY = y + self.padding.top
    local trackX = contentX + w - self.scrollbarWidth - self.scrollbarPadding
    local trackY = contentY + self.scrollbarPadding

    -- Determine thumb color based on state (independent for vertical)
    local thumbColor = self.scrollbarColor
    if self._scrollbarDragging and self._hoveredScrollbar == "vertical" then
      -- Active state: brighter
      thumbColor = Color.new(math.min(1, thumbColor.r * 1.4), math.min(1, thumbColor.g * 1.4), math.min(1, thumbColor.b * 1.4), thumbColor.a)
    elseif self._scrollbarHoveredVertical then
      -- Hover state: slightly brighter
      thumbColor = Color.new(math.min(1, thumbColor.r * 1.2), math.min(1, thumbColor.g * 1.2), math.min(1, thumbColor.b * 1.2), thumbColor.a)
    end

    -- Draw track
    love.graphics.setColor(self.scrollbarTrackColor:toRGBA())
    love.graphics.rectangle("fill", trackX, trackY, self.scrollbarWidth, dims.vertical.trackHeight, self.scrollbarRadius)

    -- Draw thumb with state-based color
    love.graphics.setColor(thumbColor:toRGBA())
    love.graphics.rectangle("fill", trackX, trackY + dims.vertical.thumbY, self.scrollbarWidth, dims.vertical.thumbHeight, self.scrollbarRadius)
  end

  -- Horizontal scrollbar
  if dims.horizontal.visible and not self.hideScrollbars.horizontal then
    -- Position scrollbar within content area (x, y is border-box origin)
    local contentX = x + self.padding.left
    local contentY = y + self.padding.top
    local trackX = contentX + self.scrollbarPadding
    local trackY = contentY + h - self.scrollbarWidth - self.scrollbarPadding

    -- Determine thumb color based on state (independent for horizontal)
    local thumbColor = self.scrollbarColor
    if self._scrollbarDragging and self._hoveredScrollbar == "horizontal" then
      -- Active state: brighter
      thumbColor = Color.new(math.min(1, thumbColor.r * 1.4), math.min(1, thumbColor.g * 1.4), math.min(1, thumbColor.b * 1.4), thumbColor.a)
    elseif self._scrollbarHoveredHorizontal then
      -- Hover state: slightly brighter
      thumbColor = Color.new(math.min(1, thumbColor.r * 1.2), math.min(1, thumbColor.g * 1.2), math.min(1, thumbColor.b * 1.2), thumbColor.a)
    end

    -- Draw track
    love.graphics.setColor(self.scrollbarTrackColor:toRGBA())
    love.graphics.rectangle("fill", trackX, trackY, dims.horizontal.trackWidth, self.scrollbarWidth, self.scrollbarRadius)

    -- Draw thumb with state-based color
    love.graphics.setColor(thumbColor:toRGBA())
    love.graphics.rectangle("fill", trackX + dims.horizontal.thumbX, trackY, dims.horizontal.thumbWidth, self.scrollbarWidth, self.scrollbarRadius)
  end

  -- Reset color
  love.graphics.setColor(1, 1, 1, 1)
end

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
    if self.autosizing.height then
      local contentHeight = self:calculateAutoHeight()
      -- BORDER-BOX MODEL: Add padding to get border-box, then subtract to get content
      self._borderBoxHeight = contentHeight + self.padding.top + self.padding.bottom
      self.height = contentHeight
    end
    if self.autosizing.width then
      local contentWidth = self:calculateAutoWidth()
      -- BORDER-BOX MODEL: Add padding to get border-box, then subtract to get content
      self._borderBoxWidth = contentWidth + self.padding.left + self.padding.right
      self.width = contentWidth
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
  if not element then
    return
  end

  -- For CSS-style positioning, we need the parent's bounds
  local parent = element.parent
  if not parent then
    return
  end

  -- Only apply offsets to explicitly absolute children or children in relative/absolute containers
  -- Flex/grid children ignore positioning offsets as they participate in layout
  local isFlexChild = element.positioning == Positioning.FLEX
    or element.positioning == Positioning.GRID
    or (element.positioning == Positioning.ABSOLUTE and not element._explicitlyAbsolute)

  if not isFlexChild then
    -- Apply absolute positioning for explicitly absolute children
    -- Apply top offset (distance from parent's content box top edge)
    if element.top then
      element.y = parent.y + parent.padding.top + element.top
    end

    -- Apply bottom offset (distance from parent's content box bottom edge)
    -- BORDER-BOX MODEL: Use border-box dimensions for positioning
    if element.bottom then
      local elementBorderBoxHeight = element:getBorderBoxHeight()
      element.y = parent.y + parent.padding.top + parent.height - element.bottom - elementBorderBoxHeight
    end

    -- Apply left offset (distance from parent's content box left edge)
    if element.left then
      element.x = parent.x + parent.padding.left + element.left
    end

    -- Apply right offset (distance from parent's content box right edge)
    -- BORDER-BOX MODEL: Use border-box dimensions for positioning
    if element.right then
      local elementBorderBoxWidth = element:getBorderBoxWidth()
      element.x = parent.x + parent.padding.left + parent.width - element.right - elementBorderBoxWidth
    end
  end
end

function Element:layoutChildren()
  if self.positioning == Positioning.ABSOLUTE or self.positioning == Positioning.RELATIVE then
    -- Absolute/Relative positioned containers don't layout their children according to flex rules,
    -- but they should still apply CSS positioning offsets to their children
    for _, child in ipairs(self.children) do
      if child.top or child.right or child.bottom or child.left then
        self:applyPositioningOffsets(child)
      end
    end
    return
  end

  -- Handle grid layout
  if self.positioning == Positioning.GRID then
    Grid.layoutGridItems(self)
    return
  end

  local childCount = #self.children

  if childCount == 0 then
    return
  end

  -- Get flex children (children that participate in flex layout)
  local flexChildren = {}
  for _, child in ipairs(self.children) do
    local isFlexChild = not (child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute)
    if isFlexChild then
      table.insert(flexChildren, child)
    end
  end

  if #flexChildren == 0 then
    return
  end

  -- Calculate space reserved by absolutely positioned siblings with explicit positioning
  local reservedMainStart = 0 -- Space reserved at the start of main axis (left for horizontal, top for vertical)
  local reservedMainEnd = 0 -- Space reserved at the end of main axis (right for horizontal, bottom for vertical)
  local reservedCrossStart = 0 -- Space reserved at the start of cross axis (top for horizontal, left for vertical)
  local reservedCrossEnd = 0 -- Space reserved at the end of cross axis (bottom for horizontal, right for vertical)

  for _, child in ipairs(self.children) do
    -- Only consider absolutely positioned children with explicit positioning
    if child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute then
      -- BORDER-BOX MODEL: Use border-box dimensions for space calculations
      local childBorderBoxWidth = child:getBorderBoxWidth()
      local childBorderBoxHeight = child:getBorderBoxHeight()

      if self.flexDirection == FlexDirection.HORIZONTAL then
        -- Horizontal layout: main axis is X, cross axis is Y
        -- Check for left positioning (reserves space at main axis start)
        if child.left then
          local spaceNeeded = child.left + childBorderBoxWidth
          reservedMainStart = math.max(reservedMainStart, spaceNeeded)
        end
        -- Check for right positioning (reserves space at main axis end)
        if child.right then
          local spaceNeeded = child.right + childBorderBoxWidth
          reservedMainEnd = math.max(reservedMainEnd, spaceNeeded)
        end
        -- Check for top positioning (reserves space at cross axis start)
        if child.top then
          local spaceNeeded = child.top + childBorderBoxHeight
          reservedCrossStart = math.max(reservedCrossStart, spaceNeeded)
        end
        -- Check for bottom positioning (reserves space at cross axis end)
        if child.bottom then
          local spaceNeeded = child.bottom + childBorderBoxHeight
          reservedCrossEnd = math.max(reservedCrossEnd, spaceNeeded)
        end
      else
        -- Vertical layout: main axis is Y, cross axis is X
        -- Check for top positioning (reserves space at main axis start)
        if child.top then
          local spaceNeeded = child.top + childBorderBoxHeight
          reservedMainStart = math.max(reservedMainStart, spaceNeeded)
        end
        -- Check for bottom positioning (reserves space at main axis end)
        if child.bottom then
          local spaceNeeded = child.bottom + childBorderBoxHeight
          reservedMainEnd = math.max(reservedMainEnd, spaceNeeded)
        end
        -- Check for left positioning (reserves space at cross axis start)
        if child.left then
          local spaceNeeded = child.left + childBorderBoxWidth
          reservedCrossStart = math.max(reservedCrossStart, spaceNeeded)
        end
        -- Check for right positioning (reserves space at cross axis end)
        if child.right then
          local spaceNeeded = child.right + childBorderBoxWidth
          reservedCrossEnd = math.max(reservedCrossEnd, spaceNeeded)
        end
      end
    end
  end

  -- Calculate available space (accounting for padding and reserved space)
  -- BORDER-BOX MODEL: self.width and self.height are already content dimensions (padding subtracted)
  local availableMainSize = 0
  local availableCrossSize = 0
  if self.flexDirection == FlexDirection.HORIZONTAL then
    availableMainSize = self.width - reservedMainStart - reservedMainEnd
    availableCrossSize = self.height - reservedCrossStart - reservedCrossEnd
  else
    availableMainSize = self.height - reservedMainStart - reservedMainEnd
    availableCrossSize = self.width - reservedCrossStart - reservedCrossEnd
  end

  -- Handle flex wrap: create lines of children
  local lines = {}

  if self.flexWrap == FlexWrap.NOWRAP then
    -- All children go on one line
    lines[1] = flexChildren
  else
    -- Wrap children into multiple lines
    local currentLine = {}
    local currentLineSize = 0

    for _, child in ipairs(flexChildren) do
      -- BORDER-BOX MODEL: Use border-box dimensions for layout calculations
      -- Include margins in size calculations
      local childMainSize = 0
      local childMainMargin = 0
      if self.flexDirection == FlexDirection.HORIZONTAL then
        childMainSize = child:getBorderBoxWidth()
        childMainMargin = child.margin.left + child.margin.right
      else
        childMainSize = child:getBorderBoxHeight()
        childMainMargin = child.margin.top + child.margin.bottom
      end
      local childTotalMainSize = childMainSize + childMainMargin

      -- Check if adding this child would exceed the available space
      local lineSpacing = #currentLine > 0 and self.gap or 0
      if #currentLine > 0 and currentLineSize + lineSpacing + childTotalMainSize > availableMainSize then
        -- Start a new line
        if #currentLine > 0 then
          table.insert(lines, currentLine)
        end
        currentLine = { child }
        currentLineSize = childTotalMainSize
      else
        -- Add to current line
        table.insert(currentLine, child)
        currentLineSize = currentLineSize + lineSpacing + childTotalMainSize
      end
    end

    -- Add the last line if it has children
    if #currentLine > 0 then
      table.insert(lines, currentLine)
    end

    -- Handle wrap-reverse: reverse the order of lines
    if self.flexWrap == FlexWrap.WRAP_REVERSE then
      local reversedLines = {}
      for i = #lines, 1, -1 do
        table.insert(reversedLines, lines[i])
      end
      lines = reversedLines
    end
  end

  -- Calculate line positions and heights (including child padding)
  local lineHeights = {}
  local totalLinesHeight = 0

  for lineIndex, line in ipairs(lines) do
    local maxCrossSize = 0
    for _, child in ipairs(line) do
      -- BORDER-BOX MODEL: Use border-box dimensions for layout calculations
      -- Include margins in cross-axis size calculations
      local childCrossSize = 0
      local childCrossMargin = 0
      if self.flexDirection == FlexDirection.HORIZONTAL then
        childCrossSize = child:getBorderBoxHeight()
        childCrossMargin = child.margin.top + child.margin.bottom
      else
        childCrossSize = child:getBorderBoxWidth()
        childCrossMargin = child.margin.left + child.margin.right
      end
      local childTotalCrossSize = childCrossSize + childCrossMargin
      maxCrossSize = math.max(maxCrossSize, childTotalCrossSize)
    end
    lineHeights[lineIndex] = maxCrossSize
    totalLinesHeight = totalLinesHeight + maxCrossSize
  end

  -- Account for gaps between lines
  local lineGaps = math.max(0, #lines - 1) * self.gap
  totalLinesHeight = totalLinesHeight + lineGaps

  -- For single line layouts, CENTER, FLEX_END and STRETCH should use full cross size
  if #lines == 1 then
    if self.alignItems == AlignItems.STRETCH or self.alignItems == AlignItems.CENTER or self.alignItems == AlignItems.FLEX_END then
      -- STRETCH, CENTER, and FLEX_END should use full available cross size
      lineHeights[1] = availableCrossSize
      totalLinesHeight = availableCrossSize
    end
    -- CENTER and FLEX_END should preserve natural child dimensions
    -- and only affect positioning within the available space
  end

  -- Calculate starting position for lines based on alignContent
  local lineStartPos = 0
  local lineSpacing = self.gap
  local freeLineSpace = availableCrossSize - totalLinesHeight

  -- Apply AlignContent logic for both single and multiple lines
  if self.alignContent == AlignContent.FLEX_START then
    lineStartPos = 0
  elseif self.alignContent == AlignContent.CENTER then
    lineStartPos = freeLineSpace / 2
  elseif self.alignContent == AlignContent.FLEX_END then
    lineStartPos = freeLineSpace
  elseif self.alignContent == AlignContent.SPACE_BETWEEN then
    lineStartPos = 0
    if #lines > 1 then
      lineSpacing = self.gap + (freeLineSpace / (#lines - 1))
    end
  elseif self.alignContent == AlignContent.SPACE_AROUND then
    local spaceAroundEach = freeLineSpace / #lines
    lineStartPos = spaceAroundEach / 2
    lineSpacing = self.gap + spaceAroundEach
  elseif self.alignContent == AlignContent.STRETCH then
    lineStartPos = 0
    if #lines > 1 and freeLineSpace > 0 then
      lineSpacing = self.gap + (freeLineSpace / #lines)
      -- Distribute extra space to line heights (only if positive)
      local extraPerLine = freeLineSpace / #lines
      for i = 1, #lineHeights do
        lineHeights[i] = lineHeights[i] + extraPerLine
      end
    end
  end

  -- Position children within each line
  local currentCrossPos = lineStartPos

  for lineIndex, line in ipairs(lines) do
    local lineHeight = lineHeights[lineIndex]

    -- Calculate total size of children in this line (including padding and margins)
    -- BORDER-BOX MODEL: Use border-box dimensions for layout calculations
    local totalChildrenSize = 0
    for _, child in ipairs(line) do
      if self.flexDirection == FlexDirection.HORIZONTAL then
        totalChildrenSize = totalChildrenSize + child:getBorderBoxWidth() + child.margin.left + child.margin.right
      else
        totalChildrenSize = totalChildrenSize + child:getBorderBoxHeight() + child.margin.top + child.margin.bottom
      end
    end

    local totalGapSize = math.max(0, #line - 1) * self.gap
    local totalContentSize = totalChildrenSize + totalGapSize
    local freeSpace = availableMainSize - totalContentSize

    -- Calculate initial position and spacing based on justifyContent
    local startPos = 0
    local itemSpacing = self.gap

    if self.justifyContent == JustifyContent.FLEX_START then
      startPos = 0
    elseif self.justifyContent == JustifyContent.CENTER then
      startPos = freeSpace / 2
    elseif self.justifyContent == JustifyContent.FLEX_END then
      startPos = freeSpace
    elseif self.justifyContent == JustifyContent.SPACE_BETWEEN then
      startPos = 0
      if #line > 1 then
        itemSpacing = self.gap + (freeSpace / (#line - 1))
      end
    elseif self.justifyContent == JustifyContent.SPACE_AROUND then
      local spaceAroundEach = freeSpace / #line
      startPos = spaceAroundEach / 2
      itemSpacing = self.gap + spaceAroundEach
    elseif self.justifyContent == JustifyContent.SPACE_EVENLY then
      local spaceBetween = freeSpace / (#line + 1)
      startPos = spaceBetween
      itemSpacing = self.gap + spaceBetween
    end

    -- Position children in this line
    local currentMainPos = startPos

    for _, child in ipairs(line) do
      -- Determine effective cross-axis alignment
      local effectiveAlign = child.alignSelf
      if effectiveAlign == nil or effectiveAlign == AlignSelf.AUTO then
        effectiveAlign = self.alignItems
      end

      if self.flexDirection == FlexDirection.HORIZONTAL then
        -- Horizontal layout: main axis is X, cross axis is Y
        -- Position child at border box (x, y represents top-left including padding)
        -- Add reservedMainStart and left margin to account for absolutely positioned siblings and margins
        child.x = self.x + self.padding.left + reservedMainStart + currentMainPos + child.margin.left

        -- BORDER-BOX MODEL: Use border-box dimensions for alignment calculations
        local childBorderBoxHeight = child:getBorderBoxHeight()
        local childTotalCrossSize = childBorderBoxHeight + child.margin.top + child.margin.bottom

        if effectiveAlign == AlignItems.FLEX_START then
          child.y = self.y + self.padding.top + reservedCrossStart + currentCrossPos + child.margin.top
        elseif effectiveAlign == AlignItems.CENTER then
          child.y = self.y + self.padding.top + reservedCrossStart + currentCrossPos + ((lineHeight - childTotalCrossSize) / 2) + child.margin.top
        elseif effectiveAlign == AlignItems.FLEX_END then
          child.y = self.y + self.padding.top + reservedCrossStart + currentCrossPos + lineHeight - childTotalCrossSize + child.margin.top
        elseif effectiveAlign == AlignItems.STRETCH then
          -- STRETCH: Only apply if height was not explicitly set
          if child.autosizing and child.autosizing.height then
            -- STRETCH: Set border-box height to lineHeight minus margins, content area shrinks to fit
            local availableHeight = lineHeight - child.margin.top - child.margin.bottom
            child._borderBoxHeight = availableHeight
            child.height = math.max(0, availableHeight - child.padding.top - child.padding.bottom)
          end
          child.y = self.y + self.padding.top + reservedCrossStart + currentCrossPos + child.margin.top
        end

        -- Apply positioning offsets (top, right, bottom, left)
        self:applyPositioningOffsets(child)

        -- If child has children, re-layout them after position change
        if #child.children > 0 then
          child:layoutChildren()
        end

        -- Advance position by child's border-box width plus margins
        currentMainPos = currentMainPos + child:getBorderBoxWidth() + child.margin.left + child.margin.right + itemSpacing
      else
        -- Vertical layout: main axis is Y, cross axis is X
        -- Position child at border box (x, y represents top-left including padding)
        -- Add reservedMainStart and top margin to account for absolutely positioned siblings and margins
        child.y = self.y + self.padding.top + reservedMainStart + currentMainPos + child.margin.top

        -- BORDER-BOX MODEL: Use border-box dimensions for alignment calculations
        local childBorderBoxWidth = child:getBorderBoxWidth()
        local childTotalCrossSize = childBorderBoxWidth + child.margin.left + child.margin.right

        if effectiveAlign == AlignItems.FLEX_START then
          child.x = self.x + self.padding.left + reservedCrossStart + currentCrossPos + child.margin.left
        elseif effectiveAlign == AlignItems.CENTER then
          child.x = self.x + self.padding.left + reservedCrossStart + currentCrossPos + ((lineHeight - childTotalCrossSize) / 2) + child.margin.left
        elseif effectiveAlign == AlignItems.FLEX_END then
          child.x = self.x + self.padding.left + reservedCrossStart + currentCrossPos + lineHeight - childTotalCrossSize + child.margin.left
        elseif effectiveAlign == AlignItems.STRETCH then
          -- STRETCH: Only apply if width was not explicitly set
          if child.autosizing and child.autosizing.width then
            -- STRETCH: Set border-box width to lineHeight minus margins, content area shrinks to fit
            local availableWidth = lineHeight - child.margin.left - child.margin.right
            child._borderBoxWidth = availableWidth
            child.width = math.max(0, availableWidth - child.padding.left - child.padding.right)
          end
          child.x = self.x + self.padding.left + reservedCrossStart + currentCrossPos + child.margin.left
        end

        -- Apply positioning offsets (top, right, bottom, left)
        self:applyPositioningOffsets(child)

        -- If child has children, re-layout them after position change
        if #child.children > 0 then
          child:layoutChildren()
        end

        -- Advance position by child's border-box height plus margins
        currentMainPos = currentMainPos + child:getBorderBoxHeight() + child.margin.top + child.margin.bottom + itemSpacing
      end
    end

    -- Move to next line position
    currentCrossPos = currentCrossPos + lineHeight + lineSpacing
  end

  -- Position explicitly absolute children after flex layout
  for _, child in ipairs(self.children) do
    if child.positioning == Positioning.ABSOLUTE and child._explicitlyAbsolute then
      -- Apply positioning offsets (top, right, bottom, left)
      self:applyPositioningOffsets(child)

      -- If child has children, layout them after position change
      if #child.children > 0 then
        child:layoutChildren()
      end
    end
  end

  -- Detect overflow after children are laid out
  self:_detectOverflow()
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

  -- Clear callback to prevent closure leaks
  self.callback = nil
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

  -- LAYER 0.5: Draw backdrop blur if configured (before background)
  if self.backdropBlur and self.backdropBlur.intensity > 0 and backdropCanvas then
    local blurInstance = self:getBlurInstance()
    if blurInstance then
      Blur.applyBackdrop(blurInstance, self.backdropBlur.intensity, self.x, self.y, borderBoxWidth, borderBoxHeight, backdropCanvas)
    end
  end

  -- LAYER 1: Draw backgroundColor first (behind everything)
  -- Apply opacity to all drawing operations
  -- (x, y) represents border box, so draw background from (x, y)
  -- BORDER-BOX MODEL: Use stored border-box dimensions for drawing
  local backgroundWithOpacity = Color.new(drawBackgroundColor.r, drawBackgroundColor.g, drawBackgroundColor.b, drawBackgroundColor.a * self.opacity)
  love.graphics.setColor(backgroundWithOpacity:toRGBA())
  RoundedRect.draw("fill", self.x, self.y, borderBoxWidth, borderBoxHeight, self.cornerRadius)

  -- LAYER 1.5: Draw image on top of backgroundColor (if image exists)
  if self._loadedImage then
    -- Calculate image bounds (content area - respects padding)
    local imageX = self.x + self.padding.left
    local imageY = self.y + self.padding.top
    local imageWidth = self.width
    local imageHeight = self.height

    -- Combine element opacity with imageOpacity
    local finalOpacity = self.opacity * self.imageOpacity

    -- Apply cornerRadius clipping if set
    local hasCornerRadius = self.cornerRadius.topLeft > 0
      or self.cornerRadius.topRight > 0
      or self.cornerRadius.bottomLeft > 0
      or self.cornerRadius.bottomRight > 0

    if hasCornerRadius then
      -- Use stencil to clip image to rounded corners
      love.graphics.stencil(function()
        RoundedRect.draw("fill", self.x, self.y, borderBoxWidth, borderBoxHeight, self.cornerRadius)
      end, "replace", 1)
      love.graphics.setStencilTest("greater", 0)
    end

    -- Draw the image
    ImageRenderer.draw(self._loadedImage, imageX, imageY, imageWidth, imageHeight, self.objectFit, self.objectPosition, finalOpacity)

    -- Clear stencil if it was used
    if hasCornerRadius then
      love.graphics.setStencilTest()
    end
  end

  -- LAYER 2: Draw theme on top of backgroundColor (if theme exists)
  if self.themeComponent then
    -- Get the theme to use
    local themeToUse = nil
    if self.theme then
      -- Element specifies a specific theme - load it if needed
      if Theme.get(self.theme) then
        themeToUse = Theme.get(self.theme)
      else
        -- Try to load the theme
        pcall(function()
          Theme.load(self.theme)
        end)
        themeToUse = Theme.get(self.theme)
      end
    else
      -- Use active theme
      themeToUse = Theme.getActive()
    end

    if themeToUse then
      -- Get the component from the theme
      local component = themeToUse.components[self.themeComponent]
      if component then
        -- Check for state-specific override
        local state = self._themeState
        if state and component.states and component.states[state] then
          component = component.states[state]
        end

        -- Use component-specific atlas if available, otherwise use theme atlas
        local atlasToUse = component._loadedAtlas or themeToUse.atlas

        if atlasToUse and component.regions then
          -- Validate component has required structure
          local hasAllRegions = component.regions.topLeft
            and component.regions.topCenter
            and component.regions.topRight
            and component.regions.middleLeft
            and component.regions.middleCenter
            and component.regions.middleRight
            and component.regions.bottomLeft
            and component.regions.bottomCenter
            and component.regions.bottomRight
          if hasAllRegions then
            -- Calculate border-box dimensions (content + padding)
            local borderBoxWidth = self.width + self.padding.left + self.padding.right
            local borderBoxHeight = self.height + self.padding.top + self.padding.bottom
            -- Pass element-level overrides for scaleCorners and scalingAlgorithm
            NinePatch.draw(component, atlasToUse, self.x, self.y, borderBoxWidth, borderBoxHeight, self.opacity, self.scaleCorners, self.scalingAlgorithm)
          else
            -- Silently skip drawing if component structure is invalid
          end
        end
      else
        -- Component not found in theme
      end
    else
      -- No theme available for themeComponent
    end
  end

  -- LAYER 3: Draw borders on top of theme (always render if specified)
  local borderColorWithOpacity = Color.new(self.borderColor.r, self.borderColor.g, self.borderColor.b, self.borderColor.a * self.opacity)
  love.graphics.setColor(borderColorWithOpacity:toRGBA())

  -- Check if all borders are enabled
  local allBorders = self.border.top and self.border.bottom and self.border.left and self.border.right

  if allBorders then
    -- Draw complete rounded rectangle border
    RoundedRect.draw("line", self.x, self.y, borderBoxWidth, borderBoxHeight, self.cornerRadius)
  else
    -- Draw individual borders (without rounded corners for partial borders)
    if self.border.top then
      love.graphics.line(self.x, self.y, self.x + borderBoxWidth, self.y)
    end
    if self.border.bottom then
      love.graphics.line(self.x, self.y + borderBoxHeight, self.x + borderBoxWidth, self.y + borderBoxHeight)
    end
    if self.border.left then
      love.graphics.line(self.x, self.y, self.x, self.y + borderBoxHeight)
    end
    if self.border.right then
      love.graphics.line(self.x + borderBoxWidth, self.y, self.x + borderBoxWidth, self.y + borderBoxHeight)
    end
  end

  -- Draw element text if present
  -- For editable elements, also handle placeholder
  -- Update text layout if dirty (for multiline auto-grow)
  if self.editable then
    self:_updateTextIfDirty()
    self:_updateAutoGrowHeight()
  end

  -- For editable elements, use _textBuffer; for non-editable, use text
  local displayText = self.editable and self._textBuffer or self.text
  local isPlaceholder = false

  -- Show placeholder if editable, empty, and not focused
  if self.editable and (not displayText or displayText == "") and self.placeholder and not self._focused then
    displayText = self.placeholder
    isPlaceholder = true
  end

  if displayText and displayText ~= "" then
    local textColor = isPlaceholder and Color.new(self.textColor.r * 0.5, self.textColor.g * 0.5, self.textColor.b * 0.5, self.textColor.a * 0.5)
      or self.textColor
    local textColorWithOpacity = Color.new(textColor.r, textColor.g, textColor.b, textColor.a * self.opacity)
    love.graphics.setColor(textColorWithOpacity:toRGBA())

    local origFont = love.graphics.getFont()
    if self.textSize then
      -- Resolve font path from font family
      local fontPath = nil
      if self.fontFamily then
        -- Check if fontFamily is a theme font name
        local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
        if themeToUse and themeToUse.fonts and themeToUse.fonts[self.fontFamily] then
          fontPath = themeToUse.fonts[self.fontFamily]
        else
          -- Treat as direct path to font file
          fontPath = self.fontFamily
        end
      elseif self.themeComponent then
        -- If using themeComponent but no fontFamily specified, check for default font in theme
        local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
        if themeToUse and themeToUse.fonts and themeToUse.fonts.default then
          fontPath = themeToUse.fonts.default
        end
      end

      -- Use cached font instead of creating new one every frame
      local font = FONT_CACHE.get(self.textSize, fontPath)
      love.graphics.setFont(font)
    end
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(displayText)
    local textHeight = font:getHeight()
    local tx, ty

    -- Text is drawn in the content box (inside padding)
    -- For 9-patch components, use contentPadding if available
    local textPaddingLeft = self.padding.left
    local textPaddingTop = self.padding.top
    local textAreaWidth = self.width
    local textAreaHeight = self.height

    -- Check if we should use 9-patch contentPadding for text positioning
    local scaledContentPadding = self:getScaledContentPadding()
    if scaledContentPadding then
      local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
      local borderBoxHeight = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)

      textPaddingLeft = scaledContentPadding.left
      textPaddingTop = scaledContentPadding.top
      textAreaWidth = borderBoxWidth - scaledContentPadding.left - scaledContentPadding.right
      textAreaHeight = borderBoxHeight - scaledContentPadding.top - scaledContentPadding.bottom
    end

    local contentX = self.x + textPaddingLeft
    local contentY = self.y + textPaddingTop

    -- Check if text wrapping is enabled
    if self.textWrap and (self.textWrap == "word" or self.textWrap == "char" or self.textWrap == true) then
      -- Use printf for wrapped text
      local align = "left"
      if self.textAlign == TextAlign.CENTER then
        align = "center"
      elseif self.textAlign == TextAlign.END then
        align = "right"
      elseif self.textAlign == TextAlign.JUSTIFY then
        align = "justify"
      end

      tx = contentX
      ty = contentY

      -- Use printf with the available width for wrapping
      love.graphics.printf(displayText, tx, ty, textAreaWidth, align)
    else
      -- Use regular print for non-wrapped text
      if self.textAlign == TextAlign.START then
        tx = contentX
        ty = contentY
      elseif self.textAlign == TextAlign.CENTER then
        tx = contentX + (textAreaWidth - textWidth) / 2
        ty = contentY + (textAreaHeight - textHeight) / 2
      elseif self.textAlign == TextAlign.END then
        tx = contentX + textAreaWidth - textWidth - 10
        ty = contentY + textAreaHeight - textHeight - 10
      elseif self.textAlign == TextAlign.JUSTIFY then
        --- need to figure out spreading
        tx = contentX
        ty = contentY
      end

      -- Apply scroll offset for editable single-line inputs
      if self.editable and not self.multiline and self._textScrollX then
        tx = tx - self._textScrollX
      end

      -- Use scissor to clip text to content area for editable inputs
      if self.editable and not self.multiline then
        love.graphics.setScissor(contentX, contentY, textAreaWidth, textAreaHeight)
      end

      love.graphics.print(displayText, tx, ty)

      -- Reset scissor
      if self.editable and not self.multiline then
        love.graphics.setScissor()
      end
    end

    -- Draw cursor for focused editable elements (even if text is empty)
    if self.editable and self._focused and self._cursorVisible then
      local cursorColor = self.cursorColor or self.textColor
      local cursorWithOpacity = Color.new(cursorColor.r, cursorColor.g, cursorColor.b, cursorColor.a * self.opacity)
      love.graphics.setColor(cursorWithOpacity:toRGBA())

      -- Calculate cursor position using new method that handles multiline
      local cursorRelX, cursorRelY = self:_getCursorScreenPosition()
      local cursorX = contentX + cursorRelX
      local cursorY = contentY + cursorRelY
      local cursorHeight = textHeight

      -- Apply scroll offset for single-line inputs
      if not self.multiline and self._textScrollX then
        cursorX = cursorX - self._textScrollX
      end

      -- Apply scissor for single-line editable inputs
      if not self.multiline then
        love.graphics.setScissor(contentX, contentY, textAreaWidth, textAreaHeight)
      end

      -- Draw cursor line
      love.graphics.rectangle("fill", cursorX, cursorY, 2, cursorHeight)

      -- Reset scissor
      if not self.multiline then
        love.graphics.setScissor()
      end
    end

    -- Draw selection highlight for editable elements
    if self.editable and self._focused and self:hasSelection() and self.text and self.text ~= "" then
      local selStart, selEnd = self:getSelection()
      local selectionColor = self.selectionColor or Color.new(0.3, 0.5, 0.8, 0.5)
      local selectionWithOpacity = Color.new(selectionColor.r, selectionColor.g, selectionColor.b, selectionColor.a * self.opacity)

      -- Calculate selection bounds safely
      local beforeSelection = ""
      local selectedText = ""

      local startByte = utf8.offset(self.text, selStart + 1)
      local endByte = utf8.offset(self.text, selEnd + 1)

      if startByte and endByte then
        beforeSelection = self.text:sub(1, startByte - 1)
        selectedText = self.text:sub(startByte, endByte - 1)
      end

      local selX = (tx or contentX) + font:getWidth(beforeSelection)
      local selWidth = font:getWidth(selectedText)
      local selY = ty or contentY
      local selHeight = textHeight

      -- Apply scissor for single-line editable inputs
      if not self.multiline then
        love.graphics.setScissor(contentX, contentY, textAreaWidth, textAreaHeight)
      end

      -- Draw selection background
      love.graphics.setColor(selectionWithOpacity:toRGBA())
      love.graphics.rectangle("fill", selX, selY, selWidth, selHeight)

      -- Redraw selected text on top
      love.graphics.setColor(textColorWithOpacity:toRGBA())
      love.graphics.print(selectedText, selX, selY)

      -- Reset scissor
      if not self.multiline then
        love.graphics.setScissor()
      end
    end

    if self.textSize then
      love.graphics.setFont(origFont)
    end
  end

  -- Draw cursor for focused editable elements even when empty
  if self.editable and self._focused and self._cursorVisible and (not displayText or displayText == "") then
    -- Set up font for cursor rendering
    local origFont = love.graphics.getFont()
    if self.textSize then
      local fontPath = nil
      if self.fontFamily then
        local themeToUse = self.theme and Theme.get(self.theme) or Theme.getActive()
        if themeToUse and themeToUse.fonts and themeToUse.fonts[self.fontFamily] then
          fontPath = themeToUse.fonts[self.fontFamily]
        else
          fontPath = self.fontFamily
        end
      end
      local font = FONT_CACHE.get(self.textSize, fontPath)
      love.graphics.setFont(font)
    end

    local font = love.graphics.getFont()
    local textHeight = font:getHeight()

    -- Calculate text area position
    local textPaddingLeft = self.padding.left
    local textPaddingTop = self.padding.top
    local scaledContentPadding = self:getScaledContentPadding()
    if scaledContentPadding then
      textPaddingLeft = scaledContentPadding.left
      textPaddingTop = scaledContentPadding.top
    end

    local contentX = self.x + textPaddingLeft
    local contentY = self.y + textPaddingTop

    -- Draw cursor
    local cursorColor = self.cursorColor or self.textColor
    local cursorWithOpacity = Color.new(cursorColor.r, cursorColor.g, cursorColor.b, cursorColor.a * self.opacity)
    love.graphics.setColor(cursorWithOpacity:toRGBA())
    love.graphics.rectangle("fill", contentX, contentY, 2, textHeight)

    if self.textSize then
      love.graphics.setFont(origFont)
    end
  end

  -- Draw visual feedback when element is pressed (if it has a callback and highlight is not disabled)
  if self.callback and not self.disableHighlight then
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
      love.graphics.setColor(0.5, 0.5, 0.5, 0.3 * self.opacity) -- Semi-transparent gray for pressed state with opacity
      RoundedRect.draw("fill", self.x, self.y, borderBoxWidth, borderBoxHeight, self.cornerRadius)
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
      self:_drawScrollbars(scrollbarDims)
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

  -- Update cursor blink timer (only if editable and focused)
  if self.editable and self._focused then
    self._cursorBlinkTimer = self._cursorBlinkTimer + dt
    if self._cursorBlinkTimer >= self.cursorBlinkRate then
      self._cursorBlinkTimer = 0
      self._cursorVisible = not self._cursorVisible
    end
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

  -- Handle scrollbar click/press (independent of callback)
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

  if self.callback or self.themeComponent or self.editable then
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
    end

    -- Only process button events if callback exists, element is not disabled,
    -- and this is the topmost element at the mouse position (z-index ordering)
    -- Exception: Allow drag continuation even if occluded (once drag starts, it continues)
    local isDragging = false
    for _, button in ipairs({ 1, 2, 3 }) do
      if self._pressed[button] and love.mouse.isDown(button) then
        isDragging = true
        break
      end
    end

    local canProcessEvents = (self.callback or self.editable) and not self.disabled and (isActiveElement or isDragging)

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
                -- Scrollbar consumed the event, mark as pressed to prevent callback
                self._pressed[button] = true
                self._scrollbarPressHandled = true
              else
                -- Just pressed - fire press event and record drag start position
                local modifiers = getModifiers()
                if self.callback then
                  local pressEvent = InputEvent.new({
                    type = "press",
                    button = button,
                    x = mx,
                    y = my,
                    modifiers = modifiers,
                    clickCount = 1,
                  })
                  self.callback(self, pressEvent)
                end
                self._pressed[button] = true
                
                -- Set mouse down position for text selection on left click
                if button == 1 and self.editable then
                  self._mouseDownPosition = self:_mouseToTextPosition(mx, my)
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
                if self.callback and isHovering then
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
                  self.callback(self, dragEvent)
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

            if self.callback then
              local clickEvent = InputEvent.new({
                type = eventType,
                button = button,
                x = mx,
                y = my,
                modifiers = modifiers,
                clickCount = clickCount,
              })

              self.callback(self, clickEvent)
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
            if self.callback then
              local releaseEvent = InputEvent.new({
                type = "release",
                button = button,
                x = mx,
                y = my,
                modifiers = modifiers,
                clickCount = clickCount,
              })
              self.callback(self, releaseEvent)
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
    end -- end if self.callback

    -- Handle touch events (maintain backward compatibility)
    if self.callback then
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
          self.callback(self, touchEvent)
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
  -- BORDER-BOX MODEL: Calculate content width, caller will add padding to get border-box
  local contentWidth = self:calculateTextWidth()
  if not self.children or #self.children == 0 then
    return contentWidth
  end

  -- For HORIZONTAL flex: sum children widths + gaps
  -- For VERTICAL flex: max of children widths
  local isHorizontal = self.flexDirection == "horizontal"
  local totalWidth = contentWidth
  local maxWidth = contentWidth
  local participatingChildren = 0

  for _, child in ipairs(self.children) do
    -- Skip explicitly absolute positioned children as they don't affect parent auto-sizing
    if not child._explicitlyAbsolute then
      -- BORDER-BOX MODEL: Use border-box width for auto-sizing calculations
      local childBorderBoxWidth = child:getBorderBoxWidth()
      if isHorizontal then
        totalWidth = totalWidth + childBorderBoxWidth
      else
        maxWidth = math.max(maxWidth, childBorderBoxWidth)
      end
      participatingChildren = participatingChildren + 1
    end
  end

  if isHorizontal then
    -- Add gaps between children (n-1 gaps for n children)
    local gapCount = math.max(0, participatingChildren - 1)
    return totalWidth + (self.gap * gapCount)
  else
    return maxWidth
  end
end

--- Calculate auto height based on children
function Element:calculateAutoHeight()
  local height = self:calculateTextHeight()
  if not self.children or #self.children == 0 then
    return height
  end

  -- For VERTICAL flex: sum children heights + gaps
  -- For HORIZONTAL flex: max of children heights
  local isVertical = self.flexDirection == "vertical"
  local totalHeight = height
  local maxHeight = height
  local participatingChildren = 0

  for _, child in ipairs(self.children) do
    -- Skip explicitly absolute positioned children as they don't affect parent auto-sizing
    if not child._explicitlyAbsolute then
      -- BORDER-BOX MODEL: Use border-box height for auto-sizing calculations
      local childBorderBoxHeight = child:getBorderBoxHeight()
      if isVertical then
        totalHeight = totalHeight + childBorderBoxHeight
      else
        maxHeight = math.max(maxHeight, childBorderBoxHeight)
      end
      participatingChildren = participatingChildren + 1
    end
  end

  if isVertical then
    -- Add gaps between children (n-1 gaps for n children)
    local gapCount = math.max(0, participatingChildren - 1)
    return totalHeight + (self.gap * gapCount)
  else
    return maxHeight
  end
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
  if not self.editable then
    return
  end
  self._cursorPosition = position
  self:_validateCursorPosition()
  self:_resetCursorBlink()
end

--- Get cursor position
---@return number -- Character index (0-based)
function Element:getCursorPosition()
  if not self.editable then
    return 0
  end
  return self._cursorPosition
end

--- Move cursor by delta characters
---@param delta number -- Number of characters to move (positive or negative)
function Element:moveCursorBy(delta)
  if not self.editable then
    return
  end
  self._cursorPosition = self._cursorPosition + delta
  self:_validateCursorPosition()
  self:_resetCursorBlink()
end

--- Move cursor to start of text
function Element:moveCursorToStart()
  if not self.editable then
    return
  end
  self._cursorPosition = 0
  self:_resetCursorBlink()
end

--- Move cursor to end of text
function Element:moveCursorToEnd()
  if not self.editable then
    return
  end
  local textLength = utf8.len(self._textBuffer or "")
  self._cursorPosition = textLength
  self:_resetCursorBlink()
end

--- Move cursor to start of current line
function Element:moveCursorToLineStart()
  if not self.editable then
    return
  end
  -- For now, just move to start (will be enhanced for multi-line)
  self:moveCursorToStart()
end

--- Move cursor to end of current line
function Element:moveCursorToLineEnd()
  if not self.editable then
    return
  end
  -- For now, just move to end (will be enhanced for multi-line)
  self:moveCursorToEnd()
end

--- Move cursor to start of previous word
function Element:moveCursorToPreviousWord()
  if not self.editable or not self._textBuffer then
    return
  end

  local text = self._textBuffer
  local pos = self._cursorPosition

  if pos <= 0 then
    return
  end

  -- Skip any whitespace/punctuation before current position
  while pos > 0 do
    local offset = utf8.offset(text, pos)
    local char = offset and text:sub(offset, utf8.offset(text, pos + 1) - 1) or ""
    if char:match("[%w]") then
      break
    end
    pos = pos - 1
  end

  -- Move to start of current word
  while pos > 0 do
    local offset = utf8.offset(text, pos)
    local char = offset and text:sub(offset, utf8.offset(text, pos + 1) - 1) or ""
    if not char:match("[%w]") then
      break
    end
    pos = pos - 1
  end

  self._cursorPosition = pos
  self:_validateCursorPosition()
end

--- Move cursor to start of next word
function Element:moveCursorToNextWord()
  if not self.editable or not self._textBuffer then
    return
  end

  local text = self._textBuffer
  local textLength = utf8.len(text) or 0
  local pos = self._cursorPosition

  if pos >= textLength then
    return
  end

  -- Skip current word
  while pos < textLength do
    local offset = utf8.offset(text, pos + 1)
    local char = offset and text:sub(offset, utf8.offset(text, pos + 2) - 1) or ""
    if not char:match("[%w]") then
      break
    end
    pos = pos + 1
  end

  -- Skip any whitespace/punctuation
  while pos < textLength do
    local offset = utf8.offset(text, pos + 1)
    local char = offset and text:sub(offset, utf8.offset(text, pos + 2) - 1) or ""
    if char:match("[%w]") then
      break
    end
    pos = pos + 1
  end

  self._cursorPosition = pos
  self:_validateCursorPosition()
end

--- Validate cursor position (ensure it's within text bounds)
function Element:_validateCursorPosition()
  if not self.editable then
    return
  end
  local textLength = utf8.len(self._textBuffer or "")
  self._cursorPosition = math.max(0, math.min(self._cursorPosition, textLength))
end

--- Reset cursor blink (show cursor immediately)
function Element:_resetCursorBlink()
  if not self.editable then
    return
  end
  self._cursorBlinkTimer = 0
  self._cursorVisible = true

  -- Update scroll to keep cursor visible
  self:_updateTextScroll()
end

--- Update text scroll offset to keep cursor visible
function Element:_updateTextScroll()
  if not self.editable or self.multiline then
    return
  end

  -- Get font for measuring text
  local font = self:_getFont()
  if not font then
    return
  end

  -- Calculate cursor X position in text coordinates
  local cursorText = ""
  if self._textBuffer and self._textBuffer ~= "" and self._cursorPosition > 0 then
    local byteOffset = utf8.offset(self._textBuffer, self._cursorPosition + 1)
    if byteOffset then
      cursorText = self._textBuffer:sub(1, byteOffset - 1)
    end
  end
  local cursorX = font:getWidth(cursorText)

  -- Get available text area width (accounting for padding)
  local textAreaWidth = self.width
  local scaledContentPadding = self:getScaledContentPadding()
  if scaledContentPadding then
    local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
    textAreaWidth = borderBoxWidth - scaledContentPadding.left - scaledContentPadding.right
  end

  -- Add some padding on the right for the cursor
  local cursorPadding = 4
  local visibleWidth = textAreaWidth - cursorPadding

  -- Adjust scroll to keep cursor visible
  if cursorX - self._textScrollX < 0 then
    -- Cursor is to the left of visible area - scroll left
    self._textScrollX = cursorX
  elseif cursorX - self._textScrollX > visibleWidth then
    -- Cursor is to the right of visible area - scroll right
    self._textScrollX = cursorX - visibleWidth
  end

  -- Ensure we don't scroll past the beginning
  self._textScrollX = math.max(0, self._textScrollX)
end

-- ====================
-- Input Handling - Selection Management
-- ====================

--- Set selection range
---@param startPos number -- Start position (inclusive)
---@param endPos number -- End position (inclusive)
function Element:setSelection(startPos, endPos)
  if not self.editable then
    return
  end
  local textLength = utf8.len(self._textBuffer or "")
  self._selectionStart = math.max(0, math.min(startPos, textLength))
  self._selectionEnd = math.max(0, math.min(endPos, textLength))

  -- Ensure start <= end
  if self._selectionStart > self._selectionEnd then
    self._selectionStart, self._selectionEnd = self._selectionEnd, self._selectionStart
  end

  self:_resetCursorBlink()
end

--- Get selection range
---@return number?, number? -- Start and end positions, or nil if no selection
function Element:getSelection()
  if not self.editable then
    return nil, nil
  end
  if not self:hasSelection() then
    return nil, nil
  end
  return self._selectionStart, self._selectionEnd
end

--- Check if there is an active selection
---@return boolean
function Element:hasSelection()
  if not self.editable then
    return false
  end
  return self._selectionStart ~= nil and self._selectionEnd ~= nil and self._selectionStart ~= self._selectionEnd
end

--- Clear selection
function Element:clearSelection()
  if not self.editable then
    return
  end
  self._selectionStart = nil
  self._selectionEnd = nil
  self._selectionAnchor = nil
end

--- Select all text
function Element:selectAll()
  if not self.editable then
    return
  end
  local textLength = utf8.len(self._textBuffer or "")
  self._selectionStart = 0
  self._selectionEnd = textLength
  self:_resetCursorBlink()
end

--- Get selected text
---@return string? -- Selected text or nil if no selection
function Element:getSelectedText()
  if not self.editable or not self:hasSelection() then
    return nil
  end
  local startPos, endPos = self:getSelection()
  if not startPos or not endPos then
    return nil
  end

  -- Convert character indices to byte offsets for string.sub
  local text = self._textBuffer or ""
  local startByte = utf8.offset(text, startPos + 1)
  local endByte = utf8.offset(text, endPos + 1)

  if not startByte then
    return ""
  end

  -- If endByte is nil, it means we want to the end of the string
  if endByte then
    endByte = endByte - 1 -- Adjust to get the last byte of the character
  end

  return string.sub(text, startByte, endByte)
end

--- Delete selected text
---@return boolean -- True if text was deleted
function Element:deleteSelection()
  if not self.editable or not self:hasSelection() then
    return false
  end
  local startPos, endPos = self:getSelection()
  if not startPos or not endPos then
    return false
  end

  self:deleteText(startPos, endPos)
  self:clearSelection()
  self._cursorPosition = startPos
  self:_validateCursorPosition()
  return true
end

-- ====================
-- Input Handling - Focus Management
-- ====================

--- Focus this element for keyboard input
function Element:focus()
  if not self.editable then
    return
  end

  if Gui._focusedElement and Gui._focusedElement ~= self then
    Gui._focusedElement:blur()
  end

  -- Set focus state
  self._focused = true
  Gui._focusedElement = self

  self:_resetCursorBlink()

  if self.selectOnFocus then
    self:selectAll()
  else
    self:moveCursorToEnd()
  end

  -- Trigger onFocus callback if defined
  if self.onFocus then
    self.onFocus(self)
  end
end

--- Remove focus from this element
function Element:blur()
  if not self.editable then
    return
  end

  self._focused = false

  -- Clear global focused element if it's this element
  if Gui._focusedElement == self then
    Gui._focusedElement = nil
  end

  -- Trigger onBlur callback if defined
  if self.onBlur then
    self.onBlur(self)
  end
end

--- Check if this element is focused
---@return boolean
function Element:isFocused()
  if not self.editable then
    return false
  end
  return self._focused == true
end

-- ====================
-- Input Handling - Text Buffer Management
-- ====================

--- Get current text buffer
---@return string
function Element:getText()
  if not self.editable then
    return self.text or ""
  end
  return self._textBuffer or ""
end

--- Set text buffer and mark dirty
---@param text string
function Element:setText(text)
  if not self.editable then
    self.text = text
    return
  end

  self._textBuffer = text or ""
  self.text = self._textBuffer -- Sync display text
  self:_markTextDirty()
  self:_updateTextIfDirty() -- Update immediately to recalculate lines/wrapping
  self:_updateAutoGrowHeight() -- Then update height based on new content
  self:_validateCursorPosition()
end

--- Insert text at position
---@param text string -- Text to insert
---@param position number? -- Position to insert at (default: cursor position)
function Element:insertText(text, position)
  if not self.editable then
    return
  end

  position = position or self._cursorPosition
  local buffer = self._textBuffer or ""

  -- Check maxLength constraint before inserting
  if self.maxLength then
    local currentLength = utf8.len(buffer) or 0
    local textLength = utf8.len(text) or 0
    local newLength = currentLength + textLength

    if newLength > self.maxLength then
      -- Don't insert if it would exceed maxLength
      return
    end
  end

  -- Convert character position to byte offset
  local byteOffset = utf8.offset(buffer, position + 1) or (#buffer + 1)

  -- Insert text
  local before = buffer:sub(1, byteOffset - 1)
  local after = buffer:sub(byteOffset)
  self._textBuffer = before .. text .. after
  self.text = self._textBuffer -- Sync display text

  self._cursorPosition = position + utf8.len(text)

  self:_markTextDirty()
  self:_updateTextIfDirty() -- Update immediately to recalculate lines/wrapping
  self:_updateAutoGrowHeight() -- Then update height based on new content
  self:_validateCursorPosition()
end

---@param startPos number -- Start position (inclusive)
---@param endPos number -- End position (inclusive)
function Element:deleteText(startPos, endPos)
  if not self.editable then
    return
  end

  local buffer = self._textBuffer or ""

  -- Ensure valid range
  local textLength = utf8.len(buffer)
  startPos = math.max(0, math.min(startPos, textLength))
  endPos = math.max(0, math.min(endPos, textLength))

  if startPos > endPos then
    startPos, endPos = endPos, startPos
  end

  -- Convert character positions to byte offsets
  local startByte = utf8.offset(buffer, startPos + 1) or 1
  local endByte = utf8.offset(buffer, endPos + 1) or (#buffer + 1)

  -- Delete text
  local before = buffer:sub(1, startByte - 1)
  local after = buffer:sub(endByte)
  self._textBuffer = before .. after
  self.text = self._textBuffer -- Sync display text

  self:_markTextDirty()
  self:_updateTextIfDirty() -- Update immediately to recalculate lines/wrapping
  self:_updateAutoGrowHeight() -- Then update height based on new content
end

--- Replace text in range
---@param startPos number -- Start position (inclusive)
---@param endPos number -- End position (inclusive)
---@param newText string -- Replacement text
function Element:replaceText(startPos, endPos, newText)
  if not self.editable then
    return
  end

  self:deleteText(startPos, endPos)
  self:insertText(newText, startPos)
end

--- Mark text as dirty (needs recalculation)
function Element:_markTextDirty()
  if not self.editable then
    return
  end
  self._textDirty = true
end

--- Update text if dirty (recalculate lines and wrapping)
function Element:_updateTextIfDirty()
  if not self.editable or not self._textDirty then
    return
  end

  self:_splitLines()
  self:_calculateWrapping()
  self:_validateCursorPosition()
  self._textDirty = false
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
    local words = {}
    for word in line:gmatch("%S+") do
      table.insert(words, word)
    end

    for i, word in ipairs(words) do
      local testLine = currentLine == "" and word or (currentLine .. " " .. word)
      local width = font:getWidth(testLine)

      if width > maxWidth and currentLine ~= "" then
        local currentLineLen = utf8.len(currentLine)
        table.insert(wrappedParts, {
          text = currentLine,
          startIdx = startIdx,
          endIdx = startIdx + currentLineLen,
        })
        startIdx = startIdx + currentLineLen + 1 -- +1 for the space
        currentLine = word

        -- Check if the word itself is too long - if so, break it with character wrapping
        if font:getWidth(word) > maxWidth then
          local wordLen = utf8.len(word)
          local charLine = ""
          local charStartIdx = startIdx

          for j = 1, wordLen do
            local char = getUtf8Char(word, j)
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
        local wordLen = utf8.len(word)
        local charLine = ""
        local charStartIdx = startIdx

        for j = 1, wordLen do
          local char = getUtf8Char(word, j)
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
      else
        currentLine = testLine
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

--- Get cursor screen position for rendering (handles multiline text)
---@return number, number -- Cursor X and Y position relative to content area
function Element:_getCursorScreenPosition()
  if not self.editable then
    return 0, 0
  end

  local font = self:_getFont()
  if not font then
    return 0, 0
  end

  local text = self._textBuffer or ""
  local cursorPos = self._cursorPosition or 0

  -- For single-line text, calculate simple X position
  if not self.multiline then
    local cursorText = ""
    if text ~= "" and cursorPos > 0 then
      local byteOffset = utf8.offset(text, cursorPos + 1)
      if byteOffset then
        cursorText = text:sub(1, byteOffset - 1)
      end
    end
    return font:getWidth(cursorText), 0
  end

  -- For multiline text, we need to find which wrapped line the cursor is on
  -- Update text wrapping if dirty
  self:_updateTextIfDirty()

  -- Get text area width for wrapping
  local textAreaWidth = self.width
  local scaledContentPadding = self:getScaledContentPadding()
  if scaledContentPadding then
    local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
    textAreaWidth = borderBoxWidth - scaledContentPadding.left - scaledContentPadding.right
  end

  -- Split text by actual newlines first
  local lines = {}
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(lines, line)
  end
  if #lines == 0 then
    lines = { "" }
  end

  -- Track character position as we iterate through lines
  local charCount = 0
  local cursorX = 0
  local cursorY = 0
  local lineHeight = font:getHeight()

  for lineNum, line in ipairs(lines) do
    local lineLength = utf8.len(line) or 0

    -- Check if cursor is on this line (before the newline)
    if cursorPos <= charCount + lineLength then
      -- Cursor is on this line
      local posInLine = cursorPos - charCount

      -- If text wrapping is enabled, find which wrapped segment
      if self.textWrap and textAreaWidth > 0 then
        local wrappedSegments = self:_wrapLine(line, textAreaWidth)

        for segmentIdx, segment in ipairs(wrappedSegments) do
          -- Check if cursor is within this segment's character range
          if posInLine >= segment.startIdx and posInLine <= segment.endIdx then
            -- Cursor is in this segment
            local posInSegment = posInLine - segment.startIdx
            local segmentText = ""
            if posInSegment > 0 and segment.text ~= "" then
              -- Extract substring by character positions using byte offsets
              local endByte = utf8.offset(segment.text, posInSegment + 1)
              if endByte then
                segmentText = segment.text:sub(1, endByte - 1)
              else
                segmentText = segment.text
              end
            end
            cursorX = font:getWidth(segmentText)
            cursorY = (lineNum - 1) * lineHeight + (segmentIdx - 1) * lineHeight

            return cursorX, cursorY
          end
        end
      else
        -- No wrapping, simple calculation
        local lineText = ""
        if posInLine > 0 then
          -- Extract substring by character positions using byte offsets
          local endByte = utf8.offset(line, posInLine + 1)
          if endByte then
            lineText = line:sub(1, endByte - 1)
          else
            lineText = line
          end
        end
        cursorX = font:getWidth(lineText)
        cursorY = (lineNum - 1) * lineHeight
        return cursorX, cursorY
      end
    end

    charCount = charCount + lineLength + 1
  end

  -- Cursor is at the very end
  return 0, #lines * lineHeight
end

--- Update element height based on text content (for autoGrow multiline fields)
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

  -- Calculate relative X position within text area
  local relativeX = mouseX - contentX

  -- Account for horizontal scroll offset in single-line inputs
  if not self.multiline and self._textScrollX then
    relativeX = relativeX + self._textScrollX
  end

  -- Get font for measuring text
  local font = self:_getFont()

  -- Find the character position closest to the click
  local text = self._textBuffer
  local textLength = utf8.len(text) or 0
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

--- Handle mouse click on text (set cursor position or start selection)
---@param mouseX number -- Mouse X coordinate
---@param mouseY number -- Mouse Y coordinate
---@param clickCount number -- Number of clicks (1=single, 2=double, 3=triple)
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

--- Select word at given position
---@param position number -- Character position
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

-- ====================
-- Input Handling - Keyboard Input
-- ====================

--- Handle text input (character input)
---@param text string -- Character(s) to insert
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
end

--- Handle key press (special keys)
---@param key string -- Key name
---@param scancode string -- Scancode
---@param isrepeat boolean -- Whether this is a key repeat
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
      if self:hasSelection() and not modifiers.shift then
        -- Move to start of selection
        local startPos, _ = self:getSelection()
        self._cursorPosition = startPos
        self:clearSelection()
      elseif ctrl then
        -- Ctrl+Left: Move to previous word
        self:moveCursorToPreviousWord()
      else
        self:moveCursorBy(-1)
      end
    elseif key == "right" then
      if self:hasSelection() and not modifiers.shift then
        -- Move to end of selection
        local _, endPos = self:getSelection()
        self._cursorPosition = endPos
        self:clearSelection()
      elseif ctrl then
        -- Ctrl+Right: Move to next word
        self:moveCursorToNextWord()
      else
        self:moveCursorBy(1)
      end
    elseif key == "home" then
      -- Move to line start (or document start for single-line)
      if ctrl or not self.multiline then
        self:moveCursorToStart()
      else
        self:moveCursorToLineStart()
      end
      if not modifiers.shift then
        self:clearSelection()
      end
    elseif key == "end" then
      -- Move to line end (or document end for single-line)
      if ctrl or not self.multiline then
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
    self:_resetCursorBlink()
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
    self:_resetCursorBlink()

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
    self:_resetCursorBlink()

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
    self:_resetCursorBlink()

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
    self:_resetCursorBlink()

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
end

return Element
