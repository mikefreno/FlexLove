-- Test suite for absolute positioning child layout functionality
-- Tests that absolute positioned elements properly handle child elements
-- and don't interfere with flex layout calculations

package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums

local Positioning = enums.Positioning
local FlexDirection = enums.FlexDirection
local JustifyContent = enums.JustifyContent
local AlignItems = enums.AlignItems

-- Test class
TestAbsolutePositioningChildLayout = {}

function TestAbsolutePositioningChildLayout:setUp()
    -- Clean up before each test
    Gui.destroy()
end

function TestAbsolutePositioningChildLayout:tearDown()
    -- Clean up after each test
    Gui.destroy()
end

-- Test 1: Adding children to absolute positioned parents
function TestAbsolutePositioningChildLayout:testAddChildToAbsoluteParent()
    local parent = Gui.new({
        id = "absolute_parent",
        positioning = Positioning.ABSOLUTE,
        x = 100,
        y = 50,
        w = 200,
        h = 150
    })
    
    local child = Gui.new({
        id = "child",
        x = 10,
        y = 20,
        w = 50,
        h = 30
    })
    
    parent:addChild(child)
    
    -- Verify child was added
    luaunit.assertEquals(#parent.children, 1)
    luaunit.assertEquals(parent.children[1], child)
    luaunit.assertEquals(child.parent, parent)
end

-- Test 2: Children maintain their own coordinates
function TestAbsolutePositioningChildLayout:testChildrenMaintainCoordinates()
    local parent = Gui.new({
        id = "absolute_parent",
        positioning = Positioning.ABSOLUTE,
        x = 100,
        y = 50,
        w = 200,
        h = 150
    })
    
    local child1 = Gui.new({
        id = "child1",
        x = 10,
        y = 20,
        w = 50,
        h = 30
    })
    
    local child2 = Gui.new({
        id = "child2",
        x = 75,
        y = 85,
        w = 40,
        h = 25
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- Children should maintain their original coordinates
    luaunit.assertEquals(child1.x, 10)
    luaunit.assertEquals(child1.y, 20)
    luaunit.assertEquals(child2.x, 75)
    luaunit.assertEquals(child2.y, 85)
end

-- Test 3: Absolute positioned elements don't call layoutChildren() logic
function TestAbsolutePositioningChildLayout:testAbsoluteParentSkipsLayoutChildren()
    local parent = Gui.new({
        id = "absolute_parent",
        positioning = Positioning.ABSOLUTE,
        x = 100,
        y = 50,
        w = 200,
        h = 150,
        flexDirection = FlexDirection.HORIZONTAL
    })
    
    local child1 = Gui.new({
        id = "child1",
        x = 10,
        y = 20,
        w = 50,
        h = 30
    })
    
    local child2 = Gui.new({
        id = "child2",
        x = 200, -- Way beyond parent w - this would be repositioned in flex layout
        y = 300,
        w = 40,
        h = 25
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- In absolute positioning, children should keep their original positions
    -- regardless of flex direction or justification
    luaunit.assertEquals(child1.x, 10)
    luaunit.assertEquals(child1.y, 20)
    luaunit.assertEquals(child2.x, 200) -- Not repositioned by flex layout
    luaunit.assertEquals(child2.y, 300)
end

-- Test 4: Adding children to absolute parent doesn't affect parent's flex properties
function TestAbsolutePositioningChildLayout:testAbsoluteParentFlexPropertiesUnchanged()
    local parent = Gui.new({
        id = "absolute_parent",
        positioning = Positioning.ABSOLUTE,
        x = 100,
        y = 50,
        w = 200,
        h = 150,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.CENTER,
        alignItems = AlignItems.FLEX_END
    })
    
    local child = Gui.new({
        id = "child",
        x = 10,
        y = 20,
        w = 50,
        h = 30
    })
    
    -- Store original values
    local originalFlexDirection = parent.flexDirection
    local originalJustifyContent = parent.justifyContent
    local originalAlignItems = parent.alignItems
    local originalX = parent.x
    local originalY = parent.y
    
    parent:addChild(child)
    
    -- Parent properties should remain unchanged
    luaunit.assertEquals(parent.flexDirection, originalFlexDirection)
    luaunit.assertEquals(parent.justifyContent, originalJustifyContent)
    luaunit.assertEquals(parent.alignItems, originalAlignItems)
    luaunit.assertEquals(parent.x, originalX)
    luaunit.assertEquals(parent.y, originalY)
end

-- Test 5: Multiple children added to absolute parent maintain independent positioning
function TestAbsolutePositioningChildLayout:testMultipleChildrenIndependentPositioning()
    local parent = Gui.new({
        id = "absolute_parent",
        positioning = Positioning.ABSOLUTE,
        x = 0,
        y = 0,
        w = 300,
        h = 300
    })
    
    local children = {}
    for i = 1, 5 do
        children[i] = Gui.new({
            id = "child" .. i,
            x = i * 25,
            y = i * 30,
            w = 20,
            h = 15
        })
        parent:addChild(children[i])
    end
    
    -- Verify each child maintains its position
    for i = 1, 5 do
        luaunit.assertEquals(children[i].x, i * 25)
        luaunit.assertEquals(children[i].y, i * 30)
        luaunit.assertEquals(children[i].parent, parent)
    end
    
    luaunit.assertEquals(#parent.children, 5)
end

-- Test 6: Absolute children don't participate in flex layout of their parent
function TestAbsolutePositioningChildLayout:testAbsoluteChildrenIgnoreFlexLayout()
    local parent = Gui.new({
        id = "flex_parent",
        positioning = Positioning.FLEX,
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_BETWEEN
    })
    
    local flexChild = Gui.new({
        id = "flex_child",
        w = 50,
        h = 30
    })
    
    local absoluteChild = Gui.new({
        id = "absolute_child",
        positioning = Positioning.ABSOLUTE,
        x = 200,
        y = 40,
        w = 50,
        h = 30
    })
    
    parent:addChild(flexChild)
    parent:addChild(absoluteChild)
    
    -- The absolute child should maintain its position
    luaunit.assertEquals(absoluteChild.x, 200)
    luaunit.assertEquals(absoluteChild.y, 40)
    
    -- The flex child should be positioned by the flex layout (at the start since it's the only flex child)
    -- Note: exact positioning depends on flex implementation, but it shouldn't be at 200,40
    luaunit.assertNotEquals(flexChild.x, 200)
end

-- Test 7: Child coordinates remain independent of parent position changes
function TestAbsolutePositioningChildLayout:testChildCoordinatesIndependentOfParentChanges()
    local parent = Gui.new({
        id = "absolute_parent",
        positioning = Positioning.ABSOLUTE,
        x = 100,
        y = 50,
        w = 200,
        h = 150
    })
    
    local child = Gui.new({
        id = "child",
        x = 25,
        y = 30,
        w = 50,
        h = 40
    })
    
    parent:addChild(child)
    
    -- Change parent position
    parent.x = 300
    parent.y = 250
    
    -- Child coordinates should remain unchanged (they're relative to parent)
    luaunit.assertEquals(child.x, 25)
    luaunit.assertEquals(child.y, 30)
end

-- Test 8: Nested absolute positioning
function TestAbsolutePositioningChildLayout:testNestedAbsolutePositioning()
    local grandparent = Gui.new({
        id = "grandparent",
        positioning = Positioning.ABSOLUTE,
        x = 50,
        y = 25,
        w = 400,
        h = 300
    })
    
    local parent = Gui.new({
        id = "parent",
        positioning = Positioning.ABSOLUTE,
        x = 75,
        y = 50,
        w = 200,
        h = 150
    })
    
    local child = Gui.new({
        id = "child",
        x = 10,
        y = 20,
        w = 50,
        h = 30
    })
    
    grandparent:addChild(parent)
    parent:addChild(child)
    
    -- Verify the hierarchy
    luaunit.assertEquals(parent.parent, grandparent)
    luaunit.assertEquals(child.parent, parent)
    
    -- Verify positions are maintained at each level
    luaunit.assertEquals(grandparent.x, 50)
    luaunit.assertEquals(parent.x, 75)
    luaunit.assertEquals(child.x, 10)
end

-- Test 9: Absolute parent with flex children maintains flex properties
function TestAbsolutePositioningChildLayout:testAbsoluteParentWithFlexChildren()
    local parent = Gui.new({
        id = "absolute_parent",
        positioning = Positioning.ABSOLUTE,
        x = 100,
        y = 50,
        w = 200,
        h = 150
    })
    
    local flexChild = Gui.new({
        id = "flex_child",
        positioning = Positioning.FLEX,
        w = 50,
        h = 30
    })
    
    parent:addChild(flexChild)
    
    -- Child should maintain its flex positioning mode
    luaunit.assertEquals(flexChild.positioning, Positioning.FLEX)
    luaunit.assertEquals(flexChild.parent, parent)
end

-- Test 10: Auto-sizing behavior with absolute parent and children
function TestAbsolutePositioningChildLayout:testAutoSizingWithAbsoluteParentAndChildren()
    local parent = Gui.new({
        id = "absolute_parent",
        positioning = Positioning.ABSOLUTE,
        x = 100,
        y = 50
        -- No w/h specified, so it should auto-size
    })
    
    local child = Gui.new({
        id = "child",
        x = 10,
        y = 20,
        w = 50,
        h = 30
    })
    
    parent:addChild(child)
    
    -- Auto-sizing should still work for absolute parents
    -- (though the exact behavior may depend on implementation)
    luaunit.assertTrue(parent.width >= 0)
    luaunit.assertTrue(parent.height >= 0)
end

-- Test 11: Children added to absolute parent preserve their positioning type
function TestAbsolutePositioningChildLayout:testChildrenPreservePositioningType()
    local parent = Gui.new({
        id = "absolute_parent",
        positioning = Positioning.ABSOLUTE,
        x = 100,
        y = 50,
        w = 200,
        h = 150
    })
    
    local absoluteChild = Gui.new({
        id = "absolute_child",
        positioning = Positioning.ABSOLUTE,
        x = 25,
        y = 30,
        w = 50,
        h = 40
    })
    
    local flexChild = Gui.new({
        id = "flex_child",
        positioning = Positioning.FLEX,
        w = 60,
        h = 35
    })
    
    parent:addChild(absoluteChild)
    parent:addChild(flexChild)
    
    -- Children should maintain their original positioning types
    luaunit.assertEquals(absoluteChild.positioning, Positioning.ABSOLUTE)
    luaunit.assertEquals(flexChild.positioning, Positioning.FLEX)
end

-- Test 12: Parent-child coordinate relationships
function TestAbsolutePositioningChildLayout:testParentChildCoordinateRelationships()
    local parent = Gui.new({
        id = "absolute_parent",
        positioning = Positioning.ABSOLUTE,
        x = 100,
        y = 50,
        w = 200,
        h = 150
    })
    
    local child = Gui.new({
        id = "child",
        x = 25,
        y = 30,
        w = 50,
        h = 40
    })
    
    parent:addChild(child)
    
    -- Child coordinates should be relative to parent
    -- Note: This test verifies the conceptual relationship
    -- The actual implementation might handle coordinate systems differently
    luaunit.assertEquals(child.x, 25) -- Child maintains its relative coordinates
    luaunit.assertEquals(child.y, 30)
end

-- Test 13: Adding child doesn't trigger parent repositioning
function TestAbsolutePositioningChildLayout:testAddChildNoParentRepositioning()
    local parent = Gui.new({
        id = "absolute_parent",
        positioning = Positioning.ABSOLUTE,
        x = 150,
        y = 75,
        w = 200,
        h = 150
    })
    
    local originalX = parent.x
    local originalY = parent.y
    
    local child = Gui.new({
        id = "child",
        x = 25,
        y = 30,
        w = 50,
        h = 40
    })
    
    parent:addChild(child)
    
    -- Parent position should remain unchanged after adding child
    luaunit.assertEquals(parent.x, originalX)
    luaunit.assertEquals(parent.y, originalY)
end

-- Test 14: Children table is properly maintained
function TestAbsolutePositioningChildLayout:testChildrenTableMaintained()
    local parent = Gui.new({
        id = "absolute_parent",
        positioning = Positioning.ABSOLUTE,
        x = 100,
        y = 50,
        w = 200,
        h = 150
    })
    
    local child1 = Gui.new({id = "child1", x = 10, y = 20, w = 50, h = 30})
    local child2 = Gui.new({id = "child2", x = 70, y = 80, w = 40, h = 25})
    local child3 = Gui.new({id = "child3", x = 120, y = 90, w = 30, h = 35})
    
    parent:addChild(child1)
    luaunit.assertEquals(#parent.children, 1)
    luaunit.assertEquals(parent.children[1], child1)
    
    parent:addChild(child2)
    luaunit.assertEquals(#parent.children, 2)
    luaunit.assertEquals(parent.children[2], child2)
    
    parent:addChild(child3)
    luaunit.assertEquals(#parent.children, 3)
    luaunit.assertEquals(parent.children[3], child3)
    
    -- Verify all children have correct parent reference
    luaunit.assertEquals(child1.parent, parent)
    luaunit.assertEquals(child2.parent, parent)
    luaunit.assertEquals(child3.parent, parent)
end

-- Test 15: Absolute parent with mixed child types
function TestAbsolutePositioningChildLayout:testAbsoluteParentMixedChildTypes()
    local parent = Gui.new({
        id = "absolute_parent",
        positioning = Positioning.ABSOLUTE,
        x = 100,
        y = 50,
        w = 300,
        h = 200
    })
    
    local absoluteChild = Gui.new({
        id = "absolute_child",
        positioning = Positioning.ABSOLUTE,
        x = 25,
        y = 30,
        w = 50,
        h = 40
    })
    
    local flexChild = Gui.new({
        id = "flex_child",
        positioning = Positioning.FLEX,
        w = 60,
        h = 35
    })
    
    parent:addChild(absoluteChild)
    parent:addChild(flexChild)
    
    -- Both children should be added successfully
    luaunit.assertEquals(#parent.children, 2)
    luaunit.assertEquals(parent.children[1], absoluteChild)
    luaunit.assertEquals(parent.children[2], flexChild)
    
    -- Children should maintain their positioning types and properties
    luaunit.assertEquals(absoluteChild.positioning, Positioning.ABSOLUTE)
    luaunit.assertEquals(flexChild.positioning, Positioning.FLEX)
    luaunit.assertEquals(absoluteChild.x, 25)
    luaunit.assertEquals(absoluteChild.y, 30)
end

-- Run the tests
if arg and arg[0] == debug.getinfo(1, "S").source:sub(2) then
    os.exit(luaunit.LuaUnit.run())
end