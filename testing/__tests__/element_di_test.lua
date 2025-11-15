-- Test that demonstrates dependency injection with mocked dependencies
package.path = package.path .. ";../../?.lua;../?.lua"
local luaunit = require("testing.luaunit")
local Element = require("modules.Element")

-- Mock dependencies
local function createMockDeps()
  return {
    Context = {
      _immediateMode = false,
      defaultTheme = "test",
      scaleFactors = { x = 1, y = 1 },
      registerElement = function() end,
      topElements = {},
    },
    Theme = {
      Manager = {
        new = function() 
          return {
            getThemeState = function() return "normal" end,
            update = function() end,
          }
        end
      },
    },
    Color = {
      new = function(r, g, b, a) 
        return { r = r or 0, g = g or 0, b = b or 0, a = a or 1 }
      end,
    },
    Units = {
      getViewport = function() return 1920, 1080 end,
      parse = function(value) 
        if type(value) == "number" then
          return value, "px"
        end
        return 100, "px"
      end,
    },
    Blur = {},
    ImageRenderer = {},
    NinePatch = {},
    RoundedRect = {},
    ImageCache = {},
    utils = {
      enums = {
        Positioning = { RELATIVE = "relative", ABSOLUTE = "absolute", FLEX = "flex", GRID = "grid" },
        FlexDirection = { HORIZONTAL = "horizontal", VERTICAL = "vertical" },
        JustifyContent = { FLEX_START = "flex-start", FLEX_END = "flex-end", CENTER = "center" },
        AlignContent = { STRETCH = "stretch", FLEX_START = "flex-start", FLEX_END = "flex-end" },
        AlignItems = { STRETCH = "stretch", FLEX_START = "flex-start", FLEX_END = "flex-end", CENTER = "center" },
        TextAlign = { LEFT = "left", CENTER = "center", RIGHT = "right" },
        AlignSelf = { AUTO = "auto", STRETCH = "stretch", FLEX_START = "flex-start" },
        JustifySelf = { AUTO = "auto", FLEX_START = "flex-start", FLEX_END = "flex-end" },
        FlexWrap = { NOWRAP = "nowrap", WRAP = "wrap" },
      },
      validateEnum = function() end,
      validateRange = function() end,
      validateType = function() end,
      resolveTextSizePreset = function(size) return size end,
      getModifiers = function() return false, false, false, false end,
    },
    Grid = {},
    InputEvent = {
      new = function() return {} end,
    },
    StateManager = {
      generateID = function() return "test-id" end,
    },
    TextEditor = {
      new = function() 
        return {
          initialize = function() end,
        }
      end,
    },
    LayoutEngine = {
      new = function()
        return {
          initialize = function() end,
          calculateLayout = function() end,
        }
      end,
    },
    Renderer = {
      new = function()
        return {
          initialize = function() end,
          draw = function() end,
        }
      end,
    },
    EventHandler = {
      new = function()
        return {
          initialize = function() end,
          getState = function() return {} end,
        }
      end,
    },
    ScrollManager = {
      new = function()
        return {
          initialize = function() end,
        }
      end,
    },
    ErrorHandler = {
      handle = function() end,
    },
  }
end

TestDependencyInjection = {}

function TestDependencyInjection:test_element_with_mocked_dependencies()
  -- Create mock dependencies
  local mockDeps = createMockDeps()
  
  -- Track if Context.registerElement was called
  local registerCalled = false
  mockDeps.Context.registerElement = function()
    registerCalled = true
  end
  
  -- Create element with mocked dependencies
  local element = Element.new({
    id = "test-element",
    width = 100,
    height = 100,
    x = 0,
    y = 0,
  }, mockDeps)
  
  -- Verify element was created
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.id, "test-element")
  luaunit.assertEquals(element.width, 100)
  luaunit.assertEquals(element.height, 100)
  
  -- Verify the element is using our mocked dependencies
  luaunit.assertEquals(element._deps, mockDeps)
  
  -- Verify Context.registerElement was called
  luaunit.assertTrue(registerCalled)
end

function TestDependencyInjection:test_element_without_deps_should_error()
  -- Element.new now requires deps parameter
  local success, err = pcall(function()
    Element.new({
      id = "test-element",
      width = 100,
      height = 100,
    })
  end)
  
  luaunit.assertFalse(success)
  luaunit.assertNotNil(err)
  luaunit.assertStrContains(err, "deps")
end

function TestDependencyInjection:test_can_mock_specific_module_behavior()
  local mockDeps = createMockDeps()
  
  -- Mock Units.parse to return specific values
  local parseCallCount = 0
  mockDeps.Units.parse = function(value)
    parseCallCount = parseCallCount + 1
    return 200, "px"  -- Always return 200px
  end
  
  -- Create element (this will call Units.parse)
  local element = Element.new({
    id = "test",
    width = "50%",  -- This should be parsed by our mock
    height = 100,
    x = 0,
    y = 0,
  }, mockDeps)
  
  -- Verify our mock was called
  luaunit.assertTrue(parseCallCount > 0, "Units.parse should have been called")
end

os.exit(luaunit.LuaUnit.run())
