-- Unit + integration tests for modules.behaviors.Animated (task 06).
--
-- Validates the concrete Animated behavior that owns animation update,
-- interpolation application, chaining resolution, and Animation-module wiring
-- — everything that previously lived inline in Element:update's
-- `if self.animation then ... end` block.
--
-- Coverage:
--   * shouldAttach predicate — true for pre-declared transitions or a runtime
--     element.animation; false for plain passive elements / nil props.
--   * Behavior interface conformance — Animated exposes all 6 lifecycle hooks
--     (callable, no-op-safe for the ones it does not override) and a
--     shouldAttach predicate; the wrapped frozen behavior instance is a Behavior.
--   * onUpdate — no-ops when there is no animation; advances an active
--     animation and applies interpolation to element properties; resolves a
--     `_next` chained animation; resolves a `_nextFactory` chained animation;
--     clears element.animation when an unchained animation completes.
--   * saveState / restoreState — are no-ops (animations are ephemeral; the
--     behavior's state snapshot is nil and restore touches nothing).
--   * onAttach — wires Element._Animation._ColorModule / _TransformModule
--     exactly once (idempotent).
--   * ensureAttached — idempotent late-attach: attaches once, no-ops on repeat,
--     and tolerates nil element / nil behavior.
--   * Integration — Element.new auto-attaches Animated to elements that
--     pre-declare transitions; Element:update advances a manually-applied
--     animation via the early dispatcher (no inline `if self.animation` branch);
--     a transition firing in setProperty animates and runs to completion through
--     Element:update alone.

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
local Animated = require("modules.behaviors.Animated")
local FlexLove = require("FlexLove")

-- Resolve Animation + Element through the harness (mirrors the chaining test).
FlexLove.init()
local Animation = FlexLove.Animation

-- ============================================================================
-- Helpers
-- ============================================================================

-- Build a bare element whose metatable is the Element class so the Animated
-- behavior's ElementClass(element) (getmetatable) resolves Element._Animation /
-- _Color / _Transform the same way production elements do.
local function makeElement(props)
  props = props or {}
  props.id = props.id or "animated-test-" .. tostring(math.random(1e9))
  props.width = props.width or 100
  props.height = props.height or 100
  return FlexLove.new(props)
end

-- Build a stand-alone element-like table for pure onAttach/onUpdate unit tests
-- so we can exercise Animated.onUpdate in isolation without a full Element.new
-- (mirrors how the Easing unit tests call animation:update directly). We give
-- it the Element class as its metatable so ElementClass(element) resolves the
-- Animation module deps.
local function stubElement()
  local Element = require("modules.Element")
  local el = setmetatable({
    behaviors = {},
    -- reasonable element defaults so applyInterpolation has fields to write.
    -- backgroundColor is required because Animation:applyInterpolation has a
    -- backward-compat path that writes backgroundColor.a for opacity-only
    -- animations.
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    opacity = 1,
    backgroundColor = { r = 0, g = 0, b = 0, a = 1 },
  }, Element)
  return el
end

-- ============================================================================
-- shouldAttach predicate
-- ============================================================================

TestAnimatedShouldAttach = {}

function TestAnimatedShouldAttach:testTransitionsPredeclared_Attaches()
  -- Pre-declared transitions (set via setTransition before/at construction)
  -- cause Animated to auto-attach during Element.new.
  luaunit.assertTrue(Animated.shouldAttach({ transitions = { opacity = {} } }))
end

function TestAnimatedShouldAttach:testEmptyTransitionsTable_Attaches()
  -- An empty (but non-nil) transitions table should attach: setTransition
  -- initializes self.transitions = {} before writing the first entry, so the
  -- element may legitimately have an empty table by the time shouldAttach runs.
  luaunit.assertTrue(Animated.shouldAttach({ transitions = {} }))
end

function TestAnimatedShouldAttach:testRuntimeAnimation_Attaches()
  -- The late-attach arm: when ensureAttached passes the element instance as
  -- `props`, an existing element.animation triggers shouldAttach.
  luaunit.assertTrue(Animated.shouldAttach({
    animation = Animation.new({
      duration = 0.2,
      start = {},
      final = {},
    }),
  }))
end

function TestAnimatedShouldAttach:testPassiveProps_DoNotAttach()
  luaunit.assertFalse(Animated.shouldAttach({}))
  luaunit.assertFalse(Animated.shouldAttach(nil))
  luaunit.assertFalse(Animated.shouldAttach({ width = 100, height = 50 }))
  luaunit.assertFalse(Animated.shouldAttach({ text = "label" }))
  luaunit.assertFalse(Animated.shouldAttach({ editable = true }))
end

-- ============================================================================
-- Behavior interface conformance
-- ============================================================================

TestAnimatedInterface = {}

function TestAnimatedInterface:testWrappedBehaviorIsABehaviorInstance()
  -- The module returns a thin table; the frozen behavior it wraps IS a
  -- Behavior instance. The registry iterates and calls hooks on the wrapper
  -- (which fall through to the frozen behavior via __index).
  luaunit.assertTrue(Behavior.isBehavior(Animated.behavior))
end

function TestAnimatedInterface:testExposesAllLifecycleHooksAsFunctions()
  for _, hook in ipairs(Behavior.HOOK_NAMES) do
    luaunit.assertEquals(type(Animated[hook]), "function", hook .. " must be reachable as a function")
  end
  luaunit.assertEquals(type(Animated.shouldAttach), "function")
end

function TestAnimatedInterface:testExposesEnsureAttachedHelper()
  -- The spec calls for `Animated.ensureAttached(element)` to be callable from
  -- Element.setProperty / transition helpers.
  luaunit.assertEquals(type(Animated.ensureAttached), "function")
end

function TestAnimatedInterface:testOnDrawIsCallableNoOp()
  -- Animation has no draw pass; the inherited no-op onDraw must be safe.
  Animated.onDraw({}, {})
  luaunit.assertTrue(true, "onDraw no-op completed without error")
end

-- ============================================================================
-- onAttach — Animation module wiring
-- ============================================================================

TestAnimatedOnAttach = {}

function TestAnimatedOnAttach:testWiresColorModuleExactlyOnce()
  local el = stubElement()
  -- Clear any module wiring left by other tests so we can observe the write.
  local AnimationModule = getmetatable(el)._Animation
  AnimationModule._ColorModule = nil
  AnimationModule._TransformModule = nil

  Animated.onAttach(el)
  luaunit.assertNotNil(AnimationModule._ColorModule, "onAttach must wire _ColorModule")
  luaunit.assertNotNil(AnimationModule._TransformModule, "onAttach must wire _TransformModule")

  -- Idempotent: second onAttach does not overwrite (and does not error).
  local firstColor = AnimationModule._ColorModule
  Animated.onAttach(el)
  luaunit.assertIs(AnimationModule._ColorModule, firstColor)
end

function TestAnimatedOnAttach:testNoAnimationModule_DoesNotError()
  -- Minimal builds may omit the Animation deps; onAttach must no-op safely.
  local el = stubElement()
  local Element = getmetatable(el)
  local saved = Element._Animation
  Element._Animation = nil
  Animated.onAttach(el)
  Element._Animation = saved
  luaunit.assertTrue(true, "onAttach must not error when Element._Animation is nil")
end

-- ============================================================================
-- onUpdate — no-op / advance / interpolation
-- ============================================================================

TestAnimatedOnUpdateNoOp = {}

function TestAnimatedOnUpdateNoOp:testNoAnimation_IsNoOp()
  local el = stubElement()
  el.animation = nil
  local before = { x = el.x, y = el.y, width = el.width, height = el.height, opacity = el.opacity }
  Animated.onUpdate(el, 0.016)
  luaunit.assertEquals(el.x, before.x)
  luaunit.assertEquals(el.y, before.y)
  luaunit.assertEquals(el.width, before.width)
  luaunit.assertEquals(el.height, before.height)
  luaunit.assertEquals(el.opacity, before.opacity)
  luaunit.assertIsNil(el.animation)
end

TestAnimatedOnUpdateAdvance = {}

function TestAnimatedOnUpdateAdvance:testAdvancesAnimationAndAppliesInterpolation()
  -- A 0.2s opacity animation 1 -> 0. After one 0.05s step, elapsed advances
  -- and the interpolation is applied to element.opacity (between 1 and 0).
  local el = stubElement()
  el.opacity = 1
  local anim = Animation.new({
    duration = 0.2,
    start = { opacity = 1 },
    final = { opacity = 0 },
    easing = "linear",
  })
  el.animation = anim

  Animated.onUpdate(el, 0.05)
  luaunit.assertEquals(anim:getProgress(), 0.25)
  -- applyInterpolation writes element.opacity (linear lerp 1*0.75 + 0*0.25).
  luaunit.assertTrue(el.opacity < 1, "opacity must be interpolated below start value")
  luaunit.assertTrue(el.opacity > 0, "opacity must be interpolated above final value")
  luaunit.assertNotNil(el.animation, "animation must remain active while not finished")
end

function TestAnimatedOnUpdateAdvance:testCompletedUnchainedAnimation_ClearsElementAnimation()
  local el = stubElement()
  el.opacity = 1
  el.animation = Animation.new({
    duration = 0.1,
    start = { opacity = 1 },
    final = { opacity = 0 },
  })
  -- Stepping past duration completes the animation.
  Animated.onUpdate(el, 1.0)
  luaunit.assertIsNil(el.animation, "completed unchained animation must be cleared")
end

-- ============================================================================
-- onUpdate — chained animation resolution
-- ============================================================================

TestAnimatedChaining = {}

function TestAnimatedChaining:testNextAnimation_ResolvesOnCompletion()
  local el = stubElement()
  el.x = 0
  local anim1 = Animation.new({
    duration = 0.1,
    start = { x = 0 },
    final = { x = 50 },
  })
  local anim2 = Animation.new({
    duration = 0.1,
    start = { x = 50 },
    final = { x = 100 },
  })
  anim1:chain(anim2)
  el.animation = anim1

  -- Run anim1 to completion.
  Animated.onUpdate(el, 1.0)
  luaunit.assertIs(el.animation, anim2, "completed animation must hand off to its _next chain")
end

function TestAnimatedChaining:testNextFactory_ResolvesOnCompletion()
  local el = stubElement()
  el.x = 0
  local factoryCalled = false
  local anim1 = Animation.new({
    duration = 0.1,
    start = { x = 0 },
    final = { x = 50 },
  })
  local anim2 = Animation.new({
    duration = 0.2,
    start = { x = 50 },
    final = { x = 200 },
  })
  anim1:chain(function(element)
    factoryCalled = true
    luaunit.assertIs(element, el, "factory must receive the owning element")
    return anim2
  end)
  el.animation = anim1

  Animated.onUpdate(el, 1.0)
  luaunit.assertTrue(factoryCalled, "_nextFactory must be invoked on completion")
  luaunit.assertIs(el.animation, anim2, "factory's return value must become element.animation")
end

function TestAnimatedChaining:testNextFactoryReturningNil_ClearsAnimation()
  local el = stubElement()
  el.x = 0
  local anim1 = Animation.new({
    duration = 0.1,
    start = { x = 0 },
    final = { x = 50 },
  })
  anim1:chain(function()
    return nil
  end)
  el.animation = anim1

  Animated.onUpdate(el, 1.0)
  luaunit.assertIsNil(el.animation, "factory returning nil must clear element.animation")
end

function TestAnimatedChaining:testNextFactoryThrowing_ClearsAnimationDoesNotPropagate()
  local el = stubElement()
  el.x = 0
  local anim1 = Animation.new({
    duration = 0.1,
    start = { x = 0 },
    final = { x = 50 },
  })
  anim1:chain(function()
    error("boom")
  end)
  el.animation = anim1

  Animated.onUpdate(el, 1.0)
  luaunit.assertIsNil(el.animation, "factory throwing must be pcall'd and clear element.animation")
end

-- ============================================================================
-- saveState / restoreState — no-ops (ephemeral animation state)
-- ============================================================================

TestAnimatedState = {}

function TestAnimatedState:testSaveStateReturnsNil()
  local el = stubElement()
  el.animation = Animation.new({ duration = 0.1, start = {}, final = {} })
  luaunit.assertIsNil(Animated.saveState(el))
  -- No animation -> still nil (no-op).
  el.animation = nil
  luaunit.assertIsNil(Animated.saveState(el))
end

function TestAnimatedState:testRestoreStateIsNoOpDoesNotTouchAnimation()
  local el = stubElement()
  local anim = Animation.new({ duration = 0.1, start = {}, final = {} })
  el.animation = anim
  -- restoreState must not clear / replace element.animation and must not error.
  Animated.restoreState(el, { someState = 1 })
  Animated.restoreState(el, nil)
  luaunit.assertIs(el.animation, anim, "restoreState must not modify element.animation")
end

-- ============================================================================
-- ensureAttached — idempotent late-attach
-- ============================================================================

TestAnimatedEnsureAttached = {}

function TestAnimatedEnsureAttached:testFirstCallAttachesAndReturnsTrue()
  local el = stubElement()
  el.behaviors = {}
  luaunit.assertEquals(#el.behaviors, 0)
  local ok = Animated.ensureAttached(el, Animated)
  luaunit.assertTrue(ok, "first ensureAttached must return true")
  luaunit.assertEquals(#el.behaviors, 1)
  luaunit.assertIs(el.behaviors[1], Animated, "must insert the Animated behavior into element.behaviors")
end

function TestAnimatedEnsureAttached:testSecondCallIsNoOpReturnsFalse()
  local el = stubElement()
  el.behaviors = {}
  luaunit.assertTrue(Animated.ensureAttached(el, Animated))
  luaunit.assertFalse(Animated.ensureAttached(el, Animated), "repeat attach must return false")
  luaunit.assertEquals(#el.behaviors, 1, "must not double-register the behavior")
end

function TestAnimatedEnsureAttached:testNilElementReturnsFalse()
  luaunit.assertFalse(Animated.ensureAttached(nil, Animated))
end

function TestAnimatedEnsureAttached:testNilBehaviorReturnsFalse()
  local el = stubElement()
  luaunit.assertFalse(Animated.ensureAttached(el, nil))
  luaunit.assertFalse(Animated.ensureAttached(nil, nil))
end

function TestAnimatedEnsureAttached:testAttachInvokesOnAttach_WiresModules()
  local el = stubElement()
  el.behaviors = {}
  local AnimationModule = getmetatable(el)._Animation
  AnimationModule._ColorModule = nil
  Animated.ensureAttached(el, Animated)
  luaunit.assertNotNil(AnimationModule._ColorModule, "ensureAttached must dispatch onAttach which wires _ColorModule")
end

-- ============================================================================
-- Integration: Element.new + Element:update dispatch path
-- ============================================================================

TestAnimatedIntegration = {}

function TestAnimatedIntegration:setUp()
  FlexLove.beginFrame()
end

function TestAnimatedIntegration:tearDown()
  FlexLove.endFrame()
end

function TestAnimatedIntegration:testPredeclaredTransitions_AutoAttachesAnimated()
  -- shouldAttach({transitions=...}) is true -> Animated attaches during
  -- Element.new. (Registry iteration order does not affect attachment.)
  local el = FlexLove.new({
    id = "anim-int-trans",
    width = 100,
    height = 50,
    transitions = { opacity = { duration = 0.3 } },
  })
  local attached = false
  for _, b in ipairs(el.behaviors) do
    if b == Animated then
      attached = true
      break
    end
  end
  luaunit.assertTrue(attached, "element pre-declaring transitions must attach Animated")
end

function TestAnimatedIntegration:testPassiveElement_DoesNotAutoAttachAnimated()
  local el = FlexLove.new({ id = "anim-int-passive", width = 100, height = 50, text = "label" })
  for _, b in ipairs(el.behaviors) do
    luaunit.assertNotIs(b, Animated, "passive element must not auto-attach Animated")
  end
end

function TestAnimatedIntegration:testElementUpdate_AdvancesAppliedAnimation()
  -- The spec acceptance criterion: Element:update advances an active animation
  -- and applies interpolation. There is no `if self.animation` branch in
  -- Element:update anymore — dispatch goes through the early
  -- `_dispatchAnimatedUpdate` path -> Animated.onUpdate.
  local el = FlexLove.new({ id = "anim-int-update", width = 100, height = 100, opacity = 1 })
  el.animation = Animation.new({
    duration = 0.2,
    start = { opacity = 1 },
    final = { opacity = 0 },
    easing = "linear",
  })
  el:update(0.05)
  -- Interpolation applied: opacity moved strictly between 1 and 0.
  luaunit.assertTrue(el.opacity < 1 and el.opacity > 0, "Element:update must apply animation interpolation")
  luaunit.assertNotNil(el.animation, "animation must remain active after a partial step")
end

function TestAnimatedIntegration:testElementUpdate_RunsTransitionAnimationToCompletion()
  -- A setProperty() transition fires an animation; Element:update alone drives
  -- it to completion (clearing element.animation) via the Animated behavior.
  local el = FlexLove.new({ id = "anim-int-transition", width = 100, height = 100, opacity = 1 })
  el:setTransition("opacity", { duration = 0.2 })
  el:setProperty("opacity", 0)
  luaunit.assertNotNil(el.animation, "setProperty transition must create element.animation")
  for _ = 1, 60 do
    el:update(1 / 60)
    if not el.animation then
      break
    end
  end
  luaunit.assertIsNil(el.animation, "transition animation must reach completion and clear element.animation")
end

function TestAnimatedIntegration:testChainedAnimationResolvesViaElementUpdate()
  -- End-to-end chaining through Element:update (the spec integration case).
  -- Uses the same timing profile as animation_chaining_test.lua (0.2s anims,
  -- 20 frames per phase) so each animation completes within its run loop.
  local el = FlexLove.new({ id = "anim-int-chain", width = 100, height = 100 })
  el.x = 0
  local order = {}
  local anim1 = Animation.new({
    duration = 0.2,
    start = { x = 0 },
    final = { x = 50 },
    onComplete = function()
      table.insert(order, 1)
    end,
  })
  local anim2 = Animation.new({
    duration = 0.2,
    start = { x = 50 },
    final = { x = 100 },
    onComplete = function()
      table.insert(order, 2)
    end,
  })
  anim1:chain(anim2)
  anim1:apply(el)

  for _ = 1, 20 do
    el:update(1 / 60)
  end
  luaunit.assertEquals(order[1], 1, "anim1 onComplete must fire")
  luaunit.assertIs(el.animation, anim2, "chain must hand off to anim2 through Element:update")
  for _ = 1, 20 do
    el:update(1 / 60)
  end
  luaunit.assertEquals(order[2], 2, "anim2 onComplete must fire")
  luaunit.assertIsNil(el.animation, "chain end must clear element.animation")
end

function TestAnimatedIntegration:testNoInlineIfSelfAnimationBranchInElementUpdateDraw()
  -- Acceptance criterion against regressions: Element.lua must not contain a
  -- behavioral `if self.animation` code branch in update/draw (comments don't
  -- count). Load the source and assert no CODE-level occurrence remains.
  local f = io.open("modules/Element.lua", "r")
  luaunit.assertNotNil(f, "Element.lua must be readable")
  local src = f:read("*a")
  f:close()
  -- Strip block + line comments so we only inspect code. Lua comments run to
  -- end of line (-- ...) so a simple line-based filter suffices.
  local codeLines = {}
  for line in src:gmatch("[^\r\n]+") do
    -- Remove a trailing `-- ...` comment, preserving code before it. A line
    -- that is ONLY a comment becomes empty.
    local stripped = line:gsub("%-%-.*$", "")
    table.insert(codeLines, stripped)
  end
  local code = table.concat(codeLines, "\n")
  -- Count `if self.animation` as a CODE token (not inside a comment now).
  local _, count = code:gsub("if self%.animation", "")
  luaunit.assertEquals(count, 0, "Element.lua must have zero behavioral 'if self.animation' branches in code")
  -- And no Animation-module wiring left in Element.lua either.
  local _, colorCount = code:gsub("Element%._Animation%._ColorModule", "")
  luaunit.assertEquals(colorCount, 0, "Element.lua must not wire Element._Animation._ColorModule")
end

-- Run tests if this file is executed directly.
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
