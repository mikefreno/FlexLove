---@class FFI
---@field enabled boolean Whether FFI is available and enabled
---@field _ffi table? LuaJIT FFI library reference
---@field _ColorStruct table? FFI color struct type
---@field _Vec2Struct table? FFI vec2 struct type
---@field _RectStruct table? FFI rect struct type
---@field _TimerStruct table? FFI timer struct type
---@field _colorPool table Pool of reusable color structs
---@field _vec2Pool table Pool of reusable vec2 structs
---@field _rectPool table Pool of reusable rect structs
---@field _ErrorHandler ErrorHandler
local FFI = {}
FFI.__index = FFI

---@type FFI|nil
local instance = nil

--- Initialize FFI module
---@param deps {ErrorHandler: ErrorHandler}
---@return FFI
function FFI.init(deps)
  if instance then
    return instance
  end

  local self = setmetatable({}, FFI)
  self._ErrorHandler = deps.ErrorHandler
  self.enabled = false
  self._ffi = nil

  -- Try to load LuaJIT FFI
  local success, ffi = pcall(require, "ffi")
  if success and ffi then
    self._ffi = ffi
    self.enabled = true

    -- Define FFI structs
    self:_defineStructs()

    -- Initialize object pools
    self:_initializePools()

    -- FFI successfully enabled
  else
    -- FFI not available (not running on LuaJIT)
  end

  instance = self
  return self
end

--- Define FFI struct types
function FFI:_defineStructs()
  local ffi = self._ffi
  if not ffi or not ffi.cdef then
    self.enabled = false
    return
  end

  -- Wrap in pcall to handle any FFI definition errors
  local success, err = pcall(function()
    -- Color struct (16 bytes - 4 floats)
    ffi.cdef([[
      typedef struct {
        float r;
        float g;
        float b;
        float a;
      } FlexLove_Color;
    ]])

    -- Vec2 struct (8 bytes - 2 floats)
    ffi.cdef([[
      typedef struct {
        float x;
        float y;
      } FlexLove_Vec2;
    ]])

    -- Rect struct (16 bytes - 4 floats)
    ffi.cdef([[
      typedef struct {
        float x;
        float y;
        float width;
        float height;
      } FlexLove_Rect;
    ]])

    -- Timer struct (16 bytes - 2 doubles)
    ffi.cdef([[
      typedef struct {
        double startTime;
        double elapsed;
      } FlexLove_Timer;
    ]])
  end)

  if not success then
    -- FFI definition failed, disable FFI
    self.enabled = false
    return
  end

  -- Cache struct types
  self._ColorStruct = ffi.typeof("FlexLove_Color")
  self._Vec2Struct = ffi.typeof("FlexLove_Vec2")
  self._RectStruct = ffi.typeof("FlexLove_Rect")
  self._TimerStruct = ffi.typeof("FlexLove_Timer")
end

--- Initialize object pools for reuse
function FFI:_initializePools()
  self._colorPool = {
    available = {},
    inUse = {},
    maxSize = 1000,
  }

  self._vec2Pool = {
    available = {},
    inUse = {},
    maxSize = 2000,
  }

  self._rectPool = {
    available = {},
    inUse = {},
    maxSize = 500,
  }
end

--- Create a new color struct (pooled)
--- Note: Not used by Color module due to method requirement
--- Available for internal FFI operations that don't need methods
---@param r number Red component (0-1)
---@param g number Green component (0-1)
---@param b number Blue component (0-1)
---@param a number Alpha component (0-1)
---@return table color FFI color struct
function FFI:createColor(r, g, b, a)
  if not self.enabled then
    return { r = r, g = g, b = b, a = a }
  end

  local color
  local pool = self._colorPool

  -- Try to reuse from pool
  if #pool.available > 0 then
    color = table.remove(pool.available)
  else
    color = self._ColorStruct()
  end

  -- Set values
  color.r = r or 0
  color.g = g or 0
  color.b = b or 0
  color.a = a or 1

  -- Track in use
  pool.inUse[color] = true

  return color
end

--- Release a color struct back to the pool
---@param color table FFI color struct
function FFI:releaseColor(color)
  if not self.enabled or not color then
    return
  end

  local pool = self._colorPool

  -- Remove from in-use tracking
  if pool.inUse[color] then
    pool.inUse[color] = nil

    -- Return to pool if not at max size
    if #pool.available < pool.maxSize then
      table.insert(pool.available, color)
    end
  end
end

--- Create a new vec2 struct (pooled)
---@param x number X component
---@param y number Y component
---@return table vec2 FFI vec2 struct
function FFI:createVec2(x, y)
  if not self.enabled then
    return { x = x, y = y }
  end

  local vec2
  local pool = self._vec2Pool

  -- Try to reuse from pool
  if #pool.available > 0 then
    vec2 = table.remove(pool.available)
  else
    vec2 = self._Vec2Struct()
  end

  -- Set values
  vec2.x = x or 0
  vec2.y = y or 0

  -- Track in use
  pool.inUse[vec2] = true

  return vec2
end

--- Release a vec2 struct back to the pool
---@param vec2 table FFI vec2 struct
function FFI:releaseVec2(vec2)
  if not self.enabled or not vec2 then
    return
  end

  local pool = self._vec2Pool

  -- Remove from in-use tracking
  if pool.inUse[vec2] then
    pool.inUse[vec2] = nil

    -- Return to pool if not at max size
    if #pool.available < pool.maxSize then
      table.insert(pool.available, vec2)
    end
  end
end

--- Create a new rect struct (pooled)
---@param x number X position
---@param y number Y position
---@param width number Width
---@param height number Height
---@return table rect FFI rect struct
function FFI:createRect(x, y, width, height)
  if not self.enabled then
    return { x = x, y = y, width = width, height = height }
  end

  local rect
  local pool = self._rectPool

  -- Try to reuse from pool
  if #pool.available > 0 then
    rect = table.remove(pool.available)
  else
    rect = self._RectStruct()
  end

  -- Set values
  rect.x = x or 0
  rect.y = y or 0
  rect.width = width or 0
  rect.height = height or 0

  -- Track in use
  pool.inUse[rect] = true

  return rect
end

--- Release a rect struct back to the pool
---@param rect table FFI rect struct
function FFI:releaseRect(rect)
  if not self.enabled or not rect then
    return
  end

  local pool = self._rectPool

  -- Remove from in-use tracking
  if pool.inUse[rect] then
    pool.inUse[rect] = nil

    -- Return to pool if not at max size
    if #pool.available < pool.maxSize then
      table.insert(pool.available, rect)
    end
  end
end

--- Create a new timer struct
---@return table timer FFI timer struct
function FFI:createTimer()
  if not self.enabled then
    return { startTime = 0, elapsed = 0 }
  end

  local timer = self._TimerStruct()
  timer.startTime = 0
  timer.elapsed = 0
  return timer
end

--- Allocate a contiguous array of colors (for batch operations)
---@param count number Number of colors to allocate
---@return table colors FFI color array
function FFI:allocateColorArray(count)
  if not self.enabled then
    local colors = {}
    for i = 1, count do
      colors[i] = { r = 0, g = 0, b = 0, a = 1 }
    end
    return colors
  end

  return self._ffi.new("FlexLove_Color[?]", count)
end

--- Allocate a contiguous array of vec2s (for batch operations)
---@param count number Number of vec2s to allocate
---@return table vec2s FFI vec2 array
function FFI:allocateVec2Array(count)
  if not self.enabled then
    local vec2s = {}
    for i = 1, count do
      vec2s[i] = { x = 0, y = 0 }
    end
    return vec2s
  end

  return self._ffi.new("FlexLove_Vec2[?]", count)
end

--- Allocate a contiguous array of rects (for batch operations)
---@param count number Number of rects to allocate
---@return table rects FFI rect array
function FFI:allocateRectArray(count)
  if not self.enabled then
    local rects = {}
    for i = 1, count do
      rects[i] = { x = 0, y = 0, width = 0, height = 0 }
    end
    return rects
  end

  return self._ffi.new("FlexLove_Rect[?]", count)
end

--- Clear all object pools (useful for cleanup)
function FFI:clearPools()
  if not self.enabled then
    return
  end

  -- Clear color pool
  self._colorPool.available = {}
  self._colorPool.inUse = {}

  -- Clear vec2 pool
  self._vec2Pool.available = {}
  self._vec2Pool.inUse = {}

  -- Clear rect pool
  self._rectPool.available = {}
  self._rectPool.inUse = {}
end

--- Get pool statistics (for debugging)
---@return table stats Pool statistics
function FFI:getPoolStats()
  if not self.enabled then
    return {
      enabled = false,
      colors = { available = 0, inUse = 0 },
      vec2s = { available = 0, inUse = 0 },
      rects = { available = 0, inUse = 0 },
    }
  end

  local function countInUse(pool)
    local count = 0
    for _ in pairs(pool.inUse) do
      count = count + 1
    end
    return count
  end

  return {
    enabled = true,
    colors = {
      available = #self._colorPool.available,
      inUse = countInUse(self._colorPool),
      maxSize = self._colorPool.maxSize,
    },
    vec2s = {
      available = #self._vec2Pool.available,
      inUse = countInUse(self._vec2Pool),
      maxSize = self._vec2Pool.maxSize,
    },
    rects = {
      available = #self._rectPool.available,
      inUse = countInUse(self._rectPool),
      maxSize = self._rectPool.maxSize,
    },
  }
end

--- Copy color values from FFI struct to Lua table (for compatibility)
---@param ffiColor table FFI color struct
---@return table color Lua table with r, g, b, a fields
function FFI:colorToTable(ffiColor)
  return {
    r = ffiColor.r,
    g = ffiColor.g,
    b = ffiColor.b,
    a = ffiColor.a,
  }
end

--- Copy vec2 values from FFI struct to Lua table (for compatibility)
---@param ffiVec2 table FFI vec2 struct
---@return table vec2 Lua table with x, y fields
function FFI:vec2ToTable(ffiVec2)
  return {
    x = ffiVec2.x,
    y = ffiVec2.y,
  }
end

--- Copy rect values from FFI struct to Lua table (for compatibility)
---@param ffiRect table FFI rect struct
---@return table rect Lua table with x, y, width, height fields
function FFI:rectToTable(ffiRect)
  return {
    x = ffiRect.x,
    y = ffiRect.y,
    width = ffiRect.width,
    height = ffiRect.height,
  }
end

--- Batch color multiplication (for opacity/tint operations)
---@param colors table Array of FFI color structs
---@param count number Number of colors
---@param multiplier number Multiplier value (0-1)
function FFI:batchMultiplyColors(colors, count, multiplier)
  if not self.enabled then
    for i = 1, count do
      local c = colors[i]
      c.r = c.r * multiplier
      c.g = c.g * multiplier
      c.b = c.b * multiplier
      c.a = c.a * multiplier
    end
    return
  end

  -- FFI arrays are 0-indexed
  for i = 0, count - 1 do
    colors[i].r = colors[i].r * multiplier
    colors[i].g = colors[i].g * multiplier
    colors[i].b = colors[i].b * multiplier
    colors[i].a = colors[i].a * multiplier
  end
end

--- Batch vec2 addition (for offset operations)
---@param vec2s table Array of FFI vec2 structs
---@param count number Number of vec2s
---@param offsetX number X offset
---@param offsetY number Y offset
function FFI:batchAddVec2s(vec2s, count, offsetX, offsetY)
  if not self.enabled then
    for i = 1, count do
      local v = vec2s[i]
      v.x = v.x + offsetX
      v.y = v.y + offsetY
    end
    return
  end

  -- FFI arrays are 0-indexed
  for i = 0, count - 1 do
    vec2s[i].x = vec2s[i].x + offsetX
    vec2s[i].y = vec2s[i].y + offsetY
  end
end

return FFI
