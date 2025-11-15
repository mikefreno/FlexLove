# Animation

## __index


```lua
Animation
```

## _resultDirty


```lua
boolean
```

## apply


```lua
(method) Animation:apply(element: Element)
```

## duration


```lua
number
```

## elapsed


```lua
number
```

## fade


```lua
function Animation.fade(duration: number, fromOpacity: number, toOpacity: number)
  -> Animation
```

 Create a simple fade animation

## final


```lua
{ width: number?, height: number?, opacity: number? }
```

## interpolate


```lua
(method) Animation:interpolate()
  -> table
```

## new


```lua
function Animation.new(props: AnimationProps)
  -> Animation
```

## scale


```lua
function Animation.scale(duration: number, fromScale: table, toScale: table)
  -> Animation
```

 Create a simple scale animation

@*param* `fromScale` — {width:number,height:number}

@*param* `toScale` — {width:number,height:number}

## start


```lua
{ width: number?, height: number?, opacity: number? }
```

## transform


```lua
table?
```

## transition


```lua
table?
```

## update


```lua
(method) Animation:update(dt: number)
  -> boolean
```


---

# AnimationProps

## duration


```lua
number
```

## final


```lua
{ width: number, height: number, opacity: number }
```

## start


```lua
{ width: number, height: number, opacity: number }
```

## transform


```lua
table?
```

## transition


```lua
table?
```


---

# Border

## bottom


```lua
boolean
```

## left


```lua
boolean
```

## right


```lua
boolean
```

## top


```lua
boolean
```


---

# Color

## __index


```lua
Color
```

 Utility class for color handling

## a


```lua
number
```

Alpha component (0-1)

## b


```lua
number
```

Blue component (0-1)

## fromHex


```lua
function Color.fromHex(hexWithTag: string)
  -> Color
```

 Convert hex string to color
 Supports both 6-digit (#RRGGBB) and 8-digit (#RRGGBBAA) hex formats

@*param* `hexWithTag` — e.g. "#RRGGBB" or "#RRGGBBAA"

## g


```lua
number
```

Green component (0-1)

## isValidColorFormat


```lua
function Color.isValidColorFormat(value: any)
  -> format: string?
```

 Check if a value is a valid color format

@*param* `value` — Value to check

@*return* `format` — Format type (hex, rgb, rgba, named, table, nil if invalid)

## new


```lua
function Color.new(r?: number, g?: number, b?: number, a?: number)
  -> Color
```

 Create a new color instance

## parse


```lua
function Color.parse(value: any)
  -> Color
```

 Parse a color from various formats

@*param* `value` — Color value (hex, named, table)

@*return* — Parsed color

## r


```lua
number
```

Red component (0-1)

## sanitizeColor


```lua
function Color.sanitizeColor(value: any, default?: Color)
  -> Color
```

 Sanitize a color value

@*param* `value` — Color value to sanitize

@*param* `default` — Default color if invalid

@*return* — Sanitized color

## toRGBA


```lua
(method) Color:toRGBA()
  -> r: number
  2. g: number
  3. b: number
  4. a: number
```

## validateColor


```lua
function Color.validateColor(value: any, options?: table)
  -> valid: boolean
  2. error: string?
```

 Validate a color value

@*param* `value` — Color value to validate

@*param* `options` — Validation options

@*return* `valid` — True if valid

@*return* `error` — Error message if invalid

## validateColorChannel


```lua
function Color.validateColorChannel(value: any, max?: number)
  -> valid: boolean
  2. clamped: number?
```

 Validate a single color channel value

@*param* `value` — Value to validate

@*param* `max` — Maximum value (255 for 0-255 range, 1 for 0-1 range)

@*return* `valid` — True if valid

@*return* `clamped` — Clamped value in 0-1 range

## validateHexColor


```lua
function Color.validateHexColor(hex: string)
  -> valid: boolean
  2. error: string?
```

 Validate hex color format

@*param* `hex` — Hex color string (with or without #)

@*return* `valid` — True if valid format

@*return* `error` — Error message if invalid

## validateNamedColor


```lua
function Color.validateNamedColor(name: string)
  -> valid: boolean
  2. error: string?
```

 Validate named color

@*param* `name` — Color name

@*return* `valid` — True if valid

@*return* `error` — Error message if invalid

## validateRGBColor


```lua
function Color.validateRGBColor(r: number, g: number, b: number, a?: number, max?: number)
  -> valid: boolean
  2. error: string?
```

 Validate RGB/RGBA color values

@*param* `r` — Red component

@*param* `g` — Green component

@*param* `b` — Blue component

@*param* `a` — Alpha component (optional)

@*param* `max` — Maximum value (255 or 1)

@*return* `valid` — True if valid

@*return* `error` — Error message if invalid


---

# Context

## clearFrameElements


```lua
function Context.clearFrameElements()
```

 Clear frame elements (called at start of each immediate mode frame)

## getScaleFactors


```lua
function Context.getScaleFactors()
  -> number
  2. number
```

 Get current scale factors

@*return* — scaleX, scaleY

## getTopElementAt


```lua
function Context.getTopElementAt(x: number, y: number)
  -> The: Element|nil
```

 Get the topmost element at a screen position

@*param* `x` — Screen X coordinate

@*param* `y` — Screen Y coordinate

@*return* `The` — topmost element at the position, or nil if none

## registerElement


```lua
function Context.registerElement(element: Element)
```

 Register an element in the z-index ordered tree (for immediate mode)

@*param* `element` — The element to register

## sortElementsByZIndex


```lua
function Context.sortElementsByZIndex()
```

 Sort elements by z-index (called after all elements are registered)


---

# Element

## __index


```lua
Element
```

## _blurInstance


```lua
table?
```

Internal: cached blur effect instance

## _borderBoxHeight


```lua
number?
```

Internal: cached border-box height

## _borderBoxWidth


```lua
number?
```

Internal: cached border-box width

## _calculateScrollbarDimensions


```lua
(method) Element:_calculateScrollbarDimensions()
  -> table
```

 Calculate scrollbar dimensions and positions (delegates to ScrollManager)

@*return* — {vertical: {visible, trackHeight, thumbHeight, thumbY}, horizontal: {visible, trackWidth, thumbWidth, thumbX}}

## _contentHeight


```lua
number?
```

Internal: total content height

## _contentWidth


```lua
number?
```

Internal: total content width

## _cursorBlinkPauseTimer


```lua
number?
```

Internal: timer for how long cursor blink has been paused

## _cursorBlinkPaused


```lua
boolean?
```

Internal: whether cursor blink is paused (e.g., while typing)

## _cursorBlinkTimer


```lua
number?
```

Internal: cursor blink timer

## _cursorColumn


```lua
number?
```

Internal: cursor column within line

## _cursorLine


```lua
number?
```

Internal: cursor line number (1-based)

## _cursorPosition


```lua
number?
```

Internal: cursor character position (0-based)

## _cursorVisible


```lua
boolean?
```

Internal: cursor visibility state

## _detectOverflow


```lua
(method) Element:_detectOverflow()
```

 Detect if content overflows container bounds (delegates to ScrollManager)

## _eventHandler


```lua
EventHandler
```

Event handler instance for input processing

## _explicitlyAbsolute


```lua
boolean?
```

## _focused


```lua
boolean?
```

Internal: focus state

## _getFont


```lua
(method) Element:_getFont()
  -> love.Font
```

## _getScrollbarAtPosition


```lua
(method) Element:_getScrollbarAtPosition(mouseX: number, mouseY: number)
  -> table|nil
```

 Get scrollbar at mouse position (delegates to ScrollManager)

@*return* — {component: "vertical"|"horizontal", region: "thumb"|"track"}

## _handleScrollbarDrag


```lua
(method) Element:_handleScrollbarDrag(mouseX: number, mouseY: number)
  -> boolean
```

 Handle scrollbar drag (delegates to ScrollManager)

@*return* — True if event was consumed

## _handleScrollbarPress


```lua
(method) Element:_handleScrollbarPress(mouseX: number, mouseY: number, button: number)
  -> boolean
```

 Handle scrollbar mouse press

@*return* — True if event was consumed

## _handleScrollbarRelease


```lua
(method) Element:_handleScrollbarRelease(button: number)
  -> boolean
```

 Handle scrollbar release (delegates to ScrollManager)

@*return* — True if event was consumed

## _handleTextClick


```lua
(method) Element:_handleTextClick(mouseX: number, mouseY: number, clickCount: number)
```

 Handle mouse click on text (set cursor position or start selection)

@*param* `mouseX` — Mouse X coordinate

@*param* `mouseY` — Mouse Y coordinate

@*param* `clickCount` — Number of clicks (1=single, 2=double, 3=triple)

## _handleTextDrag


```lua
(method) Element:_handleTextDrag(mouseX: number, mouseY: number)
```

 Handle mouse drag for text selection

@*param* `mouseX` — Mouse X coordinate

@*param* `mouseY` — Mouse Y coordinate

## _handleWheelScroll


```lua
(method) Element:_handleWheelScroll(x: number, y: number)
  -> boolean
```

 Handle mouse wheel scrolling (delegates to ScrollManager)

@*param* `x` — Horizontal scroll amount

@*param* `y` — Vertical scroll amount

@*return* — True if scroll was handled

## _hoveredScrollbar


```lua
table?
```

Internal: currently hovered scrollbar info

## _layoutEngine


```lua
LayoutEngine
```

Internal: LayoutEngine instance for layout calculations

## _lines


```lua
table?
```

Internal: split lines for multi-line text

## _loadedImage


```lua
(love.Image)?
```

Internal: cached loaded image

## _maxScrollX


```lua
number?
```

Internal: maximum horizontal scroll

## _maxScrollY


```lua
number?
```

Internal: maximum vertical scroll

## _mouseDownPosition


```lua
number?
```

Internal: mouse down position for drag tracking

## _originalPositioning


```lua
Positioning?
```

Original positioning value set by user

## _overflowX


```lua
boolean?
```

Internal: whether content overflows horizontally

## _overflowY


```lua
boolean?
```

Internal: whether content overflows vertically

## _pressed


```lua
table?
```

Internal: button press state tracking

## _renderer


```lua
Renderer
```

Internal: Renderer instance for visual rendering

## _scrollManager


```lua
ScrollManager?
```

Internal: ScrollManager instance for scroll handling

## _scrollX


```lua
number?
```

Internal: horizontal scroll position

## _scrollY


```lua
number?
```

Internal: vertical scroll position

## _scrollbarDragOffset


```lua
number?
```

Internal: scrollbar drag offset

## _scrollbarDragging


```lua
boolean?
```

Internal: scrollbar dragging state

## _scrollbarHoveredHorizontal


```lua
boolean?
```

Internal: horizontal scrollbar hover state

## _scrollbarHoveredVertical


```lua
boolean?
```

Internal: vertical scrollbar hover state

## _scrollbarPressHandled


```lua
boolean?
```

Internal: scrollbar press handled flag

## _selectionAnchor


```lua
number?
```

Internal: selection anchor point

## _selectionEnd


```lua
number?
```

Internal: selection end position

## _selectionStart


```lua
number?
```

Internal: selection start position

## _stateId


```lua
string?
```

State manager ID for this element

## _syncScrollManagerState


```lua
(method) Element:_syncScrollManagerState()
```

 Sync ScrollManager state to Element properties for backward compatibility
 This ensures Renderer and StateManager can access scroll state from Element

## _textBuffer


```lua
string?
```

Internal: text buffer for editable elements

## _textDirty


```lua
boolean?
```

Internal: flag to recalculate lines/wrapping

## _textDragOccurred


```lua
boolean?
```

Internal: whether text drag occurred

## _textEditor


```lua
TextEditor?
```

Internal: TextEditor instance for editable elements

## _themeManager


```lua
ThemeManager
```

Internal: theme manager instance

## _themeState


```lua
string?
```

Current theme state (normal, hover, pressed, active, disabled)

## _wrapLine


```lua
(method) Element:_wrapLine(line: string, maxWidth: number)
  -> table
```

 Wrap a single line of text

@*param* `line` — Line to wrap

@*param* `maxWidth` — Maximum width in pixels

@*return* — Array of wrapped line parts

## _wrappedLines


```lua
table?
```

Internal: wrapped line data

## active


```lua
boolean?
```

Whether the element is active/focused (for inputs, default: false)

## addChild


```lua
(method) Element:addChild(child: Element)
```

 Add child to element

## alignContent


```lua
AlignContent
```

Alignment of lines in multi-line flex containers (default: STRETCH)

## alignItems


```lua
AlignItems
```

Alignment of items along cross axis (default: STRETCH)

## alignSelf


```lua
AlignSelf
```

Alignment of the item itself along cross axis (default: AUTO)

## animation


```lua
table?
```

Animation instance for this element

## applyPositioningOffsets


```lua
(method) Element:applyPositioningOffsets(element: any)
```

 Apply positioning offsets (top, right, bottom, left) to an element
 @param element The element to apply offsets to

## autoGrow


```lua
boolean
```

Whether element auto-grows with text (default: false)

## autoScaleText


```lua
boolean
```

Whether text should auto-scale with window size (default: true)

## autosizing


```lua
{ width: boolean, height: boolean }
```

Whether the element should automatically size to fit its children

## backdropBlur


```lua
{ intensity: number, quality: number }?
```

Blur content behind the element (intensity: 0-100, quality: 1-10)

## backgroundColor


```lua
Color
```

Background color of the element

## blur


```lua
(method) Element:blur()
```

 Remove focus from this element

## border


```lua
Border
```

Border configuration for the element

## borderColor


```lua
Color
```

Color of the border

## bottom


```lua
number?
```

Offset from bottom edge (CSS-style positioning)

## calculateAutoHeight


```lua
(method) Element:calculateAutoHeight()
  -> number
```

 Calculate auto height based on children

## calculateAutoWidth


```lua
(method) Element:calculateAutoWidth()
  -> number
```

## calculateTextHeight


```lua
(method) Element:calculateTextHeight()
  -> number
```

## calculateTextWidth


```lua
(method) Element:calculateTextWidth()
  -> number
```

 Calculate text width for button

## children


```lua
table<integer, Element>
```

Children of this element

## clearChildren


```lua
(method) Element:clearChildren()
```

 Remove all children from this element

## clearSelection


```lua
(method) Element:clearSelection()
```

 Clear selection

## columnGap


```lua
(string|number)?
```

Gap between grid columns

## contains


```lua
(method) Element:contains(x: number, y: number)
  -> boolean
```

 Check if point is inside element bounds

## contentAutoSizingMultiplier


```lua
{ width: number?, height: number? }?
```

Multiplier for auto-sized content dimensions

## contentBlur


```lua
{ intensity: number, quality: number }?
```

Blur the element's content including children (intensity: 0-100, quality: 1-10)

## cornerRadius


```lua
(number|{ topLeft: number?, topRight: number?, bottomLeft: number?, bottomRight: number? })?
```

Corner radius for rounded corners (default: 0)

## cursorBlinkRate


```lua
number
```

Cursor blink rate in seconds (default: 0.5)

## cursorColor


```lua
Color?
```

Cursor color (default: nil, uses textColor)

## deleteSelection


```lua
(method) Element:deleteSelection()
  -> boolean
```

 Delete selected text

@*return* — True if text was deleted

## deleteText


```lua
(method) Element:deleteText(startPos: number, endPos: number)
```

@*param* `startPos` — Start position (inclusive)

@*param* `endPos` — End position (inclusive)

## destroy


```lua
(method) Element:destroy()
```

 Destroy element and its children

## disableHighlight


```lua
boolean?
```

Whether to disable the pressed state highlight overlay (default: false)

## disabled


```lua
boolean?
```

Whether the element is disabled (default: false)

## draw


```lua
(method) Element:draw(backdropCanvas: any)
```

 Draw element and its children

## editable


```lua
boolean
```

Whether the element is editable (default: false)

## flexDirection


```lua
FlexDirection
```

Direction of flex layout (default: HORIZONTAL)

## flexWrap


```lua
FlexWrap
```

Whether children wrap to multiple lines (default: NOWRAP)

## focus


```lua
(method) Element:focus()
```

 Focus this element for keyboard input

## fontFamily


```lua
string?
```

Font family name from theme or path to font file

## gap


```lua
string|number
```

Space between children elements (default: 10)

## getAvailableContentHeight


```lua
(method) Element:getAvailableContentHeight()
  -> number
```

 Get available content height for children (accounting for 9-patch content padding)
 This is the height that children should use when calculating percentage heights

## getAvailableContentWidth


```lua
(method) Element:getAvailableContentWidth()
  -> number
```

 Get available content width for children (accounting for 9-patch content padding)
 This is the width that children should use when calculating percentage widths

## getBlurInstance


```lua
(method) Element:getBlurInstance()
  -> table?
```

 Get or create blur instance for this element

@*return* — Blur instance or nil if no blur configured

## getBorderBoxHeight


```lua
(method) Element:getBorderBoxHeight()
  -> number
```

 Get border-box height (including padding)

## getBorderBoxWidth


```lua
(method) Element:getBorderBoxWidth()
  -> number
```

 Get border-box width (including padding)

## getBounds


```lua
(method) Element:getBounds()
  -> { x: number, y: number, width: number, height: number }
```

 Get element bounds (content box)

## getChildCount


```lua
(method) Element:getChildCount()
  -> number
```

 Get the number of children this element has

## getContentSize


```lua
(method) Element:getContentSize()
  -> contentWidth: number
  2. contentHeight: number
```

 Get content dimensions (including overflow) (delegates to ScrollManager)

## getCursorPosition


```lua
(method) Element:getCursorPosition()
  -> number
```

 Get cursor position

@*return* — Character index (0-based)

## getMaxScroll


```lua
(method) Element:getMaxScroll()
  -> maxScrollX: number
  2. maxScrollY: number
```

 Get maximum scroll bounds (delegates to ScrollManager)

## getScaledContentPadding


```lua
(method) Element:getScaledContentPadding()
  -> table|nil
```

 Get the current state's scaled content padding
 Returns the contentPadding for the current theme state, scaled to the element's size

@*return* — {left, top, right, bottom} or nil if no contentPadding

## getScrollPercentage


```lua
(method) Element:getScrollPercentage()
  -> percentX: number
  2. percentY: number
```

 Get scroll percentage (0-1) (delegates to ScrollManager)

## getScrollPosition


```lua
(method) Element:getScrollPosition()
  -> scrollX: number
  2. scrollY: number
```

 Get current scroll position (delegates to ScrollManager)

## getSelectedText


```lua
(method) Element:getSelectedText()
  -> string?
```

 Get selected text

@*return* — Selected text or nil if no selection

## getSelection


```lua
(method) Element:getSelection()
  -> number?
  2. number?
```

 Get selection range

@*return* — Start and end positions, or nil if no selection

## getText


```lua
(method) Element:getText()
  -> string
```

 Get current text buffer

## gridColumns


```lua
number?
```

Number of columns in the grid

## gridRows


```lua
number?
```

Number of rows in the grid

## hasOverflow


```lua
(method) Element:hasOverflow()
  -> hasOverflowX: boolean
  2. hasOverflowY: boolean
```

 Check if element has overflow (delegates to ScrollManager)

## hasSelection


```lua
(method) Element:hasSelection()
  -> boolean
```

 Check if there is an active selection

## height


```lua
string|number
```

Height of the element

## hide


```lua
(method) Element:hide()
```

 same as calling updateOpacity(0)

## hideScrollbars


```lua
(boolean|{ vertical: boolean, horizontal: boolean })?
```

Hide scrollbars (boolean for both, or table for individual control)

## id


```lua
string
```

## image


```lua
(love.Image)?
```

Image object to display

## imageOpacity


```lua
number?
```

Image opacity 0-1 (default: 1, combines with element opacity)

## imagePath


```lua
string?
```

Path to image file (auto-loads via ImageCache)

## inputType


```lua
"email"|"number"|"text"|"url"
```

Input type for validation (default: "text")

## insertText


```lua
(method) Element:insertText(text: string, position?: number)
```

 Insert text at position

@*param* `text` — Text to insert

@*param* `position` — Position to insert at (default: cursor position)

## isFocused


```lua
(method) Element:isFocused()
  -> boolean
```

 Check if this element is focused

## justifyContent


```lua
JustifyContent
```

Alignment of items along main axis (default: FLEX_START)

## justifySelf


```lua
JustifySelf
```

Alignment of the item itself along main axis (default: AUTO)

## keypressed


```lua
(method) Element:keypressed(key: string, scancode: string, isrepeat: boolean)
```

 Handle key press (special keys)

@*param* `key` — Key name

@*param* `scancode` — Scancode

@*param* `isrepeat` — Whether this is a key repeat

## layoutChildren


```lua
(method) Element:layoutChildren()
```

## left


```lua
number?
```

Offset from left edge (CSS-style positioning)

## margin


```lua
{ top: number, right: number, bottom: number, left: number }
```

Margin around children (default: {top=0, right=0, bottom=0, left=0})

## maxLength


```lua
number?
```

Maximum text length in characters (default: nil)

## maxLines


```lua
number?
```

Maximum number of lines (default: nil)

## maxTextSize


```lua
number?
```

## minTextSize


```lua
number?
```

## moveCursorBy


```lua
(method) Element:moveCursorBy(delta: number)
```

 Move cursor by delta characters

@*param* `delta` — Number of characters to move (positive or negative)

## moveCursorToEnd


```lua
(method) Element:moveCursorToEnd()
```

 Move cursor to end of text

## moveCursorToLineEnd


```lua
(method) Element:moveCursorToLineEnd()
```

 Move cursor to end of current line

## moveCursorToLineStart


```lua
(method) Element:moveCursorToLineStart()
```

 Move cursor to start of current line

## moveCursorToNextWord


```lua
(method) Element:moveCursorToNextWord()
```

 Move cursor to start of next word

## moveCursorToPreviousWord


```lua
(method) Element:moveCursorToPreviousWord()
```

 Move cursor to start of previous word

## moveCursorToStart


```lua
(method) Element:moveCursorToStart()
```

 Move cursor to start of text

## multiline


```lua
boolean
```

Whether the element supports multiple lines (default: false)

## new


```lua
function Element.new(props: ElementProps, deps: table)
  -> Element
```

@*param* `deps` — Required dependency table (provided by FlexLove)

## objectFit


```lua
("contain"|"cover"|"fill"|"none"|"scale-down")?
```

Image fit mode (default: "fill")

## objectPosition


```lua
string?
```

Image position like "center center", "top left", "50% 50%" (default: "center center")

## onBlur


```lua
fun(element: Element)?
```

Callback function when element loses focus

## onEnter


```lua
fun(element: Element)?
```

Callback function when Enter key is pressed

## onEvent


```lua
fun(element: Element, event: InputEvent)?
```

Callback function for interaction events

## onFocus


```lua
fun(element: Element)?
```

Callback function when element receives focus

## onTextChange


```lua
fun(element: Element, text: string)?
```

Callback function when text changes

## onTextInput


```lua
fun(element: Element, text: string)?
```

Callback function for text input

## opacity


```lua
number
```

## overflow


```lua
string?
```

Overflow behavior for both axes

## overflowX


```lua
string?
```

Overflow behavior for horizontal axis

## overflowY


```lua
string?
```

Overflow behavior for vertical axis

## padding


```lua
{ top: number, right: number, bottom: number, left: number }?
```

Padding around children (default: {top=0, right=0, bottom=0, left=0})

## parent


```lua
Element?
```

Parent element (nil if top-level)

## passwordMode


```lua
boolean
```

Whether to display text as password (default: false)

## placeholder


```lua
string?
```

Placeholder text when empty (default: nil)

## positioning


```lua
Positioning
```

Layout positioning mode (default: RELATIVE)

## prevGameSize


```lua
{ width: number, height: number }
```

Previous game size for resize calculations

## recalculateUnits


```lua
(method) Element:recalculateUnits(newViewportWidth: number, newViewportHeight: number)
```

## removeChild


```lua
(method) Element:removeChild(child: Element)
```

 Remove a specific child from this element

## replaceText


```lua
(method) Element:replaceText(startPos: number, endPos: number, newText: string)
```

 Replace text in range

@*param* `startPos` — Start position (inclusive)

@*param* `endPos` — End position (inclusive)

@*param* `newText` — Replacement text

## resize


```lua
(method) Element:resize(newGameWidth: number, newGameHeight: number)
```

 Resize element and its children based on game window size change

## right


```lua
number?
```

Offset from right edge (CSS-style positioning)

## rowGap


```lua
(string|number)?
```

Gap between grid rows

## scaleCorners


```lua
number?
```

Scale multiplier for 9-patch corners/edges. E.g., 2 = 2x size (overrides theme setting)

## scalingAlgorithm


```lua
("bilinear"|"nearest")?
```

Scaling algorithm for 9-patch corners: "nearest" (sharp/pixelated) or "bilinear" (smooth) (overrides theme setting)

## scrollBy


```lua
(method) Element:scrollBy(dx?: number, dy?: number)
```

 Scroll by delta amount (delegates to ScrollManager)

@*param* `dx` — X delta (nil for no change)

@*param* `dy` — Y delta (nil for no change)

## scrollSpeed


```lua
number?
```

Scroll speed multiplier

## scrollToBottom


```lua
(method) Element:scrollToBottom()
```

 Scroll to bottom

## scrollToLeft


```lua
(method) Element:scrollToLeft()
```

 Scroll to left

## scrollToRight


```lua
(method) Element:scrollToRight()
```

 Scroll to right

## scrollToTop


```lua
(method) Element:scrollToTop()
```

 Scroll to top

## scrollable


```lua
boolean
```

Whether text is scrollable (default: false for single-line, true for multi-line)

## scrollbarColor


```lua
Color?
```

Scrollbar thumb color

## scrollbarPadding


```lua
number?
```

Scrollbar padding from edges

## scrollbarRadius


```lua
number?
```

Scrollbar corner radius

## scrollbarTrackColor


```lua
Color?
```

Scrollbar track color

## scrollbarWidth


```lua
number?
```

Scrollbar width in pixels

## selectAll


```lua
(method) Element:selectAll()
```

 Select all text

## selectOnFocus


```lua
boolean
```

Whether to select all text on focus (default: false)

## selectionColor


```lua
Color?
```

Selection background color (default: nil, uses theme or default)

## setCursorPosition


```lua
(method) Element:setCursorPosition(position: number)
```

 Set cursor position

@*param* `position` — Character index (0-based)

## setScrollPosition


```lua
(method) Element:setScrollPosition(x?: number, y?: number)
```

 Set scroll position with bounds clamping (delegates to ScrollManager)

@*param* `x` — X scroll position (nil to keep current)

@*param* `y` — Y scroll position (nil to keep current)

## setSelection


```lua
(method) Element:setSelection(startPos: number, endPos: number)
```

 Set selection range

@*param* `startPos` — Start position (inclusive)

@*param* `endPos` — End position (inclusive)

## setText


```lua
(method) Element:setText(text: string)
```

 Set text buffer and mark dirty

## show


```lua
(method) Element:show()
```

 same as calling updateOpacity(1)

## text


```lua
string?
```

Text content to display in the element

## textAlign


```lua
TextAlign
```

Alignment of the text content

## textColor


```lua
Color
```

Color of the text content

## textOverflow


```lua
"clip"|"ellipsis"|"scroll"
```

Text overflow behavior (default: "clip")

## textSize


```lua
number?
```

Resolved font size for text content in pixels

## textWrap


```lua
boolean|"char"|"word"
```

Text wrapping mode (default: false for single-line, "word" for multi-line)

## textinput


```lua
(method) Element:textinput(text: string)
```

 Handle text input (character input)

@*param* `text` — Character(s) to insert

## theme


```lua
string?
```

Theme component to use for rendering

## themeComponent


```lua
string?
```

## top


```lua
number?
```

Offset from top edge (CSS-style positioning)

## transform


```lua
TransformProps
```

Transform properties for animations and styling

## transition


```lua
TransitionProps
```

Transition settings for animations

## units


```lua
table
```

Original unit specifications for responsive behavior

## update


```lua
(method) Element:update(dt: number)
```

 Update element (propagate to children)

## updateOpacity


```lua
(method) Element:updateOpacity(newOpacity: number)
```

## updateText


```lua
(method) Element:updateText(newText: string, autoresize?: boolean)
```

@*param* `autoresize` — default: false

## userdata


```lua
table?
```

## width


```lua
string|number
```

Width of the element

## x


```lua
string|number
```

X coordinate of the element

## y


```lua
string|number
```

Y coordinate of the element

## z


```lua
number
```

Z-index for layering (default: 0)


---

# ElementProps

## _scrollX


```lua
number?
```

Internal: scroll X position (restored in immediate mode)

## _scrollY


```lua
number?
```

Internal: scroll Y position (restored in immediate mode)

## active


```lua
boolean?
```

Whether the element is active/focused (for inputs, default: false)

## alignContent


```lua
AlignContent?
```

Alignment of lines in multi-line flex containers (default: STRETCH)

## alignItems


```lua
AlignItems?
```

Alignment of items along cross axis (default: STRETCH)

## alignSelf


```lua
AlignSelf?
```

Alignment of the item itself along cross axis (default: AUTO)

## autoGrow


```lua
boolean?
```

Whether element auto-grows with text (default: false for single-line, true for multi-line)

## autoScaleText


```lua
boolean?
```

Whether text should auto-scale with window size (default: true)

## backdropBlur


```lua
{ intensity: number, quality: number }?
```

Blur content behind the element (intensity: 0-100, quality: 1-10, default: nil)

## backgroundColor


```lua
Color?
```

Background color (default: transparent)

## border


```lua
Border?
```

Border configuration for the element

## borderColor


```lua
Color?
```

Color of the border (default: black)

## bottom


```lua
(string|number)?
```

Offset from bottom edge (CSS-style positioning)

## columnGap


```lua
(string|number)?
```

Gap between grid columns (default: 0)

## contentAutoSizingMultiplier


```lua
{ width: number?, height: number? }?
```

Multiplier for auto-sized content dimensions (default: sourced from theme or {1, 1})

## contentBlur


```lua
{ intensity: number, quality: number }?
```

Blur the element's content including children (intensity: 0-100, quality: 1-10, default: nil)

## cornerRadius


```lua
(number|{ topLeft: number?, topRight: number?, bottomLeft: number?, bottomRight: number? })?
```

Corner radius: number (all corners) or table for individual corners (default: 0)

## cursorBlinkRate


```lua
number?
```

Cursor blink rate in seconds (default: 0.5)

## cursorColor


```lua
Color?
```

Cursor color (default: nil, uses textColor)

## disableHighlight


```lua
boolean?
```

Whether to disable the pressed state highlight overlay (default: false, or true when using themeComponent)

## disabled


```lua
boolean?
```

Whether the element is disabled (default: false)

## editable


```lua
boolean?
```

Whether the element is editable (default: false)

## flexDirection


```lua
FlexDirection?
```

Direction of flex layout: "horizontal"|"vertical" (default: HORIZONTAL)

## flexWrap


```lua
FlexWrap?
```

Whether children wrap to multiple lines: "nowrap"|"wrap"|"wrap-reverse" (default: NOWRAP)

## fontFamily


```lua
string?
```

Font family name from theme or path to font file (default: theme default or system default, inherits from parent)

## gap


```lua
(string|number)?
```

Space between children elements (default: 0)

## gridColumns


```lua
number?
```

Number of columns in the grid (default: 1)

## gridRows


```lua
number?
```

Number of rows in the grid (default: 1)

## height


```lua
(string|number)?
```

Height of the element (default: calculated automatically)

## hideScrollbars


```lua
(boolean|{ vertical: boolean, horizontal: boolean })?
```

Hide scrollbars (boolean for both, or table for individual control, default: false)

## id


```lua
string?
```

Unique identifier for the element (auto-generated in immediate mode if not provided)

## image


```lua
(love.Image)?
```

Image object to display

## imageOpacity


```lua
number?
```

Image opacity 0-1 (default: 1, combines with element opacity)

## imagePath


```lua
string?
```

Path to image file (auto-loads via ImageCache)

## inputType


```lua
("email"|"number"|"text"|"url")?
```

Input type for validation (default: "text")

## justifyContent


```lua
JustifyContent?
```

Alignment of items along main axis (default: FLEX_START)

## justifySelf


```lua
JustifySelf?
```

Alignment of the item itself along main axis (default: AUTO)

## left


```lua
(string|number)?
```

Offset from left edge (CSS-style positioning)

## margin


```lua
{ top: (string|number)?, right: (string|number)?, bottom: (string|number)?, left: (string|number)?, horizontal: (string|number)?, vertical: (string|number)? }?
```

Margin around element (default: {top=0, right=0, bottom=0, left=0})

## maxLength


```lua
number?
```

Maximum text length in characters (default: nil)

## maxLines


```lua
number?
```

Maximum number of lines (default: nil)

## maxTextSize


```lua
number?
```

Maximum text size in pixels for auto-scaling

## minTextSize


```lua
number?
```

Minimum text size in pixels for auto-scaling

## multiline


```lua
boolean?
```

Whether the element supports multiple lines (default: false)

## objectFit


```lua
("contain"|"cover"|"fill"|"none"|"scale-down")?
```

Image fit mode (default: "fill")

## objectPosition


```lua
string?
```

Image position like "center center", "top left", "50% 50%" (default: "center center")

## onBlur


```lua
fun(element: Element, event: InputEvent)?
```

Callback when element loses focus

## onEnter


```lua
fun(element: Element)?
```

Callback when Enter key is pressed

## onEvent


```lua
fun(element: Element, event: InputEvent)?
```

Callback function for interaction events

## onFocus


```lua
fun(element: Element, event: InputEvent)?
```

Callback when element receives focus

## onTextChange


```lua
fun(element: Element, text: string)?
```

Callback when text content changes

## onTextInput


```lua
fun(element: Element, text: string)?
```

Callback when text is input

## opacity


```lua
number?
```

Element opacity 0-1 (default: 1)

## overflow


```lua
("auto"|"hidden"|"scroll"|"visible")?
```

Overflow behavior (default: "hidden")

## overflowX


```lua
("auto"|"hidden"|"scroll"|"visible")?
```

X-axis overflow (overrides overflow)

## overflowY


```lua
("auto"|"hidden"|"scroll"|"visible")?
```

Y-axis overflow (overrides overflow)

## padding


```lua
{ top: (string|number)?, right: (string|number)?, bottom: (string|number)?, left: (string|number)?, horizontal: (string|number)?, vertical: (string|number)? }?
```

Padding around children (default: {top=0, right=0, bottom=0, left=0})

## parent


```lua
Element?
```

Parent element for hierarchical structure

## passwordMode


```lua
boolean?
```

Whether to display text as password (default: false, disables multiline)

## placeholder


```lua
string?
```

Placeholder text when empty (default: nil)

## positioning


```lua
Positioning?
```

Layout positioning mode: "absolute"|"relative"|"flex"|"grid" (default: RELATIVE)

## right


```lua
(string|number)?
```

Offset from right edge (CSS-style positioning)

## rowGap


```lua
(string|number)?
```

Gap between grid rows (default: 0)

## scaleCorners


```lua
number?
```

Scale multiplier for 9-patch corners/edges. E.g., 2 = 2x size (overrides theme setting)

## scalingAlgorithm


```lua
("bilinear"|"nearest")?
```

Scaling algorithm for 9-patch corners: "nearest" (sharp/pixelated) or "bilinear" (smooth) (overrides theme setting)

## scrollSpeed


```lua
number?
```

Pixels per wheel notch (default: 20)

## scrollable


```lua
boolean?
```

Whether text is scrollable (default: false for single-line, true for multi-line)

## scrollbarColor


```lua
Color?
```

Scrollbar thumb color (default: Color.new(0.5, 0.5, 0.5, 0.8))

## scrollbarPadding


```lua
number?
```

Padding between scrollbar and edge (default: 2)

## scrollbarRadius


```lua
number?
```

Corner radius for scrollbar (default: 6)

## scrollbarTrackColor


```lua
Color?
```

Scrollbar track color (default: Color.new(0.2, 0.2, 0.2, 0.5))

## scrollbarWidth


```lua
number?
```

Width of scrollbar track in pixels (default: 12)

## selectOnFocus


```lua
boolean?
```

Whether to select all text on focus (default: false)

## selectionColor


```lua
Color?
```

Selection background color (default: nil, uses theme or default)

## text


```lua
string?
```

Text content to display (default: nil)

## textAlign


```lua
TextAlign?
```

Alignment of the text content (default: START)

## textColor


```lua
Color?
```

Color of the text content (default: black or theme text color)

## textOverflow


```lua
("clip"|"ellipsis"|"scroll")?
```

Text overflow behavior (default: "clip")

## textSize


```lua
(string|number)?
```

Font size: number (px), string with units ("2vh", "10%"), or preset ("xxs"|"xs"|"sm"|"md"|"lg"|"xl"|"xxl"|"3xl"|"4xl") (default: "md" or 12px)

## textWrap


```lua
(boolean|"char"|"word")?
```

Text wrapping mode (default: false for single-line, "word" for multi-line)

## theme


```lua
string?
```

Theme name to use (e.g., "space", "metal"). Defaults to theme from flexlove.init()

## themeComponent


```lua
string?
```

Theme component to use (e.g., "panel", "button", "input"). If nil, no theme is applied

## top


```lua
(string|number)?
```

Offset from top edge (CSS-style positioning)

## transform


```lua
TransformProps?
```

Transform properties for animations and styling

## transition


```lua
TransitionProps?
```

Transition settings for animations

## userdata


```lua
table?
```

User-defined data storage for custom properties

## width


```lua
(string|number)?
```

Width of the element (default: calculated automatically)

## x


```lua
(string|number)?
```

X coordinate of the element (default: 0)

## y


```lua
(string|number)?
```

Y coordinate of the element (default: 0)

## z


```lua
number?
```

Z-index for layering (default: 0)


---

# ErrorCodes

## categories


```lua
table
```

 Error code categories

## codes


```lua
table
```

 Error code definitions

## describe


```lua
function ErrorCodes.describe(code: string)
  -> description: string
```

 Get human-readable description for error code

@*param* `code` — Error code

@*return* `description` — Error description

## formatMessage


```lua
function ErrorCodes.formatMessage(code: string, message: string)
  -> formattedMessage: string
```

 Format error message with code

@*param* `code` — Error code

@*param* `message` — Error message

@*return* `formattedMessage` — Formatted error message with code

## get


```lua
function ErrorCodes.get(code: string)
  -> errorInfo: table?
```

 Get error information by code

@*param* `code` — Error code (e.g., "VAL_001" or "FLEXLOVE_VAL_001")

@*return* `errorInfo` — Error information or nil if not found

## getCategory


```lua
function ErrorCodes.getCategory(code: string)
  -> category: string
```

 Get category for error code

@*param* `code` — Error code

@*return* `category` — Error category name

## getSuggestion


```lua
function ErrorCodes.getSuggestion(code: string)
  -> suggestion: string
```

 Get suggested fix for error code

@*param* `code` — Error code

@*return* `suggestion` — Suggested fix

## listAll


```lua
function ErrorCodes.listAll()
  -> codes: table
```

 Get all error codes

@*return* `codes` — All error codes

## listByCategory


```lua
function ErrorCodes.listByCategory(category: string)
  -> codes: table
```

 List all error codes in a category

@*param* `category` — Category code (e.g., "VAL", "LAY")

@*return* `codes` — List of error codes in category

## search


```lua
function ErrorCodes.search(keyword: string)
  -> codes: table
```

 Search error codes by keyword

@*param* `keyword` — Keyword to search for

@*return* `codes` — Matching error codes

## validate


```lua
function ErrorCodes.validate()
  -> boolean
  2. Returns: string?
```

 Validate that all error codes are unique and properly formatted

@*return* `Returns` — true if valid, or false with error message


---

# EventHandler

## _Context


```lua
table
```

## _InputEvent


```lua
table
```

## __index


```lua
EventHandler
```

## _clickCount


```lua
number
```

## _dragStartX


```lua
table<number, number>
```

## _dragStartY


```lua
table<number, number>
```

## _element


```lua
Element?
```

## _handleMouseDrag


```lua
(method) EventHandler:_handleMouseDrag(mx: number, my: number, button: number, isHovering: boolean)
```

 Handle mouse drag (while button is pressed and mouse moves)

@*param* `mx` — Mouse X position

@*param* `my` — Mouse Y position

@*param* `button` — Mouse button

@*param* `isHovering` — Whether mouse is over element

## _handleMousePress


```lua
(method) EventHandler:_handleMousePress(mx: number, my: number, button: number)
```

 Handle mouse button press

@*param* `mx` — Mouse X position

@*param* `my` — Mouse Y position

@*param* `button` — Mouse button (1=left, 2=right, 3=middle)

## _handleMouseRelease


```lua
(method) EventHandler:_handleMouseRelease(mx: number, my: number, button: number)
```

 Handle mouse button release

@*param* `mx` — Mouse X position

@*param* `my` — Mouse Y position

@*param* `button` — Mouse button

## _hovered


```lua
boolean
```

## _lastClickButton


```lua
number?
```

## _lastClickTime


```lua
number?
```

## _lastMouseX


```lua
table<number, number>
```

## _lastMouseY


```lua
table<number, number>
```

## _pressed


```lua
table<number, boolean>
```

## _scrollbarPressHandled


```lua
boolean
```

## _touchPressed


```lua
table<number, boolean>
```

## _utils


```lua
table
```

## getState


```lua
(method) EventHandler:getState()
  -> State: table
```

 Get state for persistence (for immediate mode)

@*return* `State` — data

## initialize


```lua
(method) EventHandler:initialize(element: Element)
```

 Initialize EventHandler with parent element reference

@*param* `element` — The parent element

## isAnyButtonPressed


```lua
(method) EventHandler:isAnyButtonPressed()
  -> True: boolean
```

 Check if any mouse button is pressed

@*return* `True` — if any button is pressed

## isButtonPressed


```lua
(method) EventHandler:isButtonPressed(button: number)
  -> True: boolean
```

 Check if a specific button is pressed

@*param* `button` — Mouse button (1=left, 2=right, 3=middle)

@*return* `True` — if button is pressed

## new


```lua
function EventHandler.new(config: table, deps: table)
  -> EventHandler
```

 Create a new EventHandler instance

@*param* `config` — Configuration options

@*param* `deps` — Dependencies {InputEvent, Context, utils}

## onEvent


```lua
fun(element: Element, event: InputEvent)?
```

## processMouseEvents


```lua
(method) EventHandler:processMouseEvents(mx: number, my: number, isHovering: boolean, isActiveElement: boolean)
```

 Process mouse button events in the update cycle

@*param* `mx` — Mouse X position

@*param* `my` — Mouse Y position

@*param* `isHovering` — Whether mouse is over element

@*param* `isActiveElement` — Whether this is the top element at mouse position

## processTouchEvents


```lua
(method) EventHandler:processTouchEvents()
```

 Process touch events in the update cycle

## resetScrollbarPressFlag


```lua
(method) EventHandler:resetScrollbarPressFlag()
```

 Reset scrollbar press flag (called each frame)

## setState


```lua
(method) EventHandler:setState(state: table)
```

 Restore state from persistence (for immediate mode)

@*param* `state` — State data


---

# FlexLove

## Animation


```lua
Animation
```

## Color


```lua
Color
```

 Utility class for color handling

## Theme


```lua
Theme
```

## _DESCRIPTION


```lua
string
```

## _LICENSE


```lua
string
```

## _URL


```lua
string
```

## _VERSION


```lua
string
```

 Add version and metadata

## _activeEventElement


```lua
Element?
```

## _autoBeganFrame


```lua
boolean
```

## _autoFrameManagement


```lua
boolean
```

## _backdropCanvas


```lua
nil
```


A Canvas is used for off-screen rendering. Think of it as an invisible screen that you can draw to, but that will not be visible until you draw it to the actual visible screen. It is also known as "render to texture".

By drawing things that do not change position often (such as background items) to the Canvas, and then drawing the entire Canvas instead of each item,  you can reduce the number of draw operations performed each frame.

In versions prior to love.graphics.isSupported("canvas") could be used to check for support at runtime.


[Open in Browser](https://love2d.org/wiki/love.graphics)


## _cachedViewport


```lua
table
```

## _canvasDimensions


```lua
table
```

## _currentFrameElements


```lua
table
```

## _focusedElement


```lua
nil
```

## _frameNumber


```lua
integer
```

## _frameStarted


```lua
boolean
```

## _gameCanvas


```lua
nil
```


A Canvas is used for off-screen rendering. Think of it as an invisible screen that you can draw to, but that will not be visible until you draw it to the actual visible screen. It is also known as "render to texture".

By drawing things that do not change position often (such as background items) to the Canvas, and then drawing the entire Canvas instead of each item,  you can reduce the number of draw operations performed each frame.

In versions prior to love.graphics.isSupported("canvas") could be used to check for support at runtime.


[Open in Browser](https://love2d.org/wiki/love.graphics)


## _immediateMode


```lua
boolean
```

## _immediateModeState


```lua
unknown
```

## baseScale


```lua
table
```

## beginFrame


```lua
function FlexLove.beginFrame()
```

 Begin a new immediate mode frame

## clearAllStates


```lua
function FlexLove.clearAllStates()
```

 Clear all immediate mode states

## clearState


```lua
function FlexLove.clearState(id: string)
```

 Clear state for a specific element ID

## defaultTheme


```lua
(string|ThemeDefinition)?
```

## destroy


```lua
function FlexLove.destroy()
```

## draw


```lua
function FlexLove.draw(gameDrawFunc: function|nil, postDrawFunc: function|nil)
```

## endFrame


```lua
function FlexLove.endFrame()
```

## enums


```lua
unknown
```

## getElementAtPosition


```lua
function FlexLove.getElementAtPosition(x: number, y: number)
  -> Element?
```

 Find the topmost element at given coordinates

## getMode


```lua
function FlexLove.getMode()
  -> "immediate"|"retained"
```

```lua
return #1:
    | "immediate"
    | "retained"
```

## getStateCount


```lua
function FlexLove.getStateCount()
  -> number
```

## getStateStats


```lua
function FlexLove.getStateStats()
  -> table
```

 Get state statistics (for debugging)

## init


```lua
function FlexLove.init(config: { baseScale: { width: number?, height: number? }?, theme: (string|ThemeDefinition)?, immediateMode: boolean?, stateRetentionFrames: number?, maxStateEntries: number?, autoFrameManagement: boolean? })
```

## keypressed


```lua
function FlexLove.keypressed(key: string, scancode: string, isrepeat: boolean)
```

## new


```lua
function FlexLove.new(props: ElementProps)
  -> Element
```

## resize


```lua
function FlexLove.resize()
```

## scaleFactors


```lua
table
```

## setMode


```lua
function FlexLove.setMode(mode: "immediate"|"retained")
```

```lua
mode:
    | "immediate"
    | "retained"
```

## textinput


```lua
function FlexLove.textinput(text: string)
```

## topElements


```lua
table
```

## update


```lua
function FlexLove.update(dt: any)
```

## wheelmoved


```lua
function FlexLove.wheelmoved(dx: any, dy: any)
```


---

# FontFamily

## _loadedFont


```lua
(love.Font)?
```

Internal: cached loaded font

## path


```lua
string
```

Path to the font file (relative to FlexLove or absolute)


---

# ImageCache

## _cache


```lua
table<string, { image: love.Image, imageData: (love.ImageData)? }>
```

## clear


```lua
function ImageCache.clear()
```

 Clear all cached images

## get


```lua
function ImageCache.get(imagePath: string)
  -> love.Image|nil
```

 Get a cached image without loading

@*param* `imagePath` — Path to image file

@*return* — Cached image or nil if not found

## getImageData


```lua
function ImageCache.getImageData(imagePath: string)
  -> love.ImageData|nil
```

 Get cached ImageData for an image

@*param* `imagePath` — Path to image file

@*return* — Cached ImageData or nil if not found

## getStats


```lua
function ImageCache.getStats()
  -> { count: number, memoryEstimate: number }
```

 Get cache statistics

@*return* — Cache stats

## load


```lua
function ImageCache.load(imagePath: string, loadImageData?: boolean)
  -> love.Image|nil
  2. string|nil
```

 Load an image from file path with caching
 Returns cached image if already loaded, otherwise loads and caches it

@*param* `imagePath` — Path to image file

@*param* `loadImageData` — Optional: also load ImageData for pixel access (default: false)

@*return* — Image object or nil on error

@*return* — Error message if loading failed

## remove


```lua
function ImageCache.remove(imagePath: string)
  -> boolean
```

 Remove a specific image from cache

@*param* `imagePath` — Path to image file to remove

@*return* — True if image was removed, false if not found


---

# ImageRenderer

## _parsePosition


```lua
function ImageRenderer._parsePosition(position: string)
  -> number
  2. number
```

 Parse object-position string into normalized coordinates (0-1)
 Supports keywords (center, top, bottom, left, right) and percentages

@*param* `position` — Position string like "center center", "top left", "50% 50%"

@*return* — Normalized X and Y positions (0-1)

## calculateFit


```lua
function ImageRenderer.calculateFit(imageWidth: number, imageHeight: number, boundsWidth: number, boundsHeight: number, fitMode?: string, objectPosition?: string)
  -> { sx: number, sy: number, sw: number, sh: number, dx: number, dy: number, dw: number, dh: number, scaleX: number, scaleY: number }
```

 Calculate rendering parameters for object-fit modes
 Returns source and destination rectangles for rendering

@*param* `imageWidth` — Natural width of the image

@*param* `imageHeight` — Natural height of the image

@*param* `boundsWidth` — Width of the bounds to fit within

@*param* `boundsHeight` — Height of the bounds to fit within

@*param* `fitMode` — One of: "fill", "contain", "cover", "scale-down", "none" (default: "fill")

@*param* `objectPosition` — Position like "center center", "top left", "50% 50%" (default: "center center")

## draw


```lua
function ImageRenderer.draw(image: love.Image, x: number, y: number, width: number, height: number, fitMode?: string, objectPosition?: string, opacity?: number)
```

 Draw an image with specified object-fit mode

@*param* `image` — Image to draw

@*param* `x` — X position of bounds

@*param* `y` — Y position of bounds

@*param* `width` — Width of bounds

@*param* `height` — Height of bounds

@*param* `fitMode` — Object-fit mode (default: "fill")

@*param* `objectPosition` — Object-position (default: "center center")

@*param* `opacity` — Opacity 0-1 (default: 1)


---

# InputEvent

## __index


```lua
InputEvent
```

## button


```lua
number
```

Mouse button: 1 (left), 2 (right), 3 (middle)

## clickCount


```lua
number
```

Number of clicks (for double/triple click detection)

## dx


```lua
number?
```

Delta X from drag start (only for drag events)

## dy


```lua
number?
```

Delta Y from drag start (only for drag events)

## modifiers


```lua
{ shift: boolean, ctrl: boolean, alt: boolean, super: boolean }
```

## new


```lua
function InputEvent.new(props: InputEventProps)
  -> InputEvent
```

 Create a new input event

## timestamp


```lua
number
```

Time when event occurred

## type


```lua
"click"|"drag"|"middleclick"|"press"|"release"...(+1)
```

## x


```lua
number
```

Mouse X position

## y


```lua
number
```

Mouse Y position


---

# InputEventProps

## button


```lua
number
```

## clickCount


```lua
number?
```

## dx


```lua
number?
```

## dy


```lua
number?
```

## modifiers


```lua
{ shift: boolean, ctrl: boolean, alt: boolean, super: boolean }
```

## timestamp


```lua
number?
```

## type


```lua
"click"|"drag"|"middleclick"|"press"|"release"...(+1)
```

## x


```lua
number
```

## y


```lua
number
```


---

# LayoutEngine

## _AlignContent


```lua
table
```

## _AlignItems


```lua
table
```

## _AlignSelf


```lua
table
```

## _Context


```lua
table
```

## _FlexDirection


```lua
table
```

## _FlexWrap


```lua
table
```

## _Grid


```lua
table
```

## _JustifyContent


```lua
table
```

## _Positioning


```lua
table
```

## _Units


```lua
table
```

## __index


```lua
LayoutEngine
```

## alignContent


```lua
AlignContent
```

Alignment of lines in multi-line flex containers

## alignItems


```lua
AlignItems
```

Alignment of items along cross axis

## applyPositioningOffsets


```lua
(method) LayoutEngine:applyPositioningOffsets(child: Element)
```

 Apply CSS positioning offsets (top, right, bottom, left) to a child element

@*param* `child` — The element to apply offsets to

## calculateAutoHeight


```lua
(method) LayoutEngine:calculateAutoHeight()
  -> number
```

## calculateAutoWidth


```lua
(method) LayoutEngine:calculateAutoWidth()
  -> number
```

 Calculate auto width based on children

## columnGap


```lua
number?
```

Gap between grid columns

## element


```lua
Element?
```

Reference to the parent element

## flexDirection


```lua
FlexDirection
```

Direction of flex layout

## flexWrap


```lua
FlexWrap
```

Whether children wrap to multiple lines

## gap


```lua
number
```

Space between children elements

## gridColumns


```lua
number?
```

Number of columns in the grid

## gridRows


```lua
number?
```

Number of rows in the grid

## initialize


```lua
(method) LayoutEngine:initialize(element: Element)
```

 Initialize the LayoutEngine with its parent element

@*param* `element` — The parent element

## justifyContent


```lua
JustifyContent
```

Alignment of items along main axis

## layoutChildren


```lua
(method) LayoutEngine:layoutChildren()
```

 Layout children within this element according to positioning mode

## new


```lua
function LayoutEngine.new(props: LayoutEngineProps, deps: table)
  -> LayoutEngine
```

 Create a new LayoutEngine instance

@*param* `deps` — Dependencies {utils, Grid, Units, Context}

## positioning


```lua
Positioning
```

Layout positioning mode

## recalculateUnits


```lua
(method) LayoutEngine:recalculateUnits(newViewportWidth: number, newViewportHeight: number)
```

 Recalculate units based on new viewport dimensions (for vw, vh, % units)

## rowGap


```lua
number?
```

Gap between grid rows


---

# LayoutEngineProps

## alignContent


```lua
AlignContent?
```

Alignment of lines in multi-line flex containers (default: STRETCH)

## alignItems


```lua
AlignItems?
```

Alignment of items along cross axis (default: STRETCH)

## columnGap


```lua
number?
```

Gap between grid columns

## flexDirection


```lua
FlexDirection?
```

Direction of flex layout (default: HORIZONTAL)

## flexWrap


```lua
FlexWrap?
```

Whether children wrap to multiple lines (default: NOWRAP)

## gap


```lua
number?
```

Space between children elements (default: 10)

## gridColumns


```lua
number?
```

Number of columns in the grid

## gridRows


```lua
number?
```

Number of rows in the grid

## justifyContent


```lua
JustifyContent?
```

Alignment of items along main axis (default: FLEX_START)

## positioning


```lua
Positioning?
```

Layout positioning mode (default: RELATIVE)

## rowGap


```lua
number?
```

Gap between grid rows


---

# LuaLS


---

# Performance

## addWarning


```lua
function Performance.addWarning(name: string, value: number, level: "critical"|"warning")
```

 Add a performance warning

@*param* `name` — Metric name

@*param* `value` — Metric value

@*param* `level` — Warning level

```lua
level:
    | "warning"
    | "critical"
```

## disable


```lua
function Performance.disable()
```

 Disable performance monitoring

## enable


```lua
function Performance.enable()
```

 Enable performance monitoring

## endFrame


```lua
function Performance.endFrame()
```

 End frame timing (call at end of frame)

## exportCSV


```lua
function Performance.exportCSV()
  -> csv: string
```

 Export metrics to CSV format

@*return* `csv` — CSV string of metrics

## exportJSON


```lua
function Performance.exportJSON()
  -> json: string
```

 Export metrics to JSON format

@*return* `json` — JSON string of metrics

## getConfig


```lua
function Performance.getConfig()
  -> config: table
```

 Get configuration

@*return* `config` — Current configuration

## getFPS


```lua
function Performance.getFPS()
  -> fps: number
```

 Get current FPS

@*return* `fps` — Frames per second

## getFrameMetrics


```lua
function Performance.getFrameMetrics()
  -> frameMetrics: table
```

 Get frame metrics

@*return* `frameMetrics` — Frame timing data

## getMemoryMetrics


```lua
function Performance.getMemoryMetrics()
  -> memoryMetrics: table
```

 Get memory metrics

@*return* `memoryMetrics` — Memory usage data

## getMetrics


```lua
function Performance.getMetrics()
  -> metrics: table
```

 Get all performance metrics

@*return* `metrics` — All collected metrics

## getWarnings


```lua
function Performance.getWarnings(count?: number)
  -> warnings: table
```

 Get recent warnings

@*param* `count` — Number of warnings to return (default: 10)

@*return* `warnings` — Recent warnings

## init


```lua
function Performance.init(options?: table)
```

 Initialize performance monitoring

@*param* `options` — Optional configuration overrides

## isEnabled


```lua
function Performance.isEnabled()
  -> boolean
```

 Check if performance monitoring is enabled

## keypressed


```lua
function Performance.keypressed(key: string)
```

 Handle keyboard input for HUD toggle

@*param* `key` — Key pressed

## measure


```lua
function Performance.measure(name: string, fn: function)
  -> Wrapped: function
```

 Wrap a function with performance timing

@*param* `name` — Metric name

@*param* `fn` — Function to measure

@*return* `Wrapped` — function

## renderHUD


```lua
function Performance.renderHUD(x?: number, y?: number)
```

 Render performance HUD

@*param* `x` — X position (default: 10)

@*param* `y` — Y position (default: 10)

## reset


```lua
function Performance.reset()
```

 Reset all metrics

## setConfig


```lua
function Performance.setConfig(key: string, value: any)
```

 Set configuration option

@*param* `key` — Configuration key

@*param* `value` — Configuration value

## startFrame


```lua
function Performance.startFrame()
```

 Start frame timing (call at beginning of frame)

## startTimer


```lua
function Performance.startTimer(name: string)
```

 Start a named timer

@*param* `name` — Timer name

## stopTimer


```lua
function Performance.stopTimer(name: string)
  -> elapsedMs: number?
```

 Stop a named timer and record the elapsed time

@*param* `name` — Timer name

@*return* `elapsedMs` — Elapsed time in milliseconds, or nil if timer not found

## toggleHUD


```lua
function Performance.toggleHUD()
```

 Toggle performance HUD

## updateMemory


```lua
function Performance.updateMemory()
```

 Update memory metrics


---

# Proto


---

# Renderer

## _Blur


```lua
table
```

## _Color


```lua
table
```

## _FONT_CACHE


```lua
table
```

## _ImageCache


```lua
table
```

## _ImageRenderer


```lua
table
```

## _NinePatch


```lua
table
```

## _RoundedRect


```lua
table
```

## _TextAlign


```lua
table
```

## _Theme


```lua
table
```

## __index


```lua
Renderer
```

## _blurInstance


```lua
table?
```

## _drawBackground


```lua
(method) Renderer:_drawBackground(x: number, y: number, width: number, height: number, drawBackgroundColor: table)
```

 Draw background layer

@*param* `x` — X position

@*param* `y` — Y position

@*param* `width` — Width

@*param* `height` — Height

@*param* `drawBackgroundColor` — Background color (may have animation applied)

## _drawBorders


```lua
(method) Renderer:_drawBorders(x: number, y: number, borderBoxWidth: number, borderBoxHeight: number)
```

 Draw borders

@*param* `x` — X position

@*param* `y` — Y position

@*param* `borderBoxWidth` — Border box width

@*param* `borderBoxHeight` — Border box height

## _drawImage


```lua
(method) Renderer:_drawImage(x: number, y: number, paddingLeft: number, paddingTop: number, contentWidth: number, contentHeight: number, borderBoxWidth: number, borderBoxHeight: number)
```

 Draw image layer

@*param* `x` — X position (border box)

@*param* `y` — Y position (border box)

@*param* `paddingLeft` — Left padding

@*param* `paddingTop` — Top padding

@*param* `contentWidth` — Content width

@*param* `contentHeight` — Content height

@*param* `borderBoxWidth` — Border box width

@*param* `borderBoxHeight` — Border box height

## _drawTheme


```lua
(method) Renderer:_drawTheme(x: number, y: number, borderBoxWidth: number, borderBoxHeight: number, scaleCorners: boolean, scalingAlgorithm: string)
```

 Draw theme layer (9-patch)

@*param* `x` — X position

@*param* `y` — Y position

@*param* `borderBoxWidth` — Border box width

@*param* `borderBoxHeight` — Border box height

@*param* `scaleCorners` — Whether to scale corners (from element)

@*param* `scalingAlgorithm` — Scaling algorithm (from element)

## _element


```lua
Element?
```

## _loadedImage


```lua
(love.Image)?
```


Drawable image type.


[Open in Browser](https://love2d.org/wiki/love.graphics)


## _themeState


```lua
string
```

## _utils


```lua
table
```

## backdropBlur


```lua
{ intensity: number, quality: number }?
```

## backgroundColor


```lua
Color
```

 Utility class for color handling

## border


```lua
{ top: boolean, right: boolean, bottom: boolean, left: boolean }
```

## borderColor


```lua
Color
```

 Utility class for color handling

## contentBlur


```lua
{ intensity: number, quality: number }?
```

## cornerRadius


```lua
{ topLeft: number, topRight: number, bottomLeft: number, bottomRight: number }
```

## destroy


```lua
(method) Renderer:destroy()
```

 Cleanup renderer resources

## draw


```lua
(method) Renderer:draw(backdropCanvas: table|nil)
```

 Main draw method - renders all visual layers

@*param* `backdropCanvas` — Backdrop canvas for backdrop blur

## drawPressedState


```lua
(method) Renderer:drawPressedState(x: number, y: number, borderBoxWidth: number, borderBoxHeight: number)
```

 Draw visual feedback when element is pressed

@*param* `x` — X position

@*param* `y` — Y position

@*param* `borderBoxWidth` — Border box width

@*param* `borderBoxHeight` — Border box height

## drawScrollbars


```lua
(method) Renderer:drawScrollbars(element: table, x: number, y: number, w: number, h: number, dims: table)
```

 Draw scrollbars (both vertical and horizontal)

@*param* `element` — Reference to the parent Element instance

@*param* `x` — X position

@*param* `y` — Y position

@*param* `w` — Width

@*param* `h` — Height

@*param* `dims` — Scrollbar dimensions from _calculateScrollbarDimensions

## drawText


```lua
(method) Renderer:drawText(element: table)
```

 Draw text content (includes text, cursor, selection, placeholder, password masking)

@*param* `element` — Reference to the parent Element instance

## getBlurInstance


```lua
(method) Renderer:getBlurInstance()
  -> Blur: table|nil
```

 Get or create blur instance for this element

@*return* `Blur` — instance or nil

## getFont


```lua
(method) Renderer:getFont(element: table)
  -> love.Font
```

 Get font for element (resolves from theme or fontFamily)

@*param* `element` — Reference to the parent Element instance

## image


```lua
(love.Image)?
```


Drawable image type.


[Open in Browser](https://love2d.org/wiki/love.graphics)


## imageOpacity


```lua
number
```

## imagePath


```lua
string?
```

## initialize


```lua
(method) Renderer:initialize(element: table)
```

 Initialize renderer with parent element reference

@*param* `element` — The parent Element instance

## new


```lua
function Renderer.new(config: table, deps: table)
  -> Renderer
```

 Create a new Renderer instance

@*param* `config` — Configuration table with rendering properties

@*param* `deps` — Dependencies {Color, RoundedRect, NinePatch, ImageRenderer, ImageCache, Theme, Blur, utils}

## objectFit


```lua
string
```

## objectPosition


```lua
string
```

## opacity


```lua
number
```

## setThemeState


```lua
(method) Renderer:setThemeState(state: string)
```

 Set theme state (normal, hover, pressed, disabled, active)

@*param* `state` — The theme state

## theme


```lua
string?
```

## themeComponent


```lua
string?
```

## wrapLine


```lua
(method) Renderer:wrapLine(element: table, line: string, maxWidth: number)
  -> Array: table
```

 Wrap a line of text based on element's textWrap mode

@*param* `element` — Reference to the parent Element instance

@*param* `line` — The line of text to wrap

@*param* `maxWidth` — Maximum width for wrapping

@*return* `Array` — of {text, startIdx, endIdx}


---

# ScrollManager

## _Color


```lua
table
```

## __index


```lua
ScrollManager
```

## _contentHeight


```lua
number
```

Total content height (including overflow)

## _contentWidth


```lua
number
```

Total content width (including overflow)

## _element


```lua
Element?
```

Reference to parent Element (set via initialize)

## _hoveredScrollbar


```lua
string?
```

"vertical" or "horizontal" when dragging

## _maxScrollX


```lua
number
```

Maximum horizontal scroll (contentWidth - containerWidth)

## _maxScrollY


```lua
number
```

Maximum vertical scroll (contentHeight - containerHeight)

## _overflowX


```lua
boolean
```

True if content overflows horizontally

## _overflowY


```lua
boolean
```

True if content overflows vertically

## _scrollToTrackPosition


```lua
(method) ScrollManager:_scrollToTrackPosition(mouseX: number, mouseY: number, component: string)
```

 Scroll to track click position (internal helper)

@*param* `component` — vertical

## _scrollX


```lua
number
```

Current horizontal scroll position

## _scrollY


```lua
number
```

Current vertical scroll position

## _scrollbarDragOffset


```lua
number
```

Offset from thumb top when drag started

## _scrollbarDragging


```lua
boolean
```

True if currently dragging a scrollbar

## _scrollbarHoveredHorizontal


```lua
boolean
```

True if mouse is over horizontal scrollbar

## _scrollbarHoveredVertical


```lua
boolean
```

True if mouse is over vertical scrollbar

## _scrollbarPressHandled


```lua
boolean
```

Track if scrollbar press was handled this frame

## _utils


```lua
table
```

## calculateScrollbarDimensions


```lua
(method) ScrollManager:calculateScrollbarDimensions()
  -> table
```

 Calculate scrollbar dimensions and positions

@*return* — {vertical: {visible, trackHeight, thumbHeight, thumbY}, horizontal: {visible, trackWidth, thumbWidth, thumbX}}

## detectOverflow


```lua
(method) ScrollManager:detectOverflow()
```

 Detect if content overflows container bounds

## getContentSize


```lua
(method) ScrollManager:getContentSize()
  -> contentWidth: number
  2. contentHeight: number
```

 Get content dimensions (including overflow)

## getMaxScroll


```lua
(method) ScrollManager:getMaxScroll()
  -> maxScrollX: number
  2. maxScrollY: number
```

 Get maximum scroll bounds

## getScroll


```lua
(method) ScrollManager:getScroll()
  -> scrollX: number
  2. scrollY: number
```

 Get current scroll position

## getScrollPercentage


```lua
(method) ScrollManager:getScrollPercentage()
  -> percentX: number
  2. percentY: number
```

 Get scroll percentage (0-1)

## getScrollbarAtPosition


```lua
(method) ScrollManager:getScrollbarAtPosition(mouseX: number, mouseY: number)
  -> table|nil
```

 Get scrollbar at mouse position

@*return* — {component: "vertical"|"horizontal", region: "thumb"|"track"}

## getState


```lua
(method) ScrollManager:getState()
  -> State: table
```

 Get state for immediate mode persistence

@*return* `State` — data

## handleMouseMove


```lua
(method) ScrollManager:handleMouseMove(mouseX: number, mouseY: number)
  -> boolean
```

 Handle scrollbar drag

@*return* — True if event was consumed

## handleMousePress


```lua
(method) ScrollManager:handleMousePress(mouseX: number, mouseY: number, button: number)
  -> boolean
```

 Handle scrollbar mouse press

@*return* — True if event was consumed

## handleMouseRelease


```lua
(method) ScrollManager:handleMouseRelease(button: number)
  -> boolean
```

 Handle scrollbar release

@*return* — True if event was consumed

## handleWheel


```lua
(method) ScrollManager:handleWheel(x: number, y: number)
  -> boolean
```

 Handle mouse wheel scrolling

@*param* `x` — Horizontal scroll amount

@*param* `y` — Vertical scroll amount

@*return* — True if scroll was handled

## hasOverflow


```lua
(method) ScrollManager:hasOverflow()
  -> hasOverflowX: boolean
  2. hasOverflowY: boolean
```

 Check if element has overflow

## hideScrollbars


```lua
table
```

{vertical: boolean, horizontal: boolean}

## initialize


```lua
(method) ScrollManager:initialize(element: table)
```

 Initialize with parent element reference

@*param* `element` — The parent Element instance

## new


```lua
function ScrollManager.new(config: table, deps: table)
  -> ScrollManager
```

 Create a new ScrollManager instance

@*param* `config` — Configuration options

@*param* `deps` — Dependencies {Color: Color module, utils: utils module}

## overflow


```lua
string
```

visible

## overflowX


```lua
string?
```

X-axis specific overflow (overrides overflow)

## overflowY


```lua
string?
```

Y-axis specific overflow (overrides overflow)

## resetScrollbarPressFlag


```lua
(method) ScrollManager:resetScrollbarPressFlag()
```

 Reset scrollbar press handled flag (call at start of frame)

## scrollBy


```lua
(method) ScrollManager:scrollBy(dx?: number, dy?: number)
```

 Scroll by delta amount

@*param* `dx` — X delta (nil for no change)

@*param* `dy` — Y delta (nil for no change)

## scrollSpeed


```lua
number
```

Scroll speed for wheel events (pixels per wheel unit)

## scrollbarColor


```lua
Color
```

Scrollbar thumb color

## scrollbarPadding


```lua
number
```

Padding around scrollbar

## scrollbarRadius


```lua
number
```

Border radius for scrollbars

## scrollbarTrackColor


```lua
Color
```

Scrollbar track background color

## scrollbarWidth


```lua
number
```

Width/height of scrollbar track

## setScroll


```lua
(method) ScrollManager:setScroll(x?: number, y?: number)
```

 Set scroll position with bounds clamping

@*param* `x` — X scroll position (nil to keep current)

@*param* `y` — Y scroll position (nil to keep current)

## setScrollbarPressHandled


```lua
(method) ScrollManager:setScrollbarPressHandled()
```

 Set scrollbar press handled flag

## setState


```lua
(method) ScrollManager:setState(state: table)
```

 Set state from immediate mode persistence

@*param* `state` — State data

## updateHoverState


```lua
(method) ScrollManager:updateHoverState(mouseX: number, mouseY: number)
```

 Update scrollbar hover state based on mouse position

## wasScrollbarPressHandled


```lua
(method) ScrollManager:wasScrollbarPressHandled()
  -> boolean
```

 Check if scrollbar press was handled this frame


---

# StateManager

## cleanup


```lua
function StateManager.cleanup()
  -> count: number
```

 Clean up stale states (not accessed recently)

@*return* `count` — Number of states cleaned up

## clearAllStates


```lua
function StateManager.clearAllStates()
```

 Clear all states

## clearState


```lua
function StateManager.clearState(id: string)
```

 Clear state for a specific element ID

@*param* `id` — Element ID

## configure


```lua
function StateManager.configure(newConfig: { stateRetentionFrames: number, maxStateEntries: number })
```

 Configure state management

## dumpStates


```lua
function StateManager.dumpStates()
  -> states: table
```

 Dump all states for debugging

@*return* `states` — Copy of all states with metadata

## forceCleanupIfNeeded


```lua
function StateManager.forceCleanupIfNeeded()
  -> count: number
```

 Force cleanup if state count exceeds maximum

@*return* `count` — Number of states cleaned up

## generateID


```lua
function StateManager.generateID(props: table|nil, parent: table|nil)
  -> string
```

 Generate a unique ID from call site and properties

@*param* `props` — Optional properties to include in ID generation

@*param* `parent` — Optional parent element for tree-based ID generation

## getActiveState


```lua
function StateManager.getActiveState(id: string)
  -> state: table
```

 Get the active state values for an element (interaction states only)

@*param* `id` — Element ID

@*return* `state` — Active state values

## getCurrentState


```lua
function StateManager.getCurrentState(id: string)
  -> state: table
```

 Get the current state for an element ID (alias for getState)

@*param* `id` — Element ID

@*return* `state` — State object for the element

## getFrameNumber


```lua
function StateManager.getFrameNumber()
  -> number
```

 Get current frame number

## getLastAccessedFrame


```lua
function StateManager.getLastAccessedFrame(id: string)
  -> frameNumber: number|nil
```

 Get the last frame number when state was accessed

@*param* `id` — Element ID

@*return* `frameNumber` — Last accessed frame, or nil if not found

## getState


```lua
function StateManager.getState(id: string, defaultState: table|nil)
  -> state: table
```

 Get state for an element ID, creating if it doesn't exist

@*param* `id` — Element ID

@*param* `defaultState` — Default state if creating new

@*return* `state` — State table for the element

## getStateCount


```lua
function StateManager.getStateCount()
  -> number
```

 Get total number of stored states

## getStats


```lua
function StateManager.getStats()
  -> { stateCount: number, frameNumber: number, oldestState: number|nil, newestState: number|nil }
```

 Get state statistics for debugging

## incrementFrame


```lua
function StateManager.incrementFrame()
```

 Increment frame counter (called at frame start)

## isActive


```lua
function StateManager.isActive(id: string)
  -> boolean
```

 Check if an element is active (e.g., input focused)

@*param* `id` — Element ID

## isDisabled


```lua
function StateManager.isDisabled(id: string)
  -> boolean
```

 Check if an element is disabled

@*param* `id` — Element ID

## isFocused


```lua
function StateManager.isFocused(id: string)
  -> boolean
```

 Check if an element is currently focused

@*param* `id` — Element ID

## isHovered


```lua
function StateManager.isHovered(id: string)
  -> boolean
```

 Check if an element is currently hovered

@*param* `id` — Element ID

## isPressed


```lua
function StateManager.isPressed(id: string)
  -> boolean
```

 Check if an element is currently pressed

@*param* `id` — Element ID

## markStateUsed


```lua
function StateManager.markStateUsed(id: string)
```

 Mark state as used this frame (updates last accessed frame)

@*param* `id` — Element ID

## reset


```lua
function StateManager.reset()
```

 Reset the entire state system (for testing)

## setState


```lua
function StateManager.setState(id: string, state: table)
```

 Set state for an element ID (replaces entire state)

@*param* `id` — Element ID

@*param* `state` — State to store

## updateState


```lua
function StateManager.updateState(id: string, newState: table)
```

 Update state for an element ID (merges with existing state)

@*param* `id` — Element ID

@*param* `newState` — New state values to merge


---

# TextEditor

## _Color


```lua
table
```

## _Context


```lua
table
```

## _FONT_CACHE


```lua
table
```

## _StateManager


```lua
table
```

## __index


```lua
TextEditor
```

## _calculateWrapping


```lua
(method) TextEditor:_calculateWrapping()
```

Calculate text wrapping

## _cursorBlinkPauseTimer


```lua
number
```

## _cursorBlinkPaused


```lua
boolean
```

## _cursorBlinkTimer


```lua
number
```

## _cursorColumn


```lua
number
```

## _cursorLine


```lua
number
```

## _cursorPosition


```lua
number
```

## _cursorVisible


```lua
boolean
```

## _element


```lua
Element?
```

## _focused


```lua
boolean
```

## _getCursorScreenPosition


```lua
(method) TextEditor:_getCursorScreenPosition()
  -> number
  2. number
```

Get cursor screen position for rendering (handles multiline text)

@*return* — Cursor X and Y position relative to content area

## _getFont


```lua
(method) TextEditor:_getFont()
  -> (love.Font)?
```

Get font for text rendering

## _getModifiers


```lua
function
```

## _getSelectionRects


```lua
(method) TextEditor:_getSelectionRects(selStart: number, selEnd: number)
  -> table
```

Get selection rectangles for rendering

@*param* `selStart` — Selection start position

@*param* `selEnd` — Selection end position

@*return* — Array of rectangles {x, y, width, height}

## _lines


```lua
table?
```

## _markTextDirty


```lua
(method) TextEditor:_markTextDirty()
```

Mark text as dirty (needs recalculation)

## _mouseDownPosition


```lua
number
```

## _resetCursorBlink


```lua
(method) TextEditor:_resetCursorBlink(pauseBlink: boolean|nil)
```

Reset cursor blink (show cursor immediately)

@*param* `pauseBlink` — Whether to pause blinking (for typing)

## _sanitizeText


```lua
(method) TextEditor:_sanitizeText(text: string)
  -> string
```

Internal: Sanitize text input

@*param* `text` — Text to sanitize

@*return* — Sanitized text

## _saveState


```lua
(method) TextEditor:_saveState()
```

Save state to StateManager (for immediate mode)

## _selectWordAtPosition


```lua
(method) TextEditor:_selectWordAtPosition(position: number)
```

Select word at given position

## _selectionAnchor


```lua
number?
```

## _selectionEnd


```lua
number?
```

## _selectionStart


```lua
number?
```

## _splitLines


```lua
(method) TextEditor:_splitLines()
```

Split text into lines (for multi-line text)

## _textBuffer


```lua
string
```

## _textDirty


```lua
boolean
```

## _textDragOccurred


```lua
boolean?
```

## _textScrollX


```lua
number
```

## _updateTextIfDirty


```lua
(method) TextEditor:_updateTextIfDirty()
```

Update text if dirty (recalculate lines and wrapping)

## _updateTextScroll


```lua
(method) TextEditor:_updateTextScroll()
```

Update text scroll offset to keep cursor visible

## _utils


```lua
table
```

## _validateCursorPosition


```lua
(method) TextEditor:_validateCursorPosition()
```

Validate cursor position (ensure it's within text bounds)

## _wrapLine


```lua
(method) TextEditor:_wrapLine(line: string, maxWidth: number)
  -> table
```

Wrap a single line of text

@*param* `line` — Line to wrap

@*param* `maxWidth` — Maximum width in pixels

@*return* — Array of wrapped line parts

## _wrappedLines


```lua
table?
```

## allowNewlines


```lua
boolean
```

## allowTabs


```lua
boolean
```

## autoGrow


```lua
boolean
```

## blur


```lua
(method) TextEditor:blur()
```

Remove focus from this element

## clearSelection


```lua
(method) TextEditor:clearSelection()
```

Clear selection

## cursorBlinkRate


```lua
number
```

## cursorColor


```lua
Color?
```

 Utility class for color handling

## customSanitizer


```lua
function?
```

## deleteSelection


```lua
(method) TextEditor:deleteSelection()
  -> boolean
```

Delete selected text

@*return* — True if text was deleted

## deleteText


```lua
(method) TextEditor:deleteText(startPos: number, endPos: number)
```

Delete text in range

@*param* `startPos` — Start position (inclusive)

@*param* `endPos` — End position (inclusive)

## editable


```lua
boolean
```

## focus


```lua
(method) TextEditor:focus()
```

Focus this element for keyboard input

## getCursorPosition


```lua
(method) TextEditor:getCursorPosition()
  -> number
```

Get cursor position

@*return* — Character index (0-based)

## getSelectedText


```lua
(method) TextEditor:getSelectedText()
  -> string?
```

Get selected text

@*return* — Selected text or nil if no selection

## getSelection


```lua
(method) TextEditor:getSelection()
  -> number?
  2. number?
```

Get selection range

@*return* — Start and end positions, or nil if no selection

## getText


```lua
(method) TextEditor:getText()
  -> string
```

Get current text buffer

## handleKeyPress


```lua
(method) TextEditor:handleKeyPress(key: string, scancode: string, isrepeat: boolean)
```

Handle key press (special keys)

@*param* `key` — Key name

@*param* `scancode` — Scancode

@*param* `isrepeat` — Whether this is a key repeat

## handleTextClick


```lua
(method) TextEditor:handleTextClick(mouseX: number, mouseY: number, clickCount: number)
```

Handle mouse click on text

@*param* `clickCount` — 1=single, 2=double, 3=triple

## handleTextDrag


```lua
(method) TextEditor:handleTextDrag(mouseX: number, mouseY: number)
```

Handle mouse drag for text selection

## handleTextInput


```lua
(method) TextEditor:handleTextInput(text: string)
```

Handle text input (character insertion)

## hasSelection


```lua
(method) TextEditor:hasSelection()
  -> boolean
```

Check if there is an active selection

## initialize


```lua
(method) TextEditor:initialize(element: table)
```

Initialize TextEditor with parent element reference

@*param* `element` — The parent Element instance

## inputType


```lua
"email"|"number"|"text"|"url"
```

## insertText


```lua
(method) TextEditor:insertText(text: string, position?: number, skipSanitization?: boolean)
```

Insert text at position

@*param* `text` — Text to insert

@*param* `position` — Position to insert at (default: cursor position)

@*param* `skipSanitization` — Skip sanitization (for internal use)

## isFocused


```lua
(method) TextEditor:isFocused()
  -> boolean
```

Check if this element is focused

## maxLength


```lua
number?
```

## maxLines


```lua
number?
```

## mouseToTextPosition


```lua
(method) TextEditor:mouseToTextPosition(mouseX: number, mouseY: number)
  -> number
```

Convert mouse coordinates to cursor position in text

@*param* `mouseX` — Mouse X coordinate (absolute)

@*param* `mouseY` — Mouse Y coordinate (absolute)

@*return* — Cursor position (character index)

## moveCursorBy


```lua
(method) TextEditor:moveCursorBy(delta: number)
```

Move cursor by delta characters

@*param* `delta` — Number of characters to move (positive or negative)

## moveCursorToEnd


```lua
(method) TextEditor:moveCursorToEnd()
```

Move cursor to end of text

## moveCursorToLineEnd


```lua
(method) TextEditor:moveCursorToLineEnd()
```

Move cursor to end of current line

## moveCursorToLineStart


```lua
(method) TextEditor:moveCursorToLineStart()
```

Move cursor to start of current line

## moveCursorToNextWord


```lua
(method) TextEditor:moveCursorToNextWord()
```

Move cursor to start of next word

## moveCursorToPreviousWord


```lua
(method) TextEditor:moveCursorToPreviousWord()
```

Move cursor to start of previous word

## moveCursorToStart


```lua
(method) TextEditor:moveCursorToStart()
```

Move cursor to start of text

## multiline


```lua
boolean
```

## new


```lua
function TextEditor.new(config: TextEditorConfig, deps: table)
  -> TextEditor: table
```

Create a new TextEditor instance

@*param* `deps` — Dependencies {Context, StateManager, Color, utils}

@*return* `TextEditor` — instance

## onBlur


```lua
fun(element: Element)?
```

## onEnter


```lua
fun(element: Element)?
```

## onFocus


```lua
fun(element: Element)?
```

## onSanitize


```lua
fun(element: Element, original: string, sanitized: string)?
```

## onTextChange


```lua
fun(element: Element, text: string)?
```

## onTextInput


```lua
fun(element: Element, text: string)?
```

## passwordMode


```lua
boolean
```

## placeholder


```lua
string?
```

## replaceText


```lua
(method) TextEditor:replaceText(startPos: number, endPos: number, newText: string)
```

Replace text in range

@*param* `startPos` — Start position (inclusive)

@*param* `endPos` — End position (inclusive)

@*param* `newText` — Replacement text

## sanitize


```lua
boolean
```

## scrollable


```lua
boolean
```

## selectAll


```lua
(method) TextEditor:selectAll()
```

Select all text

## selectOnFocus


```lua
boolean
```

## selectionColor


```lua
Color?
```

 Utility class for color handling

## setCursorPosition


```lua
(method) TextEditor:setCursorPosition(position: number)
```

Set cursor position

@*param* `position` — Character index (0-based)

## setSelection


```lua
(method) TextEditor:setSelection(startPos: number, endPos: number)
```

Set selection range

@*param* `startPos` — Start position (inclusive)

@*param* `endPos` — End position (inclusive)

## setText


```lua
(method) TextEditor:setText(text: string, skipSanitization?: boolean)
```

Set text buffer and mark dirty

@*param* `skipSanitization` — Skip sanitization (for trusted input)

## textOverflow


```lua
"clip"|"ellipsis"|"scroll"
```

## textWrap


```lua
boolean|"char"|"word"
```

## update


```lua
(method) TextEditor:update(dt: number)
```

Update cursor blink animation

@*param* `dt` — Delta time

## updateAutoGrowHeight


```lua
(method) TextEditor:updateAutoGrowHeight()
```

Update element height based on text content (for autoGrow)


---

# TextEditorConfig

## allowNewlines


```lua
boolean?
```

Whether to allow newline characters (default: true in multiline)

## allowTabs


```lua
boolean?
```

Whether to allow tab characters (default: true)

## autoGrow


```lua
boolean
```

Whether element auto-grows with text

## cursorBlinkRate


```lua
number
```

Cursor blink rate in seconds

## cursorColor


```lua
Color?
```

Cursor color

## customSanitizer


```lua
function?
```

Custom sanitization function

## editable


```lua
boolean
```

Whether text is editable

## inputType


```lua
"email"|"number"|"text"|"url"
```

Input validation type

## maxLength


```lua
number?
```

Maximum text length in characters

## maxLines


```lua
number?
```

Maximum number of lines

## multiline


```lua
boolean
```

Whether multi-line is supported

## passwordMode


```lua
boolean
```

Whether to mask text

## placeholder


```lua
string?
```

Placeholder text when empty

## sanitize


```lua
boolean?
```

Whether to sanitize text input (default: true)

## scrollable


```lua
boolean
```

Whether text is scrollable

## selectOnFocus


```lua
boolean
```

Whether to select all text on focus

## selectionColor


```lua
Color?
```

Selection background color

## textOverflow


```lua
"clip"|"ellipsis"|"scroll"
```

Text overflow behavior

## textWrap


```lua
boolean|"char"|"word"
```

Text wrapping mode


---

# Theme

## Manager


```lua
ThemeManager
```

 Export both Theme and ThemeManager

## __index


```lua
Theme
```

## atlas


```lua
(love.Image)?
```

Optional: global atlas

## atlasData


```lua
(love.ImageData)?
```


Raw (decoded) image data.

You can't draw ImageData directly to screen. See Image for that.


[Open in Browser](https://love2d.org/wiki/love.image)


## colors


```lua
table<string, Color>
```

## components


```lua
table<string, ThemeComponent>
```

## contentAutoSizingMultiplier


```lua
{ width: number?, height: number? }?
```

Optional: default multiplier for auto-sized content dimensions

## fonts


```lua
table<string, string>
```

Font family definitions

## get


```lua
function Theme.get(themeName: string)
  -> Theme|nil
```

 Get a theme by name

@*param* `themeName` — Name of the theme

@*return* — Returns theme or nil if not found

## getActive


```lua
function Theme.getActive()
  -> Theme?
```

 Get the active theme

## getAllColors


```lua
function Theme.getAllColors()
  -> table<string, Color>|nil
```

 Get all colors from the active theme

@*return* — Table of all colors, or nil if no theme active

## getColor


```lua
function Theme.getColor(colorName: string)
  -> Color?
```

 Get a color from the active theme

@*param* `colorName` — Name of the color (e.g., "primary", "secondary")

@*return* — Returns Color instance or nil if not found

## getColorNames


```lua
function Theme.getColorNames()
  -> table<string>|nil
```

 Get all available color names from the active theme

@*return* — Array of color names, or nil if no theme active

## getColorOrDefault


```lua
function Theme.getColorOrDefault(colorName: string, fallback: Color|nil)
  -> Color
```

 Get a color with a fallback if not found

@*param* `colorName` — Name of the color to retrieve

@*param* `fallback` — Fallback color if not found (default: white)

@*return* — The color or fallback

## getComponent


```lua
function Theme.getComponent(componentName: string, state?: string)
  -> ThemeComponent?
```

 Get a component from the active theme

@*param* `componentName` — Name of the component (e.g., "button", "panel")

@*param* `state` — Optional state (e.g., "hover", "pressed", "disabled")

@*return* — Returns component or nil if not found

## getFont


```lua
function Theme.getFont(fontName: string)
  -> string?
```

 Get a font from the active theme

@*param* `fontName` — Name of the font family (e.g., "default", "heading")

@*return* — Returns font path or nil if not found

## getRegisteredThemes


```lua
function Theme.getRegisteredThemes()
  -> table<string>
```

 Get all registered theme names

@*return* — Array of theme names

## hasActive


```lua
function Theme.hasActive()
  -> boolean
```

 Check if a theme is currently active

@*return* — Returns true if a theme is active

## load


```lua
function Theme.load(path: string)
  -> Theme
```

 Load a theme from a Lua file

@*param* `path` — Path to theme definition file (e.g., "space" or "mytheme")

## name


```lua
string
```

## new


```lua
function Theme.new(definition: any)
  -> Theme
```

## sanitizeTheme


```lua
function Theme.sanitizeTheme(theme?: table)
  -> sanitized: table
```

Sanitize a theme definition by removing invalid values and providing defaults

@*param* `theme` — The theme to sanitize

@*return* `sanitized` — The sanitized theme

## setActive


```lua
function Theme.setActive(themeOrName: string|Theme)
```

## validateTheme


```lua
function Theme.validateTheme(theme?: table, options?: table)
  -> valid: boolean
  2. errors: table
```

Validate a theme definition for structural correctness (non-aggressive)

@*param* `theme` — The theme to validate

@*param* `options` — Optional validation options {strict: boolean}

@*return* `valid,errors` — List of validation errors


---

# ThemeComponent

## _loadedAtlas


```lua
(string|love.Image)?
```

Internal: cached loaded atlas image

## _loadedAtlasData


```lua
(love.ImageData)?
```

Internal: cached loaded atlas ImageData for pixel access

## _ninePatchData


```lua
{ insets: table, contentPadding: table, stretchX: table, stretchY: table }?
```

Internal: parsed 9-patch data with stretch regions and content padding

## _scaledRegionCache


```lua
table<string, love.Image>?
```

Internal: cache for scaled corner/edge images

## atlas


```lua
(string|love.Image)?
```

Optional: component-specific atlas (overrides theme atlas). Files ending in .9.png are auto-parsed

## contentAutoSizingMultiplier


```lua
{ width: number?, height: number? }?
```

Optional: multiplier for auto-sized content dimensions

## insets


```lua
{ left: number, top: number, right: number, bottom: number }?
```

Optional: 9-patch insets (auto-extracted from .9.png files or manually defined)

## regions


```lua
{ topLeft: ThemeRegion, topCenter: ThemeRegion, topRight: ThemeRegion, middleLeft: ThemeRegion, middleCenter: ThemeRegion, middleRight: ThemeRegion, bottomLeft: ThemeRegion, bottomCenter: ThemeRegion, bottomRight: ThemeRegion }
```

## scaleCorners


```lua
number?
```

Optional: scale multiplier for non-stretched regions (corners/edges). E.g., 2 = 2x size. Default: nil (no scaling)

## scalingAlgorithm


```lua
("bilinear"|"nearest")?
```

Optional: scaling algorithm for non-stretched regions. Default: "bilinear"

## states


```lua
table<string, ThemeComponent>?
```

## stretch


```lua
{ horizontal: table<integer, string>, vertical: table<integer, string> }
```


---

# ThemeDefinition

## atlas


```lua
(string|love.Image)?
```

Optional: global atlas (can be overridden per component)

## colors


```lua
table<string, Color>?
```

## components


```lua
table<string, ThemeComponent>
```

## contentAutoSizingMultiplier


```lua
{ width: number?, height: number? }?
```

Optional: default multiplier for auto-sized content dimensions

## fonts


```lua
table<string, string>?
```

Optional: font family definitions (name -> path)

## name


```lua
string
```


---

# ThemeManager

## __index


```lua
ThemeManager
```

## _element


```lua
Element?
```

Reference to parent Element

## _themeState


```lua
string
```

Current theme state (normal, hover, pressed, active, disabled)

## active


```lua
boolean
```

## disableHighlight


```lua
boolean
```

If true, disable pressed highlight overlay

## disabled


```lua
boolean
```

## getComponent


```lua
(method) ThemeManager:getComponent()
  -> table?
```

## getContentAutoSizingMultiplier


```lua
(method) ThemeManager:getContentAutoSizingMultiplier()
  -> number?
```

## getDefaultFontFamily


```lua
(method) ThemeManager:getDefaultFontFamily()
  -> string?
```

## getScaledContentPadding


```lua
(method) ThemeManager:getScaledContentPadding(borderBoxWidth: number, borderBoxHeight: number)
  -> table?
```

@*return* — {left, top, right, bottom} or nil if no contentPadding

## getState


```lua
(method) ThemeManager:getState()
  -> The: string
```

@*return* `The` — current theme state

## getStateComponent


```lua
(method) ThemeManager:getStateComponent()
  -> table?
```

## getStyle


```lua
(method) ThemeManager:getStyle(property: string)
  -> any
```

## getTheme


```lua
(method) ThemeManager:getTheme()
  -> table?
```

## hasThemeComponent


```lua
(method) ThemeManager:hasThemeComponent()
  -> boolean
```

## initialize


```lua
(method) ThemeManager:initialize(element: table)
```

@*param* `element` — The parent Element

## new


```lua
function ThemeManager.new(config: table)
  -> ThemeManager
```

@*param* `config` — Configuration options

## scaleCorners


```lua
number?
```

Scale multiplier for 9-patch corners/edges

## scalingAlgorithm


```lua
string?
```

"nearest" or "bilinear" scaling for 9-patch

## setState


```lua
(method) ThemeManager:setState(state: string)
```

@*param* `state` — The theme state to set

## setTheme


```lua
(method) ThemeManager:setTheme(themeName?: string, componentName?: string)
```

@*param* `themeName` — The theme name

@*param* `componentName` — The component name

## theme


```lua
string?
```

Override theme name

## themeComponent


```lua
string?
```

Component to use from theme

## updateState


```lua
(method) ThemeManager:updateState(isHovered: boolean, isPressed: boolean, isFocused: boolean, isDisabled: boolean)
  -> The: string
```

@*param* `isHovered` — Whether element is hovered

@*param* `isPressed` — Whether element is pressed

@*param* `isFocused` — Whether element is focused

@*param* `isDisabled` — Whether element is disabled

@*return* `The` — new theme state


---

# ThemeRegion

## h


```lua
number
```

Height in atlas

## w


```lua
number
```

Width in atlas

## x


```lua
number
```

X position in atlas

## y


```lua
number
```

Y position in atlas


---

# Trace


---

# TransformProps

## rotate


```lua
number?
```

## scale


```lua
{ x: number, y: number }?
```

## skew


```lua
{ x: number, y: number }?
```

## translate


```lua
{ x: number, y: number }?
```


---

# TransitionProps

## duration


```lua
number?
```

## easing


```lua
string?
```


---

# _G


---

# _G


```lua
_G
```


---

# _VERSION


```lua
string
```


---

# any


---

# arg


```lua
string[]
```


---

# assert


```lua
function assert(v?: <T>, message?: any, ...any)
  -> <T>
  2. ...any
```


---

# bit


```lua
bitlib
```


---

# bit.arshift


```lua
function bit.arshift(x: integer, n: integer)
  -> y: integer
```


---

# bit.band


```lua
function bit.band(x: integer, ...integer)
  -> y: integer
```


---

# bit.bnot


```lua
function bit.bnot(x: integer)
  -> y: integer
```


---

# bit.bor


```lua
function bit.bor(x: integer, ...integer)
  -> y: integer
```


---

# bit.bswap


```lua
function bit.bswap(x: integer)
  -> y: integer
```


---

# bit.bxor


```lua
function bit.bxor(x: integer, ...integer)
  -> y: integer
```


---

# bit.lshift


```lua
function bit.lshift(x: integer, n: integer)
  -> y: integer
```


---

# bit.rol


```lua
function bit.rol(x: integer, n: integer)
  -> y: integer
```


---

# bit.ror


```lua
function bit.ror(x: integer, n: integer)
  -> y: integer
```


---

# bit.rshift


```lua
function bit.rshift(x: integer, n: integer)
  -> y: integer
```


---

# bit.tobit


```lua
function bit.tobit(x: integer)
  -> y: integer
```


---

# bit.tohex


```lua
function bit.tohex(x: integer, n?: integer)
  -> y: string
```


---

# bitlib

## arshift


```lua
function bit.arshift(x: integer, n: integer)
  -> y: integer
```

## band


```lua
function bit.band(x: integer, ...integer)
  -> y: integer
```

## bnot


```lua
function bit.bnot(x: integer)
  -> y: integer
```

## bor


```lua
function bit.bor(x: integer, ...integer)
  -> y: integer
```

## bswap


```lua
function bit.bswap(x: integer)
  -> y: integer
```

## bxor


```lua
function bit.bxor(x: integer, ...integer)
  -> y: integer
```

## lshift


```lua
function bit.lshift(x: integer, n: integer)
  -> y: integer
```

## rol


```lua
function bit.rol(x: integer, n: integer)
  -> y: integer
```

## ror


```lua
function bit.ror(x: integer, n: integer)
  -> y: integer
```

## rshift


```lua
function bit.rshift(x: integer, n: integer)
  -> y: integer
```

## tobit


```lua
function bit.tobit(x: integer)
  -> y: integer
```

## tohex


```lua
function bit.tohex(x: integer, n?: integer)
  -> y: string
```


---

# boolean


---

# collectgarbage


```lua
function collectgarbage(opt?: "collect"|"count"|"isrunning"|"restart"|"setpause"...(+3), arg?: integer)
  -> any
```


---

# coroutine


```lua
coroutinelib
```


---

# coroutine.close


```lua
function coroutine.close(co: thread)
  -> noerror: boolean
  2. errorobject: any
```


---

# coroutine.create


```lua
function coroutine.create(f: fun(...any):...unknown)
  -> thread
```


---

# coroutine.isyieldable


```lua
function coroutine.isyieldable()
  -> boolean
```


---

# coroutine.resume


```lua
function coroutine.resume(co: thread, val1?: any, ...any)
  -> success: boolean
  2. ...any
```


---

# coroutine.running


```lua
function coroutine.running()
  -> running: thread
  2. ismain: boolean
```


---

# coroutine.status


```lua
function coroutine.status(co: thread)
  -> "dead"|"normal"|"running"|"suspended"
```


---

# coroutine.wrap


```lua
function coroutine.wrap(f: fun(...any):...unknown)
  -> fun(...any):...unknown
```


---

# coroutine.yield


```lua
(async) function coroutine.yield(...any)
  -> ...any
```


---

# coroutinelib

## close


```lua
function coroutine.close(co: thread)
  -> noerror: boolean
  2. errorobject: any
```


Closes coroutine `co` , closing all its pending to-be-closed variables and putting the coroutine in a dead state.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-coroutine.close"])

## create


```lua
function coroutine.create(f: fun(...any):...unknown)
  -> thread
```


Creates a new coroutine, with body `f`. `f` must be a function. Returns this new coroutine, an object with type `"thread"`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-coroutine.create"])

## isyieldable


```lua
function coroutine.isyieldable()
  -> boolean
```


Returns true when the running coroutine can yield.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-coroutine.isyieldable"])

## resume


```lua
function coroutine.resume(co: thread, val1?: any, ...any)
  -> success: boolean
  2. ...any
```


Starts or continues the execution of coroutine `co`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-coroutine.resume"])

## running


```lua
function coroutine.running()
  -> running: thread
  2. ismain: boolean
```


Returns the running coroutine plus a boolean, true when the running coroutine is the main one.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-coroutine.running"])

## status


```lua
function coroutine.status(co: thread)
  -> "dead"|"normal"|"running"|"suspended"
```


Returns the status of coroutine `co`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-coroutine.status"])


```lua
return #1:
    | "running" -- Is running.
    | "suspended" -- Is suspended or not started.
    | "normal" -- Is active but not running.
    | "dead" -- Has finished or stopped with an error.
```

## wrap


```lua
function coroutine.wrap(f: fun(...any):...unknown)
  -> fun(...any):...unknown
```


Creates a new coroutine, with body `f`; `f` must be a function. Returns a function that resumes the coroutine each time it is called.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-coroutine.wrap"])

## yield


```lua
(async) function coroutine.yield(...any)
  -> ...any
```


Suspends the execution of the calling coroutine.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-coroutine.yield"])


---

# debug


```lua
debuglib
```


---

# debug.debug


```lua
function debug.debug()
```


---

# debug.getfenv


```lua
function debug.getfenv(o: any)
  -> table
```


---

# debug.gethook


```lua
function debug.gethook(co?: thread)
  -> hook: function
  2. mask: string
  3. count: integer
```


---

# debug.getinfo


```lua
function debug.getinfo(thread: thread, f: integer|fun(...any):...unknown, what?: string|"L"|"S"|"f"|"l"...(+3))
  -> debuginfo
```


---

# debug.getlocal


```lua
function debug.getlocal(thread: thread, f: integer|fun(...any):...unknown, index: integer)
  -> name: string
  2. value: any
```


---

# debug.getmetatable


```lua
function debug.getmetatable(object: any)
  -> metatable: table
```


---

# debug.getregistry


```lua
function debug.getregistry()
  -> table
```


---

# debug.getupvalue


```lua
function debug.getupvalue(f: fun(...any):...unknown, up: integer)
  -> name: string
  2. value: any
```


---

# debug.getuservalue


```lua
function debug.getuservalue(u: userdata)
  -> any
```


---

# debug.setcstacklimit


```lua
function debug.setcstacklimit(limit: integer)
  -> boolean|integer
```


---

# debug.setfenv


```lua
function debug.setfenv(object: <T>, env: table)
  -> object: <T>
```


---

# debug.sethook


```lua
function debug.sethook(thread: thread, hook: fun(...any):...unknown, mask: string|"c"|"l"|"r", count?: integer)
```


---

# debug.setlocal


```lua
function debug.setlocal(thread: thread, level: integer, index: integer, value: any)
  -> name: string
```


---

# debug.setmetatable


```lua
function debug.setmetatable(value: <T>, meta?: table)
  -> value: <T>
```


---

# debug.setupvalue


```lua
function debug.setupvalue(f: fun(...any):...unknown, up: integer, value: any)
  -> name: string
```


---

# debug.setuservalue


```lua
function debug.setuservalue(udata: userdata, value: any)
  -> udata: userdata
```


---

# debug.traceback


```lua
function debug.traceback(thread: thread, message?: any, level?: integer)
  -> message: string
```


---

# debug.upvalueid


```lua
function debug.upvalueid(f: fun(...any):...unknown, n: integer)
  -> id: lightuserdata
```


---

# debug.upvaluejoin


```lua
function debug.upvaluejoin(f1: fun(...any):...unknown, n1: integer, f2: fun(...any):...unknown, n2: integer)
```


---

# debuginfo

## activelines


```lua
table
```

## currentline


```lua
integer
```

## func


```lua
function
```

## istailcall


```lua
boolean
```

## isvararg


```lua
boolean
```

## lastlinedefined


```lua
integer
```

## linedefined


```lua
integer
```

## name


```lua
string
```

## namewhat


```lua
string
```

## nparams


```lua
integer
```

## nups


```lua
integer
```

## short_src


```lua
string
```

## source


```lua
string
```

## what


```lua
string
```


---

# debuglib

## debug


```lua
function debug.debug()
```


Enters an interactive mode with the user, running each string that the user enters.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.debug"])

## getfenv


```lua
function debug.getfenv(o: any)
  -> table
```


Returns the environment of object `o` .

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.getfenv"])

## gethook


```lua
function debug.gethook(co?: thread)
  -> hook: function
  2. mask: string
  3. count: integer
```


Returns the current hook settings of the thread.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.gethook"])

## getinfo


```lua
function debug.getinfo(thread: thread, f: integer|fun(...any):...unknown, what?: string|"L"|"S"|"f"|"l"...(+3))
  -> debuginfo
```


Returns a table with information about a function.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.getinfo"])


---

```lua
what:
   +> "n" -- `name` and `namewhat`
   +> "S" -- `source`, `short_src`, `linedefined`, `lastlinedefined`, and `what`
   +> "l" -- `currentline`
   +> "t" -- `istailcall`
   +> "u" -- `nups`, `nparams`, and `isvararg`
   +> "f" -- `func`
   +> "L" -- `activelines`
```

## getlocal


```lua
function debug.getlocal(thread: thread, f: integer|fun(...any):...unknown, index: integer)
  -> name: string
  2. value: any
```


Returns the name and the value of the local variable with index `local` of the function at level `f` of the stack.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.getlocal"])

## getmetatable


```lua
function debug.getmetatable(object: any)
  -> metatable: table
```


Returns the metatable of the given value.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.getmetatable"])

## getregistry


```lua
function debug.getregistry()
  -> table
```


Returns the registry table.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.getregistry"])

## getupvalue


```lua
function debug.getupvalue(f: fun(...any):...unknown, up: integer)
  -> name: string
  2. value: any
```


Returns the name and the value of the upvalue with index `up` of the function.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.getupvalue"])

## getuservalue


```lua
function debug.getuservalue(u: userdata)
  -> any
```


Returns the Lua value associated to u.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.getuservalue"])

## setcstacklimit


```lua
function debug.setcstacklimit(limit: integer)
  -> boolean|integer
```


### **Deprecated in `Lua 5.4.2`**

Sets a new limit for the C stack. This limit controls how deeply nested calls can go in Lua, with the intent of avoiding a stack overflow.

In case of success, this function returns the old limit. In case of error, it returns `false`.


[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.setcstacklimit"])

## setfenv


```lua
function debug.setfenv(object: <T>, env: table)
  -> object: <T>
```


Sets the environment of the given `object` to the given `table` .

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.setfenv"])

## sethook


```lua
function debug.sethook(thread: thread, hook: fun(...any):...unknown, mask: string|"c"|"l"|"r", count?: integer)
```


Sets the given function as a hook.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.sethook"])


---

```lua
mask:
   +> "c" -- Calls hook when Lua calls a function.
   +> "r" -- Calls hook when Lua returns from a function.
   +> "l" -- Calls hook when Lua enters a new line of code.
```

## setlocal


```lua
function debug.setlocal(thread: thread, level: integer, index: integer, value: any)
  -> name: string
```


Assigns the `value` to the local variable with index `local` of the function at `level` of the stack.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.setlocal"])

## setmetatable


```lua
function debug.setmetatable(value: <T>, meta?: table)
  -> value: <T>
```


Sets the metatable for the given value to the given table (which can be `nil`).

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.setmetatable"])

## setupvalue


```lua
function debug.setupvalue(f: fun(...any):...unknown, up: integer, value: any)
  -> name: string
```


Assigns the `value` to the upvalue with index `up` of the function.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.setupvalue"])

## setuservalue


```lua
function debug.setuservalue(udata: userdata, value: any)
  -> udata: userdata
```


Sets the given value as the Lua value associated to the given udata.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.setuservalue"])

## traceback


```lua
function debug.traceback(thread: thread, message?: any, level?: integer)
  -> message: string
```


Returns a string with a traceback of the call stack. The optional message string is appended at the beginning of the traceback.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.traceback"])

## upvalueid


```lua
function debug.upvalueid(f: fun(...any):...unknown, n: integer)
  -> id: lightuserdata
```


Returns a unique identifier (as a light userdata) for the upvalue numbered `n` from the given function.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.upvalueid"])

## upvaluejoin


```lua
function debug.upvaluejoin(f1: fun(...any):...unknown, n1: integer, f2: fun(...any):...unknown, n2: integer)
```


Make the `n1`-th upvalue of the Lua closure `f1` refer to the `n2`-th upvalue of the Lua closure `f2`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-debug.upvaluejoin"])


---

# dofile


```lua
function dofile(filename?: string)
  -> ...any
```


---

# error


```lua
function error(message: any, level?: integer)
```


---

# exitcode


---

# false


---

# ffi.VLA*


---

# ffi.VLS*


---

# ffi.cb*

## free


```lua
(method) ffi.cb*:free()
```

## set


```lua
(method) ffi.cb*:set(func: function)
```


---

# ffi.cdata*


---

# ffi.cdecl*

## byte


```lua
function string.byte(s: string|number, i?: integer, j?: integer)
  -> ...integer
```


Returns the internal numeric codes of the characters `s[i], s[i+1], ..., s[j]`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.byte"])

## char


```lua
function string.char(byte: integer, ...integer)
  -> string
```


Returns a string with length equal to the number of arguments, in which each character has the internal numeric code equal to its corresponding argument.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.char"])

## dump


```lua
function string.dump(f: fun(...any):...unknown, strip?: boolean)
  -> string
```


Returns a string containing a binary representation (a *binary chunk*) of the given function.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.dump"])

## find


```lua
function string.find(s: string|number, pattern: string|number, init?: integer, plain?: boolean)
  -> start: integer|nil
  2. end: integer|nil
  3. ...any
```


Miss locale <string.find>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.find"])

@*return* `start`

@*return* `end`

@*return* `...` — captured

## format


```lua
function string.format(s: string|number, ...any)
  -> string
```


Returns a formatted version of its variable number of arguments following the description given in its first argument.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.format"])

## gmatch


```lua
function string.gmatch(s: string|number, pattern: string|number)
  -> fun():string, ...unknown
```


Miss locale <string.gmatch>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.gmatch"])

## gsub


```lua
function string.gsub(s: string|number, pattern: string|number, repl: string|number|function|table, n?: integer)
  -> string
  2. count: integer
```


Miss locale <string.gsub>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.gsub"])

## len


```lua
function string.len(s: string|number)
  -> integer
```


Returns its length.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.len"])

## lower


```lua
function string.lower(s: string|number)
  -> string
```


Returns a copy of this string with all uppercase letters changed to lowercase.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.lower"])

## match


```lua
function string.match(s: string|number, pattern: string|number, init?: integer)
  -> ...any
```


Miss locale <string.match>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.match"])

## pack


```lua
function string.pack(fmt: string, v1: string|number, v2?: string|number, ...string|number)
  -> binary: string
```


Miss locale <string.pack>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.pack"])

## packsize


```lua
function string.packsize(fmt: string)
  -> integer
```


Miss locale <string.packsize>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.packsize"])

## rep


```lua
function string.rep(s: string|number, n: integer, sep?: string|number)
  -> string
```


Returns a string that is the concatenation of `n` copies of the string `s` separated by the string `sep`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.rep"])

## reverse


```lua
function string.reverse(s: string|number)
  -> string
```


Returns a string that is the string `s` reversed.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.reverse"])

## sub


```lua
function string.sub(s: string|number, i: integer, j?: integer)
  -> string
```


Returns the substring of the string that starts at `i` and continues until `j`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.sub"])

## unpack


```lua
function string.unpack(fmt: string, s: string, pos?: integer)
  -> ...any
```


Returns the values packed in string according to the format string `fmt` (see [§6.4.2](command:extension.lua.doc?["en-us/51/manual.html/6.4.2"])) .

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.unpack"])

## upper


```lua
function string.upper(s: string|number)
  -> string
```


Returns a copy of this string with all lowercase letters changed to uppercase.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.upper"])


---

# ffi.ct*


---

# ffi.ctype*


---

# ffi.namespace*

## [string]


```lua
function
```


---

# ffilib

## C


```lua
ffi.namespace*
```

## abi


```lua
function ffilib.abi(param: string)
  -> status: boolean
```

## alignof


```lua
function ffilib.alignof(ct: ffi.cdata*|ffi.cdecl*|ffi.ctype*)
  -> align: integer
```

## arch


```lua
string
```

## cast


```lua
function ffilib.cast(ct: ffi.cdata*|ffi.cdecl*|ffi.ctype*, init: any)
  -> cdata: ffi.cdata*
```

## cdef


```lua
function ffilib.cdef(def: string, params?: any, ...any)
```

## copy


```lua
function ffilib.copy(dst: any, src: any, len: integer)
```

## errno


```lua
function ffilib.errno(newerr?: integer)
  -> err: integer
```

## fill


```lua
function ffilib.fill(dst: any, len: integer, c?: any)
```

## gc


```lua
function ffilib.gc(cdata: ffi.cdata*, finalizer?: function)
  -> cdata: ffi.cdata*
```

## istype


```lua
function ffilib.istype(ct: ffi.cdata*|ffi.cdecl*|ffi.ctype*, obj: any)
  -> status: boolean
```

## load


```lua
function ffilib.load(name: string, global?: boolean)
  -> clib: ffi.namespace*
```

## metatype


```lua
function ffilib.metatype(ct: ffi.cdata*|ffi.cdecl*|ffi.ctype*, metatable: table)
  -> ctype: ffi.ctype*
```

## new


```lua
function ffilib.new(ct: ffi.cdata*|ffi.cdecl*|ffi.ctype*, nelem?: integer, init?: any, ...any)
  -> cdata: ffi.cdata*
```

## offsetof


```lua
function ffilib.offsetof(ct: ffi.cdata*|ffi.cdecl*|ffi.ctype*, field: string)
  -> ofs: integer
  2. bpos: integer?
  3. bsize: integer?
```

## os


```lua
string
```

## sizeof


```lua
function ffilib.sizeof(ct: ffi.cdata*|ffi.cdecl*|ffi.ctype*, nelem?: integer)
  -> size: integer|nil
```

## string


```lua
function ffilib.string(ptr: any, len?: integer)
  -> str: string
```

## typeof


```lua
function ffilib.typeof(ct: ffi.cdata*|ffi.cdecl*|ffi.ctype*, params?: any, ...any)
  -> ctype: ffi.ctype*
```


---

# file*

## close


```lua
(method) file*:close()
  -> suc: boolean?
  2. exitcode: ("exit"|"signal")?
  3. code: integer?
```


Close `file`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-file:close"])


```lua
exitcode:
    | "exit"
    | "signal"
```

## flush


```lua
(method) file*:flush()
```


Saves any written data to `file`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-file:flush"])

## lines


```lua
(method) file*:lines(...string|integer|"*L"|"*a"|"*l"...(+1))
  -> fun():any, ...unknown
```


------
```lua
for c in file:lines(...) do
    body
end
```


[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-file:lines"])


```lua
...(param):
    | "*n" -- Reads a numeral and returns it as number.
    | "*a" -- Reads the whole file.
   -> "*l" -- Reads the next line skipping the end of line.
    | "*L" -- Reads the next line keeping the end of line.
```

## read


```lua
(method) file*:read(...string|integer|"*L"|"*a"|"*l"...(+1))
  -> any
  2. ...any
```


Reads the `file`, according to the given formats, which specify what to read.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-file:read"])


```lua
...(param):
    | "*n" -- Reads a numeral and returns it as number.
    | "*a" -- Reads the whole file.
   -> "*l" -- Reads the next line skipping the end of line.
    | "*L" -- Reads the next line keeping the end of line.
```

## seek


```lua
(method) file*:seek(whence?: "cur"|"end"|"set", offset?: integer)
  -> offset: integer
  2. errmsg: string?
```


Sets and gets the file position, measured from the beginning of the file.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-file:seek"])


```lua
whence:
    | "set" -- Base is beginning of the file.
   -> "cur" -- Base is current position.
    | "end" -- Base is end of file.
```

## setvbuf


```lua
(method) file*:setvbuf(mode: "full"|"line"|"no", size?: integer)
```


Sets the buffering mode for an output file.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-file:setvbuf"])


```lua
mode:
    | "no" -- Output operation appears immediately.
    | "full" -- Performed only when the buffer is full.
    | "line" -- Buffered until a newline is output.
```

## write


```lua
(method) file*:write(...string|number)
  -> file*?
  2. errmsg: string?
```


Writes the value of each of its arguments to `file`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-file:write"])


---

# filetype


---

# function


---

# gcoptions


---

# getfenv


```lua
function getfenv(f?: integer|fun(...any):...unknown)
  -> table
```


---

# getmetatable


```lua
function getmetatable(object: any)
  -> metatable: table
```


---

# hookmask


---

# infowhat


---

# integer


---

# io


```lua
iolib
```


---

# io.close


```lua
function io.close(file?: file*)
  -> suc: boolean?
  2. exitcode: ("exit"|"signal")?
  3. code: integer?
```


---

# io.flush


```lua
function io.flush()
```


---

# io.input


```lua
function io.input(file: string|file*)
```


---

# io.lines


```lua
function io.lines(filename?: string, ...string|integer|"*L"|"*a"|"*l"...(+1))
  -> fun():any, ...unknown
```


---

# io.open


```lua
function io.open(filename: string, mode?: "a"|"a+"|"a+b"|"ab"|"r"...(+7))
  -> file*?
  2. errmsg: string?
```


---

# io.output


```lua
function io.output(file: string|file*)
```


---

# io.popen


```lua
function io.popen(prog: string, mode?: "r"|"w")
  -> file*?
  2. errmsg: string?
```


---

# io.read


```lua
function io.read(...string|integer|"*L"|"*a"|"*l"...(+1))
  -> any
  2. ...any
```


---

# io.tmpfile


```lua
function io.tmpfile()
  -> file*
```


---

# io.type


```lua
function io.type(file: file*)
  -> "closed file"|"file"|`nil`
```


---

# io.write


```lua
function io.write(...any)
  -> file*
  2. errmsg: string?
```


---

# iolib

## close


```lua
function io.close(file?: file*)
  -> suc: boolean?
  2. exitcode: ("exit"|"signal")?
  3. code: integer?
```


Close `file` or default output file.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.close"])


```lua
exitcode:
    | "exit"
    | "signal"
```

## flush


```lua
function io.flush()
```


Saves any written data to default output file.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.flush"])

## input


```lua
function io.input(file: string|file*)
```


Sets `file` as the default input file.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.input"])

## lines


```lua
function io.lines(filename?: string, ...string|integer|"*L"|"*a"|"*l"...(+1))
  -> fun():any, ...unknown
```


------
```lua
for c in io.lines(filename, ...) do
    body
end
```


[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.lines"])


```lua
...(param):
    | "*n" -- Reads a numeral and returns it as number.
    | "*a" -- Reads the whole file.
   -> "*l" -- Reads the next line skipping the end of line.
    | "*L" -- Reads the next line keeping the end of line.
```

## open


```lua
function io.open(filename: string, mode?: "a"|"a+"|"a+b"|"ab"|"r"...(+7))
  -> file*?
  2. errmsg: string?
```


Opens a file, in the mode specified in the string `mode`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.open"])


```lua
mode:
   -> "r" -- Read mode.
    | "w" -- Write mode.
    | "a" -- Append mode.
    | "r+" -- Update mode, all previous data is preserved.
    | "w+" -- Update mode, all previous data is erased.
    | "a+" -- Append update mode, previous data is preserved, writing is only allowed at the end of file.
    | "rb" -- Read mode. (in binary mode.)
    | "wb" -- Write mode. (in binary mode.)
    | "ab" -- Append mode. (in binary mode.)
    | "r+b" -- Update mode, all previous data is preserved. (in binary mode.)
    | "w+b" -- Update mode, all previous data is erased. (in binary mode.)
    | "a+b" -- Append update mode, previous data is preserved, writing is only allowed at the end of file. (in binary mode.)
```

## output


```lua
function io.output(file: string|file*)
```


Sets `file` as the default output file.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.output"])

## popen


```lua
function io.popen(prog: string, mode?: "r"|"w")
  -> file*?
  2. errmsg: string?
```


Starts program prog in a separated process.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.popen"])


```lua
mode:
    | "r" -- Read data from this program by `file`.
    | "w" -- Write data to this program by `file`.
```

## read


```lua
function io.read(...string|integer|"*L"|"*a"|"*l"...(+1))
  -> any
  2. ...any
```


Reads the `file`, according to the given formats, which specify what to read.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.read"])


```lua
...(param):
    | "*n" -- Reads a numeral and returns it as number.
    | "*a" -- Reads the whole file.
   -> "*l" -- Reads the next line skipping the end of line.
    | "*L" -- Reads the next line keeping the end of line.
```

## stderr


```lua
file*
```


standard error.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.stderr"])


## stdin


```lua
file*
```


standard input.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.stdin"])


## stdout


```lua
file*
```


standard output.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.stdout"])


## tmpfile


```lua
function io.tmpfile()
  -> file*
```


In case of success, returns a handle for a temporary file.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.tmpfile"])

## type


```lua
function io.type(file: file*)
  -> "closed file"|"file"|`nil`
```


Checks whether `obj` is a valid file handle.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.type"])


```lua
return #1:
    | "file" -- Is an open file handle.
    | "closed file" -- Is a closed file handle.
    | `nil` -- Is not a file handle.
```

## write


```lua
function io.write(...any)
  -> file*
  2. errmsg: string?
```


Writes the value of each of its arguments to default output file.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-io.write"])


---

# ipairs


```lua
function ipairs(t: <T:table>)
  -> fun(table: <V>[], i?: integer):integer, <V>
  2. <T:table>
  3. i: integer
```


---

# jit


```lua
jitlib
```


---

# jit.flush


```lua
function jit.flush(func: boolean|function, recursive?: boolean)
```


---

# jit.funcinfo.c

## ffid


```lua
integer|nil
```


---

# jit.funcinfo.lua


---

# jit.off


```lua
function jit.off(func: boolean|function, recursive?: boolean)
```


---

# jit.on


```lua
function jit.on(func: boolean|function, recursive?: boolean)
```


---

# jit.opt


```lua
table
```


---

# jit.opt.start


```lua
function jit.opt.start(...any)
```


---

# jit.snap


---

# jit.status


```lua
function jit.status()
  -> status: boolean
  2. ...string
```


---

# jit.traceinfo


---

# jitlib

## arch


```lua
string|'arm'|'arm64'|'arm64be'|'mips'...(+8)
```

## flush


```lua
function jit.flush(func: boolean|function, recursive?: boolean)
```

## off


```lua
function jit.off(func: boolean|function, recursive?: boolean)
```

## on


```lua
function jit.on(func: boolean|function, recursive?: boolean)
```

## opt


```lua
table
```

## os


```lua
'BSD'|'Linux'|'OSX'|'Other'|'POSIX'...(+1)
```

## status


```lua
function jit.status()
  -> status: boolean
  2. ...string
```

## version


```lua
string
```

## version_num


```lua
number
```


---

# lightuserdata


---

# load


```lua
function load(chunk: string|function, chunkname?: string, mode?: "b"|"bt"|"t", env?: table)
  -> function?
  2. error_message: string?
```


---

# loadfile


```lua
function loadfile(filename?: string, mode?: "b"|"bt"|"t", env?: table)
  -> function?
  2. error_message: string?
```


---

# loadmode


---

# loadstring


```lua
function loadstring(text: string, chunkname?: string)
  -> function?
  2. error_message: string?
```


---

# localecategory


---

# love


```lua
love
```


---

# love

## audio


```lua
love.audio
```


Provides an interface to create noise with the user's speakers.


[Open in Browser](https://love2d.org/wiki/love.audio)


## data


```lua
love.data
```


Provides functionality for creating and transforming data.


[Open in Browser](https://love2d.org/wiki/love.data)


## event


```lua
love.event
```


Manages events, like keypresses.


[Open in Browser](https://love2d.org/wiki/love.event)


## filesystem


```lua
love.filesystem
```


Provides an interface to the user's filesystem.


[Open in Browser](https://love2d.org/wiki/love.filesystem)


## font


```lua
love.font
```


Allows you to work with fonts.


[Open in Browser](https://love2d.org/wiki/love.font)


## getVersion


```lua
function love.getVersion()
  -> major: number
  2. minor: number
  3. revision: number
  4. codename: string
```


Gets the current running version of LÖVE.


[Open in Browser](https://love2d.org/wiki/love.getVersion)

@*return* `major` — The major version of LÖVE, i.e. 0 for version 0.9.1.

@*return* `minor` — The minor version of LÖVE, i.e. 9 for version 0.9.1.

@*return* `revision` — The revision version of LÖVE, i.e. 1 for version 0.9.1.

@*return* `codename` — The codename of the current version, i.e. 'Baby Inspector' for version 0.9.1.

## graphics


```lua
love.graphics
```


The primary responsibility for the love.graphics module is the drawing of lines, shapes, text, Images and other Drawable objects onto the screen. Its secondary responsibilities include loading external files (including Images and Fonts) into memory, creating specialized objects (such as ParticleSystems or Canvases) and managing screen geometry.

LÖVE's coordinate system is rooted in the upper-left corner of the screen, which is at location (0, 0). The x axis is horizontal: larger values are further to the right. The y axis is vertical: larger values are further towards the bottom.

In many cases, you draw images or shapes in terms of their upper-left corner.

Many of the functions are used to manipulate the graphics coordinate system, which is essentially the way coordinates are mapped to the display. You can change the position, scale, and even rotation in this way.


[Open in Browser](https://love2d.org/wiki/love.graphics)


## hasDeprecationOutput


```lua
function love.hasDeprecationOutput()
  -> enabled: boolean
```


Gets whether LÖVE displays warnings when using deprecated functionality. It is disabled by default in fused mode, and enabled by default otherwise.

When deprecation output is enabled, the first use of a formally deprecated LÖVE API will show a message at the bottom of the screen for a short time, and print the message to the console.


[Open in Browser](https://love2d.org/wiki/love.hasDeprecationOutput)

@*return* `enabled` — Whether deprecation output is enabled.

## image


```lua
love.image
```


Provides an interface to decode encoded image data.


[Open in Browser](https://love2d.org/wiki/love.image)


## isVersionCompatible


```lua
function love.isVersionCompatible(version: string)
  -> compatible: boolean
```


Gets whether the given version is compatible with the current running version of LÖVE.


[Open in Browser](https://love2d.org/wiki/love.isVersionCompatible)


---

@*param* `version` — The version to check (for example '11.3' or '0.10.2').

@*return* `compatible` — Whether the given version is compatible with the current running version of LÖVE.

## joystick


```lua
love.joystick
```


Provides an interface to the user's joystick.


[Open in Browser](https://love2d.org/wiki/love.joystick)


## keyboard


```lua
love.keyboard
```


Provides an interface to the user's keyboard.


[Open in Browser](https://love2d.org/wiki/love.keyboard)


## math


```lua
love.math
```


Provides system-independent mathematical functions.


[Open in Browser](https://love2d.org/wiki/love.math)


## mouse


```lua
love.mouse
```


Provides an interface to the user's mouse.


[Open in Browser](https://love2d.org/wiki/love.mouse)


## physics


```lua
love.physics
```


Can simulate 2D rigid body physics in a realistic manner. This module is based on Box2D, and this API corresponds to the Box2D API as closely as possible.


[Open in Browser](https://love2d.org/wiki/love.physics)


## setDeprecationOutput


```lua
function love.setDeprecationOutput(enable: boolean)
```


Sets whether LÖVE displays warnings when using deprecated functionality. It is disabled by default in fused mode, and enabled by default otherwise.

When deprecation output is enabled, the first use of a formally deprecated LÖVE API will show a message at the bottom of the screen for a short time, and print the message to the console.


[Open in Browser](https://love2d.org/wiki/love.setDeprecationOutput)

@*param* `enable` — Whether to enable or disable deprecation output.

## sound


```lua
love.sound
```


This module is responsible for decoding sound files. It can't play the sounds, see love.audio for that.


[Open in Browser](https://love2d.org/wiki/love.sound)


## system


```lua
love.system
```


Provides access to information about the user's system.


[Open in Browser](https://love2d.org/wiki/love.system)


## thread


```lua
love.thread
```


Allows you to work with threads.

Threads are separate Lua environments, running in parallel to the main code. As their code runs separately, they can be used to compute complex operations without adversely affecting the frame rate of the main thread. However, as they are separate environments, they cannot access the variables and functions of the main thread, and communication between threads is limited.

All LOVE objects (userdata) are shared among threads so you'll only have to send their references across threads. You may run into concurrency issues if you manipulate an object on multiple threads at the same time.

When a Thread is started, it only loads the love.thread module. Every other module has to be loaded with require.


[Open in Browser](https://love2d.org/wiki/love.thread)


## timer


```lua
love.timer
```


Provides an interface to the user's clock.


[Open in Browser](https://love2d.org/wiki/love.timer)


## touch


```lua
love.touch
```


Provides an interface to touch-screen presses.


[Open in Browser](https://love2d.org/wiki/love.touch)


## video


```lua
love.video
```


This module is responsible for decoding, controlling, and streaming video files.

It can't draw the videos, see love.graphics.newVideo and Video objects for that.


[Open in Browser](https://love2d.org/wiki/love.video)


## window


```lua
love.window
```


Provides an interface for modifying and retrieving information about the program's window.


[Open in Browser](https://love2d.org/wiki/love.window)



---

# love.AlignMode


---

# love.ArcType


---

# love.AreaSpreadDistribution


---

# love.BezierCurve

## evaluate


```lua
(method) love.BezierCurve:evaluate(t: number)
  -> x: number
  2. y: number
```


Evaluate Bézier curve at parameter t. The parameter must be between 0 and 1 (inclusive).

This function can be used to move objects along paths or tween parameters. However it should not be used to render the curve, see BezierCurve:render for that purpose.


[Open in Browser](https://love2d.org/wiki/BezierCurve:evaluate)

@*param* `t` — Where to evaluate the curve.

@*return* `x` — x coordinate of the curve at parameter t.

@*return* `y` — y coordinate of the curve at parameter t.

## getControlPoint


```lua
(method) love.BezierCurve:getControlPoint(i: number)
  -> x: number
  2. y: number
```


Get coordinates of the i-th control point. Indices start with 1.


[Open in Browser](https://love2d.org/wiki/BezierCurve:getControlPoint)

@*param* `i` — Index of the control point.

@*return* `x` — Position of the control point along the x axis.

@*return* `y` — Position of the control point along the y axis.

## getControlPointCount


```lua
(method) love.BezierCurve:getControlPointCount()
  -> count: number
```


Get the number of control points in the Bézier curve.


[Open in Browser](https://love2d.org/wiki/BezierCurve:getControlPointCount)

@*return* `count` — The number of control points.

## getDegree


```lua
(method) love.BezierCurve:getDegree()
  -> degree: number
```


Get degree of the Bézier curve. The degree is equal to number-of-control-points - 1.


[Open in Browser](https://love2d.org/wiki/BezierCurve:getDegree)

@*return* `degree` — Degree of the Bézier curve.

## getDerivative


```lua
(method) love.BezierCurve:getDerivative()
  -> derivative: love.BezierCurve
```


Get the derivative of the Bézier curve.

This function can be used to rotate sprites moving along a curve in the direction of the movement and compute the direction perpendicular to the curve at some parameter t.


[Open in Browser](https://love2d.org/wiki/BezierCurve:getDerivative)

@*return* `derivative` — The derivative curve.

## getSegment


```lua
(method) love.BezierCurve:getSegment(startpoint: number, endpoint: number)
  -> curve: love.BezierCurve
```


Gets a BezierCurve that corresponds to the specified segment of this BezierCurve.


[Open in Browser](https://love2d.org/wiki/BezierCurve:getSegment)

@*param* `startpoint` — The starting point along the curve. Must be between 0 and 1.

@*param* `endpoint` — The end of the segment. Must be between 0 and 1.

@*return* `curve` — A BezierCurve that corresponds to the specified segment.

## insertControlPoint


```lua
(method) love.BezierCurve:insertControlPoint(x: number, y: number, i?: number)
```


Insert control point as the new i-th control point. Existing control points from i onwards are pushed back by 1. Indices start with 1. Negative indices wrap around: -1 is the last control point, -2 the one before the last, etc.


[Open in Browser](https://love2d.org/wiki/BezierCurve:insertControlPoint)

@*param* `x` — Position of the control point along the x axis.

@*param* `y` — Position of the control point along the y axis.

@*param* `i` — Index of the control point.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## removeControlPoint


```lua
(method) love.BezierCurve:removeControlPoint(index: number)
```


Removes the specified control point.


[Open in Browser](https://love2d.org/wiki/BezierCurve:removeControlPoint)

@*param* `index` — The index of the control point to remove.

## render


```lua
(method) love.BezierCurve:render(depth?: number)
  -> coordinates: table
```


Get a list of coordinates to be used with love.graphics.line.

This function samples the Bézier curve using recursive subdivision. You can control the recursion depth using the depth parameter.

If you are just interested to know the position on the curve given a parameter, use BezierCurve:evaluate.


[Open in Browser](https://love2d.org/wiki/BezierCurve:render)

@*param* `depth` — Number of recursive subdivision steps.

@*return* `coordinates` — List of x,y-coordinate pairs of points on the curve.

## renderSegment


```lua
(method) love.BezierCurve:renderSegment(startpoint: number, endpoint: number, depth?: number)
  -> coordinates: table
```


Get a list of coordinates on a specific part of the curve, to be used with love.graphics.line.

This function samples the Bézier curve using recursive subdivision. You can control the recursion depth using the depth parameter.

If you are just need to know the position on the curve given a parameter, use BezierCurve:evaluate.


[Open in Browser](https://love2d.org/wiki/BezierCurve:renderSegment)

@*param* `startpoint` — The starting point along the curve. Must be between 0 and 1.

@*param* `endpoint` — The end of the segment to render. Must be between 0 and 1.

@*param* `depth` — Number of recursive subdivision steps.

@*return* `coordinates` — List of x,y-coordinate pairs of points on the specified part of the curve.

## rotate


```lua
(method) love.BezierCurve:rotate(angle: number, ox?: number, oy?: number)
```


Rotate the Bézier curve by an angle.


[Open in Browser](https://love2d.org/wiki/BezierCurve:rotate)

@*param* `angle` — Rotation angle in radians.

@*param* `ox` — X coordinate of the rotation center.

@*param* `oy` — Y coordinate of the rotation center.

## scale


```lua
(method) love.BezierCurve:scale(s: number, ox?: number, oy?: number)
```


Scale the Bézier curve by a factor.


[Open in Browser](https://love2d.org/wiki/BezierCurve:scale)

@*param* `s` — Scale factor.

@*param* `ox` — X coordinate of the scaling center.

@*param* `oy` — Y coordinate of the scaling center.

## setControlPoint


```lua
(method) love.BezierCurve:setControlPoint(i: number, x: number, y: number)
```


Set coordinates of the i-th control point. Indices start with 1.


[Open in Browser](https://love2d.org/wiki/BezierCurve:setControlPoint)

@*param* `i` — Index of the control point.

@*param* `x` — Position of the control point along the x axis.

@*param* `y` — Position of the control point along the y axis.

## translate


```lua
(method) love.BezierCurve:translate(dx: number, dy: number)
```


Move the Bézier curve by an offset.


[Open in Browser](https://love2d.org/wiki/BezierCurve:translate)

@*param* `dx` — Offset along the x axis.

@*param* `dy` — Offset along the y axis.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.BlendAlphaMode


---

# love.BlendMode


---

# love.Body

## applyAngularImpulse


```lua
(method) love.Body:applyAngularImpulse(impulse: number)
```


Applies an angular impulse to a body. This makes a single, instantaneous addition to the body momentum.

A body with with a larger mass will react less. The reaction does '''not''' depend on the timestep, and is equivalent to applying a force continuously for 1 second. Impulses are best used to give a single push to a body. For a continuous push to a body it is better to use Body:applyForce.


[Open in Browser](https://love2d.org/wiki/Body:applyAngularImpulse)

@*param* `impulse` — The impulse in kilogram-square meter per second.

## applyForce


```lua
(method) love.Body:applyForce(fx: number, fy: number)
```


Apply force to a Body.

A force pushes a body in a direction. A body with with a larger mass will react less. The reaction also depends on how long a force is applied: since the force acts continuously over the entire timestep, a short timestep will only push the body for a short time. Thus forces are best used for many timesteps to give a continuous push to a body (like gravity). For a single push that is independent of timestep, it is better to use Body:applyLinearImpulse.

If the position to apply the force is not given, it will act on the center of mass of the body. The part of the force not directed towards the center of mass will cause the body to spin (and depends on the rotational inertia).

Note that the force components and position must be given in world coordinates.


[Open in Browser](https://love2d.org/wiki/Body:applyForce)


---

@*param* `fx` — The x component of force to apply to the center of mass.

@*param* `fy` — The y component of force to apply to the center of mass.

## applyLinearImpulse


```lua
(method) love.Body:applyLinearImpulse(ix: number, iy: number)
```


Applies an impulse to a body.

This makes a single, instantaneous addition to the body momentum.

An impulse pushes a body in a direction. A body with with a larger mass will react less. The reaction does '''not''' depend on the timestep, and is equivalent to applying a force continuously for 1 second. Impulses are best used to give a single push to a body. For a continuous push to a body it is better to use Body:applyForce.

If the position to apply the impulse is not given, it will act on the center of mass of the body. The part of the impulse not directed towards the center of mass will cause the body to spin (and depends on the rotational inertia).

Note that the impulse components and position must be given in world coordinates.


[Open in Browser](https://love2d.org/wiki/Body:applyLinearImpulse)


---

@*param* `ix` — The x component of the impulse applied to the center of mass.

@*param* `iy` — The y component of the impulse applied to the center of mass.

## applyTorque


```lua
(method) love.Body:applyTorque(torque: number)
```


Apply torque to a body.

Torque is like a force that will change the angular velocity (spin) of a body. The effect will depend on the rotational inertia a body has.


[Open in Browser](https://love2d.org/wiki/Body:applyTorque)

@*param* `torque` — The torque to apply.

## destroy


```lua
(method) love.Body:destroy()
```


Explicitly destroys the Body and all fixtures and joints attached to it.

An error will occur if you attempt to use the object after calling this function. In 0.7.2, when you don't have time to wait for garbage collection, this function may be used to free the object immediately.


[Open in Browser](https://love2d.org/wiki/Body:destroy)

## getAngle


```lua
(method) love.Body:getAngle()
  -> angle: number
```


Get the angle of the body.

The angle is measured in radians. If you need to transform it to degrees, use math.deg.

A value of 0 radians will mean 'looking to the right'. Although radians increase counter-clockwise, the y axis points down so it becomes ''clockwise'' from our point of view.


[Open in Browser](https://love2d.org/wiki/Body:getAngle)

@*return* `angle` — The angle in radians.

## getAngularDamping


```lua
(method) love.Body:getAngularDamping()
  -> damping: number
```


Gets the Angular damping of the Body

The angular damping is the ''rate of decrease of the angular velocity over time'': A spinning body with no damping and no external forces will continue spinning indefinitely. A spinning body with damping will gradually stop spinning.

Damping is not the same as friction - they can be modelled together. However, only damping is provided by Box2D (and LOVE).

Damping parameters should be between 0 and infinity, with 0 meaning no damping, and infinity meaning full damping. Normally you will use a damping value between 0 and 0.1.


[Open in Browser](https://love2d.org/wiki/Body:getAngularDamping)

@*return* `damping` — The value of the angular damping.

## getAngularVelocity


```lua
(method) love.Body:getAngularVelocity()
  -> w: number
```


Get the angular velocity of the Body.

The angular velocity is the ''rate of change of angle over time''.

It is changed in World:update by applying torques, off centre forces/impulses, and angular damping. It can be set directly with Body:setAngularVelocity.

If you need the ''rate of change of position over time'', use Body:getLinearVelocity.


[Open in Browser](https://love2d.org/wiki/Body:getAngularVelocity)

@*return* `w` — The angular velocity in radians/second.

## getContacts


```lua
(method) love.Body:getContacts()
  -> contacts: table
```


Gets a list of all Contacts attached to the Body.


[Open in Browser](https://love2d.org/wiki/Body:getContacts)

@*return* `contacts` — A list with all contacts associated with the Body.

## getFixtures


```lua
(method) love.Body:getFixtures()
  -> fixtures: table
```


Returns a table with all fixtures.


[Open in Browser](https://love2d.org/wiki/Body:getFixtures)

@*return* `fixtures` — A sequence with all fixtures.

## getGravityScale


```lua
(method) love.Body:getGravityScale()
  -> scale: number
```


Returns the gravity scale factor.


[Open in Browser](https://love2d.org/wiki/Body:getGravityScale)

@*return* `scale` — The gravity scale factor.

## getInertia


```lua
(method) love.Body:getInertia()
  -> inertia: number
```


Gets the rotational inertia of the body.

The rotational inertia is how hard is it to make the body spin.


[Open in Browser](https://love2d.org/wiki/Body:getInertia)

@*return* `inertia` — The rotational inertial of the body.

## getJoints


```lua
(method) love.Body:getJoints()
  -> joints: table
```


Returns a table containing the Joints attached to this Body.


[Open in Browser](https://love2d.org/wiki/Body:getJoints)

@*return* `joints` — A sequence with the Joints attached to the Body.

## getLinearDamping


```lua
(method) love.Body:getLinearDamping()
  -> damping: number
```


Gets the linear damping of the Body.

The linear damping is the ''rate of decrease of the linear velocity over time''. A moving body with no damping and no external forces will continue moving indefinitely, as is the case in space. A moving body with damping will gradually stop moving.

Damping is not the same as friction - they can be modelled together.


[Open in Browser](https://love2d.org/wiki/Body:getLinearDamping)

@*return* `damping` — The value of the linear damping.

## getLinearVelocity


```lua
(method) love.Body:getLinearVelocity()
  -> x: number
  2. y: number
```


Gets the linear velocity of the Body from its center of mass.

The linear velocity is the ''rate of change of position over time''.

If you need the ''rate of change of angle over time'', use Body:getAngularVelocity.

If you need to get the linear velocity of a point different from the center of mass:

*  Body:getLinearVelocityFromLocalPoint allows you to specify the point in local coordinates.

*  Body:getLinearVelocityFromWorldPoint allows you to specify the point in world coordinates.

See page 136 of 'Essential Mathematics for Games and Interactive Applications' for definitions of local and world coordinates.


[Open in Browser](https://love2d.org/wiki/Body:getLinearVelocity)

@*return* `x` — The x-component of the velocity vector

@*return* `y` — The y-component of the velocity vector

## getLinearVelocityFromLocalPoint


```lua
(method) love.Body:getLinearVelocityFromLocalPoint(x: number, y: number)
  -> vx: number
  2. vy: number
```


Get the linear velocity of a point on the body.

The linear velocity for a point on the body is the velocity of the body center of mass plus the velocity at that point from the body spinning.

The point on the body must given in local coordinates. Use Body:getLinearVelocityFromWorldPoint to specify this with world coordinates.


[Open in Browser](https://love2d.org/wiki/Body:getLinearVelocityFromLocalPoint)

@*param* `x` — The x position to measure velocity.

@*param* `y` — The y position to measure velocity.

@*return* `vx` — The x component of velocity at point (x,y).

@*return* `vy` — The y component of velocity at point (x,y).

## getLinearVelocityFromWorldPoint


```lua
(method) love.Body:getLinearVelocityFromWorldPoint(x: number, y: number)
  -> vx: number
  2. vy: number
```


Get the linear velocity of a point on the body.

The linear velocity for a point on the body is the velocity of the body center of mass plus the velocity at that point from the body spinning.

The point on the body must given in world coordinates. Use Body:getLinearVelocityFromLocalPoint to specify this with local coordinates.


[Open in Browser](https://love2d.org/wiki/Body:getLinearVelocityFromWorldPoint)

@*param* `x` — The x position to measure velocity.

@*param* `y` — The y position to measure velocity.

@*return* `vx` — The x component of velocity at point (x,y).

@*return* `vy` — The y component of velocity at point (x,y).

## getLocalCenter


```lua
(method) love.Body:getLocalCenter()
  -> x: number
  2. y: number
```


Get the center of mass position in local coordinates.

Use Body:getWorldCenter to get the center of mass in world coordinates.


[Open in Browser](https://love2d.org/wiki/Body:getLocalCenter)

@*return* `x` — The x coordinate of the center of mass.

@*return* `y` — The y coordinate of the center of mass.

## getLocalPoint


```lua
(method) love.Body:getLocalPoint(worldX: number, worldY: number)
  -> localX: number
  2. localY: number
```


Transform a point from world coordinates to local coordinates.


[Open in Browser](https://love2d.org/wiki/Body:getLocalPoint)

@*param* `worldX` — The x position in world coordinates.

@*param* `worldY` — The y position in world coordinates.

@*return* `localX` — The x position in local coordinates.

@*return* `localY` — The y position in local coordinates.

## getLocalPoints


```lua
(method) love.Body:getLocalPoints(x1: number, y1: number, x2: number, y2: number, ...number)
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Transforms multiple points from world coordinates to local coordinates.


[Open in Browser](https://love2d.org/wiki/Body:getLocalPoints)

@*param* `x1` — (Argument) The x position of the first point.

@*param* `y1` — (Argument) The y position of the first point.

@*param* `x2` — (Argument) The x position of the second point.

@*param* `y2` — (Argument) The y position of the second point.

@*return* `x1` — (Result) The transformed x position of the first point.

@*return* `y1` — (Result) The transformed y position of the first point.

@*return* `x2` — (Result) The transformed x position of the second point.

@*return* `y2` — (Result) The transformed y position of the second point.

## getLocalVector


```lua
(method) love.Body:getLocalVector(worldX: number, worldY: number)
  -> localX: number
  2. localY: number
```


Transform a vector from world coordinates to local coordinates.


[Open in Browser](https://love2d.org/wiki/Body:getLocalVector)

@*param* `worldX` — The vector x component in world coordinates.

@*param* `worldY` — The vector y component in world coordinates.

@*return* `localX` — The vector x component in local coordinates.

@*return* `localY` — The vector y component in local coordinates.

## getMass


```lua
(method) love.Body:getMass()
  -> mass: number
```


Get the mass of the body.

Static bodies always have a mass of 0.


[Open in Browser](https://love2d.org/wiki/Body:getMass)

@*return* `mass` — The mass of the body (in kilograms).

## getMassData


```lua
(method) love.Body:getMassData()
  -> x: number
  2. y: number
  3. mass: number
  4. inertia: number
```


Returns the mass, its center, and the rotational inertia.


[Open in Browser](https://love2d.org/wiki/Body:getMassData)

@*return* `x` — The x position of the center of mass.

@*return* `y` — The y position of the center of mass.

@*return* `mass` — The mass of the body.

@*return* `inertia` — The rotational inertia.

## getPosition


```lua
(method) love.Body:getPosition()
  -> x: number
  2. y: number
```


Get the position of the body.

Note that this may not be the center of mass of the body.


[Open in Browser](https://love2d.org/wiki/Body:getPosition)

@*return* `x` — The x position.

@*return* `y` — The y position.

## getTransform


```lua
(method) love.Body:getTransform()
  -> x: number
  2. y: number
  3. angle: number
```


Get the position and angle of the body.

Note that the position may not be the center of mass of the body. An angle of 0 radians will mean 'looking to the right'. Although radians increase counter-clockwise, the y axis points down so it becomes clockwise from our point of view.


[Open in Browser](https://love2d.org/wiki/Body:getTransform)

@*return* `x` — The x component of the position.

@*return* `y` — The y component of the position.

@*return* `angle` — The angle in radians.

## getType


```lua
(method) love.Body:getType()
  -> type: "dynamic"|"kinematic"|"static"
```


Returns the type of the body.


[Open in Browser](https://love2d.org/wiki/Body:getType)

@*return* `type` — The body type.

```lua
-- 
-- The types of a Body.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/BodyType)
-- 
type:
    | "static" -- Static bodies do not move.
    | "dynamic" -- Dynamic bodies collide with all bodies.
    | "kinematic" -- Kinematic bodies only collide with dynamic bodies.
```

## getUserData


```lua
(method) love.Body:getUserData()
  -> value: any
```


Returns the Lua value associated with this Body.


[Open in Browser](https://love2d.org/wiki/Body:getUserData)

@*return* `value` — The Lua value associated with the Body.

## getWorld


```lua
(method) love.Body:getWorld()
  -> world: love.World
```


Gets the World the body lives in.


[Open in Browser](https://love2d.org/wiki/Body:getWorld)

@*return* `world` — The world the body lives in.

## getWorldCenter


```lua
(method) love.Body:getWorldCenter()
  -> x: number
  2. y: number
```


Get the center of mass position in world coordinates.

Use Body:getLocalCenter to get the center of mass in local coordinates.


[Open in Browser](https://love2d.org/wiki/Body:getWorldCenter)

@*return* `x` — The x coordinate of the center of mass.

@*return* `y` — The y coordinate of the center of mass.

## getWorldPoint


```lua
(method) love.Body:getWorldPoint(localX: number, localY: number)
  -> worldX: number
  2. worldY: number
```


Transform a point from local coordinates to world coordinates.


[Open in Browser](https://love2d.org/wiki/Body:getWorldPoint)

@*param* `localX` — The x position in local coordinates.

@*param* `localY` — The y position in local coordinates.

@*return* `worldX` — The x position in world coordinates.

@*return* `worldY` — The y position in world coordinates.

## getWorldPoints


```lua
(method) love.Body:getWorldPoints(x1: number, y1: number, x2: number, y2: number)
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Transforms multiple points from local coordinates to world coordinates.


[Open in Browser](https://love2d.org/wiki/Body:getWorldPoints)

@*param* `x1` — The x position of the first point.

@*param* `y1` — The y position of the first point.

@*param* `x2` — The x position of the second point.

@*param* `y2` — The y position of the second point.

@*return* `x1` — The transformed x position of the first point.

@*return* `y1` — The transformed y position of the first point.

@*return* `x2` — The transformed x position of the second point.

@*return* `y2` — The transformed y position of the second point.

## getWorldVector


```lua
(method) love.Body:getWorldVector(localX: number, localY: number)
  -> worldX: number
  2. worldY: number
```


Transform a vector from local coordinates to world coordinates.


[Open in Browser](https://love2d.org/wiki/Body:getWorldVector)

@*param* `localX` — The vector x component in local coordinates.

@*param* `localY` — The vector y component in local coordinates.

@*return* `worldX` — The vector x component in world coordinates.

@*return* `worldY` — The vector y component in world coordinates.

## getX


```lua
(method) love.Body:getX()
  -> x: number
```


Get the x position of the body in world coordinates.


[Open in Browser](https://love2d.org/wiki/Body:getX)

@*return* `x` — The x position in world coordinates.

## getY


```lua
(method) love.Body:getY()
  -> y: number
```


Get the y position of the body in world coordinates.


[Open in Browser](https://love2d.org/wiki/Body:getY)

@*return* `y` — The y position in world coordinates.

## isActive


```lua
(method) love.Body:isActive()
  -> status: boolean
```


Returns whether the body is actively used in the simulation.


[Open in Browser](https://love2d.org/wiki/Body:isActive)

@*return* `status` — True if the body is active or false if not.

## isAwake


```lua
(method) love.Body:isAwake()
  -> status: boolean
```


Returns the sleep status of the body.


[Open in Browser](https://love2d.org/wiki/Body:isAwake)

@*return* `status` — True if the body is awake or false if not.

## isBullet


```lua
(method) love.Body:isBullet()
  -> status: boolean
```


Get the bullet status of a body.

There are two methods to check for body collisions:

*  at their location when the world is updated (default)

*  using continuous collision detection (CCD)

The default method is efficient, but a body moving very quickly may sometimes jump over another body without producing a collision. A body that is set as a bullet will use CCD. This is less efficient, but is guaranteed not to jump when moving quickly.

Note that static bodies (with zero mass) always use CCD, so your walls will not let a fast moving body pass through even if it is not a bullet.


[Open in Browser](https://love2d.org/wiki/Body:isBullet)

@*return* `status` — The bullet status of the body.

## isDestroyed


```lua
(method) love.Body:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Body is destroyed. Destroyed bodies cannot be used.


[Open in Browser](https://love2d.org/wiki/Body:isDestroyed)

@*return* `destroyed` — Whether the Body is destroyed.

## isFixedRotation


```lua
(method) love.Body:isFixedRotation()
  -> fixed: boolean
```


Returns whether the body rotation is locked.


[Open in Browser](https://love2d.org/wiki/Body:isFixedRotation)

@*return* `fixed` — True if the body's rotation is locked or false if not.

## isSleepingAllowed


```lua
(method) love.Body:isSleepingAllowed()
  -> allowed: boolean
```


Returns the sleeping behaviour of the body.


[Open in Browser](https://love2d.org/wiki/Body:isSleepingAllowed)

@*return* `allowed` — True if the body is allowed to sleep or false if not.

## isTouching


```lua
(method) love.Body:isTouching(otherbody: love.Body)
  -> touching: boolean
```


Gets whether the Body is touching the given other Body.


[Open in Browser](https://love2d.org/wiki/Body:isTouching)

@*param* `otherbody` — The other body to check.

@*return* `touching` — True if this body is touching the other body, false otherwise.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## resetMassData


```lua
(method) love.Body:resetMassData()
```


Resets the mass of the body by recalculating it from the mass properties of the fixtures.


[Open in Browser](https://love2d.org/wiki/Body:resetMassData)

## setActive


```lua
(method) love.Body:setActive(active: boolean)
```


Sets whether the body is active in the world.

An inactive body does not take part in the simulation. It will not move or cause any collisions.


[Open in Browser](https://love2d.org/wiki/Body:setActive)

@*param* `active` — If the body is active or not.

## setAngle


```lua
(method) love.Body:setAngle(angle: number)
```


Set the angle of the body.

The angle is measured in radians. If you need to transform it from degrees, use math.rad.

A value of 0 radians will mean 'looking to the right'. Although radians increase counter-clockwise, the y axis points down so it becomes ''clockwise'' from our point of view.

It is possible to cause a collision with another body by changing its angle.


[Open in Browser](https://love2d.org/wiki/Body:setAngle)

@*param* `angle` — The angle in radians.

## setAngularDamping


```lua
(method) love.Body:setAngularDamping(damping: number)
```


Sets the angular damping of a Body

See Body:getAngularDamping for a definition of angular damping.

Angular damping can take any value from 0 to infinity. It is recommended to stay between 0 and 0.1, though. Other values will look unrealistic.


[Open in Browser](https://love2d.org/wiki/Body:setAngularDamping)

@*param* `damping` — The new angular damping.

## setAngularVelocity


```lua
(method) love.Body:setAngularVelocity(w: number)
```


Sets the angular velocity of a Body.

The angular velocity is the ''rate of change of angle over time''.

This function will not accumulate anything; any impulses previously applied since the last call to World:update will be lost.


[Open in Browser](https://love2d.org/wiki/Body:setAngularVelocity)

@*param* `w` — The new angular velocity, in radians per second

## setAwake


```lua
(method) love.Body:setAwake(awake: boolean)
```


Wakes the body up or puts it to sleep.


[Open in Browser](https://love2d.org/wiki/Body:setAwake)

@*param* `awake` — The body sleep status.

## setBullet


```lua
(method) love.Body:setBullet(status: boolean)
```


Set the bullet status of a body.

There are two methods to check for body collisions:

*  at their location when the world is updated (default)

*  using continuous collision detection (CCD)

The default method is efficient, but a body moving very quickly may sometimes jump over another body without producing a collision. A body that is set as a bullet will use CCD. This is less efficient, but is guaranteed not to jump when moving quickly.

Note that static bodies (with zero mass) always use CCD, so your walls will not let a fast moving body pass through even if it is not a bullet.


[Open in Browser](https://love2d.org/wiki/Body:setBullet)

@*param* `status` — The bullet status of the body.

## setFixedRotation


```lua
(method) love.Body:setFixedRotation(isFixed: boolean)
```


Set whether a body has fixed rotation.

Bodies with fixed rotation don't vary the speed at which they rotate. Calling this function causes the mass to be reset.


[Open in Browser](https://love2d.org/wiki/Body:setFixedRotation)

@*param* `isFixed` — Whether the body should have fixed rotation.

## setGravityScale


```lua
(method) love.Body:setGravityScale(scale: number)
```


Sets a new gravity scale factor for the body.


[Open in Browser](https://love2d.org/wiki/Body:setGravityScale)

@*param* `scale` — The new gravity scale factor.

## setInertia


```lua
(method) love.Body:setInertia(inertia: number)
```


Set the inertia of a body.


[Open in Browser](https://love2d.org/wiki/Body:setInertia)

@*param* `inertia` — The new moment of inertia, in kilograms * pixel squared.

## setLinearDamping


```lua
(method) love.Body:setLinearDamping(ld: number)
```


Sets the linear damping of a Body

See Body:getLinearDamping for a definition of linear damping.

Linear damping can take any value from 0 to infinity. It is recommended to stay between 0 and 0.1, though. Other values will make the objects look 'floaty'(if gravity is enabled).


[Open in Browser](https://love2d.org/wiki/Body:setLinearDamping)

@*param* `ld` — The new linear damping

## setLinearVelocity


```lua
(method) love.Body:setLinearVelocity(x: number, y: number)
```


Sets a new linear velocity for the Body.

This function will not accumulate anything; any impulses previously applied since the last call to World:update will be lost.


[Open in Browser](https://love2d.org/wiki/Body:setLinearVelocity)

@*param* `x` — The x-component of the velocity vector.

@*param* `y` — The y-component of the velocity vector.

## setMass


```lua
(method) love.Body:setMass(mass: number)
```


Sets a new body mass.


[Open in Browser](https://love2d.org/wiki/Body:setMass)

@*param* `mass` — The mass, in kilograms.

## setMassData


```lua
(method) love.Body:setMassData(x: number, y: number, mass: number, inertia: number)
```


Overrides the calculated mass data.


[Open in Browser](https://love2d.org/wiki/Body:setMassData)

@*param* `x` — The x position of the center of mass.

@*param* `y` — The y position of the center of mass.

@*param* `mass` — The mass of the body.

@*param* `inertia` — The rotational inertia.

## setPosition


```lua
(method) love.Body:setPosition(x: number, y: number)
```


Set the position of the body.

Note that this may not be the center of mass of the body.

This function cannot wake up the body.


[Open in Browser](https://love2d.org/wiki/Body:setPosition)

@*param* `x` — The x position.

@*param* `y` — The y position.

## setSleepingAllowed


```lua
(method) love.Body:setSleepingAllowed(allowed: boolean)
```


Sets the sleeping behaviour of the body. Should sleeping be allowed, a body at rest will automatically sleep. A sleeping body is not simulated unless it collided with an awake body. Be wary that one can end up with a situation like a floating sleeping body if the floor was removed.


[Open in Browser](https://love2d.org/wiki/Body:setSleepingAllowed)

@*param* `allowed` — True if the body is allowed to sleep or false if not.

## setTransform


```lua
(method) love.Body:setTransform(x: number, y: number, angle: number)
```


Set the position and angle of the body.

Note that the position may not be the center of mass of the body. An angle of 0 radians will mean 'looking to the right'. Although radians increase counter-clockwise, the y axis points down so it becomes clockwise from our point of view.

This function cannot wake up the body.


[Open in Browser](https://love2d.org/wiki/Body:setTransform)

@*param* `x` — The x component of the position.

@*param* `y` — The y component of the position.

@*param* `angle` — The angle in radians.

## setType


```lua
(method) love.Body:setType(type: "dynamic"|"kinematic"|"static")
```


Sets a new body type.


[Open in Browser](https://love2d.org/wiki/Body:setType)

@*param* `type` — The new type.

```lua
-- 
-- The types of a Body.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/BodyType)
-- 
type:
    | "static" -- Static bodies do not move.
    | "dynamic" -- Dynamic bodies collide with all bodies.
    | "kinematic" -- Kinematic bodies only collide with dynamic bodies.
```

## setUserData


```lua
(method) love.Body:setUserData(value: any)
```


Associates a Lua value with the Body.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Body:setUserData)

@*param* `value` — The Lua value to associate with the Body.

## setX


```lua
(method) love.Body:setX(x: number)
```


Set the x position of the body.

This function cannot wake up the body.


[Open in Browser](https://love2d.org/wiki/Body:setX)

@*param* `x` — The x position.

## setY


```lua
(method) love.Body:setY(y: number)
```


Set the y position of the body.

This function cannot wake up the body.


[Open in Browser](https://love2d.org/wiki/Body:setY)

@*param* `y` — The y position.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.BodyType


---

# love.BufferMode


---

# love.ByteData

## clone


```lua
(method) love.Data:clone()
  -> clone: love.Data
```


Creates a new copy of the Data object.


[Open in Browser](https://love2d.org/wiki/Data:clone)

@*return* `clone` — The new copy.

## getFFIPointer


```lua
(method) love.Data:getFFIPointer()
  -> pointer: ffi.cdata*
```


Gets an FFI pointer to the Data.

This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.


[Open in Browser](https://love2d.org/wiki/Data:getFFIPointer)

@*return* `pointer` — A raw void* pointer to the Data, or nil if FFI is unavailable.

## getPointer


```lua
(method) love.Data:getPointer()
  -> pointer: lightuserdata
```


Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.


[Open in Browser](https://love2d.org/wiki/Data:getPointer)

@*return* `pointer` — A raw pointer to the Data.

## getSize


```lua
(method) love.Data:getSize()
  -> size: number
```


Gets the Data's size in bytes.


[Open in Browser](https://love2d.org/wiki/Data:getSize)

@*return* `size` — The size of the Data in bytes.

## getString


```lua
(method) love.Data:getString()
  -> data: string
```


Gets the full Data as a string.


[Open in Browser](https://love2d.org/wiki/Data:getString)

@*return* `data` — The raw data.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.Canvas

## generateMipmaps


```lua
(method) love.Canvas:generateMipmaps()
```


Generates mipmaps for the Canvas, based on the contents of the highest-resolution mipmap level.

The Canvas must be created with mipmaps set to a MipmapMode other than 'none' for this function to work. It should only be called while the Canvas is not the active render target.

If the mipmap mode is set to 'auto', this function is automatically called inside love.graphics.setCanvas when switching from this Canvas to another Canvas or to the main screen.


[Open in Browser](https://love2d.org/wiki/Canvas:generateMipmaps)

## getDPIScale


```lua
(method) love.Texture:getDPIScale()
  -> dpiscale: number
```


Gets the DPI scale factor of the Texture.

The DPI scale factor represents relative pixel density. A DPI scale factor of 2 means the texture has twice the pixel density in each dimension (4 times as many pixels in the same area) compared to a texture with a DPI scale factor of 1.

For example, a texture with pixel dimensions of 100x100 with a DPI scale factor of 2 will be drawn as if it was 50x50. This is useful with high-dpi /  retina displays to easily allow swapping out higher or lower pixel density Images and Canvases without needing any extra manual scaling logic.


[Open in Browser](https://love2d.org/wiki/Texture:getDPIScale)

@*return* `dpiscale` — The DPI scale factor of the Texture.

## getDepth


```lua
(method) love.Texture:getDepth()
  -> depth: number
```


Gets the depth of a Volume Texture. Returns 1 for 2D, Cubemap, and Array textures.


[Open in Browser](https://love2d.org/wiki/Texture:getDepth)

@*return* `depth` — The depth of the volume Texture.

## getDepthSampleMode


```lua
(method) love.Texture:getDepthSampleMode()
  -> compare: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3)
```


Gets the comparison mode used when sampling from a depth texture in a shader.

Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.


[Open in Browser](https://love2d.org/wiki/Texture:getDepthSampleMode)

@*return* `compare` — The comparison mode used when sampling from this texture in a shader, or nil if setDepthSampleMode has not been called on this Texture.

```lua
-- 
-- Different types of per-pixel stencil test and depth test comparisons. The pixels of an object will be drawn if the comparison succeeds, for each pixel that the object touches.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CompareMode)
-- 
compare:
    | "equal" -- * stencil tests: the stencil value of the pixel must be equal to the supplied value.
              -- * depth tests: the depth value of the drawn object at that pixel must be equal to the existing depth value of that pixel.
    | "notequal" -- * stencil tests: the stencil value of the pixel must not be equal to the supplied value.
                 -- * depth tests: the depth value of the drawn object at that pixel must not be equal to the existing depth value of that pixel.
    | "less" -- * stencil tests: the stencil value of the pixel must be less than the supplied value.
             -- * depth tests: the depth value of the drawn object at that pixel must be less than the existing depth value of that pixel.
    | "lequal" -- * stencil tests: the stencil value of the pixel must be less than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be less than or equal to the existing depth value of that pixel.
    | "gequal" -- * stencil tests: the stencil value of the pixel must be greater than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be greater than or equal to the existing depth value of that pixel.
    | "greater" -- * stencil tests: the stencil value of the pixel must be greater than the supplied value.
                -- * depth tests: the depth value of the drawn object at that pixel must be greater than the existing depth value of that pixel.
    | "never" -- Objects will never be drawn.
    | "always" -- Objects will always be drawn. Effectively disables the depth or stencil test.
```

## getDimensions


```lua
(method) love.Texture:getDimensions()
  -> width: number
  2. height: number
```


Gets the width and height of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getDimensions)

@*return* `width` — The width of the Texture.

@*return* `height` — The height of the Texture.

## getFilter


```lua
(method) love.Texture:getFilter()
  -> min: "linear"|"nearest"
  2. mag: "linear"|"nearest"
  3. anisotropy: number
```


Gets the filter mode of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getFilter)

@*return* `min` — Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).

@*return* `mag` — Filter mode to use when magnifying the texture (rendering it at a smaller size on-screen than its size in pixels).

@*return* `anisotropy` — Maximum amount of anisotropic filtering used.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
min:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.

-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mag:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## getFormat


```lua
(method) love.Texture:getFormat()
  -> format: "ASTC10x10"|"ASTC10x5"|"ASTC10x6"|"ASTC10x8"|"ASTC12x10"...(+59)
```


Gets the pixel format of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getFormat)

@*return* `format` — The pixel format the Texture was created with.

```lua
-- 
-- Pixel formats for Textures, ImageData, and CompressedImageData.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/PixelFormat)
-- 
format:
    | "unknown" -- Indicates unknown pixel format, used internally.
    | "normal" -- Alias for rgba8, or srgba8 if gamma-correct rendering is enabled.
    | "hdr" -- A format suitable for high dynamic range content - an alias for the rgba16f format, normally.
    | "r8" -- Single-channel (red component) format (8 bpp).
    | "rg8" -- Two channels (red and green components) with 8 bits per channel (16 bpp).
    | "rgba8" -- 8 bits per channel (32 bpp) RGBA. Color channel values range from 0-255 (0-1 in shaders).
    | "srgba8" -- gamma-correct version of rgba8.
    | "r16" -- Single-channel (red component) format (16 bpp).
    | "rg16" -- Two channels (red and green components) with 16 bits per channel (32 bpp).
    | "rgba16" -- 16 bits per channel (64 bpp) RGBA. Color channel values range from 0-65535 (0-1 in shaders).
    | "r16f" -- Floating point single-channel format (16 bpp). Color values can range from [-65504, +65504].
    | "rg16f" -- Floating point two-channel format with 16 bits per channel (32 bpp). Color values can range from [-65504, +65504].
    | "rgba16f" -- Floating point RGBA with 16 bits per channel (64 bpp). Color values can range from [-65504, +65504].
    | "r32f" -- Floating point single-channel format (32 bpp).
    | "rg32f" -- Floating point two-channel format with 32 bits per channel (64 bpp).
    | "rgba32f" -- Floating point RGBA with 32 bits per channel (128 bpp).
    | "la8" -- Same as rg8, but accessed as (L, L, L, A)
    | "rgba4" -- 4 bits per channel (16 bpp) RGBA.
    | "rgb5a1" -- RGB with 5 bits each, and a 1-bit alpha channel (16 bpp).
    | "rgb565" -- RGB with 5, 6, and 5 bits each, respectively (16 bpp). There is no alpha channel in this format.
    | "rgb10a2" -- RGB with 10 bits per channel, and a 2-bit alpha channel (32 bpp).
    | "rg11b10f" -- Floating point RGB with 11 bits in the red and green channels, and 10 bits in the blue channel (32 bpp). There is no alpha channel. Color values can range from [0, +65024].
    | "stencil8" -- No depth buffer and 8-bit stencil buffer.
    | "depth16" -- 16-bit depth buffer and no stencil buffer.
    | "depth24" -- 24-bit depth buffer and no stencil buffer.
    | "depth32f" -- 32-bit float depth buffer and no stencil buffer.
    | "depth24stencil8" -- 24-bit depth buffer and 8-bit stencil buffer.
    | "depth32fstencil8" -- 32-bit float depth buffer and 8-bit stencil buffer.
    | "DXT1" -- The DXT1 format. RGB data at 4 bits per pixel (compared to 32 bits for ImageData and regular Images.) Suitable for fully opaque images on desktop systems.
    | "DXT3" -- The DXT3 format. RGBA data at 8 bits per pixel. Smooth variations in opacity do not mix well with this format.
    | "DXT5" -- The DXT5 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on desktop systems.
    | "BC4" -- The BC4 format (also known as 3Dc+ or ATI1.) Stores just the red channel, at 4 bits per pixel.
    | "BC4s" -- The signed variant of the BC4 format. Same as above but pixel values in the texture are in the range of 1 instead of 1 in shaders.
    | "BC5" -- The BC5 format (also known as 3Dc or ATI2.) Stores red and green channels at 8 bits per pixel.
    | "BC5s" -- The signed variant of the BC5 format.
    | "BC6h" -- The BC6H format. Stores half-precision floating-point RGB data in the range of 65504 at 8 bits per pixel. Suitable for HDR images on desktop systems.
    | "BC6hs" -- The signed variant of the BC6H format. Stores RGB data in the range of +65504.
    | "BC7" -- The BC7 format (also known as BPTC.) Stores RGB or RGBA data at 8 bits per pixel.
    | "ETC1" -- The ETC1 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on older Android devices.
    | "ETC2rgb" -- The RGB variant of the ETC2 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on newer mobile devices.
    | "ETC2rgba" -- The RGBA variant of the ETC2 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on newer mobile devices.
    | "ETC2rgba1" -- The RGBA variant of the ETC2 format where pixels are either fully transparent or fully opaque. RGBA data at 4 bits per pixel.
    | "EACr" -- The single-channel variant of the EAC format. Stores just the red channel, at 4 bits per pixel.
    | "EACrs" -- The signed single-channel variant of the EAC format. Same as above but pixel values in the texture are in the range of 1 instead of 1 in shaders.
    | "EACrg" -- The two-channel variant of the EAC format. Stores red and green channels at 8 bits per pixel.
    | "EACrgs" -- The signed two-channel variant of the EAC format.
    | "PVR1rgb2" -- The 2 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 2 bits per pixel. Textures compressed with PVRTC1 formats must be square and power-of-two sized.
    | "PVR1rgb4" -- The 4 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 4 bits per pixel.
    | "PVR1rgba2" -- The 2 bit per pixel RGBA variant of the PVRTC1 format.
    | "PVR1rgba4" -- The 4 bit per pixel RGBA variant of the PVRTC1 format.
    | "ASTC4x4" -- The 4x4 pixels per block variant of the ASTC format. RGBA data at 8 bits per pixel.
    | "ASTC5x4" -- The 5x4 pixels per block variant of the ASTC format. RGBA data at 6.4 bits per pixel.
    | "ASTC5x5" -- The 5x5 pixels per block variant of the ASTC format. RGBA data at 5.12 bits per pixel.
    | "ASTC6x5" -- The 6x5 pixels per block variant of the ASTC format. RGBA data at 4.27 bits per pixel.
    | "ASTC6x6" -- The 6x6 pixels per block variant of the ASTC format. RGBA data at 3.56 bits per pixel.
    | "ASTC8x5" -- The 8x5 pixels per block variant of the ASTC format. RGBA data at 3.2 bits per pixel.
    | "ASTC8x6" -- The 8x6 pixels per block variant of the ASTC format. RGBA data at 2.67 bits per pixel.
    | "ASTC8x8" -- The 8x8 pixels per block variant of the ASTC format. RGBA data at 2 bits per pixel.
    | "ASTC10x5" -- The 10x5 pixels per block variant of the ASTC format. RGBA data at 2.56 bits per pixel.
    | "ASTC10x6" -- The 10x6 pixels per block variant of the ASTC format. RGBA data at 2.13 bits per pixel.
    | "ASTC10x8" -- The 10x8 pixels per block variant of the ASTC format. RGBA data at 1.6 bits per pixel.
    | "ASTC10x10" -- The 10x10 pixels per block variant of the ASTC format. RGBA data at 1.28 bits per pixel.
    | "ASTC12x10" -- The 12x10 pixels per block variant of the ASTC format. RGBA data at 1.07 bits per pixel.
    | "ASTC12x12" -- The 12x12 pixels per block variant of the ASTC format. RGBA data at 0.89 bits per pixel.
```

## getHeight


```lua
(method) love.Texture:getHeight()
  -> height: number
```


Gets the height of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getHeight)

@*return* `height` — The height of the Texture.

## getLayerCount


```lua
(method) love.Texture:getLayerCount()
  -> layers: number
```


Gets the number of layers / slices in an Array Texture. Returns 1 for 2D, Cubemap, and Volume textures.


[Open in Browser](https://love2d.org/wiki/Texture:getLayerCount)

@*return* `layers` — The number of layers in the Array Texture.

## getMSAA


```lua
(method) love.Canvas:getMSAA()
  -> samples: number
```


Gets the number of multisample antialiasing (MSAA) samples used when drawing to the Canvas.

This may be different than the number used as an argument to love.graphics.newCanvas if the system running LÖVE doesn't support that number.


[Open in Browser](https://love2d.org/wiki/Canvas:getMSAA)

@*return* `samples` — The number of multisample antialiasing samples used by the canvas when drawing to it.

## getMipmapCount


```lua
(method) love.Texture:getMipmapCount()
  -> mipmaps: number
```


Gets the number of mipmaps contained in the Texture. If the texture was not created with mipmaps, it will return 1.


[Open in Browser](https://love2d.org/wiki/Texture:getMipmapCount)

@*return* `mipmaps` — The number of mipmaps in the Texture.

## getMipmapFilter


```lua
(method) love.Texture:getMipmapFilter()
  -> mode: "linear"|"nearest"
  2. sharpness: number
```


Gets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.


[Open in Browser](https://love2d.org/wiki/Texture:getMipmapFilter)

@*return* `mode` — The filter mode used in between mipmap levels. nil if mipmap filtering is not enabled.

@*return* `sharpness` — Value used to determine whether the image should use more or less detailed mipmap levels than normal when drawing.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mode:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## getMipmapMode


```lua
(method) love.Canvas:getMipmapMode()
  -> mode: "auto"|"manual"|"none"
```


Gets the MipmapMode this Canvas was created with.


[Open in Browser](https://love2d.org/wiki/Canvas:getMipmapMode)

@*return* `mode` — The mipmap mode this Canvas was created with.

```lua
-- 
-- Controls whether a Canvas has mipmaps, and its behaviour when it does.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/MipmapMode)
-- 
mode:
    | "none" -- The Canvas has no mipmaps.
    | "auto" -- The Canvas has mipmaps. love.graphics.setCanvas can be used to render to a specific mipmap level, or Canvas:generateMipmaps can (re-)compute all mipmap levels based on the base level.
    | "manual" -- The Canvas has mipmaps, and all mipmap levels will automatically be recomputed when switching away from the Canvas with love.graphics.setCanvas.
```

## getPixelDimensions


```lua
(method) love.Texture:getPixelDimensions()
  -> pixelwidth: number
  2. pixelheight: number
```


Gets the width and height in pixels of the Texture.

Texture:getDimensions gets the dimensions of the texture in units scaled by the texture's DPI scale factor, rather than pixels. Use getDimensions for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelDimensions only when dealing specifically with pixels, for example when using Canvas:newImageData.


[Open in Browser](https://love2d.org/wiki/Texture:getPixelDimensions)

@*return* `pixelwidth` — The width of the Texture, in pixels.

@*return* `pixelheight` — The height of the Texture, in pixels.

## getPixelHeight


```lua
(method) love.Texture:getPixelHeight()
  -> pixelheight: number
```


Gets the height in pixels of the Texture.

DPI scale factor, rather than pixels. Use getHeight for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelHeight only when dealing specifically with pixels, for example when using Canvas:newImageData.


[Open in Browser](https://love2d.org/wiki/Texture:getPixelHeight)

@*return* `pixelheight` — The height of the Texture, in pixels.

## getPixelWidth


```lua
(method) love.Texture:getPixelWidth()
  -> pixelwidth: number
```


Gets the width in pixels of the Texture.

DPI scale factor, rather than pixels. Use getWidth for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelWidth only when dealing specifically with pixels, for example when using Canvas:newImageData.


[Open in Browser](https://love2d.org/wiki/Texture:getPixelWidth)

@*return* `pixelwidth` — The width of the Texture, in pixels.

## getTextureType


```lua
(method) love.Texture:getTextureType()
  -> texturetype: "2d"|"array"|"cube"|"volume"
```


Gets the type of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getTextureType)

@*return* `texturetype` — The type of the Texture.

```lua
-- 
-- Types of textures (2D, cubemap, etc.)
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/TextureType)
-- 
texturetype:
    | "2d" -- Regular 2D texture with width and height.
    | "array" -- Several same-size 2D textures organized into a single object. Similar to a texture atlas / sprite sheet, but avoids sprite bleeding and other issues.
    | "cube" -- Cubemap texture with 6 faces. Requires a custom shader (and Shader:send) to use. Sampling from a cube texture in a shader takes a 3D direction vector instead of a texture coordinate.
    | "volume" -- 3D texture with width, height, and depth. Requires a custom shader to use. Volume textures can have texture filtering applied along the 3rd axis.
```

## getWidth


```lua
(method) love.Texture:getWidth()
  -> width: number
```


Gets the width of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getWidth)

@*return* `width` — The width of the Texture.

## getWrap


```lua
(method) love.Texture:getWrap()
  -> horiz: "clamp"|"clampzero"|"mirroredrepeat"|"repeat"
  2. vert: "clamp"|"clampzero"|"mirroredrepeat"|"repeat"
  3. depth: "clamp"|"clampzero"|"mirroredrepeat"|"repeat"
```


Gets the wrapping properties of a Texture.

This function returns the currently set horizontal and vertical wrapping modes for the texture.


[Open in Browser](https://love2d.org/wiki/Texture:getWrap)

@*return* `horiz` — Horizontal wrapping mode of the texture.

@*return* `vert` — Vertical wrapping mode of the texture.

@*return* `depth` — Wrapping mode for the z-axis of a Volume texture.

```lua
-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
horiz:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)

-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
vert:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)

-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
depth:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)
```

## isReadable


```lua
(method) love.Texture:isReadable()
  -> readable: boolean
```


Gets whether the Texture can be drawn and sent to a Shader.

Canvases created with stencil and/or depth PixelFormats are not readable by default, unless readable=true is specified in the settings table passed into love.graphics.newCanvas.

Non-readable Canvases can still be rendered to.


[Open in Browser](https://love2d.org/wiki/Texture:isReadable)

@*return* `readable` — Whether the Texture is readable.

## newImageData


```lua
(method) love.Canvas:newImageData()
  -> data: love.ImageData
```


Generates ImageData from the contents of the Canvas.


[Open in Browser](https://love2d.org/wiki/Canvas:newImageData)


---

@*return* `data` — The new ImageData made from the Canvas' contents.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## renderTo


```lua
(method) love.Canvas:renderTo(func: function)
```


Render to the Canvas using a function.

This is a shortcut to love.graphics.setCanvas:

canvas:renderTo( func )

is the same as

love.graphics.setCanvas( canvas )

func()

love.graphics.setCanvas()


[Open in Browser](https://love2d.org/wiki/Canvas:renderTo)

@*param* `func` — A function performing drawing operations.

## setDepthSampleMode


```lua
(method) love.Texture:setDepthSampleMode(compare: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3))
```


Sets the comparison mode used when sampling from a depth texture in a shader. Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.

When using a depth texture with a comparison mode set in a shader, it must be declared as a sampler2DShadow and used in a GLSL 3 Shader. The result of accessing the texture in the shader will return a float between 0 and 1, proportional to the number of samples (up to 4 samples will be used if bilinear filtering is enabled) that passed the test set by the comparison operation.

Depth texture comparison can only be used with readable depth-formatted Canvases.


[Open in Browser](https://love2d.org/wiki/Texture:setDepthSampleMode)

@*param* `compare` — The comparison mode used when sampling from this texture in a shader.

```lua
-- 
-- Different types of per-pixel stencil test and depth test comparisons. The pixels of an object will be drawn if the comparison succeeds, for each pixel that the object touches.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CompareMode)
-- 
compare:
    | "equal" -- * stencil tests: the stencil value of the pixel must be equal to the supplied value.
              -- * depth tests: the depth value of the drawn object at that pixel must be equal to the existing depth value of that pixel.
    | "notequal" -- * stencil tests: the stencil value of the pixel must not be equal to the supplied value.
                 -- * depth tests: the depth value of the drawn object at that pixel must not be equal to the existing depth value of that pixel.
    | "less" -- * stencil tests: the stencil value of the pixel must be less than the supplied value.
             -- * depth tests: the depth value of the drawn object at that pixel must be less than the existing depth value of that pixel.
    | "lequal" -- * stencil tests: the stencil value of the pixel must be less than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be less than or equal to the existing depth value of that pixel.
    | "gequal" -- * stencil tests: the stencil value of the pixel must be greater than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be greater than or equal to the existing depth value of that pixel.
    | "greater" -- * stencil tests: the stencil value of the pixel must be greater than the supplied value.
                -- * depth tests: the depth value of the drawn object at that pixel must be greater than the existing depth value of that pixel.
    | "never" -- Objects will never be drawn.
    | "always" -- Objects will always be drawn. Effectively disables the depth or stencil test.
```

## setFilter


```lua
(method) love.Texture:setFilter(min: "linear"|"nearest", mag?: "linear"|"nearest", anisotropy?: number)
```


Sets the filter mode of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:setFilter)

@*param* `min` — Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).

@*param* `mag` — Filter mode to use when magnifying the texture (rendering it at a larger size on-screen than its size in pixels).

@*param* `anisotropy` — Maximum amount of anisotropic filtering to use.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
min:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.

-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mag:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## setMipmapFilter


```lua
(method) love.Texture:setMipmapFilter(filtermode: "linear"|"nearest", sharpness?: number)
```


Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.

Mipmapping is useful when drawing a texture at a reduced scale. It can improve performance and reduce aliasing issues.

In created with the mipmaps flag enabled for the mipmap filter to have any effect. In versions prior to 0.10.0 it's best to call this method directly after creating the image with love.graphics.newImage, to avoid bugs in certain graphics drivers.

Due to hardware restrictions and driver bugs, in versions prior to 0.10.0 images that weren't loaded from a CompressedData must have power-of-two dimensions (64x64, 512x256, etc.) to use mipmaps.


[Open in Browser](https://love2d.org/wiki/Texture:setMipmapFilter)


---

@*param* `filtermode` — The filter mode to use in between mipmap levels. 'nearest' will often give better performance.

@*param* `sharpness` — A positive sharpness value makes the texture use a more detailed mipmap level when drawing, at the expense of performance. A negative value does the reverse.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
filtermode:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## setWrap


```lua
(method) love.Texture:setWrap(horiz: "clamp"|"clampzero"|"mirroredrepeat"|"repeat", vert?: "clamp"|"clampzero"|"mirroredrepeat"|"repeat", depth?: "clamp"|"clampzero"|"mirroredrepeat"|"repeat")
```


Sets the wrapping properties of a Texture.

This function sets the way a Texture is repeated when it is drawn with a Quad that is larger than the texture's extent, or when a custom Shader is used which uses texture coordinates outside of [0, 1]. A texture may be clamped or set to repeat in both horizontal and vertical directions.

Clamped textures appear only once (with the edges of the texture stretching to fill the extent of the Quad), whereas repeated ones repeat as many times as there is room in the Quad.


[Open in Browser](https://love2d.org/wiki/Texture:setWrap)

@*param* `horiz` — Horizontal wrapping mode of the texture.

@*param* `vert` — Vertical wrapping mode of the texture.

@*param* `depth` — Wrapping mode for the z-axis of a Volume texture.

```lua
-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
horiz:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)

-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
vert:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)

-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
depth:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)
```

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.ChainShape

## computeAABB


```lua
(method) love.Shape:computeAABB(tx: number, ty: number, tr: number, childIndex?: number)
  -> topLeftX: number
  2. topLeftY: number
  3. bottomRightX: number
  4. bottomRightY: number
```


Returns the points of the bounding box for the transformed shape.


[Open in Browser](https://love2d.org/wiki/Shape:computeAABB)

@*param* `tx` — The translation of the shape on the x-axis.

@*param* `ty` — The translation of the shape on the y-axis.

@*param* `tr` — The shape rotation.

@*param* `childIndex` — The index of the child to compute the bounding box of.

@*return* `topLeftX` — The x position of the top-left point.

@*return* `topLeftY` — The y position of the top-left point.

@*return* `bottomRightX` — The x position of the bottom-right point.

@*return* `bottomRightY` — The y position of the bottom-right point.

## computeMass


```lua
(method) love.Shape:computeMass(density: number)
  -> x: number
  2. y: number
  3. mass: number
  4. inertia: number
```


Computes the mass properties for the shape with the specified density.


[Open in Browser](https://love2d.org/wiki/Shape:computeMass)

@*param* `density` — The shape density.

@*return* `x` — The x postition of the center of mass.

@*return* `y` — The y postition of the center of mass.

@*return* `mass` — The mass of the shape.

@*return* `inertia` — The rotational inertia.

## getChildCount


```lua
(method) love.Shape:getChildCount()
  -> count: number
```


Returns the number of children the shape has.


[Open in Browser](https://love2d.org/wiki/Shape:getChildCount)

@*return* `count` — The number of children.

## getChildEdge


```lua
(method) love.ChainShape:getChildEdge(index: number)
  -> shape: love.EdgeShape
```


Returns a child of the shape as an EdgeShape.


[Open in Browser](https://love2d.org/wiki/ChainShape:getChildEdge)

@*param* `index` — The index of the child.

@*return* `shape` — The child as an EdgeShape.

## getNextVertex


```lua
(method) love.ChainShape:getNextVertex()
  -> x: number
  2. y: number
```


Gets the vertex that establishes a connection to the next shape.

Setting next and previous ChainShape vertices can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.


[Open in Browser](https://love2d.org/wiki/ChainShape:getNextVertex)

@*return* `x` — The x-component of the vertex, or nil if ChainShape:setNextVertex hasn't been called.

@*return* `y` — The y-component of the vertex, or nil if ChainShape:setNextVertex hasn't been called.

## getPoint


```lua
(method) love.ChainShape:getPoint(index: number)
  -> x: number
  2. y: number
```


Returns a point of the shape.


[Open in Browser](https://love2d.org/wiki/ChainShape:getPoint)

@*param* `index` — The index of the point to return.

@*return* `x` — The x-coordinate of the point.

@*return* `y` — The y-coordinate of the point.

## getPoints


```lua
(method) love.ChainShape:getPoints()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Returns all points of the shape.


[Open in Browser](https://love2d.org/wiki/ChainShape:getPoints)

@*return* `x1` — The x-coordinate of the first point.

@*return* `y1` — The y-coordinate of the first point.

@*return* `x2` — The x-coordinate of the second point.

@*return* `y2` — The y-coordinate of the second point.

## getPreviousVertex


```lua
(method) love.ChainShape:getPreviousVertex()
  -> x: number
  2. y: number
```


Gets the vertex that establishes a connection to the previous shape.

Setting next and previous ChainShape vertices can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.


[Open in Browser](https://love2d.org/wiki/ChainShape:getPreviousVertex)

@*return* `x` — The x-component of the vertex, or nil if ChainShape:setPreviousVertex hasn't been called.

@*return* `y` — The y-component of the vertex, or nil if ChainShape:setPreviousVertex hasn't been called.

## getRadius


```lua
(method) love.Shape:getRadius()
  -> radius: number
```


Gets the radius of the shape.


[Open in Browser](https://love2d.org/wiki/Shape:getRadius)

@*return* `radius` — The radius of the shape.

## getType


```lua
(method) love.Shape:getType()
  -> type: "chain"|"circle"|"edge"|"polygon"
```


Gets a string representing the Shape.

This function can be useful for conditional debug drawing.


[Open in Browser](https://love2d.org/wiki/Shape:getType)

@*return* `type` — The type of the Shape.

```lua
-- 
-- The different types of Shapes, as returned by Shape:getType.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/ShapeType)
-- 
type:
    | "circle" -- The Shape is a CircleShape.
    | "polygon" -- The Shape is a PolygonShape.
    | "edge" -- The Shape is a EdgeShape.
    | "chain" -- The Shape is a ChainShape.
```

## getVertexCount


```lua
(method) love.ChainShape:getVertexCount()
  -> count: number
```


Returns the number of vertices the shape has.


[Open in Browser](https://love2d.org/wiki/ChainShape:getVertexCount)

@*return* `count` — The number of vertices.

## rayCast


```lua
(method) love.Shape:rayCast(x1: number, y1: number, x2: number, y2: number, maxFraction: number, tx: number, ty: number, tr: number, childIndex?: number)
  -> xn: number
  2. yn: number
  3. fraction: number
```


Casts a ray against the shape and returns the surface normal vector and the line position where the ray hit. If the ray missed the shape, nil will be returned. The Shape can be transformed to get it into the desired position.

The ray starts on the first point of the input line and goes towards the second point of the line. The fourth argument is the maximum distance the ray is going to travel as a scale factor of the input line length.

The childIndex parameter is used to specify which child of a parent shape, such as a ChainShape, will be ray casted. For ChainShapes, the index of 1 is the first edge on the chain. Ray casting a parent shape will only test the child specified so if you want to test every shape of the parent, you must loop through all of its children.

The world position of the impact can be calculated by multiplying the line vector with the third return value and adding it to the line starting point.

hitx, hity = x1 + (x2 - x1) * fraction, y1 + (y2 - y1) * fraction


[Open in Browser](https://love2d.org/wiki/Shape:rayCast)

@*param* `x1` — The x position of the input line starting point.

@*param* `y1` — The y position of the input line starting point.

@*param* `x2` — The x position of the input line end point.

@*param* `y2` — The y position of the input line end point.

@*param* `maxFraction` — Ray length parameter.

@*param* `tx` — The translation of the shape on the x-axis.

@*param* `ty` — The translation of the shape on the y-axis.

@*param* `tr` — The shape rotation.

@*param* `childIndex` — The index of the child the ray gets cast against.

@*return* `xn` — The x component of the normal vector of the edge where the ray hit the shape.

@*return* `yn` — The y component of the normal vector of the edge where the ray hit the shape.

@*return* `fraction` — The position on the input line where the intersection happened as a factor of the line length.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setNextVertex


```lua
(method) love.ChainShape:setNextVertex(x: number, y: number)
```


Sets a vertex that establishes a connection to the next shape.

This can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.


[Open in Browser](https://love2d.org/wiki/ChainShape:setNextVertex)

@*param* `x` — The x-component of the vertex.

@*param* `y` — The y-component of the vertex.

## setPreviousVertex


```lua
(method) love.ChainShape:setPreviousVertex(x: number, y: number)
```


Sets a vertex that establishes a connection to the previous shape.

This can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.


[Open in Browser](https://love2d.org/wiki/ChainShape:setPreviousVertex)

@*param* `x` — The x-component of the vertex.

@*param* `y` — The y-component of the vertex.

## testPoint


```lua
(method) love.Shape:testPoint(tx: number, ty: number, tr: number, x: number, y: number)
  -> hit: boolean
```


This is particularly useful for mouse interaction with the shapes. By looping through all shapes and testing the mouse position with this function, we can find which shapes the mouse touches.


[Open in Browser](https://love2d.org/wiki/Shape:testPoint)

@*param* `tx` — Translates the shape along the x-axis.

@*param* `ty` — Translates the shape along the y-axis.

@*param* `tr` — Rotates the shape.

@*param* `x` — The x-component of the point.

@*param* `y` — The y-component of the point.

@*return* `hit` — True if inside, false if outside

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.Channel

## clear


```lua
(method) love.Channel:clear()
```


Clears all the messages in the Channel queue.


[Open in Browser](https://love2d.org/wiki/Channel:clear)

## demand


```lua
(method) love.Channel:demand()
  -> value: any
```


Retrieves the value of a Channel message and removes it from the message queue.

It waits until a message is in the queue then returns the message value.


[Open in Browser](https://love2d.org/wiki/Channel:demand)


---

@*return* `value` — The contents of the message.

## getCount


```lua
(method) love.Channel:getCount()
  -> count: number
```


Retrieves the number of messages in the thread Channel queue.


[Open in Browser](https://love2d.org/wiki/Channel:getCount)

@*return* `count` — The number of messages in the queue.

## hasRead


```lua
(method) love.Channel:hasRead(id: number)
  -> hasread: boolean
```


Gets whether a pushed value has been popped or otherwise removed from the Channel.


[Open in Browser](https://love2d.org/wiki/Channel:hasRead)

@*param* `id` — An id value previously returned by Channel:push.

@*return* `hasread` — Whether the value represented by the id has been removed from the Channel via Channel:pop, Channel:demand, or Channel:clear.

## peek


```lua
(method) love.Channel:peek()
  -> value: any
```


Retrieves the value of a Channel message, but leaves it in the queue.

It returns nil if there's no message in the queue.


[Open in Browser](https://love2d.org/wiki/Channel:peek)

@*return* `value` — The contents of the message.

## performAtomic


```lua
(method) love.Channel:performAtomic(func: function, arg1: any, ...any)
  -> ret1: any
```


Executes the specified function atomically with respect to this Channel.

Calling multiple methods in a row on the same Channel is often useful. However if multiple Threads are calling this Channel's methods at the same time, the different calls on each Thread might end up interleaved (e.g. one or more of the second thread's calls may happen in between the first thread's calls.)

This method avoids that issue by making sure the Thread calling the method has exclusive access to the Channel until the specified function has returned.


[Open in Browser](https://love2d.org/wiki/Channel:performAtomic)

@*param* `func` — The function to call, the form of function(channel, arg1, arg2, ...) end. The Channel is passed as the first argument to the function when it is called.

@*param* `arg1` — Additional arguments that the given function will receive when it is called.

@*return* `ret1` — The first return value of the given function (if any.)

## pop


```lua
(method) love.Channel:pop()
  -> value: any
```


Retrieves the value of a Channel message and removes it from the message queue.

It returns nil if there are no messages in the queue.


[Open in Browser](https://love2d.org/wiki/Channel:pop)

@*return* `value` — The contents of the message.

## push


```lua
(method) love.Channel:push(value: any)
  -> id: number
```


Send a message to the thread Channel.

See Variant for the list of supported types.


[Open in Browser](https://love2d.org/wiki/Channel:push)

@*param* `value` — The contents of the message.

@*return* `id` — Identifier which can be supplied to Channel:hasRead

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## supply


```lua
(method) love.Channel:supply(value: any)
  -> success: boolean
```


Send a message to the thread Channel and wait for a thread to accept it.

See Variant for the list of supported types.


[Open in Browser](https://love2d.org/wiki/Channel:supply)


---

@*param* `value` — The contents of the message.

@*return* `success` — Whether the message was successfully supplied (always true).

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.CircleShape

## computeAABB


```lua
(method) love.Shape:computeAABB(tx: number, ty: number, tr: number, childIndex?: number)
  -> topLeftX: number
  2. topLeftY: number
  3. bottomRightX: number
  4. bottomRightY: number
```


Returns the points of the bounding box for the transformed shape.


[Open in Browser](https://love2d.org/wiki/Shape:computeAABB)

@*param* `tx` — The translation of the shape on the x-axis.

@*param* `ty` — The translation of the shape on the y-axis.

@*param* `tr` — The shape rotation.

@*param* `childIndex` — The index of the child to compute the bounding box of.

@*return* `topLeftX` — The x position of the top-left point.

@*return* `topLeftY` — The y position of the top-left point.

@*return* `bottomRightX` — The x position of the bottom-right point.

@*return* `bottomRightY` — The y position of the bottom-right point.

## computeMass


```lua
(method) love.Shape:computeMass(density: number)
  -> x: number
  2. y: number
  3. mass: number
  4. inertia: number
```


Computes the mass properties for the shape with the specified density.


[Open in Browser](https://love2d.org/wiki/Shape:computeMass)

@*param* `density` — The shape density.

@*return* `x` — The x postition of the center of mass.

@*return* `y` — The y postition of the center of mass.

@*return* `mass` — The mass of the shape.

@*return* `inertia` — The rotational inertia.

## getChildCount


```lua
(method) love.Shape:getChildCount()
  -> count: number
```


Returns the number of children the shape has.


[Open in Browser](https://love2d.org/wiki/Shape:getChildCount)

@*return* `count` — The number of children.

## getPoint


```lua
(method) love.CircleShape:getPoint()
  -> x: number
  2. y: number
```


Gets the center point of the circle shape.


[Open in Browser](https://love2d.org/wiki/CircleShape:getPoint)

@*return* `x` — The x-component of the center point of the circle.

@*return* `y` — The y-component of the center point of the circle.

## getRadius


```lua
(method) love.CircleShape:getRadius()
  -> radius: number
```


Gets the radius of the circle shape.


[Open in Browser](https://love2d.org/wiki/CircleShape:getRadius)

@*return* `radius` — The radius of the circle

## getType


```lua
(method) love.Shape:getType()
  -> type: "chain"|"circle"|"edge"|"polygon"
```


Gets a string representing the Shape.

This function can be useful for conditional debug drawing.


[Open in Browser](https://love2d.org/wiki/Shape:getType)

@*return* `type` — The type of the Shape.

```lua
-- 
-- The different types of Shapes, as returned by Shape:getType.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/ShapeType)
-- 
type:
    | "circle" -- The Shape is a CircleShape.
    | "polygon" -- The Shape is a PolygonShape.
    | "edge" -- The Shape is a EdgeShape.
    | "chain" -- The Shape is a ChainShape.
```

## rayCast


```lua
(method) love.Shape:rayCast(x1: number, y1: number, x2: number, y2: number, maxFraction: number, tx: number, ty: number, tr: number, childIndex?: number)
  -> xn: number
  2. yn: number
  3. fraction: number
```


Casts a ray against the shape and returns the surface normal vector and the line position where the ray hit. If the ray missed the shape, nil will be returned. The Shape can be transformed to get it into the desired position.

The ray starts on the first point of the input line and goes towards the second point of the line. The fourth argument is the maximum distance the ray is going to travel as a scale factor of the input line length.

The childIndex parameter is used to specify which child of a parent shape, such as a ChainShape, will be ray casted. For ChainShapes, the index of 1 is the first edge on the chain. Ray casting a parent shape will only test the child specified so if you want to test every shape of the parent, you must loop through all of its children.

The world position of the impact can be calculated by multiplying the line vector with the third return value and adding it to the line starting point.

hitx, hity = x1 + (x2 - x1) * fraction, y1 + (y2 - y1) * fraction


[Open in Browser](https://love2d.org/wiki/Shape:rayCast)

@*param* `x1` — The x position of the input line starting point.

@*param* `y1` — The y position of the input line starting point.

@*param* `x2` — The x position of the input line end point.

@*param* `y2` — The y position of the input line end point.

@*param* `maxFraction` — Ray length parameter.

@*param* `tx` — The translation of the shape on the x-axis.

@*param* `ty` — The translation of the shape on the y-axis.

@*param* `tr` — The shape rotation.

@*param* `childIndex` — The index of the child the ray gets cast against.

@*return* `xn` — The x component of the normal vector of the edge where the ray hit the shape.

@*return* `yn` — The y component of the normal vector of the edge where the ray hit the shape.

@*return* `fraction` — The position on the input line where the intersection happened as a factor of the line length.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setPoint


```lua
(method) love.CircleShape:setPoint(x: number, y: number)
```


Sets the location of the center of the circle shape.


[Open in Browser](https://love2d.org/wiki/CircleShape:setPoint)

@*param* `x` — The x-component of the new center point of the circle.

@*param* `y` — The y-component of the new center point of the circle.

## setRadius


```lua
(method) love.CircleShape:setRadius(radius: number)
```


Sets the radius of the circle.


[Open in Browser](https://love2d.org/wiki/CircleShape:setRadius)

@*param* `radius` — The radius of the circle

## testPoint


```lua
(method) love.Shape:testPoint(tx: number, ty: number, tr: number, x: number, y: number)
  -> hit: boolean
```


This is particularly useful for mouse interaction with the shapes. By looping through all shapes and testing the mouse position with this function, we can find which shapes the mouse touches.


[Open in Browser](https://love2d.org/wiki/Shape:testPoint)

@*param* `tx` — Translates the shape along the x-axis.

@*param* `ty` — Translates the shape along the y-axis.

@*param* `tr` — Rotates the shape.

@*param* `x` — The x-component of the point.

@*param* `y` — The y-component of the point.

@*return* `hit` — True if inside, false if outside

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.CompareMode


---

# love.CompressedData

## clone


```lua
(method) love.Data:clone()
  -> clone: love.Data
```


Creates a new copy of the Data object.


[Open in Browser](https://love2d.org/wiki/Data:clone)

@*return* `clone` — The new copy.

## getFFIPointer


```lua
(method) love.Data:getFFIPointer()
  -> pointer: ffi.cdata*
```


Gets an FFI pointer to the Data.

This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.


[Open in Browser](https://love2d.org/wiki/Data:getFFIPointer)

@*return* `pointer` — A raw void* pointer to the Data, or nil if FFI is unavailable.

## getFormat


```lua
(method) love.CompressedData:getFormat()
  -> format: "deflate"|"gzip"|"lz4"|"zlib"
```


Gets the compression format of the CompressedData.


[Open in Browser](https://love2d.org/wiki/CompressedData:getFormat)

@*return* `format` — The format of the CompressedData.

```lua
-- 
-- Compressed data formats.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CompressedDataFormat)
-- 
format:
    | "lz4" -- The LZ4 compression format. Compresses and decompresses very quickly, but the compression ratio is not the best. LZ4-HC is used when compression level 9 is specified. Some benchmarks are available here.
    | "zlib" -- The zlib format is DEFLATE-compressed data with a small bit of header data. Compresses relatively slowly and decompresses moderately quickly, and has a decent compression ratio.
    | "gzip" -- The gzip format is DEFLATE-compressed data with a slightly larger header than zlib. Since it uses DEFLATE it has the same compression characteristics as the zlib format.
    | "deflate" -- Raw DEFLATE-compressed data (no header).
```

## getPointer


```lua
(method) love.Data:getPointer()
  -> pointer: lightuserdata
```


Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.


[Open in Browser](https://love2d.org/wiki/Data:getPointer)

@*return* `pointer` — A raw pointer to the Data.

## getSize


```lua
(method) love.Data:getSize()
  -> size: number
```


Gets the Data's size in bytes.


[Open in Browser](https://love2d.org/wiki/Data:getSize)

@*return* `size` — The size of the Data in bytes.

## getString


```lua
(method) love.Data:getString()
  -> data: string
```


Gets the full Data as a string.


[Open in Browser](https://love2d.org/wiki/Data:getString)

@*return* `data` — The raw data.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.CompressedDataFormat


---

# love.CompressedImageData

## clone


```lua
(method) love.Data:clone()
  -> clone: love.Data
```


Creates a new copy of the Data object.


[Open in Browser](https://love2d.org/wiki/Data:clone)

@*return* `clone` — The new copy.

## getDimensions


```lua
(method) love.CompressedImageData:getDimensions()
  -> width: number
  2. height: number
```


Gets the width and height of the CompressedImageData.


[Open in Browser](https://love2d.org/wiki/CompressedImageData:getDimensions)


---

@*return* `width` — The width of the CompressedImageData.

@*return* `height` — The height of the CompressedImageData.

## getFFIPointer


```lua
(method) love.Data:getFFIPointer()
  -> pointer: ffi.cdata*
```


Gets an FFI pointer to the Data.

This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.


[Open in Browser](https://love2d.org/wiki/Data:getFFIPointer)

@*return* `pointer` — A raw void* pointer to the Data, or nil if FFI is unavailable.

## getFormat


```lua
(method) love.CompressedImageData:getFormat()
  -> format: "ASTC10x10"|"ASTC10x5"|"ASTC10x6"|"ASTC10x8"|"ASTC12x10"...(+31)
```


Gets the format of the CompressedImageData.


[Open in Browser](https://love2d.org/wiki/CompressedImageData:getFormat)

@*return* `format` — The format of the CompressedImageData.

```lua
-- 
-- Compressed image data formats. Here and here are a couple overviews of many of the formats.
-- 
-- Unlike traditional PNG or jpeg, these formats stay compressed in RAM and in the graphics card's VRAM. This is good for saving memory space as well as improving performance, since the graphics card will be able to keep more of the image's pixels in its fast-access cache when drawing it.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CompressedImageFormat)
-- 
format:
    | "DXT1" -- The DXT1 format. RGB data at 4 bits per pixel (compared to 32 bits for ImageData and regular Images.) Suitable for fully opaque images on desktop systems.
    | "DXT3" -- The DXT3 format. RGBA data at 8 bits per pixel. Smooth variations in opacity do not mix well with this format.
    | "DXT5" -- The DXT5 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on desktop systems.
    | "BC4" -- The BC4 format (also known as 3Dc+ or ATI1.) Stores just the red channel, at 4 bits per pixel.
    | "BC4s" -- The signed variant of the BC4 format. Same as above but pixel values in the texture are in the range of 1 instead of 1 in shaders.
    | "BC5" -- The BC5 format (also known as 3Dc or ATI2.) Stores red and green channels at 8 bits per pixel.
    | "BC5s" -- The signed variant of the BC5 format.
    | "BC6h" -- The BC6H format. Stores half-precision floating-point RGB data in the range of 65504 at 8 bits per pixel. Suitable for HDR images on desktop systems.
    | "BC6hs" -- The signed variant of the BC6H format. Stores RGB data in the range of +65504.
    | "BC7" -- The BC7 format (also known as BPTC.) Stores RGB or RGBA data at 8 bits per pixel.
    | "ETC1" -- The ETC1 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on older Android devices.
    | "ETC2rgb" -- The RGB variant of the ETC2 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on newer mobile devices.
    | "ETC2rgba" -- The RGBA variant of the ETC2 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on newer mobile devices.
    | "ETC2rgba1" -- The RGBA variant of the ETC2 format where pixels are either fully transparent or fully opaque. RGBA data at 4 bits per pixel.
    | "EACr" -- The single-channel variant of the EAC format. Stores just the red channel, at 4 bits per pixel.
    | "EACrs" -- The signed single-channel variant of the EAC format. Same as above but pixel values in the texture are in the range of 1 instead of 1 in shaders.
    | "EACrg" -- The two-channel variant of the EAC format. Stores red and green channels at 8 bits per pixel.
    | "EACrgs" -- The signed two-channel variant of the EAC format.
    | "PVR1rgb2" -- The 2 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 2 bits per pixel. Textures compressed with PVRTC1 formats must be square and power-of-two sized.
    | "PVR1rgb4" -- The 4 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 4 bits per pixel.
    | "PVR1rgba2" -- The 2 bit per pixel RGBA variant of the PVRTC1 format.
    | "PVR1rgba4" -- The 4 bit per pixel RGBA variant of the PVRTC1 format.
    | "ASTC4x4" -- The 4x4 pixels per block variant of the ASTC format. RGBA data at 8 bits per pixel.
    | "ASTC5x4" -- The 5x4 pixels per block variant of the ASTC format. RGBA data at 6.4 bits per pixel.
    | "ASTC5x5" -- The 5x5 pixels per block variant of the ASTC format. RGBA data at 5.12 bits per pixel.
    | "ASTC6x5" -- The 6x5 pixels per block variant of the ASTC format. RGBA data at 4.27 bits per pixel.
    | "ASTC6x6" -- The 6x6 pixels per block variant of the ASTC format. RGBA data at 3.56 bits per pixel.
    | "ASTC8x5" -- The 8x5 pixels per block variant of the ASTC format. RGBA data at 3.2 bits per pixel.
    | "ASTC8x6" -- The 8x6 pixels per block variant of the ASTC format. RGBA data at 2.67 bits per pixel.
    | "ASTC8x8" -- The 8x8 pixels per block variant of the ASTC format. RGBA data at 2 bits per pixel.
    | "ASTC10x5" -- The 10x5 pixels per block variant of the ASTC format. RGBA data at 2.56 bits per pixel.
    | "ASTC10x6" -- The 10x6 pixels per block variant of the ASTC format. RGBA data at 2.13 bits per pixel.
    | "ASTC10x8" -- The 10x8 pixels per block variant of the ASTC format. RGBA data at 1.6 bits per pixel.
    | "ASTC10x10" -- The 10x10 pixels per block variant of the ASTC format. RGBA data at 1.28 bits per pixel.
    | "ASTC12x10" -- The 12x10 pixels per block variant of the ASTC format. RGBA data at 1.07 bits per pixel.
    | "ASTC12x12" -- The 12x12 pixels per block variant of the ASTC format. RGBA data at 0.89 bits per pixel.
```

## getHeight


```lua
(method) love.CompressedImageData:getHeight()
  -> height: number
```


Gets the height of the CompressedImageData.


[Open in Browser](https://love2d.org/wiki/CompressedImageData:getHeight)


---

@*return* `height` — The height of the CompressedImageData.

## getMipmapCount


```lua
(method) love.CompressedImageData:getMipmapCount()
  -> mipmaps: number
```


Gets the number of mipmap levels in the CompressedImageData. The base mipmap level (original image) is included in the count.


[Open in Browser](https://love2d.org/wiki/CompressedImageData:getMipmapCount)

@*return* `mipmaps` — The number of mipmap levels stored in the CompressedImageData.

## getPointer


```lua
(method) love.Data:getPointer()
  -> pointer: lightuserdata
```


Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.


[Open in Browser](https://love2d.org/wiki/Data:getPointer)

@*return* `pointer` — A raw pointer to the Data.

## getSize


```lua
(method) love.Data:getSize()
  -> size: number
```


Gets the Data's size in bytes.


[Open in Browser](https://love2d.org/wiki/Data:getSize)

@*return* `size` — The size of the Data in bytes.

## getString


```lua
(method) love.Data:getString()
  -> data: string
```


Gets the full Data as a string.


[Open in Browser](https://love2d.org/wiki/Data:getString)

@*return* `data` — The raw data.

## getWidth


```lua
(method) love.CompressedImageData:getWidth()
  -> width: number
```


Gets the width of the CompressedImageData.


[Open in Browser](https://love2d.org/wiki/CompressedImageData:getWidth)


---

@*return* `width` — The width of the CompressedImageData.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.CompressedImageFormat


---

# love.Contact

## getChildren


```lua
(method) love.Contact:getChildren()
  -> indexA: number
  2. indexB: number
```


Gets the child indices of the shapes of the two colliding fixtures. For ChainShapes, an index of 1 is the first edge in the chain.
Used together with Fixture:rayCast or ChainShape:getChildEdge.


[Open in Browser](https://love2d.org/wiki/Contact:getChildren)

@*return* `indexA` — The child index of the first fixture's shape.

@*return* `indexB` — The child index of the second fixture's shape.

## getFixtures


```lua
(method) love.Contact:getFixtures()
  -> fixtureA: love.Fixture
  2. fixtureB: love.Fixture
```


Gets the two Fixtures that hold the shapes that are in contact.


[Open in Browser](https://love2d.org/wiki/Contact:getFixtures)

@*return* `fixtureA` — The first Fixture.

@*return* `fixtureB` — The second Fixture.

## getFriction


```lua
(method) love.Contact:getFriction()
  -> friction: number
```


Get the friction between two shapes that are in contact.


[Open in Browser](https://love2d.org/wiki/Contact:getFriction)

@*return* `friction` — The friction of the contact.

## getNormal


```lua
(method) love.Contact:getNormal()
  -> nx: number
  2. ny: number
```


Get the normal vector between two shapes that are in contact.

This function returns the coordinates of a unit vector that points from the first shape to the second.


[Open in Browser](https://love2d.org/wiki/Contact:getNormal)

@*return* `nx` — The x component of the normal vector.

@*return* `ny` — The y component of the normal vector.

## getPositions


```lua
(method) love.Contact:getPositions()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Returns the contact points of the two colliding fixtures. There can be one or two points.


[Open in Browser](https://love2d.org/wiki/Contact:getPositions)

@*return* `x1` — The x coordinate of the first contact point.

@*return* `y1` — The y coordinate of the first contact point.

@*return* `x2` — The x coordinate of the second contact point.

@*return* `y2` — The y coordinate of the second contact point.

## getRestitution


```lua
(method) love.Contact:getRestitution()
  -> restitution: number
```


Get the restitution between two shapes that are in contact.


[Open in Browser](https://love2d.org/wiki/Contact:getRestitution)

@*return* `restitution` — The restitution between the two shapes.

## isEnabled


```lua
(method) love.Contact:isEnabled()
  -> enabled: boolean
```


Returns whether the contact is enabled. The collision will be ignored if a contact gets disabled in the preSolve callback.


[Open in Browser](https://love2d.org/wiki/Contact:isEnabled)

@*return* `enabled` — True if enabled, false otherwise.

## isTouching


```lua
(method) love.Contact:isTouching()
  -> touching: boolean
```


Returns whether the two colliding fixtures are touching each other.


[Open in Browser](https://love2d.org/wiki/Contact:isTouching)

@*return* `touching` — True if they touch or false if not.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## resetFriction


```lua
(method) love.Contact:resetFriction()
```


Resets the contact friction to the mixture value of both fixtures.


[Open in Browser](https://love2d.org/wiki/Contact:resetFriction)

## resetRestitution


```lua
(method) love.Contact:resetRestitution()
```


Resets the contact restitution to the mixture value of both fixtures.


[Open in Browser](https://love2d.org/wiki/Contact:resetRestitution)

## setEnabled


```lua
(method) love.Contact:setEnabled(enabled: boolean)
```


Enables or disables the contact.


[Open in Browser](https://love2d.org/wiki/Contact:setEnabled)

@*param* `enabled` — True to enable or false to disable.

## setFriction


```lua
(method) love.Contact:setFriction(friction: number)
```


Sets the contact friction.


[Open in Browser](https://love2d.org/wiki/Contact:setFriction)

@*param* `friction` — The contact friction.

## setRestitution


```lua
(method) love.Contact:setRestitution(restitution: number)
```


Sets the contact restitution.


[Open in Browser](https://love2d.org/wiki/Contact:setRestitution)

@*param* `restitution` — The contact restitution.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.ContainerType


---

# love.CullMode


---

# love.Cursor

## getType


```lua
(method) love.Cursor:getType()
  -> ctype: "arrow"|"crosshair"|"hand"|"ibeam"|"image"...(+8)
```


Gets the type of the Cursor.


[Open in Browser](https://love2d.org/wiki/Cursor:getType)

@*return* `ctype` — The type of the Cursor.

```lua
-- 
-- Types of hardware cursors.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CursorType)
-- 
ctype:
    | "image" -- The cursor is using a custom image.
    | "arrow" -- An arrow pointer.
    | "ibeam" -- An I-beam, normally used when mousing over editable or selectable text.
    | "wait" -- Wait graphic.
    | "waitarrow" -- Small wait cursor with an arrow pointer.
    | "crosshair" -- Crosshair symbol.
    | "sizenwse" -- Double arrow pointing to the top-left and bottom-right.
    | "sizenesw" -- Double arrow pointing to the top-right and bottom-left.
    | "sizewe" -- Double arrow pointing left and right.
    | "sizens" -- Double arrow pointing up and down.
    | "sizeall" -- Four-pointed arrow pointing up, down, left, and right.
    | "no" -- Slashed circle or crossbones.
    | "hand" -- Hand symbol.
```

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.CursorType


---

# love.Data

## clone


```lua
(method) love.Data:clone()
  -> clone: love.Data
```


Creates a new copy of the Data object.


[Open in Browser](https://love2d.org/wiki/Data:clone)

@*return* `clone` — The new copy.

## getFFIPointer


```lua
(method) love.Data:getFFIPointer()
  -> pointer: ffi.cdata*
```


Gets an FFI pointer to the Data.

This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.


[Open in Browser](https://love2d.org/wiki/Data:getFFIPointer)

@*return* `pointer` — A raw void* pointer to the Data, or nil if FFI is unavailable.

## getPointer


```lua
(method) love.Data:getPointer()
  -> pointer: lightuserdata
```


Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.


[Open in Browser](https://love2d.org/wiki/Data:getPointer)

@*return* `pointer` — A raw pointer to the Data.

## getSize


```lua
(method) love.Data:getSize()
  -> size: number
```


Gets the Data's size in bytes.


[Open in Browser](https://love2d.org/wiki/Data:getSize)

@*return* `size` — The size of the Data in bytes.

## getString


```lua
(method) love.Data:getString()
  -> data: string
```


Gets the full Data as a string.


[Open in Browser](https://love2d.org/wiki/Data:getString)

@*return* `data` — The raw data.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.Decoder

## clone


```lua
(method) love.Decoder:clone()
  -> decoder: love.Decoder
```


Creates a new copy of current decoder.

The new decoder will start decoding from the beginning of the audio stream.


[Open in Browser](https://love2d.org/wiki/Decoder:clone)

@*return* `decoder` — New copy of the decoder.

## decode


```lua
(method) love.Decoder:decode()
  -> soundData: love.SoundData
```


Decodes the audio and returns a SoundData object containing the decoded audio data.


[Open in Browser](https://love2d.org/wiki/Decoder:decode)

@*return* `soundData` — Decoded audio data.

## getBitDepth


```lua
(method) love.Decoder:getBitDepth()
  -> bitDepth: number
```


Returns the number of bits per sample.


[Open in Browser](https://love2d.org/wiki/Decoder:getBitDepth)

@*return* `bitDepth` — Either 8, or 16.

## getChannelCount


```lua
(method) love.Decoder:getChannelCount()
  -> channels: number
```


Returns the number of channels in the stream.


[Open in Browser](https://love2d.org/wiki/Decoder:getChannelCount)

@*return* `channels` — 1 for mono, 2 for stereo.

## getDuration


```lua
(method) love.Decoder:getDuration()
  -> duration: number
```


Gets the duration of the sound file. It may not always be sample-accurate, and it may return -1 if the duration cannot be determined at all.


[Open in Browser](https://love2d.org/wiki/Decoder:getDuration)

@*return* `duration` — The duration of the sound file in seconds, or -1 if it cannot be determined.

## getSampleRate


```lua
(method) love.Decoder:getSampleRate()
  -> rate: number
```


Returns the sample rate of the Decoder.


[Open in Browser](https://love2d.org/wiki/Decoder:getSampleRate)

@*return* `rate` — Number of samples per second.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## seek


```lua
(method) love.Decoder:seek(offset: number)
```


Sets the currently playing position of the Decoder.


[Open in Browser](https://love2d.org/wiki/Decoder:seek)

@*param* `offset` — The position to seek to, in seconds.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.DisplayOrientation


---

# love.DistanceJoint

## destroy


```lua
(method) love.Joint:destroy()
```


Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.

In 0.7.2, when you don't have time to wait for garbage collection, this function

may be used to free the object immediately.


[Open in Browser](https://love2d.org/wiki/Joint:destroy)

## getAnchors


```lua
(method) love.Joint:getAnchors()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Get the anchor points of the joint.


[Open in Browser](https://love2d.org/wiki/Joint:getAnchors)

@*return* `x1` — The x-component of the anchor on Body 1.

@*return* `y1` — The y-component of the anchor on Body 1.

@*return* `x2` — The x-component of the anchor on Body 2.

@*return* `y2` — The y-component of the anchor on Body 2.

## getBodies


```lua
(method) love.Joint:getBodies()
  -> bodyA: love.Body
  2. bodyB: love.Body
```


Gets the bodies that the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/Joint:getBodies)

@*return* `bodyA` — The first Body.

@*return* `bodyB` — The second Body.

## getCollideConnected


```lua
(method) love.Joint:getCollideConnected()
  -> c: boolean
```


Gets whether the connected Bodies collide.


[Open in Browser](https://love2d.org/wiki/Joint:getCollideConnected)

@*return* `c` — True if they collide, false otherwise.

## getDampingRatio


```lua
(method) love.DistanceJoint:getDampingRatio()
  -> ratio: number
```


Gets the damping ratio.


[Open in Browser](https://love2d.org/wiki/DistanceJoint:getDampingRatio)

@*return* `ratio` — The damping ratio.

## getFrequency


```lua
(method) love.DistanceJoint:getFrequency()
  -> Hz: number
```


Gets the response speed.


[Open in Browser](https://love2d.org/wiki/DistanceJoint:getFrequency)

@*return* `Hz` — The response speed.

## getLength


```lua
(method) love.DistanceJoint:getLength()
  -> l: number
```


Gets the equilibrium distance between the two Bodies.


[Open in Browser](https://love2d.org/wiki/DistanceJoint:getLength)

@*return* `l` — The length between the two Bodies.

## getReactionForce


```lua
(method) love.Joint:getReactionForce(x: number)
  -> x: number
  2. y: number
```


Returns the reaction force in newtons on the second body


[Open in Browser](https://love2d.org/wiki/Joint:getReactionForce)

@*param* `x` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `x` — The x-component of the force.

@*return* `y` — The y-component of the force.

## getReactionTorque


```lua
(method) love.Joint:getReactionTorque(invdt: number)
  -> torque: number
```


Returns the reaction torque on the second body.


[Open in Browser](https://love2d.org/wiki/Joint:getReactionTorque)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `torque` — The reaction torque on the second body.

## getType


```lua
(method) love.Joint:getType()
  -> type: "distance"|"friction"|"gear"|"mouse"|"prismatic"...(+4)
```


Gets a string representing the type.


[Open in Browser](https://love2d.org/wiki/Joint:getType)

@*return* `type` — A string with the name of the Joint type.

```lua
-- 
-- Different types of joints.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JointType)
-- 
type:
    | "distance" -- A DistanceJoint.
    | "friction" -- A FrictionJoint.
    | "gear" -- A GearJoint.
    | "mouse" -- A MouseJoint.
    | "prismatic" -- A PrismaticJoint.
    | "pulley" -- A PulleyJoint.
    | "revolute" -- A RevoluteJoint.
    | "rope" -- A RopeJoint.
    | "weld" -- A WeldJoint.
```

## getUserData


```lua
(method) love.Joint:getUserData()
  -> value: any
```


Returns the Lua value associated with this Joint.


[Open in Browser](https://love2d.org/wiki/Joint:getUserData)

@*return* `value` — The Lua value associated with the Joint.

## isDestroyed


```lua
(method) love.Joint:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Joint is destroyed. Destroyed joints cannot be used.


[Open in Browser](https://love2d.org/wiki/Joint:isDestroyed)

@*return* `destroyed` — Whether the Joint is destroyed.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setDampingRatio


```lua
(method) love.DistanceJoint:setDampingRatio(ratio: number)
```


Sets the damping ratio.


[Open in Browser](https://love2d.org/wiki/DistanceJoint:setDampingRatio)

@*param* `ratio` — The damping ratio.

## setFrequency


```lua
(method) love.DistanceJoint:setFrequency(Hz: number)
```


Sets the response speed.


[Open in Browser](https://love2d.org/wiki/DistanceJoint:setFrequency)

@*param* `Hz` — The response speed.

## setLength


```lua
(method) love.DistanceJoint:setLength(l: number)
```


Sets the equilibrium distance between the two Bodies.


[Open in Browser](https://love2d.org/wiki/DistanceJoint:setLength)

@*param* `l` — The length between the two Bodies.

## setUserData


```lua
(method) love.Joint:setUserData(value: any)
```


Associates a Lua value with the Joint.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Joint:setUserData)

@*param* `value` — The Lua value to associate with the Joint.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.DistanceModel


---

# love.DrawMode


---

# love.Drawable

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.DroppedFile

## close


```lua
(method) love.File:close()
  -> success: boolean
```


Closes a File.


[Open in Browser](https://love2d.org/wiki/File:close)

@*return* `success` — Whether closing was successful.

## flush


```lua
(method) love.File:flush()
  -> success: boolean
  2. err: string
```


Flushes any buffered written data in the file to the disk.


[Open in Browser](https://love2d.org/wiki/File:flush)

@*return* `success` — Whether the file successfully flushed any buffered data to the disk.

@*return* `err` — The error string, if an error occurred and the file could not be flushed.

## getBuffer


```lua
(method) love.File:getBuffer()
  -> mode: "full"|"line"|"none"
  2. size: number
```


Gets the buffer mode of a file.


[Open in Browser](https://love2d.org/wiki/File:getBuffer)

@*return* `mode` — The current buffer mode of the file.

@*return* `size` — The maximum size in bytes of the file's buffer.

```lua
-- 
-- Buffer modes for File objects.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/BufferMode)
-- 
mode:
    | "none" -- No buffering. The result of write and append operations appears immediately.
    | "line" -- Line buffering. Write and append operations are buffered until a newline is output or the buffer size limit is reached.
    | "full" -- Full buffering. Write and append operations are always buffered until the buffer size limit is reached.
```

## getFilename


```lua
(method) love.File:getFilename()
  -> filename: string
```


Gets the filename that the File object was created with. If the file object originated from the love.filedropped callback, the filename will be the full platform-dependent file path.


[Open in Browser](https://love2d.org/wiki/File:getFilename)

@*return* `filename` — The filename of the File.

## getMode


```lua
(method) love.File:getMode()
  -> mode: "a"|"c"|"r"|"w"
```


Gets the FileMode the file has been opened with.


[Open in Browser](https://love2d.org/wiki/File:getMode)

@*return* `mode` — The mode this file has been opened with.

```lua
-- 
-- The different modes you can open a File in.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FileMode)
-- 
mode:
    | "r" -- Open a file for read.
    | "w" -- Open a file for write.
    | "a" -- Open a file for append.
    | "c" -- Do not open a file (represents a closed file.)
```

## getSize


```lua
(method) love.File:getSize()
  -> size: number
```


Returns the file size.


[Open in Browser](https://love2d.org/wiki/File:getSize)

@*return* `size` — The file size in bytes.

## isEOF


```lua
(method) love.File:isEOF()
  -> eof: boolean
```


Gets whether end-of-file has been reached.


[Open in Browser](https://love2d.org/wiki/File:isEOF)

@*return* `eof` — Whether EOF has been reached.

## isOpen


```lua
(method) love.File:isOpen()
  -> open: boolean
```


Gets whether the file is open.


[Open in Browser](https://love2d.org/wiki/File:isOpen)

@*return* `open` — True if the file is currently open, false otherwise.

## lines


```lua
(method) love.File:lines()
  -> iterator: function
```


Iterate over all the lines in a file.


[Open in Browser](https://love2d.org/wiki/File:lines)

@*return* `iterator` — The iterator (can be used in for loops).

## open


```lua
(method) love.File:open(mode: "a"|"c"|"r"|"w")
  -> ok: boolean
  2. err: string
```


Open the file for write, read or append.


[Open in Browser](https://love2d.org/wiki/File:open)

@*param* `mode` — The mode to open the file in.

@*return* `ok` — True on success, false otherwise.

@*return* `err` — The error string if an error occurred.

```lua
-- 
-- The different modes you can open a File in.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FileMode)
-- 
mode:
    | "r" -- Open a file for read.
    | "w" -- Open a file for write.
    | "a" -- Open a file for append.
    | "c" -- Do not open a file (represents a closed file.)
```

## read


```lua
(method) love.File:read(bytes?: number)
  -> contents: string
  2. size: number
```


Read a number of bytes from a file.


[Open in Browser](https://love2d.org/wiki/File:read)


---

@*param* `bytes` — The number of bytes to read.

@*return* `contents` — The contents of the read bytes.

@*return* `size` — How many bytes have been read.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## seek


```lua
(method) love.File:seek(pos: number)
  -> success: boolean
```


Seek to a position in a file


[Open in Browser](https://love2d.org/wiki/File:seek)

@*param* `pos` — The position to seek to

@*return* `success` — Whether the operation was successful

## setBuffer


```lua
(method) love.File:setBuffer(mode: "full"|"line"|"none", size?: number)
  -> success: boolean
  2. errorstr: string
```


Sets the buffer mode for a file opened for writing or appending. Files with buffering enabled will not write data to the disk until the buffer size limit is reached, depending on the buffer mode.

File:flush will force any buffered data to be written to the disk.


[Open in Browser](https://love2d.org/wiki/File:setBuffer)

@*param* `mode` — The buffer mode to use.

@*param* `size` — The maximum size in bytes of the file's buffer.

@*return* `success` — Whether the buffer mode was successfully set.

@*return* `errorstr` — The error string, if the buffer mode could not be set and an error occurred.

```lua
-- 
-- Buffer modes for File objects.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/BufferMode)
-- 
mode:
    | "none" -- No buffering. The result of write and append operations appears immediately.
    | "line" -- Line buffering. Write and append operations are buffered until a newline is output or the buffer size limit is reached.
    | "full" -- Full buffering. Write and append operations are always buffered until the buffer size limit is reached.
```

## tell


```lua
(method) love.File:tell()
  -> pos: number
```


Returns the position in the file.


[Open in Browser](https://love2d.org/wiki/File:tell)

@*return* `pos` — The current position.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.

## write


```lua
(method) love.File:write(data: string, size?: number)
  -> success: boolean
  2. err: string
```


Write data to a file.


[Open in Browser](https://love2d.org/wiki/File:write)


---

@*param* `data` — The string data to write.

@*param* `size` — How many bytes to write.

@*return* `success` — Whether the operation was successful.

@*return* `err` — The error string if an error occurred.


---

# love.EdgeShape

## computeAABB


```lua
(method) love.Shape:computeAABB(tx: number, ty: number, tr: number, childIndex?: number)
  -> topLeftX: number
  2. topLeftY: number
  3. bottomRightX: number
  4. bottomRightY: number
```


Returns the points of the bounding box for the transformed shape.


[Open in Browser](https://love2d.org/wiki/Shape:computeAABB)

@*param* `tx` — The translation of the shape on the x-axis.

@*param* `ty` — The translation of the shape on the y-axis.

@*param* `tr` — The shape rotation.

@*param* `childIndex` — The index of the child to compute the bounding box of.

@*return* `topLeftX` — The x position of the top-left point.

@*return* `topLeftY` — The y position of the top-left point.

@*return* `bottomRightX` — The x position of the bottom-right point.

@*return* `bottomRightY` — The y position of the bottom-right point.

## computeMass


```lua
(method) love.Shape:computeMass(density: number)
  -> x: number
  2. y: number
  3. mass: number
  4. inertia: number
```


Computes the mass properties for the shape with the specified density.


[Open in Browser](https://love2d.org/wiki/Shape:computeMass)

@*param* `density` — The shape density.

@*return* `x` — The x postition of the center of mass.

@*return* `y` — The y postition of the center of mass.

@*return* `mass` — The mass of the shape.

@*return* `inertia` — The rotational inertia.

## getChildCount


```lua
(method) love.Shape:getChildCount()
  -> count: number
```


Returns the number of children the shape has.


[Open in Browser](https://love2d.org/wiki/Shape:getChildCount)

@*return* `count` — The number of children.

## getNextVertex


```lua
(method) love.EdgeShape:getNextVertex()
  -> x: number
  2. y: number
```


Gets the vertex that establishes a connection to the next shape.

Setting next and previous EdgeShape vertices can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.


[Open in Browser](https://love2d.org/wiki/EdgeShape:getNextVertex)

@*return* `x` — The x-component of the vertex, or nil if EdgeShape:setNextVertex hasn't been called.

@*return* `y` — The y-component of the vertex, or nil if EdgeShape:setNextVertex hasn't been called.

## getPoints


```lua
(method) love.EdgeShape:getPoints()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Returns the local coordinates of the edge points.


[Open in Browser](https://love2d.org/wiki/EdgeShape:getPoints)

@*return* `x1` — The x-component of the first vertex.

@*return* `y1` — The y-component of the first vertex.

@*return* `x2` — The x-component of the second vertex.

@*return* `y2` — The y-component of the second vertex.

## getPreviousVertex


```lua
(method) love.EdgeShape:getPreviousVertex()
  -> x: number
  2. y: number
```


Gets the vertex that establishes a connection to the previous shape.

Setting next and previous EdgeShape vertices can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.


[Open in Browser](https://love2d.org/wiki/EdgeShape:getPreviousVertex)

@*return* `x` — The x-component of the vertex, or nil if EdgeShape:setPreviousVertex hasn't been called.

@*return* `y` — The y-component of the vertex, or nil if EdgeShape:setPreviousVertex hasn't been called.

## getRadius


```lua
(method) love.Shape:getRadius()
  -> radius: number
```


Gets the radius of the shape.


[Open in Browser](https://love2d.org/wiki/Shape:getRadius)

@*return* `radius` — The radius of the shape.

## getType


```lua
(method) love.Shape:getType()
  -> type: "chain"|"circle"|"edge"|"polygon"
```


Gets a string representing the Shape.

This function can be useful for conditional debug drawing.


[Open in Browser](https://love2d.org/wiki/Shape:getType)

@*return* `type` — The type of the Shape.

```lua
-- 
-- The different types of Shapes, as returned by Shape:getType.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/ShapeType)
-- 
type:
    | "circle" -- The Shape is a CircleShape.
    | "polygon" -- The Shape is a PolygonShape.
    | "edge" -- The Shape is a EdgeShape.
    | "chain" -- The Shape is a ChainShape.
```

## rayCast


```lua
(method) love.Shape:rayCast(x1: number, y1: number, x2: number, y2: number, maxFraction: number, tx: number, ty: number, tr: number, childIndex?: number)
  -> xn: number
  2. yn: number
  3. fraction: number
```


Casts a ray against the shape and returns the surface normal vector and the line position where the ray hit. If the ray missed the shape, nil will be returned. The Shape can be transformed to get it into the desired position.

The ray starts on the first point of the input line and goes towards the second point of the line. The fourth argument is the maximum distance the ray is going to travel as a scale factor of the input line length.

The childIndex parameter is used to specify which child of a parent shape, such as a ChainShape, will be ray casted. For ChainShapes, the index of 1 is the first edge on the chain. Ray casting a parent shape will only test the child specified so if you want to test every shape of the parent, you must loop through all of its children.

The world position of the impact can be calculated by multiplying the line vector with the third return value and adding it to the line starting point.

hitx, hity = x1 + (x2 - x1) * fraction, y1 + (y2 - y1) * fraction


[Open in Browser](https://love2d.org/wiki/Shape:rayCast)

@*param* `x1` — The x position of the input line starting point.

@*param* `y1` — The y position of the input line starting point.

@*param* `x2` — The x position of the input line end point.

@*param* `y2` — The y position of the input line end point.

@*param* `maxFraction` — Ray length parameter.

@*param* `tx` — The translation of the shape on the x-axis.

@*param* `ty` — The translation of the shape on the y-axis.

@*param* `tr` — The shape rotation.

@*param* `childIndex` — The index of the child the ray gets cast against.

@*return* `xn` — The x component of the normal vector of the edge where the ray hit the shape.

@*return* `yn` — The y component of the normal vector of the edge where the ray hit the shape.

@*return* `fraction` — The position on the input line where the intersection happened as a factor of the line length.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setNextVertex


```lua
(method) love.EdgeShape:setNextVertex(x: number, y: number)
```


Sets a vertex that establishes a connection to the next shape.

This can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.


[Open in Browser](https://love2d.org/wiki/EdgeShape:setNextVertex)

@*param* `x` — The x-component of the vertex.

@*param* `y` — The y-component of the vertex.

## setPreviousVertex


```lua
(method) love.EdgeShape:setPreviousVertex(x: number, y: number)
```


Sets a vertex that establishes a connection to the previous shape.

This can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.


[Open in Browser](https://love2d.org/wiki/EdgeShape:setPreviousVertex)

@*param* `x` — The x-component of the vertex.

@*param* `y` — The y-component of the vertex.

## testPoint


```lua
(method) love.Shape:testPoint(tx: number, ty: number, tr: number, x: number, y: number)
  -> hit: boolean
```


This is particularly useful for mouse interaction with the shapes. By looping through all shapes and testing the mouse position with this function, we can find which shapes the mouse touches.


[Open in Browser](https://love2d.org/wiki/Shape:testPoint)

@*param* `tx` — Translates the shape along the x-axis.

@*param* `ty` — Translates the shape along the y-axis.

@*param* `tr` — Rotates the shape.

@*param* `x` — The x-component of the point.

@*param* `y` — The y-component of the point.

@*return* `hit` — True if inside, false if outside

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.EffectType


---

# love.EffectWaveform


---

# love.EncodeFormat


---

# love.Event


---

# love.File

## close


```lua
(method) love.File:close()
  -> success: boolean
```


Closes a File.


[Open in Browser](https://love2d.org/wiki/File:close)

@*return* `success` — Whether closing was successful.

## flush


```lua
(method) love.File:flush()
  -> success: boolean
  2. err: string
```


Flushes any buffered written data in the file to the disk.


[Open in Browser](https://love2d.org/wiki/File:flush)

@*return* `success` — Whether the file successfully flushed any buffered data to the disk.

@*return* `err` — The error string, if an error occurred and the file could not be flushed.

## getBuffer


```lua
(method) love.File:getBuffer()
  -> mode: "full"|"line"|"none"
  2. size: number
```


Gets the buffer mode of a file.


[Open in Browser](https://love2d.org/wiki/File:getBuffer)

@*return* `mode` — The current buffer mode of the file.

@*return* `size` — The maximum size in bytes of the file's buffer.

```lua
-- 
-- Buffer modes for File objects.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/BufferMode)
-- 
mode:
    | "none" -- No buffering. The result of write and append operations appears immediately.
    | "line" -- Line buffering. Write and append operations are buffered until a newline is output or the buffer size limit is reached.
    | "full" -- Full buffering. Write and append operations are always buffered until the buffer size limit is reached.
```

## getFilename


```lua
(method) love.File:getFilename()
  -> filename: string
```


Gets the filename that the File object was created with. If the file object originated from the love.filedropped callback, the filename will be the full platform-dependent file path.


[Open in Browser](https://love2d.org/wiki/File:getFilename)

@*return* `filename` — The filename of the File.

## getMode


```lua
(method) love.File:getMode()
  -> mode: "a"|"c"|"r"|"w"
```


Gets the FileMode the file has been opened with.


[Open in Browser](https://love2d.org/wiki/File:getMode)

@*return* `mode` — The mode this file has been opened with.

```lua
-- 
-- The different modes you can open a File in.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FileMode)
-- 
mode:
    | "r" -- Open a file for read.
    | "w" -- Open a file for write.
    | "a" -- Open a file for append.
    | "c" -- Do not open a file (represents a closed file.)
```

## getSize


```lua
(method) love.File:getSize()
  -> size: number
```


Returns the file size.


[Open in Browser](https://love2d.org/wiki/File:getSize)

@*return* `size` — The file size in bytes.

## isEOF


```lua
(method) love.File:isEOF()
  -> eof: boolean
```


Gets whether end-of-file has been reached.


[Open in Browser](https://love2d.org/wiki/File:isEOF)

@*return* `eof` — Whether EOF has been reached.

## isOpen


```lua
(method) love.File:isOpen()
  -> open: boolean
```


Gets whether the file is open.


[Open in Browser](https://love2d.org/wiki/File:isOpen)

@*return* `open` — True if the file is currently open, false otherwise.

## lines


```lua
(method) love.File:lines()
  -> iterator: function
```


Iterate over all the lines in a file.


[Open in Browser](https://love2d.org/wiki/File:lines)

@*return* `iterator` — The iterator (can be used in for loops).

## open


```lua
(method) love.File:open(mode: "a"|"c"|"r"|"w")
  -> ok: boolean
  2. err: string
```


Open the file for write, read or append.


[Open in Browser](https://love2d.org/wiki/File:open)

@*param* `mode` — The mode to open the file in.

@*return* `ok` — True on success, false otherwise.

@*return* `err` — The error string if an error occurred.

```lua
-- 
-- The different modes you can open a File in.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FileMode)
-- 
mode:
    | "r" -- Open a file for read.
    | "w" -- Open a file for write.
    | "a" -- Open a file for append.
    | "c" -- Do not open a file (represents a closed file.)
```

## read


```lua
(method) love.File:read(bytes?: number)
  -> contents: string
  2. size: number
```


Read a number of bytes from a file.


[Open in Browser](https://love2d.org/wiki/File:read)


---

@*param* `bytes` — The number of bytes to read.

@*return* `contents` — The contents of the read bytes.

@*return* `size` — How many bytes have been read.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## seek


```lua
(method) love.File:seek(pos: number)
  -> success: boolean
```


Seek to a position in a file


[Open in Browser](https://love2d.org/wiki/File:seek)

@*param* `pos` — The position to seek to

@*return* `success` — Whether the operation was successful

## setBuffer


```lua
(method) love.File:setBuffer(mode: "full"|"line"|"none", size?: number)
  -> success: boolean
  2. errorstr: string
```


Sets the buffer mode for a file opened for writing or appending. Files with buffering enabled will not write data to the disk until the buffer size limit is reached, depending on the buffer mode.

File:flush will force any buffered data to be written to the disk.


[Open in Browser](https://love2d.org/wiki/File:setBuffer)

@*param* `mode` — The buffer mode to use.

@*param* `size` — The maximum size in bytes of the file's buffer.

@*return* `success` — Whether the buffer mode was successfully set.

@*return* `errorstr` — The error string, if the buffer mode could not be set and an error occurred.

```lua
-- 
-- Buffer modes for File objects.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/BufferMode)
-- 
mode:
    | "none" -- No buffering. The result of write and append operations appears immediately.
    | "line" -- Line buffering. Write and append operations are buffered until a newline is output or the buffer size limit is reached.
    | "full" -- Full buffering. Write and append operations are always buffered until the buffer size limit is reached.
```

## tell


```lua
(method) love.File:tell()
  -> pos: number
```


Returns the position in the file.


[Open in Browser](https://love2d.org/wiki/File:tell)

@*return* `pos` — The current position.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.

## write


```lua
(method) love.File:write(data: string, size?: number)
  -> success: boolean
  2. err: string
```


Write data to a file.


[Open in Browser](https://love2d.org/wiki/File:write)


---

@*param* `data` — The string data to write.

@*param* `size` — How many bytes to write.

@*return* `success` — Whether the operation was successful.

@*return* `err` — The error string if an error occurred.


---

# love.FileData

## clone


```lua
(method) love.Data:clone()
  -> clone: love.Data
```


Creates a new copy of the Data object.


[Open in Browser](https://love2d.org/wiki/Data:clone)

@*return* `clone` — The new copy.

## getExtension


```lua
(method) love.FileData:getExtension()
  -> ext: string
```


Gets the extension of the FileData.


[Open in Browser](https://love2d.org/wiki/FileData:getExtension)

@*return* `ext` — The extension of the file the FileData represents.

## getFFIPointer


```lua
(method) love.Data:getFFIPointer()
  -> pointer: ffi.cdata*
```


Gets an FFI pointer to the Data.

This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.


[Open in Browser](https://love2d.org/wiki/Data:getFFIPointer)

@*return* `pointer` — A raw void* pointer to the Data, or nil if FFI is unavailable.

## getFilename


```lua
(method) love.FileData:getFilename()
  -> name: string
```


Gets the filename of the FileData.


[Open in Browser](https://love2d.org/wiki/FileData:getFilename)

@*return* `name` — The name of the file the FileData represents.

## getPointer


```lua
(method) love.Data:getPointer()
  -> pointer: lightuserdata
```


Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.


[Open in Browser](https://love2d.org/wiki/Data:getPointer)

@*return* `pointer` — A raw pointer to the Data.

## getSize


```lua
(method) love.Data:getSize()
  -> size: number
```


Gets the Data's size in bytes.


[Open in Browser](https://love2d.org/wiki/Data:getSize)

@*return* `size` — The size of the Data in bytes.

## getString


```lua
(method) love.Data:getString()
  -> data: string
```


Gets the full Data as a string.


[Open in Browser](https://love2d.org/wiki/Data:getString)

@*return* `data` — The raw data.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.FileDecoder


---

# love.FileMode


---

# love.FileType


---

# love.FilterMode


---

# love.FilterType


---

# love.Fixture

## destroy


```lua
(method) love.Fixture:destroy()
```


Destroys the fixture.


[Open in Browser](https://love2d.org/wiki/Fixture:destroy)

## getBody


```lua
(method) love.Fixture:getBody()
  -> body: love.Body
```


Returns the body to which the fixture is attached.


[Open in Browser](https://love2d.org/wiki/Fixture:getBody)

@*return* `body` — The parent body.

## getBoundingBox


```lua
(method) love.Fixture:getBoundingBox(index?: number)
  -> topLeftX: number
  2. topLeftY: number
  3. bottomRightX: number
  4. bottomRightY: number
```


Returns the points of the fixture bounding box. In case the fixture has multiple children a 1-based index can be specified. For example, a fixture will have multiple children with a chain shape.


[Open in Browser](https://love2d.org/wiki/Fixture:getBoundingBox)

@*param* `index` — A bounding box of the fixture.

@*return* `topLeftX` — The x position of the top-left point.

@*return* `topLeftY` — The y position of the top-left point.

@*return* `bottomRightX` — The x position of the bottom-right point.

@*return* `bottomRightY` — The y position of the bottom-right point.

## getCategory


```lua
(method) love.Fixture:getCategory()
```


Returns the categories the fixture belongs to.


[Open in Browser](https://love2d.org/wiki/Fixture:getCategory)

## getDensity


```lua
(method) love.Fixture:getDensity()
  -> density: number
```


Returns the density of the fixture.


[Open in Browser](https://love2d.org/wiki/Fixture:getDensity)

@*return* `density` — The fixture density in kilograms per square meter.

## getFilterData


```lua
(method) love.Fixture:getFilterData()
  -> categories: number
  2. mask: number
  3. group: number
```


Returns the filter data of the fixture.

Categories and masks are encoded as the bits of a 16-bit integer.


[Open in Browser](https://love2d.org/wiki/Fixture:getFilterData)

@*return* `categories` — The categories as an integer from 0 to 65535.

@*return* `mask` — The mask as an integer from 0 to 65535.

@*return* `group` — The group as an integer from -32768 to 32767.

## getFriction


```lua
(method) love.Fixture:getFriction()
  -> friction: number
```


Returns the friction of the fixture.


[Open in Browser](https://love2d.org/wiki/Fixture:getFriction)

@*return* `friction` — The fixture friction.

## getGroupIndex


```lua
(method) love.Fixture:getGroupIndex()
  -> group: number
```


Returns the group the fixture belongs to. Fixtures with the same group will always collide if the group is positive or never collide if it's negative. The group zero means no group.

The groups range from -32768 to 32767.


[Open in Browser](https://love2d.org/wiki/Fixture:getGroupIndex)

@*return* `group` — The group of the fixture.

## getMask


```lua
(method) love.Fixture:getMask()
```


Returns which categories this fixture should '''NOT''' collide with.


[Open in Browser](https://love2d.org/wiki/Fixture:getMask)

## getMassData


```lua
(method) love.Fixture:getMassData()
  -> x: number
  2. y: number
  3. mass: number
  4. inertia: number
```


Returns the mass, its center and the rotational inertia.


[Open in Browser](https://love2d.org/wiki/Fixture:getMassData)

@*return* `x` — The x position of the center of mass.

@*return* `y` — The y position of the center of mass.

@*return* `mass` — The mass of the fixture.

@*return* `inertia` — The rotational inertia.

## getRestitution


```lua
(method) love.Fixture:getRestitution()
  -> restitution: number
```


Returns the restitution of the fixture.


[Open in Browser](https://love2d.org/wiki/Fixture:getRestitution)

@*return* `restitution` — The fixture restitution.

## getShape


```lua
(method) love.Fixture:getShape()
  -> shape: love.Shape
```


Returns the shape of the fixture. This shape is a reference to the actual data used in the simulation. It's possible to change its values between timesteps.


[Open in Browser](https://love2d.org/wiki/Fixture:getShape)

@*return* `shape` — The fixture's shape.

## getUserData


```lua
(method) love.Fixture:getUserData()
  -> value: any
```


Returns the Lua value associated with this fixture.


[Open in Browser](https://love2d.org/wiki/Fixture:getUserData)

@*return* `value` — The Lua value associated with the fixture.

## isDestroyed


```lua
(method) love.Fixture:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Fixture is destroyed. Destroyed fixtures cannot be used.


[Open in Browser](https://love2d.org/wiki/Fixture:isDestroyed)

@*return* `destroyed` — Whether the Fixture is destroyed.

## isSensor


```lua
(method) love.Fixture:isSensor()
  -> sensor: boolean
```


Returns whether the fixture is a sensor.


[Open in Browser](https://love2d.org/wiki/Fixture:isSensor)

@*return* `sensor` — If the fixture is a sensor.

## rayCast


```lua
(method) love.Fixture:rayCast(x1: number, y1: number, x2: number, y2: number, maxFraction: number, childIndex?: number)
  -> xn: number
  2. yn: number
  3. fraction: number
```


Casts a ray against the shape of the fixture and returns the surface normal vector and the line position where the ray hit. If the ray missed the shape, nil will be returned.

The ray starts on the first point of the input line and goes towards the second point of the line. The fifth argument is the maximum distance the ray is going to travel as a scale factor of the input line length.

The childIndex parameter is used to specify which child of a parent shape, such as a ChainShape, will be ray casted. For ChainShapes, the index of 1 is the first edge on the chain. Ray casting a parent shape will only test the child specified so if you want to test every shape of the parent, you must loop through all of its children.

The world position of the impact can be calculated by multiplying the line vector with the third return value and adding it to the line starting point.

hitx, hity = x1 + (x2 - x1) * fraction, y1 + (y2 - y1) * fraction


[Open in Browser](https://love2d.org/wiki/Fixture:rayCast)

@*param* `x1` — The x position of the input line starting point.

@*param* `y1` — The y position of the input line starting point.

@*param* `x2` — The x position of the input line end point.

@*param* `y2` — The y position of the input line end point.

@*param* `maxFraction` — Ray length parameter.

@*param* `childIndex` — The index of the child the ray gets cast against.

@*return* `xn` — The x component of the normal vector of the edge where the ray hit the shape.

@*return* `yn` — The y component of the normal vector of the edge where the ray hit the shape.

@*return* `fraction` — The position on the input line where the intersection happened as a factor of the line length.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setCategory


```lua
(method) love.Fixture:setCategory(...number)
```


Sets the categories the fixture belongs to. There can be up to 16 categories represented as a number from 1 to 16.

All fixture's default category is 1.


[Open in Browser](https://love2d.org/wiki/Fixture:setCategory)

## setDensity


```lua
(method) love.Fixture:setDensity(density: number)
```


Sets the density of the fixture. Call Body:resetMassData if this needs to take effect immediately.


[Open in Browser](https://love2d.org/wiki/Fixture:setDensity)

@*param* `density` — The fixture density in kilograms per square meter.

## setFilterData


```lua
(method) love.Fixture:setFilterData(categories: number, mask: number, group: number)
```


Sets the filter data of the fixture.

Groups, categories, and mask can be used to define the collision behaviour of the fixture.

If two fixtures are in the same group they either always collide if the group is positive, or never collide if it's negative. If the group is zero or they do not match, then the contact filter checks if the fixtures select a category of the other fixture with their masks. The fixtures do not collide if that's not the case. If they do have each other's categories selected, the return value of the custom contact filter will be used. They always collide if none was set.

There can be up to 16 categories. Categories and masks are encoded as the bits of a 16-bit integer.

When created, prior to calling this function, all fixtures have category set to 1, mask set to 65535 (all categories) and group set to 0.

This function allows setting all filter data for a fixture at once. To set only the categories, the mask or the group, you can use Fixture:setCategory, Fixture:setMask or Fixture:setGroupIndex respectively.


[Open in Browser](https://love2d.org/wiki/Fixture:setFilterData)

@*param* `categories` — The categories as an integer from 0 to 65535.

@*param* `mask` — The mask as an integer from 0 to 65535.

@*param* `group` — The group as an integer from -32768 to 32767.

## setFriction


```lua
(method) love.Fixture:setFriction(friction: number)
```


Sets the friction of the fixture.

Friction determines how shapes react when they 'slide' along other shapes. Low friction indicates a slippery surface, like ice, while high friction indicates a rough surface, like concrete. Range: 0.0 - 1.0.


[Open in Browser](https://love2d.org/wiki/Fixture:setFriction)

@*param* `friction` — The fixture friction.

## setGroupIndex


```lua
(method) love.Fixture:setGroupIndex(group: number)
```


Sets the group the fixture belongs to. Fixtures with the same group will always collide if the group is positive or never collide if it's negative. The group zero means no group.

The groups range from -32768 to 32767.


[Open in Browser](https://love2d.org/wiki/Fixture:setGroupIndex)

@*param* `group` — The group as an integer from -32768 to 32767.

## setMask


```lua
(method) love.Fixture:setMask(...number)
```


Sets the category mask of the fixture. There can be up to 16 categories represented as a number from 1 to 16.

This fixture will '''NOT''' collide with the fixtures that are in the selected categories if the other fixture also has a category of this fixture selected.


[Open in Browser](https://love2d.org/wiki/Fixture:setMask)

## setRestitution


```lua
(method) love.Fixture:setRestitution(restitution: number)
```


Sets the restitution of the fixture.


[Open in Browser](https://love2d.org/wiki/Fixture:setRestitution)

@*param* `restitution` — The fixture restitution.

## setSensor


```lua
(method) love.Fixture:setSensor(sensor: boolean)
```


Sets whether the fixture should act as a sensor.

Sensors do not cause collision responses, but the begin-contact and end-contact World callbacks will still be called for this fixture.


[Open in Browser](https://love2d.org/wiki/Fixture:setSensor)

@*param* `sensor` — The sensor status.

## setUserData


```lua
(method) love.Fixture:setUserData(value: any)
```


Associates a Lua value with the fixture.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Fixture:setUserData)

@*param* `value` — The Lua value to associate with the fixture.

## testPoint


```lua
(method) love.Fixture:testPoint(x: number, y: number)
  -> isInside: boolean
```


Checks if a point is inside the shape of the fixture.


[Open in Browser](https://love2d.org/wiki/Fixture:testPoint)

@*param* `x` — The x position of the point.

@*param* `y` — The y position of the point.

@*return* `isInside` — True if the point is inside or false if it is outside.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.Font

## getAscent


```lua
(method) love.Font:getAscent()
  -> ascent: number
```


Gets the ascent of the Font.

The ascent spans the distance between the baseline and the top of the glyph that reaches farthest from the baseline.


[Open in Browser](https://love2d.org/wiki/Font:getAscent)

@*return* `ascent` — The ascent of the Font in pixels.

## getBaseline


```lua
(method) love.Font:getBaseline()
  -> baseline: number
```


Gets the baseline of the Font.

Most scripts share the notion of a baseline: an imaginary horizontal line on which characters rest. In some scripts, parts of glyphs lie below the baseline.


[Open in Browser](https://love2d.org/wiki/Font:getBaseline)

@*return* `baseline` — The baseline of the Font in pixels.

## getDPIScale


```lua
(method) love.Font:getDPIScale()
  -> dpiscale: number
```


Gets the DPI scale factor of the Font.

The DPI scale factor represents relative pixel density. A DPI scale factor of 2 means the font's glyphs have twice the pixel density in each dimension (4 times as many pixels in the same area) compared to a font with a DPI scale factor of 1.

The font size of TrueType fonts is scaled internally by the font's specified DPI scale factor. By default, LÖVE uses the screen's DPI scale factor when creating TrueType fonts.


[Open in Browser](https://love2d.org/wiki/Font:getDPIScale)

@*return* `dpiscale` — The DPI scale factor of the Font.

## getDescent


```lua
(method) love.Font:getDescent()
  -> descent: number
```


Gets the descent of the Font.

The descent spans the distance between the baseline and the lowest descending glyph in a typeface.


[Open in Browser](https://love2d.org/wiki/Font:getDescent)

@*return* `descent` — The descent of the Font in pixels.

## getFilter


```lua
(method) love.Font:getFilter()
  -> min: "linear"|"nearest"
  2. mag: "linear"|"nearest"
  3. anisotropy: number
```


Gets the filter mode for a font.


[Open in Browser](https://love2d.org/wiki/Font:getFilter)

@*return* `min` — Filter mode used when minifying the font.

@*return* `mag` — Filter mode used when magnifying the font.

@*return* `anisotropy` — Maximum amount of anisotropic filtering used.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
min:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.

-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mag:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## getHeight


```lua
(method) love.Font:getHeight()
  -> height: number
```


Gets the height of the Font.

The height of the font is the size including any spacing; the height which it will need.


[Open in Browser](https://love2d.org/wiki/Font:getHeight)

@*return* `height` — The height of the Font in pixels.

## getKerning


```lua
(method) love.Font:getKerning(leftchar: string, rightchar: string)
  -> kerning: number
```


Gets the kerning between two characters in the Font.

Kerning is normally handled automatically in love.graphics.print, Text objects, Font:getWidth, Font:getWrap, etc. This function is useful when stitching text together manually.


[Open in Browser](https://love2d.org/wiki/Font:getKerning)


---

@*param* `leftchar` — The left character.

@*param* `rightchar` — The right character.

@*return* `kerning` — The kerning amount to add to the spacing between the two characters. May be negative.

## getLineHeight


```lua
(method) love.Font:getLineHeight()
  -> height: number
```


Gets the line height.

This will be the value previously set by Font:setLineHeight, or 1.0 by default.


[Open in Browser](https://love2d.org/wiki/Font:getLineHeight)

@*return* `height` — The current line height.

## getWidth


```lua
(method) love.Font:getWidth(text: string|number)
  -> width: number
```


Determines the maximum width (accounting for newlines) taken by the given string.


[Open in Browser](https://love2d.org/wiki/Font:getWidth)

@*param* `text` — A string or number.

@*return* `width` — The width of the text.

## getWrap


```lua
(method) love.Font:getWrap(text: string, wraplimit: number)
  -> width: number
  2. wrappedtext: table
```


Gets formatting information for text, given a wrap limit.

This function accounts for newlines correctly (i.e. '\n').


[Open in Browser](https://love2d.org/wiki/Font:getWrap)

@*param* `text` — The text that will be wrapped.

@*param* `wraplimit` — The maximum width in pixels of each line that ''text'' is allowed before wrapping.

@*return* `width` — The maximum width of the wrapped text.

@*return* `wrappedtext` — A sequence containing each line of text that was wrapped.

## hasGlyphs


```lua
(method) love.Font:hasGlyphs(text: string)
  -> hasglyph: boolean
```


Gets whether the Font can render a character or string.


[Open in Browser](https://love2d.org/wiki/Font:hasGlyphs)


---

@*param* `text` — A UTF-8 encoded unicode string.

@*return* `hasglyph` — Whether the font can render all the UTF-8 characters in the string.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setFallbacks


```lua
(method) love.Font:setFallbacks(fallbackfont1: love.Font, ...love.Font)
```


Sets the fallback fonts. When the Font doesn't contain a glyph, it will substitute the glyph from the next subsequent fallback Fonts. This is akin to setting a 'font stack' in Cascading Style Sheets (CSS).


[Open in Browser](https://love2d.org/wiki/Font:setFallbacks)

@*param* `fallbackfont1` — The first fallback Font to use.

## setFilter


```lua
(method) love.Font:setFilter(min: "linear"|"nearest", mag: "linear"|"nearest", anisotropy?: number)
```


Sets the filter mode for a font.


[Open in Browser](https://love2d.org/wiki/Font:setFilter)

@*param* `min` — How to scale a font down.

@*param* `mag` — How to scale a font up.

@*param* `anisotropy` — Maximum amount of anisotropic filtering used.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
min:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.

-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mag:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## setLineHeight


```lua
(method) love.Font:setLineHeight(height: number)
```


Sets the line height.

When rendering the font in lines the actual height will be determined by the line height multiplied by the height of the font. The default is 1.0.


[Open in Browser](https://love2d.org/wiki/Font:setLineHeight)

@*param* `height` — The new line height.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.FrictionJoint

## destroy


```lua
(method) love.Joint:destroy()
```


Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.

In 0.7.2, when you don't have time to wait for garbage collection, this function

may be used to free the object immediately.


[Open in Browser](https://love2d.org/wiki/Joint:destroy)

## getAnchors


```lua
(method) love.Joint:getAnchors()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Get the anchor points of the joint.


[Open in Browser](https://love2d.org/wiki/Joint:getAnchors)

@*return* `x1` — The x-component of the anchor on Body 1.

@*return* `y1` — The y-component of the anchor on Body 1.

@*return* `x2` — The x-component of the anchor on Body 2.

@*return* `y2` — The y-component of the anchor on Body 2.

## getBodies


```lua
(method) love.Joint:getBodies()
  -> bodyA: love.Body
  2. bodyB: love.Body
```


Gets the bodies that the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/Joint:getBodies)

@*return* `bodyA` — The first Body.

@*return* `bodyB` — The second Body.

## getCollideConnected


```lua
(method) love.Joint:getCollideConnected()
  -> c: boolean
```


Gets whether the connected Bodies collide.


[Open in Browser](https://love2d.org/wiki/Joint:getCollideConnected)

@*return* `c` — True if they collide, false otherwise.

## getMaxForce


```lua
(method) love.FrictionJoint:getMaxForce()
  -> force: number
```


Gets the maximum friction force in Newtons.


[Open in Browser](https://love2d.org/wiki/FrictionJoint:getMaxForce)

@*return* `force` — Maximum force in Newtons.

## getMaxTorque


```lua
(method) love.FrictionJoint:getMaxTorque()
  -> torque: number
```


Gets the maximum friction torque in Newton-meters.


[Open in Browser](https://love2d.org/wiki/FrictionJoint:getMaxTorque)

@*return* `torque` — Maximum torque in Newton-meters.

## getReactionForce


```lua
(method) love.Joint:getReactionForce(x: number)
  -> x: number
  2. y: number
```


Returns the reaction force in newtons on the second body


[Open in Browser](https://love2d.org/wiki/Joint:getReactionForce)

@*param* `x` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `x` — The x-component of the force.

@*return* `y` — The y-component of the force.

## getReactionTorque


```lua
(method) love.Joint:getReactionTorque(invdt: number)
  -> torque: number
```


Returns the reaction torque on the second body.


[Open in Browser](https://love2d.org/wiki/Joint:getReactionTorque)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `torque` — The reaction torque on the second body.

## getType


```lua
(method) love.Joint:getType()
  -> type: "distance"|"friction"|"gear"|"mouse"|"prismatic"...(+4)
```


Gets a string representing the type.


[Open in Browser](https://love2d.org/wiki/Joint:getType)

@*return* `type` — A string with the name of the Joint type.

```lua
-- 
-- Different types of joints.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JointType)
-- 
type:
    | "distance" -- A DistanceJoint.
    | "friction" -- A FrictionJoint.
    | "gear" -- A GearJoint.
    | "mouse" -- A MouseJoint.
    | "prismatic" -- A PrismaticJoint.
    | "pulley" -- A PulleyJoint.
    | "revolute" -- A RevoluteJoint.
    | "rope" -- A RopeJoint.
    | "weld" -- A WeldJoint.
```

## getUserData


```lua
(method) love.Joint:getUserData()
  -> value: any
```


Returns the Lua value associated with this Joint.


[Open in Browser](https://love2d.org/wiki/Joint:getUserData)

@*return* `value` — The Lua value associated with the Joint.

## isDestroyed


```lua
(method) love.Joint:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Joint is destroyed. Destroyed joints cannot be used.


[Open in Browser](https://love2d.org/wiki/Joint:isDestroyed)

@*return* `destroyed` — Whether the Joint is destroyed.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setMaxForce


```lua
(method) love.FrictionJoint:setMaxForce(maxForce: number)
```


Sets the maximum friction force in Newtons.


[Open in Browser](https://love2d.org/wiki/FrictionJoint:setMaxForce)

@*param* `maxForce` — Max force in Newtons.

## setMaxTorque


```lua
(method) love.FrictionJoint:setMaxTorque(torque: number)
```


Sets the maximum friction torque in Newton-meters.


[Open in Browser](https://love2d.org/wiki/FrictionJoint:setMaxTorque)

@*param* `torque` — Maximum torque in Newton-meters.

## setUserData


```lua
(method) love.Joint:setUserData(value: any)
```


Associates a Lua value with the Joint.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Joint:setUserData)

@*param* `value` — The Lua value to associate with the Joint.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.FullscreenType


---

# love.GamepadAxis


---

# love.GamepadButton


---

# love.GearJoint

## destroy


```lua
(method) love.Joint:destroy()
```


Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.

In 0.7.2, when you don't have time to wait for garbage collection, this function

may be used to free the object immediately.


[Open in Browser](https://love2d.org/wiki/Joint:destroy)

## getAnchors


```lua
(method) love.Joint:getAnchors()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Get the anchor points of the joint.


[Open in Browser](https://love2d.org/wiki/Joint:getAnchors)

@*return* `x1` — The x-component of the anchor on Body 1.

@*return* `y1` — The y-component of the anchor on Body 1.

@*return* `x2` — The x-component of the anchor on Body 2.

@*return* `y2` — The y-component of the anchor on Body 2.

## getBodies


```lua
(method) love.Joint:getBodies()
  -> bodyA: love.Body
  2. bodyB: love.Body
```


Gets the bodies that the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/Joint:getBodies)

@*return* `bodyA` — The first Body.

@*return* `bodyB` — The second Body.

## getCollideConnected


```lua
(method) love.Joint:getCollideConnected()
  -> c: boolean
```


Gets whether the connected Bodies collide.


[Open in Browser](https://love2d.org/wiki/Joint:getCollideConnected)

@*return* `c` — True if they collide, false otherwise.

## getJoints


```lua
(method) love.GearJoint:getJoints()
  -> joint1: love.Joint
  2. joint2: love.Joint
```


Get the Joints connected by this GearJoint.


[Open in Browser](https://love2d.org/wiki/GearJoint:getJoints)

@*return* `joint1` — The first connected Joint.

@*return* `joint2` — The second connected Joint.

## getRatio


```lua
(method) love.GearJoint:getRatio()
  -> ratio: number
```


Get the ratio of a gear joint.


[Open in Browser](https://love2d.org/wiki/GearJoint:getRatio)

@*return* `ratio` — The ratio of the joint.

## getReactionForce


```lua
(method) love.Joint:getReactionForce(x: number)
  -> x: number
  2. y: number
```


Returns the reaction force in newtons on the second body


[Open in Browser](https://love2d.org/wiki/Joint:getReactionForce)

@*param* `x` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `x` — The x-component of the force.

@*return* `y` — The y-component of the force.

## getReactionTorque


```lua
(method) love.Joint:getReactionTorque(invdt: number)
  -> torque: number
```


Returns the reaction torque on the second body.


[Open in Browser](https://love2d.org/wiki/Joint:getReactionTorque)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `torque` — The reaction torque on the second body.

## getType


```lua
(method) love.Joint:getType()
  -> type: "distance"|"friction"|"gear"|"mouse"|"prismatic"...(+4)
```


Gets a string representing the type.


[Open in Browser](https://love2d.org/wiki/Joint:getType)

@*return* `type` — A string with the name of the Joint type.

```lua
-- 
-- Different types of joints.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JointType)
-- 
type:
    | "distance" -- A DistanceJoint.
    | "friction" -- A FrictionJoint.
    | "gear" -- A GearJoint.
    | "mouse" -- A MouseJoint.
    | "prismatic" -- A PrismaticJoint.
    | "pulley" -- A PulleyJoint.
    | "revolute" -- A RevoluteJoint.
    | "rope" -- A RopeJoint.
    | "weld" -- A WeldJoint.
```

## getUserData


```lua
(method) love.Joint:getUserData()
  -> value: any
```


Returns the Lua value associated with this Joint.


[Open in Browser](https://love2d.org/wiki/Joint:getUserData)

@*return* `value` — The Lua value associated with the Joint.

## isDestroyed


```lua
(method) love.Joint:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Joint is destroyed. Destroyed joints cannot be used.


[Open in Browser](https://love2d.org/wiki/Joint:isDestroyed)

@*return* `destroyed` — Whether the Joint is destroyed.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setRatio


```lua
(method) love.GearJoint:setRatio(ratio: number)
```


Set the ratio of a gear joint.


[Open in Browser](https://love2d.org/wiki/GearJoint:setRatio)

@*param* `ratio` — The new ratio of the joint.

## setUserData


```lua
(method) love.Joint:setUserData(value: any)
```


Associates a Lua value with the Joint.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Joint:setUserData)

@*param* `value` — The Lua value to associate with the Joint.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.GlyphData

## clone


```lua
(method) love.Data:clone()
  -> clone: love.Data
```


Creates a new copy of the Data object.


[Open in Browser](https://love2d.org/wiki/Data:clone)

@*return* `clone` — The new copy.

## getAdvance


```lua
(method) love.GlyphData:getAdvance()
  -> advance: number
```


Gets glyph advance.


[Open in Browser](https://love2d.org/wiki/GlyphData:getAdvance)

@*return* `advance` — Glyph advance.

## getBearing


```lua
(method) love.GlyphData:getBearing()
  -> bx: number
  2. by: number
```


Gets glyph bearing.


[Open in Browser](https://love2d.org/wiki/GlyphData:getBearing)

@*return* `bx` — Glyph bearing X.

@*return* `by` — Glyph bearing Y.

## getBoundingBox


```lua
(method) love.GlyphData:getBoundingBox()
  -> x: number
  2. y: number
  3. width: number
  4. height: number
```


Gets glyph bounding box.


[Open in Browser](https://love2d.org/wiki/GlyphData:getBoundingBox)

@*return* `x` — Glyph position x.

@*return* `y` — Glyph position y.

@*return* `width` — Glyph width.

@*return* `height` — Glyph height.

## getDimensions


```lua
(method) love.GlyphData:getDimensions()
  -> width: number
  2. height: number
```


Gets glyph dimensions.


[Open in Browser](https://love2d.org/wiki/GlyphData:getDimensions)

@*return* `width` — Glyph width.

@*return* `height` — Glyph height.

## getFFIPointer


```lua
(method) love.Data:getFFIPointer()
  -> pointer: ffi.cdata*
```


Gets an FFI pointer to the Data.

This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.


[Open in Browser](https://love2d.org/wiki/Data:getFFIPointer)

@*return* `pointer` — A raw void* pointer to the Data, or nil if FFI is unavailable.

## getFormat


```lua
(method) love.GlyphData:getFormat()
  -> format: "ASTC10x10"|"ASTC10x5"|"ASTC10x6"|"ASTC10x8"|"ASTC12x10"...(+59)
```


Gets glyph pixel format.


[Open in Browser](https://love2d.org/wiki/GlyphData:getFormat)

@*return* `format` — Glyph pixel format.

```lua
-- 
-- Pixel formats for Textures, ImageData, and CompressedImageData.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/PixelFormat)
-- 
format:
    | "unknown" -- Indicates unknown pixel format, used internally.
    | "normal" -- Alias for rgba8, or srgba8 if gamma-correct rendering is enabled.
    | "hdr" -- A format suitable for high dynamic range content - an alias for the rgba16f format, normally.
    | "r8" -- Single-channel (red component) format (8 bpp).
    | "rg8" -- Two channels (red and green components) with 8 bits per channel (16 bpp).
    | "rgba8" -- 8 bits per channel (32 bpp) RGBA. Color channel values range from 0-255 (0-1 in shaders).
    | "srgba8" -- gamma-correct version of rgba8.
    | "r16" -- Single-channel (red component) format (16 bpp).
    | "rg16" -- Two channels (red and green components) with 16 bits per channel (32 bpp).
    | "rgba16" -- 16 bits per channel (64 bpp) RGBA. Color channel values range from 0-65535 (0-1 in shaders).
    | "r16f" -- Floating point single-channel format (16 bpp). Color values can range from [-65504, +65504].
    | "rg16f" -- Floating point two-channel format with 16 bits per channel (32 bpp). Color values can range from [-65504, +65504].
    | "rgba16f" -- Floating point RGBA with 16 bits per channel (64 bpp). Color values can range from [-65504, +65504].
    | "r32f" -- Floating point single-channel format (32 bpp).
    | "rg32f" -- Floating point two-channel format with 32 bits per channel (64 bpp).
    | "rgba32f" -- Floating point RGBA with 32 bits per channel (128 bpp).
    | "la8" -- Same as rg8, but accessed as (L, L, L, A)
    | "rgba4" -- 4 bits per channel (16 bpp) RGBA.
    | "rgb5a1" -- RGB with 5 bits each, and a 1-bit alpha channel (16 bpp).
    | "rgb565" -- RGB with 5, 6, and 5 bits each, respectively (16 bpp). There is no alpha channel in this format.
    | "rgb10a2" -- RGB with 10 bits per channel, and a 2-bit alpha channel (32 bpp).
    | "rg11b10f" -- Floating point RGB with 11 bits in the red and green channels, and 10 bits in the blue channel (32 bpp). There is no alpha channel. Color values can range from [0, +65024].
    | "stencil8" -- No depth buffer and 8-bit stencil buffer.
    | "depth16" -- 16-bit depth buffer and no stencil buffer.
    | "depth24" -- 24-bit depth buffer and no stencil buffer.
    | "depth32f" -- 32-bit float depth buffer and no stencil buffer.
    | "depth24stencil8" -- 24-bit depth buffer and 8-bit stencil buffer.
    | "depth32fstencil8" -- 32-bit float depth buffer and 8-bit stencil buffer.
    | "DXT1" -- The DXT1 format. RGB data at 4 bits per pixel (compared to 32 bits for ImageData and regular Images.) Suitable for fully opaque images on desktop systems.
    | "DXT3" -- The DXT3 format. RGBA data at 8 bits per pixel. Smooth variations in opacity do not mix well with this format.
    | "DXT5" -- The DXT5 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on desktop systems.
    | "BC4" -- The BC4 format (also known as 3Dc+ or ATI1.) Stores just the red channel, at 4 bits per pixel.
    | "BC4s" -- The signed variant of the BC4 format. Same as above but pixel values in the texture are in the range of 1 instead of 1 in shaders.
    | "BC5" -- The BC5 format (also known as 3Dc or ATI2.) Stores red and green channels at 8 bits per pixel.
    | "BC5s" -- The signed variant of the BC5 format.
    | "BC6h" -- The BC6H format. Stores half-precision floating-point RGB data in the range of 65504 at 8 bits per pixel. Suitable for HDR images on desktop systems.
    | "BC6hs" -- The signed variant of the BC6H format. Stores RGB data in the range of +65504.
    | "BC7" -- The BC7 format (also known as BPTC.) Stores RGB or RGBA data at 8 bits per pixel.
    | "ETC1" -- The ETC1 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on older Android devices.
    | "ETC2rgb" -- The RGB variant of the ETC2 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on newer mobile devices.
    | "ETC2rgba" -- The RGBA variant of the ETC2 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on newer mobile devices.
    | "ETC2rgba1" -- The RGBA variant of the ETC2 format where pixels are either fully transparent or fully opaque. RGBA data at 4 bits per pixel.
    | "EACr" -- The single-channel variant of the EAC format. Stores just the red channel, at 4 bits per pixel.
    | "EACrs" -- The signed single-channel variant of the EAC format. Same as above but pixel values in the texture are in the range of 1 instead of 1 in shaders.
    | "EACrg" -- The two-channel variant of the EAC format. Stores red and green channels at 8 bits per pixel.
    | "EACrgs" -- The signed two-channel variant of the EAC format.
    | "PVR1rgb2" -- The 2 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 2 bits per pixel. Textures compressed with PVRTC1 formats must be square and power-of-two sized.
    | "PVR1rgb4" -- The 4 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 4 bits per pixel.
    | "PVR1rgba2" -- The 2 bit per pixel RGBA variant of the PVRTC1 format.
    | "PVR1rgba4" -- The 4 bit per pixel RGBA variant of the PVRTC1 format.
    | "ASTC4x4" -- The 4x4 pixels per block variant of the ASTC format. RGBA data at 8 bits per pixel.
    | "ASTC5x4" -- The 5x4 pixels per block variant of the ASTC format. RGBA data at 6.4 bits per pixel.
    | "ASTC5x5" -- The 5x5 pixels per block variant of the ASTC format. RGBA data at 5.12 bits per pixel.
    | "ASTC6x5" -- The 6x5 pixels per block variant of the ASTC format. RGBA data at 4.27 bits per pixel.
    | "ASTC6x6" -- The 6x6 pixels per block variant of the ASTC format. RGBA data at 3.56 bits per pixel.
    | "ASTC8x5" -- The 8x5 pixels per block variant of the ASTC format. RGBA data at 3.2 bits per pixel.
    | "ASTC8x6" -- The 8x6 pixels per block variant of the ASTC format. RGBA data at 2.67 bits per pixel.
    | "ASTC8x8" -- The 8x8 pixels per block variant of the ASTC format. RGBA data at 2 bits per pixel.
    | "ASTC10x5" -- The 10x5 pixels per block variant of the ASTC format. RGBA data at 2.56 bits per pixel.
    | "ASTC10x6" -- The 10x6 pixels per block variant of the ASTC format. RGBA data at 2.13 bits per pixel.
    | "ASTC10x8" -- The 10x8 pixels per block variant of the ASTC format. RGBA data at 1.6 bits per pixel.
    | "ASTC10x10" -- The 10x10 pixels per block variant of the ASTC format. RGBA data at 1.28 bits per pixel.
    | "ASTC12x10" -- The 12x10 pixels per block variant of the ASTC format. RGBA data at 1.07 bits per pixel.
    | "ASTC12x12" -- The 12x12 pixels per block variant of the ASTC format. RGBA data at 0.89 bits per pixel.
```

## getGlyph


```lua
(method) love.GlyphData:getGlyph()
  -> glyph: number
```


Gets glyph number.


[Open in Browser](https://love2d.org/wiki/GlyphData:getGlyph)

@*return* `glyph` — Glyph number.

## getGlyphString


```lua
(method) love.GlyphData:getGlyphString()
  -> glyph: string
```


Gets glyph string.


[Open in Browser](https://love2d.org/wiki/GlyphData:getGlyphString)

@*return* `glyph` — Glyph string.

## getHeight


```lua
(method) love.GlyphData:getHeight()
  -> height: number
```


Gets glyph height.


[Open in Browser](https://love2d.org/wiki/GlyphData:getHeight)

@*return* `height` — Glyph height.

## getPointer


```lua
(method) love.Data:getPointer()
  -> pointer: lightuserdata
```


Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.


[Open in Browser](https://love2d.org/wiki/Data:getPointer)

@*return* `pointer` — A raw pointer to the Data.

## getSize


```lua
(method) love.Data:getSize()
  -> size: number
```


Gets the Data's size in bytes.


[Open in Browser](https://love2d.org/wiki/Data:getSize)

@*return* `size` — The size of the Data in bytes.

## getString


```lua
(method) love.Data:getString()
  -> data: string
```


Gets the full Data as a string.


[Open in Browser](https://love2d.org/wiki/Data:getString)

@*return* `data` — The raw data.

## getWidth


```lua
(method) love.GlyphData:getWidth()
  -> width: number
```


Gets glyph width.


[Open in Browser](https://love2d.org/wiki/GlyphData:getWidth)

@*return* `width` — Glyph width.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.GraphicsFeature


---

# love.GraphicsLimit


---

# love.HashFunction


---

# love.HintingMode


---

# love.Image

## getDPIScale


```lua
(method) love.Texture:getDPIScale()
  -> dpiscale: number
```


Gets the DPI scale factor of the Texture.

The DPI scale factor represents relative pixel density. A DPI scale factor of 2 means the texture has twice the pixel density in each dimension (4 times as many pixels in the same area) compared to a texture with a DPI scale factor of 1.

For example, a texture with pixel dimensions of 100x100 with a DPI scale factor of 2 will be drawn as if it was 50x50. This is useful with high-dpi /  retina displays to easily allow swapping out higher or lower pixel density Images and Canvases without needing any extra manual scaling logic.


[Open in Browser](https://love2d.org/wiki/Texture:getDPIScale)

@*return* `dpiscale` — The DPI scale factor of the Texture.

## getDepth


```lua
(method) love.Texture:getDepth()
  -> depth: number
```


Gets the depth of a Volume Texture. Returns 1 for 2D, Cubemap, and Array textures.


[Open in Browser](https://love2d.org/wiki/Texture:getDepth)

@*return* `depth` — The depth of the volume Texture.

## getDepthSampleMode


```lua
(method) love.Texture:getDepthSampleMode()
  -> compare: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3)
```


Gets the comparison mode used when sampling from a depth texture in a shader.

Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.


[Open in Browser](https://love2d.org/wiki/Texture:getDepthSampleMode)

@*return* `compare` — The comparison mode used when sampling from this texture in a shader, or nil if setDepthSampleMode has not been called on this Texture.

```lua
-- 
-- Different types of per-pixel stencil test and depth test comparisons. The pixels of an object will be drawn if the comparison succeeds, for each pixel that the object touches.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CompareMode)
-- 
compare:
    | "equal" -- * stencil tests: the stencil value of the pixel must be equal to the supplied value.
              -- * depth tests: the depth value of the drawn object at that pixel must be equal to the existing depth value of that pixel.
    | "notequal" -- * stencil tests: the stencil value of the pixel must not be equal to the supplied value.
                 -- * depth tests: the depth value of the drawn object at that pixel must not be equal to the existing depth value of that pixel.
    | "less" -- * stencil tests: the stencil value of the pixel must be less than the supplied value.
             -- * depth tests: the depth value of the drawn object at that pixel must be less than the existing depth value of that pixel.
    | "lequal" -- * stencil tests: the stencil value of the pixel must be less than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be less than or equal to the existing depth value of that pixel.
    | "gequal" -- * stencil tests: the stencil value of the pixel must be greater than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be greater than or equal to the existing depth value of that pixel.
    | "greater" -- * stencil tests: the stencil value of the pixel must be greater than the supplied value.
                -- * depth tests: the depth value of the drawn object at that pixel must be greater than the existing depth value of that pixel.
    | "never" -- Objects will never be drawn.
    | "always" -- Objects will always be drawn. Effectively disables the depth or stencil test.
```

## getDimensions


```lua
(method) love.Texture:getDimensions()
  -> width: number
  2. height: number
```


Gets the width and height of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getDimensions)

@*return* `width` — The width of the Texture.

@*return* `height` — The height of the Texture.

## getFilter


```lua
(method) love.Texture:getFilter()
  -> min: "linear"|"nearest"
  2. mag: "linear"|"nearest"
  3. anisotropy: number
```


Gets the filter mode of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getFilter)

@*return* `min` — Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).

@*return* `mag` — Filter mode to use when magnifying the texture (rendering it at a smaller size on-screen than its size in pixels).

@*return* `anisotropy` — Maximum amount of anisotropic filtering used.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
min:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.

-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mag:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## getFormat


```lua
(method) love.Texture:getFormat()
  -> format: "ASTC10x10"|"ASTC10x5"|"ASTC10x6"|"ASTC10x8"|"ASTC12x10"...(+59)
```


Gets the pixel format of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getFormat)

@*return* `format` — The pixel format the Texture was created with.

```lua
-- 
-- Pixel formats for Textures, ImageData, and CompressedImageData.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/PixelFormat)
-- 
format:
    | "unknown" -- Indicates unknown pixel format, used internally.
    | "normal" -- Alias for rgba8, or srgba8 if gamma-correct rendering is enabled.
    | "hdr" -- A format suitable for high dynamic range content - an alias for the rgba16f format, normally.
    | "r8" -- Single-channel (red component) format (8 bpp).
    | "rg8" -- Two channels (red and green components) with 8 bits per channel (16 bpp).
    | "rgba8" -- 8 bits per channel (32 bpp) RGBA. Color channel values range from 0-255 (0-1 in shaders).
    | "srgba8" -- gamma-correct version of rgba8.
    | "r16" -- Single-channel (red component) format (16 bpp).
    | "rg16" -- Two channels (red and green components) with 16 bits per channel (32 bpp).
    | "rgba16" -- 16 bits per channel (64 bpp) RGBA. Color channel values range from 0-65535 (0-1 in shaders).
    | "r16f" -- Floating point single-channel format (16 bpp). Color values can range from [-65504, +65504].
    | "rg16f" -- Floating point two-channel format with 16 bits per channel (32 bpp). Color values can range from [-65504, +65504].
    | "rgba16f" -- Floating point RGBA with 16 bits per channel (64 bpp). Color values can range from [-65504, +65504].
    | "r32f" -- Floating point single-channel format (32 bpp).
    | "rg32f" -- Floating point two-channel format with 32 bits per channel (64 bpp).
    | "rgba32f" -- Floating point RGBA with 32 bits per channel (128 bpp).
    | "la8" -- Same as rg8, but accessed as (L, L, L, A)
    | "rgba4" -- 4 bits per channel (16 bpp) RGBA.
    | "rgb5a1" -- RGB with 5 bits each, and a 1-bit alpha channel (16 bpp).
    | "rgb565" -- RGB with 5, 6, and 5 bits each, respectively (16 bpp). There is no alpha channel in this format.
    | "rgb10a2" -- RGB with 10 bits per channel, and a 2-bit alpha channel (32 bpp).
    | "rg11b10f" -- Floating point RGB with 11 bits in the red and green channels, and 10 bits in the blue channel (32 bpp). There is no alpha channel. Color values can range from [0, +65024].
    | "stencil8" -- No depth buffer and 8-bit stencil buffer.
    | "depth16" -- 16-bit depth buffer and no stencil buffer.
    | "depth24" -- 24-bit depth buffer and no stencil buffer.
    | "depth32f" -- 32-bit float depth buffer and no stencil buffer.
    | "depth24stencil8" -- 24-bit depth buffer and 8-bit stencil buffer.
    | "depth32fstencil8" -- 32-bit float depth buffer and 8-bit stencil buffer.
    | "DXT1" -- The DXT1 format. RGB data at 4 bits per pixel (compared to 32 bits for ImageData and regular Images.) Suitable for fully opaque images on desktop systems.
    | "DXT3" -- The DXT3 format. RGBA data at 8 bits per pixel. Smooth variations in opacity do not mix well with this format.
    | "DXT5" -- The DXT5 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on desktop systems.
    | "BC4" -- The BC4 format (also known as 3Dc+ or ATI1.) Stores just the red channel, at 4 bits per pixel.
    | "BC4s" -- The signed variant of the BC4 format. Same as above but pixel values in the texture are in the range of 1 instead of 1 in shaders.
    | "BC5" -- The BC5 format (also known as 3Dc or ATI2.) Stores red and green channels at 8 bits per pixel.
    | "BC5s" -- The signed variant of the BC5 format.
    | "BC6h" -- The BC6H format. Stores half-precision floating-point RGB data in the range of 65504 at 8 bits per pixel. Suitable for HDR images on desktop systems.
    | "BC6hs" -- The signed variant of the BC6H format. Stores RGB data in the range of +65504.
    | "BC7" -- The BC7 format (also known as BPTC.) Stores RGB or RGBA data at 8 bits per pixel.
    | "ETC1" -- The ETC1 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on older Android devices.
    | "ETC2rgb" -- The RGB variant of the ETC2 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on newer mobile devices.
    | "ETC2rgba" -- The RGBA variant of the ETC2 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on newer mobile devices.
    | "ETC2rgba1" -- The RGBA variant of the ETC2 format where pixels are either fully transparent or fully opaque. RGBA data at 4 bits per pixel.
    | "EACr" -- The single-channel variant of the EAC format. Stores just the red channel, at 4 bits per pixel.
    | "EACrs" -- The signed single-channel variant of the EAC format. Same as above but pixel values in the texture are in the range of 1 instead of 1 in shaders.
    | "EACrg" -- The two-channel variant of the EAC format. Stores red and green channels at 8 bits per pixel.
    | "EACrgs" -- The signed two-channel variant of the EAC format.
    | "PVR1rgb2" -- The 2 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 2 bits per pixel. Textures compressed with PVRTC1 formats must be square and power-of-two sized.
    | "PVR1rgb4" -- The 4 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 4 bits per pixel.
    | "PVR1rgba2" -- The 2 bit per pixel RGBA variant of the PVRTC1 format.
    | "PVR1rgba4" -- The 4 bit per pixel RGBA variant of the PVRTC1 format.
    | "ASTC4x4" -- The 4x4 pixels per block variant of the ASTC format. RGBA data at 8 bits per pixel.
    | "ASTC5x4" -- The 5x4 pixels per block variant of the ASTC format. RGBA data at 6.4 bits per pixel.
    | "ASTC5x5" -- The 5x5 pixels per block variant of the ASTC format. RGBA data at 5.12 bits per pixel.
    | "ASTC6x5" -- The 6x5 pixels per block variant of the ASTC format. RGBA data at 4.27 bits per pixel.
    | "ASTC6x6" -- The 6x6 pixels per block variant of the ASTC format. RGBA data at 3.56 bits per pixel.
    | "ASTC8x5" -- The 8x5 pixels per block variant of the ASTC format. RGBA data at 3.2 bits per pixel.
    | "ASTC8x6" -- The 8x6 pixels per block variant of the ASTC format. RGBA data at 2.67 bits per pixel.
    | "ASTC8x8" -- The 8x8 pixels per block variant of the ASTC format. RGBA data at 2 bits per pixel.
    | "ASTC10x5" -- The 10x5 pixels per block variant of the ASTC format. RGBA data at 2.56 bits per pixel.
    | "ASTC10x6" -- The 10x6 pixels per block variant of the ASTC format. RGBA data at 2.13 bits per pixel.
    | "ASTC10x8" -- The 10x8 pixels per block variant of the ASTC format. RGBA data at 1.6 bits per pixel.
    | "ASTC10x10" -- The 10x10 pixels per block variant of the ASTC format. RGBA data at 1.28 bits per pixel.
    | "ASTC12x10" -- The 12x10 pixels per block variant of the ASTC format. RGBA data at 1.07 bits per pixel.
    | "ASTC12x12" -- The 12x12 pixels per block variant of the ASTC format. RGBA data at 0.89 bits per pixel.
```

## getHeight


```lua
(method) love.Texture:getHeight()
  -> height: number
```


Gets the height of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getHeight)

@*return* `height` — The height of the Texture.

## getLayerCount


```lua
(method) love.Texture:getLayerCount()
  -> layers: number
```


Gets the number of layers / slices in an Array Texture. Returns 1 for 2D, Cubemap, and Volume textures.


[Open in Browser](https://love2d.org/wiki/Texture:getLayerCount)

@*return* `layers` — The number of layers in the Array Texture.

## getMipmapCount


```lua
(method) love.Texture:getMipmapCount()
  -> mipmaps: number
```


Gets the number of mipmaps contained in the Texture. If the texture was not created with mipmaps, it will return 1.


[Open in Browser](https://love2d.org/wiki/Texture:getMipmapCount)

@*return* `mipmaps` — The number of mipmaps in the Texture.

## getMipmapFilter


```lua
(method) love.Texture:getMipmapFilter()
  -> mode: "linear"|"nearest"
  2. sharpness: number
```


Gets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.


[Open in Browser](https://love2d.org/wiki/Texture:getMipmapFilter)

@*return* `mode` — The filter mode used in between mipmap levels. nil if mipmap filtering is not enabled.

@*return* `sharpness` — Value used to determine whether the image should use more or less detailed mipmap levels than normal when drawing.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mode:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## getPixelDimensions


```lua
(method) love.Texture:getPixelDimensions()
  -> pixelwidth: number
  2. pixelheight: number
```


Gets the width and height in pixels of the Texture.

Texture:getDimensions gets the dimensions of the texture in units scaled by the texture's DPI scale factor, rather than pixels. Use getDimensions for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelDimensions only when dealing specifically with pixels, for example when using Canvas:newImageData.


[Open in Browser](https://love2d.org/wiki/Texture:getPixelDimensions)

@*return* `pixelwidth` — The width of the Texture, in pixels.

@*return* `pixelheight` — The height of the Texture, in pixels.

## getPixelHeight


```lua
(method) love.Texture:getPixelHeight()
  -> pixelheight: number
```


Gets the height in pixels of the Texture.

DPI scale factor, rather than pixels. Use getHeight for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelHeight only when dealing specifically with pixels, for example when using Canvas:newImageData.


[Open in Browser](https://love2d.org/wiki/Texture:getPixelHeight)

@*return* `pixelheight` — The height of the Texture, in pixels.

## getPixelWidth


```lua
(method) love.Texture:getPixelWidth()
  -> pixelwidth: number
```


Gets the width in pixels of the Texture.

DPI scale factor, rather than pixels. Use getWidth for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelWidth only when dealing specifically with pixels, for example when using Canvas:newImageData.


[Open in Browser](https://love2d.org/wiki/Texture:getPixelWidth)

@*return* `pixelwidth` — The width of the Texture, in pixels.

## getTextureType


```lua
(method) love.Texture:getTextureType()
  -> texturetype: "2d"|"array"|"cube"|"volume"
```


Gets the type of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getTextureType)

@*return* `texturetype` — The type of the Texture.

```lua
-- 
-- Types of textures (2D, cubemap, etc.)
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/TextureType)
-- 
texturetype:
    | "2d" -- Regular 2D texture with width and height.
    | "array" -- Several same-size 2D textures organized into a single object. Similar to a texture atlas / sprite sheet, but avoids sprite bleeding and other issues.
    | "cube" -- Cubemap texture with 6 faces. Requires a custom shader (and Shader:send) to use. Sampling from a cube texture in a shader takes a 3D direction vector instead of a texture coordinate.
    | "volume" -- 3D texture with width, height, and depth. Requires a custom shader to use. Volume textures can have texture filtering applied along the 3rd axis.
```

## getWidth


```lua
(method) love.Texture:getWidth()
  -> width: number
```


Gets the width of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getWidth)

@*return* `width` — The width of the Texture.

## getWrap


```lua
(method) love.Texture:getWrap()
  -> horiz: "clamp"|"clampzero"|"mirroredrepeat"|"repeat"
  2. vert: "clamp"|"clampzero"|"mirroredrepeat"|"repeat"
  3. depth: "clamp"|"clampzero"|"mirroredrepeat"|"repeat"
```


Gets the wrapping properties of a Texture.

This function returns the currently set horizontal and vertical wrapping modes for the texture.


[Open in Browser](https://love2d.org/wiki/Texture:getWrap)

@*return* `horiz` — Horizontal wrapping mode of the texture.

@*return* `vert` — Vertical wrapping mode of the texture.

@*return* `depth` — Wrapping mode for the z-axis of a Volume texture.

```lua
-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
horiz:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)

-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
vert:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)

-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
depth:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)
```

## isCompressed


```lua
(method) love.Image:isCompressed()
  -> compressed: boolean
```


Gets whether the Image was created from CompressedData.

Compressed images take up less space in VRAM, and drawing a compressed image will generally be more efficient than drawing one created from raw pixel data.


[Open in Browser](https://love2d.org/wiki/Image:isCompressed)

@*return* `compressed` — Whether the Image is stored as a compressed texture on the GPU.

## isFormatLinear


```lua
(method) love.Image:isFormatLinear()
  -> linear: boolean
```


Gets whether the Image was created with the linear (non-gamma corrected) flag set to true.

This method always returns false when gamma-correct rendering is not enabled.


[Open in Browser](https://love2d.org/wiki/Image:isFormatLinear)

@*return* `linear` — Whether the Image's internal pixel format is linear (not gamma corrected), when gamma-correct rendering is enabled.

## isReadable


```lua
(method) love.Texture:isReadable()
  -> readable: boolean
```


Gets whether the Texture can be drawn and sent to a Shader.

Canvases created with stencil and/or depth PixelFormats are not readable by default, unless readable=true is specified in the settings table passed into love.graphics.newCanvas.

Non-readable Canvases can still be rendered to.


[Open in Browser](https://love2d.org/wiki/Texture:isReadable)

@*return* `readable` — Whether the Texture is readable.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## replacePixels


```lua
(method) love.Image:replacePixels(data: love.ImageData, slice?: number, mipmap?: number, x?: number, y?: number, reloadmipmaps?: boolean)
```


Replace the contents of an Image.


[Open in Browser](https://love2d.org/wiki/Image:replacePixels)

@*param* `data` — The new ImageData to replace the contents with.

@*param* `slice` — Which cubemap face, array index, or volume layer to replace, if applicable.

@*param* `mipmap` — The mimap level to replace, if the Image has mipmaps.

@*param* `x` — The x-offset in pixels from the top-left of the image to replace. The given ImageData's width plus this value must not be greater than the pixel width of the Image's specified mipmap level.

@*param* `y` — The y-offset in pixels from the top-left of the image to replace. The given ImageData's height plus this value must not be greater than the pixel height of the Image's specified mipmap level.

@*param* `reloadmipmaps` — Whether to generate new mipmaps after replacing the Image's pixels. True by default if the Image was created with automatically generated mipmaps, false by default otherwise.

## setDepthSampleMode


```lua
(method) love.Texture:setDepthSampleMode(compare: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3))
```


Sets the comparison mode used when sampling from a depth texture in a shader. Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.

When using a depth texture with a comparison mode set in a shader, it must be declared as a sampler2DShadow and used in a GLSL 3 Shader. The result of accessing the texture in the shader will return a float between 0 and 1, proportional to the number of samples (up to 4 samples will be used if bilinear filtering is enabled) that passed the test set by the comparison operation.

Depth texture comparison can only be used with readable depth-formatted Canvases.


[Open in Browser](https://love2d.org/wiki/Texture:setDepthSampleMode)

@*param* `compare` — The comparison mode used when sampling from this texture in a shader.

```lua
-- 
-- Different types of per-pixel stencil test and depth test comparisons. The pixels of an object will be drawn if the comparison succeeds, for each pixel that the object touches.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CompareMode)
-- 
compare:
    | "equal" -- * stencil tests: the stencil value of the pixel must be equal to the supplied value.
              -- * depth tests: the depth value of the drawn object at that pixel must be equal to the existing depth value of that pixel.
    | "notequal" -- * stencil tests: the stencil value of the pixel must not be equal to the supplied value.
                 -- * depth tests: the depth value of the drawn object at that pixel must not be equal to the existing depth value of that pixel.
    | "less" -- * stencil tests: the stencil value of the pixel must be less than the supplied value.
             -- * depth tests: the depth value of the drawn object at that pixel must be less than the existing depth value of that pixel.
    | "lequal" -- * stencil tests: the stencil value of the pixel must be less than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be less than or equal to the existing depth value of that pixel.
    | "gequal" -- * stencil tests: the stencil value of the pixel must be greater than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be greater than or equal to the existing depth value of that pixel.
    | "greater" -- * stencil tests: the stencil value of the pixel must be greater than the supplied value.
                -- * depth tests: the depth value of the drawn object at that pixel must be greater than the existing depth value of that pixel.
    | "never" -- Objects will never be drawn.
    | "always" -- Objects will always be drawn. Effectively disables the depth or stencil test.
```

## setFilter


```lua
(method) love.Texture:setFilter(min: "linear"|"nearest", mag?: "linear"|"nearest", anisotropy?: number)
```


Sets the filter mode of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:setFilter)

@*param* `min` — Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).

@*param* `mag` — Filter mode to use when magnifying the texture (rendering it at a larger size on-screen than its size in pixels).

@*param* `anisotropy` — Maximum amount of anisotropic filtering to use.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
min:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.

-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mag:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## setMipmapFilter


```lua
(method) love.Texture:setMipmapFilter(filtermode: "linear"|"nearest", sharpness?: number)
```


Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.

Mipmapping is useful when drawing a texture at a reduced scale. It can improve performance and reduce aliasing issues.

In created with the mipmaps flag enabled for the mipmap filter to have any effect. In versions prior to 0.10.0 it's best to call this method directly after creating the image with love.graphics.newImage, to avoid bugs in certain graphics drivers.

Due to hardware restrictions and driver bugs, in versions prior to 0.10.0 images that weren't loaded from a CompressedData must have power-of-two dimensions (64x64, 512x256, etc.) to use mipmaps.


[Open in Browser](https://love2d.org/wiki/Texture:setMipmapFilter)


---

@*param* `filtermode` — The filter mode to use in between mipmap levels. 'nearest' will often give better performance.

@*param* `sharpness` — A positive sharpness value makes the texture use a more detailed mipmap level when drawing, at the expense of performance. A negative value does the reverse.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
filtermode:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## setWrap


```lua
(method) love.Texture:setWrap(horiz: "clamp"|"clampzero"|"mirroredrepeat"|"repeat", vert?: "clamp"|"clampzero"|"mirroredrepeat"|"repeat", depth?: "clamp"|"clampzero"|"mirroredrepeat"|"repeat")
```


Sets the wrapping properties of a Texture.

This function sets the way a Texture is repeated when it is drawn with a Quad that is larger than the texture's extent, or when a custom Shader is used which uses texture coordinates outside of [0, 1]. A texture may be clamped or set to repeat in both horizontal and vertical directions.

Clamped textures appear only once (with the edges of the texture stretching to fill the extent of the Quad), whereas repeated ones repeat as many times as there is room in the Quad.


[Open in Browser](https://love2d.org/wiki/Texture:setWrap)

@*param* `horiz` — Horizontal wrapping mode of the texture.

@*param* `vert` — Vertical wrapping mode of the texture.

@*param* `depth` — Wrapping mode for the z-axis of a Volume texture.

```lua
-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
horiz:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)

-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
vert:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)

-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
depth:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)
```

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.ImageData

## clone


```lua
(method) love.Data:clone()
  -> clone: love.Data
```


Creates a new copy of the Data object.


[Open in Browser](https://love2d.org/wiki/Data:clone)

@*return* `clone` — The new copy.

## encode


```lua
(method) love.ImageData:encode(format: "bmp"|"jpg"|"png"|"tga", filename?: string)
  -> filedata: love.FileData
```


Encodes the ImageData and optionally writes it to the save directory.


[Open in Browser](https://love2d.org/wiki/ImageData:encode)


---

@*param* `format` — The format to encode the image as.

@*param* `filename` — The filename to write the file to. If nil, no file will be written but the FileData will still be returned.

@*return* `filedata` — The encoded image as a new FileData object.

```lua
-- 
-- Encoded image formats.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/ImageFormat)
-- 
format:
    | "tga" -- Targa image format.
    | "png" -- PNG image format.
    | "jpg" -- JPG image format.
    | "bmp" -- BMP image format.
```

## getDimensions


```lua
(method) love.ImageData:getDimensions()
  -> width: number
  2. height: number
```


Gets the width and height of the ImageData in pixels.


[Open in Browser](https://love2d.org/wiki/ImageData:getDimensions)

@*return* `width` — The width of the ImageData in pixels.

@*return* `height` — The height of the ImageData in pixels.

## getFFIPointer


```lua
(method) love.Data:getFFIPointer()
  -> pointer: ffi.cdata*
```


Gets an FFI pointer to the Data.

This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.


[Open in Browser](https://love2d.org/wiki/Data:getFFIPointer)

@*return* `pointer` — A raw void* pointer to the Data, or nil if FFI is unavailable.

## getFormat


```lua
(method) love.ImageData:getFormat()
  -> format: "ASTC10x10"|"ASTC10x5"|"ASTC10x6"|"ASTC10x8"|"ASTC12x10"...(+59)
```


Gets the pixel format of the ImageData.


[Open in Browser](https://love2d.org/wiki/ImageData:getFormat)

@*return* `format` — The pixel format the ImageData was created with.

```lua
-- 
-- Pixel formats for Textures, ImageData, and CompressedImageData.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/PixelFormat)
-- 
format:
    | "unknown" -- Indicates unknown pixel format, used internally.
    | "normal" -- Alias for rgba8, or srgba8 if gamma-correct rendering is enabled.
    | "hdr" -- A format suitable for high dynamic range content - an alias for the rgba16f format, normally.
    | "r8" -- Single-channel (red component) format (8 bpp).
    | "rg8" -- Two channels (red and green components) with 8 bits per channel (16 bpp).
    | "rgba8" -- 8 bits per channel (32 bpp) RGBA. Color channel values range from 0-255 (0-1 in shaders).
    | "srgba8" -- gamma-correct version of rgba8.
    | "r16" -- Single-channel (red component) format (16 bpp).
    | "rg16" -- Two channels (red and green components) with 16 bits per channel (32 bpp).
    | "rgba16" -- 16 bits per channel (64 bpp) RGBA. Color channel values range from 0-65535 (0-1 in shaders).
    | "r16f" -- Floating point single-channel format (16 bpp). Color values can range from [-65504, +65504].
    | "rg16f" -- Floating point two-channel format with 16 bits per channel (32 bpp). Color values can range from [-65504, +65504].
    | "rgba16f" -- Floating point RGBA with 16 bits per channel (64 bpp). Color values can range from [-65504, +65504].
    | "r32f" -- Floating point single-channel format (32 bpp).
    | "rg32f" -- Floating point two-channel format with 32 bits per channel (64 bpp).
    | "rgba32f" -- Floating point RGBA with 32 bits per channel (128 bpp).
    | "la8" -- Same as rg8, but accessed as (L, L, L, A)
    | "rgba4" -- 4 bits per channel (16 bpp) RGBA.
    | "rgb5a1" -- RGB with 5 bits each, and a 1-bit alpha channel (16 bpp).
    | "rgb565" -- RGB with 5, 6, and 5 bits each, respectively (16 bpp). There is no alpha channel in this format.
    | "rgb10a2" -- RGB with 10 bits per channel, and a 2-bit alpha channel (32 bpp).
    | "rg11b10f" -- Floating point RGB with 11 bits in the red and green channels, and 10 bits in the blue channel (32 bpp). There is no alpha channel. Color values can range from [0, +65024].
    | "stencil8" -- No depth buffer and 8-bit stencil buffer.
    | "depth16" -- 16-bit depth buffer and no stencil buffer.
    | "depth24" -- 24-bit depth buffer and no stencil buffer.
    | "depth32f" -- 32-bit float depth buffer and no stencil buffer.
    | "depth24stencil8" -- 24-bit depth buffer and 8-bit stencil buffer.
    | "depth32fstencil8" -- 32-bit float depth buffer and 8-bit stencil buffer.
    | "DXT1" -- The DXT1 format. RGB data at 4 bits per pixel (compared to 32 bits for ImageData and regular Images.) Suitable for fully opaque images on desktop systems.
    | "DXT3" -- The DXT3 format. RGBA data at 8 bits per pixel. Smooth variations in opacity do not mix well with this format.
    | "DXT5" -- The DXT5 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on desktop systems.
    | "BC4" -- The BC4 format (also known as 3Dc+ or ATI1.) Stores just the red channel, at 4 bits per pixel.
    | "BC4s" -- The signed variant of the BC4 format. Same as above but pixel values in the texture are in the range of 1 instead of 1 in shaders.
    | "BC5" -- The BC5 format (also known as 3Dc or ATI2.) Stores red and green channels at 8 bits per pixel.
    | "BC5s" -- The signed variant of the BC5 format.
    | "BC6h" -- The BC6H format. Stores half-precision floating-point RGB data in the range of 65504 at 8 bits per pixel. Suitable for HDR images on desktop systems.
    | "BC6hs" -- The signed variant of the BC6H format. Stores RGB data in the range of +65504.
    | "BC7" -- The BC7 format (also known as BPTC.) Stores RGB or RGBA data at 8 bits per pixel.
    | "ETC1" -- The ETC1 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on older Android devices.
    | "ETC2rgb" -- The RGB variant of the ETC2 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on newer mobile devices.
    | "ETC2rgba" -- The RGBA variant of the ETC2 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on newer mobile devices.
    | "ETC2rgba1" -- The RGBA variant of the ETC2 format where pixels are either fully transparent or fully opaque. RGBA data at 4 bits per pixel.
    | "EACr" -- The single-channel variant of the EAC format. Stores just the red channel, at 4 bits per pixel.
    | "EACrs" -- The signed single-channel variant of the EAC format. Same as above but pixel values in the texture are in the range of 1 instead of 1 in shaders.
    | "EACrg" -- The two-channel variant of the EAC format. Stores red and green channels at 8 bits per pixel.
    | "EACrgs" -- The signed two-channel variant of the EAC format.
    | "PVR1rgb2" -- The 2 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 2 bits per pixel. Textures compressed with PVRTC1 formats must be square and power-of-two sized.
    | "PVR1rgb4" -- The 4 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 4 bits per pixel.
    | "PVR1rgba2" -- The 2 bit per pixel RGBA variant of the PVRTC1 format.
    | "PVR1rgba4" -- The 4 bit per pixel RGBA variant of the PVRTC1 format.
    | "ASTC4x4" -- The 4x4 pixels per block variant of the ASTC format. RGBA data at 8 bits per pixel.
    | "ASTC5x4" -- The 5x4 pixels per block variant of the ASTC format. RGBA data at 6.4 bits per pixel.
    | "ASTC5x5" -- The 5x5 pixels per block variant of the ASTC format. RGBA data at 5.12 bits per pixel.
    | "ASTC6x5" -- The 6x5 pixels per block variant of the ASTC format. RGBA data at 4.27 bits per pixel.
    | "ASTC6x6" -- The 6x6 pixels per block variant of the ASTC format. RGBA data at 3.56 bits per pixel.
    | "ASTC8x5" -- The 8x5 pixels per block variant of the ASTC format. RGBA data at 3.2 bits per pixel.
    | "ASTC8x6" -- The 8x6 pixels per block variant of the ASTC format. RGBA data at 2.67 bits per pixel.
    | "ASTC8x8" -- The 8x8 pixels per block variant of the ASTC format. RGBA data at 2 bits per pixel.
    | "ASTC10x5" -- The 10x5 pixels per block variant of the ASTC format. RGBA data at 2.56 bits per pixel.
    | "ASTC10x6" -- The 10x6 pixels per block variant of the ASTC format. RGBA data at 2.13 bits per pixel.
    | "ASTC10x8" -- The 10x8 pixels per block variant of the ASTC format. RGBA data at 1.6 bits per pixel.
    | "ASTC10x10" -- The 10x10 pixels per block variant of the ASTC format. RGBA data at 1.28 bits per pixel.
    | "ASTC12x10" -- The 12x10 pixels per block variant of the ASTC format. RGBA data at 1.07 bits per pixel.
    | "ASTC12x12" -- The 12x12 pixels per block variant of the ASTC format. RGBA data at 0.89 bits per pixel.
```

## getHeight


```lua
(method) love.ImageData:getHeight()
  -> height: number
```


Gets the height of the ImageData in pixels.


[Open in Browser](https://love2d.org/wiki/ImageData:getHeight)

@*return* `height` — The height of the ImageData in pixels.

## getPixel


```lua
(method) love.ImageData:getPixel(x: number, y: number)
  -> r: number
  2. g: number
  3. b: number
  4. a: number
```


Gets the color of a pixel at a specific position in the image.

Valid x and y values start at 0 and go up to image width and height minus 1. Non-integer values are floored.

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/ImageData:getPixel)

@*param* `x` — The position of the pixel on the x-axis.

@*param* `y` — The position of the pixel on the y-axis.

@*return* `r` — The red component (0-1).

@*return* `g` — The green component (0-1).

@*return* `b` — The blue component (0-1).

@*return* `a` — The alpha component (0-1).

## getPointer


```lua
(method) love.Data:getPointer()
  -> pointer: lightuserdata
```


Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.


[Open in Browser](https://love2d.org/wiki/Data:getPointer)

@*return* `pointer` — A raw pointer to the Data.

## getSize


```lua
(method) love.Data:getSize()
  -> size: number
```


Gets the Data's size in bytes.


[Open in Browser](https://love2d.org/wiki/Data:getSize)

@*return* `size` — The size of the Data in bytes.

## getString


```lua
(method) love.Data:getString()
  -> data: string
```


Gets the full Data as a string.


[Open in Browser](https://love2d.org/wiki/Data:getString)

@*return* `data` — The raw data.

## getWidth


```lua
(method) love.ImageData:getWidth()
  -> width: number
```


Gets the width of the ImageData in pixels.


[Open in Browser](https://love2d.org/wiki/ImageData:getWidth)

@*return* `width` — The width of the ImageData in pixels.

## mapPixel


```lua
(method) love.ImageData:mapPixel(pixelFunction: function, x?: number, y?: number, width?: number, height?: number)
```


Transform an image by applying a function to every pixel.

This function is a higher-order function. It takes another function as a parameter, and calls it once for each pixel in the ImageData.

The passed function is called with six parameters for each pixel in turn. The parameters are numbers that represent the x and y coordinates of the pixel and its red, green, blue and alpha values. The function should return the new red, green, blue, and alpha values for that pixel.

function pixelFunction(x, y, r, g, b, a)

    -- template for defining your own pixel mapping function

    -- perform computations giving the new values for r, g, b and a

    -- ...

    return r, g, b, a

end

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/ImageData:mapPixel)

@*param* `pixelFunction` — Function to apply to every pixel.

@*param* `x` — The x-axis of the top-left corner of the area within the ImageData to apply the function to.

@*param* `y` — The y-axis of the top-left corner of the area within the ImageData to apply the function to.

@*param* `width` — The width of the area within the ImageData to apply the function to.

@*param* `height` — The height of the area within the ImageData to apply the function to.

## paste


```lua
(method) love.ImageData:paste(source: love.ImageData, dx: number, dy: number, sx: number, sy: number, sw: number, sh: number)
```


Paste into ImageData from another source ImageData.


[Open in Browser](https://love2d.org/wiki/ImageData:paste)

@*param* `source` — Source ImageData from which to copy.

@*param* `dx` — Destination top-left position on x-axis.

@*param* `dy` — Destination top-left position on y-axis.

@*param* `sx` — Source top-left position on x-axis.

@*param* `sy` — Source top-left position on y-axis.

@*param* `sw` — Source width.

@*param* `sh` — Source height.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setPixel


```lua
(method) love.ImageData:setPixel(x: number, y: number, r: number, g: number, b: number, a: number)
```


Sets the color of a pixel at a specific position in the image.

Valid x and y values start at 0 and go up to image width and height minus 1.

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/ImageData:setPixel)


---

@*param* `x` — The position of the pixel on the x-axis.

@*param* `y` — The position of the pixel on the y-axis.

@*param* `r` — The red component (0-1).

@*param* `g` — The green component (0-1).

@*param* `b` — The blue component (0-1).

@*param* `a` — The alpha component (0-1).

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.ImageFormat


---

# love.IndexDataType


---

# love.Joint

## destroy


```lua
(method) love.Joint:destroy()
```


Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.

In 0.7.2, when you don't have time to wait for garbage collection, this function

may be used to free the object immediately.


[Open in Browser](https://love2d.org/wiki/Joint:destroy)

## getAnchors


```lua
(method) love.Joint:getAnchors()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Get the anchor points of the joint.


[Open in Browser](https://love2d.org/wiki/Joint:getAnchors)

@*return* `x1` — The x-component of the anchor on Body 1.

@*return* `y1` — The y-component of the anchor on Body 1.

@*return* `x2` — The x-component of the anchor on Body 2.

@*return* `y2` — The y-component of the anchor on Body 2.

## getBodies


```lua
(method) love.Joint:getBodies()
  -> bodyA: love.Body
  2. bodyB: love.Body
```


Gets the bodies that the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/Joint:getBodies)

@*return* `bodyA` — The first Body.

@*return* `bodyB` — The second Body.

## getCollideConnected


```lua
(method) love.Joint:getCollideConnected()
  -> c: boolean
```


Gets whether the connected Bodies collide.


[Open in Browser](https://love2d.org/wiki/Joint:getCollideConnected)

@*return* `c` — True if they collide, false otherwise.

## getReactionForce


```lua
(method) love.Joint:getReactionForce(x: number)
  -> x: number
  2. y: number
```


Returns the reaction force in newtons on the second body


[Open in Browser](https://love2d.org/wiki/Joint:getReactionForce)

@*param* `x` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `x` — The x-component of the force.

@*return* `y` — The y-component of the force.

## getReactionTorque


```lua
(method) love.Joint:getReactionTorque(invdt: number)
  -> torque: number
```


Returns the reaction torque on the second body.


[Open in Browser](https://love2d.org/wiki/Joint:getReactionTorque)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `torque` — The reaction torque on the second body.

## getType


```lua
(method) love.Joint:getType()
  -> type: "distance"|"friction"|"gear"|"mouse"|"prismatic"...(+4)
```


Gets a string representing the type.


[Open in Browser](https://love2d.org/wiki/Joint:getType)

@*return* `type` — A string with the name of the Joint type.

```lua
-- 
-- Different types of joints.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JointType)
-- 
type:
    | "distance" -- A DistanceJoint.
    | "friction" -- A FrictionJoint.
    | "gear" -- A GearJoint.
    | "mouse" -- A MouseJoint.
    | "prismatic" -- A PrismaticJoint.
    | "pulley" -- A PulleyJoint.
    | "revolute" -- A RevoluteJoint.
    | "rope" -- A RopeJoint.
    | "weld" -- A WeldJoint.
```

## getUserData


```lua
(method) love.Joint:getUserData()
  -> value: any
```


Returns the Lua value associated with this Joint.


[Open in Browser](https://love2d.org/wiki/Joint:getUserData)

@*return* `value` — The Lua value associated with the Joint.

## isDestroyed


```lua
(method) love.Joint:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Joint is destroyed. Destroyed joints cannot be used.


[Open in Browser](https://love2d.org/wiki/Joint:isDestroyed)

@*return* `destroyed` — Whether the Joint is destroyed.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setUserData


```lua
(method) love.Joint:setUserData(value: any)
```


Associates a Lua value with the Joint.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Joint:setUserData)

@*param* `value` — The Lua value to associate with the Joint.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.JointType


---

# love.Joystick

## getAxes


```lua
(method) love.Joystick:getAxes()
  -> axisDir1: number
  2. axisDir2: number
  3. axisDirN: number
```


Gets the direction of each axis.


[Open in Browser](https://love2d.org/wiki/Joystick:getAxes)

@*return* `axisDir1` — Direction of axis1.

@*return* `axisDir2` — Direction of axis2.

@*return* `axisDirN` — Direction of axisN.

## getAxis


```lua
(method) love.Joystick:getAxis(axis: number)
  -> direction: number
```


Gets the direction of an axis.


[Open in Browser](https://love2d.org/wiki/Joystick:getAxis)

@*param* `axis` — The index of the axis to be checked.

@*return* `direction` — Current value of the axis.

## getAxisCount


```lua
(method) love.Joystick:getAxisCount()
  -> axes: number
```


Gets the number of axes on the joystick.


[Open in Browser](https://love2d.org/wiki/Joystick:getAxisCount)

@*return* `axes` — The number of axes available.

## getButtonCount


```lua
(method) love.Joystick:getButtonCount()
  -> buttons: number
```


Gets the number of buttons on the joystick.


[Open in Browser](https://love2d.org/wiki/Joystick:getButtonCount)

@*return* `buttons` — The number of buttons available.

## getDeviceInfo


```lua
(method) love.Joystick:getDeviceInfo()
  -> vendorID: number
  2. productID: number
  3. productVersion: number
```


Gets the USB vendor ID, product ID, and product version numbers of joystick which consistent across operating systems.

Can be used to show different icons, etc. for different gamepads.


[Open in Browser](https://love2d.org/wiki/Joystick:getDeviceInfo)

@*return* `vendorID` — The USB vendor ID of the joystick.

@*return* `productID` — The USB product ID of the joystick.

@*return* `productVersion` — The product version of the joystick.

## getGUID


```lua
(method) love.Joystick:getGUID()
  -> guid: string
```


Gets a stable GUID unique to the type of the physical joystick which does not change over time. For example, all Sony Dualshock 3 controllers in OS X have the same GUID. The value is platform-dependent.


[Open in Browser](https://love2d.org/wiki/Joystick:getGUID)

@*return* `guid` — The Joystick type's OS-dependent unique identifier.

## getGamepadAxis


```lua
(method) love.Joystick:getGamepadAxis(axis: "leftx"|"lefty"|"rightx"|"righty"|"triggerleft"...(+1))
  -> direction: number
```


Gets the direction of a virtual gamepad axis. If the Joystick isn't recognized as a gamepad or isn't connected, this function will always return 0.


[Open in Browser](https://love2d.org/wiki/Joystick:getGamepadAxis)

@*param* `axis` — The virtual axis to be checked.

@*return* `direction` — Current value of the axis.

```lua
-- 
-- Virtual gamepad axes.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/GamepadAxis)
-- 
axis:
    | "leftx" -- The x-axis of the left thumbstick.
    | "lefty" -- The y-axis of the left thumbstick.
    | "rightx" -- The x-axis of the right thumbstick.
    | "righty" -- The y-axis of the right thumbstick.
    | "triggerleft" -- Left analog trigger.
    | "triggerright" -- Right analog trigger.
```

## getGamepadMapping


```lua
(method) love.Joystick:getGamepadMapping(axis: "leftx"|"lefty"|"rightx"|"righty"|"triggerleft"...(+1))
  -> inputtype: "axis"|"button"|"hat"
  2. inputindex: number
  3. hatdirection: "c"|"d"|"l"|"ld"|"lu"...(+4)
```


Gets the button, axis or hat that a virtual gamepad input is bound to.


[Open in Browser](https://love2d.org/wiki/Joystick:getGamepadMapping)


---

@*param* `axis` — The virtual gamepad axis to get the binding for.

@*return* `inputtype` — The type of input the virtual gamepad axis is bound to.

@*return* `inputindex` — The index of the Joystick's button, axis or hat that the virtual gamepad axis is bound to.

@*return* `hatdirection` — The direction of the hat, if the virtual gamepad axis is bound to a hat. nil otherwise.

```lua
-- 
-- Virtual gamepad axes.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/GamepadAxis)
-- 
axis:
    | "leftx" -- The x-axis of the left thumbstick.
    | "lefty" -- The y-axis of the left thumbstick.
    | "rightx" -- The x-axis of the right thumbstick.
    | "righty" -- The y-axis of the right thumbstick.
    | "triggerleft" -- Left analog trigger.
    | "triggerright" -- Right analog trigger.

-- 
-- Types of Joystick inputs.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JoystickInputType)
-- 
inputtype:
    | "axis" -- Analog axis.
    | "button" -- Button.
    | "hat" -- 8-direction hat value.

-- 
-- Joystick hat positions.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JoystickHat)
-- 
hatdirection:
    | "c" -- Centered
    | "d" -- Down
    | "l" -- Left
    | "ld" -- Left+Down
    | "lu" -- Left+Up
    | "r" -- Right
    | "rd" -- Right+Down
    | "ru" -- Right+Up
    | "u" -- Up
```

## getGamepadMappingString


```lua
(method) love.Joystick:getGamepadMappingString()
  -> mappingstring: string
```


Gets the full gamepad mapping string of this Joystick, or nil if it's not recognized as a gamepad.

The mapping string contains binding information used to map the Joystick's buttons an axes to the standard gamepad layout, and can be used later with love.joystick.loadGamepadMappings.


[Open in Browser](https://love2d.org/wiki/Joystick:getGamepadMappingString)

@*return* `mappingstring` — A string containing the Joystick's gamepad mappings, or nil if the Joystick is not recognized as a gamepad.

## getHat


```lua
(method) love.Joystick:getHat(hat: number)
  -> direction: "c"|"d"|"l"|"ld"|"lu"...(+4)
```


Gets the direction of the Joystick's hat.


[Open in Browser](https://love2d.org/wiki/Joystick:getHat)

@*param* `hat` — The index of the hat to be checked.

@*return* `direction` — The direction the hat is pushed.

```lua
-- 
-- Joystick hat positions.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JoystickHat)
-- 
direction:
    | "c" -- Centered
    | "d" -- Down
    | "l" -- Left
    | "ld" -- Left+Down
    | "lu" -- Left+Up
    | "r" -- Right
    | "rd" -- Right+Down
    | "ru" -- Right+Up
    | "u" -- Up
```

## getHatCount


```lua
(method) love.Joystick:getHatCount()
  -> hats: number
```


Gets the number of hats on the joystick.


[Open in Browser](https://love2d.org/wiki/Joystick:getHatCount)

@*return* `hats` — How many hats the joystick has.

## getID


```lua
(method) love.Joystick:getID()
  -> id: number
  2. instanceid: number
```


Gets the joystick's unique identifier. The identifier will remain the same for the life of the game, even when the Joystick is disconnected and reconnected, but it '''will''' change when the game is re-launched.


[Open in Browser](https://love2d.org/wiki/Joystick:getID)

@*return* `id` — The Joystick's unique identifier. Remains the same as long as the game is running.

@*return* `instanceid` — Unique instance identifier. Changes every time the Joystick is reconnected. nil if the Joystick is not connected.

## getName


```lua
(method) love.Joystick:getName()
  -> name: string
```


Gets the name of the joystick.


[Open in Browser](https://love2d.org/wiki/Joystick:getName)

@*return* `name` — The name of the joystick.

## getVibration


```lua
(method) love.Joystick:getVibration()
  -> left: number
  2. right: number
```


Gets the current vibration motor strengths on a Joystick with rumble support.


[Open in Browser](https://love2d.org/wiki/Joystick:getVibration)

@*return* `left` — Current strength of the left vibration motor on the Joystick.

@*return* `right` — Current strength of the right vibration motor on the Joystick.

## isConnected


```lua
(method) love.Joystick:isConnected()
  -> connected: boolean
```


Gets whether the Joystick is connected.


[Open in Browser](https://love2d.org/wiki/Joystick:isConnected)

@*return* `connected` — True if the Joystick is currently connected, false otherwise.

## isDown


```lua
(method) love.Joystick:isDown(buttonN: number)
  -> anyDown: boolean
```


Checks if a button on the Joystick is pressed.

LÖVE 0.9.0 had a bug which required the button indices passed to Joystick:isDown to be 0-based instead of 1-based, for example button 1 would be 0 for this function. It was fixed in 0.9.1.


[Open in Browser](https://love2d.org/wiki/Joystick:isDown)

@*param* `buttonN` — The index of a button to check.

@*return* `anyDown` — True if any supplied button is down, false if not.

## isGamepad


```lua
(method) love.Joystick:isGamepad()
  -> isgamepad: boolean
```


Gets whether the Joystick is recognized as a gamepad. If this is the case, the Joystick's buttons and axes can be used in a standardized manner across different operating systems and joystick models via Joystick:getGamepadAxis, Joystick:isGamepadDown, love.gamepadpressed, and related functions.

LÖVE automatically recognizes most popular controllers with a similar layout to the Xbox 360 controller as gamepads, but you can add more with love.joystick.setGamepadMapping.


[Open in Browser](https://love2d.org/wiki/Joystick:isGamepad)

@*return* `isgamepad` — True if the Joystick is recognized as a gamepad, false otherwise.

## isGamepadDown


```lua
(method) love.Joystick:isGamepadDown(buttonN: "a"|"b"|"back"|"dpdown"|"dpleft"...(+10))
  -> anyDown: boolean
```


Checks if a virtual gamepad button on the Joystick is pressed. If the Joystick is not recognized as a Gamepad or isn't connected, then this function will always return false.


[Open in Browser](https://love2d.org/wiki/Joystick:isGamepadDown)

@*param* `buttonN` — The gamepad button to check.

@*return* `anyDown` — True if any supplied button is down, false if not.

```lua
-- 
-- Virtual gamepad buttons.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/GamepadButton)
-- 
buttonN:
    | "a" -- Bottom face button (A).
    | "b" -- Right face button (B).
    | "x" -- Left face button (X).
    | "y" -- Top face button (Y).
    | "back" -- Back button.
    | "guide" -- Guide button.
    | "start" -- Start button.
    | "leftstick" -- Left stick click button.
    | "rightstick" -- Right stick click button.
    | "leftshoulder" -- Left bumper.
    | "rightshoulder" -- Right bumper.
    | "dpup" -- D-pad up.
    | "dpdown" -- D-pad down.
    | "dpleft" -- D-pad left.
    | "dpright" -- D-pad right.
```

## isVibrationSupported


```lua
(method) love.Joystick:isVibrationSupported()
  -> supported: boolean
```


Gets whether the Joystick supports vibration.


[Open in Browser](https://love2d.org/wiki/Joystick:isVibrationSupported)

@*return* `supported` — True if rumble / force feedback vibration is supported on this Joystick, false if not.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setVibration


```lua
(method) love.Joystick:setVibration(left: number, right: number)
  -> success: boolean
```


Sets the vibration motor speeds on a Joystick with rumble support. Most common gamepads have this functionality, although not all drivers give proper support. Use Joystick:isVibrationSupported to check.


[Open in Browser](https://love2d.org/wiki/Joystick:setVibration)


---

@*param* `left` — Strength of the left vibration motor on the Joystick. Must be in the range of 1.

@*param* `right` — Strength of the right vibration motor on the Joystick. Must be in the range of 1.

@*return* `success` — True if the vibration was successfully applied, false if not.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.JoystickHat


---

# love.JoystickInputType


---

# love.KeyConstant


---

# love.LineJoin


---

# love.LineStyle


---

# love.MatrixLayout


---

# love.Mesh

## attachAttribute


```lua
(method) love.Mesh:attachAttribute(name: string, mesh: love.Mesh)
```


Attaches a vertex attribute from a different Mesh onto this Mesh, for use when drawing. This can be used to share vertex attribute data between several different Meshes.


[Open in Browser](https://love2d.org/wiki/Mesh:attachAttribute)


---

@*param* `name` — The name of the vertex attribute to attach.

@*param* `mesh` — The Mesh to get the vertex attribute from.

## detachAttribute


```lua
(method) love.Mesh:detachAttribute(name: string)
  -> success: boolean
```


Removes a previously attached vertex attribute from this Mesh.


[Open in Browser](https://love2d.org/wiki/Mesh:detachAttribute)

@*param* `name` — The name of the attached vertex attribute to detach.

@*return* `success` — Whether the attribute was successfully detached.

## flush


```lua
(method) love.Mesh:flush()
```


Immediately sends all modified vertex data in the Mesh to the graphics card.

Normally it isn't necessary to call this method as love.graphics.draw(mesh, ...) will do it automatically if needed, but explicitly using **Mesh:flush** gives more control over when the work happens.

If this method is used, it generally shouldn't be called more than once (at most) between love.graphics.draw(mesh, ...) calls.


[Open in Browser](https://love2d.org/wiki/Mesh:flush)

## getDrawMode


```lua
(method) love.Mesh:getDrawMode()
  -> mode: "fan"|"points"|"strip"|"triangles"
```


Gets the mode used when drawing the Mesh.


[Open in Browser](https://love2d.org/wiki/Mesh:getDrawMode)

@*return* `mode` — The mode used when drawing the Mesh.

```lua
-- 
-- How a Mesh's vertices are used when drawing.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/MeshDrawMode)
-- 
mode:
    | "fan" -- The vertices create a "fan" shape with the first vertex acting as the hub point. Can be easily used to draw simple convex polygons.
    | "strip" -- The vertices create a series of connected triangles using vertices 1, 2, 3, then 3, 2, 4 (note the order), then 3, 4, 5, and so on.
    | "triangles" -- The vertices create unconnected triangles.
    | "points" -- The vertices are drawn as unconnected points (see love.graphics.setPointSize.)
```

## getDrawRange


```lua
(method) love.Mesh:getDrawRange()
  -> min: number
  2. max: number
```


Gets the range of vertices used when drawing the Mesh.


[Open in Browser](https://love2d.org/wiki/Mesh:getDrawRange)

@*return* `min` — The index of the first vertex used when drawing, or the index of the first value in the vertex map used if one is set for this Mesh.

@*return* `max` — The index of the last vertex used when drawing, or the index of the last value in the vertex map used if one is set for this Mesh.

## getTexture


```lua
(method) love.Mesh:getTexture()
  -> texture: love.Texture
```


Gets the texture (Image or Canvas) used when drawing the Mesh.


[Open in Browser](https://love2d.org/wiki/Mesh:getTexture)

@*return* `texture` — The Image or Canvas to texture the Mesh with when drawing, or nil if none is set.

## getVertex


```lua
(method) love.Mesh:getVertex(index: number)
  -> attributecomponent: number
```


Gets the properties of a vertex in the Mesh.

In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/Mesh:getVertex)


---

@*param* `index` — The one-based index of the vertex you want to retrieve the information for.

@*return* `attributecomponent` — The first component of the first vertex attribute in the specified vertex.

## getVertexAttribute


```lua
(method) love.Mesh:getVertexAttribute(vertexindex: number, attributeindex: number)
  -> value1: number
  2. value2: number
```


Gets the properties of a specific attribute within a vertex in the Mesh.

Meshes without a custom vertex format specified in love.graphics.newMesh have position as their first attribute, texture coordinates as their second attribute, and color as their third attribute.


[Open in Browser](https://love2d.org/wiki/Mesh:getVertexAttribute)

@*param* `vertexindex` — The index of the the vertex you want to retrieve the attribute for (one-based).

@*param* `attributeindex` — The index of the attribute within the vertex to be retrieved (one-based).

@*return* `value1` — The value of the first component of the attribute.

@*return* `value2` — The value of the second component of the attribute.

## getVertexCount


```lua
(method) love.Mesh:getVertexCount()
  -> count: number
```


Gets the total number of vertices in the Mesh.


[Open in Browser](https://love2d.org/wiki/Mesh:getVertexCount)

@*return* `count` — The total number of vertices in the mesh.

## getVertexFormat


```lua
(method) love.Mesh:getVertexFormat()
  -> format: { attribute: table }
```


Gets the vertex format that the Mesh was created with.


[Open in Browser](https://love2d.org/wiki/Mesh:getVertexFormat)

@*return* `format` — The vertex format of the Mesh, which is a table containing tables for each vertex attribute the Mesh was created with, in the form of {attribute, ...}.

## getVertexMap


```lua
(method) love.Mesh:getVertexMap()
  -> map: table
```


Gets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the screen.

If no vertex map has been set previously via Mesh:setVertexMap, then this function will return nil in LÖVE 0.10.0+, or an empty table in 0.9.2 and older.


[Open in Browser](https://love2d.org/wiki/Mesh:getVertexMap)

@*return* `map` — A table containing the list of vertex indices used when drawing.

## isAttributeEnabled


```lua
(method) love.Mesh:isAttributeEnabled(name: string)
  -> enabled: boolean
```


Gets whether a specific vertex attribute in the Mesh is enabled. Vertex data from disabled attributes is not used when drawing the Mesh.


[Open in Browser](https://love2d.org/wiki/Mesh:isAttributeEnabled)

@*param* `name` — The name of the vertex attribute to be checked.

@*return* `enabled` — Whether the vertex attribute is used when drawing this Mesh.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setAttributeEnabled


```lua
(method) love.Mesh:setAttributeEnabled(name: string, enable: boolean)
```


Enables or disables a specific vertex attribute in the Mesh. Vertex data from disabled attributes is not used when drawing the Mesh.


[Open in Browser](https://love2d.org/wiki/Mesh:setAttributeEnabled)

@*param* `name` — The name of the vertex attribute to enable or disable.

@*param* `enable` — Whether the vertex attribute is used when drawing this Mesh.

## setDrawMode


```lua
(method) love.Mesh:setDrawMode(mode: "fan"|"points"|"strip"|"triangles")
```


Sets the mode used when drawing the Mesh.


[Open in Browser](https://love2d.org/wiki/Mesh:setDrawMode)

@*param* `mode` — The mode to use when drawing the Mesh.

```lua
-- 
-- How a Mesh's vertices are used when drawing.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/MeshDrawMode)
-- 
mode:
    | "fan" -- The vertices create a "fan" shape with the first vertex acting as the hub point. Can be easily used to draw simple convex polygons.
    | "strip" -- The vertices create a series of connected triangles using vertices 1, 2, 3, then 3, 2, 4 (note the order), then 3, 4, 5, and so on.
    | "triangles" -- The vertices create unconnected triangles.
    | "points" -- The vertices are drawn as unconnected points (see love.graphics.setPointSize.)
```

## setDrawRange


```lua
(method) love.Mesh:setDrawRange(start: number, count: number)
```


Restricts the drawn vertices of the Mesh to a subset of the total.


[Open in Browser](https://love2d.org/wiki/Mesh:setDrawRange)


---

@*param* `start` — The index of the first vertex to use when drawing, or the index of the first value in the vertex map to use if one is set for this Mesh.

@*param* `count` — The number of vertices to use when drawing, or number of values in the vertex map to use if one is set for this Mesh.

## setTexture


```lua
(method) love.Mesh:setTexture(texture: love.Texture)
```


Sets the texture (Image or Canvas) used when drawing the Mesh.


[Open in Browser](https://love2d.org/wiki/Mesh:setTexture)


---

@*param* `texture` — The Image or Canvas to texture the Mesh with when drawing.

## setVertex


```lua
(method) love.Mesh:setVertex(index: number, attributecomponent: number, ...number)
```


Sets the properties of a vertex in the Mesh.

In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/Mesh:setVertex)


---

@*param* `index` — The index of the the vertex you want to modify (one-based).

@*param* `attributecomponent` — The first component of the first vertex attribute in the specified vertex.

## setVertexAttribute


```lua
(method) love.Mesh:setVertexAttribute(vertexindex: number, attributeindex: number, value1: number, value2: number, ...number)
```


Sets the properties of a specific attribute within a vertex in the Mesh.

Meshes without a custom vertex format specified in love.graphics.newMesh have position as their first attribute, texture coordinates as their second attribute, and color as their third attribute.


[Open in Browser](https://love2d.org/wiki/Mesh:setVertexAttribute)

@*param* `vertexindex` — The index of the the vertex to be modified (one-based).

@*param* `attributeindex` — The index of the attribute within the vertex to be modified (one-based).

@*param* `value1` — The new value for the first component of the attribute.

@*param* `value2` — The new value for the second component of the attribute.

## setVertexMap


```lua
(method) love.Mesh:setVertexMap(map: table)
```


Sets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the screen.

The vertex map allows you to re-order or reuse vertices when drawing without changing the actual vertex parameters or duplicating vertices. It is especially useful when combined with different Mesh Draw Modes.


[Open in Browser](https://love2d.org/wiki/Mesh:setVertexMap)


---

@*param* `map` — A table containing a list of vertex indices to use when drawing. Values must be in the range of Mesh:getVertexCount().

## setVertices


```lua
(method) love.Mesh:setVertices(vertices: { attributecomponent: number }, startvertex?: number, count?: number)
```


Replaces a range of vertices in the Mesh with new ones. The total number of vertices in a Mesh cannot be changed after it has been created. This is often more efficient than calling Mesh:setVertex in a loop.


[Open in Browser](https://love2d.org/wiki/Mesh:setVertices)


---

@*param* `vertices` — The table filled with vertex information tables for each vertex, in the form of {vertex, ...} where each vertex is a table in the form of {attributecomponent, ...}.

@*param* `startvertex` — The index of the first vertex to replace.

@*param* `count` — Amount of vertices to replace.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.MeshDrawMode


---

# love.MessageBoxType


---

# love.MipmapMode


---

# love.MotorJoint

## destroy


```lua
(method) love.Joint:destroy()
```


Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.

In 0.7.2, when you don't have time to wait for garbage collection, this function

may be used to free the object immediately.


[Open in Browser](https://love2d.org/wiki/Joint:destroy)

## getAnchors


```lua
(method) love.Joint:getAnchors()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Get the anchor points of the joint.


[Open in Browser](https://love2d.org/wiki/Joint:getAnchors)

@*return* `x1` — The x-component of the anchor on Body 1.

@*return* `y1` — The y-component of the anchor on Body 1.

@*return* `x2` — The x-component of the anchor on Body 2.

@*return* `y2` — The y-component of the anchor on Body 2.

## getAngularOffset


```lua
(method) love.MotorJoint:getAngularOffset()
  -> angleoffset: number
```


Gets the target angular offset between the two Bodies the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/MotorJoint:getAngularOffset)

@*return* `angleoffset` — The target angular offset in radians: the second body's angle minus the first body's angle.

## getBodies


```lua
(method) love.Joint:getBodies()
  -> bodyA: love.Body
  2. bodyB: love.Body
```


Gets the bodies that the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/Joint:getBodies)

@*return* `bodyA` — The first Body.

@*return* `bodyB` — The second Body.

## getCollideConnected


```lua
(method) love.Joint:getCollideConnected()
  -> c: boolean
```


Gets whether the connected Bodies collide.


[Open in Browser](https://love2d.org/wiki/Joint:getCollideConnected)

@*return* `c` — True if they collide, false otherwise.

## getLinearOffset


```lua
(method) love.MotorJoint:getLinearOffset()
  -> x: number
  2. y: number
```


Gets the target linear offset between the two Bodies the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/MotorJoint:getLinearOffset)

@*return* `x` — The x component of the target linear offset, relative to the first Body.

@*return* `y` — The y component of the target linear offset, relative to the first Body.

## getReactionForce


```lua
(method) love.Joint:getReactionForce(x: number)
  -> x: number
  2. y: number
```


Returns the reaction force in newtons on the second body


[Open in Browser](https://love2d.org/wiki/Joint:getReactionForce)

@*param* `x` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `x` — The x-component of the force.

@*return* `y` — The y-component of the force.

## getReactionTorque


```lua
(method) love.Joint:getReactionTorque(invdt: number)
  -> torque: number
```


Returns the reaction torque on the second body.


[Open in Browser](https://love2d.org/wiki/Joint:getReactionTorque)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `torque` — The reaction torque on the second body.

## getType


```lua
(method) love.Joint:getType()
  -> type: "distance"|"friction"|"gear"|"mouse"|"prismatic"...(+4)
```


Gets a string representing the type.


[Open in Browser](https://love2d.org/wiki/Joint:getType)

@*return* `type` — A string with the name of the Joint type.

```lua
-- 
-- Different types of joints.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JointType)
-- 
type:
    | "distance" -- A DistanceJoint.
    | "friction" -- A FrictionJoint.
    | "gear" -- A GearJoint.
    | "mouse" -- A MouseJoint.
    | "prismatic" -- A PrismaticJoint.
    | "pulley" -- A PulleyJoint.
    | "revolute" -- A RevoluteJoint.
    | "rope" -- A RopeJoint.
    | "weld" -- A WeldJoint.
```

## getUserData


```lua
(method) love.Joint:getUserData()
  -> value: any
```


Returns the Lua value associated with this Joint.


[Open in Browser](https://love2d.org/wiki/Joint:getUserData)

@*return* `value` — The Lua value associated with the Joint.

## isDestroyed


```lua
(method) love.Joint:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Joint is destroyed. Destroyed joints cannot be used.


[Open in Browser](https://love2d.org/wiki/Joint:isDestroyed)

@*return* `destroyed` — Whether the Joint is destroyed.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setAngularOffset


```lua
(method) love.MotorJoint:setAngularOffset(angleoffset: number)
```


Sets the target angluar offset between the two Bodies the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/MotorJoint:setAngularOffset)

@*param* `angleoffset` — The target angular offset in radians: the second body's angle minus the first body's angle.

## setLinearOffset


```lua
(method) love.MotorJoint:setLinearOffset(x: number, y: number)
```


Sets the target linear offset between the two Bodies the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/MotorJoint:setLinearOffset)

@*param* `x` — The x component of the target linear offset, relative to the first Body.

@*param* `y` — The y component of the target linear offset, relative to the first Body.

## setUserData


```lua
(method) love.Joint:setUserData(value: any)
```


Associates a Lua value with the Joint.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Joint:setUserData)

@*param* `value` — The Lua value to associate with the Joint.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.MouseJoint

## destroy


```lua
(method) love.Joint:destroy()
```


Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.

In 0.7.2, when you don't have time to wait for garbage collection, this function

may be used to free the object immediately.


[Open in Browser](https://love2d.org/wiki/Joint:destroy)

## getAnchors


```lua
(method) love.Joint:getAnchors()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Get the anchor points of the joint.


[Open in Browser](https://love2d.org/wiki/Joint:getAnchors)

@*return* `x1` — The x-component of the anchor on Body 1.

@*return* `y1` — The y-component of the anchor on Body 1.

@*return* `x2` — The x-component of the anchor on Body 2.

@*return* `y2` — The y-component of the anchor on Body 2.

## getBodies


```lua
(method) love.Joint:getBodies()
  -> bodyA: love.Body
  2. bodyB: love.Body
```


Gets the bodies that the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/Joint:getBodies)

@*return* `bodyA` — The first Body.

@*return* `bodyB` — The second Body.

## getCollideConnected


```lua
(method) love.Joint:getCollideConnected()
  -> c: boolean
```


Gets whether the connected Bodies collide.


[Open in Browser](https://love2d.org/wiki/Joint:getCollideConnected)

@*return* `c` — True if they collide, false otherwise.

## getDampingRatio


```lua
(method) love.MouseJoint:getDampingRatio()
  -> ratio: number
```


Returns the damping ratio.


[Open in Browser](https://love2d.org/wiki/MouseJoint:getDampingRatio)

@*return* `ratio` — The new damping ratio.

## getFrequency


```lua
(method) love.MouseJoint:getFrequency()
  -> freq: number
```


Returns the frequency.


[Open in Browser](https://love2d.org/wiki/MouseJoint:getFrequency)

@*return* `freq` — The frequency in hertz.

## getMaxForce


```lua
(method) love.MouseJoint:getMaxForce()
  -> f: number
```


Gets the highest allowed force.


[Open in Browser](https://love2d.org/wiki/MouseJoint:getMaxForce)

@*return* `f` — The max allowed force.

## getReactionForce


```lua
(method) love.Joint:getReactionForce(x: number)
  -> x: number
  2. y: number
```


Returns the reaction force in newtons on the second body


[Open in Browser](https://love2d.org/wiki/Joint:getReactionForce)

@*param* `x` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `x` — The x-component of the force.

@*return* `y` — The y-component of the force.

## getReactionTorque


```lua
(method) love.Joint:getReactionTorque(invdt: number)
  -> torque: number
```


Returns the reaction torque on the second body.


[Open in Browser](https://love2d.org/wiki/Joint:getReactionTorque)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `torque` — The reaction torque on the second body.

## getTarget


```lua
(method) love.MouseJoint:getTarget()
  -> x: number
  2. y: number
```


Gets the target point.


[Open in Browser](https://love2d.org/wiki/MouseJoint:getTarget)

@*return* `x` — The x-component of the target.

@*return* `y` — The x-component of the target.

## getType


```lua
(method) love.Joint:getType()
  -> type: "distance"|"friction"|"gear"|"mouse"|"prismatic"...(+4)
```


Gets a string representing the type.


[Open in Browser](https://love2d.org/wiki/Joint:getType)

@*return* `type` — A string with the name of the Joint type.

```lua
-- 
-- Different types of joints.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JointType)
-- 
type:
    | "distance" -- A DistanceJoint.
    | "friction" -- A FrictionJoint.
    | "gear" -- A GearJoint.
    | "mouse" -- A MouseJoint.
    | "prismatic" -- A PrismaticJoint.
    | "pulley" -- A PulleyJoint.
    | "revolute" -- A RevoluteJoint.
    | "rope" -- A RopeJoint.
    | "weld" -- A WeldJoint.
```

## getUserData


```lua
(method) love.Joint:getUserData()
  -> value: any
```


Returns the Lua value associated with this Joint.


[Open in Browser](https://love2d.org/wiki/Joint:getUserData)

@*return* `value` — The Lua value associated with the Joint.

## isDestroyed


```lua
(method) love.Joint:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Joint is destroyed. Destroyed joints cannot be used.


[Open in Browser](https://love2d.org/wiki/Joint:isDestroyed)

@*return* `destroyed` — Whether the Joint is destroyed.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setDampingRatio


```lua
(method) love.MouseJoint:setDampingRatio(ratio: number)
```


Sets a new damping ratio.


[Open in Browser](https://love2d.org/wiki/MouseJoint:setDampingRatio)

@*param* `ratio` — The new damping ratio.

## setFrequency


```lua
(method) love.MouseJoint:setFrequency(freq: number)
```


Sets a new frequency.


[Open in Browser](https://love2d.org/wiki/MouseJoint:setFrequency)

@*param* `freq` — The new frequency in hertz.

## setMaxForce


```lua
(method) love.MouseJoint:setMaxForce(f: number)
```


Sets the highest allowed force.


[Open in Browser](https://love2d.org/wiki/MouseJoint:setMaxForce)

@*param* `f` — The max allowed force.

## setTarget


```lua
(method) love.MouseJoint:setTarget(x: number, y: number)
```


Sets the target point.


[Open in Browser](https://love2d.org/wiki/MouseJoint:setTarget)

@*param* `x` — The x-component of the target.

@*param* `y` — The y-component of the target.

## setUserData


```lua
(method) love.Joint:setUserData(value: any)
```


Associates a Lua value with the Joint.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Joint:setUserData)

@*param* `value` — The Lua value to associate with the Joint.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.Object

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.ParticleInsertMode


---

# love.ParticleSystem

## clone


```lua
(method) love.ParticleSystem:clone()
  -> particlesystem: love.ParticleSystem
```


Creates an identical copy of the ParticleSystem in the stopped state.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:clone)

@*return* `particlesystem` — The new identical copy of this ParticleSystem.

## emit


```lua
(method) love.ParticleSystem:emit(numparticles: number)
```


Emits a burst of particles from the particle emitter.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:emit)

@*param* `numparticles` — The amount of particles to emit. The number of emitted particles will be truncated if the particle system's max buffer size is reached.

## getBufferSize


```lua
(method) love.ParticleSystem:getBufferSize()
  -> size: number
```


Gets the maximum number of particles the ParticleSystem can have at once.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getBufferSize)

@*return* `size` — The maximum number of particles.

## getColors


```lua
(method) love.ParticleSystem:getColors()
  -> r1: number
  2. g1: number
  3. b1: number
  4. a1: number
  5. r2: number
  6. g2: number
  7. b2: number
  8. a2: number
  9. r8: number
 10. g8: number
 11. b8: number
 12. a8: number
```


Gets the series of colors applied to the particle sprite.

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getColors)

@*return* `r1` — First color, red component (0-1).

@*return* `g1` — First color, green component (0-1).

@*return* `b1` — First color, blue component (0-1).

@*return* `a1` — First color, alpha component (0-1).

@*return* `r2` — Second color, red component (0-1).

@*return* `g2` — Second color, green component (0-1).

@*return* `b2` — Second color, blue component (0-1).

@*return* `a2` — Second color, alpha component (0-1).

@*return* `r8` — Eighth color, red component (0-1).

@*return* `g8` — Eighth color, green component (0-1).

@*return* `b8` — Eighth color, blue component (0-1).

@*return* `a8` — Eighth color, alpha component (0-1).

## getCount


```lua
(method) love.ParticleSystem:getCount()
  -> count: number
```


Gets the number of particles that are currently in the system.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getCount)

@*return* `count` — The current number of live particles.

## getDirection


```lua
(method) love.ParticleSystem:getDirection()
  -> direction: number
```


Gets the direction of the particle emitter (in radians).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getDirection)

@*return* `direction` — The direction of the emitter (radians).

## getEmissionArea


```lua
(method) love.ParticleSystem:getEmissionArea()
  -> distribution: "borderellipse"|"borderrectangle"|"ellipse"|"none"|"normal"...(+1)
  2. dx: number
  3. dy: number
  4. angle: number
  5. directionRelativeToCenter: boolean
```


Gets the area-based spawn parameters for the particles.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getEmissionArea)

@*return* `distribution` — The type of distribution for new particles.

@*return* `dx` — The maximum spawn distance from the emitter along the x-axis for uniform distribution, or the standard deviation along the x-axis for normal distribution.

@*return* `dy` — The maximum spawn distance from the emitter along the y-axis for uniform distribution, or the standard deviation along the y-axis for normal distribution.

@*return* `angle` — The angle in radians of the emission area.

@*return* `directionRelativeToCenter` — True if newly spawned particles will be oriented relative to the center of the emission area, false otherwise.

```lua
-- 
-- Types of particle area spread distribution.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/AreaSpreadDistribution)
-- 
distribution:
    | "uniform" -- Uniform distribution.
    | "normal" -- Normal (gaussian) distribution.
    | "ellipse" -- Uniform distribution in an ellipse.
    | "borderellipse" -- Distribution in an ellipse with particles spawning at the edges of the ellipse.
    | "borderrectangle" -- Distribution in a rectangle with particles spawning at the edges of the rectangle.
    | "none" -- No distribution - area spread is disabled.
```

## getEmissionRate


```lua
(method) love.ParticleSystem:getEmissionRate()
  -> rate: number
```


Gets the amount of particles emitted per second.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getEmissionRate)

@*return* `rate` — The amount of particles per second.

## getEmitterLifetime


```lua
(method) love.ParticleSystem:getEmitterLifetime()
  -> life: number
```


Gets how long the particle system will emit particles (if -1 then it emits particles forever).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getEmitterLifetime)

@*return* `life` — The lifetime of the emitter (in seconds).

## getInsertMode


```lua
(method) love.ParticleSystem:getInsertMode()
  -> mode: "bottom"|"random"|"top"
```


Gets the mode used when the ParticleSystem adds new particles.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getInsertMode)

@*return* `mode` — The mode used when the ParticleSystem adds new particles.

```lua
-- 
-- How newly created particles are added to the ParticleSystem.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/ParticleInsertMode)
-- 
mode:
    | "top" -- Particles are inserted at the top of the ParticleSystem's list of particles.
    | "bottom" -- Particles are inserted at the bottom of the ParticleSystem's list of particles.
    | "random" -- Particles are inserted at random positions in the ParticleSystem's list of particles.
```

## getLinearAcceleration


```lua
(method) love.ParticleSystem:getLinearAcceleration()
  -> xmin: number
  2. ymin: number
  3. xmax: number
  4. ymax: number
```


Gets the linear acceleration (acceleration along the x and y axes) for particles.

Every particle created will accelerate along the x and y axes between xmin,ymin and xmax,ymax.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getLinearAcceleration)

@*return* `xmin` — The minimum acceleration along the x axis.

@*return* `ymin` — The minimum acceleration along the y axis.

@*return* `xmax` — The maximum acceleration along the x axis.

@*return* `ymax` — The maximum acceleration along the y axis.

## getLinearDamping


```lua
(method) love.ParticleSystem:getLinearDamping()
  -> min: number
  2. max: number
```


Gets the amount of linear damping (constant deceleration) for particles.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getLinearDamping)

@*return* `min` — The minimum amount of linear damping applied to particles.

@*return* `max` — The maximum amount of linear damping applied to particles.

## getOffset


```lua
(method) love.ParticleSystem:getOffset()
  -> ox: number
  2. oy: number
```


Gets the particle image's draw offset.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getOffset)

@*return* `ox` — The x coordinate of the particle image's draw offset.

@*return* `oy` — The y coordinate of the particle image's draw offset.

## getParticleLifetime


```lua
(method) love.ParticleSystem:getParticleLifetime()
  -> min: number
  2. max: number
```


Gets the lifetime of the particles.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getParticleLifetime)

@*return* `min` — The minimum life of the particles (in seconds).

@*return* `max` — The maximum life of the particles (in seconds).

## getPosition


```lua
(method) love.ParticleSystem:getPosition()
  -> x: number
  2. y: number
```


Gets the position of the emitter.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getPosition)

@*return* `x` — Position along x-axis.

@*return* `y` — Position along y-axis.

## getQuads


```lua
(method) love.ParticleSystem:getQuads()
  -> quads: table
```


Gets the series of Quads used for the particle sprites.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getQuads)

@*return* `quads` — A table containing the Quads used.

## getRadialAcceleration


```lua
(method) love.ParticleSystem:getRadialAcceleration()
  -> min: number
  2. max: number
```


Gets the radial acceleration (away from the emitter).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getRadialAcceleration)

@*return* `min` — The minimum acceleration.

@*return* `max` — The maximum acceleration.

## getRotation


```lua
(method) love.ParticleSystem:getRotation()
  -> min: number
  2. max: number
```


Gets the rotation of the image upon particle creation (in radians).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getRotation)

@*return* `min` — The minimum initial angle (radians).

@*return* `max` — The maximum initial angle (radians).

## getSizeVariation


```lua
(method) love.ParticleSystem:getSizeVariation()
  -> variation: number
```


Gets the amount of size variation (0 meaning no variation and 1 meaning full variation between start and end).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getSizeVariation)

@*return* `variation` — The amount of variation (0 meaning no variation and 1 meaning full variation between start and end).

## getSizes


```lua
(method) love.ParticleSystem:getSizes()
  -> size1: number
  2. size2: number
  3. size8: number
```


Gets the series of sizes by which the sprite is scaled. 1.0 is normal size. The particle system will interpolate between each size evenly over the particle's lifetime.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getSizes)

@*return* `size1` — The first size.

@*return* `size2` — The second size.

@*return* `size8` — The eighth size.

## getSpeed


```lua
(method) love.ParticleSystem:getSpeed()
  -> min: number
  2. max: number
```


Gets the speed of the particles.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getSpeed)

@*return* `min` — The minimum linear speed of the particles.

@*return* `max` — The maximum linear speed of the particles.

## getSpin


```lua
(method) love.ParticleSystem:getSpin()
  -> min: number
  2. max: number
  3. variation: number
```


Gets the spin of the sprite.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getSpin)

@*return* `min` — The minimum spin (radians per second).

@*return* `max` — The maximum spin (radians per second).

@*return* `variation` — The degree of variation (0 meaning no variation and 1 meaning full variation between start and end).

## getSpinVariation


```lua
(method) love.ParticleSystem:getSpinVariation()
  -> variation: number
```


Gets the amount of spin variation (0 meaning no variation and 1 meaning full variation between start and end).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getSpinVariation)

@*return* `variation` — The amount of variation (0 meaning no variation and 1 meaning full variation between start and end).

## getSpread


```lua
(method) love.ParticleSystem:getSpread()
  -> spread: number
```


Gets the amount of directional spread of the particle emitter (in radians).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getSpread)

@*return* `spread` — The spread of the emitter (radians).

## getTangentialAcceleration


```lua
(method) love.ParticleSystem:getTangentialAcceleration()
  -> min: number
  2. max: number
```


Gets the tangential acceleration (acceleration perpendicular to the particle's direction).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getTangentialAcceleration)

@*return* `min` — The minimum acceleration.

@*return* `max` — The maximum acceleration.

## getTexture


```lua
(method) love.ParticleSystem:getTexture()
  -> texture: love.Texture
```


Gets the texture (Image or Canvas) used for the particles.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:getTexture)

@*return* `texture` — The Image or Canvas used for the particles.

## hasRelativeRotation


```lua
(method) love.ParticleSystem:hasRelativeRotation()
  -> enable: boolean
```


Gets whether particle angles and rotations are relative to their velocities. If enabled, particles are aligned to the angle of their velocities and rotate relative to that angle.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:hasRelativeRotation)

@*return* `enable` — True if relative particle rotation is enabled, false if it's disabled.

## isActive


```lua
(method) love.ParticleSystem:isActive()
  -> active: boolean
```


Checks whether the particle system is actively emitting particles.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:isActive)

@*return* `active` — True if system is active, false otherwise.

## isPaused


```lua
(method) love.ParticleSystem:isPaused()
  -> paused: boolean
```


Checks whether the particle system is paused.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:isPaused)

@*return* `paused` — True if system is paused, false otherwise.

## isStopped


```lua
(method) love.ParticleSystem:isStopped()
  -> stopped: boolean
```


Checks whether the particle system is stopped.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:isStopped)

@*return* `stopped` — True if system is stopped, false otherwise.

## moveTo


```lua
(method) love.ParticleSystem:moveTo(x: number, y: number)
```


Moves the position of the emitter. This results in smoother particle spawning behaviour than if ParticleSystem:setPosition is used every frame.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:moveTo)

@*param* `x` — Position along x-axis.

@*param* `y` — Position along y-axis.

## pause


```lua
(method) love.ParticleSystem:pause()
```


Pauses the particle emitter.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:pause)

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## reset


```lua
(method) love.ParticleSystem:reset()
```


Resets the particle emitter, removing any existing particles and resetting the lifetime counter.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:reset)

## setBufferSize


```lua
(method) love.ParticleSystem:setBufferSize(size: number)
```


Sets the size of the buffer (the max allowed amount of particles in the system).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setBufferSize)

@*param* `size` — The buffer size.

## setColors


```lua
(method) love.ParticleSystem:setColors(r1: number, g1: number, b1: number, a1?: number, r2?: number, g2?: number, b2?: number, a2?: number, r8?: number, g8?: number, b8?: number, a8?: number)
```


Sets a series of colors to apply to the particle sprite. The particle system will interpolate between each color evenly over the particle's lifetime.

Arguments can be passed in groups of four, representing the components of the desired RGBA value, or as tables of RGBA component values, with a default alpha value of 1 if only three values are given. At least one color must be specified. A maximum of eight may be used.

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setColors)


---

@*param* `r1` — First color, red component (0-1).

@*param* `g1` — First color, green component (0-1).

@*param* `b1` — First color, blue component (0-1).

@*param* `a1` — First color, alpha component (0-1).

@*param* `r2` — Second color, red component (0-1).

@*param* `g2` — Second color, green component (0-1).

@*param* `b2` — Second color, blue component (0-1).

@*param* `a2` — Second color, alpha component (0-1).

@*param* `r8` — Eighth color, red component (0-1).

@*param* `g8` — Eighth color, green component (0-1).

@*param* `b8` — Eighth color, blue component (0-1).

@*param* `a8` — Eighth color, alpha component (0-1).

## setDirection


```lua
(method) love.ParticleSystem:setDirection(direction: number)
```


Sets the direction the particles will be emitted in.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setDirection)

@*param* `direction` — The direction of the particles (in radians).

## setEmissionArea


```lua
(method) love.ParticleSystem:setEmissionArea(distribution: "borderellipse"|"borderrectangle"|"ellipse"|"none"|"normal"...(+1), dx: number, dy: number, angle?: number, directionRelativeToCenter?: boolean)
```


Sets area-based spawn parameters for the particles. Newly created particles will spawn in an area around the emitter based on the parameters to this function.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setEmissionArea)

@*param* `distribution` — The type of distribution for new particles.

@*param* `dx` — The maximum spawn distance from the emitter along the x-axis for uniform distribution, or the standard deviation along the x-axis for normal distribution.

@*param* `dy` — The maximum spawn distance from the emitter along the y-axis for uniform distribution, or the standard deviation along the y-axis for normal distribution.

@*param* `angle` — The angle in radians of the emission area.

@*param* `directionRelativeToCenter` — True if newly spawned particles will be oriented relative to the center of the emission area, false otherwise.

```lua
-- 
-- Types of particle area spread distribution.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/AreaSpreadDistribution)
-- 
distribution:
    | "uniform" -- Uniform distribution.
    | "normal" -- Normal (gaussian) distribution.
    | "ellipse" -- Uniform distribution in an ellipse.
    | "borderellipse" -- Distribution in an ellipse with particles spawning at the edges of the ellipse.
    | "borderrectangle" -- Distribution in a rectangle with particles spawning at the edges of the rectangle.
    | "none" -- No distribution - area spread is disabled.
```

## setEmissionRate


```lua
(method) love.ParticleSystem:setEmissionRate(rate: number)
```


Sets the amount of particles emitted per second.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setEmissionRate)

@*param* `rate` — The amount of particles per second.

## setEmitterLifetime


```lua
(method) love.ParticleSystem:setEmitterLifetime(life: number)
```


Sets how long the particle system should emit particles (if -1 then it emits particles forever).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setEmitterLifetime)

@*param* `life` — The lifetime of the emitter (in seconds).

## setInsertMode


```lua
(method) love.ParticleSystem:setInsertMode(mode: "bottom"|"random"|"top")
```


Sets the mode to use when the ParticleSystem adds new particles.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setInsertMode)

@*param* `mode` — The mode to use when the ParticleSystem adds new particles.

```lua
-- 
-- How newly created particles are added to the ParticleSystem.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/ParticleInsertMode)
-- 
mode:
    | "top" -- Particles are inserted at the top of the ParticleSystem's list of particles.
    | "bottom" -- Particles are inserted at the bottom of the ParticleSystem's list of particles.
    | "random" -- Particles are inserted at random positions in the ParticleSystem's list of particles.
```

## setLinearAcceleration


```lua
(method) love.ParticleSystem:setLinearAcceleration(xmin: number, ymin: number, xmax?: number, ymax?: number)
```


Sets the linear acceleration (acceleration along the x and y axes) for particles.

Every particle created will accelerate along the x and y axes between xmin,ymin and xmax,ymax.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setLinearAcceleration)

@*param* `xmin` — The minimum acceleration along the x axis.

@*param* `ymin` — The minimum acceleration along the y axis.

@*param* `xmax` — The maximum acceleration along the x axis.

@*param* `ymax` — The maximum acceleration along the y axis.

## setLinearDamping


```lua
(method) love.ParticleSystem:setLinearDamping(min: number, max?: number)
```


Sets the amount of linear damping (constant deceleration) for particles.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setLinearDamping)

@*param* `min` — The minimum amount of linear damping applied to particles.

@*param* `max` — The maximum amount of linear damping applied to particles.

## setOffset


```lua
(method) love.ParticleSystem:setOffset(x: number, y: number)
```


Set the offset position which the particle sprite is rotated around.

If this function is not used, the particles rotate around their center.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setOffset)

@*param* `x` — The x coordinate of the rotation offset.

@*param* `y` — The y coordinate of the rotation offset.

## setParticleLifetime


```lua
(method) love.ParticleSystem:setParticleLifetime(min: number, max?: number)
```


Sets the lifetime of the particles.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setParticleLifetime)

@*param* `min` — The minimum life of the particles (in seconds).

@*param* `max` — The maximum life of the particles (in seconds).

## setPosition


```lua
(method) love.ParticleSystem:setPosition(x: number, y: number)
```


Sets the position of the emitter.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setPosition)

@*param* `x` — Position along x-axis.

@*param* `y` — Position along y-axis.

## setQuads


```lua
(method) love.ParticleSystem:setQuads(quad1: love.Quad, quad2: love.Quad)
```


Sets a series of Quads to use for the particle sprites. Particles will choose a Quad from the list based on the particle's current lifetime, allowing for the use of animated sprite sheets with ParticleSystems.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setQuads)


---

@*param* `quad1` — The first Quad to use.

@*param* `quad2` — The second Quad to use.

## setRadialAcceleration


```lua
(method) love.ParticleSystem:setRadialAcceleration(min: number, max?: number)
```


Set the radial acceleration (away from the emitter).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setRadialAcceleration)

@*param* `min` — The minimum acceleration.

@*param* `max` — The maximum acceleration.

## setRelativeRotation


```lua
(method) love.ParticleSystem:setRelativeRotation(enable: boolean)
```


Sets whether particle angles and rotations are relative to their velocities. If enabled, particles are aligned to the angle of their velocities and rotate relative to that angle.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setRelativeRotation)

@*param* `enable` — True to enable relative particle rotation, false to disable it.

## setRotation


```lua
(method) love.ParticleSystem:setRotation(min: number, max?: number)
```


Sets the rotation of the image upon particle creation (in radians).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setRotation)

@*param* `min` — The minimum initial angle (radians).

@*param* `max` — The maximum initial angle (radians).

## setSizeVariation


```lua
(method) love.ParticleSystem:setSizeVariation(variation: number)
```


Sets the amount of size variation (0 meaning no variation and 1 meaning full variation between start and end).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setSizeVariation)

@*param* `variation` — The amount of variation (0 meaning no variation and 1 meaning full variation between start and end).

## setSizes


```lua
(method) love.ParticleSystem:setSizes(size1: number, size2?: number, size8?: number)
```


Sets a series of sizes by which to scale a particle sprite. 1.0 is normal size. The particle system will interpolate between each size evenly over the particle's lifetime.

At least one size must be specified. A maximum of eight may be used.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setSizes)

@*param* `size1` — The first size.

@*param* `size2` — The second size.

@*param* `size8` — The eighth size.

## setSpeed


```lua
(method) love.ParticleSystem:setSpeed(min: number, max?: number)
```


Sets the speed of the particles.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setSpeed)

@*param* `min` — The minimum linear speed of the particles.

@*param* `max` — The maximum linear speed of the particles.

## setSpin


```lua
(method) love.ParticleSystem:setSpin(min: number, max?: number)
```


Sets the spin of the sprite.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setSpin)

@*param* `min` — The minimum spin (radians per second).

@*param* `max` — The maximum spin (radians per second).

## setSpinVariation


```lua
(method) love.ParticleSystem:setSpinVariation(variation: number)
```


Sets the amount of spin variation (0 meaning no variation and 1 meaning full variation between start and end).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setSpinVariation)

@*param* `variation` — The amount of variation (0 meaning no variation and 1 meaning full variation between start and end).

## setSpread


```lua
(method) love.ParticleSystem:setSpread(spread: number)
```


Sets the amount of spread for the system.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setSpread)

@*param* `spread` — The amount of spread (radians).

## setTangentialAcceleration


```lua
(method) love.ParticleSystem:setTangentialAcceleration(min: number, max?: number)
```


Sets the tangential acceleration (acceleration perpendicular to the particle's direction).


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setTangentialAcceleration)

@*param* `min` — The minimum acceleration.

@*param* `max` — The maximum acceleration.

## setTexture


```lua
(method) love.ParticleSystem:setTexture(texture: love.Texture)
```


Sets the texture (Image or Canvas) to be used for the particles.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:setTexture)

@*param* `texture` — An Image or Canvas to use for the particles.

## start


```lua
(method) love.ParticleSystem:start()
```


Starts the particle emitter.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:start)

## stop


```lua
(method) love.ParticleSystem:stop()
```


Stops the particle emitter, resetting the lifetime counter.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:stop)

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.

## update


```lua
(method) love.ParticleSystem:update(dt: number)
```


Updates the particle system; moving, creating and killing particles.


[Open in Browser](https://love2d.org/wiki/ParticleSystem:update)

@*param* `dt` — The time (seconds) since last frame.


---

# love.PixelFormat


---

# love.PolygonShape

## computeAABB


```lua
(method) love.Shape:computeAABB(tx: number, ty: number, tr: number, childIndex?: number)
  -> topLeftX: number
  2. topLeftY: number
  3. bottomRightX: number
  4. bottomRightY: number
```


Returns the points of the bounding box for the transformed shape.


[Open in Browser](https://love2d.org/wiki/Shape:computeAABB)

@*param* `tx` — The translation of the shape on the x-axis.

@*param* `ty` — The translation of the shape on the y-axis.

@*param* `tr` — The shape rotation.

@*param* `childIndex` — The index of the child to compute the bounding box of.

@*return* `topLeftX` — The x position of the top-left point.

@*return* `topLeftY` — The y position of the top-left point.

@*return* `bottomRightX` — The x position of the bottom-right point.

@*return* `bottomRightY` — The y position of the bottom-right point.

## computeMass


```lua
(method) love.Shape:computeMass(density: number)
  -> x: number
  2. y: number
  3. mass: number
  4. inertia: number
```


Computes the mass properties for the shape with the specified density.


[Open in Browser](https://love2d.org/wiki/Shape:computeMass)

@*param* `density` — The shape density.

@*return* `x` — The x postition of the center of mass.

@*return* `y` — The y postition of the center of mass.

@*return* `mass` — The mass of the shape.

@*return* `inertia` — The rotational inertia.

## getChildCount


```lua
(method) love.Shape:getChildCount()
  -> count: number
```


Returns the number of children the shape has.


[Open in Browser](https://love2d.org/wiki/Shape:getChildCount)

@*return* `count` — The number of children.

## getPoints


```lua
(method) love.PolygonShape:getPoints()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Get the local coordinates of the polygon's vertices.

This function has a variable number of return values. It can be used in a nested fashion with love.graphics.polygon.


[Open in Browser](https://love2d.org/wiki/PolygonShape:getPoints)

@*return* `x1` — The x-component of the first vertex.

@*return* `y1` — The y-component of the first vertex.

@*return* `x2` — The x-component of the second vertex.

@*return* `y2` — The y-component of the second vertex.

## getRadius


```lua
(method) love.Shape:getRadius()
  -> radius: number
```


Gets the radius of the shape.


[Open in Browser](https://love2d.org/wiki/Shape:getRadius)

@*return* `radius` — The radius of the shape.

## getType


```lua
(method) love.Shape:getType()
  -> type: "chain"|"circle"|"edge"|"polygon"
```


Gets a string representing the Shape.

This function can be useful for conditional debug drawing.


[Open in Browser](https://love2d.org/wiki/Shape:getType)

@*return* `type` — The type of the Shape.

```lua
-- 
-- The different types of Shapes, as returned by Shape:getType.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/ShapeType)
-- 
type:
    | "circle" -- The Shape is a CircleShape.
    | "polygon" -- The Shape is a PolygonShape.
    | "edge" -- The Shape is a EdgeShape.
    | "chain" -- The Shape is a ChainShape.
```

## rayCast


```lua
(method) love.Shape:rayCast(x1: number, y1: number, x2: number, y2: number, maxFraction: number, tx: number, ty: number, tr: number, childIndex?: number)
  -> xn: number
  2. yn: number
  3. fraction: number
```


Casts a ray against the shape and returns the surface normal vector and the line position where the ray hit. If the ray missed the shape, nil will be returned. The Shape can be transformed to get it into the desired position.

The ray starts on the first point of the input line and goes towards the second point of the line. The fourth argument is the maximum distance the ray is going to travel as a scale factor of the input line length.

The childIndex parameter is used to specify which child of a parent shape, such as a ChainShape, will be ray casted. For ChainShapes, the index of 1 is the first edge on the chain. Ray casting a parent shape will only test the child specified so if you want to test every shape of the parent, you must loop through all of its children.

The world position of the impact can be calculated by multiplying the line vector with the third return value and adding it to the line starting point.

hitx, hity = x1 + (x2 - x1) * fraction, y1 + (y2 - y1) * fraction


[Open in Browser](https://love2d.org/wiki/Shape:rayCast)

@*param* `x1` — The x position of the input line starting point.

@*param* `y1` — The y position of the input line starting point.

@*param* `x2` — The x position of the input line end point.

@*param* `y2` — The y position of the input line end point.

@*param* `maxFraction` — Ray length parameter.

@*param* `tx` — The translation of the shape on the x-axis.

@*param* `ty` — The translation of the shape on the y-axis.

@*param* `tr` — The shape rotation.

@*param* `childIndex` — The index of the child the ray gets cast against.

@*return* `xn` — The x component of the normal vector of the edge where the ray hit the shape.

@*return* `yn` — The y component of the normal vector of the edge where the ray hit the shape.

@*return* `fraction` — The position on the input line where the intersection happened as a factor of the line length.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## testPoint


```lua
(method) love.Shape:testPoint(tx: number, ty: number, tr: number, x: number, y: number)
  -> hit: boolean
```


This is particularly useful for mouse interaction with the shapes. By looping through all shapes and testing the mouse position with this function, we can find which shapes the mouse touches.


[Open in Browser](https://love2d.org/wiki/Shape:testPoint)

@*param* `tx` — Translates the shape along the x-axis.

@*param* `ty` — Translates the shape along the y-axis.

@*param* `tr` — Rotates the shape.

@*param* `x` — The x-component of the point.

@*param* `y` — The y-component of the point.

@*return* `hit` — True if inside, false if outside

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.PowerState


---

# love.PrismaticJoint

## areLimitsEnabled


```lua
(method) love.PrismaticJoint:areLimitsEnabled()
  -> enabled: boolean
```


Checks whether the limits are enabled.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:areLimitsEnabled)

@*return* `enabled` — True if enabled, false otherwise.

## destroy


```lua
(method) love.Joint:destroy()
```


Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.

In 0.7.2, when you don't have time to wait for garbage collection, this function

may be used to free the object immediately.


[Open in Browser](https://love2d.org/wiki/Joint:destroy)

## getAnchors


```lua
(method) love.Joint:getAnchors()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Get the anchor points of the joint.


[Open in Browser](https://love2d.org/wiki/Joint:getAnchors)

@*return* `x1` — The x-component of the anchor on Body 1.

@*return* `y1` — The y-component of the anchor on Body 1.

@*return* `x2` — The x-component of the anchor on Body 2.

@*return* `y2` — The y-component of the anchor on Body 2.

## getAxis


```lua
(method) love.PrismaticJoint:getAxis()
  -> x: number
  2. y: number
```


Gets the world-space axis vector of the Prismatic Joint.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:getAxis)

@*return* `x` — The x-axis coordinate of the world-space axis vector.

@*return* `y` — The y-axis coordinate of the world-space axis vector.

## getBodies


```lua
(method) love.Joint:getBodies()
  -> bodyA: love.Body
  2. bodyB: love.Body
```


Gets the bodies that the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/Joint:getBodies)

@*return* `bodyA` — The first Body.

@*return* `bodyB` — The second Body.

## getCollideConnected


```lua
(method) love.Joint:getCollideConnected()
  -> c: boolean
```


Gets whether the connected Bodies collide.


[Open in Browser](https://love2d.org/wiki/Joint:getCollideConnected)

@*return* `c` — True if they collide, false otherwise.

## getJointSpeed


```lua
(method) love.PrismaticJoint:getJointSpeed()
  -> s: number
```


Get the current joint angle speed.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:getJointSpeed)

@*return* `s` — Joint angle speed in meters/second.

## getJointTranslation


```lua
(method) love.PrismaticJoint:getJointTranslation()
  -> t: number
```


Get the current joint translation.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:getJointTranslation)

@*return* `t` — Joint translation, usually in meters..

## getLimits


```lua
(method) love.PrismaticJoint:getLimits()
  -> lower: number
  2. upper: number
```


Gets the joint limits.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:getLimits)

@*return* `lower` — The lower limit, usually in meters.

@*return* `upper` — The upper limit, usually in meters.

## getLowerLimit


```lua
(method) love.PrismaticJoint:getLowerLimit()
  -> lower: number
```


Gets the lower limit.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:getLowerLimit)

@*return* `lower` — The lower limit, usually in meters.

## getMaxMotorForce


```lua
(method) love.PrismaticJoint:getMaxMotorForce()
  -> f: number
```


Gets the maximum motor force.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:getMaxMotorForce)

@*return* `f` — The maximum motor force, usually in N.

## getMotorForce


```lua
(method) love.PrismaticJoint:getMotorForce(invdt: number)
  -> force: number
```


Returns the current motor force.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:getMotorForce)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `force` — The force on the motor in newtons.

## getMotorSpeed


```lua
(method) love.PrismaticJoint:getMotorSpeed()
  -> s: number
```


Gets the motor speed.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:getMotorSpeed)

@*return* `s` — The motor speed, usually in meters per second.

## getReactionForce


```lua
(method) love.Joint:getReactionForce(x: number)
  -> x: number
  2. y: number
```


Returns the reaction force in newtons on the second body


[Open in Browser](https://love2d.org/wiki/Joint:getReactionForce)

@*param* `x` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `x` — The x-component of the force.

@*return* `y` — The y-component of the force.

## getReactionTorque


```lua
(method) love.Joint:getReactionTorque(invdt: number)
  -> torque: number
```


Returns the reaction torque on the second body.


[Open in Browser](https://love2d.org/wiki/Joint:getReactionTorque)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `torque` — The reaction torque on the second body.

## getReferenceAngle


```lua
(method) love.PrismaticJoint:getReferenceAngle()
  -> angle: number
```


Gets the reference angle.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:getReferenceAngle)

@*return* `angle` — The reference angle in radians.

## getType


```lua
(method) love.Joint:getType()
  -> type: "distance"|"friction"|"gear"|"mouse"|"prismatic"...(+4)
```


Gets a string representing the type.


[Open in Browser](https://love2d.org/wiki/Joint:getType)

@*return* `type` — A string with the name of the Joint type.

```lua
-- 
-- Different types of joints.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JointType)
-- 
type:
    | "distance" -- A DistanceJoint.
    | "friction" -- A FrictionJoint.
    | "gear" -- A GearJoint.
    | "mouse" -- A MouseJoint.
    | "prismatic" -- A PrismaticJoint.
    | "pulley" -- A PulleyJoint.
    | "revolute" -- A RevoluteJoint.
    | "rope" -- A RopeJoint.
    | "weld" -- A WeldJoint.
```

## getUpperLimit


```lua
(method) love.PrismaticJoint:getUpperLimit()
  -> upper: number
```


Gets the upper limit.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:getUpperLimit)

@*return* `upper` — The upper limit, usually in meters.

## getUserData


```lua
(method) love.Joint:getUserData()
  -> value: any
```


Returns the Lua value associated with this Joint.


[Open in Browser](https://love2d.org/wiki/Joint:getUserData)

@*return* `value` — The Lua value associated with the Joint.

## isDestroyed


```lua
(method) love.Joint:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Joint is destroyed. Destroyed joints cannot be used.


[Open in Browser](https://love2d.org/wiki/Joint:isDestroyed)

@*return* `destroyed` — Whether the Joint is destroyed.

## isMotorEnabled


```lua
(method) love.PrismaticJoint:isMotorEnabled()
  -> enabled: boolean
```


Checks whether the motor is enabled.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:isMotorEnabled)

@*return* `enabled` — True if enabled, false if disabled.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setLimits


```lua
(method) love.PrismaticJoint:setLimits(lower: number, upper: number)
```


Sets the limits.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:setLimits)

@*param* `lower` — The lower limit, usually in meters.

@*param* `upper` — The upper limit, usually in meters.

## setLimitsEnabled


```lua
(method) love.PrismaticJoint:setLimitsEnabled()
  -> enable: boolean
```


Enables/disables the joint limit.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:setLimitsEnabled)

@*return* `enable` — True if enabled, false if disabled.

## setLowerLimit


```lua
(method) love.PrismaticJoint:setLowerLimit(lower: number)
```


Sets the lower limit.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:setLowerLimit)

@*param* `lower` — The lower limit, usually in meters.

## setMaxMotorForce


```lua
(method) love.PrismaticJoint:setMaxMotorForce(f: number)
```


Set the maximum motor force.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:setMaxMotorForce)

@*param* `f` — The maximum motor force, usually in N.

## setMotorEnabled


```lua
(method) love.PrismaticJoint:setMotorEnabled(enable: boolean)
```


Enables/disables the joint motor.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:setMotorEnabled)

@*param* `enable` — True to enable, false to disable.

## setMotorSpeed


```lua
(method) love.PrismaticJoint:setMotorSpeed(s: number)
```


Sets the motor speed.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:setMotorSpeed)

@*param* `s` — The motor speed, usually in meters per second.

## setUpperLimit


```lua
(method) love.PrismaticJoint:setUpperLimit(upper: number)
```


Sets the upper limit.


[Open in Browser](https://love2d.org/wiki/PrismaticJoint:setUpperLimit)

@*param* `upper` — The upper limit, usually in meters.

## setUserData


```lua
(method) love.Joint:setUserData(value: any)
```


Associates a Lua value with the Joint.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Joint:setUserData)

@*param* `value` — The Lua value to associate with the Joint.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.PulleyJoint

## destroy


```lua
(method) love.Joint:destroy()
```


Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.

In 0.7.2, when you don't have time to wait for garbage collection, this function

may be used to free the object immediately.


[Open in Browser](https://love2d.org/wiki/Joint:destroy)

## getAnchors


```lua
(method) love.Joint:getAnchors()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Get the anchor points of the joint.


[Open in Browser](https://love2d.org/wiki/Joint:getAnchors)

@*return* `x1` — The x-component of the anchor on Body 1.

@*return* `y1` — The y-component of the anchor on Body 1.

@*return* `x2` — The x-component of the anchor on Body 2.

@*return* `y2` — The y-component of the anchor on Body 2.

## getBodies


```lua
(method) love.Joint:getBodies()
  -> bodyA: love.Body
  2. bodyB: love.Body
```


Gets the bodies that the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/Joint:getBodies)

@*return* `bodyA` — The first Body.

@*return* `bodyB` — The second Body.

## getCollideConnected


```lua
(method) love.Joint:getCollideConnected()
  -> c: boolean
```


Gets whether the connected Bodies collide.


[Open in Browser](https://love2d.org/wiki/Joint:getCollideConnected)

@*return* `c` — True if they collide, false otherwise.

## getConstant


```lua
(method) love.PulleyJoint:getConstant()
  -> length: number
```


Get the total length of the rope.


[Open in Browser](https://love2d.org/wiki/PulleyJoint:getConstant)

@*return* `length` — The length of the rope in the joint.

## getGroundAnchors


```lua
(method) love.PulleyJoint:getGroundAnchors()
  -> a1x: number
  2. a1y: number
  3. a2x: number
  4. a2y: number
```


Get the ground anchor positions in world coordinates.


[Open in Browser](https://love2d.org/wiki/PulleyJoint:getGroundAnchors)

@*return* `a1x` — The x coordinate of the first anchor.

@*return* `a1y` — The y coordinate of the first anchor.

@*return* `a2x` — The x coordinate of the second anchor.

@*return* `a2y` — The y coordinate of the second anchor.

## getLengthA


```lua
(method) love.PulleyJoint:getLengthA()
  -> length: number
```


Get the current length of the rope segment attached to the first body.


[Open in Browser](https://love2d.org/wiki/PulleyJoint:getLengthA)

@*return* `length` — The length of the rope segment.

## getLengthB


```lua
(method) love.PulleyJoint:getLengthB()
  -> length: number
```


Get the current length of the rope segment attached to the second body.


[Open in Browser](https://love2d.org/wiki/PulleyJoint:getLengthB)

@*return* `length` — The length of the rope segment.

## getMaxLengths


```lua
(method) love.PulleyJoint:getMaxLengths()
  -> len1: number
  2. len2: number
```


Get the maximum lengths of the rope segments.


[Open in Browser](https://love2d.org/wiki/PulleyJoint:getMaxLengths)

@*return* `len1` — The maximum length of the first rope segment.

@*return* `len2` — The maximum length of the second rope segment.

## getRatio


```lua
(method) love.PulleyJoint:getRatio()
  -> ratio: number
```


Get the pulley ratio.


[Open in Browser](https://love2d.org/wiki/PulleyJoint:getRatio)

@*return* `ratio` — The pulley ratio of the joint.

## getReactionForce


```lua
(method) love.Joint:getReactionForce(x: number)
  -> x: number
  2. y: number
```


Returns the reaction force in newtons on the second body


[Open in Browser](https://love2d.org/wiki/Joint:getReactionForce)

@*param* `x` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `x` — The x-component of the force.

@*return* `y` — The y-component of the force.

## getReactionTorque


```lua
(method) love.Joint:getReactionTorque(invdt: number)
  -> torque: number
```


Returns the reaction torque on the second body.


[Open in Browser](https://love2d.org/wiki/Joint:getReactionTorque)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `torque` — The reaction torque on the second body.

## getType


```lua
(method) love.Joint:getType()
  -> type: "distance"|"friction"|"gear"|"mouse"|"prismatic"...(+4)
```


Gets a string representing the type.


[Open in Browser](https://love2d.org/wiki/Joint:getType)

@*return* `type` — A string with the name of the Joint type.

```lua
-- 
-- Different types of joints.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JointType)
-- 
type:
    | "distance" -- A DistanceJoint.
    | "friction" -- A FrictionJoint.
    | "gear" -- A GearJoint.
    | "mouse" -- A MouseJoint.
    | "prismatic" -- A PrismaticJoint.
    | "pulley" -- A PulleyJoint.
    | "revolute" -- A RevoluteJoint.
    | "rope" -- A RopeJoint.
    | "weld" -- A WeldJoint.
```

## getUserData


```lua
(method) love.Joint:getUserData()
  -> value: any
```


Returns the Lua value associated with this Joint.


[Open in Browser](https://love2d.org/wiki/Joint:getUserData)

@*return* `value` — The Lua value associated with the Joint.

## isDestroyed


```lua
(method) love.Joint:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Joint is destroyed. Destroyed joints cannot be used.


[Open in Browser](https://love2d.org/wiki/Joint:isDestroyed)

@*return* `destroyed` — Whether the Joint is destroyed.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setConstant


```lua
(method) love.PulleyJoint:setConstant(length: number)
```


Set the total length of the rope.

Setting a new length for the rope updates the maximum length values of the joint.


[Open in Browser](https://love2d.org/wiki/PulleyJoint:setConstant)

@*param* `length` — The new length of the rope in the joint.

## setMaxLengths


```lua
(method) love.PulleyJoint:setMaxLengths(max1: number, max2: number)
```


Set the maximum lengths of the rope segments.

The physics module also imposes maximum values for the rope segments. If the parameters exceed these values, the maximum values are set instead of the requested values.


[Open in Browser](https://love2d.org/wiki/PulleyJoint:setMaxLengths)

@*param* `max1` — The new maximum length of the first segment.

@*param* `max2` — The new maximum length of the second segment.

## setRatio


```lua
(method) love.PulleyJoint:setRatio(ratio: number)
```


Set the pulley ratio.


[Open in Browser](https://love2d.org/wiki/PulleyJoint:setRatio)

@*param* `ratio` — The new pulley ratio of the joint.

## setUserData


```lua
(method) love.Joint:setUserData(value: any)
```


Associates a Lua value with the Joint.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Joint:setUserData)

@*param* `value` — The Lua value to associate with the Joint.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.Quad

## getTextureDimensions


```lua
(method) love.Quad:getTextureDimensions()
  -> sw: number
  2. sh: number
```


Gets reference texture dimensions initially specified in love.graphics.newQuad.


[Open in Browser](https://love2d.org/wiki/Quad:getTextureDimensions)

@*return* `sw` — The Texture width used by the Quad.

@*return* `sh` — The Texture height used by the Quad.

## getViewport


```lua
(method) love.Quad:getViewport()
  -> x: number
  2. y: number
  3. w: number
  4. h: number
```


Gets the current viewport of this Quad.


[Open in Browser](https://love2d.org/wiki/Quad:getViewport)

@*return* `x` — The top-left corner along the x-axis.

@*return* `y` — The top-left corner along the y-axis.

@*return* `w` — The width of the viewport.

@*return* `h` — The height of the viewport.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setViewport


```lua
(method) love.Quad:setViewport(x: number, y: number, w: number, h: number, sw: number, sh: number)
```


Sets the texture coordinates according to a viewport.


[Open in Browser](https://love2d.org/wiki/Quad:setViewport)

@*param* `x` — The top-left corner along the x-axis.

@*param* `y` — The top-left corner along the y-axis.

@*param* `w` — The width of the viewport.

@*param* `h` — The height of the viewport.

@*param* `sw` — The reference width, the width of the Image. (Must be greater than 0.)

@*param* `sh` — The reference height, the height of the Image. (Must be greater than 0.)

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.RandomGenerator

## getSeed


```lua
(method) love.RandomGenerator:getSeed()
  -> low: number
  2. high: number
```


Gets the seed of the random number generator object.

The seed is split into two numbers due to Lua's use of doubles for all number values - doubles can't accurately represent integer  values above 2^53, but the seed value is an integer number in the range of 2^64 - 1.


[Open in Browser](https://love2d.org/wiki/RandomGenerator:getSeed)

@*return* `low` — Integer number representing the lower 32 bits of the RandomGenerator's 64 bit seed value.

@*return* `high` — Integer number representing the higher 32 bits of the RandomGenerator's 64 bit seed value.

## getState


```lua
(method) love.RandomGenerator:getState()
  -> state: string
```


Gets the current state of the random number generator. This returns an opaque string which is only useful for later use with RandomGenerator:setState in the same major version of LÖVE.

This is different from RandomGenerator:getSeed in that getState gets the RandomGenerator's current state, whereas getSeed gets the previously set seed number.


[Open in Browser](https://love2d.org/wiki/RandomGenerator:getState)

@*return* `state` — The current state of the RandomGenerator object, represented as a string.

## random


```lua
(method) love.RandomGenerator:random()
  -> number: number
```


Generates a pseudo-random number in a platform independent manner.


[Open in Browser](https://love2d.org/wiki/RandomGenerator:random)


---

@*return* `number` — The pseudo-random number.

## randomNormal


```lua
(method) love.RandomGenerator:randomNormal(stddev?: number, mean?: number)
  -> number: number
```


Get a normally distributed pseudo random number.


[Open in Browser](https://love2d.org/wiki/RandomGenerator:randomNormal)

@*param* `stddev` — Standard deviation of the distribution.

@*param* `mean` — The mean of the distribution.

@*return* `number` — Normally distributed random number with variance (stddev)² and the specified mean.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setSeed


```lua
(method) love.RandomGenerator:setSeed(seed: number)
```


Sets the seed of the random number generator using the specified integer number.


[Open in Browser](https://love2d.org/wiki/RandomGenerator:setSeed)


---

@*param* `seed` — The integer number with which you want to seed the randomization. Must be within the range of 2^53.

## setState


```lua
(method) love.RandomGenerator:setState(state: string)
```


Sets the current state of the random number generator. The value used as an argument for this function is an opaque string and should only originate from a previous call to RandomGenerator:getState in the same major version of LÖVE.

This is different from RandomGenerator:setSeed in that setState directly sets the RandomGenerator's current implementation-dependent state, whereas setSeed gives it a new seed value.


[Open in Browser](https://love2d.org/wiki/RandomGenerator:setState)

@*param* `state` — The new state of the RandomGenerator object, represented as a string. This should originate from a previous call to RandomGenerator:getState.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.Rasterizer

## getAdvance


```lua
(method) love.Rasterizer:getAdvance()
  -> advance: number
```


Gets font advance.


[Open in Browser](https://love2d.org/wiki/Rasterizer:getAdvance)

@*return* `advance` — Font advance.

## getAscent


```lua
(method) love.Rasterizer:getAscent()
  -> height: number
```


Gets ascent height.


[Open in Browser](https://love2d.org/wiki/Rasterizer:getAscent)

@*return* `height` — Ascent height.

## getDescent


```lua
(method) love.Rasterizer:getDescent()
  -> height: number
```


Gets descent height.


[Open in Browser](https://love2d.org/wiki/Rasterizer:getDescent)

@*return* `height` — Descent height.

## getGlyphCount


```lua
(method) love.Rasterizer:getGlyphCount()
  -> count: number
```


Gets number of glyphs in font.


[Open in Browser](https://love2d.org/wiki/Rasterizer:getGlyphCount)

@*return* `count` — Glyphs count.

## getGlyphData


```lua
(method) love.Rasterizer:getGlyphData(glyph: string)
  -> glyphData: love.GlyphData
```


Gets glyph data of a specified glyph.


[Open in Browser](https://love2d.org/wiki/Rasterizer:getGlyphData)


---

@*param* `glyph` — Glyph

@*return* `glyphData` — Glyph data

## getHeight


```lua
(method) love.Rasterizer:getHeight()
  -> height: number
```


Gets font height.


[Open in Browser](https://love2d.org/wiki/Rasterizer:getHeight)

@*return* `height` — Font height

## getLineHeight


```lua
(method) love.Rasterizer:getLineHeight()
  -> height: number
```


Gets line height of a font.


[Open in Browser](https://love2d.org/wiki/Rasterizer:getLineHeight)

@*return* `height` — Line height of a font.

## hasGlyphs


```lua
(method) love.Rasterizer:hasGlyphs(glyph1: string|number, glyph2: string|number, ...string|number)
  -> hasGlyphs: boolean
```


Checks if font contains specified glyphs.


[Open in Browser](https://love2d.org/wiki/Rasterizer:hasGlyphs)

@*param* `glyph1` — Glyph

@*param* `glyph2` — Glyph

@*return* `hasGlyphs` — Whatever font contains specified glyphs.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.RecordingDevice

## getBitDepth


```lua
(method) love.RecordingDevice:getBitDepth()
  -> bits: number
```


Gets the number of bits per sample in the data currently being recorded.


[Open in Browser](https://love2d.org/wiki/RecordingDevice:getBitDepth)

@*return* `bits` — The number of bits per sample in the data that's currently being recorded.

## getChannelCount


```lua
(method) love.RecordingDevice:getChannelCount()
  -> channels: number
```


Gets the number of channels currently being recorded (mono or stereo).


[Open in Browser](https://love2d.org/wiki/RecordingDevice:getChannelCount)

@*return* `channels` — The number of channels being recorded (1 for mono, 2 for stereo).

## getData


```lua
(method) love.RecordingDevice:getData()
  -> data: love.SoundData
```


Gets all recorded audio SoundData stored in the device's internal ring buffer.

The internal ring buffer is cleared when this function is called, so calling it again will only get audio recorded after the previous call. If the device's internal ring buffer completely fills up before getData is called, the oldest data that doesn't fit into the buffer will be lost.


[Open in Browser](https://love2d.org/wiki/RecordingDevice:getData)

@*return* `data` — The recorded audio data, or nil if the device isn't recording.

## getName


```lua
(method) love.RecordingDevice:getName()
  -> name: string
```


Gets the name of the recording device.


[Open in Browser](https://love2d.org/wiki/RecordingDevice:getName)

@*return* `name` — The name of the device.

## getSampleCount


```lua
(method) love.RecordingDevice:getSampleCount()
  -> samples: number
```


Gets the number of currently recorded samples.


[Open in Browser](https://love2d.org/wiki/RecordingDevice:getSampleCount)

@*return* `samples` — The number of samples that have been recorded so far.

## getSampleRate


```lua
(method) love.RecordingDevice:getSampleRate()
  -> rate: number
```


Gets the number of samples per second currently being recorded.


[Open in Browser](https://love2d.org/wiki/RecordingDevice:getSampleRate)

@*return* `rate` — The number of samples being recorded per second (sample rate).

## isRecording


```lua
(method) love.RecordingDevice:isRecording()
  -> recording: boolean
```


Gets whether the device is currently recording.


[Open in Browser](https://love2d.org/wiki/RecordingDevice:isRecording)

@*return* `recording` — True if the recording, false otherwise.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## start


```lua
(method) love.RecordingDevice:start(samplecount: number, samplerate?: number, bitdepth?: number, channels?: number)
  -> success: boolean
```


Begins recording audio using this device.


[Open in Browser](https://love2d.org/wiki/RecordingDevice:start)

@*param* `samplecount` — The maximum number of samples to store in an internal ring buffer when recording. RecordingDevice:getData clears the internal buffer when called.

@*param* `samplerate` — The number of samples per second to store when recording.

@*param* `bitdepth` — The number of bits per sample.

@*param* `channels` — Whether to record in mono or stereo. Most microphones don't support more than 1 channel.

@*return* `success` — True if the device successfully began recording using the specified parameters, false if not.

## stop


```lua
(method) love.RecordingDevice:stop()
  -> data: love.SoundData
```


Stops recording audio from this device. Any sound data currently in the device's buffer will be returned.


[Open in Browser](https://love2d.org/wiki/RecordingDevice:stop)

@*return* `data` — The sound data currently in the device's buffer, or nil if the device wasn't recording.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.RevoluteJoint

## areLimitsEnabled


```lua
(method) love.RevoluteJoint:areLimitsEnabled()
  -> enabled: boolean
```


Checks whether limits are enabled.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:areLimitsEnabled)

@*return* `enabled` — True if enabled, false otherwise.

## destroy


```lua
(method) love.Joint:destroy()
```


Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.

In 0.7.2, when you don't have time to wait for garbage collection, this function

may be used to free the object immediately.


[Open in Browser](https://love2d.org/wiki/Joint:destroy)

## getAnchors


```lua
(method) love.Joint:getAnchors()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Get the anchor points of the joint.


[Open in Browser](https://love2d.org/wiki/Joint:getAnchors)

@*return* `x1` — The x-component of the anchor on Body 1.

@*return* `y1` — The y-component of the anchor on Body 1.

@*return* `x2` — The x-component of the anchor on Body 2.

@*return* `y2` — The y-component of the anchor on Body 2.

## getBodies


```lua
(method) love.Joint:getBodies()
  -> bodyA: love.Body
  2. bodyB: love.Body
```


Gets the bodies that the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/Joint:getBodies)

@*return* `bodyA` — The first Body.

@*return* `bodyB` — The second Body.

## getCollideConnected


```lua
(method) love.Joint:getCollideConnected()
  -> c: boolean
```


Gets whether the connected Bodies collide.


[Open in Browser](https://love2d.org/wiki/Joint:getCollideConnected)

@*return* `c` — True if they collide, false otherwise.

## getJointAngle


```lua
(method) love.RevoluteJoint:getJointAngle()
  -> angle: number
```


Get the current joint angle.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:getJointAngle)

@*return* `angle` — The joint angle in radians.

## getJointSpeed


```lua
(method) love.RevoluteJoint:getJointSpeed()
  -> s: number
```


Get the current joint angle speed.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:getJointSpeed)

@*return* `s` — Joint angle speed in radians/second.

## getLimits


```lua
(method) love.RevoluteJoint:getLimits()
  -> lower: number
  2. upper: number
```


Gets the joint limits.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:getLimits)

@*return* `lower` — The lower limit, in radians.

@*return* `upper` — The upper limit, in radians.

## getLowerLimit


```lua
(method) love.RevoluteJoint:getLowerLimit()
  -> lower: number
```


Gets the lower limit.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:getLowerLimit)

@*return* `lower` — The lower limit, in radians.

## getMaxMotorTorque


```lua
(method) love.RevoluteJoint:getMaxMotorTorque()
  -> f: number
```


Gets the maximum motor force.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:getMaxMotorTorque)

@*return* `f` — The maximum motor force, in Nm.

## getMotorSpeed


```lua
(method) love.RevoluteJoint:getMotorSpeed()
  -> s: number
```


Gets the motor speed.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:getMotorSpeed)

@*return* `s` — The motor speed, radians per second.

## getMotorTorque


```lua
(method) love.RevoluteJoint:getMotorTorque()
  -> f: number
```


Get the current motor force.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:getMotorTorque)

@*return* `f` — The current motor force, in Nm.

## getReactionForce


```lua
(method) love.Joint:getReactionForce(x: number)
  -> x: number
  2. y: number
```


Returns the reaction force in newtons on the second body


[Open in Browser](https://love2d.org/wiki/Joint:getReactionForce)

@*param* `x` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `x` — The x-component of the force.

@*return* `y` — The y-component of the force.

## getReactionTorque


```lua
(method) love.Joint:getReactionTorque(invdt: number)
  -> torque: number
```


Returns the reaction torque on the second body.


[Open in Browser](https://love2d.org/wiki/Joint:getReactionTorque)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `torque` — The reaction torque on the second body.

## getReferenceAngle


```lua
(method) love.RevoluteJoint:getReferenceAngle()
  -> angle: number
```


Gets the reference angle.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:getReferenceAngle)

@*return* `angle` — The reference angle in radians.

## getType


```lua
(method) love.Joint:getType()
  -> type: "distance"|"friction"|"gear"|"mouse"|"prismatic"...(+4)
```


Gets a string representing the type.


[Open in Browser](https://love2d.org/wiki/Joint:getType)

@*return* `type` — A string with the name of the Joint type.

```lua
-- 
-- Different types of joints.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JointType)
-- 
type:
    | "distance" -- A DistanceJoint.
    | "friction" -- A FrictionJoint.
    | "gear" -- A GearJoint.
    | "mouse" -- A MouseJoint.
    | "prismatic" -- A PrismaticJoint.
    | "pulley" -- A PulleyJoint.
    | "revolute" -- A RevoluteJoint.
    | "rope" -- A RopeJoint.
    | "weld" -- A WeldJoint.
```

## getUpperLimit


```lua
(method) love.RevoluteJoint:getUpperLimit()
  -> upper: number
```


Gets the upper limit.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:getUpperLimit)

@*return* `upper` — The upper limit, in radians.

## getUserData


```lua
(method) love.Joint:getUserData()
  -> value: any
```


Returns the Lua value associated with this Joint.


[Open in Browser](https://love2d.org/wiki/Joint:getUserData)

@*return* `value` — The Lua value associated with the Joint.

## hasLimitsEnabled


```lua
(method) love.RevoluteJoint:hasLimitsEnabled()
  -> enabled: boolean
```


Checks whether limits are enabled.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:hasLimitsEnabled)

@*return* `enabled` — True if enabled, false otherwise.

## isDestroyed


```lua
(method) love.Joint:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Joint is destroyed. Destroyed joints cannot be used.


[Open in Browser](https://love2d.org/wiki/Joint:isDestroyed)

@*return* `destroyed` — Whether the Joint is destroyed.

## isMotorEnabled


```lua
(method) love.RevoluteJoint:isMotorEnabled()
  -> enabled: boolean
```


Checks whether the motor is enabled.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:isMotorEnabled)

@*return* `enabled` — True if enabled, false if disabled.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setLimits


```lua
(method) love.RevoluteJoint:setLimits(lower: number, upper: number)
```


Sets the limits.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:setLimits)

@*param* `lower` — The lower limit, in radians.

@*param* `upper` — The upper limit, in radians.

## setLimitsEnabled


```lua
(method) love.RevoluteJoint:setLimitsEnabled(enable: boolean)
```


Enables/disables the joint limit.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:setLimitsEnabled)

@*param* `enable` — True to enable, false to disable.

## setLowerLimit


```lua
(method) love.RevoluteJoint:setLowerLimit(lower: number)
```


Sets the lower limit.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:setLowerLimit)

@*param* `lower` — The lower limit, in radians.

## setMaxMotorTorque


```lua
(method) love.RevoluteJoint:setMaxMotorTorque(f: number)
```


Set the maximum motor force.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:setMaxMotorTorque)

@*param* `f` — The maximum motor force, in Nm.

## setMotorEnabled


```lua
(method) love.RevoluteJoint:setMotorEnabled(enable: boolean)
```


Enables/disables the joint motor.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:setMotorEnabled)

@*param* `enable` — True to enable, false to disable.

## setMotorSpeed


```lua
(method) love.RevoluteJoint:setMotorSpeed(s: number)
```


Sets the motor speed.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:setMotorSpeed)

@*param* `s` — The motor speed, radians per second.

## setUpperLimit


```lua
(method) love.RevoluteJoint:setUpperLimit(upper: number)
```


Sets the upper limit.


[Open in Browser](https://love2d.org/wiki/RevoluteJoint:setUpperLimit)

@*param* `upper` — The upper limit, in radians.

## setUserData


```lua
(method) love.Joint:setUserData(value: any)
```


Associates a Lua value with the Joint.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Joint:setUserData)

@*param* `value` — The Lua value to associate with the Joint.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.RopeJoint

## destroy


```lua
(method) love.Joint:destroy()
```


Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.

In 0.7.2, when you don't have time to wait for garbage collection, this function

may be used to free the object immediately.


[Open in Browser](https://love2d.org/wiki/Joint:destroy)

## getAnchors


```lua
(method) love.Joint:getAnchors()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Get the anchor points of the joint.


[Open in Browser](https://love2d.org/wiki/Joint:getAnchors)

@*return* `x1` — The x-component of the anchor on Body 1.

@*return* `y1` — The y-component of the anchor on Body 1.

@*return* `x2` — The x-component of the anchor on Body 2.

@*return* `y2` — The y-component of the anchor on Body 2.

## getBodies


```lua
(method) love.Joint:getBodies()
  -> bodyA: love.Body
  2. bodyB: love.Body
```


Gets the bodies that the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/Joint:getBodies)

@*return* `bodyA` — The first Body.

@*return* `bodyB` — The second Body.

## getCollideConnected


```lua
(method) love.Joint:getCollideConnected()
  -> c: boolean
```


Gets whether the connected Bodies collide.


[Open in Browser](https://love2d.org/wiki/Joint:getCollideConnected)

@*return* `c` — True if they collide, false otherwise.

## getMaxLength


```lua
(method) love.RopeJoint:getMaxLength()
  -> maxLength: number
```


Gets the maximum length of a RopeJoint.


[Open in Browser](https://love2d.org/wiki/RopeJoint:getMaxLength)

@*return* `maxLength` — The maximum length of the RopeJoint.

## getReactionForce


```lua
(method) love.Joint:getReactionForce(x: number)
  -> x: number
  2. y: number
```


Returns the reaction force in newtons on the second body


[Open in Browser](https://love2d.org/wiki/Joint:getReactionForce)

@*param* `x` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `x` — The x-component of the force.

@*return* `y` — The y-component of the force.

## getReactionTorque


```lua
(method) love.Joint:getReactionTorque(invdt: number)
  -> torque: number
```


Returns the reaction torque on the second body.


[Open in Browser](https://love2d.org/wiki/Joint:getReactionTorque)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `torque` — The reaction torque on the second body.

## getType


```lua
(method) love.Joint:getType()
  -> type: "distance"|"friction"|"gear"|"mouse"|"prismatic"...(+4)
```


Gets a string representing the type.


[Open in Browser](https://love2d.org/wiki/Joint:getType)

@*return* `type` — A string with the name of the Joint type.

```lua
-- 
-- Different types of joints.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JointType)
-- 
type:
    | "distance" -- A DistanceJoint.
    | "friction" -- A FrictionJoint.
    | "gear" -- A GearJoint.
    | "mouse" -- A MouseJoint.
    | "prismatic" -- A PrismaticJoint.
    | "pulley" -- A PulleyJoint.
    | "revolute" -- A RevoluteJoint.
    | "rope" -- A RopeJoint.
    | "weld" -- A WeldJoint.
```

## getUserData


```lua
(method) love.Joint:getUserData()
  -> value: any
```


Returns the Lua value associated with this Joint.


[Open in Browser](https://love2d.org/wiki/Joint:getUserData)

@*return* `value` — The Lua value associated with the Joint.

## isDestroyed


```lua
(method) love.Joint:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Joint is destroyed. Destroyed joints cannot be used.


[Open in Browser](https://love2d.org/wiki/Joint:isDestroyed)

@*return* `destroyed` — Whether the Joint is destroyed.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setMaxLength


```lua
(method) love.RopeJoint:setMaxLength(maxLength: number)
```


Sets the maximum length of a RopeJoint.


[Open in Browser](https://love2d.org/wiki/RopeJoint:setMaxLength)

@*param* `maxLength` — The new maximum length of the RopeJoint.

## setUserData


```lua
(method) love.Joint:setUserData(value: any)
```


Associates a Lua value with the Joint.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Joint:setUserData)

@*param* `value` — The Lua value to associate with the Joint.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.Scancode


---

# love.Shader

## getWarnings


```lua
(method) love.Shader:getWarnings()
  -> warnings: string
```


Returns any warning and error messages from compiling the shader code. This can be used for debugging your shaders if there's anything the graphics hardware doesn't like.


[Open in Browser](https://love2d.org/wiki/Shader:getWarnings)

@*return* `warnings` — Warning and error messages (if any).

## hasUniform


```lua
(method) love.Shader:hasUniform(name: string)
  -> hasuniform: boolean
```


Gets whether a uniform / extern variable exists in the Shader.

If a graphics driver's shader compiler determines that a uniform / extern variable doesn't affect the final output of the shader, it may optimize the variable out. This function will return false in that case.


[Open in Browser](https://love2d.org/wiki/Shader:hasUniform)

@*param* `name` — The name of the uniform variable.

@*return* `hasuniform` — Whether the uniform exists in the shader and affects its final output.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## send


```lua
(method) love.Shader:send(name: string, number: number, ...number)
```


Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.

uniform float time;  // 'float' is the typical number type used in GLSL shaders.

uniform float varsvec2 light_pos;

uniform vec4 colors[4;

The corresponding send calls would be

shader:send('time', t)

shader:send('vars',a,b)

shader:send('light_pos', {light_x, light_y})

shader:send('colors', {r1, g1, b1, a1},  {r2, g2, b2, a2},  {r3, g3, b3, a3},  {r4, g4, b4, a4})

Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.


[Open in Browser](https://love2d.org/wiki/Shader:send)


---

@*param* `name` — Name of the number to send to the shader.

@*param* `number` — Number to send to store in the uniform variable.

## sendColor


```lua
(method) love.Shader:sendColor(name: string, color: table, ...table)
```


Sends one or more colors to a special (''extern'' / ''uniform'') vec3 or vec4 variable inside the shader. The color components must be in the range of 1. The colors are gamma-corrected if global gamma-correction is enabled.

Extern variables must be marked using the ''extern'' keyword, e.g.

extern vec4 Color;

The corresponding sendColor call would be

shader:sendColor('Color', {r, g, b, a})

Extern variables can be accessed in both the Vertex and Pixel stages of a shader, as long as the variable is declared in each.

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/Shader:sendColor)

@*param* `name` — The name of the color extern variable to send to in the shader.

@*param* `color` — A table with red, green, blue, and optional alpha color components in the range of 1 to send to the extern as a vector.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.Shape

## computeAABB


```lua
(method) love.Shape:computeAABB(tx: number, ty: number, tr: number, childIndex?: number)
  -> topLeftX: number
  2. topLeftY: number
  3. bottomRightX: number
  4. bottomRightY: number
```


Returns the points of the bounding box for the transformed shape.


[Open in Browser](https://love2d.org/wiki/Shape:computeAABB)

@*param* `tx` — The translation of the shape on the x-axis.

@*param* `ty` — The translation of the shape on the y-axis.

@*param* `tr` — The shape rotation.

@*param* `childIndex` — The index of the child to compute the bounding box of.

@*return* `topLeftX` — The x position of the top-left point.

@*return* `topLeftY` — The y position of the top-left point.

@*return* `bottomRightX` — The x position of the bottom-right point.

@*return* `bottomRightY` — The y position of the bottom-right point.

## computeMass


```lua
(method) love.Shape:computeMass(density: number)
  -> x: number
  2. y: number
  3. mass: number
  4. inertia: number
```


Computes the mass properties for the shape with the specified density.


[Open in Browser](https://love2d.org/wiki/Shape:computeMass)

@*param* `density` — The shape density.

@*return* `x` — The x postition of the center of mass.

@*return* `y` — The y postition of the center of mass.

@*return* `mass` — The mass of the shape.

@*return* `inertia` — The rotational inertia.

## getChildCount


```lua
(method) love.Shape:getChildCount()
  -> count: number
```


Returns the number of children the shape has.


[Open in Browser](https://love2d.org/wiki/Shape:getChildCount)

@*return* `count` — The number of children.

## getRadius


```lua
(method) love.Shape:getRadius()
  -> radius: number
```


Gets the radius of the shape.


[Open in Browser](https://love2d.org/wiki/Shape:getRadius)

@*return* `radius` — The radius of the shape.

## getType


```lua
(method) love.Shape:getType()
  -> type: "chain"|"circle"|"edge"|"polygon"
```


Gets a string representing the Shape.

This function can be useful for conditional debug drawing.


[Open in Browser](https://love2d.org/wiki/Shape:getType)

@*return* `type` — The type of the Shape.

```lua
-- 
-- The different types of Shapes, as returned by Shape:getType.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/ShapeType)
-- 
type:
    | "circle" -- The Shape is a CircleShape.
    | "polygon" -- The Shape is a PolygonShape.
    | "edge" -- The Shape is a EdgeShape.
    | "chain" -- The Shape is a ChainShape.
```

## rayCast


```lua
(method) love.Shape:rayCast(x1: number, y1: number, x2: number, y2: number, maxFraction: number, tx: number, ty: number, tr: number, childIndex?: number)
  -> xn: number
  2. yn: number
  3. fraction: number
```


Casts a ray against the shape and returns the surface normal vector and the line position where the ray hit. If the ray missed the shape, nil will be returned. The Shape can be transformed to get it into the desired position.

The ray starts on the first point of the input line and goes towards the second point of the line. The fourth argument is the maximum distance the ray is going to travel as a scale factor of the input line length.

The childIndex parameter is used to specify which child of a parent shape, such as a ChainShape, will be ray casted. For ChainShapes, the index of 1 is the first edge on the chain. Ray casting a parent shape will only test the child specified so if you want to test every shape of the parent, you must loop through all of its children.

The world position of the impact can be calculated by multiplying the line vector with the third return value and adding it to the line starting point.

hitx, hity = x1 + (x2 - x1) * fraction, y1 + (y2 - y1) * fraction


[Open in Browser](https://love2d.org/wiki/Shape:rayCast)

@*param* `x1` — The x position of the input line starting point.

@*param* `y1` — The y position of the input line starting point.

@*param* `x2` — The x position of the input line end point.

@*param* `y2` — The y position of the input line end point.

@*param* `maxFraction` — Ray length parameter.

@*param* `tx` — The translation of the shape on the x-axis.

@*param* `ty` — The translation of the shape on the y-axis.

@*param* `tr` — The shape rotation.

@*param* `childIndex` — The index of the child the ray gets cast against.

@*return* `xn` — The x component of the normal vector of the edge where the ray hit the shape.

@*return* `yn` — The y component of the normal vector of the edge where the ray hit the shape.

@*return* `fraction` — The position on the input line where the intersection happened as a factor of the line length.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## testPoint


```lua
(method) love.Shape:testPoint(tx: number, ty: number, tr: number, x: number, y: number)
  -> hit: boolean
```


This is particularly useful for mouse interaction with the shapes. By looping through all shapes and testing the mouse position with this function, we can find which shapes the mouse touches.


[Open in Browser](https://love2d.org/wiki/Shape:testPoint)

@*param* `tx` — Translates the shape along the x-axis.

@*param* `ty` — Translates the shape along the y-axis.

@*param* `tr` — Rotates the shape.

@*param* `x` — The x-component of the point.

@*param* `y` — The y-component of the point.

@*return* `hit` — True if inside, false if outside

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.ShapeType


---

# love.SoundData

## clone


```lua
(method) love.Data:clone()
  -> clone: love.Data
```


Creates a new copy of the Data object.


[Open in Browser](https://love2d.org/wiki/Data:clone)

@*return* `clone` — The new copy.

## getBitDepth


```lua
(method) love.SoundData:getBitDepth()
  -> bitdepth: number
```


Returns the number of bits per sample.


[Open in Browser](https://love2d.org/wiki/SoundData:getBitDepth)

@*return* `bitdepth` — Either 8, or 16.

## getChannelCount


```lua
(method) love.SoundData:getChannelCount()
  -> channels: number
```


Returns the number of channels in the SoundData.


[Open in Browser](https://love2d.org/wiki/SoundData:getChannelCount)

@*return* `channels` — 1 for mono, 2 for stereo.

## getDuration


```lua
(method) love.SoundData:getDuration()
  -> duration: number
```


Gets the duration of the sound data.


[Open in Browser](https://love2d.org/wiki/SoundData:getDuration)

@*return* `duration` — The duration of the sound data in seconds.

## getFFIPointer


```lua
(method) love.Data:getFFIPointer()
  -> pointer: ffi.cdata*
```


Gets an FFI pointer to the Data.

This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.


[Open in Browser](https://love2d.org/wiki/Data:getFFIPointer)

@*return* `pointer` — A raw void* pointer to the Data, or nil if FFI is unavailable.

## getPointer


```lua
(method) love.Data:getPointer()
  -> pointer: lightuserdata
```


Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.


[Open in Browser](https://love2d.org/wiki/Data:getPointer)

@*return* `pointer` — A raw pointer to the Data.

## getSample


```lua
(method) love.SoundData:getSample(i: number)
  -> sample: number
```


Gets the value of the sample-point at the specified position. For stereo SoundData objects, the data from the left and right channels are interleaved in that order.


[Open in Browser](https://love2d.org/wiki/SoundData:getSample)


---

@*param* `i` — An integer value specifying the position of the sample (starting at 0).

@*return* `sample` — The normalized samplepoint (range -1.0 to 1.0).

## getSampleCount


```lua
(method) love.SoundData:getSampleCount()
  -> count: number
```


Returns the number of samples per channel of the SoundData.


[Open in Browser](https://love2d.org/wiki/SoundData:getSampleCount)

@*return* `count` — Total number of samples.

## getSampleRate


```lua
(method) love.SoundData:getSampleRate()
  -> rate: number
```


Returns the sample rate of the SoundData.


[Open in Browser](https://love2d.org/wiki/SoundData:getSampleRate)

@*return* `rate` — Number of samples per second.

## getSize


```lua
(method) love.Data:getSize()
  -> size: number
```


Gets the Data's size in bytes.


[Open in Browser](https://love2d.org/wiki/Data:getSize)

@*return* `size` — The size of the Data in bytes.

## getString


```lua
(method) love.Data:getString()
  -> data: string
```


Gets the full Data as a string.


[Open in Browser](https://love2d.org/wiki/Data:getString)

@*return* `data` — The raw data.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setSample


```lua
(method) love.SoundData:setSample(i: number, sample: number)
```


Sets the value of the sample-point at the specified position. For stereo SoundData objects, the data from the left and right channels are interleaved in that order.


[Open in Browser](https://love2d.org/wiki/SoundData:setSample)


---

@*param* `i` — An integer value specifying the position of the sample (starting at 0).

@*param* `sample` — The normalized samplepoint (range -1.0 to 1.0).

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.Source

## clone


```lua
(method) love.Source:clone()
  -> source: love.Source
```


Creates an identical copy of the Source in the stopped state.

Static Sources will use significantly less memory and take much less time to be created if Source:clone is used to create them instead of love.audio.newSource, so this method should be preferred when making multiple Sources which play the same sound.


[Open in Browser](https://love2d.org/wiki/Source:clone)

@*return* `source` — The new identical copy of this Source.

## getActiveEffects


```lua
(method) love.Source:getActiveEffects()
  -> effects: table
```


Gets a list of the Source's active effect names.


[Open in Browser](https://love2d.org/wiki/Source:getActiveEffects)

@*return* `effects` — A list of the source's active effect names.

## getAirAbsorption


```lua
(method) love.Source:getAirAbsorption()
  -> amount: number
```


Gets the amount of air absorption applied to the Source.

By default the value is set to 0 which means that air absorption effects are disabled. A value of 1 will apply high frequency attenuation to the Source at a rate of 0.05 dB per meter.


[Open in Browser](https://love2d.org/wiki/Source:getAirAbsorption)

@*return* `amount` — The amount of air absorption applied to the Source.

## getAttenuationDistances


```lua
(method) love.Source:getAttenuationDistances()
  -> ref: number
  2. max: number
```


Gets the reference and maximum attenuation distances of the Source. The values, combined with the current DistanceModel, affect how the Source's volume attenuates based on distance from the listener.


[Open in Browser](https://love2d.org/wiki/Source:getAttenuationDistances)

@*return* `ref` — The current reference attenuation distance. If the current DistanceModel is clamped, this is the minimum distance before the Source is no longer attenuated.

@*return* `max` — The current maximum attenuation distance.

## getChannelCount


```lua
(method) love.Source:getChannelCount()
  -> channels: number
```


Gets the number of channels in the Source. Only 1-channel (mono) Sources can use directional and positional effects.


[Open in Browser](https://love2d.org/wiki/Source:getChannelCount)

@*return* `channels` — 1 for mono, 2 for stereo.

## getCone


```lua
(method) love.Source:getCone()
  -> innerAngle: number
  2. outerAngle: number
  3. outerVolume: number
```


Gets the Source's directional volume cones. Together with Source:setDirection, the cone angles allow for the Source's volume to vary depending on its direction.


[Open in Browser](https://love2d.org/wiki/Source:getCone)

@*return* `innerAngle` — The inner angle from the Source's direction, in radians. The Source will play at normal volume if the listener is inside the cone defined by this angle.

@*return* `outerAngle` — The outer angle from the Source's direction, in radians. The Source will play at a volume between the normal and outer volumes, if the listener is in between the cones defined by the inner and outer angles.

@*return* `outerVolume` — The Source's volume when the listener is outside both the inner and outer cone angles.

## getDirection


```lua
(method) love.Source:getDirection()
  -> x: number
  2. y: number
  3. z: number
```


Gets the direction of the Source.


[Open in Browser](https://love2d.org/wiki/Source:getDirection)

@*return* `x` — The X part of the direction vector.

@*return* `y` — The Y part of the direction vector.

@*return* `z` — The Z part of the direction vector.

## getDuration


```lua
(method) love.Source:getDuration(unit?: "samples"|"seconds")
  -> duration: number
```


Gets the duration of the Source. For streaming Sources it may not always be sample-accurate, and may return -1 if the duration cannot be determined at all.


[Open in Browser](https://love2d.org/wiki/Source:getDuration)

@*param* `unit` — The time unit for the return value.

@*return* `duration` — The duration of the Source, or -1 if it cannot be determined.

```lua
-- 
-- Units that represent time.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/TimeUnit)
-- 
unit:
    | "seconds" -- Regular seconds.
    | "samples" -- Audio samples.
```

## getEffect


```lua
(method) love.Source:getEffect(name: string, filtersettings: table)
  -> filtersettings: { volume: number, highgain: number, lowgain: number }
```


Gets the filter settings associated to a specific effect.

This function returns nil if the effect was applied with no filter settings associated to it.


[Open in Browser](https://love2d.org/wiki/Source:getEffect)

@*param* `name` — The name of the effect.

@*param* `filtersettings` — An optional empty table that will be filled with the filter settings.

@*return* `filtersettings` — The settings for the filter associated to this effect, or nil if the effect is not present in this Source or has no filter associated. The table has the following fields:

## getFilter


```lua
(method) love.Source:getFilter()
  -> settings: { type: "bandpass"|"highpass"|"lowpass", volume: number, highgain: number, lowgain: number }
```


Gets the filter settings currently applied to the Source.


[Open in Browser](https://love2d.org/wiki/Source:getFilter)

@*return* `settings` — The filter settings to use for this Source, or nil if the Source has no active filter. The table has the following fields:

## getFreeBufferCount


```lua
(method) love.Source:getFreeBufferCount()
  -> buffers: number
```


Gets the number of free buffer slots in a queueable Source. If the queueable Source is playing, this value will increase up to the amount the Source was created with. If the queueable Source is stopped, it will process all of its internal buffers first, in which case this function will always return the amount it was created with.


[Open in Browser](https://love2d.org/wiki/Source:getFreeBufferCount)

@*return* `buffers` — How many more SoundData objects can be queued up.

## getPitch


```lua
(method) love.Source:getPitch()
  -> pitch: number
```


Gets the current pitch of the Source.


[Open in Browser](https://love2d.org/wiki/Source:getPitch)

@*return* `pitch` — The pitch, where 1.0 is normal.

## getPosition


```lua
(method) love.Source:getPosition()
  -> x: number
  2. y: number
  3. z: number
```


Gets the position of the Source.


[Open in Browser](https://love2d.org/wiki/Source:getPosition)

@*return* `x` — The X position of the Source.

@*return* `y` — The Y position of the Source.

@*return* `z` — The Z position of the Source.

## getRolloff


```lua
(method) love.Source:getRolloff()
  -> rolloff: number
```


Returns the rolloff factor of the source.


[Open in Browser](https://love2d.org/wiki/Source:getRolloff)

@*return* `rolloff` — The rolloff factor.

## getType


```lua
(method) love.Source:getType()
  -> sourcetype: "queue"|"static"|"stream"
```


Gets the type of the Source.


[Open in Browser](https://love2d.org/wiki/Source:getType)

@*return* `sourcetype` — The type of the source.

```lua
-- 
-- Types of audio sources.
-- 
-- A good rule of thumb is to use stream for music files and static for all short sound effects. Basically, you want to avoid loading large files into memory at once.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/SourceType)
-- 
sourcetype:
    | "static" -- The whole audio is decoded.
    | "stream" -- The audio is decoded in chunks when needed.
    | "queue" -- The audio must be manually queued by the user.
```

## getVelocity


```lua
(method) love.Source:getVelocity()
  -> x: number
  2. y: number
  3. z: number
```


Gets the velocity of the Source.


[Open in Browser](https://love2d.org/wiki/Source:getVelocity)

@*return* `x` — The X part of the velocity vector.

@*return* `y` — The Y part of the velocity vector.

@*return* `z` — The Z part of the velocity vector.

## getVolume


```lua
(method) love.Source:getVolume()
  -> volume: number
```


Gets the current volume of the Source.


[Open in Browser](https://love2d.org/wiki/Source:getVolume)

@*return* `volume` — The volume of the Source, where 1.0 is normal volume.

## getVolumeLimits


```lua
(method) love.Source:getVolumeLimits()
  -> min: number
  2. max: number
```


Returns the volume limits of the source.


[Open in Browser](https://love2d.org/wiki/Source:getVolumeLimits)

@*return* `min` — The minimum volume.

@*return* `max` — The maximum volume.

## isLooping


```lua
(method) love.Source:isLooping()
  -> loop: boolean
```


Returns whether the Source will loop.


[Open in Browser](https://love2d.org/wiki/Source:isLooping)

@*return* `loop` — True if the Source will loop, false otherwise.

## isPlaying


```lua
(method) love.Source:isPlaying()
  -> playing: boolean
```


Returns whether the Source is playing.


[Open in Browser](https://love2d.org/wiki/Source:isPlaying)

@*return* `playing` — True if the Source is playing, false otherwise.

## isRelative


```lua
(method) love.Source:isRelative()
  -> relative: boolean
```


Gets whether the Source's position, velocity, direction, and cone angles are relative to the listener.


[Open in Browser](https://love2d.org/wiki/Source:isRelative)

@*return* `relative` — True if the position, velocity, direction and cone angles are relative to the listener, false if they're absolute.

## pause


```lua
(method) love.Source:pause()
```


Pauses the Source.


[Open in Browser](https://love2d.org/wiki/Source:pause)

## play


```lua
(method) love.Source:play()
  -> success: boolean
```


Starts playing the Source.


[Open in Browser](https://love2d.org/wiki/Source:play)

@*return* `success` — Whether the Source was able to successfully start playing.

## queue


```lua
(method) love.Source:queue(sounddata: love.SoundData)
  -> success: boolean
```


Queues SoundData for playback in a queueable Source.

This method requires the Source to be created via love.audio.newQueueableSource.


[Open in Browser](https://love2d.org/wiki/Source:queue)

@*param* `sounddata` — The data to queue. The SoundData's sample rate, bit depth, and channel count must match the Source's.

@*return* `success` — True if the data was successfully queued for playback, false if there were no available buffers to use for queueing.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## seek


```lua
(method) love.Source:seek(offset: number, unit?: "samples"|"seconds")
```


Sets the currently playing position of the Source.


[Open in Browser](https://love2d.org/wiki/Source:seek)

@*param* `offset` — The position to seek to.

@*param* `unit` — The unit of the position value.

```lua
-- 
-- Units that represent time.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/TimeUnit)
-- 
unit:
    | "seconds" -- Regular seconds.
    | "samples" -- Audio samples.
```

## setAirAbsorption


```lua
(method) love.Source:setAirAbsorption(amount: number)
```


Sets the amount of air absorption applied to the Source.

By default the value is set to 0 which means that air absorption effects are disabled. A value of 1 will apply high frequency attenuation to the Source at a rate of 0.05 dB per meter.

Air absorption can simulate sound transmission through foggy air, dry air, smoky atmosphere, etc. It can be used to simulate different atmospheric conditions within different locations in an area.


[Open in Browser](https://love2d.org/wiki/Source:setAirAbsorption)

@*param* `amount` — The amount of air absorption applied to the Source. Must be between 0 and 10.

## setAttenuationDistances


```lua
(method) love.Source:setAttenuationDistances(ref: number, max: number)
```


Sets the reference and maximum attenuation distances of the Source. The parameters, combined with the current DistanceModel, affect how the Source's volume attenuates based on distance.

Distance attenuation is only applicable to Sources based on mono (rather than stereo) audio.


[Open in Browser](https://love2d.org/wiki/Source:setAttenuationDistances)

@*param* `ref` — The new reference attenuation distance. If the current DistanceModel is clamped, this is the minimum attenuation distance.

@*param* `max` — The new maximum attenuation distance.

## setCone


```lua
(method) love.Source:setCone(innerAngle: number, outerAngle: number, outerVolume?: number)
```


Sets the Source's directional volume cones. Together with Source:setDirection, the cone angles allow for the Source's volume to vary depending on its direction.


[Open in Browser](https://love2d.org/wiki/Source:setCone)

@*param* `innerAngle` — The inner angle from the Source's direction, in radians. The Source will play at normal volume if the listener is inside the cone defined by this angle.

@*param* `outerAngle` — The outer angle from the Source's direction, in radians. The Source will play at a volume between the normal and outer volumes, if the listener is in between the cones defined by the inner and outer angles.

@*param* `outerVolume` — The Source's volume when the listener is outside both the inner and outer cone angles.

## setDirection


```lua
(method) love.Source:setDirection(x: number, y: number, z: number)
```


Sets the direction vector of the Source. A zero vector makes the source non-directional.


[Open in Browser](https://love2d.org/wiki/Source:setDirection)

@*param* `x` — The X part of the direction vector.

@*param* `y` — The Y part of the direction vector.

@*param* `z` — The Z part of the direction vector.

## setEffect


```lua
(method) love.Source:setEffect(name: string, enable?: boolean)
  -> success: boolean
```


Applies an audio effect to the Source.

The effect must have been previously defined using love.audio.setEffect.


[Open in Browser](https://love2d.org/wiki/Source:setEffect)


---

@*param* `name` — The name of the effect previously set up with love.audio.setEffect.

@*param* `enable` — If false and the given effect name was previously enabled on this Source, disables the effect.

@*return* `success` — Whether the effect was successfully applied to this Source.

## setFilter


```lua
(method) love.Source:setFilter(settings: { type: "bandpass"|"highpass"|"lowpass", volume: number, highgain: number, lowgain: number })
  -> success: boolean
```


Sets a low-pass, high-pass, or band-pass filter to apply when playing the Source.


[Open in Browser](https://love2d.org/wiki/Source:setFilter)


---

@*param* `settings` — The filter settings to use for this Source, with the following fields:

@*return* `success` — Whether the filter was successfully applied to the Source.

## setLooping


```lua
(method) love.Source:setLooping(loop: boolean)
```


Sets whether the Source should loop.


[Open in Browser](https://love2d.org/wiki/Source:setLooping)

@*param* `loop` — True if the source should loop, false otherwise.

## setPitch


```lua
(method) love.Source:setPitch(pitch: number)
```


Sets the pitch of the Source.


[Open in Browser](https://love2d.org/wiki/Source:setPitch)

@*param* `pitch` — Calculated with regard to 1 being the base pitch. Each reduction by 50 percent equals a pitch shift of -12 semitones (one octave reduction). Each doubling equals a pitch shift of 12 semitones (one octave increase). Zero is not a legal value.

## setPosition


```lua
(method) love.Source:setPosition(x: number, y: number, z: number)
```


Sets the position of the Source. Please note that this only works for mono (i.e. non-stereo) sound files!


[Open in Browser](https://love2d.org/wiki/Source:setPosition)

@*param* `x` — The X position of the Source.

@*param* `y` — The Y position of the Source.

@*param* `z` — The Z position of the Source.

## setRelative


```lua
(method) love.Source:setRelative(enable?: boolean)
```


Sets whether the Source's position, velocity, direction, and cone angles are relative to the listener, or absolute.

By default, all sources are absolute and therefore relative to the origin of love's coordinate system 0, 0. Only absolute sources are affected by the position of the listener. Please note that positional audio only works for mono (i.e. non-stereo) sources.


[Open in Browser](https://love2d.org/wiki/Source:setRelative)

@*param* `enable` — True to make the position, velocity, direction and cone angles relative to the listener, false to make them absolute.

## setRolloff


```lua
(method) love.Source:setRolloff(rolloff: number)
```


Sets the rolloff factor which affects the strength of the used distance attenuation.

Extended information and detailed formulas can be found in the chapter '3.4. Attenuation By Distance' of OpenAL 1.1 specification.


[Open in Browser](https://love2d.org/wiki/Source:setRolloff)

@*param* `rolloff` — The new rolloff factor.

## setVelocity


```lua
(method) love.Source:setVelocity(x: number, y: number, z: number)
```


Sets the velocity of the Source.

This does '''not''' change the position of the Source, but lets the application know how it has to calculate the doppler effect.


[Open in Browser](https://love2d.org/wiki/Source:setVelocity)

@*param* `x` — The X part of the velocity vector.

@*param* `y` — The Y part of the velocity vector.

@*param* `z` — The Z part of the velocity vector.

## setVolume


```lua
(method) love.Source:setVolume(volume: number)
```


Sets the current volume of the Source.


[Open in Browser](https://love2d.org/wiki/Source:setVolume)

@*param* `volume` — The volume for a Source, where 1.0 is normal volume. Volume cannot be raised above 1.0.

## setVolumeLimits


```lua
(method) love.Source:setVolumeLimits(min: number, max: number)
```


Sets the volume limits of the source. The limits have to be numbers from 0 to 1.


[Open in Browser](https://love2d.org/wiki/Source:setVolumeLimits)

@*param* `min` — The minimum volume.

@*param* `max` — The maximum volume.

## stop


```lua
(method) love.Source:stop()
```


Stops a Source.


[Open in Browser](https://love2d.org/wiki/Source:stop)

## tell


```lua
(method) love.Source:tell(unit?: "samples"|"seconds")
  -> position: number
```


Gets the currently playing position of the Source.


[Open in Browser](https://love2d.org/wiki/Source:tell)

@*param* `unit` — The type of unit for the return value.

@*return* `position` — The currently playing position of the Source.

```lua
-- 
-- Units that represent time.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/TimeUnit)
-- 
unit:
    | "seconds" -- Regular seconds.
    | "samples" -- Audio samples.
```

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.SourceType


---

# love.SpriteBatch

## add


```lua
(method) love.SpriteBatch:add(x: number, y: number, r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
  -> id: number
```


Adds a sprite to the batch. Sprites are drawn in the order they are added.


[Open in Browser](https://love2d.org/wiki/SpriteBatch:add)


---

@*param* `x` — The position to draw the object (x-axis).

@*param* `y` — The position to draw the object (y-axis).

@*param* `r` — Orientation (radians).

@*param* `sx` — Scale factor (x-axis).

@*param* `sy` — Scale factor (y-axis).

@*param* `ox` — Origin offset (x-axis).

@*param* `oy` — Origin offset (y-axis).

@*param* `kx` — Shear factor (x-axis).

@*param* `ky` — Shear factor (y-axis).

@*return* `id` — An identifier for the added sprite.

## addLayer


```lua
(method) love.SpriteBatch:addLayer(layerindex: number, x?: number, y?: number, r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
  -> spriteindex: number
```


Adds a sprite to a batch created with an Array Texture.


[Open in Browser](https://love2d.org/wiki/SpriteBatch:addLayer)


---

@*param* `layerindex` — The index of the layer to use for this sprite.

@*param* `x` — The position to draw the sprite (x-axis).

@*param* `y` — The position to draw the sprite (y-axis).

@*param* `r` — Orientation (radians).

@*param* `sx` — Scale factor (x-axis).

@*param* `sy` — Scale factor (y-axis).

@*param* `ox` — Origin offset (x-axis).

@*param* `oy` — Origin offset (y-axis).

@*param* `kx` — Shearing factor (x-axis).

@*param* `ky` — Shearing factor (y-axis).

@*return* `spriteindex` — The index of the added sprite, for use with SpriteBatch:set or SpriteBatch:setLayer.

## attachAttribute


```lua
(method) love.SpriteBatch:attachAttribute(name: string, mesh: love.Mesh)
```


Attaches a per-vertex attribute from a Mesh onto this SpriteBatch, for use when drawing. This can be combined with a Shader to augment a SpriteBatch with per-vertex or additional per-sprite information instead of just having per-sprite colors.

Each sprite in a SpriteBatch has 4 vertices in the following order: top-left, bottom-left, top-right, bottom-right. The index returned by SpriteBatch:add (and used by SpriteBatch:set) can used to determine the first vertex of a specific sprite with the formula 1 + 4 * ( id - 1 ).


[Open in Browser](https://love2d.org/wiki/SpriteBatch:attachAttribute)

@*param* `name` — The name of the vertex attribute to attach.

@*param* `mesh` — The Mesh to get the vertex attribute from.

## clear


```lua
(method) love.SpriteBatch:clear()
```


Removes all sprites from the buffer.


[Open in Browser](https://love2d.org/wiki/SpriteBatch:clear)

## flush


```lua
(method) love.SpriteBatch:flush()
```


Immediately sends all new and modified sprite data in the batch to the graphics card.

Normally it isn't necessary to call this method as love.graphics.draw(spritebatch, ...) will do it automatically if needed, but explicitly using SpriteBatch:flush gives more control over when the work happens.

If this method is used, it generally shouldn't be called more than once (at most) between love.graphics.draw(spritebatch, ...) calls.


[Open in Browser](https://love2d.org/wiki/SpriteBatch:flush)

## getBufferSize


```lua
(method) love.SpriteBatch:getBufferSize()
  -> size: number
```


Gets the maximum number of sprites the SpriteBatch can hold.


[Open in Browser](https://love2d.org/wiki/SpriteBatch:getBufferSize)

@*return* `size` — The maximum number of sprites the batch can hold.

## getColor


```lua
(method) love.SpriteBatch:getColor()
  -> r: number
  2. g: number
  3. b: number
  4. a: number
```


Gets the color that will be used for the next add and set operations.

If no color has been set with SpriteBatch:setColor or the current SpriteBatch color has been cleared, this method will return nil.

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/SpriteBatch:getColor)

@*return* `r` — The red component (0-1).

@*return* `g` — The green component (0-1).

@*return* `b` — The blue component (0-1).

@*return* `a` — The alpha component (0-1).

## getCount


```lua
(method) love.SpriteBatch:getCount()
  -> count: number
```


Gets the number of sprites currently in the SpriteBatch.


[Open in Browser](https://love2d.org/wiki/SpriteBatch:getCount)

@*return* `count` — The number of sprites currently in the batch.

## getTexture


```lua
(method) love.SpriteBatch:getTexture()
  -> texture: love.Texture
```


Gets the texture (Image or Canvas) used by the SpriteBatch.


[Open in Browser](https://love2d.org/wiki/SpriteBatch:getTexture)

@*return* `texture` — The Image or Canvas used by the SpriteBatch.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## set


```lua
(method) love.SpriteBatch:set(spriteindex: number, x: number, y: number, r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
```


Changes a sprite in the batch. This requires the sprite index returned by SpriteBatch:add or SpriteBatch:addLayer.


[Open in Browser](https://love2d.org/wiki/SpriteBatch:set)


---

@*param* `spriteindex` — The index of the sprite that will be changed.

@*param* `x` — The position to draw the object (x-axis).

@*param* `y` — The position to draw the object (y-axis).

@*param* `r` — Orientation (radians).

@*param* `sx` — Scale factor (x-axis).

@*param* `sy` — Scale factor (y-axis).

@*param* `ox` — Origin offset (x-axis).

@*param* `oy` — Origin offset (y-axis).

@*param* `kx` — Shear factor (x-axis).

@*param* `ky` — Shear factor (y-axis).

## setColor


```lua
(method) love.SpriteBatch:setColor(r: number, g: number, b: number, a?: number)
```


Sets the color that will be used for the next add and set operations. Calling the function without arguments will disable all per-sprite colors for the SpriteBatch.

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.

In version 0.9.2 and older, the global color set with love.graphics.setColor will not work on the SpriteBatch if any of the sprites has its own color.


[Open in Browser](https://love2d.org/wiki/SpriteBatch:setColor)


---

@*param* `r` — The amount of red.

@*param* `g` — The amount of green.

@*param* `b` — The amount of blue.

@*param* `a` — The amount of alpha.

## setDrawRange


```lua
(method) love.SpriteBatch:setDrawRange(start: number, count: number)
```


Restricts the drawn sprites in the SpriteBatch to a subset of the total.


[Open in Browser](https://love2d.org/wiki/SpriteBatch:setDrawRange)


---

@*param* `start` — The index of the first sprite to draw. Index 1 corresponds to the first sprite added with SpriteBatch:add.

@*param* `count` — The number of sprites to draw.

## setLayer


```lua
(method) love.SpriteBatch:setLayer(spriteindex: number, layerindex: number, x?: number, y?: number, r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
```


Changes a sprite previously added with add or addLayer, in a batch created with an Array Texture.


[Open in Browser](https://love2d.org/wiki/SpriteBatch:setLayer)


---

@*param* `spriteindex` — The index of the existing sprite to replace.

@*param* `layerindex` — The index of the layer in the Array Texture to use for this sprite.

@*param* `x` — The position to draw the sprite (x-axis).

@*param* `y` — The position to draw the sprite (y-axis).

@*param* `r` — Orientation (radians).

@*param* `sx` — Scale factor (x-axis).

@*param* `sy` — Scale factor (y-axis).

@*param* `ox` — Origin offset (x-axis).

@*param* `oy` — Origin offset (y-axis).

@*param* `kx` — Shearing factor (x-axis).

@*param* `ky` — Shearing factor (y-axis).

## setTexture


```lua
(method) love.SpriteBatch:setTexture(texture: love.Texture)
```


Sets the texture (Image or Canvas) used for the sprites in the batch, when drawing.


[Open in Browser](https://love2d.org/wiki/SpriteBatch:setTexture)

@*param* `texture` — The new Image or Canvas to use for the sprites in the batch.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.SpriteBatchUsage


---

# love.StackType


---

# love.StencilAction


---

# love.Text

## add


```lua
(method) love.Text:add(textstring: string, x?: number, y?: number, angle?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
  -> index: number
```


Adds additional colored text to the Text object at the specified position.


[Open in Browser](https://love2d.org/wiki/Text:add)


---

@*param* `textstring` — The text to add to the object.

@*param* `x` — The position of the new text on the x-axis.

@*param* `y` — The position of the new text on the y-axis.

@*param* `angle` — The orientation of the new text in radians.

@*param* `sx` — Scale factor on the x-axis.

@*param* `sy` — Scale factor on the y-axis.

@*param* `ox` — Origin offset on the x-axis.

@*param* `oy` — Origin offset on the y-axis.

@*param* `kx` — Shearing / skew factor on the x-axis.

@*param* `ky` — Shearing / skew factor on the y-axis.

@*return* `index` — An index number that can be used with Text:getWidth or Text:getHeight.

## addf


```lua
(method) love.Text:addf(textstring: string, wraplimit: number, align: "center"|"justify"|"left"|"right", x: number, y: number, angle?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
  -> index: number
```


Adds additional formatted / colored text to the Text object at the specified position.

The word wrap limit is applied before any scaling, rotation, and other coordinate transformations. Therefore the amount of text per line stays constant given the same wrap limit, even if the scale arguments change.


[Open in Browser](https://love2d.org/wiki/Text:addf)


---

@*param* `textstring` — The text to add to the object.

@*param* `wraplimit` — The maximum width in pixels of the text before it gets automatically wrapped to a new line.

@*param* `align` — The alignment of the text.

@*param* `x` — The position of the new text (x-axis).

@*param* `y` — The position of the new text (y-axis).

@*param* `angle` — Orientation (radians).

@*param* `sx` — Scale factor (x-axis).

@*param* `sy` — Scale factor (y-axis).

@*param* `ox` — Origin offset (x-axis).

@*param* `oy` — Origin offset (y-axis).

@*param* `kx` — Shearing / skew factor (x-axis).

@*param* `ky` — Shearing / skew factor (y-axis).

@*return* `index` — An index number that can be used with Text:getWidth or Text:getHeight.

```lua
-- 
-- Text alignment.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/AlignMode)
-- 
align:
    | "center" -- Align text center.
    | "left" -- Align text left.
    | "right" -- Align text right.
    | "justify" -- Align text both left and right.
```

## clear


```lua
(method) love.Text:clear()
```


Clears the contents of the Text object.


[Open in Browser](https://love2d.org/wiki/Text:clear)

## getDimensions


```lua
(method) love.Text:getDimensions()
  -> width: number
  2. height: number
```


Gets the width and height of the text in pixels.


[Open in Browser](https://love2d.org/wiki/Text:getDimensions)


---

@*return* `width` — The width of the text. If multiple sub-strings have been added with Text:add, the width of the last sub-string is returned.

@*return* `height` — The height of the text. If multiple sub-strings have been added with Text:add, the height of the last sub-string is returned.

## getFont


```lua
(method) love.Text:getFont()
  -> font: love.Font
```


Gets the Font used with the Text object.


[Open in Browser](https://love2d.org/wiki/Text:getFont)

@*return* `font` — The font used with this Text object.

## getHeight


```lua
(method) love.Text:getHeight()
  -> height: number
```


Gets the height of the text in pixels.


[Open in Browser](https://love2d.org/wiki/Text:getHeight)


---

@*return* `height` — The height of the text. If multiple sub-strings have been added with Text:add, the height of the last sub-string is returned.

## getWidth


```lua
(method) love.Text:getWidth()
  -> width: number
```


Gets the width of the text in pixels.


[Open in Browser](https://love2d.org/wiki/Text:getWidth)


---

@*return* `width` — The width of the text. If multiple sub-strings have been added with Text:add, the width of the last sub-string is returned.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## set


```lua
(method) love.Text:set(textstring: string)
```


Replaces the contents of the Text object with a new unformatted string.


[Open in Browser](https://love2d.org/wiki/Text:set)


---

@*param* `textstring` — The new string of text to use.

## setFont


```lua
(method) love.Text:setFont(font: love.Font)
```


Replaces the Font used with the text.


[Open in Browser](https://love2d.org/wiki/Text:setFont)

@*param* `font` — The new font to use with this Text object.

## setf


```lua
(method) love.Text:setf(textstring: string, wraplimit: number, align: "center"|"justify"|"left"|"right")
```


Replaces the contents of the Text object with a new formatted string.


[Open in Browser](https://love2d.org/wiki/Text:setf)


---

@*param* `textstring` — The new string of text to use.

@*param* `wraplimit` — The maximum width in pixels of the text before it gets automatically wrapped to a new line.

@*param* `align` — The alignment of the text.

```lua
-- 
-- Text alignment.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/AlignMode)
-- 
align:
    | "center" -- Align text center.
    | "left" -- Align text left.
    | "right" -- Align text right.
    | "justify" -- Align text both left and right.
```

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.Texture

## getDPIScale


```lua
(method) love.Texture:getDPIScale()
  -> dpiscale: number
```


Gets the DPI scale factor of the Texture.

The DPI scale factor represents relative pixel density. A DPI scale factor of 2 means the texture has twice the pixel density in each dimension (4 times as many pixels in the same area) compared to a texture with a DPI scale factor of 1.

For example, a texture with pixel dimensions of 100x100 with a DPI scale factor of 2 will be drawn as if it was 50x50. This is useful with high-dpi /  retina displays to easily allow swapping out higher or lower pixel density Images and Canvases without needing any extra manual scaling logic.


[Open in Browser](https://love2d.org/wiki/Texture:getDPIScale)

@*return* `dpiscale` — The DPI scale factor of the Texture.

## getDepth


```lua
(method) love.Texture:getDepth()
  -> depth: number
```


Gets the depth of a Volume Texture. Returns 1 for 2D, Cubemap, and Array textures.


[Open in Browser](https://love2d.org/wiki/Texture:getDepth)

@*return* `depth` — The depth of the volume Texture.

## getDepthSampleMode


```lua
(method) love.Texture:getDepthSampleMode()
  -> compare: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3)
```


Gets the comparison mode used when sampling from a depth texture in a shader.

Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.


[Open in Browser](https://love2d.org/wiki/Texture:getDepthSampleMode)

@*return* `compare` — The comparison mode used when sampling from this texture in a shader, or nil if setDepthSampleMode has not been called on this Texture.

```lua
-- 
-- Different types of per-pixel stencil test and depth test comparisons. The pixels of an object will be drawn if the comparison succeeds, for each pixel that the object touches.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CompareMode)
-- 
compare:
    | "equal" -- * stencil tests: the stencil value of the pixel must be equal to the supplied value.
              -- * depth tests: the depth value of the drawn object at that pixel must be equal to the existing depth value of that pixel.
    | "notequal" -- * stencil tests: the stencil value of the pixel must not be equal to the supplied value.
                 -- * depth tests: the depth value of the drawn object at that pixel must not be equal to the existing depth value of that pixel.
    | "less" -- * stencil tests: the stencil value of the pixel must be less than the supplied value.
             -- * depth tests: the depth value of the drawn object at that pixel must be less than the existing depth value of that pixel.
    | "lequal" -- * stencil tests: the stencil value of the pixel must be less than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be less than or equal to the existing depth value of that pixel.
    | "gequal" -- * stencil tests: the stencil value of the pixel must be greater than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be greater than or equal to the existing depth value of that pixel.
    | "greater" -- * stencil tests: the stencil value of the pixel must be greater than the supplied value.
                -- * depth tests: the depth value of the drawn object at that pixel must be greater than the existing depth value of that pixel.
    | "never" -- Objects will never be drawn.
    | "always" -- Objects will always be drawn. Effectively disables the depth or stencil test.
```

## getDimensions


```lua
(method) love.Texture:getDimensions()
  -> width: number
  2. height: number
```


Gets the width and height of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getDimensions)

@*return* `width` — The width of the Texture.

@*return* `height` — The height of the Texture.

## getFilter


```lua
(method) love.Texture:getFilter()
  -> min: "linear"|"nearest"
  2. mag: "linear"|"nearest"
  3. anisotropy: number
```


Gets the filter mode of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getFilter)

@*return* `min` — Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).

@*return* `mag` — Filter mode to use when magnifying the texture (rendering it at a smaller size on-screen than its size in pixels).

@*return* `anisotropy` — Maximum amount of anisotropic filtering used.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
min:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.

-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mag:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## getFormat


```lua
(method) love.Texture:getFormat()
  -> format: "ASTC10x10"|"ASTC10x5"|"ASTC10x6"|"ASTC10x8"|"ASTC12x10"...(+59)
```


Gets the pixel format of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getFormat)

@*return* `format` — The pixel format the Texture was created with.

```lua
-- 
-- Pixel formats for Textures, ImageData, and CompressedImageData.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/PixelFormat)
-- 
format:
    | "unknown" -- Indicates unknown pixel format, used internally.
    | "normal" -- Alias for rgba8, or srgba8 if gamma-correct rendering is enabled.
    | "hdr" -- A format suitable for high dynamic range content - an alias for the rgba16f format, normally.
    | "r8" -- Single-channel (red component) format (8 bpp).
    | "rg8" -- Two channels (red and green components) with 8 bits per channel (16 bpp).
    | "rgba8" -- 8 bits per channel (32 bpp) RGBA. Color channel values range from 0-255 (0-1 in shaders).
    | "srgba8" -- gamma-correct version of rgba8.
    | "r16" -- Single-channel (red component) format (16 bpp).
    | "rg16" -- Two channels (red and green components) with 16 bits per channel (32 bpp).
    | "rgba16" -- 16 bits per channel (64 bpp) RGBA. Color channel values range from 0-65535 (0-1 in shaders).
    | "r16f" -- Floating point single-channel format (16 bpp). Color values can range from [-65504, +65504].
    | "rg16f" -- Floating point two-channel format with 16 bits per channel (32 bpp). Color values can range from [-65504, +65504].
    | "rgba16f" -- Floating point RGBA with 16 bits per channel (64 bpp). Color values can range from [-65504, +65504].
    | "r32f" -- Floating point single-channel format (32 bpp).
    | "rg32f" -- Floating point two-channel format with 32 bits per channel (64 bpp).
    | "rgba32f" -- Floating point RGBA with 32 bits per channel (128 bpp).
    | "la8" -- Same as rg8, but accessed as (L, L, L, A)
    | "rgba4" -- 4 bits per channel (16 bpp) RGBA.
    | "rgb5a1" -- RGB with 5 bits each, and a 1-bit alpha channel (16 bpp).
    | "rgb565" -- RGB with 5, 6, and 5 bits each, respectively (16 bpp). There is no alpha channel in this format.
    | "rgb10a2" -- RGB with 10 bits per channel, and a 2-bit alpha channel (32 bpp).
    | "rg11b10f" -- Floating point RGB with 11 bits in the red and green channels, and 10 bits in the blue channel (32 bpp). There is no alpha channel. Color values can range from [0, +65024].
    | "stencil8" -- No depth buffer and 8-bit stencil buffer.
    | "depth16" -- 16-bit depth buffer and no stencil buffer.
    | "depth24" -- 24-bit depth buffer and no stencil buffer.
    | "depth32f" -- 32-bit float depth buffer and no stencil buffer.
    | "depth24stencil8" -- 24-bit depth buffer and 8-bit stencil buffer.
    | "depth32fstencil8" -- 32-bit float depth buffer and 8-bit stencil buffer.
    | "DXT1" -- The DXT1 format. RGB data at 4 bits per pixel (compared to 32 bits for ImageData and regular Images.) Suitable for fully opaque images on desktop systems.
    | "DXT3" -- The DXT3 format. RGBA data at 8 bits per pixel. Smooth variations in opacity do not mix well with this format.
    | "DXT5" -- The DXT5 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on desktop systems.
    | "BC4" -- The BC4 format (also known as 3Dc+ or ATI1.) Stores just the red channel, at 4 bits per pixel.
    | "BC4s" -- The signed variant of the BC4 format. Same as above but pixel values in the texture are in the range of 1 instead of 1 in shaders.
    | "BC5" -- The BC5 format (also known as 3Dc or ATI2.) Stores red and green channels at 8 bits per pixel.
    | "BC5s" -- The signed variant of the BC5 format.
    | "BC6h" -- The BC6H format. Stores half-precision floating-point RGB data in the range of 65504 at 8 bits per pixel. Suitable for HDR images on desktop systems.
    | "BC6hs" -- The signed variant of the BC6H format. Stores RGB data in the range of +65504.
    | "BC7" -- The BC7 format (also known as BPTC.) Stores RGB or RGBA data at 8 bits per pixel.
    | "ETC1" -- The ETC1 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on older Android devices.
    | "ETC2rgb" -- The RGB variant of the ETC2 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on newer mobile devices.
    | "ETC2rgba" -- The RGBA variant of the ETC2 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on newer mobile devices.
    | "ETC2rgba1" -- The RGBA variant of the ETC2 format where pixels are either fully transparent or fully opaque. RGBA data at 4 bits per pixel.
    | "EACr" -- The single-channel variant of the EAC format. Stores just the red channel, at 4 bits per pixel.
    | "EACrs" -- The signed single-channel variant of the EAC format. Same as above but pixel values in the texture are in the range of 1 instead of 1 in shaders.
    | "EACrg" -- The two-channel variant of the EAC format. Stores red and green channels at 8 bits per pixel.
    | "EACrgs" -- The signed two-channel variant of the EAC format.
    | "PVR1rgb2" -- The 2 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 2 bits per pixel. Textures compressed with PVRTC1 formats must be square and power-of-two sized.
    | "PVR1rgb4" -- The 4 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 4 bits per pixel.
    | "PVR1rgba2" -- The 2 bit per pixel RGBA variant of the PVRTC1 format.
    | "PVR1rgba4" -- The 4 bit per pixel RGBA variant of the PVRTC1 format.
    | "ASTC4x4" -- The 4x4 pixels per block variant of the ASTC format. RGBA data at 8 bits per pixel.
    | "ASTC5x4" -- The 5x4 pixels per block variant of the ASTC format. RGBA data at 6.4 bits per pixel.
    | "ASTC5x5" -- The 5x5 pixels per block variant of the ASTC format. RGBA data at 5.12 bits per pixel.
    | "ASTC6x5" -- The 6x5 pixels per block variant of the ASTC format. RGBA data at 4.27 bits per pixel.
    | "ASTC6x6" -- The 6x6 pixels per block variant of the ASTC format. RGBA data at 3.56 bits per pixel.
    | "ASTC8x5" -- The 8x5 pixels per block variant of the ASTC format. RGBA data at 3.2 bits per pixel.
    | "ASTC8x6" -- The 8x6 pixels per block variant of the ASTC format. RGBA data at 2.67 bits per pixel.
    | "ASTC8x8" -- The 8x8 pixels per block variant of the ASTC format. RGBA data at 2 bits per pixel.
    | "ASTC10x5" -- The 10x5 pixels per block variant of the ASTC format. RGBA data at 2.56 bits per pixel.
    | "ASTC10x6" -- The 10x6 pixels per block variant of the ASTC format. RGBA data at 2.13 bits per pixel.
    | "ASTC10x8" -- The 10x8 pixels per block variant of the ASTC format. RGBA data at 1.6 bits per pixel.
    | "ASTC10x10" -- The 10x10 pixels per block variant of the ASTC format. RGBA data at 1.28 bits per pixel.
    | "ASTC12x10" -- The 12x10 pixels per block variant of the ASTC format. RGBA data at 1.07 bits per pixel.
    | "ASTC12x12" -- The 12x12 pixels per block variant of the ASTC format. RGBA data at 0.89 bits per pixel.
```

## getHeight


```lua
(method) love.Texture:getHeight()
  -> height: number
```


Gets the height of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getHeight)

@*return* `height` — The height of the Texture.

## getLayerCount


```lua
(method) love.Texture:getLayerCount()
  -> layers: number
```


Gets the number of layers / slices in an Array Texture. Returns 1 for 2D, Cubemap, and Volume textures.


[Open in Browser](https://love2d.org/wiki/Texture:getLayerCount)

@*return* `layers` — The number of layers in the Array Texture.

## getMipmapCount


```lua
(method) love.Texture:getMipmapCount()
  -> mipmaps: number
```


Gets the number of mipmaps contained in the Texture. If the texture was not created with mipmaps, it will return 1.


[Open in Browser](https://love2d.org/wiki/Texture:getMipmapCount)

@*return* `mipmaps` — The number of mipmaps in the Texture.

## getMipmapFilter


```lua
(method) love.Texture:getMipmapFilter()
  -> mode: "linear"|"nearest"
  2. sharpness: number
```


Gets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.


[Open in Browser](https://love2d.org/wiki/Texture:getMipmapFilter)

@*return* `mode` — The filter mode used in between mipmap levels. nil if mipmap filtering is not enabled.

@*return* `sharpness` — Value used to determine whether the image should use more or less detailed mipmap levels than normal when drawing.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mode:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## getPixelDimensions


```lua
(method) love.Texture:getPixelDimensions()
  -> pixelwidth: number
  2. pixelheight: number
```


Gets the width and height in pixels of the Texture.

Texture:getDimensions gets the dimensions of the texture in units scaled by the texture's DPI scale factor, rather than pixels. Use getDimensions for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelDimensions only when dealing specifically with pixels, for example when using Canvas:newImageData.


[Open in Browser](https://love2d.org/wiki/Texture:getPixelDimensions)

@*return* `pixelwidth` — The width of the Texture, in pixels.

@*return* `pixelheight` — The height of the Texture, in pixels.

## getPixelHeight


```lua
(method) love.Texture:getPixelHeight()
  -> pixelheight: number
```


Gets the height in pixels of the Texture.

DPI scale factor, rather than pixels. Use getHeight for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelHeight only when dealing specifically with pixels, for example when using Canvas:newImageData.


[Open in Browser](https://love2d.org/wiki/Texture:getPixelHeight)

@*return* `pixelheight` — The height of the Texture, in pixels.

## getPixelWidth


```lua
(method) love.Texture:getPixelWidth()
  -> pixelwidth: number
```


Gets the width in pixels of the Texture.

DPI scale factor, rather than pixels. Use getWidth for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelWidth only when dealing specifically with pixels, for example when using Canvas:newImageData.


[Open in Browser](https://love2d.org/wiki/Texture:getPixelWidth)

@*return* `pixelwidth` — The width of the Texture, in pixels.

## getTextureType


```lua
(method) love.Texture:getTextureType()
  -> texturetype: "2d"|"array"|"cube"|"volume"
```


Gets the type of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getTextureType)

@*return* `texturetype` — The type of the Texture.

```lua
-- 
-- Types of textures (2D, cubemap, etc.)
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/TextureType)
-- 
texturetype:
    | "2d" -- Regular 2D texture with width and height.
    | "array" -- Several same-size 2D textures organized into a single object. Similar to a texture atlas / sprite sheet, but avoids sprite bleeding and other issues.
    | "cube" -- Cubemap texture with 6 faces. Requires a custom shader (and Shader:send) to use. Sampling from a cube texture in a shader takes a 3D direction vector instead of a texture coordinate.
    | "volume" -- 3D texture with width, height, and depth. Requires a custom shader to use. Volume textures can have texture filtering applied along the 3rd axis.
```

## getWidth


```lua
(method) love.Texture:getWidth()
  -> width: number
```


Gets the width of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:getWidth)

@*return* `width` — The width of the Texture.

## getWrap


```lua
(method) love.Texture:getWrap()
  -> horiz: "clamp"|"clampzero"|"mirroredrepeat"|"repeat"
  2. vert: "clamp"|"clampzero"|"mirroredrepeat"|"repeat"
  3. depth: "clamp"|"clampzero"|"mirroredrepeat"|"repeat"
```


Gets the wrapping properties of a Texture.

This function returns the currently set horizontal and vertical wrapping modes for the texture.


[Open in Browser](https://love2d.org/wiki/Texture:getWrap)

@*return* `horiz` — Horizontal wrapping mode of the texture.

@*return* `vert` — Vertical wrapping mode of the texture.

@*return* `depth` — Wrapping mode for the z-axis of a Volume texture.

```lua
-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
horiz:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)

-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
vert:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)

-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
depth:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)
```

## isReadable


```lua
(method) love.Texture:isReadable()
  -> readable: boolean
```


Gets whether the Texture can be drawn and sent to a Shader.

Canvases created with stencil and/or depth PixelFormats are not readable by default, unless readable=true is specified in the settings table passed into love.graphics.newCanvas.

Non-readable Canvases can still be rendered to.


[Open in Browser](https://love2d.org/wiki/Texture:isReadable)

@*return* `readable` — Whether the Texture is readable.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setDepthSampleMode


```lua
(method) love.Texture:setDepthSampleMode(compare: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3))
```


Sets the comparison mode used when sampling from a depth texture in a shader. Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.

When using a depth texture with a comparison mode set in a shader, it must be declared as a sampler2DShadow and used in a GLSL 3 Shader. The result of accessing the texture in the shader will return a float between 0 and 1, proportional to the number of samples (up to 4 samples will be used if bilinear filtering is enabled) that passed the test set by the comparison operation.

Depth texture comparison can only be used with readable depth-formatted Canvases.


[Open in Browser](https://love2d.org/wiki/Texture:setDepthSampleMode)

@*param* `compare` — The comparison mode used when sampling from this texture in a shader.

```lua
-- 
-- Different types of per-pixel stencil test and depth test comparisons. The pixels of an object will be drawn if the comparison succeeds, for each pixel that the object touches.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CompareMode)
-- 
compare:
    | "equal" -- * stencil tests: the stencil value of the pixel must be equal to the supplied value.
              -- * depth tests: the depth value of the drawn object at that pixel must be equal to the existing depth value of that pixel.
    | "notequal" -- * stencil tests: the stencil value of the pixel must not be equal to the supplied value.
                 -- * depth tests: the depth value of the drawn object at that pixel must not be equal to the existing depth value of that pixel.
    | "less" -- * stencil tests: the stencil value of the pixel must be less than the supplied value.
             -- * depth tests: the depth value of the drawn object at that pixel must be less than the existing depth value of that pixel.
    | "lequal" -- * stencil tests: the stencil value of the pixel must be less than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be less than or equal to the existing depth value of that pixel.
    | "gequal" -- * stencil tests: the stencil value of the pixel must be greater than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be greater than or equal to the existing depth value of that pixel.
    | "greater" -- * stencil tests: the stencil value of the pixel must be greater than the supplied value.
                -- * depth tests: the depth value of the drawn object at that pixel must be greater than the existing depth value of that pixel.
    | "never" -- Objects will never be drawn.
    | "always" -- Objects will always be drawn. Effectively disables the depth or stencil test.
```

## setFilter


```lua
(method) love.Texture:setFilter(min: "linear"|"nearest", mag?: "linear"|"nearest", anisotropy?: number)
```


Sets the filter mode of the Texture.


[Open in Browser](https://love2d.org/wiki/Texture:setFilter)

@*param* `min` — Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).

@*param* `mag` — Filter mode to use when magnifying the texture (rendering it at a larger size on-screen than its size in pixels).

@*param* `anisotropy` — Maximum amount of anisotropic filtering to use.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
min:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.

-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mag:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## setMipmapFilter


```lua
(method) love.Texture:setMipmapFilter(filtermode: "linear"|"nearest", sharpness?: number)
```


Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.

Mipmapping is useful when drawing a texture at a reduced scale. It can improve performance and reduce aliasing issues.

In created with the mipmaps flag enabled for the mipmap filter to have any effect. In versions prior to 0.10.0 it's best to call this method directly after creating the image with love.graphics.newImage, to avoid bugs in certain graphics drivers.

Due to hardware restrictions and driver bugs, in versions prior to 0.10.0 images that weren't loaded from a CompressedData must have power-of-two dimensions (64x64, 512x256, etc.) to use mipmaps.


[Open in Browser](https://love2d.org/wiki/Texture:setMipmapFilter)


---

@*param* `filtermode` — The filter mode to use in between mipmap levels. 'nearest' will often give better performance.

@*param* `sharpness` — A positive sharpness value makes the texture use a more detailed mipmap level when drawing, at the expense of performance. A negative value does the reverse.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
filtermode:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## setWrap


```lua
(method) love.Texture:setWrap(horiz: "clamp"|"clampzero"|"mirroredrepeat"|"repeat", vert?: "clamp"|"clampzero"|"mirroredrepeat"|"repeat", depth?: "clamp"|"clampzero"|"mirroredrepeat"|"repeat")
```


Sets the wrapping properties of a Texture.

This function sets the way a Texture is repeated when it is drawn with a Quad that is larger than the texture's extent, or when a custom Shader is used which uses texture coordinates outside of [0, 1]. A texture may be clamped or set to repeat in both horizontal and vertical directions.

Clamped textures appear only once (with the edges of the texture stretching to fill the extent of the Quad), whereas repeated ones repeat as many times as there is room in the Quad.


[Open in Browser](https://love2d.org/wiki/Texture:setWrap)

@*param* `horiz` — Horizontal wrapping mode of the texture.

@*param* `vert` — Vertical wrapping mode of the texture.

@*param* `depth` — Wrapping mode for the z-axis of a Volume texture.

```lua
-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
horiz:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)

-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
vert:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)

-- 
-- How the image wraps inside a Quad with a larger quad size than image size. This also affects how Meshes with texture coordinates which are outside the range of 1 are drawn, and the color returned by the Texel Shader function when using it to sample from texture coordinates outside of the range of 1.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/WrapMode)
-- 
depth:
    | "clamp" -- Clamp the texture. Appears only once. The area outside the texture's normal range is colored based on the edge pixels of the texture.
    | "repeat" -- Repeat the texture. Fills the whole available extent.
    | "mirroredrepeat" -- Repeat the texture, flipping it each time it repeats. May produce better visual results than the repeat mode when the texture doesn't seamlessly tile.
    | "clampzero" -- Clamp the texture. Fills the area outside the texture's normal range with transparent black (or opaque black for textures with no alpha channel.)
```

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.TextureType


---

# love.Thread

## getError


```lua
(method) love.Thread:getError()
  -> err: string
```


Retrieves the error string from the thread if it produced an error.


[Open in Browser](https://love2d.org/wiki/Thread:getError)

@*return* `err` — The error message, or nil if the Thread has not caused an error.

## isRunning


```lua
(method) love.Thread:isRunning()
  -> value: boolean
```


Returns whether the thread is currently running.

Threads which are not running can be (re)started with Thread:start.


[Open in Browser](https://love2d.org/wiki/Thread:isRunning)

@*return* `value` — True if the thread is running, false otherwise.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## start


```lua
(method) love.Thread:start()
```


Starts the thread.

Beginning with version 0.9.0, threads can be restarted after they have completed their execution.


[Open in Browser](https://love2d.org/wiki/Thread:start)

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.

## wait


```lua
(method) love.Thread:wait()
```


Wait for a thread to finish.

This call will block until the thread finishes.


[Open in Browser](https://love2d.org/wiki/Thread:wait)


---

# love.TimeUnit


---

# love.Transform

## apply


```lua
(method) love.Transform:apply(other: love.Transform)
  -> transform: love.Transform
```


Applies the given other Transform object to this one.

This effectively multiplies this Transform's internal transformation matrix with the other Transform's (i.e. self * other), and stores the result in this object.


[Open in Browser](https://love2d.org/wiki/Transform:apply)

@*param* `other` — The other Transform object to apply to this Transform.

@*return* `transform` — The Transform object the method was called on. Allows easily chaining Transform methods.

## clone


```lua
(method) love.Transform:clone()
  -> clone: love.Transform
```


Creates a new copy of this Transform.


[Open in Browser](https://love2d.org/wiki/Transform:clone)

@*return* `clone` — The copy of this Transform.

## getMatrix


```lua
(method) love.Transform:getMatrix()
  -> e1_1: number
  2. e1_2: number
  3. e1_3: number
  4. e1_4: number
  5. e2_1: number
  6. e2_2: number
  7. e2_3: number
  8. e2_4: number
  9. e3_1: number
 10. e3_2: number
 11. e3_3: number
 12. e3_4: number
 13. e4_1: number
 14. e4_2: number
 15. e4_3: number
 16. e4_4: number
```


Gets the internal 4x4 transformation matrix stored by this Transform. The matrix is returned in row-major order.


[Open in Browser](https://love2d.org/wiki/Transform:getMatrix)

@*return* `e1_1` — The first column of the first row of the matrix.

@*return* `e1_2` — The second column of the first row of the matrix.

@*return* `e1_3` — The third column of the first row of the matrix.

@*return* `e1_4` — The fourth column of the first row of the matrix.

@*return* `e2_1` — The first column of the second row of the matrix.

@*return* `e2_2` — The second column of the second row of the matrix.

@*return* `e2_3` — The third column of the second row of the matrix.

@*return* `e2_4` — The fourth column of the second row of the matrix.

@*return* `e3_1` — The first column of the third row of the matrix.

@*return* `e3_2` — The second column of the third row of the matrix.

@*return* `e3_3` — The third column of the third row of the matrix.

@*return* `e3_4` — The fourth column of the third row of the matrix.

@*return* `e4_1` — The first column of the fourth row of the matrix.

@*return* `e4_2` — The second column of the fourth row of the matrix.

@*return* `e4_3` — The third column of the fourth row of the matrix.

@*return* `e4_4` — The fourth column of the fourth row of the matrix.

## inverse


```lua
(method) love.Transform:inverse()
  -> inverse: love.Transform
```


Creates a new Transform containing the inverse of this Transform.


[Open in Browser](https://love2d.org/wiki/Transform:inverse)

@*return* `inverse` — A new Transform object representing the inverse of this Transform's matrix.

## inverseTransformPoint


```lua
(method) love.Transform:inverseTransformPoint(localX: number, localY: number)
  -> globalX: number
  2. globalY: number
```


Applies the reverse of the Transform object's transformation to the given 2D position.

This effectively converts the given position from the local coordinate space of the Transform into global coordinates.

One use of this method can be to convert a screen-space mouse position into global world coordinates, if the given Transform has transformations applied that are used for a camera system in-game.


[Open in Browser](https://love2d.org/wiki/Transform:inverseTransformPoint)

@*param* `localX` — The x component of the position with the transform applied.

@*param* `localY` — The y component of the position with the transform applied.

@*return* `globalX` — The x component of the position in global coordinates.

@*return* `globalY` — The y component of the position in global coordinates.

## isAffine2DTransform


```lua
(method) love.Transform:isAffine2DTransform()
  -> affine: boolean
```


Checks whether the Transform is an affine transformation.


[Open in Browser](https://love2d.org/wiki/Transform:isAffine2DTransform)

@*return* `affine` — true if the transform object is an affine transformation, false otherwise.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## reset


```lua
(method) love.Transform:reset()
  -> transform: love.Transform
```


Resets the Transform to an identity state. All previously applied transformations are erased.


[Open in Browser](https://love2d.org/wiki/Transform:reset)

@*return* `transform` — The Transform object the method was called on. Allows easily chaining Transform methods.

## rotate


```lua
(method) love.Transform:rotate(angle: number)
  -> transform: love.Transform
```


Applies a rotation to the Transform's coordinate system. This method does not reset any previously applied transformations.


[Open in Browser](https://love2d.org/wiki/Transform:rotate)

@*param* `angle` — The relative angle in radians to rotate this Transform by.

@*return* `transform` — The Transform object the method was called on. Allows easily chaining Transform methods.

## scale


```lua
(method) love.Transform:scale(sx: number, sy?: number)
  -> transform: love.Transform
```


Scales the Transform's coordinate system. This method does not reset any previously applied transformations.


[Open in Browser](https://love2d.org/wiki/Transform:scale)

@*param* `sx` — The relative scale factor along the x-axis.

@*param* `sy` — The relative scale factor along the y-axis.

@*return* `transform` — The Transform object the method was called on. Allows easily chaining Transform methods.

## setMatrix


```lua
(method) love.Transform:setMatrix(e1_1: number, e1_2: number, e1_3: number, e1_4: number, e2_1: number, e2_2: number, e2_3: number, e2_4: number, e3_1: number, e3_2: number, e3_3: number, e3_4: number, e4_1: number, e4_2: number, e4_3: number, e4_4: number)
  -> transform: love.Transform
```


Directly sets the Transform's internal 4x4 transformation matrix.


[Open in Browser](https://love2d.org/wiki/Transform:setMatrix)


---

@*param* `e1_1` — The first column of the first row of the matrix.

@*param* `e1_2` — The second column of the first row of the matrix.

@*param* `e1_3` — The third column of the first row of the matrix.

@*param* `e1_4` — The fourth column of the first row of the matrix.

@*param* `e2_1` — The first column of the second row of the matrix.

@*param* `e2_2` — The second column of the second row of the matrix.

@*param* `e2_3` — The third column of the second row of the matrix.

@*param* `e2_4` — The fourth column of the second row of the matrix.

@*param* `e3_1` — The first column of the third row of the matrix.

@*param* `e3_2` — The second column of the third row of the matrix.

@*param* `e3_3` — The third column of the third row of the matrix.

@*param* `e3_4` — The fourth column of the third row of the matrix.

@*param* `e4_1` — The first column of the fourth row of the matrix.

@*param* `e4_2` — The second column of the fourth row of the matrix.

@*param* `e4_3` — The third column of the fourth row of the matrix.

@*param* `e4_4` — The fourth column of the fourth row of the matrix.

@*return* `transform` — The Transform object the method was called on. Allows easily chaining Transform methods.

## setTransformation


```lua
(method) love.Transform:setTransformation(x: number, y: number, angle?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
  -> transform: love.Transform
```


Resets the Transform to the specified transformation parameters.


[Open in Browser](https://love2d.org/wiki/Transform:setTransformation)

@*param* `x` — The position of the Transform on the x-axis.

@*param* `y` — The position of the Transform on the y-axis.

@*param* `angle` — The orientation of the Transform in radians.

@*param* `sx` — Scale factor on the x-axis.

@*param* `sy` — Scale factor on the y-axis.

@*param* `ox` — Origin offset on the x-axis.

@*param* `oy` — Origin offset on the y-axis.

@*param* `kx` — Shearing / skew factor on the x-axis.

@*param* `ky` — Shearing / skew factor on the y-axis.

@*return* `transform` — The Transform object the method was called on. Allows easily chaining Transform methods.

## shear


```lua
(method) love.Transform:shear(kx: number, ky: number)
  -> transform: love.Transform
```


Applies a shear factor (skew) to the Transform's coordinate system. This method does not reset any previously applied transformations.


[Open in Browser](https://love2d.org/wiki/Transform:shear)

@*param* `kx` — The shear factor along the x-axis.

@*param* `ky` — The shear factor along the y-axis.

@*return* `transform` — The Transform object the method was called on. Allows easily chaining Transform methods.

## transformPoint


```lua
(method) love.Transform:transformPoint(globalX: number, globalY: number)
  -> localX: number
  2. localY: number
```


Applies the Transform object's transformation to the given 2D position.

This effectively converts the given position from global coordinates into the local coordinate space of the Transform.


[Open in Browser](https://love2d.org/wiki/Transform:transformPoint)

@*param* `globalX` — The x component of the position in global coordinates.

@*param* `globalY` — The y component of the position in global coordinates.

@*return* `localX` — The x component of the position with the transform applied.

@*return* `localY` — The y component of the position with the transform applied.

## translate


```lua
(method) love.Transform:translate(dx: number, dy: number)
  -> transform: love.Transform
```


Applies a translation to the Transform's coordinate system. This method does not reset any previously applied transformations.


[Open in Browser](https://love2d.org/wiki/Transform:translate)

@*param* `dx` — The relative translation along the x-axis.

@*param* `dy` — The relative translation along the y-axis.

@*return* `transform` — The Transform object the method was called on. Allows easily chaining Transform methods.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.VertexAttributeStep


---

# love.VertexWinding


---

# love.Video

## getDimensions


```lua
(method) love.Video:getDimensions()
  -> width: number
  2. height: number
```


Gets the width and height of the Video in pixels.


[Open in Browser](https://love2d.org/wiki/Video:getDimensions)

@*return* `width` — The width of the Video.

@*return* `height` — The height of the Video.

## getFilter


```lua
(method) love.Video:getFilter()
  -> min: "linear"|"nearest"
  2. mag: "linear"|"nearest"
  3. anisotropy: number
```


Gets the scaling filters used when drawing the Video.


[Open in Browser](https://love2d.org/wiki/Video:getFilter)

@*return* `min` — The filter mode used when scaling the Video down.

@*return* `mag` — The filter mode used when scaling the Video up.

@*return* `anisotropy` — Maximum amount of anisotropic filtering used.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
min:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.

-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mag:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## getHeight


```lua
(method) love.Video:getHeight()
  -> height: number
```


Gets the height of the Video in pixels.


[Open in Browser](https://love2d.org/wiki/Video:getHeight)

@*return* `height` — The height of the Video.

## getSource


```lua
(method) love.Video:getSource()
  -> source: love.Source
```


Gets the audio Source used for playing back the video's audio. May return nil if the video has no audio, or if Video:setSource is called with a nil argument.


[Open in Browser](https://love2d.org/wiki/Video:getSource)

@*return* `source` — The audio Source used for audio playback, or nil if the video has no audio.

## getStream


```lua
(method) love.Video:getStream()
  -> stream: love.VideoStream
```


Gets the VideoStream object used for decoding and controlling the video.


[Open in Browser](https://love2d.org/wiki/Video:getStream)

@*return* `stream` — The VideoStream used for decoding and controlling the video.

## getWidth


```lua
(method) love.Video:getWidth()
  -> width: number
```


Gets the width of the Video in pixels.


[Open in Browser](https://love2d.org/wiki/Video:getWidth)

@*return* `width` — The width of the Video.

## isPlaying


```lua
(method) love.Video:isPlaying()
  -> playing: boolean
```


Gets whether the Video is currently playing.


[Open in Browser](https://love2d.org/wiki/Video:isPlaying)

@*return* `playing` — Whether the video is playing.

## pause


```lua
(method) love.Video:pause()
```


Pauses the Video.


[Open in Browser](https://love2d.org/wiki/Video:pause)

## play


```lua
(method) love.Video:play()
```


Starts playing the Video. In order for the video to appear onscreen it must be drawn with love.graphics.draw.


[Open in Browser](https://love2d.org/wiki/Video:play)

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## rewind


```lua
(method) love.Video:rewind()
```


Rewinds the Video to the beginning.


[Open in Browser](https://love2d.org/wiki/Video:rewind)

## seek


```lua
(method) love.Video:seek(offset: number)
```


Sets the current playback position of the Video.


[Open in Browser](https://love2d.org/wiki/Video:seek)

@*param* `offset` — The time in seconds since the beginning of the Video.

## setFilter


```lua
(method) love.Video:setFilter(min: "linear"|"nearest", mag: "linear"|"nearest", anisotropy?: number)
```


Sets the scaling filters used when drawing the Video.


[Open in Browser](https://love2d.org/wiki/Video:setFilter)

@*param* `min` — The filter mode used when scaling the Video down.

@*param* `mag` — The filter mode used when scaling the Video up.

@*param* `anisotropy` — Maximum amount of anisotropic filtering used.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
min:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.

-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mag:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## setSource


```lua
(method) love.Video:setSource(source?: love.Source)
```


Sets the audio Source used for playing back the video's audio. The audio Source also controls playback speed and synchronization.


[Open in Browser](https://love2d.org/wiki/Video:setSource)

@*param* `source` — The audio Source used for audio playback, or nil to disable audio synchronization.

## tell


```lua
(method) love.Video:tell()
  -> seconds: number
```


Gets the current playback position of the Video.


[Open in Browser](https://love2d.org/wiki/Video:tell)

@*return* `seconds` — The time in seconds since the beginning of the Video.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.VideoStream

## getFilename


```lua
(method) love.VideoStream:getFilename()
  -> filename: string
```


Gets the filename of the VideoStream.


[Open in Browser](https://love2d.org/wiki/VideoStream:getFilename)

@*return* `filename` — The filename of the VideoStream

## isPlaying


```lua
(method) love.VideoStream:isPlaying()
  -> playing: boolean
```


Gets whether the VideoStream is playing.


[Open in Browser](https://love2d.org/wiki/VideoStream:isPlaying)

@*return* `playing` — Whether the VideoStream is playing.

## pause


```lua
(method) love.VideoStream:pause()
```


Pauses the VideoStream.


[Open in Browser](https://love2d.org/wiki/VideoStream:pause)

## play


```lua
(method) love.VideoStream:play()
```


Plays the VideoStream.


[Open in Browser](https://love2d.org/wiki/VideoStream:play)

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## rewind


```lua
(method) love.VideoStream:rewind()
```


Rewinds the VideoStream. Synonym to VideoStream:seek(0).


[Open in Browser](https://love2d.org/wiki/VideoStream:rewind)

## seek


```lua
(method) love.VideoStream:seek(offset: number)
```


Sets the current playback position of the VideoStream.


[Open in Browser](https://love2d.org/wiki/VideoStream:seek)

@*param* `offset` — The time in seconds since the beginning of the VideoStream.

## tell


```lua
(method) love.VideoStream:tell()
  -> seconds: number
```


Gets the current playback position of the VideoStream.


[Open in Browser](https://love2d.org/wiki/VideoStream:tell)

@*return* `seconds` — The number of seconds sionce the beginning of the VideoStream.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.WeldJoint

## destroy


```lua
(method) love.Joint:destroy()
```


Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.

In 0.7.2, when you don't have time to wait for garbage collection, this function

may be used to free the object immediately.


[Open in Browser](https://love2d.org/wiki/Joint:destroy)

## getAnchors


```lua
(method) love.Joint:getAnchors()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Get the anchor points of the joint.


[Open in Browser](https://love2d.org/wiki/Joint:getAnchors)

@*return* `x1` — The x-component of the anchor on Body 1.

@*return* `y1` — The y-component of the anchor on Body 1.

@*return* `x2` — The x-component of the anchor on Body 2.

@*return* `y2` — The y-component of the anchor on Body 2.

## getBodies


```lua
(method) love.Joint:getBodies()
  -> bodyA: love.Body
  2. bodyB: love.Body
```


Gets the bodies that the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/Joint:getBodies)

@*return* `bodyA` — The first Body.

@*return* `bodyB` — The second Body.

## getCollideConnected


```lua
(method) love.Joint:getCollideConnected()
  -> c: boolean
```


Gets whether the connected Bodies collide.


[Open in Browser](https://love2d.org/wiki/Joint:getCollideConnected)

@*return* `c` — True if they collide, false otherwise.

## getDampingRatio


```lua
(method) love.WeldJoint:getDampingRatio()
  -> ratio: number
```


Returns the damping ratio of the joint.


[Open in Browser](https://love2d.org/wiki/WeldJoint:getDampingRatio)

@*return* `ratio` — The damping ratio.

## getFrequency


```lua
(method) love.WeldJoint:getFrequency()
  -> freq: number
```


Returns the frequency.


[Open in Browser](https://love2d.org/wiki/WeldJoint:getFrequency)

@*return* `freq` — The frequency in hertz.

## getReactionForce


```lua
(method) love.Joint:getReactionForce(x: number)
  -> x: number
  2. y: number
```


Returns the reaction force in newtons on the second body


[Open in Browser](https://love2d.org/wiki/Joint:getReactionForce)

@*param* `x` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `x` — The x-component of the force.

@*return* `y` — The y-component of the force.

## getReactionTorque


```lua
(method) love.Joint:getReactionTorque(invdt: number)
  -> torque: number
```


Returns the reaction torque on the second body.


[Open in Browser](https://love2d.org/wiki/Joint:getReactionTorque)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `torque` — The reaction torque on the second body.

## getReferenceAngle


```lua
(method) love.WeldJoint:getReferenceAngle()
  -> angle: number
```


Gets the reference angle.


[Open in Browser](https://love2d.org/wiki/WeldJoint:getReferenceAngle)

@*return* `angle` — The reference angle in radians.

## getType


```lua
(method) love.Joint:getType()
  -> type: "distance"|"friction"|"gear"|"mouse"|"prismatic"...(+4)
```


Gets a string representing the type.


[Open in Browser](https://love2d.org/wiki/Joint:getType)

@*return* `type` — A string with the name of the Joint type.

```lua
-- 
-- Different types of joints.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JointType)
-- 
type:
    | "distance" -- A DistanceJoint.
    | "friction" -- A FrictionJoint.
    | "gear" -- A GearJoint.
    | "mouse" -- A MouseJoint.
    | "prismatic" -- A PrismaticJoint.
    | "pulley" -- A PulleyJoint.
    | "revolute" -- A RevoluteJoint.
    | "rope" -- A RopeJoint.
    | "weld" -- A WeldJoint.
```

## getUserData


```lua
(method) love.Joint:getUserData()
  -> value: any
```


Returns the Lua value associated with this Joint.


[Open in Browser](https://love2d.org/wiki/Joint:getUserData)

@*return* `value` — The Lua value associated with the Joint.

## isDestroyed


```lua
(method) love.Joint:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Joint is destroyed. Destroyed joints cannot be used.


[Open in Browser](https://love2d.org/wiki/Joint:isDestroyed)

@*return* `destroyed` — Whether the Joint is destroyed.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setDampingRatio


```lua
(method) love.WeldJoint:setDampingRatio(ratio: number)
```


Sets a new damping ratio.


[Open in Browser](https://love2d.org/wiki/WeldJoint:setDampingRatio)

@*param* `ratio` — The new damping ratio.

## setFrequency


```lua
(method) love.WeldJoint:setFrequency(freq: number)
```


Sets a new frequency.


[Open in Browser](https://love2d.org/wiki/WeldJoint:setFrequency)

@*param* `freq` — The new frequency in hertz.

## setUserData


```lua
(method) love.Joint:setUserData(value: any)
```


Associates a Lua value with the Joint.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Joint:setUserData)

@*param* `value` — The Lua value to associate with the Joint.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.WheelJoint

## destroy


```lua
(method) love.Joint:destroy()
```


Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.

In 0.7.2, when you don't have time to wait for garbage collection, this function

may be used to free the object immediately.


[Open in Browser](https://love2d.org/wiki/Joint:destroy)

## getAnchors


```lua
(method) love.Joint:getAnchors()
  -> x1: number
  2. y1: number
  3. x2: number
  4. y2: number
```


Get the anchor points of the joint.


[Open in Browser](https://love2d.org/wiki/Joint:getAnchors)

@*return* `x1` — The x-component of the anchor on Body 1.

@*return* `y1` — The y-component of the anchor on Body 1.

@*return* `x2` — The x-component of the anchor on Body 2.

@*return* `y2` — The y-component of the anchor on Body 2.

## getAxis


```lua
(method) love.WheelJoint:getAxis()
  -> x: number
  2. y: number
```


Gets the world-space axis vector of the Wheel Joint.


[Open in Browser](https://love2d.org/wiki/WheelJoint:getAxis)

@*return* `x` — The x-axis coordinate of the world-space axis vector.

@*return* `y` — The y-axis coordinate of the world-space axis vector.

## getBodies


```lua
(method) love.Joint:getBodies()
  -> bodyA: love.Body
  2. bodyB: love.Body
```


Gets the bodies that the Joint is attached to.


[Open in Browser](https://love2d.org/wiki/Joint:getBodies)

@*return* `bodyA` — The first Body.

@*return* `bodyB` — The second Body.

## getCollideConnected


```lua
(method) love.Joint:getCollideConnected()
  -> c: boolean
```


Gets whether the connected Bodies collide.


[Open in Browser](https://love2d.org/wiki/Joint:getCollideConnected)

@*return* `c` — True if they collide, false otherwise.

## getJointSpeed


```lua
(method) love.WheelJoint:getJointSpeed()
  -> speed: number
```


Returns the current joint translation speed.


[Open in Browser](https://love2d.org/wiki/WheelJoint:getJointSpeed)

@*return* `speed` — The translation speed of the joint in meters per second.

## getJointTranslation


```lua
(method) love.WheelJoint:getJointTranslation()
  -> position: number
```


Returns the current joint translation.


[Open in Browser](https://love2d.org/wiki/WheelJoint:getJointTranslation)

@*return* `position` — The translation of the joint in meters.

## getMaxMotorTorque


```lua
(method) love.WheelJoint:getMaxMotorTorque()
  -> maxTorque: number
```


Returns the maximum motor torque.


[Open in Browser](https://love2d.org/wiki/WheelJoint:getMaxMotorTorque)

@*return* `maxTorque` — The maximum torque of the joint motor in newton meters.

## getMotorSpeed


```lua
(method) love.WheelJoint:getMotorSpeed()
  -> speed: number
```


Returns the speed of the motor.


[Open in Browser](https://love2d.org/wiki/WheelJoint:getMotorSpeed)

@*return* `speed` — The speed of the joint motor in radians per second.

## getMotorTorque


```lua
(method) love.WheelJoint:getMotorTorque(invdt: number)
  -> torque: number
```


Returns the current torque on the motor.


[Open in Browser](https://love2d.org/wiki/WheelJoint:getMotorTorque)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `torque` — The torque on the motor in newton meters.

## getReactionForce


```lua
(method) love.Joint:getReactionForce(x: number)
  -> x: number
  2. y: number
```


Returns the reaction force in newtons on the second body


[Open in Browser](https://love2d.org/wiki/Joint:getReactionForce)

@*param* `x` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `x` — The x-component of the force.

@*return* `y` — The y-component of the force.

## getReactionTorque


```lua
(method) love.Joint:getReactionTorque(invdt: number)
  -> torque: number
```


Returns the reaction torque on the second body.


[Open in Browser](https://love2d.org/wiki/Joint:getReactionTorque)

@*param* `invdt` — How long the force applies. Usually the inverse time step or 1/dt.

@*return* `torque` — The reaction torque on the second body.

## getSpringDampingRatio


```lua
(method) love.WheelJoint:getSpringDampingRatio()
  -> ratio: number
```


Returns the damping ratio.


[Open in Browser](https://love2d.org/wiki/WheelJoint:getSpringDampingRatio)

@*return* `ratio` — The damping ratio.

## getSpringFrequency


```lua
(method) love.WheelJoint:getSpringFrequency()
  -> freq: number
```


Returns the spring frequency.


[Open in Browser](https://love2d.org/wiki/WheelJoint:getSpringFrequency)

@*return* `freq` — The frequency in hertz.

## getType


```lua
(method) love.Joint:getType()
  -> type: "distance"|"friction"|"gear"|"mouse"|"prismatic"...(+4)
```


Gets a string representing the type.


[Open in Browser](https://love2d.org/wiki/Joint:getType)

@*return* `type` — A string with the name of the Joint type.

```lua
-- 
-- Different types of joints.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JointType)
-- 
type:
    | "distance" -- A DistanceJoint.
    | "friction" -- A FrictionJoint.
    | "gear" -- A GearJoint.
    | "mouse" -- A MouseJoint.
    | "prismatic" -- A PrismaticJoint.
    | "pulley" -- A PulleyJoint.
    | "revolute" -- A RevoluteJoint.
    | "rope" -- A RopeJoint.
    | "weld" -- A WeldJoint.
```

## getUserData


```lua
(method) love.Joint:getUserData()
  -> value: any
```


Returns the Lua value associated with this Joint.


[Open in Browser](https://love2d.org/wiki/Joint:getUserData)

@*return* `value` — The Lua value associated with the Joint.

## isDestroyed


```lua
(method) love.Joint:isDestroyed()
  -> destroyed: boolean
```


Gets whether the Joint is destroyed. Destroyed joints cannot be used.


[Open in Browser](https://love2d.org/wiki/Joint:isDestroyed)

@*return* `destroyed` — Whether the Joint is destroyed.

## isMotorEnabled


```lua
(method) love.WheelJoint:isMotorEnabled()
  -> on: boolean
```


Checks if the joint motor is running.


[Open in Browser](https://love2d.org/wiki/WheelJoint:isMotorEnabled)

@*return* `on` — The status of the joint motor.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setMaxMotorTorque


```lua
(method) love.WheelJoint:setMaxMotorTorque(maxTorque: number)
```


Sets a new maximum motor torque.


[Open in Browser](https://love2d.org/wiki/WheelJoint:setMaxMotorTorque)

@*param* `maxTorque` — The new maximum torque for the joint motor in newton meters.

## setMotorEnabled


```lua
(method) love.WheelJoint:setMotorEnabled(enable: boolean)
```


Starts and stops the joint motor.


[Open in Browser](https://love2d.org/wiki/WheelJoint:setMotorEnabled)

@*param* `enable` — True turns the motor on and false turns it off.

## setMotorSpeed


```lua
(method) love.WheelJoint:setMotorSpeed(speed: number)
```


Sets a new speed for the motor.


[Open in Browser](https://love2d.org/wiki/WheelJoint:setMotorSpeed)

@*param* `speed` — The new speed for the joint motor in radians per second.

## setSpringDampingRatio


```lua
(method) love.WheelJoint:setSpringDampingRatio(ratio: number)
```


Sets a new damping ratio.


[Open in Browser](https://love2d.org/wiki/WheelJoint:setSpringDampingRatio)

@*param* `ratio` — The new damping ratio.

## setSpringFrequency


```lua
(method) love.WheelJoint:setSpringFrequency(freq: number)
```


Sets a new spring frequency.


[Open in Browser](https://love2d.org/wiki/WheelJoint:setSpringFrequency)

@*param* `freq` — The new frequency in hertz.

## setUserData


```lua
(method) love.Joint:setUserData(value: any)
```


Associates a Lua value with the Joint.

To delete the reference, explicitly pass nil.


[Open in Browser](https://love2d.org/wiki/Joint:setUserData)

@*param* `value` — The Lua value to associate with the Joint.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.


---

# love.World

## destroy


```lua
(method) love.World:destroy()
```


Destroys the world, taking all bodies, joints, fixtures and their shapes with it.

An error will occur if you attempt to use any of the destroyed objects after calling this function.


[Open in Browser](https://love2d.org/wiki/World:destroy)

## getBodies


```lua
(method) love.World:getBodies()
  -> bodies: table
```


Returns a table with all bodies.


[Open in Browser](https://love2d.org/wiki/World:getBodies)

@*return* `bodies` — A sequence with all bodies.

## getBodyCount


```lua
(method) love.World:getBodyCount()
  -> n: number
```


Returns the number of bodies in the world.


[Open in Browser](https://love2d.org/wiki/World:getBodyCount)

@*return* `n` — The number of bodies in the world.

## getCallbacks


```lua
(method) love.World:getCallbacks()
  -> beginContact: function
  2. endContact: function
  3. preSolve: function
  4. postSolve: function
```


Returns functions for the callbacks during the world update.


[Open in Browser](https://love2d.org/wiki/World:getCallbacks)

@*return* `beginContact` — Gets called when two fixtures begin to overlap.

@*return* `endContact` — Gets called when two fixtures cease to overlap.

@*return* `preSolve` — Gets called before a collision gets resolved.

@*return* `postSolve` — Gets called after the collision has been resolved.

## getContactCount


```lua
(method) love.World:getContactCount()
  -> n: number
```


Returns the number of contacts in the world.


[Open in Browser](https://love2d.org/wiki/World:getContactCount)

@*return* `n` — The number of contacts in the world.

## getContactFilter


```lua
(method) love.World:getContactFilter()
  -> contactFilter: function
```


Returns the function for collision filtering.


[Open in Browser](https://love2d.org/wiki/World:getContactFilter)

@*return* `contactFilter` — The function that handles the contact filtering.

## getContacts


```lua
(method) love.World:getContacts()
  -> contacts: table
```


Returns a table with all Contacts.


[Open in Browser](https://love2d.org/wiki/World:getContacts)

@*return* `contacts` — A sequence with all Contacts.

## getGravity


```lua
(method) love.World:getGravity()
  -> x: number
  2. y: number
```


Get the gravity of the world.


[Open in Browser](https://love2d.org/wiki/World:getGravity)

@*return* `x` — The x component of gravity.

@*return* `y` — The y component of gravity.

## getJointCount


```lua
(method) love.World:getJointCount()
  -> n: number
```


Returns the number of joints in the world.


[Open in Browser](https://love2d.org/wiki/World:getJointCount)

@*return* `n` — The number of joints in the world.

## getJoints


```lua
(method) love.World:getJoints()
  -> joints: table
```


Returns a table with all joints.


[Open in Browser](https://love2d.org/wiki/World:getJoints)

@*return* `joints` — A sequence with all joints.

## isDestroyed


```lua
(method) love.World:isDestroyed()
  -> destroyed: boolean
```


Gets whether the World is destroyed. Destroyed worlds cannot be used.


[Open in Browser](https://love2d.org/wiki/World:isDestroyed)

@*return* `destroyed` — Whether the World is destroyed.

## isLocked


```lua
(method) love.World:isLocked()
  -> locked: boolean
```


Returns if the world is updating its state.

This will return true inside the callbacks from World:setCallbacks.


[Open in Browser](https://love2d.org/wiki/World:isLocked)

@*return* `locked` — Will be true if the world is in the process of updating its state.

## isSleepingAllowed


```lua
(method) love.World:isSleepingAllowed()
  -> allow: boolean
```


Gets the sleep behaviour of the world.


[Open in Browser](https://love2d.org/wiki/World:isSleepingAllowed)

@*return* `allow` — True if bodies in the world are allowed to sleep, or false if not.

## queryBoundingBox


```lua
(method) love.World:queryBoundingBox(topLeftX: number, topLeftY: number, bottomRightX: number, bottomRightY: number, callback: function)
```


Calls a function for each fixture inside the specified area by searching for any overlapping bounding box (Fixture:getBoundingBox).


[Open in Browser](https://love2d.org/wiki/World:queryBoundingBox)

@*param* `topLeftX` — The x position of the top-left point.

@*param* `topLeftY` — The y position of the top-left point.

@*param* `bottomRightX` — The x position of the bottom-right point.

@*param* `bottomRightY` — The y position of the bottom-right point.

@*param* `callback` — This function gets passed one argument, the fixture, and should return a boolean. The search will continue if it is true or stop if it is false.

## rayCast


```lua
(method) love.World:rayCast(x1: number, y1: number, x2: number, y2: number, callback: function)
```


Casts a ray and calls a function for each fixtures it intersects.


[Open in Browser](https://love2d.org/wiki/World:rayCast)

@*param* `x1` — The x position of the starting point of the ray.

@*param* `y1` — The x position of the starting point of the ray.

@*param* `x2` — The x position of the end point of the ray.

@*param* `y2` — The x value of the surface normal vector of the shape edge.

@*param* `callback` — A function called for each fixture intersected by the ray. The function gets six arguments and should return a number as a control value. The intersection points fed into the function will be in an arbitrary order. If you wish to find the closest point of intersection, you'll need to do that yourself within the function. The easiest way to do that is by using the fraction value.

## release


```lua
(method) love.Object:release()
  -> success: boolean
```


Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.

This method can be used to immediately clean up resources without waiting for Lua's garbage collector.


[Open in Browser](https://love2d.org/wiki/Object:release)

@*return* `success` — True if the object was released by this call, false if it had been previously released.

## setCallbacks


```lua
(method) love.World:setCallbacks(beginContact: function, endContact: function, preSolve?: function, postSolve?: function)
```


Sets functions for the collision callbacks during the world update.

Four Lua functions can be given as arguments. The value nil removes a function.

When called, each function will be passed three arguments. The first two arguments are the colliding fixtures and the third argument is the Contact between them. The postSolve callback additionally gets the normal and tangent impulse for each contact point. See notes.

If you are interested to know when exactly each callback is called, consult a Box2d manual


[Open in Browser](https://love2d.org/wiki/World:setCallbacks)

@*param* `beginContact` — Gets called when two fixtures begin to overlap.

@*param* `endContact` — Gets called when two fixtures cease to overlap. This will also be called outside of a world update, when colliding objects are destroyed.

@*param* `preSolve` — Gets called before a collision gets resolved.

@*param* `postSolve` — Gets called after the collision has been resolved.

## setContactFilter


```lua
(method) love.World:setContactFilter(filter: function)
```


Sets a function for collision filtering.

If the group and category filtering doesn't generate a collision decision, this function gets called with the two fixtures as arguments. The function should return a boolean value where true means the fixtures will collide and false means they will pass through each other.


[Open in Browser](https://love2d.org/wiki/World:setContactFilter)

@*param* `filter` — The function handling the contact filtering.

## setGravity


```lua
(method) love.World:setGravity(x: number, y: number)
```


Set the gravity of the world.


[Open in Browser](https://love2d.org/wiki/World:setGravity)

@*param* `x` — The x component of gravity.

@*param* `y` — The y component of gravity.

## setSleepingAllowed


```lua
(method) love.World:setSleepingAllowed(allow: boolean)
```


Sets the sleep behaviour of the world.


[Open in Browser](https://love2d.org/wiki/World:setSleepingAllowed)

@*param* `allow` — True if bodies in the world are allowed to sleep, or false if not.

## translateOrigin


```lua
(method) love.World:translateOrigin(x: number, y: number)
```


Translates the World's origin. Useful in large worlds where floating point precision issues become noticeable at far distances from the origin.


[Open in Browser](https://love2d.org/wiki/World:translateOrigin)

@*param* `x` — The x component of the new origin with respect to the old origin.

@*param* `y` — The y component of the new origin with respect to the old origin.

## type


```lua
(method) love.Object:type()
  -> type: string
```


Gets the type of the object as a string.


[Open in Browser](https://love2d.org/wiki/Object:type)

@*return* `type` — The type as a string.

## typeOf


```lua
(method) love.Object:typeOf(name: string)
  -> b: boolean
```


Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.


[Open in Browser](https://love2d.org/wiki/Object:typeOf)

@*param* `name` — The name of the type to check for.

@*return* `b` — True if the object is of the specified type, false otherwise.

## update


```lua
(method) love.World:update(dt: number, velocityiterations?: number, positioniterations?: number)
```


Update the state of the world.


[Open in Browser](https://love2d.org/wiki/World:update)

@*param* `dt` — The time (in seconds) to advance the physics simulation.

@*param* `velocityiterations` — The maximum number of steps used to determine the new velocities when resolving a collision.

@*param* `positioniterations` — The maximum number of steps used to determine the new positions when resolving a collision.


---

# love.WrapMode


---

# love.audio

## getActiveEffects


```lua
function love.audio.getActiveEffects()
  -> effects: table
```


Gets a list of the names of the currently enabled effects.


[Open in Browser](https://love2d.org/wiki/love.audio.getActiveEffects)

@*return* `effects` — The list of the names of the currently enabled effects.

## getActiveSourceCount


```lua
function love.audio.getActiveSourceCount()
  -> count: number
```


Gets the current number of simultaneously playing sources.


[Open in Browser](https://love2d.org/wiki/love.audio.getActiveSourceCount)

@*return* `count` — The current number of simultaneously playing sources.

## getDistanceModel


```lua
function love.audio.getDistanceModel()
  -> model: "exponent"|"exponentclamped"|"inverse"|"inverseclamped"|"linear"...(+2)
```


Returns the distance attenuation model.


[Open in Browser](https://love2d.org/wiki/love.audio.getDistanceModel)

@*return* `model` — The current distance model. The default is 'inverseclamped'.

```lua
-- 
-- The different distance models.
-- 
-- Extended information can be found in the chapter "3.4. Attenuation By Distance" of the OpenAL 1.1 specification.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/DistanceModel)
-- 
model:
    | "none" -- Sources do not get attenuated.
    | "inverse" -- Inverse distance attenuation.
    | "inverseclamped" -- Inverse distance attenuation. Gain is clamped. In version 0.9.2 and older this is named '''inverse clamped'''.
    | "linear" -- Linear attenuation.
    | "linearclamped" -- Linear attenuation. Gain is clamped. In version 0.9.2 and older this is named '''linear clamped'''.
    | "exponent" -- Exponential attenuation.
    | "exponentclamped" -- Exponential attenuation. Gain is clamped. In version 0.9.2 and older this is named '''exponent clamped'''.
```

## getDopplerScale


```lua
function love.audio.getDopplerScale()
  -> scale: number
```


Gets the current global scale factor for velocity-based doppler effects.


[Open in Browser](https://love2d.org/wiki/love.audio.getDopplerScale)

@*return* `scale` — The current doppler scale factor.

## getEffect


```lua
function love.audio.getEffect(name: string)
  -> settings: table
```


Gets the settings associated with an effect.


[Open in Browser](https://love2d.org/wiki/love.audio.getEffect)

@*param* `name` — The name of the effect.

@*return* `settings` — The settings associated with the effect.

## getMaxSceneEffects


```lua
function love.audio.getMaxSceneEffects()
  -> maximum: number
```


Gets the maximum number of active effects supported by the system.


[Open in Browser](https://love2d.org/wiki/love.audio.getMaxSceneEffects)

@*return* `maximum` — The maximum number of active effects.

## getMaxSourceEffects


```lua
function love.audio.getMaxSourceEffects()
  -> maximum: number
```


Gets the maximum number of active Effects in a single Source object, that the system can support.


[Open in Browser](https://love2d.org/wiki/love.audio.getMaxSourceEffects)

@*return* `maximum` — The maximum number of active Effects per Source.

## getOrientation


```lua
function love.audio.getOrientation()
  -> fx: number
  2. fy: number
  3. fz: number
  4. ux: number
  5. uy: number
  6. uz: number
```


Returns the orientation of the listener.


[Open in Browser](https://love2d.org/wiki/love.audio.getOrientation)

@*return* `fx` — Forward vector of the listener orientation.

@*return* `fy` — Forward vector of the listener orientation.

@*return* `fz` — Forward vector of the listener orientation.

@*return* `ux` — Up vector of the listener orientation.

@*return* `uy` — Up vector of the listener orientation.

@*return* `uz` — Up vector of the listener orientation.

## getPosition


```lua
function love.audio.getPosition()
  -> x: number
  2. y: number
  3. z: number
```


Returns the position of the listener. Please note that positional audio only works for mono (i.e. non-stereo) sources.


[Open in Browser](https://love2d.org/wiki/love.audio.getPosition)

@*return* `x` — The X position of the listener.

@*return* `y` — The Y position of the listener.

@*return* `z` — The Z position of the listener.

## getRecordingDevices


```lua
function love.audio.getRecordingDevices()
  -> devices: table
```


Gets a list of RecordingDevices on the system.

The first device in the list is the user's default recording device. The list may be empty if there are no microphones connected to the system.

Audio recording is currently not supported on iOS.


[Open in Browser](https://love2d.org/wiki/love.audio.getRecordingDevices)

@*return* `devices` — The list of connected recording devices.

## getVelocity


```lua
function love.audio.getVelocity()
  -> x: number
  2. y: number
  3. z: number
```


Returns the velocity of the listener.


[Open in Browser](https://love2d.org/wiki/love.audio.getVelocity)

@*return* `x` — The X velocity of the listener.

@*return* `y` — The Y velocity of the listener.

@*return* `z` — The Z velocity of the listener.

## getVolume


```lua
function love.audio.getVolume()
  -> volume: number
```


Returns the master volume.


[Open in Browser](https://love2d.org/wiki/love.audio.getVolume)

@*return* `volume` — The current master volume

## isEffectsSupported


```lua
function love.audio.isEffectsSupported()
  -> supported: boolean
```


Gets whether audio effects are supported in the system.


[Open in Browser](https://love2d.org/wiki/love.audio.isEffectsSupported)

@*return* `supported` — True if effects are supported, false otherwise.

## newQueueableSource


```lua
function love.audio.newQueueableSource(samplerate: number, bitdepth: number, channels: number, buffercount?: number)
  -> source: love.Source
```


Creates a new Source usable for real-time generated sound playback with Source:queue.


[Open in Browser](https://love2d.org/wiki/love.audio.newQueueableSource)

@*param* `samplerate` — Number of samples per second when playing.

@*param* `bitdepth` — Bits per sample (8 or 16).

@*param* `channels` — 1 for mono or 2 for stereo.

@*param* `buffercount` — The number of buffers that can be queued up at any given time with Source:queue. Cannot be greater than 64. A sensible default (~8) is chosen if no value is specified.

@*return* `source` — The new Source usable with Source:queue.

## newSource


```lua
function love.audio.newSource(filename: string, type: "queue"|"static"|"stream")
  -> source: love.Source
```


Creates a new Source from a filepath, File, Decoder or SoundData.

Sources created from SoundData are always static.


[Open in Browser](https://love2d.org/wiki/love.audio.newSource)


---

@*param* `filename` — The filepath to the audio file.

@*param* `type` — Streaming or static source.

@*return* `source` — A new Source that can play the specified audio.

```lua
-- 
-- Types of audio sources.
-- 
-- A good rule of thumb is to use stream for music files and static for all short sound effects. Basically, you want to avoid loading large files into memory at once.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/SourceType)
-- 
type:
    | "static" -- The whole audio is decoded.
    | "stream" -- The audio is decoded in chunks when needed.
    | "queue" -- The audio must be manually queued by the user.
```

## pause


```lua
function love.audio.pause()
  -> Sources: table
```


Pauses specific or all currently played Sources.


[Open in Browser](https://love2d.org/wiki/love.audio.pause)


---

@*return* `Sources` — A table containing a list of Sources that were paused by this call.

## play


```lua
function love.audio.play(source: love.Source)
```


Plays the specified Source.


[Open in Browser](https://love2d.org/wiki/love.audio.play)


---

@*param* `source` — The Source to play.

## setDistanceModel


```lua
function love.audio.setDistanceModel(model: "exponent"|"exponentclamped"|"inverse"|"inverseclamped"|"linear"...(+2))
```


Sets the distance attenuation model.


[Open in Browser](https://love2d.org/wiki/love.audio.setDistanceModel)

@*param* `model` — The new distance model.

```lua
-- 
-- The different distance models.
-- 
-- Extended information can be found in the chapter "3.4. Attenuation By Distance" of the OpenAL 1.1 specification.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/DistanceModel)
-- 
model:
    | "none" -- Sources do not get attenuated.
    | "inverse" -- Inverse distance attenuation.
    | "inverseclamped" -- Inverse distance attenuation. Gain is clamped. In version 0.9.2 and older this is named '''inverse clamped'''.
    | "linear" -- Linear attenuation.
    | "linearclamped" -- Linear attenuation. Gain is clamped. In version 0.9.2 and older this is named '''linear clamped'''.
    | "exponent" -- Exponential attenuation.
    | "exponentclamped" -- Exponential attenuation. Gain is clamped. In version 0.9.2 and older this is named '''exponent clamped'''.
```

## setDopplerScale


```lua
function love.audio.setDopplerScale(scale: number)
```


Sets a global scale factor for velocity-based doppler effects. The default scale value is 1.


[Open in Browser](https://love2d.org/wiki/love.audio.setDopplerScale)

@*param* `scale` — The new doppler scale factor. The scale must be greater than 0.

## setEffect


```lua
function love.audio.setEffect(name: string, settings: { type: "chorus"|"compressor"|"distortion"|"echo"|"equalizer"...(+3), volume: number })
  -> success: boolean
```


Defines an effect that can be applied to a Source.

Not all system supports audio effects. Use love.audio.isEffectsSupported to check.


[Open in Browser](https://love2d.org/wiki/love.audio.setEffect)


---

@*param* `name` — The name of the effect.

@*param* `settings` — The settings to use for this effect, with the following fields:

@*return* `success` — Whether the effect was successfully created.

## setMixWithSystem


```lua
function love.audio.setMixWithSystem(mix: boolean)
  -> success: boolean
```


Sets whether the system should mix the audio with the system's audio.


[Open in Browser](https://love2d.org/wiki/love.audio.setMixWithSystem)

@*param* `mix` — True to enable mixing, false to disable it.

@*return* `success` — True if the change succeeded, false otherwise.

## setOrientation


```lua
function love.audio.setOrientation(fx: number, fy: number, fz: number, ux: number, uy: number, uz: number)
```


Sets the orientation of the listener.


[Open in Browser](https://love2d.org/wiki/love.audio.setOrientation)

@*param* `fx` — Forward vector of the listener orientation.

@*param* `fy` — Forward vector of the listener orientation.

@*param* `fz` — Forward vector of the listener orientation.

@*param* `ux` — Up vector of the listener orientation.

@*param* `uy` — Up vector of the listener orientation.

@*param* `uz` — Up vector of the listener orientation.

## setPosition


```lua
function love.audio.setPosition(x: number, y: number, z: number)
```


Sets the position of the listener, which determines how sounds play.


[Open in Browser](https://love2d.org/wiki/love.audio.setPosition)

@*param* `x` — The x position of the listener.

@*param* `y` — The y position of the listener.

@*param* `z` — The z position of the listener.

## setVelocity


```lua
function love.audio.setVelocity(x: number, y: number, z: number)
```


Sets the velocity of the listener.


[Open in Browser](https://love2d.org/wiki/love.audio.setVelocity)

@*param* `x` — The X velocity of the listener.

@*param* `y` — The Y velocity of the listener.

@*param* `z` — The Z velocity of the listener.

## setVolume


```lua
function love.audio.setVolume(volume: number)
```


Sets the master volume.


[Open in Browser](https://love2d.org/wiki/love.audio.setVolume)

@*param* `volume` — 1.0 is max and 0.0 is off.

## stop


```lua
function love.audio.stop()
```


Stops currently played sources.


[Open in Browser](https://love2d.org/wiki/love.audio.stop)


---

# love.audio


```lua
love.audio
```


---

# love.audio.getActiveEffects


```lua
function love.audio.getActiveEffects()
  -> effects: table
```


---

# love.audio.getActiveSourceCount


```lua
function love.audio.getActiveSourceCount()
  -> count: number
```


---

# love.audio.getDistanceModel


```lua
function love.audio.getDistanceModel()
  -> model: "exponent"|"exponentclamped"|"inverse"|"inverseclamped"|"linear"...(+2)
```


---

# love.audio.getDopplerScale


```lua
function love.audio.getDopplerScale()
  -> scale: number
```


---

# love.audio.getEffect


```lua
function love.audio.getEffect(name: string)
  -> settings: table
```


---

# love.audio.getMaxSceneEffects


```lua
function love.audio.getMaxSceneEffects()
  -> maximum: number
```


---

# love.audio.getMaxSourceEffects


```lua
function love.audio.getMaxSourceEffects()
  -> maximum: number
```


---

# love.audio.getOrientation


```lua
function love.audio.getOrientation()
  -> fx: number
  2. fy: number
  3. fz: number
  4. ux: number
  5. uy: number
  6. uz: number
```


---

# love.audio.getPosition


```lua
function love.audio.getPosition()
  -> x: number
  2. y: number
  3. z: number
```


---

# love.audio.getRecordingDevices


```lua
function love.audio.getRecordingDevices()
  -> devices: table
```


---

# love.audio.getVelocity


```lua
function love.audio.getVelocity()
  -> x: number
  2. y: number
  3. z: number
```


---

# love.audio.getVolume


```lua
function love.audio.getVolume()
  -> volume: number
```


---

# love.audio.isEffectsSupported


```lua
function love.audio.isEffectsSupported()
  -> supported: boolean
```


---

# love.audio.newQueueableSource


```lua
function love.audio.newQueueableSource(samplerate: number, bitdepth: number, channels: number, buffercount?: number)
  -> source: love.Source
```


---

# love.audio.newSource


```lua
function love.audio.newSource(filename: string, type: "queue"|"static"|"stream")
  -> source: love.Source
```


---

# love.audio.pause


```lua
function love.audio.pause()
  -> Sources: table
```


---

# love.audio.play


```lua
function love.audio.play(source: love.Source)
```


---

# love.audio.setDistanceModel


```lua
function love.audio.setDistanceModel(model: "exponent"|"exponentclamped"|"inverse"|"inverseclamped"|"linear"...(+2))
```


---

# love.audio.setDopplerScale


```lua
function love.audio.setDopplerScale(scale: number)
```


---

# love.audio.setEffect


```lua
function love.audio.setEffect(name: string, settings: { type: "chorus"|"compressor"|"distortion"|"echo"|"equalizer"...(+3), volume: number })
  -> success: boolean
```


---

# love.audio.setMixWithSystem


```lua
function love.audio.setMixWithSystem(mix: boolean)
  -> success: boolean
```


---

# love.audio.setOrientation


```lua
function love.audio.setOrientation(fx: number, fy: number, fz: number, ux: number, uy: number, uz: number)
```


---

# love.audio.setPosition


```lua
function love.audio.setPosition(x: number, y: number, z: number)
```


---

# love.audio.setVelocity


```lua
function love.audio.setVelocity(x: number, y: number, z: number)
```


---

# love.audio.setVolume


```lua
function love.audio.setVolume(volume: number)
```


---

# love.audio.stop


```lua
function love.audio.stop()
```


---

# love.conf


---

# love.data


```lua
love.data
```


---

# love.data

## compress


```lua
function love.data.compress(container: "data"|"string", format: "deflate"|"gzip"|"lz4"|"zlib", rawstring: string, level?: number)
  -> compressedData: string|love.CompressedData
```


Compresses a string or data using a specific compression algorithm.


[Open in Browser](https://love2d.org/wiki/love.data.compress)


---

@*param* `container` — What type to return the compressed data as.

@*param* `format` — The format to use when compressing the string.

@*param* `rawstring` — The raw (un-compressed) string to compress.

@*param* `level` — The level of compression to use, between 0 and 9. -1 indicates the default level. The meaning of this argument depends on the compression format being used.

@*return* `compressedData` — CompressedData/string which contains the compressed version of rawstring.

```lua
-- 
-- Return type of various data-returning functions.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/ContainerType)
-- 
container:
    | "data" -- Return type is ByteData.
    | "string" -- Return type is string.

-- 
-- Compressed data formats.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CompressedDataFormat)
-- 
format:
    | "lz4" -- The LZ4 compression format. Compresses and decompresses very quickly, but the compression ratio is not the best. LZ4-HC is used when compression level 9 is specified. Some benchmarks are available here.
    | "zlib" -- The zlib format is DEFLATE-compressed data with a small bit of header data. Compresses relatively slowly and decompresses moderately quickly, and has a decent compression ratio.
    | "gzip" -- The gzip format is DEFLATE-compressed data with a slightly larger header than zlib. Since it uses DEFLATE it has the same compression characteristics as the zlib format.
    | "deflate" -- Raw DEFLATE-compressed data (no header).
```

## decode


```lua
function love.data.decode(container: "data"|"string", format: "base64"|"hex", sourceString: string)
  -> decoded: string|love.ByteData
```


Decode Data or a string from any of the EncodeFormats to Data or string.


[Open in Browser](https://love2d.org/wiki/love.data.decode)


---

@*param* `container` — What type to return the decoded data as.

@*param* `format` — The format of the input data.

@*param* `sourceString` — The raw (encoded) data to decode.

@*return* `decoded` — ByteData/string which contains the decoded version of source.

```lua
-- 
-- Return type of various data-returning functions.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/ContainerType)
-- 
container:
    | "data" -- Return type is ByteData.
    | "string" -- Return type is string.

-- 
-- Encoding format used to encode or decode data.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/EncodeFormat)
-- 
format:
    | "base64" -- Encode/decode data as base64 binary-to-text encoding.
    | "hex" -- Encode/decode data as hexadecimal string.
```

## decompress


```lua
function love.data.decompress(container: "data"|"string", compressedData: love.CompressedData)
  -> decompressedData: string|love.Data
```


Decompresses a CompressedData or previously compressed string or Data object.


[Open in Browser](https://love2d.org/wiki/love.data.decompress)


---

@*param* `container` — What type to return the decompressed data as.

@*param* `compressedData` — The compressed data to decompress.

@*return* `decompressedData` — Data/string containing the raw decompressed data.

```lua
-- 
-- Return type of various data-returning functions.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/ContainerType)
-- 
container:
    | "data" -- Return type is ByteData.
    | "string" -- Return type is string.
```

## encode


```lua
function love.data.encode(container: "data"|"string", format: "base64"|"hex", sourceString: string, linelength?: number)
  -> encoded: string|love.ByteData
```


Encode Data or a string to a Data or string in one of the EncodeFormats.


[Open in Browser](https://love2d.org/wiki/love.data.encode)


---

@*param* `container` — What type to return the encoded data as.

@*param* `format` — The format of the output data.

@*param* `sourceString` — The raw data to encode.

@*param* `linelength` — The maximum line length of the output. Only supported for base64, ignored if 0.

@*return* `encoded` — ByteData/string which contains the encoded version of source.

```lua
-- 
-- Return type of various data-returning functions.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/ContainerType)
-- 
container:
    | "data" -- Return type is ByteData.
    | "string" -- Return type is string.

-- 
-- Encoding format used to encode or decode data.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/EncodeFormat)
-- 
format:
    | "base64" -- Encode/decode data as base64 binary-to-text encoding.
    | "hex" -- Encode/decode data as hexadecimal string.
```

## getPackedSize


```lua
function love.data.getPackedSize(format: string)
  -> size: number
```


Gets the size in bytes that a given format used with love.data.pack will use.

This function behaves the same as Lua 5.3's string.packsize.


[Open in Browser](https://love2d.org/wiki/love.data.getPackedSize)

@*param* `format` — A string determining how the values are packed. Follows the rules of Lua 5.3's string.pack format strings.

@*return* `size` — The size in bytes that the packed data will use.

## hash


```lua
function love.data.hash(hashFunction: "md5"|"sha1"|"sha224"|"sha256"|"sha384"...(+1), string: string)
  -> rawdigest: string
```


Compute the message digest of a string using a specified hash algorithm.


[Open in Browser](https://love2d.org/wiki/love.data.hash)


---

@*param* `hashFunction` — Hash algorithm to use.

@*param* `string` — String to hash.

@*return* `rawdigest` — Raw message digest string.

```lua
-- 
-- Hash algorithm of love.data.hash.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/HashFunction)
-- 
hashFunction:
    | "md5" -- MD5 hash algorithm (16 bytes).
    | "sha1" -- SHA1 hash algorithm (20 bytes).
    | "sha224" -- SHA2 hash algorithm with message digest size of 224 bits (28 bytes).
    | "sha256" -- SHA2 hash algorithm with message digest size of 256 bits (32 bytes).
    | "sha384" -- SHA2 hash algorithm with message digest size of 384 bits (48 bytes).
    | "sha512" -- SHA2 hash algorithm with message digest size of 512 bits (64 bytes).
```

## newByteData


```lua
function love.data.newByteData(datastring: string)
  -> bytedata: love.ByteData
```


Creates a new Data object containing arbitrary bytes.

Data:getPointer along with LuaJIT's FFI can be used to manipulate the contents of the ByteData object after it has been created.


[Open in Browser](https://love2d.org/wiki/love.data.newByteData)


---

@*param* `datastring` — The byte string to copy.

@*return* `bytedata` — The new Data object.

## newDataView


```lua
function love.data.newDataView(data: love.Data, offset: number, size: number)
  -> view: love.Data
```


Creates a new Data referencing a subsection of an existing Data object.


[Open in Browser](https://love2d.org/wiki/love.data.newDataView)

@*param* `data` — The Data object to reference.

@*param* `offset` — The offset of the subsection to reference, in bytes.

@*param* `size` — The size in bytes of the subsection to reference.

@*return* `view` — The new Data view.

## pack


```lua
function love.data.pack(container: "data"|"string", format: string, v1: boolean|string|number, ...boolean|string|number)
  -> data: string|love.Data
```


Packs (serializes) simple Lua values.

This function behaves the same as Lua 5.3's string.pack.


[Open in Browser](https://love2d.org/wiki/love.data.pack)

@*param* `container` — What type to return the encoded data as.

@*param* `format` — A string determining how the values are packed. Follows the rules of Lua 5.3's string.pack format strings.

@*param* `v1` — The first value (number, boolean, or string) to serialize.

@*return* `data` — Data/string which contains the serialized data.

```lua
-- 
-- Return type of various data-returning functions.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/ContainerType)
-- 
container:
    | "data" -- Return type is ByteData.
    | "string" -- Return type is string.
```

## unpack


```lua
function love.data.unpack(format: string, datastring: string, pos?: number)
  -> v1: boolean|string|number
  2. index: number
```


Unpacks (deserializes) a byte-string or Data into simple Lua values.

This function behaves the same as Lua 5.3's string.unpack.


[Open in Browser](https://love2d.org/wiki/love.data.unpack)


---

@*param* `format` — A string determining how the values were packed. Follows the rules of Lua 5.3's string.pack format strings.

@*param* `datastring` — A string containing the packed (serialized) data.

@*param* `pos` — Where to start reading in the string. Negative values can be used to read relative from the end of the string.

@*return* `v1` — The first value (number, boolean, or string) that was unpacked.

@*return* `index` — The index of the first unread byte in the data string.


---

# love.data.compress


```lua
function love.data.compress(container: "data"|"string", format: "deflate"|"gzip"|"lz4"|"zlib", rawstring: string, level?: number)
  -> compressedData: string|love.CompressedData
```


---

# love.data.decode


```lua
function love.data.decode(container: "data"|"string", format: "base64"|"hex", sourceString: string)
  -> decoded: string|love.ByteData
```


---

# love.data.decompress


```lua
function love.data.decompress(container: "data"|"string", compressedData: love.CompressedData)
  -> decompressedData: string|love.Data
```


---

# love.data.encode


```lua
function love.data.encode(container: "data"|"string", format: "base64"|"hex", sourceString: string, linelength?: number)
  -> encoded: string|love.ByteData
```


---

# love.data.getPackedSize


```lua
function love.data.getPackedSize(format: string)
  -> size: number
```


---

# love.data.hash


```lua
function love.data.hash(hashFunction: "md5"|"sha1"|"sha224"|"sha256"|"sha384"...(+1), string: string)
  -> rawdigest: string
```


---

# love.data.newByteData


```lua
function love.data.newByteData(datastring: string)
  -> bytedata: love.ByteData
```


---

# love.data.newDataView


```lua
function love.data.newDataView(data: love.Data, offset: number, size: number)
  -> view: love.Data
```


---

# love.data.pack


```lua
function love.data.pack(container: "data"|"string", format: string, v1: boolean|string|number, ...boolean|string|number)
  -> data: string|love.Data
```


---

# love.data.unpack


```lua
function love.data.unpack(format: string, datastring: string, pos?: number)
  -> v1: boolean|string|number
  2. index: number
```


---

# love.directorydropped


---

# love.displayrotated


---

# love.draw


---

# love.errorhandler


---

# love.event


```lua
love.event
```


---

# love.event

## clear


```lua
function love.event.clear()
```


Clears the event queue.


[Open in Browser](https://love2d.org/wiki/love.event.clear)

## poll


```lua
function love.event.poll()
  -> i: function
```


Returns an iterator for messages in the event queue.


[Open in Browser](https://love2d.org/wiki/love.event.poll)

@*return* `i` — Iterator function usable in a for loop.

## pump


```lua
function love.event.pump()
```


Pump events into the event queue.

This is a low-level function, and is usually not called by the user, but by love.run.

Note that this does need to be called for any OS to think you're still running,

and if you want to handle OS-generated events at all (think callbacks).


[Open in Browser](https://love2d.org/wiki/love.event.pump)

## push


```lua
function love.event.push(n: "directorydropped"|"f"|"filedropped"|"focus"|"gamepadaxis"...(+32), a?: any, b?: any, c?: any, d?: any, e?: any, f?: any, ...any)
```


Adds an event to the event queue.

From 0.10.0 onwards, you may pass an arbitrary amount of arguments with this function, though the default callbacks don't ever use more than six.


[Open in Browser](https://love2d.org/wiki/love.event.push)

@*param* `n` — The name of the event.

@*param* `a` — First event argument.

@*param* `b` — Second event argument.

@*param* `c` — Third event argument.

@*param* `d` — Fourth event argument.

@*param* `e` — Fifth event argument.

@*param* `f` — Sixth event argument.

```lua
-- 
-- Arguments to love.event.push() and the like.
-- 
-- Since 0.8.0, event names are no longer abbreviated.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/Event)
-- 
n:
    | "focus" -- Window focus gained or lost
    | "joystickpressed" -- Joystick pressed
    | "joystickreleased" -- Joystick released
    | "keypressed" -- Key pressed
    | "keyreleased" -- Key released
    | "mousepressed" -- Mouse pressed
    | "mousereleased" -- Mouse released
    | "quit" -- Quit
    | "resize" -- Window size changed by the user
    | "visible" -- Window is minimized or un-minimized by the user
    | "mousefocus" -- Window mouse focus gained or lost
    | "threaderror" -- A Lua error has occurred in a thread
    | "joystickadded" -- Joystick connected
    | "joystickremoved" -- Joystick disconnected
    | "joystickaxis" -- Joystick axis motion
    | "joystickhat" -- Joystick hat pressed
    | "gamepadpressed" -- Joystick's virtual gamepad button pressed
    | "gamepadreleased" -- Joystick's virtual gamepad button released
    | "gamepadaxis" -- Joystick's virtual gamepad axis moved
    | "textinput" -- User entered text
    | "mousemoved" -- Mouse position changed
    | "lowmemory" -- Running out of memory on mobile devices system
    | "textedited" -- Candidate text for an IME changed
    | "wheelmoved" -- Mouse wheel moved
    | "touchpressed" -- Touch screen touched
    | "touchreleased" -- Touch screen stop touching
    | "touchmoved" -- Touch press moved inside touch screen
    | "directorydropped" -- Directory is dragged and dropped onto the window
    | "filedropped" -- File is dragged and dropped onto the window.
    | "jp" -- Joystick pressed
    | "jr" -- Joystick released
    | "kp" -- Key pressed
    | "kr" -- Key released
    | "mp" -- Mouse pressed
    | "mr" -- Mouse released
    | "q" -- Quit
    | "f" -- Window focus gained or lost
```

## quit


```lua
function love.event.quit(exitstatus?: number)
```


Adds the quit event to the queue.

The quit event is a signal for the event handler to close LÖVE. It's possible to abort the exit process with the love.quit callback.


[Open in Browser](https://love2d.org/wiki/love.event.quit)


---

@*param* `exitstatus` — The program exit status to use when closing the application.

## wait


```lua
function love.event.wait()
  -> n: "directorydropped"|"f"|"filedropped"|"focus"|"gamepadaxis"...(+32)
  2. a: any
  3. b: any
  4. c: any
  5. d: any
  6. e: any
  7. f: any
```


Like love.event.poll(), but blocks until there is an event in the queue.


[Open in Browser](https://love2d.org/wiki/love.event.wait)

@*return* `n` — The name of event.

@*return* `a` — First event argument.

@*return* `b` — Second event argument.

@*return* `c` — Third event argument.

@*return* `d` — Fourth event argument.

@*return* `e` — Fifth event argument.

@*return* `f` — Sixth event argument.

```lua
-- 
-- Arguments to love.event.push() and the like.
-- 
-- Since 0.8.0, event names are no longer abbreviated.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/Event)
-- 
n:
    | "focus" -- Window focus gained or lost
    | "joystickpressed" -- Joystick pressed
    | "joystickreleased" -- Joystick released
    | "keypressed" -- Key pressed
    | "keyreleased" -- Key released
    | "mousepressed" -- Mouse pressed
    | "mousereleased" -- Mouse released
    | "quit" -- Quit
    | "resize" -- Window size changed by the user
    | "visible" -- Window is minimized or un-minimized by the user
    | "mousefocus" -- Window mouse focus gained or lost
    | "threaderror" -- A Lua error has occurred in a thread
    | "joystickadded" -- Joystick connected
    | "joystickremoved" -- Joystick disconnected
    | "joystickaxis" -- Joystick axis motion
    | "joystickhat" -- Joystick hat pressed
    | "gamepadpressed" -- Joystick's virtual gamepad button pressed
    | "gamepadreleased" -- Joystick's virtual gamepad button released
    | "gamepadaxis" -- Joystick's virtual gamepad axis moved
    | "textinput" -- User entered text
    | "mousemoved" -- Mouse position changed
    | "lowmemory" -- Running out of memory on mobile devices system
    | "textedited" -- Candidate text for an IME changed
    | "wheelmoved" -- Mouse wheel moved
    | "touchpressed" -- Touch screen touched
    | "touchreleased" -- Touch screen stop touching
    | "touchmoved" -- Touch press moved inside touch screen
    | "directorydropped" -- Directory is dragged and dropped onto the window
    | "filedropped" -- File is dragged and dropped onto the window.
    | "jp" -- Joystick pressed
    | "jr" -- Joystick released
    | "kp" -- Key pressed
    | "kr" -- Key released
    | "mp" -- Mouse pressed
    | "mr" -- Mouse released
    | "q" -- Quit
    | "f" -- Window focus gained or lost
```


---

# love.event.clear


```lua
function love.event.clear()
```


---

# love.event.poll


```lua
function love.event.poll()
  -> i: function
```


---

# love.event.pump


```lua
function love.event.pump()
```


---

# love.event.push


```lua
function love.event.push(n: "directorydropped"|"f"|"filedropped"|"focus"|"gamepadaxis"...(+32), a?: any, b?: any, c?: any, d?: any, e?: any, f?: any, ...any)
```


---

# love.event.quit


```lua
function love.event.quit(exitstatus?: number)
```


---

# love.event.wait


```lua
function love.event.wait()
  -> n: "directorydropped"|"f"|"filedropped"|"focus"|"gamepadaxis"...(+32)
  2. a: any
  3. b: any
  4. c: any
  5. d: any
  6. e: any
  7. f: any
```


---

# love.filedropped


---

# love.filesystem

## append


```lua
function love.filesystem.append(name: string, data: string, size?: number)
  -> success: boolean
  2. errormsg: string
```


Append data to an existing file.


[Open in Browser](https://love2d.org/wiki/love.filesystem.append)


---

@*param* `name` — The name (and path) of the file.

@*param* `data` — The string data to append to the file.

@*param* `size` — How many bytes to write.

@*return* `success` — True if the operation was successful, or nil if there was an error.

@*return* `errormsg` — The error message on failure.

## areSymlinksEnabled


```lua
function love.filesystem.areSymlinksEnabled()
  -> enable: boolean
```


Gets whether love.filesystem follows symbolic links.


[Open in Browser](https://love2d.org/wiki/love.filesystem.areSymlinksEnabled)

@*return* `enable` — Whether love.filesystem follows symbolic links.

## createDirectory


```lua
function love.filesystem.createDirectory(name: string)
  -> success: boolean
```


Recursively creates a directory.

When called with 'a/b' it creates both 'a' and 'a/b', if they don't exist already.


[Open in Browser](https://love2d.org/wiki/love.filesystem.createDirectory)

@*param* `name` — The directory to create.

@*return* `success` — True if the directory was created, false if not.

## getAppdataDirectory


```lua
function love.filesystem.getAppdataDirectory()
  -> path: string
```


Returns the application data directory (could be the same as getUserDirectory)


[Open in Browser](https://love2d.org/wiki/love.filesystem.getAppdataDirectory)

@*return* `path` — The path of the application data directory

## getCRequirePath


```lua
function love.filesystem.getCRequirePath()
  -> paths: string
```


Gets the filesystem paths that will be searched for c libraries when require is called.

The paths string returned by this function is a sequence of path templates separated by semicolons. The argument passed to ''require'' will be inserted in place of any question mark ('?') character in each template (after the dot characters in the argument passed to ''require'' are replaced by directory separators.) Additionally, any occurrence of a double question mark ('??') will be replaced by the name passed to require and the default library extension for the platform.

The paths are relative to the game's source and save directories, as well as any paths mounted with love.filesystem.mount.


[Open in Browser](https://love2d.org/wiki/love.filesystem.getCRequirePath)

@*return* `paths` — The paths that the ''require'' function will check for c libraries in love's filesystem.

## getDirectoryItems


```lua
function love.filesystem.getDirectoryItems(dir: string)
  -> files: table
```


Returns a table with the names of files and subdirectories in the specified path. The table is not sorted in any way; the order is undefined.

If the path passed to the function exists in the game and the save directory, it will list the files and directories from both places.


[Open in Browser](https://love2d.org/wiki/love.filesystem.getDirectoryItems)


---

@*param* `dir` — The directory.

@*return* `files` — A sequence with the names of all files and subdirectories as strings.

## getIdentity


```lua
function love.filesystem.getIdentity()
  -> name: string
```


Gets the write directory name for your game.

Note that this only returns the name of the folder to store your files in, not the full path.


[Open in Browser](https://love2d.org/wiki/love.filesystem.getIdentity)

@*return* `name` — The identity that is used as write directory.

## getInfo


```lua
function love.filesystem.getInfo(path: string, filtertype?: "directory"|"file"|"other"|"symlink")
  -> info: { type: "directory"|"file"|"other"|"symlink", size: number, modtime: number }
```


Gets information about the specified file or directory.


[Open in Browser](https://love2d.org/wiki/love.filesystem.getInfo)


---

@*param* `path` — The file or directory path to check.

@*param* `filtertype` — If supplied, this parameter causes getInfo to only return the info table if the item at the given path matches the specified file type.

@*return* `info` — A table containing information about the specified path, or nil if nothing exists at the path. The table contains the following fields:

```lua
-- 
-- The type of a file.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FileType)
-- 
filtertype:
    | "file" -- Regular file.
    | "directory" -- Directory.
    | "symlink" -- Symbolic link.
    | "other" -- Something completely different like a device.
```

## getRealDirectory


```lua
function love.filesystem.getRealDirectory(filepath: string)
  -> realdir: string
```


Gets the platform-specific absolute path of the directory containing a filepath.

This can be used to determine whether a file is inside the save directory or the game's source .love.


[Open in Browser](https://love2d.org/wiki/love.filesystem.getRealDirectory)

@*param* `filepath` — The filepath to get the directory of.

@*return* `realdir` — The platform-specific full path of the directory containing the filepath.

## getRequirePath


```lua
function love.filesystem.getRequirePath()
  -> paths: string
```


Gets the filesystem paths that will be searched when require is called.

The paths string returned by this function is a sequence of path templates separated by semicolons. The argument passed to ''require'' will be inserted in place of any question mark ('?') character in each template (after the dot characters in the argument passed to ''require'' are replaced by directory separators.)

The paths are relative to the game's source and save directories, as well as any paths mounted with love.filesystem.mount.


[Open in Browser](https://love2d.org/wiki/love.filesystem.getRequirePath)

@*return* `paths` — The paths that the ''require'' function will check in love's filesystem.

## getSaveDirectory


```lua
function love.filesystem.getSaveDirectory()
  -> dir: string
```


Gets the full path to the designated save directory.

This can be useful if you want to use the standard io library (or something else) to

read or write in the save directory.


[Open in Browser](https://love2d.org/wiki/love.filesystem.getSaveDirectory)

@*return* `dir` — The absolute path to the save directory.

## getSource


```lua
function love.filesystem.getSource()
  -> path: string
```


Returns the full path to the the .love file or directory. If the game is fused to the LÖVE executable, then the executable is returned.


[Open in Browser](https://love2d.org/wiki/love.filesystem.getSource)

@*return* `path` — The full platform-dependent path of the .love file or directory.

## getSourceBaseDirectory


```lua
function love.filesystem.getSourceBaseDirectory()
  -> path: string
```


Returns the full path to the directory containing the .love file. If the game is fused to the LÖVE executable, then the directory containing the executable is returned.

If love.filesystem.isFused is true, the path returned by this function can be passed to love.filesystem.mount, which will make the directory containing the main game (e.g. C:\Program Files\coolgame\) readable by love.filesystem.


[Open in Browser](https://love2d.org/wiki/love.filesystem.getSourceBaseDirectory)

@*return* `path` — The full platform-dependent path of the directory containing the .love file.

## getUserDirectory


```lua
function love.filesystem.getUserDirectory()
  -> path: string
```


Returns the path of the user's directory


[Open in Browser](https://love2d.org/wiki/love.filesystem.getUserDirectory)

@*return* `path` — The path of the user's directory

## getWorkingDirectory


```lua
function love.filesystem.getWorkingDirectory()
  -> cwd: string
```


Gets the current working directory.


[Open in Browser](https://love2d.org/wiki/love.filesystem.getWorkingDirectory)

@*return* `cwd` — The current working directory.

## init


```lua
function love.filesystem.init(appname: string)
```


Initializes love.filesystem, will be called internally, so should not be used explicitly.


[Open in Browser](https://love2d.org/wiki/love.filesystem.init)

@*param* `appname` — The name of the application binary, typically love.

## isFused


```lua
function love.filesystem.isFused()
  -> fused: boolean
```


Gets whether the game is in fused mode or not.

If a game is in fused mode, its save directory will be directly in the Appdata directory instead of Appdata/LOVE/. The game will also be able to load C Lua dynamic libraries which are located in the save directory.

A game is in fused mode if the source .love has been fused to the executable (see Game Distribution), or if '--fused' has been given as a command-line argument when starting the game.


[Open in Browser](https://love2d.org/wiki/love.filesystem.isFused)

@*return* `fused` — True if the game is in fused mode, false otherwise.

## lines


```lua
function love.filesystem.lines(name: string)
  -> iterator: function
```


Iterate over the lines in a file.


[Open in Browser](https://love2d.org/wiki/love.filesystem.lines)

@*param* `name` — The name (and path) of the file

@*return* `iterator` — A function that iterates over all the lines in the file

## load


```lua
function love.filesystem.load(name: string)
  -> chunk: function
  2. errormsg: string
```


Loads a Lua file (but does not run it).


[Open in Browser](https://love2d.org/wiki/love.filesystem.load)

@*param* `name` — The name (and path) of the file.

@*return* `chunk` — The loaded chunk.

@*return* `errormsg` — The error message if file could not be opened.

## mount


```lua
function love.filesystem.mount(archive: string, mountpoint: string, appendToPath?: boolean)
  -> success: boolean
```


Mounts a zip file or folder in the game's save directory for reading.

It is also possible to mount love.filesystem.getSourceBaseDirectory if the game is in fused mode.


[Open in Browser](https://love2d.org/wiki/love.filesystem.mount)


---

@*param* `archive` — The folder or zip file in the game's save directory to mount.

@*param* `mountpoint` — The new path the archive will be mounted to.

@*param* `appendToPath` — Whether the archive will be searched when reading a filepath before or after already-mounted archives. This includes the game's source and save directories.

@*return* `success` — True if the archive was successfully mounted, false otherwise.

## newFile


```lua
function love.filesystem.newFile(filename: string)
  -> file: love.File
```


Creates a new File object.

It needs to be opened before it can be accessed.


[Open in Browser](https://love2d.org/wiki/love.filesystem.newFile)


---

@*param* `filename` — The filename of the file.

@*return* `file` — The new File object.

## newFileData


```lua
function love.filesystem.newFileData(contents: string, name: string)
  -> data: love.FileData
```


Creates a new FileData object from a file on disk, or from a string in memory.


[Open in Browser](https://love2d.org/wiki/love.filesystem.newFileData)


---

@*param* `contents` — The contents of the file in memory represented as a string.

@*param* `name` — The name of the file. The extension may be parsed and used by LÖVE when passing the FileData object into love.audio.newSource.

@*return* `data` — The new FileData.

## read


```lua
function love.filesystem.read(name: string, size?: number)
  -> contents: string
  2. size: number
  3. contents: nil
  4. error: string
```


Read the contents of a file.


[Open in Browser](https://love2d.org/wiki/love.filesystem.read)


---

@*param* `name` — The name (and path) of the file.

@*param* `size` — How many bytes to read.

@*return* `contents` — The file contents.

@*return* `size` — How many bytes have been read.

@*return* `contents` — returns nil as content.

@*return* `error` — returns an error message.

## remove


```lua
function love.filesystem.remove(name: string)
  -> success: boolean
```


Removes a file or empty directory.


[Open in Browser](https://love2d.org/wiki/love.filesystem.remove)

@*param* `name` — The file or directory to remove.

@*return* `success` — True if the file/directory was removed, false otherwise.

## setCRequirePath


```lua
function love.filesystem.setCRequirePath(paths: string)
```


Sets the filesystem paths that will be searched for c libraries when require is called.

The paths string returned by this function is a sequence of path templates separated by semicolons. The argument passed to ''require'' will be inserted in place of any question mark ('?') character in each template (after the dot characters in the argument passed to ''require'' are replaced by directory separators.) Additionally, any occurrence of a double question mark ('??') will be replaced by the name passed to require and the default library extension for the platform.

The paths are relative to the game's source and save directories, as well as any paths mounted with love.filesystem.mount.


[Open in Browser](https://love2d.org/wiki/love.filesystem.setCRequirePath)

@*param* `paths` — The paths that the ''require'' function will check in love's filesystem.

## setIdentity


```lua
function love.filesystem.setIdentity(name: string)
```


Sets the write directory for your game.

Note that you can only set the name of the folder to store your files in, not the location.


[Open in Browser](https://love2d.org/wiki/love.filesystem.setIdentity)


---

@*param* `name` — The new identity that will be used as write directory.

## setRequirePath


```lua
function love.filesystem.setRequirePath(paths: string)
```


Sets the filesystem paths that will be searched when require is called.

The paths string given to this function is a sequence of path templates separated by semicolons. The argument passed to ''require'' will be inserted in place of any question mark ('?') character in each template (after the dot characters in the argument passed to ''require'' are replaced by directory separators.)

The paths are relative to the game's source and save directories, as well as any paths mounted with love.filesystem.mount.


[Open in Browser](https://love2d.org/wiki/love.filesystem.setRequirePath)

@*param* `paths` — The paths that the ''require'' function will check in love's filesystem.

## setSource


```lua
function love.filesystem.setSource(path: string)
```


Sets the source of the game, where the code is present. This function can only be called once, and is normally automatically done by LÖVE.


[Open in Browser](https://love2d.org/wiki/love.filesystem.setSource)

@*param* `path` — Absolute path to the game's source folder.

## setSymlinksEnabled


```lua
function love.filesystem.setSymlinksEnabled(enable: boolean)
```


Sets whether love.filesystem follows symbolic links. It is enabled by default in version 0.10.0 and newer, and disabled by default in 0.9.2.


[Open in Browser](https://love2d.org/wiki/love.filesystem.setSymlinksEnabled)

@*param* `enable` — Whether love.filesystem should follow symbolic links.

## unmount


```lua
function love.filesystem.unmount(archive: string)
  -> success: boolean
```


Unmounts a zip file or folder previously mounted for reading with love.filesystem.mount.


[Open in Browser](https://love2d.org/wiki/love.filesystem.unmount)

@*param* `archive` — The folder or zip file in the game's save directory which is currently mounted.

@*return* `success` — True if the archive was successfully unmounted, false otherwise.

## write


```lua
function love.filesystem.write(name: string, data: string, size?: number)
  -> success: boolean
  2. message: string
```


Write data to a file in the save directory. If the file existed already, it will be completely replaced by the new contents.


[Open in Browser](https://love2d.org/wiki/love.filesystem.write)


---

@*param* `name` — The name (and path) of the file.

@*param* `data` — The string data to write to the file.

@*param* `size` — How many bytes to write.

@*return* `success` — If the operation was successful.

@*return* `message` — Error message if operation was unsuccessful.


---

# love.filesystem


```lua
love.filesystem
```


---

# love.filesystem.append


```lua
function love.filesystem.append(name: string, data: string, size?: number)
  -> success: boolean
  2. errormsg: string
```


---

# love.filesystem.areSymlinksEnabled


```lua
function love.filesystem.areSymlinksEnabled()
  -> enable: boolean
```


---

# love.filesystem.createDirectory


```lua
function love.filesystem.createDirectory(name: string)
  -> success: boolean
```


---

# love.filesystem.getAppdataDirectory


```lua
function love.filesystem.getAppdataDirectory()
  -> path: string
```


---

# love.filesystem.getCRequirePath


```lua
function love.filesystem.getCRequirePath()
  -> paths: string
```


---

# love.filesystem.getDirectoryItems


```lua
function love.filesystem.getDirectoryItems(dir: string)
  -> files: table
```


---

# love.filesystem.getIdentity


```lua
function love.filesystem.getIdentity()
  -> name: string
```


---

# love.filesystem.getInfo


```lua
function love.filesystem.getInfo(path: string, filtertype?: "directory"|"file"|"other"|"symlink")
  -> info: { type: "directory"|"file"|"other"|"symlink", size: number, modtime: number }
```


---

# love.filesystem.getRealDirectory


```lua
function love.filesystem.getRealDirectory(filepath: string)
  -> realdir: string
```


---

# love.filesystem.getRequirePath


```lua
function love.filesystem.getRequirePath()
  -> paths: string
```


---

# love.filesystem.getSaveDirectory


```lua
function love.filesystem.getSaveDirectory()
  -> dir: string
```


---

# love.filesystem.getSource


```lua
function love.filesystem.getSource()
  -> path: string
```


---

# love.filesystem.getSourceBaseDirectory


```lua
function love.filesystem.getSourceBaseDirectory()
  -> path: string
```


---

# love.filesystem.getUserDirectory


```lua
function love.filesystem.getUserDirectory()
  -> path: string
```


---

# love.filesystem.getWorkingDirectory


```lua
function love.filesystem.getWorkingDirectory()
  -> cwd: string
```


---

# love.filesystem.init


```lua
function love.filesystem.init(appname: string)
```


---

# love.filesystem.isFused


```lua
function love.filesystem.isFused()
  -> fused: boolean
```


---

# love.filesystem.lines


```lua
function love.filesystem.lines(name: string)
  -> iterator: function
```


---

# love.filesystem.load


```lua
function love.filesystem.load(name: string)
  -> chunk: function
  2. errormsg: string
```


---

# love.filesystem.mount


```lua
function love.filesystem.mount(archive: string, mountpoint: string, appendToPath?: boolean)
  -> success: boolean
```


---

# love.filesystem.newFile


```lua
function love.filesystem.newFile(filename: string)
  -> file: love.File
```


---

# love.filesystem.newFileData


```lua
function love.filesystem.newFileData(contents: string, name: string)
  -> data: love.FileData
```


---

# love.filesystem.read


```lua
function love.filesystem.read(name: string, size?: number)
  -> contents: string
  2. size: number
  3. contents: nil
  4. error: string
```


---

# love.filesystem.remove


```lua
function love.filesystem.remove(name: string)
  -> success: boolean
```


---

# love.filesystem.setCRequirePath


```lua
function love.filesystem.setCRequirePath(paths: string)
```


---

# love.filesystem.setIdentity


```lua
function love.filesystem.setIdentity(name: string)
```


---

# love.filesystem.setRequirePath


```lua
function love.filesystem.setRequirePath(paths: string)
```


---

# love.filesystem.setSource


```lua
function love.filesystem.setSource(path: string)
```


---

# love.filesystem.setSymlinksEnabled


```lua
function love.filesystem.setSymlinksEnabled(enable: boolean)
```


---

# love.filesystem.unmount


```lua
function love.filesystem.unmount(archive: string)
  -> success: boolean
```


---

# love.filesystem.write


```lua
function love.filesystem.write(name: string, data: string, size?: number)
  -> success: boolean
  2. message: string
```


---

# love.focus


---

# love.font

## newBMFontRasterizer


```lua
function love.font.newBMFontRasterizer(imageData: love.ImageData, glyphs: string, dpiscale?: number)
  -> rasterizer: love.Rasterizer
```


Creates a new BMFont Rasterizer.


[Open in Browser](https://love2d.org/wiki/love.font.newBMFontRasterizer)


---

@*param* `imageData` — The image data containing the drawable pictures of font glyphs.

@*param* `glyphs` — The sequence of glyphs in the ImageData.

@*param* `dpiscale` — DPI scale.

@*return* `rasterizer` — The rasterizer.

## newGlyphData


```lua
function love.font.newGlyphData(rasterizer: love.Rasterizer, glyph: number)
```


Creates a new GlyphData.


[Open in Browser](https://love2d.org/wiki/love.font.newGlyphData)

@*param* `rasterizer` — The Rasterizer containing the font.

@*param* `glyph` — The character code of the glyph.

## newImageRasterizer


```lua
function love.font.newImageRasterizer(imageData: love.ImageData, glyphs: string, extraSpacing?: number, dpiscale?: number)
  -> rasterizer: love.Rasterizer
```


Creates a new Image Rasterizer.


[Open in Browser](https://love2d.org/wiki/love.font.newImageRasterizer)

@*param* `imageData` — Font image data.

@*param* `glyphs` — String containing font glyphs.

@*param* `extraSpacing` — Font extra spacing.

@*param* `dpiscale` — Font DPI scale.

@*return* `rasterizer` — The rasterizer.

## newRasterizer


```lua
function love.font.newRasterizer(filename: string)
  -> rasterizer: love.Rasterizer
```


Creates a new Rasterizer.


[Open in Browser](https://love2d.org/wiki/love.font.newRasterizer)


---

@*param* `filename` — The font file.

@*return* `rasterizer` — The rasterizer.

## newTrueTypeRasterizer


```lua
function love.font.newTrueTypeRasterizer(size?: number, hinting?: "light"|"mono"|"none"|"normal", dpiscale?: number)
  -> rasterizer: love.Rasterizer
```


Creates a new TrueType Rasterizer.


[Open in Browser](https://love2d.org/wiki/love.font.newTrueTypeRasterizer)


---

@*param* `size` — The font size.

@*param* `hinting` — True Type hinting mode.

@*param* `dpiscale` — The font DPI scale.

@*return* `rasterizer` — The rasterizer.

```lua
-- 
-- True Type hinting mode.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/HintingMode)
-- 
hinting:
    | "normal" -- Default hinting. Should be preferred for typical antialiased fonts.
    | "light" -- Results in fuzzier text but can sometimes preserve the original glyph shapes of the text better than normal hinting.
    | "mono" -- Results in aliased / unsmoothed text with either full opacity or completely transparent pixels. Should be used when antialiasing is not desired for the font.
    | "none" -- Disables hinting for the font. Results in fuzzier text.
```


---

# love.font


```lua
love.font
```


---

# love.font.newBMFontRasterizer


```lua
function love.font.newBMFontRasterizer(imageData: love.ImageData, glyphs: string, dpiscale?: number)
  -> rasterizer: love.Rasterizer
```


---

# love.font.newGlyphData


```lua
function love.font.newGlyphData(rasterizer: love.Rasterizer, glyph: number)
```


---

# love.font.newImageRasterizer


```lua
function love.font.newImageRasterizer(imageData: love.ImageData, glyphs: string, extraSpacing?: number, dpiscale?: number)
  -> rasterizer: love.Rasterizer
```


---

# love.font.newRasterizer


```lua
function love.font.newRasterizer(filename: string)
  -> rasterizer: love.Rasterizer
```


---

# love.font.newTrueTypeRasterizer


```lua
function love.font.newTrueTypeRasterizer(size?: number, hinting?: "light"|"mono"|"none"|"normal", dpiscale?: number)
  -> rasterizer: love.Rasterizer
```


---

# love.gamepadaxis


---

# love.gamepadpressed


---

# love.gamepadreleased


---

# love.getVersion


```lua
function love.getVersion()
  -> major: number
  2. minor: number
  3. revision: number
  4. codename: string
```


---

# love.graphics

## applyTransform


```lua
function love.graphics.applyTransform(transform: love.Transform)
```


Applies the given Transform object to the current coordinate transformation.

This effectively multiplies the existing coordinate transformation's matrix with the Transform object's internal matrix to produce the new coordinate transformation.


[Open in Browser](https://love2d.org/wiki/love.graphics.applyTransform)

@*param* `transform` — The Transform object to apply to the current graphics coordinate transform.

## arc


```lua
function love.graphics.arc(drawmode: "fill"|"line", x: number, y: number, radius: number, angle1: number, angle2: number, segments?: number)
```


Draws a filled or unfilled arc at position (x, y). The arc is drawn from angle1 to angle2 in radians. The segments parameter determines how many segments are used to draw the arc. The more segments, the smoother the edge.


[Open in Browser](https://love2d.org/wiki/love.graphics.arc)


---

@*param* `drawmode` — How to draw the arc.

@*param* `x` — The position of the center along x-axis.

@*param* `y` — The position of the center along y-axis.

@*param* `radius` — Radius of the arc.

@*param* `angle1` — The angle at which the arc begins.

@*param* `angle2` — The angle at which the arc terminates.

@*param* `segments` — The number of segments used for drawing the arc.

```lua
-- 
-- Controls whether shapes are drawn as an outline, or filled.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/DrawMode)
-- 
drawmode:
    | "fill" -- Draw filled shape.
    | "line" -- Draw outlined shape.
```

## captureScreenshot


```lua
function love.graphics.captureScreenshot(filename: string)
```


Creates a screenshot once the current frame is done (after love.draw has finished).

Since this function enqueues a screenshot capture rather than executing it immediately, it can be called from an input callback or love.update and it will still capture all of what's drawn to the screen in that frame.


[Open in Browser](https://love2d.org/wiki/love.graphics.captureScreenshot)


---

@*param* `filename` — The filename to save the screenshot to. The encoded image type is determined based on the extension of the filename, and must be one of the ImageFormats.

## circle


```lua
function love.graphics.circle(mode: "fill"|"line", x: number, y: number, radius: number)
```


Draws a circle.


[Open in Browser](https://love2d.org/wiki/love.graphics.circle)


---

@*param* `mode` — How to draw the circle.

@*param* `x` — The position of the center along x-axis.

@*param* `y` — The position of the center along y-axis.

@*param* `radius` — The radius of the circle.

```lua
-- 
-- Controls whether shapes are drawn as an outline, or filled.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/DrawMode)
-- 
mode:
    | "fill" -- Draw filled shape.
    | "line" -- Draw outlined shape.
```

## clear


```lua
function love.graphics.clear()
```


Clears the screen or active Canvas to the specified color.

This function is called automatically before love.draw in the default love.run function. See the example in love.run for a typical use of this function.

Note that the scissor area bounds the cleared region.

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.

In versions prior to background color instead.


[Open in Browser](https://love2d.org/wiki/love.graphics.clear)

## discard


```lua
function love.graphics.discard(discardcolor?: boolean, discardstencil?: boolean)
```


Discards (trashes) the contents of the screen or active Canvas. This is a performance optimization function with niche use cases.

If the active Canvas has just been changed and the 'replace' BlendMode is about to be used to draw something which covers the entire screen, calling love.graphics.discard rather than calling love.graphics.clear or doing nothing may improve performance on mobile devices.

On some desktop systems this function may do nothing.


[Open in Browser](https://love2d.org/wiki/love.graphics.discard)


---

@*param* `discardcolor` — Whether to discard the texture(s) of the active Canvas(es) (the contents of the screen if no Canvas is active.)

@*param* `discardstencil` — Whether to discard the contents of the stencil buffer of the screen / active Canvas.

## draw


```lua
function love.graphics.draw(drawable: love.Drawable, x?: number, y?: number, r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
```


Draws a Drawable object (an Image, Canvas, SpriteBatch, ParticleSystem, Mesh, Text object, or Video) on the screen with optional rotation, scaling and shearing.

Objects are drawn relative to their local coordinate system. The origin is by default located at the top left corner of Image and Canvas. All scaling, shearing, and rotation arguments transform the object relative to that point. Also, the position of the origin can be specified on the screen coordinate system.

It's possible to rotate an object about its center by offsetting the origin to the center. Angles must be given in radians for rotation. One can also use a negative scaling factor to flip about its centerline.

Note that the offsets are applied before rotation, scaling, or shearing; scaling and shearing are applied before rotation.

The right and bottom edges of the object are shifted at an angle defined by the shearing factors.

When using the default shader anything drawn with this function will be tinted according to the currently selected color.

Set it to pure white to preserve the object's original colors.


[Open in Browser](https://love2d.org/wiki/love.graphics.draw)


---

@*param* `drawable` — A drawable object.

@*param* `x` — The position to draw the object (x-axis).

@*param* `y` — The position to draw the object (y-axis).

@*param* `r` — Orientation (radians).

@*param* `sx` — Scale factor (x-axis).

@*param* `sy` — Scale factor (y-axis).

@*param* `ox` — Origin offset (x-axis).

@*param* `oy` — Origin offset (y-axis).

@*param* `kx` — Shearing factor (x-axis).

@*param* `ky` — Shearing factor (y-axis).

## drawInstanced


```lua
function love.graphics.drawInstanced(mesh: love.Mesh, instancecount: number, x?: number, y?: number, r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
```


Draws many instances of a Mesh with a single draw call, using hardware geometry instancing.

Each instance can have unique properties (positions, colors, etc.) but will not by default unless a custom per-instance vertex attributes or the love_InstanceID GLSL 3 vertex shader variable is used, otherwise they will all render at the same position on top of each other.

Instancing is not supported by some older GPUs that are only capable of using OpenGL ES 2 or OpenGL 2. Use love.graphics.getSupported to check.


[Open in Browser](https://love2d.org/wiki/love.graphics.drawInstanced)


---

@*param* `mesh` — The mesh to render.

@*param* `instancecount` — The number of instances to render.

@*param* `x` — The position to draw the instances (x-axis).

@*param* `y` — The position to draw the instances (y-axis).

@*param* `r` — Orientation (radians).

@*param* `sx` — Scale factor (x-axis).

@*param* `sy` — Scale factor (y-axis).

@*param* `ox` — Origin offset (x-axis).

@*param* `oy` — Origin offset (y-axis).

@*param* `kx` — Shearing factor (x-axis).

@*param* `ky` — Shearing factor (y-axis).

## drawLayer


```lua
function love.graphics.drawLayer(texture: love.Texture, layerindex: number, x?: number, y?: number, r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
```


Draws a layer of an Array Texture.


[Open in Browser](https://love2d.org/wiki/love.graphics.drawLayer)


---

@*param* `texture` — The Array Texture to draw.

@*param* `layerindex` — The index of the layer to use when drawing.

@*param* `x` — The position to draw the texture (x-axis).

@*param* `y` — The position to draw the texture (y-axis).

@*param* `r` — Orientation (radians).

@*param* `sx` — Scale factor (x-axis).

@*param* `sy` — Scale factor (y-axis).

@*param* `ox` — Origin offset (x-axis).

@*param* `oy` — Origin offset (y-axis).

@*param* `kx` — Shearing factor (x-axis).

@*param* `ky` — Shearing factor (y-axis).

## ellipse


```lua
function love.graphics.ellipse(mode: "fill"|"line", x: number, y: number, radiusx: number, radiusy: number)
```


Draws an ellipse.


[Open in Browser](https://love2d.org/wiki/love.graphics.ellipse)


---

@*param* `mode` — How to draw the ellipse.

@*param* `x` — The position of the center along x-axis.

@*param* `y` — The position of the center along y-axis.

@*param* `radiusx` — The radius of the ellipse along the x-axis (half the ellipse's width).

@*param* `radiusy` — The radius of the ellipse along the y-axis (half the ellipse's height).

```lua
-- 
-- Controls whether shapes are drawn as an outline, or filled.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/DrawMode)
-- 
mode:
    | "fill" -- Draw filled shape.
    | "line" -- Draw outlined shape.
```

## flushBatch


```lua
function love.graphics.flushBatch()
```


Immediately renders any pending automatically batched draws.

LÖVE will call this function internally as needed when most state is changed, so it is not necessary to manually call it.

The current batch will be automatically flushed by love.graphics state changes (except for the transform stack and the current color), as well as Shader:send and methods on Textures which change their state. Using a different Image in consecutive love.graphics.draw calls will also flush the current batch.

SpriteBatches, ParticleSystems, Meshes, and Text objects do their own batching and do not affect automatic batching of other draws, aside from flushing the current batch when they're drawn.


[Open in Browser](https://love2d.org/wiki/love.graphics.flushBatch)

## getBackgroundColor


```lua
function love.graphics.getBackgroundColor()
  -> r: number
  2. g: number
  3. b: number
  4. a: number
```


Gets the current background color.

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/love.graphics.getBackgroundColor)

@*return* `r` — The red component (0-1).

@*return* `g` — The green component (0-1).

@*return* `b` — The blue component (0-1).

@*return* `a` — The alpha component (0-1).

## getBlendMode


```lua
function love.graphics.getBlendMode()
  -> mode: "add"|"additive"|"alpha"|"darken"|"lighten"...(+7)
  2. alphamode: "alphamultiply"|"premultiplied"
```


Gets the blending mode.


[Open in Browser](https://love2d.org/wiki/love.graphics.getBlendMode)

@*return* `mode` — The current blend mode.

@*return* `alphamode` — The current blend alpha mode – it determines how the alpha of drawn objects affects blending.

```lua
-- 
-- Different ways to do color blending. See BlendAlphaMode and the BlendMode Formulas for additional notes.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/BlendMode)
-- 
mode:
    | "alpha" -- Alpha blending (normal). The alpha of what's drawn determines its opacity.
    | "replace" -- The colors of what's drawn completely replace what was on the screen, with no additional blending. The BlendAlphaMode specified in love.graphics.setBlendMode still affects what happens.
    | "screen" -- 'Screen' blending.
    | "add" -- The pixel colors of what's drawn are added to the pixel colors already on the screen. The alpha of the screen is not modified.
    | "subtract" -- The pixel colors of what's drawn are subtracted from the pixel colors already on the screen. The alpha of the screen is not modified.
    | "multiply" -- The pixel colors of what's drawn are multiplied with the pixel colors already on the screen (darkening them). The alpha of drawn objects is multiplied with the alpha of the screen rather than determining how much the colors on the screen are affected, even when the "alphamultiply" BlendAlphaMode is used.
    | "lighten" -- The pixel colors of what's drawn are compared to the existing pixel colors, and the larger of the two values for each color component is used. Only works when the "premultiplied" BlendAlphaMode is used in love.graphics.setBlendMode.
    | "darken" -- The pixel colors of what's drawn are compared to the existing pixel colors, and the smaller of the two values for each color component is used. Only works when the "premultiplied" BlendAlphaMode is used in love.graphics.setBlendMode.
    | "additive" -- Additive blend mode.
    | "subtractive" -- Subtractive blend mode.
    | "multiplicative" -- Multiply blend mode.
    | "premultiplied" -- Premultiplied alpha blend mode.

-- 
-- Different ways alpha affects color blending. See BlendMode and the BlendMode Formulas for additional notes.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/BlendAlphaMode)
-- 
alphamode:
    | "alphamultiply" -- The RGB values of what's drawn are multiplied by the alpha values of those colors during blending. This is the default alpha mode.
    | "premultiplied" -- The RGB values of what's drawn are '''not''' multiplied by the alpha values of those colors during blending. For most blend modes to work correctly with this alpha mode, the colors of a drawn object need to have had their RGB values multiplied by their alpha values at some point previously ("premultiplied alpha").
```

## getCanvas


```lua
function love.graphics.getCanvas()
  -> canvas: love.Canvas
```


Gets the current target Canvas.


[Open in Browser](https://love2d.org/wiki/love.graphics.getCanvas)

@*return* `canvas` — The Canvas set by setCanvas. Returns nil if drawing to the real screen.

## getCanvasFormats


```lua
function love.graphics.getCanvasFormats()
  -> formats: table
```


Gets the available Canvas formats, and whether each is supported.


[Open in Browser](https://love2d.org/wiki/love.graphics.getCanvasFormats)


---

@*return* `formats` — A table containing CanvasFormats as keys, and a boolean indicating whether the format is supported as values. Not all systems support all formats.

## getColor


```lua
function love.graphics.getColor()
  -> r: number
  2. g: number
  3. b: number
  4. a: number
```


Gets the current color.

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/love.graphics.getColor)

@*return* `r` — The red component (0-1).

@*return* `g` — The green component (0-1).

@*return* `b` — The blue component (0-1).

@*return* `a` — The alpha component (0-1).

## getColorMask


```lua
function love.graphics.getColorMask()
  -> r: boolean
  2. g: boolean
  3. b: boolean
  4. a: boolean
```


Gets the active color components used when drawing. Normally all 4 components are active unless love.graphics.setColorMask has been used.

The color mask determines whether individual components of the colors of drawn objects will affect the color of the screen. They affect love.graphics.clear and Canvas:clear as well.


[Open in Browser](https://love2d.org/wiki/love.graphics.getColorMask)

@*return* `r` — Whether the red color component is active when rendering.

@*return* `g` — Whether the green color component is active when rendering.

@*return* `b` — Whether the blue color component is active when rendering.

@*return* `a` — Whether the alpha color component is active when rendering.

## getDPIScale


```lua
function love.graphics.getDPIScale()
  -> scale: number
```


Gets the DPI scale factor of the window.

The DPI scale factor represents relative pixel density. The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.graphics.getDPIScale() would return 2 in that case.

The love.window.fromPixels and love.window.toPixels functions can also be used to convert between units.

The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.


[Open in Browser](https://love2d.org/wiki/love.graphics.getDPIScale)

@*return* `scale` — The pixel scale factor associated with the window.

## getDefaultFilter


```lua
function love.graphics.getDefaultFilter()
  -> min: "linear"|"nearest"
  2. mag: "linear"|"nearest"
  3. anisotropy: number
```


Returns the default scaling filters used with Images, Canvases, and Fonts.


[Open in Browser](https://love2d.org/wiki/love.graphics.getDefaultFilter)

@*return* `min` — Filter mode used when scaling the image down.

@*return* `mag` — Filter mode used when scaling the image up.

@*return* `anisotropy` — Maximum amount of Anisotropic Filtering used.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
min:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.

-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mag:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## getDepthMode


```lua
function love.graphics.getDepthMode()
  -> comparemode: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3)
  2. write: boolean
```


Gets the current depth test mode and whether writing to the depth buffer is enabled.

This is low-level functionality designed for use with custom vertex shaders and Meshes with custom vertex attributes. No higher level APIs are provided to set the depth of 2D graphics such as shapes, lines, and Images.


[Open in Browser](https://love2d.org/wiki/love.graphics.getDepthMode)

@*return* `comparemode` — Depth comparison mode used for depth testing.

@*return* `write` — Whether to write update / write values to the depth buffer when rendering.

```lua
-- 
-- Different types of per-pixel stencil test and depth test comparisons. The pixels of an object will be drawn if the comparison succeeds, for each pixel that the object touches.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CompareMode)
-- 
comparemode:
    | "equal" -- * stencil tests: the stencil value of the pixel must be equal to the supplied value.
              -- * depth tests: the depth value of the drawn object at that pixel must be equal to the existing depth value of that pixel.
    | "notequal" -- * stencil tests: the stencil value of the pixel must not be equal to the supplied value.
                 -- * depth tests: the depth value of the drawn object at that pixel must not be equal to the existing depth value of that pixel.
    | "less" -- * stencil tests: the stencil value of the pixel must be less than the supplied value.
             -- * depth tests: the depth value of the drawn object at that pixel must be less than the existing depth value of that pixel.
    | "lequal" -- * stencil tests: the stencil value of the pixel must be less than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be less than or equal to the existing depth value of that pixel.
    | "gequal" -- * stencil tests: the stencil value of the pixel must be greater than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be greater than or equal to the existing depth value of that pixel.
    | "greater" -- * stencil tests: the stencil value of the pixel must be greater than the supplied value.
                -- * depth tests: the depth value of the drawn object at that pixel must be greater than the existing depth value of that pixel.
    | "never" -- Objects will never be drawn.
    | "always" -- Objects will always be drawn. Effectively disables the depth or stencil test.
```

## getDimensions


```lua
function love.graphics.getDimensions()
  -> width: number
  2. height: number
```


Gets the width and height in pixels of the window.


[Open in Browser](https://love2d.org/wiki/love.graphics.getDimensions)

@*return* `width` — The width of the window.

@*return* `height` — The height of the window.

## getFont


```lua
function love.graphics.getFont()
  -> font: love.Font
```


Gets the current Font object.


[Open in Browser](https://love2d.org/wiki/love.graphics.getFont)

@*return* `font` — The current Font. Automatically creates and sets the default font, if none is set yet.

## getFrontFaceWinding


```lua
function love.graphics.getFrontFaceWinding()
  -> winding: "ccw"|"cw"
```


Gets whether triangles with clockwise- or counterclockwise-ordered vertices are considered front-facing.

This is designed for use in combination with Mesh face culling. Other love.graphics shapes, lines, and sprites are not guaranteed to have a specific winding order to their internal vertices.


[Open in Browser](https://love2d.org/wiki/love.graphics.getFrontFaceWinding)

@*return* `winding` — The winding mode being used. The default winding is counterclockwise ('ccw').

```lua
-- 
-- How Mesh geometry vertices are ordered.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/VertexWinding)
-- 
winding:
    | "cw" -- Clockwise.
    | "ccw" -- Counter-clockwise.
```

## getHeight


```lua
function love.graphics.getHeight()
  -> height: number
```


Gets the height in pixels of the window.


[Open in Browser](https://love2d.org/wiki/love.graphics.getHeight)

@*return* `height` — The height of the window.

## getImageFormats


```lua
function love.graphics.getImageFormats()
  -> formats: table
```


Gets the raw and compressed pixel formats usable for Images, and whether each is supported.


[Open in Browser](https://love2d.org/wiki/love.graphics.getImageFormats)

@*return* `formats` — A table containing PixelFormats as keys, and a boolean indicating whether the format is supported as values. Not all systems support all formats.

## getLineJoin


```lua
function love.graphics.getLineJoin()
  -> join: "bevel"|"miter"|"none"
```


Gets the line join style.


[Open in Browser](https://love2d.org/wiki/love.graphics.getLineJoin)

@*return* `join` — The LineJoin style.

```lua
-- 
-- Line join style.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/LineJoin)
-- 
join:
    | "miter" -- The ends of the line segments beveled in an angle so that they join seamlessly.
    | "none" -- No cap applied to the ends of the line segments.
    | "bevel" -- Flattens the point where line segments join together.
```

## getLineStyle


```lua
function love.graphics.getLineStyle()
  -> style: "rough"|"smooth"
```


Gets the line style.


[Open in Browser](https://love2d.org/wiki/love.graphics.getLineStyle)

@*return* `style` — The current line style.

```lua
-- 
-- The styles in which lines are drawn.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/LineStyle)
-- 
style:
    | "rough" -- Draw rough lines.
    | "smooth" -- Draw smooth lines.
```

## getLineWidth


```lua
function love.graphics.getLineWidth()
  -> width: number
```


Gets the current line width.


[Open in Browser](https://love2d.org/wiki/love.graphics.getLineWidth)

@*return* `width` — The current line width.

## getMeshCullMode


```lua
function love.graphics.getMeshCullMode()
  -> mode: "back"|"front"|"none"
```


Gets whether back-facing triangles in a Mesh are culled.

Mesh face culling is designed for use with low level custom hardware-accelerated 3D rendering via custom vertex attributes on Meshes, custom vertex shaders, and depth testing with a depth buffer.


[Open in Browser](https://love2d.org/wiki/love.graphics.getMeshCullMode)

@*return* `mode` — The Mesh face culling mode in use (whether to render everything, cull back-facing triangles, or cull front-facing triangles).

```lua
-- 
-- How Mesh geometry is culled when rendering.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CullMode)
-- 
mode:
    | "back" -- Back-facing triangles in Meshes are culled (not rendered). The vertex order of a triangle determines whether it is back- or front-facing.
    | "front" -- Front-facing triangles in Meshes are culled.
    | "none" -- Both back- and front-facing triangles in Meshes are rendered.
```

## getPixelDimensions


```lua
function love.graphics.getPixelDimensions()
  -> pixelwidth: number
  2. pixelheight: number
```


Gets the width and height in pixels of the window.

love.graphics.getDimensions gets the dimensions of the window in units scaled by the screen's DPI scale factor, rather than pixels. Use getDimensions for calculations related to drawing to the screen and using the graphics coordinate system (calculating the center of the screen, for example), and getPixelDimensions only when dealing specifically with underlying pixels (pixel-related calculations in a pixel Shader, for example).


[Open in Browser](https://love2d.org/wiki/love.graphics.getPixelDimensions)

@*return* `pixelwidth` — The width of the window in pixels.

@*return* `pixelheight` — The height of the window in pixels.

## getPixelHeight


```lua
function love.graphics.getPixelHeight()
  -> pixelheight: number
```


Gets the height in pixels of the window.

The graphics coordinate system and DPI scale factor, rather than raw pixels. Use getHeight for calculations related to drawing to the screen and using the coordinate system (calculating the center of the screen, for example), and getPixelHeight only when dealing specifically with underlying pixels (pixel-related calculations in a pixel Shader, for example).


[Open in Browser](https://love2d.org/wiki/love.graphics.getPixelHeight)

@*return* `pixelheight` — The height of the window in pixels.

## getPixelWidth


```lua
function love.graphics.getPixelWidth()
  -> pixelwidth: number
```


Gets the width in pixels of the window.

The graphics coordinate system and DPI scale factor, rather than raw pixels. Use getWidth for calculations related to drawing to the screen and using the coordinate system (calculating the center of the screen, for example), and getPixelWidth only when dealing specifically with underlying pixels (pixel-related calculations in a pixel Shader, for example).


[Open in Browser](https://love2d.org/wiki/love.graphics.getPixelWidth)

@*return* `pixelwidth` — The width of the window in pixels.

## getPointSize


```lua
function love.graphics.getPointSize()
  -> size: number
```


Gets the point size.


[Open in Browser](https://love2d.org/wiki/love.graphics.getPointSize)

@*return* `size` — The current point size.

## getRendererInfo


```lua
function love.graphics.getRendererInfo()
  -> name: string
  2. version: string
  3. vendor: string
  4. device: string
```


Gets information about the system's video card and drivers.


[Open in Browser](https://love2d.org/wiki/love.graphics.getRendererInfo)

@*return* `name` — The name of the renderer, e.g. 'OpenGL' or 'OpenGL ES'.

@*return* `version` — The version of the renderer with some extra driver-dependent version info, e.g. '2.1 INTEL-8.10.44'.

@*return* `vendor` — The name of the graphics card vendor, e.g. 'Intel Inc'.

@*return* `device` — The name of the graphics card, e.g. 'Intel HD Graphics 3000 OpenGL Engine'.

## getScissor


```lua
function love.graphics.getScissor()
  -> x: number
  2. y: number
  3. width: number
  4. height: number
```


Gets the current scissor box.


[Open in Browser](https://love2d.org/wiki/love.graphics.getScissor)

@*return* `x` — The x-component of the top-left point of the box.

@*return* `y` — The y-component of the top-left point of the box.

@*return* `width` — The width of the box.

@*return* `height` — The height of the box.

## getShader


```lua
function love.graphics.getShader()
  -> shader: love.Shader
```


Gets the current Shader. Returns nil if none is set.


[Open in Browser](https://love2d.org/wiki/love.graphics.getShader)

@*return* `shader` — The currently active Shader, or nil if none is set.

## getStackDepth


```lua
function love.graphics.getStackDepth()
  -> depth: number
```


Gets the current depth of the transform / state stack (the number of pushes without corresponding pops).


[Open in Browser](https://love2d.org/wiki/love.graphics.getStackDepth)

@*return* `depth` — The current depth of the transform and state love.graphics stack.

## getStats


```lua
function love.graphics.getStats()
  -> stats: { drawcalls: number, canvasswitches: number, texturememory: number, images: number, canvases: number, fonts: number, shaderswitches: number, drawcallsbatched: number }
```


Gets performance-related rendering statistics.


[Open in Browser](https://love2d.org/wiki/love.graphics.getStats)


---

@*return* `stats` — A table with the following fields:

## getStencilTest


```lua
function love.graphics.getStencilTest()
  -> comparemode: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3)
  2. comparevalue: number
```


Gets the current stencil test configuration.

When stencil testing is enabled, the geometry of everything that is drawn afterward will be clipped / stencilled out based on a comparison between the arguments of this function and the stencil value of each pixel that the geometry touches. The stencil values of pixels are affected via love.graphics.stencil.

Each Canvas has its own per-pixel stencil values.


[Open in Browser](https://love2d.org/wiki/love.graphics.getStencilTest)

@*return* `comparemode` — The type of comparison that is made for each pixel. Will be 'always' if stencil testing is disabled.

@*return* `comparevalue` — The value used when comparing with the stencil value of each pixel.

```lua
-- 
-- Different types of per-pixel stencil test and depth test comparisons. The pixels of an object will be drawn if the comparison succeeds, for each pixel that the object touches.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CompareMode)
-- 
comparemode:
    | "equal" -- * stencil tests: the stencil value of the pixel must be equal to the supplied value.
              -- * depth tests: the depth value of the drawn object at that pixel must be equal to the existing depth value of that pixel.
    | "notequal" -- * stencil tests: the stencil value of the pixel must not be equal to the supplied value.
                 -- * depth tests: the depth value of the drawn object at that pixel must not be equal to the existing depth value of that pixel.
    | "less" -- * stencil tests: the stencil value of the pixel must be less than the supplied value.
             -- * depth tests: the depth value of the drawn object at that pixel must be less than the existing depth value of that pixel.
    | "lequal" -- * stencil tests: the stencil value of the pixel must be less than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be less than or equal to the existing depth value of that pixel.
    | "gequal" -- * stencil tests: the stencil value of the pixel must be greater than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be greater than or equal to the existing depth value of that pixel.
    | "greater" -- * stencil tests: the stencil value of the pixel must be greater than the supplied value.
                -- * depth tests: the depth value of the drawn object at that pixel must be greater than the existing depth value of that pixel.
    | "never" -- Objects will never be drawn.
    | "always" -- Objects will always be drawn. Effectively disables the depth or stencil test.
```

## getSupported


```lua
function love.graphics.getSupported()
  -> features: table
```


Gets the optional graphics features and whether they're supported on the system.

Some older or low-end systems don't always support all graphics features.


[Open in Browser](https://love2d.org/wiki/love.graphics.getSupported)

@*return* `features` — A table containing GraphicsFeature keys, and boolean values indicating whether each feature is supported.

## getSystemLimits


```lua
function love.graphics.getSystemLimits()
  -> limits: table
```


Gets the system-dependent maximum values for love.graphics features.


[Open in Browser](https://love2d.org/wiki/love.graphics.getSystemLimits)

@*return* `limits` — A table containing GraphicsLimit keys, and number values.

## getTextureTypes


```lua
function love.graphics.getTextureTypes()
  -> texturetypes: table
```


Gets the available texture types, and whether each is supported.


[Open in Browser](https://love2d.org/wiki/love.graphics.getTextureTypes)

@*return* `texturetypes` — A table containing TextureTypes as keys, and a boolean indicating whether the type is supported as values. Not all systems support all types.

## getWidth


```lua
function love.graphics.getWidth()
  -> width: number
```


Gets the width in pixels of the window.


[Open in Browser](https://love2d.org/wiki/love.graphics.getWidth)

@*return* `width` — The width of the window.

## intersectScissor


```lua
function love.graphics.intersectScissor(x: number, y: number, width: number, height: number)
```


Sets the scissor to the rectangle created by the intersection of the specified rectangle with the existing scissor.

If no scissor is active yet, it behaves like love.graphics.setScissor.

The scissor limits the drawing area to a specified rectangle. This affects all graphics calls, including love.graphics.clear.

The dimensions of the scissor is unaffected by graphical transformations (translate, scale, ...).


[Open in Browser](https://love2d.org/wiki/love.graphics.intersectScissor)

@*param* `x` — The x-coordinate of the upper left corner of the rectangle to intersect with the existing scissor rectangle.

@*param* `y` — The y-coordinate of the upper left corner of the rectangle to intersect with the existing scissor rectangle.

@*param* `width` — The width of the rectangle to intersect with the existing scissor rectangle.

@*param* `height` — The height of the rectangle to intersect with the existing scissor rectangle.

## inverseTransformPoint


```lua
function love.graphics.inverseTransformPoint(screenX: number, screenY: number)
  -> globalX: number
  2. globalY: number
```


Converts the given 2D position from screen-space into global coordinates.

This effectively applies the reverse of the current graphics transformations to the given position. A similar Transform:inverseTransformPoint method exists for Transform objects.


[Open in Browser](https://love2d.org/wiki/love.graphics.inverseTransformPoint)

@*param* `screenX` — The x component of the screen-space position.

@*param* `screenY` — The y component of the screen-space position.

@*return* `globalX` — The x component of the position in global coordinates.

@*return* `globalY` — The y component of the position in global coordinates.

## isActive


```lua
function love.graphics.isActive()
  -> active: boolean
```


Gets whether the graphics module is able to be used. If it is not active, love.graphics function and method calls will not work correctly and may cause the program to crash.
The graphics module is inactive if a window is not open, or if the app is in the background on iOS. Typically the app's execution will be automatically paused by the system, in the latter case.


[Open in Browser](https://love2d.org/wiki/love.graphics.isActive)

@*return* `active` — Whether the graphics module is active and able to be used.

## isGammaCorrect


```lua
function love.graphics.isGammaCorrect()
  -> gammacorrect: boolean
```


Gets whether gamma-correct rendering is supported and enabled. It can be enabled by setting t.gammacorrect = true in love.conf.

Not all devices support gamma-correct rendering, in which case it will be automatically disabled and this function will return false. It is supported on desktop systems which have graphics cards that are capable of using OpenGL 3 / DirectX 10, and iOS devices that can use OpenGL ES 3.


[Open in Browser](https://love2d.org/wiki/love.graphics.isGammaCorrect)

@*return* `gammacorrect` — True if gamma-correct rendering is supported and was enabled in love.conf, false otherwise.

## isWireframe


```lua
function love.graphics.isWireframe()
  -> wireframe: boolean
```


Gets whether wireframe mode is used when drawing.


[Open in Browser](https://love2d.org/wiki/love.graphics.isWireframe)

@*return* `wireframe` — True if wireframe lines are used when drawing, false if it's not.

## line


```lua
function love.graphics.line(x1: number, y1: number, x2: number, y2: number, ...number)
```


Draws lines between points.


[Open in Browser](https://love2d.org/wiki/love.graphics.line)


---

@*param* `x1` — The position of first point on the x-axis.

@*param* `y1` — The position of first point on the y-axis.

@*param* `x2` — The position of second point on the x-axis.

@*param* `y2` — The position of second point on the y-axis.

## newArrayImage


```lua
function love.graphics.newArrayImage(slices: table, settings?: { mipmaps: boolean, linear: boolean, dpiscale: number })
  -> image: love.Image
```


Creates a new array Image.

An array image / array texture is a single object which contains multiple 'layers' or 'slices' of 2D sub-images. It can be thought of similarly to a texture atlas or sprite sheet, but it doesn't suffer from the same tile / quad bleeding artifacts that texture atlases do – although every sub-image must have the same dimensions.

A specific layer of an array image can be drawn with love.graphics.drawLayer / SpriteBatch:addLayer, or with the Quad variant of love.graphics.draw and Quad:setLayer, or via a custom Shader.

To use an array image in a Shader, it must be declared as a ArrayImage or sampler2DArray type (instead of Image or sampler2D). The Texel(ArrayImage image, vec3 texturecoord) shader function must be used to get pixel colors from a slice of the array image. The vec3 argument contains the texture coordinate in the first two components, and the 0-based slice index in the third component.


[Open in Browser](https://love2d.org/wiki/love.graphics.newArrayImage)

@*param* `slices` — A table containing filepaths to images (or File, FileData, ImageData, or CompressedImageData objects), in an array. Each sub-image must have the same dimensions. A table of tables can also be given, where each sub-table contains all mipmap levels for the slice index of that sub-table.

@*param* `settings` — Optional table of settings to configure the array image, containing the following fields:

@*return* `image` — An Array Image object.

## newCanvas


```lua
function love.graphics.newCanvas()
  -> canvas: love.Canvas
```


Creates a new Canvas object for offscreen rendering.


[Open in Browser](https://love2d.org/wiki/love.graphics.newCanvas)


---

@*return* `canvas` — A new Canvas with dimensions equal to the window's size in pixels.

## newCubeImage


```lua
function love.graphics.newCubeImage(filename: string, settings?: { mipmaps: boolean, linear: boolean })
  -> image: love.Image
```


Creates a new cubemap Image.

Cubemap images have 6 faces (sides) which represent a cube. They can't be rendered directly, they can only be used in Shader code (and sent to the shader via Shader:send).

To use a cubemap image in a Shader, it must be declared as a CubeImage or samplerCube type (instead of Image or sampler2D). The Texel(CubeImage image, vec3 direction) shader function must be used to get pixel colors from the cubemap. The vec3 argument is a normalized direction from the center of the cube, rather than explicit texture coordinates.

Each face in a cubemap image must have square dimensions.

For variants of this function which accept a single image containing multiple cubemap faces, they must be laid out in one of the following forms in the image:

   +y

+z +x -z

   -y

   -x

or:

   +y

-x +z +x -z

   -y

or:

+x

-x

+y

-y

+z

-z

or:

+x -x +y -y +z -z


[Open in Browser](https://love2d.org/wiki/love.graphics.newCubeImage)


---

@*param* `filename` — The filepath to a cubemap image file (or a File, FileData, or ImageData).

@*param* `settings` — Optional table of settings to configure the cubemap image, containing the following fields:

@*return* `image` — An cubemap Image object.

## newFont


```lua
function love.graphics.newFont(filename: string)
  -> font: love.Font
```


Creates a new Font from a TrueType Font or BMFont file. Created fonts are not cached, in that calling this function with the same arguments will always create a new Font object.

All variants which accept a filename can also accept a Data object instead.


[Open in Browser](https://love2d.org/wiki/love.graphics.newFont)


---

@*param* `filename` — The filepath to the BMFont or TrueType font file.

@*return* `font` — A Font object which can be used to draw text on screen.

## newImage


```lua
function love.graphics.newImage(filename: string, settings?: { dpiscale: number, linear: boolean, mipmaps: boolean })
  -> image: love.Image
```


Creates a new Image from a filepath, FileData, an ImageData, or a CompressedImageData, and optionally generates or specifies mipmaps for the image.


[Open in Browser](https://love2d.org/wiki/love.graphics.newImage)


---

@*param* `filename` — The filepath to the image file.

@*param* `settings` — A table containing the following fields:

@*return* `image` — A new Image object which can be drawn on screen.

## newImageFont


```lua
function love.graphics.newImageFont(filename: string, glyphs: string)
  -> font: love.Font
```


Creates a new specifically formatted image.

In versions prior to 0.9.0, LÖVE expects ISO 8859-1 encoding for the glyphs string.


[Open in Browser](https://love2d.org/wiki/love.graphics.newImageFont)


---

@*param* `filename` — The filepath to the image file.

@*param* `glyphs` — A string of the characters in the image in order from left to right.

@*return* `font` — A Font object which can be used to draw text on screen.

## newMesh


```lua
function love.graphics.newMesh(vertices: { ["1"]: number, ["2"]: number, ["3"]: number, ["4"]: number, ["5"]: number, ["6"]: number, ["7"]: number, ["8"]: number }, mode?: "fan"|"points"|"strip"|"triangles", usage?: "dynamic"|"static"|"stream")
  -> mesh: love.Mesh
```


Creates a new Mesh.

Use Mesh:setTexture if the Mesh should be textured with an Image or Canvas when it's drawn.

In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/love.graphics.newMesh)


---

@*param* `vertices` — The table filled with vertex information tables for each vertex as follows:

@*param* `mode` — How the vertices are used when drawing. The default mode 'fan' is sufficient for simple convex polygons.

@*param* `usage` — The expected usage of the Mesh. The specified usage mode affects the Mesh's memory usage and performance.

@*return* `mesh` — The new mesh.

```lua
-- 
-- How a Mesh's vertices are used when drawing.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/MeshDrawMode)
-- 
mode:
    | "fan" -- The vertices create a "fan" shape with the first vertex acting as the hub point. Can be easily used to draw simple convex polygons.
    | "strip" -- The vertices create a series of connected triangles using vertices 1, 2, 3, then 3, 2, 4 (note the order), then 3, 4, 5, and so on.
    | "triangles" -- The vertices create unconnected triangles.
    | "points" -- The vertices are drawn as unconnected points (see love.graphics.setPointSize.)

-- 
-- Usage hints for SpriteBatches and Meshes to optimize data storage and access.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/SpriteBatchUsage)
-- 
usage:
    | "dynamic" -- The object's data will change occasionally during its lifetime.
    | "static" -- The object will not be modified after initial sprites or vertices are added.
    | "stream" -- The object data will always change between draws.
```

## newParticleSystem


```lua
function love.graphics.newParticleSystem(image: love.Image, buffer?: number)
  -> system: love.ParticleSystem
```


Creates a new ParticleSystem.


[Open in Browser](https://love2d.org/wiki/love.graphics.newParticleSystem)


---

@*param* `image` — The image to use.

@*param* `buffer` — The max number of particles at the same time.

@*return* `system` — A new ParticleSystem.

## newQuad


```lua
function love.graphics.newQuad(x: number, y: number, width: number, height: number, sw: number, sh: number)
  -> quad: love.Quad
```


Creates a new Quad.

The purpose of a Quad is to use a fraction of an image to draw objects, as opposed to drawing entire image. It is most useful for sprite sheets and atlases: in a sprite atlas, multiple sprites reside in same image, quad is used to draw a specific sprite from that image; in animated sprites with all frames residing in the same image, quad is used to draw specific frame from the animation.


[Open in Browser](https://love2d.org/wiki/love.graphics.newQuad)


---

@*param* `x` — The top-left position in the Image along the x-axis.

@*param* `y` — The top-left position in the Image along the y-axis.

@*param* `width` — The width of the Quad in the Image. (Must be greater than 0.)

@*param* `height` — The height of the Quad in the Image. (Must be greater than 0.)

@*param* `sw` — The reference width, the width of the Image. (Must be greater than 0.)

@*param* `sh` — The reference height, the height of the Image. (Must be greater than 0.)

@*return* `quad` — The new Quad.

## newShader


```lua
function love.graphics.newShader(code: string)
  -> shader: love.Shader
```


Creates a new Shader object for hardware-accelerated vertex and pixel effects. A Shader contains either vertex shader code, pixel shader code, or both.

Shaders are small programs which are run on the graphics card when drawing. Vertex shaders are run once for each vertex (for example, an image has 4 vertices - one at each corner. A Mesh might have many more.) Pixel shaders are run once for each pixel on the screen which the drawn object touches. Pixel shader code is executed after all the object's vertices have been processed by the vertex shader.


[Open in Browser](https://love2d.org/wiki/love.graphics.newShader)


---

@*param* `code` — The pixel shader or vertex shader code, or a filename pointing to a file with the code.

@*return* `shader` — A Shader object for use in drawing operations.

## newSpriteBatch


```lua
function love.graphics.newSpriteBatch(image: love.Image, maxsprites?: number)
  -> spriteBatch: love.SpriteBatch
```


Creates a new SpriteBatch object.


[Open in Browser](https://love2d.org/wiki/love.graphics.newSpriteBatch)


---

@*param* `image` — The Image to use for the sprites.

@*param* `maxsprites` — The maximum number of sprites that the SpriteBatch can contain at any given time. Since version 11.0, additional sprites added past this number will automatically grow the spritebatch.

@*return* `spriteBatch` — The new SpriteBatch.

## newText


```lua
function love.graphics.newText(font: love.Font, textstring?: string)
  -> text: love.Text
```


Creates a new drawable Text object.


[Open in Browser](https://love2d.org/wiki/love.graphics.newText)


---

@*param* `font` — The font to use for the text.

@*param* `textstring` — The initial string of text that the new Text object will contain. May be nil.

@*return* `text` — The new drawable Text object.

## newVideo


```lua
function love.graphics.newVideo(filename: string)
  -> video: love.Video
```


Creates a new drawable Video. Currently only Ogg Theora video files are supported.


[Open in Browser](https://love2d.org/wiki/love.graphics.newVideo)


---

@*param* `filename` — The file path to the Ogg Theora video file.

@*return* `video` — A new Video.

## newVolumeImage


```lua
function love.graphics.newVolumeImage(layers: table, settings?: { mipmaps: boolean, linear: boolean })
  -> image: love.Image
```


Creates a new volume (3D) Image.

Volume images are 3D textures with width, height, and depth. They can't be rendered directly, they can only be used in Shader code (and sent to the shader via Shader:send).

To use a volume image in a Shader, it must be declared as a VolumeImage or sampler3D type (instead of Image or sampler2D). The Texel(VolumeImage image, vec3 texcoords) shader function must be used to get pixel colors from the volume image. The vec3 argument is a normalized texture coordinate with the z component representing the depth to sample at (ranging from 1).

Volume images are typically used as lookup tables in shaders for color grading, for example, because sampling using a texture coordinate that is partway in between two pixels can interpolate across all 3 dimensions in the volume image, resulting in a smooth gradient even when a small-sized volume image is used as the lookup table.

Array images are a much better choice than volume images for storing multiple different sprites in a single array image for directly drawing them.


[Open in Browser](https://love2d.org/wiki/love.graphics.newVolumeImage)

@*param* `layers` — A table containing filepaths to images (or File, FileData, ImageData, or CompressedImageData objects), in an array. A table of tables can also be given, where each sub-table represents a single mipmap level and contains all layers for that mipmap.

@*param* `settings` — Optional table of settings to configure the volume image, containing the following fields:

@*return* `image` — A volume Image object.

## origin


```lua
function love.graphics.origin()
```


Resets the current coordinate transformation.

This function is always used to reverse any previous calls to love.graphics.rotate, love.graphics.scale, love.graphics.shear or love.graphics.translate. It returns the current transformation state to its defaults.


[Open in Browser](https://love2d.org/wiki/love.graphics.origin)

## points


```lua
function love.graphics.points(x: number, y: number, ...number)
```


Draws one or more points.


[Open in Browser](https://love2d.org/wiki/love.graphics.points)


---

@*param* `x` — The position of the first point on the x-axis.

@*param* `y` — The position of the first point on the y-axis.

## polygon


```lua
function love.graphics.polygon(mode: "fill"|"line", ...number)
```


Draw a polygon.

Following the mode argument, this function can accept multiple numeric arguments or a single table of numeric arguments. In either case the arguments are interpreted as alternating x and y coordinates of the polygon's vertices.


[Open in Browser](https://love2d.org/wiki/love.graphics.polygon)


---

@*param* `mode` — How to draw the polygon.

```lua
-- 
-- Controls whether shapes are drawn as an outline, or filled.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/DrawMode)
-- 
mode:
    | "fill" -- Draw filled shape.
    | "line" -- Draw outlined shape.
```

## pop


```lua
function love.graphics.pop()
```


Pops the current coordinate transformation from the transformation stack.

This function is always used to reverse a previous push operation. It returns the current transformation state to what it was before the last preceding push.


[Open in Browser](https://love2d.org/wiki/love.graphics.pop)

## present


```lua
function love.graphics.present()
```


Displays the results of drawing operations on the screen.

This function is used when writing your own love.run function. It presents all the results of your drawing operations on the screen. See the example in love.run for a typical use of this function.


[Open in Browser](https://love2d.org/wiki/love.graphics.present)

## print


```lua
function love.graphics.print(text: string|number, x?: number, y?: number, r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
```


Draws text on screen. If no Font is set, one will be created and set (once) if needed.

As of LOVE 0.7.1, when using translation and scaling functions while drawing text, this function assumes the scale occurs first.

If you don't script with this in mind, the text won't be in the right position, or possibly even on screen.

love.graphics.print and love.graphics.printf both support UTF-8 encoding. You'll also need a proper Font for special characters.

In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/love.graphics.print)


---

@*param* `text` — The text to draw.

@*param* `x` — The position to draw the object (x-axis).

@*param* `y` — The position to draw the object (y-axis).

@*param* `r` — Orientation (radians).

@*param* `sx` — Scale factor (x-axis).

@*param* `sy` — Scale factor (y-axis).

@*param* `ox` — Origin offset (x-axis).

@*param* `oy` — Origin offset (y-axis).

@*param* `kx` — Shearing factor (x-axis).

@*param* `ky` — Shearing factor (y-axis).

## printf


```lua
function love.graphics.printf(text: string|number, x: number, y: number, limit: number, align?: "center"|"justify"|"left"|"right", r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
```


Draws formatted text, with word wrap and alignment.

See additional notes in love.graphics.print.

The word wrap limit is applied before any scaling, rotation, and other coordinate transformations. Therefore the amount of text per line stays constant given the same wrap limit, even if the scale arguments change.

In version 0.9.2 and earlier, wrapping was implemented by breaking up words by spaces and putting them back together to make sure things fit nicely within the limit provided. However, due to the way this is done, extra spaces between words would end up missing when printed on the screen, and some lines could overflow past the provided wrap limit. In version 0.10.0 and newer this is no longer the case.

In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/love.graphics.printf)


---

@*param* `text` — A text string.

@*param* `x` — The position on the x-axis.

@*param* `y` — The position on the y-axis.

@*param* `limit` — Wrap the line after this many horizontal pixels.

@*param* `align` — The alignment.

@*param* `r` — Orientation (radians).

@*param* `sx` — Scale factor (x-axis).

@*param* `sy` — Scale factor (y-axis).

@*param* `ox` — Origin offset (x-axis).

@*param* `oy` — Origin offset (y-axis).

@*param* `kx` — Shearing factor (x-axis).

@*param* `ky` — Shearing factor (y-axis).

```lua
-- 
-- Text alignment.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/AlignMode)
-- 
align:
    | "center" -- Align text center.
    | "left" -- Align text left.
    | "right" -- Align text right.
    | "justify" -- Align text both left and right.
```

## push


```lua
function love.graphics.push()
```


Copies and pushes the current coordinate transformation to the transformation stack.

This function is always used to prepare for a corresponding pop operation later. It stores the current coordinate transformation state into the transformation stack and keeps it active. Later changes to the transformation can be undone by using the pop operation, which returns the coordinate transform to the state it was in before calling push.


[Open in Browser](https://love2d.org/wiki/love.graphics.push)

## rectangle


```lua
function love.graphics.rectangle(mode: "fill"|"line", x: number, y: number, width: number, height: number)
```


Draws a rectangle.


[Open in Browser](https://love2d.org/wiki/love.graphics.rectangle)


---

@*param* `mode` — How to draw the rectangle.

@*param* `x` — The position of top-left corner along the x-axis.

@*param* `y` — The position of top-left corner along the y-axis.

@*param* `width` — Width of the rectangle.

@*param* `height` — Height of the rectangle.

```lua
-- 
-- Controls whether shapes are drawn as an outline, or filled.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/DrawMode)
-- 
mode:
    | "fill" -- Draw filled shape.
    | "line" -- Draw outlined shape.
```

## replaceTransform


```lua
function love.graphics.replaceTransform(transform: love.Transform)
```


Replaces the current coordinate transformation with the given Transform object.


[Open in Browser](https://love2d.org/wiki/love.graphics.replaceTransform)

@*param* `transform` — The Transform object to replace the current graphics coordinate transform with.

## reset


```lua
function love.graphics.reset()
```


Resets the current graphics settings.

Calling reset makes the current drawing color white, the current background color black, disables any active color component masks, disables wireframe mode and resets the current graphics transformation to the origin. It also sets both the point and line drawing modes to smooth and their sizes to 1.0.


[Open in Browser](https://love2d.org/wiki/love.graphics.reset)

## rotate


```lua
function love.graphics.rotate(angle: number)
```


Rotates the coordinate system in two dimensions.

Calling this function affects all future drawing operations by rotating the coordinate system around the origin by the given amount of radians. This change lasts until love.draw() exits.


[Open in Browser](https://love2d.org/wiki/love.graphics.rotate)

@*param* `angle` — The amount to rotate the coordinate system in radians.

## scale


```lua
function love.graphics.scale(sx: number, sy?: number)
```


Scales the coordinate system in two dimensions.

By default the coordinate system in LÖVE corresponds to the display pixels in horizontal and vertical directions one-to-one, and the x-axis increases towards the right while the y-axis increases downwards. Scaling the coordinate system changes this relation.

After scaling by sx and sy, all coordinates are treated as if they were multiplied by sx and sy. Every result of a drawing operation is also correspondingly scaled, so scaling by (2, 2) for example would mean making everything twice as large in both x- and y-directions. Scaling by a negative value flips the coordinate system in the corresponding direction, which also means everything will be drawn flipped or upside down, or both. Scaling by zero is not a useful operation.

Scale and translate are not commutative operations, therefore, calling them in different orders will change the outcome.

Scaling lasts until love.draw() exits.


[Open in Browser](https://love2d.org/wiki/love.graphics.scale)

@*param* `sx` — The scaling in the direction of the x-axis.

@*param* `sy` — The scaling in the direction of the y-axis. If omitted, it defaults to same as parameter sx.

## setBackgroundColor


```lua
function love.graphics.setBackgroundColor(red: number, green: number, blue: number, alpha?: number)
```


Sets the background color.


[Open in Browser](https://love2d.org/wiki/love.graphics.setBackgroundColor)


---

@*param* `red` — The red component (0-1).

@*param* `green` — The green component (0-1).

@*param* `blue` — The blue component (0-1).

@*param* `alpha` — The alpha component (0-1).

## setBlendMode


```lua
function love.graphics.setBlendMode(mode: "add"|"additive"|"alpha"|"darken"|"lighten"...(+7))
```


Sets the blending mode.


[Open in Browser](https://love2d.org/wiki/love.graphics.setBlendMode)


---

@*param* `mode` — The blend mode to use.

```lua
-- 
-- Different ways to do color blending. See BlendAlphaMode and the BlendMode Formulas for additional notes.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/BlendMode)
-- 
mode:
    | "alpha" -- Alpha blending (normal). The alpha of what's drawn determines its opacity.
    | "replace" -- The colors of what's drawn completely replace what was on the screen, with no additional blending. The BlendAlphaMode specified in love.graphics.setBlendMode still affects what happens.
    | "screen" -- 'Screen' blending.
    | "add" -- The pixel colors of what's drawn are added to the pixel colors already on the screen. The alpha of the screen is not modified.
    | "subtract" -- The pixel colors of what's drawn are subtracted from the pixel colors already on the screen. The alpha of the screen is not modified.
    | "multiply" -- The pixel colors of what's drawn are multiplied with the pixel colors already on the screen (darkening them). The alpha of drawn objects is multiplied with the alpha of the screen rather than determining how much the colors on the screen are affected, even when the "alphamultiply" BlendAlphaMode is used.
    | "lighten" -- The pixel colors of what's drawn are compared to the existing pixel colors, and the larger of the two values for each color component is used. Only works when the "premultiplied" BlendAlphaMode is used in love.graphics.setBlendMode.
    | "darken" -- The pixel colors of what's drawn are compared to the existing pixel colors, and the smaller of the two values for each color component is used. Only works when the "premultiplied" BlendAlphaMode is used in love.graphics.setBlendMode.
    | "additive" -- Additive blend mode.
    | "subtractive" -- Subtractive blend mode.
    | "multiplicative" -- Multiply blend mode.
    | "premultiplied" -- Premultiplied alpha blend mode.
```

## setCanvas


```lua
function love.graphics.setCanvas(canvas: love.Canvas, mipmap?: number)
```


Captures drawing operations to a Canvas.


[Open in Browser](https://love2d.org/wiki/love.graphics.setCanvas)


---

@*param* `canvas` — The new target.

@*param* `mipmap` — The mipmap level to render to, for Canvases with mipmaps.

## setColor


```lua
function love.graphics.setColor(red: number, green: number, blue: number, alpha?: number)
```


Sets the color used for drawing.

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/love.graphics.setColor)


---

@*param* `red` — The amount of red.

@*param* `green` — The amount of green.

@*param* `blue` — The amount of blue.

@*param* `alpha` — The amount of alpha.  The alpha value will be applied to all subsequent draw operations, even the drawing of an image.

## setColorMask


```lua
function love.graphics.setColorMask(red: boolean, green: boolean, blue: boolean, alpha: boolean)
```


Sets the color mask. Enables or disables specific color components when rendering and clearing the screen. For example, if '''red''' is set to '''false''', no further changes will be made to the red component of any pixels.


[Open in Browser](https://love2d.org/wiki/love.graphics.setColorMask)


---

@*param* `red` — Render red component.

@*param* `green` — Render green component.

@*param* `blue` — Render blue component.

@*param* `alpha` — Render alpha component.

## setDefaultFilter


```lua
function love.graphics.setDefaultFilter(min: "linear"|"nearest", mag?: "linear"|"nearest", anisotropy?: number)
```


Sets the default scaling filters used with Images, Canvases, and Fonts.


[Open in Browser](https://love2d.org/wiki/love.graphics.setDefaultFilter)

@*param* `min` — Filter mode used when scaling the image down.

@*param* `mag` — Filter mode used when scaling the image up.

@*param* `anisotropy` — Maximum amount of Anisotropic Filtering used.

```lua
-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
min:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.

-- 
-- How the image is filtered when scaling.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FilterMode)
-- 
mag:
    | "linear" -- Scale image with linear interpolation.
    | "nearest" -- Scale image with nearest neighbor interpolation.
```

## setDepthMode


```lua
function love.graphics.setDepthMode(comparemode: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3), write: boolean)
```


Configures depth testing and writing to the depth buffer.

This is low-level functionality designed for use with custom vertex shaders and Meshes with custom vertex attributes. No higher level APIs are provided to set the depth of 2D graphics such as shapes, lines, and Images.


[Open in Browser](https://love2d.org/wiki/love.graphics.setDepthMode)


---

@*param* `comparemode` — Depth comparison mode used for depth testing.

@*param* `write` — Whether to write update / write values to the depth buffer when rendering.

```lua
-- 
-- Different types of per-pixel stencil test and depth test comparisons. The pixels of an object will be drawn if the comparison succeeds, for each pixel that the object touches.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CompareMode)
-- 
comparemode:
    | "equal" -- * stencil tests: the stencil value of the pixel must be equal to the supplied value.
              -- * depth tests: the depth value of the drawn object at that pixel must be equal to the existing depth value of that pixel.
    | "notequal" -- * stencil tests: the stencil value of the pixel must not be equal to the supplied value.
                 -- * depth tests: the depth value of the drawn object at that pixel must not be equal to the existing depth value of that pixel.
    | "less" -- * stencil tests: the stencil value of the pixel must be less than the supplied value.
             -- * depth tests: the depth value of the drawn object at that pixel must be less than the existing depth value of that pixel.
    | "lequal" -- * stencil tests: the stencil value of the pixel must be less than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be less than or equal to the existing depth value of that pixel.
    | "gequal" -- * stencil tests: the stencil value of the pixel must be greater than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be greater than or equal to the existing depth value of that pixel.
    | "greater" -- * stencil tests: the stencil value of the pixel must be greater than the supplied value.
                -- * depth tests: the depth value of the drawn object at that pixel must be greater than the existing depth value of that pixel.
    | "never" -- Objects will never be drawn.
    | "always" -- Objects will always be drawn. Effectively disables the depth or stencil test.
```

## setFont


```lua
function love.graphics.setFont(font: love.Font)
```


Set an already-loaded Font as the current font or create and load a new one from the file and size.

It's recommended that Font objects are created with love.graphics.newFont in the loading stage and then passed to this function in the drawing stage.


[Open in Browser](https://love2d.org/wiki/love.graphics.setFont)

@*param* `font` — The Font object to use.

## setFrontFaceWinding


```lua
function love.graphics.setFrontFaceWinding(winding: "ccw"|"cw")
```


Sets whether triangles with clockwise- or counterclockwise-ordered vertices are considered front-facing.

This is designed for use in combination with Mesh face culling. Other love.graphics shapes, lines, and sprites are not guaranteed to have a specific winding order to their internal vertices.


[Open in Browser](https://love2d.org/wiki/love.graphics.setFrontFaceWinding)

@*param* `winding` — The winding mode to use. The default winding is counterclockwise ('ccw').

```lua
-- 
-- How Mesh geometry vertices are ordered.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/VertexWinding)
-- 
winding:
    | "cw" -- Clockwise.
    | "ccw" -- Counter-clockwise.
```

## setLineJoin


```lua
function love.graphics.setLineJoin(join: "bevel"|"miter"|"none")
```


Sets the line join style. See LineJoin for the possible options.


[Open in Browser](https://love2d.org/wiki/love.graphics.setLineJoin)

@*param* `join` — The LineJoin to use.

```lua
-- 
-- Line join style.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/LineJoin)
-- 
join:
    | "miter" -- The ends of the line segments beveled in an angle so that they join seamlessly.
    | "none" -- No cap applied to the ends of the line segments.
    | "bevel" -- Flattens the point where line segments join together.
```

## setLineStyle


```lua
function love.graphics.setLineStyle(style: "rough"|"smooth")
```


Sets the line style.


[Open in Browser](https://love2d.org/wiki/love.graphics.setLineStyle)

@*param* `style` — The LineStyle to use. Line styles include smooth and rough.

```lua
-- 
-- The styles in which lines are drawn.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/LineStyle)
-- 
style:
    | "rough" -- Draw rough lines.
    | "smooth" -- Draw smooth lines.
```

## setLineWidth


```lua
function love.graphics.setLineWidth(width: number)
```


Sets the line width.


[Open in Browser](https://love2d.org/wiki/love.graphics.setLineWidth)

@*param* `width` — The width of the line.

## setMeshCullMode


```lua
function love.graphics.setMeshCullMode(mode: "back"|"front"|"none")
```


Sets whether back-facing triangles in a Mesh are culled.

This is designed for use with low level custom hardware-accelerated 3D rendering via custom vertex attributes on Meshes, custom vertex shaders, and depth testing with a depth buffer.

By default, both front- and back-facing triangles in Meshes are rendered.


[Open in Browser](https://love2d.org/wiki/love.graphics.setMeshCullMode)

@*param* `mode` — The Mesh face culling mode to use (whether to render everything, cull back-facing triangles, or cull front-facing triangles).

```lua
-- 
-- How Mesh geometry is culled when rendering.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CullMode)
-- 
mode:
    | "back" -- Back-facing triangles in Meshes are culled (not rendered). The vertex order of a triangle determines whether it is back- or front-facing.
    | "front" -- Front-facing triangles in Meshes are culled.
    | "none" -- Both back- and front-facing triangles in Meshes are rendered.
```

## setNewFont


```lua
function love.graphics.setNewFont(size?: number)
  -> font: love.Font
```


Creates and sets a new Font.


[Open in Browser](https://love2d.org/wiki/love.graphics.setNewFont)


---

@*param* `size` — The size of the font.

@*return* `font` — The new font.

## setPointSize


```lua
function love.graphics.setPointSize(size: number)
```


Sets the point size.


[Open in Browser](https://love2d.org/wiki/love.graphics.setPointSize)

@*param* `size` — The new point size.

## setScissor


```lua
function love.graphics.setScissor(x: number, y: number, width: number, height: number)
```


Sets or disables scissor.

The scissor limits the drawing area to a specified rectangle. This affects all graphics calls, including love.graphics.clear.

The dimensions of the scissor is unaffected by graphical transformations (translate, scale, ...).


[Open in Browser](https://love2d.org/wiki/love.graphics.setScissor)


---

@*param* `x` — x coordinate of upper left corner.

@*param* `y` — y coordinate of upper left corner.

@*param* `width` — width of clipping rectangle.

@*param* `height` — height of clipping rectangle.

## setShader


```lua
function love.graphics.setShader(shader: love.Shader)
```


Sets or resets a Shader as the current pixel effect or vertex shaders. All drawing operations until the next ''love.graphics.setShader'' will be drawn using the Shader object specified.


[Open in Browser](https://love2d.org/wiki/love.graphics.setShader)


---

@*param* `shader` — The new shader.

## setStencilTest


```lua
function love.graphics.setStencilTest(comparemode: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3), comparevalue: number)
```


Configures or disables stencil testing.

When stencil testing is enabled, the geometry of everything that is drawn afterward will be clipped / stencilled out based on a comparison between the arguments of this function and the stencil value of each pixel that the geometry touches. The stencil values of pixels are affected via love.graphics.stencil.


[Open in Browser](https://love2d.org/wiki/love.graphics.setStencilTest)


---

@*param* `comparemode` — The type of comparison to make for each pixel.

@*param* `comparevalue` — The value to use when comparing with the stencil value of each pixel. Must be between 0 and 255.

```lua
-- 
-- Different types of per-pixel stencil test and depth test comparisons. The pixels of an object will be drawn if the comparison succeeds, for each pixel that the object touches.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CompareMode)
-- 
comparemode:
    | "equal" -- * stencil tests: the stencil value of the pixel must be equal to the supplied value.
              -- * depth tests: the depth value of the drawn object at that pixel must be equal to the existing depth value of that pixel.
    | "notequal" -- * stencil tests: the stencil value of the pixel must not be equal to the supplied value.
                 -- * depth tests: the depth value of the drawn object at that pixel must not be equal to the existing depth value of that pixel.
    | "less" -- * stencil tests: the stencil value of the pixel must be less than the supplied value.
             -- * depth tests: the depth value of the drawn object at that pixel must be less than the existing depth value of that pixel.
    | "lequal" -- * stencil tests: the stencil value of the pixel must be less than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be less than or equal to the existing depth value of that pixel.
    | "gequal" -- * stencil tests: the stencil value of the pixel must be greater than or equal to the supplied value.
               -- * depth tests: the depth value of the drawn object at that pixel must be greater than or equal to the existing depth value of that pixel.
    | "greater" -- * stencil tests: the stencil value of the pixel must be greater than the supplied value.
                -- * depth tests: the depth value of the drawn object at that pixel must be greater than the existing depth value of that pixel.
    | "never" -- Objects will never be drawn.
    | "always" -- Objects will always be drawn. Effectively disables the depth or stencil test.
```

## setWireframe


```lua
function love.graphics.setWireframe(enable: boolean)
```


Sets whether wireframe lines will be used when drawing.


[Open in Browser](https://love2d.org/wiki/love.graphics.setWireframe)

@*param* `enable` — True to enable wireframe mode when drawing, false to disable it.

## shear


```lua
function love.graphics.shear(kx: number, ky: number)
```


Shears the coordinate system.


[Open in Browser](https://love2d.org/wiki/love.graphics.shear)

@*param* `kx` — The shear factor on the x-axis.

@*param* `ky` — The shear factor on the y-axis.

## stencil


```lua
function love.graphics.stencil(stencilfunction: function, action?: "decrement"|"decrementwrap"|"increment"|"incrementwrap"|"invert"...(+1), value?: number, keepvalues?: boolean)
```


Draws geometry as a stencil.

The geometry drawn by the supplied function sets invisible stencil values of pixels, instead of setting pixel colors. The stencil buffer (which contains those stencil values) can act like a mask / stencil - love.graphics.setStencilTest can be used afterward to determine how further rendering is affected by the stencil values in each pixel.

Stencil values are integers within the range of 255.


[Open in Browser](https://love2d.org/wiki/love.graphics.stencil)

@*param* `stencilfunction` — Function which draws geometry. The stencil values of pixels, rather than the color of each pixel, will be affected by the geometry.

@*param* `action` — How to modify any stencil values of pixels that are touched by what's drawn in the stencil function.

@*param* `value` — The new stencil value to use for pixels if the 'replace' stencil action is used. Has no effect with other stencil actions. Must be between 0 and 255.

@*param* `keepvalues` — True to preserve old stencil values of pixels, false to re-set every pixel's stencil value to 0 before executing the stencil function. love.graphics.clear will also re-set all stencil values.

```lua
-- 
-- How a stencil function modifies the stencil values of pixels it touches.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/StencilAction)
-- 
action:
    | "replace" -- The stencil value of a pixel will be replaced by the value specified in love.graphics.stencil, if any object touches the pixel.
    | "increment" -- The stencil value of a pixel will be incremented by 1 for each object that touches the pixel. If the stencil value reaches 255 it will stay at 255.
    | "decrement" -- The stencil value of a pixel will be decremented by 1 for each object that touches the pixel. If the stencil value reaches 0 it will stay at 0.
    | "incrementwrap" -- The stencil value of a pixel will be incremented by 1 for each object that touches the pixel. If a stencil value of 255 is incremented it will be set to 0.
    | "decrementwrap" -- The stencil value of a pixel will be decremented by 1 for each object that touches the pixel. If the stencil value of 0 is decremented it will be set to 255.
    | "invert" -- The stencil value of a pixel will be bitwise-inverted for each object that touches the pixel. If a stencil value of 0 is inverted it will become 255.
```

## transformPoint


```lua
function love.graphics.transformPoint(globalX: number, globalY: number)
  -> screenX: number
  2. screenY: number
```


Converts the given 2D position from global coordinates into screen-space.

This effectively applies the current graphics transformations to the given position. A similar Transform:transformPoint method exists for Transform objects.


[Open in Browser](https://love2d.org/wiki/love.graphics.transformPoint)

@*param* `globalX` — The x component of the position in global coordinates.

@*param* `globalY` — The y component of the position in global coordinates.

@*return* `screenX` — The x component of the position with graphics transformations applied.

@*return* `screenY` — The y component of the position with graphics transformations applied.

## translate


```lua
function love.graphics.translate(dx: number, dy: number)
```


Translates the coordinate system in two dimensions.

When this function is called with two numbers, dx, and dy, all the following drawing operations take effect as if their x and y coordinates were x+dx and y+dy.

Scale and translate are not commutative operations, therefore, calling them in different orders will change the outcome.

This change lasts until love.draw() exits or else a love.graphics.pop reverts to a previous love.graphics.push.

Translating using whole numbers will prevent tearing/blurring of images and fonts draw after translating.


[Open in Browser](https://love2d.org/wiki/love.graphics.translate)

@*param* `dx` — The translation relative to the x-axis.

@*param* `dy` — The translation relative to the y-axis.

## validateShader


```lua
function love.graphics.validateShader(gles: boolean, code: string)
  -> status: boolean
  2. message: string
```


Validates shader code. Check if specified shader code does not contain any errors.


[Open in Browser](https://love2d.org/wiki/love.graphics.validateShader)


---

@*param* `gles` — Validate code as GLSL ES shader.

@*param* `code` — The pixel shader or vertex shader code, or a filename pointing to a file with the code.

@*return* `status` — true if specified shader code doesn't contain any errors. false otherwise.

@*return* `message` — Reason why shader code validation failed (or nil if validation succeded).


---

# love.graphics


```lua
love.graphics
```


---

# love.graphics.applyTransform


```lua
function love.graphics.applyTransform(transform: love.Transform)
```


---

# love.graphics.arc


```lua
function love.graphics.arc(drawmode: "fill"|"line", x: number, y: number, radius: number, angle1: number, angle2: number, segments?: number)
```


---

# love.graphics.captureScreenshot


```lua
function love.graphics.captureScreenshot(filename: string)
```


---

# love.graphics.circle


```lua
function love.graphics.circle(mode: "fill"|"line", x: number, y: number, radius: number)
```


---

# love.graphics.clear


```lua
function love.graphics.clear()
```


---

# love.graphics.discard


```lua
function love.graphics.discard(discardcolor?: boolean, discardstencil?: boolean)
```


---

# love.graphics.draw


```lua
function love.graphics.draw(drawable: love.Drawable, x?: number, y?: number, r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
```


---

# love.graphics.drawInstanced


```lua
function love.graphics.drawInstanced(mesh: love.Mesh, instancecount: number, x?: number, y?: number, r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
```


---

# love.graphics.drawLayer


```lua
function love.graphics.drawLayer(texture: love.Texture, layerindex: number, x?: number, y?: number, r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
```


---

# love.graphics.ellipse


```lua
function love.graphics.ellipse(mode: "fill"|"line", x: number, y: number, radiusx: number, radiusy: number)
```


---

# love.graphics.flushBatch


```lua
function love.graphics.flushBatch()
```


---

# love.graphics.getBackgroundColor


```lua
function love.graphics.getBackgroundColor()
  -> r: number
  2. g: number
  3. b: number
  4. a: number
```


---

# love.graphics.getBlendMode


```lua
function love.graphics.getBlendMode()
  -> mode: "add"|"additive"|"alpha"|"darken"|"lighten"...(+7)
  2. alphamode: "alphamultiply"|"premultiplied"
```


---

# love.graphics.getCanvas


```lua
function love.graphics.getCanvas()
  -> canvas: love.Canvas
```


---

# love.graphics.getCanvasFormats


```lua
function love.graphics.getCanvasFormats()
  -> formats: table
```


---

# love.graphics.getColor


```lua
function love.graphics.getColor()
  -> r: number
  2. g: number
  3. b: number
  4. a: number
```


---

# love.graphics.getColorMask


```lua
function love.graphics.getColorMask()
  -> r: boolean
  2. g: boolean
  3. b: boolean
  4. a: boolean
```


---

# love.graphics.getDPIScale


```lua
function love.graphics.getDPIScale()
  -> scale: number
```


---

# love.graphics.getDefaultFilter


```lua
function love.graphics.getDefaultFilter()
  -> min: "linear"|"nearest"
  2. mag: "linear"|"nearest"
  3. anisotropy: number
```


---

# love.graphics.getDepthMode


```lua
function love.graphics.getDepthMode()
  -> comparemode: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3)
  2. write: boolean
```


---

# love.graphics.getDimensions


```lua
function love.graphics.getDimensions()
  -> width: number
  2. height: number
```


---

# love.graphics.getFont


```lua
function love.graphics.getFont()
  -> font: love.Font
```


---

# love.graphics.getFrontFaceWinding


```lua
function love.graphics.getFrontFaceWinding()
  -> winding: "ccw"|"cw"
```


---

# love.graphics.getHeight


```lua
function love.graphics.getHeight()
  -> height: number
```


---

# love.graphics.getImageFormats


```lua
function love.graphics.getImageFormats()
  -> formats: table
```


---

# love.graphics.getLineJoin


```lua
function love.graphics.getLineJoin()
  -> join: "bevel"|"miter"|"none"
```


---

# love.graphics.getLineStyle


```lua
function love.graphics.getLineStyle()
  -> style: "rough"|"smooth"
```


---

# love.graphics.getLineWidth


```lua
function love.graphics.getLineWidth()
  -> width: number
```


---

# love.graphics.getMeshCullMode


```lua
function love.graphics.getMeshCullMode()
  -> mode: "back"|"front"|"none"
```


---

# love.graphics.getPixelDimensions


```lua
function love.graphics.getPixelDimensions()
  -> pixelwidth: number
  2. pixelheight: number
```


---

# love.graphics.getPixelHeight


```lua
function love.graphics.getPixelHeight()
  -> pixelheight: number
```


---

# love.graphics.getPixelWidth


```lua
function love.graphics.getPixelWidth()
  -> pixelwidth: number
```


---

# love.graphics.getPointSize


```lua
function love.graphics.getPointSize()
  -> size: number
```


---

# love.graphics.getRendererInfo


```lua
function love.graphics.getRendererInfo()
  -> name: string
  2. version: string
  3. vendor: string
  4. device: string
```


---

# love.graphics.getScissor


```lua
function love.graphics.getScissor()
  -> x: number
  2. y: number
  3. width: number
  4. height: number
```


---

# love.graphics.getShader


```lua
function love.graphics.getShader()
  -> shader: love.Shader
```


---

# love.graphics.getStackDepth


```lua
function love.graphics.getStackDepth()
  -> depth: number
```


---

# love.graphics.getStats


```lua
function love.graphics.getStats()
  -> stats: { drawcalls: number, canvasswitches: number, texturememory: number, images: number, canvases: number, fonts: number, shaderswitches: number, drawcallsbatched: number }
```


---

# love.graphics.getStencilTest


```lua
function love.graphics.getStencilTest()
  -> comparemode: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3)
  2. comparevalue: number
```


---

# love.graphics.getSupported


```lua
function love.graphics.getSupported()
  -> features: table
```


---

# love.graphics.getSystemLimits


```lua
function love.graphics.getSystemLimits()
  -> limits: table
```


---

# love.graphics.getTextureTypes


```lua
function love.graphics.getTextureTypes()
  -> texturetypes: table
```


---

# love.graphics.getWidth


```lua
function love.graphics.getWidth()
  -> width: number
```


---

# love.graphics.intersectScissor


```lua
function love.graphics.intersectScissor(x: number, y: number, width: number, height: number)
```


---

# love.graphics.inverseTransformPoint


```lua
function love.graphics.inverseTransformPoint(screenX: number, screenY: number)
  -> globalX: number
  2. globalY: number
```


---

# love.graphics.isActive


```lua
function love.graphics.isActive()
  -> active: boolean
```


---

# love.graphics.isGammaCorrect


```lua
function love.graphics.isGammaCorrect()
  -> gammacorrect: boolean
```


---

# love.graphics.isWireframe


```lua
function love.graphics.isWireframe()
  -> wireframe: boolean
```


---

# love.graphics.line


```lua
function love.graphics.line(x1: number, y1: number, x2: number, y2: number, ...number)
```


---

# love.graphics.newArrayImage


```lua
function love.graphics.newArrayImage(slices: table, settings?: { mipmaps: boolean, linear: boolean, dpiscale: number })
  -> image: love.Image
```


---

# love.graphics.newCanvas


```lua
function love.graphics.newCanvas()
  -> canvas: love.Canvas
```


---

# love.graphics.newCubeImage


```lua
function love.graphics.newCubeImage(filename: string, settings?: { mipmaps: boolean, linear: boolean })
  -> image: love.Image
```


---

# love.graphics.newFont


```lua
function love.graphics.newFont(filename: string)
  -> font: love.Font
```


---

# love.graphics.newImage


```lua
function love.graphics.newImage(filename: string, settings?: { dpiscale: number, linear: boolean, mipmaps: boolean })
  -> image: love.Image
```


---

# love.graphics.newImageFont


```lua
function love.graphics.newImageFont(filename: string, glyphs: string)
  -> font: love.Font
```


---

# love.graphics.newMesh


```lua
function love.graphics.newMesh(vertices: { ["1"]: number, ["2"]: number, ["3"]: number, ["4"]: number, ["5"]: number, ["6"]: number, ["7"]: number, ["8"]: number }, mode?: "fan"|"points"|"strip"|"triangles", usage?: "dynamic"|"static"|"stream")
  -> mesh: love.Mesh
```


---

# love.graphics.newParticleSystem


```lua
function love.graphics.newParticleSystem(image: love.Image, buffer?: number)
  -> system: love.ParticleSystem
```


---

# love.graphics.newQuad


```lua
function love.graphics.newQuad(x: number, y: number, width: number, height: number, sw: number, sh: number)
  -> quad: love.Quad
```


---

# love.graphics.newShader


```lua
function love.graphics.newShader(code: string)
  -> shader: love.Shader
```


---

# love.graphics.newSpriteBatch


```lua
function love.graphics.newSpriteBatch(image: love.Image, maxsprites?: number)
  -> spriteBatch: love.SpriteBatch
```


---

# love.graphics.newText


```lua
function love.graphics.newText(font: love.Font, textstring?: string)
  -> text: love.Text
```


---

# love.graphics.newVideo


```lua
function love.graphics.newVideo(filename: string)
  -> video: love.Video
```


---

# love.graphics.newVolumeImage


```lua
function love.graphics.newVolumeImage(layers: table, settings?: { mipmaps: boolean, linear: boolean })
  -> image: love.Image
```


---

# love.graphics.origin


```lua
function love.graphics.origin()
```


---

# love.graphics.points


```lua
function love.graphics.points(x: number, y: number, ...number)
```


---

# love.graphics.polygon


```lua
function love.graphics.polygon(mode: "fill"|"line", ...number)
```


---

# love.graphics.pop


```lua
function love.graphics.pop()
```


---

# love.graphics.present


```lua
function love.graphics.present()
```


---

# love.graphics.print


```lua
function love.graphics.print(text: string|number, x?: number, y?: number, r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
```


---

# love.graphics.printf


```lua
function love.graphics.printf(text: string|number, x: number, y: number, limit: number, align?: "center"|"justify"|"left"|"right", r?: number, sx?: number, sy?: number, ox?: number, oy?: number, kx?: number, ky?: number)
```


---

# love.graphics.push


```lua
function love.graphics.push()
```


---

# love.graphics.rectangle


```lua
function love.graphics.rectangle(mode: "fill"|"line", x: number, y: number, width: number, height: number)
```


---

# love.graphics.replaceTransform


```lua
function love.graphics.replaceTransform(transform: love.Transform)
```


---

# love.graphics.reset


```lua
function love.graphics.reset()
```


---

# love.graphics.rotate


```lua
function love.graphics.rotate(angle: number)
```


---

# love.graphics.scale


```lua
function love.graphics.scale(sx: number, sy?: number)
```


---

# love.graphics.setBackgroundColor


```lua
function love.graphics.setBackgroundColor(red: number, green: number, blue: number, alpha?: number)
```


---

# love.graphics.setBlendMode


```lua
function love.graphics.setBlendMode(mode: "add"|"additive"|"alpha"|"darken"|"lighten"...(+7))
```


---

# love.graphics.setCanvas


```lua
function love.graphics.setCanvas(canvas: love.Canvas, mipmap?: number)
```


---

# love.graphics.setColor


```lua
function love.graphics.setColor(red: number, green: number, blue: number, alpha?: number)
```


---

# love.graphics.setColorMask


```lua
function love.graphics.setColorMask(red: boolean, green: boolean, blue: boolean, alpha: boolean)
```


---

# love.graphics.setDefaultFilter


```lua
function love.graphics.setDefaultFilter(min: "linear"|"nearest", mag?: "linear"|"nearest", anisotropy?: number)
```


---

# love.graphics.setDepthMode


```lua
function love.graphics.setDepthMode(comparemode: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3), write: boolean)
```


---

# love.graphics.setFont


```lua
function love.graphics.setFont(font: love.Font)
```


---

# love.graphics.setFrontFaceWinding


```lua
function love.graphics.setFrontFaceWinding(winding: "ccw"|"cw")
```


---

# love.graphics.setLineJoin


```lua
function love.graphics.setLineJoin(join: "bevel"|"miter"|"none")
```


---

# love.graphics.setLineStyle


```lua
function love.graphics.setLineStyle(style: "rough"|"smooth")
```


---

# love.graphics.setLineWidth


```lua
function love.graphics.setLineWidth(width: number)
```


---

# love.graphics.setMeshCullMode


```lua
function love.graphics.setMeshCullMode(mode: "back"|"front"|"none")
```


---

# love.graphics.setNewFont


```lua
function love.graphics.setNewFont(size?: number)
  -> font: love.Font
```


---

# love.graphics.setPointSize


```lua
function love.graphics.setPointSize(size: number)
```


---

# love.graphics.setScissor


```lua
function love.graphics.setScissor(x: number, y: number, width: number, height: number)
```


---

# love.graphics.setShader


```lua
function love.graphics.setShader(shader: love.Shader)
```


---

# love.graphics.setStencilTest


```lua
function love.graphics.setStencilTest(comparemode: "always"|"equal"|"gequal"|"greater"|"lequal"...(+3), comparevalue: number)
```


---

# love.graphics.setWireframe


```lua
function love.graphics.setWireframe(enable: boolean)
```


---

# love.graphics.shear


```lua
function love.graphics.shear(kx: number, ky: number)
```


---

# love.graphics.stencil


```lua
function love.graphics.stencil(stencilfunction: function, action?: "decrement"|"decrementwrap"|"increment"|"incrementwrap"|"invert"...(+1), value?: number, keepvalues?: boolean)
```


---

# love.graphics.transformPoint


```lua
function love.graphics.transformPoint(globalX: number, globalY: number)
  -> screenX: number
  2. screenY: number
```


---

# love.graphics.translate


```lua
function love.graphics.translate(dx: number, dy: number)
```


---

# love.graphics.validateShader


```lua
function love.graphics.validateShader(gles: boolean, code: string)
  -> status: boolean
  2. message: string
```


---

# love.hasDeprecationOutput


```lua
function love.hasDeprecationOutput()
  -> enabled: boolean
```


---

# love.image

## isCompressed


```lua
function love.image.isCompressed(filename: string)
  -> compressed: boolean
```


Determines whether a file can be loaded as CompressedImageData.


[Open in Browser](https://love2d.org/wiki/love.image.isCompressed)


---

@*param* `filename` — The filename of the potentially compressed image file.

@*return* `compressed` — Whether the file can be loaded as CompressedImageData or not.

## newCompressedData


```lua
function love.image.newCompressedData(filename: string)
  -> compressedImageData: love.CompressedImageData
```


Create a new CompressedImageData object from a compressed image file. LÖVE supports several compressed texture formats, enumerated in the CompressedImageFormat page.


[Open in Browser](https://love2d.org/wiki/love.image.newCompressedData)


---

@*param* `filename` — The filename of the compressed image file.

@*return* `compressedImageData` — The new CompressedImageData object.

## newImageData


```lua
function love.image.newImageData(width: number, height: number)
  -> imageData: love.ImageData
```


Creates a new ImageData object.


[Open in Browser](https://love2d.org/wiki/love.image.newImageData)


---

@*param* `width` — The width of the ImageData.

@*param* `height` — The height of the ImageData.

@*return* `imageData` — The new blank ImageData object. Each pixel's color values, (including the alpha values!) will be set to zero.


---

# love.image


```lua
love.image
```


---

# love.image.isCompressed


```lua
function love.image.isCompressed(filename: string)
  -> compressed: boolean
```


---

# love.image.newCompressedData


```lua
function love.image.newCompressedData(filename: string)
  -> compressedImageData: love.CompressedImageData
```


---

# love.image.newImageData


```lua
function love.image.newImageData(width: number, height: number)
  -> imageData: love.ImageData
```


---

# love.isVersionCompatible


```lua
function love.isVersionCompatible(version: string)
  -> compatible: boolean
```


---

# love.joystick

## getGamepadMappingString


```lua
function love.joystick.getGamepadMappingString(guid: string)
  -> mappingstring: string
```


Gets the full gamepad mapping string of the Joysticks which have the given GUID, or nil if the GUID isn't recognized as a gamepad.

The mapping string contains binding information used to map the Joystick's buttons an axes to the standard gamepad layout, and can be used later with love.joystick.loadGamepadMappings.


[Open in Browser](https://love2d.org/wiki/love.joystick.getGamepadMappingString)

@*param* `guid` — The GUID value to get the mapping string for.

@*return* `mappingstring` — A string containing the Joystick's gamepad mappings, or nil if the GUID is not recognized as a gamepad.

## getJoystickCount


```lua
function love.joystick.getJoystickCount()
  -> joystickcount: number
```


Gets the number of connected joysticks.


[Open in Browser](https://love2d.org/wiki/love.joystick.getJoystickCount)

@*return* `joystickcount` — The number of connected joysticks.

## getJoysticks


```lua
function love.joystick.getJoysticks()
  -> joysticks: table
```


Gets a list of connected Joysticks.


[Open in Browser](https://love2d.org/wiki/love.joystick.getJoysticks)

@*return* `joysticks` — The list of currently connected Joysticks.

## loadGamepadMappings


```lua
function love.joystick.loadGamepadMappings(filename: string)
```


Loads a gamepad mappings string or file created with love.joystick.saveGamepadMappings.

It also recognizes any SDL gamecontroller mapping string, such as those created with Steam's Big Picture controller configure interface, or this nice database. If a new mapping is loaded for an already known controller GUID, the later version will overwrite the one currently loaded.


[Open in Browser](https://love2d.org/wiki/love.joystick.loadGamepadMappings)


---

@*param* `filename` — The filename to load the mappings string from.

## saveGamepadMappings


```lua
function love.joystick.saveGamepadMappings(filename: string)
  -> mappings: string
```


Saves the virtual gamepad mappings of all recognized as gamepads and have either been recently used or their gamepad bindings have been modified.

The mappings are stored as a string for use with love.joystick.loadGamepadMappings.


[Open in Browser](https://love2d.org/wiki/love.joystick.saveGamepadMappings)


---

@*param* `filename` — The filename to save the mappings string to.

@*return* `mappings` — The mappings string that was written to the file.

## setGamepadMapping


```lua
function love.joystick.setGamepadMapping(guid: string, button: "a"|"b"|"back"|"dpdown"|"dpleft"...(+10), inputtype: "axis"|"button"|"hat", inputindex: number, hatdir?: "c"|"d"|"l"|"ld"|"lu"...(+4))
  -> success: boolean
```


Binds a virtual gamepad input to a button, axis or hat for all Joysticks of a certain type. For example, if this function is used with a GUID returned by a Dualshock 3 controller in OS X, the binding will affect Joystick:getGamepadAxis and Joystick:isGamepadDown for ''all'' Dualshock 3 controllers used with the game when run in OS X.

LÖVE includes built-in gamepad bindings for many common controllers. This function lets you change the bindings or add new ones for types of Joysticks which aren't recognized as gamepads by default.

The virtual gamepad buttons and axes are designed around the Xbox 360 controller layout.


[Open in Browser](https://love2d.org/wiki/love.joystick.setGamepadMapping)


---

@*param* `guid` — The OS-dependent GUID for the type of Joystick the binding will affect.

@*param* `button` — The virtual gamepad button to bind.

@*param* `inputtype` — The type of input to bind the virtual gamepad button to.

@*param* `inputindex` — The index of the axis, button, or hat to bind the virtual gamepad button to.

@*param* `hatdir` — The direction of the hat, if the virtual gamepad button will be bound to a hat. nil otherwise.

@*return* `success` — Whether the virtual gamepad button was successfully bound.

```lua
-- 
-- Virtual gamepad buttons.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/GamepadButton)
-- 
button:
    | "a" -- Bottom face button (A).
    | "b" -- Right face button (B).
    | "x" -- Left face button (X).
    | "y" -- Top face button (Y).
    | "back" -- Back button.
    | "guide" -- Guide button.
    | "start" -- Start button.
    | "leftstick" -- Left stick click button.
    | "rightstick" -- Right stick click button.
    | "leftshoulder" -- Left bumper.
    | "rightshoulder" -- Right bumper.
    | "dpup" -- D-pad up.
    | "dpdown" -- D-pad down.
    | "dpleft" -- D-pad left.
    | "dpright" -- D-pad right.

-- 
-- Types of Joystick inputs.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JoystickInputType)
-- 
inputtype:
    | "axis" -- Analog axis.
    | "button" -- Button.
    | "hat" -- 8-direction hat value.

-- 
-- Joystick hat positions.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/JoystickHat)
-- 
hatdir:
    | "c" -- Centered
    | "d" -- Down
    | "l" -- Left
    | "ld" -- Left+Down
    | "lu" -- Left+Up
    | "r" -- Right
    | "rd" -- Right+Down
    | "ru" -- Right+Up
    | "u" -- Up
```


---

# love.joystick


```lua
love.joystick
```


---

# love.joystick.getGamepadMappingString


```lua
function love.joystick.getGamepadMappingString(guid: string)
  -> mappingstring: string
```


---

# love.joystick.getJoystickCount


```lua
function love.joystick.getJoystickCount()
  -> joystickcount: number
```


---

# love.joystick.getJoysticks


```lua
function love.joystick.getJoysticks()
  -> joysticks: table
```


---

# love.joystick.loadGamepadMappings


```lua
function love.joystick.loadGamepadMappings(filename: string)
```


---

# love.joystick.saveGamepadMappings


```lua
function love.joystick.saveGamepadMappings(filename: string)
  -> mappings: string
```


---

# love.joystick.setGamepadMapping


```lua
function love.joystick.setGamepadMapping(guid: string, button: "a"|"b"|"back"|"dpdown"|"dpleft"...(+10), inputtype: "axis"|"button"|"hat", inputindex: number, hatdir?: "c"|"d"|"l"|"ld"|"lu"...(+4))
  -> success: boolean
```


---

# love.joystickadded


---

# love.joystickaxis


---

# love.joystickhat


---

# love.joystickpressed


---

# love.joystickreleased


---

# love.joystickremoved


---

# love.keyboard

## getKeyFromScancode


```lua
function love.keyboard.getKeyFromScancode(scancode: "'"|","|"-"|"."|"/"...(+189))
  -> key: "!"|"#"|"$"|"&"|"'"...(+139)
```


Gets the key corresponding to the given hardware scancode.

Unlike key constants, Scancodes are keyboard layout-independent. For example the scancode 'w' will be generated if the key in the same place as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are.

Scancodes are useful for creating default controls that have the same physical locations on on all systems.


[Open in Browser](https://love2d.org/wiki/love.keyboard.getKeyFromScancode)

@*param* `scancode` — The scancode to get the key from.

@*return* `key` — The key corresponding to the given scancode, or 'unknown' if the scancode doesn't map to a KeyConstant on the current system.

```lua
-- 
-- Keyboard scancodes.
-- 
-- Scancodes are keyboard layout-independent, so the scancode "w" will be generated if the key in the same place as the "w" key on an American QWERTY keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are.
-- 
-- Using scancodes, rather than keycodes, is useful because keyboards with layouts differing from the US/UK layout(s) might have keys that generate 'unknown' keycodes, but the scancodes will still be detected. This however would necessitate having a list for each keyboard layout one would choose to support.
-- 
-- One could use textinput or textedited instead, but those only give back the end result of keys used, i.e. you can't get modifiers on their own from it, only the final symbols that were generated.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/Scancode)
-- 
scancode:
    | "a" -- The 'A' key on an American layout.
    | "b" -- The 'B' key on an American layout.
    | "c" -- The 'C' key on an American layout.
    | "d" -- The 'D' key on an American layout.
    | "e" -- The 'E' key on an American layout.
    | "f" -- The 'F' key on an American layout.
    | "g" -- The 'G' key on an American layout.
    | "h" -- The 'H' key on an American layout.
    | "i" -- The 'I' key on an American layout.
    | "j" -- The 'J' key on an American layout.
    | "k" -- The 'K' key on an American layout.
    | "l" -- The 'L' key on an American layout.
    | "m" -- The 'M' key on an American layout.
    | "n" -- The 'N' key on an American layout.
    | "o" -- The 'O' key on an American layout.
    | "p" -- The 'P' key on an American layout.
    | "q" -- The 'Q' key on an American layout.
    | "r" -- The 'R' key on an American layout.
    | "s" -- The 'S' key on an American layout.
    | "t" -- The 'T' key on an American layout.
    | "u" -- The 'U' key on an American layout.
    | "v" -- The 'V' key on an American layout.
    | "w" -- The 'W' key on an American layout.
    | "x" -- The 'X' key on an American layout.
    | "y" -- The 'Y' key on an American layout.
    | "z" -- The 'Z' key on an American layout.
    | "1" -- The '1' key on an American layout.
    | "2" -- The '2' key on an American layout.
    | "3" -- The '3' key on an American layout.
    | "4" -- The '4' key on an American layout.
    | "5" -- The '5' key on an American layout.
    | "6" -- The '6' key on an American layout.
    | "7" -- The '7' key on an American layout.
    | "8" -- The '8' key on an American layout.
    | "9" -- The '9' key on an American layout.
    | "0" -- The '0' key on an American layout.
    | "return" -- The 'return' / 'enter' key on an American layout.
    | "escape" -- The 'escape' key on an American layout.
    | "backspace" -- The 'backspace' key on an American layout.
    | "tab" -- The 'tab' key on an American layout.
    | "space" -- The spacebar on an American layout.
    | "-" -- The minus key on an American layout.
    | "=" -- The equals key on an American layout.
    | "[" -- The left-bracket key on an American layout.
    | "]" -- The right-bracket key on an American layout.
    | "\" -- The backslash key on an American layout.
    | "nonus#" -- The non-U.S. hash scancode.
    | ";" -- The semicolon key on an American layout.
    | "'" -- The apostrophe key on an American layout.
    | "`" -- The back-tick / grave key on an American layout.
    | "," -- The comma key on an American layout.
    | "." -- The period key on an American layout.
    | "/" -- The forward-slash key on an American layout.
    | "capslock" -- The capslock key on an American layout.
    | "f1" -- The F1 key on an American layout.
    | "f2" -- The F2 key on an American layout.
    | "f3" -- The F3 key on an American layout.
    | "f4" -- The F4 key on an American layout.
    | "f5" -- The F5 key on an American layout.
    | "f6" -- The F6 key on an American layout.
    | "f7" -- The F7 key on an American layout.
    | "f8" -- The F8 key on an American layout.
    | "f9" -- The F9 key on an American layout.
    | "f10" -- The F10 key on an American layout.
    | "f11" -- The F11 key on an American layout.
    | "f12" -- The F12 key on an American layout.
    | "f13" -- The F13 key on an American layout.
    | "f14" -- The F14 key on an American layout.
    | "f15" -- The F15 key on an American layout.
    | "f16" -- The F16 key on an American layout.
    | "f17" -- The F17 key on an American layout.
    | "f18" -- The F18 key on an American layout.
    | "f19" -- The F19 key on an American layout.
    | "f20" -- The F20 key on an American layout.
    | "f21" -- The F21 key on an American layout.
    | "f22" -- The F22 key on an American layout.
    | "f23" -- The F23 key on an American layout.
    | "f24" -- The F24 key on an American layout.
    | "lctrl" -- The left control key on an American layout.
    | "lshift" -- The left shift key on an American layout.
    | "lalt" -- The left alt / option key on an American layout.
    | "lgui" -- The left GUI (command / windows / super) key on an American layout.
    | "rctrl" -- The right control key on an American layout.
    | "rshift" -- The right shift key on an American layout.
    | "ralt" -- The right alt / option key on an American layout.
    | "rgui" -- The right GUI (command / windows / super) key on an American layout.
    | "printscreen" -- The printscreen key on an American layout.
    | "scrolllock" -- The scroll-lock key on an American layout.
    | "pause" -- The pause key on an American layout.
    | "insert" -- The insert key on an American layout.
    | "home" -- The home key on an American layout.
    | "numlock" -- The numlock / clear key on an American layout.
    | "pageup" -- The page-up key on an American layout.
    | "delete" -- The forward-delete key on an American layout.
    | "end" -- The end key on an American layout.
    | "pagedown" -- The page-down key on an American layout.
    | "right" -- The right-arrow key on an American layout.
    | "left" -- The left-arrow key on an American layout.
    | "down" -- The down-arrow key on an American layout.
    | "up" -- The up-arrow key on an American layout.
    | "nonusbackslash" -- The non-U.S. backslash scancode.
    | "application" -- The application key on an American layout. Windows contextual menu, compose key.
    | "execute" -- The 'execute' key on an American layout.
    | "help" -- The 'help' key on an American layout.
    | "menu" -- The 'menu' key on an American layout.
    | "select" -- The 'select' key on an American layout.
    | "stop" -- The 'stop' key on an American layout.
    | "again" -- The 'again' key on an American layout.
    | "undo" -- The 'undo' key on an American layout.
    | "cut" -- The 'cut' key on an American layout.
    | "copy" -- The 'copy' key on an American layout.
    | "paste" -- The 'paste' key on an American layout.
    | "find" -- The 'find' key on an American layout.
    | "kp/" -- The keypad forward-slash key on an American layout.
    | "kp*" -- The keypad '*' key on an American layout.
    | "kp-" -- The keypad minus key on an American layout.
    | "kp+" -- The keypad plus key on an American layout.
    | "kp=" -- The keypad equals key on an American layout.
    | "kpenter" -- The keypad enter key on an American layout.
    | "kp1" -- The keypad '1' key on an American layout.
    | "kp2" -- The keypad '2' key on an American layout.
    | "kp3" -- The keypad '3' key on an American layout.
    | "kp4" -- The keypad '4' key on an American layout.
    | "kp5" -- The keypad '5' key on an American layout.
    | "kp6" -- The keypad '6' key on an American layout.
    | "kp7" -- The keypad '7' key on an American layout.
    | "kp8" -- The keypad '8' key on an American layout.
    | "kp9" -- The keypad '9' key on an American layout.
    | "kp0" -- The keypad '0' key on an American layout.
    | "kp." -- The keypad period key on an American layout.
    | "international1" -- The 1st international key on an American layout. Used on Asian keyboards.
    | "international2" -- The 2nd international key on an American layout.
    | "international3" -- The 3rd international  key on an American layout. Yen.
    | "international4" -- The 4th international key on an American layout.
    | "international5" -- The 5th international key on an American layout.
    | "international6" -- The 6th international key on an American layout.
    | "international7" -- The 7th international key on an American layout.
    | "international8" -- The 8th international key on an American layout.
    | "international9" -- The 9th international key on an American layout.
    | "lang1" -- Hangul/English toggle scancode.
    | "lang2" -- Hanja conversion scancode.
    | "lang3" -- Katakana scancode.
    | "lang4" -- Hiragana scancode.
    | "lang5" -- Zenkaku/Hankaku scancode.
    | "mute" -- The mute key on an American layout.
    | "volumeup" -- The volume up key on an American layout.
    | "volumedown" -- The volume down key on an American layout.
    | "audionext" -- The audio next track key on an American layout.
    | "audioprev" -- The audio previous track key on an American layout.
    | "audiostop" -- The audio stop key on an American layout.
    | "audioplay" -- The audio play key on an American layout.
    | "audiomute" -- The audio mute key on an American layout.
    | "mediaselect" -- The media select key on an American layout.
    | "www" -- The 'WWW' key on an American layout.
    | "mail" -- The Mail key on an American layout.
    | "calculator" -- The calculator key on an American layout.
    | "computer" -- The 'computer' key on an American layout.
    | "acsearch" -- The AC Search key on an American layout.
    | "achome" -- The AC Home key on an American layout.
    | "acback" -- The AC Back key on an American layout.
    | "acforward" -- The AC Forward key on an American layout.
    | "acstop" -- Th AC Stop key on an American layout.
    | "acrefresh" -- The AC Refresh key on an American layout.
    | "acbookmarks" -- The AC Bookmarks key on an American layout.
    | "power" -- The system power scancode.
    | "brightnessdown" -- The brightness-down scancode.
    | "brightnessup" -- The brightness-up scancode.
    | "displayswitch" -- The display switch scancode.
    | "kbdillumtoggle" -- The keyboard illumination toggle scancode.
    | "kbdillumdown" -- The keyboard illumination down scancode.
    | "kbdillumup" -- The keyboard illumination up scancode.
    | "eject" -- The eject scancode.
    | "sleep" -- The system sleep scancode.
    | "alterase" -- The alt-erase key on an American layout.
    | "sysreq" -- The sysreq key on an American layout.
    | "cancel" -- The 'cancel' key on an American layout.
    | "clear" -- The 'clear' key on an American layout.
    | "prior" -- The 'prior' key on an American layout.
    | "return2" -- The 'return2' key on an American layout.
    | "separator" -- The 'separator' key on an American layout.
    | "out" -- The 'out' key on an American layout.
    | "oper" -- The 'oper' key on an American layout.
    | "clearagain" -- The 'clearagain' key on an American layout.
    | "crsel" -- The 'crsel' key on an American layout.
    | "exsel" -- The 'exsel' key on an American layout.
    | "kp00" -- The keypad 00 key on an American layout.
    | "kp000" -- The keypad 000 key on an American layout.
    | "thsousandsseparator" -- The thousands-separator key on an American layout.
    | "decimalseparator" -- The decimal separator key on an American layout.
    | "currencyunit" -- The currency unit key on an American layout.
    | "currencysubunit" -- The currency sub-unit key on an American layout.
    | "app1" -- The 'app1' scancode.
    | "app2" -- The 'app2' scancode.
    | "unknown" -- An unknown key.

-- 
-- All the keys you can press. Note that some keys may not be available on your keyboard or system.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/KeyConstant)
-- 
key:
    | "a" -- The A key
    | "b" -- The B key
    | "c" -- The C key
    | "d" -- The D key
    | "e" -- The E key
    | "f" -- The F key
    | "g" -- The G key
    | "h" -- The H key
    | "i" -- The I key
    | "j" -- The J key
    | "k" -- The K key
    | "l" -- The L key
    | "m" -- The M key
    | "n" -- The N key
    | "o" -- The O key
    | "p" -- The P key
    | "q" -- The Q key
    | "r" -- The R key
    | "s" -- The S key
    | "t" -- The T key
    | "u" -- The U key
    | "v" -- The V key
    | "w" -- The W key
    | "x" -- The X key
    | "y" -- The Y key
    | "z" -- The Z key
    | "0" -- The zero key
    | "1" -- The one key
    | "2" -- The two key
    | "3" -- The three key
    | "4" -- The four key
    | "5" -- The five key
    | "6" -- The six key
    | "7" -- The seven key
    | "8" -- The eight key
    | "9" -- The nine key
    | "space" -- Space key
    | "!" -- Exclamation mark key
    | "\"" -- Double quote key
    | "#" -- Hash key
    | "$" -- Dollar key
    | "&" -- Ampersand key
    | "'" -- Single quote key
    | "(" -- Left parenthesis key
    | ")" -- Right parenthesis key
    | "*" -- Asterisk key
    | "+" -- Plus key
    | "," -- Comma key
    | "-" -- Hyphen-minus key
    | "." -- Full stop key
    | "/" -- Slash key
    | ":" -- Colon key
    | ";" -- Semicolon key
    | "<" -- Less-than key
    | "=" -- Equal key
    | ">" -- Greater-than key
    | "?" -- Question mark key
    | "@" -- At sign key
    | "[" -- Left square bracket key
    | "\" -- Backslash key
    | "]" -- Right square bracket key
    | "^" -- Caret key
    | "_" -- Underscore key
    | "`" -- Grave accent key
    | "kp0" -- The numpad zero key
    | "kp1" -- The numpad one key
    | "kp2" -- The numpad two key
    | "kp3" -- The numpad three key
    | "kp4" -- The numpad four key
    | "kp5" -- The numpad five key
    | "kp6" -- The numpad six key
    | "kp7" -- The numpad seven key
    | "kp8" -- The numpad eight key
    | "kp9" -- The numpad nine key
    | "kp." -- The numpad decimal point key
    | "kp/" -- The numpad division key
    | "kp*" -- The numpad multiplication key
    | "kp-" -- The numpad substraction key
    | "kp+" -- The numpad addition key
    | "kpenter" -- The numpad enter key
    | "kp=" -- The numpad equals key
    | "up" -- Up cursor key
    | "down" -- Down cursor key
    | "right" -- Right cursor key
    | "left" -- Left cursor key
    | "home" -- Home key
    | "end" -- End key
    | "pageup" -- Page up key
    | "pagedown" -- Page down key
    | "insert" -- Insert key
    | "backspace" -- Backspace key
    | "tab" -- Tab key
    | "clear" -- Clear key
    | "return" -- Return key
    | "delete" -- Delete key
    | "f1" -- The 1st function key
    | "f2" -- The 2nd function key
    | "f3" -- The 3rd function key
    | "f4" -- The 4th function key
    | "f5" -- The 5th function key
    | "f6" -- The 6th function key
    | "f7" -- The 7th function key
    | "f8" -- The 8th function key
    | "f9" -- The 9th function key
    | "f10" -- The 10th function key
    | "f11" -- The 11th function key
    | "f12" -- The 12th function key
    | "f13" -- The 13th function key
    | "f14" -- The 14th function key
    | "f15" -- The 15th function key
    | "numlock" -- Num-lock key
    | "capslock" -- Caps-lock key
    | "scrollock" -- Scroll-lock key
    | "rshift" -- Right shift key
    | "lshift" -- Left shift key
    | "rctrl" -- Right control key
    | "lctrl" -- Left control key
    | "ralt" -- Right alt key
    | "lalt" -- Left alt key
    | "rmeta" -- Right meta key
    | "lmeta" -- Left meta key
    | "lsuper" -- Left super key
    | "rsuper" -- Right super key
    | "mode" -- Mode key
    | "compose" -- Compose key
    | "pause" -- Pause key
    | "escape" -- Escape key
    | "help" -- Help key
    | "print" -- Print key
    | "sysreq" -- System request key
    | "break" -- Break key
    | "menu" -- Menu key
    | "power" -- Power key
    | "euro" -- Euro (&euro;) key
    | "undo" -- Undo key
    | "www" -- WWW key
    | "mail" -- Mail key
    | "calculator" -- Calculator key
    | "appsearch" -- Application search key
    | "apphome" -- Application home key
    | "appback" -- Application back key
    | "appforward" -- Application forward key
    | "apprefresh" -- Application refresh key
    | "appbookmarks" -- Application bookmarks key
```

## getScancodeFromKey


```lua
function love.keyboard.getScancodeFromKey(key: "!"|"#"|"$"|"&"|"'"...(+139))
  -> scancode: "'"|","|"-"|"."|"/"...(+189)
```


Gets the hardware scancode corresponding to the given key.

Unlike key constants, Scancodes are keyboard layout-independent. For example the scancode 'w' will be generated if the key in the same place as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are.

Scancodes are useful for creating default controls that have the same physical locations on on all systems.


[Open in Browser](https://love2d.org/wiki/love.keyboard.getScancodeFromKey)

@*param* `key` — The key to get the scancode from.

@*return* `scancode` — The scancode corresponding to the given key, or 'unknown' if the given key has no known physical representation on the current system.

```lua
-- 
-- All the keys you can press. Note that some keys may not be available on your keyboard or system.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/KeyConstant)
-- 
key:
    | "a" -- The A key
    | "b" -- The B key
    | "c" -- The C key
    | "d" -- The D key
    | "e" -- The E key
    | "f" -- The F key
    | "g" -- The G key
    | "h" -- The H key
    | "i" -- The I key
    | "j" -- The J key
    | "k" -- The K key
    | "l" -- The L key
    | "m" -- The M key
    | "n" -- The N key
    | "o" -- The O key
    | "p" -- The P key
    | "q" -- The Q key
    | "r" -- The R key
    | "s" -- The S key
    | "t" -- The T key
    | "u" -- The U key
    | "v" -- The V key
    | "w" -- The W key
    | "x" -- The X key
    | "y" -- The Y key
    | "z" -- The Z key
    | "0" -- The zero key
    | "1" -- The one key
    | "2" -- The two key
    | "3" -- The three key
    | "4" -- The four key
    | "5" -- The five key
    | "6" -- The six key
    | "7" -- The seven key
    | "8" -- The eight key
    | "9" -- The nine key
    | "space" -- Space key
    | "!" -- Exclamation mark key
    | "\"" -- Double quote key
    | "#" -- Hash key
    | "$" -- Dollar key
    | "&" -- Ampersand key
    | "'" -- Single quote key
    | "(" -- Left parenthesis key
    | ")" -- Right parenthesis key
    | "*" -- Asterisk key
    | "+" -- Plus key
    | "," -- Comma key
    | "-" -- Hyphen-minus key
    | "." -- Full stop key
    | "/" -- Slash key
    | ":" -- Colon key
    | ";" -- Semicolon key
    | "<" -- Less-than key
    | "=" -- Equal key
    | ">" -- Greater-than key
    | "?" -- Question mark key
    | "@" -- At sign key
    | "[" -- Left square bracket key
    | "\" -- Backslash key
    | "]" -- Right square bracket key
    | "^" -- Caret key
    | "_" -- Underscore key
    | "`" -- Grave accent key
    | "kp0" -- The numpad zero key
    | "kp1" -- The numpad one key
    | "kp2" -- The numpad two key
    | "kp3" -- The numpad three key
    | "kp4" -- The numpad four key
    | "kp5" -- The numpad five key
    | "kp6" -- The numpad six key
    | "kp7" -- The numpad seven key
    | "kp8" -- The numpad eight key
    | "kp9" -- The numpad nine key
    | "kp." -- The numpad decimal point key
    | "kp/" -- The numpad division key
    | "kp*" -- The numpad multiplication key
    | "kp-" -- The numpad substraction key
    | "kp+" -- The numpad addition key
    | "kpenter" -- The numpad enter key
    | "kp=" -- The numpad equals key
    | "up" -- Up cursor key
    | "down" -- Down cursor key
    | "right" -- Right cursor key
    | "left" -- Left cursor key
    | "home" -- Home key
    | "end" -- End key
    | "pageup" -- Page up key
    | "pagedown" -- Page down key
    | "insert" -- Insert key
    | "backspace" -- Backspace key
    | "tab" -- Tab key
    | "clear" -- Clear key
    | "return" -- Return key
    | "delete" -- Delete key
    | "f1" -- The 1st function key
    | "f2" -- The 2nd function key
    | "f3" -- The 3rd function key
    | "f4" -- The 4th function key
    | "f5" -- The 5th function key
    | "f6" -- The 6th function key
    | "f7" -- The 7th function key
    | "f8" -- The 8th function key
    | "f9" -- The 9th function key
    | "f10" -- The 10th function key
    | "f11" -- The 11th function key
    | "f12" -- The 12th function key
    | "f13" -- The 13th function key
    | "f14" -- The 14th function key
    | "f15" -- The 15th function key
    | "numlock" -- Num-lock key
    | "capslock" -- Caps-lock key
    | "scrollock" -- Scroll-lock key
    | "rshift" -- Right shift key
    | "lshift" -- Left shift key
    | "rctrl" -- Right control key
    | "lctrl" -- Left control key
    | "ralt" -- Right alt key
    | "lalt" -- Left alt key
    | "rmeta" -- Right meta key
    | "lmeta" -- Left meta key
    | "lsuper" -- Left super key
    | "rsuper" -- Right super key
    | "mode" -- Mode key
    | "compose" -- Compose key
    | "pause" -- Pause key
    | "escape" -- Escape key
    | "help" -- Help key
    | "print" -- Print key
    | "sysreq" -- System request key
    | "break" -- Break key
    | "menu" -- Menu key
    | "power" -- Power key
    | "euro" -- Euro (&euro;) key
    | "undo" -- Undo key
    | "www" -- WWW key
    | "mail" -- Mail key
    | "calculator" -- Calculator key
    | "appsearch" -- Application search key
    | "apphome" -- Application home key
    | "appback" -- Application back key
    | "appforward" -- Application forward key
    | "apprefresh" -- Application refresh key
    | "appbookmarks" -- Application bookmarks key

-- 
-- Keyboard scancodes.
-- 
-- Scancodes are keyboard layout-independent, so the scancode "w" will be generated if the key in the same place as the "w" key on an American QWERTY keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are.
-- 
-- Using scancodes, rather than keycodes, is useful because keyboards with layouts differing from the US/UK layout(s) might have keys that generate 'unknown' keycodes, but the scancodes will still be detected. This however would necessitate having a list for each keyboard layout one would choose to support.
-- 
-- One could use textinput or textedited instead, but those only give back the end result of keys used, i.e. you can't get modifiers on their own from it, only the final symbols that were generated.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/Scancode)
-- 
scancode:
    | "a" -- The 'A' key on an American layout.
    | "b" -- The 'B' key on an American layout.
    | "c" -- The 'C' key on an American layout.
    | "d" -- The 'D' key on an American layout.
    | "e" -- The 'E' key on an American layout.
    | "f" -- The 'F' key on an American layout.
    | "g" -- The 'G' key on an American layout.
    | "h" -- The 'H' key on an American layout.
    | "i" -- The 'I' key on an American layout.
    | "j" -- The 'J' key on an American layout.
    | "k" -- The 'K' key on an American layout.
    | "l" -- The 'L' key on an American layout.
    | "m" -- The 'M' key on an American layout.
    | "n" -- The 'N' key on an American layout.
    | "o" -- The 'O' key on an American layout.
    | "p" -- The 'P' key on an American layout.
    | "q" -- The 'Q' key on an American layout.
    | "r" -- The 'R' key on an American layout.
    | "s" -- The 'S' key on an American layout.
    | "t" -- The 'T' key on an American layout.
    | "u" -- The 'U' key on an American layout.
    | "v" -- The 'V' key on an American layout.
    | "w" -- The 'W' key on an American layout.
    | "x" -- The 'X' key on an American layout.
    | "y" -- The 'Y' key on an American layout.
    | "z" -- The 'Z' key on an American layout.
    | "1" -- The '1' key on an American layout.
    | "2" -- The '2' key on an American layout.
    | "3" -- The '3' key on an American layout.
    | "4" -- The '4' key on an American layout.
    | "5" -- The '5' key on an American layout.
    | "6" -- The '6' key on an American layout.
    | "7" -- The '7' key on an American layout.
    | "8" -- The '8' key on an American layout.
    | "9" -- The '9' key on an American layout.
    | "0" -- The '0' key on an American layout.
    | "return" -- The 'return' / 'enter' key on an American layout.
    | "escape" -- The 'escape' key on an American layout.
    | "backspace" -- The 'backspace' key on an American layout.
    | "tab" -- The 'tab' key on an American layout.
    | "space" -- The spacebar on an American layout.
    | "-" -- The minus key on an American layout.
    | "=" -- The equals key on an American layout.
    | "[" -- The left-bracket key on an American layout.
    | "]" -- The right-bracket key on an American layout.
    | "\" -- The backslash key on an American layout.
    | "nonus#" -- The non-U.S. hash scancode.
    | ";" -- The semicolon key on an American layout.
    | "'" -- The apostrophe key on an American layout.
    | "`" -- The back-tick / grave key on an American layout.
    | "," -- The comma key on an American layout.
    | "." -- The period key on an American layout.
    | "/" -- The forward-slash key on an American layout.
    | "capslock" -- The capslock key on an American layout.
    | "f1" -- The F1 key on an American layout.
    | "f2" -- The F2 key on an American layout.
    | "f3" -- The F3 key on an American layout.
    | "f4" -- The F4 key on an American layout.
    | "f5" -- The F5 key on an American layout.
    | "f6" -- The F6 key on an American layout.
    | "f7" -- The F7 key on an American layout.
    | "f8" -- The F8 key on an American layout.
    | "f9" -- The F9 key on an American layout.
    | "f10" -- The F10 key on an American layout.
    | "f11" -- The F11 key on an American layout.
    | "f12" -- The F12 key on an American layout.
    | "f13" -- The F13 key on an American layout.
    | "f14" -- The F14 key on an American layout.
    | "f15" -- The F15 key on an American layout.
    | "f16" -- The F16 key on an American layout.
    | "f17" -- The F17 key on an American layout.
    | "f18" -- The F18 key on an American layout.
    | "f19" -- The F19 key on an American layout.
    | "f20" -- The F20 key on an American layout.
    | "f21" -- The F21 key on an American layout.
    | "f22" -- The F22 key on an American layout.
    | "f23" -- The F23 key on an American layout.
    | "f24" -- The F24 key on an American layout.
    | "lctrl" -- The left control key on an American layout.
    | "lshift" -- The left shift key on an American layout.
    | "lalt" -- The left alt / option key on an American layout.
    | "lgui" -- The left GUI (command / windows / super) key on an American layout.
    | "rctrl" -- The right control key on an American layout.
    | "rshift" -- The right shift key on an American layout.
    | "ralt" -- The right alt / option key on an American layout.
    | "rgui" -- The right GUI (command / windows / super) key on an American layout.
    | "printscreen" -- The printscreen key on an American layout.
    | "scrolllock" -- The scroll-lock key on an American layout.
    | "pause" -- The pause key on an American layout.
    | "insert" -- The insert key on an American layout.
    | "home" -- The home key on an American layout.
    | "numlock" -- The numlock / clear key on an American layout.
    | "pageup" -- The page-up key on an American layout.
    | "delete" -- The forward-delete key on an American layout.
    | "end" -- The end key on an American layout.
    | "pagedown" -- The page-down key on an American layout.
    | "right" -- The right-arrow key on an American layout.
    | "left" -- The left-arrow key on an American layout.
    | "down" -- The down-arrow key on an American layout.
    | "up" -- The up-arrow key on an American layout.
    | "nonusbackslash" -- The non-U.S. backslash scancode.
    | "application" -- The application key on an American layout. Windows contextual menu, compose key.
    | "execute" -- The 'execute' key on an American layout.
    | "help" -- The 'help' key on an American layout.
    | "menu" -- The 'menu' key on an American layout.
    | "select" -- The 'select' key on an American layout.
    | "stop" -- The 'stop' key on an American layout.
    | "again" -- The 'again' key on an American layout.
    | "undo" -- The 'undo' key on an American layout.
    | "cut" -- The 'cut' key on an American layout.
    | "copy" -- The 'copy' key on an American layout.
    | "paste" -- The 'paste' key on an American layout.
    | "find" -- The 'find' key on an American layout.
    | "kp/" -- The keypad forward-slash key on an American layout.
    | "kp*" -- The keypad '*' key on an American layout.
    | "kp-" -- The keypad minus key on an American layout.
    | "kp+" -- The keypad plus key on an American layout.
    | "kp=" -- The keypad equals key on an American layout.
    | "kpenter" -- The keypad enter key on an American layout.
    | "kp1" -- The keypad '1' key on an American layout.
    | "kp2" -- The keypad '2' key on an American layout.
    | "kp3" -- The keypad '3' key on an American layout.
    | "kp4" -- The keypad '4' key on an American layout.
    | "kp5" -- The keypad '5' key on an American layout.
    | "kp6" -- The keypad '6' key on an American layout.
    | "kp7" -- The keypad '7' key on an American layout.
    | "kp8" -- The keypad '8' key on an American layout.
    | "kp9" -- The keypad '9' key on an American layout.
    | "kp0" -- The keypad '0' key on an American layout.
    | "kp." -- The keypad period key on an American layout.
    | "international1" -- The 1st international key on an American layout. Used on Asian keyboards.
    | "international2" -- The 2nd international key on an American layout.
    | "international3" -- The 3rd international  key on an American layout. Yen.
    | "international4" -- The 4th international key on an American layout.
    | "international5" -- The 5th international key on an American layout.
    | "international6" -- The 6th international key on an American layout.
    | "international7" -- The 7th international key on an American layout.
    | "international8" -- The 8th international key on an American layout.
    | "international9" -- The 9th international key on an American layout.
    | "lang1" -- Hangul/English toggle scancode.
    | "lang2" -- Hanja conversion scancode.
    | "lang3" -- Katakana scancode.
    | "lang4" -- Hiragana scancode.
    | "lang5" -- Zenkaku/Hankaku scancode.
    | "mute" -- The mute key on an American layout.
    | "volumeup" -- The volume up key on an American layout.
    | "volumedown" -- The volume down key on an American layout.
    | "audionext" -- The audio next track key on an American layout.
    | "audioprev" -- The audio previous track key on an American layout.
    | "audiostop" -- The audio stop key on an American layout.
    | "audioplay" -- The audio play key on an American layout.
    | "audiomute" -- The audio mute key on an American layout.
    | "mediaselect" -- The media select key on an American layout.
    | "www" -- The 'WWW' key on an American layout.
    | "mail" -- The Mail key on an American layout.
    | "calculator" -- The calculator key on an American layout.
    | "computer" -- The 'computer' key on an American layout.
    | "acsearch" -- The AC Search key on an American layout.
    | "achome" -- The AC Home key on an American layout.
    | "acback" -- The AC Back key on an American layout.
    | "acforward" -- The AC Forward key on an American layout.
    | "acstop" -- Th AC Stop key on an American layout.
    | "acrefresh" -- The AC Refresh key on an American layout.
    | "acbookmarks" -- The AC Bookmarks key on an American layout.
    | "power" -- The system power scancode.
    | "brightnessdown" -- The brightness-down scancode.
    | "brightnessup" -- The brightness-up scancode.
    | "displayswitch" -- The display switch scancode.
    | "kbdillumtoggle" -- The keyboard illumination toggle scancode.
    | "kbdillumdown" -- The keyboard illumination down scancode.
    | "kbdillumup" -- The keyboard illumination up scancode.
    | "eject" -- The eject scancode.
    | "sleep" -- The system sleep scancode.
    | "alterase" -- The alt-erase key on an American layout.
    | "sysreq" -- The sysreq key on an American layout.
    | "cancel" -- The 'cancel' key on an American layout.
    | "clear" -- The 'clear' key on an American layout.
    | "prior" -- The 'prior' key on an American layout.
    | "return2" -- The 'return2' key on an American layout.
    | "separator" -- The 'separator' key on an American layout.
    | "out" -- The 'out' key on an American layout.
    | "oper" -- The 'oper' key on an American layout.
    | "clearagain" -- The 'clearagain' key on an American layout.
    | "crsel" -- The 'crsel' key on an American layout.
    | "exsel" -- The 'exsel' key on an American layout.
    | "kp00" -- The keypad 00 key on an American layout.
    | "kp000" -- The keypad 000 key on an American layout.
    | "thsousandsseparator" -- The thousands-separator key on an American layout.
    | "decimalseparator" -- The decimal separator key on an American layout.
    | "currencyunit" -- The currency unit key on an American layout.
    | "currencysubunit" -- The currency sub-unit key on an American layout.
    | "app1" -- The 'app1' scancode.
    | "app2" -- The 'app2' scancode.
    | "unknown" -- An unknown key.
```

## hasKeyRepeat


```lua
function love.keyboard.hasKeyRepeat()
  -> enabled: boolean
```


Gets whether key repeat is enabled.


[Open in Browser](https://love2d.org/wiki/love.keyboard.hasKeyRepeat)

@*return* `enabled` — Whether key repeat is enabled.

## hasScreenKeyboard


```lua
function love.keyboard.hasScreenKeyboard()
  -> supported: boolean
```


Gets whether screen keyboard is supported.


[Open in Browser](https://love2d.org/wiki/love.keyboard.hasScreenKeyboard)

@*return* `supported` — Whether screen keyboard is supported.

## hasTextInput


```lua
function love.keyboard.hasTextInput()
  -> enabled: boolean
```


Gets whether text input events are enabled.


[Open in Browser](https://love2d.org/wiki/love.keyboard.hasTextInput)

@*return* `enabled` — Whether text input events are enabled.

## isDown


```lua
function love.keyboard.isDown(key: "!"|"#"|"$"|"&"|"'"...(+139))
  -> down: boolean
```


Checks whether a certain key is down. Not to be confused with love.keypressed or love.keyreleased.


[Open in Browser](https://love2d.org/wiki/love.keyboard.isDown)


---

@*param* `key` — The key to check.

@*return* `down` — True if the key is down, false if not.

```lua
-- 
-- All the keys you can press. Note that some keys may not be available on your keyboard or system.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/KeyConstant)
-- 
key:
    | "a" -- The A key
    | "b" -- The B key
    | "c" -- The C key
    | "d" -- The D key
    | "e" -- The E key
    | "f" -- The F key
    | "g" -- The G key
    | "h" -- The H key
    | "i" -- The I key
    | "j" -- The J key
    | "k" -- The K key
    | "l" -- The L key
    | "m" -- The M key
    | "n" -- The N key
    | "o" -- The O key
    | "p" -- The P key
    | "q" -- The Q key
    | "r" -- The R key
    | "s" -- The S key
    | "t" -- The T key
    | "u" -- The U key
    | "v" -- The V key
    | "w" -- The W key
    | "x" -- The X key
    | "y" -- The Y key
    | "z" -- The Z key
    | "0" -- The zero key
    | "1" -- The one key
    | "2" -- The two key
    | "3" -- The three key
    | "4" -- The four key
    | "5" -- The five key
    | "6" -- The six key
    | "7" -- The seven key
    | "8" -- The eight key
    | "9" -- The nine key
    | "space" -- Space key
    | "!" -- Exclamation mark key
    | "\"" -- Double quote key
    | "#" -- Hash key
    | "$" -- Dollar key
    | "&" -- Ampersand key
    | "'" -- Single quote key
    | "(" -- Left parenthesis key
    | ")" -- Right parenthesis key
    | "*" -- Asterisk key
    | "+" -- Plus key
    | "," -- Comma key
    | "-" -- Hyphen-minus key
    | "." -- Full stop key
    | "/" -- Slash key
    | ":" -- Colon key
    | ";" -- Semicolon key
    | "<" -- Less-than key
    | "=" -- Equal key
    | ">" -- Greater-than key
    | "?" -- Question mark key
    | "@" -- At sign key
    | "[" -- Left square bracket key
    | "\" -- Backslash key
    | "]" -- Right square bracket key
    | "^" -- Caret key
    | "_" -- Underscore key
    | "`" -- Grave accent key
    | "kp0" -- The numpad zero key
    | "kp1" -- The numpad one key
    | "kp2" -- The numpad two key
    | "kp3" -- The numpad three key
    | "kp4" -- The numpad four key
    | "kp5" -- The numpad five key
    | "kp6" -- The numpad six key
    | "kp7" -- The numpad seven key
    | "kp8" -- The numpad eight key
    | "kp9" -- The numpad nine key
    | "kp." -- The numpad decimal point key
    | "kp/" -- The numpad division key
    | "kp*" -- The numpad multiplication key
    | "kp-" -- The numpad substraction key
    | "kp+" -- The numpad addition key
    | "kpenter" -- The numpad enter key
    | "kp=" -- The numpad equals key
    | "up" -- Up cursor key
    | "down" -- Down cursor key
    | "right" -- Right cursor key
    | "left" -- Left cursor key
    | "home" -- Home key
    | "end" -- End key
    | "pageup" -- Page up key
    | "pagedown" -- Page down key
    | "insert" -- Insert key
    | "backspace" -- Backspace key
    | "tab" -- Tab key
    | "clear" -- Clear key
    | "return" -- Return key
    | "delete" -- Delete key
    | "f1" -- The 1st function key
    | "f2" -- The 2nd function key
    | "f3" -- The 3rd function key
    | "f4" -- The 4th function key
    | "f5" -- The 5th function key
    | "f6" -- The 6th function key
    | "f7" -- The 7th function key
    | "f8" -- The 8th function key
    | "f9" -- The 9th function key
    | "f10" -- The 10th function key
    | "f11" -- The 11th function key
    | "f12" -- The 12th function key
    | "f13" -- The 13th function key
    | "f14" -- The 14th function key
    | "f15" -- The 15th function key
    | "numlock" -- Num-lock key
    | "capslock" -- Caps-lock key
    | "scrollock" -- Scroll-lock key
    | "rshift" -- Right shift key
    | "lshift" -- Left shift key
    | "rctrl" -- Right control key
    | "lctrl" -- Left control key
    | "ralt" -- Right alt key
    | "lalt" -- Left alt key
    | "rmeta" -- Right meta key
    | "lmeta" -- Left meta key
    | "lsuper" -- Left super key
    | "rsuper" -- Right super key
    | "mode" -- Mode key
    | "compose" -- Compose key
    | "pause" -- Pause key
    | "escape" -- Escape key
    | "help" -- Help key
    | "print" -- Print key
    | "sysreq" -- System request key
    | "break" -- Break key
    | "menu" -- Menu key
    | "power" -- Power key
    | "euro" -- Euro (&euro;) key
    | "undo" -- Undo key
    | "www" -- WWW key
    | "mail" -- Mail key
    | "calculator" -- Calculator key
    | "appsearch" -- Application search key
    | "apphome" -- Application home key
    | "appback" -- Application back key
    | "appforward" -- Application forward key
    | "apprefresh" -- Application refresh key
    | "appbookmarks" -- Application bookmarks key
```

## isScancodeDown


```lua
function love.keyboard.isScancodeDown(scancode: "'"|","|"-"|"."|"/"...(+189), ..."'"|","|"-"|"."|"/"...(+189))
  -> down: boolean
```


Checks whether the specified Scancodes are pressed. Not to be confused with love.keypressed or love.keyreleased.

Unlike regular KeyConstants, Scancodes are keyboard layout-independent. The scancode 'w' is used if the key in the same place as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are.


[Open in Browser](https://love2d.org/wiki/love.keyboard.isScancodeDown)

@*param* `scancode` — A Scancode to check.

@*return* `down` — True if any supplied Scancode is down, false if not.

```lua
-- 
-- Keyboard scancodes.
-- 
-- Scancodes are keyboard layout-independent, so the scancode "w" will be generated if the key in the same place as the "w" key on an American QWERTY keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are.
-- 
-- Using scancodes, rather than keycodes, is useful because keyboards with layouts differing from the US/UK layout(s) might have keys that generate 'unknown' keycodes, but the scancodes will still be detected. This however would necessitate having a list for each keyboard layout one would choose to support.
-- 
-- One could use textinput or textedited instead, but those only give back the end result of keys used, i.e. you can't get modifiers on their own from it, only the final symbols that were generated.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/Scancode)
-- 
scancode:
    | "a" -- The 'A' key on an American layout.
    | "b" -- The 'B' key on an American layout.
    | "c" -- The 'C' key on an American layout.
    | "d" -- The 'D' key on an American layout.
    | "e" -- The 'E' key on an American layout.
    | "f" -- The 'F' key on an American layout.
    | "g" -- The 'G' key on an American layout.
    | "h" -- The 'H' key on an American layout.
    | "i" -- The 'I' key on an American layout.
    | "j" -- The 'J' key on an American layout.
    | "k" -- The 'K' key on an American layout.
    | "l" -- The 'L' key on an American layout.
    | "m" -- The 'M' key on an American layout.
    | "n" -- The 'N' key on an American layout.
    | "o" -- The 'O' key on an American layout.
    | "p" -- The 'P' key on an American layout.
    | "q" -- The 'Q' key on an American layout.
    | "r" -- The 'R' key on an American layout.
    | "s" -- The 'S' key on an American layout.
    | "t" -- The 'T' key on an American layout.
    | "u" -- The 'U' key on an American layout.
    | "v" -- The 'V' key on an American layout.
    | "w" -- The 'W' key on an American layout.
    | "x" -- The 'X' key on an American layout.
    | "y" -- The 'Y' key on an American layout.
    | "z" -- The 'Z' key on an American layout.
    | "1" -- The '1' key on an American layout.
    | "2" -- The '2' key on an American layout.
    | "3" -- The '3' key on an American layout.
    | "4" -- The '4' key on an American layout.
    | "5" -- The '5' key on an American layout.
    | "6" -- The '6' key on an American layout.
    | "7" -- The '7' key on an American layout.
    | "8" -- The '8' key on an American layout.
    | "9" -- The '9' key on an American layout.
    | "0" -- The '0' key on an American layout.
    | "return" -- The 'return' / 'enter' key on an American layout.
    | "escape" -- The 'escape' key on an American layout.
    | "backspace" -- The 'backspace' key on an American layout.
    | "tab" -- The 'tab' key on an American layout.
    | "space" -- The spacebar on an American layout.
    | "-" -- The minus key on an American layout.
    | "=" -- The equals key on an American layout.
    | "[" -- The left-bracket key on an American layout.
    | "]" -- The right-bracket key on an American layout.
    | "\" -- The backslash key on an American layout.
    | "nonus#" -- The non-U.S. hash scancode.
    | ";" -- The semicolon key on an American layout.
    | "'" -- The apostrophe key on an American layout.
    | "`" -- The back-tick / grave key on an American layout.
    | "," -- The comma key on an American layout.
    | "." -- The period key on an American layout.
    | "/" -- The forward-slash key on an American layout.
    | "capslock" -- The capslock key on an American layout.
    | "f1" -- The F1 key on an American layout.
    | "f2" -- The F2 key on an American layout.
    | "f3" -- The F3 key on an American layout.
    | "f4" -- The F4 key on an American layout.
    | "f5" -- The F5 key on an American layout.
    | "f6" -- The F6 key on an American layout.
    | "f7" -- The F7 key on an American layout.
    | "f8" -- The F8 key on an American layout.
    | "f9" -- The F9 key on an American layout.
    | "f10" -- The F10 key on an American layout.
    | "f11" -- The F11 key on an American layout.
    | "f12" -- The F12 key on an American layout.
    | "f13" -- The F13 key on an American layout.
    | "f14" -- The F14 key on an American layout.
    | "f15" -- The F15 key on an American layout.
    | "f16" -- The F16 key on an American layout.
    | "f17" -- The F17 key on an American layout.
    | "f18" -- The F18 key on an American layout.
    | "f19" -- The F19 key on an American layout.
    | "f20" -- The F20 key on an American layout.
    | "f21" -- The F21 key on an American layout.
    | "f22" -- The F22 key on an American layout.
    | "f23" -- The F23 key on an American layout.
    | "f24" -- The F24 key on an American layout.
    | "lctrl" -- The left control key on an American layout.
    | "lshift" -- The left shift key on an American layout.
    | "lalt" -- The left alt / option key on an American layout.
    | "lgui" -- The left GUI (command / windows / super) key on an American layout.
    | "rctrl" -- The right control key on an American layout.
    | "rshift" -- The right shift key on an American layout.
    | "ralt" -- The right alt / option key on an American layout.
    | "rgui" -- The right GUI (command / windows / super) key on an American layout.
    | "printscreen" -- The printscreen key on an American layout.
    | "scrolllock" -- The scroll-lock key on an American layout.
    | "pause" -- The pause key on an American layout.
    | "insert" -- The insert key on an American layout.
    | "home" -- The home key on an American layout.
    | "numlock" -- The numlock / clear key on an American layout.
    | "pageup" -- The page-up key on an American layout.
    | "delete" -- The forward-delete key on an American layout.
    | "end" -- The end key on an American layout.
    | "pagedown" -- The page-down key on an American layout.
    | "right" -- The right-arrow key on an American layout.
    | "left" -- The left-arrow key on an American layout.
    | "down" -- The down-arrow key on an American layout.
    | "up" -- The up-arrow key on an American layout.
    | "nonusbackslash" -- The non-U.S. backslash scancode.
    | "application" -- The application key on an American layout. Windows contextual menu, compose key.
    | "execute" -- The 'execute' key on an American layout.
    | "help" -- The 'help' key on an American layout.
    | "menu" -- The 'menu' key on an American layout.
    | "select" -- The 'select' key on an American layout.
    | "stop" -- The 'stop' key on an American layout.
    | "again" -- The 'again' key on an American layout.
    | "undo" -- The 'undo' key on an American layout.
    | "cut" -- The 'cut' key on an American layout.
    | "copy" -- The 'copy' key on an American layout.
    | "paste" -- The 'paste' key on an American layout.
    | "find" -- The 'find' key on an American layout.
    | "kp/" -- The keypad forward-slash key on an American layout.
    | "kp*" -- The keypad '*' key on an American layout.
    | "kp-" -- The keypad minus key on an American layout.
    | "kp+" -- The keypad plus key on an American layout.
    | "kp=" -- The keypad equals key on an American layout.
    | "kpenter" -- The keypad enter key on an American layout.
    | "kp1" -- The keypad '1' key on an American layout.
    | "kp2" -- The keypad '2' key on an American layout.
    | "kp3" -- The keypad '3' key on an American layout.
    | "kp4" -- The keypad '4' key on an American layout.
    | "kp5" -- The keypad '5' key on an American layout.
    | "kp6" -- The keypad '6' key on an American layout.
    | "kp7" -- The keypad '7' key on an American layout.
    | "kp8" -- The keypad '8' key on an American layout.
    | "kp9" -- The keypad '9' key on an American layout.
    | "kp0" -- The keypad '0' key on an American layout.
    | "kp." -- The keypad period key on an American layout.
    | "international1" -- The 1st international key on an American layout. Used on Asian keyboards.
    | "international2" -- The 2nd international key on an American layout.
    | "international3" -- The 3rd international  key on an American layout. Yen.
    | "international4" -- The 4th international key on an American layout.
    | "international5" -- The 5th international key on an American layout.
    | "international6" -- The 6th international key on an American layout.
    | "international7" -- The 7th international key on an American layout.
    | "international8" -- The 8th international key on an American layout.
    | "international9" -- The 9th international key on an American layout.
    | "lang1" -- Hangul/English toggle scancode.
    | "lang2" -- Hanja conversion scancode.
    | "lang3" -- Katakana scancode.
    | "lang4" -- Hiragana scancode.
    | "lang5" -- Zenkaku/Hankaku scancode.
    | "mute" -- The mute key on an American layout.
    | "volumeup" -- The volume up key on an American layout.
    | "volumedown" -- The volume down key on an American layout.
    | "audionext" -- The audio next track key on an American layout.
    | "audioprev" -- The audio previous track key on an American layout.
    | "audiostop" -- The audio stop key on an American layout.
    | "audioplay" -- The audio play key on an American layout.
    | "audiomute" -- The audio mute key on an American layout.
    | "mediaselect" -- The media select key on an American layout.
    | "www" -- The 'WWW' key on an American layout.
    | "mail" -- The Mail key on an American layout.
    | "calculator" -- The calculator key on an American layout.
    | "computer" -- The 'computer' key on an American layout.
    | "acsearch" -- The AC Search key on an American layout.
    | "achome" -- The AC Home key on an American layout.
    | "acback" -- The AC Back key on an American layout.
    | "acforward" -- The AC Forward key on an American layout.
    | "acstop" -- Th AC Stop key on an American layout.
    | "acrefresh" -- The AC Refresh key on an American layout.
    | "acbookmarks" -- The AC Bookmarks key on an American layout.
    | "power" -- The system power scancode.
    | "brightnessdown" -- The brightness-down scancode.
    | "brightnessup" -- The brightness-up scancode.
    | "displayswitch" -- The display switch scancode.
    | "kbdillumtoggle" -- The keyboard illumination toggle scancode.
    | "kbdillumdown" -- The keyboard illumination down scancode.
    | "kbdillumup" -- The keyboard illumination up scancode.
    | "eject" -- The eject scancode.
    | "sleep" -- The system sleep scancode.
    | "alterase" -- The alt-erase key on an American layout.
    | "sysreq" -- The sysreq key on an American layout.
    | "cancel" -- The 'cancel' key on an American layout.
    | "clear" -- The 'clear' key on an American layout.
    | "prior" -- The 'prior' key on an American layout.
    | "return2" -- The 'return2' key on an American layout.
    | "separator" -- The 'separator' key on an American layout.
    | "out" -- The 'out' key on an American layout.
    | "oper" -- The 'oper' key on an American layout.
    | "clearagain" -- The 'clearagain' key on an American layout.
    | "crsel" -- The 'crsel' key on an American layout.
    | "exsel" -- The 'exsel' key on an American layout.
    | "kp00" -- The keypad 00 key on an American layout.
    | "kp000" -- The keypad 000 key on an American layout.
    | "thsousandsseparator" -- The thousands-separator key on an American layout.
    | "decimalseparator" -- The decimal separator key on an American layout.
    | "currencyunit" -- The currency unit key on an American layout.
    | "currencysubunit" -- The currency sub-unit key on an American layout.
    | "app1" -- The 'app1' scancode.
    | "app2" -- The 'app2' scancode.
    | "unknown" -- An unknown key.
```

## setKeyRepeat


```lua
function love.keyboard.setKeyRepeat(enable: boolean)
```


Enables or disables key repeat for love.keypressed. It is disabled by default.


[Open in Browser](https://love2d.org/wiki/love.keyboard.setKeyRepeat)

@*param* `enable` — Whether repeat keypress events should be enabled when a key is held down.

## setTextInput


```lua
function love.keyboard.setTextInput(enable: boolean)
```


Enables or disables text input events. It is enabled by default on Windows, Mac, and Linux, and disabled by default on iOS and Android.

On touch devices, this shows the system's native on-screen keyboard when it's enabled.


[Open in Browser](https://love2d.org/wiki/love.keyboard.setTextInput)


---

@*param* `enable` — Whether text input events should be enabled.


---

# love.keyboard


```lua
love.keyboard
```


---

# love.keyboard.getKeyFromScancode


```lua
function love.keyboard.getKeyFromScancode(scancode: "'"|","|"-"|"."|"/"...(+189))
  -> key: "!"|"#"|"$"|"&"|"'"...(+139)
```


---

# love.keyboard.getScancodeFromKey


```lua
function love.keyboard.getScancodeFromKey(key: "!"|"#"|"$"|"&"|"'"...(+139))
  -> scancode: "'"|","|"-"|"."|"/"...(+189)
```


---

# love.keyboard.hasKeyRepeat


```lua
function love.keyboard.hasKeyRepeat()
  -> enabled: boolean
```


---

# love.keyboard.hasScreenKeyboard


```lua
function love.keyboard.hasScreenKeyboard()
  -> supported: boolean
```


---

# love.keyboard.hasTextInput


```lua
function love.keyboard.hasTextInput()
  -> enabled: boolean
```


---

# love.keyboard.isDown


```lua
function love.keyboard.isDown(key: "!"|"#"|"$"|"&"|"'"...(+139))
  -> down: boolean
```


---

# love.keyboard.isScancodeDown


```lua
function love.keyboard.isScancodeDown(scancode: "'"|","|"-"|"."|"/"...(+189), ..."'"|","|"-"|"."|"/"...(+189))
  -> down: boolean
```


---

# love.keyboard.setKeyRepeat


```lua
function love.keyboard.setKeyRepeat(enable: boolean)
```


---

# love.keyboard.setTextInput


```lua
function love.keyboard.setTextInput(enable: boolean)
```


---

# love.keypressed


---

# love.keyreleased


---

# love.load


---

# love.lowmemory


---

# love.math


```lua
love.math
```


---

# love.math

## colorFromBytes


```lua
function love.math.colorFromBytes(rb: number, gb: number, bb: number, ab?: number)
  -> r: number
  2. g: number
  3. b: number
  4. a: number
```


Converts a color from 0..255 to 0..1 range.


[Open in Browser](https://love2d.org/wiki/love.math.colorFromBytes)

@*param* `rb` — Red color component in 0..255 range.

@*param* `gb` — Green color component in 0..255 range.

@*param* `bb` — Blue color component in 0..255 range.

@*param* `ab` — Alpha color component in 0..255 range.

@*return* `r` — Red color component in 0..1 range.

@*return* `g` — Green color component in 0..1 range.

@*return* `b` — Blue color component in 0..1 range.

@*return* `a` — Alpha color component in 0..1 range or nil if alpha is not specified.

## colorToBytes


```lua
function love.math.colorToBytes(r: number, g: number, b: number, a?: number)
  -> rb: number
  2. gb: number
  3. bb: number
  4. ab: number
```


Converts a color from 0..1 to 0..255 range.


[Open in Browser](https://love2d.org/wiki/love.math.colorToBytes)

@*param* `r` — Red color component.

@*param* `g` — Green color component.

@*param* `b` — Blue color component.

@*param* `a` — Alpha color component.

@*return* `rb` — Red color component in 0..255 range.

@*return* `gb` — Green color component in 0..255 range.

@*return* `bb` — Blue color component in 0..255 range.

@*return* `ab` — Alpha color component in 0..255 range or nil if alpha is not specified.

## gammaToLinear


```lua
function love.math.gammaToLinear(r: number, g: number, b: number)
  -> lr: number
  2. lg: number
  3. lb: number
```


Converts a color from gamma-space (sRGB) to linear-space (RGB). This is useful when doing gamma-correct rendering and you need to do math in linear RGB in the few cases where LÖVE doesn't handle conversions automatically.

Read more about gamma-correct rendering here, here, and here.

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/love.math.gammaToLinear)


---

@*param* `r` — The red channel of the sRGB color to convert.

@*param* `g` — The green channel of the sRGB color to convert.

@*param* `b` — The blue channel of the sRGB color to convert.

@*return* `lr` — The red channel of the converted color in linear RGB space.

@*return* `lg` — The green channel of the converted color in linear RGB space.

@*return* `lb` — The blue channel of the converted color in linear RGB space.

## getRandomSeed


```lua
function love.math.getRandomSeed()
  -> low: number
  2. high: number
```


Gets the seed of the random number generator.

The seed is split into two numbers due to Lua's use of doubles for all number values - doubles can't accurately represent integer  values above 2^53, but the seed can be an integer value up to 2^64.


[Open in Browser](https://love2d.org/wiki/love.math.getRandomSeed)

@*return* `low` — Integer number representing the lower 32 bits of the random number generator's 64 bit seed value.

@*return* `high` — Integer number representing the higher 32 bits of the random number generator's 64 bit seed value.

## getRandomState


```lua
function love.math.getRandomState()
  -> state: string
```


Gets the current state of the random number generator. This returns an opaque implementation-dependent string which is only useful for later use with love.math.setRandomState or RandomGenerator:setState.

This is different from love.math.getRandomSeed in that getRandomState gets the random number generator's current state, whereas getRandomSeed gets the previously set seed number.


[Open in Browser](https://love2d.org/wiki/love.math.getRandomState)

@*return* `state` — The current state of the random number generator, represented as a string.

## isConvex


```lua
function love.math.isConvex(vertices: table)
  -> convex: boolean
```


Checks whether a polygon is convex.

PolygonShapes in love.physics, some forms of Meshes, and polygons drawn with love.graphics.polygon must be simple convex polygons.


[Open in Browser](https://love2d.org/wiki/love.math.isConvex)


---

@*param* `vertices` — The vertices of the polygon as a table in the form of {x1, y1, x2, y2, x3, y3, ...}.

@*return* `convex` — Whether the given polygon is convex.

## linearToGamma


```lua
function love.math.linearToGamma(lr: number, lg: number, lb: number)
  -> cr: number
  2. cg: number
  3. cb: number
```


Converts a color from linear-space (RGB) to gamma-space (sRGB). This is useful when storing linear RGB color values in an image, because the linear RGB color space has less precision than sRGB for dark colors, which can result in noticeable color banding when drawing.

In general, colors chosen based on what they look like on-screen are already in gamma-space and should not be double-converted. Colors calculated using math are often in the linear RGB space.

Read more about gamma-correct rendering here, here, and here.

In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.


[Open in Browser](https://love2d.org/wiki/love.math.linearToGamma)


---

@*param* `lr` — The red channel of the linear RGB color to convert.

@*param* `lg` — The green channel of the linear RGB color to convert.

@*param* `lb` — The blue channel of the linear RGB color to convert.

@*return* `cr` — The red channel of the converted color in gamma sRGB space.

@*return* `cg` — The green channel of the converted color in gamma sRGB space.

@*return* `cb` — The blue channel of the converted color in gamma sRGB space.

## newBezierCurve


```lua
function love.math.newBezierCurve(vertices: table)
  -> curve: love.BezierCurve
```


Creates a new BezierCurve object.

The number of vertices in the control polygon determines the degree of the curve, e.g. three vertices define a quadratic (degree 2) Bézier curve, four vertices define a cubic (degree 3) Bézier curve, etc.


[Open in Browser](https://love2d.org/wiki/love.math.newBezierCurve)


---

@*param* `vertices` — The vertices of the control polygon as a table in the form of {x1, y1, x2, y2, x3, y3, ...}.

@*return* `curve` — A Bézier curve object.

## newRandomGenerator


```lua
function love.math.newRandomGenerator()
  -> rng: love.RandomGenerator
```


Creates a new RandomGenerator object which is completely independent of other RandomGenerator objects and random functions.


[Open in Browser](https://love2d.org/wiki/love.math.newRandomGenerator)


---

@*return* `rng` — The new Random Number Generator object.

## newTransform


```lua
function love.math.newTransform()
  -> transform: love.Transform
```


Creates a new Transform object.


[Open in Browser](https://love2d.org/wiki/love.math.newTransform)


---

@*return* `transform` — The new Transform object.

## noise


```lua
function love.math.noise(x: number)
  -> value: number
```


Generates a Simplex or Perlin noise value in 1-4 dimensions. The return value will always be the same, given the same arguments.

Simplex noise is closely related to Perlin noise. It is widely used for procedural content generation.

There are many webpages which discuss Perlin and Simplex noise in detail.


[Open in Browser](https://love2d.org/wiki/love.math.noise)


---

@*param* `x` — The number used to generate the noise value.

@*return* `value` — The noise value in the range of 1.

## random


```lua
function love.math.random()
  -> number: number
```


Generates a pseudo-random number in a platform independent manner. The default love.run seeds this function at startup, so you generally don't need to seed it yourself.


[Open in Browser](https://love2d.org/wiki/love.math.random)


---

@*return* `number` — The pseudo-random number.

## randomNormal


```lua
function love.math.randomNormal(stddev?: number, mean?: number)
  -> number: number
```


Get a normally distributed pseudo random number.


[Open in Browser](https://love2d.org/wiki/love.math.randomNormal)

@*param* `stddev` — Standard deviation of the distribution.

@*param* `mean` — The mean of the distribution.

@*return* `number` — Normally distributed random number with variance (stddev)² and the specified mean.

## setRandomSeed


```lua
function love.math.setRandomSeed(seed: number)
```


Sets the seed of the random number generator using the specified integer number. This is called internally at startup, so you generally don't need to call it yourself.


[Open in Browser](https://love2d.org/wiki/love.math.setRandomSeed)


---

@*param* `seed` — The integer number with which you want to seed the randomization. Must be within the range of 2^53 - 1.

## setRandomState


```lua
function love.math.setRandomState(state: string)
```


Sets the current state of the random number generator. The value used as an argument for this function is an opaque implementation-dependent string and should only originate from a previous call to love.math.getRandomState.

This is different from love.math.setRandomSeed in that setRandomState directly sets the random number generator's current implementation-dependent state, whereas setRandomSeed gives it a new seed value.


[Open in Browser](https://love2d.org/wiki/love.math.setRandomState)

@*param* `state` — The new state of the random number generator, represented as a string. This should originate from a previous call to love.math.getRandomState.

## triangulate


```lua
function love.math.triangulate(polygon: table)
  -> triangles: table
```


Decomposes a simple convex or concave polygon into triangles.


[Open in Browser](https://love2d.org/wiki/love.math.triangulate)


---

@*param* `polygon` — Polygon to triangulate. Must not intersect itself.

@*return* `triangles` — List of triangles the polygon is composed of, in the form of {{x1, y1, x2, y2, x3, y3},  {x1, y1, x2, y2, x3, y3}, ...}.


---

# love.math.colorFromBytes


```lua
function love.math.colorFromBytes(rb: number, gb: number, bb: number, ab?: number)
  -> r: number
  2. g: number
  3. b: number
  4. a: number
```


---

# love.math.colorToBytes


```lua
function love.math.colorToBytes(r: number, g: number, b: number, a?: number)
  -> rb: number
  2. gb: number
  3. bb: number
  4. ab: number
```


---

# love.math.gammaToLinear


```lua
function love.math.gammaToLinear(r: number, g: number, b: number)
  -> lr: number
  2. lg: number
  3. lb: number
```


---

# love.math.getRandomSeed


```lua
function love.math.getRandomSeed()
  -> low: number
  2. high: number
```


---

# love.math.getRandomState


```lua
function love.math.getRandomState()
  -> state: string
```


---

# love.math.isConvex


```lua
function love.math.isConvex(vertices: table)
  -> convex: boolean
```


---

# love.math.linearToGamma


```lua
function love.math.linearToGamma(lr: number, lg: number, lb: number)
  -> cr: number
  2. cg: number
  3. cb: number
```


---

# love.math.newBezierCurve


```lua
function love.math.newBezierCurve(vertices: table)
  -> curve: love.BezierCurve
```


---

# love.math.newRandomGenerator


```lua
function love.math.newRandomGenerator()
  -> rng: love.RandomGenerator
```


---

# love.math.newTransform


```lua
function love.math.newTransform()
  -> transform: love.Transform
```


---

# love.math.noise


```lua
function love.math.noise(x: number)
  -> value: number
```


---

# love.math.random


```lua
function love.math.random()
  -> number: number
```


---

# love.math.randomNormal


```lua
function love.math.randomNormal(stddev?: number, mean?: number)
  -> number: number
```


---

# love.math.setRandomSeed


```lua
function love.math.setRandomSeed(seed: number)
```


---

# love.math.setRandomState


```lua
function love.math.setRandomState(state: string)
```


---

# love.math.triangulate


```lua
function love.math.triangulate(polygon: table)
  -> triangles: table
```


---

# love.mouse


```lua
love.mouse
```


---

# love.mouse

## getCursor


```lua
function love.mouse.getCursor()
  -> cursor: love.Cursor
```


Gets the current Cursor.


[Open in Browser](https://love2d.org/wiki/love.mouse.getCursor)

@*return* `cursor` — The current cursor, or nil if no cursor is set.

## getPosition


```lua
function love.mouse.getPosition()
  -> x: number
  2. y: number
```


Returns the current position of the mouse.


[Open in Browser](https://love2d.org/wiki/love.mouse.getPosition)

@*return* `x` — The position of the mouse along the x-axis.

@*return* `y` — The position of the mouse along the y-axis.

## getRelativeMode


```lua
function love.mouse.getRelativeMode()
  -> enabled: boolean
```


Gets whether relative mode is enabled for the mouse.

If relative mode is enabled, the cursor is hidden and doesn't move when the mouse does, but relative mouse motion events are still generated via love.mousemoved. This lets the mouse move in any direction indefinitely without the cursor getting stuck at the edges of the screen.

The reported position of the mouse is not updated while relative mode is enabled, even when relative mouse motion events are generated.


[Open in Browser](https://love2d.org/wiki/love.mouse.getRelativeMode)

@*return* `enabled` — True if relative mode is enabled, false if it's disabled.

## getSystemCursor


```lua
function love.mouse.getSystemCursor(ctype: "arrow"|"crosshair"|"hand"|"ibeam"|"image"...(+8))
  -> cursor: love.Cursor
```


Gets a Cursor object representing a system-native hardware cursor.

Hardware cursors are framerate-independent and work the same way as normal operating system cursors. Unlike drawing an image at the mouse's current coordinates, hardware cursors never have visible lag between when the mouse is moved and when the cursor position updates, even at low framerates.


[Open in Browser](https://love2d.org/wiki/love.mouse.getSystemCursor)

@*param* `ctype` — The type of system cursor to get.

@*return* `cursor` — The Cursor object representing the system cursor type.

```lua
-- 
-- Types of hardware cursors.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/CursorType)
-- 
ctype:
    | "image" -- The cursor is using a custom image.
    | "arrow" -- An arrow pointer.
    | "ibeam" -- An I-beam, normally used when mousing over editable or selectable text.
    | "wait" -- Wait graphic.
    | "waitarrow" -- Small wait cursor with an arrow pointer.
    | "crosshair" -- Crosshair symbol.
    | "sizenwse" -- Double arrow pointing to the top-left and bottom-right.
    | "sizenesw" -- Double arrow pointing to the top-right and bottom-left.
    | "sizewe" -- Double arrow pointing left and right.
    | "sizens" -- Double arrow pointing up and down.
    | "sizeall" -- Four-pointed arrow pointing up, down, left, and right.
    | "no" -- Slashed circle or crossbones.
    | "hand" -- Hand symbol.
```

## getX


```lua
function love.mouse.getX()
  -> x: number
```


Returns the current x-position of the mouse.


[Open in Browser](https://love2d.org/wiki/love.mouse.getX)

@*return* `x` — The position of the mouse along the x-axis.

## getY


```lua
function love.mouse.getY()
  -> y: number
```


Returns the current y-position of the mouse.


[Open in Browser](https://love2d.org/wiki/love.mouse.getY)

@*return* `y` — The position of the mouse along the y-axis.

## isCursorSupported


```lua
function love.mouse.isCursorSupported()
  -> supported: boolean
```


Gets whether cursor functionality is supported.

If it isn't supported, calling love.mouse.newCursor and love.mouse.getSystemCursor will cause an error. Mobile devices do not support cursors.


[Open in Browser](https://love2d.org/wiki/love.mouse.isCursorSupported)

@*return* `supported` — Whether the system has cursor functionality.

## isDown


```lua
function love.mouse.isDown(button: number, ...number)
  -> down: boolean
```


Checks whether a certain mouse button is down.

This function does not detect mouse wheel scrolling; you must use the love.wheelmoved (or love.mousepressed in version 0.9.2 and older) callback for that.


[Open in Browser](https://love2d.org/wiki/love.mouse.isDown)

@*param* `button` — The index of a button to check. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependant.

@*return* `down` — True if any specified button is down.

## isGrabbed


```lua
function love.mouse.isGrabbed()
  -> grabbed: boolean
```


Checks if the mouse is grabbed.


[Open in Browser](https://love2d.org/wiki/love.mouse.isGrabbed)

@*return* `grabbed` — True if the cursor is grabbed, false if it is not.

## isVisible


```lua
function love.mouse.isVisible()
  -> visible: boolean
```


Checks if the cursor is visible.


[Open in Browser](https://love2d.org/wiki/love.mouse.isVisible)

@*return* `visible` — True if the cursor to visible, false if the cursor is hidden.

## newCursor


```lua
function love.mouse.newCursor(imageData: love.ImageData, hotx?: number, hoty?: number)
  -> cursor: love.Cursor
```


Creates a new hardware Cursor object from an image file or ImageData.

Hardware cursors are framerate-independent and work the same way as normal operating system cursors. Unlike drawing an image at the mouse's current coordinates, hardware cursors never have visible lag between when the mouse is moved and when the cursor position updates, even at low framerates.

The hot spot is the point the operating system uses to determine what was clicked and at what position the mouse cursor is. For example, the normal arrow pointer normally has its hot spot at the top left of the image, but a crosshair cursor might have it in the middle.


[Open in Browser](https://love2d.org/wiki/love.mouse.newCursor)


---

@*param* `imageData` — The ImageData to use for the new Cursor.

@*param* `hotx` — The x-coordinate in the ImageData of the cursor's hot spot.

@*param* `hoty` — The y-coordinate in the ImageData of the cursor's hot spot.

@*return* `cursor` — The new Cursor object.

## setCursor


```lua
function love.mouse.setCursor(cursor: love.Cursor)
```


Sets the current mouse cursor.


[Open in Browser](https://love2d.org/wiki/love.mouse.setCursor)


---

@*param* `cursor` — The Cursor object to use as the current mouse cursor.

## setGrabbed


```lua
function love.mouse.setGrabbed(grab: boolean)
```


Grabs the mouse and confines it to the window.


[Open in Browser](https://love2d.org/wiki/love.mouse.setGrabbed)

@*param* `grab` — True to confine the mouse, false to let it leave the window.

## setPosition


```lua
function love.mouse.setPosition(x: number, y: number)
```


Sets the current position of the mouse. Non-integer values are floored.


[Open in Browser](https://love2d.org/wiki/love.mouse.setPosition)

@*param* `x` — The new position of the mouse along the x-axis.

@*param* `y` — The new position of the mouse along the y-axis.

## setRelativeMode


```lua
function love.mouse.setRelativeMode(enable: boolean)
```


Sets whether relative mode is enabled for the mouse.

When relative mode is enabled, the cursor is hidden and doesn't move when the mouse does, but relative mouse motion events are still generated via love.mousemoved. This lets the mouse move in any direction indefinitely without the cursor getting stuck at the edges of the screen.

The reported position of the mouse may not be updated while relative mode is enabled, even when relative mouse motion events are generated.


[Open in Browser](https://love2d.org/wiki/love.mouse.setRelativeMode)

@*param* `enable` — True to enable relative mode, false to disable it.

## setVisible


```lua
function love.mouse.setVisible(visible: boolean)
```


Sets the current visibility of the cursor.


[Open in Browser](https://love2d.org/wiki/love.mouse.setVisible)

@*param* `visible` — True to set the cursor to visible, false to hide the cursor.

## setX


```lua
function love.mouse.setX(x: number)
```


Sets the current X position of the mouse.

Non-integer values are floored.


[Open in Browser](https://love2d.org/wiki/love.mouse.setX)

@*param* `x` — The new position of the mouse along the x-axis.

## setY


```lua
function love.mouse.setY(y: number)
```


Sets the current Y position of the mouse.

Non-integer values are floored.


[Open in Browser](https://love2d.org/wiki/love.mouse.setY)

@*param* `y` — The new position of the mouse along the y-axis.


---

# love.mouse.getCursor


```lua
function love.mouse.getCursor()
  -> cursor: love.Cursor
```


---

# love.mouse.getPosition


```lua
function love.mouse.getPosition()
  -> x: number
  2. y: number
```


---

# love.mouse.getRelativeMode


```lua
function love.mouse.getRelativeMode()
  -> enabled: boolean
```


---

# love.mouse.getSystemCursor


```lua
function love.mouse.getSystemCursor(ctype: "arrow"|"crosshair"|"hand"|"ibeam"|"image"...(+8))
  -> cursor: love.Cursor
```


---

# love.mouse.getX


```lua
function love.mouse.getX()
  -> x: number
```


---

# love.mouse.getY


```lua
function love.mouse.getY()
  -> y: number
```


---

# love.mouse.isCursorSupported


```lua
function love.mouse.isCursorSupported()
  -> supported: boolean
```


---

# love.mouse.isDown


```lua
function love.mouse.isDown(button: number, ...number)
  -> down: boolean
```


---

# love.mouse.isGrabbed


```lua
function love.mouse.isGrabbed()
  -> grabbed: boolean
```


---

# love.mouse.isVisible


```lua
function love.mouse.isVisible()
  -> visible: boolean
```


---

# love.mouse.newCursor


```lua
function love.mouse.newCursor(imageData: love.ImageData, hotx?: number, hoty?: number)
  -> cursor: love.Cursor
```


---

# love.mouse.setCursor


```lua
function love.mouse.setCursor(cursor: love.Cursor)
```


---

# love.mouse.setGrabbed


```lua
function love.mouse.setGrabbed(grab: boolean)
```


---

# love.mouse.setPosition


```lua
function love.mouse.setPosition(x: number, y: number)
```


---

# love.mouse.setRelativeMode


```lua
function love.mouse.setRelativeMode(enable: boolean)
```


---

# love.mouse.setVisible


```lua
function love.mouse.setVisible(visible: boolean)
```


---

# love.mouse.setX


```lua
function love.mouse.setX(x: number)
```


---

# love.mouse.setY


```lua
function love.mouse.setY(y: number)
```


---

# love.mousefocus


---

# love.mousemoved


---

# love.mousepressed


---

# love.mousereleased


---

# love.physics


```lua
love.physics
```


---

# love.physics

## getDistance


```lua
function love.physics.getDistance(fixture1: love.Fixture, fixture2: love.Fixture)
  -> distance: number
  2. x1: number
  3. y1: number
  4. x2: number
  5. y2: number
```


Returns the two closest points between two fixtures and their distance.


[Open in Browser](https://love2d.org/wiki/love.physics.getDistance)

@*param* `fixture1` — The first fixture.

@*param* `fixture2` — The second fixture.

@*return* `distance` — The distance of the two points.

@*return* `x1` — The x-coordinate of the first point.

@*return* `y1` — The y-coordinate of the first point.

@*return* `x2` — The x-coordinate of the second point.

@*return* `y2` — The y-coordinate of the second point.

## getMeter


```lua
function love.physics.getMeter()
  -> scale: number
```


Returns the meter scale factor.

All coordinates in the physics module are divided by this number, creating a convenient way to draw the objects directly to the screen without the need for graphics transformations.

It is recommended to create shapes no larger than 10 times the scale. This is important because Box2D is tuned to work well with shape sizes from 0.1 to 10 meters.


[Open in Browser](https://love2d.org/wiki/love.physics.getMeter)

@*return* `scale` — The scale factor as an integer.

## newBody


```lua
function love.physics.newBody(world: love.World, x?: number, y?: number, type?: "dynamic"|"kinematic"|"static")
  -> body: love.Body
```


Creates a new body.

There are three types of bodies.

* Static bodies do not move, have a infinite mass, and can be used for level boundaries.

* Dynamic bodies are the main actors in the simulation, they collide with everything.

* Kinematic bodies do not react to forces and only collide with dynamic bodies.

The mass of the body gets calculated when a Fixture is attached or removed, but can be changed at any time with Body:setMass or Body:resetMassData.


[Open in Browser](https://love2d.org/wiki/love.physics.newBody)

@*param* `world` — The world to create the body in.

@*param* `x` — The x position of the body.

@*param* `y` — The y position of the body.

@*param* `type` — The type of the body.

@*return* `body` — A new body.

```lua
-- 
-- The types of a Body.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/BodyType)
-- 
type:
    | "static" -- Static bodies do not move.
    | "dynamic" -- Dynamic bodies collide with all bodies.
    | "kinematic" -- Kinematic bodies only collide with dynamic bodies.
```

## newChainShape


```lua
function love.physics.newChainShape(loop: boolean, x1: number, y1: number, x2: number, y2: number, ...number)
  -> shape: love.ChainShape
```


Creates a new ChainShape.


[Open in Browser](https://love2d.org/wiki/love.physics.newChainShape)


---

@*param* `loop` — If the chain should loop back to the first point.

@*param* `x1` — The x position of the first point.

@*param* `y1` — The y position of the first point.

@*param* `x2` — The x position of the second point.

@*param* `y2` — The y position of the second point.

@*return* `shape` — The new shape.

## newCircleShape


```lua
function love.physics.newCircleShape(radius: number)
  -> shape: love.CircleShape
```


Creates a new CircleShape.


[Open in Browser](https://love2d.org/wiki/love.physics.newCircleShape)


---

@*param* `radius` — The radius of the circle.

@*return* `shape` — The new shape.

## newDistanceJoint


```lua
function love.physics.newDistanceJoint(body1: love.Body, body2: love.Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean)
  -> joint: love.DistanceJoint
```


Creates a DistanceJoint between two bodies.

This joint constrains the distance between two points on two bodies to be constant. These two points are specified in world coordinates and the two bodies are assumed to be in place when this joint is created. The first anchor point is connected to the first body and the second to the second body, and the points define the length of the distance joint.


[Open in Browser](https://love2d.org/wiki/love.physics.newDistanceJoint)

@*param* `body1` — The first body to attach to the joint.

@*param* `body2` — The second body to attach to the joint.

@*param* `x1` — The x position of the first anchor point (world space).

@*param* `y1` — The y position of the first anchor point (world space).

@*param* `x2` — The x position of the second anchor point (world space).

@*param* `y2` — The y position of the second anchor point (world space).

@*param* `collideConnected` — Specifies whether the two bodies should collide with each other.

@*return* `joint` — The new distance joint.

## newEdgeShape


```lua
function love.physics.newEdgeShape(x1: number, y1: number, x2: number, y2: number)
  -> shape: love.EdgeShape
```


Creates a new EdgeShape.


[Open in Browser](https://love2d.org/wiki/love.physics.newEdgeShape)

@*param* `x1` — The x position of the first point.

@*param* `y1` — The y position of the first point.

@*param* `x2` — The x position of the second point.

@*param* `y2` — The y position of the second point.

@*return* `shape` — The new shape.

## newFixture


```lua
function love.physics.newFixture(body: love.Body, shape: love.Shape, density?: number)
  -> fixture: love.Fixture
```


Creates and attaches a Fixture to a body.

Note that the Shape object is copied rather than kept as a reference when the Fixture is created. To get the Shape object that the Fixture owns, use Fixture:getShape.


[Open in Browser](https://love2d.org/wiki/love.physics.newFixture)

@*param* `body` — The body which gets the fixture attached.

@*param* `shape` — The shape to be copied to the fixture.

@*param* `density` — The density of the fixture.

@*return* `fixture` — The new fixture.

## newFrictionJoint


```lua
function love.physics.newFrictionJoint(body1: love.Body, body2: love.Body, x: number, y: number, collideConnected?: boolean)
  -> joint: love.FrictionJoint
```


Create a friction joint between two bodies. A FrictionJoint applies friction to a body.


[Open in Browser](https://love2d.org/wiki/love.physics.newFrictionJoint)


---

@*param* `body1` — The first body to attach to the joint.

@*param* `body2` — The second body to attach to the joint.

@*param* `x` — The x position of the anchor point.

@*param* `y` — The y position of the anchor point.

@*param* `collideConnected` — Specifies whether the two bodies should collide with each other.

@*return* `joint` — The new FrictionJoint.

## newGearJoint


```lua
function love.physics.newGearJoint(joint1: love.Joint, joint2: love.Joint, ratio?: number, collideConnected?: boolean)
  -> joint: love.GearJoint
```


Create a GearJoint connecting two Joints.

The gear joint connects two joints that must be either  prismatic or  revolute joints. Using this joint requires that the joints it uses connect their respective bodies to the ground and have the ground as the first body. When destroying the bodies and joints you must make sure you destroy the gear joint before the other joints.

The gear joint has a ratio the determines how the angular or distance values of the connected joints relate to each other. The formula coordinate1 + ratio * coordinate2 always has a constant value that is set when the gear joint is created.


[Open in Browser](https://love2d.org/wiki/love.physics.newGearJoint)

@*param* `joint1` — The first joint to connect with a gear joint.

@*param* `joint2` — The second joint to connect with a gear joint.

@*param* `ratio` — The gear ratio.

@*param* `collideConnected` — Specifies whether the two bodies should collide with each other.

@*return* `joint` — The new gear joint.

## newMotorJoint


```lua
function love.physics.newMotorJoint(body1: love.Body, body2: love.Body, correctionFactor?: number)
  -> joint: love.MotorJoint
```


Creates a joint between two bodies which controls the relative motion between them.

Position and rotation offsets can be specified once the MotorJoint has been created, as well as the maximum motor force and torque that will be be applied to reach the target offsets.


[Open in Browser](https://love2d.org/wiki/love.physics.newMotorJoint)


---

@*param* `body1` — The first body to attach to the joint.

@*param* `body2` — The second body to attach to the joint.

@*param* `correctionFactor` — The joint's initial position correction factor, in the range of 1.

@*return* `joint` — The new MotorJoint.

## newMouseJoint


```lua
function love.physics.newMouseJoint(body: love.Body, x: number, y: number)
  -> joint: love.MouseJoint
```


Create a joint between a body and the mouse.

This joint actually connects the body to a fixed point in the world. To make it follow the mouse, the fixed point must be updated every timestep (example below).

The advantage of using a MouseJoint instead of just changing a body position directly is that collisions and reactions to other joints are handled by the physics engine.


[Open in Browser](https://love2d.org/wiki/love.physics.newMouseJoint)

@*param* `body` — The body to attach to the mouse.

@*param* `x` — The x position of the connecting point.

@*param* `y` — The y position of the connecting point.

@*return* `joint` — The new mouse joint.

## newPolygonShape


```lua
function love.physics.newPolygonShape(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, ...number)
  -> shape: love.PolygonShape
```


Creates a new PolygonShape.

This shape can have 8 vertices at most, and must form a convex shape.


[Open in Browser](https://love2d.org/wiki/love.physics.newPolygonShape)


---

@*param* `x1` — The x position of the first point.

@*param* `y1` — The y position of the first point.

@*param* `x2` — The x position of the second point.

@*param* `y2` — The y position of the second point.

@*param* `x3` — The x position of the third point.

@*param* `y3` — The y position of the third point.

@*return* `shape` — A new PolygonShape.

## newPrismaticJoint


```lua
function love.physics.newPrismaticJoint(body1: love.Body, body2: love.Body, x: number, y: number, ax: number, ay: number, collideConnected?: boolean)
  -> joint: love.PrismaticJoint
```


Creates a PrismaticJoint between two bodies.

A prismatic joint constrains two bodies to move relatively to each other on a specified axis. It does not allow for relative rotation. Its definition and operation are similar to a  revolute joint, but with translation and force substituted for angle and torque.


[Open in Browser](https://love2d.org/wiki/love.physics.newPrismaticJoint)


---

@*param* `body1` — The first body to connect with a prismatic joint.

@*param* `body2` — The second body to connect with a prismatic joint.

@*param* `x` — The x coordinate of the anchor point.

@*param* `y` — The y coordinate of the anchor point.

@*param* `ax` — The x coordinate of the axis vector.

@*param* `ay` — The y coordinate of the axis vector.

@*param* `collideConnected` — Specifies whether the two bodies should collide with each other.

@*return* `joint` — The new prismatic joint.

## newPulleyJoint


```lua
function love.physics.newPulleyJoint(body1: love.Body, body2: love.Body, gx1: number, gy1: number, gx2: number, gy2: number, x1: number, y1: number, x2: number, y2: number, ratio?: number, collideConnected?: boolean)
  -> joint: love.PulleyJoint
```


Creates a PulleyJoint to join two bodies to each other and the ground.

The pulley joint simulates a pulley with an optional block and tackle. If the ratio parameter has a value different from one, then the simulated rope extends faster on one side than the other. In a pulley joint the total length of the simulated rope is the constant length1 + ratio * length2, which is set when the pulley joint is created.

Pulley joints can behave unpredictably if one side is fully extended. It is recommended that the method  setMaxLengths  be used to constrain the maximum lengths each side can attain.


[Open in Browser](https://love2d.org/wiki/love.physics.newPulleyJoint)

@*param* `body1` — The first body to connect with a pulley joint.

@*param* `body2` — The second body to connect with a pulley joint.

@*param* `gx1` — The x coordinate of the first body's ground anchor.

@*param* `gy1` — The y coordinate of the first body's ground anchor.

@*param* `gx2` — The x coordinate of the second body's ground anchor.

@*param* `gy2` — The y coordinate of the second body's ground anchor.

@*param* `x1` — The x coordinate of the pulley joint anchor in the first body.

@*param* `y1` — The y coordinate of the pulley joint anchor in the first body.

@*param* `x2` — The x coordinate of the pulley joint anchor in the second body.

@*param* `y2` — The y coordinate of the pulley joint anchor in the second body.

@*param* `ratio` — The joint ratio.

@*param* `collideConnected` — Specifies whether the two bodies should collide with each other.

@*return* `joint` — The new pulley joint.

## newRectangleShape


```lua
function love.physics.newRectangleShape(width: number, height: number)
  -> shape: love.PolygonShape
```


Shorthand for creating rectangular PolygonShapes.

By default, the local origin is located at the '''center''' of the rectangle as opposed to the top left for graphics.


[Open in Browser](https://love2d.org/wiki/love.physics.newRectangleShape)


---

@*param* `width` — The width of the rectangle.

@*param* `height` — The height of the rectangle.

@*return* `shape` — A new PolygonShape.

## newRevoluteJoint


```lua
function love.physics.newRevoluteJoint(body1: love.Body, body2: love.Body, x: number, y: number, collideConnected?: boolean)
  -> joint: love.RevoluteJoint
```


Creates a pivot joint between two bodies.

This joint connects two bodies to a point around which they can pivot.


[Open in Browser](https://love2d.org/wiki/love.physics.newRevoluteJoint)


---

@*param* `body1` — The first body.

@*param* `body2` — The second body.

@*param* `x` — The x position of the connecting point.

@*param* `y` — The y position of the connecting point.

@*param* `collideConnected` — Specifies whether the two bodies should collide with each other.

@*return* `joint` — The new revolute joint.

## newRopeJoint


```lua
function love.physics.newRopeJoint(body1: love.Body, body2: love.Body, x1: number, y1: number, x2: number, y2: number, maxLength: number, collideConnected?: boolean)
  -> joint: love.RopeJoint
```


Creates a joint between two bodies. Its only function is enforcing a max distance between these bodies.


[Open in Browser](https://love2d.org/wiki/love.physics.newRopeJoint)

@*param* `body1` — The first body to attach to the joint.

@*param* `body2` — The second body to attach to the joint.

@*param* `x1` — The x position of the first anchor point.

@*param* `y1` — The y position of the first anchor point.

@*param* `x2` — The x position of the second anchor point.

@*param* `y2` — The y position of the second anchor point.

@*param* `maxLength` — The maximum distance for the bodies.

@*param* `collideConnected` — Specifies whether the two bodies should collide with each other.

@*return* `joint` — The new RopeJoint.

## newWeldJoint


```lua
function love.physics.newWeldJoint(body1: love.Body, body2: love.Body, x: number, y: number, collideConnected?: boolean)
  -> joint: love.WeldJoint
```


Creates a constraint joint between two bodies. A WeldJoint essentially glues two bodies together. The constraint is a bit soft, however, due to Box2D's iterative solver.


[Open in Browser](https://love2d.org/wiki/love.physics.newWeldJoint)


---

@*param* `body1` — The first body to attach to the joint.

@*param* `body2` — The second body to attach to the joint.

@*param* `x` — The x position of the anchor point (world space).

@*param* `y` — The y position of the anchor point (world space).

@*param* `collideConnected` — Specifies whether the two bodies should collide with each other.

@*return* `joint` — The new WeldJoint.

## newWheelJoint


```lua
function love.physics.newWheelJoint(body1: love.Body, body2: love.Body, x: number, y: number, ax: number, ay: number, collideConnected?: boolean)
  -> joint: love.WheelJoint
```


Creates a wheel joint.


[Open in Browser](https://love2d.org/wiki/love.physics.newWheelJoint)


---

@*param* `body1` — The first body.

@*param* `body2` — The second body.

@*param* `x` — The x position of the anchor point.

@*param* `y` — The y position of the anchor point.

@*param* `ax` — The x position of the axis unit vector.

@*param* `ay` — The y position of the axis unit vector.

@*param* `collideConnected` — Specifies whether the two bodies should collide with each other.

@*return* `joint` — The new WheelJoint.

## newWorld


```lua
function love.physics.newWorld(xg?: number, yg?: number, sleep?: boolean)
  -> world: love.World
```


Creates a new World.


[Open in Browser](https://love2d.org/wiki/love.physics.newWorld)

@*param* `xg` — The x component of gravity.

@*param* `yg` — The y component of gravity.

@*param* `sleep` — Whether the bodies in this world are allowed to sleep.

@*return* `world` — A brave new World.

## setMeter


```lua
function love.physics.setMeter(scale: number)
```


Sets the pixels to meter scale factor.

All coordinates in the physics module are divided by this number and converted to meters, and it creates a convenient way to draw the objects directly to the screen without the need for graphics transformations.

It is recommended to create shapes no larger than 10 times the scale. This is important because Box2D is tuned to work well with shape sizes from 0.1 to 10 meters. The default meter scale is 30.


[Open in Browser](https://love2d.org/wiki/love.physics.setMeter)

@*param* `scale` — The scale factor as an integer.


---

# love.physics.getDistance


```lua
function love.physics.getDistance(fixture1: love.Fixture, fixture2: love.Fixture)
  -> distance: number
  2. x1: number
  3. y1: number
  4. x2: number
  5. y2: number
```


---

# love.physics.getMeter


```lua
function love.physics.getMeter()
  -> scale: number
```


---

# love.physics.newBody


```lua
function love.physics.newBody(world: love.World, x?: number, y?: number, type?: "dynamic"|"kinematic"|"static")
  -> body: love.Body
```


---

# love.physics.newChainShape


```lua
function love.physics.newChainShape(loop: boolean, x1: number, y1: number, x2: number, y2: number, ...number)
  -> shape: love.ChainShape
```


---

# love.physics.newCircleShape


```lua
function love.physics.newCircleShape(radius: number)
  -> shape: love.CircleShape
```


---

# love.physics.newDistanceJoint


```lua
function love.physics.newDistanceJoint(body1: love.Body, body2: love.Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean)
  -> joint: love.DistanceJoint
```


---

# love.physics.newEdgeShape


```lua
function love.physics.newEdgeShape(x1: number, y1: number, x2: number, y2: number)
  -> shape: love.EdgeShape
```


---

# love.physics.newFixture


```lua
function love.physics.newFixture(body: love.Body, shape: love.Shape, density?: number)
  -> fixture: love.Fixture
```


---

# love.physics.newFrictionJoint


```lua
function love.physics.newFrictionJoint(body1: love.Body, body2: love.Body, x: number, y: number, collideConnected?: boolean)
  -> joint: love.FrictionJoint
```


---

# love.physics.newGearJoint


```lua
function love.physics.newGearJoint(joint1: love.Joint, joint2: love.Joint, ratio?: number, collideConnected?: boolean)
  -> joint: love.GearJoint
```


---

# love.physics.newMotorJoint


```lua
function love.physics.newMotorJoint(body1: love.Body, body2: love.Body, correctionFactor?: number)
  -> joint: love.MotorJoint
```


---

# love.physics.newMouseJoint


```lua
function love.physics.newMouseJoint(body: love.Body, x: number, y: number)
  -> joint: love.MouseJoint
```


---

# love.physics.newPolygonShape


```lua
function love.physics.newPolygonShape(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, ...number)
  -> shape: love.PolygonShape
```


---

# love.physics.newPrismaticJoint


```lua
function love.physics.newPrismaticJoint(body1: love.Body, body2: love.Body, x: number, y: number, ax: number, ay: number, collideConnected?: boolean)
  -> joint: love.PrismaticJoint
```


---

# love.physics.newPulleyJoint


```lua
function love.physics.newPulleyJoint(body1: love.Body, body2: love.Body, gx1: number, gy1: number, gx2: number, gy2: number, x1: number, y1: number, x2: number, y2: number, ratio?: number, collideConnected?: boolean)
  -> joint: love.PulleyJoint
```


---

# love.physics.newRectangleShape


```lua
function love.physics.newRectangleShape(width: number, height: number)
  -> shape: love.PolygonShape
```


---

# love.physics.newRevoluteJoint


```lua
function love.physics.newRevoluteJoint(body1: love.Body, body2: love.Body, x: number, y: number, collideConnected?: boolean)
  -> joint: love.RevoluteJoint
```


---

# love.physics.newRopeJoint


```lua
function love.physics.newRopeJoint(body1: love.Body, body2: love.Body, x1: number, y1: number, x2: number, y2: number, maxLength: number, collideConnected?: boolean)
  -> joint: love.RopeJoint
```


---

# love.physics.newWeldJoint


```lua
function love.physics.newWeldJoint(body1: love.Body, body2: love.Body, x: number, y: number, collideConnected?: boolean)
  -> joint: love.WeldJoint
```


---

# love.physics.newWheelJoint


```lua
function love.physics.newWheelJoint(body1: love.Body, body2: love.Body, x: number, y: number, ax: number, ay: number, collideConnected?: boolean)
  -> joint: love.WheelJoint
```


---

# love.physics.newWorld


```lua
function love.physics.newWorld(xg?: number, yg?: number, sleep?: boolean)
  -> world: love.World
```


---

# love.physics.setMeter


```lua
function love.physics.setMeter(scale: number)
```


---

# love.quit


---

# love.resize


---

# love.run


---

# love.setDeprecationOutput


```lua
function love.setDeprecationOutput(enable: boolean)
```


---

# love.sound


```lua
love.sound
```


---

# love.sound

## newDecoder


```lua
function love.sound.newDecoder(file: love.File, buffer?: number)
  -> decoder: love.Decoder
```


Attempts to find a decoder for the encoded sound data in the specified file.


[Open in Browser](https://love2d.org/wiki/love.sound.newDecoder)


---

@*param* `file` — The file with encoded sound data.

@*param* `buffer` — The size of each decoded chunk, in bytes.

@*return* `decoder` — A new Decoder object.

## newSoundData


```lua
function love.sound.newSoundData(filename: string)
  -> soundData: love.SoundData
```


Creates new SoundData from a filepath, File, or Decoder. It's also possible to create SoundData with a custom sample rate, channel and bit depth.

The sound data will be decoded to the memory in a raw format. It is recommended to create only short sounds like effects, as a 3 minute song uses 30 MB of memory this way.


[Open in Browser](https://love2d.org/wiki/love.sound.newSoundData)


---

@*param* `filename` — The file name of the file to load.

@*return* `soundData` — A new SoundData object.


---

# love.sound.newDecoder


```lua
function love.sound.newDecoder(file: love.File, buffer?: number)
  -> decoder: love.Decoder
```


---

# love.sound.newSoundData


```lua
function love.sound.newSoundData(filename: string)
  -> soundData: love.SoundData
```


---

# love.system

## getClipboardText


```lua
function love.system.getClipboardText()
  -> text: string
```


Gets text from the clipboard.


[Open in Browser](https://love2d.org/wiki/love.system.getClipboardText)

@*return* `text` — The text currently held in the system's clipboard.

## getOS


```lua
function love.system.getOS()
  -> osString: string
```


Gets the current operating system. In general, LÖVE abstracts away the need to know the current operating system, but there are a few cases where it can be useful (especially in combination with os.execute.)


[Open in Browser](https://love2d.org/wiki/love.system.getOS)

@*return* `osString` — The current operating system. 'OS X', 'Windows', 'Linux', 'Android' or 'iOS'.

## getPowerInfo


```lua
function love.system.getPowerInfo()
  -> state: "battery"|"charged"|"charging"|"nobattery"|"unknown"
  2. percent: number
  3. seconds: number
```


Gets information about the system's power supply.


[Open in Browser](https://love2d.org/wiki/love.system.getPowerInfo)

@*return* `state` — The basic state of the power supply.

@*return* `percent` — Percentage of battery life left, between 0 and 100. nil if the value can't be determined or there's no battery.

@*return* `seconds` — Seconds of battery life left. nil if the value can't be determined or there's no battery.

```lua
-- 
-- The basic state of the system's power supply.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/PowerState)
-- 
state:
    | "unknown" -- Cannot determine power status.
    | "battery" -- Not plugged in, running on a battery.
    | "nobattery" -- Plugged in, no battery available.
    | "charging" -- Plugged in, charging battery.
    | "charged" -- Plugged in, battery is fully charged.
```

## getProcessorCount


```lua
function love.system.getProcessorCount()
  -> processorCount: number
```


Gets the amount of logical processor in the system.


[Open in Browser](https://love2d.org/wiki/love.system.getProcessorCount)

@*return* `processorCount` — Amount of logical processors.

## hasBackgroundMusic


```lua
function love.system.hasBackgroundMusic()
  -> backgroundmusic: boolean
```


Gets whether another application on the system is playing music in the background.

Currently this is implemented on iOS and Android, and will always return false on other operating systems. The t.audio.mixwithsystem flag in love.conf can be used to configure whether background audio / music from other apps should play while LÖVE is open.


[Open in Browser](https://love2d.org/wiki/love.system.hasBackgroundMusic)

@*return* `backgroundmusic` — True if the user is playing music in the background via another app, false otherwise.

## openURL


```lua
function love.system.openURL(url: string)
  -> success: boolean
```


Opens a URL with the user's web or file browser.


[Open in Browser](https://love2d.org/wiki/love.system.openURL)

@*param* `url` — The URL to open. Must be formatted as a proper URL.

@*return* `success` — Whether the URL was opened successfully.

## setClipboardText


```lua
function love.system.setClipboardText(text: string)
```


Puts text in the clipboard.


[Open in Browser](https://love2d.org/wiki/love.system.setClipboardText)

@*param* `text` — The new text to hold in the system's clipboard.

## vibrate


```lua
function love.system.vibrate(seconds?: number)
```


Causes the device to vibrate, if possible. Currently this will only work on Android and iOS devices that have a built-in vibration motor.


[Open in Browser](https://love2d.org/wiki/love.system.vibrate)

@*param* `seconds` — The duration to vibrate for. If called on an iOS device, it will always vibrate for 0.5 seconds due to limitations in the iOS system APIs.


---

# love.system


```lua
love.system
```


---

# love.system.getClipboardText


```lua
function love.system.getClipboardText()
  -> text: string
```


---

# love.system.getOS


```lua
function love.system.getOS()
  -> osString: string
```


---

# love.system.getPowerInfo


```lua
function love.system.getPowerInfo()
  -> state: "battery"|"charged"|"charging"|"nobattery"|"unknown"
  2. percent: number
  3. seconds: number
```


---

# love.system.getProcessorCount


```lua
function love.system.getProcessorCount()
  -> processorCount: number
```


---

# love.system.hasBackgroundMusic


```lua
function love.system.hasBackgroundMusic()
  -> backgroundmusic: boolean
```


---

# love.system.openURL


```lua
function love.system.openURL(url: string)
  -> success: boolean
```


---

# love.system.setClipboardText


```lua
function love.system.setClipboardText(text: string)
```


---

# love.system.vibrate


```lua
function love.system.vibrate(seconds?: number)
```


---

# love.textedited


---

# love.textinput


---

# love.thread

## getChannel


```lua
function love.thread.getChannel(name: string)
  -> channel: love.Channel
```


Creates or retrieves a named thread channel.


[Open in Browser](https://love2d.org/wiki/love.thread.getChannel)

@*param* `name` — The name of the channel you want to create or retrieve.

@*return* `channel` — The Channel object associated with the name.

## newChannel


```lua
function love.thread.newChannel()
  -> channel: love.Channel
```


Create a new unnamed thread channel.

One use for them is to pass new unnamed channels to other threads via Channel:push on a named channel.


[Open in Browser](https://love2d.org/wiki/love.thread.newChannel)

@*return* `channel` — The new Channel object.

## newThread


```lua
function love.thread.newThread(filename: string)
  -> thread: love.Thread
```


Creates a new Thread from a filename, string or FileData object containing Lua code.


[Open in Browser](https://love2d.org/wiki/love.thread.newThread)


---

@*param* `filename` — The name of the Lua file to use as the source.

@*return* `thread` — A new Thread that has yet to be started.


---

# love.thread


```lua
love.thread
```


---

# love.thread.getChannel


```lua
function love.thread.getChannel(name: string)
  -> channel: love.Channel
```


---

# love.thread.newChannel


```lua
function love.thread.newChannel()
  -> channel: love.Channel
```


---

# love.thread.newThread


```lua
function love.thread.newThread(filename: string)
  -> thread: love.Thread
```


---

# love.threaderror


---

# love.timer

## getAverageDelta


```lua
function love.timer.getAverageDelta()
  -> delta: number
```


Returns the average delta time (seconds per frame) over the last second.


[Open in Browser](https://love2d.org/wiki/love.timer.getAverageDelta)

@*return* `delta` — The average delta time over the last second.

## getDelta


```lua
function love.timer.getDelta()
  -> dt: number
```


Returns the time between the last two frames.


[Open in Browser](https://love2d.org/wiki/love.timer.getDelta)

@*return* `dt` — The time passed (in seconds).

## getFPS


```lua
function love.timer.getFPS()
  -> fps: number
```


Returns the current frames per second.


[Open in Browser](https://love2d.org/wiki/love.timer.getFPS)

@*return* `fps` — The current FPS.

## getTime


```lua
function love.timer.getTime()
  -> time: number
```


Returns the value of a timer with an unspecified starting time.

This function should only be used to calculate differences between points in time, as the starting time of the timer is unknown.


[Open in Browser](https://love2d.org/wiki/love.timer.getTime)

@*return* `time` — The time in seconds. Given as a decimal, accurate to the microsecond.

## sleep


```lua
function love.timer.sleep(s: number)
```


Pauses the current thread for the specified amount of time.


[Open in Browser](https://love2d.org/wiki/love.timer.sleep)

@*param* `s` — Seconds to sleep for.

## step


```lua
function love.timer.step()
  -> dt: number
```


Measures the time between two frames.

Calling this changes the return value of love.timer.getDelta.


[Open in Browser](https://love2d.org/wiki/love.timer.step)

@*return* `dt` — The time passed (in seconds).


---

# love.timer


```lua
love.timer
```


---

# love.timer.getAverageDelta


```lua
function love.timer.getAverageDelta()
  -> delta: number
```


---

# love.timer.getDelta


```lua
function love.timer.getDelta()
  -> dt: number
```


---

# love.timer.getFPS


```lua
function love.timer.getFPS()
  -> fps: number
```


---

# love.timer.getTime


```lua
function love.timer.getTime()
  -> time: number
```


---

# love.timer.sleep


```lua
function love.timer.sleep(s: number)
```


---

# love.timer.step


```lua
function love.timer.step()
  -> dt: number
```


---

# love.touch


```lua
love.touch
```


---

# love.touch

## getPosition


```lua
function love.touch.getPosition(id: lightuserdata)
  -> x: number
  2. y: number
```


Gets the current position of the specified touch-press, in pixels.


[Open in Browser](https://love2d.org/wiki/love.touch.getPosition)

@*param* `id` — The identifier of the touch-press. Use love.touch.getTouches, love.touchpressed, or love.touchmoved to obtain touch id values.

@*return* `x` — The position along the x-axis of the touch-press inside the window, in pixels.

@*return* `y` — The position along the y-axis of the touch-press inside the window, in pixels.

## getPressure


```lua
function love.touch.getPressure(id: lightuserdata)
  -> pressure: number
```


Gets the current pressure of the specified touch-press.


[Open in Browser](https://love2d.org/wiki/love.touch.getPressure)

@*param* `id` — The identifier of the touch-press. Use love.touch.getTouches, love.touchpressed, or love.touchmoved to obtain touch id values.

@*return* `pressure` — The pressure of the touch-press. Most touch screens aren't pressure sensitive, in which case the pressure will be 1.

## getTouches


```lua
function love.touch.getTouches()
  -> touches: table
```


Gets a list of all active touch-presses.


[Open in Browser](https://love2d.org/wiki/love.touch.getTouches)

@*return* `touches` — A list of active touch-press id values, which can be used with love.touch.getPosition.


---

# love.touch.getPosition


```lua
function love.touch.getPosition(id: lightuserdata)
  -> x: number
  2. y: number
```


---

# love.touch.getPressure


```lua
function love.touch.getPressure(id: lightuserdata)
  -> pressure: number
```


---

# love.touch.getTouches


```lua
function love.touch.getTouches()
  -> touches: table
```


---

# love.touchmoved


---

# love.touchpressed


---

# love.touchreleased


---

# love.update


---

# love.video

## newVideoStream


```lua
function love.video.newVideoStream(filename: string)
  -> videostream: love.VideoStream
```


Creates a new VideoStream. Currently only Ogg Theora video files are supported. VideoStreams can't draw videos, see love.graphics.newVideo for that.


[Open in Browser](https://love2d.org/wiki/love.video.newVideoStream)


---

@*param* `filename` — The file path to the Ogg Theora video file.

@*return* `videostream` — A new VideoStream.


---

# love.video


```lua
love.video
```


---

# love.video.newVideoStream


```lua
function love.video.newVideoStream(filename: string)
  -> videostream: love.VideoStream
```


---

# love.visible


---

# love.wheelmoved


---

# love.window

## close


```lua
function love.window.close()
```


Closes the window. It can be reopened with love.window.setMode.


[Open in Browser](https://love2d.org/wiki/love.window.close)

## fromPixels


```lua
function love.window.fromPixels(pixelvalue: number)
  -> value: number
```


Converts a number from pixels to density-independent units.

The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.window.fromPixels(1600) would return 800 in that case.

This function converts coordinates from pixels to the size users are expecting them to display at onscreen. love.window.toPixels does the opposite. The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.

Most LÖVE functions return values and expect arguments in terms of pixels rather than density-independent units.


[Open in Browser](https://love2d.org/wiki/love.window.fromPixels)


---

@*param* `pixelvalue` — A number in pixels to convert to density-independent units.

@*return* `value` — The converted number, in density-independent units.

## getDPIScale


```lua
function love.window.getDPIScale()
  -> scale: number
```


Gets the DPI scale factor associated with the window.

The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.window.getDPIScale() would return 2.0 in that case.

The love.window.fromPixels and love.window.toPixels functions can also be used to convert between units.

The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.


[Open in Browser](https://love2d.org/wiki/love.window.getDPIScale)

@*return* `scale` — The pixel scale factor associated with the window.

## getDesktopDimensions


```lua
function love.window.getDesktopDimensions(displayindex?: number)
  -> width: number
  2. height: number
```


Gets the width and height of the desktop.


[Open in Browser](https://love2d.org/wiki/love.window.getDesktopDimensions)

@*param* `displayindex` — The index of the display, if multiple monitors are available.

@*return* `width` — The width of the desktop.

@*return* `height` — The height of the desktop.

## getDisplayCount


```lua
function love.window.getDisplayCount()
  -> count: number
```


Gets the number of connected monitors.


[Open in Browser](https://love2d.org/wiki/love.window.getDisplayCount)

@*return* `count` — The number of currently connected displays.

## getDisplayName


```lua
function love.window.getDisplayName(displayindex?: number)
  -> name: string
```


Gets the name of a display.


[Open in Browser](https://love2d.org/wiki/love.window.getDisplayName)

@*param* `displayindex` — The index of the display to get the name of.

@*return* `name` — The name of the specified display.

## getDisplayOrientation


```lua
function love.window.getDisplayOrientation(displayindex?: number)
  -> orientation: "landscape"|"landscapeflipped"|"portrait"|"portraitflipped"|"unknown"
```


Gets current device display orientation.


[Open in Browser](https://love2d.org/wiki/love.window.getDisplayOrientation)

@*param* `displayindex` — Display index to get its display orientation, or nil for default display index.

@*return* `orientation` — Current device display orientation.

```lua
-- 
-- Types of device display orientation.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/DisplayOrientation)
-- 
orientation:
    | "unknown" -- Orientation cannot be determined.
    | "landscape" -- Landscape orientation.
    | "landscapeflipped" -- Landscape orientation (flipped).
    | "portrait" -- Portrait orientation.
    | "portraitflipped" -- Portrait orientation (flipped).
```

## getFullscreen


```lua
function love.window.getFullscreen()
  -> fullscreen: boolean
  2. fstype: "desktop"|"exclusive"|"normal"
```


Gets whether the window is fullscreen.


[Open in Browser](https://love2d.org/wiki/love.window.getFullscreen)

@*return* `fullscreen` — True if the window is fullscreen, false otherwise.

@*return* `fstype` — The type of fullscreen mode used.

```lua
-- 
-- Types of fullscreen modes.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/FullscreenType)
-- 
fstype:
    | "desktop" -- Sometimes known as borderless fullscreen windowed mode. A borderless screen-sized window is created which sits on top of all desktop UI elements. The window is automatically resized to match the dimensions of the desktop, and its size cannot be changed.
    | "exclusive" -- Standard exclusive-fullscreen mode. Changes the display mode (actual resolution) of the monitor.
    | "normal" -- Standard exclusive-fullscreen mode. Changes the display mode (actual resolution) of the monitor.
```

## getFullscreenModes


```lua
function love.window.getFullscreenModes(displayindex?: number)
  -> modes: table
```


Gets a list of supported fullscreen modes.


[Open in Browser](https://love2d.org/wiki/love.window.getFullscreenModes)

@*param* `displayindex` — The index of the display, if multiple monitors are available.

@*return* `modes` — A table of width/height pairs. (Note that this may not be in order.)

## getIcon


```lua
function love.window.getIcon()
  -> imagedata: love.ImageData
```


Gets the window icon.


[Open in Browser](https://love2d.org/wiki/love.window.getIcon)

@*return* `imagedata` — The window icon imagedata, or nil if no icon has been set with love.window.setIcon.

## getMode


```lua
function love.window.getMode()
  -> width: number
  2. height: number
  3. flags: { fullscreen: boolean, fullscreentype: "desktop"|"exclusive"|"normal", vsync: boolean, msaa: number, resizable: boolean, borderless: boolean, centered: boolean, display: number, minwidth: number, minheight: number, highdpi: boolean, refreshrate: number, x: number, y: number, srgb: boolean }
```


Gets the display mode and properties of the window.


[Open in Browser](https://love2d.org/wiki/love.window.getMode)

@*return* `width` — Window width.

@*return* `height` — Window height.

@*return* `flags` — Table with the window properties:

## getPosition


```lua
function love.window.getPosition()
  -> x: number
  2. y: number
  3. displayindex: number
```


Gets the position of the window on the screen.

The window position is in the coordinate space of the display it is currently in.


[Open in Browser](https://love2d.org/wiki/love.window.getPosition)

@*return* `x` — The x-coordinate of the window's position.

@*return* `y` — The y-coordinate of the window's position.

@*return* `displayindex` — The index of the display that the window is in.

## getSafeArea


```lua
function love.window.getSafeArea()
  -> x: number
  2. y: number
  3. w: number
  4. h: number
```


Gets area inside the window which is known to be unobstructed by a system title bar, the iPhone X notch, etc. Useful for making sure UI elements can be seen by the user.


[Open in Browser](https://love2d.org/wiki/love.window.getSafeArea)

@*return* `x` — Starting position of safe area (x-axis).

@*return* `y` — Starting position of safe area (y-axis).

@*return* `w` — Width of safe area.

@*return* `h` — Height of safe area.

## getTitle


```lua
function love.window.getTitle()
  -> title: string
```


Gets the window title.


[Open in Browser](https://love2d.org/wiki/love.window.getTitle)

@*return* `title` — The current window title.

## getVSync


```lua
function love.window.getVSync()
  -> vsync: number
```


Gets current vertical synchronization (vsync).


[Open in Browser](https://love2d.org/wiki/love.window.getVSync)

@*return* `vsync` — Current vsync status. 1 if enabled, 0 if disabled, and -1 for adaptive vsync.

## hasFocus


```lua
function love.window.hasFocus()
  -> focus: boolean
```


Checks if the game window has keyboard focus.


[Open in Browser](https://love2d.org/wiki/love.window.hasFocus)

@*return* `focus` — True if the window has the focus or false if not.

## hasMouseFocus


```lua
function love.window.hasMouseFocus()
  -> focus: boolean
```


Checks if the game window has mouse focus.


[Open in Browser](https://love2d.org/wiki/love.window.hasMouseFocus)

@*return* `focus` — True if the window has mouse focus or false if not.

## isDisplaySleepEnabled


```lua
function love.window.isDisplaySleepEnabled()
  -> enabled: boolean
```


Gets whether the display is allowed to sleep while the program is running.

Display sleep is disabled by default. Some types of input (e.g. joystick button presses) might not prevent the display from sleeping, if display sleep is allowed.


[Open in Browser](https://love2d.org/wiki/love.window.isDisplaySleepEnabled)

@*return* `enabled` — True if system display sleep is enabled / allowed, false otherwise.

## isMaximized


```lua
function love.window.isMaximized()
  -> maximized: boolean
```


Gets whether the Window is currently maximized.

The window can be maximized if it is not fullscreen and is resizable, and either the user has pressed the window's Maximize button or love.window.maximize has been called.


[Open in Browser](https://love2d.org/wiki/love.window.isMaximized)

@*return* `maximized` — True if the window is currently maximized in windowed mode, false otherwise.

## isMinimized


```lua
function love.window.isMinimized()
  -> minimized: boolean
```


Gets whether the Window is currently minimized.


[Open in Browser](https://love2d.org/wiki/love.window.isMinimized)

@*return* `minimized` — True if the window is currently minimized, false otherwise.

## isOpen


```lua
function love.window.isOpen()
  -> open: boolean
```


Checks if the window is open.


[Open in Browser](https://love2d.org/wiki/love.window.isOpen)

@*return* `open` — True if the window is open, false otherwise.

## isVisible


```lua
function love.window.isVisible()
  -> visible: boolean
```


Checks if the game window is visible.

The window is considered visible if it's not minimized and the program isn't hidden.


[Open in Browser](https://love2d.org/wiki/love.window.isVisible)

@*return* `visible` — True if the window is visible or false if not.

## maximize


```lua
function love.window.maximize()
```


Makes the window as large as possible.

This function has no effect if the window isn't resizable, since it essentially programmatically presses the window's 'maximize' button.


[Open in Browser](https://love2d.org/wiki/love.window.maximize)

## minimize


```lua
function love.window.minimize()
```


Minimizes the window to the system's task bar / dock.


[Open in Browser](https://love2d.org/wiki/love.window.minimize)

## requestAttention


```lua
function love.window.requestAttention(continuous?: boolean)
```


Causes the window to request the attention of the user if it is not in the foreground.

In Windows the taskbar icon will flash, and in OS X the dock icon will bounce.


[Open in Browser](https://love2d.org/wiki/love.window.requestAttention)

@*param* `continuous` — Whether to continuously request attention until the window becomes active, or to do it only once.

## restore


```lua
function love.window.restore()
```


Restores the size and position of the window if it was minimized or maximized.


[Open in Browser](https://love2d.org/wiki/love.window.restore)

## setDisplaySleepEnabled


```lua
function love.window.setDisplaySleepEnabled(enable: boolean)
```


Sets whether the display is allowed to sleep while the program is running.

Display sleep is disabled by default. Some types of input (e.g. joystick button presses) might not prevent the display from sleeping, if display sleep is allowed.


[Open in Browser](https://love2d.org/wiki/love.window.setDisplaySleepEnabled)

@*param* `enable` — True to enable system display sleep, false to disable it.

## setFullscreen


```lua
function love.window.setFullscreen(fullscreen: boolean)
  -> success: boolean
```


Enters or exits fullscreen. The display to use when entering fullscreen is chosen based on which display the window is currently in, if multiple monitors are connected.


[Open in Browser](https://love2d.org/wiki/love.window.setFullscreen)


---

@*param* `fullscreen` — Whether to enter or exit fullscreen mode.

@*return* `success` — True if an attempt to enter fullscreen was successful, false otherwise.

## setIcon


```lua
function love.window.setIcon(imagedata: love.ImageData)
  -> success: boolean
```


Sets the window icon until the game is quit. Not all operating systems support very large icon images.


[Open in Browser](https://love2d.org/wiki/love.window.setIcon)

@*param* `imagedata` — The window icon image.

@*return* `success` — Whether the icon has been set successfully.

## setMode


```lua
function love.window.setMode(width: number, height: number, flags?: { fullscreen: boolean, fullscreentype: "desktop"|"exclusive"|"normal", vsync: boolean, msaa: number, stencil: boolean, depth: number, resizable: boolean, borderless: boolean, centered: boolean, display: number, minwidth: number, minheight: number, highdpi: boolean, x: number, y: number, usedpiscale: boolean, srgb: boolean })
  -> success: boolean
```


Sets the display mode and properties of the window.

If width or height is 0, setMode will use the width and height of the desktop.

Changing the display mode may have side effects: for example, canvases will be cleared and values sent to shaders with canvases beforehand or re-draw to them afterward if you need to.


[Open in Browser](https://love2d.org/wiki/love.window.setMode)

@*param* `width` — Display width.

@*param* `height` — Display height.

@*param* `flags` — The flags table with the options:

@*return* `success` — True if successful, false otherwise.

## setPosition


```lua
function love.window.setPosition(x: number, y: number, displayindex?: number)
```


Sets the position of the window on the screen.

The window position is in the coordinate space of the specified display.


[Open in Browser](https://love2d.org/wiki/love.window.setPosition)

@*param* `x` — The x-coordinate of the window's position.

@*param* `y` — The y-coordinate of the window's position.

@*param* `displayindex` — The index of the display that the new window position is relative to.

## setTitle


```lua
function love.window.setTitle(title: string)
```


Sets the window title.


[Open in Browser](https://love2d.org/wiki/love.window.setTitle)

@*param* `title` — The new window title.

## setVSync


```lua
function love.window.setVSync(vsync: number)
```


Sets vertical synchronization mode.


[Open in Browser](https://love2d.org/wiki/love.window.setVSync)

@*param* `vsync` — VSync number: 1 to enable, 0 to disable, and -1 for adaptive vsync.

## showMessageBox


```lua
function love.window.showMessageBox(title: string, message: string, type?: "error"|"info"|"warning", attachtowindow?: boolean)
  -> success: boolean
```


Displays a message box dialog above the love window. The message box contains a title, optional text, and buttons.


[Open in Browser](https://love2d.org/wiki/love.window.showMessageBox)


---

@*param* `title` — The title of the message box.

@*param* `message` — The text inside the message box.

@*param* `type` — The type of the message box.

@*param* `attachtowindow` — Whether the message box should be attached to the love window or free-floating.

@*return* `success` — Whether the message box was successfully displayed.

```lua
-- 
-- Types of message box dialogs. Different types may have slightly different looks.
-- 
-- 
-- [Open in Browser](https://love2d.org/wiki/MessageBoxType)
-- 
type:
    | "info" -- Informational dialog.
    | "warning" -- Warning dialog.
    | "error" -- Error dialog.
```

## toPixels


```lua
function love.window.toPixels(value: number)
  -> pixelvalue: number
```


Converts a number from density-independent units to pixels.

The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.window.toPixels(800) would return 1600 in that case.

This is used to convert coordinates from the size users are expecting them to display at onscreen to pixels. love.window.fromPixels does the opposite. The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.

Most LÖVE functions return values and expect arguments in terms of pixels rather than density-independent units.


[Open in Browser](https://love2d.org/wiki/love.window.toPixels)


---

@*param* `value` — A number in density-independent units to convert to pixels.

@*return* `pixelvalue` — The converted number, in pixels.

## updateMode


```lua
function love.window.updateMode(width: number, height: number, settings: { fullscreen: boolean, fullscreentype: "desktop"|"exclusive"|"normal", vsync: boolean, msaa: number, resizable: boolean, borderless: boolean, centered: boolean, display: number, minwidth: number, minheight: number, highdpi: boolean, x: number, y: number })
  -> success: boolean
```


Sets the display mode and properties of the window, without modifying unspecified properties.

If width or height is 0, updateMode will use the width and height of the desktop.

Changing the display mode may have side effects: for example, canvases will be cleared. Make sure to save the contents of canvases beforehand or re-draw to them afterward if you need to.


[Open in Browser](https://love2d.org/wiki/love.window.updateMode)

@*param* `width` — Window width.

@*param* `height` — Window height.

@*param* `settings` — The settings table with the following optional fields. Any field not filled in will use the current value that would be returned by love.window.getMode.

@*return* `success` — True if successful, false otherwise.


---

# love.window


```lua
love.window
```


---

# love.window.close


```lua
function love.window.close()
```


---

# love.window.fromPixels


```lua
function love.window.fromPixels(pixelvalue: number)
  -> value: number
```


---

# love.window.getDPIScale


```lua
function love.window.getDPIScale()
  -> scale: number
```


---

# love.window.getDesktopDimensions


```lua
function love.window.getDesktopDimensions(displayindex?: number)
  -> width: number
  2. height: number
```


---

# love.window.getDisplayCount


```lua
function love.window.getDisplayCount()
  -> count: number
```


---

# love.window.getDisplayName


```lua
function love.window.getDisplayName(displayindex?: number)
  -> name: string
```


---

# love.window.getDisplayOrientation


```lua
function love.window.getDisplayOrientation(displayindex?: number)
  -> orientation: "landscape"|"landscapeflipped"|"portrait"|"portraitflipped"|"unknown"
```


---

# love.window.getFullscreen


```lua
function love.window.getFullscreen()
  -> fullscreen: boolean
  2. fstype: "desktop"|"exclusive"|"normal"
```


---

# love.window.getFullscreenModes


```lua
function love.window.getFullscreenModes(displayindex?: number)
  -> modes: table
```


---

# love.window.getIcon


```lua
function love.window.getIcon()
  -> imagedata: love.ImageData
```


---

# love.window.getMode


```lua
function love.window.getMode()
  -> width: number
  2. height: number
  3. flags: { fullscreen: boolean, fullscreentype: "desktop"|"exclusive"|"normal", vsync: boolean, msaa: number, resizable: boolean, borderless: boolean, centered: boolean, display: number, minwidth: number, minheight: number, highdpi: boolean, refreshrate: number, x: number, y: number, srgb: boolean }
```


---

# love.window.getPosition


```lua
function love.window.getPosition()
  -> x: number
  2. y: number
  3. displayindex: number
```


---

# love.window.getSafeArea


```lua
function love.window.getSafeArea()
  -> x: number
  2. y: number
  3. w: number
  4. h: number
```


---

# love.window.getTitle


```lua
function love.window.getTitle()
  -> title: string
```


---

# love.window.getVSync


```lua
function love.window.getVSync()
  -> vsync: number
```


---

# love.window.hasFocus


```lua
function love.window.hasFocus()
  -> focus: boolean
```


---

# love.window.hasMouseFocus


```lua
function love.window.hasMouseFocus()
  -> focus: boolean
```


---

# love.window.isDisplaySleepEnabled


```lua
function love.window.isDisplaySleepEnabled()
  -> enabled: boolean
```


---

# love.window.isMaximized


```lua
function love.window.isMaximized()
  -> maximized: boolean
```


---

# love.window.isMinimized


```lua
function love.window.isMinimized()
  -> minimized: boolean
```


---

# love.window.isOpen


```lua
function love.window.isOpen()
  -> open: boolean
```


---

# love.window.isVisible


```lua
function love.window.isVisible()
  -> visible: boolean
```


---

# love.window.maximize


```lua
function love.window.maximize()
```


---

# love.window.minimize


```lua
function love.window.minimize()
```


---

# love.window.requestAttention


```lua
function love.window.requestAttention(continuous?: boolean)
```


---

# love.window.restore


```lua
function love.window.restore()
```


---

# love.window.setDisplaySleepEnabled


```lua
function love.window.setDisplaySleepEnabled(enable: boolean)
```


---

# love.window.setFullscreen


```lua
function love.window.setFullscreen(fullscreen: boolean)
  -> success: boolean
```


---

# love.window.setIcon


```lua
function love.window.setIcon(imagedata: love.ImageData)
  -> success: boolean
```


---

# love.window.setMode


```lua
function love.window.setMode(width: number, height: number, flags?: { fullscreen: boolean, fullscreentype: "desktop"|"exclusive"|"normal", vsync: boolean, msaa: number, stencil: boolean, depth: number, resizable: boolean, borderless: boolean, centered: boolean, display: number, minwidth: number, minheight: number, highdpi: boolean, x: number, y: number, usedpiscale: boolean, srgb: boolean })
  -> success: boolean
```


---

# love.window.setPosition


```lua
function love.window.setPosition(x: number, y: number, displayindex?: number)
```


---

# love.window.setTitle


```lua
function love.window.setTitle(title: string)
```


---

# love.window.setVSync


```lua
function love.window.setVSync(vsync: number)
```


---

# love.window.showMessageBox


```lua
function love.window.showMessageBox(title: string, message: string, type?: "error"|"info"|"warning", attachtowindow?: boolean)
  -> success: boolean
```


---

# love.window.toPixels


```lua
function love.window.toPixels(value: number)
  -> pixelvalue: number
```


---

# love.window.updateMode


```lua
function love.window.updateMode(width: number, height: number, settings: { fullscreen: boolean, fullscreentype: "desktop"|"exclusive"|"normal", vsync: boolean, msaa: number, resizable: boolean, borderless: boolean, centered: boolean, display: number, minwidth: number, minheight: number, highdpi: boolean, x: number, y: number })
  -> success: boolean
```


---

# math


```lua
mathlib
```


---

# math.abs


```lua
function math.abs(x: <Number:number>)
  -> <Number:number>
```


---

# math.acos


```lua
function math.acos(x: number)
  -> number
```


---

# math.asin


```lua
function math.asin(x: number)
  -> number
```


---

# math.atan


```lua
function math.atan(y: number)
  -> number
```


---

# math.atan2


```lua
function math.atan2(y: number, x: number)
  -> number
```


---

# math.ceil


```lua
function math.ceil(x: number)
  -> integer
```


---

# math.cos


```lua
function math.cos(x: number)
  -> number
```


---

# math.cosh


```lua
function math.cosh(x: number)
  -> number
```


---

# math.deg


```lua
function math.deg(x: number)
  -> number
```


---

# math.exp


```lua
function math.exp(x: number)
  -> number
```


---

# math.floor


```lua
function math.floor(x: number)
  -> integer
```


---

# math.fmod


```lua
function math.fmod(x: number, y: number)
  -> number
```


---

# math.frexp


```lua
function math.frexp(x: number)
  -> m: number
  2. e: number
```


---

# math.ldexp


```lua
function math.ldexp(m: number, e: number)
  -> number
```


---

# math.log


```lua
function math.log(x: number, base?: integer)
  -> number
```


---

# math.log10


```lua
function math.log10(x: number)
  -> number
```


---

# math.max


```lua
function math.max(x: <Number:number>, ...<Number:number>)
  -> <Number:number>
```


---

# math.min


```lua
function math.min(x: <Number:number>, ...<Number:number>)
  -> <Number:number>
```


---

# math.modf


```lua
function math.modf(x: number)
  -> integer
  2. number
```


---

# math.pow


```lua
function math.pow(x: number, y: number)
  -> number
```


---

# math.rad


```lua
function math.rad(x: number)
  -> number
```


---

# math.random


```lua
function math.random(m: integer, n: integer)
  -> integer
```


---

# math.randomseed


```lua
function math.randomseed(x: integer)
```


---

# math.sin


```lua
function math.sin(x: number)
  -> number
```


---

# math.sinh


```lua
function math.sinh(x: number)
  -> number
```


---

# math.sqrt


```lua
function math.sqrt(x: number)
  -> number
```


---

# math.tan


```lua
function math.tan(x: number)
  -> number
```


---

# math.tanh


```lua
function math.tanh(x: number)
  -> number
```


---

# math.tointeger


```lua
function math.tointeger(x: any)
  -> integer?
```


---

# math.type


```lua
function math.type(x: any)
  -> "float"|"integer"|'nil'
```


---

# math.ult


```lua
function math.ult(m: integer, n: integer)
  -> boolean
```


---

# mathlib

## abs


```lua
function math.abs(x: <Number:number>)
  -> <Number:number>
```


Returns the absolute value of `x`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.abs"])

## acos


```lua
function math.acos(x: number)
  -> number
```


Returns the arc cosine of `x` (in radians).

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.acos"])

## asin


```lua
function math.asin(x: number)
  -> number
```


Returns the arc sine of `x` (in radians).

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.asin"])

## atan


```lua
function math.atan(y: number)
  -> number
```


Returns the arc tangent of `x` (in radians).

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.atan"])

## atan2


```lua
function math.atan2(y: number, x: number)
  -> number
```


Returns the arc tangent of `y/x` (in radians).

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.atan2"])

## ceil


```lua
function math.ceil(x: number)
  -> integer
```


Returns the smallest integral value larger than or equal to `x`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.ceil"])

## cos


```lua
function math.cos(x: number)
  -> number
```


Returns the cosine of `x` (assumed to be in radians).

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.cos"])

## cosh


```lua
function math.cosh(x: number)
  -> number
```


Returns the hyperbolic cosine of `x` (assumed to be in radians).

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.cosh"])

## deg


```lua
function math.deg(x: number)
  -> number
```


Converts the angle `x` from radians to degrees.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.deg"])

## exp


```lua
function math.exp(x: number)
  -> number
```


Returns the value `e^x` (where `e` is the base of natural logarithms).

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.exp"])

## floor


```lua
function math.floor(x: number)
  -> integer
```


Returns the largest integral value smaller than or equal to `x`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.floor"])

## fmod


```lua
function math.fmod(x: number, y: number)
  -> number
```


Returns the remainder of the division of `x` by `y` that rounds the quotient towards zero.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.fmod"])

## frexp


```lua
function math.frexp(x: number)
  -> m: number
  2. e: number
```


Decompose `x` into tails and exponents. Returns `m` and `e` such that `x = m * (2 ^ e)`, `e` is an integer and the absolute value of `m` is in the range [0.5, 1) (or zero when `x` is zero).

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.frexp"])

## huge


```lua
number
```


A value larger than any other numeric value.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.huge"])


## ldexp


```lua
function math.ldexp(m: number, e: number)
  -> number
```


Returns `m * (2 ^ e)` .

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.ldexp"])

## log


```lua
function math.log(x: number, base?: integer)
  -> number
```


Returns the logarithm of `x` in the given base.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.log"])

## log10


```lua
function math.log10(x: number)
  -> number
```


Returns the base-10 logarithm of x.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.log10"])

## max


```lua
function math.max(x: <Number:number>, ...<Number:number>)
  -> <Number:number>
```


Returns the argument with the maximum value, according to the Lua operator `<`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.max"])

## min


```lua
function math.min(x: <Number:number>, ...<Number:number>)
  -> <Number:number>
```


Returns the argument with the minimum value, according to the Lua operator `<`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.min"])

## modf


```lua
function math.modf(x: number)
  -> integer
  2. number
```


Returns the integral part of `x` and the fractional part of `x`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.modf"])

## pi


```lua
number
```


The value of *π*.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.pi"])


## pow


```lua
function math.pow(x: number, y: number)
  -> number
```


Returns `x ^ y` .

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.pow"])

## rad


```lua
function math.rad(x: number)
  -> number
```


Converts the angle `x` from degrees to radians.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.rad"])

## random


```lua
function math.random(m: integer, n: integer)
  -> integer
```


* `math.random()`: Returns a float in the range [0,1).
* `math.random(n)`: Returns a integer in the range [1, n].
* `math.random(m, n)`: Returns a integer in the range [m, n].


[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.random"])

## randomseed


```lua
function math.randomseed(x: integer)
```


Sets `x` as the "seed" for the pseudo-random generator.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.randomseed"])

## sin


```lua
function math.sin(x: number)
  -> number
```


Returns the sine of `x` (assumed to be in radians).

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.sin"])

## sinh


```lua
function math.sinh(x: number)
  -> number
```


Returns the hyperbolic sine of `x` (assumed to be in radians).

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.sinh"])

## sqrt


```lua
function math.sqrt(x: number)
  -> number
```


Returns the square root of `x`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.sqrt"])

## tan


```lua
function math.tan(x: number)
  -> number
```


Returns the tangent of `x` (assumed to be in radians).

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.tan"])

## tanh


```lua
function math.tanh(x: number)
  -> number
```


Returns the hyperbolic tangent of `x` (assumed to be in radians).

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.tanh"])

## tointeger


```lua
function math.tointeger(x: any)
  -> integer?
```


Miss locale <math.tointeger>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.tointeger"])

## type


```lua
function math.type(x: any)
  -> "float"|"integer"|'nil'
```


Miss locale <math.type>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.type"])


```lua
return #1:
    | "integer"
    | "float"
    | 'nil'
```

## ult


```lua
function math.ult(m: integer, n: integer)
  -> boolean
```


Miss locale <math.ult>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-math.ult"])


---

# metatable

## __add


```lua
fun(t1: any, t2: any):any|nil
```

## __call


```lua
fun(t: any, ...any):...unknown|nil
```

## __concat


```lua
fun(t1: any, t2: any):any|nil
```

## __div


```lua
fun(t1: any, t2: any):any|nil
```

## __eq


```lua
fun(t1: any, t2: any):boolean|nil
```

## __gc


```lua
fun(t: any)|nil
```

## __index


```lua
table|fun(t: any, k: any):any|nil
```

## __le


```lua
fun(t1: any, t2: any):boolean|nil
```

## __len


```lua
fun(t: any):integer|nil
```

## __lt


```lua
fun(t1: any, t2: any):boolean|nil
```

## __metatable


```lua
any
```

## __mod


```lua
fun(t1: any, t2: any):any|nil
```

## __mode


```lua
'k'|'kv'|'v'|nil
```

## __mul


```lua
fun(t1: any, t2: any):any|nil
```

## __newindex


```lua
table|fun(t: any, k: any, v: any)|nil
```

## __pow


```lua
fun(t1: any, t2: any):any|nil
```

## __sub


```lua
fun(t1: any, t2: any):any|nil
```

## __tostring


```lua
fun(t: any):string|nil
```

## __unm


```lua
fun(t: any):any|nil
```


---

# module


```lua
function module(name: string, ...any)
```


---

# newproxy


```lua
function newproxy(proxy: boolean|table|userdata)
  -> userdata
```


---

# next


```lua
function next(table: table<<K>, <V>>, index?: <K>)
  -> <K>?
  2. <V>?
```


---

# nil


---

# number


---

# openmode


---

# os


```lua
oslib
```


---

# os.clock


```lua
function os.clock()
  -> number
```


---

# os.date


```lua
function os.date(format?: string, time?: integer)
  -> string|osdate
```


---

# os.difftime


```lua
function os.difftime(t2: integer, t1: integer)
  -> integer
```


---

# os.execute


```lua
function os.execute(command?: string)
  -> suc: boolean?
  2. exitcode: ("exit"|"signal")?
  3. code: integer?
```


---

# os.exit


```lua
function os.exit(code?: boolean|integer, close?: boolean)
```


---

# os.getenv


```lua
function os.getenv(varname: string)
  -> string?
```


---

# os.remove


```lua
function os.remove(filename: string)
  -> suc: boolean
  2. errmsg: string?
```


---

# os.rename


```lua
function os.rename(oldname: string, newname: string)
  -> suc: boolean
  2. errmsg: string?
```


---

# os.setlocale


```lua
function os.setlocale(locale: string|nil, category?: "all"|"collate"|"ctype"|"monetary"|"numeric"...(+1))
  -> localecategory: string
```


---

# os.time


```lua
function os.time(date?: osdateparam)
  -> integer
```


---

# os.tmpname


```lua
function os.tmpname()
  -> string
```


---

# osdate

## day


```lua
string|integer
```


1-31

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.day"])


## hour


```lua
string|integer
```


0-23

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.hour"])


## isdst


```lua
boolean
```


daylight saving flag, a boolean

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.isdst"])


## min


```lua
string|integer
```


0-59

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.min"])


## month


```lua
string|integer
```


1-12

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.month"])


## sec


```lua
string|integer
```


0-61

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.sec"])


## wday


```lua
string|integer
```


weekday, 1–7, Sunday is 1

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.wday"])


## yday


```lua
string|integer
```


day of the year, 1–366

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.yday"])


## year


```lua
string|integer
```


four digits

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.year"])



---

# osdateparam

## day


```lua
string|integer
```


1-31

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.day"])


## hour


```lua
(string|integer)?
```


0-23

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.hour"])


## isdst


```lua
boolean?
```


daylight saving flag, a boolean

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.isdst"])


## min


```lua
(string|integer)?
```


0-59

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.min"])


## month


```lua
string|integer
```


1-12

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.month"])


## sec


```lua
(string|integer)?
```


0-61

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.sec"])


## wday


```lua
(string|integer)?
```


weekday, 1–7, Sunday is 1

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.wday"])


## yday


```lua
(string|integer)?
```


day of the year, 1–366

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.yday"])


## year


```lua
string|integer
```


four digits

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-osdate.year"])



---

# oslib

## clock


```lua
function os.clock()
  -> number
```


Returns an approximation of the amount in seconds of CPU time used by the program.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-os.clock"])

## date


```lua
function os.date(format?: string, time?: integer)
  -> string|osdate
```


Returns a string or a table containing date and time, formatted according to the given string `format`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-os.date"])

## difftime


```lua
function os.difftime(t2: integer, t1: integer)
  -> integer
```


Returns the difference, in seconds, from time `t1` to time `t2`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-os.difftime"])

## execute


```lua
function os.execute(command?: string)
  -> suc: boolean?
  2. exitcode: ("exit"|"signal")?
  3. code: integer?
```


Passes `command` to be executed by an operating system shell.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-os.execute"])


```lua
exitcode:
    | "exit"
    | "signal"
```

## exit


```lua
function os.exit(code?: boolean|integer, close?: boolean)
```


Calls the ISO C function `exit` to terminate the host program.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-os.exit"])

## getenv


```lua
function os.getenv(varname: string)
  -> string?
```


Returns the value of the process environment variable `varname`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-os.getenv"])

## remove


```lua
function os.remove(filename: string)
  -> suc: boolean
  2. errmsg: string?
```


Deletes the file with the given name.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-os.remove"])

## rename


```lua
function os.rename(oldname: string, newname: string)
  -> suc: boolean
  2. errmsg: string?
```


Renames the file or directory named `oldname` to `newname`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-os.rename"])

## setlocale


```lua
function os.setlocale(locale: string|nil, category?: "all"|"collate"|"ctype"|"monetary"|"numeric"...(+1))
  -> localecategory: string
```


Sets the current locale of the program.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-os.setlocale"])


```lua
category:
   -> "all"
    | "collate"
    | "ctype"
    | "monetary"
    | "numeric"
    | "time"
```

## time


```lua
function os.time(date?: osdateparam)
  -> integer
```


Returns the current time when called without arguments, or a time representing the local date and time specified by the given table.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-os.time"])

## tmpname


```lua
function os.tmpname()
  -> string
```


Returns a string with a file name that can be used for a temporary file.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-os.tmpname"])


---

# package


```lua
packagelib
```


---

# package.config


```lua
string
```


---

# package.loaders


```lua
table
```


---

# package.loadlib


```lua
function package.loadlib(libname: string, funcname: string)
  -> any
```


---

# package.searchers


```lua
table
```


---

# package.searchpath


```lua
function package.searchpath(name: string, path: string, sep?: string, rep?: string)
  -> filename: string?
  2. errmsg: string?
```


---

# package.seeall


```lua
function package.seeall(module: table)
```


---

# packagelib

## config


```lua
string
```


A string describing some compile-time configurations for packages.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-package.config"])


## cpath


```lua
string
```


The path used by `require` to search for a C loader.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-package.cpath"])


## loaded


```lua
table
```


A table used by `require` to control which modules are already loaded.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-package.loaded"])


## loaders


```lua
table
```


A table used by `require` to control how to load modules.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-package.loaders"])


## loadlib


```lua
function package.loadlib(libname: string, funcname: string)
  -> any
```


Dynamically links the host program with the C library `libname`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-package.loadlib"])

## path


```lua
string
```


The path used by `require` to search for a Lua loader.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-package.path"])


## preload


```lua
table
```


A table to store loaders for specific modules.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-package.preload"])


## searchers


```lua
table
```


A table used by `require` to control how to load modules.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-package.searchers"])


## searchpath


```lua
function package.searchpath(name: string, path: string, sep?: string, rep?: string)
  -> filename: string?
  2. errmsg: string?
```


Searches for the given `name` in the given `path`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-package.searchpath"])

## seeall


```lua
function package.seeall(module: table)
```


Sets a metatable for `module` with its `__index` field referring to the global environment, so that this module inherits values from the global environment. To be used as an option to function `module` .

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-package.seeall"])


---

# pairs


```lua
function pairs(t: <T:table>)
  -> fun(table: table<<K>, <V>>, index?: <K>):<K>, <V>
  2. <T:table>
```


---

# pcall


```lua
function pcall(f: fun(...any):...unknown, arg1?: any, ...any)
  -> success: boolean
  2. result: any
  3. ...any
```


---

# popenmode


---

# print


```lua
function print(...any)
```


---

# rawequal


```lua
function rawequal(v1: any, v2: any)
  -> boolean
```


---

# rawget


```lua
function rawget(table: table, index: any)
  -> any
```


---

# rawlen


```lua
function rawlen(v: string|table)
  -> len: integer
```


---

# rawset


```lua
function rawset(table: table, index: any, value: any)
  -> table
```


---

# readmode


---

# require


```lua
function require(modname: string)
  -> unknown
```


---

# seekwhence


---

# select


```lua
function select(index: integer|"#", ...any)
  -> any
```


---

# setfenv


```lua
function setfenv(f: integer|fun(...any):...unknown, table: table)
  -> function
```


---

# setmetatable


```lua
function setmetatable(table: table, metatable?: table|metatable)
  -> table
```


---

# string


```lua
stringlib
```


---

# string

## byte


```lua
function string.byte(s: string|number, i?: integer, j?: integer)
  -> ...integer
```


Returns the internal numeric codes of the characters `s[i], s[i+1], ..., s[j]`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.byte"])

## char


```lua
function string.char(byte: integer, ...integer)
  -> string
```


Returns a string with length equal to the number of arguments, in which each character has the internal numeric code equal to its corresponding argument.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.char"])

## dump


```lua
function string.dump(f: fun(...any):...unknown, strip?: boolean)
  -> string
```


Returns a string containing a binary representation (a *binary chunk*) of the given function.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.dump"])

## find


```lua
function string.find(s: string|number, pattern: string|number, init?: integer, plain?: boolean)
  -> start: integer|nil
  2. end: integer|nil
  3. ...any
```


Miss locale <string.find>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.find"])

@*return* `start`

@*return* `end`

@*return* `...` — captured

## format


```lua
function string.format(s: string|number, ...any)
  -> string
```


Returns a formatted version of its variable number of arguments following the description given in its first argument.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.format"])

## gmatch


```lua
function string.gmatch(s: string|number, pattern: string|number)
  -> fun():string, ...unknown
```


Miss locale <string.gmatch>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.gmatch"])

## gsub


```lua
function string.gsub(s: string|number, pattern: string|number, repl: string|number|function|table, n?: integer)
  -> string
  2. count: integer
```


Miss locale <string.gsub>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.gsub"])

## len


```lua
function string.len(s: string|number)
  -> integer
```


Returns its length.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.len"])

## lower


```lua
function string.lower(s: string|number)
  -> string
```


Returns a copy of this string with all uppercase letters changed to lowercase.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.lower"])

## match


```lua
function string.match(s: string|number, pattern: string|number, init?: integer)
  -> ...any
```


Miss locale <string.match>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.match"])

## pack


```lua
function string.pack(fmt: string, v1: string|number, v2?: string|number, ...string|number)
  -> binary: string
```


Miss locale <string.pack>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.pack"])

## packsize


```lua
function string.packsize(fmt: string)
  -> integer
```


Miss locale <string.packsize>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.packsize"])

## rep


```lua
function string.rep(s: string|number, n: integer, sep?: string|number)
  -> string
```


Returns a string that is the concatenation of `n` copies of the string `s` separated by the string `sep`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.rep"])

## reverse


```lua
function string.reverse(s: string|number)
  -> string
```


Returns a string that is the string `s` reversed.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.reverse"])

## sub


```lua
function string.sub(s: string|number, i: integer, j?: integer)
  -> string
```


Returns the substring of the string that starts at `i` and continues until `j`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.sub"])

## unpack


```lua
function string.unpack(fmt: string, s: string, pos?: integer)
  -> ...any
```


Returns the values packed in string according to the format string `fmt` (see [§6.4.2](command:extension.lua.doc?["en-us/51/manual.html/6.4.2"])) .

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.unpack"])

## upper


```lua
function string.upper(s: string|number)
  -> string
```


Returns a copy of this string with all lowercase letters changed to uppercase.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.upper"])


---

# string.buffer

## commit


```lua
(method) string.buffer:commit(used: integer)
  -> string.buffer
```

 Appends the used bytes of the previously returned write space to the buffer data.

## decode


```lua
(method) string.buffer:decode()
  -> obj: string|number|table|nil
```

 De-serializes one object from the buffer.

 The returned object may be any of the supported Lua types — even `nil`.

 This function may throw an error when fed with malformed or incomplete encoded data.

 Leaves any left-over data in the buffer.

 Attempting to de-serialize an FFI type will throw an error, if the FFI library is not built-in or has not been loaded, yet.

## encode


```lua
(method) string.buffer:encode(obj: string|number|table)
  -> string.buffer
```

 Serializes (encodes) the Lua object to the buffer

 This function may throw an error when attempting to serialize unsupported object types, circular references or deeply nested tables.

## free


```lua
(method) string.buffer:free()
```

 The buffer space of the buffer object is freed. The object itself remains intact, empty and may be reused.

 Note: you normally don't need to use this method. The garbage collector automatically frees the buffer space, when the buffer object is collected. Use this method, if you need to free the associated memory immediately.

## get


```lua
(method) string.buffer:get(len?: integer, ...integer|nil)
  -> ...string
```

 Consumes the buffer data and returns one or more strings. If called without arguments, the whole buffer data is consumed. If called with a number, up to `len` bytes are consumed. A `nil` argument consumes the remaining buffer space (this only makes sense as the last argument). Multiple arguments consume the buffer data in the given order.

 Note: a zero length or no remaining buffer data returns an empty string and not `nil`.

## put


```lua
(method) string.buffer:put(data: string|number|table, ...string|number|table)
  -> string.buffer
```

 Appends a string str, a number num or any object obj with a `__tostring` metamethod to the buffer. Multiple arguments are appended in the given order.

 Appending a buffer to a buffer is possible and short-circuited internally. But it still involves a copy. Better combine the buffer writes to use a single buffer.

## putcdata


```lua
(method) string.buffer:putcdata(cdata: ffi.cdata*, len: integer)
  -> string.buffer
```

 Appends the given len number of bytes from the memory pointed to by the FFI cdata object to the buffer. The object needs to be convertible to a (constant) pointer.

## putf


```lua
(method) string.buffer:putf(format: string, ...string|number|table)
  -> string.buffer
```

 Appends the formatted arguments to the buffer. The format string supports the same options as string.format().

## ref


```lua
(method) string.buffer:ref()
  -> ptr: ffi.cdata*
  2. len: integer
```

 Returns an uint8_t * FFI cdata pointer ptr that points to the buffer data. The length of the buffer data in bytes is returned in len.

 The returned pointer can be directly passed to C functions that expect a buffer and a length. You can also do bytewise reads (`local x = ptr[i]`) or writes (`ptr[i] = 0x40`) of the buffer data.

 In conjunction with the `buf:skip()` method, this allows zero-copy use of C write-style APIs:

 ```lua
 repeat
   local ptr, len = buf:ref()
   if len == 0 then break end
   local n = C.write(fd, ptr, len)
   if n < 0 then error("write error") end
   buf:skip(n)
 until n >= len
 ```

 Unlike Lua strings, buffer data is not implicitly zero-terminated. It's not safe to pass ptr to C functions that expect zero-terminated strings. If you're not using len, then you're doing something wrong.

@*return* `ptr` — an uint8_t * FFI cdata pointer that points to the buffer data.

@*return* `len` — length of the buffer data in bytes

## reserve


```lua
(method) string.buffer:reserve(size: integer)
  -> ptr: ffi.cdata*
  2. len: integer
```

 The reserve method reserves at least size bytes of write space in the buffer. It returns an uint8_t * FFI cdata pointer ptr that points to this space.

 The available length in bytes is returned in len. This is at least size bytes, but may be more to facilitate efficient buffer growth. You can either make use of the additional space or ignore len and only use size bytes.

 This, along with `buf:commit()` allow zero-copy use of C read-style APIs:

 ```lua
 local MIN_SIZE = 65536
 repeat
   local ptr, len = buf:reserve(MIN_SIZE)
   local n = C.read(fd, ptr, len)
   if n == 0 then break end -- EOF.
   if n < 0 then error("read error") end
   buf:commit(n)
 until false
 ```

 The reserved write space is not initialized. At least the used bytes must be written to before calling the commit method. There's no need to call the commit method, if nothing is added to the buffer (e.g. on error).

@*return* `ptr` — an uint8_t * FFI cdata pointer that points to this space

@*return* `len` — available length (bytes)

## reset


```lua
(method) string.buffer:reset()
  -> string.buffer
```

 Reset (empty) the buffer. The allocated buffer space is not freed and may be reused.

## set


```lua
(method) string.buffer:set(str: string|number|table)
  -> string.buffer
```

 This method allows zero-copy consumption of a string or an FFI cdata object as a buffer. It stores a reference to the passed string str or the FFI cdata object in the buffer. Any buffer space originally allocated is freed. This is not an append operation, unlike the `buf:put*()` methods.

 After calling this method, the buffer behaves as if `buf:free():put(str)` or `buf:free():put(cdata, len)` had been called. However, the data is only referenced and not copied, as long as the buffer is only consumed.

 In case the buffer is written to later on, the referenced data is copied and the object reference is removed (copy-on-write semantics).

 The stored reference is an anchor for the garbage collector and keeps the originally passed string or FFI cdata object alive.

## skip


```lua
(method) string.buffer:skip(len: integer)
  -> string.buffer
```

 Skips (consumes) len bytes from the buffer up to the current length of the buffer data.

## tostring


```lua
(method) string.buffer:tostring()
  -> string
```

 Creates a string from the buffer data, but doesn't consume it. The buffer remains unchanged.

 Buffer objects also define a `__tostring metamethod`. This means buffers can be passed to the global `tostring()` function and many other functions that accept this in place of strings. The important internal uses in functions like `io.write()` are short-circuited to avoid the creation of an intermediate string object.


---

# string.buffer.data


---

# string.buffer.serialization.opts

## dict


```lua
string[]
```

## metatable


```lua
table[]
```


---

# string.byte


```lua
function string.byte(s: string|number, i?: integer, j?: integer)
  -> ...integer
```


---

# string.char


```lua
function string.char(byte: integer, ...integer)
  -> string
```


---

# string.dump


```lua
function string.dump(f: fun(...any):...unknown, strip?: boolean)
  -> string
```


---

# string.find


```lua
function string.find(s: string|number, pattern: string|number, init?: integer, plain?: boolean)
  -> start: integer|nil
  2. end: integer|nil
  3. ...any
```


---

# string.format


```lua
function string.format(s: string|number, ...any)
  -> string
```


---

# string.gmatch


```lua
function string.gmatch(s: string|number, pattern: string|number)
  -> fun():string, ...unknown
```


---

# string.gsub


```lua
function string.gsub(s: string|number, pattern: string|number, repl: string|number|function|table, n?: integer)
  -> string
  2. count: integer
```


---

# string.len


```lua
function string.len(s: string|number)
  -> integer
```


---

# string.lower


```lua
function string.lower(s: string|number)
  -> string
```


---

# string.match


```lua
function string.match(s: string|number, pattern: string|number, init?: integer)
  -> ...any
```


---

# string.pack


```lua
function string.pack(fmt: string, v1: string|number, v2?: string|number, ...string|number)
  -> binary: string
```


---

# string.packsize


```lua
function string.packsize(fmt: string)
  -> integer
```


---

# string.rep


```lua
function string.rep(s: string|number, n: integer, sep?: string|number)
  -> string
```


---

# string.reverse


```lua
function string.reverse(s: string|number)
  -> string
```


---

# string.sub


```lua
function string.sub(s: string|number, i: integer, j?: integer)
  -> string
```


---

# string.unpack


```lua
function string.unpack(fmt: string, s: string, pos?: integer)
  -> ...any
```


---

# string.upper


```lua
function string.upper(s: string|number)
  -> string
```


---

# stringlib

## byte


```lua
function string.byte(s: string|number, i?: integer, j?: integer)
  -> ...integer
```


Returns the internal numeric codes of the characters `s[i], s[i+1], ..., s[j]`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.byte"])

## char


```lua
function string.char(byte: integer, ...integer)
  -> string
```


Returns a string with length equal to the number of arguments, in which each character has the internal numeric code equal to its corresponding argument.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.char"])

## dump


```lua
function string.dump(f: fun(...any):...unknown, strip?: boolean)
  -> string
```


Returns a string containing a binary representation (a *binary chunk*) of the given function.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.dump"])

## find


```lua
function string.find(s: string|number, pattern: string|number, init?: integer, plain?: boolean)
  -> start: integer|nil
  2. end: integer|nil
  3. ...any
```


Miss locale <string.find>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.find"])

@*return* `start`

@*return* `end`

@*return* `...` — captured

## format


```lua
function string.format(s: string|number, ...any)
  -> string
```


Returns a formatted version of its variable number of arguments following the description given in its first argument.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.format"])

## gmatch


```lua
function string.gmatch(s: string|number, pattern: string|number)
  -> fun():string, ...unknown
```


Miss locale <string.gmatch>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.gmatch"])

## gsub


```lua
function string.gsub(s: string|number, pattern: string|number, repl: string|number|function|table, n?: integer)
  -> string
  2. count: integer
```


Miss locale <string.gsub>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.gsub"])

## len


```lua
function string.len(s: string|number)
  -> integer
```


Returns its length.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.len"])

## lower


```lua
function string.lower(s: string|number)
  -> string
```


Returns a copy of this string with all uppercase letters changed to lowercase.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.lower"])

## match


```lua
function string.match(s: string|number, pattern: string|number, init?: integer)
  -> ...any
```


Miss locale <string.match>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.match"])

## pack


```lua
function string.pack(fmt: string, v1: string|number, v2?: string|number, ...string|number)
  -> binary: string
```


Miss locale <string.pack>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.pack"])

## packsize


```lua
function string.packsize(fmt: string)
  -> integer
```


Miss locale <string.packsize>

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.packsize"])

## rep


```lua
function string.rep(s: string|number, n: integer, sep?: string|number)
  -> string
```


Returns a string that is the concatenation of `n` copies of the string `s` separated by the string `sep`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.rep"])

## reverse


```lua
function string.reverse(s: string|number)
  -> string
```


Returns a string that is the string `s` reversed.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.reverse"])

## sub


```lua
function string.sub(s: string|number, i: integer, j?: integer)
  -> string
```


Returns the substring of the string that starts at `i` and continues until `j`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.sub"])

## unpack


```lua
function string.unpack(fmt: string, s: string, pos?: integer)
  -> ...any
```


Returns the values packed in string according to the format string `fmt` (see [§6.4.2](command:extension.lua.doc?["en-us/51/manual.html/6.4.2"])) .

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.unpack"])

## upper


```lua
function string.upper(s: string|number)
  -> string
```


Returns a copy of this string with all lowercase letters changed to uppercase.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-string.upper"])


---

# table


---

# table


```lua
tablelib
```


---

# table.concat


```lua
function table.concat(list: table, sep?: string, i?: integer, j?: integer)
  -> string
```


---

# table.foreach


```lua
function table.foreach(list: any, callback: fun(key: string, value: any):<T>|nil)
  -> <T>|nil
```


---

# table.foreachi


```lua
function table.foreachi(list: any, callback: fun(key: string, value: any):<T>|nil)
  -> <T>|nil
```


---

# table.getn


```lua
function table.getn(list: <T>[])
  -> integer
```


---

# table.insert


```lua
function table.insert(list: table, pos: integer, value: any)
```


---

# table.maxn


```lua
function table.maxn(table: table)
  -> integer
```


---

# table.move


```lua
function table.move(a1: table, f: integer, e: integer, t: integer, a2?: table)
  -> a2: table
```


---

# table.pack


```lua
function table.pack(...any)
  -> table
```


---

# table.remove


```lua
function table.remove(list: table, pos?: integer)
  -> any
```


---

# table.sort


```lua
function table.sort(list: <T>[], comp?: fun(a: <T>, b: <T>):boolean)
```


---

# table.unpack


```lua
function table.unpack(list: { [1]: <T1>, [2]: <T2>, [3]: <T3>, [4]: <T4>, [5]: <T5>, [6]: <T6>, [7]: <T7>, [8]: <T8>, [9]: <T9>, [10]: <T10> }, i?: integer, j?: integer)
  -> <T1>
  2. <T2>
  3. <T3>
  4. <T4>
  5. <T5>
  6. <T6>
  7. <T7>
  8. <T8>
  9. <T9>
 10. <T10>
```


---

# tablelib

## concat


```lua
function table.concat(list: table, sep?: string, i?: integer, j?: integer)
  -> string
```


Given a list where all elements are strings or numbers, returns the string `list[i]..sep..list[i+1] ··· sep..list[j]`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-table.concat"])

## foreach


```lua
function table.foreach(list: any, callback: fun(key: string, value: any):<T>|nil)
  -> <T>|nil
```


Executes the given f over all elements of table. For each element, f is called with the index and respective value as arguments. If f returns a non-nil value, then the loop is broken, and this value is returned as the final value of foreach.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-table.foreach"])

## foreachi


```lua
function table.foreachi(list: any, callback: fun(key: string, value: any):<T>|nil)
  -> <T>|nil
```


Executes the given f over the numerical indices of table. For each index, f is called with the index and respective value as arguments. Indices are visited in sequential order, from 1 to n, where n is the size of the table. If f returns a non-nil value, then the loop is broken and this value is returned as the result of foreachi.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-table.foreachi"])

## getn


```lua
function table.getn(list: <T>[])
  -> integer
```


Returns the number of elements in the table. This function is equivalent to `#list`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-table.getn"])

## insert


```lua
function table.insert(list: table, pos: integer, value: any)
```


Inserts element `value` at position `pos` in `list`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-table.insert"])

## maxn


```lua
function table.maxn(table: table)
  -> integer
```


Returns the largest positive numerical index of the given table, or zero if the table has no positive numerical indices.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-table.maxn"])

## move


```lua
function table.move(a1: table, f: integer, e: integer, t: integer, a2?: table)
  -> a2: table
```


Moves elements from table `a1` to table `a2`.
```lua
a2[t],··· =
a1[f],···,a1[e]
return a2
```


[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-table.move"])

## pack


```lua
function table.pack(...any)
  -> table
```


Returns a new table with all arguments stored into keys `1`, `2`, etc. and with a field `"n"` with the total number of arguments.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-table.pack"])

## remove


```lua
function table.remove(list: table, pos?: integer)
  -> any
```


Removes from `list` the element at position `pos`, returning the value of the removed element.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-table.remove"])

## sort


```lua
function table.sort(list: <T>[], comp?: fun(a: <T>, b: <T>):boolean)
```


Sorts list elements in a given order, *in-place*, from `list[1]` to `list[#list]`.

[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-table.sort"])

## unpack


```lua
function table.unpack(list: { [1]: <T1>, [2]: <T2>, [3]: <T3>, [4]: <T4>, [5]: <T5>, [6]: <T6>, [7]: <T7>, [8]: <T8>, [9]: <T9>, [10]: <T10> }, i?: integer, j?: integer)
  -> <T1>
  2. <T2>
  3. <T3>
  4. <T4>
  5. <T5>
  6. <T6>
  7. <T7>
  8. <T8>
  9. <T9>
 10. <T10>
```


Returns the elements from the given list. This function is equivalent to
```lua
    return list[i], list[i+1], ···, list[j]
```
By default, `i` is `1` and `j` is `#list`.


[View documents](command:extension.lua.doc?["en-us/54/manual.html/pdf-table.unpack"])


---

# thread


---

# tonumber


```lua
function tonumber(e: any)
  -> number?
```


---

# tostring


```lua
function tostring(v: any)
  -> string
```


---

# true


---

# type


```lua
function type(v: any)
  -> type: "boolean"|"function"|"nil"|"number"|"string"...(+3)
```


---

# type


---

# unknown


---

# unpack


```lua
function unpack(list: { [1]: <T1>, [2]: <T2>, [3]: <T3>, [4]: <T4>, [5]: <T5>, [6]: <T6>, [7]: <T7>, [8]: <T8>, [9]: <T9>, [10]: <T10> }, i?: integer, j?: integer)
  -> <T1>
  2. <T2>
  3. <T3>
  4. <T4>
  5. <T5>
  6. <T6>
  7. <T7>
  8. <T8>
  9. <T9>
 10. <T10>
```


```lua
function unpack(list: { [1]: <T1>, [2]: <T2>, [3]: <T3>, [4]: <T4>, [5]: <T5>, [6]: <T6>, [7]: <T7>, [8]: <T8>, [9]: <T9> })
  -> <T1>
  2. <T2>
  3. <T3>
  4. <T4>
  5. <T5>
  6. <T6>
  7. <T7>
  8. <T8>
  9. <T9>
```


---

# userdata


---

# vbuf


---

# warn


```lua
function warn(message: string, ...any)
```


---

# xpcall


```lua
function xpcall(f: fun(...any):...unknown, msgh: function, arg1?: any, ...any)
  -> success: boolean
  2. result: any
  3. ...any
```