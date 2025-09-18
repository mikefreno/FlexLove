package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

-- Create test cases
TestAuxiliaryFunctions = {}

function TestAuxiliaryFunctions:setUp()
  self.GUI = FlexLove.GUI
end

function TestAuxiliaryFunctions:testFindElementById()
  local root = self.GUI.new({
    id = "root",
    x = 0,
    y = 0,
    w = 500,
    h = 500,
  })

  local child = self.GUI.new({
    id = "child",
    parent = root,
    x = 0,
    y = 0,
    w = 100,
    h = 100,
  })

  -- Test finding elements by ID
  luaunit.assertNotNil(self.GUI.findElementById)
  local foundRoot = self.GUI:findElementById("root")
  local foundChild = self.GUI:findElementById("child")

  luaunit.assertNotNil(foundRoot)
  luaunit.assertNotNil(foundChild)
  luaunit.assertEquals(foundRoot, root)
  luaunit.assertEquals(foundChild, child)
end

function TestAuxiliaryFunctions:testFindElementsByClass()
  local root = self.GUI.new({
    class = "container",
    x = 0,
    y = 0,
    w = 500,
    h = 500,
  })

  self.GUI.new({
    class = "item",
    parent = root,
    x = 0,
    y = 0,
    w = 100,
    h = 100,
  })

  self.GUI.new({
    class = "item",
    parent = root,
    x = 100,
    y = 0,
    w = 100,
    h = 100,
  })

  -- Test finding elements by class
  luaunit.assertNotNil(self.GUI.findElementsByClass)
  local items = self.GUI:findElementsByClass("item")
  luaunit.assertEquals(#items, 2)

  local containers = self.GUI:findElementsByClass("container")
  luaunit.assertEquals(#containers, 1)
  luaunit.assertEquals(containers[1], root)
end

function TestAuxiliaryFunctions:testGetElementsAtPoint()
  local root = self.GUI.new({
    x = 0,
    y = 0,
    w = 500,
    h = 500,
  })

  self.GUI.new({
    parent = root,
    x = 50,
    y = 50,
    w = 100,
    h = 100,
  })

  self.GUI.new({
    parent = root,
    x = 200,
    y = 200,
    w = 100,
    h = 100,
  })

  -- Test getting elements at specific points
  luaunit.assertNotNil(self.GUI.getElementsAtPoint)
  local elements1 = self.GUI:getElementsAtPoint(75, 75)
  local elements2 = self.GUI:getElementsAtPoint(250, 250)
  local elements3 = self.GUI:getElementsAtPoint(0, 0)

  luaunit.assertTrue(#elements1 >= 2) -- Should find root and child1
  luaunit.assertTrue(#elements2 >= 2) -- Should find root and child2
  luaunit.assertEquals(#elements3, 1) -- Should only find root
end

function TestAuxiliaryFunctions:testQuerySelector()
  local root = self.GUI.new({
    id = "root",
    class = "container",
    x = 0,
    y = 0,
    w = 500,
    h = 500,
  })

  self.GUI.new({
    id = "btn1",
    class = "button primary",
    parent = root,
    x = 0,
    y = 0,
    w = 100,
    h = 100,
  })

  self.GUI.new({
    id = "btn2",
    class = "button secondary",
    parent = root,
    x = 100,
    y = 0,
    w = 100,
    h = 100,
  })

  -- Test querySelector functionality
  luaunit.assertNotNil(self.GUI.querySelector)
  local container = self.GUI:querySelector(".container")
  local primaryBtn = self.GUI:querySelector(".button.primary")
  local secondaryBtn = self.GUI:querySelector(".button.secondary")
  local specificBtn = self.GUI:querySelector("#btn1")

  luaunit.assertNotNil(container)
  luaunit.assertNotNil(primaryBtn)
  luaunit.assertNotNil(secondaryBtn)
  luaunit.assertNotNil(specificBtn)
  luaunit.assertEquals(container, root)
end

function TestAuxiliaryFunctions:testQuerySelectorAll()
  local root = self.GUI.new({
    class = "container",
    x = 0,
    y = 0,
    w = 500,
    h = 500,
  })

  for i = 1, 3 do
    self.GUI.new({
      class = "item",
      parent = root,
      x = i * 100,
      y = 0,
      w = 100,
      h = 100,
    })
  end

  -- Test querySelectorAll functionality
  luaunit.assertNotNil(self.GUI.querySelectorAll)
  local items = self.GUI:querySelectorAll(".item")
  local containers = self.GUI:querySelectorAll(".container")

  luaunit.assertEquals(#items, 3)
  luaunit.assertEquals(#containers, 1)
end

function TestAuxiliaryFunctions:testDebugPrint()
  local root = self.GUI.new({
    id = "root",
    x = 0,
    y = 0,
    w = 500,
    h = 500,
  })

  self.GUI.new({
    id = "child",
    parent = root,
    x = 0,
    y = 0,
    w = 100,
    h = 100,
  })

  -- Test debug print functionality
  luaunit.assertNotNil(self.GUI.debugPrint)
  local debugOutput = self.GUI:debugPrint()
  luaunit.assertNotNil(debugOutput)
  luaunit.assertString(debugOutput)
  luaunit.assertTrue(string.find(debugOutput, "root") ~= nil)
  luaunit.assertTrue(string.find(debugOutput, "child") ~= nil)
end

function TestAuxiliaryFunctions:testMeasureText()
  local text = "Hello World"
  local fontSize = 12

  -- Test text measurement functionality
  luaunit.assertNotNil(self.GUI.measureText)
  local width, height = self.GUI:measureText(text, fontSize)

  luaunit.assertNotNil(width)
  luaunit.assertNotNil(height)
  luaunit.assertNumber(width)
  luaunit.assertNumber(height)
  luaunit.assertTrue(width > 0)
  luaunit.assertTrue(height > 0)
end

function TestAuxiliaryFunctions:testUtilityFunctions()
  -- Test color conversion
  luaunit.assertNotNil(self.GUI.hexToRGB)
  local r, g, b = self.GUI:hexToRGB("#FF0000")
  luaunit.assertEquals(r, 255)
  luaunit.assertEquals(g, 0)
  luaunit.assertEquals(b, 0)

  -- Test point inside rectangle
  luaunit.assertNotNil(self.GUI.pointInRect)
  local isInside = self.GUI:pointInRect(10, 10, 0, 0, 20, 20)
  luaunit.assertTrue(isInside)

  -- Test rectangle intersection
  luaunit.assertNotNil(self.GUI.rectIntersect)
  local intersects = self.GUI:rectIntersect(0, 0, 10, 10, 5, 5, 10, 10)
  luaunit.assertTrue(intersects)
end

luaunit.LuaUnit.run()
