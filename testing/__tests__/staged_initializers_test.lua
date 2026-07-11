-- Test suite for Task 10: split Element.new into staged initializers.
-- Verifies the orchestrator is a thin dispatcher, all staged phase methods
-- exist and are callable, the 5 subsystem deps tables are hoisted (created
-- once at init, shared across constructions), and behavioral parity holds for
-- a representative constructed element.

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
local Element = require("modules.Element")

TestStagedInit = {}

local PHASE_METHODS = {
  -- Core-data phases (behavior-mode-unification task 08 capstone). The former
  -- behavioral phases (_initSubSystems / _initVisualState / _initImageAndRenderer
  -- / _initScrollManager) are deleted: field-binding folded into _applyProps
  -- (bindThemeAndFields + bindVisualState local helpers) and subsystem creation
  -- moved into behavior onAttach hooks dispatched from _attachBehaviors.
  "_construct",
  "_applyProps",
  "_initSizingContext",
  "_initBoxModel",
  "_initPositioning",
  "_finalizeConstruction",
  "_attachBehaviors",
}

local HOISTED_DEPS = {
  "_eventHandlerDeps",
  "_rendererDeps",
  "_layoutEngineDeps",
  "_textEditorDeps",
  "_scrollManagerDeps",
}

function TestStagedInit:setUp()
  FlexLove.init()
  FlexLove.beginFrame()
end

function TestStagedInit:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

-- ------------------------------------------------------- orchestrator is thin
function TestStagedInit:test_element_new_body_is_short_orchestrator()
  -- Element.new should be a short orchestrator (<= ~80 LOC), dispatching to the
  -- staged phases. It must NOT contain inline dimension/layout/theme logic.
  local src = io.open("modules/Element.lua", "r")
  luaunit.assertNotNil(src, "Element.lua source must be readable")
  local content = src:read("*a")
  src:close()
  local body = content:match("function Element%.new%(props%)(.-)\nend\n")
  luaunit.assertNotNil(body, "Element.new must be defined")
  local lineCount = select(2, body:gsub("\n", "\n")) + 1
  luaunit.assertTrue(lineCount <= 80, "Element.new body should be <= ~80 LOC, got " .. tostring(lineCount))
  -- orchestrated phase calls present
  for _, m in ipairs(PHASE_METHODS) do
    local pat = m:gsub("%%", "%%%%")
    luaunit.assertTrue(
      body:find("self:" .. pat .. "%(") ~= nil or body:find("Element:" .. pat .. "%(") ~= nil,
      "orchestrator must call phase " .. m
    )
  end
end

-- ------------------------------------------------------- phase methods exist
function TestStagedInit:test_all_phase_methods_defined_on_Element()
  for _, m in ipairs(PHASE_METHODS) do
    luaunit.assertNotNil(Element[m], "Element." .. m .. " must be defined after init")
    luaunit.assertEquals(type(Element[m]), "function", "Element." .. m .. " must be a function")
  end
end

-- ------------------------------------------------------- no per-construction deps
function TestStagedInit:test_deps_tables_hoisted_not_rebuilt_per_new()
  for _, d in ipairs(HOISTED_DEPS) do
    luaunit.assertNotNil(Element[d], "Element." .. d .. " must be hoisted to module scope after init")
    luaunit.assertEquals(type(Element[d]), "table", "Element." .. d .. " must be a table")
  end
  -- The same table identity is reused across constructions (not rebuilt per new()).
  local before = {}
  for _, d in ipairs(HOISTED_DEPS) do
    before[d] = Element[d]
  end
  FlexLove.new({ width = 50, height = 50 })
  FlexLove.new({ width = 50, height = 50 })
  for _, d in ipairs(HOISTED_DEPS) do
    luaunit.assertTrue(
      Element[d] == before[d],
      "hoisted deps table " .. d .. " identity must be stable across constructions"
    )
  end
end

-- ------------------------------------------------------- construction parity
function TestStagedInit:test_constructed_element_has_expected_state()
  local el = FlexLove.new({
    width = 120,
    height = 80,
    text = "hello",
    border = 2,
    backgroundColor = { 1, 0, 0, 1 },
    onEvent = function() end, -- interactive: Clickable behavior attaches + creates EventHandler
  })
  luaunit.assertTrue(el._constructed, "element must be marked constructed")
  luaunit.assertEquals(el.width, 120, "width preserved")
  luaunit.assertEquals(el.height, 80, "height preserved")
  luaunit.assertEquals(el.text, "hello", "text preserved")
  luaunit.assertNotNil(el._eventHandler, "EventHandler initialized (via Clickable behavior for interactive elements)")
  luaunit.assertNotNil(el._renderer, "Renderer initialized")
  luaunit.assertNotNil(el._layoutEngine, "LayoutEngine initialized")
  luaunit.assertNotNil(el._themeManager, "ThemeManager initialized")
  luaunit.assertNotNil(el.children, "children table initialized")
  luaunit.assertNotNil(el._deferredMethods, "_deferredMethods table initialized")
  luaunit.assertNotNil(el.units, "units table initialized")
  luaunit.assertEquals(type(el.id), "string", "id generated as string")
end

-- ------------------------------------------------------- scroll subsystem parity
function TestStagedInit:test_scroll_manager_created_when_overflow_set()
  local el = FlexLove.new({
    width = 100,
    height = 100,
    overflow = "auto",
  })
  luaunit.assertNotNil(el._scrollManager, "ScrollManager created when overflow set")
  luaunit.assertEquals(el.overflow, "auto", "overflow exposed on element")
  luaunit.assertNotNil(el.setScrollPosition, "scroll API bound from ScrollManager")
end

function TestStagedInit:test_no_scroll_manager_when_overflow_absent()
  local el = FlexLove.new({ width = 100, height = 100 })
  luaunit.assertNil(el._scrollManager, "ScrollManager not created without overflow")
end

-- ------------------------------------------------------- declarative children parity
function TestStagedInit:test_declarative_children_still_built()
  local parent = FlexLove.new({
    width = 200,
    height = 200,
    children = {
      { width = 50, height = 50, id = "child-a" },
      { width = 50, height = 50, id = "child-b" },
    },
  })
  luaunit.assertEquals(#parent.children, 2, "declarative children built")
  luaunit.assertEquals(parent.children[1].id, "child-a")
  luaunit.assertEquals(parent.children[2].id, "child-b")
end

-- ------------------------------------------------------- onCreate callback parity
function TestStagedInit:test_onCreate_callback_fired()
  local fired = false
  local el = FlexLove.new({
    width = 50,
    height = 50,
    onCreate = function()
      fired = true
    end,
  })
  luaunit.assertTrue(fired, "onCreate must fire during construction")
  luaunit.assertTrue(el._constructed, "constructed flag set after onCreate")
end

-- ------------------------------------------------------- _construct produces instance
function TestStagedInit:test_construct_in_isolation()
  -- _construct alone (before _applyProps) must produce a metatable'd instance
  -- with children/_deferredMethods/ID initialized and returning itself.
  local el = Element:_construct({ width = 40, height = 40 })
  luaunit.assertEquals(getmetatable(el), Element, "_construct sets Element metatable")
  luaunit.assertEquals(type(el.children), "table", "_construct sets children")
  luaunit.assertEquals(type(el._deferredMethods), "table", "_construct sets _deferredMethods")
  luaunit.assertEquals(type(el.id), "string", "_construct generates id")
  luaunit.assertEquals(el._stateId, el.id, "_construct sets _stateId to id")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
