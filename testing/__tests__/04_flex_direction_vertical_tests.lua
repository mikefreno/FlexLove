-- Test suite for vertical flex direction functionality
-- Tests that flex layout works correctly with vertical direction

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
TestVerticalFlexDirection = {}

function TestVerticalFlexDirection:setUp()
    -- Clean up before each test
    Gui.destroy()
end

function TestVerticalFlexDirection:tearDown()
    -- Clean up after each test
    Gui.destroy()
end

-- Test 1: Basic element creation with vertical flex direction
function TestVerticalFlexDirection:testCreateElementWithVerticalFlexDirection()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        x = 0,
        y = 0,
        w = 100,
        h = 300
    })
    
    -- Verify element was created with correct properties
    luaunit.assertEquals(parent.positioning, Positioning.FLEX)
    luaunit.assertEquals(parent.flexDirection, FlexDirection.VERTICAL)
    luaunit.assertEquals(parent.width, 100)
    luaunit.assertEquals(parent.height, 300)
end

-- Test 2: Single child vertical layout
function TestVerticalFlexDirection:testSingleChildVerticalLayout()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        x = 0,
        y = 0,
        w = 100,
        h = 300
    })
    
    local child = Gui.new({
        id = "single_child",
        w = 80,
        h = 50
    })
    
    parent:addChild(child)
    
    -- Child should be positioned at top of parent (flex-start default)
    luaunit.assertEquals(child.x, parent.x)
    luaunit.assertEquals(child.y, parent.y)
end

-- Test 3: Multiple children vertical layout
function TestVerticalFlexDirection:testMultipleChildrenVerticalLayout()
    local parent = Gui.new({
        id = "vertical_parent", 
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        x = 0,
        y = 0,
        w = 100,
        h = 300,
        gap = 10
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 80,
        h = 50
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 70,
        h = 40
    })
    
    local child3 = Gui.new({
        id = "child3",
        w = 60,
        h = 30
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    parent:addChild(child3)
    
    -- Children should be positioned vertically with gaps
    luaunit.assertEquals(child1.x, parent.x)
    luaunit.assertEquals(child1.y, parent.y)
    
    luaunit.assertEquals(child2.x, parent.x)
    luaunit.assertEquals(child2.y, child1.y + child1.height + parent.gap)
    
    luaunit.assertEquals(child3.x, parent.x)
    luaunit.assertEquals(child3.y, child2.y + child2.height + parent.gap)
end

-- Test 4: Empty parent (no children) vertical layout
function TestVerticalFlexDirection:testEmptyParentVerticalLayout()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        x = 0,
        y = 0,
        w = 100,
        h = 300
    })
    
    -- Should not cause any errors and should have no children
    luaunit.assertEquals(#parent.children, 0)
end

-- Test 5: Vertical layout with flex-start justification (default)
function TestVerticalFlexDirection:testVerticalLayoutFlexStart()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.FLEX_START,
        x = 0,
        y = 0,
        w = 100,
        h = 300,
        gap = 10
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 80,
        h = 50
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 70,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- Children should be positioned at top (flex-start)
    luaunit.assertEquals(child1.y, parent.y)
    luaunit.assertEquals(child2.y, child1.y + child1.height + parent.gap)
end

-- Test 6: Vertical layout with center justification
function TestVerticalFlexDirection:testVerticalLayoutCenter()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.CENTER,
        x = 0,
        y = 0,
        w = 100,
        h = 300,
        gap = 10
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 80,
        h = 50
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 70,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- Calculate expected center positioning
    local totalChildHeight = child1.height + child2.height + parent.gap
    local availableSpace = parent.height - totalChildHeight
    local startY = availableSpace / 2
    
    luaunit.assertEquals(child1.y, parent.y + startY)
    luaunit.assertEquals(child2.y, child1.y + child1.height + parent.gap)
end

-- Test 7: Vertical layout with flex-end justification
function TestVerticalFlexDirection:testVerticalLayoutFlexEnd()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.FLEX_END,
        x = 0,
        y = 0,
        w = 100,
        h = 300,
        gap = 10
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 80,
        h = 50
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 70,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- Calculate expected end positioning
    local totalChildHeight = child1.height + child2.height + parent.gap
    local availableSpace = parent.height - totalChildHeight
    local startY = availableSpace
    
    luaunit.assertEquals(child1.y, parent.y + startY)
    luaunit.assertEquals(child2.y, child1.y + child1.height + parent.gap)
end

-- Test 8: Single child with center justification
function TestVerticalFlexDirection:testSingleChildVerticalLayoutCentered()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.CENTER,
        x = 20,
        y = 10,
        w = 100,
        h = 300
    })
    
    local child = Gui.new({
        id = "single_child",
        w = 80,
        h = 50
    })
    
    parent:addChild(child)
    
    -- Single child with center justification should be centered
    local expectedY = parent.y + (parent.height - child.height) / 2
    luaunit.assertEquals(child.y, expectedY)
    luaunit.assertEquals(child.x, parent.x)
end

-- Test 9: Vertical layout maintains child widths
function TestVerticalFlexDirection:testVerticalLayoutMaintainsChildWidths()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        alignItems = AlignItems.FLEX_START, -- Explicitly set to maintain child widths
        x = 0,
        y = 0,
        w = 100,
        h = 300
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 80,
        h = 50
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40 -- Different width
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- In vertical layout, child widths should be preserved
    luaunit.assertEquals(child1.width, 80)
    luaunit.assertEquals(child2.width, 60)
end

-- Test 10: Vertical layout with align-items center
function TestVerticalFlexDirection:testVerticalLayoutAlignItemsCenter()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        alignItems = AlignItems.CENTER,
        x = 0,
        y = 0,
        w = 100,
        h = 300
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 80,
        h = 50
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- Children should be centered horizontally
    local expectedX1 = parent.x + (parent.width - child1.width) / 2
    local expectedX2 = parent.x + (parent.width - child2.width) / 2
    
    luaunit.assertEquals(child1.x, expectedX1)
    luaunit.assertEquals(child2.x, expectedX2)
end

-- Test 11: Vertical layout with align-items flex-end
function TestVerticalFlexDirection:testVerticalLayoutAlignItemsFlexEnd()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        alignItems = AlignItems.FLEX_END,
        x = 0,
        y = 0,
        w = 100,
        h = 300
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 80,
        h = 50
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- Children should be aligned to the right
    local expectedX1 = parent.x + parent.width - child1.width
    local expectedX2 = parent.x + parent.width - child2.width
    
    luaunit.assertEquals(child1.x, expectedX1)
    luaunit.assertEquals(child2.x, expectedX2)
end

-- Test 12: Vertical layout with align-items stretch
function TestVerticalFlexDirection:testVerticalLayoutAlignItemsStretch()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        alignItems = AlignItems.STRETCH,
        x = 0,
        y = 0,
        w = 100,
        h = 300
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 80,
        h = 50
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- Children should be stretched to fill parent width
    luaunit.assertEquals(child1.width, parent.width)
    luaunit.assertEquals(child2.width, parent.width)
end

-- Test 13: Vertical layout with space-between
function TestVerticalFlexDirection:testVerticalLayoutSpaceBetween()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        x = 0,
        y = 0,
        w = 100,
        h = 300,
        gap = 0 -- Space-between controls spacing, not gap
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 80,
        h = 50
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 70,
        h = 40
    })
    
    local child3 = Gui.new({
        id = "child3",
        w = 60,
        h = 30
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    parent:addChild(child3)
    
    -- First child should be at start
    luaunit.assertEquals(child1.y, parent.y)
    
    -- Last child should be at end  
    luaunit.assertEquals(child3.y, parent.y + parent.height - child3.height)
    
    -- Middle child should be evenly spaced
    local remainingSpace = parent.height - child1.height - child2.height - child3.height
    local spaceBetween = remainingSpace / 2
    luaunit.assertEquals(child2.y, child1.y + child1.height + spaceBetween)
end

-- Test 14: Vertical layout with custom gap
function TestVerticalFlexDirection:testVerticalLayoutCustomGap()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        x = 0,
        y = 0,
        w = 100,
        h = 300,
        gap = 20 -- Custom gap
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 80,
        h = 50
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 70,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- Children should be positioned with custom gap
    luaunit.assertEquals(child1.y, parent.y)
    luaunit.assertEquals(child2.y, child1.y + child1.height + 20)
end

-- Test 15: Vertical layout with positioning offset
function TestVerticalFlexDirection:testVerticalLayoutWithPositioningOffset()
    local parent = Gui.new({
        id = "vertical_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.CENTER,
        x = 50,
        y = 100,
        w = 100,
        h = 300
    })
    
    local child = Gui.new({
        id = "single_child",
        w = 80,
        h = 50
    })
    
    parent:addChild(child)
    
    -- Child should respect parent's position offset
    local expectedY = parent.y + (parent.height - child.height) / 2
    luaunit.assertEquals(child.x, parent.x)
    luaunit.assertEquals(child.y, expectedY)
end

-- Run the tests
os.exit(luaunit.LuaUnit.run())