package.path = package.path .. ";./?.lua;./modules/?.lua"
local originalSearchers = package.searchers or package.loaders
table.insert(originalSearchers, 2, function(modname)
  if modname:match("^FlexLove%.modules%.") then
    local moduleName = modname:gsub("^FlexLove%.modules%.", "")
    return function()
      return require("modules." .. moduleName)
    end
  end
end)

-- Test automatic initialization queue functionality
require("testing.loveStub")
local luaunit = require("testing.luaunit")
local FlexLove = require("FlexLove")

TestInitQueue = {}

function TestInitQueue:setUp()
  -- Reset FlexLove state before each test
  FlexLove.destroy()
  -- Reset initialization state
  FlexLove._initState = "uninitialized"
  FlexLove.initialized = false
  FlexLove._initQueue = {}
end

function TestInitQueue:tearDown()
  FlexLove.destroy()
end

function TestInitQueue:test_elementCreationIsQueuedBeforeInit()
  -- Element creation before init should be queued
  local element = FlexLove.new({ text = "Test" })

  -- Should return nil when queued
  luaunit.assertNil(element)

  -- Queue should have one item
  luaunit.assertEquals(#FlexLove._initQueue, 1)
  luaunit.assertEquals(FlexLove._initQueue[1].props.text, "Test")
end

function TestInitQueue:test_queuedElementsCreatedAfterInit()
  local createdElement = nil

  -- Create element before init with callback
  FlexLove.new({
    text = "Queued Element",
    width = 100,
    height = 50,
  }, function(element)
    createdElement = element
  end)

  -- Should be queued
  luaunit.assertNil(createdElement)
  luaunit.assertEquals(#FlexLove._initQueue, 1)

  -- Initialize FlexLove
  FlexLove.init()

  -- Callback should have been called with created element
  luaunit.assertNotNil(createdElement)
  luaunit.assertEquals(createdElement.text, "Queued Element")
  luaunit.assertEquals(createdElement.width, 100)
  luaunit.assertEquals(createdElement.height, 50)

  -- Queue should be empty after init
  luaunit.assertEquals(#FlexLove._initQueue, 0)
end

function TestInitQueue:test_multipleElementsQueuedAndCreated()
  local elements = {}

  -- Queue multiple elements
  for i = 1, 5 do
    FlexLove.new({
      text = "Element " .. i,
      width = i * 10,
    }, function(element)
      table.insert(elements, element)
    end)
  end

  -- All should be queued
  luaunit.assertEquals(#FlexLove._initQueue, 5)
  luaunit.assertEquals(#elements, 0)

  -- Initialize
  FlexLove.init()

  -- All should be created
  luaunit.assertEquals(#elements, 5)
  luaunit.assertEquals(#FlexLove._initQueue, 0)

  -- Verify properties
  for i = 1, 5 do
    luaunit.assertEquals(elements[i].text, "Element " .. i)
    luaunit.assertEquals(elements[i].width, i * 10)
  end
end

function TestInitQueue:test_elementCreatedImmediatelyAfterInit()
  -- Initialize first
  FlexLove.init()

  -- Element creation after init should work immediately
  local element = FlexLove.new({ text = "Immediate" })

  -- Should return element, not nil
  luaunit.assertNotNil(element)
  luaunit.assertEquals(element.text, "Immediate")

  -- Queue should remain empty
  luaunit.assertEquals(#FlexLove._initQueue, 0)
end

function TestInitQueue:test_isReadyReturnsFalseBeforeInit()
  luaunit.assertFalse(FlexLove.isReady())
  luaunit.assertEquals(FlexLove._initState, "uninitialized")
end

function TestInitQueue:test_isReadyReturnsTrueAfterInit()
  FlexLove.init()

  luaunit.assertTrue(FlexLove.isReady())
  luaunit.assertEquals(FlexLove._initState, "ready")
end

function TestInitQueue:test_callbackErrorDoesNotStopQueue()
  local elements = {}

  -- First element with failing callback
  FlexLove.new({ text = "Element 1" }, function(element)
    table.insert(elements, element)
    error("Intentional error")
  end)

  -- Second element with working callback
  FlexLove.new({ text = "Element 2" }, function(element)
    table.insert(elements, element)
  end)

  -- Initialize (errors should be caught and logged)
  FlexLove.init()

  -- Both elements should have been created despite error
  luaunit.assertEquals(#elements, 2)
  luaunit.assertEquals(elements[1].text, "Element 1")
  luaunit.assertEquals(elements[2].text, "Element 2")
end

function TestInitQueue:test_queueWithoutCallback()
  -- Element without callback
  FlexLove.new({ text = "No Callback" })

  luaunit.assertEquals(#FlexLove._initQueue, 1)
  luaunit.assertNil(FlexLove._initQueue[1].callback)

  -- Should still be created after init
  FlexLove.init()

  luaunit.assertEquals(#FlexLove._initQueue, 0)
  -- Element was created, just no way to reference it without callback
end

if not _G.RUNNING_ALL_TESTS then
  os.exit(luaunit.LuaUnit.run())
end
