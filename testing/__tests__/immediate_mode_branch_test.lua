-- Source-invariant + behavioral tests for behavior-mode-unification task 11
-- (Remove Immediate Mode Branches).
--
-- Locks in the contract that the per-frame / save-restore code paths never
-- branch on a raw `._immediateMode` field read inside the consumer modules
-- (Element, ScrollManager, TextEditor, Select, and the behaviors). The mode
-- flag is consumed only through the mode-aware accessors
-- `Context.isImmediateMode()` / `StateManager.isImmediateMode()` /
-- `StateManager.shouldLayout()`, which live in StateManager.lua / Context.lua
-- (the only places the literal `_immediateMode` may appear).

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

-- Modules whose source must be free of the literal `_immediateMode`.
local SOURCE_FILES = {
  "modules/Element.lua",
  "modules/ScrollManager.lua",
  "modules/TextEditor.lua",
  "modules/Select.lua",
  "modules/behaviors/Clickable.lua",
  "modules/behaviors/Scrollable.lua",
  "modules/behaviors/TextEditable.lua",
  "modules/KeyboardNavigation.lua",
  "modules/MemoryScanner.lua",
  "modules/Behavior.lua",
}

-- Read a file's text (returns nil if missing).
local function readFile(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*all")
  f:close()
  return content
end

TestImmediateModeBranchInvariants = {}

-- Deliverable: zero `._immediateMode` branches in the four target modules.
function TestImmediateModeBranchInvariants:testTargetModulesHaveNoImmediateModeLiteral()
  for _, file in ipairs({
    "modules/Element.lua",
    "modules/ScrollManager.lua",
    "modules/TextEditor.lua",
    "modules/Select.lua",
  }) do
    local content = readFile(file)
    luaunit.assertNotNil(content, "could not read " .. file)
    local _, count = content:gsub("_immediateMode", "")
    luaunit.assertEquals(count, 0, file .. " must not contain the literal `_immediateMode` (task 11)")
  end
end

-- Broad acceptance: the literal only appears in StateManager.lua / Context.lua
-- (where the mode is defined/read), nowhere else under modules/.
function TestImmediateModeBranchInvariants:testLiteralConfinedToStateManagerAndContext()
  local exempted = { ["modules/StateManager.lua"] = true, ["modules/Context.lua"] = true }
  for _, file in ipairs(SOURCE_FILES) do
    luaunit.assertIsNil(exempted[file], file .. " should be in the checked (non-exempted) set")
    local content = readFile(file)
    if content then
      local _, count = content:gsub("_immediateMode", "")
      luaunit.assertEquals(count, 0, file .. " must not reference `_immediateMode` directly")
    end
  end
end

-- The mode-aware accessors must exist and reflect the active mode.
function TestImmediateModeBranchInvariants:testModeAwareAccessorsExist()
  local Context = require("modules.Context")
  local StateManager = require("modules.StateManager")
  luaunit.assertEquals(type(Context.isImmediateMode), "function", "Context.isImmediateMode must exist")
  luaunit.assertEquals(type(StateManager.isImmediateMode), "function", "StateManager.isImmediateMode must exist")
  luaunit.assertEquals(type(StateManager.shouldLayout), "function", "StateManager.shouldLayout must exist")
end

function TestImmediateModeBranchInvariants:testShouldLayoutReflectsMode()
  FlexLove.init()
  local StateManager = require("modules.StateManager")
  FlexLove.setMode("retained")
  luaunit.assertTrue(StateManager.shouldLayout(), "shouldLayout() must be true in retained mode")
  luaunit.assertFalse(StateManager.isImmediateMode(), "isImmediateMode() must be false in retained mode")
  FlexLove.setMode("immediate")
  luaunit.assertFalse(StateManager.shouldLayout(), "shouldLayout() must be false in immediate mode")
  luaunit.assertTrue(StateManager.isImmediateMode(), "isImmediateMode() must be true in immediate mode")
  FlexLove.setMode("retained")
  FlexLove.destroy()
end

-- Behavioral: immediate-mode state hydration still works end-to-end through
-- the uniform accessor path (an element's id-keyed state persists across a
-- frame boundary that recreates the element).
TestImmediateModeHydration = {}

function TestImmediateModeHydration:setUp()
  FlexLove.init({ immediateMode = true })
  FlexLove.beginFrame()
end

function TestImmediateModeHydration:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

function TestImmediateModeHydration:testPublicPropPersistsAcrossImmediateModeFrames()
  local el = FlexLove.new({ id = "imp-prop", width = 100, height = 40, text = "first" })
  el.text = "mutated"
  FlexLove.endFrame()
  FlexLove.beginFrame()
  local el2 = FlexLove.new({ id = "imp-prop", width = 100, height = 40, text = "first" })
  luaunit.assertEquals(el2.text, "mutated", "event-driven prop mutation must persist across immediate-mode recreation")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
