-- LuaCheck configuration for FlexLöve
-- Install: luarocks install luacheck
-- Run: luacheck modules/ FlexLove.lua

-- Suppress warnings about undefined globals from LÖVE2D and LuaJIT
globals = {
  "love",
  "jit",
}

-- Read-only globals (standard Lua + common libs)
read_globals = {
  "math",
  "table",
  "string",
  "io",
  "os",
  "type",
  "pairs",
  "ipairs",
  "next",
  "select",
  "pcall",
  "xpcall",
  "error",
  "assert",
  "print",
  "tostring",
  "tonumber",
  "rawget",
  "rawset",
  "rawequal",
  "rawlen",
  "setmetatable",
  "getmetatable",
  "require",
  "dofile",
  "loadfile",
  "load",
  "unpack",
  "table.unpack",
  "utf8",
  "bit",
}

-- Ignore specific warnings
ignore = {
  "212", -- unused argument (common in callbacks with fixed signatures)
  "213", -- unused loop variable
}

-- Max line length (matches stylua.toml)
max_line_length = 120

-- Exclude non-library files from strict checks
exclude_files = {
  "testing/",
  "examples/",
  "profiling/",
  "themes/",
  "docs/",
}

-- Allow unused self in OOP methods
self = true
