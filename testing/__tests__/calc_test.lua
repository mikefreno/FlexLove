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

-- ============================================================================
-- STRESS TESTS - Complex calculations and deeply nested structures
-- ============================================================================

--- Test deeply nested parentheses (3 levels)
function TestCalc:testDeeplyNested3Levels()
  local calcObj = Calc.new("(((100px + 50px) * 2) - 100px) / 2")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- (((150) * 2) - 100) / 2 = (300 - 100) / 2 = 200 / 2 = 100
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 100)
end

--- Test deeply nested parentheses (5 levels)
function TestCalc:testDeeplyNested5Levels()
  local calcObj = Calc.new("(((((10px + 5px) * 2) + 10px) * 2) - 20px) / 2")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- (((((15) * 2) + 10) * 2) - 20) / 2
  -- ((((30) + 10) * 2) - 20) / 2
  -- (((40) * 2) - 20) / 2
  -- ((80) - 20) / 2
  -- (60) / 2 = 30
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 30)
end

--- Test deeply nested parentheses (10 levels)
function TestCalc:testDeeplyNested10Levels()
  local calcObj = Calc.new("((((((((((2px * 2) * 2) * 2) * 2) * 2) * 2) * 2) * 2) * 2) * 2)")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 2 * 2^10 = 2 * 1024 = 2048
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 2048)
end

--- Test complex multi-operation expression with all operators
function TestCalc:testComplexMultiOperationAllOperators()
  local calcObj = Calc.new("100px + 50px - 20px * 2 / 4 + 30px")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Precedence: 20 * 2 = 40, 40 / 4 = 10
  -- Then: 100 + 50 - 10 + 30 = 170
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 170)
end

--- Test complex expression with mixed units and all operators
function TestCalc:testComplexMixedUnitsAllOperators()
  local calcObj = Calc.new("50% + 10vw - 5vh * 2 / 4")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 50% = 500 (parent 1000), 10vw = 192, 5vh = 54, 54 * 2 = 108, 108 / 4 = 27
  -- 500 + 192 - 27 = 665
  local result = Calc.resolve(calcObj, 1920, 1080, 1000, nil, nil)
  lu.assertEquals(result, 665)
end

--- Test nested parentheses with mixed operations
function TestCalc:testNestedParenthesesMixedOperations()
  local calcObj = Calc.new("((100px + 50px) * (200px - 100px)) / 50px")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- (150 * 100) / 50 = 15000 / 50 = 300
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 300)
end

--- Test extremely long expression with many operations
function TestCalc:testExtremelyLongExpression()
  local calcObj = Calc.new("10px + 20px + 30px + 40px + 50px - 5px - 10px - 15px * 2 / 3 + 100px")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 15 * 2 / 3 = 30 / 3 = 10
  -- 10 + 20 + 30 + 40 + 50 - 5 - 10 - 10 + 100 = 225
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 225)
end

--- Test alternating operations with parentheses
function TestCalc:testAlternatingOperationsWithParentheses()
  local calcObj = Calc.new("(50px + 50px) * (100px - 50px) / (25px + 25px)")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- (100) * (50) / (50) = 5000 / 50 = 100
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 100)
end

--- Test very large numbers
function TestCalc:testVeryLargeNumbers()
  local calcObj = Calc.new("10000px + 50000px * 2")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 50000 * 2 = 100000, 10000 + 100000 = 110000
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 110000)
end

--- Test very small decimal numbers
function TestCalc:testVerySmallDecimals()
  local calcObj = Calc.new("0.1px + 0.2px + 0.3px")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertAlmostEquals(result, 0.6, 0.0001)
end

--- Test negative numbers in complex expression
function TestCalc:testNegativeNumbersInComplexExpression()
  local calcObj = Calc.new("(-50px + 100px) * (-2px + 5px)")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- (50) * (3) = 150
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 150)
end

--- Test multiple negative numbers
function TestCalc:testMultipleNegativeNumbers()
  local calcObj = Calc.new("-50px - 30px - 20px")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- -50 - 30 - 20 = -100
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, -100)
end

--- Test negative result from subtraction
function TestCalc:testNegativeResultFromSubtraction()
  local calcObj = Calc.new("50px - 100px")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, -50)
end

--- Test all unit types in single expression
function TestCalc:testAllUnitTypesInSingleExpression()
  local calcObj = Calc.new("100px + 10% + 5vw + 5vh + 10ew + 10eh")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 100 + 100 (10% of 1000) + 96 (5% of 1920) + 54 (5% of 1080) + 50 (10% of 500) + 30 (10% of 300)
  -- = 100 + 100 + 96 + 54 + 50 + 30 = 430
  local result = Calc.resolve(calcObj, 1920, 1080, 1000, 500, 300)
  lu.assertEquals(result, 430)
end

--- Test precedence with multiple levels
function TestCalc:testPrecedenceWithMultipleLevels()
  local calcObj = Calc.new("100px + 50px * 2 - 30px / 3")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 50 * 2 = 100, 30 / 3 = 10
  -- 100 + 100 - 10 = 190
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 190)
end

--- Test parentheses overriding precedence in complex way
function TestCalc:testParenthesesOverridingPrecedenceComplex()
  local calcObj = Calc.new("(100px + 50px) * (2px + 3px) - (30px + 20px) / (5px - 3px)")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- (150) * (5) - (50) / (2) = 750 - 25 = 725
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 725)
end

--- Test percentage calculations with zero parent
function TestCalc:testPercentageWithZeroParent()
  local calcObj = Calc.new("50% + 100px")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 50% of 0 = 0, 0 + 100 = 100
  local result = Calc.resolve(calcObj, 1920, 1080, 0, nil, nil)
  lu.assertEquals(result, 100)
end

--- Test element units without element dimensions
function TestCalc:testElementUnitsWithoutDimensions()
  local calcObj = Calc.new("100ew + 50eh")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should return 0 + 0 = 0 due to missing dimensions
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test mixed parentheses and operations at different levels
function TestCalc:testMixedParenthesesDifferentLevels()
  local calcObj = Calc.new("((100px + 50px) * 2) + (200px / (10px + 10px))")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- ((150) * 2) + (200 / (20)) = 300 + 10 = 310
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 310)
end

--- Test chain multiplication
function TestCalc:testChainMultiplication()
  local calcObj = Calc.new("2px * 3 * 4 * 5")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 2 * 3 * 4 * 5 = 120
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 120)
end

--- Test chain division
function TestCalc:testChainDivision()
  local calcObj = Calc.new("1000px / 2 / 5 / 10")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 1000 / 2 / 5 / 10 = 500 / 5 / 10 = 100 / 10 = 10
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 10)
end

--- Test fractional results
function TestCalc:testFractionalResults()
  local calcObj = Calc.new("100px / 3")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertAlmostEquals(result, 33.333333333, 0.0001)
end

--- Test complex viewport-based layout calculation
function TestCalc:testComplexViewportBasedLayout()
  -- Simulate: margin-left = (100vw - element_width) / 2, where element is 30vw
  local calcObj = Calc.new("(100vw - 30vw) / 2")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- (1920 - 576) / 2 = 1344 / 2 = 672
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 672)
end

--- Test complex responsive sizing calculation
function TestCalc:testComplexResponsiveSizing()
  -- Simulate: width = 100% - 20px padding on each side - 10vw margin
  local calcObj = Calc.new("100% - 40px - 10vw")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 100% of 1000 - 40 - 10% of 1920 = 1000 - 40 - 192 = 768
  local result = Calc.resolve(calcObj, 1920, 1080, 1000, nil, nil)
  lu.assertEquals(result, 768)
end

--- Test expression with leading negative in parentheses
function TestCalc:testLeadingNegativeInParentheses()
  local calcObj = Calc.new("100px + (-50px * 2)")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 100 + (-100) = 0
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test multiple parentheses groups at same level
function TestCalc:testMultipleParenthesesGroupsSameLevel()
  local calcObj = Calc.new("(100px + 50px) + (200px - 100px) + (300px / 3)")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 150 + 100 + 100 = 350
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 350)
end

--- Test near-zero division result
function TestCalc:testNearZeroDivisionResult()
  local calcObj = Calc.new("1px / 1000")
  lu.assertTrue(Calc.isCalc(calcObj))
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertAlmostEquals(result, 0.001, 0.0001)
end

--- Test expression with only multiplication and division
function TestCalc:testOnlyMultiplicationAndDivision()
  local calcObj = Calc.new("100px * 2 / 4 * 3 / 5")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 100 * 2 / 4 * 3 / 5 = 200 / 4 * 3 / 5 = 50 * 3 / 5 = 150 / 5 = 30
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 30)
end

--- Test expression with decimal percentages
function TestCalc:testDecimalPercentages()
  local calcObj = Calc.new("12.5% + 37.5%")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 12.5% + 37.5% = 50% of 1000 = 500
  local result = Calc.resolve(calcObj, 1920, 1080, 1000, nil, nil)
  lu.assertEquals(result, 500)
end

--- Test unitless numbers in multiplication/division
function TestCalc:testUnitlessNumbersInMultDiv()
  local calcObj = Calc.new("100px * 2.5 / 0.5")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- 100 * 2.5 / 0.5 = 250 / 0.5 = 500
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 500)
end

--- Test deeply nested with negative numbers
function TestCalc:testDeeplyNestedWithNegatives()
  local calcObj = Calc.new("((-100px + 200px) * (-2px + 5px)) / (10px - 5px)")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- ((100) * (3)) / (5) = 300 / 5 = 60
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 60)
end

--- Test asymmetric nested parentheses
function TestCalc:testAsymmetricNestedParentheses()
  local calcObj = Calc.new("((100px + 50px) * 2) + 200px / 4")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- (150 * 2) + (200 / 4) = 300 + 50 = 350
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 350)
end

--- Test maximum nesting with all operations
function TestCalc:testMaximumNestingAllOperations()
  local calcObj = Calc.new("((((100px + 50px) - 30px) * 2) / 4)")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- ((((150) - 30) * 2) / 4) = (((120) * 2) / 4) = ((240) / 4) = 60
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 60)
end

--- Test whitespace in complex expressions
function TestCalc:testWhitespaceInComplexExpression()
  local calcObj = Calc.new("  (  100px  +  50px  )  *  (  2px  +  3px  )  ")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- (150) * (5) = 750
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 750)
end

-- ============================================================================
-- ERROR CONDITION STRESS TESTS
-- ============================================================================

--- Test mismatched parentheses (missing closing)
function TestCalc:testMismatchedParenthesesMissingClosing()
  local calcObj = Calc.new("((100px + 50px) * 2")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should handle gracefully and return 0
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test mismatched parentheses (missing opening)
function TestCalc:testMismatchedParenthesesMissingOpening()
  local calcObj = Calc.new("100px + 50px) * 2")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should handle gracefully and return 0
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test empty parentheses
function TestCalc:testEmptyParentheses()
  local calcObj = Calc.new("100px + ()")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should handle gracefully and return 0
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test consecutive operators
function TestCalc:testConsecutiveOperators()
  local calcObj = Calc.new("100px ++ 50px")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should handle gracefully and return 0
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test trailing operator
function TestCalc:testTrailingOperator()
  local calcObj = Calc.new("100px + 50px *")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should handle gracefully and return 0
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test leading operator (non-negative)
function TestCalc:testLeadingOperatorNonNegative()
  local calcObj = Calc.new("+ 100px")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should handle gracefully and return 0
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test invalid unit
function TestCalc:testInvalidUnit()
  local calcObj = Calc.new("100xyz + 50px")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should handle gracefully and return 0
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test mixed invalid syntax
function TestCalc:testMixedInvalidSyntax()
  local calcObj = Calc.new("100px + * 50px")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should handle gracefully and return 0
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test special characters
function TestCalc:testSpecialCharacters()
  local calcObj = Calc.new("100px + 50px @ 20px")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should handle gracefully and return 0
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test extremely long invalid expression
function TestCalc:testExtremelyLongInvalidExpression()
  local calcObj = Calc.new("100px + + + + + + + + + + 50px")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should handle gracefully and return 0
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test division by calculated zero
function TestCalc:testDivisionByCalculatedZero()
  local calcObj = Calc.new("100px / (50px - 50px)")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should handle division by zero and return 0
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

--- Test nested division by zero
function TestCalc:testNestedDivisionByZero()
  local calcObj = Calc.new("((100px + 50px) / 0) * 2")
  lu.assertTrue(Calc.isCalc(calcObj))
  -- Should handle division by zero and return 0
  local result = Calc.resolve(calcObj, 1920, 1080, nil, nil, nil)
  lu.assertEquals(result, 0)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(lu.LuaUnit.run())
end
