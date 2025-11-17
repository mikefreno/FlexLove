---@class ErrorCodes
local ErrorCodes = {}

-- Error code categories
ErrorCodes.categories = {
  VAL = "Validation",
  LAY = "Layout",
  REN = "Render",
  THM = "Theme",
  EVT = "Event",
  RES = "Resource",
  SYS = "System",
}

-- Error code definitions
ErrorCodes.codes = {
  -- Validation Errors (VAL_001 - VAL_099)
  VAL_001 = {
    code = "FLEXLOVE_VAL_001",
    category = "VAL",
    description = "Invalid property type",
    suggestion = "Check the property type matches the expected type (e.g., number, string, table)",
  },
  VAL_002 = {
    code = "FLEXLOVE_VAL_002",
    category = "VAL",
    description = "Property value out of range",
    suggestion = "Ensure the value is within the allowed min/max range",
  },
  VAL_003 = {
    code = "FLEXLOVE_VAL_003",
    category = "VAL",
    description = "Required property missing",
    suggestion = "Provide the required property in your element definition",
  },
  VAL_004 = {
    code = "FLEXLOVE_VAL_004",
    category = "VAL",
    description = "Invalid color format",
    suggestion = "Use valid color format: {r, g, b, a} with values 0-1, hex string, or Color object",
  },
  VAL_005 = {
    code = "FLEXLOVE_VAL_005",
    category = "VAL",
    description = "Invalid unit format",
    suggestion = "Use valid unit format: number (px), '50%', '10vw', '5vh', etc.",
  },
  VAL_006 = {
    code = "FLEXLOVE_VAL_006",
    category = "VAL",
    description = "Invalid file path",
    suggestion = "Check that the file path is correct and the file exists",
  },
  VAL_007 = {
    code = "FLEXLOVE_VAL_007",
    category = "VAL",
    description = "Invalid enum value",
    suggestion = "Use one of the allowed enum values for this property",
  },
  VAL_008 = {
    code = "FLEXLOVE_VAL_008",
    category = "VAL",
    description = "Invalid text input",
    suggestion = "Ensure text meets validation requirements (length, pattern, allowed characters)",
  },

  -- Layout Errors (LAY_001 - LAY_099)
  LAY_001 = {
    code = "FLEXLOVE_LAY_001",
    category = "LAY",
    description = "Invalid flex direction",
    suggestion = "Use 'horizontal' or 'vertical' for flexDirection",
  },
  LAY_002 = {
    code = "FLEXLOVE_LAY_002",
    category = "LAY",
    description = "Circular dependency detected",
    suggestion = "Remove circular references in element hierarchy or layout constraints",
  },
  LAY_003 = {
    code = "FLEXLOVE_LAY_003",
    category = "LAY",
    description = "Invalid dimensions (negative or NaN)",
    suggestion = "Ensure width and height are positive numbers",
  },
  LAY_004 = {
    code = "FLEXLOVE_LAY_004",
    category = "LAY",
    description = "Layout calculation overflow",
    suggestion = "Reduce complexity of layout or increase recursion limit",
  },
  LAY_005 = {
    code = "FLEXLOVE_LAY_005",
    category = "LAY",
    description = "Invalid alignment value",
    suggestion = "Use valid alignment values (flex-start, center, flex-end, etc.)",
  },
  LAY_006 = {
    code = "FLEXLOVE_LAY_006",
    category = "LAY",
    description = "Invalid positioning mode",
    suggestion = "Use 'absolute', 'relative', 'flex', or 'grid' for positioning",
  },
  LAY_007 = {
    code = "FLEXLOVE_LAY_007",
    category = "LAY",
    description = "Grid layout error",
    suggestion = "Check grid template columns/rows and item placement",
  },

  -- Rendering Errors (REN_001 - REN_099)
  REN_001 = {
    code = "FLEXLOVE_REN_001",
    category = "REN",
    description = "Invalid render state",
    suggestion = "Ensure element is properly initialized before rendering",
  },
  REN_002 = {
    code = "FLEXLOVE_REN_002",
    category = "REN",
    description = "Texture loading failed",
    suggestion = "Check image path and format, ensure file exists",
  },
  REN_003 = {
    code = "FLEXLOVE_REN_003",
    category = "REN",
    description = "Font loading failed",
    suggestion = "Check font path and format, ensure file exists",
  },
  REN_004 = {
    code = "FLEXLOVE_REN_004",
    category = "REN",
    description = "Invalid color value",
    suggestion = "Color components must be numbers between 0 and 1",
  },
  REN_005 = {
    code = "FLEXLOVE_REN_005",
    category = "REN",
    description = "Clipping stack overflow",
    suggestion = "Reduce nesting depth or check for missing scissor pops",
  },
  REN_006 = {
    code = "FLEXLOVE_REN_006",
    category = "REN",
    description = "Shader compilation failed",
    suggestion = "Check shader code for syntax errors",
  },
  REN_007 = {
    code = "FLEXLOVE_REN_007",
    category = "REN",
    description = "Invalid nine-patch configuration",
    suggestion = "Check nine-patch slice values and image dimensions",
  },

  -- Theme Errors (THM_001 - THM_099)
  THM_001 = {
    code = "FLEXLOVE_THM_001",
    category = "THM",
    description = "Theme file not found",
    suggestion = "Check theme file path and ensure file exists",
  },
  THM_002 = {
    code = "FLEXLOVE_THM_002",
    category = "THM",
    description = "Invalid theme structure",
    suggestion = "Theme must return a table with 'name' and component styles",
  },
  THM_003 = {
    code = "FLEXLOVE_THM_003",
    category = "THM",
    description = "Required theme property missing",
    suggestion = "Ensure theme has required properties (name, base styles, etc.)",
  },
  THM_004 = {
    code = "FLEXLOVE_THM_004",
    category = "THM",
    description = "Invalid component style",
    suggestion = "Component styles must be tables with valid properties",
  },
  THM_005 = {
    code = "FLEXLOVE_THM_005",
    category = "THM",
    description = "Theme loading failed",
    suggestion = "Check theme file for Lua syntax errors",
  },
  THM_006 = {
    code = "FLEXLOVE_THM_006",
    category = "THM",
    description = "Invalid theme color",
    suggestion = "Theme colors must be valid color values (hex, rgba, Color object)",
  },

  -- Event Errors (EVT_001 - EVT_099)
  EVT_001 = {
    code = "FLEXLOVE_EVT_001",
    category = "EVT",
    description = "Invalid event type",
    suggestion = "Use valid event types (mousepressed, textinput, etc.)",
  },
  EVT_002 = {
    code = "FLEXLOVE_EVT_002",
    category = "EVT",
    description = "Event handler error",
    suggestion = "Check event handler function for errors",
  },
  EVT_003 = {
    code = "FLEXLOVE_EVT_003",
    category = "EVT",
    description = "Event propagation error",
    suggestion = "Check event bubbling/capturing logic",
  },
  EVT_004 = {
    code = "FLEXLOVE_EVT_004",
    category = "EVT",
    description = "Invalid event target",
    suggestion = "Ensure event target element exists and is valid",
  },
  EVT_005 = {
    code = "FLEXLOVE_EVT_005",
    category = "EVT",
    description = "Event handler not a function",
    suggestion = "Event handlers must be functions",
  },

  -- Resource Errors (RES_001 - RES_099)
  RES_001 = {
    code = "FLEXLOVE_RES_001",
    category = "RES",
    description = "File not found",
    suggestion = "Check file path and ensure file exists in the filesystem",
  },
  RES_002 = {
    code = "FLEXLOVE_RES_002",
    category = "RES",
    description = "Permission denied",
    suggestion = "Check file permissions and access rights",
  },
  RES_003 = {
    code = "FLEXLOVE_RES_003",
    category = "RES",
    description = "Invalid file format",
    suggestion = "Ensure file format is supported (png, jpg, ttf, etc.)",
  },
  RES_004 = {
    code = "FLEXLOVE_RES_004",
    category = "RES",
    description = "Resource loading failed",
    suggestion = "Check file integrity and format compatibility",
  },
  RES_005 = {
    code = "FLEXLOVE_RES_005",
    category = "RES",
    description = "Image cache error",
    suggestion = "Clear image cache or check memory availability",
  },

  -- System Errors (SYS_001 - SYS_099)
  SYS_001 = {
    code = "FLEXLOVE_SYS_001",
    category = "SYS",
    description = "Memory allocation failed",
    suggestion = "Reduce memory usage or check available memory",
  },
  SYS_002 = {
    code = "FLEXLOVE_SYS_002",
    category = "SYS",
    description = "Stack overflow",
    suggestion = "Reduce recursion depth or check for infinite loops",
  },
  SYS_003 = {
    code = "FLEXLOVE_SYS_003",
    category = "SYS",
    description = "Invalid state",
    suggestion = "Check initialization order and state management",
  },
  SYS_004 = {
    code = "FLEXLOVE_SYS_004",
    category = "SYS",
    description = "Module initialization failed",
    suggestion = "Check module dependencies and initialization order",
  },
}

--- Get error information by code
--- @param code string Error code (e.g., "VAL_001" or "FLEXLOVE_VAL_001")
--- @return table? errorInfo Error information or nil if not found
function ErrorCodes.get(code)
  -- Handle both short and full format
  local shortCode = code:gsub("^FLEXLOVE_", "")
  return ErrorCodes.codes[shortCode]
end

--- Get human-readable description for error code
--- @param code string Error code
--- @return string description Error description
function ErrorCodes.describe(code)
  local info = ErrorCodes.get(code)
  if info then
    return info.description
  end
  return "Unknown error code: " .. code
end

--- Get suggested fix for error code
--- @param code string Error code
--- @return string suggestion Suggested fix
function ErrorCodes.getSuggestion(code)
  local info = ErrorCodes.get(code)
  if info then
    return info.suggestion
  end
  return "No suggestion available"
end

--- Get category for error code
--- @param code string Error code
--- @return string category Error category name
function ErrorCodes.getCategory(code)
  local info = ErrorCodes.get(code)
  if info then
    return ErrorCodes.categories[info.category] or info.category
  end
  return "Unknown"
end

--- List all error codes in a category
--- @param category string Category code (e.g., "VAL", "LAY")
--- @return table codes List of error codes in category
function ErrorCodes.listByCategory(category)
  local result = {}
  for code, info in pairs(ErrorCodes.codes) do
    if info.category == category then
      table.insert(result, {
        code = code,
        fullCode = info.code,
        description = info.description,
        suggestion = info.suggestion,
      })
    end
  end
  table.sort(result, function(a, b)
    return a.code < b.code
  end)
  return result
end

--- Search error codes by keyword
--- @param keyword string Keyword to search for
--- @return table codes Matching error codes
function ErrorCodes.search(keyword)
  keyword = keyword:lower()
  local result = {}
  for code, info in pairs(ErrorCodes.codes) do
    local searchText = (code .. " " .. info.description .. " " .. info.suggestion):lower()
    if searchText:find(keyword, 1, true) then
      table.insert(result, {
        code = code,
        fullCode = info.code,
        description = info.description,
        suggestion = info.suggestion,
        category = ErrorCodes.categories[info.category],
      })
    end
  end
  return result
end

--- Get all error codes
--- @return table codes All error codes
function ErrorCodes.listAll()
  local result = {}
  for code, info in pairs(ErrorCodes.codes) do
    table.insert(result, {
      code = code,
      fullCode = info.code,
      description = info.description,
      suggestion = info.suggestion,
      category = ErrorCodes.categories[info.category],
    })
  end
  table.sort(result, function(a, b)
    return a.code < b.code
  end)
  return result
end

--- Format error message with code
--- @param code string Error code
--- @param message string Error message
--- @return string formattedMessage Formatted error message with code
function ErrorCodes.formatMessage(code, message)
  local info = ErrorCodes.get(code)
  if info then
    return string.format("[%s] %s", info.code, message)
  end
  return message
end

--- Validate that all error codes are unique and properly formatted
--- @return boolean, string? Returns true if valid, or false with error message
function ErrorCodes.validate()
  local seen = {}
  local fullCodes = {}

  for code, info in pairs(ErrorCodes.codes) do
    -- Check for duplicates
    if seen[code] then
      return false, "Duplicate error code: " .. code
    end
    seen[code] = true

    if fullCodes[info.code] then
      return false, "Duplicate full error code: " .. info.code
    end
    fullCodes[info.code] = true

    -- Check format
    if not code:match("^[A-Z]+_[0-9]+$") then
      return false, "Invalid code format: " .. code .. " (expected CATEGORY_NUMBER)"
    end

    -- Check full code format
    local expectedFullCode = "FLEXLOVE_" .. code
    if info.code ~= expectedFullCode then
      return false, "Mismatched full code for " .. code .. ": expected " .. expectedFullCode .. ", got " .. info.code
    end

    -- Check required fields
    if not info.description or info.description == "" then
      return false, "Missing description for " .. code
    end
    if not info.suggestion or info.suggestion == "" then
      return false, "Missing suggestion for " .. code
    end
    if not info.category or info.category == "" then
      return false, "Missing category for " .. code
    end
  end

  return true, nil
end

return ErrorCodes
