-- Test padding resize behavior with percentage units
package.path = package.path .. ";?.lua"
local luaunit = require("testing.luaunit")
local loveStub = require("testing.loveStub")
_G.love = loveStub
local FlexLove = require("FlexLove")

TestPaddingResize = {}

function TestPaddingResize:setUp()
  -- Reset GUI state before each test
  FlexLove.Gui.destroy()

  -- Set up a consistent viewport size
  love.window.setMode(1920, 1080)

  -- Initialize with base scaling
  FlexLove.Gui.init({
    baseScale = { width = 1920, height = 1080 },
  })
end

function TestPaddingResize:tearDown()
  FlexLove.Gui.destroy()
end

-- Test that percentage padding recalculates on resize
function TestPaddingResize:testPercentagePaddingHorizontalResize()
  -- Create parent with percentage padding
  local parent = FlexLove.Element.new({
    x = 0,
    y = 0,
    width = "100%",
    height = "100%",
    padding = { horizontal = "10%", vertical = "5%" },
  })

  -- Initial padding should be 10% of 1920 = 192px (horizontal), 5% of 1080 = 54px (vertical)
  luaunit.assertAlmostEquals(parent.padding.left, 192, 1, "Initial left padding should be 10% of 1920")
  luaunit.assertAlmostEquals(parent.padding.right, 192, 1, "Initial right padding should be 10% of 1920")
  luaunit.assertAlmostEquals(parent.padding.top, 54, 1, "Initial top padding should be 5% of 1080")
  luaunit.assertAlmostEquals(parent.padding.bottom, 54, 1, "Initial bottom padding should be 5% of 1080")

  -- Resize to larger viewport
  parent:resize(2560, 1440)

  -- Padding should recalculate: 10% of 2560 = 256px (horizontal), 5% of 1440 = 72px (vertical)
  luaunit.assertAlmostEquals(parent.padding.left, 256, 1, "After resize, left padding should be 10% of 2560")
  luaunit.assertAlmostEquals(parent.padding.right, 256, 1, "After resize, right padding should be 10% of 2560")
  luaunit.assertAlmostEquals(parent.padding.top, 72, 1, "After resize, top padding should be 5% of 1440")
  luaunit.assertAlmostEquals(parent.padding.bottom, 72, 1, "After resize, bottom padding should be 5% of 1440")

  -- Resize to smaller viewport
  parent:resize(1280, 720)

  -- Padding should recalculate: 10% of 1280 = 128px (horizontal), 5% of 720 = 36px (vertical)
  luaunit.assertAlmostEquals(parent.padding.left, 128, 1, "After second resize, left padding should be 10% of 1280")
  luaunit.assertAlmostEquals(parent.padding.right, 128, 1, "After second resize, right padding should be 10% of 1280")
  luaunit.assertAlmostEquals(parent.padding.top, 36, 1, "After second resize, top padding should be 5% of 720")
  luaunit.assertAlmostEquals(parent.padding.bottom, 36, 1, "After second resize, bottom padding should be 5% of 720")
end

-- Test that pixel padding with fixed dimensions doesn't shrink on resize
function TestPaddingResize:testPixelPaddingFixedDimensions()
  -- Create element with pixel padding and fixed dimensions
  local element = FlexLove.Element.new({
    x = 0,
    y = 0,
    width = 160,
    height = 40,
    padding = { horizontal = 12, vertical = 8 },
  })

  -- Store initial dimensions
  local initialWidth = element.width
  local initialHeight = element.height
  local initialPaddingLeft = element.padding.left
  local initialPaddingTop = element.padding.top

  -- Resize multiple times
  for i = 1, 5 do
    element:resize(1920 + i * 100, 1080 + i * 50)
  end

  -- Dimensions should scale with base scaling but not shrink progressively
  luaunit.assertTrue(
    element.width >= initialWidth * 0.9,
    string.format("Width should not shrink significantly. Initial: %f, Current: %f", initialWidth, element.width)
  )
  luaunit.assertTrue(
    element.height >= initialHeight * 0.9,
    string.format("Height should not shrink significantly. Initial: %f, Current: %f", initialHeight, element.height)
  )
end

-- Test nested elements with percentage padding
function TestPaddingResize:testNestedPercentagePadding()
  -- Create parent with percentage padding
  local parent = FlexLove.Element.new({
    x = 0,
    y = 0,
    width = "100%",
    height = "100%",
    padding = { horizontal = "10%", vertical = "10%" },
    positioning = FlexLove.enums.Positioning.FLEX,
    flexDirection = FlexLove.enums.FlexDirection.VERTICAL,
  })

  -- Create child with percentage padding (relative to parent's content area)
  local child = FlexLove.Element.new({
    parent = parent,
    width = "80%",
    height = "50%",
    padding = { horizontal = "5%", vertical = "5%" },
  })

  -- Store initial child padding
  local initialChildPaddingLeft = child.padding.left
  local initialChildPaddingTop = child.padding.top

  -- Resize
  parent:resize(2560, 1440)

  -- Child padding should recalculate based on parent's new content area
  -- Parent content width after padding: 2560 - 2*(10% of 2560) = 2560 - 512 = 2048
  -- Child width: 80% of 2048 = 1638.4
  -- Child horizontal padding: 5% of 1638.4 = 81.92
  luaunit.assertTrue(
    child.padding.left > initialChildPaddingLeft,
    string.format(
      "Child left padding should increase after resize. Initial: %f, Current: %f",
      initialChildPaddingLeft,
      child.padding.left
    )
  )
  luaunit.assertTrue(
    child.padding.top > initialChildPaddingTop,
    string.format(
      "Child top padding should increase after resize. Initial: %f, Current: %f",
      initialChildPaddingTop,
      child.padding.top
    )
  )
end

-- Test that percentage padding doesn't cause progressive shrinkage
function TestPaddingResize:testNoProgressiveShrinkage()
  -- Create element with percentage padding
  local element = FlexLove.Element.new({
    x = 0,
    y = 0,
    width = "100%",
    height = "100%",
    padding = { horizontal = "10%", vertical = "10%" },
  })

  -- Store initial content dimensions
  local initialContentWidth = element.width
  local initialContentHeight = element.height

  -- Resize back to original size multiple times
  for i = 1, 10 do
    element:resize(2560, 1440) -- Larger
    element:resize(1920, 1080) -- Back to original
  end

  -- Content dimensions should return to original (no progressive shrinkage)
  luaunit.assertAlmostEquals(
    element.width,
    initialContentWidth,
    5,
    string.format(
      "Content width should return to original after multiple resizes. Initial: %f, Current: %f",
      initialContentWidth,
      element.width
    )
  )
  luaunit.assertAlmostEquals(
    element.height,
    initialContentHeight,
    5,
    string.format(
      "Content height should return to original after multiple resizes. Initial: %f, Current: %f",
      initialContentHeight,
      element.height
    )
  )
end

-- Test viewport-relative padding (vw/vh)
function TestPaddingResize:testViewportRelativePadding()
  -- Create element with viewport-relative padding
  local element = FlexLove.Element.new({
    x = 0,
    y = 0,
    width = "50%",
    height = "50%",
    padding = { horizontal = "2vw", vertical = "3vh" },
  })

  -- Initial padding: 2vw of 1920 = 38.4px, 3vh of 1080 = 32.4px
  luaunit.assertAlmostEquals(element.padding.left, 38.4, 1, "Initial left padding should be 2vw of 1920")
  luaunit.assertAlmostEquals(element.padding.top, 32.4, 1, "Initial top padding should be 3vh of 1080")

  -- Resize
  element:resize(2560, 1440)

  -- Padding should recalculate: 2vw of 2560 = 51.2px, 3vh of 1440 = 43.2px
  luaunit.assertAlmostEquals(element.padding.left, 51.2, 1, "After resize, left padding should be 2vw of 2560")
  luaunit.assertAlmostEquals(element.padding.top, 43.2, 1, "After resize, top padding should be 3vh of 1440")
end

-- Test individual side padding with different units
function TestPaddingResize:testMixedPaddingUnits()
  -- Create element with mixed padding units
  local element = FlexLove.Element.new({
    x = 0,
    y = 0,
    width = "100%",
    height = "100%",
    padding = { top = "5%", right = "2vw", bottom = 20, left = "3vh" },
  })

  -- Store initial padding
  local initialTop = element.padding.top
  local initialRight = element.padding.right
  local initialBottom = element.padding.bottom
  local initialLeft = element.padding.left

  -- Resize
  element:resize(2560, 1440)

  -- Check that each side recalculates according to its unit
  luaunit.assertTrue(initialTop < element.padding.top, "Top padding (%) should increase")
  luaunit.assertTrue(initialRight < element.padding.right, "Right padding (vw) should increase")
  luaunit.assertTrue(
    math.abs(initialBottom - element.padding.bottom) < 1,
    "Bottom padding (px) should remain roughly the same with base scaling"
  )
  luaunit.assertTrue(initialLeft < element.padding.left, "Left padding (vh) should increase")
end

luaunit.LuaUnit.run()
