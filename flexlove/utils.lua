local enums = {
  ---@enum TextAlign
  TextAlign = { START = "start", CENTER = "center", END = "end", JUSTIFY = "justify" },
  ---@enum Positioning
  Positioning = { ABSOLUTE = "absolute", RELATIVE = "relative", FLEX = "flex", GRID = "grid" },
  ---@enum FlexDirection
  FlexDirection = { HORIZONTAL = "horizontal", VERTICAL = "vertical" },
  ---@enum JustifyContent
  JustifyContent = {
    FLEX_START = "flex-start",
    CENTER = "center",
    SPACE_AROUND = "space-around",
    FLEX_END = "flex-end",
    SPACE_EVENLY = "space-evenly",
    SPACE_BETWEEN = "space-between",
  },
  ---@enum JustifySelf
  JustifySelf = {
    AUTO = "auto",
    FLEX_START = "flex-start",
    CENTER = "center",
    FLEX_END = "flex-end",
    SPACE_AROUND = "space-around",
    SPACE_EVENLY = "space-evenly",
    SPACE_BETWEEN = "space-between",
  },
  ---@enum AlignItems
  AlignItems = {
    STRETCH = "stretch",
    FLEX_START = "flex-start",
    FLEX_END = "flex-end",
    CENTER = "center",
    BASELINE = "baseline",
  },
  ---@enum AlignSelf
  AlignSelf = {
    AUTO = "auto",
    STRETCH = "stretch",
    FLEX_START = "flex-start",
    FLEX_END = "flex-end",
    CENTER = "center",
    BASELINE = "baseline",
  },
  ---@enum AlignContent
  AlignContent = {
    STRETCH = "stretch",
    FLEX_START = "flex-start",
    FLEX_END = "flex-end",
    CENTER = "center",
    SPACE_BETWEEN = "space-between",
    SPACE_AROUND = "space-around",
  },
  ---@enum FlexWrap
  FlexWrap = { NOWRAP = "nowrap", WRAP = "wrap", WRAP_REVERSE = "wrap-reverse" },
  ---@enum TextSize
  TextSize = {
    XXS = "xxs",
    XS = "xs",
    SM = "sm",
    MD = "md",
    LG = "lg",
    XL = "xl",
    XXL = "xxl",
    XL3 = "3xl",
    XL4 = "4xl",
  },
}

---@class ElementProps
---@field id string?
---@field parent Element? -- Parent element for hierarchical structure
---@field x number|string? -- X coordinate of the element (default: 0)
---@field y number|string? -- Y coordinate of the element (default: 0)
---@field z number? -- Z-index for layering (default: 0)
---@field width number|string? -- Width of the element (default: calculated automatically)
---@field height number|string? -- Height of the element (default: calculated automatically)
---@field top number|string? -- Offset from top edge (CSS-style positioning)
---@field right number|string? -- Offset from right edge (CSS-style positioning)
---@field bottom number|string? -- Offset from bottom edge (CSS-style positioning)
---@field left number|string? -- Offset from left edge (CSS-style positioning)
---@field border Border? -- Border configuration for the element
---@field borderColor Color? -- Color of the border (default: black)
---@field opacity number?
---@field backgroundColor Color? -- Background color (default: transparent)
---@field cornerRadius number|{topLeft:number?, topRight:number?, bottomLeft:number?, bottomRight:number?}? -- Corner radius: number (all corners) or table for individual corners (default: 0)
---@field gap number|string? -- Space between children elements (default: 10)
---@field padding {top:number|string?, right:number|string?, bottom:number|string?, left:number|string?, horizontal: number|string?, vertical:number|string?}? -- Padding around children (default: {top=0, right=0, bottom=0, left=0})
---@field margin {top:number|string?, right:number|string?, bottom:number|string?, left:number|string?, horizontal: number|string?, vertical:number|string?}? -- Margin around children (default: {top=0, right=0, bottom=0, left=0})
---@field text string? -- Text content to display (default: nil)
---@field titleColor Color? -- Color of the text content (default: black)
---@field textAlign TextAlign? -- Alignment of the text content (default: START)
---@field textColor Color? -- Color of the text content (default: black)
---@field textSize number|string? -- Font size: number (px), string with units ("2vh", "10%"), or preset ("xxs"|"xs"|"sm"|"md"|"lg"|"xl"|"xxl"|"3xl"|"4xl") (default: "md")
---@field minTextSize number?
---@field maxTextSize number?
---@field fontFamily string? -- Font family name from theme or path to font file (default: theme default or system default)
---@field autoScaleText boolean? -- Whether text should auto-scale with window size (default: true)
---@field positioning Positioning? -- Layout positioning mode (default: RELATIVE)
---@field flexDirection FlexDirection? -- Direction of flex layout (default: HORIZONTAL)
---@field justifyContent JustifyContent? -- Alignment of items along main axis (default: FLEX_START)
---@field alignItems AlignItems? -- Alignment of items along cross axis (default: STRETCH)
---@field alignContent AlignContent? -- Alignment of lines in multi-line flex containers (default: STRETCH)
---@field flexWrap FlexWrap? -- Whether children wrap to multiple lines (default: NOWRAP)
---@field justifySelf JustifySelf? -- Alignment of the item itself along main axis (default: AUTO)
---@field alignSelf AlignSelf? -- Alignment of the item itself along cross axis (default: AUTO)
---@field callback fun(element:Element, event:InputEvent)? -- Callback function for interaction events
---@field transform table? -- Transform properties for animations and styling
---@field transition table? -- Transition settings for animations
---@field gridRows number? -- Number of rows in the grid (default: 1)
---@field gridColumns number? -- Number of columns in the grid (default: 1)
---@field columnGap number|string? -- Gap between grid columns
---@field rowGap number|string? -- Gap between grid rows
---@field theme string? -- Theme name to use (e.g., "space", "dark"). Defaults to theme from Gui.init()
---@field themeComponent string? -- Theme component to use (e.g., "panel", "button", "input"). If nil, no theme is applied
---@field disabled boolean? -- Whether the element is disabled (default: false)
---@field active boolean? -- Whether the element is active/focused (for inputs, default: false)
---@field disableHighlight boolean? -- Whether to disable the pressed state highlight overlay (default: false)
---@field contentAutoSizingMultiplier {width:number?, height:number?}? -- Multiplier for auto-sized content dimensions (default: sourced from theme)
---@field scaleCorners number? -- Scale multiplier for 9-slice corners/edges. E.g., 2 = 2x size (overrides theme setting)
---@field scalingAlgorithm "nearest"|"bilinear"? -- Scaling algorithm for 9-slice corners: "nearest" (sharp/pixelated) or "bilinear" (smooth) (overrides theme setting)
---@field contentBlur {intensity:number, quality:number}? -- Blur the element's content including children (intensity: 0-100, quality: 1-10, default: nil)
---@field backdropBlur {intensity:number, quality:number}? -- Blur content behind the element (intensity: 0-100, quality: 1-10, default: nil)
---@field editable boolean? -- Whether the element is editable (default: false)
---@field multiline boolean? -- Whether the element supports multiple lines (default: false)
---@field textWrap boolean|"word"|"char"? -- Text wrapping mode (default: false for single-line, "word" for multi-line)
---@field maxLines number? -- Maximum number of lines (default: nil)
---@field maxLength number? -- Maximum text length in characters (default: nil)
---@field placeholder string? -- Placeholder text when empty (default: nil)
---@field passwordMode boolean? -- Whether to display text as password (default: false)
---@field inputType "text"|"number"|"email"|"url"? -- Input type for validation (default: "text")
---@field textOverflow "clip"|"ellipsis"|"scroll"? -- Text overflow behavior (default: "clip")
---@field scrollable boolean? -- Whether text is scrollable (default: false for single-line, true for multi-line)
---@field autoGrow boolean? -- Whether element auto-grows with text (default: false)
---@field selectOnFocus boolean? -- Whether to select all text on focus (default: false)
---@field cursorColor Color? -- Cursor color (default: nil, uses textColor)
---@field selectionColor Color? -- Selection background color (default: nil, uses theme or default)
---@field cursorBlinkRate number? -- Cursor blink rate in seconds (default: 0.5)
---@field overflow "visible"|"hidden"|"scroll"|"auto"? -- Overflow behavior (default: "visible")
---@field overflowX "visible"|"hidden"|"scroll"|"auto"? -- X-axis overflow (overrides overflow)
---@field overflowY "visible"|"hidden"|"scroll"|"auto"? -- Y-axis overflow (overrides overflow)
---@field scrollbarWidth number? -- Width of scrollbar track in pixels (default: 12)
---@field scrollbarColor Color? -- Scrollbar thumb color
---@field scrollbarTrackColor Color? -- Scrollbar track color
---@field scrollbarRadius number? -- Corner radius for scrollbar (default: 6)
---@field scrollbarPadding number? -- Padding between scrollbar and edge (default: 2)
---@field scrollSpeed number? -- Pixels per wheel notch (default: 20)

---@class Border
---@field top boolean?
---@field right boolean?
---@field bottom boolean?
---@field left boolean?

--- Get current keyboard modifiers state
---@return {shift:boolean, ctrl:boolean, alt:boolean, super:boolean}
local function getModifiers()
  return {
    shift = love.keyboard.isDown("lshift", "rshift"),
    ctrl = love.keyboard.isDown("lctrl", "rctrl"),
    alt = love.keyboard.isDown("lalt", "ralt"),
    ---@diagnostic disable-next-line
    super = love.keyboard.isDown("lgui", "rgui"), -- cmd/windows key
  }
end

local TEXT_SIZE_PRESETS = {
  ["2xs"] = 0.75, -- 0.75vh
  xxs = 0.75, -- 0.75vh
  xs = 1.25, -- 1.25vh
  sm = 1.75, -- 1.75vh
  md = 2.25, -- 2.25vh (default)
  lg = 2.75, -- 2.75vh
  xl = 3.5, -- 3.5vh
  xxl = 4.5, -- 4.5vh
  ["2xl"] = 4.5, -- 4.5vh
  ["3xl"] = 5.0, -- 5vh
  ["4xl"] = 7.0, -- 7vh
}

-- ====================
-- Text Size Utilities
-- ====================

--- Resolve text size preset to viewport units
---@param sizeValue string|number
---@return number?, string? -- Returns value and unit ("vh" for presets, original unit otherwise)
local function resolveTextSizePreset(sizeValue)
  if type(sizeValue) == "string" then
    -- Check if it's a preset
    local preset = TEXT_SIZE_PRESETS[sizeValue]
    if preset then
      return preset, "vh"
    end
  end
  -- Not a preset, return nil to indicate normal parsing should occur
  return nil, nil
end

local FONT_CACHE = {}
local FONT_CACHE_MAX_SIZE = 50 -- Limit cache size to prevent unbounded growth
local FONT_CACHE_ORDER = {} -- Track access order for LRU eviction

--- Create or get a font from cache
---@param size number
---@param fontPath string? -- Optional: path to font file
---@return love.Font
function FONT_CACHE.get(size, fontPath)
  -- Create cache key from size and font path
  local cacheKey = fontPath and (fontPath .. "_" .. tostring(size)) or tostring(size)

  if not FONT_CACHE[cacheKey] then
    if fontPath then
      -- Load custom font
      local resolvedPath = resolveImagePath(fontPath)
      -- Note: love.graphics.newFont signature is (path, size) for custom fonts
      local success, font = pcall(love.graphics.newFont, resolvedPath, size)
      if success then
        FONT_CACHE[cacheKey] = font
      else
        -- Fallback to default font if custom font fails to load
        print("[FlexLove] Failed to load font: " .. fontPath .. " - using default font")
        FONT_CACHE[cacheKey] = love.graphics.newFont(size)
      end
    else
      -- Load default font
      FONT_CACHE[cacheKey] = love.graphics.newFont(size)
    end

    -- Add to access order for LRU tracking
    table.insert(FONT_CACHE_ORDER, cacheKey)

    -- Evict oldest entry if cache is full (LRU eviction)
    if #FONT_CACHE_ORDER > FONT_CACHE_MAX_SIZE then
      local oldestKey = table.remove(FONT_CACHE_ORDER, 1)
      FONT_CACHE[oldestKey] = nil
    end
  end
  return FONT_CACHE[cacheKey]
end

--- Get font for text size (cached)
---@param textSize number?
---@param fontPath string? -- Optional: path to font file
---@return love.Font
function FONT_CACHE.getFont(textSize, fontPath)
  if textSize then
    return FONT_CACHE.get(textSize, fontPath)
  else
    return love.graphics.getFont()
  end
end

return { enums, FONT_CACHE, resolveTextSizePreset, getModifiers }
