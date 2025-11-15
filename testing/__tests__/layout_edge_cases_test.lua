-- Test suite for layout edge cases and warnings
-- Tests untested code paths in LayoutEngine
package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local FlexLove = require("FlexLove")
local ErrorHandler = require("modules.ErrorHandler")

TestLayoutEdgeCases = {}

function TestLayoutEdgeCases:setUp()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
  -- Capture warnings
  self.warnings = {}
  self.originalWarn = ErrorHandler.warn
  ErrorHandler.warn = function(module, message)
    table.insert(self.warnings, {module = module, message = message})
  end
end

function TestLayoutEdgeCases:tearDown()
  -- Restore original warn function
  ErrorHandler.warn = self.originalWarn
  FlexLove.endFrame()
end

-- Test: Child with percentage width in auto-sizing parent should trigger warning
function TestLayoutEdgeCases:test_percentage_width_with_auto_parent_warns()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    -- width not specified - auto-sizing width
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal"
  })
  
  FlexLove.new({
    id = "child_with_percentage",
    parent = container,
    width = "50%",  -- Percentage width with auto-sizing parent - should warn
    height = 100
  })
  
  FlexLove.endFrame()
  FlexLove.beginFrame()
  
  -- Check that a warning was issued
  luaunit.assertTrue(#self.warnings > 0, "Should issue warning for percentage width with auto-sizing parent")
  
  local found = false
  for _, warning in ipairs(self.warnings) do
    if warning.message:match("percentage width") and warning.message:match("auto%-sizing") then
      found = true
      break
    end
  end
  
  luaunit.assertTrue(found, "Warning should mention percentage width and auto-sizing")
end

-- Test: Child with percentage height in auto-sizing parent should trigger warning
function TestLayoutEdgeCases:test_percentage_height_with_auto_parent_warns()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 200,
    -- height not specified - auto-sizing height
    positioning = "flex",
    flexDirection = "vertical"
  })
  
  FlexLove.new({
    id = "child_with_percentage",
    parent = container,
    width = 100,
    height = "50%"  -- Percentage height with auto-sizing parent - should warn
  })
  
  FlexLove.endFrame()
  FlexLove.beginFrame()
  
  -- Check that a warning was issued
  luaunit.assertTrue(#self.warnings > 0, "Should issue warning for percentage height with auto-sizing parent")
  
  local found = false
  for _, warning in ipairs(self.warnings) do
    if warning.message:match("percentage height") and warning.message:match("auto%-sizing") then
      found = true
      break
    end
  end
  
  luaunit.assertTrue(found, "Warning should mention percentage height and auto-sizing")
end

-- Test: Pixel-sized children in auto-sizing parent should NOT warn
function TestLayoutEdgeCases:test_pixel_width_with_auto_parent_no_warn()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    -- width not specified - auto-sizing
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal"
  })
  
  FlexLove.new({
    id = "child_with_pixels",
    parent = container,
    width = 100,  -- Pixel width - should NOT warn
    height = 100
  })
  
  FlexLove.endFrame()
  FlexLove.beginFrame()
  
  -- Check that NO warning was issued about percentage sizing
  for _, warning in ipairs(self.warnings) do
    local hasPercentageWarning = warning.message:match("percentage") and warning.message:match("auto%-sizing")
    luaunit.assertFalse(hasPercentageWarning, "Should not warn for pixel-sized children")
  end
end

-- Test: CSS positioning - top offset in absolute container
function TestLayoutEdgeCases:test_css_positioning_top_offset()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "absolute"
  })
  
  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 50,  -- 50px from top
    left = 0,
    width = 100,
    height = 100
  })
  
  -- Trigger layout by ending and restarting frame
  FlexLove.endFrame()
  FlexLove.beginFrame()
  
  -- Child should be positioned 50px from container's top edge (accounting for padding)
  local expectedY = container.y + container.padding.top + 50
  luaunit.assertEquals(child.y, expectedY, "Child should be positioned with top offset")
end

-- Test: CSS positioning - bottom offset in absolute container
function TestLayoutEdgeCases:test_css_positioning_bottom_offset()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "absolute"
  })
  
  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    bottom = 50,  -- 50px from bottom
    left = 0,
    width = 100,
    height = 100
  })
  
  FlexLove.endFrame()
  FlexLove.beginFrame()
  
  -- Child should be positioned 50px from container's bottom edge
  local expectedY = container.y + container.padding.top + container.height - 50 - child:getBorderBoxHeight()
  luaunit.assertEquals(child.y, expectedY, "Child should be positioned with bottom offset")
end

-- Test: CSS positioning - left offset in absolute container
function TestLayoutEdgeCases:test_css_positioning_left_offset()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "absolute"
  })
  
  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 0,
    left = 50,  -- 50px from left
    width = 100,
    height = 100
  })
  
  FlexLove.endFrame()
  FlexLove.beginFrame()
  
  -- Child should be positioned 50px from container's left edge
  local expectedX = container.x + container.padding.left + 50
  luaunit.assertEquals(child.x, expectedX, "Child should be positioned with left offset")
end

-- Test: CSS positioning - right offset in absolute container
function TestLayoutEdgeCases:test_css_positioning_right_offset()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "absolute"
  })
  
  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 0,
    right = 50,  -- 50px from right
    width = 100,
    height = 100
  })
  
  FlexLove.endFrame()
  FlexLove.beginFrame()
  
  -- Child should be positioned 50px from container's right edge
  local expectedX = container.x + container.padding.left + container.width - 50 - child:getBorderBoxWidth()
  luaunit.assertEquals(child.x, expectedX, "Child should be positioned with right offset")
end

-- Test: CSS positioning - combined top and bottom (bottom should take precedence or be ignored)
function TestLayoutEdgeCases:test_css_positioning_top_and_bottom()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "absolute"
  })
  
  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 10,
    bottom = 20,  -- Both specified - last one wins in current implementation
    left = 0,
    width = 100,
    height = 100
  })
  
  FlexLove.endFrame()
  FlexLove.beginFrame()
  
  -- Bottom should override top
  local expectedY = container.y + container.padding.top + container.height - 20 - child:getBorderBoxHeight()
  luaunit.assertEquals(child.y, expectedY, "Bottom offset should override top when both specified")
end

-- Test: CSS positioning - combined left and right (right should take precedence or be ignored)
function TestLayoutEdgeCases:test_css_positioning_left_and_right()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "absolute"
  })
  
  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 0,
    left = 10,
    right = 20,  -- Both specified - last one wins in current implementation
    width = 100,
    height = 100
  })
  
  FlexLove.endFrame()
  FlexLove.beginFrame()
  
  -- Right should override left
  local expectedX = container.x + container.padding.left + container.width - 20 - child:getBorderBoxWidth()
  luaunit.assertEquals(child.x, expectedX, "Right offset should override left when both specified")
end

-- Test: CSS positioning with padding in container
function TestLayoutEdgeCases:test_css_positioning_with_padding()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
    positioning = "absolute"
  })
  
  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 10,
    left = 10,
    width = 100,
    height = 100
  })
  
  FlexLove.endFrame()
  FlexLove.beginFrame()
  
  -- Offsets should be relative to content area (after padding)
  local expectedX = container.x + container.padding.left + 10
  local expectedY = container.y + container.padding.top + 10
  
  luaunit.assertEquals(child.x, expectedX, "Left offset should account for container padding")
  luaunit.assertEquals(child.y, expectedY, "Top offset should account for container padding")
end

-- Test: CSS positioning should NOT affect flex children
function TestLayoutEdgeCases:test_css_positioning_ignored_in_flex()
  local container = FlexLove.new({
    id = "container",
    x = 0,
    y = 0,
    width = 400,
    height = 400,
    positioning = "flex",
    flexDirection = "horizontal"
  })
  
  local child = FlexLove.new({
    id = "child",
    parent = container,
    top = 100,  -- This should be IGNORED in flex layout
    left = 100,  -- This should be IGNORED in flex layout
    width = 100,
    height = 100
  })
  
  FlexLove.endFrame()
  FlexLove.beginFrame()
  
  -- In flex layout, child should be positioned by flex rules, not CSS offsets
  -- Child should be at (0, 0) relative to container content area
  luaunit.assertEquals(child.x, 0, "CSS offsets should be ignored in flex layout")
  luaunit.assertEquals(child.y, 0, "CSS offsets should be ignored in flex layout")
end

-- Test: CSS positioning in relative container
function TestLayoutEdgeCases:test_css_positioning_in_relative_container()
  local container = FlexLove.new({
    id = "container",
    x = 100,
    y = 100,
    width = 400,
    height = 400,
    positioning = "relative"
  })
  
  local child = FlexLove.new({
    id = "child",
    parent = container,
    positioning = "absolute",
    top = 30,
    left = 30,
    width = 100,
    height = 100
  })
  
  FlexLove.endFrame()
  FlexLove.beginFrame()
  
  -- Should work the same as absolute container
  local expectedX = container.x + container.padding.left + 30
  local expectedY = container.y + container.padding.top + 30
  
  luaunit.assertEquals(child.x, expectedX, "CSS positioning should work in relative containers")
  luaunit.assertEquals(child.y, expectedY, "CSS positioning should work in relative containers")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
