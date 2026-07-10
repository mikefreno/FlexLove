-- Test suite for NumberValidation.lua (extracted from utils.lua)
-- Verifies the focused module produces identical output to the old utils
-- validation functions, and exercises the ErrorHandler-driven VAL_xxx paths.

package.path = package.path .. ";./?.lua;./modules/?.lua"

-- Load love stub before anything else
require("testing.loveStub")

local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")
ErrorHandler.init({})

local utils = require("modules.utils")
local NumberValidation = require("modules.NumberValidation")
-- NumberValidation.init is propagated through utils.init (called below); call it
-- explicitly too so this suite is independent of FlexLove.init ordering.
utils.init({ ErrorHandler = ErrorHandler })

TestNumberValidation = {}

function TestNumberValidation:testIsNaN()
  luaunit.assertTrue(NumberValidation.isNaN(0 / 0))
  luaunit.assertFalse(NumberValidation.isNaN(1))
  luaunit.assertFalse(NumberValidation.isNaN("x"))
end

function TestNumberValidation:testIsInfinity()
  luaunit.assertTrue(NumberValidation.isInfinity(math.huge))
  luaunit.assertTrue(NumberValidation.isInfinity(-math.huge))
  luaunit.assertFalse(NumberValidation.isInfinity(0))
  luaunit.assertFalse(NumberValidation.isInfinity("x"))
end

function TestNumberValidation:testValidateEnum_ValidValue()
  local testEnum = { VALUE1 = "value1", VALUE2 = "value2", VALUE3 = "value3" }
  luaunit.assertTrue(NumberValidation.validateEnum("value1", testEnum, "testProp"))
  luaunit.assertTrue(NumberValidation.validateEnum(nil, testEnum, "testProp"))
end

function TestNumberValidation:testValidateEnum_InvalidValue_VAL007()
  local testEnum = { VALUE1 = "value1", VALUE2 = "value2" }
  luaunit.assertErrorMsgContains("VAL_007", function()
    NumberValidation.validateEnum("invalid", testEnum, "testProp")
  end)
end

function TestNumberValidation:testValidateRange_InRange()
  luaunit.assertTrue(NumberValidation.validateRange(5, 0, 10, "testProp"))
  luaunit.assertTrue(NumberValidation.validateRange(nil, 0, 10, "testProp"))
end

function TestNumberValidation:testValidateRange_OutOfRange_VAL002()
  luaunit.assertErrorMsgContains("VAL_002", function()
    NumberValidation.validateRange(-1, 0, 10, "testProp")
  end)
end

function TestNumberValidation:testValidateRange_WrongType_VAL001()
  luaunit.assertErrorMsgContains("VAL_001", function()
    NumberValidation.validateRange("not a number", 0, 10, "testProp")
  end)
end

function TestNumberValidation:testValidateType()
  luaunit.assertTrue(NumberValidation.validateType("hi", "string", "p"))
  luaunit.assertTrue(NumberValidation.validateType(nil, "string", "p"))
  luaunit.assertErrorMsgContains("VAL_001", function()
    NumberValidation.validateType(123, "string", "p")
  end)
end

function TestNumberValidation:testValidateNumber()
  local ok, _, val = NumberValidation.validateNumber(5, { min = 0, max = 10 })
  luaunit.assertTrue(ok)
  luaunit.assertEquals(val, 5)
  local ok2, err = NumberValidation.validateNumber("x", {})
  luaunit.assertFalse(ok2)
  luaunit.assertNotNil(err)
  local ok3, _, d = NumberValidation.validateNumber("x", { default = 7 })
  luaunit.assertTrue(ok3)
  luaunit.assertEquals(d, 7)
end

function TestNumberValidation:testSanitizeNumber()
  luaunit.assertEquals(NumberValidation.sanitizeNumber(5, 0, 10), 5)
  luaunit.assertEquals(NumberValidation.sanitizeNumber(-5, 0, 10), 0)
  luaunit.assertEquals(NumberValidation.sanitizeNumber(99, 0, 10), 10)
  luaunit.assertEquals(NumberValidation.sanitizeNumber("x", 0, 10, 3), 3)
  luaunit.assertEquals(NumberValidation.sanitizeNumber(math.huge, 0, 10), 10)
  luaunit.assertEquals(NumberValidation.sanitizeNumber(-math.huge, 0, 10), 0)
end

function TestNumberValidation:testValidateInteger()
  local ok, _, i = NumberValidation.validateInteger(5, 0, 10)
  luaunit.assertTrue(ok)
  luaunit.assertEquals(i, 5)
  local ok2 = NumberValidation.validateInteger(5.5, 0, 10)
  luaunit.assertFalse(ok2)
end

function TestNumberValidation:testValidatePercentage()
  local ok, _, v = NumberValidation.validatePercentage("50%")
  luaunit.assertTrue(ok)
  luaunit.assertEquals(v, 0.5)
  local ok2, _, v2 = NumberValidation.validatePercentage(0.5)
  luaunit.assertTrue(ok2)
  luaunit.assertEquals(v2, 0.5)
  local ok3, _, v3 = NumberValidation.validatePercentage(50)
  luaunit.assertTrue(ok3)
  luaunit.assertEquals(v3, 0.5)
  local ok4, err = NumberValidation.validatePercentage("x")
  luaunit.assertFalse(ok4)
  luaunit.assertNotNil(err)
end

function TestNumberValidation:testValidateOpacity()
  local ok, _, v = NumberValidation.validateOpacity(0.5)
  luaunit.assertTrue(ok)
  luaunit.assertEquals(v, 0.5)
  local ok2, _, d = NumberValidation.validateOpacity("x")
  luaunit.assertTrue(ok2)
  luaunit.assertEquals(d, 1)
end

function TestNumberValidation:testValidateDegrees()
  local ok, _, v = NumberValidation.validateDegrees(370)
  luaunit.assertTrue(ok)
  luaunit.assertEquals(v, 10)
  local ok2, err = NumberValidation.validateDegrees("x")
  luaunit.assertFalse(ok2)
  luaunit.assertNotNil(err)
end

function TestNumberValidation:testValidateCoordinate()
  local ok, _, v = NumberValidation.validateCoordinate(5)
  luaunit.assertTrue(ok)
  luaunit.assertEquals(v, 5)
  luaunit.assertFalse(NumberValidation.validateCoordinate(0 / 0))
end

function TestNumberValidation:testValidateDimension()
  local ok, _, v = NumberValidation.validateDimension(5)
  luaunit.assertTrue(ok)
  luaunit.assertEquals(v, 5)
  luaunit.assertFalse(NumberValidation.validateDimension(-1))
end

-- Alias parity: utils.validateRange must be the same function as the module's.
function TestNumberValidation:testAliasParity()
  luaunit.assertEquals(utils.validateRange, NumberValidation.validateRange)
  luaunit.assertEquals(utils.validateEnum, NumberValidation.validateEnum)
  luaunit.assertEquals(utils.validateType, NumberValidation.validateType)
  luaunit.assertEquals(utils.isNaN, NumberValidation.isNaN)
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
