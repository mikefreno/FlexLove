local ErrorHandler = {}
local ErrorCodes = nil -- Will be injected via init

local LOG_LEVELS = {
  CRITICAL = 1,
  ERROR = 2,
  WARNING = 3,
  INFO = 4,
  DEBUG = 5,
}

local config = {
  debugMode = false,
  includeStackTrace = false,
  logLevel = LOG_LEVELS.WARNING, -- Default: log errors and warnings
  logTarget = "console", -- Options: "console", "file", "both", "none"
  logFormat = "human", -- Options: "human", "json"
  logFile = "flexlove-errors.log",
  maxLogSize = 10 * 1024 * 1024, -- 10MB default
  maxLogFiles = 5, -- Keep 5 rotated logs
  enableRotation = true,
}

-- Internal state
local logFileHandle = nil
local currentLogSize = 0

--- Initialize ErrorHandler with dependencies
---@param deps table Dependencies table with ErrorCodes
function ErrorHandler.init(deps)
  if deps and deps.ErrorCodes then
    ErrorCodes = deps.ErrorCodes
  else
    -- Try to require if not provided (backward compatibility)
    local success, module = pcall(require, "modules.ErrorCodes")
    if success then
      ErrorCodes = module
    else
      -- Create minimal stub if ErrorCodes not available
      ErrorCodes = {
        get = function() return nil end,
        describe = function(code) return code end,
        getSuggestion = function() return "" end,
      }
    end
  end
end

--- Set debug mode (enables stack traces and verbose output)
---@param enabled boolean Enable debug mode
function ErrorHandler.setDebugMode(enabled)
  config.debugMode = enabled
  config.includeStackTrace = enabled
  if enabled then
    config.logLevel = LOG_LEVELS.DEBUG
  end
end

--- Set whether to include stack traces
---@param enabled boolean Enable stack traces
function ErrorHandler.setStackTrace(enabled)
  config.includeStackTrace = enabled
end

--- Set log level (minimum level to log)
---@param level string|number Log level ("CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG") or number
function ErrorHandler.setLogLevel(level)
  if type(level) == "string" then
    config.logLevel = LOG_LEVELS[level:upper()] or LOG_LEVELS.WARNING
  elseif type(level) == "number" then
    config.logLevel = level
  end
end

--- Set log target
---@param target string "console", "file", "both", or "none"
function ErrorHandler.setLogTarget(target)
  config.logTarget = target
  -- Note: File will be opened lazily on first write
  if target == "console" or target == "none" then
    -- Close log file if open
    if logFileHandle then
      logFileHandle:close()
      logFileHandle = nil
      currentLogSize = 0
    end
  end
end

--- Set log format
---@param format string "human" or "json"
function ErrorHandler.setLogFormat(format)
  config.logFormat = format
end

--- Set log file path
---@param path string Path to log file
function ErrorHandler.setLogFile(path)
  -- Close existing log file
  if logFileHandle then
    logFileHandle:close()
    logFileHandle = nil
  end

  config.logFile = path
  currentLogSize = 0

  -- Note: File will be opened lazily on first write
end

--- Enable/disable log rotation
---@param enabled boolean|table Enable rotation or config table
function ErrorHandler.enableLogRotation(enabled)
  if type(enabled) == "boolean" then
    config.enableRotation = enabled
  elseif type(enabled) == "table" then
    config.enableRotation = true
    if enabled.maxSize then
      config.maxLogSize = enabled.maxSize
    end
    if enabled.maxFiles then
      config.maxLogFiles = enabled.maxFiles
    end
  end
end

--- Get current timestamp with milliseconds
---@return string Formatted timestamp
local function getTimestamp()
  local time = os.time()
  local date = os.date("%Y-%m-%d %H:%M:%S", time)
  -- Note: Lua doesn't have millisecond precision by default, so we approximate
  return date
end

--- Rotate log file if needed
local function rotateLogIfNeeded()
  if not config.enableRotation then
    return
  end
  if currentLogSize < config.maxLogSize then
    return
  end

  -- Close current log
  if logFileHandle then
    logFileHandle:close()
    logFileHandle = nil
  end

  -- Rotate existing logs
  for i = config.maxLogFiles - 1, 1, -1 do
    local oldName = config.logFile .. "." .. i
    local newName = config.logFile .. "." .. (i + 1)
    os.rename(oldName, newName) -- Will fail silently if file doesn't exist
  end

  -- Move current log to .1
  os.rename(config.logFile, config.logFile .. ".1")

  -- Create new log file
  logFileHandle = io.open(config.logFile, "a")
  currentLogSize = 0
end

--- Escape string for JSON
---@param str string String to escape
---@return string Escaped string
local function escapeJson(str)
  str = tostring(str)
  str = str:gsub("\\", "\\\\")
  str = str:gsub('"', '\\"')
  str = str:gsub("\n", "\\n")
  str = str:gsub("\r", "\\r")
  str = str:gsub("\t", "\\t")
  return str
end

--- Format details as JSON object
---@param details table|nil Details object
---@return string JSON string
local function formatDetailsJson(details)
  if not details or type(details) ~= "table" then
    return "{}"
  end

  local parts = {}
  for key, value in pairs(details) do
    local jsonKey = escapeJson(tostring(key))
    local jsonValue = escapeJson(tostring(value))
    table.insert(parts, string.format('"%s":"%s"', jsonKey, jsonValue))
  end

  return "{" .. table.concat(parts, ",") .. "}"
end

--- Format details object as readable key-value pairs
---@param details table|nil Details object
---@return string Formatted details
local function formatDetails(details)
  if not details or type(details) ~= "table" then
    return ""
  end

  local lines = {}
  for key, value in pairs(details) do
    local formattedKey = tostring(key):gsub("^%l", string.upper)
    local formattedValue = tostring(value)
    -- Truncate very long values
    if #formattedValue > 100 then
      formattedValue = formattedValue:sub(1, 97) .. "..."
    end
    table.insert(lines, string.format("  %s: %s", formattedKey, formattedValue))
  end

  if #lines > 0 then
    return "\n\nDetails:\n" .. table.concat(lines, "\n")
  end
  return ""
end

--- Extract and format stack trace
---@param level number Stack level to start from
---@return string Formatted stack trace
local function formatStackTrace(level)
  if not config.includeStackTrace then
    return ""
  end

  local lines = {}
  local currentLevel = level or 3

  while true do
    local info = debug.getinfo(currentLevel, "Sl")
    if not info then
      break
    end

    -- Skip internal Lua files
    if info.source:match("^@") and not info.source:match("loveStub") then
      local source = info.source:sub(2) -- Remove @ prefix
      local location = string.format("%s:%d", source, info.currentline)
      table.insert(lines, "  " .. location)
    end

    currentLevel = currentLevel + 1
    if currentLevel > level + 10 then
      break
    end -- Limit depth
  end

  if #lines > 0 then
    return "\n\nStack trace:\n" .. table.concat(lines, "\n")
  end
  return ""
end

--- Format an error or warning message with optional error code
---@param module string The module name (e.g., "Element", "Units", "Theme")
---@param level string "Error" or "Warning"
---@param codeOrMessage string Error code (e.g., "VAL_001") or message
---@param messageOrDetails string|table|nil Message or details object
---@param detailsOrSuggestion table|string|nil Details or suggestion
---@param suggestionOrNil string|nil Suggestion
---@return string Formatted message
local function formatMessage(module, level, codeOrMessage, messageOrDetails, detailsOrSuggestion, suggestionOrNil)
  local code = nil
  local message = codeOrMessage
  local details = nil
  local suggestion = nil

  -- Parse arguments (support multiple signatures)
  if type(codeOrMessage) == "string" and ErrorCodes.get(codeOrMessage) then
    -- Called with error code
    code = codeOrMessage
    message = messageOrDetails or ErrorCodes.describe(code)

    if type(detailsOrSuggestion) == "table" then
      details = detailsOrSuggestion
      suggestion = suggestionOrNil or ErrorCodes.getSuggestion(code)
    elseif type(detailsOrSuggestion) == "string" then
      suggestion = detailsOrSuggestion
    else
      suggestion = ErrorCodes.getSuggestion(code)
    end
  else
    -- Called with message only (backward compatibility)
    message = codeOrMessage
    if type(messageOrDetails) == "table" then
      details = messageOrDetails
      suggestion = detailsOrSuggestion
    elseif type(messageOrDetails) == "string" then
      suggestion = messageOrDetails
    end
  end

  -- Build formatted message
  local parts = {}

  -- Header: [FlexLove - Module] Level [CODE]: Message
  if code then
    local codeInfo = ErrorCodes.get(code)
    table.insert(parts, string.format("[FlexLove - %s] %s [%s]: %s", module, level, codeInfo.code, message))
  else
    table.insert(parts, string.format("[FlexLove - %s] %s: %s", module, level, message))
  end

  -- Details section
  if details then
    table.insert(parts, formatDetails(details))
  end

  -- Suggestion section
  if suggestion and suggestion ~= "" then
    table.insert(parts, string.format("\n\nSuggestion: %s", suggestion))
  end

  return table.concat(parts, "")
end

--- Write log entry to file and/or console
---@param level string Log level
---@param levelNum number Log level number
---@param module string Module name
---@param code string|nil Error code
---@param message string Message
---@param details table|nil Details
---@param suggestion string|nil Suggestion
local function writeLog(level, levelNum, module, code, message, details, suggestion)
  -- Check if we should log this level
  if levelNum > config.logLevel then
    return
  end

  local timestamp = getTimestamp()
  local logEntry

  if config.logFormat == "json" then
    -- JSON format
    local jsonParts = {
      string.format('"timestamp":"%s"', escapeJson(timestamp)),
      string.format('"level":"%s"', level),
      string.format('"module":"%s"', escapeJson(module)),
      string.format('"message":"%s"', escapeJson(message)),
    }

    if code then
      table.insert(jsonParts, string.format('"code":"%s"', escapeJson(code)))
    end

    if details then
      table.insert(jsonParts, string.format('"details":%s', formatDetailsJson(details)))
    end

    if suggestion then
      table.insert(jsonParts, string.format('"suggestion":"%s"', escapeJson(suggestion)))
    end

    logEntry = "{" .. table.concat(jsonParts, ",") .. "}\n"
  else
    -- Human-readable format
    local parts = {
      string.format("[%s] [%s] [%s]", timestamp, level, module),
    }

    if code then
      table.insert(parts, string.format("[%s]", code))
    end

    table.insert(parts, message)
    logEntry = table.concat(parts, " ") .. "\n"

    if details then
      logEntry = logEntry .. formatDetails(details):gsub("^\n\n", "") .. "\n"
    end

    if suggestion then
      logEntry = logEntry .. "Suggestion: " .. suggestion .. "\n"
    end

    logEntry = logEntry .. "\n"
  end

  -- Write to console
  if config.logTarget == "console" or config.logTarget == "both" then
    io.write(logEntry)
    io.flush()
  end

  -- Write to file
  if config.logTarget == "file" or config.logTarget == "both" then
    -- Lazy file opening: open on first write
    if not logFileHandle then
      logFileHandle = io.open(config.logFile, "a")
      if logFileHandle then
        -- Get current file size
        local currentPos = logFileHandle:seek("end")
        currentLogSize = currentPos or 0
      end
    end

    if logFileHandle then
      rotateLogIfNeeded()

      -- Reopen if rotation closed it
      if not logFileHandle then
        logFileHandle = io.open(config.logFile, "a")
      end

      if logFileHandle then
        logFileHandle:write(logEntry)
        logFileHandle:flush()
        currentLogSize = currentLogSize + #logEntry
      end
    end
  end
end

--- Throw a critical error (stops execution)
---@param module string The module name
---@param codeOrMessage string Error code or message
---@param messageOrDetails string|table|nil Message or details
---@param detailsOrSuggestion table|string|nil Details or suggestion
---@param suggestion string|nil Suggestion
function ErrorHandler.error(module, codeOrMessage, messageOrDetails, detailsOrSuggestion, suggestion)
  local formattedMessage = formatMessage(module, "Error", codeOrMessage, messageOrDetails, detailsOrSuggestion, suggestion)

  -- Parse arguments for logging
  local code = nil
  local message = codeOrMessage
  local details = nil
  local logSuggestion = nil

  if type(codeOrMessage) == "string" and ErrorCodes.get(codeOrMessage) then
    code = codeOrMessage
    message = messageOrDetails or ErrorCodes.describe(code)

    if type(detailsOrSuggestion) == "table" then
      details = detailsOrSuggestion
      logSuggestion = suggestion or ErrorCodes.getSuggestion(code)
    elseif type(detailsOrSuggestion) == "string" then
      logSuggestion = detailsOrSuggestion
    else
      logSuggestion = ErrorCodes.getSuggestion(code)
    end
  else
    message = codeOrMessage
    if type(messageOrDetails) == "table" then
      details = messageOrDetails
      logSuggestion = detailsOrSuggestion
    elseif type(messageOrDetails) == "string" then
      logSuggestion = messageOrDetails
    end
  end

  -- Log the error
  writeLog("ERROR", LOG_LEVELS.ERROR, module, code, message, details, logSuggestion)

  -- Add stack trace if enabled
  if config.includeStackTrace then
    formattedMessage = formattedMessage .. formatStackTrace(3)
  end

  error(formattedMessage, 2)
end

--- Print a warning (non-critical, continues execution)
---@param module string The module name
---@param codeOrMessage string Warning code or message
---@param messageOrDetails string|table|nil Message or details
---@param detailsOrSuggestion table|string|nil Details or suggestion
---@param suggestion string|nil Suggestion
function ErrorHandler.warn(module, codeOrMessage, messageOrDetails, detailsOrSuggestion, suggestion)
  -- Parse arguments for logging
  local code = nil
  local message = codeOrMessage
  local details = nil
  local logSuggestion = nil

  if type(codeOrMessage) == "string" and ErrorCodes.get(codeOrMessage) then
    code = codeOrMessage
    message = messageOrDetails or ErrorCodes.describe(code)

    if type(detailsOrSuggestion) == "table" then
      details = detailsOrSuggestion
      logSuggestion = suggestion or ErrorCodes.getSuggestion(code)
    elseif type(detailsOrSuggestion) == "string" then
      logSuggestion = detailsOrSuggestion
    else
      logSuggestion = ErrorCodes.getSuggestion(code)
    end
  else
    message = codeOrMessage
    if type(messageOrDetails) == "table" then
      details = messageOrDetails
      logSuggestion = detailsOrSuggestion
    elseif type(messageOrDetails) == "string" then
      logSuggestion = messageOrDetails
    end
  end

  -- Log the warning
  writeLog("WARNING", LOG_LEVELS.WARNING, module, code, message, details, logSuggestion)

  local formattedMessage = formatMessage(module, "Warning", codeOrMessage, messageOrDetails, detailsOrSuggestion, suggestion)
  print(formattedMessage)
end

--- Validate that a value is not nil
---@param module string The module name
---@param value any The value to check
---@param paramName string The parameter name
---@return boolean True if valid
function ErrorHandler.assertNotNil(module, value, paramName)
  if value == nil then
    ErrorHandler.error(module, "VAL_003", "Required parameter missing", {
      parameter = paramName,
    })
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
    ErrorHandler.error(module, "VAL_001", "Invalid property type", {
      property = paramName,
      expected = expectedType,
      got = actualType,
    })
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
    ErrorHandler.error(module, "VAL_002", "Property value out of range", {
      property = paramName,
      min = tostring(min),
      max = tostring(max),
      value = tostring(value),
    })
    return false
  end
  return true
end

--- Warn if a value is deprecated
---@param module string The module name
---@param oldName string The deprecated name
---@param newName string The new name to use
function ErrorHandler.warnDeprecated(module, oldName, newName)
  ErrorHandler.warn(module, string.format("'%s' is deprecated. Use '%s' instead", oldName, newName))
end

--- Warn about a common mistake
---@param module string The module name
---@param issue string Description of the issue
---@param suggestion string Suggested fix
function ErrorHandler.warnCommonMistake(module, issue, suggestion)
  ErrorHandler.warn(module, string.format("%s. Suggestion: %s", issue, suggestion))
end

return ErrorHandler
