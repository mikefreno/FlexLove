package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums
local Positioning = enums.Positioning
local FlexDirection = enums.FlexDirection
local JustifyContent = enums.JustifyContent
local AlignItems = enums.AlignItems
local FlexWrap = enums.FlexWrap

-- Create test cases for performance testing
TestPerformance = {}

function TestPerformance:setUp()
  -- Clean up before each test
  Gui.destroy()
end

function TestPerformance:tearDown()
  -- Clean up after each test
  Gui.destroy()
end

-- Helper function to measure execution time
local function measureTime(func)
  local start_time = os.clock()
  local result = func()
  local end_time = os.clock()
  return end_time - start_time, result
end

-- Helper function to create test containers
local function createTestContainer(props)
  props = props or {}
  local defaults = {
    x = 0,
    y = 0,
    w = 800,
    h = 600,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    flexWrap = FlexWrap.NOWRAP,
    gap = 0,
  }
  
  for key, value in pairs(props) do
    defaults[key] = value
  end
  
  return Gui.new(defaults)
end

-- Helper function to create many children
local function createManyChildren(parent, count, child_props)
  child_props = child_props or {}
  local children = {}
  
  for i = 1, count do
    local props = {
      w = child_props.w or 50,
      h = child_props.h or 30,
    }
    
    -- Add any additional properties
    for key, value in pairs(child_props) do
      if key ~= "w" and key ~= "h" then
        props[key] = value
      end
    end
    
    local child = Gui.new(props)
    child.parent = parent
    table.insert(parent.children, child)
    table.insert(children, child)
  end
  
  return children
end

-- Test 1: Basic Layout Performance Benchmark
function TestPerformance:testBasicLayoutPerformanceBenchmark()
  local container = createTestContainer()
  
  -- Test with small number of children (baseline)
  local children_10 = createManyChildren(container, 10)
  local time_10, _ = measureTime(function()
    container:layoutChildren()
  end)
  
  -- Clear and test with medium number of children
  container.children = {}
  local children_50 = createManyChildren(container, 50)
  local time_50, _ = measureTime(function()
    container:layoutChildren()
  end)
  
  -- Clear and test with larger number of children
  container.children = {}
  local children_100 = createManyChildren(container, 100)
  local time_100, _ = measureTime(function()
    container:layoutChildren()
  end)
  
  print(string.format("Performance Benchmark:"))
  print(string.format("  10 children: %.6f seconds", time_10))
  print(string.format("  50 children: %.6f seconds", time_50))
  print(string.format("  100 children: %.6f seconds", time_100))
  
  -- Assert reasonable performance (should complete within 1 second)
  luaunit.assertTrue(time_10 < 1.0, "10 children layout should complete within 1 second")
  luaunit.assertTrue(time_50 < 1.0, "50 children layout should complete within 1 second")
  luaunit.assertTrue(time_100 < 1.0, "100 children layout should complete within 1 second")
  
  -- Performance should scale reasonably (not exponentially)
  -- Allow some overhead but ensure it's not exponential growth
  luaunit.assertTrue(time_100 <= time_10 * 50, "Performance should not degrade exponentially")
end

-- Test 2: Scalability Testing with Large Numbers
function TestPerformance:testScalabilityWithLargeNumbers()
  local container = createTestContainer()
  
  -- Test progressively larger numbers of children
  local test_sizes = {10, 50, 100, 200}
  local times = {}
  
  for _, size in ipairs(test_sizes) do
    container.children = {} -- Clear previous children
    local children = createManyChildren(container, size)
    
    local time, _ = measureTime(function()
      container:layoutChildren()
    end)
    
    times[size] = time
    print(string.format("Scalability Test - %d children: %.6f seconds", size, time))
    
    -- Each test should complete within reasonable time
    luaunit.assertTrue(time < 2.0, string.format("%d children should layout within 2 seconds", size))
  end
  
  -- Check that performance scales linearly or sub-linearly
  -- Time for 200 children should not be more than 20x time for 10 children
  luaunit.assertTrue(times[200] <= times[10] * 20, "Performance should scale sub-linearly")
end

-- Test 3: Complex Nested Layout Performance
function TestPerformance:testComplexNestedLayoutPerformance()
  -- Create a deeply nested structure with multiple levels
  local root = createTestContainer({
    w = 1000,
    h = 800,
    flexDirection = FlexDirection.VERTICAL,
  })
  
  local time, _ = measureTime(function()
    -- Level 1: 5 sections
    for i = 1, 5 do
      local section = Gui.new({
        w = 950,
        h = 150,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
      })
      section.parent = root
      table.insert(root.children, section)
      
      -- Level 2: 4 columns per section
      for j = 1, 4 do
        local column = Gui.new({
          w = 200,
          h = 140,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.VERTICAL,
          alignItems = AlignItems.CENTER,
        })
        column.parent = section
        table.insert(section.children, column)
        
        -- Level 3: 3 items per column
        for k = 1, 3 do
          local item = Gui.new({
            w = 180,
            h = 40,
          })
          item.parent = column
          table.insert(column.children, item)
        end
      end
    end
    
    -- Layout the entire structure
    root:layoutChildren()
  end)
  
  print(string.format("Complex Nested Layout (5x4x3 = 60 total elements): %.6f seconds", time))
  
  -- Complex nested layout should complete within reasonable time
  luaunit.assertTrue(time < 3.0, "Complex nested layout should complete within 3 seconds")
  
  -- Verify structure was created correctly
  luaunit.assertEquals(#root.children, 5) -- 5 sections
  luaunit.assertEquals(#root.children[1].children, 4) -- 4 columns per section
  luaunit.assertEquals(#root.children[1].children[1].children, 3) -- 3 items per column
end

-- Test 4: Flex Wrap Performance with Many Elements
function TestPerformance:testFlexWrapPerformanceWithManyElements()
  local container = createTestContainer({
    w = 400,
    h = 600,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.SPACE_AROUND,
    alignItems = AlignItems.CENTER,
  })
  
  -- Create many children that will wrap
  local children = createManyChildren(container, 50, {
    w = 80,
    h = 50,
  })
  
  local time, _ = measureTime(function()
    container:layoutChildren()
  end)
  
  print(string.format("Flex Wrap Performance (50 wrapping elements): %.6f seconds", time))
  
  -- Flex wrap with many elements should complete within reasonable time
  luaunit.assertTrue(time < 2.0, "Flex wrap layout should complete within 2 seconds")
  
  -- Verify that elements are positioned (wrapped layout worked)
  luaunit.assertTrue(children[1].x >= 0 and children[1].y >= 0, "First child should be positioned")
  luaunit.assertTrue(children[#children].x >= 0 and children[#children].y >= 0, "Last child should be positioned")
end

-- Test 5: Dynamic Layout Change Performance
function TestPerformance:testDynamicLayoutChangePerformance()
  local container = createTestContainer()
  local children = createManyChildren(container, 30)
  
  -- Initial layout
  container:layoutChildren()
  
  -- Test performance of multiple layout property changes
  local time, _ = measureTime(function()
    for i = 1, 10 do
      -- Change flex direction
      container.flexDirection = (i % 2 == 0) and FlexDirection.VERTICAL or FlexDirection.HORIZONTAL
      container:layoutChildren()
      
      -- Change justify content
      container.justifyContent = (i % 3 == 0) and JustifyContent.CENTER or JustifyContent.FLEX_START
      container:layoutChildren()
      
      -- Change align items
      container.alignItems = (i % 4 == 0) and AlignItems.CENTER or AlignItems.STRETCH
      container:layoutChildren()
    end
  end)
  
  print(string.format("Dynamic Layout Changes (30 relayouts): %.6f seconds", time))
  
  -- Dynamic layout changes should complete within reasonable time
  luaunit.assertTrue(time < 2.0, "Dynamic layout changes should complete within 2 seconds")
  
  -- Verify final layout is valid
  luaunit.assertTrue(children[1].x >= 0 and children[1].y >= 0, "Children should be positioned after changes")
end

-- Test 6: Memory Usage Pattern Test
function TestPerformance:testMemoryUsagePattern()
  -- This test checks that we don't have obvious memory leaks during layout operations
  local container = createTestContainer()
  
  -- Create and destroy many children multiple times
  local time, _ = measureTime(function()
    for cycle = 1, 5 do
      -- Create children
      local children = createManyChildren(container, 100)
      container:layoutChildren()
      
      -- Clear children (simulating component cleanup)
      container.children = {}
      
      -- Force garbage collection to test for leaks
      collectgarbage("collect")
    end
  end)
  
  print(string.format("Memory Usage Pattern Test (5 cycles, 100 elements each): %.6f seconds", time))
  
  -- Memory pattern test should complete within reasonable time
  luaunit.assertTrue(time < 3.0, "Memory usage pattern test should complete within 3 seconds")
  
  -- Verify container is clean after cycles
  luaunit.assertEquals(#container.children, 0, "Container should be clean after memory test")
end

-- Test 7: Performance with Different Layout Strategies
function TestPerformance:testPerformanceWithDifferentLayoutStrategies()
  local strategies = {
    {
      name = "Simple Horizontal",
      props = {
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.FLEX_START,
        alignItems = AlignItems.STRETCH,
      }
    },
    {
      name = "Centered Vertical",
      props = {
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.CENTER,
        alignItems = AlignItems.CENTER,
      }
    },
    {
      name = "Wrapped Space-Between",
      props = {
        flexDirection = FlexDirection.HORIZONTAL,
        flexWrap = FlexWrap.WRAP,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        alignItems = AlignItems.FLEX_START,
      }
    },
  }
  
  local times = {}
  
  for _, strategy in ipairs(strategies) do
    local container = createTestContainer(strategy.props)
    local children = createManyChildren(container, 40)
    
    local time, _ = measureTime(function()
      container:layoutChildren()
    end)
    
    times[strategy.name] = time
    print(string.format("Layout Strategy '%s': %.6f seconds", strategy.name, time))
    
    -- Each strategy should complete within reasonable time
    luaunit.assertTrue(time < 1.0, string.format("'%s' layout should complete within 1 second", strategy.name))
  end
  
  -- All strategies should perform reasonably similarly
  -- None should be more than 10x slower than the fastest
  local min_time = math.huge
  local max_time = 0
  
  for _, time in pairs(times) do
    min_time = math.min(min_time, time)
    max_time = math.max(max_time, time)
  end
  
  luaunit.assertTrue(max_time <= min_time * 10, "Layout strategies should have similar performance characteristics")
end

-- Test 8: Stress Test with Maximum Elements
function TestPerformance:testStressTestWithMaximumElements()
  local container = createTestContainer({
    w = 1200,
    h = 900,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
  })
  
  -- Create a large number of children for stress testing
  local stress_count = 300
  local children = createManyChildren(container, stress_count, {
    w = 30,
    h = 20,
  })
  
  local time, _ = measureTime(function()
    container:layoutChildren()
  end)
  
  print(string.format("Stress Test (%d elements): %.6f seconds", stress_count, time))
  
  -- Stress test should complete within reasonable time even with many elements
  luaunit.assertTrue(time < 5.0, string.format("Stress test with %d elements should complete within 5 seconds", stress_count))
  
  -- Verify that all children are positioned
  local positioned_count = 0
  for _, child in ipairs(children) do
    if child.x >= 0 and child.y >= 0 then
      positioned_count = positioned_count + 1
    end
  end
  
  luaunit.assertEquals(positioned_count, stress_count, "All children should be positioned in stress test")
end

-- Run the tests
print("=== Running Performance Tests ===")
luaunit.LuaUnit.run()

return TestPerformance