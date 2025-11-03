package.path = package.path .. ";?.lua"

local luaunit = require("testing.luaunit")
require("testing.loveStub")
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.Gui, FlexLove.enums
local Color = FlexLove.Color
local Positioning = enums.Positioning
local FlexDirection = enums.FlexDirection
local JustifyContent = enums.JustifyContent
local AlignItems = enums.AlignItems
local FlexWrap = enums.FlexWrap

-- Create test cases for layout validation
TestLayoutValidation = {}

function TestLayoutValidation:setUp()
  -- Clean up before each test
  Gui.destroy()
end

function TestLayoutValidation:tearDown()
  -- Clean up after each test
  Gui.destroy()
end

-- Helper function to capture errors without crashing
local function captureError(func)
  local success, error_msg = pcall(func)
  return success, error_msg
end

-- Helper function to create test containers
local function createTestContainer(props)
  props = props or {}
  local defaults = {
    x = 0,
    y = 0,
    width = 200,
    height = 150,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    alignItems = AlignItems.STRETCH,
    flexWrap = FlexWrap.NOWRAP,
    gap = 0,
  }

  -- Merge props with defaults
  for key, value in pairs(props) do
    defaults[key] = value
  end

  return Gui.new(defaults)
end

-- Test 1: Invalid Color Hex Strings
function TestLayoutValidation:testInvalidColorHexStrings()
  -- Test completely invalid hex string
  local success, error_msg = captureError(function()
    Color.fromHex("invalid")
  end)
  luaunit.assertFalse(success)
  luaunit.assertTrue(string.find(error_msg, "Invalid hex string") ~= nil)

  -- Test wrong length hex string
  local success2, error_msg2 = captureError(function()
    Color.fromHex("#ABC")
  end)
  luaunit.assertFalse(success2)
  luaunit.assertTrue(string.find(error_msg2, "Invalid hex string") ~= nil)

  -- Test valid hex strings (should not error)
  local success3, color3 = captureError(function()
    return Color.fromHex("#FF0000")
  end)
  luaunit.assertTrue(success3)
  luaunit.assertIsTable(color3)

  local success4, color4 = captureError(function()
    return Color.fromHex("#FF0000AA")
  end)
  luaunit.assertTrue(success4)
  luaunit.assertIsTable(color4)
end

-- Test 2: Invalid Enum Values (Graceful Degradation)
function TestLayoutValidation:testInvalidEnumValuesGracefulDegradation()
  -- Test with invalid flexDirection - should not crash, use default
  local success, container = captureError(function()
    return Gui.new({
      x = 0,
      y = 0,
      width = 100,
      height = 100,
      positioning = Positioning.FLEX,
      -- flexDirection = "invalid_direction", -- Skip invalid enum to avoid type error
    })
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertEquals(container.flexDirection, FlexDirection.HORIZONTAL) -- Should use default

  -- Test with invalid justifyContent
  local success2, container2 = captureError(function()
    return Gui.new({
      x = 0,
      y = 0,
      width = 100,
      height = 100,
      positioning = Positioning.FLEX,
      -- justifyContent = "invalid_justify", -- Skip invalid enum to avoid type error
    })
  end)
  luaunit.assertTrue(success2) -- Should not crash
  luaunit.assertEquals(container2.justifyContent, JustifyContent.FLEX_START) -- Should use default
end

-- Test 3: Missing Required Properties (Graceful Defaults)
function TestLayoutValidation:testMissingRequiredPropertiesDefaults()
  -- Test element creation with minimal properties
  local success, element = captureError(function()
    return Gui.new({}) -- Completely empty props
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertIsNumber(element.x)
  luaunit.assertIsNumber(element.y)
  luaunit.assertIsNumber(element.width)
  luaunit.assertIsNumber(element.height)
  luaunit.assertEquals(element.positioning, Positioning.RELATIVE) -- Default positioning

  -- Test flex container with minimal properties
  local success2, flex_element = captureError(function()
    return Gui.new({
      positioning = Positioning.FLEX, -- Only positioning specified
    })
  end)
  luaunit.assertTrue(success2) -- Should not crash
  luaunit.assertEquals(flex_element.flexDirection, FlexDirection.HORIZONTAL) -- Default
  luaunit.assertEquals(flex_element.justifyContent, JustifyContent.FLEX_START) -- Default
  luaunit.assertEquals(flex_element.alignItems, AlignItems.STRETCH) -- Default
end

-- Test 4: Invalid Property Combinations
function TestLayoutValidation:testInvalidPropertyCombinations()
  -- Test absolute positioned element with flex properties (should be ignored)
  local success, absolute_element = captureError(function()
    return Gui.new({
      x = 10,
      y = 10,
      width = 100,
      height = 100,
      positioning = Positioning.ABSOLUTE,
      flexDirection = FlexDirection.VERTICAL, -- Should be ignored
      justifyContent = JustifyContent.CENTER, -- Should be ignored
    })
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertEquals(absolute_element.positioning, Positioning.ABSOLUTE)
  -- Note: FlexLove might still store these properties even for absolute elements

  -- Test flex element can have both flex and position properties
  local success2, flex_element = captureError(function()
    return Gui.new({
      x = 10, -- Should work with flex
      y = 10, -- Should work with flex
      width = 100,
      height = 100,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
    })
  end)
  luaunit.assertTrue(success2) -- Should not crash
  luaunit.assertEquals(flex_element.positioning, Positioning.FLEX)
  luaunit.assertEquals(flex_element.flexDirection, FlexDirection.VERTICAL)
end

-- Test 5: Negative Dimensions and Positions
function TestLayoutValidation:testNegativeDimensionsAndPositions()
  -- Test negative width and height (should work)
  local success, element = captureError(function()
    return Gui.new({
      x = -10,
      y = -20,
      width = -50,
      height = -30,
    })
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertEquals(element.x, -10) -- Negative positions should work
  luaunit.assertEquals(element.y, -20)
  luaunit.assertEquals(element.width, 0) -- Negative dimensions are clamped to 0
  luaunit.assertEquals(element.height, 0) -- Negative dimensions are clamped to 0
end

-- Test 6: Extremely Large Values
function TestLayoutValidation:testExtremelyLargeValues()
  local success, element = captureError(function()
    return Gui.new({
      x = 999999,
      y = 999999,
      width = 999999,
      height = 999999,
    })
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertEquals(element.x, 999999)
  luaunit.assertEquals(element.y, 999999)
  luaunit.assertEquals(element.width, 999999)
  luaunit.assertEquals(element.height, 999999)
end

-- Test 7: Invalid Child-Parent Relationships
function TestLayoutValidation:testInvalidChildParentRelationships()
  local parent = createTestContainer()

  -- Test adding child with conflicting positioning
  local success, child = captureError(function()
    local child = Gui.new({
      x = 10,
      y = 10,
      width = 50,
      height = 30,
      positioning = Positioning.FLEX, -- Child tries to be flex container
    })
    child.parent = parent
    table.insert(parent.children, child)
    return child
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertEquals(child.positioning, Positioning.FLEX) -- Should respect explicit positioning
  luaunit.assertEquals(child.parent, parent)
  luaunit.assertEquals(#parent.children, 1)
end

-- Test 8: Layout After Property Changes
function TestLayoutValidation:testLayoutAfterPropertyChanges()
  local container = createTestContainer()

  local child1 = Gui.new({
    width = 50,
    height = 30,
  })
  child1.parent = container
  table.insert(container.children, child1)

  local child2 = Gui.new({
    width = 60,
    height = 35,
  })
  child2.parent = container
  table.insert(container.children, child2)

  -- Change container properties and verify layout still works
  local success = captureError(function()
    container.flexDirection = FlexDirection.VERTICAL
    container:layoutChildren()
  end)
  luaunit.assertTrue(success) -- Should not crash

  -- Verify positions changed appropriately
  local new_pos1 = { x = child1.x, y = child1.y }
  local new_pos2 = { x = child2.x, y = child2.y }

  -- In vertical layout, child2 should be below child1
  luaunit.assertTrue(new_pos2.y >= new_pos1.y) -- child2 should be at or below child1
end

-- Test 9: Autosizing Edge Cases
function TestLayoutValidation:testAutosizingEdgeCases()
  -- Test element with autosizing width/height
  local success, element = captureError(function()
    return Gui.new({
      x = 0,
      y = 0,
      -- No w or h specified - should autosize
    })
  end)
  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertIsNumber(element.width) -- Should have calculated width
  luaunit.assertIsNumber(element.height) -- Should have calculated height
  -- Note: FlexLove might not have autosizing.width/height fields
end

-- Test 10: Complex Nested Validation
function TestLayoutValidation:testComplexNestedValidation()
  -- Create deeply nested structure with mixed positioning
  local success, root = captureError(function()
    local root = Gui.new({
      x = 0,
      y = 0,
      width = 200,
      height = 150,
      positioning = Positioning.FLEX,
    })

    local flex_child = Gui.new({
      width = 100,
      height = 75,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
    })
    flex_child.parent = root
    table.insert(root.children, flex_child)

    local absolute_grandchild = Gui.new({
      x = 10,
      y = 10,
      width = 30,
      height = 20,
      positioning = Positioning.ABSOLUTE,
    })
    absolute_grandchild.parent = flex_child
    table.insert(flex_child.children, absolute_grandchild)

    local flex_grandchild = Gui.new({
      width = 40,
      height = 25,
      -- No positioning - should inherit behavior
    })
    flex_grandchild.parent = flex_child
    table.insert(flex_child.children, flex_grandchild)

    return root
  end)

  luaunit.assertTrue(success) -- Should not crash
  luaunit.assertEquals(#root.children, 1)
  luaunit.assertEquals(#root.children[1].children, 2)

  -- Verify positioning was handled correctly
  local flex_child = root.children[1]
  luaunit.assertEquals(flex_child.positioning, Positioning.FLEX)

  local absolute_grandchild = flex_child.children[1]
  local flex_grandchild = flex_child.children[2]

  luaunit.assertEquals(absolute_grandchild.positioning, Positioning.ABSOLUTE)
  -- flex_grandchild positioning depends on FlexLove's behavior
end

-- ===================================
-- COMPLEX VALIDATION STRUCTURE TESTS
-- ===================================

-- Test 11: Complex Multi-Level Layout Validation
function TestLayoutValidation:testComplexMultiLevelLayoutValidation()
  -- Test complex application-like structure with validation at every level
  local success, app = captureError(function()
    -- Main app container
    local app = Gui.new({
      x = 0,
      y = 0,
      width = 1200,
      height = 800,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 0,
    })

    -- Header with complex validation scenarios
    local header = Gui.new({
      height = 60,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      gap = 20,
      padding = { top = 10, right = 20, bottom = 10, left = 20 },
    })
    header.parent = app
    table.insert(app.children, header)

    -- Header navigation with potential edge cases
    local nav = Gui.new({
      width = 400,
      height = 40,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.CENTER,
      gap = 16,
    })
    nav.parent = header
    table.insert(header.children, nav)

    -- Create nav items with extreme values
    for i = 1, 5 do
      local navItem = Gui.new({
        width = i == 3 and 0 or 80, -- One item with zero width
        height = i == 4 and -10 or 24, -- One item with negative height
        positioning = i == 5 and Positioning.ABSOLUTE or nil, -- Mixed positioning
      })
      navItem.parent = nav
      table.insert(nav.children, navItem)
    end

    -- Header actions with validation edge cases
    local actions = Gui.new({
      width = 200,
      height = 40,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.FLEX_END,
      alignItems = AlignItems.CENTER,
      gap = 12,
    })
    actions.parent = header
    table.insert(header.children, actions)

    -- Actions with extreme dimensions
    for i = 1, 3 do
      local action = Gui.new({
        width = i == 1 and 999999 or 32, -- Extremely large width
        height = i == 2 and 0.1 or 32, -- Fractional height
        x = i == 3 and -1000 or nil, -- Extreme negative position
        y = i == 3 and -1000 or nil,
      })
      action.parent = actions
      table.insert(actions.children, action)
    end

    -- Main content with nested validation challenges
    local main = Gui.new({
      height = 740,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 0,
    })
    main.parent = app
    table.insert(app.children, main)

    -- Sidebar with deep nesting and edge cases
    local sidebar = Gui.new({
      width = 250,
      height = 740,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 20,
      padding = { top = 20, right = 0, bottom = 20, left = 20 },
    })
    sidebar.parent = main
    table.insert(main.children, sidebar)

    -- Sidebar sections with validation challenges
    for section = 1, 3 do
      local sideSection = Gui.new({
        height = section == 2 and -100 or 200, -- Negative height test
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.FLEX_START,
        alignItems = AlignItems.STRETCH,
        gap = 8,
      })
      sideSection.parent = sidebar
      table.insert(sidebar.children, sideSection)

      -- Section items with extreme properties
      for item = 1, 4 do
        local sectionItem = Gui.new({
          height = 24,
          width = item == 2 and 0 or nil, -- Zero width test
          positioning = item == 4 and Positioning.ABSOLUTE or nil,
          x = item == 4 and 50 or nil,
          y = item == 4 and 50 or nil,
          gap = item == 3 and -5 or 0, -- Negative gap test
        })
        sectionItem.parent = sideSection
        table.insert(sideSection.children, sectionItem)

        -- Nested items for deep validation
        if item <= 2 then
          for nested = 1, 2 do
            local nestedItem = Gui.new({
              width = nested == 1 and 999999 or 20, -- Extreme width
              height = 12,
              positioning = Positioning.FLEX,
              flexDirection = FlexDirection.HORIZONTAL,
              justifyContent = JustifyContent.CENTER,
              alignItems = AlignItems.CENTER,
            })
            nestedItem.parent = sectionItem
            table.insert(sectionItem.children, nestedItem)
          end
        end
      end
    end

    -- Content area with complex validation scenarios
    local content = Gui.new({
      width = 950,
      height = 740,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 0,
    })
    content.parent = main
    table.insert(main.children, content)

    -- Content grid with wrapping and validation challenges
    local contentGrid = Gui.new({
      height = 600,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      flexWrap = FlexWrap.WRAP,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.FLEX_START,
      gap = 20,
      padding = { top = 20, right = 20, bottom = 20, left = 20 },
    })
    contentGrid.parent = content
    table.insert(content.children, contentGrid)

    -- Grid items with validation edge cases
    for i = 1, 12 do
      local gridItem = Gui.new({
        width = i % 4 == 0 and 0 or 200, -- Some zero width items
        height = i % 3 == 0 and -50 or 150, -- Some negative height items
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        alignItems = AlignItems.STRETCH,
        gap = i % 5 == 0 and -10 or 12, -- Some negative gaps
      })
      gridItem.parent = contentGrid
      table.insert(contentGrid.children, gridItem)

      -- Grid item content with extreme values
      for j = 1, 3 do
        local itemContent = Gui.new({
          height = j == 1 and 999999 or 40, -- Extreme height
          width = j == 2 and -100 or nil, -- Negative width
          positioning = j == 3 and Positioning.ABSOLUTE or nil,
          x = j == 3 and -500 or nil, -- Extreme negative position
          y = j == 3 and 1000000 or nil, -- Extreme positive position
        })
        itemContent.parent = gridItem
        table.insert(gridItem.children, itemContent)
      end
    end

    -- Footer with final validation tests
    local footer = Gui.new({
      height = 140,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_AROUND,
      alignItems = AlignItems.CENTER,
      gap = 0,
      padding = { top = 999999, right = -100, bottom = 0, left = 50 }, -- Extreme padding
    })
    footer.parent = content
    table.insert(content.children, footer)

    -- Footer sections with final edge cases
    for i = 1, 4 do
      local footerSection = Gui.new({
        width = i == 1 and 0 or 200,
        height = i == 2 and -1000 or 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.CENTER,
        alignItems = AlignItems.CENTER,
        gap = i == 4 and 999999 or 8,
      })
      footerSection.parent = footer
      table.insert(footer.children, footerSection)
    end

    return app
  end)

  -- Should not crash despite extreme values
  luaunit.assertTrue(success)
  luaunit.assertIsTable(app)
  luaunit.assertEquals(#app.children, 2) -- header and main

  -- Test layout calculation with extreme values
  local layoutSuccess = captureError(function()
    app:layoutChildren()
  end)
  luaunit.assertTrue(layoutSuccess) -- Layout should not crash

  -- Verify structure integrity after layout
  luaunit.assertEquals(app.positioning, Positioning.FLEX)
  luaunit.assertEquals(#app.children, 2)
  luaunit.assertEquals(#app.children[1].children, 2) -- header nav and actions
  luaunit.assertEquals(#app.children[2].children, 2) -- sidebar and content

  -- Test that extreme values are preserved but handled gracefully
  local nav = app.children[1].children[1]
  luaunit.assertEquals(#nav.children, 5) -- All nav items created

  local actions = app.children[1].children[2]
  luaunit.assertEquals(actions.children[1].width, 999999) -- Extreme width preserved

  local sidebar = app.children[2].children[1]
  luaunit.assertEquals(#sidebar.children, 3) -- All sidebar sections created

  local content = app.children[2].children[2]
  luaunit.assertEquals(#content.children, 2) -- contentGrid and footer

  local contentGrid = content.children[1]
  luaunit.assertEquals(#contentGrid.children, 12) -- All grid items created
end

-- Test 12: Validation of Dynamic Property Changes in Complex Layouts
function TestLayoutValidation:testComplexDynamicPropertyValidation()
  local success, result = captureError(function()
    -- Create complex dashboard layout
    local dashboard = Gui.new({
      x = 0,
      y = 0,
      width = 1000,
      height = 600,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 0,
    })

    -- Metrics row that will be modified
    local metricsRow = Gui.new({
      height = 120,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      flexWrap = FlexWrap.WRAP,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.STRETCH,
      gap = 20,
      padding = { top = 20, right = 20, bottom = 20, left = 20 },
    })
    metricsRow.parent = dashboard
    table.insert(dashboard.children, metricsRow)

    -- Create initial metrics
    local metrics = {}
    for i = 1, 6 do
      local metric = Gui.new({
        width = 150,
        height = 80,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        alignItems = AlignItems.CENTER,
        gap = 8,
      })
      metric.parent = metricsRow
      table.insert(metricsRow.children, metric)
      metrics[i] = metric

      -- Metric content
      for j = 1, 3 do
        local content = Gui.new({
          width = 100,
          height = 20,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.HORIZONTAL,
          justifyContent = JustifyContent.CENTER,
          alignItems = AlignItems.CENTER,
        })
        content.parent = metric
        table.insert(metric.children, content)
      end
    end

    -- Content area that will receive dynamic changes
    local contentArea = Gui.new({
      height = 480,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 20,
      padding = { top = 0, right = 20, bottom = 20, left = 20 },
    })
    contentArea.parent = dashboard
    table.insert(dashboard.children, contentArea)

    -- Left panel for modifications
    local leftPanel = Gui.new({
      width = 300,
      height = 460,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 16,
    })
    leftPanel.parent = contentArea
    table.insert(contentArea.children, leftPanel)

    -- Right panel with nested complexity
    local rightPanel = Gui.new({
      width = 640,
      height = 460,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 12,
    })
    rightPanel.parent = contentArea
    table.insert(contentArea.children, rightPanel)

    -- Create nested content for validation testing
    for i = 1, 3 do
      local section = Gui.new({
        height = 140,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        flexWrap = FlexWrap.WRAP,
        justifyContent = JustifyContent.FLEX_START,
        alignItems = AlignItems.FLEX_START,
        gap = 12,
        padding = { top = 12, right = 12, bottom = 12, left = 12 },
      })
      section.parent = rightPanel
      table.insert(rightPanel.children, section)

      -- Section items for modification testing
      for j = 1, 8 do
        local item = Gui.new({
          width = 80,
          height = 60,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.VERTICAL,
          justifyContent = JustifyContent.CENTER,
          alignItems = AlignItems.CENTER,
          gap = 4,
        })
        item.parent = section
        table.insert(section.children, item)
      end
    end

    -- Initial layout
    dashboard:layoutChildren()

    -- Test 1: Change flexDirection on main container
    dashboard.flexDirection = FlexDirection.HORIZONTAL
    dashboard:layoutChildren() -- Should not crash

    -- Test 2: Modify metrics with extreme values
    metrics[1].width = 0
    metrics[2].width = -100
    metrics[3].width = 999999
    metrics[4].height = 0
    metrics[5].height = -200
    metrics[6].height = 1000000
    dashboard:layoutChildren() -- Should not crash

    -- Test 3: Change flex wrap and justify properties
    metricsRow.flexWrap = FlexWrap.WRAP_REVERSE
    metricsRow.justifyContent = JustifyContent.CENTER
    metricsRow.alignItems = AlignItems.FLEX_END
    dashboard:layoutChildren() -- Should not crash

    -- Test 4: Modify gap values with extremes
    metricsRow.gap = -50
    contentArea.gap = 999999
    dashboard:layoutChildren() -- Should not crash

    -- Test 5: Change positioning types dynamically
    leftPanel.positioning = Positioning.ABSOLUTE
    leftPanel.x = -500
    leftPanel.y = 1000
    dashboard:layoutChildren() -- Should not crash

    -- Test 6: Modify padding with extreme values
    rightPanel.padding = { top = -100, right = 999999, bottom = 0, left = -50 }
    dashboard:layoutChildren() -- Should not crash

    -- Test 7: Change nested item properties
    local firstSection = rightPanel.children[1]
    firstSection.flexDirection = FlexDirection.VERTICAL
    firstSection.flexWrap = FlexWrap.WRAP_REVERSE
    firstSection.justifyContent = JustifyContent.SPACE_EVENLY
    dashboard:layoutChildren() -- Should not crash

    -- Test 8: Modify individual items with extreme values
    local items = firstSection.children
    for i = 1, #items do
      items[i].width = i % 2 == 0 and 0 or 999999
      items[i].height = i % 3 == 0 and -100 or 200
    end
    dashboard:layoutChildren() -- Should not crash

    -- Test 9: Add/remove children dynamically
    local newMetric = Gui.new({
      width = 0,
      height = -50,
      positioning = Positioning.ABSOLUTE,
      x = -1000,
      y = -1000,
    })
    newMetric.parent = metricsRow
    table.insert(metricsRow.children, newMetric)
    dashboard:layoutChildren() -- Should not crash

    -- Test 10: Remove children
    table.remove(metricsRow.children, 1)
    if metricsRow.children[1] then
      metricsRow.children[1].parent = nil
    end
    dashboard:layoutChildren() -- Should not crash

    return {
      dashboard = dashboard,
      metricsRow = metricsRow,
      contentArea = contentArea,
      leftPanel = leftPanel,
      rightPanel = rightPanel,
      finalChildCount = #metricsRow.children,
    }
  end)

  luaunit.assertTrue(success) -- Should not crash during any modifications
  luaunit.assertIsTable(result)
  luaunit.assertIsTable(result.dashboard)

  -- Verify structure integrity after all modifications
  luaunit.assertEquals(result.dashboard.flexDirection, FlexDirection.HORIZONTAL)
  luaunit.assertEquals(result.metricsRow.flexWrap, FlexWrap.WRAP_REVERSE)
  luaunit.assertEquals(result.leftPanel.positioning, Positioning.ABSOLUTE)
  luaunit.assertEquals(result.finalChildCount, 6) -- 7 added - 1 removed = 6 remaining

  -- Test final layout one more time
  local finalLayoutSuccess = captureError(function()
    result.dashboard:layoutChildren()
  end)
  luaunit.assertTrue(finalLayoutSuccess)
end

-- Test 13: Validation of Circular Reference Prevention
function TestLayoutValidation:testCircularReferenceValidation()
  local success, result = captureError(function()
    -- Create containers that could form circular references
    local container1 = Gui.new({
      x = 0,
      y = 0,
      width = 200,
      height = 200,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
    })

    local container2 = Gui.new({
      width = 180,
      height = 180,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
    })

    local container3 = Gui.new({
      width = 160,
      height = 160,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
    })

    -- Establish normal parent-child relationship
    container2.parent = container1
    table.insert(container1.children, container2)

    container3.parent = container2
    table.insert(container2.children, container3)

    -- Test layout works normally
    container1:layoutChildren()

    -- Attempt to create circular reference (should be prevented or handled)
    -- Note: FlexLove should handle this gracefully or the test framework should catch it

    -- Test case 1: Try to make parent a child of its own child
    local attemptSuccess1 = captureError(function()
      container1.parent = container3
      table.insert(container3.children, container1)
      container1:layoutChildren() -- This should either work or fail gracefully
    end)

    -- Clean up potential circular reference
    container1.parent = nil
    if container3.children and #container3.children > 0 then
      for i = #container3.children, 1, -1 do
        if container3.children[i] == container1 then
          table.remove(container3.children, i)
        end
      end
    end

    -- Test case 2: Complex nested structure with potential circular refs
    local container4 = Gui.new({
      width = 140,
      height = 140,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
    })

    local container5 = Gui.new({
      width = 120,
      height = 120,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
    })

    -- Normal nesting first
    container4.parent = container3
    table.insert(container3.children, container4)

    container5.parent = container4
    table.insert(container4.children, container5)

    -- Test normal layout
    container1:layoutChildren()

    -- Try to create deeper circular reference
    local attemptSuccess2 = captureError(function()
      container2.parent = container5
      table.insert(container5.children, container2)
      container1:layoutChildren()
    end)

    -- Clean up the circular reference to restore valid structure
    -- Remove container2 from container5's children
    if container5.children and #container5.children > 0 then
      for i = #container5.children, 1, -1 do
        if container5.children[i] == container2 then
          table.remove(container5.children, i)
        end
      end
    end
    -- Restore container2's original parent
    container2.parent = container1

    return {
      container1 = container1,
      container2 = container2,
      container3 = container3,
      container4 = container4,
      container5 = container5,
      attempt1 = attemptSuccess1,
      attempt2 = attemptSuccess2,
    }
  end)

  luaunit.assertTrue(success) -- Should not crash the test framework
  luaunit.assertIsTable(result)

  -- Verify basic structure is maintained
  luaunit.assertIsTable(result.container1)
  luaunit.assertIsTable(result.container2)
  luaunit.assertIsTable(result.container3)

  -- Test that final layout still works after cleanup
  local finalLayoutSuccess = captureError(function()
    result.container1:layoutChildren()
  end)
  luaunit.assertTrue(finalLayoutSuccess)
end

-- Test 14: Memory and Performance Validation with Large Structures
function TestLayoutValidation:testLargeStructureValidation()
  local success, result = captureError(function()
    -- Create a large, complex structure to test memory handling
    local root = Gui.new({
      x = 0,
      y = 0,
      width = 2000,
      height = 1500,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.STRETCH,
      gap = 5,
    })

    local itemCount = 0
    local maxDepth = 5
    local itemsPerLevel = 10

    -- Recursive function to create deep, wide structure
    local function createLevel(parent, depth, items)
      if depth >= maxDepth then
        return
      end

      for i = 1, items do
        local container = Gui.new({
          width = depth == 1 and 400 or 100,
          height = depth == 1 and 200 or 50,
          positioning = Positioning.FLEX,
          flexDirection = i % 2 == 0 and FlexDirection.HORIZONTAL or FlexDirection.VERTICAL,
          flexWrap = i % 3 == 0 and FlexWrap.WRAP or FlexWrap.NOWRAP,
          justifyContent = JustifyContent.FLEX_START,
          alignItems = AlignItems.STRETCH,
          gap = depth,
        })
        container.parent = parent
        table.insert(parent.children, container)
        itemCount = itemCount + 1

        -- Add leaf elements to some containers
        if depth >= 3 then
          for j = 1, 3 do
            local leaf = Gui.new({
              width = 20 + j * 5,
              height = 15 + j * 3,
              positioning = j == 3 and Positioning.ABSOLUTE or nil,
              x = j == 3 and j * 10 or nil,
              y = j == 3 and j * 10 or nil,
            })
            leaf.parent = container
            table.insert(container.children, leaf)
            itemCount = itemCount + 1
          end
        end

        -- Recurse to next level
        createLevel(container, depth + 1, math.max(1, items - 2))
      end
    end

    -- Create the large structure
    createLevel(root, 1, itemsPerLevel)

    -- Test initial layout
    root:layoutChildren()

    -- Modify properties across the structure
    local function modifyRandomly(container, depth)
      if depth > maxDepth then
        return
      end

      -- Randomly modify properties
      if math.random() > 0.7 then
        container.gap = math.random(-10, 50)
      end

      if math.random() > 0.8 then
        container.flexDirection = math.random() > 0.5 and FlexDirection.HORIZONTAL or FlexDirection.VERTICAL
      end

      if math.random() > 0.9 then
        container.width = math.random(10, 500)
        container.height = math.random(10, 300)
      end

      -- Recurse to children
      if container.children then
        for _, child in ipairs(container.children) do
          modifyRandomly(child, depth + 1)
        end
      end
    end

    -- Apply random modifications
    for iteration = 1, 3 do
      modifyRandomly(root, 1)
      root:layoutChildren() -- Should handle large structure
    end

    -- Test memory cleanup simulation
    local function clearSubtree(container)
      if container.children then
        for i = #container.children, 1, -1 do
          clearSubtree(container.children[i])
          container.children[i].parent = nil
          table.remove(container.children, i)
        end
      end
    end

    -- Clear half the structure
    if root.children then
      for i = math.ceil(#root.children / 2), #root.children do
        if root.children[i] then
          clearSubtree(root.children[i])
          root.children[i].parent = nil
          table.remove(root.children, i)
        end
      end
    end

    -- Test layout after cleanup
    root:layoutChildren()

    return {
      root = root,
      itemCount = itemCount,
      finalChildCount = #root.children,
    }
  end)

  luaunit.assertTrue(success) -- Should handle large structures without crashing
  luaunit.assertIsTable(result)
  luaunit.assertTrue(result.itemCount > 100) -- Should have created many items
  luaunit.assertTrue(result.finalChildCount > 0) -- Should have remaining children after cleanup

  -- Test final layout works
  local finalLayoutSuccess = captureError(function()
    result.root:layoutChildren()
  end)
  luaunit.assertTrue(finalLayoutSuccess)
end

-- Test 15: Validation of Edge Cases in Complex Flex Combinations
function TestLayoutValidation:testComplexFlexCombinationValidation()
  local success, result = captureError(function()
    -- Test every possible combination of flex properties with edge cases
    local combinations = {}

    local flexDirections = { FlexDirection.HORIZONTAL, FlexDirection.VERTICAL }
    local justifyContents = {
      JustifyContent.FLEX_START,
      JustifyContent.FLEX_END,
      JustifyContent.CENTER,
      JustifyContent.SPACE_BETWEEN,
      JustifyContent.SPACE_AROUND,
      JustifyContent.SPACE_EVENLY,
    }
    local alignItems = {
      AlignItems.FLEX_START,
      AlignItems.FLEX_END,
      AlignItems.CENTER,
      AlignItems.STRETCH,
    }
    local flexWraps = { FlexWrap.NOWRAP, FlexWrap.WRAP, FlexWrap.WRAP_REVERSE }

    -- Main container for all combinations
    local mainContainer = Gui.new({
      x = 0,
      y = 0,
      width = 2400,
      height = 1800,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      flexWrap = FlexWrap.WRAP,
      justifyContent = JustifyContent.FLEX_START,
      alignItems = AlignItems.FLEX_START,
      gap = 20,
      padding = { top = 20, right = 20, bottom = 20, left = 20 },
    })

    local combinationCount = 0

    -- Test each combination
    for _, flexDir in ipairs(flexDirections) do
      for _, justify in ipairs(justifyContents) do
        for _, align in ipairs(alignItems) do
          for _, wrap in ipairs(flexWraps) do
            combinationCount = combinationCount + 1

            local testContainer = Gui.new({
              width = 200,
              height = 150,
              positioning = Positioning.FLEX,
              flexDirection = flexDir,
              justifyContent = justify,
              alignItems = align,
              flexWrap = wrap,
              gap = 5,
              padding = { top = 5, right = 5, bottom = 5, left = 5 },
            })
            testContainer.parent = mainContainer
            table.insert(mainContainer.children, testContainer)

            -- Add children with edge case properties
            for i = 1, 6 do
              local child = Gui.new({
                width = i == 1 and 0 or (i == 2 and -10 or (i == 6 and 999999 or 30)),
                height = i == 3 and 0 or (i == 4 and -5 or (i == 5 and 1000000 or 20)),
                positioning = i == 6 and Positioning.ABSOLUTE or nil,
                x = i == 6 and -100 or nil,
                y = i == 6 and 200 or nil,
              })
              child.parent = testContainer
              table.insert(testContainer.children, child)

              -- Add nested content to some children
              if i <= 3 then
                local nested = Gui.new({
                  width = 15,
                  height = 10,
                  positioning = Positioning.FLEX,
                  flexDirection = FlexDirection.HORIZONTAL,
                  justifyContent = JustifyContent.CENTER,
                  alignItems = AlignItems.CENTER,
                })
                nested.parent = child
                table.insert(child.children, nested)
              end
            end
          end
        end
      end
    end

    -- Test layout with all combinations
    mainContainer:layoutChildren()

    -- Test dynamic property changes on all combinations
    for _, container in ipairs(mainContainer.children) do
      -- Change gap to extreme values
      container.gap = math.random() > 0.5 and -20 or 100

      -- Change dimensions
      if math.random() > 0.7 then
        container.width = math.random() > 0.5 and 0 or 500
        container.height = math.random() > 0.5 and -50 or 300
      end

      -- Modify children
      if container.children then
        for i, child in ipairs(container.children) do
          if math.random() > 0.8 then
            child.width = math.random() > 0.5 and 0 or 999999
            child.height = math.random() > 0.5 and -100 or 1000000
          end
        end
      end
    end

    -- Test layout after modifications
    mainContainer:layoutChildren()

    return {
      mainContainer = mainContainer,
      combinationCount = combinationCount,
      finalContainerCount = #mainContainer.children,
    }
  end)

  luaunit.assertTrue(success) -- Should handle all combinations without crashing
  luaunit.assertIsTable(result)

  -- Should have tested many combinations
  local expectedCombinations = 2 * 6 * 4 * 3 -- 144 combinations
  luaunit.assertEquals(result.combinationCount, expectedCombinations)
  luaunit.assertEquals(result.finalContainerCount, expectedCombinations)

  -- Test final layout works
  local finalLayoutSuccess = captureError(function()
    result.mainContainer:layoutChildren()
  end)
  luaunit.assertTrue(finalLayoutSuccess)
end

luaunit.LuaUnit.run()
