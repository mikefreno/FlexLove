-- Test suite for ErrorHandler module
package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")

TestErrorHandler = {}

-- Test: error() throws with correct format
function TestErrorHandler:test_error_throws_with_format()
  local success, err = pcall(function()
    ErrorHandler.error("TestModule", "Something went wrong")
  end)

  luaunit.assertFalse(success, "error() should throw")
  luaunit.assertStrContains(err, "[FlexLove - TestModule] Error: Something went wrong")
end

-- Test: warn() prints with correct format
function TestErrorHandler:test_warn_prints_with_format()
  -- Capture print output by mocking print
  local captured = nil
  local originalPrint = print
  print = function(msg)
    captured = msg
  end

  ErrorHandler.warn("TestModule", "This is a warning")

  print = originalPrint

  luaunit.assertNotNil(captured, "warn() should print")
  luaunit.assertEquals(captured, "[FlexLove - TestModule] Warning: This is a warning")
end

-- Test: assertNotNil returns true for non-nil value
function TestErrorHandler:test_assertNotNil_returns_true_for_valid()
  local result = ErrorHandler.assertNotNil("TestModule", "some value", "testParam")
  luaunit.assertTrue(result, "assertNotNil should return true for non-nil value")
end

-- Test: assertNotNil throws for nil value
function TestErrorHandler:test_assertNotNil_throws_for_nil()
  local success, err = pcall(function()
    ErrorHandler.assertNotNil("TestModule", nil, "testParam")
  end)

  luaunit.assertFalse(success, "assertNotNil should throw for nil")
  luaunit.assertStrContains(err, "Parameter 'testParam' cannot be nil")
end

-- Test: assertType returns true for correct type
function TestErrorHandler:test_assertType_returns_true_for_valid()
  local result = ErrorHandler.assertType("TestModule", "hello", "string", "testParam")
  luaunit.assertTrue(result, "assertType should return true for correct type")

  result = ErrorHandler.assertType("TestModule", 123, "number", "testParam")
  luaunit.assertTrue(result, "assertType should return true for number")

  result = ErrorHandler.assertType("TestModule", {}, "table", "testParam")
  luaunit.assertTrue(result, "assertType should return true for table")
end

-- Test: assertType throws for wrong type
function TestErrorHandler:test_assertType_throws_for_wrong_type()
  local success, err = pcall(function()
    ErrorHandler.assertType("TestModule", 123, "string", "testParam")
  end)

  luaunit.assertFalse(success, "assertType should throw for wrong type")
  luaunit.assertStrContains(err, "Parameter 'testParam' must be string, got number")
end

-- Test: assertRange returns true for value in range
function TestErrorHandler:test_assertRange_returns_true_for_valid()
  local result = ErrorHandler.assertRange("TestModule", 5, 0, 10, "testParam")
  luaunit.assertTrue(result, "assertRange should return true for value in range")

  result = ErrorHandler.assertRange("TestModule", 0, 0, 10, "testParam")
  luaunit.assertTrue(result, "assertRange should accept min boundary")

  result = ErrorHandler.assertRange("TestModule", 10, 0, 10, "testParam")
  luaunit.assertTrue(result, "assertRange should accept max boundary")
end

-- Test: assertRange throws for value below min
function TestErrorHandler:test_assertRange_throws_for_below_min()
  local success, err = pcall(function()
    ErrorHandler.assertRange("TestModule", -1, 0, 10, "testParam")
  end)

  luaunit.assertFalse(success, "assertRange should throw for value below min")
  luaunit.assertStrContains(err, "Parameter 'testParam' must be between 0 and 10, got -1")
end

-- Test: assertRange throws for value above max
function TestErrorHandler:test_assertRange_throws_for_above_max()
  local success, err = pcall(function()
    ErrorHandler.assertRange("TestModule", 11, 0, 10, "testParam")
  end)

  luaunit.assertFalse(success, "assertRange should throw for value above max")
  luaunit.assertStrContains(err, "Parameter 'testParam' must be between 0 and 10, got 11")
end

-- Test: warnDeprecated prints deprecation warning
function TestErrorHandler:test_warnDeprecated_prints_message()
  local captured = nil
  local originalPrint = print
  print = function(msg)
    captured = msg
  end

  ErrorHandler.warnDeprecated("TestModule", "oldFunction", "newFunction")

  print = originalPrint

  luaunit.assertNotNil(captured, "warnDeprecated should print")
  luaunit.assertStrContains(captured, "'oldFunction' is deprecated. Use 'newFunction' instead")
end

-- Test: warnCommonMistake prints helpful message
function TestErrorHandler:test_warnCommonMistake_prints_message()
  local captured = nil
  local originalPrint = print
  print = function(msg)
    captured = msg
  end

  ErrorHandler.warnCommonMistake("TestModule", "Width is zero", "Set width to positive value")

  print = originalPrint

  luaunit.assertNotNil(captured, "warnCommonMistake should print")
  luaunit.assertStrContains(captured, "Width is zero. Suggestion: Set width to positive value")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
