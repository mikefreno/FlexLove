package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")

-- Import only the enum values we need for each test
local FlexDirection = FlexLove.enums.FlexDirection
local Positioning = FlexLove.enums.Positioning
local JustifyContent = FlexLove.enums.JustifyContent
local AlignItems = FlexLove.enums.AlignItems

-- Create test cases
TestPerformance = {}

function TestPerformance:setUp()
  self.GUI = FlexLove.GUI
end

-- Helper function to measure execution time
local function measure(fn)
  local start = os.clock()
  fn()
  return os.clock() - start
end

function TestPerformance:testLargeNumberOfChildren()
  -- Test performance with a large number of children
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 1000,
    h = 1000,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_START,
  })

  -- Create 100 children
  local createTime = measure(function()
    for _ = 1, 100 do
      self.GUI.new({
        parent = container,
        w = 50,
        h = 50,
        positioning = Positioning.FLEX,
      })
    end
  end)

  -- Print creation time for visibility
  print(string.format("Creating 100 children took: %.4f seconds", createTime))

  -- Verify container has all children
  luaunit.assertEquals(#container.children, 100)

  -- Performance should be reasonable (adjust threshold based on target hardware)
  luaunit.assertTrue(createTime < 1.0, "Creating children took too long: " .. createTime)

  -- Test layout time (with nil check)
  local layoutTime = measure(function()
    luaunit.assertNotNil(container.layoutChildren, "layoutChildren method should exist")
    container:layoutChildren()
  end)

  -- Print layout time for visibility
  print(string.format("Laying out 100 children took: %.4f seconds", layoutTime))

  -- Layout should be reasonably fast
  luaunit.assertTrue(layoutTime < 1.0, "Layout took too long: " .. layoutTime)
end

function TestPerformance:testDeepHierarchy()
  -- Test performance with a deep hierarchy
  local root = nil
  local rootTime = measure(function()
    root = self.GUI.new({
      x = 0,
      y = 0,
      w = 1000,
      h = 1000,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
    })

    local current = root
    for i = 1, 10 do
      current = self.GUI.new({
        parent = current,
        w = 900 - (i * 50),
        h = 900 - (i * 50),
        positioning = Positioning.FLEX,
        flexDirection = i % 2 == 0 and FlexDirection.HORIZONTAL or FlexDirection.VERTICAL,
      })

      -- Add some siblings at each level
      for _ = 1, 3 do
        self.GUI.new({
          parent = current,
          w = 50,
          h = 50,
          positioning = Positioning.FLEX,
        })
      end
    end
  end)

  -- Print creation time for visibility
  print(string.format("Creating deep hierarchy took: %.4f seconds", rootTime))

  -- Creation should be reasonably fast
  luaunit.assertTrue(rootTime < 1.0, "Creating deep hierarchy took too long: " .. rootTime)

  -- Test layout performance (with nil check)
  local layoutTime = measure(function()
    luaunit.assertNotNil(root.layoutChildren, "layoutChildren method should exist")
    root:layoutChildren()
  end)

  -- Print layout time for visibility
  print(string.format("Laying out deep hierarchy took: %.4f seconds", layoutTime))

  -- Layout should be reasonably fast
  luaunit.assertTrue(layoutTime < 1.0, "Layout took too long: " .. layoutTime)
end

function TestPerformance:testDynamicUpdates()
  -- Test performance of dynamic updates
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 1000,
    h = 1000,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    alignItems = AlignItems.CENTER,
  })

  -- Create 50 children
  local children = {}
  for i = 1, 50 do
    children[i] = self.GUI.new({
      parent = container,
      w = 50,
      h = 50,
      positioning = Positioning.FLEX,
    })
  end

  -- Test update performance (resizing children)
  local updateTime = measure(function()
    for _, child in ipairs(children) do
      child.width = child.width + 10
      child.height = child.height + 10
    end
    luaunit.assertNotNil(container.layoutChildren, "layoutChildren method should exist")
    container:layoutChildren()
  end)

  -- Print update time for visibility
  print(string.format("Updating 50 children took: %.4f seconds", updateTime))

  -- Updates should be reasonably fast
  luaunit.assertTrue(updateTime < 1.0, "Updates took too long: " .. updateTime)

  -- Verify updates were applied
  luaunit.assertEquals(children[1].width, 60)
  luaunit.assertEquals(children[1].height, 60)
end

function TestPerformance:testRapidResizing()
  -- Test performance of rapid window resizing
  local container = self.GUI.new({
    x = 0,
    y = 0,
    w = 1000,
    h = 1000,
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
  })

  -- Add 20 children
  for _ = 1, 20 do
    self.GUI.new({
      parent = container,
      w = 50,
      h = 50,
      positioning = Positioning.FLEX,
    })
  end

  -- Test 10 rapid resizes
  local resizeTime = measure(function()
    for i = 1, 10 do
      container:resize(1000 + i * 100, 1000 + i * 100)
    end
  end)

  -- Print resize time for visibility
  print(string.format("10 rapid resizes took: %.4f seconds", resizeTime))

  -- Resizing should be reasonably fast
  luaunit.assertTrue(resizeTime < 1.0, "Resizing took too long: " .. resizeTime)

  -- Verify final dimensions
  luaunit.assertEquals(container.width, 2000)
  luaunit.assertEquals(container.height, 2000)
end

luaunit.LuaUnit.run()
