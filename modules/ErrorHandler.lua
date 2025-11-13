-- modules/ErrorHandler.lua
local ErrorHandler = {}

--- Format an error or warning message
---@param module string The module name (e.g., "Element", "Units", "Theme")
---@param level string "Error" or "Warning"
---@param message string The error/warning message
---@return string Formatted message
local function formatMessage(module, level, message)
  return string.format("[FlexLove - %s] %s: %s", module, level, message)
end

--- Throw a critical error (stops execution)
---@param module string The module name
---@param message string The error message
function ErrorHandler.error(module, message)
  error(formatMessage(module, "Error", message), 2)
end

--- Print a warning (non-critical, continues execution)
---@param module string The module name
---@param message string The warning message
function ErrorHandler.warn(module, message)
  print(formatMessage(module, "Warning", message))
end

--- Validate that a value is not nil
---@param module string The module name
---@param value any The value to check
---@param paramName string The parameter name
---@return boolean True if valid
function ErrorHandler.assertNotNil(module, value, paramName)
  if value == nil then
    ErrorHandler.error(module, string.format("Parameter '%s' cannot be nil", paramName))
    return false
  end
  return true
end

--- Validate that a value is of the expected type
---@param module string The module name
---@param value any The value to check
---@param expectedType string The expected type name
---@param paramName string The parameter name
---@return boolean True if valid
function ErrorHandler.assertType(module, value, expectedType, paramName)
  local actualType = type(value)
  if actualType ~= expectedType then
    ErrorHandler.error(module, string.format(
      "Parameter '%s' must be %s, got %s",
      paramName, expectedType, actualType
    ))
    return false
  end
  return true
end

--- Validate that a number is within a range
---@param module string The module name
---@param value number The value to check
---@param min number Minimum value (inclusive)
---@param max number Maximum value (inclusive)
---@param paramName string The parameter name
---@return boolean True if valid
function ErrorHandler.assertRange(module, value, min, max, paramName)
  if value < min or value > max then
    ErrorHandler.error(module, string.format(
      "Parameter '%s' must be between %s and %s, got %s",
      paramName, tostring(min), tostring(max), tostring(value)
    ))
    return false
  end
  return true
end

--- Warn if a value is deprecated
---@param module string The module name
---@param oldName string The deprecated name
---@param newName string The new name to use
function ErrorHandler.warnDeprecated(module, oldName, newName)
  ErrorHandler.warn(module, string.format(
    "'%s' is deprecated. Use '%s' instead",
    oldName, newName
  ))
end

--- Warn about a common mistake
---@param module string The module name
---@param issue string Description of the issue
---@param suggestion string Suggested fix
function ErrorHandler.warnCommonMistake(module, issue, suggestion)
  ErrorHandler.warn(module, string.format(
    "%s. Suggestion: %s",
    issue, suggestion
  ))
end

return ErrorHandler
