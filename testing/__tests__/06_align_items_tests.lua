-- 06. Align Items Tests
-- Tests for FlexLove align items functionality

-- Load test framework and dependencies
package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums

-- Import required enums
local Positioning = enums.Positioning
local FlexDirection = enums.FlexDirection
local AlignItems = enums.AlignItems

-- Test class for align items functionality
TestAlignItems = {}

function TestAlignItems:setUp()
    -- Clear any previous state if needed
    Gui.destroy()
end

function TestAlignItems:tearDown()
    -- Clean up after each test
    Gui.destroy()
end

-- Test 1: Horizontal Flex with AlignItems.FLEX_START
function TestAlignItems:testHorizontalFlexAlignItemsFlexStart()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.FLEX_START,
    })

    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40,
        positioning = Positioning.FLEX,
    })

    local child3 = Gui.new({
        id = "child3",
        w = 70,
        h = 20,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)
    container:addChild(child3)

    -- With FLEX_START, children should be aligned to top (start of cross axis)
    luaunit.assertEquals(child1.y, 0)
    luaunit.assertEquals(child2.y, 0)
    luaunit.assertEquals(child3.y, 0)
    
    -- Heights should remain original (no stretching)
    luaunit.assertEquals(child1.height, 30)
    luaunit.assertEquals(child2.height, 40)
    luaunit.assertEquals(child3.height, 20)
end

-- Test 2: Horizontal Flex with AlignItems.CENTER
function TestAlignItems:testHorizontalFlexAlignItemsCenter()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.CENTER,
    })

    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)

    -- Children should be centered vertically
    -- child1: (100 - 30) / 2 = 35
    -- child2: (100 - 40) / 2 = 30
    luaunit.assertEquals(child1.y, 35)
    luaunit.assertEquals(child2.y, 30)
    
    -- Heights should remain original
    luaunit.assertEquals(child1.height, 30)
    luaunit.assertEquals(child2.height, 40)
end

-- Test 3: Horizontal Flex with AlignItems.FLEX_END
function TestAlignItems:testHorizontalFlexAlignItemsFlexEnd()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.FLEX_END,
    })

    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)

    -- Children should be aligned to bottom (end of cross axis)
    -- child1: 100 - 30 = 70
    -- child2: 100 - 40 = 60
    luaunit.assertEquals(child1.y, 70)
    luaunit.assertEquals(child2.y, 60)
    
    -- Heights should remain original
    luaunit.assertEquals(child1.height, 30)
    luaunit.assertEquals(child2.height, 40)
end

-- Test 4: Horizontal Flex with AlignItems.STRETCH
function TestAlignItems:testHorizontalFlexAlignItemsStretch()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.STRETCH,
    })

    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)

    -- Children should be stretched to fill container height
    luaunit.assertEquals(child1.y, 0)
    luaunit.assertEquals(child2.y, 0)
    luaunit.assertEquals(child1.height, 100)
    luaunit.assertEquals(child2.height, 100)
end

-- Test 5: Vertical Flex with AlignItems.FLEX_START
function TestAlignItems:testVerticalFlexAlignItemsFlexStart()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 200,
        h = 300,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        alignItems = AlignItems.FLEX_START,
    })

    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    local child2 = Gui.new({
        id = "child2",
        w = 80,
        h = 40,
        positioning = Positioning.FLEX,
    })

    local child3 = Gui.new({
        id = "child3",
        w = 60,
        h = 35,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)
    container:addChild(child3)

    -- With FLEX_START, children should be aligned to left (start of cross axis)
    luaunit.assertEquals(child1.x, 0)
    luaunit.assertEquals(child2.x, 0)
    luaunit.assertEquals(child3.x, 0)
    
    -- Widths should remain original (no stretching)
    luaunit.assertEquals(child1.width, 50)
    luaunit.assertEquals(child2.width, 80)
    luaunit.assertEquals(child3.width, 60)
end

-- Test 6: Vertical Flex with AlignItems.CENTER
function TestAlignItems:testVerticalFlexAlignItemsCenter()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 200,
        h = 300,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        alignItems = AlignItems.CENTER,
    })

    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    local child2 = Gui.new({
        id = "child2",
        w = 80,
        h = 40,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)

    -- Children should be centered horizontally
    -- child1: (200 - 50) / 2 = 75
    -- child2: (200 - 80) / 2 = 60
    luaunit.assertEquals(child1.x, 75)
    luaunit.assertEquals(child2.x, 60)
    
    -- Widths should remain original
    luaunit.assertEquals(child1.width, 50)
    luaunit.assertEquals(child2.width, 80)
end

-- Test 7: Vertical Flex with AlignItems.FLEX_END
function TestAlignItems:testVerticalFlexAlignItemsFlexEnd()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 200,
        h = 300,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        alignItems = AlignItems.FLEX_END,
    })

    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    local child2 = Gui.new({
        id = "child2",
        w = 80,
        h = 40,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)

    -- Children should be aligned to right (end of cross axis)
    -- child1: 200 - 50 = 150
    -- child2: 200 - 80 = 120
    luaunit.assertEquals(child1.x, 150)
    luaunit.assertEquals(child2.x, 120)
    
    -- Widths should remain original
    luaunit.assertEquals(child1.width, 50)
    luaunit.assertEquals(child2.width, 80)
end

-- Test 8: Vertical Flex with AlignItems.STRETCH
function TestAlignItems:testVerticalFlexAlignItemsStretch()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 200,
        h = 300,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        alignItems = AlignItems.STRETCH,
    })

    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    local child2 = Gui.new({
        id = "child2",
        w = 80,
        h = 40,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)

    -- Children should be stretched to fill container width
    luaunit.assertEquals(child1.x, 0)
    luaunit.assertEquals(child2.x, 0)
    luaunit.assertEquals(child1.width, 200)
    luaunit.assertEquals(child2.width, 200)
end

-- Test 9: Default AlignItems value (should be STRETCH)
function TestAlignItems:testDefaultAlignItems()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        -- No alignItems specified, should default to STRETCH
    })

    local child = Gui.new({
        id = "child",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    container:addChild(child)

    -- Default should be STRETCH
    luaunit.assertEquals(container.alignItems, AlignItems.STRETCH)
    luaunit.assertEquals(child.height, 100) -- Should be stretched
end

-- Test 10: AlignItems with mixed child sizes
function TestAlignItems:testAlignItemsWithMixedChildSizes()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 120,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.CENTER,
    })

    local child1 = Gui.new({
        id = "child1",
        w = 40,
        h = 20,
        positioning = Positioning.FLEX,
    })

    local child2 = Gui.new({
        id = "child2",
        w = 50,
        h = 80,
        positioning = Positioning.FLEX,
    })

    local child3 = Gui.new({
        id = "child3",
        w = 60,
        h = 30,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)
    container:addChild(child3)

    -- All children should be centered vertically
    -- child1: (120 - 20) / 2 = 50
    -- child2: (120 - 80) / 2 = 20
    -- child3: (120 - 30) / 2 = 45
    luaunit.assertEquals(child1.y, 50)
    luaunit.assertEquals(child2.y, 20)
    luaunit.assertEquals(child3.y, 45)
end

-- Test 11: AlignItems with single child
function TestAlignItems:testAlignItemsWithSingleChild()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 200,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.FLEX_END,
    })

    local child = Gui.new({
        id = "child",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    container:addChild(child)

    -- Child should be aligned to bottom
    luaunit.assertEquals(child.y, 70) -- 100 - 30
end

-- Test 12: AlignItems with container coordinates
function TestAlignItems:testAlignItemsWithContainerCoordinates()
    local container = Gui.new({
        id = "container",
        x = 50,
        y = 20,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.CENTER,
    })

    local child = Gui.new({
        id = "child",
        w = 60,
        h = 40,
        positioning = Positioning.FLEX,
    })

    container:addChild(child)

    -- Child should be centered relative to container position
    -- Y position: container.y + (container.height - child.height) / 2
    -- Y position: 20 + (100 - 40) / 2 = 20 + 30 = 50
    luaunit.assertEquals(child.y, 50)
end

-- Test 13: AlignItems BASELINE (should behave like FLEX_START for now)
function TestAlignItems:testAlignItemsBaseline()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.BASELINE,
    })

    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)

    -- BASELINE should behave like FLEX_START for basic implementation
    luaunit.assertEquals(child1.y, 0)
    luaunit.assertEquals(child2.y, 0)
end

-- Test 14: AlignItems interaction with gap
function TestAlignItems:testAlignItemsWithGap()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.CENTER,
        gap = 10,
    })

    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    local child2 = Gui.new({
        id = "child2",
        w = 60,
        h = 40,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)

    -- Children should be centered vertically despite gap
    luaunit.assertEquals(child1.y, 35) -- (100 - 30) / 2
    luaunit.assertEquals(child2.y, 30) -- (100 - 40) / 2
    
    -- X positions should respect gap
    luaunit.assertEquals(child1.x, 0)
    luaunit.assertEquals(child2.x, 60) -- 50 + 10 gap
end

-- Test 15: AlignItems with different flex directions
function TestAlignItems:testAlignItemsCrossAxisConsistency()
    -- Horizontal container with vertical alignment
    local hContainer = Gui.new({
        id = "hContainer",
        x = 0, y = 0, w = 200, h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        alignItems = AlignItems.CENTER,
    })

    local hChild = Gui.new({
        id = "hChild",
        w = 50, h = 40,
        positioning = Positioning.FLEX,
    })

    hContainer:addChild(hChild)

    -- Vertical container with horizontal alignment
    local vContainer = Gui.new({
        id = "vContainer",
        x = 0, y = 0, w = 100, h = 200,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        alignItems = AlignItems.CENTER,
    })

    local vChild = Gui.new({
        id = "vChild",
        w = 40, h = 50,
        positioning = Positioning.FLEX,
    })

    vContainer:addChild(vChild)

    -- Both should be centered on their respective cross axes
    luaunit.assertEquals(hChild.y, 30) -- (100 - 40) / 2 - vertical centering
    luaunit.assertEquals(vChild.x, 30) -- (100 - 40) / 2 - horizontal centering
end

-- Run the tests
if arg and arg[0]:match("06_align_items_tests%.lua$") then
    os.exit(luaunit.LuaUnit.run())
end

return TestAlignItems