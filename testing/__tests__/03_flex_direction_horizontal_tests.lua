-- Test suite for horizontal flex direction functionality
-- Tests that flex layout works correctly with horizontal direction (default)

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
TestHorizontalFlexDirection = {}

function TestHorizontalFlexDirection:setUp()
    -- Clean up before each test
    Gui.destroy()
end

function TestHorizontalFlexDirection:tearDown()
    -- Clean up after each test
    Gui.destroy()
end

-- Test 1: Basic element creation with horizontal flex direction
function TestHorizontalFlexDirection:testCreateElementWithHorizontalFlexDirection()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        x = 0,
        y = 0,
        w = 300,
        h = 100
    })
    
    -- Verify element was created with correct properties
    luaunit.assertEquals(parent.positioning, Positioning.FLEX)
    luaunit.assertEquals(parent.flexDirection, FlexDirection.HORIZONTAL)
    luaunit.assertEquals(parent.width, 300)
    luaunit.assertEquals(parent.height, 100)
end

-- Test 2: Default flex direction should be horizontal
function TestHorizontalFlexDirection:testDefaultFlexDirectionIsHorizontal()
    local parent = Gui.new({
        id = "default_parent",
        positioning = Positioning.FLEX,
        x = 0,
        y = 0,
        w = 300,
        h = 100
    })
    
    -- Default flex direction should be horizontal
    luaunit.assertEquals(parent.flexDirection, FlexDirection.HORIZONTAL)
end

-- Test 3: Children positioned horizontally along x-axis
function TestHorizontalFlexDirection:testChildrenPositionedHorizontally()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        x = 0,
        y = 0,
        w = 300,
        h = 100
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40
    })
    
    local child3 = Gui.new({
        id = "child3",
        w = 40,
        h = 35
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    parent:addChild(child3)
    
    -- Children should be positioned horizontally
    -- child1 should be at x=0 (start)
    luaunit.assertEquals(child1.x, 0)
    
    -- child2 should be positioned after child1 + gap
    local expectedChild2X = child1.width + parent.gap
    luaunit.assertEquals(child2.x, expectedChild2X)
    
    -- child3 should be positioned after child2 + gap
    local expectedChild3X = child1.width + parent.gap + child2.width + parent.gap
    luaunit.assertEquals(child3.x, expectedChild3X)
    
    -- All children should have same y position as parent
    luaunit.assertEquals(child1.y, parent.y)
    luaunit.assertEquals(child2.y, parent.y)
    luaunit.assertEquals(child3.y, parent.y)
end

-- Test 4: Horizontal layout with gap property
function TestHorizontalFlexDirection:testHorizontalLayoutWithGap()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        gap = 20, -- Custom gap
        x = 0,
        y = 0,
        w = 300,
        h = 100
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- Verify gap is applied correctly
    luaunit.assertEquals(parent.gap, 20)
    luaunit.assertEquals(child1.x, 0)
    luaunit.assertEquals(child2.x, child1.width + 20) -- 50 + 20 = 70
end

-- Test 5: Horizontal layout with flex-start justification (default)
function TestHorizontalFlexDirection:testHorizontalLayoutFlexStart()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.FLEX_START,
        x = 0,
        y = 0,
        w = 300,
        h = 100
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- With flex-start, children should start at the beginning
    luaunit.assertEquals(child1.x, 0)
    luaunit.assertEquals(child2.x, child1.width + parent.gap)
end

-- Test 6: Horizontal layout with center justification
function TestHorizontalFlexDirection:testHorizontalLayoutCenter()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.CENTER,
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        gap = 10
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- Calculate expected center positioning
    local totalChildWidth = child1.width + child2.width + parent.gap
    local availableSpace = parent.width - totalChildWidth
    local startX = availableSpace / 2
    
    luaunit.assertEquals(child1.x, startX)
    luaunit.assertEquals(child2.x, startX + child1.width + parent.gap)
end

-- Test 7: Horizontal layout with flex-end justification
function TestHorizontalFlexDirection:testHorizontalLayoutFlexEnd()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.FLEX_END,
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        gap = 10
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- Calculate expected flex-end positioning
    local totalChildWidth = child1.width + child2.width + parent.gap
    local availableSpace = parent.width - totalChildWidth
    
    luaunit.assertEquals(child1.x, availableSpace)
    luaunit.assertEquals(child2.x, availableSpace + child1.width + parent.gap)
end

-- Test 8: Horizontal layout with space-between justification
function TestHorizontalFlexDirection:testHorizontalLayoutSpaceBetween()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        gap = 0 -- Space-between doesn't use gap, it distributes available space
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40
    })
    
    local child3 = Gui.new({
        id = "child3",
        w = 40,
        h = 35
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    parent:addChild(child3)
    
    -- With space-between, first child at start, last at end, others distributed
    luaunit.assertEquals(child1.x, 0)
    luaunit.assertEquals(child3.x, parent.width - child3.width)
    
    -- child2 should be positioned in the middle
    local availableSpace = parent.width - (child1.width + child2.width + child3.width)
    local spaceBetweenItems = availableSpace / 2 -- 2 gaps for 3 children
    luaunit.assertEquals(child2.x, child1.width + spaceBetweenItems)
end

-- Test 9: Single child in horizontal layout
function TestHorizontalFlexDirection:testSingleChildHorizontalLayout()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.CENTER,
        x = 10,
        y = 20,
        w = 300,
        h = 100
    })
    
    local child = Gui.new({
        id = "single_child",
        w = 50,
        h = 30
    })
    
    parent:addChild(child)
    
    -- Single child with center justification should be centered
    local expectedX = parent.x + (parent.width - child.width) / 2
    luaunit.assertEquals(child.x, expectedX)
    luaunit.assertEquals(child.y, parent.y)
end

-- Test 10: Empty parent (no children) horizontal layout
function TestHorizontalFlexDirection:testEmptyParentHorizontalLayout()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        x = 0,
        y = 0,
        w = 300,
        h = 100
    })
    
    -- No children added
    luaunit.assertEquals(#parent.children, 0)
    
    -- Should not cause any errors when layoutChildren is called
    parent:layoutChildren() -- This should not throw an error
end

-- Test 11: Horizontal layout coordinate system relative to parent
function TestHorizontalFlexDirection:testHorizontalLayoutCoordinateSystem()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        x = 100,
        y = 50,
        w = 300,
        h = 100
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- Children coordinates should be relative to parent position
    luaunit.assertEquals(child1.x, parent.x + 0) -- First child at parent's x
    luaunit.assertEquals(child1.y, parent.y)     -- Same y as parent
    
    luaunit.assertEquals(child2.x, parent.x + child1.width + parent.gap)
    luaunit.assertEquals(child2.y, parent.y)
end

-- Test 12: Horizontal layout maintains child heights
function TestHorizontalFlexDirection:testHorizontalLayoutMaintainsChildHeights()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.FLEX_START, -- Explicitly set to maintain child heights
        x = 0,
        y = 0,
        w = 300,
        h = 100
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 70 -- Different height
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- In horizontal layout, child heights should be preserved
    luaunit.assertEquals(child1.height, 30)
    luaunit.assertEquals(child2.height, 70)
end

-- Test 13: Horizontal layout with align-items stretch
function TestHorizontalFlexDirection:testHorizontalLayoutAlignItemsStretch()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.STRETCH,
        x = 0,
        y = 0,
        w = 300,
        h = 100
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- With align-items stretch in horizontal layout, children should stretch to parent height
    luaunit.assertEquals(child1.height, parent.height)
    luaunit.assertEquals(child2.height, parent.height)
end

-- Test 14: Horizontal layout with align-items center
function TestHorizontalFlexDirection:testHorizontalLayoutAlignItemsCenter()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.CENTER,
        x = 0,
        y = 0,
        w = 300,
        h = 100
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- With align-items center in horizontal layout, children should be centered vertically
    local expectedChild1Y = parent.y + (parent.height - child1.height) / 2
    local expectedChild2Y = parent.y + (parent.height - child2.height) / 2
    
    luaunit.assertEquals(child1.y, expectedChild1Y)
    luaunit.assertEquals(child2.y, expectedChild2Y)
end

-- Test 15: Horizontal layout with align-items flex-end
function TestHorizontalFlexDirection:testHorizontalLayoutAlignItemsFlexEnd()
    local parent = Gui.new({
        id = "horizontal_parent",
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.FLEX_END,
        x = 0,
        y = 0,
        w = 300,
        h = 100
    })
    
    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30
    })
    
    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40
    })
    
    parent:addChild(child1)
    parent:addChild(child2)
    
    -- With align-items flex-end in horizontal layout, children should be aligned to bottom
    local expectedChild1Y = parent.y + parent.height - child1.height
    local expectedChild2Y = parent.y + parent.height - child2.height
    
    luaunit.assertEquals(child1.y, expectedChild1Y)
    luaunit.assertEquals(child2.y, expectedChild2Y)
end

-- Run the tests
if arg and arg[0] == debug.getinfo(1, "S").source:sub(2) then
    os.exit(luaunit.LuaUnit.run())
end