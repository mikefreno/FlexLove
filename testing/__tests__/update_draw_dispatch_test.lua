-- Unit tests for behavior-driven Element:update / Element:draw dispatch
-- (behavior-mode-unification task 09).
--
-- Validates the core dispatch contract:
--   * Element:update dispatches onUpdate to every attached behavior (in
--     registry order) and propagates to children; an element whose behaviors
--     table has been emptied calls no behavior's onUpdate (only child:update).
--   * Element:draw dispatches onDraw to every attached behavior, split into a
--     pre-children pass (drawLayer ~= "overlay") and a post-children pass
--     (drawLayer == "overlay") so overlay layers paint after child content.
--   * Element:_processDeferredMethods retries deferred method entries.

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
local Behavior = require("modules.Behavior")
local FlexLove = require("FlexLove")

-- Build a recording behavior: spies onUpdate / onDraw and the drawLayer the
-- caller wants. onUpdate receives (element, dt); onDraw receives (element, ctx).
local function spyBehavior(opts)
  opts = opts or {}
  local calls = { onUpdate = 0, onDraw = 0, lastElement = nil, lastDt = nil }
  local spec = {
    onUpdate = function(element, dt)
      calls.onUpdate = calls.onUpdate + 1
      calls.lastElement = element
      calls.lastDt = dt
    end,
    onDraw = function(element, ctx)
      calls.onDraw = calls.onDraw + 1
      calls.lastElement = element
      calls.lastCtx = ctx
    end,
  }
  if opts.drawLayer then
    spec.drawLayer = opts.drawLayer
  end
  local b = Behavior.new(spec)
  return b, calls
end

TestUpdateDispatch = {}

function TestUpdateDispatch:setUp()
  FlexLove.init()
  FlexLove.beginFrame()
end

function TestUpdateDispatch:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

function TestUpdateDispatch:testUpdate_DispatchesOnUpdateToEachAttachedBehavior()
  local el = FlexLove.new({ id = "upd-spy", width = 100, height = 50 })
  local spy, calls = spyBehavior()
  el.behaviors = { spy }
  el:update(0.016)
  luaunit.assertEquals(calls.onUpdate, 1, "attached behavior onUpdate must be called once")
  luaunit.assertIs(calls.lastElement, el, "onUpdate must receive the element")
  luaunit.assertEquals(calls.lastDt, 0.016, "onUpdate must receive dt")
end

function TestUpdateDispatch:testUpdate_DispatchesInRegistryOrder()
  local el = FlexLove.new({ id = "upd-order", width = 100, height = 50 })
  local order = {}
  local function mk(label)
    return Behavior.new({
      onUpdate = function()
        table.insert(order, label)
      end,
    })
  end
  el.behaviors = { mk("a"), mk("b"), mk("c") }
  el:update(0.016)
  luaunit.assertEquals(order[1], "a")
  luaunit.assertEquals(order[2], "b")
  luaunit.assertEquals(order[3], "c")
end

function TestUpdateDispatch:testUpdate_EmptyBehaviors_CallsNoBehaviorOnUpdate()
  local el = FlexLove.new({ id = "upd-empty", width = 100, height = 50 })
  local spy, calls = spyBehavior()
  -- behaviors emptied → the loop must not dispatch any (attached) onUpdate.
  el.behaviors = {}
  el:update(0.016)
  luaunit.assertEquals(calls.onUpdate, 0, "no behavior onUpdate must fire when behaviors is empty")
end

function TestUpdateDispatch:testUpdate_PropagatesToChildren()
  local parent = FlexLove.new({ id = "upd-parent", width = 100, height = 50 })
  local child = FlexLove.new({ id = "upd-child", width = 10, height = 10, parent = parent })
  local childCalled = 0
  local realChildUpdate = child.update
  child.update = function(self, dt)
    childCalled = childCalled + 1
    luaunit.assertIs(self, child)
    luaunit.assertEquals(dt, 0.016)
  end
  parent:update(0.016)
  child.update = realChildUpdate
  luaunit.assertEquals(childCalled, 1, "Element:update must call child:update once")
end

TestDrawDispatch = {}

function TestDrawDispatch:setUp()
  FlexLove.init()
  FlexLove.beginFrame()
end

function TestDrawDispatch:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

function TestDrawDispatch:testDraw_DispatchesOnDrawToBackgroundBehavior()
  local el = FlexLove.new({ id = "draw-bg", width = 100, height = 50 })
  local spy, calls = spyBehavior({ drawLayer = nil }) -- background (pre-children)
  el.behaviors = { spy }
  el:draw(nil)
  luaunit.assertEquals(calls.onDraw, 1, "background behavior onDraw must be called once")
  luaunit.assertIs(calls.lastElement, el, "onDraw must receive the element")
  luaunit.assertNotNil(calls.lastCtx, "onDraw must receive a draw context")
end

function TestDrawDispatch:testDraw_DispatchesOnDrawToOverlayBehavior()
  local el = FlexLove.new({ id = "draw-ovl", width = 100, height = 50 })
  local spy, calls = spyBehavior({ drawLayer = "overlay" })
  el.behaviors = { spy }
  el:draw(nil)
  luaunit.assertEquals(calls.onDraw, 1, "overlay behavior onDraw must be called once")
end

function TestDrawDispatch:testDraw_BackgroundBeforeChildren_OverlayAfterChildren()
  -- A background behavior, a child, and an overlay behavior: background onDraw
  -- must fire before child:draw, and overlay onDraw after child:draw.
  local parent = FlexLove.new({ id = "draw-order-parent", width = 100, height = 50 })
  local child = FlexLove.new({ id = "draw-order-child", width = 10, height = 10, parent = parent })
  local log = {}
  local bg = Behavior.new({
    onDraw = function()
      table.insert(log, "bg")
    end,
  })
  local ovl = Behavior.new({
    drawLayer = "overlay",
    onDraw = function()
      table.insert(log, "ovl")
    end,
  })
  parent.behaviors = { bg, ovl }
  local realChildDraw = child.draw
  child.draw = function()
    table.insert(log, "child")
  end
  parent:draw(nil)
  child.draw = realChildDraw
  luaunit.assertEquals(log[1], "bg", "background onDraw must run before child:draw")
  luaunit.assertEquals(log[2], "child", "child:draw must run between background and overlay")
  luaunit.assertEquals(log[3], "ovl", "overlay onDraw must run after child:draw")
end

TestDeferredMethods = {}

function TestDeferredMethods:setUp()
  FlexLove.init()
  FlexLove.beginFrame()
end

function TestDeferredMethods:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

function TestDeferredMethods:testProcessDeferredMethods_RetriesQueuedMethod()
  local el = FlexLove.new({ id = "defer-1", width = 100, height = 50 })
  local called = 0
  -- Define a method the dispatcher can resolve via self[methodName].
  el.deferredProbe = function(self)
    called = called + 1
  end
  el:_deferMethod("deferredProbe")
  luaunit.assertEquals(called, 0, "must not run before _processDeferredMethods")
  el:_processDeferredMethods()
  luaunit.assertEquals(called, 1, "_processDeferredMethods must invoke the queued method")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
