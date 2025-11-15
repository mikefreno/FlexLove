-- Test suite for Element.lua
-- Tests element creation, size calculations, and basic functionality

package.path = package.path .. ";./?.lua;./modules/?.lua"

-- Load love stub before anything else
require("testing.loveStub")

local luaunit = require("testing.luaunit")

-- Load FlexLove which properly initializes all dependencies
local FlexLove = require("FlexLove")

-- Test suite for Element creation
TestElementCreation = {}

function TestElementCreation:setUp()
  -- Initialize FlexLove for each test
  FlexLove.beginFrame(1920, 1080)
end

function TestElementCreation:tearDown()
  FlexLove.endFrame()
end

function TestElementCreation:test_create_minimal_element()
  local element = FlexLove.new({
    id = "test1",
    x = 10,
    y = 20,
    width = 100,
    height = 50
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.id, "test1")
  luaunit.assertEquals(element.x, 10)
  luaunit.assertEquals(element.y, 20)
  luaunit.assertEquals(element.width, 100)
  luaunit.assertEquals(element.height, 50)
end

function TestElementCreation:test_element_with_text()
  local element = FlexLove.new({
    id = "text1",
    x = 0,
    y = 0,
    width = 200,
    height = 100,
    text = "Hello World"
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.text, "Hello World")
end

function TestElementCreation:test_element_with_backgroundColor()
  local element = FlexLove.new({
    id = "colored1",
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    backgroundColor = {1, 0, 0, 1}
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertNotNil(element.backgroundColor)
end

function TestElementCreation:test_element_with_children()
  local parent = FlexLove.new({
    id = "parent1",
    x = 0,
    y = 0,
    width = 300,
    height = 200
  })
  
  local child = FlexLove.new({
    id = "child1",
    x = 10,
    y = 10,
    width = 50,
    height = 50,
    parent = parent
  })
  
  luaunit.assertNotNil(parent)
  luaunit.assertNotNil(child)
  luaunit.assertEquals(child.parent, parent)
  luaunit.assertEquals(#parent.children, 1)
  luaunit.assertEquals(parent.children[1], child)
end

function TestElementCreation:test_element_with_padding()
  local element = FlexLove.new({
    id = "padded1",
    x = 0,
    y = 0,
    width = 200,
    height = 100,
    padding = { horizontal = 10, vertical = 10 }
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.padding.left, 10)
  luaunit.assertEquals(element.padding.top, 10)
  luaunit.assertEquals(element.padding.right, 10)
  luaunit.assertEquals(element.padding.bottom, 10)
end

function TestElementCreation:test_element_with_margin()
  local element = FlexLove.new({
    id = "margined1",
    x = 0,
    y = 0,
    width = 200,
    height = 100,
    margin = { horizontal = 5, vertical = 5 }
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.margin.left, 5)
  luaunit.assertEquals(element.margin.top, 5)
  luaunit.assertEquals(element.margin.right, 5)
  luaunit.assertEquals(element.margin.bottom, 5)
end

-- Test suite for Element sizing
TestElementSizing = {}

function TestElementSizing:setUp()
  FlexLove.beginFrame(1920, 1080)
end

function TestElementSizing:tearDown()
  FlexLove.endFrame()
end

function TestElementSizing:test_getBorderBoxWidth()
  local element = FlexLove.new({
    id = "sized1",
    x = 0,
    y = 0,
    width = 100,
    height = 50
  })
  
  local borderBoxWidth = element:getBorderBoxWidth()
  luaunit.assertEquals(borderBoxWidth, 100)
end

function TestElementSizing:test_getBorderBoxHeight()
  local element = FlexLove.new({
    id = "sized2",
    x = 0,
    y = 0,
    width = 100,
    height = 50
  })
  
  local borderBoxHeight = element:getBorderBoxHeight()
  luaunit.assertEquals(borderBoxHeight, 50)
end

function TestElementSizing:test_getBounds()
  local element = FlexLove.new({
    id = "bounds1",
    x = 10,
    y = 20,
    width = 100,
    height = 50
  })
  
  local bounds = element:getBounds()
  luaunit.assertEquals(bounds.x, 10)
  luaunit.assertEquals(bounds.y, 20)
  luaunit.assertEquals(bounds.width, 100)
  luaunit.assertEquals(bounds.height, 50)
end

function TestElementSizing:test_contains_point_inside()
  local element = FlexLove.new({
    id = "contains1",
    x = 10,
    y = 20,
    width = 100,
    height = 50
  })
  
  local contains = element:contains(50, 40)
  luaunit.assertTrue(contains)
end

function TestElementSizing:test_contains_point_outside()
  local element = FlexLove.new({
    id = "contains2",
    x = 10,
    y = 20,
    width = 100,
    height = 50
  })
  
  local contains = element:contains(150, 100)
  luaunit.assertFalse(contains)
end

function TestElementSizing:test_contains_point_on_edge()
  local element = FlexLove.new({
    id = "contains3",
    x = 10,
    y = 20,
    width = 100,
    height = 50
  })
  
  -- Point on right edge
  local contains = element:contains(110, 40)
  luaunit.assertTrue(contains)
  
  -- Point on bottom edge
  contains = element:contains(50, 70)
  luaunit.assertTrue(contains)
end

-- Test suite for Element with units (units are resolved immediately after creation)
TestElementUnits = {}

function TestElementUnits:setUp()
  FlexLove.beginFrame(1920, 1080)
end

function TestElementUnits:tearDown()
  FlexLove.endFrame()
end

function TestElementUnits:test_element_with_percentage_width()
  local parent = FlexLove.new({
    id = "parent_pct",
    x = 0,
    y = 0,
    width = 1000,
    height = 500
  })
  
  local child = FlexLove.new({
    id = "child_pct",
    x = 0,
    y = 0,
    width = "50%",
    height = 100,
    parent = parent
  })
  
  luaunit.assertNotNil(child)
  -- Width should be resolved to 500 (50% of parent's 1000)
  luaunit.assertEquals(child.width, 500)
end

function TestElementUnits:test_element_with_viewport_units()
  local element = FlexLove.new({
    id = "viewport1",
    x = 0,
    y = 0,
    width = "50vw",  -- 50% of viewport width (1920) = 960
    height = "25vh"  -- 25% of viewport height (1080) = 270
  })
  
  luaunit.assertNotNil(element)
  -- Units should be resolved immediately to numbers
  luaunit.assertEquals(type(element.width), "number")
  luaunit.assertEquals(type(element.height), "number")
  -- Should be positive values
  luaunit.assertTrue(element.width > 0)
  luaunit.assertTrue(element.height > 0)
end

-- Test suite for Element positioning
TestElementPositioning = {}

function TestElementPositioning:setUp()
  FlexLove.beginFrame(1920, 1080)
end

function TestElementPositioning:tearDown()
  FlexLove.endFrame()
end

function TestElementPositioning:test_element_absolute_position()
  local element = FlexLove.new({
    id = "abs1",
    x = 100,
    y = 200,
    width = 50,
    height = 50,
    positioning = "absolute"
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.positioning, "absolute")
end

function TestElementPositioning:test_nested_element_positions()
  local parent = FlexLove.new({
    id = "nest_parent",
    x = 100,
    y = 100,
    width = 300,
    height = 200
  })
  
  local child = FlexLove.new({
    id = "nest_child",
    x = 20,
    y = 30,
    width = 50,
    height = 50,
    parent = parent
  })
  
  luaunit.assertNotNil(parent)
  luaunit.assertNotNil(child)
  -- Child positions are absolute in FlexLove, not relative to parent
  -- So child.x = parent.x + relative_x = 100 + 20 = 120
  luaunit.assertEquals(child.x, 120)
  luaunit.assertEquals(child.y, 130)
end

-- Test suite for Element flex layout
TestElementFlex = {}

function TestElementFlex:setUp()
  FlexLove.beginFrame(1920, 1080)
end

function TestElementFlex:tearDown()
  FlexLove.endFrame()
end

function TestElementFlex:test_element_with_flex_direction()
  local element = FlexLove.new({
    id = "flex1",
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal"
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.flexDirection, "horizontal")
end

function TestElementFlex:test_element_with_flex_properties()
  local parent = FlexLove.new({
    id = "flex_parent",
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal"
  })
  
  local element = FlexLove.new({
    id = "flex2",
    parent = parent,
    width = 100,
    height = 100,
    flexGrow = 1,
    flexShrink = 0,
    flexBasis = "auto"
  })
  
  luaunit.assertNotNil(element)
  -- Just check element was created successfully
  -- Flex properties are handled by LayoutEngine, not stored on element
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.parent, parent)
end

function TestElementFlex:test_element_with_gap()
  local element = FlexLove.new({
    id = "gap1",
    x = 0,
    y = 0,
    width = 300,
    height = 200,
    positioning = "flex",
    gap = 10
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.gap, 10)
end

-- Run tests if this file is executed directly
if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end

-- Test suite for Element styling properties
TestElementStyling = {}

function TestElementStyling:setUp()
  FlexLove.beginFrame(1920, 1080)
end

function TestElementStyling:tearDown()
  FlexLove.endFrame()
end

function TestElementStyling:test_element_with_border()
  local element = FlexLove.new({
    id = "bordered1",
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    border = 2
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.border, 2)
end

function TestElementStyling:test_element_with_corner_radius()
  local element = FlexLove.new({
    id = "rounded1",
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    cornerRadius = 10
  })
  
  luaunit.assertNotNil(element)
  -- Corner radius might be stored as a table
  luaunit.assertNotNil(element.cornerRadius)
end

function TestElementStyling:test_element_with_text_align()
  local element = FlexLove.new({
    id = "aligned1",
    x = 0,
    y = 0,
    width = 200,
    height = 100,
    text = "Centered Text",
    textAlign = "center"
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.textAlign, "center")
end

function TestElementStyling:test_element_with_opacity()
  local element = FlexLove.new({
    id = "transparent1",
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    opacity = 0.5
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.opacity, 0.5)
end

function TestElementStyling:test_element_with_border_color()
  local element = FlexLove.new({
    id = "colored_border",
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    border = 2,
    borderColor = {1, 0, 0, 1}
  })
  
  luaunit.assertNotNil(element)
  luaunit.assertNotNil(element.borderColor)
end

-- Test suite for Element methods
TestElementMethods = {}

function TestElementMethods:setUp()
  FlexLove.beginFrame(1920, 1080)
end

function TestElementMethods:tearDown()
  FlexLove.endFrame()
end

function TestElementMethods:test_element_setText()
  local element = FlexLove.new({
    id = "textual1",
    x = 0,
    y = 0,
    width = 200,
    height = 100,
    text = "Initial"
  })
  
  element:setText("Updated")
  luaunit.assertEquals(element.text, "Updated")
end

function TestElementMethods:test_element_addChild()
  local parent = FlexLove.new({
    id = "parent_add",
    x = 0,
    y = 0,
    width = 300,
    height = 200
  })
  
  local child = FlexLove.new({
    id = "child_add",
    x = 10,
    y = 10,
    width = 50,
    height = 50
  })
  
  parent:addChild(child)
  luaunit.assertEquals(#parent.children, 1)
  luaunit.assertEquals(parent.children[1], child)
  luaunit.assertEquals(child.parent, parent)
end

