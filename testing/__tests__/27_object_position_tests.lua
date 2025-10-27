local lu = require("testing.luaunit")
local FlexLove = require("FlexLove")
local ImageRenderer = FlexLove.ImageRenderer

TestObjectPosition = {}

-- ====================
-- Position Parsing Tests
-- ====================

function TestObjectPosition:testCenterCenterDefault()
  local x, y = ImageRenderer._parsePosition("center center")
  lu.assertEquals(x, 0.5)
  lu.assertEquals(y, 0.5)
end

function TestObjectPosition:testTopLeft()
  local x, y = ImageRenderer._parsePosition("top left")
  lu.assertEquals(x, 0)
  lu.assertEquals(y, 0)
end

function TestObjectPosition:testBottomRight()
  local x, y = ImageRenderer._parsePosition("bottom right")
  lu.assertEquals(x, 1)
  lu.assertEquals(y, 1)
end

function TestObjectPosition:testPercentage50()
  local x, y = ImageRenderer._parsePosition("50% 50%")
  lu.assertEquals(x, 0.5)
  lu.assertEquals(y, 0.5)
end

function TestObjectPosition:testPercentage0()
  local x, y = ImageRenderer._parsePosition("0% 0%")
  lu.assertEquals(x, 0)
  lu.assertEquals(y, 0)
end

function TestObjectPosition:testPercentage100()
  local x, y = ImageRenderer._parsePosition("100% 100%")
  lu.assertEquals(x, 1)
  lu.assertEquals(y, 1)
end

function TestObjectPosition:testMixedKeywordPercentage()
  local x, y = ImageRenderer._parsePosition("center 25%")
  lu.assertEquals(x, 0.5)
  lu.assertEquals(y, 0.25)
end

function TestObjectPosition:testSingleValueLeft()
  local x, y = ImageRenderer._parsePosition("left")
  lu.assertEquals(x, 0)
  lu.assertEquals(y, 0.5) -- Should center on Y axis
end

function TestObjectPosition:testSingleValueTop()
  local x, y = ImageRenderer._parsePosition("top")
  lu.assertEquals(x, 0.5) -- Should center on X axis
  lu.assertEquals(y, 0)
end

function TestObjectPosition:testInvalidPositionDefaultsToCenter()
  local x, y = ImageRenderer._parsePosition("invalid position")
  lu.assertEquals(x, 0.5)
  lu.assertEquals(y, 0.5)
end

function TestObjectPosition:testNilPositionDefaultsToCenter()
  local x, y = ImageRenderer._parsePosition(nil)
  lu.assertEquals(x, 0.5)
  lu.assertEquals(y, 0.5)
end

function TestObjectPosition:testEmptyStringDefaultsToCenter()
  local x, y = ImageRenderer._parsePosition("")
  lu.assertEquals(x, 0.5)
  lu.assertEquals(y, 0.5)
end

-- ====================
-- Position with Contain Mode Tests
-- ====================

function TestObjectPosition:testContainWithTopLeft()
  local params = ImageRenderer.calculateFit(
    400,
    300, -- Image (landscape)
    200,
    200, -- Bounds (square)
    "contain",
    "top left"
  )

  -- Image should be in top-left of letterbox
  lu.assertEquals(params.dx, 0)
  lu.assertEquals(params.dy, 0)
end

function TestObjectPosition:testContainWithBottomRight()
  local params = ImageRenderer.calculateFit(
    400,
    300, -- Image (landscape)
    200,
    200, -- Bounds (square)
    "contain",
    "bottom right"
  )

  -- Image should be in bottom-right of letterbox
  lu.assertTrue(params.dx + params.dw <= 200)
  lu.assertTrue(params.dy + params.dh <= 200)
  -- Should be at the bottom right
  lu.assertAlmostEquals(params.dx + params.dw, 200, 0.01)
  lu.assertAlmostEquals(params.dy + params.dh, 200, 0.01)
end

function TestObjectPosition:testContainWithCenter()
  local params = ImageRenderer.calculateFit(400, 300, 200, 200, "contain", "center center")

  -- Image (400x300) will be scaled to fit width (200x150)
  -- Should be centered horizontally (dx=0) and vertically (dy=25)
  lu.assertEquals(params.dx, 0)
  lu.assertTrue(params.dy > 0)
end

-- ====================
-- Position with Cover Mode Tests
-- ====================

function TestObjectPosition:testCoverWithTopLeft()
  local params = ImageRenderer.calculateFit(400, 300, 200, 200, "cover", "top left")

  -- Crop should start from top-left
  lu.assertEquals(params.sx, 0)
  lu.assertEquals(params.sy, 0)
end

function TestObjectPosition:testCoverWithBottomRight()
  local params = ImageRenderer.calculateFit(400, 300, 200, 200, "cover", "bottom right")

  -- Crop should be from bottom-right
  lu.assertTrue(params.sx > 0)
  lu.assertTrue(params.sy >= 0)
end

function TestObjectPosition:testCoverWithCenter()
  local params = ImageRenderer.calculateFit(400, 300, 200, 200, "cover", "center center")

  -- Crop should be centered
  lu.assertTrue(params.sx > 0)
end

-- ====================
-- Position with None Mode Tests
-- ====================

function TestObjectPosition:testNoneWithTopLeft()
  local params = ImageRenderer.calculateFit(100, 100, 200, 200, "none", "top left")

  -- Image should be at top-left
  lu.assertEquals(params.dx, 0)
  lu.assertEquals(params.dy, 0)
end

function TestObjectPosition:testNoneWithBottomRight()
  local params = ImageRenderer.calculateFit(100, 100, 200, 200, "none", "bottom right")

  -- Image should be at bottom-right
  lu.assertEquals(params.dx, 100) -- 200 - 100
  lu.assertEquals(params.dy, 100) -- 200 - 100
end

function TestObjectPosition:testNoneWithCenter()
  local params = ImageRenderer.calculateFit(100, 100, 200, 200, "none", "center center")

  -- Image should be centered
  lu.assertEquals(params.dx, 50) -- (200 - 100) / 2
  lu.assertEquals(params.dy, 50) -- (200 - 100) / 2
end

lu.LuaUnit.run()
