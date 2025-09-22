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
    width = 300,
    height = 100,
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
    width = 300,
    height = 100,
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
    width = 300,
    height = 100,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
  })

  local child3 = Gui.new({
    id = "child3",
    width = 40,
    height = 35,
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
    width = 300,
    height = 100,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
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
    width = 300,
    height = 100,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
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
    width = 300,
    height = 100,
    gap = 10,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
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
    width = 300,
    height = 100,
    gap = 10,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
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
    width = 300,
    height = 100,
    gap = 0, -- Space-between doesn't use gap, it distributes available space
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
  })

  local child3 = Gui.new({
    id = "child3",
    width = 40,
    height = 35,
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
    width = 300,
    height = 100,
  })

  local child = Gui.new({
    id = "single_child",
    width = 50,
    height = 30,
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
    width = 300,
    height = 100,
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
    width = 300,
    height = 100,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
  })

  parent:addChild(child1)
  parent:addChild(child2)

  -- Children coordinates should be relative to parent position
  luaunit.assertEquals(child1.x, parent.x + 0) -- First child at parent's x
  luaunit.assertEquals(child1.y, parent.y) -- Same y as parent

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
    width = 300,
    height = 100,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 70, -- Different height
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
    width = 300,
    height = 100,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
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
    width = 300,
    height = 100,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
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
    width = 300,
    height = 100,
  })

  local child1 = Gui.new({
    id = "child1",
    width = 50,
    height = 30,
  })

  local child2 = Gui.new({
    id = "child2",
    width = 60,
    height = 40,
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

-- ===========================================================================
-- COMPLEX NESTED FLEX CONTAINER TESTS
-- ===========================================================================

-- Test 16: Nested horizontal flex containers (flexbox within flexbox)
function TestHorizontalFlexDirection:testNestedHorizontalFlexContainers()
  local outerContainer = Gui.new({
    id = "outerContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    x = 0,
    y = 0,
    width = 1200,
    height = 300,
    gap = 20,
  })

  -- Create 3 nested flex containers
  for i = 1, 3 do
    local innerContainer = Gui.new({
      parent = outerContainer,
      id = "innerContainer" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.CENTER,
      width = 350,
      height = 280,
      gap = 10,
    })

    -- Each inner container has 4 flex items
    for j = 1, 4 do
      Gui.new({
        parent = innerContainer,
        id = "item" .. i .. "_" .. j,
        positioning = Positioning.FLEX,
        width = 70,
        height = 120,
      })
    end
  end

  -- Verify nested structure
  luaunit.assertEquals(#outerContainer.children, 3)

  for i = 1, 3 do
    local innerContainer = outerContainer.children[i]
    luaunit.assertEquals(innerContainer.positioning, Positioning.FLEX)
    luaunit.assertEquals(innerContainer.flexDirection, FlexDirection.HORIZONTAL)
    luaunit.assertEquals(#innerContainer.children, 4)

    -- Verify inner items are positioned horizontally within their container
    for j = 1, 4 do
      local item = innerContainer.children[j]
      luaunit.assertEquals(item.positioning, Positioning.FLEX)
      luaunit.assertEquals(item.width, 70)
      luaunit.assertEquals(item.height, 120)
    end
  end
end

-- Test 17: Complex grid layout using nested horizontal flex
function TestHorizontalFlexDirection:testComplexGridLayoutNestedHorizontalFlex()
  local gridContainer = Gui.new({
    id = "gridContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    width = 1000,
    height = 800,
    gap = 15,
  })

  -- Create 4 rows, each being a horizontal flex container
  for row = 1, 4 do
    local rowContainer = Gui.new({
      parent = gridContainer,
      id = "row" .. row,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_EVENLY,
      width = 980,
      height = 180,
      gap = 12,
    })

    -- Each row has varying number of columns
    local colCount = row + 2 -- Row 1 has 3 cols, row 2 has 4 cols, etc.
    for col = 1, colCount do
      local cell = Gui.new({
        parent = rowContainer,
        id = "cell" .. row .. "_" .. col,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.CENTER,
        alignItems = AlignItems.CENTER,
        width = (980 - (colCount - 1) * 12) / colCount, -- Dynamic width
        height = 160,
      })

      -- Each cell contains a nested horizontal layout with icons
      for icon = 1, 3 do
        Gui.new({
          parent = cell,
          id = "icon" .. row .. "_" .. col .. "_" .. icon,
          positioning = Positioning.FLEX,
          width = 30,
          height = 30,
        })
      end
    end
  end

  -- Verify grid structure
  luaunit.assertEquals(#gridContainer.children, 4)

  for row = 1, 4 do
    local rowContainer = gridContainer.children[row]
    local expectedColCount = row + 2
    luaunit.assertEquals(#rowContainer.children, expectedColCount)
    luaunit.assertEquals(rowContainer.flexDirection, FlexDirection.HORIZONTAL)
    luaunit.assertEquals(rowContainer.justifyContent, JustifyContent.SPACE_EVENLY)

    for col = 1, expectedColCount do
      local cell = rowContainer.children[col]
      luaunit.assertEquals(#cell.children, 3) -- 3 icons per cell
      luaunit.assertEquals(cell.flexDirection, FlexDirection.HORIZONTAL)
      luaunit.assertEquals(cell.justifyContent, JustifyContent.CENTER)
    end
  end
end

-- Test 18: Horizontal flex with mixed positioning children (absolute within flex)
function TestHorizontalFlexDirection:testHorizontalFlexWithMixedPositioningChildren()
  local flexContainer = Gui.new({
    id = "flexContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    x = 100,
    y = 100,
    width = 800,
    height = 200,
    gap = 20,
  })

  -- Add flex children
  local flexChild1 = Gui.new({
    parent = flexContainer,
    id = "flexChild1",
    positioning = Positioning.FLEX,
    width = 150,
    height = 180,
  })

  local flexChild2 = Gui.new({
    parent = flexContainer,
    id = "flexChild2",
    positioning = Positioning.FLEX,
    width = 150,
    height = 180,
  })

  local flexChild3 = Gui.new({
    parent = flexContainer,
    id = "flexChild3",
    positioning = Positioning.FLEX,
    width = 150,
    height = 180,
  })

  -- Add absolute positioned children (should not participate in flex layout)
  local absoluteChild1 = Gui.new({
    parent = flexContainer,
    id = "absoluteChild1",
    positioning = Positioning.ABSOLUTE,
    x = 600,
    y = 50,
    width = 100,
    height = 100,
  })

  local absoluteChild2 = Gui.new({
    parent = flexContainer,
    id = "absoluteChild2",
    positioning = Positioning.ABSOLUTE,
    x = 650,
    y = 75,
    width = 80,
    height = 80,
  })

  -- Add nested flex containers within flex children
  for i, flexChild in ipairs({ flexChild1, flexChild2, flexChild3 }) do
    local nestedFlex = Gui.new({
      parent = flexChild,
      id = "nestedFlex" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.CENTER,
      width = 140,
      height = 170,
      gap = 5,
    })

    -- Add items to nested flex
    for j = 1, 2 do
      Gui.new({
        parent = nestedFlex,
        id = "nestedItem" .. i .. "_" .. j,
        positioning = Positioning.FLEX,
        width = 60,
        height = 80,
      })
    end

    -- Add absolute child to flex child
    Gui.new({
      parent = flexChild,
      id = "absInFlex" .. i,
      positioning = Positioning.ABSOLUTE,
      x = 120,
      y = 150,
      width = 25,
      height = 25,
    })
  end

  -- Verify mixed positioning structure
  luaunit.assertEquals(#flexContainer.children, 5) -- 3 flex + 2 absolute

  -- Verify absolute children maintain their positions
  luaunit.assertEquals(absoluteChild1.x, 600)
  luaunit.assertEquals(absoluteChild1.y, 50)
  luaunit.assertEquals(absoluteChild2.x, 650)
  luaunit.assertEquals(absoluteChild2.y, 75)

  -- Verify nested flex structures
  for i = 1, 3 do
    local flexChild = flexContainer.children[i]
    luaunit.assertEquals(#flexChild.children, 2) -- nested flex + absolute

    local nestedFlex = flexChild.children[1]
    luaunit.assertEquals(nestedFlex.positioning, Positioning.FLEX)
    luaunit.assertEquals(#nestedFlex.children, 2)

    local absInFlex = flexChild.children[2]
    luaunit.assertEquals(absInFlex.positioning, Positioning.ABSOLUTE)
    luaunit.assertEquals(absInFlex.x, 120)
    luaunit.assertEquals(absInFlex.y, 150)
  end
end

-- Test 19: Multi-level horizontal flex navigation system
function TestHorizontalFlexDirection:testMultiLevelHorizontalFlexNavigation()
  local navSystem = Gui.new({
    id = "navSystem",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    width = 1200,
    height = 400,
    gap = 0,
  })

  -- Primary navigation (horizontal)
  local primaryNav = Gui.new({
    parent = navSystem,
    id = "primaryNav",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    width = 1200,
    height = 60,
    gap = 0,
  })

  -- Primary nav items
  local primaryItems = { "Home", "Products", "Services", "About", "Contact" }
  for i, itemName in ipairs(primaryItems) do
    local primaryItem = Gui.new({
      parent = primaryNav,
      id = "primaryItem" .. i,
      positioning = Positioning.FLEX,
      width = 240,
      height = 60,
    })

    -- Some primary items have secondary navigation
    if i == 2 or i == 3 then -- Products and Services have sub-menus
      local secondaryNav = Gui.new({
        parent = primaryItem,
        id = "secondaryNav" .. i,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.CENTER,
        width = 240,
        height = 40,
        gap = 5,
      })

      -- Secondary nav items
      local secCount = i == 2 and 4 or 3 -- Products has 4, Services has 3
      for j = 1, secCount do
        local secondaryItem = Gui.new({
          parent = secondaryNav,
          id = "secondaryItem" .. i .. "_" .. j,
          positioning = Positioning.FLEX,
          width = (240 - (secCount - 1) * 5) / secCount,
          height = 35,
        })

        -- Tertiary items for some secondary items
        if j <= 2 then
          local tertiaryNav = Gui.new({
            parent = secondaryItem,
            id = "tertiaryNav" .. i .. "_" .. j,
            positioning = Positioning.FLEX,
            flexDirection = FlexDirection.HORIZONTAL,
            justifyContent = JustifyContent.SPACE_EVENLY,
            width = (240 - (secCount - 1) * 5) / secCount,
            height = 25,
            gap = 2,
          })

          -- Tertiary items
          for k = 1, 2 do
            Gui.new({
              parent = tertiaryNav,
              id = "tertiaryItem" .. i .. "_" .. j .. "_" .. k,
              positioning = Positioning.FLEX,
              width = ((240 - (secCount - 1) * 5) / secCount - 2) / 2,
              height = 20,
            })
          end
        end
      end
    end
  end

  -- Secondary navigation bar (horizontal)
  local secondaryNavBar = Gui.new({
    parent = navSystem,
    id = "secondaryNavBar",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    width = 1200,
    height = 50,
    gap = 30,
  })

  -- Breadcrumb navigation
  for i = 1, 5 do
    local breadcrumb = Gui.new({
      parent = secondaryNavBar,
      id = "breadcrumb" .. i,
      positioning = Positioning.FLEX,
      width = 120,
      height = 40,
    })
  end

  -- Verify navigation structure
  luaunit.assertEquals(#navSystem.children, 2) -- primary nav + secondary nav bar
  luaunit.assertEquals(#primaryNav.children, 5) -- 5 primary items
  luaunit.assertEquals(#secondaryNavBar.children, 5) -- 5 breadcrumbs

  -- Verify Products (item 2) has secondary navigation
  local productsItem = primaryNav.children[2]
  luaunit.assertEquals(#productsItem.children, 1) -- secondary nav
  local productsSecondary = productsItem.children[1]
  luaunit.assertEquals(#productsSecondary.children, 4) -- 4 secondary items

  -- Verify tertiary navigation exists
  for j = 1, 2 do
    local secondaryItem = productsSecondary.children[j]
    luaunit.assertEquals(#secondaryItem.children, 1) -- tertiary nav
    local tertiaryNav = secondaryItem.children[1]
    luaunit.assertEquals(#tertiaryNav.children, 2) -- 2 tertiary items
  end
end

-- Test 20: Horizontal flex card layout with dynamic sizing
function TestHorizontalFlexDirection:testHorizontalFlexCardLayoutDynamicSizing()
  local cardContainer = Gui.new({
    id = "cardContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_AROUND,
    x = 50,
    y = 50,
    width = 1400,
    height = 600,
    gap = 25,
  })

  -- Create cards with different content complexities
  local cardConfigs = {
    { width = 300, items = 3, hasImage = true },
    { width = 250, items = 2, hasImage = false },
    { width = 350, items = 4, hasImage = true },
    { width = 280, items = 3, hasImage = true },
    { width = 320, items = 5, hasImage = false },
  }

  for i, config in ipairs(cardConfigs) do
    local card = Gui.new({
      parent = cardContainer,
      id = "card" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      width = config.width,
      height = 550,
      gap = 10,
    })

    -- Card header (horizontal layout)
    local cardHeader = Gui.new({
      parent = card,
      id = "cardHeader" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      width = config.width - 20,
      height = 50,
      gap = 10,
    })

    -- Header title and actions
    Gui.new({
      parent = cardHeader,
      id = "cardTitle" .. i,
      positioning = Positioning.FLEX,
      width = (config.width - 30) * 0.7,
      height = 40,
    })

    local headerActions = Gui.new({
      parent = cardHeader,
      id = "headerActions" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.FLEX_END,
      width = (config.width - 30) * 0.3,
      height = 40,
      gap = 5,
    })

    -- Action buttons
    for j = 1, 2 do
      Gui.new({
        parent = headerActions,
        id = "actionBtn" .. i .. "_" .. j,
        positioning = Positioning.FLEX,
        width = ((config.width - 30) * 0.3 - 5) / 2,
        height = 35,
      })
    end

    -- Card image (if configured)
    if config.hasImage then
      Gui.new({
        parent = card,
        id = "cardImage" .. i,
        positioning = Positioning.FLEX,
        width = config.width - 20,
        height = 200,
      })
    end

    -- Card content area
    local cardContent = Gui.new({
      parent = card,
      id = "cardContent" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      width = config.width - 20,
      height = config.hasImage and 240 or 440,
      gap = 8,
    })

    -- Content items
    for j = 1, config.items do
      local contentItem = Gui.new({
        parent = cardContent,
        id = "contentItem" .. i .. "_" .. j,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        justifyContent = JustifyContent.FLEX_START,
        width = config.width - 40,
        height = (config.hasImage and 230 or 430) / config.items - 8,
        gap = 10,
      })

      -- Item icon and text
      Gui.new({
        parent = contentItem,
        id = "itemIcon" .. i .. "_" .. j,
        positioning = Positioning.FLEX,
        width = 30,
        height = (config.hasImage and 230 or 430) / config.items - 8,
      })

      Gui.new({
        parent = contentItem,
        id = "itemText" .. i .. "_" .. j,
        positioning = Positioning.FLEX,
        width = config.width - 80,
        height = (config.hasImage and 230 or 430) / config.items - 8,
      })
    end

    -- Card footer (horizontal layout)
    local cardFooter = Gui.new({
      parent = card,
      id = "cardFooter" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.CENTER,
      width = config.width - 20,
      height = 50,
      gap = 15,
    })

    -- Footer buttons
    for j = 1, 3 do
      Gui.new({
        parent = cardFooter,
        id = "footerBtn" .. i .. "_" .. j,
        positioning = Positioning.FLEX,
        width = (config.width - 50) / 3,
        height = 40,
      })
    end
  end

  -- Verify card structure
  luaunit.assertEquals(#cardContainer.children, 5)

  for i, config in ipairs(cardConfigs) do
    local card = cardContainer.children[i]
    luaunit.assertEquals(card.width, config.width)

    -- Count expected children: header + content + footer + optional image
    local expectedChildren = 3 + (config.hasImage and 1 or 0)
    luaunit.assertEquals(#card.children, expectedChildren)

    -- Verify header structure
    local cardHeader = card.children[1]
    luaunit.assertEquals(#cardHeader.children, 2) -- title + actions
    local headerActions = cardHeader.children[2]
    luaunit.assertEquals(#headerActions.children, 2) -- 2 action buttons

    -- Verify content structure
    local contentIndex = config.hasImage and 3 or 2
    local cardContent = card.children[contentIndex]
    luaunit.assertEquals(#cardContent.children, config.items)

    -- Verify each content item has icon and text
    for j = 1, config.items do
      local contentItem = cardContent.children[j]
      luaunit.assertEquals(#contentItem.children, 2) -- icon + text
    end

    -- Verify footer structure
    local footerIndex = config.hasImage and 4 or 3
    local cardFooter = card.children[footerIndex]
    luaunit.assertEquals(#cardFooter.children, 3) -- 3 footer buttons
  end
end

-- Test 21: Horizontal flex with overflow and scrolling simulation
function TestHorizontalFlexDirection:testHorizontalFlexOverflowScrolling()
  local scrollContainer = Gui.new({
    id = "scrollContainer",
    positioning = Positioning.ABSOLUTE,
    x = 100,
    y = 100,
    width = 800,
    height = 200,
  })

  -- Content container (wider than viewport)
  local contentContainer = Gui.new({
    parent = scrollContainer,
    id = "contentContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    x = 0, -- This would change with scrolling
    y = 0,
    width = 2000, -- Wider than scroll container
    height = 180,
    gap = 20,
  })

  -- Create many items that exceed viewport width
  for i = 1, 15 do
    local item = Gui.new({
      parent = contentContainer,
      id = "scrollItem" .. i,
      positioning = Positioning.FLEX,
      width = 120,
      height = 160,
    })

    -- Each item has internal horizontal layout
    local itemContent = Gui.new({
      parent = item,
      id = "itemContent" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.CENTER,
      width = 110,
      height = 150,
      gap = 5,
    })

    -- Item components
    for j = 1, 2 do
      local component = Gui.new({
        parent = itemContent,
        id = "component" .. i .. "_" .. j,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        width = 50,
        height = 140,
        gap = 3,
      })

      -- Sub-components in vertical layout
      for k = 1, 3 do
        Gui.new({
          parent = component,
          id = "subComponent" .. i .. "_" .. j .. "_" .. k,
          positioning = Positioning.FLEX,
          width = 45,
          height = 42,
        })
      end
    end
  end

  -- Verify overflow structure
  luaunit.assertEquals(#scrollContainer.children, 1)
  luaunit.assertEquals(#contentContainer.children, 15)

  -- Verify content is wider than container
  luaunit.assertTrue(contentContainer.width > scrollContainer.width)

  -- Verify nested structure
  for i = 1, 15 do
    local item = contentContainer.children[i]
    luaunit.assertEquals(#item.children, 1) -- item content

    local itemContent = item.children[1]
    luaunit.assertEquals(#itemContent.children, 2) -- 2 components
    luaunit.assertEquals(itemContent.flexDirection, FlexDirection.HORIZONTAL)

    for j = 1, 2 do
      local component = itemContent.children[j]
      luaunit.assertEquals(#component.children, 3) -- 3 sub-components
      luaunit.assertEquals(component.flexDirection, FlexDirection.VERTICAL)
    end
  end
end

-- Test 22: Complex horizontal dashboard layout
function TestHorizontalFlexDirection:testComplexHorizontalDashboardLayout()
  local dashboard = Gui.new({
    id = "dashboard",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    width = 1600,
    height = 1000,
    gap = 0,
  })

  -- Dashboard header (horizontal)
  local header = Gui.new({
    parent = dashboard,
    id = "dashboardHeader",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    width = 1600,
    height = 80,
    gap = 20,
  })

  -- Header left section
  local headerLeft = Gui.new({
    parent = header,
    id = "headerLeft",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    width = 400,
    height = 60,
    gap = 15,
  })

  -- Logo and title
  Gui.new({
    parent = headerLeft,
    id = "logo",
    positioning = Positioning.FLEX,
    width = 60,
    height = 60,
  })

  Gui.new({
    parent = headerLeft,
    id = "title",
    positioning = Positioning.FLEX,
    width = 300,
    height = 60,
  })

  -- Header center - search and navigation
  local headerCenter = Gui.new({
    parent = header,
    id = "headerCenter",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    width = 800,
    height = 60,
    gap = 20,
  })

  -- Search bar
  Gui.new({
    parent = headerCenter,
    id = "searchBar",
    positioning = Positioning.FLEX,
    width = 400,
    height = 50,
  })

  -- Quick actions
  local quickActions = Gui.new({
    parent = headerCenter,
    id = "quickActions",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_EVENLY,
    width = 300,
    height = 50,
    gap = 10,
  })

  for i = 1, 4 do
    Gui.new({
      parent = quickActions,
      id = "quickAction" .. i,
      positioning = Positioning.FLEX,
      width = 65,
      height = 45,
    })
  end

  -- Header right - user section
  local headerRight = Gui.new({
    parent = header,
    id = "headerRight",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    width = 300,
    height = 60,
    gap = 10,
  })

  -- Notifications and user menu
  Gui.new({
    parent = headerRight,
    id = "notifications",
    positioning = Positioning.FLEX,
    width = 50,
    height = 50,
  })

  Gui.new({
    parent = headerRight,
    id = "userMenu",
    positioning = Positioning.FLEX,
    width = 200,
    height = 50,
  })

  -- Main dashboard content (horizontal sections)
  local mainContent = Gui.new({
    parent = dashboard,
    id = "mainContent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
    width = 1600,
    height = 920,
    gap = 0,
  })

  -- Left sidebar
  local leftSidebar = Gui.new({
    parent = mainContent,
    id = "leftSidebar",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    width = 250,
    height = 920,
    gap = 10,
  })

  -- Sidebar sections
  for i = 1, 5 do
    local sidebarSection = Gui.new({
      parent = leftSidebar,
      id = "sidebarSection" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      width = 240,
      height = 170,
      gap = 5,
    })

    -- Section header
    Gui.new({
      parent = sidebarSection,
      id = "sectionHeader" .. i,
      positioning = Positioning.FLEX,
      width = 230,
      height = 30,
    })

    -- Section items
    for j = 1, 4 do
      Gui.new({
        parent = sidebarSection,
        id = "sectionItem" .. i .. "_" .. j,
        positioning = Positioning.FLEX,
        width = 230,
        height = 30,
      })
    end
  end

  -- Center content area (horizontal widget layout)
  local centerArea = Gui.new({
    parent = mainContent,
    id = "centerArea",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    width = 1100,
    height = 920,
    gap = 20,
  })

  -- Top widgets row
  local topWidgets = Gui.new({
    parent = centerArea,
    id = "topWidgets",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    width = 1080,
    height = 280,
    gap = 20,
  })

  -- Create 4 top widgets
  for i = 1, 4 do
    local widget = Gui.new({
      parent = topWidgets,
      id = "topWidget" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      width = 250,
      height = 260,
      gap = 10,
    })

    -- Widget header
    local widgetHeader = Gui.new({
      parent = widget,
      id = "topWidgetHeader" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      width = 240,
      height = 40,
      gap = 10,
    })

    Gui.new({
      parent = widgetHeader,
      id = "widgetTitle" .. i,
      positioning = Positioning.FLEX,
      width = 180,
      height = 35,
    })

    Gui.new({
      parent = widgetHeader,
      id = "widgetControls" .. i,
      positioning = Positioning.FLEX,
      width = 50,
      height = 35,
    })

    -- Widget content
    Gui.new({
      parent = widget,
      id = "topWidgetContent" .. i,
      positioning = Positioning.FLEX,
      width = 240,
      height = 200,
    })
  end

  -- Bottom content area
  local bottomWidgets = Gui.new({
    parent = centerArea,
    id = "bottomWidgets",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_AROUND,
    width = 1080,
    height = 600,
    gap = 30,
  })

  -- Large widget and smaller widgets
  local largeWidget = Gui.new({
    parent = bottomWidgets,
    id = "largeWidget",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    width = 700,
    height = 580,
    gap = 15,
  })

  -- Large widget components
  Gui.new({
    parent = largeWidget,
    id = "largeWidgetHeader",
    positioning = Positioning.FLEX,
    width = 680,
    height = 50,
  })

  local largeWidgetContent = Gui.new({
    parent = largeWidget,
    id = "largeWidgetContent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    width = 680,
    height = 500,
    gap = 20,
  })

  -- Chart and details
  Gui.new({
    parent = largeWidgetContent,
    id = "chart",
    positioning = Positioning.FLEX,
    width = 400,
    height = 480,
  })

  local details = Gui.new({
    parent = largeWidgetContent,
    id = "details",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    width = 240,
    height = 480,
    gap = 10,
  })

  -- Detail items
  for i = 1, 6 do
    Gui.new({
      parent = details,
      id = "detailItem" .. i,
      positioning = Positioning.FLEX,
      width = 230,
      height = 70,
    })
  end

  -- Small widgets column
  local smallWidgets = Gui.new({
    parent = bottomWidgets,
    id = "smallWidgets",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    width = 300,
    height = 580,
    gap = 20,
  })

  -- Create 3 small widgets
  for i = 1, 3 do
    local smallWidget = Gui.new({
      parent = smallWidgets,
      id = "smallWidget" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      width = 280,
      height = 173,
      gap = 10,
    })

    Gui.new({
      parent = smallWidget,
      id = "smallWidgetHeader" .. i,
      positioning = Positioning.FLEX,
      width = 270,
      height = 35,
    })

    Gui.new({
      parent = smallWidget,
      id = "smallWidgetContent" .. i,
      positioning = Positioning.FLEX,
      width = 270,
      height = 128,
    })
  end

  -- Right sidebar
  local rightSidebar = Gui.new({
    parent = mainContent,
    id = "rightSidebar",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    width = 250,
    height = 920,
    gap = 15,
  })

  -- Activity feed
  for i = 1, 8 do
    Gui.new({
      parent = rightSidebar,
      id = "activityItem" .. i,
      positioning = Positioning.FLEX,
      width = 240,
      height = 100,
    })
  end

  -- Verify dashboard structure
  luaunit.assertEquals(#dashboard.children, 2) -- header + main content
  luaunit.assertEquals(#header.children, 3) -- left + center + right
  luaunit.assertEquals(#headerLeft.children, 2) -- logo + title
  luaunit.assertEquals(#headerCenter.children, 2) -- search + quick actions
  luaunit.assertEquals(#quickActions.children, 4) -- 4 quick actions
  luaunit.assertEquals(#headerRight.children, 2) -- notifications + user menu

  luaunit.assertEquals(#mainContent.children, 3) -- left sidebar + center + right sidebar
  luaunit.assertEquals(#leftSidebar.children, 5) -- 5 sidebar sections
  luaunit.assertEquals(#centerArea.children, 2) -- top widgets + bottom widgets
  luaunit.assertEquals(#topWidgets.children, 4) -- 4 top widgets
  luaunit.assertEquals(#bottomWidgets.children, 2) -- large widget + small widgets
  luaunit.assertEquals(#smallWidgets.children, 3) -- 3 small widgets
  luaunit.assertEquals(#rightSidebar.children, 8) -- 8 activity items

  -- Verify large widget structure
  luaunit.assertEquals(#largeWidget.children, 2) -- header + content
  luaunit.assertEquals(#largeWidgetContent.children, 2) -- chart + details
  luaunit.assertEquals(#details.children, 6) -- 6 detail items
end

-- Run the tests
luaunit.LuaUnit.run()
