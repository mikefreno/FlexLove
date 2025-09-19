-- 05. Justify Content Alignment Tests
-- Tests for FlexLove justify content functionality

-- Load test framework and dependencies
package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums

-- Import required enums
local Positioning = enums.Positioning
local FlexDirection = enums.FlexDirection
local JustifyContent = enums.JustifyContent

-- Test class for justify content functionality
TestJustifyContent = {}

function TestJustifyContent:setUp()
    -- Clear any previous state if needed
    Gui.destroy()
end

function TestJustifyContent:tearDown()
    -- Clean up after each test
    Gui.destroy()
end

-- Test 1: Horizontal Flex with JustifyContent.FLEX_START
function TestJustifyContent:testHorizontalFlexJustifyContentFlexStart()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.FLEX_START,
        gap = 0,
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
        h = 35,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)
    container:addChild(child3)

    -- With FLEX_START, children should be positioned from the start (left)
    luaunit.assertEquals(child1.x, 0)
    luaunit.assertEquals(child2.x, 50)
    luaunit.assertEquals(child3.x, 110)
    
    -- Y positions should be 0 (aligned to top by default)
    luaunit.assertEquals(child1.y, 0)
    luaunit.assertEquals(child2.y, 0)
    luaunit.assertEquals(child3.y, 0)
end

-- Test 2: Horizontal Flex with JustifyContent.CENTER
function TestJustifyContent:testHorizontalFlexJustifyContentCenter()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.CENTER,
        gap = 0,
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

    -- Total child width: 50 + 60 = 110
    -- Available space: 300 - 110 = 190
    -- Center offset: 190 / 2 = 95
    luaunit.assertEquals(child1.x, 95)
    luaunit.assertEquals(child2.x, 145)
end

-- Test 3: Horizontal Flex with JustifyContent.FLEX_END
function TestJustifyContent:testHorizontalFlexJustifyContentFlexEnd()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.FLEX_END,
        gap = 0,
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

    -- Total child width: 50 + 60 = 110
    -- Available space: 300 - 110 = 190
    -- Children should be positioned from the end
    luaunit.assertEquals(child1.x, 190)
    luaunit.assertEquals(child2.x, 240)
end

-- Test 4: Horizontal Flex with JustifyContent.SPACE_BETWEEN
function TestJustifyContent:testHorizontalFlexJustifyContentSpaceBetween()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        gap = 0,
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
        w = 40,
        h = 35,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)
    container:addChild(child3)

    -- Total child width: 50 + 60 + 40 = 150
    -- Available space: 300 - 150 = 150
    -- Space between 3 children: 150 / 2 = 75
    luaunit.assertEquals(child1.x, 0)
    luaunit.assertEquals(child2.x, 125) -- 0 + 50 + 75
    luaunit.assertEquals(child3.x, 260) -- 125 + 60 + 75
end

-- Test 5: Horizontal Flex with JustifyContent.SPACE_AROUND
function TestJustifyContent:testHorizontalFlexJustifyContentSpaceAround()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_AROUND,
        gap = 0,
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

    -- Total child width: 50 + 60 = 110
    -- Available space: 300 - 110 = 190
    -- Space around each: 190 / 2 = 95 (FlexLove divides by number of children)
    -- Start position: 95 / 2 = 47.5
    -- Item spacing: 0 + 95 = 95
    luaunit.assertEquals(child1.x, 47.5)
    luaunit.assertEquals(child2.x, 192.5) -- 47.5 + 50 + 95
end

-- Test 6: Horizontal Flex with JustifyContent.SPACE_EVENLY
function TestJustifyContent:testHorizontalFlexJustifyContentSpaceEvenly()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_EVENLY,
        gap = 0,
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

    -- Total child width: 50 + 60 = 110
    -- Available space: 300 - 110 = 190
    -- Space evenly: 190 / 3 = 63.33... (equal spaces at start, between, and end)
    local expectedSpace = 190 / 3
    luaunit.assertAlmostEquals(child1.x, expectedSpace, 0.01)
    luaunit.assertAlmostEquals(child2.x, expectedSpace + 50 + expectedSpace, 0.01)
end

-- Test 7: Vertical Flex with JustifyContent.FLEX_START
function TestJustifyContent:testVerticalFlexJustifyContentFlexStart()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 100,
        h = 300,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.FLEX_START,
        gap = 0,
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
        h = 35,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)
    container:addChild(child3)

    -- With FLEX_START, children should be positioned from the start (top)
    luaunit.assertEquals(child1.y, 0)
    luaunit.assertEquals(child2.y, 30)
    luaunit.assertEquals(child3.y, 70)
    
    -- X positions should be 0 (aligned to left by default)
    luaunit.assertEquals(child1.x, 0)
    luaunit.assertEquals(child2.x, 0)
    luaunit.assertEquals(child3.x, 0)
end

-- Test 8: Vertical Flex with JustifyContent.CENTER
function TestJustifyContent:testVerticalFlexJustifyContentCenter()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 100,
        h = 300,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.CENTER,
        gap = 0,
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

    -- Total child height: 30 + 40 = 70
    -- Available space: 300 - 70 = 230
    -- Center offset: 230 / 2 = 115
    luaunit.assertEquals(child1.y, 115)
    luaunit.assertEquals(child2.y, 145)
end

-- Test 9: Vertical Flex with JustifyContent.FLEX_END
function TestJustifyContent:testVerticalFlexJustifyContentFlexEnd()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 100,
        h = 300,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.FLEX_END,
        gap = 0,
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

    -- Total child height: 30 + 40 = 70
    -- Available space: 300 - 70 = 230
    -- Children should be positioned from the end
    luaunit.assertEquals(child1.y, 230)
    luaunit.assertEquals(child2.y, 260)
end

-- Test 10: Vertical Flex with JustifyContent.SPACE_BETWEEN
function TestJustifyContent:testVerticalFlexJustifyContentSpaceBetween()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 100,
        h = 300,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        gap = 0,
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
        w = 40,
        h = 35,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)
    container:addChild(child3)

    -- Total child height: 30 + 40 + 35 = 105
    -- Available space: 300 - 105 = 195
    -- Space between 3 children: 195 / 2 = 97.5
    luaunit.assertEquals(child1.y, 0)
    luaunit.assertEquals(child2.y, 127.5) -- 0 + 30 + 97.5
    luaunit.assertEquals(child3.y, 265) -- 127.5 + 40 + 97.5
end

-- Test 11: Vertical Flex with JustifyContent.SPACE_AROUND
function TestJustifyContent:testVerticalFlexJustifyContentSpaceAround()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 100,
        h = 300,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.SPACE_AROUND,
        gap = 0,
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

    -- Total child height: 30 + 40 = 70
    -- Available space: 300 - 70 = 230
    -- Space around each: 230 / 2 = 115 (FlexLove divides by number of children)
    -- Start position: 115 / 2 = 57.5
    -- Item spacing: 0 + 115 = 115
    luaunit.assertEquals(child1.y, 57.5)
    luaunit.assertEquals(child2.y, 202.5) -- 57.5 + 30 + 115
end

-- Test 12: Vertical Flex with JustifyContent.SPACE_EVENLY
function TestJustifyContent:testVerticalFlexJustifyContentSpaceEvenly()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 100,
        h = 300,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        justifyContent = JustifyContent.SPACE_EVENLY,
        gap = 0,
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

    -- Total child height: 30 + 40 = 70
    -- Available space: 300 - 70 = 230
    -- Space evenly: 230 / 3 = 76.67... (equal spaces at start, between, and end)
    local expectedSpace = 230 / 3
    luaunit.assertAlmostEquals(child1.y, expectedSpace, 0.01)
    luaunit.assertAlmostEquals(child2.y, expectedSpace + 30 + expectedSpace, 0.01)
end

-- Test 13: JustifyContent with Single Child
function TestJustifyContent:testJustifyContentWithSingleChild()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.CENTER,
        gap = 0,
    })

    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)

    -- With single child and CENTER, child should be centered
    -- Available space: 300 - 50 = 250
    -- Center offset: 250 / 2 = 125
    luaunit.assertEquals(child1.x, 125)
end

-- Test 14: JustifyContent with No Available Space
function TestJustifyContent:testJustifyContentWithNoAvailableSpace()
    local container = Gui.new({
        id = "container",
        x = 0,
        y = 0,
        w = 100,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.SPACE_BETWEEN,
        gap = 0,
    })

    local child1 = Gui.new({
        id = "child1",
        w = 50,
        h = 30,
        positioning = Positioning.FLEX,
    })

    local child2 = Gui.new({
        id = "child2",
        w = 50,
        h = 40,
        positioning = Positioning.FLEX,
    })

    container:addChild(child1)
    container:addChild(child2)

    -- Children exactly fill container width (100)
    -- Should fall back to FLEX_START behavior
    luaunit.assertEquals(child1.x, 0)
    luaunit.assertEquals(child2.x, 50)
end

-- Test 15: JustifyContent Preservation with Parent Coordinates
function TestJustifyContent:testJustifyContentWithParentCoordinates()
    local parent = Gui.new({
        id = "parent",
        x = 50,
        y = 30,
        w = 400,
        h = 200,
        positioning = Positioning.ABSOLUTE,
    })

    local container = Gui.new({
        id = "container",
        x = 20,
        y = 10,
        w = 300,
        h = 100,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.CENTER,
        gap = 0,
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

    parent:addChild(container)
    container:addChild(child1)
    container:addChild(child2)

    -- Container should maintain its own coordinates since parent is ABSOLUTE
    luaunit.assertEquals(container.x, 20) -- container keeps its own x
    luaunit.assertEquals(container.y, 10) -- container keeps its own y

    -- Children should be centered within container coordinate system
    -- Total child width: 50 + 60 = 110
    -- Available space: 300 - 110 = 190
    -- Center offset: 190 / 2 = 95
    -- Children are positioned in absolute coordinates: container.x + offset
    luaunit.assertEquals(child1.x, 115) -- container.x(20) + center_offset(95)
    luaunit.assertEquals(child2.x, 165) -- container.x(20) + center_offset(95) + child1.width(50)
end

-- Run the tests
if arg and arg[0]:match("05_justify_content_tests%.lua$") then
    os.exit(luaunit.LuaUnit.run())
end

return TestJustifyContent