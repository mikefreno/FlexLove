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
local StateManager = require("modules.StateManager")

TestElementModeOverride = {}

function TestElementModeOverride:setUp()
  -- Initialize FlexLove in immediate mode by default
  FlexLove.init({ immediateMode = true })
  FlexLove.beginFrame()
end

function TestElementModeOverride:tearDown()
  if FlexLove.getMode() == "immediate" then
    FlexLove.endFrame()
  end
  -- Reset to default state
  FlexLove.init({ immediateMode = false })
end

-- Test 01: Mode resolution - explicit immediate
function TestElementModeOverride:test_modeResolution_explicitImmediate()
  local element = FlexLove.new({
    mode = "immediate",
    text = "Test",
  })

  luaunit.assertEquals(element._elementMode, "immediate")
end

-- Test 02: Mode resolution - explicit retained
function TestElementModeOverride:test_modeResolution_explicitRetained()
  local element = FlexLove.new({
    mode = "retained",
    text = "Test",
  })

  luaunit.assertEquals(element._elementMode, "retained")
end

-- Test 03: Mode resolution - nil uses global (immediate)
function TestElementModeOverride:test_modeResolution_nilUsesGlobalImmediate()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()

  local element = FlexLove.new({
    text = "Test",
  })

  luaunit.assertEquals(element._elementMode, "immediate")
end

-- Test 04: Mode resolution - nil uses global (retained)
function TestElementModeOverride:test_modeResolution_nilUsesGlobalRetained()
  FlexLove.setMode("retained")

  local element = FlexLove.new({
    text = "Test",
  })

  luaunit.assertEquals(element._elementMode, "retained")
end

-- Test 06: Immediate override in retained context
function TestElementModeOverride:test_immediateOverrideInRetainedContext()
  FlexLove.setMode("retained")

  local element = FlexLove.new({
    mode = "immediate",
    id = "test-immediate",
    text = "Immediate in retained context",
  })

  luaunit.assertEquals(element._elementMode, "immediate")
  luaunit.assertEquals(element.id, "test-immediate")
end

-- Test 08: Mixed-mode parent-child (immediate parent, retained child)
function TestElementModeOverride:test_mixedMode_immediateParent_retainedChild()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()

  local parent = FlexLove.new({
    mode = "immediate",
    id = "parent",
    text = "Parent",
  })

  local child = FlexLove.new({
    mode = "retained",
    parent = parent,
    text = "Child",
  })

  luaunit.assertEquals(parent._elementMode, "immediate")
  luaunit.assertEquals(child._elementMode, "retained")
  -- Child should not inherit parent mode
  luaunit.assertNotEquals(child._elementMode, parent._elementMode)
end

-- Test 09: Mixed-mode parent-child (retained parent, immediate child)
function TestElementModeOverride:test_mixedMode_retainedParent_immediateChild()
  FlexLove.setMode("retained")

  local parent = FlexLove.new({
    mode = "retained",
    text = "Parent",
  })

  local child = FlexLove.new({
    mode = "immediate",
    id = "child",
    parent = parent,
    text = "Child",
  })

  luaunit.assertEquals(parent._elementMode, "retained")
  luaunit.assertEquals(child._elementMode, "immediate")
  luaunit.assertEquals(child.id, "child")
end

-- Test 10: Frame registration only for immediate elements
function TestElementModeOverride:test_frameRegistration_onlyImmediate()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()

  local immediate1 = FlexLove.new({
    mode = "immediate",
    id = "imm1",
    text = "Immediate 1",
  })

  local retained1 = FlexLove.new({
    mode = "retained",
    text = "Retained 1",
  })

  local immediate2 = FlexLove.new({
    mode = "immediate",
    id = "imm2",
    text = "Immediate 2",
  })

  -- Count immediate elements in _currentFrameElements
  local immediateCount = 0
  for _, element in ipairs(FlexLove._currentFrameElements) do
    if element._elementMode == "immediate" then
      immediateCount = immediateCount + 1
    end
  end

  luaunit.assertEquals(immediateCount, 2)
end

-- Test 11: Layout calculation for retained parent with immediate children
function TestElementModeOverride:test_layoutRetainedParentWithImmediateChildren()
  FlexLove.setMode("retained")

  -- Create retained parent with flex layout
  local parent = FlexLove.new({
    mode = "retained",
    width = 800,
    height = 600,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 10,
  })

  -- Switch to immediate mode and add children
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()

  local child1 = FlexLove.new({
    mode = "immediate",
    id = "child1",
    parent = parent,
    width = 100,
    height = 50,
  })

  local child2 = FlexLove.new({
    mode = "immediate",
    id = "child2",
    parent = parent,
    width = 100,
    height = 50,
  })

  FlexLove.endFrame()

  -- Verify children are positioned correctly by flex layout
  luaunit.assertEquals(child1.x, 0)
  luaunit.assertEquals(child1.y, 0)
  luaunit.assertEquals(child2.x, 110) -- 100 + 10 gap
  luaunit.assertEquals(child2.y, 0)
end

-- Test 12: Deeply nested mixed modes (retained -> immediate -> retained)
function TestElementModeOverride:test_deeplyNestedMixedModes()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()

  -- Level 1: Retained root
  local root = FlexLove.new({
    mode = "retained",
    width = 800,
    height = 600,
    positioning = "flex",
    flexDirection = "vertical",
    gap = 5,
  })

  -- Level 2: Immediate child of retained parent
  local middle = FlexLove.new({
    mode = "immediate",
    id = "middle",
    parent = root,
    width = 400,
    height = 300,
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 10,
  })

  -- Level 3: Retained grandchildren
  local leaf1 = FlexLove.new({
    mode = "retained",
    parent = middle,
    width = 100,
    height = 50,
  })

  local leaf2 = FlexLove.new({
    mode = "retained",
    parent = middle,
    width = 100,
    height = 50,
  })

  FlexLove.endFrame()

  -- Verify all levels are positioned correctly
  luaunit.assertEquals(root.x, 0)
  luaunit.assertEquals(root.y, 0)
  luaunit.assertEquals(middle.x, 0)
  luaunit.assertEquals(middle.y, 0)
  luaunit.assertEquals(leaf1.x, 0)
  luaunit.assertEquals(leaf1.y, 0)
  luaunit.assertEquals(leaf2.x, 110) -- 100 + 10 gap
  luaunit.assertEquals(leaf2.y, 0)
end

-- Test 13: Immediate children of retained parents receive updates
function TestElementModeOverride:test_immediateChildrenOfRetainedParentsGetUpdated()
  FlexLove.setMode("retained")

  local updateCount = 0

  -- Create retained parent
  local parent = FlexLove.new({
    mode = "retained",
    width = 800,
    height = 600,
  })

  -- Switch to immediate mode for child
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()

  -- Create immediate child that tracks updates
  local child = FlexLove.new({
    mode = "immediate",
    id = "updateTest",
    parent = parent,
    width = 100,
    height = 50,
  })

  -- Manually call update on the child to simulate what endFrame should do
  -- In the real implementation, endFrame calls update on retained parents,
  -- which cascades to immediate children
  FlexLove.endFrame()

  -- The child should be in the state manager
  local state = StateManager.getState("updateTest")
  luaunit.assertNotNil(state)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
