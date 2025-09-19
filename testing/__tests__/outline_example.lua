package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums

local FlexDirection = enums.FlexDirection
local Positioning = enums.Positioning
local JustifyContent = enums.JustifyContent
local AlignItems = enums.AlignItems

-- Create test cases
TestFlexDirection = {}

function TestFlexDirection:testHorizontalFlexBasic()
  local elem = Gui.new({ ... }) -- fill with props
end

function TestFlexDirection:testHorizontalFlexWithJustifyContentFlexStart() end

luaunit.LuaUnit.run()
