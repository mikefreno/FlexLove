---@diagnostic disable: undefined-global, undefined-field
local lu = require("testing.luaunit")

-- Mock love globals for testing environment
_G.love = _G.love or {}
_G.love.graphics = _G.love.graphics or {}
_G.love.graphics.getDimensions = function()
  return 1920, 1080
end
_G.love.window = _G.love.window or {}
_G.love.window.getMode = function()
  return 1920, 1080
end

-- Load Calc module directly
local Calc = require("modules.Calc")
local ErrorHandler = require("modules.ErrorHandler")

-- Initialize with error handler
ErrorHandler.init({})
Calc.init({ ErrorHandler = ErrorHandler })

---@class TestCalc
TestCalc = {}

function TestCalc:setUp()
  -- Fresh initialization for each test
end

function TestCalc:tearDown()
  -- Cleanup after each test
end

--- Test basic arithmetic: addition
function TestCalc:testBasicAddition()
  local calcObj = Calc.new("100px + 50px")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 150)
end

--- Test basic arithmetic: subtraction
function TestCalc:testBasicSubtraction()
  local calcObj = Calc.new("100px - 30px")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 70)
end

--- Test basic arithmetic: multiplication
function TestCalc:testBasicMultiplication()
  local calcObj = Calc.new("10px * 5")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 50)
end

--- Test basic arithmetic: division
function TestCalc:testBasicDivision()
  local calcObj = Calc.new("100px / 4")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 25)
end

--- Test negative numbers
function TestCalc:testNegativeNumbers()
  local calcObj = Calc.new("-50px + 100px")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 50)
end

--- Test decimal numbers
function TestCalc:testDecimalNumbers()
  local calcObj = Calc.new("10.5px + 5.5px")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 16)
end

--- Test percentage units
function TestCalc:testPercentageUnits()
  local calcObj = Calc.new("50% + 25%")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, 1000, nil, nil) -- parent size = 1000
  lu.assertEquals(result, 750) -- 50% of 1000 + 25% of 1000 = 500 + 250
end

--- Test viewport width units (vw)
function TestCalc:testViewportWidthUnits()
  local calcObj = Calc.new("50vw - 10vw")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 768) -- 40% of 1920 = 768
end

--- Test viewport height units (vh)
function TestCalc:testViewportHeightUnits()
  local calcObj = Calc.new("50vh + 10vh")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 648) -- 60% of 1080 = 648
end

--- Test mixed units
function TestCalc:testMixedUnits()
  local calcObj = Calc.new("50% - 10vw")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, 1000, nil, nil)
  lu.assertEquals(result, 308) -- 50% of 1000 - 10% of 1920 = 500 - 192 = 308
end

--- Test complex expression with multiple operations
function TestCalc:testComplexExpression()
  local calcObj = Calc.new("100px + 50px - 20px")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 130)
end

--- Test parentheses for precedence
function TestCalc:testParentheses()
  local calcObj = Calc.new("(100px + 50px) * 2")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 300)
end

--- Test nested parentheses
function TestCalc:testNestedParentheses()
  local calcObj = Calc.new("((100px + 50px) / 3) * 2")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 100) -- (150 / 3) * 2 = 50 * 2 = 100
end

--- Test operator precedence (multiplication before addition)
function TestCalc:testOperatorPrecedence()
  local calcObj = Calc.new("100px + 50px * 2")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 200) -- 100 + (50 * 2) = 100 + 100 = 200
end

--- Test centering use case (50% - 10vw)
function TestCalc:testCenteringUseCase()
  local calcObj = Calc.new("50% - 10vw")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Assuming element width is 20vw (384px) and parent width is 1920px
  -- 50% of parent - 10vw should center it
  local result = Calc.resolve(calcObj, 1920, 1080, 1920, nil, nil)
  lu.assertEquals(result, 768) -- 50% of 1920 - 10% of 1920 = 960 - 192 = 768
end

--- Test element width units (ew)
function TestCalc:testElementWidthUnits()
  local calcObj = Calc.new("100ew - 20ew")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, 500, nil) -- element width = 500
  lu.assertEquals(result, 400) -- 80% of 500 = 400
end

--- Test element height units (eh)
function TestCalc:testElementHeightUnits()
  local calcObj = Calc.new("50eh + 25eh")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, 300) -- element height = 300
  lu.assertEquals(result, 225) -- 75% of 300 = 225
end

--- Test whitespace handling
function TestCalc:testWhitespaceHandling()
  local calcObj = Calc.new("  100px  +  50px  ")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 150)
end

--- Test zero value
function TestCalc:testZeroValue()
  local calcObj = Calc.new("100px - 100px")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test single value (no operation)
function TestCalc:testSingleValue()
  local calcObj = Calc.new("100px")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 100)
end

--- Test isCalc function with non-calc values
function TestCalc:testIsCalcWithNonCalcValues()
  lu.assertFalse(Calc.isCalc("100px"))
  lu.assertFalse(Calc.isCalc(100))
  lu.assertFalse(Calc.isCalc(nil))
  lu.assertFalse(Calc.isCalc({}))
end

--- Test division by zero error handling
function TestCalc:testDivisionByZeroHandling()
  local calcObj = Calc.new("100px / 0")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0) -- Should return 0 on division by zero error
end

--- Test invalid expression error handling
function TestCalc:testInvalidExpressionHandling()
  local calcObj = Calc.new("100px +") -- Incomplete expression
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should return 0 for invalid expressions
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test complex real-world centering scenario
function TestCalc:testRealWorldCentering()
  -- Button with 20vw width, centered at 50% - 10vw
  local xCalc = Calc.new("50% - 10vw")
  local result = Calc.resolve(xCalc, 1920, 1080, 1920, nil, nil)
  -- Expected: 50% of 1920 - 10% of 1920 = 960 - 192 = 768
  lu.assertEquals(result, 768)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(lu.LuaUnit.run())
end
