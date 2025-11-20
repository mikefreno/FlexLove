-- Tests for shorthand syntax features (flexDirection aliases, margin/padding shortcuts)
package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize ErrorHandler
ErrorHandler.init({})
local FlexLove = require("FlexLove")

TestShorthandSyntax = {}

function TestShorthandSyntax:setUp()
  FlexLove.init()
  FlexLove.setMode("immediate")
  FlexLove.beginFrame()
end

function TestShorthandSyntax:tearDown()
  FlexLove.endFrame()
  FlexLove.destroy()
end

-- ============================================================================
-- FlexDirection Aliases Tests
-- ============================================================================

function TestShorthandSyntax:testFlexDirectionRowEqualsHorizontal()
  -- Create two containers: one with "row", one with "horizontal"
  local containerRow = FlexLove.new({
    id = "container-row",
    width = 400,
    height = 200,
    positioning = "flex",
    flexDirection = "row",
  })

  local containerHorizontal = FlexLove.new({
    id = "container-horizontal",
    width = 400,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
  })

  -- Both should have the same internal flexDirection value
  luaunit.assertEquals(containerRow.flexDirection, "horizontal")
  luaunit.assertEquals(containerHorizontal.flexDirection, "horizontal")
  luaunit.assertEquals(containerRow.flexDirection, containerHorizontal.flexDirection)
end

function TestShorthandSyntax:testFlexDirectionColumnEqualsVertical()
  -- Create two containers: one with "column", one with "vertical"
  local containerColumn = FlexLove.new({
    id = "container-column",
    width = 200,
    height = 400,
    positioning = "flex",
    flexDirection = "column",
  })

  local containerVertical = FlexLove.new({
    id = "container-vertical",
    width = 200,
    height = 400,
    positioning = "flex",
    flexDirection = "vertical",
  })

  -- Both should have the same internal flexDirection value
  luaunit.assertEquals(containerColumn.flexDirection, "vertical")
  luaunit.assertEquals(containerVertical.flexDirection, "vertical")
  luaunit.assertEquals(containerColumn.flexDirection, containerVertical.flexDirection)
end

function TestShorthandSyntax:testFlexDirectionRowLayoutMatchesHorizontal()
  -- Create two containers with children: one with "row", one with "horizontal"
  local containerRow = FlexLove.new({
    id = "container-row",
    width = 400,
    height = 200,
    positioning = "flex",
    flexDirection = "row",
  })

  local containerHorizontal = FlexLove.new({
    id = "container-horizontal",
    width = 400,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
  })

  -- Add identical children to both
  for i = 1, 3 do
    FlexLove.new({
      id = "child-row-" .. i,
      width = 100,
      height = 50,
      parent = containerRow,
    })

    FlexLove.new({
      id = "child-horizontal-" .. i,
      width = 100,
      height = 50,
      parent = containerHorizontal,
    })
  end

  -- Trigger layout
  FlexLove.resize(800, 600)

  -- Children should be laid out identically
  for i = 1, 3 do
    local childRow = containerRow.children[i]
    local childHorizontal = containerHorizontal.children[i]

    luaunit.assertEquals(childRow.x, childHorizontal.x, "Child " .. i .. " x position should match")
    luaunit.assertEquals(childRow.y, childHorizontal.y, "Child " .. i .. " y position should match")
    luaunit.assertEquals(childRow.width, childHorizontal.width, "Child " .. i .. " width should match")
    luaunit.assertEquals(childRow.height, childHorizontal.height, "Child " .. i .. " height should match")
  end
end

function TestShorthandSyntax:testFlexDirectionColumnLayoutMatchesVertical()
  -- Create two containers with children: one with "column", one with "vertical"
  local containerColumn = FlexLove.new({
    id = "container-column",
    width = 200,
    height = 400,
    positioning = "flex",
    flexDirection = "column",
  })

  local containerVertical = FlexLove.new({
    id = "container-vertical",
    width = 200,
    height = 400,
    positioning = "flex",
    flexDirection = "vertical",
  })

  -- Add identical children to both
  for i = 1, 3 do
    FlexLove.new({
      id = "child-column-" .. i,
      width = 100,
      height = 50,
      parent = containerColumn,
    })

    FlexLove.new({
      id = "child-vertical-" .. i,
      width = 100,
      height = 50,
      parent = containerVertical,
    })
  end

  -- Trigger layout
  FlexLove.resize(800, 600)

  -- Children should be laid out identically
  for i = 1, 3 do
    local childColumn = containerColumn.children[i]
    local childVertical = containerVertical.children[i]

    luaunit.assertEquals(childColumn.x, childVertical.x, "Child " .. i .. " x position should match")
    luaunit.assertEquals(childColumn.y, childVertical.y, "Child " .. i .. " y position should match")
    luaunit.assertEquals(childColumn.width, childVertical.width, "Child " .. i .. " width should match")
    luaunit.assertEquals(childColumn.height, childVertical.height, "Child " .. i .. " height should match")
  end
end

function TestShorthandSyntax:testFlexDirectionRowWithJustifyContent()
  -- Test that "row" works with justifyContent like "horizontal" does
  local containerRow = FlexLove.new({
    id = "container-row",
    width = 400,
    height = 200,
    positioning = "flex",
    flexDirection = "row",
    justifyContent = "space-between",
  })

  local containerHorizontal = FlexLove.new({
    id = "container-horizontal",
    width = 400,
    height = 200,
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "space-between",
  })

  -- Add children
  for i = 1, 3 do
    FlexLove.new({
      id = "child-row-" .. i,
      width = 80,
      height = 50,
      parent = containerRow,
    })

    FlexLove.new({
      id = "child-horizontal-" .. i,
      width = 80,
      height = 50,
      parent = containerHorizontal,
    })
  end

  FlexLove.resize(800, 600)

  -- Verify space-between worked the same way
  for i = 1, 3 do
    local childRow = containerRow.children[i]
    local childHorizontal = containerHorizontal.children[i]
    luaunit.assertEquals(childRow.x, childHorizontal.x, "space-between should work identically")
  end
end

function TestShorthandSyntax:testFlexDirectionColumnWithAlignItems()
  -- Test that "column" works with alignItems like "vertical" does
  local containerColumn = FlexLove.new({
    id = "container-column",
    width = 200,
    height = 400,
    positioning = "flex",
    flexDirection = "column",
    alignItems = "center",
  })

  local containerVertical = FlexLove.new({
    id = "container-vertical",
    width = 200,
    height = 400,
    positioning = "flex",
    flexDirection = "vertical",
    alignItems = "center",
  })

  -- Add children
  for i = 1, 3 do
    FlexLove.new({
      id = "child-column-" .. i,
      width = 80,
      height = 50,
      parent = containerColumn,
    })

    FlexLove.new({
      id = "child-vertical-" .. i,
      width = 80,
      height = 50,
      parent = containerVertical,
    })
  end

  FlexLove.resize(800, 600)

  -- Verify center alignment worked the same way
  for i = 1, 3 do
    local childColumn = containerColumn.children[i]
    local childVertical = containerVertical.children[i]
    luaunit.assertEquals(childColumn.x, childVertical.x, "center alignment should work identically")
  end
end

-- ============================================================================
-- Margin Shorthand Tests
-- ============================================================================

function TestShorthandSyntax:testMarginNumberEqualsMarginTable()
  -- Create two elements: one with margin=10, one with margin={top=10,right=10,bottom=10,left=10}
  local parent = FlexLove.new({
    id = "parent",
    width = 400,
    height = 400,
  })

  local elementShorthand = FlexLove.new({
    id = "element-shorthand",
    width = 100,
    height = 100,
    margin = 10,
    parent = parent,
  })

  local elementExplicit = FlexLove.new({
    id = "element-explicit",
    width = 100,
    height = 100,
    margin = { top = 10, right = 10, bottom = 10, left = 10 },
    parent = parent,
  })

  -- Both should have the same margin values
  luaunit.assertEquals(elementShorthand.margin.top, 10)
  luaunit.assertEquals(elementShorthand.margin.right, 10)
  luaunit.assertEquals(elementShorthand.margin.bottom, 10)
  luaunit.assertEquals(elementShorthand.margin.left, 10)

  luaunit.assertEquals(elementShorthand.margin.top, elementExplicit.margin.top)
  luaunit.assertEquals(elementShorthand.margin.right, elementExplicit.margin.right)
  luaunit.assertEquals(elementShorthand.margin.bottom, elementExplicit.margin.bottom)
  luaunit.assertEquals(elementShorthand.margin.left, elementExplicit.margin.left)
end

function TestShorthandSyntax:testMarginShorthandLayoutMatchesExplicit()
  -- Create container with two children in column layout
  local container = FlexLove.new({
    id = "container",
    width = 400,
    height = 400,
    positioning = "flex",
    flexDirection = "column",
  })

  local elementShorthand = FlexLove.new({
    id = "element-shorthand",
    width = 100,
    height = 100,
    margin = 20,
    parent = container,
  })

  local elementExplicit = FlexLove.new({
    id = "element-explicit",
    width = 100,
    height = 100,
    margin = { top = 20, right = 20, bottom = 20, left = 20 },
    parent = container,
  })

  FlexLove.resize(800, 600)

  -- The explicit element should be positioned 20px below the shorthand element
  -- shorthand: y=20 (top margin), height=100, bottom margin=20 → next starts at 140
  -- explicit: y=140+20=160
  luaunit.assertEquals(elementShorthand.y, 20, "Shorthand element should have top margin applied")
  luaunit.assertEquals(elementExplicit.y, 160, "Explicit element should be positioned after shorthand's bottom margin")
end

function TestShorthandSyntax:testMarginZeroShorthand()
  local element = FlexLove.new({
    id = "element",
    width = 100,
    height = 100,
    margin = 0,
  })

  luaunit.assertEquals(element.margin.top, 0)
  luaunit.assertEquals(element.margin.right, 0)
  luaunit.assertEquals(element.margin.bottom, 0)
  luaunit.assertEquals(element.margin.left, 0)
end

function TestShorthandSyntax:testMarginLargeValueShorthand()
  local element = FlexLove.new({
    id = "element",
    width = 100,
    height = 100,
    margin = 100,
  })

  luaunit.assertEquals(element.margin.top, 100)
  luaunit.assertEquals(element.margin.right, 100)
  luaunit.assertEquals(element.margin.bottom, 100)
  luaunit.assertEquals(element.margin.left, 100)
end

function TestShorthandSyntax:testMarginDecimalShorthand()
  local element = FlexLove.new({
    id = "element",
    width = 100,
    height = 100,
    margin = 15.5,
  })

  luaunit.assertEquals(element.margin.top, 15.5)
  luaunit.assertEquals(element.margin.right, 15.5)
  luaunit.assertEquals(element.margin.bottom, 15.5)
  luaunit.assertEquals(element.margin.left, 15.5)
end

-- ============================================================================
-- Padding Shorthand Tests
-- ============================================================================

function TestShorthandSyntax:testPaddingNumberEqualsPaddingTable()
  -- Create two elements: one with padding=20, one with padding={top=20,right=20,bottom=20,left=20}
  local elementShorthand = FlexLove.new({
    id = "element-shorthand",
    width = 200,
    height = 200,
    padding = 20,
  })

  local elementExplicit = FlexLove.new({
    id = "element-explicit",
    width = 200,
    height = 200,
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })

  -- Both should have the same padding values
  luaunit.assertEquals(elementShorthand.padding.top, 20)
  luaunit.assertEquals(elementShorthand.padding.right, 20)
  luaunit.assertEquals(elementShorthand.padding.bottom, 20)
  luaunit.assertEquals(elementShorthand.padding.left, 20)

  luaunit.assertEquals(elementShorthand.padding.top, elementExplicit.padding.top)
  luaunit.assertEquals(elementShorthand.padding.right, elementExplicit.padding.right)
  luaunit.assertEquals(elementShorthand.padding.bottom, elementExplicit.padding.bottom)
  luaunit.assertEquals(elementShorthand.padding.left, elementExplicit.padding.left)
end

function TestShorthandSyntax:testPaddingShorthandAffectsContentArea()
  -- Create container with padding and a child
  local containerShorthand = FlexLove.new({
    id = "container-shorthand",
    width = 200,
    height = 200,
    padding = 30,
  })

  local containerExplicit = FlexLove.new({
    id = "container-explicit",
    width = 200,
    height = 200,
    padding = { top = 30, right = 30, bottom = 30, left = 30 },
  })

  -- Add children
  local childShorthand = FlexLove.new({
    id = "child-shorthand",
    width = "100%",
    height = "100%",
    parent = containerShorthand,
  })

  local childExplicit = FlexLove.new({
    id = "child-explicit",
    width = "100%",
    height = "100%",
    parent = containerExplicit,
  })

  FlexLove.resize(800, 600)

  -- Children should have the same dimensions (200 - 30*2 = 140)
  luaunit.assertEquals(childShorthand.width, 140)
  luaunit.assertEquals(childShorthand.height, 140)
  luaunit.assertEquals(childExplicit.width, 140)
  luaunit.assertEquals(childExplicit.height, 140)

  luaunit.assertEquals(childShorthand.width, childExplicit.width)
  luaunit.assertEquals(childShorthand.height, childExplicit.height)
end

function TestShorthandSyntax:testPaddingZeroShorthand()
  local element = FlexLove.new({
    id = "element",
    width = 100,
    height = 100,
    padding = 0,
  })

  luaunit.assertEquals(element.padding.top, 0)
  luaunit.assertEquals(element.padding.right, 0)
  luaunit.assertEquals(element.padding.bottom, 0)
  luaunit.assertEquals(element.padding.left, 0)
end

function TestShorthandSyntax:testPaddingLargeValueShorthand()
  local element = FlexLove.new({
    id = "element",
    width = 300,
    height = 300,
    padding = 50,
  })

  luaunit.assertEquals(element.padding.top, 50)
  luaunit.assertEquals(element.padding.right, 50)
  luaunit.assertEquals(element.padding.bottom, 50)
  luaunit.assertEquals(element.padding.left, 50)
end

function TestShorthandSyntax:testPaddingDecimalShorthand()
  local element = FlexLove.new({
    id = "element",
    width = 100,
    height = 100,
    padding = 12.5,
  })

  luaunit.assertEquals(element.padding.top, 12.5)
  luaunit.assertEquals(element.padding.right, 12.5)
  luaunit.assertEquals(element.padding.bottom, 12.5)
  luaunit.assertEquals(element.padding.left, 12.5)
end

-- ============================================================================
-- Combined Tests (FlexDirection + Margin/Padding)
-- ============================================================================

function TestShorthandSyntax:testRowWithMarginShorthand()
  local container = FlexLove.new({
    id = "container",
    width = 500,
    height = 200,
    flexDirection = "row", -- Alias for "horizontal"
  })

  for i = 1, 3 do
    FlexLove.new({
      id = "child-" .. i,
      width = 100,
      height = 100,
      margin = 10, -- Shorthand
      parent = container,
    })
  end

  FlexLove.resize(800, 600)

  -- First child: x=10 (left margin)
  -- Second child: x=10+100+10 (first child's margin-right) + 10 (own margin-left) = 130
  -- Third child: x=130+100+10+10 = 250
  luaunit.assertEquals(container.children[1].x, 10)
  luaunit.assertEquals(container.children[2].x, 130)
  luaunit.assertEquals(container.children[3].x, 250)
end

function TestShorthandSyntax:testColumnWithPaddingShorthand()
  local container = FlexLove.new({
    id = "container",
    width = 200,
    height = 500,
    flexDirection = "column", -- Alias for "vertical"
    padding = 15, -- Shorthand
  })

  for i = 1, 3 do
    FlexLove.new({
      id = "child-" .. i,
      width = 100,
      height = 50,
      parent = container,
    })
  end

  FlexLove.resize(800, 600)

  -- Children should start at y=15 (top padding)
  -- First child: y=15
  -- Second child: y=15+50=65
  -- Third child: y=65+50=115
  luaunit.assertEquals(container.children[1].y, 15)
  luaunit.assertEquals(container.children[2].y, 65)
  luaunit.assertEquals(container.children[3].y, 115)
end

function TestShorthandSyntax:testRowAndColumnAliasesWithAllShorthands()
  -- Complex test: use all shorthands together
  local container = FlexLove.new({
    id = "container",
    width = 600,
    height = 400,
    flexDirection = "row", -- Alias
    padding = 20, -- Shorthand
  })

  for i = 1, 2 do
    FlexLove.new({
      id = "child-" .. i,
      width = 150,
      height = 100,
      margin = 10, -- Shorthand
      parent = container,
    })
  end

  FlexLove.resize(800, 600)

  -- First child: x=20 (container padding) + 10 (own margin) = 30
  -- Second child: x=30 + 150 + 10 (first child's margin-right) + 10 (own margin-left) = 200
  luaunit.assertEquals(container.children[1].x, 30)
  luaunit.assertEquals(container.children[2].x, 200)

  -- Both children should be at y=20 (container padding) + 10 (own margin) = 30
  luaunit.assertEquals(container.children[1].y, 30)
  luaunit.assertEquals(container.children[2].y, 30)
end

function TestShorthandSyntax:testNestedContainersWithShorthands()
  -- Test nested containers with multiple shorthand usages
  local outerContainer = FlexLove.new({
    id = "outer",
    width = 500,
    height = 500,
    flexDirection = "column", -- Alias
    padding = 25, -- Shorthand
  })

  local innerContainer = FlexLove.new({
    id = "inner",
    width = 400,
    height = 200,
    flexDirection = "row", -- Alias
    margin = 15, -- Shorthand
    padding = 10, -- Shorthand
    parent = outerContainer,
  })

  local child = FlexLove.new({
    id = "child",
    width = 100,
    height = 100,
    margin = 5, -- Shorthand
    parent = innerContainer,
  })

  FlexLove.resize(800, 600)

  -- Inner container position: y=25 (outer padding) + 15 (own margin) = 40
  luaunit.assertEquals(innerContainer.y, 40)

  -- Child position within inner:
  -- x relative to inner = 10 (inner padding) + 5 (own margin) = 15
  -- y relative to inner = 10 (inner padding) + 5 (own margin) = 15
  local expectedChildX = innerContainer.x + 15
  local expectedChildY = innerContainer.y + 15
  luaunit.assertEquals(child.x, expectedChildX)
  luaunit.assertEquals(child.y, expectedChildY)
end

-- ============================================================================
-- Edge Cases
-- ============================================================================

function TestShorthandSyntax:testFlexDirectionAliasDoesNotAffectOtherValues()
  local element = FlexLove.new({
    id = "element",
    width = 200,
    height = 200,
    positioning = "flex",
    flexDirection = "row",
    justifyContent = "center",
    alignItems = "center",
  })

  -- Using alias shouldn't affect other properties
  luaunit.assertEquals(element.justifyContent, "center")
  luaunit.assertEquals(element.alignItems, "center")
end

function TestShorthandSyntax:testMarginShorthandDoesNotAffectPadding()
  local element = FlexLove.new({
    id = "element",
    width = 200,
    height = 200,
    margin = 10,
    padding = { top = 5, right = 5, bottom = 5, left = 5 },
  })

  -- Margin shorthand shouldn't affect padding
  luaunit.assertEquals(element.padding.top, 5)
  luaunit.assertEquals(element.padding.right, 5)
  luaunit.assertEquals(element.padding.bottom, 5)
  luaunit.assertEquals(element.padding.left, 5)
end

function TestShorthandSyntax:testPaddingShorthandDoesNotAffectMargin()
  local element = FlexLove.new({
    id = "element",
    width = 200,
    height = 200,
    padding = 20,
    margin = { top = 10, right = 10, bottom = 10, left = 10 },
  })

  -- Padding shorthand shouldn't affect margin
  luaunit.assertEquals(element.margin.top, 10)
  luaunit.assertEquals(element.margin.right, 10)
  luaunit.assertEquals(element.margin.bottom, 10)
  luaunit.assertEquals(element.margin.left, 10)
end

function TestShorthandSyntax:testBothMarginAndPaddingShorthands()
  local element = FlexLove.new({
    id = "element",
    width = 200,
    height = 200,
    margin = 15,
    padding = 25,
  })

  -- Both should be expanded correctly
  luaunit.assertEquals(element.margin.top, 15)
  luaunit.assertEquals(element.margin.right, 15)
  luaunit.assertEquals(element.margin.bottom, 15)
  luaunit.assertEquals(element.margin.left, 15)

  luaunit.assertEquals(element.padding.top, 25)
  luaunit.assertEquals(element.padding.right, 25)
  luaunit.assertEquals(element.padding.bottom, 25)
  luaunit.assertEquals(element.padding.left, 25)
end

function TestShorthandSyntax:testNegativeMarginShorthand()
  -- Negative margins should work
  local element = FlexLove.new({
    id = "element",
    width = 100,
    height = 100,
    margin = -5,
  })

  luaunit.assertEquals(element.margin.top, -5)
  luaunit.assertEquals(element.margin.right, -5)
  luaunit.assertEquals(element.margin.bottom, -5)
  luaunit.assertEquals(element.margin.left, -5)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
