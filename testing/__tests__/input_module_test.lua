-- Test suite for modules/Input.lua (virtual input indirection)
-- Covers: default passthrough to love, virtual position/buttons/keys,
-- modifiers, multi-key AND, and state reset semantics.

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
local Input = require("modules.Input")
local virtX, virtY = 0, 0

TestInputPassthrough = {}

local baseX, baseY

function TestInputPassthrough:setUp()
  baseX, baseY = love.mouse.getPosition()
  love.mouse.setDown(1, false)
  love.mouse.setDown(2, false)
  love.mouse.setPosition(10, 15)
end

function TestInputPassthrough:tearDown()
  Input.useVirtual(false)
  love.mouse.setPosition(baseX, baseY)
end

function TestInputPassthrough:testDefaultReadsLove()
  luaunit.assertFalse(Input.isVirtual())
  love.mouse.setPosition(10, 15)
  luaunit.assertEquals({ Input.getPosition() }, { 10, 15 })
  love.mouse.setDown(1, true)
  luaunit.assertTrue(Input.isDown(1))
  love.mouse.setDown(1, false)
  luaunit.assertFalse(Input.isDown(1))
end

TestInputVirtual = {}

function TestInputVirtual:setUp()
  virtX, virtY = love.mouse.getPosition()
  Input.useVirtual(true)
end

function TestInputVirtual:tearDown()
  Input.useVirtual(false)
  love.mouse.setPosition(virtX, virtY)
end

function TestInputVirtual:testPositionAndButtons()
  Input.setVirtualState({ x = 100, y = 200, buttons = { [1] = true } })
  luaunit.assertEquals({ Input.getPosition() }, { 100, 200 })
  luaunit.assertTrue(Input.isDown(1))
  luaunit.assertFalse(Input.isDown(2))
  luaunit.assertFalse(Input.isDown(3))
end

function TestInputVirtual:testButtonsReplaceNotMerge()
  Input.setVirtualState({ buttons = { [1] = true } })
  Input.setVirtualState({ buttons = { [2] = true } })
  luaunit.assertFalse(Input.isDown(1))
  luaunit.assertTrue(Input.isDown(2))
end

function TestInputVirtual:testOmittedTablesKept()
  Input.setVirtualState({ x = 5, buttons = { [3] = true } })
  Input.setVirtualState({ y = 9 })
  luaunit.assertTrue(Input.isDown(3))
  luaunit.assertEquals({ Input.getPosition() }, { 5, 9 })
end

function TestInputVirtual:testKeysAndMultiKeyAnd()
  love.keyboard.setDown("lshift", true)
  Input.setVirtualState({ keys = { lshift = true, lctrl = true } })
  luaunit.assertTrue(Input.isKeyDown("lshift"))
  luaunit.assertTrue(Input.isKeyDown("lshift", "lctrl"))
  luaunit.assertFalse(Input.isKeyDown("lshift", "lctrl", "a"))
  luaunit.assertFalse(Input.isKeyDown("a"))
end

function TestInputVirtual:testModifiers()
  Input.setVirtualState({ keys = { lshift = true, rctrl = true } })
  local mods = Input.getModifiers()
  luaunit.assertTrue(mods.shift)
  luaunit.assertTrue(mods.ctrl)
  luaunit.assertFalse(mods.alt)
  luaunit.assertFalse(mods.super)
end

function TestInputVirtual:testIgnoresRealMouseWhileVirtual()
  love.mouse.setPosition(999, 999)
  love.mouse.setDown(1, true)
  Input.setVirtualState({ x = 42, y = 43, buttons = {} })
  luaunit.assertEquals({ Input.getPosition() }, { 42, 43 })
  luaunit.assertFalse(Input.isDown(1))
end

TestFindByText = {}

function TestFindByText:setUp()
  local FlexLove = require("FlexLove")
  FlexLove.init({})
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  self.fl = FlexLove
end

function TestFindByText:tearDown()
  self.fl.destroy()
end

function TestFindByText:testFindsExactAndPattern()
  self.fl.new({ id = "t1", text = "New Game" })
  self.fl.new({ id = "t2", text = "Load Game" })
  self.fl.new({ id = "t3", text = "Settings" })
  local m = self.fl.findByText("New Game", { exact = true })
  luaunit.assertEquals(#m, 1)
  luaunit.assertEquals(m[1].id, "t1")
  m = self.fl.findByText("Game")
  luaunit.assertTrue(#m >= 2)
end

function TestFindByText:testNoMatchReturnsEmpty()
  self.fl.new({ id = "t1", text = "Alpha" })
  luaunit.assertEquals(#self.fl.findByText("nope"), 0)
end

-- Run tests if this file is executed directly.
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
