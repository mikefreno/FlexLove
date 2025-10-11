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
    width = 200,
    height = 150,
  })

  local child = Gui.new({
    id = "child",
    x = 10,
    y = 20,
    width = 50,
    height = 30,
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
    width = 200,
    height = 150,
  })

  local child1 = Gui.new({
    id = "child1",
    x = 10,
    y = 20,
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    id = "child2",
    x = 75,
    y = 85,
    width = 40,
    height = 25,
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
    width = 200,
    height = 150,
    flexDirection = FlexDirection.HORIZONTAL,
  })

  local child1 = Gui.new({
    id = "child1",
    x = 10,
    y = 20,
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    id = "child2",
    x = 200, -- Way beyond parent w - this would be repositioned in flex layout
    y = 300,
    width = 40,
    height = 25,
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
    width = 200,
    height = 150,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.CENTER,
    alignItems = AlignItems.FLEX_END,
  })

  local child = Gui.new({
    id = "child",
    x = 10,
    y = 20,
    width = 50,
    height = 30,
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
    width = 300,
    height = 300,
  })

  local children = {}
  for i = 1, 5 do
    children[i] = Gui.new({
      id = "child" .. i,
      x = i * 25,
      y = i * 30,
      width = 20,
      height = 15,
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
    width = 300,
    height = 100,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
  })

  local flexChild = Gui.new({
    id = "flex_child",
    width = 50,
    height = 30,
  })

  local absoluteChild = Gui.new({
    id = "absolute_child",
    positioning = Positioning.ABSOLUTE,
    x = 200,
    y = 40,
    width = 50,
    height = 30,
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
    width = 200,
    height = 150,
  })

  local child = Gui.new({
    id = "child",
    x = 25,
    y = 30,
    width = 50,
    height = 40,
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
    width = 400,
    height = 300,
  })

  local parent = Gui.new({
    id = "parent",
    positioning = Positioning.ABSOLUTE,
    x = 75,
    y = 50,
    width = 200,
    height = 150,
  })

  local child = Gui.new({
    id = "child",
    x = 10,
    y = 20,
    width = 50,
    height = 30,
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
    width = 200,
    height = 150,
  })

  local flexChild = Gui.new({
    id = "flex_child",
    positioning = Positioning.FLEX,
    width = 50,
    height = 30,
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
    y = 50,
    -- No w/h specified, so it should auto-size
  })

  local child = Gui.new({
    id = "child",
    x = 10,
    y = 20,
    width = 50,
    height = 30,
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
    width = 200,
    height = 150,
  })

  local absoluteChild = Gui.new({
    id = "absolute_child",
    positioning = Positioning.ABSOLUTE,
    x = 25,
    y = 30,
    width = 50,
    height = 40,
  })

  local flexChild = Gui.new({
    id = "flex_child",
    positioning = Positioning.FLEX,
    width = 60,
    height = 35,
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
    width = 200,
    height = 150,
  })

  local child = Gui.new({
    id = "child",
    x = 25,
    y = 30,
    width = 50,
    height = 40,
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
    width = 200,
    height = 150,
  })

  local originalX = parent.x
  local originalY = parent.y

  local child = Gui.new({
    id = "child",
    x = 25,
    y = 30,
    width = 50,
    height = 40,
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
    width = 200,
    height = 150,
  })

  local child1 = Gui.new({ id = "child1", x = 10, y = 20, width = 50, height = 30 })
  local child2 = Gui.new({ id = "child2", x = 70, y = 80, width = 40, height = 25 })
  local child3 = Gui.new({ id = "child3", x = 120, y = 90, width = 30, height = 35 })

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
    width = 300,
    height = 200,
  })

  local absoluteChild = Gui.new({
    id = "absolute_child",
    positioning = Positioning.ABSOLUTE,
    x = 25,
    y = 30,
    width = 50,
    height = 40,
  })

  local flexChild = Gui.new({
    id = "flex_child",
    positioning = Positioning.FLEX,
    width = 60,
    height = 35,
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

-- ===========================================================================
-- COMPLEX MULTI-LEVEL HIERARCHY TESTS
-- ===========================================================================

-- Test 16: Deep hierarchy with mixed positioning types (CSS-like behavior)
function TestAbsolutePositioningChildLayout:testDeepHierarchyMixedPositioning()
  -- Create a complex hierarchy: absolute -> flex -> absolute -> flex
  local absoluteRoot = Gui.new({
    id = "absoluteRoot",
    positioning = Positioning.ABSOLUTE,
    x = 100,
    y = 100,
    width = 800,
    height = 600,
  })

  local flexLevel1 = Gui.new({
    parent = absoluteRoot,
    id = "flexLevel1",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    x = 50, -- Should be ignored due to flex positioning
    y = 50,
    width = 700,
    height = 500,
    gap = 20,
  })

  -- Add absolute children to flex parent
  local absoluteChild1 = Gui.new({
    parent = flexLevel1,
    id = "absoluteChild1",
    positioning = Positioning.ABSOLUTE,
    x = 600, -- Absolute position within flex parent
    y = 400,
    width = 150,
    height = 100,
  })

  local flexChild1 = Gui.new({
    parent = flexLevel1,
    id = "flexChild1",
    positioning = Positioning.FLEX,
    width = 200,
    height = 150,
  })

  local flexChild2 = Gui.new({
    parent = flexLevel1,
    id = "flexChild2",
    positioning = Positioning.FLEX,
    width = 200,
    height = 150,
  })

  -- Add grandchildren to flex children
  local absoluteGrandchild = Gui.new({
    parent = flexChild1,
    id = "absoluteGrandchild",
    positioning = Positioning.ABSOLUTE,
    x = 75,
    y = 75,
    width = 50,
    height = 50,
  })

  local flexGrandchild = Gui.new({
    parent = flexChild2,
    id = "flexGrandchild",
    positioning = Positioning.FLEX,
    width = 100,
    height = 75,
  })

  -- Verify hierarchy structure
  luaunit.assertEquals(#absoluteRoot.children, 1)
  luaunit.assertEquals(absoluteRoot.children[1], flexLevel1)

  luaunit.assertEquals(#flexLevel1.children, 3)
  luaunit.assertTrue(
    flexLevel1.children[1] == absoluteChild1
      or flexLevel1.children[2] == absoluteChild1
      or flexLevel1.children[3] == absoluteChild1
  )

  luaunit.assertEquals(#flexChild1.children, 1)
  luaunit.assertEquals(flexChild1.children[1], absoluteGrandchild)

  luaunit.assertEquals(#flexChild2.children, 1)
  luaunit.assertEquals(flexChild2.children[1], flexGrandchild)

  -- Verify absolute elements maintain their positioning
  luaunit.assertEquals(absoluteChild1.x, 600)
  luaunit.assertEquals(absoluteChild1.y, 400)
  luaunit.assertEquals(absoluteGrandchild.x, 75)
  luaunit.assertEquals(absoluteGrandchild.y, 75)
end

-- Test 17: Multi-branch tree with absolute parents having flex and absolute children
function TestAbsolutePositioningChildLayout:testMultiBranchAbsoluteWithMixedChildren()
  local root = Gui.new({
    id = "root",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 0,
    width = 1200,
    height = 800,
  })

  -- Left branch: Absolute parent with flex children
  local leftAbsoluteParent = Gui.new({
    parent = root,
    id = "leftAbsoluteParent",
    positioning = Positioning.ABSOLUTE,
    x = 50,
    y = 50,
    width = 500,
    height = 700,
  })

  -- Flex container within absolute parent
  local leftFlexContainer = Gui.new({
    parent = leftAbsoluteParent,
    id = "leftFlexContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    width = 400,
    height = 600,
    gap = 15,
  })

  -- Add multiple flex children
  for i = 1, 4 do
    local flexChild = Gui.new({
      parent = leftFlexContainer,
      id = "leftFlexChild" .. i,
      positioning = Positioning.FLEX,
      width = 350,
      height = 120,
    })

    -- Each flex child has absolute grandchildren
    for j = 1, 2 do
      Gui.new({
        parent = flexChild,
        id = "leftAbsGrandchild" .. i .. "_" .. j,
        positioning = Positioning.ABSOLUTE,
        x = j * 100,
        y = 20,
        width = 80,
        height = 80,
      })
    end
  end

  -- Add some absolute children to the absolute parent
  for i = 1, 3 do
    Gui.new({
      parent = leftAbsoluteParent,
      id = "leftAbsoluteChild" .. i,
      positioning = Positioning.ABSOLUTE,
      x = 450,
      y = i * 200,
      width = 40,
      height = 150,
    })
  end

  -- Right branch: Similar structure but different layout
  local rightAbsoluteParent = Gui.new({
    parent = root,
    id = "rightAbsoluteParent",
    positioning = Positioning.ABSOLUTE,
    x = 650,
    y = 50,
    width = 500,
    height = 700,
  })

  local rightFlexContainer = Gui.new({
    parent = rightAbsoluteParent,
    id = "rightFlexContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    width = 450,
    height = 200,
    gap = 10,
  })

  -- Add horizontal flex children
  for i = 1, 3 do
    local flexChild = Gui.new({
      parent = rightFlexContainer,
      id = "rightFlexChild" .. i,
      positioning = Positioning.FLEX,
      width = 130,
      height = 180,
    })

    -- Nested flex container
    local nestedFlex = Gui.new({
      parent = flexChild,
      id = "rightNestedFlex" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      width = 120,
      height = 170,
      gap = 5,
    })

    -- Add children to nested flex
    for j = 1, 3 do
      Gui.new({
        parent = nestedFlex,
        id = "rightNestedChild" .. i .. "_" .. j,
        positioning = Positioning.FLEX,
        width = 110,
        height = 50,
      })
    end
  end

  -- Verify structure
  luaunit.assertEquals(#root.children, 2)
  luaunit.assertEquals(#leftAbsoluteParent.children, 4) -- 1 flex container + 3 absolute children
  luaunit.assertEquals(#rightAbsoluteParent.children, 1) -- 1 flex container

  luaunit.assertEquals(#leftFlexContainer.children, 4)
  luaunit.assertEquals(#rightFlexContainer.children, 3)

  -- Verify absolute children maintain positions
  for i = 1, 3 do
    local absChild = leftAbsoluteParent.children[i + 1] -- Skip flex container (first child)
    luaunit.assertEquals(absChild.x, 450)
    luaunit.assertEquals(absChild.y, i * 200)
  end
end

-- Test 18: Cascade of absolute positioned containers with z-index conflicts
function TestAbsolutePositioningChildLayout:testCascadeAbsoluteWithZIndexConflicts()
  local viewport = Gui.new({
    id = "viewport",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 0,
    width = 1000,
    height = 1000,
    z = 0,
  })

  -- Create overlapping layers with complex z-index hierarchies
  local layers = {}
  for i = 1, 5 do
    layers[i] = Gui.new({
      parent = viewport,
      id = "layer" .. i,
      positioning = Positioning.ABSOLUTE,
      x = i * 50,
      y = i * 50,
      width = 600,
      height = 600,
      z = 6 - i, -- Reverse z-index (layer1=5, layer2=4, etc.)
    })

    -- Each layer has sublayers with conflicting z-indices
    for j = 1, 3 do
      local sublayer = Gui.new({
        parent = layers[i],
        id = "sublayer" .. i .. "_" .. j,
        positioning = Positioning.ABSOLUTE,
        x = j * 100,
        y = j * 100,
        width = 200,
        height = 200,
        z = j, -- Same z-index pattern across all layers
      })

      -- Each sublayer has items
      for k = 1, 2 do
        Gui.new({
          parent = sublayer,
          id = "item" .. i .. "_" .. j .. "_" .. k,
          positioning = Positioning.ABSOLUTE,
          x = k * 30,
          y = k * 30,
          width = 50,
          height = 50,
          z = k,
        })
      end
    end
  end

  -- Verify layer structure and z-index ordering
  luaunit.assertEquals(#viewport.children, 5)

  for i = 1, 5 do
    luaunit.assertEquals(layers[i].z, 6 - i)
    luaunit.assertEquals(#layers[i].children, 3)

    for j = 1, 3 do
      local sublayer = layers[i].children[j]
      luaunit.assertEquals(sublayer.z, j)
      luaunit.assertEquals(#sublayer.children, 2)

      for k = 1, 2 do
        local item = sublayer.children[k]
        luaunit.assertEquals(item.z, k)
        luaunit.assertEquals(item.x, k * 30)
        luaunit.assertEquals(item.y, k * 30)
      end
    end
  end
end

-- Test 19: Grid-like structure using absolute positioning
function TestAbsolutePositioningChildLayout:testGridStructureAbsolutePositioning()
  local grid = Gui.new({
    id = "grid",
    positioning = Positioning.ABSOLUTE,
    x = 100,
    y = 100,
    width = 800,
    height = 600,
  })

  local rows, cols = 4, 5
  local cellWidth, cellHeight = 150, 120
  local gap = 10

  -- Create grid cells
  local cells = {}
  for row = 1, rows do
    cells[row] = {}
    for col = 1, cols do
      local x = (col - 1) * (cellWidth + gap)
      local y = (row - 1) * (cellHeight + gap)

      cells[row][col] = Gui.new({
        parent = grid,
        id = "cell_" .. row .. "_" .. col,
        positioning = Positioning.ABSOLUTE,
        x = x,
        y = y,
        width = cellWidth,
        height = cellHeight,
        z = row * cols + col, -- Unique z-index for each cell
      })

      -- Each cell has a header and content
      local header = Gui.new({
        parent = cells[row][col],
        id = "header_" .. row .. "_" .. col,
        positioning = Positioning.ABSOLUTE,
        x = 0,
        y = 0,
        width = cellWidth,
        height = 30,
        z = 1,
      })

      local content = Gui.new({
        parent = cells[row][col],
        id = "content_" .. row .. "_" .. col,
        positioning = Positioning.ABSOLUTE,
        x = 5,
        y = 35,
        width = cellWidth - 10,
        height = cellHeight - 40,
        z = 1,
      })

      -- Content has multiple items
      for i = 1, 3 do
        Gui.new({
          parent = content,
          id = "item_" .. row .. "_" .. col .. "_" .. i,
          positioning = Positioning.ABSOLUTE,
          x = 10,
          y = i * 25,
          width = cellWidth - 30,
          height = 20,
          z = i,
        })
      end
    end
  end

  -- Verify grid structure
  luaunit.assertEquals(#grid.children, rows * cols)

  for row = 1, rows do
    for col = 1, cols do
      local cell = cells[row][col]
      local expectedX = (col - 1) * (cellWidth + gap)
      local expectedY = (row - 1) * (cellHeight + gap)

      luaunit.assertEquals(cell.x, expectedX)
      luaunit.assertEquals(cell.y, expectedY)
      luaunit.assertEquals(#cell.children, 2) -- header + content

      local content = cell.children[2]
      luaunit.assertEquals(#content.children, 3) -- 3 items
    end
  end
end

-- Test 20: Complex nested modal/dialog system
function TestAbsolutePositioningChildLayout:testComplexModalDialogSystem()
  local app = Gui.new({
    id = "app",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 0,
    width = 1920,
    height = 1080,
    z = 0,
  })

  -- Main content
  local mainContent = Gui.new({
    parent = app,
    id = "mainContent",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 0,
    width = 1920,
    height = 1080,
    z = 1,
  })

  -- Modal overlay
  local modalOverlay = Gui.new({
    parent = app,
    id = "modalOverlay",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 0,
    width = 1920,
    height = 1080,
    z = 1000, -- High z-index for overlay
  })

  -- Primary modal
  local primaryModal = Gui.new({
    parent = modalOverlay,
    id = "primaryModal",
    positioning = Positioning.ABSOLUTE,
    x = 460, -- Centered: (1920 - 1000) / 2
    y = 290, -- Centered: (1080 - 500) / 2
    width = 1000,
    height = 500,
    z = 1001,
  })

  -- Modal header
  local modalHeader = Gui.new({
    parent = primaryModal,
    id = "modalHeader",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 0,
    width = 1000,
    height = 50,
    z = 1,
  })

  -- Modal content with tabs
  local modalContent = Gui.new({
    parent = primaryModal,
    id = "modalContent",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 50,
    width = 1000,
    height = 400,
    z = 1,
  })

  -- Tab system
  local tabContainer = Gui.new({
    parent = modalContent,
    id = "tabContainer",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 0,
    width = 1000,
    height = 40,
    z = 2,
  })

  -- Create tabs
  for i = 1, 4 do
    Gui.new({
      parent = tabContainer,
      id = "tab" .. i,
      positioning = Positioning.ABSOLUTE,
      x = (i - 1) * 250,
      y = 0,
      width = 250,
      height = 40,
      z = i,
    })
  end

  -- Tab content area
  local tabContentArea = Gui.new({
    parent = modalContent,
    id = "tabContentArea",
    positioning = Positioning.ABSOLUTE,
    x = 10,
    y = 50,
    width = 980,
    height = 340,
    z = 1,
  })

  -- Secondary modal (popup within modal)
  local secondaryModal = Gui.new({
    parent = modalOverlay,
    id = "secondaryModal",
    positioning = Positioning.ABSOLUTE,
    x = 710, -- Offset from primary modal
    y = 340,
    width = 500,
    height = 400,
    z = 1002, -- Above primary modal
  })

  -- Tooltip system
  local tooltipContainer = Gui.new({
    parent = app,
    id = "tooltipContainer",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 0,
    width = 1920,
    height = 1080,
    z = 2000, -- Highest z-index
  })

  local tooltip = Gui.new({
    parent = tooltipContainer,
    id = "tooltip",
    positioning = Positioning.ABSOLUTE,
    x = 800,
    y = 600,
    width = 200,
    height = 50,
    z = 2001,
  })

  -- Verify complex modal structure
  luaunit.assertEquals(#app.children, 3) -- main, modal overlay, tooltip container
  luaunit.assertEquals(#modalOverlay.children, 2) -- primary + secondary modal
  luaunit.assertEquals(#primaryModal.children, 2) -- header + content
  luaunit.assertEquals(#modalContent.children, 2) -- tab container + content area
  luaunit.assertEquals(#tabContainer.children, 4) -- 4 tabs
  luaunit.assertEquals(#tooltipContainer.children, 1) -- tooltip

  -- Verify z-index hierarchy
  luaunit.assertEquals(mainContent.z, 1)
  luaunit.assertEquals(modalOverlay.z, 1000)
  luaunit.assertEquals(primaryModal.z, 1001)
  luaunit.assertEquals(secondaryModal.z, 1002)
  luaunit.assertEquals(tooltipContainer.z, 2000)
  luaunit.assertEquals(tooltip.z, 2001)
end

-- Test 21: Tree with dynamic branching (simulating DOM-like structure)
function TestAbsolutePositioningChildLayout:testDynamicBranchingDOMStructure()
  -- Simulate a complex web page structure
  local document = Gui.new({
    id = "document",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 0,
    width = 1200,
    height = 2000,
    z = 0,
  })

  -- Header
  local header = Gui.new({
    parent = document,
    id = "header",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 0,
    width = 1200,
    height = 100,
    z = 10,
  })

  -- Navigation in header
  local nav = Gui.new({
    parent = header,
    id = "nav",
    positioning = Positioning.ABSOLUTE,
    x = 100,
    y = 20,
    width = 1000,
    height = 60,
    z = 1,
  })

  -- Nav items
  for i = 1, 5 do
    local navItem = Gui.new({
      parent = nav,
      id = "navItem" .. i,
      positioning = Positioning.ABSOLUTE,
      x = (i - 1) * 200,
      y = 0,
      width = 180,
      height = 60,
      z = i,
    })

    -- Dropdown for each nav item
    if i <= 3 then -- Only first 3 have dropdowns
      local dropdown = Gui.new({
        parent = navItem,
        id = "dropdown" .. i,
        positioning = Positioning.ABSOLUTE,
        x = 0,
        y = 60,
        width = 180,
        height = 200,
        z = 100, -- High z-index for dropdown
      })

      -- Dropdown items
      for j = 1, 4 do
        Gui.new({
          parent = dropdown,
          id = "dropdownItem" .. i .. "_" .. j,
          positioning = Positioning.ABSOLUTE,
          x = 0,
          y = (j - 1) * 50,
          width = 180,
          height = 50,
          z = j,
        })
      end
    end
  end

  -- Main content area
  local main = Gui.new({
    parent = document,
    id = "main",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 100,
    width = 1200,
    height = 1700,
    z = 1,
  })

  -- Sidebar
  local sidebar = Gui.new({
    parent = main,
    id = "sidebar",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 0,
    width = 300,
    height = 1700,
    z = 2,
  })

  -- Sidebar widgets
  for i = 1, 6 do
    local widget = Gui.new({
      parent = sidebar,
      id = "widget" .. i,
      positioning = Positioning.ABSOLUTE,
      x = 10,
      y = (i - 1) * 280 + 10,
      width = 280,
      height = 260,
      z = i,
    })

    -- Widget header
    Gui.new({
      parent = widget,
      id = "widgetHeader" .. i,
      positioning = Positioning.ABSOLUTE,
      x = 0,
      y = 0,
      width = 280,
      height = 40,
      z = 1,
    })

    -- Widget content with items
    local widgetContent = Gui.new({
      parent = widget,
      id = "widgetContent" .. i,
      positioning = Positioning.ABSOLUTE,
      x = 5,
      y = 45,
      width = 270,
      height = 210,
      z = 1,
    })

    -- Items in widget
    for j = 1, 4 do
      Gui.new({
        parent = widgetContent,
        id = "widgetItem" .. i .. "_" .. j,
        positioning = Positioning.ABSOLUTE,
        x = 5,
        y = (j - 1) * 50,
        width = 260,
        height = 45,
        z = j,
      })
    end
  end

  -- Content area
  local content = Gui.new({
    parent = main,
    id = "content",
    positioning = Positioning.ABSOLUTE,
    x = 320,
    y = 0,
    width = 880,
    height = 1700,
    z = 1,
  })

  -- Articles in content
  for i = 1, 3 do
    local article = Gui.new({
      parent = content,
      id = "article" .. i,
      positioning = Positioning.ABSOLUTE,
      x = 20,
      y = (i - 1) * 550 + 20,
      width = 840,
      height = 500,
      z = i,
    })

    -- Article header, content, footer
    local articleHeader = Gui.new({
      parent = article,
      id = "articleHeader" .. i,
      positioning = Positioning.ABSOLUTE,
      x = 0,
      y = 0,
      width = 840,
      height = 80,
      z = 1,
    })

    local articleContent = Gui.new({
      parent = article,
      id = "articleContent" .. i,
      positioning = Positioning.ABSOLUTE,
      x = 0,
      y = 80,
      width = 840,
      height = 350,
      z = 1,
    })

    local articleFooter = Gui.new({
      parent = article,
      id = "articleFooter" .. i,
      positioning = Positioning.ABSOLUTE,
      x = 0,
      y = 430,
      width = 840,
      height = 70,
      z = 1,
    })

    -- Comments in article content
    for j = 1, 3 do
      Gui.new({
        parent = articleContent,
        id = "comment" .. i .. "_" .. j,
        positioning = Positioning.ABSOLUTE,
        x = 20,
        y = 50 + (j - 1) * 100,
        width = 800,
        height = 80,
        z = j,
      })
    end
  end

  -- Footer
  local footer = Gui.new({
    parent = document,
    id = "footer",
    positioning = Positioning.ABSOLUTE,
    x = 0,
    y = 1800,
    width = 1200,
    height = 200,
    z = 10,
  })

  -- Verify complex DOM structure
  luaunit.assertEquals(#document.children, 3) -- header, main, footer
  luaunit.assertEquals(#header.children, 1) -- nav
  luaunit.assertEquals(#nav.children, 5) -- 5 nav items
  luaunit.assertEquals(#main.children, 2) -- sidebar, content
  luaunit.assertEquals(#sidebar.children, 6) -- 6 widgets
  luaunit.assertEquals(#content.children, 3) -- 3 articles

  -- Verify nav dropdowns
  for i = 1, 3 do
    local navItem = nav.children[i]
    luaunit.assertEquals(#navItem.children, 1) -- dropdown
    local dropdown = navItem.children[1]
    luaunit.assertEquals(#dropdown.children, 4) -- 4 dropdown items
  end

  -- Verify widgets
  for i = 1, 6 do
    local widget = sidebar.children[i]
    luaunit.assertEquals(#widget.children, 2) -- header + content
    local widgetContent = widget.children[2]
    luaunit.assertEquals(#widgetContent.children, 4) -- 4 items
  end

  -- Verify articles
  for i = 1, 3 do
    local article = content.children[i]
    luaunit.assertEquals(#article.children, 3) -- header, content, footer
    local articleContent = article.children[2]
    luaunit.assertEquals(#articleContent.children, 3) -- 3 comments
  end
end

-- Run the tests
luaunit.LuaUnit.run()
