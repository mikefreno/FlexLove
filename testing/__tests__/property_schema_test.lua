-- Test suite for modules.PropertySchema.lua
-- Validates the keystone registry consumed by tasks 03 (data-driven prop binding)
-- and 05 (registry-driven setProperty dispatch).

package.path = package.path .. ";./?.lua;./modules/?.lua"

-- PropertySchema is pure Lua — love stub is loaded only to mirror the FlexLove
-- test lifecycle (some test harnesses proxy require through it). The module
-- must NOT import love; this is asserted below.
require("testing.loveStub")

local luaunit = require("testing.luaunit")
local PropertySchema = require("modules.PropertySchema")

-- Re-run populate up front to make test ordering deterministic (define is additive).
PropertySchema.populate()

TestPropertySchema = {}

-- -------------------------------------------------------------------- lookup
function TestPropertySchema:testGet_ReturnsMetadataForKnownProp()
  local meta = PropertySchema.get("opacity")
  luaunit.assertNotNil(meta)
  luaunit.assertEquals(meta.type, "number")
  luaunit.assertEquals(meta.default, 1)
  luaunit.assertTrue(meta.validator ~= nil)
  luaunit.assertFalse(meta.isDimension)
  luaunit.assertFalse(meta.affectsLayout)
  luaunit.assertFalse(meta.syncsTheme)
  luaunit.assertFalse(meta.hasDeferred)
  luaunit.assertIsNil(meta.storageKey)
end

function TestPropertySchema:testGet_UnknownPropReturnsNilWithoutError()
  luaunit.assertIsNil(PropertySchema.get("thisPropDoesNotExist"))
  luaunit.assertIsNil(PropertySchema.get(""))
end

function TestPropertySchema:testHas_ReturnsCorrectBoolean()
  luaunit.assertTrue(PropertySchema.has("width"))
  luaunit.assertTrue(PropertySchema.has("themeComponent"))
  luaunit.assertFalse(PropertySchema.has("nonexistentPropXYZ"))
end

function TestPropertySchema:testAll_ReturnsRegistryTable()
  local all = PropertySchema.all()
  luaunit.assertNotNil(all)
  luaunit.assertEquals(type(all), "table")
  luaunit.assertNotNil(all["opacity"])
end

function TestPropertySchema:testGet_IsO1NoPerCallConstruction()
  -- Two lookups return the same table reference (pre-built registry, not cloned).
  local a = PropertySchema.get("width")
  local b = PropertySchema.get("width")
  luaunit.assertTrue(a == b)
end

-- -------------------------------------------------------------------- defaults
function TestPropertySchema:testDefault_TouchEnabled()
  local meta = PropertySchema.get("touchEnabled")
  luaunit.assertEquals(meta.default, true)
end

function TestPropertySchema:testDefault_MultiTouchEnabled()
  local meta = PropertySchema.get("multiTouchEnabled")
  luaunit.assertEquals(meta.default, false)
end

function TestPropertySchema:testDefault_CursorBlinkRate()
  local meta = PropertySchema.get("cursorBlinkRate")
  luaunit.assertEquals(meta.default, 0.5)
end

function TestPropertySchema:testDefault_ObjectFit()
  local meta = PropertySchema.get("objectFit")
  luaunit.assertEquals(meta.default, "fill")
end

function TestPropertySchema:testDefault_ImageRepeat()
  local meta = PropertySchema.get("imageRepeat")
  luaunit.assertEquals(meta.default, "no-repeat")
end

function TestPropertySchema:testDefault_FlexDirection()
  local meta = PropertySchema.get("flexDirection")
  luaunit.assertEquals(meta.default, "horizontal")
end

function TestPropertySchema:testDefault_Transition()
  local meta = PropertySchema.get("transition")
  luaunit.assertEquals(type(meta.default), "table")
end

-- -------------------------------------------------------------------- flags: dimension / layout / theme / deferred
function TestPropertySchema:testFlags_WidthAndHeightAreDimensions()
  for _, name in ipairs({ "width", "height" }) do
    local m = PropertySchema.get(name)
    luaunit.assertTrue(m.isDimension, name .. " should be a dimension")
    luaunit.assertTrue(m.affectsLayout, name .. " should affect layout")
  end
end

function TestPropertySchema:testFlags_LayoutPropertiesMatchBaseline()
  -- Mirror the legacy setProperty `layoutProperties` table exactly.
  local expectLayout = {
    width = true,
    height = true,
    padding = true,
    margin = true,
    gap = true,
    flexDirection = true,
    flexWrap = true,
    justifyContent = true,
    alignItems = true,
    alignContent = true,
    positioning = true,
    gridRows = true,
    gridColumns = true,
    top = true,
    right = true,
    bottom = true,
    left = true,
  }
  for name, _ in pairs(expectLayout) do
    local m = PropertySchema.get(name)
    luaunit.assertNotNil(m, name .. " missing from registry")
    luaunit.assertTrue(m.affectsLayout, name .. " should affect layout")
  end
  -- Non-layout props must NOT be flagged.
  for _, name in ipairs({ "opacity", "textColor", "imagePath", "id", "themeComponent" }) do
    local m = PropertySchema.get(name)
    luaunit.assertFalse(m.affectsLayout, name .. " should NOT affect layout")
  end
end

function TestPropertySchema:testFlags_OnlyWidthHeightAreDimensions()
  -- Only width/height route through _resolveDimensionProperty in setProperty.
  local all = PropertySchema.all()
  local dims = {}
  for name, m in pairs(all) do
    if m.isDimension then
      table.insert(dims, name)
    end
  end
  table.sort(dims)
  luaunit.assertEquals(dims, { "height", "width" })
end

function TestPropertySchema:testFlags_SyncsThemeProps()
  local expect = { disabled = true, active = true, themeComponent = true, isDisabled = true }
  for name, _ in pairs(expect) do
    local m = PropertySchema.get(name)
    luaunit.assertNotNil(m)
    luaunit.assertTrue(m.syncsTheme, name .. " should sync theme")
  end
  for _, name in ipairs({ "opacity", "width", "borderColor" }) do
    local m = PropertySchema.get(name)
    luaunit.assertFalse(m.syncsTheme, name .. " should NOT sync theme")
  end
end

function TestPropertySchema:testFlags_CallbacksHaveDeferred()
  local callbacks = {
    "onEvent",
    "onFocus",
    "onBlur",
    "onTextInput",
    "onTextChange",
    "onEnter",
    "onCreate",
    "onTouchEvent",
    "onGesture",
    "onImageLoad",
    "onImageError",
  }
  for _, name in ipairs(callbacks) do
    local m = PropertySchema.get(name)
    luaunit.assertNotNil(m, name .. " missing")
    luaunit.assertTrue(m.hasDeferred, name .. " should have a Deferred companion")
  end
  -- The Deferred companion props themselves must be registered (default false).
  for _, name in ipairs(callbacks) do
    local dm = PropertySchema.get(name .. "Deferred")
    luaunit.assertNotNil(dm, name .. "Deferred missing")
    luaunit.assertEquals(dm.default, false)
    luaunit.assertFalse(dm.hasDeferred, name .. "Deferred must not itself have a Deferred companion")
  end
end

function TestPropertySchema:testStorageKey_IsDisabledAliasesDisabled()
  local m = PropertySchema.get("isDisabled")
  luaunit.assertEquals(m.storageKey, "disabled")
  luaunit.assertTrue(m.syncsTheme)
  -- Props without aliases have nil storageKey.
  luaunit.assertIsNil(PropertySchema.get("opacity").storageKey)
  luaunit.assertIsNil(PropertySchema.get("width").storageKey)
end

-- -------------------------------------------------------------------- normalizers
function TestPropertySchema:testNormalizer_PaddingSingleValueToFourSides()
  local m = PropertySchema.get("padding")
  luaunit.assertNotNil(m.normalizer)
  local out = m.normalizer(5)
  luaunit.assertEquals(out.top, 5)
  luaunit.assertEquals(out.right, 5)
  luaunit.assertEquals(out.bottom, 5)
  luaunit.assertEquals(out.left, 5)
end

function TestPropertySchema:testNormalizer_PaddingTablePassthrough()
  local m = PropertySchema.get("padding")
  local tbl = { top = 1, right = 2, bottom = 3, left = 4 }
  local out = m.normalizer(tbl)
  luaunit.assertTrue(out == tbl, "table should pass through by reference")
end

function TestPropertySchema:testNormalizer_PaddingNilPassthrough()
  local m = PropertySchema.get("padding")
  luaunit.assertIsNil(m.normalizer(nil))
end

function TestPropertySchema:testNormalizer_MarginSingleValueToFourSides()
  local m = PropertySchema.get("margin")
  local out = m.normalizer(10)
  luaunit.assertEquals(out.top, 10)
  luaunit.assertEquals(out.right, 10)
  luaunit.assertEquals(out.bottom, 10)
  luaunit.assertEquals(out.left, 10)
end

function TestPropertySchema:testNormalizer_FlexDirectionRowToHorizontal()
  local m = PropertySchema.get("flexDirection")
  luaunit.assertEquals(m.normalizer("row"), "horizontal")
  luaunit.assertEquals(m.normalizer("column"), "vertical")
  luaunit.assertEquals(m.normalizer("horizontal"), "horizontal")
  luaunit.assertEquals(m.normalizer("vertical"), "vertical")
  luaunit.assertIsNil(m.normalizer(nil))
end

function TestPropertySchema:testNormalizer_BorderTableTrueToNumber()
  local m = PropertySchema.get("border")
  -- all-false/nil table -> nil
  luaunit.assertIsNil(m.normalizer({ top = false, right = nil, bottom = false, left = false }))
  -- true -> 1, number -> value, false -> false
  local out = m.normalizer({ top = true, right = 5, bottom = false, left = nil })
  luaunit.assertEquals(out.top, 1)
  luaunit.assertEquals(out.right, 5)
  luaunit.assertEquals(out.bottom, false)
  luaunit.assertEquals(out.left, false)
  -- truthy scalar passes through
  luaunit.assertEquals(m.normalizer(3), 3)
  luaunit.assertIsNil(m.normalizer(nil))
  luaunit.assertIsNil(m.normalizer(false))
end

function TestPropertySchema:testNormalizer_CornerRadiusNumberZeroToNil()
  local m = PropertySchema.get("cornerRadius")
  luaunit.assertIsNil(m.normalizer(0))
  luaunit.assertEquals(m.normalizer(8), 8)
  luaunit.assertIsNil(m.normalizer(nil))
  -- all-nil table -> nil (no side present)
  luaunit.assertIsNil(m.normalizer({ topLeft = nil, topRight = nil, bottomLeft = nil, bottomRight = nil }))
  -- all-zero table -> kept with zeros (mirrors Element.new: 0 is truthy in Lua)
  local zeroTbl = m.normalizer({ topLeft = 0, topRight = 0, bottomLeft = 0, bottomRight = 0 })
  luaunit.assertNotNil(zeroTbl)
  luaunit.assertEquals(zeroTbl.topLeft, 0)
  luaunit.assertEquals(zeroTbl.bottomRight, 0)
  -- partial table fills zeros
  local out = m.normalizer({ topLeft = 4 })
  luaunit.assertEquals(out.topLeft, 4)
  luaunit.assertEquals(out.topRight, 0)
  luaunit.assertEquals(out.bottomLeft, 0)
  luaunit.assertEquals(out.bottomRight, 0)
end

-- -------------------------------------------------------------------- validators
function TestPropertySchema:testValidator_OpacityRange()
  local v = PropertySchema.get("opacity").validator
  luaunit.assertTrue(v(0))
  luaunit.assertTrue(v(1))
  luaunit.assertTrue(v(0.5))
  luaunit.assertTrue(v(nil)) -- absence is valid
  luaunit.assertFalse(v(-0.1))
  luaunit.assertFalse(v(1.1))
  luaunit.assertFalse(v("0.5"))
end

function TestPropertySchema:testValidator_ImageOpacityRange()
  local v = PropertySchema.get("imageOpacity").validator
  luaunit.assertTrue(v(0.7))
  luaunit.assertFalse(v(2))
  luaunit.assertFalse(v(-1))
end

function TestPropertySchema:testValidator_ObjectFitEnum()
  local v = PropertySchema.get("objectFit").validator
  for _, ok in ipairs({ "fill", "contain", "cover", "scale-down", "none" }) do
    luaunit.assertTrue(v(ok), ok .. " should be valid")
  end
  luaunit.assertFalse(v("invalid"))
  luaunit.assertTrue(v(nil))
end

function TestPropertySchema:testValidator_ImageRepeatEnum()
  local v = PropertySchema.get("imageRepeat").validator
  luaunit.assertTrue(v("repeat"))
  luaunit.assertTrue(v("repeat-x"))
  luaunit.assertFalse(v("tile"))
end

function TestPropertySchema:testValidator_FlexGrowShrinkNonNegative()
  local g = PropertySchema.get("flexGrow").validator
  luaunit.assertTrue(g(0))
  luaunit.assertTrue(g(2))
  luaunit.assertFalse(g(-1))
  local s = PropertySchema.get("flexShrink").validator
  luaunit.assertTrue(s(0))
  luaunit.assertFalse(s(-0.5))
end

function TestPropertySchema:testValidator_DisplayBoolean()
  local v = PropertySchema.get("display").validator
  luaunit.assertTrue(v(true))
  luaunit.assertTrue(v(false))
  luaunit.assertTrue(v(nil))
  luaunit.assertFalse(v("true"))
end

-- -------------------------------------------------------------------- define / override
function TestPropertySchema:testDefine_AddsNewProp()
  PropertySchema.define({
    __testCustomProp = { type = "string", default = "hello", affectsLayout = true },
  })
  local m = PropertySchema.get("__testCustomProp")
  luaunit.assertNotNil(m)
  luaunit.assertEquals(m.default, "hello")
  luaunit.assertTrue(m.affectsLayout)
end

function TestPropertySchema:testDefine_OverridesExistingEntry()
  PropertySchema.define({ opacity = { type = "number", default = 0.5 } })
  local m = PropertySchema.get("opacity")
  luaunit.assertEquals(m.default, 0.5)
  luaunit.assertFalse(m.affectsLayout)
  -- Restore baseline for any later test
  PropertySchema.define({
    opacity = {
      type = "number",
      default = 1,
      validator = function(v)
        return v == nil or (type(v) == "number" and v >= 0 and v <= 1)
      end,
    },
  })
end

function TestPropertySchema:testPopulate_IsIdempotent()
  PropertySchema.populate()
  PropertySchema.populate()
  luaunit.assertNotNil(PropertySchema.get("width"))
  luaunit.assertNotNil(PropertySchema.get("opacity"))
end

-- -------------------------------------------------------------------- purity
function TestPropertySchema:testModule_HasNoLoveImport()
  -- Reload the module source and assert it does not reference `love` at runtime.
  -- Comments are stripped first so prose mentions (e.g. "NO love import") don't
  -- trip the check; only actual code tokens count.
  local path = package.searchpath("modules.PropertySchema", package.path)
  luaunit.assertNotNil(path)
  local f = io.open(path, "r")
  luaunit.assertNotNil(f, "could not open PropertySchema.lua")
  local src = f:read("*a")
  f:close()
  -- Strip block comments then line comments.
  src = src:gsub("%-%-%[%[.-%]%]", " ")
  src = src:gsub("%-%-[^\n]*", "")
  luaunit.assertIsNil(src:find("love"), "module must not reference love in code")
end

-- -------------------------------------------------------------------- integration: full inventory coverage
-- Every props.X referenced in Element.new (lines 259-1909 of the baseline) MUST
-- be registered. This guards the keystone contract for tasks 03/05.
function TestPropertySchema:testIntegration_SchemaCoversFullNewPropInventory()
  local inventory = {
    "_scrollX",
    "_scrollY",
    "active",
    "alignContent",
    "alignItems",
    "alignSelf",
    "autoGrow",
    "autoScaleText",
    "backdropBlur",
    "backgroundColor",
    "border",
    "borderColor",
    "bottom",
    "children",
    "columnGap",
    "contentAutoSizingMultiplier",
    "contentBlur",
    "cornerRadius",
    "cursorBlinkRate",
    "cursorColor",
    "customDraw",
    "disabled",
    "disableHighlight",
    "display",
    "dropFocusOnSelection",
    "editable",
    "flex",
    "flexBasis",
    "flexDirection",
    "flexGrow",
    "flexShrink",
    "flexWrap",
    "fontFamily",
    "gap",
    "gridColumns",
    "gridRows",
    "height",
    "hideScrollbars",
    "id",
    "image",
    "imageOpacity",
    "imagePath",
    "imageRepeat",
    "imageTint",
    "inputType",
    "invertScroll",
    "isDisabled",
    "justifyContent",
    "justifySelf",
    "left",
    "margin",
    "maxHeight",
    "maxLength",
    "maxLines",
    "maxTextSize",
    "maxWidth",
    "minHeight",
    "minTextSize",
    "minWidth",
    "multiline",
    "multiTouchEnabled",
    "objectFit",
    "objectPosition",
    "onBlur",
    "onBlurDeferred",
    "onCreate",
    "onCreateDeferred",
    "onEnter",
    "onEnterDeferred",
    "onEvent",
    "onEventDeferred",
    "onFocus",
    "onFocusDeferred",
    "onGesture",
    "onGestureDeferred",
    "onImageError",
    "onImageErrorDeferred",
    "onImageLoad",
    "onImageLoadDeferred",
    "onTextChange",
    "onTextChangeDeferred",
    "onTextInput",
    "onTextInputDeferred",
    "onTouchEvent",
    "onTouchEventDeferred",
    "opacity",
    "overflow",
    "overflowX",
    "overflowY",
    "padding",
    "parent",
    "passwordMode",
    "placeholder",
    "positioning",
    "right",
    "rowGap",
    "scaleCorners",
    "scalingAlgorithm",
    "scrollable",
    "scrollbarBalance",
    "scrollbarColor",
    "scrollbarKnobOffset",
    "scrollbarPadding",
    "scrollbarPlacement",
    "scrollbarRadius",
    "scrollBarStyle",
    "scrollbarTrackColor",
    "scrollbarWidth",
    "scrollSpeed",
    "selectionColor",
    "selectOnFocus",
    "selectOption",
    "selectParent",
    "smoothScrollEnabled",
    "tabIndex",
    "text",
    "textAlign",
    "textColor",
    "textOverflow",
    "textSize",
    "textWrap",
    "theme",
    "themeComponent",
    "themeComponentDisabledStates",
    "themeStateLock",
    "top",
    "touchEnabled",
    "transform",
    "transition",
    "userdata",
    "visibility",
    "width",
    "x",
    "y",
    "z",
  }
  local missing = {}
  for _, name in ipairs(inventory) do
    if PropertySchema.get(name) == nil then
      table.insert(missing, name)
    end
  end
  luaunit.assertEquals(missing, {}, "schema is missing props: " .. table.concat(missing, ", "))
end

function TestPropertySchema:testIntegration_EveryEntryHasAllMetadataFields()
  local fields = {
    "type",
    "default",
    "normalizer",
    "validator",
    "isDimension",
    "affectsLayout",
    "syncsTheme",
    "hasDeferred",
    "storageKey",
  }
  local problems = {}
  for name, m in pairs(PropertySchema.all()) do
    for _, f in ipairs(fields) do
      if m[f] == nil and f ~= "default" and f ~= "normalizer" and f ~= "validator" and f ~= "storageKey" then
        -- type is non-nil; boolean flags default to false (non-nil)
        if f == "type" then
          table.insert(problems, name .. ".type")
        elseif f == "isDimension" or f == "affectsLayout" or f == "syncsTheme" or f == "hasDeferred" then
          table.insert(problems, name .. "." .. f)
        end
      end
    end
  end
  luaunit.assertEquals(problems, {}, "entries missing metadata fields: " .. table.concat(problems, ", "))
end

-- Run tests if this file is executed directly
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
