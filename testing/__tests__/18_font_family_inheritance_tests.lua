package.path = package.path .. ";?.lua"

local lu = require("testing.luaunit")
require("testing.loveStub")
local FlexLove = require("FlexLove")

TestFontFamilyInheritance = {}

function TestFontFamilyInheritance:setUp()
  FlexLove.Gui.destroy()
  FlexLove.Gui.init({ baseScale = { width = 1920, height = 1080 } })
end

function TestFontFamilyInheritance:tearDown()
  FlexLove.Gui.destroy()
end

function TestFontFamilyInheritance:testBasicInheritanceFromParent()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
    fontFamily = "Arial",
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    text = "Child",
  })

  lu.assertEquals(child.fontFamily, "Arial", "Child should inherit fontFamily from parent")
end

function TestFontFamilyInheritance:testInheritanceThroughMultipleLevels()
  local grandparent = FlexLove.Element.new({
    width = 300,
    height = 300,
    fontFamily = "Times",
  })

  local parent = FlexLove.Element.new({
    parent = grandparent,
    width = 200,
    height = 200,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    text = "Grandchild",
  })

  lu.assertEquals(parent.fontFamily, "Times", "Parent should inherit fontFamily from grandparent")
  lu.assertEquals(child.fontFamily, "Times", "Child should inherit fontFamily through parent")
end

function TestFontFamilyInheritance:testExplicitOverrideBreaksInheritance()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
    fontFamily = "Arial",
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    text = "Child",
    fontFamily = "Helvetica",
  })

  lu.assertEquals(child.fontFamily, "Helvetica", "Child's explicit fontFamily should override parent's")
end

function TestFontFamilyInheritance:testInheritanceWithNoParentFontFamily()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
  })

  local child = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    text = "Child",
  })

  lu.assertNil(child.fontFamily, "Child should have nil fontFamily when parent doesn't have one")
end

function TestFontFamilyInheritance:testInheritanceInFlexContainer()
  local flexParent = FlexLove.Element.new({
    width = 300,
    height = 300,
    positioning = FlexLove.enums.Positioning.FLEX,
    flexDirection = FlexLove.enums.FlexDirection.HORIZONTAL,
    fontFamily = "Courier",
  })

  local child1 = FlexLove.Element.new({
    parent = flexParent,
    width = 100,
    height = 100,
    text = "Child 1",
  })

  local child2 = FlexLove.Element.new({
    parent = flexParent,
    width = 100,
    height = 100,
    text = "Child 2",
  })

  lu.assertEquals(child1.fontFamily, "Courier", "Child 1 should inherit fontFamily in flex container")
  lu.assertEquals(child2.fontFamily, "Courier", "Child 2 should inherit fontFamily in flex container")
end

function TestFontFamilyInheritance:testInheritanceInGridContainer()
  local gridParent = FlexLove.Element.new({
    width = 300,
    height = 300,
    positioning = FlexLove.enums.Positioning.GRID,
    gridRows = 2,
    gridColumns = 2,
    fontFamily = "Verdana",
  })

  local child1 = FlexLove.Element.new({
    parent = gridParent,
    text = "Cell 1",
  })

  local child2 = FlexLove.Element.new({
    parent = gridParent,
    text = "Cell 2",
  })

  lu.assertEquals(child1.fontFamily, "Verdana", "Child 1 should inherit fontFamily in grid container")
  lu.assertEquals(child2.fontFamily, "Verdana", "Child 2 should inherit fontFamily in grid container")
end

function TestFontFamilyInheritance:testMixedInheritanceAndOverride()
  local grandparent = FlexLove.Element.new({
    width = 400,
    height = 400,
    fontFamily = "Georgia",
  })

  local parent = FlexLove.Element.new({
    parent = grandparent,
    width = 300,
    height = 300,
  })

  local child1 = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    text = "Child 1",
  })

  local child2 = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    text = "Child 2",
    fontFamily = "Impact",
  })

  lu.assertEquals(parent.fontFamily, "Georgia", "Parent should inherit from grandparent")
  lu.assertEquals(child1.fontFamily, "Georgia", "Child 1 should inherit through parent")
  lu.assertEquals(child2.fontFamily, "Impact", "Child 2 should use explicit fontFamily")
end

function TestFontFamilyInheritance:testInheritanceWithAbsolutePositioning()
  local parent = FlexLove.Element.new({
    width = 200,
    height = 200,
    fontFamily = "Comic Sans",
  })

  local child = FlexLove.Element.new({
    parent = parent,
    positioning = FlexLove.enums.Positioning.ABSOLUTE,
    x = 50,
    y = 50,
    width = 100,
    height = 100,
    text = "Absolute Child",
  })

  lu.assertEquals(child.fontFamily, "Comic Sans", "Absolutely positioned child should still inherit fontFamily")
end

function TestFontFamilyInheritance:testInheritanceDoesNotAffectSiblings()
  local parent = FlexLove.Element.new({
    width = 300,
    height = 300,
    fontFamily = "Tahoma",
  })

  local child1 = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    text = "Child 1",
    fontFamily = "Trebuchet",
  })

  local child2 = FlexLove.Element.new({
    parent = parent,
    width = 100,
    height = 100,
    text = "Child 2",
  })

  lu.assertEquals(child1.fontFamily, "Trebuchet", "Child 1 should have its own fontFamily")
  lu.assertEquals(child2.fontFamily, "Tahoma", "Child 2 should inherit parent's fontFamily")
  lu.assertNotEquals(child2.fontFamily, child1.fontFamily, "Siblings should have independent fontFamily values")
end

print("Running Font Family Inheritance Tests...")
lu.LuaUnit.run()
