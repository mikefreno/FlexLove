package.path = package.path .. ";?.lua"

local lu = require("testing.luaunit")
require("testing.loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

TestNegativeMargin = {}

function TestNegativeMargin:setUp()
  FlexLove.Gui.destroy()
  FlexLove.Gui.init({ baseScale = { width = 1920, height = 1080 } })
end

function TestNegativeMargin:tearDown()
  FlexLove.Gui.destroy()
end

function TestNegativeMargin:testBasicNegativeMarginTop()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
    positioning = FlexLove.Positioning.FLEX,
    flexDirection = FlexLove.FlexDirection.VERTICAL,
  })

  local child1 = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 50,
  })

  local child2 = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 50,
    margin = { top = -20 },
  })

  parent:layoutChildren()

  lu.assertNotNil(child2.margin.top)
  lu.assertEquals(child2.margin.top, -20, "Child2 should have -20 top margin")
end

function TestNegativeMargin:testNegativeMarginLeft()
  local parent = FlexLove.Element.new({
    width = 300,
    height = 100,
    positioning = FlexLove.Positioning.FLEX,
    flexDirection = FlexLove.FlexDirection.HORIZONTAL,
  })

  local child1 = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 50,
  })

  local child2 = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 50,
    margin = { left = -30 },
  })

  parent:layoutChildren()

  lu.assertEquals(child2.margin.left, -30, "Child2 should have -30 left margin")
end

function TestNegativeMargin:testNegativeMarginRight()
  local parent = FlexLove.Element.new({
    width = 300,
    height = 100,
    positioning = FlexLove.Positioning.FLEX,
    flexDirection = FlexLove.FlexDirection.HORIZONTAL,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 50,
    margin = { right = -15 },
  })

  parent:layoutChildren()

  lu.assertEquals(child.margin.right, -15, "Child should have -15 right margin")
end

function TestNegativeMargin:testNegativeMarginBottom()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
    positioning = FlexLove.Positioning.FLEX,
    flexDirection = FlexLove.FlexDirection.VERTICAL,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 50,
    margin = { bottom = -10 },
  })

  parent:layoutChildren()

  lu.assertEquals(child.margin.bottom, -10, "Child should have -10 bottom margin")
end

function TestNegativeMargin:testMultipleNegativeMargins()
  local parent = FlexLove.Element.new({
    width = 300,
    height = 300,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    margin = { top = -20, right = -15, bottom = -10, left = -5 },
  })

  lu.assertEquals(child.margin.top, -20)
  lu.assertEquals(child.margin.right, -15)
  lu.assertEquals(child.margin.bottom, -10)
  lu.assertEquals(child.margin.left, -5)
end

function TestNegativeMargin:testNegativeMarginWithPercentage()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    margin = { left = "-10%" },
  })

  lu.assertEquals(child.margin.left, -20, "Negative 10% of 200 width should be -20")
end

function TestNegativeMargin:testNegativeMarginWithVwUnit()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    margin = { left = "-2vw" },
  })

  lu.assertNotNil(child.margin.left)
  lu.assertTrue(child.margin.left < 0, "Negative vw margin should be negative")
end

function TestNegativeMargin:testNegativeMarginWithVhUnit()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    margin = { top = "-2vh" },
  })

  lu.assertNotNil(child.margin.top)
  lu.assertTrue(child.margin.top < 0, "Negative vh margin should be negative")
end

function TestNegativeMargin:testNegativeMarginInGridLayout()
  local gridParent = FlexLove.Element.new({
    width = 300,
    height = 300,
    positioning = FlexLove.Positioning.GRID,
    gridRows = 2,
    gridColumns = 2,
  })

  local child = FlexLove.Element.new({
    parent = gridParent,
    width = 100,
    height = 100,
    margin = { top = -10, left = -10 },
  })

  lu.assertEquals(child.margin.top, -10)
  lu.assertEquals(child.margin.left, -10)
end

function TestNegativeMargin:testNegativeMarginVerticalShorthand()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    margin = { vertical = -15 },
  })

  lu.assertEquals(child.margin.top, -15, "Vertical shorthand should set top to -15")
  lu.assertEquals(child.margin.bottom, -15, "Vertical shorthand should set bottom to -15")
end

function TestNegativeMargin:testNegativeMarginHorizontalShorthand()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    margin = { horizontal = -20 },
  })

  lu.assertEquals(child.margin.left, -20, "Horizontal shorthand should set left to -20")
  lu.assertEquals(child.margin.right, -20, "Horizontal shorthand should set right to -20")
end

function TestNegativeMargin:testMixedPositiveAndNegativeMargins()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    margin = { top = 20, right = -10, bottom = 15, left = -5 },
  })

  lu.assertEquals(child.margin.top, 20)
  lu.assertEquals(child.margin.right, -10)
  lu.assertEquals(child.margin.bottom, 15)
  lu.assertEquals(child.margin.left, -5)
end

function TestNegativeMargin:testNegativeMarginWithAbsolutePositioning()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    positioning = FlexLove.Positioning.ABSOLUTE,
    x = 50,
    y = 50,
    width = 100,
    height = 100,
    margin = { top = -10, left = -10 },
  })

  lu.assertEquals(child.margin.top, -10)
  lu.assertEquals(child.margin.left, -10)
end

function TestNegativeMargin:testNegativeMarginDoesNotAffectPadding()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    padding = { top = 10, left = 10 },
    margin = { top = -15, left = -15 },
  })

  lu.assertEquals(child.padding.top, 10, "Padding should not be affected by negative margin")
  lu.assertEquals(child.padding.left, 10, "Padding should not be affected by negative margin")
  lu.assertEquals(child.margin.top, -15)
  lu.assertEquals(child.margin.left, -15)
end

function TestNegativeMargin:testExtremeNegativeMarginValues()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    margin = { top = -1000, left = -1000 },
  })

  lu.assertEquals(child.margin.top, -1000, "Extreme negative margin should be allowed")
  lu.assertEquals(child.margin.left, -1000, "Extreme negative margin should be allowed")
end

function TestNegativeMargin:testNegativeMarginInNestedElements()
  local grandparent = FlexLove.Element.new({
    width = 300,
    height = 300,
  })

  local parent = FlexLove.Element.new({
    parent = grandparent,
    width = 200,
    height = 200,
    margin = { top = -20, left = -20 },
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    margin = { top = -10, left = -10 },
  })

  lu.assertEquals(parent.margin.top, -20)
  lu.assertEquals(parent.margin.left, -20)
  lu.assertEquals(child.margin.top, -10)
  lu.assertEquals(child.margin.left, -10)
end

print("Running Negative Margin Tests...")
lu.LuaUnit.run()
