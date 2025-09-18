package.path = package.path .. ";game/libs/?.lua;?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

local Positioning = FlexLove.enums.Positioning
local TextAlign = FlexLove.enums.TextAlign
local Color = FlexLove.Color

-- Create test cases
TestElementProperties = {}

function TestElementProperties:setUp()
  self.GUI = FlexLove.GUI
end

function TestElementProperties:testBasicProperties()
  local element = self.GUI.new({
    x = 10,
    y = 20,
    w = 100,
    h = 50,
    z = 1,
    positioning = Positioning.ABSOLUTE,
  })

  -- Test basic properties
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.x, 10)
  luaunit.assertEquals(element.y, 20)
  luaunit.assertEquals(element.z, 1)
  luaunit.assertEquals(element.width, 100)
  luaunit.assertEquals(element.height, 50)
  luaunit.assertEquals(element.positioning, Positioning.ABSOLUTE)
end

function TestElementProperties:testPropertyModification()
  local element = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
  })

  -- Test property modification
  luaunit.assertNotNil(element)
  element.x = 50
  element.y = 60
  element.width = 200
  element.height = 150

  luaunit.assertEquals(element.x, 50)
  luaunit.assertEquals(element.y, 60)
  luaunit.assertEquals(element.width, 200)
  luaunit.assertEquals(element.height, 150)
end

function TestElementProperties:testParentChildRelationship()
  local parent = self.GUI.new({
    x = 0,
    y = 0,
    w = 500,
    h = 500,
  })

  local child = self.GUI.new({
    parent = parent,
    x = 10,
    y = 10,
    w = 100,
    h = 100,
  })

  -- Test parent-child relationship
  luaunit.assertNotNil(parent)
  luaunit.assertNotNil(child)
  luaunit.assertNotNil(parent.children)
  luaunit.assertEquals(child.parent, parent)
  luaunit.assertTrue(#parent.children == 1)
  luaunit.assertEquals(parent.children[1], child)
end

function TestElementProperties:testBounds()
  local element = self.GUI.new({
    x = 10,
    y = 20,
    w = 100,
    h = 50,
  })

  -- Test bounds calculation
  luaunit.assertNotNil(element)
  luaunit.assertNotNil(element.getBounds)
  local bounds = element:getBounds()
  luaunit.assertEquals(bounds.x, 10)
  luaunit.assertEquals(bounds.y, 20)
  luaunit.assertEquals(bounds.width, 100)
  luaunit.assertEquals(bounds.height, 50)
end

function TestElementProperties:testZLayering()
  local parent = self.GUI.new({
    x = 0,
    y = 0,
    w = 500,
    h = 500,
  })

  local child1 = self.GUI.new({
    parent = parent,
    x = 0,
    y = 0,
    w = 100,
    h = 100,
    z = 1,
  })

  local child2 = self.GUI.new({
    parent = parent,
    x = 0,
    y = 0,
    w = 100,
    h = 100,
    z = 2,
  })

  -- Test z ordering
  luaunit.assertNotNil(parent)
  luaunit.assertNotNil(child1)
  luaunit.assertNotNil(child2)
  luaunit.assertNotNil(child1.z)
  luaunit.assertNotNil(child2.z)
  luaunit.assertTrue(child1.z < child2.z)
end

function TestElementProperties:testColors()
  local element = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
    background = Color.new(1, 0, 0, 1), -- Red
    textColor = Color.new(0, 1, 0, 1), -- Green
    borderColor = Color.new(0, 0, 1, 1), -- Blue
  })

  -- Test color assignments
  luaunit.assertNotNil(element.background)
  luaunit.assertEquals(element.background.r, 1)
  luaunit.assertEquals(element.background.g, 0)
  luaunit.assertEquals(element.background.b, 0)
  luaunit.assertEquals(element.background.a, 1)

  luaunit.assertNotNil(element.textColor)
  luaunit.assertEquals(element.textColor.r, 0)
  luaunit.assertEquals(element.textColor.g, 1)
  luaunit.assertEquals(element.textColor.b, 0)
  luaunit.assertEquals(element.textColor.a, 1)

  luaunit.assertNotNil(element.borderColor)
  luaunit.assertEquals(element.borderColor.r, 0)
  luaunit.assertEquals(element.borderColor.g, 0)
  luaunit.assertEquals(element.borderColor.b, 1)
  luaunit.assertEquals(element.borderColor.a, 1)
end

function TestElementProperties:testText()
  local element = self.GUI.new({
    x = 0,
    y = 0,
    w = 200,
    h = 100,
    text = "Test Text",
    textSize = 16,
    textAlign = TextAlign.CENTER,
  })

  -- Test text properties
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.text, "Test Text")
  luaunit.assertEquals(element.textSize, 16)
  luaunit.assertEquals(element.textAlign, TextAlign.CENTER)

  -- Test text update
  element:updateText("New Text", true)
  luaunit.assertEquals(element.text, "New Text")
end

function TestElementProperties:testOpacity()
  local element = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
    opacity = 0.5,
  })

  -- Test opacity property and updates
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.opacity, 0.5)

  element:updateOpacity(0.8)
  luaunit.assertEquals(element.opacity, 0.8)
end

function TestElementProperties:testBorder()
  local element = self.GUI.new({
    x = 0,
    y = 0,
    w = 100,
    h = 100,
    border = {
      top = true,
      right = true,
      bottom = true,
      left = true,
    },
  })

  -- Test border configuration
  luaunit.assertNotNil(element)
  luaunit.assertTrue(element.border.top)
  luaunit.assertTrue(element.border.right)
  luaunit.assertTrue(element.border.bottom)
  luaunit.assertTrue(element.border.left)
end

luaunit.LuaUnit.run()

