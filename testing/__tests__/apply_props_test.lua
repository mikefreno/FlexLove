-- Test suite for Element:_applyProps (Task 03: data-driven prop binding)
-- Verifies the schema-driven binding loop applies defaults, respects overrides,
-- runs normalizers, and auto-wires onX/onXDeferred companion pairs identically
-- to the baseline hand-written binding behavior.

package.path = package.path .. ";./?.lua;./modules/?.lua"
local originalSearchers = package.searchers or package.loaders
table.insert(originalSearchers, 2, function(modname)
  if modname:match("^FlexLove%.modules%.") then
    local moduleName = modname:gsub("^FlexLove%.modules%.", "")
    return function()
      return require("modules." .. moduleName)
    end
  end
end)

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local FlexLove = require("FlexLove")

local function makeElement(props)
  props = props or {}
  props.width = props.width or 100
  props.height = props.height or 100
  return FlexLove.new(props)
end

TestApplyProps = {}

function TestApplyProps:setUp()
  FlexLove.init()
  FlexLove.beginFrame()
end

function TestApplyProps:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

-- -------------------------------------------------------------------- defaults
function TestApplyProps:test_default_applied_when_prop_absent()
  local el = makeElement({})
  -- number defaults
  luaunit.assertEquals(el.opacity, 1, "opacity defaults to 1")
  luaunit.assertEquals(el.imageOpacity, 1, "imageOpacity defaults to 1")
  luaunit.assertEquals(el.cursorBlinkRate, 0.5, "cursorBlinkRate defaults to 0.5")
  luaunit.assertEquals(el.flexGrow, 0, "flexGrow schema default is 0 (resolved via flex path)")
  luaunit.assertEquals(el.flexShrink, 1, "flexShrink schema default is 1 (resolved via flex path)")
  -- string defaults
  luaunit.assertEquals(el.inputType, "text", "inputType defaults to 'text'")
  luaunit.assertEquals(el.textOverflow, "clip", "textOverflow defaults to 'clip'")
  luaunit.assertEquals(el.visibility, "visible", "visibility defaults to 'visible'")
  luaunit.assertEquals(el.objectFit, "fill", "objectFit defaults to 'fill'")
  luaunit.assertEquals(el.objectPosition, "center center", "objectPosition defaults to 'center center'")
  luaunit.assertEquals(el.imageRepeat, "no-repeat", "imageRepeat defaults to 'no-repeat'")
  -- boolean defaults
  luaunit.assertEquals(el.display, true, "display defaults to true")
  luaunit.assertEquals(el.editable, false, "editable defaults to false")
  luaunit.assertEquals(el.multiline, false, "multiline defaults to false")
  luaunit.assertEquals(el.passwordMode, false, "passwordMode defaults to false")
  luaunit.assertEquals(el.autoScaleText, true, "autoScaleText defaults to true")
  luaunit.assertEquals(el.touchEnabled, true, "touchEnabled defaults to true")
  luaunit.assertEquals(el.multiTouchEnabled, false, "multiTouchEnabled defaults to false")
  luaunit.assertEquals(el.selectOnFocus, false, "selectOnFocus defaults to false")
  -- table default (fresh instance, not shared identity-sensitive here)
  luaunit.assertNotNil(el.transition, "transition defaults to a table")
  luaunit.assertEquals(type(el.transition), "table", "transition defaults to a table")
end

-- -------------------------------------------------------------------- overrides
function TestApplyProps:test_explicit_override_respected()
  local cb = function() end
  local el = makeElement({
    opacity = 0.5,
    imageOpacity = 0.25,
    inputType = "number",
    textOverflow = "ellipsis",
    visibility = "hidden",
    objectFit = "contain",
    objectPosition = "top left",
    imageRepeat = "repeat-x",
    display = false,
    editable = true,
    passwordMode = true,
    autoScaleText = false,
    touchEnabled = false,
    multiTouchEnabled = true,
    selectOnFocus = true,
    cursorBlinkRate = 1.2,
    customDraw = cb,
    dropFocusOnSelection = true,
    onImageLoad = cb,
    onImageLoadDeferred = true,
  })
  luaunit.assertEquals(el.opacity, 0.5)
  luaunit.assertEquals(el.imageOpacity, 0.25)
  luaunit.assertEquals(el.inputType, "number")
  luaunit.assertEquals(el.textOverflow, "ellipsis")
  luaunit.assertEquals(el.visibility, "hidden")
  luaunit.assertEquals(el.objectFit, "contain")
  luaunit.assertEquals(el.objectPosition, "top left")
  luaunit.assertEquals(el.imageRepeat, "repeat-x")
  luaunit.assertEquals(el.display, false)
  luaunit.assertEquals(el.editable, true)
  luaunit.assertEquals(el.passwordMode, true)
  luaunit.assertEquals(el.autoScaleText, false)
  luaunit.assertEquals(el.touchEnabled, false)
  luaunit.assertEquals(el.multiTouchEnabled, true)
  luaunit.assertEquals(el.selectOnFocus, true)
  luaunit.assertEquals(el.cursorBlinkRate, 1.2)
  luaunit.assertTrue(el.customDraw == cb)
  luaunit.assertEquals(el.dropFocusOnSelection, true)
  luaunit.assertTrue(el.onImageLoad == cb)
  luaunit.assertEquals(el.onImageLoadDeferred, true, "explicit deferred flag respected")
end

-- -------------------------------------------------------------------- normalizers
function TestApplyProps:test_padding_single_value_expanded_to_table()
  local el = makeElement({ padding = 5 })
  luaunit.assertEquals(el.padding.top, 5)
  luaunit.assertEquals(el.padding.right, 5)
  luaunit.assertEquals(el.padding.bottom, 5)
  luaunit.assertEquals(el.padding.left, 5)
end

function TestApplyProps:test_margin_single_value_expanded_to_table()
  local el = makeElement({ margin = 7 })
  luaunit.assertEquals(el.margin.top, 7)
  luaunit.assertEquals(el.margin.right, 7)
  luaunit.assertEquals(el.margin.bottom, 7)
  luaunit.assertEquals(el.margin.left, 7)
end

function TestApplyProps:test_flex_direction_row_alias_normalized()
  local el = makeElement({ positioning = "flex", flexDirection = "row" })
  luaunit.assertEquals(el.flexDirection, "horizontal", "'row' alias normalizes to 'horizontal'")
end

function TestApplyProps:test_flex_direction_column_alias_normalized()
  local el = makeElement({ positioning = "flex", flexDirection = "column" })
  luaunit.assertEquals(el.flexDirection, "vertical", "'column' alias normalizes to 'vertical'")
end

function TestApplyProps:test_border_shape_normalization()
  -- number border kept as-is
  local elNum = makeElement({ border = 3 })
  luaunit.assertEquals(elNum.border, 3)
  -- table with true sides -> 1
  local elTable = makeElement({ border = { top = true, right = 2 } })
  luaunit.assertEquals(elTable.border.top, 1)
  luaunit.assertEquals(elTable.border.right, 2)
  luaunit.assertEquals(elTable.border.bottom, false)
  luaunit.assertEquals(elTable.border.left, false)
  -- all-false table -> nil
  local elNone = makeElement({ border = { top = false } })
  luaunit.assertNil(elNone.border)
end

function TestApplyProps:test_corner_radius_shape_normalization()
  -- number 0 -> nil
  local el0 = makeElement({ cornerRadius = 0 })
  luaunit.assertNil(el0.cornerRadius)
  -- number n -> n
  local elN = makeElement({ cornerRadius = 8 })
  luaunit.assertEquals(elN.cornerRadius, 8)
  -- partial table zero-fills absent sides
  local elT = makeElement({ cornerRadius = { topLeft = 4 } })
  luaunit.assertEquals(elT.cornerRadius.topLeft, 4)
  luaunit.assertEquals(elT.cornerRadius.topRight, 0)
  luaunit.assertEquals(elT.cornerRadius.bottomLeft, 0)
  luaunit.assertEquals(elT.cornerRadius.bottomRight, 0)
  -- all-nil table -> nil
  local elEmpty = makeElement({ cornerRadius = {} })
  luaunit.assertNil(elEmpty.cornerRadius)
end

-- -------------------------------------------------------------------- deferred
function TestApplyProps:test_deferred_companions_default_false_when_omitted()
  local cb = function() end
  local el = makeElement({
    onEvent = cb,
    onFocus = cb,
    onBlur = cb,
    onTextInput = cb,
    onTextChange = cb,
    onEnter = cb,
    onCreate = cb,
    onTouchEvent = cb,
    onGesture = cb,
    onImageLoad = cb,
    onImageError = cb,
  })
  for _, name in ipairs({
    "onEventDeferred",
    "onFocusDeferred",
    "onBlurDeferred",
    "onTextInputDeferred",
    "onTextChangeDeferred",
    "onEnterDeferred",
    "onCreateDeferred",
    "onTouchEventDeferred",
    "onGestureDeferred",
    "onImageLoadDeferred",
    "onImageErrorDeferred",
  }) do
    luaunit.assertEquals(el[name], false, name .. " defaults to false when omitted")
  end
end

function TestApplyProps:test_callbacks_bound_and_deferred_respected()
  local cb = function() end
  local el = makeElement({
    onFocus = cb,
    onFocusDeferred = true,
    onImageError = cb,
    onImageErrorDeferred = true,
  })
  luaunit.assertTrue(el.onFocus == cb, "onFocus callback bound")
  luaunit.assertEquals(el.onFocusDeferred, true, "onFocusDeferred override respected")
  luaunit.assertTrue(el.onImageError == cb)
  luaunit.assertEquals(el.onImageErrorDeferred, true)
end

function TestApplyProps:test_onEvent_deferred_stored_on_self()
  -- Historically onEventDeferred was only passed to the EventHandler config and
  -- not stored on self. The schema-driven loop now stores it on self as well.
  local cb = function() end
  local el = makeElement({ onEvent = cb, onEventDeferred = true })
  luaunit.assertTrue(el.onEvent == cb)
  luaunit.assertEquals(el.onEventDeferred, true, "onEventDeferred is now stored on self")
end

-- -------------------------------------------------------------------- validators
function TestApplyProps:test_invalid_opacity_throws()
  local success = pcall(function()
    makeElement({ opacity = 2.5 })
  end)
  luaunit.assertFalse(success, "out-of-range opacity should error (throwing validator)")
end

function TestApplyProps:test_invalid_object_fit_throws()
  local success = pcall(function()
    makeElement({ objectFit = "stretch" })
  end)
  luaunit.assertFalse(success, "invalid objectFit should error (throwing validator)")
end

function TestApplyProps:test_invalid_display_falls_back_to_true()
  local el = makeElement({ display = "invalid" })
  luaunit.assertEquals(el.display, true, "invalid display warns + falls back to true (non-throwing)")
end

-- -------------------------------------------------------------------- storageKey alias
-- NOTE: isDisabled/disabled are intentionally SPECIAL (not bound by the loop).
-- Both schema entries share the `disabled` storageKey, and the ThemeManager
-- already resolves `props.isDisabled or props.disabled` deterministically; binding
-- them through the loop would race on undefined table-iteration order.

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
