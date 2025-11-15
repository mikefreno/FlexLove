#!/usr/bin/env lua
-- Script to add dependency injection to Element.lua

local function read_file(path)
  local f = io.open(path, "r")
  if not f then
    error("Could not open file: " .. path)
  end
  local content = f:read("*all")
  f:close()
  return content
end

local function write_file(path, content)
  local f = io.open(path, "w")
  if not f then
    error("Could not write file: " .. path)
  end
  f:write(content)
  f:close()
end

local element_path = "modules/Element.lua"
print("Reading " .. element_path)
local content = read_file(element_path)

-- Step 1: Add defaultDependencies after Element table definition
print("Step 1: Adding default dependencies...")
local element_def = "local Element = {}\nElement.__index = Element\n"
local new_element_def = [[local Element = {}
Element.__index = Element

-- Default dependencies (can be overridden for testing)
Element.defaultDependencies = {
  Context = Context,
  Theme = Theme,
  Color = Color,
  Units = Units,
  Blur = Blur,
  ImageRenderer = ImageRenderer,
  NinePatch = NinePatch,
  RoundedRect = RoundedRect,
  ImageCache = ImageCache,
  utils = utils,
  Grid = Grid,
  InputEvent = InputEvent,
  StateManager = StateManager,
  TextEditor = TextEditor,
  LayoutEngine = LayoutEngine,
  Renderer = Renderer,
  EventHandler = EventHandler,
  ScrollManager = ScrollManager,
  ErrorHandler = ErrorHandler,
}

]]

if not content:find("Element.defaultDependencies") then
  content = content:gsub(element_def:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"), new_element_def)
  print("  ✓ Added defaultDependencies")
else
  print("  - Already has defaultDependencies")
end

-- Step 2: Update Element.new signature
print("Step 2: Updating Element.new signature...")
local old_signature = "function Element.new%(props%)\n  local self = setmetatable%({}, Element%)"
local new_signature = [[function Element.new(props, deps)
  local self = setmetatable({}, Element)
  
  -- Initialize dependencies (allow injection for testing)
  self._deps = deps or Element.defaultDependencies]]

if not content:find("self._deps") then
  content = content:gsub(old_signature, new_signature)
  print("  ✓ Updated signature and added deps initialization")
else
  print("  - Already has deps initialization")
end

-- Step 3: Update comment for Element.new
print("Step 3: Updating function documentation...")
content = content:gsub(
  "%-%-%-@param props ElementProps\n%-%-%-@return Element",
  "---@param props ElementProps\n---@param deps table? Optional dependency injection (defaults to Element.defaultDependencies)\n---@return Element"
)

print("Writing changes to " .. element_path)
write_file(element_path, content)
print("✓ Done!")
print("\nNext steps:")
print("1. Run tests to ensure nothing broke")
print("2. Gradually replace module references with self._deps.ModuleName")
print("3. Create mock dependencies for testing")
