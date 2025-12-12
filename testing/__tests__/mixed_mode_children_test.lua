-- Test retained children persisting when immediate parents recreate
package.path = package.path .. ";./?.lua;./modules/?.lua"

-- Load love stub before anything else
require("testing.loveStub")

local luaunit = require("testing.luaunit")
local FlexLove = require("FlexLove")

TestMixedModeChildren = {}

function TestMixedModeChildren:setUp()
  FlexLove.init({ immediateMode = true })
  FlexLove.setMode("immediate")
end

function TestMixedModeChildren:tearDown()
  FlexLove._defaultDependencies.StateManager.reset()
  FlexLove.topElements = {}
  FlexLove._currentFrameElements = {}
  FlexLove._frameStarted = false
end

-- Test 1: Retained child persists when immediate parent recreates
function TestMixedModeChildren:testRetainedChildPersistsWithImmediateParent()
  FlexLove.beginFrame()

  -- Frame 1: Create immediate parent with retained child
  local parent1 = FlexLove.new({
    id = "parent",
    mode = "immediate",
    width = 200,
    height = 200,
  })

  local retainedChild = FlexLove.new({
    id = "retained_child",
    mode = "retained",
    width = 50,
    height = 50,
  })

  parent1:addChild(retainedChild)

  luaunit.assertEquals(#parent1.children, 1, "Parent should have 1 child")
  luaunit.assertEquals(parent1.children[1], retainedChild, "Child should be the retained element")
  luaunit.assertEquals(retainedChild.parent, parent1, "Child's parent should be set")

  FlexLove.endFrame()

  -- Frame 2: Recreate immediate parent, retained child should persist
  FlexLove.beginFrame()

  local parent2 = FlexLove.new({
    id = "parent",
    mode = "immediate",
    width = 200,
    height = 200,
  })

  -- The retained child should be automatically restored
  luaunit.assertEquals(#parent2.children, 1, "Parent should still have 1 child after recreation")
  luaunit.assertEquals(parent2.children[1], retainedChild, "Child should be the same retained element")
  luaunit.assertEquals(retainedChild.parent, parent2, "Child's parent reference should be updated")

  FlexLove.endFrame()
end

-- Test 2: Multiple retained children persist
function TestMixedModeChildren:testMultipleRetainedChildrenPersist()
  FlexLove.beginFrame()

  local parent1 = FlexLove.new({
    id = "parent",
    mode = "immediate",
    width = 200,
    height = 200,
  })

  local child1 = FlexLove.new({
    id = "child1",
    mode = "retained",
    width = 50,
    height = 50,
  })

  local child2 = FlexLove.new({
    id = "child2",
    mode = "retained",
    width = 50,
    height = 50,
  })

  local child3 = FlexLove.new({
    id = "child3",
    mode = "retained",
    width = 50,
    height = 50,
  })

  parent1:addChild(child1)
  parent1:addChild(child2)
  parent1:addChild(child3)

  luaunit.assertEquals(#parent1.children, 3, "Parent should have 3 children")

  FlexLove.endFrame()

  -- Frame 2
  FlexLove.beginFrame()

  local parent2 = FlexLove.new({
    id = "parent",
    mode = "immediate",
    width = 200,
    height = 200,
  })

  luaunit.assertEquals(#parent2.children, 3, "Parent should still have 3 children")
  luaunit.assertEquals(parent2.children[1], child1, "First child should persist")
  luaunit.assertEquals(parent2.children[2], child2, "Second child should persist")
  luaunit.assertEquals(parent2.children[3], child3, "Third child should persist")

  FlexLove.endFrame()
end

-- Test 3: Immediate children do NOT persist (only retained children)
function TestMixedModeChildren:testImmediateChildrenDoNotPersist()
  FlexLove.beginFrame()

  local parent1 = FlexLove.new({
    id = "parent",
    mode = "immediate",
    width = 200,
    height = 200,
  })

  local immediateChild = FlexLove.new({
    id = "immediate_child",
    mode = "immediate",
    width = 50,
    height = 50,
  })

  local retainedChild = FlexLove.new({
    id = "retained_child",
    mode = "retained",
    width = 50,
    height = 50,
  })

  parent1:addChild(immediateChild)
  parent1:addChild(retainedChild)

  luaunit.assertEquals(#parent1.children, 2, "Parent should have 2 children")

  FlexLove.endFrame()

  -- Frame 2
  FlexLove.beginFrame()

  local parent2 = FlexLove.new({
    id = "parent",
    mode = "immediate",
    width = 200,
    height = 200,
  })

  -- Only retained child should persist
  luaunit.assertEquals(#parent2.children, 1, "Parent should only have 1 child (retained)")
  luaunit.assertEquals(parent2.children[1], retainedChild, "Only retained child should persist")

  FlexLove.endFrame()
end

-- Test 4: Top-level retained element persists in immediate mode
function TestMixedModeChildren:testTopLevelRetainedElementPersists()
  FlexLove.beginFrame()

  local retainedElement = FlexLove.new({
    id = "top_retained",
    mode = "retained",
    width = 100,
    height = 100,
  })

  luaunit.assertEquals(#FlexLove.topElements, 1, "Should have 1 top-level element")
  luaunit.assertEquals(FlexLove.topElements[1], retainedElement, "Top element should be retained element")

  FlexLove.endFrame()

  -- Frame 2
  FlexLove.beginFrame()

  -- Retained element should still be in topElements
  luaunit.assertEquals(#FlexLove.topElements, 1, "Retained element should persist in topElements")
  luaunit.assertEquals(FlexLove.topElements[1], retainedElement, "Should be same retained element")

  FlexLove.endFrame()
end

-- Test 5: Mixed top-level elements (immediate and retained)
function TestMixedModeChildren:testMixedTopLevelElements()
  FlexLove.beginFrame()

  local immediateElement1 = FlexLove.new({
    id = "immediate1",
    mode = "immediate",
    width = 100,
    height = 100,
  })

  local retainedElement = FlexLove.new({
    id = "retained",
    mode = "retained",
    width = 100,
    height = 100,
  })

  luaunit.assertEquals(#FlexLove.topElements, 2, "Should have 2 top-level elements")

  FlexLove.endFrame()

  -- Frame 2
  FlexLove.beginFrame()

  local immediateElement2 = FlexLove.new({
    id = "immediate2",
    mode = "immediate",
    width = 100,
    height = 100,
  })

  -- Should have retained element + new immediate element
  luaunit.assertEquals(#FlexLove.topElements, 2, "Should have 2 top-level elements")

  -- Find retained element in topElements
  local foundRetained = false
  for _, elem in ipairs(FlexLove.topElements) do
    if elem == retainedElement then
      foundRetained = true
      break
    end
  end

  luaunit.assertTrue(foundRetained, "Retained element should still be in topElements")

  FlexLove.endFrame()
end

-- Test 6: Retained child cleanup on parent destroy
function TestMixedModeChildren:testRetainedChildCleanupOnDestroy()
  FlexLove.beginFrame()

  local parent = FlexLove.new({
    id = "parent",
    mode = "immediate",
    width = 200,
    height = 200,
  })

  local retainedChild = FlexLove.new({
    id = "retained_child",
    mode = "retained",
    width = 50,
    height = 50,
  })

  parent:addChild(retainedChild)

  FlexLove.endFrame()

  -- Destroy parent (simulating explicit cleanup)
  parent:destroy()

  -- Frame 2: Create new parent with same ID
  FlexLove.beginFrame()

  local parent2 = FlexLove.new({
    id = "parent",
    mode = "immediate",
    width = 200,
    height = 200,
  })

  -- Since parent was destroyed, retained children should be cleared
  luaunit.assertEquals(#parent2.children, 0, "Parent should have no children after destroy")

  FlexLove.endFrame()
end

-- Test 7: Nested mixed-mode tree (immediate -> retained -> immediate)
function TestMixedModeChildren:testNestedMixedModeTree()
  FlexLove.beginFrame()

  local immediateParent = FlexLove.new({
    id = "immediate_parent",
    mode = "immediate",
    width = 300,
    height = 300,
  })

  local retainedMiddle = FlexLove.new({
    id = "retained_middle",
    mode = "retained",
    width = 200,
    height = 200,
  })

  local immediateGrandchild = FlexLove.new({
    id = "immediate_grandchild",
    mode = "immediate",
    width = 100,
    height = 100,
  })

  immediateParent:addChild(retainedMiddle)
  retainedMiddle:addChild(immediateGrandchild)

  luaunit.assertEquals(#immediateParent.children, 1, "Immediate parent should have 1 child")
  luaunit.assertEquals(#retainedMiddle.children, 1, "Retained middle should have 1 child")

  FlexLove.endFrame()

  -- Frame 2: Recreate immediate parent
  FlexLove.beginFrame()

  local immediateParent2 = FlexLove.new({
    id = "immediate_parent",
    mode = "immediate",
    width = 300,
    height = 300,
  })

  -- Retained middle should persist
  luaunit.assertEquals(#immediateParent2.children, 1, "Immediate parent should still have retained child")
  luaunit.assertEquals(immediateParent2.children[1], retainedMiddle, "Retained middle should persist")

  -- Immediate grandchild should also persist (as child of retained middle)
  luaunit.assertEquals(#retainedMiddle.children, 1, "Retained middle should still have its child")

  FlexLove.endFrame()
end

-- Test 8: Prevent duplicate creation of retained children
function TestMixedModeChildren:testPreventDuplicateRetainedChildren()
  FlexLove.beginFrame()

  -- Frame 1: Create immediate parent with retained child
  local parent1 = FlexLove.new({
    id = "parent",
    mode = "immediate",
    width = 200,
    height = 200,
  })

  local retainedChild = FlexLove.new({
    id = "unique_child",
    mode = "retained",
    parent = parent1,
    width = 50,
    height = 50,
  })

  luaunit.assertEquals(#parent1.children, 1, "Parent should have 1 child")
  local originalChild = parent1.children[1]

  FlexLove.endFrame()

  -- Frame 2: Recreate parent and try to create child again
  FlexLove.beginFrame()

  local parent2 = FlexLove.new({
    id = "parent",
    mode = "immediate",
    width = 200,
    height = 200,
  })

  -- Try to create the same retained child again
  local duplicateAttempt = FlexLove.new({
    id = "unique_child",
    mode = "retained",
    parent = parent2,
    width = 50,
    height = 50,
  })

  -- Should return the existing child, not create a new one
  luaunit.assertEquals(duplicateAttempt, originalChild, "Should return existing child instead of creating duplicate")
  luaunit.assertEquals(duplicateAttempt, retainedChild, "Should be the same retained child instance")
  luaunit.assertEquals(#parent2.children, 1, "Parent should still have only 1 child")

  FlexLove.endFrame()
end

-- Run tests
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
