package.path = package.path .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua"

local luaunit = require("testing.luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums

local Positioning = enums.Positioning

-- Create test cases for basic absolute positioning
TestAbsolutePositioningBasic = {}

function TestAbsolutePositioningBasic:setUp()
  -- Clean up before each test
  Gui.destroy()
end

function TestAbsolutePositioningBasic:tearDown()
  -- Clean up after each test
  Gui.destroy()
end

-- Test 1: Basic element creation with absolute positioning
function TestAbsolutePositioningBasic:testCreateElementWithAbsolutePositioning()
  local elem = Gui.new({
    x = 100,
    y = 200,
    width = 300,
    height = 150,
    positioning = Positioning.ABSOLUTE,
  })

  -- Verify element was created with correct properties
  luaunit.assertEquals(elem.x, 100)
  luaunit.assertEquals(elem.y, 200)
  luaunit.assertEquals(elem.width, 300)
  luaunit.assertEquals(elem.height, 150)
  luaunit.assertEquals(elem.positioning, Positioning.ABSOLUTE)

  -- Verify element was added to topElements
  luaunit.assertEquals(#Gui.topElements, 1)
  luaunit.assertEquals(Gui.topElements[1], elem)
end

-- Test 2: Default absolute positioning when no positioning specified
function TestAbsolutePositioningBasic:testDefaultAbsolutePositioning()
  local elem = Gui.new({
    x = 50,
    y = 75,
    width = 200,
    height = 100,
  })

  -- Default should be absolute positioning (RELATIVE not yet implemented)
  luaunit.assertEquals(elem.positioning, Positioning.ABSOLUTE)
  luaunit.assertEquals(elem.x, 50)
  luaunit.assertEquals(elem.y, 75)
end

-- Test 3: Z-index handling for absolute positioned elements
function TestAbsolutePositioningBasic:testZIndexHandling()
  local elem1 = Gui.new({
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    z = 1,
    positioning = Positioning.ABSOLUTE,
  })

  local elem2 = Gui.new({
    x = 50,
    y = 50,
    width = 100,
    height = 100,
    z = 5,
    positioning = Positioning.ABSOLUTE,
  })

  local elem3 = Gui.new({
    x = 25,
    y = 25,
    width = 100,
    height = 100,
    z = 3,
    positioning = Positioning.ABSOLUTE,
  })

  luaunit.assertEquals(elem1.z, 1)
  luaunit.assertEquals(elem2.z, 5)
  luaunit.assertEquals(elem3.z, 3)

  -- All should be in topElements
  luaunit.assertEquals(#Gui.topElements, 3)
end

-- Test 4: Default z-index is 0
function TestAbsolutePositioningBasic:testDefaultZIndex()
  local elem = Gui.new({
    x = 10,
    y = 20,
    width = 50,
    height = 50,
    positioning = Positioning.ABSOLUTE,
  })

  luaunit.assertEquals(elem.z, 0)
end

-- Test 5: Coordinate independence from other elements
function TestAbsolutePositioningBasic:testCoordinateIndependence()
  local elem1 = Gui.new({
    x = 100,
    y = 100,
    width = 50,
    height = 50,
    positioning = Positioning.ABSOLUTE,
  })

  local elem2 = Gui.new({
    x = 200,
    y = 200,
    width = 50,
    height = 50,
    positioning = Positioning.ABSOLUTE,
  })

  -- Elements should maintain their own coordinates
  luaunit.assertEquals(elem1.x, 100)
  luaunit.assertEquals(elem1.y, 100)
  luaunit.assertEquals(elem2.x, 200)
  luaunit.assertEquals(elem2.y, 200)

  -- Modifying one shouldn't affect the other
  elem1.x = 150
  luaunit.assertEquals(elem1.x, 150)
  luaunit.assertEquals(elem2.x, 200) -- Should remain unchanged
end

-- Test 6: Absolute positioned element with parent but should maintain own coordinates
function TestAbsolutePositioningBasic:testAbsoluteWithParentIndependentCoordinates()
  local parent = Gui.new({
    x = 50,
    y = 50,
    width = 200,
    height = 200,
    positioning = Positioning.ABSOLUTE,
  })

  local child = Gui.new({
    parent = parent,
    x = 25,
    y = 25,
    width = 50,
    height = 50,
    positioning = Positioning.ABSOLUTE,
  })

  -- Child should maintain its absolute coordinates (CSS absolute behavior)
  luaunit.assertEquals(child.x, 25)
  luaunit.assertEquals(child.y, 25)
  luaunit.assertEquals(child.positioning, Positioning.ABSOLUTE)

  -- Parent should have the child
  luaunit.assertEquals(#parent.children, 1)
  luaunit.assertEquals(parent.children[1], child)
end

-- Test 7: Multiple absolute elements should not interfere
function TestAbsolutePositioningBasic:testMultipleAbsoluteElementsNonInterference()
  local elements = {}

  for i = 1, 5 do
    elements[i] = Gui.new({
      x = i * 10,
      y = i * 20,
      width = 30,
      height = 40,
      z = i,
      positioning = Positioning.ABSOLUTE,
    })
  end

  -- Verify all elements maintain their properties
  for i = 1, 5 do
    luaunit.assertEquals(elements[i].x, i * 10)
    luaunit.assertEquals(elements[i].y, i * 20)
    luaunit.assertEquals(elements[i].width, 30)
    luaunit.assertEquals(elements[i].height, 40)
    luaunit.assertEquals(elements[i].z, i)
  end

  luaunit.assertEquals(#Gui.topElements, 5)
end

-- Test 8: Negative coordinates should work
function TestAbsolutePositioningBasic:testNegativeCoordinates()
  local elem = Gui.new({
    x = -50,
    y = -100,
    width = 200,
    height = 150,
    positioning = Positioning.ABSOLUTE,
  })

  luaunit.assertEquals(elem.x, -50)
  luaunit.assertEquals(elem.y, -100)
end

-- Test 9: Zero coordinates should work
function TestAbsolutePositioningBasic:testZeroCoordinates()
  local elem = Gui.new({
    x = 0,
    y = 0,
    width = 100,
    height = 100,
    positioning = Positioning.ABSOLUTE,
  })

  luaunit.assertEquals(elem.x, 0)
  luaunit.assertEquals(elem.y, 0)
end

-- Test 10: Default coordinates when not specified
function TestAbsolutePositioningBasic:testDefaultCoordinates()
  local elem = Gui.new({
    width = 100,
    height = 100,
    positioning = Positioning.ABSOLUTE,
  })

  -- Default coordinates should be 0,0
  luaunit.assertEquals(elem.x, 0)
  luaunit.assertEquals(elem.y, 0)
end

-- Test 11: Element bounds calculation
function TestAbsolutePositioningBasic:testElementBounds()
  local elem = Gui.new({
    x = 100,
    y = 200,
    width = 300,
    height = 400,
    positioning = Positioning.ABSOLUTE,
  })

  local bounds = elem:getBounds()
  luaunit.assertEquals(bounds.x, 100)
  luaunit.assertEquals(bounds.y, 200)
  luaunit.assertEquals(bounds.width, 300)
  luaunit.assertEquals(bounds.height, 400)
end

-- Test 12: Parent-child relationship with absolute positioning
function TestAbsolutePositioningBasic:testParentChildRelationshipAbsolute()
  local parent = Gui.new({
    x = 100,
    y = 100,
    width = 300,
    height = 300,
    positioning = Positioning.ABSOLUTE,
  })

  local child = Gui.new({
    parent = parent,
    x = 50,
    y = 75,
    width = 100,
    height = 150,
    positioning = Positioning.ABSOLUTE,
  })

  -- Verify parent-child relationship
  luaunit.assertEquals(child.parent, parent)
  luaunit.assertEquals(#parent.children, 1)
  luaunit.assertEquals(parent.children[1], child)

  -- Child should maintain absolute coordinates
  luaunit.assertEquals(child.x, 50)
  luaunit.assertEquals(child.y, 75)
end

-- Test 13: Absolute positioned child should not affect parent auto-sizing
function TestAbsolutePositioningBasic:testAbsoluteChildNoParentAutoSizeAffect()
  local parent = Gui.new({
    x = 0,
    y = 0,
    positioning = Positioning.ABSOLUTE,
  })

  local originalParentWidth = parent.width
  local originalParentHeight = parent.height

  local child = Gui.new({
    parent = parent,
    x = 1000, -- Far outside parent
    y = 1000,
    width = 500,
    height = 500,
    positioning = Positioning.ABSOLUTE,
  })

  -- Parent size should not be affected by absolute positioned child
  -- (In CSS, absolute children don't affect parent size)
  luaunit.assertEquals(parent.width, originalParentWidth)
  luaunit.assertEquals(parent.height, originalParentHeight)
end

-- Test 14: Verify absolute elements don't participate in flex layout
function TestAbsolutePositioningBasic:testAbsoluteNoFlexParticipation()
  local flexParent = Gui.new({
    x = 0,
    y = 0,
    width = 400,
    height = 200,
    positioning = Positioning.FLEX,
    flexDirection = enums.FlexDirection.HORIZONTAL,
  })

  local flexChild = Gui.new({
    parent = flexParent,
    width = 100,
    height = 50,
    positioning = Positioning.FLEX,
  })

  local absoluteChild = Gui.new({
    parent = flexParent,
    x = 300,
    y = 150,
    width = 80,
    height = 40,
    positioning = Positioning.ABSOLUTE,
  })

  -- Absolute child should maintain its coordinates
  luaunit.assertEquals(absoluteChild.x, 300)
  luaunit.assertEquals(absoluteChild.y, 150)
  luaunit.assertEquals(absoluteChild.positioning, Positioning.ABSOLUTE)

  -- Both children should be in parent
  luaunit.assertEquals(#flexParent.children, 2)
end

-- Test 15: Large coordinate values
function TestAbsolutePositioningBasic:testLargeCoordinateValues()
  local elem = Gui.new({
    x = 9999,
    y = 8888,
    width = 100,
    height = 100,
    z = 1000,
    positioning = Positioning.ABSOLUTE,
  })

  luaunit.assertEquals(elem.x, 9999)
  luaunit.assertEquals(elem.y, 8888)
  luaunit.assertEquals(elem.z, 1000)
end

-- ===========================================================================
-- COMPLEX TREE/BRANCHING STRUCTURE TESTS
-- ===========================================================================

-- Test 16: Complex nested absolute tree structure (4 levels deep)
function TestAbsolutePositioningBasic:testComplexNestedAbsoluteTree()
  -- Create a 4-level deep tree structure following CSS absolute positioning
  -- Root (absolute) -> Child1 (absolute) -> Grandchild1 (absolute) -> GreatGrandchild1 (absolute)
  --                 -> Child2 (absolute) -> Grandchild2 (absolute) -> GreatGrandchild2 (absolute)

  local root = Gui.new({
    id = "root",
    x = 100,
    y = 100,
    width = 800,
    height = 600,
    positioning = Positioning.ABSOLUTE,
    z = 1,
  })

  -- Left branch
  local child1 = Gui.new({
    parent = root,
    id = "child1",
    x = 50,
    y = 50,
    width = 300,
    height = 400,
    positioning = Positioning.ABSOLUTE,
    z = 2,
  })

  local grandchild1 = Gui.new({
    parent = child1,
    id = "grandchild1",
    x = 25,
    y = 25,
    width = 150,
    height = 200,
    positioning = Positioning.ABSOLUTE,
    z = 3,
  })

  local greatGrandchild1 = Gui.new({
    parent = grandchild1,
    id = "greatGrandchild1",
    x = 10,
    y = 10,
    width = 50,
    height = 75,
    positioning = Positioning.ABSOLUTE,
    z = 4,
  })

  -- Right branch
  local child2 = Gui.new({
    parent = root,
    id = "child2",
    x = 450,
    y = 50,
    width = 300,
    height = 400,
    positioning = Positioning.ABSOLUTE,
    z = 2,
  })

  local grandchild2 = Gui.new({
    parent = child2,
    id = "grandchild2",
    x = 125,
    y = 175,
    width = 150,
    height = 200,
    positioning = Positioning.ABSOLUTE,
    z = 3,
  })

  local greatGrandchild2 = Gui.new({
    parent = grandchild2,
    id = "greatGrandchild2",
    x = 90,
    y = 160,
    width = 50,
    height = 75,
    positioning = Positioning.ABSOLUTE,
    z = 4,
  })

  -- Verify tree structure
  luaunit.assertEquals(#root.children, 2)
  luaunit.assertEquals(root.children[1], child1)
  luaunit.assertEquals(root.children[2], child2)

  luaunit.assertEquals(#child1.children, 1)
  luaunit.assertEquals(child1.children[1], grandchild1)

  luaunit.assertEquals(#child2.children, 1)
  luaunit.assertEquals(child2.children[1], grandchild2)

  luaunit.assertEquals(#grandchild1.children, 1)
  luaunit.assertEquals(grandchild1.children[1], greatGrandchild1)

  luaunit.assertEquals(#grandchild2.children, 1)
  luaunit.assertEquals(grandchild2.children[1], greatGrandchild2)

  -- Verify absolute positioning behavior (all maintain their own coordinates)
  luaunit.assertEquals(child1.x, 50)
  luaunit.assertEquals(child1.y, 50)
  luaunit.assertEquals(child2.x, 450)
  luaunit.assertEquals(child2.y, 50)

  luaunit.assertEquals(grandchild1.x, 25)
  luaunit.assertEquals(grandchild1.y, 25)
  luaunit.assertEquals(grandchild2.x, 125)
  luaunit.assertEquals(grandchild2.y, 175)

  luaunit.assertEquals(greatGrandchild1.x, 10)
  luaunit.assertEquals(greatGrandchild1.y, 10)
  luaunit.assertEquals(greatGrandchild2.x, 90)
  luaunit.assertEquals(greatGrandchild2.y, 160)
end

-- Test 17: Binary tree structure with absolute positioning
function TestAbsolutePositioningBasic:testBinaryTreeAbsoluteStructure()
  -- Create a binary tree structure where each node has exactly 2 children
  local root = Gui.new({
    id = "root",
    x = 400,
    y = 100,
    width = 100,
    height = 50,
    positioning = Positioning.ABSOLUTE,
    z = 1,
  })

  -- Level 1
  local leftChild = Gui.new({
    parent = root,
    id = "left",
    x = 200,
    y = 200,
    width = 80,
    height = 40,
    positioning = Positioning.ABSOLUTE,
    z = 2,
  })

  local rightChild = Gui.new({
    parent = root,
    id = "right",
    x = 600,
    y = 200,
    width = 80,
    height = 40,
    positioning = Positioning.ABSOLUTE,
    z = 2,
  })

  -- Level 2 - Left subtree
  local leftLeft = Gui.new({
    parent = leftChild,
    id = "leftLeft",
    x = 100,
    y = 300,
    width = 60,
    height = 30,
    positioning = Positioning.ABSOLUTE,
    z = 3,
  })

  local leftRight = Gui.new({
    parent = leftChild,
    id = "leftRight",
    x = 300,
    y = 300,
    width = 60,
    height = 30,
    positioning = Positioning.ABSOLUTE,
    z = 3,
  })

  -- Level 2 - Right subtree
  local rightLeft = Gui.new({
    parent = rightChild,
    id = "rightLeft",
    x = 500,
    y = 300,
    width = 60,
    height = 30,
    positioning = Positioning.ABSOLUTE,
    z = 3,
  })

  local rightRight = Gui.new({
    parent = rightChild,
    id = "rightRight",
    x = 700,
    y = 300,
    width = 60,
    height = 30,
    positioning = Positioning.ABSOLUTE,
    z = 3,
  })

  -- Verify binary tree structure
  luaunit.assertEquals(#root.children, 2)
  luaunit.assertEquals(#leftChild.children, 2)
  luaunit.assertEquals(#rightChild.children, 2)
  luaunit.assertEquals(#leftLeft.children, 0)
  luaunit.assertEquals(#leftRight.children, 0)
  luaunit.assertEquals(#rightLeft.children, 0)
  luaunit.assertEquals(#rightRight.children, 0)

  -- Verify all nodes maintain their absolute positions
  luaunit.assertEquals(root.x, 400)
  luaunit.assertEquals(leftChild.x, 200)
  luaunit.assertEquals(rightChild.x, 600)
  luaunit.assertEquals(leftLeft.x, 100)
  luaunit.assertEquals(leftRight.x, 300)
  luaunit.assertEquals(rightLeft.x, 500)
  luaunit.assertEquals(rightRight.x, 700)
end

-- Test 18: Multi-branch tree with stacked z-indices (CSS z-index stacking context)
function TestAbsolutePositioningBasic:testMultiBranchZIndexStacking()
  -- Create overlapping elements with complex z-index hierarchies
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 1000,
    height = 1000,
    positioning = Positioning.ABSOLUTE,
    z = 0,
  })

  -- Background layer (z=1)
  local backgroundColor = Gui.new({
    parent = container,
    id = "background",
    x = 100,
    y = 100,
    width = 800,
    height = 800,
    positioning = Positioning.ABSOLUTE,
    z = 1,
  })

  -- Middle layer branch (z=5)
  local middleParent = Gui.new({
    parent = container,
    id = "middleParent",
    x = 200,
    y = 200,
    width = 600,
    height = 600,
    positioning = Positioning.ABSOLUTE,
    z = 5,
  })

  local middleChild1 = Gui.new({
    parent = middleParent,
    id = "middleChild1",
    x = 50,
    y = 50,
    width = 200,
    height = 200,
    positioning = Positioning.ABSOLUTE,
    z = 1, -- relative to middleParent
  })

  local middleChild2 = Gui.new({
    parent = middleParent,
    id = "middleChild2",
    x = 350,
    y = 350,
    width = 200,
    height = 200,
    positioning = Positioning.ABSOLUTE,
    z = 2, -- relative to middleParent, above middleChild1
  })

  -- Foreground layer (z=10)
  local foreground = Gui.new({
    parent = container,
    id = "foreground",
    x = 300,
    y = 300,
    width = 400,
    height = 400,
    positioning = Positioning.ABSOLUTE,
    z = 10,
  })

  local foregroundChild = Gui.new({
    parent = foreground,
    id = "foregroundChild",
    x = 150,
    y = 150,
    width = 100,
    height = 100,
    positioning = Positioning.ABSOLUTE,
    z = 1,
  })

  -- Verify stacking order by z-index
  luaunit.assertEquals(background.z, 1)
  luaunit.assertEquals(middleParent.z, 5)
  luaunit.assertEquals(middleChild1.z, 1)
  luaunit.assertEquals(middleChild2.z, 2)
  luaunit.assertEquals(foreground.z, 10)
  luaunit.assertEquals(foregroundChild.z, 1)

  -- Verify structure
  luaunit.assertEquals(#container.children, 3)
  luaunit.assertEquals(#middleParent.children, 2)
  luaunit.assertEquals(#foreground.children, 1)

  -- All elements should maintain their absolute positions
  luaunit.assertEquals(middleChild1.x, 50)
  luaunit.assertEquals(middleChild2.x, 350)
  luaunit.assertEquals(foregroundChild.x, 150)
end

-- Test 19: Wide shallow tree (many siblings at same level)
function TestAbsolutePositioningBasic:testWideShallowAbsoluteTree()
  local container = Gui.new({
    id = "container",
    x = 0,
    y = 0,
    width = 2000,
    height = 500,
    positioning = Positioning.ABSOLUTE,
    z = 0,
  })

  -- Create 10 siblings in a row
  local siblings = {}
  for i = 1, 10 do
    siblings[i] = Gui.new({
      parent = container,
      id = "sibling" .. i,
      x = i * 180,
      y = 100,
      width = 150,
      height = 300,
      positioning = Positioning.ABSOLUTE,
      z = i, -- Each has different z-index
    })

    -- Each sibling has 3 children
    for j = 1, 3 do
      Gui.new({
        parent = siblings[i],
        id = "child" .. i .. "_" .. j,
        x = 25,
        y = j * 80,
        width = 100,
        height = 60,
        positioning = Positioning.ABSOLUTE,
        z = j,
      })
    end
  end

  -- Verify wide structure
  luaunit.assertEquals(#container.children, 10)

  for i = 1, 10 do
    luaunit.assertEquals(#siblings[i].children, 3)
    luaunit.assertEquals(siblings[i].x, i * 180)
    luaunit.assertEquals(siblings[i].z, i)
  end
end

-- Test 20: Asymmetric tree with mixed absolute positioning
function TestAbsolutePositioningBasic:testAsymmetricAbsoluteTree()
  -- Root with asymmetric branch structure
  local root = Gui.new({
    id = "root",
    x = 500,
    y = 100,
    width = 200,
    height = 100,
    positioning = Positioning.ABSOLUTE,
    z = 1,
  })

  -- Left branch: deep nesting
  local leftBranch = Gui.new({
    parent = root,
    id = "leftBranch",
    x = 100,
    y = 250,
    width = 150,
    height = 400,
    positioning = Positioning.ABSOLUTE,
    z = 2,
  })

  local leftDeep1 = Gui.new({
    parent = leftBranch,
    id = "leftDeep1",
    x = 25,
    y = 50,
    width = 100,
    height = 80,
    positioning = Positioning.ABSOLUTE,
    z = 3,
  })

  local leftDeep2 = Gui.new({
    parent = leftDeep1,
    id = "leftDeep2",
    x = 10,
    y = 10,
    width = 80,
    height = 60,
    positioning = Positioning.ABSOLUTE,
    z = 4,
  })

  local leftDeep3 = Gui.new({
    parent = leftDeep2,
    id = "leftDeep3",
    x = 5,
    y = 5,
    width = 70,
    height = 50,
    positioning = Positioning.ABSOLUTE,
    z = 5,
  })

  -- Right branch: wide shallow
  local rightBranch = Gui.new({
    parent = root,
    id = "rightBranch",
    x = 800,
    y = 250,
    width = 400,
    height = 200,
    positioning = Positioning.ABSOLUTE,
    z = 2,
  })

  -- Multiple children for right branch
  for i = 1, 5 do
    Gui.new({
      parent = rightBranch,
      id = "rightChild" .. i,
      x = i * 70,
      y = 50,
      width = 60,
      height = 100,
      positioning = Positioning.ABSOLUTE,
      z = i,
    })
  end

  -- Verify asymmetric structure
  luaunit.assertEquals(#root.children, 2)
  luaunit.assertEquals(#leftBranch.children, 1) -- Deep chain
  luaunit.assertEquals(#rightBranch.children, 5) -- Wide spread

  -- Verify deep chain
  luaunit.assertEquals(#leftDeep1.children, 1)
  luaunit.assertEquals(#leftDeep2.children, 1)
  luaunit.assertEquals(#leftDeep3.children, 0)

  -- Verify positions maintained
  luaunit.assertEquals(leftBranch.x, 100)
  luaunit.assertEquals(rightBranch.x, 800)
  luaunit.assertEquals(leftDeep3.x, 5)
end

-- Test 21: Overlapping absolute elements with negative coordinates
function TestAbsolutePositioningBasic:testOverlappingNegativeCoordinates()
  local viewport = Gui.new({
    id = "viewport",
    x = 500,
    y = 500,
    width = 400,
    height = 400,
    positioning = Positioning.ABSOLUTE,
    z = 0,
  })

  -- Elements that extend outside viewport boundaries
  local topLeft = Gui.new({
    parent = viewport,
    id = "topLeft",
    x = -100,
    y = -100,
    width = 200,
    height = 200,
    positioning = Positioning.ABSOLUTE,
    z = 1,
  })

  local topRight = Gui.new({
    parent = viewport,
    id = "topRight",
    x = 300,
    y = -50,
    width = 200,
    height = 150,
    positioning = Positioning.ABSOLUTE,
    z = 2,
  })

  local bottomLeft = Gui.new({
    parent = viewport,
    id = "bottomLeft",
    x = -50,
    y = 350,
    width = 150,
    height = 200,
    positioning = Positioning.ABSOLUTE,
    z = 3,
  })

  local center = Gui.new({
    parent = viewport,
    id = "center",
    x = 150,
    y = 150,
    width = 100,
    height = 100,
    positioning = Positioning.ABSOLUTE,
    z = 10, -- Highest z-index
  })

  -- Verify negative coordinates are preserved
  luaunit.assertEquals(topLeft.x, -100)
  luaunit.assertEquals(topLeft.y, -100)
  luaunit.assertEquals(topRight.x, 300)
  luaunit.assertEquals(topRight.y, -50)
  luaunit.assertEquals(bottomLeft.x, -50)
  luaunit.assertEquals(bottomLeft.y, 350)

  -- Center element with highest z-index
  luaunit.assertEquals(center.z, 10)
  luaunit.assertEquals(center.x, 150)
  luaunit.assertEquals(center.y, 150)

  luaunit.assertEquals(#viewport.children, 4)
end

-- Test 22: Tree with circular-like positioning (elements in circle pattern)
function TestAbsolutePositioningBasic:testCircularPositioningPattern()
  local center = Gui.new({
    id = "center",
    x = 400,
    y = 400,
    width = 100,
    height = 100,
    positioning = Positioning.ABSOLUTE,
    z = 1,
  })

  -- Create 8 elements positioned in a circle around center
  local radius = 200
  local centerX, centerY = 450, 450 -- Center point of circle

  for i = 1, 8 do
    local angle = (i - 1) * (math.pi * 2 / 8) -- 8 evenly spaced angles
    local x = centerX + radius * math.cos(angle)
    local y = centerY + radius * math.sin(angle)

    local orbiter = Gui.new({
      parent = center,
      id = "orbiter" .. i,
      x = math.floor(x),
      y = math.floor(y),
      width = 50,
      height = 50,
      positioning = Positioning.ABSOLUTE,
      z = i,
    })

    -- Each orbiter has a small child
    Gui.new({
      parent = orbiter,
      id = "orbiterChild" .. i,
      x = 10,
      y = 10,
      width = 30,
      height = 30,
      positioning = Positioning.ABSOLUTE,
      z = 1,
    })
  end

  -- Verify circular structure
  luaunit.assertEquals(#center.children, 8)

  for i = 1, 8 do
    luaunit.assertEquals(#center.children[i].children, 1)
    luaunit.assertEquals(center.children[i].z, i)
  end
end

-- Test 23: Deep single-branch chain (maximum depth test)
function TestAbsolutePositioningBasic:testDeepSingleBranchChain()
  local current = Gui.new({
    id = "root",
    x = 100,
    y = 100,
    width = 500,
    height = 500,
    positioning = Positioning.ABSOLUTE,
    z = 1,
  })

  -- Create a 15-level deep chain
  for i = 2, 15 do
    local child = Gui.new({
      parent = current,
      id = "depth" .. i,
      x = 10,
      y = 10,
      width = math.max(50, 500 - (i * 25)), -- Decreasing width
      height = math.max(50, 500 - (i * 25)), -- Decreasing height
      positioning = Positioning.ABSOLUTE,
      z = i,
    })
    current = child
  end

  -- Verify deep chain structure
  current = Gui.topElements[1] -- root element
  luaunit.assertEquals(current.id, "root")

  for i = 2, 15 do
    luaunit.assertEquals(#current.children, 1)
    current = current.children[1]
    luaunit.assertEquals(current.id, "depth" .. i)
    luaunit.assertEquals(current.z, i)
    luaunit.assertEquals(current.x, 10)
    luaunit.assertEquals(current.y, 10)
  end

  -- Last element should have no children
  luaunit.assertEquals(#current.children, 0)
end

-- Test 24: Complex branching with mixed z-indices and overlapping regions
function TestAbsolutePositioningBasic:testComplexBranchingWithOverlaps()
  -- Create a complex layout simulating a windowing system
  local desktop = Gui.new({
    id = "desktop",
    x = 0,
    y = 0,
    width = 1920,
    height = 1080,
    positioning = Positioning.ABSOLUTE,
    z = 0,
  })

  -- Taskbar
  local taskbar = Gui.new({
    parent = desktop,
    id = "taskbar",
    x = 0,
    y = 1040,
    width = 1920,
    height = 40,
    positioning = Positioning.ABSOLUTE,
    z = 100, -- Always on top
  })

  -- Windows with different z-indices
  local window1 = Gui.new({
    parent = desktop,
    id = "window1",
    x = 100,
    y = 100,
    width = 600,
    height = 400,
    positioning = Positioning.ABSOLUTE,
    z = 10,
  })

  local window2 = Gui.new({
    parent = desktop,
    id = "window2",
    x = 300,
    y = 200,
    width = 500,
    height = 350,
    positioning = Positioning.ABSOLUTE,
    z = 15, -- Above window1
  })

  local window3 = Gui.new({
    parent = desktop,
    id = "window3",
    x = 200,
    y = 150,
    width = 400,
    height = 300,
    positioning = Positioning.ABSOLUTE,
    z = 5, -- Behind window1 and window2
  })

  -- Each window has title bar and content
  for i, window in ipairs({ window1, window2, window3 }) do
    local titlebar = Gui.new({
      parent = window,
      id = window.id .. "_titlebar",
      x = 0,
      y = 0,
      width = window.width,
      height = 30,
      positioning = Positioning.ABSOLUTE,
      z = 1,
    })

    local content = Gui.new({
      parent = window,
      id = window.id .. "_content",
      x = 0,
      y = 30,
      width = window.width,
      height = window.height - 30,
      positioning = Positioning.ABSOLUTE,
      z = 1,
    })

    -- Content has multiple child elements
    for j = 1, 3 do
      Gui.new({
        parent = content,
        id = window.id .. "_item" .. j,
        x = j * 50,
        y = j * 40,
        width = 80,
        height = 30,
        positioning = Positioning.ABSOLUTE,
        z = j,
      })
    end
  end

  -- Verify complex structure
  luaunit.assertEquals(#desktop.children, 4) -- taskbar + 3 windows
  luaunit.assertEquals(taskbar.z, 100) -- Highest z-index
  luaunit.assertEquals(window1.z, 10)
  luaunit.assertEquals(window2.z, 15)
  luaunit.assertEquals(window3.z, 5)

  -- Each window has titlebar and content
  luaunit.assertEquals(#window1.children, 2)
  luaunit.assertEquals(#window2.children, 2)
  luaunit.assertEquals(#window3.children, 2)

  -- Each content area has 3 items
  for i, window in ipairs({ window1, window2, window3 }) do
    local content = window.children[2] -- content is second child
    luaunit.assertEquals(#content.children, 3)
  end
end

luaunit.LuaUnit.run()
