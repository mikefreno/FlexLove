local luaunit = require("testing.luaunit")
require("testing.loveStub")

local FlexLove = require("FlexLove")
local Performance = require("modules.Performance")
local Element = FlexLove.Element

TestPerformanceWarnings = {}

function TestPerformanceWarnings:setUp()
  -- Enable performance warnings
  Performance.setConfig("warningsEnabled", true)
  Performance.resetShownWarnings()
end

function TestPerformanceWarnings:tearDown()
  -- Reset warnings
  Performance.resetShownWarnings()
end

-- Test hierarchy depth warning
function TestPerformanceWarnings:testHierarchyDepthWarning()
  -- Create a deep hierarchy (20 levels)
  local root = Element.new({
    id = "root",
    width = 100,
    height = 100,
  }, Element.defaultDependencies)

  local current = root
  for i = 1, 20 do
    local child = Element.new({
      id = "child_" .. i,
      width = 50,
      height = 50,
      parent = current,
    }, Element.defaultDependencies)
    table.insert(current.children, child)
    current = child
  end

  -- This should trigger a hierarchy depth warning
  root:layoutChildren()

  -- Check that element was created successfully despite warning
  luaunit.assertNotNil(current)
  luaunit.assertEquals(current:getHierarchyDepth(), 20)
end

-- Test element count warning
function TestPerformanceWarnings:testElementCountWarning()
  -- Create a container with many children (simulating 1000+ elements)
  local root = Element.new({
    id = "root",
    width = 1000,
    height = 1000,
  }, Element.defaultDependencies)

  -- Add many child elements
  for i = 1, 50 do -- Keep test fast, just verify the counting logic works
    local child = Element.new({
      id = "child_" .. i,
      width = 20,
      height = 20,
      parent = root,
    }, Element.defaultDependencies)
    table.insert(root.children, child)
  end

  local count = root:countElements()
  luaunit.assertEquals(count, 51) -- root + 50 children
end

-- Test animation count warning
function TestPerformanceWarnings:testAnimationTracking()
  local root = Element.new({
    id = "root",
    width = 100,
    height = 100,
  }, Element.defaultDependencies)

  -- Add some animated children
  for i = 1, 3 do
    local child = Element.new({
      id = "animated_child_" .. i,
      width = 20,
      height = 20,
      parent = root,
    }, Element.defaultDependencies)

    -- Add mock animation
    child.animation = {
      update = function()
        return false
      end,
      interpolate = function()
        return { width = 20, height = 20 }
      end,
    }

    table.insert(root.children, child)
  end

  local animCount = root:_countActiveAnimations()
  luaunit.assertEquals(animCount, 3)
end

-- Test warnings can be disabled
function TestPerformanceWarnings:testWarningsCanBeDisabled()
  Performance.setConfig("warningsEnabled", false)

  -- Create deep hierarchy
  local root = Element.new({
    id = "root",
    width = 100,
    height = 100,
  }, Element.defaultDependencies)

  local current = root
  for i = 1, 20 do
    local child = Element.new({
      id = "child_" .. i,
      width = 50,
      height = 50,
      parent = current,
    }, Element.defaultDependencies)
    table.insert(current.children, child)
    current = child
  end

  -- Should not trigger warning (but should still create elements)
  root:layoutChildren()
  luaunit.assertEquals(current:getHierarchyDepth(), 20)

  -- Re-enable for other tests
  Performance.setConfig("warningsEnabled", true)
end

-- Test layout recalculation tracking
function TestPerformanceWarnings:testLayoutRecalculationTracking()
  local root = Element.new({
    id = "root",
    width = 100,
    height = 100,
  }, Element.defaultDependencies)

  -- Layout multiple times (simulating layout thrashing)
  for i = 1, 5 do
    root:layoutChildren()
  end

  -- Should complete without crashing
  luaunit.assertNotNil(root)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
