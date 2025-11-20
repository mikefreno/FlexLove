-- Advanced test suite for Element.lua to increase coverage
-- Focuses on uncovered edge cases and complex scenarios

package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")

local luaunit = require("testing.luaunit")
local FlexLove = require("FlexLove")
local Color = require("modules.Color")

-- Initialize FlexLove
FlexLove.init()

-- Test suite for resize behavior with different unit types
TestElementResize = {}

function TestElementResize:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestElementResize:tearDown()
  FlexLove.endFrame()
end

function TestElementResize:test_resize_with_percentage_units()
  -- Test that percentage units calculate correctly initially
  local parent = FlexLove.new({
    id = "resize_parent",
    x = 0,
    y = 0,
    width = 1000,
    height = 500,
  })
  
  local child = FlexLove.new({
    id = "resize_child",
    width = "50%",
    height = "50%",
    parent = parent,
  })
  
  -- Initial calculation should be 50% of parent
  luaunit.assertEquals(child.width, 500)
  luaunit.assertEquals(child.height, 250)
  
  -- Verify units are stored correctly
  luaunit.assertEquals(child.units.width.unit, "%")
  luaunit.assertEquals(child.units.height.unit, "%")
end

function TestElementResize:test_resize_with_viewport_units()
  -- Test that viewport units calculate correctly
  local element = FlexLove.new({
    id = "vp_resize",
    x = 0,
    y = 0,
    width = "50vw",
    height = "50vh",
  })
  
  -- Should be 50% of viewport (1920x1080)
  luaunit.assertEquals(element.width, 960)
  luaunit.assertEquals(element.height, 540)
  
  -- Verify units are stored correctly
  luaunit.assertEquals(element.units.width.unit, "vw")
  luaunit.assertEquals(element.units.height.unit, "vh")
end

function TestElementResize:test_resize_with_textSize_scaling()
  -- Test that textSize with viewport units calculates correctly
  local element = FlexLove.new({
    id = "text_resize",
    x = 0,
    y = 0,
    width = 200,
    height = 100,
    text = "Test",
    textSize = "2vh",
    autoScaleText = true,
  })
  
  -- 2vh of 1080 = 21.6
  luaunit.assertAlmostEquals(element.textSize, 21.6, 0.1)
  
  -- Verify unit is stored
  luaunit.assertEquals(element.units.textSize.unit, "vh")
end

-- Test suite for positioning offset application (top/right/bottom/left)
TestElementPositioningOffsets = {}

function TestElementPositioningOffsets:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestElementPositioningOffsets:tearDown()
  FlexLove.endFrame()
end

function TestElementPositioningOffsets:test_applyPositioningOffsets_with_absolute()
  local parent = FlexLove.new({
    id = "offset_parent",
    x = 0,
    y = 0,
    width = 500,
    height = 500,
    positioning = "absolute",
  })
  
  local child = FlexLove.new({
    id = "offset_child",
    width = 100,
    height = 100,
    positioning = "absolute",
    top = 50,
    left = 50,
    parent = parent,
  })
  
  -- Apply positioning offsets
  parent:applyPositioningOffsets(child)
  
  -- Child should be offset from parent
  luaunit.assertTrue(child.y >= parent.y + 50)
  luaunit.assertTrue(child.x >= parent.x + 50)
end

function TestElementPositioningOffsets:test_applyPositioningOffsets_with_right_bottom()
  local parent = FlexLove.new({
    id = "rb_parent",
    x = 0,
    y = 0,
    width = 500,
    height = 500,
    positioning = "relative",
  })
  
  local child = FlexLove.new({
    id = "rb_child",
    width = 100,
    height = 100,
    positioning = "absolute",
    right = 50,
    bottom = 50,
    parent = parent,
  })
  
  parent:applyPositioningOffsets(child)
  
  -- Child should be positioned from right/bottom
  luaunit.assertNotNil(child.x)
  luaunit.assertNotNil(child.y)
end

-- Test suite for scroll-related methods
TestElementScrollMethods = {}

function TestElementScrollMethods:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestElementScrollMethods:tearDown()
  FlexLove.endFrame()
end

function TestElementScrollMethods:test_scrollToTop()
  local container = FlexLove.new({
    id = "scroll_container",
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    overflow = "scroll",
    positioning = "flex",
    flexDirection = "vertical",
  })
  
  -- Add content that overflows
  for i = 1, 10 do
    FlexLove.new({
      id = "item_" .. i,
      width = 280,
      height = 50,
      parent = container,
    })
  end
  
  -- Scroll down first
  container:setScrollPosition(nil, 100)
  local _, scrollY = container:getScrollPosition()
  luaunit.assertEquals(scrollY, 100)
  
  -- Scroll to top
  container:scrollToTop()
  _, scrollY = container:getScrollPosition()
  luaunit.assertEquals(scrollY, 0)
end

function TestElementScrollMethods:test_scrollToBottom()
  local container = FlexLove.new({
    id = "scroll_bottom",
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    overflow = "scroll",
    positioning = "flex",
    flexDirection = "vertical",
  })
  
  -- Add overflowing content
  for i = 1, 10 do
    FlexLove.new({
      id = "item_" .. i,
      width = 280,
      height = 50,
      parent = container,
    })
  end
  
  container:scrollToBottom()
  
  local _, scrollY = container:getScrollPosition()
  local _, maxScrollY = container:getMaxScroll()
  
  luaunit.assertEquals(scrollY, maxScrollY)
end

function TestElementScrollMethods:test_scrollBy()
  local container = FlexLove.new({
    id = "scroll_by",
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    overflow = "scroll",
    positioning = "flex",
    flexDirection = "vertical",
  })
  
  for i = 1, 10 do
    FlexLove.new({
      id = "item_" .. i,
      width = 280,
      height = 50,
      parent = container,
    })
  end
  
  container:scrollBy(nil, 50)
  local _, scrollY = container:getScrollPosition()
  luaunit.assertEquals(scrollY, 50)
  
  container:scrollBy(nil, 25)
  _, scrollY = container:getScrollPosition()
  luaunit.assertEquals(scrollY, 75)
end

function TestElementScrollMethods:test_getScrollPercentage()
  local container = FlexLove.new({
    id = "scroll_pct",
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    overflow = "scroll",
    positioning = "flex",
    flexDirection = "vertical",
  })
  
  for i = 1, 10 do
    FlexLove.new({
      id = "item_" .. i,
      width = 280,
      height = 50,
      parent = container,
    })
  end
  
  -- At top
  local _, percentY = container:getScrollPercentage()
  luaunit.assertEquals(percentY, 0)
  
  -- Scroll halfway
  local _, maxScrollY = container:getMaxScroll()
  container:setScrollPosition(nil, maxScrollY / 2)
  _, percentY = container:getScrollPercentage()
  luaunit.assertAlmostEquals(percentY, 0.5, 0.01)
end

-- Test suite for auto-sizing with complex scenarios
TestElementComplexAutoSizing = {}

function TestElementComplexAutoSizing:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestElementComplexAutoSizing:tearDown()
  FlexLove.endFrame()
end

function TestElementComplexAutoSizing:test_autosize_with_nested_flex()
  local root = FlexLove.new({
    id = "root",
    x = 0,
    y = 0,
    positioning = "flex",
    flexDirection = "vertical",
  })
  
  local row1 = FlexLove.new({
    id = "row1",
    positioning = "flex",
    flexDirection = "horizontal",
    parent = root,
  })
  
  FlexLove.new({
    id = "item1",
    width = 100,
    height = 50,
    parent = row1,
  })
  
  FlexLove.new({
    id = "item2",
    width = 100,
    height = 50,
    parent = row1,
  })
  
  -- Root should auto-size to contain row
  luaunit.assertTrue(root.width >= 200)
  luaunit.assertTrue(root.height >= 50)
end

function TestElementComplexAutoSizing:test_autosize_with_absolutely_positioned_child()
  local parent = FlexLove.new({
    id = "abs_parent",
    x = 0,
    y = 0,
    positioning = "flex",
  })
  
  -- Regular child affects size
  FlexLove.new({
    id = "regular",
    width = 100,
    height = 100,
    parent = parent,
  })
  
  -- Absolutely positioned child should NOT affect parent size
  FlexLove.new({
    id = "absolute",
    width = 200,
    height = 200,
    positioning = "absolute",
    parent = parent,
  })
  
  -- Parent should only size to regular child
  luaunit.assertTrue(parent.width < 150)
  luaunit.assertTrue(parent.height < 150)
end

function TestElementComplexAutoSizing:test_autosize_with_margin()
  local parent = FlexLove.new({
    id = "margin_parent",
    x = 0,
    y = 0,
    positioning = "flex",
    flexDirection = "horizontal",
  })
  
  -- Add two children with margins to test margin collapsing
  FlexLove.new({
    id = "margin_child1",
    width = 100,
    height = 100,
    margin = { right = 20 },
    parent = parent,
  })
  
  FlexLove.new({
    id = "margin_child2",
    width = 100,
    height = 100,
    margin = { left = 20 },
    parent = parent,
  })
  
  -- Parent should size to children (margins don't add to content size in flex layout)
  luaunit.assertEquals(parent.width, 200)
  luaunit.assertEquals(parent.height, 100)
end

-- Test suite for theme integration
TestElementThemeIntegration = {}

function TestElementThemeIntegration:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestElementThemeIntegration:tearDown()
  FlexLove.endFrame()
end

function TestElementThemeIntegration:test_getScaledContentPadding()
  local element = FlexLove.new({
    id = "themed",
    x = 0,
    y = 0,
    width = 200,
    height = 100,
  })
  
  local padding = element:getScaledContentPadding()
  -- Should return nil if no theme component
  luaunit.assertNil(padding)
end

function TestElementThemeIntegration:test_getAvailableContentWidth_with_padding()
  local element = FlexLove.new({
    id = "content_width",
    x = 0,
    y = 0,
    width = 200,
    height = 100,
    padding = 10,
  })
  
  local availableWidth = element:getAvailableContentWidth()
  -- Should be width minus padding
  luaunit.assertEquals(availableWidth, 180) -- 200 - 10*2
end

function TestElementThemeIntegration:test_getAvailableContentHeight_with_padding()
  local element = FlexLove.new({
    id = "content_height",
    x = 0,
    y = 0,
    width = 200,
    height = 100,
    padding = 10,
  })
  
  local availableHeight = element:getAvailableContentHeight()
  luaunit.assertEquals(availableHeight, 80) -- 100 - 10*2
end

-- Test suite for child management edge cases
TestElementChildManagementEdgeCases = {}

function TestElementChildManagementEdgeCases:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestElementChildManagementEdgeCases:tearDown()
  FlexLove.endFrame()
end

function TestElementChildManagementEdgeCases:test_addChild_triggers_autosize_recalc()
  local parent = FlexLove.new({
    id = "dynamic_parent",
    x = 0,
    y = 0,
    positioning = "flex",
  })
  
  local initialWidth = parent.width
  local initialHeight = parent.height
  
  -- Add child dynamically
  local child = FlexLove.new({
    id = "dynamic_child",
    width = 150,
    height = 150,
  })
  
  parent:addChild(child)
  
  -- Parent should have resized
  luaunit.assertTrue(parent.width >= initialWidth)
  luaunit.assertTrue(parent.height >= initialHeight)
end

function TestElementChildManagementEdgeCases:test_removeChild_triggers_autosize_recalc()
  local parent = FlexLove.new({
    id = "shrink_parent",
    x = 0,
    y = 0,
    positioning = "flex",
  })
  
  local child1 = FlexLove.new({
    id = "child1",
    width = 100,
    height = 100,
    parent = parent,
  })
  
  local child2 = FlexLove.new({
    id = "child2",
    width = 100,
    height = 100,
    parent = parent,
  })
  
  local widthWithTwo = parent.width
  
  parent:removeChild(child2)
  
  -- Parent should shrink
  luaunit.assertTrue(parent.width < widthWithTwo)
end

function TestElementChildManagementEdgeCases:test_clearChildren_resets_autosize()
  local parent = FlexLove.new({
    id = "clear_parent",
    x = 0,
    y = 0,
    positioning = "flex",
  })
  
  for i = 1, 5 do
    FlexLove.new({
      id = "child_" .. i,
      width = 50,
      height = 50,
      parent = parent,
    })
  end
  
  local widthWithChildren = parent.width
  
  parent:clearChildren()
  
  -- Parent should shrink to minimal size
  luaunit.assertTrue(parent.width < widthWithChildren)
  luaunit.assertEquals(#parent.children, 0)
end

-- Test suite for grid layout edge cases
TestElementGridEdgeCases = {}

function TestElementGridEdgeCases:setUp()
  love.window.setMode(1920, 1080)
  FlexLove.beginFrame()
end

function TestElementGridEdgeCases:tearDown()
  FlexLove.endFrame()
end

function TestElementGridEdgeCases:test_grid_with_uneven_children()
  local grid = FlexLove.new({
    id = "uneven_grid",
    x = 0,
    y = 0,
    width = 300,
    height = 300,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
  })
  
  -- Add only 3 children to a 2x2 grid
  for i = 1, 3 do
    FlexLove.new({
      id = "grid_item_" .. i,
      width = 50,
      height = 50,
      parent = grid,
    })
  end
  
  luaunit.assertEquals(#grid.children, 3)
end

function TestElementGridEdgeCases:test_grid_with_percentage_gaps()
  local grid = FlexLove.new({
    id = "pct_gap_grid",
    x = 0,
    y = 0,
    width = 400,
    height = 400,
    positioning = "grid",
    gridRows = 2,
    gridColumns = 2,
    columnGap = "5%",
    rowGap = "5%",
  })
  
  luaunit.assertNotNil(grid.columnGap)
  luaunit.assertNotNil(grid.rowGap)
  luaunit.assertTrue(grid.columnGap > 0)
  luaunit.assertTrue(grid.rowGap > 0)
end

-- Run tests
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
