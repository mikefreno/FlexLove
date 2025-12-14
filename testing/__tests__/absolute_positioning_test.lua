package.path = package.path .. ";./?.lua;./modules/?.lua"
local originalSearchers = package.searchers or package.loaders
table.insert(originalSearchers, 2, function(modname)
  if modname:match("^FlexLove%.modules%.") then
    local moduleName = modname:gsub("^FlexLove%.modules%.", "")
    return function()
      return require("modules." .. moduleName)
    end
  end
end)
require("testing.loveStub")
local luaunit = require("testing.luaunit")

-- Load FlexLove
local FlexLove = require("FlexLove")

TestAbsolutePositioning = {}

function TestAbsolutePositioning:setUp()
  FlexLove.init()
end

function TestAbsolutePositioning:testAbsoluteBottomRightInFlexParent()
  -- Create a flex parent
  local parent = FlexLove.new({
    positioning = "flex",
    width = 400,
    height = 400,
  })

  -- Create an absolutely positioned child with bottom and right offsets
  local child = FlexLove.new({
    parent = parent,
    positioning = "absolute",
    bottom = 0,
    right = 0,
    width = 100,
    height = 100,
  })

  -- Child should be positioned at bottom-right
  luaunit.assertEquals(child.x, 300, "Child x should be 300 (400 - 100)")
  luaunit.assertEquals(child.y, 300, "Child y should be 300 (400 - 100)")
end

function TestAbsolutePositioning:testAbsoluteTopLeftInFlexParent()
  -- Create a flex parent
  local parent = FlexLove.new({
    positioning = "flex",
    width = 400,
    height = 400,
  })

  -- Create an absolutely positioned child with top and left offsets
  local child = FlexLove.new({
    parent = parent,
    positioning = "absolute",
    top = 10,
    left = 10,
    width = 100,
    height = 100,
  })

  -- Child should be positioned at top-left with 10px offset
  luaunit.assertEquals(child.x, 10, "Child x should be 10")
  luaunit.assertEquals(child.y, 10, "Child y should be 10")
end

function TestAbsolutePositioning:testAbsoluteWithPaddingParent()
  -- Create a flex parent with padding
  local parent = FlexLove.new({
    positioning = "flex",
    width = 400,
    height = 400,
    padding = 20,
  })

  -- Create an absolutely positioned child
  local child = FlexLove.new({
    parent = parent,
    positioning = "absolute",
    bottom = 0,
    right = 0,
    width = 100,
    height = 100,
  })

  -- Absolute positioning is relative to parent's padding box
  -- Parent content box: 400 - 20 (left padding) - 20 (right padding) = 360
  -- Child x: parent.x (0) + padding.left (20) + content.width (360) - right (0) - child.width (100) = 280
  luaunit.assertEquals(child.x, 280, "Child x should account for parent padding")
  luaunit.assertEquals(child.y, 280, "Child y should account for parent padding")
end

function TestAbsolutePositioning:testAbsoluteDoesNotAffectFlexLayout()
  -- Create a flex parent
  local parent = FlexLove.new({
    positioning = "flex",
    flexDirection = "horizontal",
    width = 400,
    height = 400,
  })

  -- Add flex children
  local flexChild1 = FlexLove.new({
    parent = parent,
    width = 100,
    height = 100,
  })

  local flexChild2 = FlexLove.new({
    parent = parent,
    width = 100,
    height = 100,
  })

  -- Add absolutely positioned child
  local absChild = FlexLove.new({
    parent = parent,
    positioning = "absolute",
    top = 0,
    left = 0,
    width = 50,
    height = 50,
  })

  -- Flex children should be positioned normally (absolute child doesn't affect layout)
  luaunit.assertEquals(flexChild1.x, 0, "First flex child at x=0")
  luaunit.assertEquals(flexChild2.x, 100, "Second flex child at x=100")

  -- Absolute child should be at top-left
  luaunit.assertEquals(absChild.x, 0, "Absolute child at x=0")
  luaunit.assertEquals(absChild.y, 0, "Absolute child at y=0")
end

function TestAbsolutePositioning:testMultipleAbsoluteChildren()
  -- Create a flex parent
  local parent = FlexLove.new({
    positioning = "flex",
    width = 400,
    height = 400,
  })

  -- Create multiple absolutely positioned children
  local topLeft = FlexLove.new({
    parent = parent,
    positioning = "absolute",
    top = 0,
    left = 0,
    width = 50,
    height = 50,
  })

  local topRight = FlexLove.new({
    parent = parent,
    positioning = "absolute",
    top = 0,
    right = 0,
    width = 50,
    height = 50,
  })

  local bottomLeft = FlexLove.new({
    parent = parent,
    positioning = "absolute",
    bottom = 0,
    left = 0,
    width = 50,
    height = 50,
  })

  local bottomRight = FlexLove.new({
    parent = parent,
    positioning = "absolute",
    bottom = 0,
    right = 0,
    width = 50,
    height = 50,
  })

  -- Verify positions
  luaunit.assertEquals(topLeft.x, 0, "Top-left x")
  luaunit.assertEquals(topLeft.y, 0, "Top-left y")

  luaunit.assertEquals(topRight.x, 350, "Top-right x")
  luaunit.assertEquals(topRight.y, 0, "Top-right y")

  luaunit.assertEquals(bottomLeft.x, 0, "Bottom-left x")
  luaunit.assertEquals(bottomLeft.y, 350, "Bottom-left y")

  luaunit.assertEquals(bottomRight.x, 350, "Bottom-right x")
  luaunit.assertEquals(bottomRight.y, 350, "Bottom-right y")
end

function TestAbsolutePositioning:testAbsoluteInImmediateMode()
  FlexLove.setMode("immediate")

  local parent, child

  local function createUI()
    parent = FlexLove.new({
      positioning = "flex",
      width = 400,
      height = 400,
    })

    child = FlexLove.new({
      parent = parent,
      positioning = "absolute",
      bottom = 0,
      right = 0,
      width = 100,
      height = 100,
    })
  end

  -- First frame
  FlexLove.beginFrame()
  createUI()
  FlexLove.endFrame()

  luaunit.assertEquals(child.x, 300, "Frame 1: Child x should be 300")
  luaunit.assertEquals(child.y, 300, "Frame 1: Child y should be 300")

  -- Second frame (recreate UI)
  FlexLove.beginFrame()
  createUI()
  FlexLove.endFrame()

  luaunit.assertEquals(child.x, 300, "Frame 2: Child x should be 300")
  luaunit.assertEquals(child.y, 300, "Frame 2: Child y should be 300")

  FlexLove.setMode("retained")
end

function TestAbsolutePositioning:testExplicitlyAbsoluteFlagIsSet()
  local parent = FlexLove.new({
    positioning = "flex",
    width = 400,
    height = 400,
  })

  -- Child with explicit absolute positioning
  local absoluteChild = FlexLove.new({
    parent = parent,
    positioning = "absolute",
    width = 100,
    height = 100,
  })

  -- Child without explicit positioning (participates in flex)
  local flexChild = FlexLove.new({
    parent = parent,
    width = 100,
    height = 100,
  })

  luaunit.assertEquals(absoluteChild._explicitlyAbsolute, true, "Explicitly absolute child should have _explicitlyAbsolute = true")
  luaunit.assertEquals(absoluteChild._originalPositioning, "absolute", "Absolute child should have _originalPositioning = 'absolute'")

  luaunit.assertEquals(flexChild._explicitlyAbsolute, false, "Flex child should have _explicitlyAbsolute = false")
  luaunit.assertEquals(flexChild._originalPositioning, nil, "Flex child should have _originalPositioning = nil")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
