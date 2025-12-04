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
---@field onEventDeferred boolean? -- Whether onEvent callback should be deferred until after canvases are released (default: false)
---@field onFocus fun(element:Element)? -- Callback function when element receives focus
---@field onFocusDeferred boolean? -- Whether onFocus callback should be deferred (default: false)
---@field onBlur fun(element:Element)? -- Callback function when element loses focus
---@field onBlurDeferred boolean? -- Whether onBlur callback should be deferred (default: false)
---@field onTextInput fun(element:Element, text:string)? -- Callback function for text input
---@field onTextInputDeferred boolean? -- Whether onTextInput callback should be deferred (default: false)
---@field onTextChange fun(element:Element, text:string)? -- Callback function when text changes
---@field onTextChangeDeferred boolean? -- Whether onTextChange callback should be deferred (default: false)
---@field onEnter fun(element:Element)? -- Callback function when Enter key is pressed
---@field onEnterDeferred boolean? -- Whether onEnter callback should be deferred (default: false)
---@field units table -- Original unit specifications for responsive behavior
---@field _eventHandler EventHandler -- Event handler instance for input processing
---@field _explicitlyAbsolute boolean?
---@field _originalPositioning Positioning? -- Original positioning value set by user
---@field gridRows number? -- Number of rows in the grid
---@field gridColumns number? -- Number of columns in the grid
---@field columnGap number|string? -- Gap between grid columns
---@field rowGap number|string? -- Gap between grid rows
---@field theme string? -- Theme component to use for rendering
---@field themeComponent string?
---@field _themeState string? -- Current theme state (normal, hover, pressed, active, disabled)
---@field _themeManager ThemeManager -- Internal: theme manager instance
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
---@field _textEditor TextEditor? -- Internal: TextEditor instance for editable elements
---@field imagePath string? -- Path to image file (auto-loads via ImageCache)
---@field image love.Image? -- Image object to display
---@field objectFit "fill"|"contain"|"cover"|"scale-down"|"none"? -- Image fit mode (default: "fill")
---@field objectPosition string? -- Image position like "center center", "top left", "50% 50%" (default: "center center")
---@field imageOpacity number? -- Image opacity 0-1 (default: 1, combines with element opacity)
---@field imageRepeat "no-repeat"|"repeat"|"repeat-x"|"repeat-y"|"space"|"round"? -- Image repeat/tiling mode (default: "no-repeat")
---@field imageTint Color? -- Color to tint the image (default: nil/white, no tint)
---@field onImageLoad fun(element:Element, image:love.Image)? -- Callback when image loads successfully
---@field onImageLoadDeferred boolean? -- Whether onImageLoad callback should be deferred (default: false)
---@field onImageError fun(element:Element, error:string)? -- Callback when image fails to load
---@field onImageErrorDeferred boolean? -- Whether onImageError callback should be deferred (default: false)
---@field _loadedImage love.Image? -- Internal: cached loaded image
---@field hideScrollbars boolean|{vertical:boolean, horizontal:boolean}? -- Hide scrollbars (boolean for both, or table for individual control)
---@field userdata table?
---@field _renderer Renderer -- Internal: Renderer instance for visual rendering
---@field _layoutEngine LayoutEngine -- Internal: LayoutEngine instance for layout calculations
---@field _scrollManager ScrollManager? -- Internal: ScrollManager instance for scroll handling
---@field _borderBoxWidth number? -- Internal: cached border-box width
---@field _borderBoxHeight number? -- Internal: cached border-box height
---@field overflow string? -- Overflow behavior for both axes
---@field overflowX string? -- Overflow behavior for horizontal axis
---@field overflowY string? -- Overflow behavior for vertical axis
---@field scrollbarWidth number? -- Scrollbar width in pixels
---@field scrollbarColor Color? -- Scrollbar thumb color
---@field scrollbarTrackColor Color? -- Scrollbar track color
---@field scrollbarRadius number? -- Scrollbar corner radius
---@field scrollbarPadding number? -- Scrollbar padding from edges
---@field scrollSpeed number? -- Scroll speed multiplier
---@field _overflowX boolean? -- Internal: whether content overflows horizontally
---@field _overflowY boolean? -- Internal: whether content overflows vertically
---@field _contentWidth number? -- Internal: total content width
---@field _contentHeight number? -- Internal: total content height
---@field _scrollX number? -- Internal: horizontal scroll position
---@field _scrollY number? -- Internal: vertical scroll position
---@field _maxScrollX number? -- Internal: maximum horizontal scroll
---@field _maxScrollY number? -- Internal: maximum vertical scroll
---@field _scrollbarHoveredVertical boolean? -- Internal: vertical scrollbar hover state
---@field _scrollbarHoveredHorizontal boolean? -- Internal: horizontal scrollbar hover state
---@field _scrollbarDragging boolean? -- Internal: scrollbar dragging state
---@field _hoveredScrollbar table? -- Internal: currently hovered scrollbar info
---@field _scrollbarDragOffset number? -- Internal: scrollbar drag offset
---@field _scrollbarPressHandled boolean? -- Internal: scrollbar press handled flag
---@field _pressed table? -- Internal: button press state tracking
---@field _mouseDownPosition number? -- Internal: mouse down position for drag tracking
---@field _textDragOccurred boolean? -- Internal: whether text drag occurred
---@field animation table? -- Animation instance for this element
local Element = {}
Element.__index = Element

---Initialize Element module with required dependencies
---@param deps table Dependency table containing all required modules
function Element.init(deps)
  Element._ErrorHandler = deps.ErrorHandler
  Element._Color = deps.Color
  Element._Context = deps.Context
  Element._Units = deps.Units
  Element._utils = deps.utils
  Element._InputEvent = deps.InputEvent
  Element._EventHandler = deps.EventHandler
  Element._Renderer = deps.Renderer
  Element._LayoutEngine = deps.LayoutEngine
  Element._TextEditor = deps.TextEditor
  Element._ScrollManager = deps.ScrollManager
  Element._Theme = deps.Theme
  Element._RoundedRect = deps.RoundedRect
  Element._NinePatch = deps.NinePatch
  Element._ImageRenderer = deps.ImageRenderer
  Element._ImageCache = deps.ImageCache
  Element._ImageScaler = deps.ImageScaler
  Element._Blur = deps.Blur
  Element._Transform = deps.Transform
  Element._Grid = deps.Grid
  Element._StateManager = deps.StateManager
  Element._GestureRecognizer = deps.GestureRecognizer
  Element._Performance = deps.Performance
end

---@param props ElementProps
---@return Element
function Element.new(props)
  local self = setmetatable({}, Element)

  -- Create dependency subsets for sub-modules (defined once, used throughout)
  local eventHandlerDeps = {
    InputEvent = Element._InputEvent,
    Context = Element._Context,
    utils = Element._utils,
  }

  local rendererDeps = {
    Color = Element._Color,
    RoundedRect = Element._RoundedRect,
    NinePatch = Element._NinePatch,
    ImageRenderer = Element._ImageRenderer,
    ImageCache = Element._ImageCache,
    Theme = Element._Theme,
    Blur = Element._Blur,
    Transform = Element._Transform,
    utils = Element._utils,
  }

  local layoutEngineDeps = {
    utils = Element._utils,
    Grid = Element._Grid,
    Units = Element._Units,
    Context = Element._Context,
    ErrorHandler = Element._ErrorHandler,
  }

  local textEditorDeps = {
    Context = Element._Context,
    StateManager = Element._StateManager,
    Color = Element._Color,
    utils = Element._utils,
  }

  local scrollManagerDeps = {
    utils = Element._utils,
    Color = Element._Color,
  }

  -- Normalize flexDirection: convert "row"→"horizontal", "column"→"vertical"
  if props.flexDirection == "row" then
    props.flexDirection = "horizontal"
  elseif props.flexDirection == "column" then
    props.flexDirection = "vertical"
  end

  -- Normalize padding: convert single value to table with all sides
  if props.padding ~= nil and type(props.padding) ~= "table" then
    local singleValue = props.padding
    props.padding = {
      top = singleValue,
      right = singleValue,
      bottom = singleValue,
      left = singleValue,
    }
  end

  -- Normalize margin: convert single value to table with all sides
  if props.margin ~= nil and type(props.margin) ~= "table" then
    local singleValue = props.margin
    props.margin = {
      top = singleValue,
      right = singleValue,
      bottom = singleValue,
      left = singleValue,
    }
  end

  self.children = {}
  self.onEvent = props.onEvent

  -- Auto-generate ID in immediate mode if not provided
  if Element._Context._immediateMode and (not props.id or props.id == "") then
    self.id = Element._StateManager.generateID(props, props.parent)
  else
    self.id = props.id or ""
  end

  self.userdata = props.userdata

  self.onFocus = props.onFocus
  self.onFocusDeferred = props.onFocusDeferred or false
  self.onBlur = props.onBlur
  self.onBlurDeferred = props.onBlurDeferred or false
  self.onTextInput = props.onTextInput
  self.onTextInputDeferred = props.onTextInputDeferred or false
  self.onTextChange = props.onTextChange
  self.onTextChangeDeferred = props.onTextChangeDeferred or false
  self.onEnter = props.onEnter
  self.onEnterDeferred = props.onEnterDeferred or false

  -- Initialize state manager ID for immediate mode (use self.id which may be auto-generated)
  self._stateId = self.id

  -- In immediate mode, restore EventHandler state from StateManager
  local eventHandlerConfig = {
    onEvent = self.onEvent,
    onEventDeferred = props.onEventDeferred,
  }
  if Element._Context._immediateMode and self._stateId and self._stateId ~= "" then
    local state = Element._StateManager.getState(self._stateId)
    if state then
      -- Restore EventHandler state from StateManager (sparse storage - provide defaults)
      eventHandlerConfig._pressed = state._pressed or {}
      eventHandlerConfig._lastClickTime = state._lastClickTime
      eventHandlerConfig._lastClickButton = state._lastClickButton
      eventHandlerConfig._clickCount = state._clickCount or 0
      eventHandlerConfig._dragStartX = state._dragStartX or {}
      eventHandlerConfig._dragStartY = state._dragStartY or {}
      eventHandlerConfig._lastMouseX = state._lastMouseX or {}
      eventHandlerConfig._lastMouseY = state._lastMouseY or {}
      eventHandlerConfig._hovered = state._hovered
    end
  end

  self._eventHandler = Element._EventHandler.new(eventHandlerConfig, eventHandlerDeps)

  self._themeManager = Element._Theme.Manager.new({
    theme = props.theme or Element._Context.defaultTheme,
    themeComponent = props.themeComponent or nil,
    disabled = props.disabled or false,
    active = props.active or false,
    disableHighlight = props.disableHighlight,
    scaleCorners = props.scaleCorners,
    scalingAlgorithm = props.scalingAlgorithm,
  })

  -- Expose theme properties for backward compatibility
  self.theme = self._themeManager.theme
  self.themeComponent = self._themeManager.themeComponent
  self.disabled = self._themeManager.disabled
  self.active = self._themeManager.active
  self._themeState = self._themeManager:getState()

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
    self.contentAutoSizingMultiplier = props.contentAutoSizingMultiplier
  else
    local multiplier = self._themeManager:getContentAutoSizingMultiplier()
    self.contentAutoSizingMultiplier = multiplier or { 1, 1 }
  end

  -- Expose 9-patch corner scaling properties for backward compatibility
  self.scaleCorners = self._themeManager.scaleCorners
  self.scalingAlgorithm = self._themeManager.scalingAlgorithm

  self.contentBlur = props.contentBlur
  self.backdropBlur = props.backdropBlur
  self._blurInstance = nil

  self.editable = props.editable or false
  self.multiline = props.multiline or false
  self.passwordMode = props.passwordMode or false

  -- Validate property combinations: passwordMode disables multiline
  if self.passwordMode and props.multiline then
    Element._ErrorHandler:warn("Element", "ELEM_006")
    self.multiline = false
  elseif self.passwordMode then
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

  self.cursorColor = props.cursorColor
  self.selectionColor = props.selectionColor
  self.cursorBlinkRate = props.cursorBlinkRate or 0.5

  if self.editable then
    self._textEditor = Element._TextEditor.new({
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
    }, textEditorDeps)
    -- Initialize will be called after self is fully constructed
  end

  -- Set parent first so it's available for size calculations
  self.parent = props.parent

  ------ add non-hereditary ------
  --- self drawing---
  -- OPTIMIZATION: Handle border - only create table if border exists
  -- This saves ~80 bytes per element without borders
  if type(props.border) == "table" then
    -- Check if any border side is truthy
    local hasAnyBorder = props.border.top or props.border.right or props.border.bottom or props.border.left
    if hasAnyBorder then
      self.border = {
        top = props.border.top or false,
        right = props.border.right or false,
        bottom = props.border.bottom or false,
        left = props.border.left or false,
      }
    else
      self.border = nil
    end
  elseif props.border then
    -- If border is a number or truthy value, keep it as-is
    self.border = props.border
  else
    -- No border specified - use nil instead of table with all false
    self.border = nil
  end
  self.borderColor = props.borderColor or Element._Color.new(0, 0, 0, 1)
  self.backgroundColor = props.backgroundColor or Element._Color.new(0, 0, 0, 0)

  -- Validate and set opacity
  if props.opacity ~= nil then
    Element._utils.validateRange(props.opacity, 0, 1, "opacity")
  end
  self.opacity = props.opacity or 1

  -- Set visibility property (default: "visible")
  self.visibility = props.visibility or "visible"

  -- Set transform property (optional)
  self.transform = props.transform or nil

  -- OPTIMIZATION: Handle cornerRadius - store as number or table, nil if all zeros
  -- This saves ~80 bytes per element without rounded corners
  if props.cornerRadius then
    if type(props.cornerRadius) == "number" then
      -- Store as number for uniform radius (compact)
      if props.cornerRadius ~= 0 then
        self.cornerRadius = props.cornerRadius
      else
        self.cornerRadius = nil
      end
    else
      -- Store as table only if non-zero values exist
      local hasNonZero = props.cornerRadius.topLeft or props.cornerRadius.topRight or props.cornerRadius.bottomLeft or props.cornerRadius.bottomRight
      if hasNonZero then
        self.cornerRadius = {
          topLeft = props.cornerRadius.topLeft or 0,
          topRight = props.cornerRadius.topRight or 0,
          bottomLeft = props.cornerRadius.bottomLeft or 0,
          bottomRight = props.cornerRadius.bottomRight or 0,
        }
      else
        self.cornerRadius = nil
      end
    end
  else
    -- No cornerRadius specified - use nil instead of table with all zeros
    self.cornerRadius = nil
  end

  -- For editable elements, default text to empty string if not provided
  if self.editable and props.text == nil then
    self.text = ""
  else
    self.text = props.text
  end

  -- Sync self.text with restored _textBuffer for editable elements in immediate mode
  if self.editable and Element._Context._immediateMode and self._textBuffer then
    self.text = self._textBuffer
  end

  -- Validate and set textAlign
  if props.textAlign then
    Element._utils.validateEnum(props.textAlign, Element._utils.enums.TextAlign, "textAlign")
  end
  self.textAlign = props.textAlign or Element._utils.enums.TextAlign.START

  -- Image properties
  self.imagePath = props.imagePath
  self.image = props.image

  -- Validate objectFit
  if props.objectFit then
    local validObjectFit = { fill = "fill", contain = "contain", cover = "cover", ["scale-down"] = "scale-down", none = "none" }
    Element._utils.validateEnum(props.objectFit, validObjectFit, "objectFit")
  end
  self.objectFit = props.objectFit or "fill"
  self.objectPosition = props.objectPosition or "center center"

  -- Validate and set imageOpacity
  if props.imageOpacity ~= nil then
    Element._utils.validateRange(props.imageOpacity, 0, 1, "imageOpacity")
  end
  self.imageOpacity = props.imageOpacity or 1

  -- Validate and set imageRepeat
  if props.imageRepeat then
    local validImageRepeat = {
      ["no-repeat"] = "no-repeat",
      ["repeat"] = "repeat",
      ["repeat-x"] = "repeat-x",
      ["repeat-y"] = "repeat-y",
      space = "space",
      round = "round",
    }
    Element._utils.validateEnum(props.imageRepeat, validImageRepeat, "imageRepeat")
  end
  self.imageRepeat = props.imageRepeat or "no-repeat"

  -- Set imageTint
  self.imageTint = props.imageTint

  -- Image callbacks
  self.onImageLoad = props.onImageLoad
  self.onImageLoadDeferred = props.onImageLoadDeferred or false
  self.onImageError = props.onImageError
  self.onImageErrorDeferred = props.onImageErrorDeferred or false

  -- Auto-load image if imagePath is provided
  if self.imagePath and not self.image then
    local loadedImage, err = Element._ImageCache.load(self.imagePath)
    if loadedImage then
      self._loadedImage = loadedImage
      -- Call onImageLoad callback if provided
      if self.onImageLoad and type(self.onImageLoad) == "function" then
        if self.onImageLoadDeferred then
          Element._Context.deferCallback(function()
            local success, callbackErr = pcall(self.onImageLoad, self, loadedImage)
            if not success then
              print(string.format("[Element] onImageLoad error: %s", tostring(callbackErr)))
            end
          end)
        else
          local success, callbackErr = pcall(self.onImageLoad, self, loadedImage)
          if not success then
            print(string.format("[Element] onImageLoad error: %s", tostring(callbackErr)))
          end
        end
      end
    else
      -- Image failed to load
      self._loadedImage = nil
      -- Call onImageError callback if provided
      if self.onImageError and type(self.onImageError) == "function" then
        if self.onImageErrorDeferred then
          Element._Context.deferCallback(function()
            local success, callbackErr = pcall(self.onImageError, self, err or "Unknown error")
            if not success then
              print(string.format("[Element] onImageError error: %s", tostring(callbackErr)))
            end
          end)
        else
          local success, callbackErr = pcall(self.onImageError, self, err or "Unknown error")
          if not success then
            print(string.format("[Element] onImageError error: %s", tostring(callbackErr)))
          end
        end
      end
    end
  elseif self.image then
    self._loadedImage = self.image
    -- Call onImageLoad for directly provided images
    if self.onImageLoad and type(self.onImageLoad) == "function" then
      if self.onImageLoadDeferred then
        Element._Context.deferCallback(function()
          local success, callbackErr = pcall(self.onImageLoad, self, self.image)
          if not success then
            print(string.format("[Element] onImageLoad error: %s", tostring(callbackErr)))
          end
        end)
      else
        local success, callbackErr = pcall(self.onImageLoad, self, self.image)
        if not success then
          print(string.format("[Element] onImageLoad error: %s", tostring(callbackErr)))
        end
      end
    end
  else
    self._loadedImage = nil
  end

  -- Initialize Renderer module for visual rendering
  self._renderer = Element._Renderer.new({
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
    imageRepeat = self.imageRepeat,
    imageTint = self.imageTint,
    contentBlur = self.contentBlur,
    backdropBlur = self.backdropBlur,
  }, rendererDeps)

  --- self positioning ---
  local viewportWidth, viewportHeight = Element._Units.getViewport()

  ---- Sizing ----
  local gw, gh = love.window.getMode()
  self.prevGameSize = { width = gw, height = gh }
  self.autosizing = { width = false, height = false }

  -- Initialize LayoutEngine early with default values for auto-sizing calculations
  -- It will be re-configured later with actual layout properties
  self._layoutEngine = Element._LayoutEngine.new({
    positioning = Element._utils.enums.Positioning.RELATIVE,
    flexDirection = Element._utils.enums.FlexDirection.HORIZONTAL,
    flexWrap = Element._utils.enums.FlexWrap.NOWRAP,
    justifyContent = Element._utils.enums.JustifyContent.FLEX_START,
    alignItems = Element._utils.enums.AlignItems.STRETCH,
    alignContent = Element._utils.enums.AlignContent.STRETCH,
    gap = 0,
    gridRows = 1,
    gridColumns = 1,
    columnGap = 0,
    rowGap = 0,
  }, layoutEngineDeps)
  self._layoutEngine:initialize(self)

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

  local scaleX, scaleY = Element._Context.getScaleFactors()

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
    -- If using themeComponent, try to get default from theme via ThemeManager
    local defaultFont = self._themeManager:getDefaultFontFamily()
    self.fontFamily = defaultFont and "default" or nil
  else
    self.fontFamily = nil
  end

  -- Handle textSize BEFORE width/height calculation (needed for auto-sizing)
  if props.textSize then
    if type(props.textSize) == "string" then
      -- Check if it's a preset first
      local presetValue, presetUnit = Element._utils.resolveTextSizePreset(props.textSize)
      local value, unit

      if presetValue then
        -- It's a preset, use the preset value and unit
        value, unit = presetValue, presetUnit
        self.units.textSize = { value = value, unit = unit }
      else
        -- Not a preset, parse normally
        value, unit = Element._Units.parse(props.textSize)
        self.units.textSize = { value = value, unit = unit }
      end

      -- Resolve textSize based on unit type
      if unit == "%" or unit == "vh" then
        -- Percentage and vh are relative to viewport height
        self.textSize = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
      elseif unit == "vw" then
        -- vw is relative to viewport width
        self.textSize = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
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
        Element._ErrorHandler:error("Element", "ELEM_002", {
          unit = unit,
        })
      end
    else
      -- Validate pixel textSize value
      if props.textSize <= 0 then
        Element._ErrorHandler:error("Element", "ELEM_001", {
          value = tostring(props.textSize),
        })
      end

      -- Pixel textSize value
      if self.autoScaleText and Element._Context.baseScale then
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
        self.textSize = Element._Context.baseScale and (props.textSize * scaleY) or props.textSize
        self.units.textSize = { value = props.textSize, unit = "px" }
      end
    end
  else
    -- No textSize specified - use auto-scaling default
    if self.autoScaleText and Element._Context.baseScale then
      -- With base scaling: use 12px as default and scale
      self.units.textSize = { value = 12, unit = "px" }
      self.textSize = 12 * scaleY
    elseif self.autoScaleText then
      -- Without base scaling: default to 1.5vh (1.5% of viewport height)
      self.units.textSize = { value = 1.5, unit = "vh" }
      self.textSize = (1.5 / 100) * viewportHeight
    else
      -- No auto-scaling: use 12px with optional base scaling
      self.textSize = Element._Context.baseScale and (12 * scaleY) or 12
      self.units.textSize = { value = nil, unit = "px" }
    end
  end

  -- Handle width (both w and width properties, prefer w if both exist)
  local widthProp = props.width
  local tempWidth = 0 -- Temporary width for padding resolution
  if widthProp then
    if type(widthProp) == "string" then
      local value, unit = Element._Units.parse(widthProp)
      self.units.width = { value = value, unit = unit }
      local parentWidth = self.parent and self.parent.width or viewportWidth
      tempWidth = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
    else
      tempWidth = Element._Context.baseScale and (widthProp * scaleX) or widthProp
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
      local value, unit = Element._Units.parse(heightProp)
      self.units.height = { value = value, unit = unit }
      local parentHeight = self.parent and self.parent.height or viewportHeight
      tempHeight = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
    else
      -- Apply base scaling to pixel values
      tempHeight = Element._Context.baseScale and (heightProp * scaleY) or heightProp
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
      local value, unit = Element._Units.parse(props.gap)
      self.units.gap = { value = value, unit = unit }
      -- Gap percentages should be relative to the element's own size, not parent
      -- For horizontal flex, gap is based on width; for vertical flex, based on height
      local flexDir = props.flexDirection or Element._utils.enums.FlexDirection.HORIZONTAL
      local containerSize = (flexDir == Element._utils.enums.FlexDirection.HORIZONTAL) and self.width or self.height
      self.gap = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, containerSize)
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
  if self._themeManager:hasThemeComponent() then
    local component = self._themeManager:getComponent()
    if component and component._ninePatchData and component._ninePatchData.contentPadding then
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

  -- First, resolve padding using temporary dimensions
  -- For auto-sized elements, this is content width; for explicit sizing, this is border-box width
  local tempPadding
  if use9PatchPadding then
    -- Get scaled 9-patch content padding from ThemeManager
    local scaledPadding = self._themeManager:getScaledContentPadding(tempWidth, tempHeight)
    if scaledPadding then
      tempPadding = scaledPadding
    else
      -- Fallback if scaling fails
      tempPadding = {
        left = ninePatchContentPadding.left,
        top = ninePatchContentPadding.top,
        right = ninePatchContentPadding.right,
        bottom = ninePatchContentPadding.bottom,
      }
    end
  else
    tempPadding = Element._Units.resolveSpacing(props.padding, self.width, self.height)
  end

  -- Margin percentages are relative to parent's dimensions (CSS spec)
  local parentWidth = self.parent and self.parent.width or viewportWidth
  local parentHeight = self.parent and self.parent.height or viewportHeight
  self.margin = Element._Units.resolveSpacing(props.margin, parentWidth, parentHeight)

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
    self.padding = Element._Units.resolveSpacing(props.padding, self._borderBoxWidth, self._borderBoxHeight)
  end

  -- Calculate final content dimensions by subtracting padding from border-box
  self.width = math.max(0, self._borderBoxWidth - self.padding.left - self.padding.right)
  self.height = math.max(0, self._borderBoxHeight - self.padding.top - self.padding.bottom)

  -- Re-resolve ew/eh textSize units now that width/height are set
  if props.textSize and type(props.textSize) == "string" then
    -- Check if it's a preset first (presets don't need re-resolution)
    local presetValue, presetUnit = Element._utils.resolveTextSizePreset(props.textSize)
    if not presetValue then
      -- Not a preset, parse and check for ew/eh units
      local value, unit = Element._Units.parse(props.textSize)
      if unit == "ew" then
        -- Element width relative (now that width is set)
        self.textSize = (value / 100) * self.width
      elseif unit == "eh" then
        -- Element height relative (now that height is set)
        self.textSize = (value / 100) * self.height
      end
    end
  end

  -- Apply min/max constraints (also scaled)
  local minSize = self.minTextSize and (Element._Context.baseScale and (self.minTextSize * scaleY) or self.minTextSize)
  local maxSize = self.maxTextSize and (Element._Context.baseScale and (self.maxTextSize * scaleY) or self.maxTextSize)

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
        local value, unit = Element._Units.parse(props.padding.horizontal)
        self.units.padding.horizontal = { value = value, unit = unit }
      else
        self.units.padding.horizontal = { value = props.padding.horizontal, unit = "px" }
      end
    end
    if props.padding.vertical then
      if type(props.padding.vertical) == "string" then
        local value, unit = Element._Units.parse(props.padding.vertical)
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
        local value, unit = Element._Units.parse(props.padding[side])
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
        local value, unit = Element._Units.parse(props.margin.horizontal)
        self.units.margin.horizontal = { value = value, unit = unit }
      else
        self.units.margin.horizontal = { value = props.margin.horizontal, unit = "px" }
      end
    end
    if props.margin.vertical then
      if type(props.margin.vertical) == "string" then
        local value, unit = Element._Units.parse(props.margin.vertical)
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
        local value, unit = Element._Units.parse(props.margin[side])
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
    table.insert(Element._Context.topElements, self)

    -- Handle x position with units
    if props.x then
      if type(props.x) == "string" then
        local value, unit = Element._Units.parse(props.x)
        self.units.x = { value = value, unit = unit }
        self.x = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
      else
        -- Apply base scaling to pixel positions
        self.x = Element._Context.baseScale and (props.x * scaleX) or props.x
        self.units.x = { value = props.x, unit = "px" }
      end
    else
      self.x = 0
      self.units.x = { value = 0, unit = "px" }
    end

    -- Handle y position with units
    if props.y then
      if type(props.y) == "string" then
        local value, unit = Element._Units.parse(props.y)
        self.units.y = { value = value, unit = unit }
        self.y = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
      else
        -- Apply base scaling to pixel positions
        self.y = Element._Context.baseScale and (props.y * scaleY) or props.y
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
      -- Try to get text color from theme via ThemeManager
      local themeToUse = self._themeManager:getTheme()
      if themeToUse and themeToUse.colors and themeToUse.colors.text then
        self.textColor = themeToUse.colors.text
      else
        -- Fallback to black
        self.textColor = Element._Color.new(0, 0, 0, 1)
      end
    end

    -- Track if positioning was explicitly set
    if props.positioning then
      Element._utils.validateEnum(props.positioning, Element._utils.enums.Positioning, "positioning")
      self.positioning = props.positioning
      self._originalPositioning = props.positioning
      self._explicitlyAbsolute = (props.positioning == Element._utils.enums.Positioning.ABSOLUTE)
    else
      self.positioning = Element._utils.enums.Positioning.RELATIVE
      self._originalPositioning = nil -- No explicit positioning
      self._explicitlyAbsolute = false
    end
  else
    -- Set positioning first and track if explicitly set
    self._originalPositioning = props.positioning -- Track original intent
    if props.positioning == Element._utils.enums.Positioning.ABSOLUTE then
      self.positioning = Element._utils.enums.Positioning.ABSOLUTE
      self._explicitlyAbsolute = true -- Explicitly set to absolute by user
    elseif props.positioning == Element._utils.enums.Positioning.FLEX then
      self.positioning = Element._utils.enums.Positioning.FLEX
      self._explicitlyAbsolute = false
    elseif props.positioning == Element._utils.enums.Positioning.GRID then
      self.positioning = Element._utils.enums.Positioning.GRID
      self._explicitlyAbsolute = false
    else
      -- Default: children in flex/grid containers participate in parent's layout
      -- children in relative/absolute containers default to relative
      if self.parent.positioning == Element._utils.enums.Positioning.FLEX or self.parent.positioning == Element._utils.enums.Positioning.GRID then
        self.positioning = Element._utils.enums.Positioning.ABSOLUTE -- They are positioned BY flex/grid, not AS flex/grid
        self._explicitlyAbsolute = false -- Participate in parent's layout
      else
        self.positioning = Element._utils.enums.Positioning.RELATIVE
        self._explicitlyAbsolute = false -- Default for relative/absolute containers
      end
    end

    -- Set initial position
    if self.positioning == Element._utils.enums.Positioning.ABSOLUTE then
      -- Absolute positioning is relative to parent's content area (padding box)
      local baseX = self.parent.x + self.parent.padding.left
      local baseY = self.parent.y + self.parent.padding.top

      -- Handle x position with units
      if props.x then
        if type(props.x) == "string" then
          local value, unit = Element._Units.parse(props.x)
          self.units.x = { value = value, unit = unit }
          local parentWidth = self.parent.width
          local offsetX = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
          self.x = baseX + offsetX
        else
          -- Apply base scaling to pixel positions
          local scaledOffset = Element._Context.baseScale and (props.x * scaleX) or props.x
          self.x = baseX + scaledOffset
          self.units.x = { value = props.x, unit = "px" }
        end
      else
        self.x = baseX
        self.units.x = { value = 0, unit = "px" }
      end

      -- Handle y position with units
      if props.y then
        if type(props.y) == "string" then
          local value, unit = Element._Units.parse(props.y)
          self.units.y = { value = value, unit = unit }
          local parentHeight = self.parent.height
          local offsetY = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
          self.y = baseY + offsetY
        else
          -- Apply base scaling to pixel positions
          local scaledOffset = Element._Context.baseScale and (props.y * scaleY) or props.y
          self.y = baseY + scaledOffset
          self.units.y = { value = props.y, unit = "px" }
        end
      else
        self.y = baseY
        self.units.y = { value = 0, unit = "px" }
      end

      self.z = props.z or 0
    else
      -- Children in flex containers start at parent position but will be repositioned by layoutChildren
      -- Children in absolute/relative containers start at parent's content area (accounting for padding)
      local baseX = self.parent.x + self.parent.padding.left
      local baseY = self.parent.y + self.parent.padding.top

      if props.x then
        if type(props.x) == "string" then
          local value, unit = Element._Units.parse(props.x)
          self.units.x = { value = value, unit = unit }
          local parentWidth = self.parent.width
          local offsetX = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, parentWidth)
          self.x = baseX + offsetX
        else
          -- Apply base scaling to pixel offsets
          local scaledOffset = Element._Context.baseScale and (props.x * scaleX) or props.x
          self.x = baseX + scaledOffset
          self.units.x = { value = props.x, unit = "px" }
        end
      else
        self.x = baseX
        self.units.x = { value = 0, unit = "px" }
      end

      if props.y then
        if type(props.y) == "string" then
          local value, unit = Element._Units.parse(props.y)
          self.units.y = { value = value, unit = unit }
          parentHeight = self.parent.height
          local offsetY = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, parentHeight)
          self.y = baseY + offsetY
        else
          -- Apply base scaling to pixel offsets
          local scaledOffset = Element._Context.baseScale and (props.y * scaleY) or props.y
          self.y = baseY + scaledOffset
          self.units.y = { value = props.y, unit = "px" }
        end
      else
        self.y = baseY
        self.units.y = { value = 0, unit = "px" }
      end

      self.z = props.z or self.parent.z or 0
    end

    if props.textColor then
      self.textColor = props.textColor
    elseif self.parent.textColor then
      self.textColor = self.parent.textColor
    else
      local themeToUse = self._themeManager:getTheme()
      if themeToUse and themeToUse.colors and themeToUse.colors.text then
        self.textColor = themeToUse.colors.text
      else
        -- Fallback to black
        self.textColor = Element._Color.new(0, 0, 0, 1)
      end
    end

    props.parent:addChild(self)
  end

  -- Handle positioning properties for ALL elements (with or without parent)
  -- Handle top positioning with units
  if props.top then
    if type(props.top) == "string" then
      local value, unit = Element._Units.parse(props.top)
      self.units.top = { value = value, unit = unit }
      self.top = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
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
      local value, unit = Element._Units.parse(props.right)
      self.units.right = { value = value, unit = unit }
      self.right = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
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
      local value, unit = Element._Units.parse(props.bottom)
      self.units.bottom = { value = value, unit = unit }
      self.bottom = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, viewportHeight)
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
      local value, unit = Element._Units.parse(props.left)
      self.units.left = { value = value, unit = unit }
      self.left = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, viewportWidth)
    else
      self.left = props.left
      self.units.left = { value = props.left, unit = "px" }
    end
  else
    self.left = nil
    self.units.left = nil
  end

  if self.positioning == Element._utils.enums.Positioning.FLEX then
    -- Validate enum properties
    if props.flexDirection then
      Element._utils.validateEnum(props.flexDirection, Element._utils.enums.FlexDirection, "flexDirection")
    end
    if props.flexWrap then
      Element._utils.validateEnum(props.flexWrap, Element._utils.enums.FlexWrap, "flexWrap")
    end
    if props.justifyContent then
      Element._utils.validateEnum(props.justifyContent, Element._utils.enums.JustifyContent, "justifyContent")
    end
    if props.alignItems then
      Element._utils.validateEnum(props.alignItems, Element._utils.enums.AlignItems, "alignItems")
    end
    if props.alignContent then
      Element._utils.validateEnum(props.alignContent, Element._utils.enums.AlignContent, "alignContent")
    end
    if props.justifySelf then
      Element._utils.validateEnum(props.justifySelf, Element._utils.enums.JustifySelf, "justifySelf")
    end

    self.flexDirection = props.flexDirection or Element._utils.enums.FlexDirection.HORIZONTAL
    self.flexWrap = props.flexWrap or Element._utils.enums.FlexWrap.NOWRAP
    self.justifyContent = props.justifyContent or Element._utils.enums.JustifyContent.FLEX_START
    self.alignItems = props.alignItems or Element._utils.enums.AlignItems.STRETCH
    self.alignContent = props.alignContent or Element._utils.enums.AlignContent.STRETCH
    self.justifySelf = props.justifySelf or Element._utils.enums.JustifySelf.AUTO
  end

  -- Grid container properties
  if self.positioning == Element._utils.enums.Positioning.GRID then
    self.gridRows = props.gridRows or 1
    self.gridColumns = props.gridColumns or 1
    self.alignItems = props.alignItems or Element._utils.enums.AlignItems.STRETCH

    -- Handle columnGap and rowGap
    if props.columnGap then
      if type(props.columnGap) == "string" then
        local value, unit = Element._Units.parse(props.columnGap)
        self.columnGap = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, self.width)
      else
        self.columnGap = props.columnGap
      end
    else
      self.columnGap = 0
    end

    if props.rowGap then
      if type(props.rowGap) == "string" then
        local value, unit = Element._Units.parse(props.rowGap)
        self.rowGap = Element._Units.resolve(value, unit, viewportWidth, viewportHeight, self.height)
      else
        self.rowGap = props.rowGap
      end
    else
      self.rowGap = 0
    end
  end

  self.alignSelf = props.alignSelf or Element._utils.enums.AlignSelf.AUTO

  -- Update the LayoutEngine with actual layout properties
  -- (it was initialized early with defaults for auto-sizing calculations)
  self._layoutEngine.positioning = self.positioning
  if self.flexDirection then
    self._layoutEngine.flexDirection = self.flexDirection
  end
  if self.flexWrap then
    self._layoutEngine.flexWrap = self.flexWrap
  end
  if self.justifyContent then
    self._layoutEngine.justifyContent = self.justifyContent
  end
  if self.alignItems then
    self._layoutEngine.alignItems = self.alignItems
  end
  if self.alignContent then
    self._layoutEngine.alignContent = self.alignContent
  end
  if self.gap then
    self._layoutEngine.gap = self.gap
  end
  if self.gridRows then
    self._layoutEngine.gridRows = self.gridRows
  end
  if self.gridColumns then
    self._layoutEngine.gridColumns = self.gridColumns
  end
  if self.columnGap then
    self._layoutEngine.columnGap = self.columnGap
  end
  if self.rowGap then
    self._layoutEngine.rowGap = self.rowGap
  end

  -- transform is already set at line 424 (props.transform or nil)
  -- Don't overwrite it here
  self.transition = props.transition or {}

  if props.overflow or props.overflowX or props.overflowY then
    self._scrollManager = Element._ScrollManager.new({
      overflow = props.overflow,
      overflowX = props.overflowX,
      overflowY = props.overflowY,
      scrollbarWidth = props.scrollbarWidth,
      scrollbarColor = props.scrollbarColor,
      scrollbarTrackColor = props.scrollbarTrackColor,
      scrollbarRadius = props.scrollbarRadius,
      scrollbarPadding = props.scrollbarPadding,
      scrollSpeed = props.scrollSpeed,
      hideScrollbars = props.hideScrollbars,
      _scrollX = props._scrollX,
      _scrollY = props._scrollY,
    }, scrollManagerDeps)

    -- Expose ScrollManager properties for backward compatibility (Renderer access)
    self.overflow = self._scrollManager.overflow
    self.overflowX = self._scrollManager.overflowX
    self.overflowY = self._scrollManager.overflowY
    self.scrollbarWidth = self._scrollManager.scrollbarWidth
    self.scrollbarColor = self._scrollManager.scrollbarColor
    self.scrollbarTrackColor = self._scrollManager.scrollbarTrackColor
    self.scrollbarRadius = self._scrollManager.scrollbarRadius
    self.scrollbarPadding = self._scrollManager.scrollbarPadding
    self.scrollSpeed = self._scrollManager.scrollSpeed
    self.hideScrollbars = self._scrollManager.hideScrollbars

    -- Initialize state properties (will be synced from ScrollManager)
    self._overflowX = false
    self._overflowY = false
    self._contentWidth = 0
    self._contentHeight = 0
    self._scrollX = 0
    self._scrollY = 0
    self._maxScrollX = 0
    self._maxScrollY = 0
    self._scrollbarHoveredVertical = false
    self._scrollbarHoveredHorizontal = false
    self._scrollbarDragging = false
    self._hoveredScrollbar = nil
    self._scrollbarDragOffset = 0
  else
    self._scrollManager = nil
  end

  -- Register element in z-index tracking for immediate mode
  if Element._Context._immediateMode then
    Element._Context.registerElement(self)
  end

  return self
end

--- Retrieve the element's screen-space rectangle for collision detection and positioning calculations
--- Use this for custom layout logic, tooltips, or detecting overlaps between elements
---@return { x:number, y:number, width:number, height:number }
function Element:getBounds()
  return { x = self.x, y = self.y, width = self:getBorderBoxWidth(), height = self:getBorderBoxHeight() }
end

--- Test if a screen coordinate falls within the element's clickable area
--- Use this for custom hit detection or determining which element the mouse is over
--- @param x number
--- @param y number
--- @return boolean
function Element:contains(x, y)
  local bounds = self:getBounds()
  return bounds.x <= x and bounds.y <= y and bounds.x + bounds.width >= x and bounds.y + bounds.height >= y
end

--- Get the element's total width including padding for layout calculations
--- Use this when you need the full visual width rather than just content width
---@return number
function Element:getBorderBoxWidth()
  return self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
end

--- Get the element's total height including padding for layout calculations
--- Use this when you need the full visual height rather than just content height
---@return number
function Element:getBorderBoxHeight()
  return self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)
end

--- Sync ScrollManager state to Element properties for backward compatibility
--- This ensures Renderer and StateManager can access scroll state from Element
function Element:_syncScrollManagerState()
  if not self._scrollManager then
    return
  end

  -- Sync state properties from ScrollManager
  self._overflowX = self._scrollManager._overflowX
  self._overflowY = self._scrollManager._overflowY
  self._contentWidth = self._scrollManager._contentWidth
  self._contentHeight = self._scrollManager._contentHeight
  self._scrollX = self._scrollManager._scrollX
  self._scrollY = self._scrollManager._scrollY
  self._maxScrollX = self._scrollManager._maxScrollX
  self._maxScrollY = self._scrollManager._maxScrollY
  self._scrollbarHoveredVertical = self._scrollManager._scrollbarHoveredVertical
  self._scrollbarHoveredHorizontal = self._scrollManager._scrollbarHoveredHorizontal
  self._scrollbarDragging = self._scrollManager._scrollbarDragging
  self._hoveredScrollbar = self._scrollManager._hoveredScrollbar
  self._scrollbarDragOffset = self._scrollManager._scrollbarDragOffset
end

--- Detect if content overflows container bounds (delegates to ScrollManager)
function Element:_detectOverflow()
  if self._scrollManager then
    self._scrollManager:detectOverflow(self)
    self:_syncScrollManagerState()
  end
end

--- Programmatically scroll content to any position for implementing "scroll to top" buttons or navigation anchors
--- Use this to create custom scrolling controls or jump to specific content sections
---@param x number? -- X scroll position (nil to keep current)
---@param y number? -- Y scroll position (nil to keep current)
function Element:setScrollPosition(x, y)
  if self._scrollManager then
    self._scrollManager:setScroll(x, y)
    self:_syncScrollManagerState()
  end
end

--- Calculate scrollbar dimensions and positions (delegates to ScrollManager)
---@return table -- {vertical: {visible, trackHeight, thumbHeight, thumbY}, horizontal: {visible, trackWidth, thumbWidth, thumbX}}
function Element:_calculateScrollbarDimensions()
  if self._scrollManager then
    return self._scrollManager:calculateScrollbarDimensions(self)
  end
  -- Return empty result if no ScrollManager
  return {
    vertical = { visible = false, trackHeight = 0, thumbHeight = 0, thumbY = 0 },
    horizontal = { visible = false, trackWidth = 0, thumbWidth = 0, thumbX = 0 },
  }
end

--- Draw scrollbars

--- Get scrollbar at mouse position (delegates to ScrollManager)
---@param mouseX number
---@param mouseY number
---@return table|nil -- {component: "vertical"|"horizontal", region: "thumb"|"track"}
function Element:_getScrollbarAtPosition(mouseX, mouseY)
  if self._scrollManager then
    return self._scrollManager:getScrollbarAtPosition(self, mouseX, mouseY)
  end
  return nil
end

--- Handle scrollbar mouse press
---@param mouseX number
---@param mouseY number
---@param button number
---@return boolean -- True if event was consumed
function Element:_handleScrollbarPress(mouseX, mouseY, button)
  if self._scrollManager then
    local consumed = self._scrollManager:handleMousePress(self, mouseX, mouseY, button)
    self:_syncScrollManagerState()
    return consumed
  end
  return false
end

--- Handle scrollbar drag (delegates to ScrollManager)
---@param mouseX number
---@param mouseY number
---@return boolean -- True if event was consumed
function Element:_handleScrollbarDrag(mouseX, mouseY)
  if self._scrollManager then
    local consumed = self._scrollManager:handleMouseMove(self, mouseX, mouseY)
    self:_syncScrollManagerState()
    return consumed
  end
  return false
end

--- Handle scrollbar release (delegates to ScrollManager)
---@param button number
---@return boolean -- True if event was consumed
function Element:_handleScrollbarRelease(button)
  if self._scrollManager then
    local consumed = self._scrollManager:handleMouseRelease(button)
    self:_syncScrollManagerState()
    return consumed
  end
  return false
end

--- Handle mouse wheel scrolling (delegates to ScrollManager)
---@param x number -- Horizontal scroll amount
---@param y number -- Vertical scroll amount
---@return boolean -- True if scroll was handled
function Element:_handleWheelScroll(x, y)
  if self._scrollManager then
    local consumed = self._scrollManager:handleWheel(x, y)
    self:_syncScrollManagerState()
    return consumed
  end
  return false
end

--- Query how far content is scrolled to implement scroll-aware UI like "back to top" buttons
--- Use this to create scroll position indicators or trigger lazy-loading
---@return number scrollX, number scrollY
function Element:getScrollPosition()
  if self._scrollManager then
    return self._scrollManager:getScroll()
  end
  return 0, 0
end

--- Find the scroll limits for validation and scroll position clamping
--- Use this to determine if content is fully scrolled or calculate remaining scroll distance
---@return number maxScrollX, number maxScrollY
function Element:getMaxScroll()
  if self._scrollManager then
    return self._scrollManager:getMaxScroll()
  end
  return 0, 0
end

--- Get normalized scroll progress for scroll-based animations or position indicators
--- Use this to drive progress bars or parallax effects based on scroll position
---@return number percentX, number percentY
function Element:getScrollPercentage()
  if self._scrollManager then
    return self._scrollManager:getScrollPercentage()
  end
  return 0, 0
end

--- Determine if content extends beyond visible bounds to conditionally show scrollbars or overflow indicators
--- Use this to decide whether to display scroll hints or enable scroll interactions
---@return boolean hasOverflowX, boolean hasOverflowY
function Element:hasOverflow()
  if self._scrollManager then
    return self._scrollManager:hasOverflow()
  end
  return false, false
end

--- Measure total content size including overflowed areas for scroll calculations
--- Use this to understand how much content exists beyond the visible viewport
---@return number contentWidth, number contentHeight
function Element:getContentSize()
  if self._scrollManager then
    return self._scrollManager:getContentSize()
  end
  return 0, 0
end

--- Scroll content by a relative amount for smooth scrolling animations or gesture-based scrolling
--- Use this to implement custom scroll controls or smooth scroll transitions
---@param dx number? -- X delta (nil for no change)
---@param dy number? -- Y delta (nil for no change)
function Element:scrollBy(dx, dy)
  if self._scrollManager then
    self._scrollManager:scrollBy(dx, dy)
    self:_syncScrollManagerState()
  end
end

--- Jump to the beginning of scrollable content instantly
--- Use this for "back to top" buttons or resetting scroll position
function Element:scrollToTop()
  self:setScrollPosition(nil, 0)
end

--- Scroll to bottom
function Element:scrollToBottom()
  if self._scrollManager then
    local _, maxScrollY = self._scrollManager:getMaxScroll()
    self:setScrollPosition(nil, maxScrollY)
  end
end

--- Scroll to left
function Element:scrollToLeft()
  self:setScrollPosition(0, nil)
end

--- Jump to the rightmost position of horizontally scrollable content
--- Use this to navigate to the end of horizontal lists or carousels
function Element:scrollToRight()
  if self._scrollManager then
    local maxScrollX, _ = self._scrollManager:getMaxScroll()
    self:setScrollPosition(maxScrollX, nil)
  end
end

--- Get the current state's scaled content padding
--- Returns the contentPadding for the current theme state, scaled to the element's size
---@return table|nil -- {left, top, right, bottom} or nil if no contentPadding
function Element:getScaledContentPadding()
  local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
  local borderBoxHeight = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)
  return self._themeManager:getScaledContentPadding(borderBoxWidth, borderBoxHeight)
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
    self._blurInstance = Element._Blur.new({ quality = quality })
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

--- Dynamically insert a child element into the hierarchy for runtime UI construction
--- Use this to build interfaces procedurally or add elements based on application state
---@param child Element
function Element:addChild(child)
  child.parent = self

  -- Re-evaluate positioning now that we have a parent
  -- If child was created without explicit positioning, inherit from parent
  if child._originalPositioning == nil then
    -- No explicit positioning was set during construction
    if self.positioning == Element._utils.enums.Positioning.FLEX or self.positioning == Element._utils.enums.Positioning.GRID then
      child.positioning = Element._utils.enums.Positioning.ABSOLUTE -- They are positioned BY flex/grid, not AS flex/grid
      child._explicitlyAbsolute = false -- Participate in parent's layout
    else
      child.positioning = Element._utils.enums.Positioning.RELATIVE
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
  if not Element._Context._immediateMode then
    self:layoutChildren()
  end
end

--- Remove a child element from the hierarchy to dynamically update UIs
--- Use this to delete elements when they're no longer needed or respond to user actions
---@param child Element
function Element:removeChild(child)
  for i, c in ipairs(self.children) do
    if c == child then
      table.remove(self.children, i)
      child.parent = nil

      -- Recalculate auto-sizing if needed
      if self.autosizing.width or self.autosizing.height then
        if self.autosizing.width then
          local contentWidth = self:calculateAutoWidth()
          self._borderBoxWidth = contentWidth + self.padding.left + self.padding.right
          self.width = contentWidth
        end
        if self.autosizing.height then
          local contentHeight = self:calculateAutoHeight()
          self._borderBoxHeight = contentHeight + self.padding.top + self.padding.bottom
          self.height = contentHeight
        end
      end

      -- Re-layout children after removal
      if not Element._Context._immediateMode then
        self:layoutChildren()
      end

      break
    end
  end
end

--- Delete all child elements at once for resetting containers or clearing lists
--- Use this to efficiently empty containers when rebuilding UI from scratch
function Element:clearChildren()
  -- Clear parent references for all children
  for _, child in ipairs(self.children) do
    child.parent = nil
  end

  -- Clear the children table
  self.children = {}

  -- Recalculate auto-sizing if needed
  if self.autosizing.width or self.autosizing.height then
    if self.autosizing.width then
      local contentWidth = self:calculateAutoWidth()
      self._borderBoxWidth = contentWidth + self.padding.left + self.padding.right
      self.width = contentWidth
    end
    if self.autosizing.height then
      local contentHeight = self:calculateAutoHeight()
      self._borderBoxHeight = contentHeight + self.padding.top + self.padding.bottom
      self.height = contentHeight
    end
  end

  -- Re-layout (though there are no children now)
  if not Element._Context._immediateMode then
    self:layoutChildren()
  end
end

--- Get the number of children this element has
---@return number
function Element:getChildCount()
  return #self.children
end

--- Apply positioning offsets (top, right, bottom, left) to an element
-- @param element The element to apply offsets to
function Element:applyPositioningOffsets(element)
  -- Delegate to LayoutEngine
  self._layoutEngine:applyPositioningOffsets(element)
end

function Element:layoutChildren()
  -- Check performance warnings (only on root elements to avoid spam)
  if not self.parent then
    self:_checkPerformanceWarnings()
  end

  -- Delegate layout to LayoutEngine
  self._layoutEngine:layoutChildren()
end

--- Destroy element and its children
function Element:destroy()
  -- Remove from global elements list
  for i, win in ipairs(Element._Context.topElements) do
    if win == self then
      table.remove(Element._Context.topElements, i)
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
      drawBackgroundColor = Element._Color.new(self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b, anim.opacity)
    end
  end

  -- Cache border box dimensions for this draw call (optimization)
  local borderBoxWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right)
  local borderBoxHeight = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom)

  -- LAYERS 0.5-3: Delegate visual rendering (backdrop blur, background, image, theme, borders) to Renderer module
  self._renderer:draw(self, backdropCanvas)

  -- LAYER 4: Delegate text rendering (text, cursor, selection, placeholder, password masking) to Renderer module
  self._renderer:drawText(self)

  -- Draw visual feedback when element is pressed (if it has an onEvent handler and highlight is not disabled)
  if self.onEvent and not self.disableHighlight and self._eventHandler then
    -- Check if any button is pressed
    local anyPressed = false
    local pressedState = self._eventHandler:getState()._pressed or {}
    for _, pressed in pairs(pressedState) do
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
  local hasRoundedCorners = false
  if self.cornerRadius then
    if type(self.cornerRadius) == "number" then
      hasRoundedCorners = self.cornerRadius > 0
    else
      hasRoundedCorners = self.cornerRadius.topLeft > 0
        or self.cornerRadius.topRight > 0
        or self.cornerRadius.bottomLeft > 0
        or self.cornerRadius.bottomRight > 0
    end
  end

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
      local stencilFunc = Element._RoundedRect.stencilFunction(self.x, self.y, borderBoxWidth, borderBoxHeight, self.cornerRadius)

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
      Element._Blur.applyToRegion(blurInstance, self.contentBlur.intensity, self.x, self.y, borderBoxWidth, borderBoxHeight, drawChildren)
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
  -- Track active animations for performance warnings (only on root elements)
  if not self.parent then
    self:_trackActiveAnimations()
  end

  -- Restore scrollbar state from StateManager in immediate mode
  if self._stateId and Element._Context._immediateMode then
    local state = Element._StateManager.getState(self._stateId)
    if state then
      self._scrollbarHoveredVertical = state.scrollbarHoveredVertical or false
      self._scrollbarHoveredHorizontal = state.scrollbarHoveredHorizontal or false
      self._scrollbarDragging = state.scrollbarDragging or false
      self._hoveredScrollbar = state.hoveredScrollbar
      self._scrollbarDragOffset = state.scrollbarDragOffset or 0

      if self._scrollManager then
        self._scrollManager._scrollbarHoveredVertical = self._scrollbarHoveredVertical
        self._scrollManager._scrollbarHoveredHorizontal = self._scrollbarHoveredHorizontal
        self._scrollManager._scrollbarDragging = self._scrollbarDragging
        self._scrollManager._hoveredScrollbar = self._hoveredScrollbar
        self._scrollManager._scrollbarDragOffset = self._scrollbarDragOffset
      end
    end
  end

  for _, child in ipairs(self.children) do
    child:update(dt)
  end

  -- Update text editor cursor blink
  if self._textEditor then
    self._textEditor:update(self, dt)
  end

  -- Update animation if exists
  if self.animation then
    -- Ensure animation has Color module reference for color interpolation
    if Element._Animation and not Element._Animation._ColorModule and Element._Color then
      Element._Animation._ColorModule = Element._Color
    end

    -- Ensure animation has Transform module reference for transform interpolation
    if Element._Animation and not Element._Animation._TransformModule and Element._Transform then
      Element._Animation._TransformModule = Element._Transform
    end

    local finished = self.animation:update(dt, self)
    if finished then
      -- Animation:update() already called onComplete callback
      -- Check for chained animation
      if self.animation._next then
        self.animation = self.animation._next
      elseif self.animation._nextFactory and type(self.animation._nextFactory) == "function" then
        local success, nextAnim = pcall(self.animation._nextFactory, self)
        if success and nextAnim then
          self.animation = nextAnim
        else
          self.animation = nil
        end
      else
        self.animation = nil
      end
    else
      -- Apply animation interpolation during update
      local anim = self.animation:interpolate()

      -- Apply numeric properties
      self.width = anim.width or self.width
      self.height = anim.height or self.height
      self.opacity = anim.opacity or self.opacity
      self.x = anim.x or self.x
      self.y = anim.y or self.y
      self.gap = anim.gap or self.gap
      self.imageOpacity = anim.imageOpacity or self.imageOpacity
      self.scrollbarWidth = anim.scrollbarWidth or self.scrollbarWidth
      self.borderWidth = anim.borderWidth or self.borderWidth
      self.fontSize = anim.fontSize or self.fontSize
      self.lineHeight = anim.lineHeight or self.lineHeight

      -- Apply color properties
      if anim.backgroundColor then
        self.backgroundColor = anim.backgroundColor
      end
      if anim.borderColor then
        self.borderColor = anim.borderColor
      end
      if anim.textColor then
        self.textColor = anim.textColor
      end
      if anim.scrollbarColor then
        self.scrollbarColor = anim.scrollbarColor
      end
      if anim.scrollbarBackgroundColor then
        self.scrollbarBackgroundColor = anim.scrollbarBackgroundColor
      end
      if anim.imageTint then
        self.imageTint = anim.imageTint
      end

      -- Apply table properties
      if anim.padding then
        self.padding = anim.padding
      end
      if anim.margin then
        self.margin = anim.margin
      end
      if anim.cornerRadius then
        self.cornerRadius = anim.cornerRadius
      end

      -- Apply transform property
      if anim.transform then
        self.transform = anim.transform
      end

      -- Backward compatibility: Update background color with interpolated opacity
      if anim.opacity and not anim.backgroundColor then
        self.backgroundColor.a = anim.opacity
      end
    end
  end

  local mx, my = love.mouse.getPosition()

  if self._scrollManager then
    self._scrollManager:updateHoverState(self, mx, my)
    self:_syncScrollManagerState()
  end

  if self._stateId and Element._Context._immediateMode then
    Element._StateManager.updateState(self._stateId, {
      scrollbarHoveredVertical = self._scrollbarHoveredVertical,
      scrollbarHoveredHorizontal = self._scrollbarHoveredHorizontal,
      scrollbarDragging = self._scrollbarDragging,
      hoveredScrollbar = self._hoveredScrollbar,
    })
  end

  if self._scrollbarDragging and love.mouse.isDown(1) then
    self:_handleScrollbarDrag(mx, my)
  elseif self._scrollbarDragging then
    if self._scrollManager then
      self._scrollManager:handleMouseRelease(1)
      self:_syncScrollManagerState()
    end

    if self._stateId and Element._Context._immediateMode then
      Element._StateManager.updateState(self._stateId, {
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
    if Element._Context._immediateMode then
      -- In immediate mode, use z-index occlusion detection
      local topElement = Element._Context.getTopElementAt(mx, my)
      isActiveElement = (topElement == self or topElement == nil)
    else
      -- In retained mode, use the old _activeEventElement mechanism
      isActiveElement = (Element._Context._activeEventElement == nil or Element._Context._activeEventElement == self)
    end

    -- Reset scrollbar press flag at start of each frame
    self._eventHandler:resetScrollbarPressFlag()

    -- Process mouse events through EventHandler FIRST
    -- This ensures pressed states are updated before theme state is calculated
    self._eventHandler:processMouseEvents(self, mx, my, isHovering, isActiveElement)

    -- In immediate mode, save EventHandler state to StateManager after processing events
    if self._stateId and Element._Context._immediateMode and self._stateId ~= "" then
      local eventHandlerState = self._eventHandler:getState()
      Element._StateManager.updateState(self._stateId, {
        _pressed = eventHandlerState._pressed,
        _lastClickTime = eventHandlerState._lastClickTime,
        _lastClickButton = eventHandlerState._lastClickButton,
        _clickCount = eventHandlerState._clickCount,
        _dragStartX = eventHandlerState._dragStartX,
        _dragStartY = eventHandlerState._dragStartY,
        _lastMouseX = eventHandlerState._lastMouseX,
        _lastMouseY = eventHandlerState._lastMouseY,
        _hovered = eventHandlerState._hovered,
      })
    end

    -- Update theme state based on interaction
    if self.themeComponent then
      -- Check if any button is pressed via EventHandler
      local anyPressed = self._eventHandler:isAnyButtonPressed()

      -- Update theme state via ThemeManager
      local newThemeState = self._themeManager:updateState(isHovering and isActiveElement, anyPressed, self._focused, self.disabled)

      -- Update state (in StateManager if in immediate mode, otherwise locally)
      if self._stateId and Element._Context._immediateMode then
        -- Update in StateManager for immediate mode
        local hover = newThemeState == "hover"
        local pressed = newThemeState == "pressed"
        local focused = newThemeState == "active" or self._focused

        Element._StateManager.updateState(self._stateId, {
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

    -- Process touch events through EventHandler
    self._eventHandler:processTouchEvents(self)
  end
end

---@param newViewportWidth number
---@param newViewportHeight number
function Element:recalculateUnits(newViewportWidth, newViewportHeight)
  self._layoutEngine:recalculateUnits(newViewportWidth, newViewportHeight)
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
    local _, scaleY = Element._Context.getScaleFactors()

    if unit == "ew" then
      -- Element width relative (use current width)
      self.textSize = (value / 100) * self.width

      -- Apply min/max constraints
      local minSize = self.minTextSize and (Element._Context.baseScale and (self.minTextSize * scaleY) or self.minTextSize)
      local maxSize = self.maxTextSize and (Element._Context.baseScale and (self.maxTextSize * scaleY) or self.maxTextSize)
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
      local minSize = self.minTextSize and (Element._Context.baseScale and (self.minTextSize * scaleY) or self.minTextSize)
      local maxSize = self.maxTextSize and (Element._Context.baseScale and (self.maxTextSize * scaleY) or self.maxTextSize)
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

  local font = Element._utils.getFont(self.textSize, self.fontFamily, self.themeComponent, self._themeManager)
  local width = font:getWidth(self.text)
  return Element._utils.applyContentMultiplier(width, self.contentAutoSizingMultiplier, "width")
end

---@return number
function Element:calculateTextHeight()
  if self.text == nil then
    return 0
  end

  local font = Element._utils.getFont(self.textSize, self.fontFamily, self.themeComponent, self._themeManager)
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

  return Element._utils.applyContentMultiplier(height, self.contentAutoSizingMultiplier, "height")
end

function Element:calculateAutoWidth()
  return self._layoutEngine:calculateAutoWidth()
end

--- Calculate auto height based on children
function Element:calculateAutoHeight()
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
    self._textEditor:setCursorPosition(self, position)
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
    self._textEditor:moveCursorBy(self, delta)
  end
end

--- Move cursor to start of text
function Element:moveCursorToStart()
  if self._textEditor then
    self._textEditor:moveCursorToStart(self)
  end
end

--- Move cursor to end of text
function Element:moveCursorToEnd()
  if self._textEditor then
    self._textEditor:moveCursorToEnd(self)
  end
end

--- Move cursor to start of current line
function Element:moveCursorToLineStart()
  if self._textEditor then
    self._textEditor:moveCursorToLineStart(self)
  end
end

--- Move cursor to end of current line
function Element:moveCursorToLineEnd()
  if self._textEditor then
    self._textEditor:moveCursorToLineEnd(self)
  end
end

--- Move cursor to start of previous word
function Element:moveCursorToPreviousWord()
  if self._textEditor then
    self._textEditor:moveCursorToPreviousWord(self)
  end
end

--- Move cursor to start of next word
function Element:moveCursorToNextWord()
  if self._textEditor then
    self._textEditor:moveCursorToNextWord(self)
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
    self._textEditor:setSelection(self, startPos, endPos)
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
    self._textEditor:clearSelection(self)
  end
end

--- Select all text
function Element:selectAll()
  if self._textEditor then
    self._textEditor:selectAll(self)
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
    local result = self._textEditor:deleteSelection(self)
    if result then
      self.text = self._textEditor:getText() -- Sync display text
      self._textEditor:updateAutoGrowHeight(self)
    end
    return result
  end
  return false
end

-- ====================
-- Input Handling - Focus Management
-- ====================

--- Give this element keyboard focus to enable text input or keyboard navigation
--- Use this to automatically focus text fields when showing forms or dialogs
function Element:focus()
  if self._textEditor then
    self._textEditor:focus(self)
  end
end

--- Remove keyboard focus to stop capturing input events
--- Use this when closing popups or switching focus to other elements
function Element:blur()
  if self._textEditor then
    self._textEditor:blur(self)
  end
end

--- Query focus state to conditionally render focus indicators or handle keyboard input
--- Use this to style focused elements or determine which element receives keyboard events
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

--- Retrieve the element's current text content for processing or validation
--- Use this to read user input from text fields or get display text
---@return string
function Element:getText()
  if self._textEditor then
    return self._textEditor:getText()
  end
  return self.text or ""
end

--- Update the element's text content programmatically for dynamic labels or resetting inputs
--- Use this to change text without user input, like clearing fields or updating status messages
---@param text string
function Element:setText(text)
  if self._textEditor then
    self._textEditor:setText(self, text)
    self.text = self._textEditor:getText() -- Sync display text
    self._textEditor:updateAutoGrowHeight(self)
    return
  end
  self.text = text
end

--- Programmatically insert text at any position for autocomplete or text manipulation
--- Use this to implement suggestions, templates, or text snippets
---@param text string -- Text to insert
---@param position number? -- Position to insert at (default: cursor position)
function Element:insertText(text, position)
  if self._textEditor then
    self._textEditor:insertText(self, text, position)
    self.text = self._textEditor:getText() -- Sync display text
    self._textEditor:updateAutoGrowHeight(self)
  end
end

---@param startPos number -- Start position (inclusive)
---@param endPos number -- End position (inclusive)
function Element:deleteText(startPos, endPos)
  if self._textEditor then
    self._textEditor:deleteText(self, startPos, endPos)
    self.text = self._textEditor:getText() -- Sync display text
    self._textEditor:updateAutoGrowHeight(self)
  end
end

--- Replace text in range
---@param startPos number -- Start position (inclusive)
---@param endPos number -- End position (inclusive)
---@param newText string -- Replacement text
function Element:replaceText(startPos, endPos, newText)
  if self._textEditor then
    self._textEditor:replaceText(self, startPos, endPos, newText)
    self.text = self._textEditor:getText() -- Sync display text
    self._textEditor:updateAutoGrowHeight(self)
  end
end

--- Wrap a single line of text
---@param line string -- Line to wrap
---@param maxWidth number -- Maximum width in pixels
---@return table -- Array of wrapped line parts
function Element:_wrapLine(line, maxWidth)
  return self._renderer:wrapLine(self, line, maxWidth)
end

---@return love.Font
function Element:_getFont()
  return self._renderer:getFont(self)
end

-- ====================
-- Input Handling - Mouse Selection
-- ====================

--- Handle mouse click on text (set cursor position or start selection)
---@param mouseX number -- Mouse X coordinate
---@param mouseY number -- Mouse Y coordinate
---@param clickCount number -- Number of clicks (1=single, 2=double, 3=triple)
function Element:_handleTextClick(mouseX, mouseY, clickCount)
  if self._textEditor then
    self._textEditor:handleTextClick(self, mouseX, mouseY, clickCount)
    -- Store mouse down position on element for drag tracking
    if clickCount == 1 then
      self._mouseDownPosition = self._textEditor:mouseToTextPosition(self, mouseX, mouseY)
    end
  end
end

--- Handle mouse drag for text selection
---@param mouseX number -- Mouse X coordinate
---@param mouseY number -- Mouse Y coordinate
function Element:_handleTextDrag(mouseX, mouseY)
  if self._textEditor then
    self._textEditor:handleTextDrag(self, mouseX, mouseY)
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
    self._textEditor:handleTextInput(self, text)
    self.text = self._textEditor:getText() -- Sync display text
    self._textEditor:updateAutoGrowHeight(self)
  end
end

--- Handle key press (special keys)
---@param key string -- Key name
---@param scancode string -- Scancode
---@param isrepeat boolean -- Whether this is a key repeat
function Element:keypressed(key, scancode, isrepeat)
  if self._textEditor then
    self._textEditor:handleKeyPress(self, key, scancode, isrepeat)
    self.text = self._textEditor:getText() -- Sync display text
    self._textEditor:updateAutoGrowHeight(self)
  end
end

-- ====================
-- Performance Monitoring
-- ====================

--- Get hierarchy depth of this element
---@return number depth Depth in the element tree (0 for root)
function Element:getHierarchyDepth()
  local depth = 0
  local current = self.parent
  while current do
    depth = depth + 1
    current = current.parent
  end
  return depth
end

--- Count total elements in this tree
---@return number count Total number of elements including this one and all descendants
function Element:countElements()
  local count = 1 -- Count self
  for _, child in ipairs(self.children) do
    count = count + child:countElements()
  end
  return count
end

function Element:_checkPerformanceWarnings()
  if not Element._Performance or not Element._Performance.warningsEnabled then
    return
  end

  -- Check hierarchy depth
  local depth = self:getHierarchyDepth()
  if depth >= 15 then
    Element._Performance:logWarning(
      string.format("hierarchy_depth_%s", self.id),
      "Element",
      string.format("Element hierarchy depth is %d levels for element '%s'", depth, self.id or "unnamed"),
      { depth = depth, elementId = self.id or "unnamed" },
      "Deep nesting can impact performance. Consider flattening the structure or using absolute positioning"
    )
  end

  -- Check total element count (only for root elements)
  if not self.parent then
    local totalElements = self:countElements()
    if totalElements >= 1000 then
      Element._Performance:logWarning(
        "element_count_high",
        "Element",
        string.format("UI contains %d+ elements", totalElements),
        { elementCount = totalElements },
        "Large element counts may impact performance. Consider virtualization for long lists or pagination for large datasets"
      )
    end
  end
end

--- Count active animations in tree
---@return number count Number of active animations
function Element:_countActiveAnimations()
  local count = self.animation and 1 or 0
  for _, child in ipairs(self.children) do
    count = count + child:_countActiveAnimations()
  end
  return count
end

--- Track active animations and warn if too many
function Element:_trackActiveAnimations()
  -- Get Performance instance from deps if available
  if not Element._Performance or not Element._Performance.warningsEnabled then
    return
  end

  local animCount = self:_countActiveAnimations()
  if animCount >= 50 then
    Element._Performance:logWarning(
      "animation_count_high",
      "Element",
      string.format("%d+ animations running simultaneously", animCount),
      { animationCount = animCount },
      "High animation counts may impact frame rate. Consider reducing concurrent animations or using CSS-style transitions"
    )
  end
end

--- Change the tint color of an image element dynamically for hover effects or state indication
--- Use this to recolor images without replacing the asset, like highlighting selected items
---@param color Color Color to tint the image
function Element:setImageTint(color)
  self.imageTint = color
  if self._renderer then
    self._renderer.imageTint = color
  end
end

--- Adjust image transparency independently from the element for fade effects
--- Use this to create image-specific fade animations or disabled states
---@param opacity number Opacity 0-1
function Element:setImageOpacity(opacity)
  if opacity ~= nil then
    Element._utils.validateRange(opacity, 0, 1, "imageOpacity")
  end
  self.imageOpacity = opacity
  if self._renderer then
    self._renderer.imageOpacity = opacity
  end
end

--- Set image repeat mode
---@param repeatMode string Repeat mode: "no-repeat", "repeat", "repeat-x", "repeat-y", "space", "round"
function Element:setImageRepeat(repeatMode)
  local validImageRepeat = {
    ["no-repeat"] = "no-repeat",
    ["repeat"] = "repeat",
    ["repeat-x"] = "repeat-x",
    ["repeat-y"] = "repeat-y",
    space = "space",
    round = "round",
  }
  Element._utils.validateEnum(repeatMode, validImageRepeat, "imageRepeat")
  self.imageRepeat = repeatMode
  if self._renderer then
    self._renderer.imageRepeat = repeatMode
  end
end

--- Apply rotation transform to create spinning animations or rotated layouts
--- Use this for loading spinners, compass needles, or angled UI elements
---@param angle number Angle in radians
function Element:rotate(angle)
  if not self.transform then
    self.transform = Element._Transform.new({})
  end
  self.transform.rotate = angle
end

--- Resize element visually using scale transforms for zoom effects
--- Use this for hover magnification, shrinking animations, or responsive scaling
---@param scaleX number X-axis scale
---@param scaleY number? Y-axis scale (defaults to scaleX)
function Element:scale(scaleX, scaleY)
  if not self.transform then
    self.transform = Element._Transform.new({})
  end
  self.transform.scaleX = scaleX
  self.transform.scaleY = scaleY or scaleX
end

--- Offset element position using transforms for smooth movement without layout recalculation
--- Use this for parallax effects, draggable elements, or position animations
---@param x number X translation
---@param y number Y translation
function Element:translate(x, y)
  if not self.transform then
    self.transform = Element._Transform.new({})
  end
  self.transform.translateX = x
  self.transform.translateY = y
end

--- Define the pivot point for rotation and scaling transforms
--- Use this to rotate around corners, edges, or custom points rather than the center
---@param originX number X origin (0-1, where 0.5 is center)
---@param originY number Y origin (0-1, where 0.5 is center)
function Element:setTransformOrigin(originX, originY)
  if not self.transform then
    self.transform = Element._Transform.new({})
  end
  self.transform.originX = originX
  self.transform.originY = originY
end

--- Set transition configuration for a property
---@param property string Property name or "all" for all properties
---@param config table Transition config {duration, easing, delay, onComplete}
function Element:setTransition(property, config)
  if not self.transitions then
    self.transitions = {}
  end

  if type(config) ~= "table" then
    Element._ErrorHandler:warn("Element", "ELEM_003")
    config = {}
  end

  -- Validate config
  if config.duration and (type(config.duration) ~= "number" or config.duration < 0) then
    Element._ErrorHandler:warn("Element", "ELEM_004", {
      value = tostring(config.duration),
    })
    config.duration = 0.3
  end

  self.transitions[property] = {
    duration = config.duration or 0.3,
    easing = config.easing or "easeOutQuad",
    delay = config.delay or 0,
    onComplete = config.onComplete,
  }
end

--- Set transition configuration for multiple properties
---@param groupName string Name for this transition group
---@param config table Transition config {duration, easing, delay, onComplete}
---@param properties table Array of property names
function Element:setTransitionGroup(groupName, config, properties)
  if type(properties) ~= "table" then
    Element._ErrorHandler:warn("Element", "ELEM_005")
    return
  end

  for _, prop in ipairs(properties) do
    self:setTransition(prop, config)
  end
end

--- Remove transition configuration for a property
---@param property string Property name or "all" to remove all
function Element:removeTransition(property)
  if not self.transitions then
    return
  end

  if property == "all" then
    self.transitions = {}
  else
    self.transitions[property] = nil
  end
end

--- Set property with automatic transition
---@param property string Property name
---@param value any New value
function Element:setProperty(property, value)
  -- Check if transitions are enabled for this property
  local shouldTransition = false
  local transitionConfig = nil

  if self.transitions then
    transitionConfig = self.transitions[property] or self.transitions["all"]
    shouldTransition = transitionConfig ~= nil
  end

  -- Don't transition if value is the same
  if self[property] == value then
    return
  end

  if shouldTransition and transitionConfig then
    local currentValue = self[property]

    -- Only transition if we have a valid current value
    if currentValue ~= nil then
      -- Create animation for the property change
      local Animation = require("modules.Animation")
      local anim = Animation.new({
        duration = transitionConfig.duration,
        start = { [property] = currentValue },
        final = { [property] = value },
        easing = transitionConfig.easing,
        onComplete = transitionConfig.onComplete,
      })

      anim:apply(self)
    else
      self[property] = value
    end
  else
    self[property] = value
  end
end

-- ====================
-- State Persistence
-- ====================

--- Save all element state for immediate mode persistence
--- Collects state from all sub-modules and returns consolidated state
---@return ElementStateData state Complete state snapshot
function Element:saveState()
  local state = {}
  if self._eventHandler then
    state.eventHandler = self._eventHandler:getState()
  end
  if self._textEditor then
    state.textEditor = self._textEditor:getState()
  end
  if self._scrollManager then
    state.scrollManager = self._scrollManager:getState()
  end
  if self.backdropBlur or self.contentBlur then
    state.blur = {
      _blurX = self.x,
      _blurY = self.y,
      _blurWidth = self._borderBoxWidth or (self.width + self.padding.left + self.padding.right),
      _blurHeight = self._borderBoxHeight or (self.height + self.padding.top + self.padding.bottom),
    }

    if self.backdropBlur then
      state.blur._backdropBlurIntensity = self.backdropBlur.intensity
      state.blur._backdropBlurQuality = self.backdropBlur.quality
    end

    if self.contentBlur then
      state.blur._contentBlurIntensity = self.contentBlur.intensity
      state.blur._contentBlurQuality = self.contentBlur.quality
    end
  end

  return state
end

--- Restore all element state from StateManager
--- Distributes state to all sub-modules
---@param state ElementStateData State to restore
function Element:restoreState(state)
  if not state then
    return
  end

  -- Restore EventHandler state (if exists)
  if self._eventHandler and state.eventHandler then
    self._eventHandler:setState(state.eventHandler)
  end

  -- Restore TextEditor state (if exists)
  if self._textEditor and state.textEditor then
    self._textEditor:setState(state.textEditor, self)
    -- Sync TextEditor's focus state to Element for theme management
    self._focused = self._textEditor._focused
    self._cursorPosition = self._textEditor._cursorPosition
    self._selectionStart = self._textEditor._selectionStart
    self._selectionEnd = self._textEditor._selectionEnd
    self._textBuffer = self._textEditor._textBuffer
  end

  -- Restore ScrollManager state (if exists)
  if self._scrollManager and state.scrollManager then
    self._scrollManager:setState(state.scrollManager)
  end

  -- Note: Blur cache data is used for invalidation, not restoration
end

--- Check if blur cache should be invalidated based on state changes
---@param oldState ElementStateData? Previous state
---@param newState ElementStateData Current state
---@return boolean shouldInvalidate True if blur cache should be cleared
function Element:shouldInvalidateBlurCache(oldState, newState)
  if not oldState or not oldState.blur or not newState.blur then
    return false
  end

  local old = oldState.blur
  local new = newState.blur

  -- Check if any blur-related property changed
  return old._blurX ~= new._blurX
    or old._blurY ~= new._blurY
    or old._blurWidth ~= new._blurWidth
    or old._blurHeight ~= new._blurHeight
    or old._backdropBlurIntensity ~= new._backdropBlurIntensity
    or old._backdropBlurQuality ~= new._backdropBlurQuality
    or old._contentBlurIntensity ~= new._contentBlurIntensity
    or old._contentBlurQuality ~= new._contentBlurQuality
end

--- Cleanup method to break circular references (for immediate mode)
--- Note: Cleans internal module state but keeps structure for inspection
function Element:_cleanup()
  -- Clear event callbacks (may hold closures)
  self.onEvent = nil
  self.onFocus = nil
  self.onBlur = nil
  self.onTextInput = nil
  self.onTextChange = nil
  self.onEnter = nil
  self.onImageLoad = nil
  self.onImageError = nil
end

return Element
