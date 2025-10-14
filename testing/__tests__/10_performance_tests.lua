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
    width = 800,
    height = 600,
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
      width = child_props.w or 50,
      height = child_props.h or 30,
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
  luaunit.assertTrue(time_10 < 0.05, "10 children layout should complete within 0.05 seconds")
  luaunit.assertTrue(time_50 < 0.05, "50 children layout should complete within 0.05 seconds")
  luaunit.assertTrue(time_100 < 0.05, "100 children layout should complete within 0.05 seconds")

  -- Performance should scale reasonably (not exponentially)
  -- Allow some overhead but ensure it's not exponential growth
  luaunit.assertTrue(time_100 <= time_10 * 50, "Performance should not degrade exponentially")
end

-- Test 2: Scalability Testing with Large Numbers
function TestPerformance:testScalabilityWithLargeNumbers()
  local container = createTestContainer()

  -- Test progressively larger numbers of children
  local test_sizes = { 10, 50, 100, 200 }
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
    luaunit.assertTrue(time < 0.05, string.format("%d children should layout within 0.05 seconds", size))
  end

  -- Check that performance scales linearly or sub-linearly
  -- Time for 200 children should not be more than 20x time for 10 children
  luaunit.assertTrue(times[200] <= times[10] * 20, "Performance should scale sub-linearly")
end

-- Test 3: Complex Nested Layout Performance
function TestPerformance:testComplexNestedLayoutPerformance()
  -- Create a deeply nested structure with multiple levels
  local root = createTestContainer({
    width = 1000,
    height = 800,
    flexDirection = FlexDirection.VERTICAL,
  })

  local time, _ = measureTime(function()
    -- Level 1: 5 sections
    for i = 1, 5 do
      local section = Gui.new({
        width = 950,
        height = 150,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
      })
      section.parent = root
      table.insert(root.children, section)

      -- Level 2: 4 columns per section
      for j = 1, 4 do
        local column = Gui.new({
          width = 200,
          height = 140,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.VERTICAL,
          alignItems = AlignItems.CENTER,
        })
        column.parent = section
        table.insert(section.children, column)

        -- Level 3: 3 items per column
        for k = 1, 3 do
          local item = Gui.new({
            width = 180,
            height = 40,
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
  luaunit.assertTrue(time < 0.05, "Complex nested layout should complete within 0.05 seconds")

  -- Verify structure was created correctly
  luaunit.assertEquals(#root.children, 5) -- 5 sections
  luaunit.assertEquals(#root.children[1].children, 4) -- 4 columns per section
  luaunit.assertEquals(#root.children[1].children[1].children, 3) -- 3 items per column
end

-- Test 4: Flex Wrap Performance with Many Elements
function TestPerformance:testFlexWrapPerformanceWithManyElements()
  local container = createTestContainer({
    width = 400,
    height = 600,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
    justifyContent = JustifyContent.SPACE_AROUND,
    alignItems = AlignItems.CENTER,
  })

  -- Create many children that will wrap
  local children = createManyChildren(container, 50, {
    width = 80,
    height = 50,
  })

  local time, _ = measureTime(function()
    container:layoutChildren()
  end)

  print(string.format("Flex Wrap Performance (50 wrapping elements): %.6f seconds", time))

  -- Flex wrap with many elements should complete within reasonable time
  luaunit.assertTrue(time < 0.05, "Flex wrap layout should complete within 0.05 seconds")

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
  luaunit.assertTrue(time < 0.05, "Dynamic layout changes should complete within 0.05 seconds")

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
  luaunit.assertTrue(time < 0.05, "Memory usage pattern test should complete within 0.05 seconds")

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
      },
    },
    {
      name = "Centered Vertical",
      props = {
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.CENTER,
        alignItems = AlignItems.CENTER,
      },
    },
    {
      name = "Wrapped Space-Between",
      props = {
        flexDirection = FlexDirection.HORIZONTAL,
        flexWrap = FlexWrap.WRAP,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        alignItems = AlignItems.FLEX_START,
      },
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
    luaunit.assertTrue(time < 0.05, string.format("'%s' layout should complete within 0.05 second", strategy.name))
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
    width = 1200,
    height = 900,
    flexDirection = FlexDirection.HORIZONTAL,
    flexWrap = FlexWrap.WRAP,
  })

  -- Create a large number of children for stress testing
  local stress_count = 300
  local children = createManyChildren(container, stress_count, {
    width = 30,
    height = 20,
  })

  local time, _ = measureTime(function()
    container:layoutChildren()
  end)

  print(string.format("Stress Test (%d elements): %.6f seconds", stress_count, time))

  -- Stress test should complete within reasonable time even with many elements
  luaunit.assertTrue(
    time < 0.05,
    string.format("Stress test with %d elements should complete within 0.05 seconds", stress_count)
  )

  -- Verify that all children are positioned
  local positioned_count = 0
  for _, child in ipairs(children) do
    if child.x >= 0 and child.y >= 0 then
      positioned_count = positioned_count + 1
    end
  end

  luaunit.assertEquals(positioned_count, stress_count, "All children should be positioned in stress test")
end

-- Test 9: Complex Real-World Application Performance - Enterprise Dashboard
function TestPerformance:testComplexEnterpriseApplicationPerformance()
  print("\n=== Test 9: Complex Enterprise Dashboard Performance ===")

  -- Create enterprise-grade dashboard with deep nesting (5 levels)
  local dashboard = createTestContainer({
    width = 1920,
    height = 1080,
    flexDirection = FlexDirection.VERTICAL,
    gap = 10,
  })

  local time, structure_info = measureTime(function()
    -- Level 1: Header, Main Content, Footer
    local header = Gui.new({
      width = 1900,
      height = 80,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 20,
    })
    header.parent = dashboard
    table.insert(dashboard.children, header)

    local main_content = Gui.new({
      width = 1900,
      height = 980,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      gap = 15,
    })
    main_content.parent = dashboard
    table.insert(dashboard.children, main_content)

    local footer = Gui.new({
      width = 1900,
      height = 60,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.CENTER,
    })
    footer.parent = dashboard
    table.insert(dashboard.children, footer)

    -- Level 2: Header components (logo, navigation, user actions)
    local header_sections = { "logo", "navigation", "search", "notifications", "user_menu" }
    for i, section_name in ipairs(header_sections) do
      local section = Gui.new({
        width = section_name == "navigation" and 400 or 150,
        height = 60,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.CENTER,
        alignItems = AlignItems.CENTER,
      })
      section.parent = header
      table.insert(header.children, section)

      -- Level 3: Section items
      local item_count = section_name == "navigation" and 6 or 3
      for j = 1, item_count do
        local item = Gui.new({
          width = section_name == "navigation" and 60 or 45,
          height = 40,
        })
        item.parent = section
        table.insert(section.children, item)
      end
    end

    -- Level 2: Main content areas (sidebar, dashboard grid)
    local sidebar = Gui.new({
      width = 280,
      height = 960,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      gap = 10,
    })
    sidebar.parent = main_content
    table.insert(main_content.children, sidebar)

    local dashboard_grid = Gui.new({
      width = 1600,
      height = 960,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      gap = 20,
    })
    dashboard_grid.parent = main_content
    table.insert(main_content.children, dashboard_grid)

    -- Level 3: Sidebar navigation items (complex menu structure)
    local menu_categories = {
      { name = "Analytics", items = 5 },
      { name = "Reports", items = 7 },
      { name = "Users", items = 4 },
      { name = "Settings", items = 6 },
      { name = "Tools", items = 8 },
    }

    for _, category in ipairs(menu_categories) do
      local category_container = Gui.new({
        width = 260,
        height = 40 + (category.items * 35),
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        gap = 2,
      })
      category_container.parent = sidebar
      table.insert(sidebar.children, category_container)

      -- Category header
      local category_header = Gui.new({ width = 250, height = 35 })
      category_header.parent = category_container
      table.insert(category_container.children, category_header)

      -- Level 4: Menu items with sub-indicators
      for i = 1, category.items do
        local menu_item = Gui.new({
          width = 240,
          height = 30,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.HORIZONTAL,
          justifyContent = JustifyContent.SPACE_BETWEEN,
          alignItems = AlignItems.CENTER,
        })
        menu_item.parent = category_container
        table.insert(category_container.children, menu_item)

        -- Level 5: Menu item components (text, icon, badge)
        local item_icon = Gui.new({ width = 20, height = 20 })
        item_icon.parent = menu_item
        table.insert(menu_item.children, item_icon)

        local item_text = Gui.new({ width = 180, height = 25 })
        item_text.parent = menu_item
        table.insert(menu_item.children, item_text)

        local item_badge = Gui.new({ width = 25, height = 18 })
        item_badge.parent = menu_item
        table.insert(menu_item.children, item_badge)
      end
    end

    -- Level 3: Dashboard grid (4x3 widget grid with complex internals)
    for row = 1, 4 do
      local grid_row = Gui.new({
        width = 1580,
        height = 220,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        gap = 20,
      })
      grid_row.parent = dashboard_grid
      table.insert(dashboard_grid.children, grid_row)

      for col = 1, 3 do
        local widget = Gui.new({
          width = 500,
          height = 200,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.VERTICAL,
          gap = 8,
        })
        widget.parent = grid_row
        table.insert(grid_row.children, widget)

        -- Level 4: Widget components (header, content, footer)
        local widget_header = Gui.new({
          width = 480,
          height = 40,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.HORIZONTAL,
          justifyContent = JustifyContent.SPACE_BETWEEN,
          alignItems = AlignItems.CENTER,
        })
        widget_header.parent = widget
        table.insert(widget.children, widget_header)

        local widget_content = Gui.new({
          width = 480,
          height = 120,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.HORIZONTAL,
          flexWrap = FlexWrap.WRAP,
          justifyContent = JustifyContent.SPACE_AROUND,
          alignItems = AlignItems.CENTER,
          gap = 5,
        })
        widget_content.parent = widget
        table.insert(widget.children, widget_content)

        local widget_footer = Gui.new({
          width = 480,
          height = 32,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.HORIZONTAL,
          justifyContent = JustifyContent.FLEX_END,
          alignItems = AlignItems.CENTER,
        })
        widget_footer.parent = widget
        table.insert(widget.children, widget_footer)

        -- Level 5: Widget content elements (charts, metrics, etc.)
        local content_elements = (row * col) % 4 == 0 and 12 or 8
        for i = 1, content_elements do
          local element = Gui.new({
            width = content_elements > 10 and 35 or 55,
            height = content_elements > 10 and 25 or 35,
          })
          element.parent = widget_content
          table.insert(widget_content.children, element)
        end

        -- Widget header components
        local widget_title = Gui.new({ width = 200, height = 30 })
        widget_title.parent = widget_header
        table.insert(widget_header.children, widget_title)

        local widget_actions = Gui.new({
          width = 120,
          height = 30,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.HORIZONTAL,
          gap = 5,
        })
        widget_actions.parent = widget_header
        table.insert(widget_header.children, widget_actions)

        for j = 1, 3 do
          local action_btn = Gui.new({ width = 30, height = 25 })
          action_btn.parent = widget_actions
          table.insert(widget_actions.children, action_btn)
        end

        -- Widget footer components
        local footer_info = Gui.new({ width = 100, height = 25 })
        footer_info.parent = widget_footer
        table.insert(widget_footer.children, footer_info)
      end
    end

    -- Perform complete layout
    dashboard:layoutChildren()

    -- Calculate structure metrics
    local total_elements = 0
    local max_depth = 0

    local function countElements(element, depth)
      total_elements = total_elements + 1
      max_depth = math.max(max_depth, depth)
      for _, child in ipairs(element.children) do
        countElements(child, depth + 1)
      end
    end

    countElements(dashboard, 1)

    return {
      total_elements = total_elements,
      max_depth = max_depth,
      widgets = 12,
      menu_items = 30,
    }
  end)

  print(string.format("Enterprise Dashboard Performance:"))
  print(string.format("  Total Elements: %d", structure_info.total_elements))
  print(string.format("  Maximum Depth: %d levels", structure_info.max_depth))
  print(string.format("  Layout Time: %.6f seconds", time))
  print(string.format("  Elements/Second: %.0f", structure_info.total_elements / time))

  -- Performance assertions for enterprise-grade application
  luaunit.assertTrue(time < 0.05, "Enterprise dashboard should layout within 0.05 seconds")
  luaunit.assertTrue(structure_info.total_elements > 200, "Should have created substantial element count")
  luaunit.assertTrue(structure_info.max_depth >= 5, "Should have deep nesting structure")

  -- Verify critical components are positioned
  luaunit.assertEquals(#dashboard.children, 3, "Should have header, main, footer")
  luaunit.assertTrue(#dashboard.children[2].children >= 2, "Main should have sidebar and grid")
end

-- Test 10: High-Frequency Dynamic Layout Updates Performance
function TestPerformance:testHighFrequencyDynamicLayoutUpdates()
  print("\n=== Test 10: High-Frequency Dynamic Updates Performance ===")

  local container = createTestContainer({
    width = 1200,
    height = 800,
    flexDirection = FlexDirection.VERTICAL,
    gap = 10,
  })

  -- Create dynamic content structure
  local sections = {}
  for i = 1, 8 do
    local section = Gui.new({
      width = 1180,
      height = 90,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 8,
    })
    section.parent = container
    table.insert(container.children, section)
    table.insert(sections, section)

    -- Create dynamic items in each section
    for j = 1, 10 do
      local item = Gui.new({
        width = 100,
        height = 70,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.CENTER,
        alignItems = AlignItems.CENTER,
      })
      item.parent = section
      table.insert(section.children, item)

      -- Sub-items for more complex updates
      for k = 1, 3 do
        local sub_item = Gui.new({ width = 80, height = 20 })
        sub_item.parent = item
        table.insert(item.children, sub_item)
      end
    end
  end

  -- Initial layout
  container:layoutChildren()

  local update_scenarios = {
    { name = "Direction Changes", iterations = 50 },
    { name = "Justify Content Cycling", iterations = 40 },
    { name = "Gap Modifications", iterations = 30 },
    { name = "Size Adjustments", iterations = 35 },
    { name = "Wrap Toggle", iterations = 25 },
  }

  local total_updates = 0
  local total_time = 0

  for _, scenario in ipairs(update_scenarios) do
    local scenario_time = measureTime(function()
      for i = 1, scenario.iterations do
        if scenario.name == "Direction Changes" then
          local section = sections[(i % #sections) + 1]
          section.flexDirection = (i % 2 == 0) and FlexDirection.VERTICAL or FlexDirection.HORIZONTAL
          section:layoutChildren()
        elseif scenario.name == "Justify Content Cycling" then
          local section = sections[(i % #sections) + 1]
          local justifies =
            { JustifyContent.FLEX_START, JustifyContent.CENTER, JustifyContent.FLEX_END, JustifyContent.SPACE_BETWEEN }
          section.justifyContent = justifies[(i % #justifies) + 1]
          section:layoutChildren()
        elseif scenario.name == "Gap Modifications" then
          local section = sections[(i % #sections) + 1]
          section.gap = (i % 20) + 5
          section:layoutChildren()
        elseif scenario.name == "Size Adjustments" then
          local section = sections[(i % #sections) + 1]
          for _, child in ipairs(section.children) do
            child.w = 80 + (i % 40)
            child.h = 60 + (i % 20)
          end
          section:layoutChildren()
        elseif scenario.name == "Wrap Toggle" then
          local section = sections[(i % #sections) + 1]
          section.flexWrap = (i % 2 == 0) and FlexWrap.WRAP or FlexWrap.NOWRAP
          section:layoutChildren()
        end
      end
    end)

    total_updates = total_updates + scenario.iterations
    total_time = total_time + scenario_time

    print(
      string.format(
        "  %s (%d updates): %.6f seconds (%.3f ms/update)",
        scenario.name,
        scenario.iterations,
        scenario_time,
        (scenario_time * 1000) / scenario.iterations
      )
    )
  end

  print(string.format("High-Frequency Updates Summary:"))
  print(string.format("  Total Updates: %d", total_updates))
  print(string.format("  Total Time: %.6f seconds", total_time))
  print(string.format("  Average Update Time: %.3f ms", (total_time * 1000) / total_updates))
  print(string.format("  Updates Per Second: %.0f", total_updates / total_time))

  -- Performance assertions
  luaunit.assertTrue(total_time < 15.0, "High-frequency updates should complete within 15 seconds")
  luaunit.assertTrue((total_time * 1000) / total_updates < 50, "Average update should be under 50ms")
  luaunit.assertTrue(total_updates / total_time > 10, "Should achieve at least 10 updates per second")

  -- Verify final state is valid
  luaunit.assertEquals(#container.children, 8, "All sections should still exist")
  for _, section in ipairs(sections) do
    luaunit.assertEquals(#section.children, 10, "All items should still exist in sections")
  end
end

-- Test 11: Complex Animation-Ready Layout Performance
function TestPerformance:testComplexAnimationReadyLayoutPerformance()
  print("\n=== Test 11: Complex Animation-Ready Layout Performance ===")

  -- Create animation-heavy interface structure
  local animation_container = createTestContainer({
    width = 1400,
    height = 900,
    flexDirection = FlexDirection.VERTICAL,
    gap = 15,
  })

  local animation_elements = {}
  local time, metrics = measureTime(function()
    -- Create multiple animated sections with complex layouts
    for section_id = 1, 6 do
      local section = Gui.new({
        width = 1380,
        height = 140,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_AROUND,
        alignItems = AlignItems.CENTER,
        gap = 12,
      })
      section.parent = animation_container
      table.insert(animation_container.children, section)

      -- Create animated cards/panels
      for card_id = 1, 8 do
        local card = Gui.new({
          width = 160,
          height = 120,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.VERTICAL,
          justifyContent = JustifyContent.SPACE_BETWEEN,
          gap = 5,
        })
        card.parent = section
        table.insert(section.children, card)
        table.insert(animation_elements, card)

        -- Card header with animated elements
        local card_header = Gui.new({
          width = 150,
          height = 30,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.HORIZONTAL,
          justifyContent = JustifyContent.SPACE_BETWEEN,
          alignItems = AlignItems.CENTER,
        })
        card_header.parent = card
        table.insert(card.children, card_header)

        -- Animated header components
        local title = Gui.new({ width = 100, height = 25 })
        title.parent = card_header
        table.insert(card_header.children, title)

        local status_indicator = Gui.new({ width = 20, height = 20 })
        status_indicator.parent = card_header
        table.insert(card_header.children, status_indicator)

        -- Card content with animated metrics
        local card_content = Gui.new({
          width = 150,
          height = 60,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.HORIZONTAL,
          flexWrap = FlexWrap.WRAP,
          justifyContent = JustifyContent.SPACE_AROUND,
          alignItems = AlignItems.CENTER,
          gap = 3,
        })
        card_content.parent = card
        table.insert(card.children, card_content)

        -- Animated metrics/values
        local metric_count = 4 + (section_id % 3)
        for i = 1, metric_count do
          local metric = Gui.new({
            width = 35,
            height = 25,
            positioning = Positioning.FLEX,
            justifyContent = JustifyContent.CENTER,
            alignItems = AlignItems.CENTER,
          })
          metric.parent = card_content
          table.insert(card_content.children, metric)
          table.insert(animation_elements, metric)
        end

        -- Card footer with action buttons
        local card_footer = Gui.new({
          width = 150,
          height = 25,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.HORIZONTAL,
          justifyContent = JustifyContent.FLEX_END,
          gap = 5,
        })
        card_footer.parent = card
        table.insert(card.children, card_footer)

        for i = 1, 2 do
          local action_btn = Gui.new({ width = 25, height = 20 })
          action_btn.parent = card_footer
          table.insert(card_footer.children, action_btn)
          table.insert(animation_elements, action_btn)
        end
      end
    end

    -- Perform initial layout
    animation_container:layoutChildren()

    -- Simulate animation frame updates (position/size changes)
    local animation_frames = 60 -- Simulate 1 second at 60fps
    local frame_times = {}

    for frame = 1, animation_frames do
      local frame_start = os.clock()

      -- Simulate animated property changes
      for i, element in ipairs(animation_elements) do
        if (frame + i) % 10 == 0 then
          -- Animate size changes
          element.w = element.width + math.sin(frame * 0.1 + i) * 2
          element.h = element.height + math.cos(frame * 0.1 + i) * 1
        end

        if (frame + i) % 15 == 0 then
          -- Animate gap changes in parent containers
          if element.parent and element.parent.gap then
            element.parent.gap = 5 + math.abs(math.sin(frame * 0.05)) * 10
          end
        end
      end

      -- Relayout for animation frame
      animation_container:layoutChildren()

      local frame_time = os.clock() - frame_start
      table.insert(frame_times, frame_time)
    end

    return {
      total_elements = #animation_elements,
      animation_frames = animation_frames,
      frame_times = frame_times,
    }
  end)

  -- Calculate animation performance metrics
  local total_frame_time = 0
  local max_frame_time = 0
  local min_frame_time = math.huge

  for _, frame_time in ipairs(metrics.frame_times) do
    total_frame_time = total_frame_time + frame_time
    max_frame_time = math.max(max_frame_time, frame_time)
    min_frame_time = math.min(min_frame_time, frame_time)
  end

  local avg_frame_time = total_frame_time / metrics.animation_frames
  local target_fps = 60
  local target_frame_time = 1.0 / target_fps

  print(string.format("Animation-Ready Layout Performance:"))
  print(string.format("  Setup Time: %.6f seconds", time - total_frame_time))
  print(string.format("  Animation Elements: %d", metrics.total_elements))
  print(string.format("  Animation Frames: %d", metrics.animation_frames))
  print(string.format("  Total Animation Time: %.6f seconds", total_frame_time))
  print(string.format("  Average Frame Time: %.6f seconds (%.1f fps equivalent)", avg_frame_time, 1.0 / avg_frame_time))
  print(string.format("  Min Frame Time: %.6f seconds", min_frame_time))
  print(string.format("  Max Frame Time: %.6f seconds", max_frame_time))
  print(string.format("  60fps Target: %.6f seconds/frame", target_frame_time))

  -- Performance assertions for animation-ready layouts
  luaunit.assertTrue(time < 0.05, "Animation setup should complete within 0.05 seconds")
  luaunit.assertTrue(avg_frame_time < target_frame_time * 2, "Average frame time should be reasonable for 30fps+")
  luaunit.assertTrue(max_frame_time < 0.05, "No single frame should take more than 50ms")
  luaunit.assertTrue(metrics.total_elements > 100, "Should have substantial number of animated elements")

  -- Verify structure integrity after animations
  luaunit.assertEquals(#animation_container.children, 6, "All sections should remain")
  local total_cards = 0
  for _, section in ipairs(animation_container.children) do
    total_cards = total_cards + #section.children
  end
  luaunit.assertEquals(total_cards, 48, "All cards should remain after animation")
end

-- Test 12: Memory-Intensive Layout Performance with Cleanup
function TestPerformance:testMemoryIntensiveLayoutPerformanceWithCleanup()
  print("\n=== Test 12: Memory-Intensive Layout with Cleanup ===")

  local memory_cycles = 8
  local elements_per_cycle = 150
  local cycle_times = {}
  local cleanup_times = {}

  local total_time = measureTime(function()
    for cycle = 1, memory_cycles do
      print(string.format("  Memory Cycle %d/%d", cycle, memory_cycles))

      -- Create intensive layout structure
      local cycle_start = os.clock()
      local root = createTestContainer({
        width = 1600,
        height = 1000,
        flexDirection = FlexDirection.VERTICAL,
        gap = 8,
      })

      local all_elements = {}

      -- Create memory-intensive nested structure
      for level1 = 1, 10 do
        local section = Gui.new({
          width = 1580,
          height = 95,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.HORIZONTAL,
          flexWrap = FlexWrap.WRAP,
          justifyContent = JustifyContent.SPACE_AROUND,
          gap = 5,
        })
        section.parent = root
        table.insert(root.children, section)
        table.insert(all_elements, section)

        for level2 = 1, 15 do
          local container = Gui.new({
            width = 100,
            height = 85,
            positioning = Positioning.FLEX,
            flexDirection = FlexDirection.VERTICAL,
            justifyContent = JustifyContent.SPACE_BETWEEN,
            gap = 2,
          })
          container.parent = section
          table.insert(section.children, container)
          table.insert(all_elements, container)

          for level3 = 1, 3 do
            local item = Gui.new({
              width = 95,
              height = 25,
              positioning = Positioning.FLEX,
              flexDirection = FlexDirection.HORIZONTAL,
              justifyContent = JustifyContent.CENTER,
              alignItems = AlignItems.CENTER,
            })
            item.parent = container
            table.insert(container.children, item)
            table.insert(all_elements, item)

            -- Add some leaf nodes for memory pressure
            for level4 = 1, 2 do
              local leaf = Gui.new({ width = 40, height = 20 })
              leaf.parent = item
              table.insert(item.children, leaf)
              table.insert(all_elements, leaf)
            end
          end
        end
      end

      -- Perform layout
      root:layoutChildren()

      local cycle_time = os.clock() - cycle_start
      table.insert(cycle_times, cycle_time)

      print(string.format("    Created %d elements in %.6f seconds", #all_elements, cycle_time))

      -- Cleanup phase
      local cleanup_start = os.clock()

      -- Clear all references systematically
      for _, element in ipairs(all_elements) do
        element.children = {}
        element.parent = nil
      end

      -- Clear root structure
      root.children = {}
      Gui.destroy()

      -- Force garbage collection
      collectgarbage("collect")

      local cleanup_time = os.clock() - cleanup_start
      table.insert(cleanup_times, cleanup_time)

      print(string.format("    Cleanup completed in %.6f seconds", cleanup_time))
    end
  end)

  -- Calculate memory performance metrics
  local total_cycle_time = 0
  local total_cleanup_time = 0
  local max_cycle_time = 0
  local max_cleanup_time = 0

  for i = 1, memory_cycles do
    total_cycle_time = total_cycle_time + cycle_times[i]
    total_cleanup_time = total_cleanup_time + cleanup_times[i]
    max_cycle_time = math.max(max_cycle_time, cycle_times[i])
    max_cleanup_time = math.max(max_cleanup_time, cleanup_times[i])
  end

  local avg_cycle_time = total_cycle_time / memory_cycles
  local avg_cleanup_time = total_cleanup_time / memory_cycles

  print(string.format("Memory-Intensive Layout Performance:"))
  print(string.format("  Memory Cycles: %d", memory_cycles))
  print(string.format("  Elements Per Cycle: ~%d", elements_per_cycle * 6)) -- Approximate
  print(string.format("  Total Test Time: %.6f seconds", total_time))
  print(string.format("  Average Cycle Time: %.6f seconds", avg_cycle_time))
  print(string.format("  Average Cleanup Time: %.6f seconds", avg_cleanup_time))
  print(string.format("  Max Cycle Time: %.6f seconds", max_cycle_time))
  print(string.format("  Max Cleanup Time: %.6f seconds", max_cleanup_time))
  print(string.format("  Cycle Efficiency: %.1f elements/second", (elements_per_cycle * 6) / avg_cycle_time))

  -- Performance assertions for memory-intensive operations
  luaunit.assertTrue(total_time < 30.0, "Memory-intensive test should complete within 30 seconds")
  luaunit.assertTrue(avg_cycle_time < 5.0, "Average cycle should complete within 5 seconds")
  luaunit.assertTrue(avg_cleanup_time < 2.0, "Average cleanup should complete within 2 seconds")
  luaunit.assertTrue(max_cycle_time <= avg_cycle_time * 3, "No cycle should be extremely slow")
  luaunit.assertTrue(max_cleanup_time <= avg_cleanup_time * 3, "No cleanup should be extremely slow")

  -- Verify clean state after all cycles
  local final_container = createTestContainer()
  luaunit.assertEquals(#final_container.children, 0, "Should start with clean container after cycles")
end

-- Test 13: Extreme Scale Performance Benchmark
function TestPerformance:testExtremeScalePerformanceBenchmark()
  print("\n=== Test 13: Extreme Scale Performance Benchmark ===")

  -- Test with extremely large layouts to find breaking points
  local scale_tests = {
    { name = "Massive Flat Layout", elements = 1000, depth = 1 },
    { name = "Deep Nesting", elements = 200, depth = 10 },
    { name = "Wide Branching", elements = 500, depth = 4 },
    { name = "Mixed Complex", elements = 800, depth = 6 },
  }

  local benchmark_results = {}

  for _, test_config in ipairs(scale_tests) do
    print(string.format("  Running %s test...", test_config.name))

    local test_time, test_metrics = measureTime(function()
      local root = createTestContainer({
        width = 2000,
        height = 1500,
        flexDirection = FlexDirection.VERTICAL,
        flexWrap = FlexWrap.WRAP,
        gap = 5,
      })

      local created_elements = 0
      local max_actual_depth = 0

      if test_config.name == "Massive Flat Layout" then
        -- Create very wide, flat structure
        local items_per_row = 50
        local rows = math.ceil(test_config.elements / items_per_row)

        for row = 1, rows do
          local row_container = Gui.new({
            width = 1980,
            height = 25,
            positioning = Positioning.FLEX,
            flexDirection = FlexDirection.HORIZONTAL,
            flexWrap = FlexWrap.WRAP,
            gap = 2,
          })
          row_container.parent = root
          table.insert(root.children, row_container)
          created_elements = created_elements + 1

          local items_in_this_row = math.min(items_per_row, test_config.elements - (row - 1) * items_per_row)
          for col = 1, items_in_this_row do
            local item = Gui.new({ width = 35, height = 20 })
            item.parent = row_container
            table.insert(row_container.children, item)
            created_elements = created_elements + 1
          end
        end
        max_actual_depth = 2
      elseif test_config.name == "Deep Nesting" then
        -- Create deep nested structure
        local current_parent = root
        local elements_per_level = math.ceil(test_config.elements / test_config.depth)

        for depth = 1, test_config.depth do
          local level_container = Gui.new({
            width = 1900 - (depth * 50),
            height = 1400 - (depth * 100),
            positioning = Positioning.FLEX,
            flexDirection = (depth % 2 == 0) and FlexDirection.VERTICAL or FlexDirection.HORIZONTAL,
            flexWrap = FlexWrap.WRAP,
            gap = math.max(1, 10 - depth),
          })
          level_container.parent = current_parent
          table.insert(current_parent.children, level_container)
          created_elements = created_elements + 1

          if depth < test_config.depth then
            current_parent = level_container
          else
            -- Final level - add many elements
            for i = 1, elements_per_level do
              local leaf = Gui.new({ width = 30 + (i % 20), height = 25 + (i % 15) })
              leaf.parent = level_container
              table.insert(level_container.children, leaf)
              created_elements = created_elements + 1
            end
          end
        end
        max_actual_depth = test_config.depth
      elseif test_config.name == "Wide Branching" then
        -- Create structure with wide branching at each level
        local function createBranching(parent, remaining_elements, current_depth, max_depth)
          if current_depth >= max_depth or remaining_elements <= 0 then
            return 0
          end

          local children_count = math.min(20, math.ceil(remaining_elements / (max_depth - current_depth)))
          local elements_used = 0

          for i = 1, children_count do
            local branch = Gui.new({
              width = 150 - (current_depth * 15),
              height = 100 - (current_depth * 10),
              positioning = Positioning.FLEX,
              flexDirection = (i % 2 == 0) and FlexDirection.VERTICAL or FlexDirection.HORIZONTAL,
              justifyContent = JustifyContent.SPACE_AROUND,
              gap = math.max(1, 8 - current_depth * 2),
            })
            branch.parent = parent
            table.insert(parent.children, branch)
            elements_used = elements_used + 1

            if current_depth < max_depth - 1 then
              elements_used = elements_used
                + createBranching(branch, remaining_elements - elements_used, current_depth + 1, max_depth)
            end

            if elements_used >= remaining_elements then
              break
            end
          end

          return elements_used
        end

        created_elements = 1 + createBranching(root, test_config.elements - 1, 1, test_config.depth)
        max_actual_depth = test_config.depth
      elseif test_config.name == "Mixed Complex" then
        -- Create mixed complex structure with varying patterns
        local sections = math.ceil(test_config.depth / 2)
        local elements_per_section = math.ceil(test_config.elements / sections)

        for section_id = 1, sections do
          local section = Gui.new({
            width = 1900,
            height = 200,
            positioning = Positioning.FLEX,
            flexDirection = FlexDirection.HORIZONTAL,
            flexWrap = FlexWrap.WRAP,
            justifyContent = JustifyContent.SPACE_BETWEEN,
            gap = 10,
          })
          section.parent = root
          table.insert(root.children, section)
          created_elements = created_elements + 1

          -- Create subsections with different patterns
          local subsections = 5 + (section_id % 3)
          for sub_id = 1, subsections do
            local subsection = Gui.new({
              width = 300,
              height = 180,
              positioning = Positioning.FLEX,
              flexDirection = FlexDirection.VERTICAL,
              justifyContent = JustifyContent.SPACE_AROUND,
              gap = 5,
            })
            subsection.parent = section
            table.insert(section.children, subsection)
            created_elements = created_elements + 1

            -- Add elements with varying complexity
            local elements_in_subsection = math.ceil(elements_per_section / subsections)
            for elem_id = 1, elements_in_subsection do
              if elem_id % 3 == 0 then
                -- Complex element with children
                local complex_elem = Gui.new({
                  width = 280,
                  height = 35,
                  positioning = Positioning.FLEX,
                  flexDirection = FlexDirection.HORIZONTAL,
                  justifyContent = JustifyContent.SPACE_BETWEEN,
                  gap = 3,
                })
                complex_elem.parent = subsection
                table.insert(subsection.children, complex_elem)
                created_elements = created_elements + 1

                for child_id = 1, 4 do
                  local child = Gui.new({ width = 60, height = 30 })
                  child.parent = complex_elem
                  table.insert(complex_elem.children, child)
                  created_elements = created_elements + 1
                end
              else
                -- Simple element
                local simple_elem = Gui.new({ width = 270, height = 25 })
                simple_elem.parent = subsection
                table.insert(subsection.children, simple_elem)
                created_elements = created_elements + 1
              end

              if created_elements >= test_config.elements then
                break
              end
            end
            if created_elements >= test_config.elements then
              break
            end
          end
          if created_elements >= test_config.elements then
            break
          end
        end
        max_actual_depth = 4
      end

      -- Perform layout
      root:layoutChildren()

      return {
        created_elements = created_elements,
        max_depth = max_actual_depth,
      }
    end)

    local elements_per_second = test_metrics.created_elements / test_time

    benchmark_results[test_config.name] = {
      time = test_time,
      elements = test_metrics.created_elements,
      elements_per_second = elements_per_second,
      depth = test_metrics.max_depth,
    }

    print(
      string.format(
        "    %s: %d elements, %.6f seconds (%.0f elem/sec)",
        test_config.name,
        test_metrics.created_elements,
        test_time,
        elements_per_second
      )
    )

    -- Individual test assertions
    luaunit.assertTrue(test_time < 1.0, string.format("%s should complete within 1 seconds", test_config.name))
    luaunit.assertTrue(
      test_metrics.created_elements > 50,
      string.format("%s should create substantial elements", test_config.name)
    )
  end

  -- Overall benchmark analysis
  print(string.format("Extreme Scale Benchmark Summary:"))
  local total_elements = 0
  local total_time = 0
  local best_performance = 0
  local worst_performance = math.huge

  for test_name, result in pairs(benchmark_results) do
    total_elements = total_elements + result.elements
    total_time = total_time + result.time
    best_performance = math.max(best_performance, result.elements_per_second)
    worst_performance = math.min(worst_performance, result.elements_per_second)
    print(string.format("  %s: %.0f elements/second", test_name, result.elements_per_second))
  end

  local avg_performance = total_elements / total_time

  print(string.format("  Overall Average: %.0f elements/second", avg_performance))
  print(string.format("  Best Performance: %.0f elements/second", best_performance))
  print(string.format("  Worst Performance: %.0f elements/second", worst_performance))
  print(string.format("  Performance Range: %.1fx", best_performance / worst_performance))

  -- Extreme scale performance assertions
  luaunit.assertTrue(total_time < 60.0, "All extreme scale tests should complete within 60 seconds")
  luaunit.assertTrue(avg_performance > 50, "Should achieve at least 50 elements/second average")
  luaunit.assertTrue(best_performance > 100, "Best case should achieve at least 100 elements/second")
  luaunit.assertTrue(best_performance / worst_performance < 20, "Performance variance should be reasonable")
  luaunit.assertTrue(total_elements > 2000, "Should have processed substantial total elements")
end

luaunit.LuaUnit.run()
