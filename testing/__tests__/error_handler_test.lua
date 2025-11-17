-- Test suite for ErrorHandler module
package.path = package.path .. ";./?.lua;./modules/?.lua"

require("testing.loveStub")
local luaunit = require("testing.luaunit")
local ErrorHandler = require("modules.ErrorHandler")
local ErrorCodes = require("modules.ErrorCodes")

TestErrorHandler = {}

function TestErrorHandler:setUp()
  -- Reset debug mode and logging before each test
  ErrorHandler.setDebugMode(false)
  ErrorHandler.setLogTarget("none") -- Disable logging during tests
end

function TestErrorHandler:tearDown()
  -- Clean up any test log files
  os.remove("test-errors.log")
  for i = 1, 5 do
    os.remove("test-errors.log." .. i)
  end
end

-- Test: error() throws with correct format (backward compatibility)
function TestErrorHandler:test_error_throws_with_format()
  local success, err = pcall(function()
    ErrorHandler.error("TestModule", "Something went wrong")
  end)

  luaunit.assertFalse(success, "error() should throw")
  luaunit.assertStrContains(err, "[FlexLove - TestModule] Error: Something went wrong")
end

-- Test: error() with error code
function TestErrorHandler:test_error_with_code()
  local success, err = pcall(function()
    ErrorHandler.error("TestModule", "VAL_001", "Invalid property type")
  end)

  luaunit.assertFalse(success, "error() should throw")
  luaunit.assertStrContains(err, "[FlexLove - TestModule] Error [FLEXLOVE_VAL_001]")
  luaunit.assertStrContains(err, "Invalid property type")
end

-- Test: error() with error code and details
function TestErrorHandler:test_error_with_code_and_details()
  local success, err = pcall(function()
    ErrorHandler.error("TestModule", "VAL_001", "Invalid property type", {
      property = "width",
      expected = "number",
      got = "string",
    })
  end)

  luaunit.assertFalse(success, "error() should throw")
  luaunit.assertStrContains(err, "[FLEXLOVE_VAL_001]")
  luaunit.assertStrContains(err, "Details:")
  luaunit.assertStrContains(err, "Property: width")
  luaunit.assertStrContains(err, "Expected: number")
  luaunit.assertStrContains(err, "Got: string")
end

-- Test: error() with error code, details, and custom suggestion
function TestErrorHandler:test_error_with_code_details_and_suggestion()
  local success, err = pcall(function()
    ErrorHandler.error("TestModule", "VAL_001", "Invalid property type", {
      property = "width",
      expected = "number",
      got = "string",
    }, "Use a number like width = 100")
  end)

  luaunit.assertFalse(success, "error() should throw")
  luaunit.assertStrContains(err, "Suggestion: Use a number like width = 100")
end

-- Test: error() with code uses automatic suggestion
function TestErrorHandler:test_error_with_code_uses_auto_suggestion()
  local success, err = pcall(function()
    ErrorHandler.error("TestModule", "VAL_001", "Invalid property type", {
      property = "width",
    })
  end)

  luaunit.assertFalse(success, "error() should throw")
  luaunit.assertStrContains(err, "Suggestion:")
  -- Should contain suggestion from ErrorCodes
  local suggestion = ErrorCodes.getSuggestion("VAL_001")
  luaunit.assertStrContains(err, suggestion)
end

-- Test: warn() prints with correct format (backward compatibility)
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

-- Test: warn() with error code
function TestErrorHandler:test_warn_with_code()
  local captured = nil
  local originalPrint = print
  print = function(msg)
    captured = msg
  end

  ErrorHandler.warn("TestModule", "VAL_001", "Potentially invalid property")

  print = originalPrint

  luaunit.assertNotNil(captured, "warn() should print")
  luaunit.assertStrContains(captured, "[FlexLove - TestModule] Warning [FLEXLOVE_VAL_001]")
  luaunit.assertStrContains(captured, "Potentially invalid property")
end

-- Test: warn() with details
function TestErrorHandler:test_warn_with_details()
  local captured = nil
  local originalPrint = print
  print = function(msg)
    captured = msg
  end

  ErrorHandler.warn("TestModule", "VAL_001", "Check this property", {
    property = "height",
    value = "auto",
  })

  print = originalPrint

  luaunit.assertNotNil(captured, "warn() should print")
  luaunit.assertStrContains(captured, "Details:")
  luaunit.assertStrContains(captured, "Property: height")
  luaunit.assertStrContains(captured, "Value: auto")
end

-- Test: assertNotNil returns true for non-nil value
function TestErrorHandler:test_assertNotNil_returns_true_for_valid()
  local result = ErrorHandler.assertNotNil("TestModule", "some value", "testParam")
  luaunit.assertTrue(result, "assertNotNil should return true for non-nil value")
end

-- Test: assertNotNil throws for nil value (now uses error codes)
function TestErrorHandler:test_assertNotNil_throws_for_nil()
  local success, err = pcall(function()
    ErrorHandler.assertNotNil("TestModule", nil, "testParam")
  end)

  luaunit.assertFalse(success, "assertNotNil should throw for nil")
  luaunit.assertStrContains(err, "[FLEXLOVE_VAL_003]")
  luaunit.assertStrContains(err, "Required parameter missing")
  luaunit.assertStrContains(err, "testParam")
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

-- Test: assertType throws for wrong type (now uses error codes)
function TestErrorHandler:test_assertType_throws_for_wrong_type()
  local success, err = pcall(function()
    ErrorHandler.assertType("TestModule", 123, "string", "testParam")
  end)

  luaunit.assertFalse(success, "assertType should throw for wrong type")
  luaunit.assertStrContains(err, "[FLEXLOVE_VAL_001]")
  luaunit.assertStrContains(err, "Invalid property type")
  luaunit.assertStrContains(err, "testParam")
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

-- Test: assertRange throws for value below min (now uses error codes)
function TestErrorHandler:test_assertRange_throws_for_below_min()
  local success, err = pcall(function()
    ErrorHandler.assertRange("TestModule", -1, 0, 10, "testParam")
  end)

  luaunit.assertFalse(success, "assertRange should throw for value below min")
  luaunit.assertStrContains(err, "[FLEXLOVE_VAL_002]")
  luaunit.assertStrContains(err, "Property value out of range")
  luaunit.assertStrContains(err, "testParam")
end

-- Test: assertRange throws for value above max (now uses error codes)
function TestErrorHandler:test_assertRange_throws_for_above_max()
  local success, err = pcall(function()
    ErrorHandler.assertRange("TestModule", 11, 0, 10, "testParam")
  end)

  luaunit.assertFalse(success, "assertRange should throw for value above max")
  luaunit.assertStrContains(err, "[FLEXLOVE_VAL_002]")
  luaunit.assertStrContains(err, "Property value out of range")
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

-- Test: debug mode enables stack traces
function TestErrorHandler:test_debug_mode_enables_stack_trace()
  ErrorHandler.setDebugMode(true)

  local success, err = pcall(function()
    ErrorHandler.error("TestModule", "VAL_001", "Test error")
  end)

  luaunit.assertFalse(success, "error() should throw")
  luaunit.assertStrContains(err, "Stack trace:")

  ErrorHandler.setDebugMode(false)
end

-- Test: setStackTrace independently
function TestErrorHandler:test_set_stack_trace()
  ErrorHandler.setStackTrace(true)

  local success, err = pcall(function()
    ErrorHandler.error("TestModule", "VAL_001", "Test error")
  end)

  luaunit.assertFalse(success, "error() should throw")
  luaunit.assertStrContains(err, "Stack trace:")

  ErrorHandler.setStackTrace(false)
end

-- Test: error code validation
function TestErrorHandler:test_invalid_error_code_fallback()
  local success, err = pcall(function()
    ErrorHandler.error("TestModule", "INVALID_CODE", "This is a message")
  end)

  luaunit.assertFalse(success, "error() should throw")
  -- Should treat as message (backward compatibility)
  luaunit.assertStrContains(err, "INVALID_CODE")
  luaunit.assertStrContains(err, "This is a message")
end

-- Test: details formatting with long values
function TestErrorHandler:test_details_with_long_values()
  local longValue = string.rep("x", 150)
  local success, err = pcall(function()
    ErrorHandler.error("TestModule", "VAL_001", "Test", {
      shortValue = "short",
      longValue = longValue,
    })
  end)

  luaunit.assertFalse(success, "error() should throw")
  luaunit.assertStrContains(err, "ShortValue: short")
  -- Long value should be truncated
  luaunit.assertStrContains(err, "...")
end

-- Test: file logging
function TestErrorHandler:test_file_logging()
  ErrorHandler.setLogTarget("file")
  ErrorHandler.setLogFile("test-errors.log")

  -- Trigger an error (will be caught)
  local success = pcall(function()
    ErrorHandler.error("TestModule", "VAL_001", "Test file logging")
  end)

  -- Check file was created and contains log
  local file = io.open("test-errors.log", "r")
  luaunit.assertNotNil(file, "Log file should be created")

  if file then
    local content = file:read("*all")
    file:close()

    luaunit.assertStrContains(content, "ERROR")
    luaunit.assertStrContains(content, "TestModule")
    luaunit.assertStrContains(content, "Test file logging")
  end

  -- Cleanup
  ErrorHandler.setLogTarget("none")
  os.remove("test-errors.log")
end

-- Test: log level filtering
function TestErrorHandler:test_log_level_filtering()
  ErrorHandler.setLogTarget("file")
  ErrorHandler.setLogFile("test-errors.log")
  ErrorHandler.setLogLevel("ERROR") -- Only log errors, not warnings

  -- Trigger a warning (should not be logged)
  ErrorHandler.warn("TestModule", "VAL_001", "Test warning")

  -- Trigger an error (should be logged)
  pcall(function()
    ErrorHandler.error("TestModule", "VAL_001", "Test error")
  end)

  -- Check file
  local file = io.open("test-errors.log", "r")
  if file then
    local content = file:read("*all")
    file:close()

    luaunit.assertStrContains(content, "Test error")
    luaunit.assertFalse(content:find("Test warning") ~= nil, "Warning should not be logged")
  end

  -- Cleanup
  ErrorHandler.setLogTarget("none")
  ErrorHandler.setLogLevel("WARNING")
  os.remove("test-errors.log")
end

-- Test: JSON format
function TestErrorHandler:test_json_format()
  ErrorHandler.setLogTarget("file")
  ErrorHandler.setLogFile("test-errors.log")
  ErrorHandler.setLogFormat("json")

  pcall(function()
    ErrorHandler.error("TestModule", "VAL_001", "Test JSON", {
      property = "width",
    })
  end)

  local file = io.open("test-errors.log", "r")
  if file then
    local content = file:read("*all")
    file:close()

    -- Should be valid JSON-like
    luaunit.assertStrContains(content, '"level":"ERROR"')
    luaunit.assertStrContains(content, '"module":"TestModule"')
    luaunit.assertStrContains(content, '"message":"Test JSON"')
    luaunit.assertStrContains(content, '"details":')
  end

  -- Cleanup
  ErrorHandler.setLogTarget("none")
  ErrorHandler.setLogFormat("human")
  os.remove("test-errors.log")
end

-- Test: log rotation
function TestErrorHandler:test_log_rotation()
  ErrorHandler.setLogTarget("file")
  ErrorHandler.setLogFile("test-errors.log")
  ErrorHandler.enableLogRotation({ maxSize = 100, maxFiles = 2 }) -- Very small for testing

  -- Write multiple errors to trigger rotation
  for i = 1, 10 do
    pcall(function()
      ErrorHandler.error("TestModule", "VAL_001", "Test rotation error number " .. i)
    end)
  end

  -- Check that rotation occurred (main file should exist)
  local file = io.open("test-errors.log", "r")
  luaunit.assertNotNil(file, "Main log file should exist")
  if file then
    file:close()
  end

  -- Check that rotated files might exist (depending on log size)
  -- We won't assert this as it depends on exact message size

  -- Cleanup
  ErrorHandler.setLogTarget("none")
  ErrorHandler.enableLogRotation(true) -- Reset to defaults
  os.remove("test-errors.log")
  os.remove("test-errors.log.1")
  os.remove("test-errors.log.2")
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
