-- Test suite for vertical flex direction functionality
-- Tests that flex layout works correctly with vertical direction

package.path = package.path .. ";?.lua"

local luaunit = require("testing/luaunit")
require("testing/loveStub") -- Required to mock LOVE functions
local FlexLove = require("FlexLove")
local Gui, enums = FlexLove.GUI, FlexLove.enums

local Positioning = enums.Positioning
local FlexDirection = enums.FlexDirection
local JustifyContent = enums.JustifyContent
local AlignItems = enums.AlignItems

-- Test class
TestVerticalFlexDirection = {}

function TestVerticalFlexDirection:setUp()
  -- Clean up before each test
  Gui.destroy()
end

function TestVerticalFlexDirection:tearDown()
  -- Clean up after each test
  Gui.destroy()
end

-- Test 1: Basic element creation with vertical flex direction
function TestVerticalFlexDirection:testCreateElementWithVerticalFlexDirection()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    w = 100,
    h = 300,
  })

  -- Verify element was created with correct properties
  luaunit.assertEquals(parent.positioning, Positioning.FLEX)
  luaunit.assertEquals(parent.flexDirection, FlexDirection.VERTICAL)
  luaunit.assertEquals(parent.width, 100)
  luaunit.assertEquals(parent.height, 300)
end

-- Test 2: Single child vertical layout
function TestVerticalFlexDirection:testSingleChildVerticalLayout()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    w = 100,
    h = 300,
  })

  local child = Gui.new({
    id = "single_child",
    w = 80,
    h = 50,
  })

  parent:addChild(child)

  -- Child should be positioned at top of parent (flex-start default)
  luaunit.assertEquals(child.x, parent.x)
  luaunit.assertEquals(child.y, parent.y)
end

-- Test 3: Multiple children vertical layout
function TestVerticalFlexDirection:testMultipleChildrenVerticalLayout()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    gap = 10,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 80,
    h = 50,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 70,
    h = 40,
  })

  local child3 = Gui.new({
    id = "child3",
    w = 60,
    h = 30,
  })

  parent:addChild(child1)
  parent:addChild(child2)
  parent:addChild(child3)

  -- Children should be positioned vertically with gaps
  luaunit.assertEquals(child1.x, parent.x)
  luaunit.assertEquals(child1.y, parent.y)

  luaunit.assertEquals(child2.x, parent.x)
  luaunit.assertEquals(child2.y, child1.y + child1.height + parent.gap)

  luaunit.assertEquals(child3.x, parent.x)
  luaunit.assertEquals(child3.y, child2.y + child2.height + parent.gap)
end

-- Test 4: Empty parent (no children) vertical layout
function TestVerticalFlexDirection:testEmptyParentVerticalLayout()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    w = 100,
    h = 300,
  })

  -- Should not cause any errors and should have no children
  luaunit.assertEquals(#parent.children, 0)
end

-- Test 5: Vertical layout with flex-start justification (default)
function TestVerticalFlexDirection:testVerticalLayoutFlexStart()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_START,
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    gap = 10,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 80,
    h = 50,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 70,
    h = 40,
  })

  parent:addChild(child1)
  parent:addChild(child2)

  -- Children should be positioned at top (flex-start)
  luaunit.assertEquals(child1.y, parent.y)
  luaunit.assertEquals(child2.y, child1.y + child1.height + parent.gap)
end

-- Test 6: Vertical layout with center justification
function TestVerticalFlexDirection:testVerticalLayoutCenter()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.CENTER,
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    gap = 10,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 80,
    h = 50,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 70,
    h = 40,
  })

  parent:addChild(child1)
  parent:addChild(child2)

  -- Calculate expected center positioning
  local totalChildHeight = child1.height + child2.height + parent.gap
  local availableSpace = parent.height - totalChildHeight
  local startY = availableSpace / 2

  luaunit.assertEquals(child1.y, parent.y + startY)
  luaunit.assertEquals(child2.y, child1.y + child1.height + parent.gap)
end

-- Test 7: Vertical layout with flex-end justification
function TestVerticalFlexDirection:testVerticalLayoutFlexEnd()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_END,
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    gap = 10,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 80,
    h = 50,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 70,
    h = 40,
  })

  parent:addChild(child1)
  parent:addChild(child2)

  -- Calculate expected end positioning
  local totalChildHeight = child1.height + child2.height + parent.gap
  local availableSpace = parent.height - totalChildHeight
  local startY = availableSpace

  luaunit.assertEquals(child1.y, parent.y + startY)
  luaunit.assertEquals(child2.y, child1.y + child1.height + parent.gap)
end

-- Test 8: Single child with center justification
function TestVerticalFlexDirection:testSingleChildVerticalLayoutCentered()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.CENTER,
    x = 20,
    y = 10,
    w = 100,
    h = 300,
  })

  local child = Gui.new({
    id = "single_child",
    w = 80,
    h = 50,
  })

  parent:addChild(child)

  -- Single child with center justification should be centered
  local expectedY = parent.y + (parent.height - child.height) / 2
  luaunit.assertEquals(child.y, expectedY)
  luaunit.assertEquals(child.x, parent.x)
end

-- Test 9: Vertical layout maintains child widths
function TestVerticalFlexDirection:testVerticalLayoutMaintainsChildWidths()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_START, -- Explicitly set to maintain child widths
    x = 0,
    y = 0,
    w = 100,
    h = 300,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 80,
    h = 50,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40, -- Different width
  })

  parent:addChild(child1)
  parent:addChild(child2)

  -- In vertical layout, child widths should be preserved
  luaunit.assertEquals(child1.width, 80)
  luaunit.assertEquals(child2.width, 60)
end

-- Test 10: Vertical layout with align-items center
function TestVerticalFlexDirection:testVerticalLayoutAlignItemsCenter()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.CENTER,
    x = 0,
    y = 0,
    w = 100,
    h = 300,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 80,
    h = 50,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
  })

  parent:addChild(child1)
  parent:addChild(child2)

  -- Children should be centered horizontally
  local expectedX1 = parent.x + (parent.width - child1.width) / 2
  local expectedX2 = parent.x + (parent.width - child2.width) / 2

  luaunit.assertEquals(child1.x, expectedX1)
  luaunit.assertEquals(child2.x, expectedX2)
end

-- Test 11: Vertical layout with align-items flex-end
function TestVerticalFlexDirection:testVerticalLayoutAlignItemsFlexEnd()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.FLEX_END,
    x = 0,
    y = 0,
    w = 100,
    h = 300,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 80,
    h = 50,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
  })

  parent:addChild(child1)
  parent:addChild(child2)

  -- Children should be aligned to the right
  local expectedX1 = parent.x + parent.width - child1.width
  local expectedX2 = parent.x + parent.width - child2.width

  luaunit.assertEquals(child1.x, expectedX1)
  luaunit.assertEquals(child2.x, expectedX2)
end

-- Test 12: Vertical layout with align-items stretch
function TestVerticalFlexDirection:testVerticalLayoutAlignItemsStretch()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    alignItems = AlignItems.STRETCH,
    x = 0,
    y = 0,
    w = 100,
    h = 300,
  })

  local child1 = Gui.new({
    id = "child1",
    w = 80,
    h = 50,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 60,
    h = 40,
  })

  parent:addChild(child1)
  parent:addChild(child2)

  -- Children should be stretched to fill parent width
  luaunit.assertEquals(child1.width, parent.width)
  luaunit.assertEquals(child2.width, parent.width)
end

-- Test 13: Vertical layout with space-between
function TestVerticalFlexDirection:testVerticalLayoutSpaceBetween()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    gap = 0, -- Space-between controls spacing, not gap
  })

  local child1 = Gui.new({
    id = "child1",
    w = 80,
    h = 50,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 70,
    h = 40,
  })

  local child3 = Gui.new({
    id = "child3",
    w = 60,
    h = 30,
  })

  parent:addChild(child1)
  parent:addChild(child2)
  parent:addChild(child3)

  -- First child should be at start
  luaunit.assertEquals(child1.y, parent.y)

  -- Last child should be at end
  luaunit.assertEquals(child3.y, parent.y + parent.height - child3.height)

  -- Middle child should be evenly spaced
  local remainingSpace = parent.height - child1.height - child2.height - child3.height
  local spaceBetween = remainingSpace / 2
  luaunit.assertEquals(child2.y, child1.y + child1.height + spaceBetween)
end

-- Test 14: Vertical layout with custom gap
function TestVerticalFlexDirection:testVerticalLayoutCustomGap()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    w = 100,
    h = 300,
    gap = 20, -- Custom gap
  })

  local child1 = Gui.new({
    id = "child1",
    w = 80,
    h = 50,
  })

  local child2 = Gui.new({
    id = "child2",
    w = 70,
    h = 40,
  })

  parent:addChild(child1)
  parent:addChild(child2)

  -- Children should be positioned with custom gap
  luaunit.assertEquals(child1.y, parent.y)
  luaunit.assertEquals(child2.y, child1.y + child1.height + 20)
end

-- Test 15: Vertical layout with positioning offset
function TestVerticalFlexDirection:testVerticalLayoutWithPositioningOffset()
  local parent = Gui.new({
    id = "vertical_parent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.CENTER,
    x = 50,
    y = 100,
    w = 100,
    h = 300,
  })

  local child = Gui.new({
    id = "single_child",
    w = 80,
    h = 50,
  })

  parent:addChild(child)

  -- Child should respect parent's position offset
  local expectedY = parent.y + (parent.height - child.height) / 2
  luaunit.assertEquals(child.x, parent.x)
  luaunit.assertEquals(child.y, expectedY)
end

-- Test 16: Complex vertical sidebar layout with nested sections
function TestVerticalFlexDirection:testComplexVerticalSidebarLayout()
  local sidebar = Gui.new({
    id = "sidebar",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    w = 300,
    h = 800,
    gap = 20,
  })

  -- Header section
  local header = Gui.new({
    id = "header",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 280,
    h = 120,
    gap = 10,
  })

  local logo = Gui.new({ id = "logo", w = 100, h = 40 })
  local userInfo = Gui.new({ id = "userInfo", w = 250, h = 60 })

  header:addChild(logo)
  header:addChild(userInfo)

  -- Navigation section with nested menus
  local navigation = Gui.new({
    id = "navigation",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 280,
    h = 400,
    gap = 5,
  })

  local mainMenu = Gui.new({
    id = "mainMenu",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 280,
    h = 200,
    gap = 2,
  })

  -- Create menu items
  for i = 1, 5 do
    local menuItem = Gui.new({
      id = "menuItem" .. i,
      w = 270,
      h = 35,
    })
    mainMenu:addChild(menuItem)
  end

  local subMenu = Gui.new({
    id = "subMenu",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 260,
    h = 180,
    gap = 3,
  })

  -- Create submenu items with indentation
  for i = 1, 4 do
    local subMenuItem = Gui.new({
      id = "subMenuItem" .. i,
      w = 240,
      h = 30,
    })
    subMenu:addChild(subMenuItem)
  end

  navigation:addChild(mainMenu)
  navigation:addChild(subMenu)

  -- Footer section
  local footer = Gui.new({
    id = "footer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_END,
    w = 280,
    h = 200,
    gap = 10,
  })

  local settings = Gui.new({ id = "settings", w = 200, h = 50 })
  local help = Gui.new({ id = "help", w = 180, h = 40 })
  local logout = Gui.new({ id = "logout", w = 120, h = 35 })

  footer:addChild(settings)
  footer:addChild(help)
  footer:addChild(logout)

  sidebar:addChild(header)
  sidebar:addChild(navigation)
  sidebar:addChild(footer)

  -- Verify complex nested positioning
  luaunit.assertEquals(header.y, sidebar.y)
  luaunit.assertEquals(navigation.y, header.y + header.height + sidebar.gap)
  luaunit.assertEquals(footer.y, navigation.y + navigation.height + sidebar.gap)

  -- Verify nested menu structure
  luaunit.assertEquals(logo.y, header.y)
  luaunit.assertEquals(userInfo.y, logo.y + logo.height + header.gap)

  -- Verify submenu positioning
  luaunit.assertEquals(subMenu.y, mainMenu.y + mainMenu.height + navigation.gap)
end

-- Test 17: Multi-level accordion/collapsible vertical layout
function TestVerticalFlexDirection:testMultiLevelAccordionLayout()
  local container = Gui.new({
    id = "accordionContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    w = 400,
    h = 600,
    gap = 5,
  })

  -- Create multiple accordion sections
  for sectionIndex = 1, 3 do
    local section = Gui.new({
      id = "section" .. sectionIndex,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      w = 380,
      h = 180,
      gap = 2,
    })

    local sectionHeader = Gui.new({
      id = "sectionHeader" .. sectionIndex,
      w = 380,
      h = 40,
    })

    local sectionContent = Gui.new({
      id = "sectionContent" .. sectionIndex,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      w = 360,
      h = 130,
      gap = 3,
    })

    -- Add subsections within each section
    for subIndex = 1, 3 do
      local subsection = Gui.new({
        id = "subsection" .. sectionIndex .. "_" .. subIndex,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        w = 340,
        h = 40,
        gap = 1,
      })

      local subHeader = Gui.new({
        id = "subHeader" .. sectionIndex .. "_" .. subIndex,
        w = 340,
        h = 20,
      })

      local subContent = Gui.new({
        id = "subContent" .. sectionIndex .. "_" .. subIndex,
        w = 320,
        h = 18,
      })

      subsection:addChild(subHeader)
      subsection:addChild(subContent)
      sectionContent:addChild(subsection)
    end

    section:addChild(sectionHeader)
    section:addChild(sectionContent)
    container:addChild(section)
  end

  -- Verify accordion structure
  local firstSection = container.children[1]
  local secondSection = container.children[2]
  local thirdSection = container.children[3]

  luaunit.assertEquals(firstSection.y, container.y)
  luaunit.assertEquals(secondSection.y, firstSection.y + firstSection.height + container.gap)
  luaunit.assertEquals(thirdSection.y, secondSection.y + secondSection.height + container.gap)

  -- Verify nested subsection positioning
  local firstSectionContent = firstSection.children[2]
  local firstSubsection = firstSectionContent.children[1]
  local secondSubsection = firstSectionContent.children[2]

  luaunit.assertEquals(firstSubsection.y, firstSectionContent.y)
  luaunit.assertEquals(secondSubsection.y, firstSubsection.y + firstSubsection.height + firstSectionContent.gap)
end

-- Test 18: Vertical chat/message thread layout
function TestVerticalFlexDirection:testVerticalChatMessageLayout()
  local chatContainer = Gui.new({
    id = "chatContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    justifyContent = JustifyContent.FLEX_END,
    x = 0,
    y = 0,
    w = 350,
    h = 500,
    gap = 8,
  })

  -- Create message threads with varying complexity
  local messageTypes = {
    { sender = "user", hasAvatar = true, hasReactions = false },
    { sender = "bot", hasAvatar = true, hasReactions = true },
    { sender = "user", hasAvatar = false, hasReactions = true },
    { sender = "system", hasAvatar = false, hasReactions = false },
  }

  for i, msgType in ipairs(messageTypes) do
    local messageGroup = Gui.new({
      id = "messageGroup" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      w = 330,
      h = msgType.hasReactions and 80 or 60,
      gap = 4,
    })

    local messageRow = Gui.new({
      id = "messageRow" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      w = 330,
      h = 40,
      gap = 8,
    })

    if msgType.hasAvatar then
      local avatar = Gui.new({
        id = "avatar" .. i,
        w = 32,
        h = 32,
      })
      messageRow:addChild(avatar)
    end

    local messageContent = Gui.new({
      id = "messageContent" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      w = msgType.hasAvatar and 290 or 330,
      h = 35,
      gap = 2,
    })

    local messageText = Gui.new({
      id = "messageText" .. i,
      w = msgType.hasAvatar and 280 or 320,
      h = 20,
    })

    local timestamp = Gui.new({
      id = "timestamp" .. i,
      w = 60,
      h = 12,
    })

    messageContent:addChild(messageText)
    messageContent:addChild(timestamp)
    messageRow:addChild(messageContent)
    messageGroup:addChild(messageRow)

    if msgType.hasReactions then
      local reactions = Gui.new({
        id = "reactions" .. i,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.HORIZONTAL,
        w = 150,
        h = 20,
        gap = 3,
      })

      -- Add reaction buttons
      for j = 1, 3 do
        local reaction = Gui.new({
          id = "reaction" .. i .. "_" .. j,
          w = 25,
          h = 18,
        })
        reactions:addChild(reaction)
      end

      messageGroup:addChild(reactions)
    end

    chatContainer:addChild(messageGroup)
  end

  -- Verify messages are positioned from bottom (flex-end)
  local lastMessage = chatContainer.children[#chatContainer.children]
  local expectedLastY = chatContainer.y + chatContainer.height - lastMessage.height

  -- Note: This test may fail if flex-end positioning isn't implemented correctly
  -- but demonstrates the expected CSS behavior
  luaunit.assertEquals(lastMessage.y + lastMessage.height, chatContainer.y + chatContainer.height)
end

-- Test 19: Nested form layout with sections and field groups
function TestVerticalFlexDirection:testNestedFormLayout()
  local form = Gui.new({
    id = "form",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    w = 500,
    h = 700,
    gap = 20,
  })

  -- Form header
  local formHeader = Gui.new({
    id = "formHeader",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 480,
    h = 80,
    gap = 10,
  })

  local title = Gui.new({ id = "title", w = 300, h = 30 })
  local description = Gui.new({ id = "description", w = 450, h = 40 })

  formHeader:addChild(title)
  formHeader:addChild(description)

  -- Personal information section
  local personalSection = Gui.new({
    id = "personalSection",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 480,
    h = 200,
    gap = 15,
  })

  local personalTitle = Gui.new({ id = "personalTitle", w = 200, h = 25 })
  personalSection:addChild(personalTitle)

  -- Field groups within personal section
  local nameGroup = Gui.new({
    id = "nameGroup",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 460,
    h = 80,
    gap = 8,
  })

  local nameLabel = Gui.new({ id = "nameLabel", w = 100, h = 20 })
  local nameInput = Gui.new({ id = "nameInput", w = 400, h = 35 })
  local nameError = Gui.new({ id = "nameError", w = 350, h = 15 })

  nameGroup:addChild(nameLabel)
  nameGroup:addChild(nameInput)
  nameGroup:addChild(nameError)

  local emailGroup = Gui.new({
    id = "emailGroup",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 460,
    h = 80,
    gap = 8,
  })

  local emailLabel = Gui.new({ id = "emailLabel", w = 100, h = 20 })
  local emailInput = Gui.new({ id = "emailInput", w = 400, h = 35 })
  local emailError = Gui.new({ id = "emailError", w = 350, h = 15 })

  emailGroup:addChild(emailLabel)
  emailGroup:addChild(emailInput)
  emailGroup:addChild(emailError)

  personalSection:addChild(nameGroup)
  personalSection:addChild(emailGroup)

  -- Address section with complex nested structure
  local addressSection = Gui.new({
    id = "addressSection",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 480,
    h = 300,
    gap = 15,
  })

  local addressTitle = Gui.new({ id = "addressTitle", w = 200, h = 25 })
  addressSection:addChild(addressTitle)

  -- Street address group
  local streetGroup = Gui.new({
    id = "streetGroup",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 460,
    h = 80,
    gap = 8,
  })

  local streetLabel = Gui.new({ id = "streetLabel", w = 120, h = 20 })
  local streetInput = Gui.new({ id = "streetInput", w = 400, h = 35 })
  local streetError = Gui.new({ id = "streetError", w = 350, h = 15 })

  streetGroup:addChild(streetLabel)
  streetGroup:addChild(streetInput)
  streetGroup:addChild(streetError)

  -- City/State/Zip compound group
  local locationGroup = Gui.new({
    id = "locationGroup",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 460,
    h = 120,
    gap = 8,
  })

  local locationLabel = Gui.new({ id = "locationLabel", w = 150, h = 20 })

  local locationInputs = Gui.new({
    id = "locationInputs",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    w = 450,
    h = 35,
    gap = 10,
  })

  local cityInput = Gui.new({ id = "cityInput", w = 200, h = 35 })
  local stateInput = Gui.new({ id = "stateInput", w = 100, h = 35 })
  local zipInput = Gui.new({ id = "zipInput", w = 120, h = 35 })

  locationInputs:addChild(cityInput)
  locationInputs:addChild(stateInput)
  locationInputs:addChild(zipInput)

  local locationErrors = Gui.new({
    id = "locationErrors",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 450,
    h = 45,
    gap = 3,
  })

  local cityError = Gui.new({ id = "cityError", w = 200, h = 12 })
  local stateError = Gui.new({ id = "stateError", w = 150, h = 12 })
  local zipError = Gui.new({ id = "zipError", w = 180, h = 12 })

  locationErrors:addChild(cityError)
  locationErrors:addChild(stateError)
  locationErrors:addChild(zipError)

  locationGroup:addChild(locationLabel)
  locationGroup:addChild(locationInputs)
  locationGroup:addChild(locationErrors)

  addressSection:addChild(streetGroup)
  addressSection:addChild(locationGroup)

  -- Form actions
  local formActions = Gui.new({
    id = "formActions",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.FLEX_END,
    w = 480,
    h = 50,
    gap = 15,
  })

  local cancelButton = Gui.new({ id = "cancelButton", w = 80, h = 40 })
  local submitButton = Gui.new({ id = "submitButton", w = 100, h = 40 })

  formActions:addChild(cancelButton)
  formActions:addChild(submitButton)

  form:addChild(formHeader)
  form:addChild(personalSection)
  form:addChild(addressSection)
  form:addChild(formActions)

  -- Verify complex form structure
  luaunit.assertEquals(formHeader.y, form.y)
  luaunit.assertEquals(personalSection.y, formHeader.y + formHeader.height + form.gap)
  luaunit.assertEquals(addressSection.y, personalSection.y + personalSection.height + form.gap)
  luaunit.assertEquals(formActions.y, addressSection.y + addressSection.height + form.gap)

  -- Verify nested field group positioning
  luaunit.assertEquals(nameGroup.y, personalTitle.y + personalTitle.height + personalSection.gap)
  luaunit.assertEquals(emailGroup.y, nameGroup.y + nameGroup.height + personalSection.gap)

  -- Verify triple-nested error positioning
  luaunit.assertEquals(cityError.y, locationErrors.y)
  luaunit.assertEquals(stateError.y, cityError.y + cityError.height + locationErrors.gap)
  luaunit.assertEquals(zipError.y, stateError.y + stateError.height + locationErrors.gap)
end

-- Test 20: Calendar/timeline vertical layout with nested events
function TestVerticalFlexDirection:testCalendarTimelineLayout()
  local timeline = Gui.new({
    id = "timeline",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    w = 600,
    h = 800,
    gap = 10,
  })

  -- Create days with events
  local daysOfWeek = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday" }

  for dayIndex, dayName in ipairs(daysOfWeek) do
    local dayContainer = Gui.new({
      id = "day" .. dayIndex,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      w = 580,
      h = 140,
      gap = 8,
    })

    local dayHeader = Gui.new({
      id = "dayHeader" .. dayIndex,
      w = 580,
      h = 30,
    })

    local eventsContainer = Gui.new({
      id = "eventsContainer" .. dayIndex,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      w = 560,
      h = 100,
      gap = 5,
    })

    -- Add events for each day (varying number)
    local eventCount = math.min(dayIndex + 1, 4) -- 2-4 events per day

    for eventIndex = 1, eventCount do
      local eventItem = Gui.new({
        id = "event" .. dayIndex .. "_" .. eventIndex,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        w = 540,
        h = 20,
        gap = 2,
      })

      local eventTime = Gui.new({
        id = "eventTime" .. dayIndex .. "_" .. eventIndex,
        w = 80,
        h = 12,
      })

      local eventTitle = Gui.new({
        id = "eventTitle" .. dayIndex .. "_" .. eventIndex,
        w = 400,
        h = 15,
      })

      -- Some events have additional details
      if eventIndex % 2 == 0 then
        local eventDetails = Gui.new({
          id = "eventDetails" .. dayIndex .. "_" .. eventIndex,
          positioning = Positioning.FLEX,
          flexDirection = FlexDirection.VERTICAL,
          w = 380,
          h = 25,
          gap = 2,
        })

        local eventLocation = Gui.new({
          id = "eventLocation" .. dayIndex .. "_" .. eventIndex,
          w = 200,
          h = 10,
        })

        local eventAttendees = Gui.new({
          id = "eventAttendees" .. dayIndex .. "_" .. eventIndex,
          w = 300,
          h = 10,
        })

        eventDetails:addChild(eventLocation)
        eventDetails:addChild(eventAttendees)

        eventItem:addChild(eventTime)
        eventItem:addChild(eventTitle)
        eventItem:addChild(eventDetails)
        eventItem.height = 40 -- Adjust height for detailed events
        eventItem.units.height = { value = 40, unit = "px" } -- Keep units in sync
      else
        eventItem:addChild(eventTime)
        eventItem:addChild(eventTitle)
      end

      eventsContainer:addChild(eventItem)
    end

    dayContainer:addChild(dayHeader)
    dayContainer:addChild(eventsContainer)
    timeline:addChild(dayContainer)
  end

  -- Verify timeline structure
  local firstDay = timeline.children[1]
  local secondDay = timeline.children[2]
  local thirdDay = timeline.children[3]

  luaunit.assertEquals(firstDay.y, timeline.y)
  luaunit.assertEquals(secondDay.y, firstDay.y + firstDay.height + timeline.gap)
  luaunit.assertEquals(thirdDay.y, secondDay.y + secondDay.height + timeline.gap)

  -- Verify nested event positioning within first day
  local firstDayEvents = firstDay.children[2] -- eventsContainer
  local firstEvent = firstDayEvents.children[1]
  local secondEvent = firstDayEvents.children[2]

  luaunit.assertEquals(firstEvent.y, firstDayEvents.y)
  luaunit.assertEquals(secondEvent.y, firstEvent.y + firstEvent.height + firstDayEvents.gap)
end

-- Test 21: Complex dashboard widget layout
function TestVerticalFlexDirection:testComplexDashboardWidgetLayout()
  local dashboard = Gui.new({
    id = "dashboard",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    w = 800,
    h = 1000,
    gap = 25,
  })

  -- Dashboard header with breadcrumbs
  local dashboardHeader = Gui.new({
    id = "dashboardHeader",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 780,
    h = 100,
    gap = 12,
  })

  local breadcrumbs = Gui.new({
    id = "breadcrumbs",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    w = 400,
    h = 20,
    gap = 8,
  })

  for i = 1, 4 do
    local crumb = Gui.new({
      id = "crumb" .. i,
      w = 80,
      h = 18,
    })
    breadcrumbs:addChild(crumb)
  end

  local pageTitle = Gui.new({ id = "pageTitle", w = 300, h = 40 })
  local pageActions = Gui.new({
    id = "pageActions",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    w = 250,
    h = 30,
    gap = 10,
  })

  local refreshButton = Gui.new({ id = "refreshButton", w = 70, h = 28 })
  local exportButton = Gui.new({ id = "exportButton", w = 80, h = 28 })
  local settingsButton = Gui.new({ id = "settingsButton", w = 75, h = 28 })

  pageActions:addChild(refreshButton)
  pageActions:addChild(exportButton)
  pageActions:addChild(settingsButton)

  dashboardHeader:addChild(breadcrumbs)
  dashboardHeader:addChild(pageTitle)
  dashboardHeader:addChild(pageActions)

  -- Widget grid rows (simulated as vertical sections)
  local topWidgetRow = Gui.new({
    id = "topWidgetRow",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    w = 780,
    h = 250,
    gap = 20,
  })

  -- Metric widgets
  for i = 1, 3 do
    local metricWidget = Gui.new({
      id = "metricWidget" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      w = 240,
      h = 240,
      gap = 10,
    })

    local widgetHeader = Gui.new({
      id = "widgetHeader" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      w = 220,
      h = 30,
      gap = 5,
    })

    local widgetTitle = Gui.new({ id = "widgetTitle" .. i, w = 150, h = 25 })
    local widgetMenu = Gui.new({ id = "widgetMenu" .. i, w = 20, h = 20 })

    widgetHeader:addChild(widgetTitle)
    widgetHeader:addChild(widgetMenu)

    local widgetContent = Gui.new({
      id = "widgetContent" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      justifyContent = JustifyContent.CENTER,
      alignItems = AlignItems.CENTER,
      w = 220,
      h = 150,
      gap = 8,
    })

    local metricValue = Gui.new({ id = "metricValue" .. i, w = 120, h = 50 })
    local metricLabel = Gui.new({ id = "metricLabel" .. i, w = 100, h = 20 })
    local metricTrend = Gui.new({ id = "metricTrend" .. i, w = 80, h = 15 })

    widgetContent:addChild(metricValue)
    widgetContent:addChild(metricLabel)
    widgetContent:addChild(metricTrend)

    local widgetFooter = Gui.new({
      id = "widgetFooter" .. i,
      w = 220,
      h = 25,
    })

    metricWidget:addChild(widgetHeader)
    metricWidget:addChild(widgetContent)
    metricWidget:addChild(widgetFooter)

    topWidgetRow:addChild(metricWidget)
  end

  -- Chart widget section
  local chartSection = Gui.new({
    id = "chartSection",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 780,
    h = 400,
    gap = 15,
  })

  local chartHeader = Gui.new({
    id = "chartHeader",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    w = 760,
    h = 40,
    gap = 10,
  })

  local chartTitle = Gui.new({ id = "chartTitle", w = 200, h = 35 })
  local chartControls = Gui.new({
    id = "chartControls",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    w = 300,
    h = 35,
    gap = 8,
  })

  local timeRangeSelect = Gui.new({ id = "timeRangeSelect", w = 120, h = 30 })
  local chartTypeSelect = Gui.new({ id = "chartTypeSelect", w = 100, h = 30 })
  local fullscreenButton = Gui.new({ id = "fullscreenButton", w = 60, h = 30 })

  chartControls:addChild(timeRangeSelect)
  chartControls:addChild(chartTypeSelect)
  chartControls:addChild(fullscreenButton)

  chartHeader:addChild(chartTitle)
  chartHeader:addChild(chartControls)

  local chartArea = Gui.new({ id = "chartArea", w = 760, h = 300 })

  local chartLegend = Gui.new({
    id = "chartLegend",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    w = 600,
    h = 30,
    gap = 15,
  })

  for i = 1, 4 do
    local legendItem = Gui.new({
      id = "legendItem" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      w = 120,
      h = 25,
      gap = 5,
    })

    local legendColor = Gui.new({ id = "legendColor" .. i, w = 15, h = 15 })
    local legendLabel = Gui.new({ id = "legendLabel" .. i, w = 95, h = 20 })

    legendItem:addChild(legendColor)
    legendItem:addChild(legendLabel)
    chartLegend:addChild(legendItem)
  end

  chartSection:addChild(chartHeader)
  chartSection:addChild(chartArea)
  chartSection:addChild(chartLegend)

  -- Table widget section
  local tableSection = Gui.new({
    id = "tableSection",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 780,
    h = 300,
    gap = 10,
  })

  local tableHeader = Gui.new({
    id = "tableHeader",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    w = 760,
    h = 35,
  })

  local tableTitle = Gui.new({ id = "tableTitle", w = 200, h = 30 })
  local tableSearch = Gui.new({ id = "tableSearch", w = 250, h = 30 })

  tableHeader:addChild(tableTitle)
  tableHeader:addChild(tableSearch)

  local tableContent = Gui.new({
    id = "tableContent",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 760,
    h = 200,
    gap = 2,
  })

  local tableHeaderRow = Gui.new({ id = "tableHeaderRow", w = 760, h = 35 })
  tableContent:addChild(tableHeaderRow)

  -- Table rows
  for i = 1, 6 do
    local tableRow = Gui.new({
      id = "tableRow" .. i,
      w = 760,
      h = 25,
    })
    tableContent:addChild(tableRow)
  end

  local tablePagination = Gui.new({
    id = "tablePagination",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.CENTER,
    w = 300,
    h = 40,
    gap = 5,
  })

  for i = 1, 5 do
    local pageButton = Gui.new({
      id = "pageButton" .. i,
      w = 30,
      h = 30,
    })
    tablePagination:addChild(pageButton)
  end

  tableSection:addChild(tableHeader)
  tableSection:addChild(tableContent)
  tableSection:addChild(tablePagination)

  dashboard:addChild(dashboardHeader)
  dashboard:addChild(topWidgetRow)
  dashboard:addChild(chartSection)
  dashboard:addChild(tableSection)

  -- Verify complex dashboard structure
  luaunit.assertEquals(dashboardHeader.y, dashboard.y)
  luaunit.assertEquals(topWidgetRow.y, dashboardHeader.y + dashboardHeader.height + dashboard.gap)
  luaunit.assertEquals(chartSection.y, topWidgetRow.y + topWidgetRow.height + dashboard.gap)
  luaunit.assertEquals(tableSection.y, chartSection.y + chartSection.height + dashboard.gap)

  -- Verify nested widget structure
  local firstWidget = topWidgetRow.children[1]
  local widgetHeader = firstWidget.children[1]
  local widgetContent = firstWidget.children[2]
  local widgetFooter = firstWidget.children[3]

  luaunit.assertEquals(widgetHeader.y, firstWidget.y)
  luaunit.assertEquals(widgetContent.y, widgetHeader.y + widgetHeader.height + firstWidget.gap)
  luaunit.assertEquals(widgetFooter.y, widgetContent.y + widgetContent.height + firstWidget.gap)

  -- Verify chart legend item structure
  local firstLegendItem = chartLegend.children[1]
  local legendColor = firstLegendItem.children[1]
  local legendLabel = firstLegendItem.children[2]

  luaunit.assertEquals(legendColor.x, firstLegendItem.x)
  luaunit.assertEquals(legendLabel.x, legendColor.x + legendColor.width + firstLegendItem.gap)
end

-- Test 22: Mobile-style vertical stack with pull-to-refresh and infinite scroll
function TestVerticalFlexDirection:testMobileVerticalStackLayout()
  local mobileContainer = Gui.new({
    id = "mobileContainer",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    x = 0,
    y = 0,
    w = 375, -- iPhone-style width
    h = 812, -- iPhone-style height
    gap = 0,
  })

  -- Status bar
  local statusBar = Gui.new({
    id = "statusBar",
    w = 375,
    h = 44,
  })

  -- Header with pull-to-refresh area
  local header = Gui.new({
    id = "header",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 375,
    h = 100,
    gap = 5,
  })

  local pullToRefresh = Gui.new({
    id = "pullToRefresh",
    w = 375,
    h = 30,
  })

  local navigationBar = Gui.new({
    id = "navigationBar",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_BETWEEN,
    alignItems = AlignItems.CENTER,
    w = 375,
    h = 60,
    gap = 10,
  })

  local backButton = Gui.new({ id = "backButton", w = 40, h = 40 })
  local headerTitle = Gui.new({ id = "headerTitle", w = 200, h = 35 })
  local moreButton = Gui.new({ id = "moreButton", w = 40, h = 40 })

  navigationBar:addChild(backButton)
  navigationBar:addChild(headerTitle)
  navigationBar:addChild(moreButton)

  header:addChild(pullToRefresh)
  header:addChild(navigationBar)

  -- Content area with scrollable list
  local contentArea = Gui.new({
    id = "contentArea",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.VERTICAL,
    w = 375,
    h = 600,
    gap = 1,
  })

  -- Feed items with varying complexity
  for i = 1, 8 do
    local feedItem = Gui.new({
      id = "feedItem" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      w = 365,
      h = i % 3 == 0 and 200 or 120, -- Some items are taller
      gap = 8,
    })

    local itemHeader = Gui.new({
      id = "itemHeader" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      alignItems = AlignItems.CENTER,
      w = 355,
      h = 50,
      gap = 12,
    })

    local avatar = Gui.new({ id = "avatar" .. i, w = 40, h = 40 })

    local userInfo = Gui.new({
      id = "userInfo" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      w = 200,
      h = 40,
      gap = 3,
    })

    local username = Gui.new({ id = "username" .. i, w = 150, h = 18 })
    local timestamp = Gui.new({ id = "timestamp" .. i, w = 100, h = 14 })

    userInfo:addChild(username)
    userInfo:addChild(timestamp)

    local itemMenu = Gui.new({ id = "itemMenu" .. i, w = 30, h = 30 })

    itemHeader:addChild(avatar)
    itemHeader:addChild(userInfo)
    itemHeader:addChild(itemMenu)

    local itemContent = Gui.new({
      id = "itemContent" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      w = 355,
      h = feedItem.height - 50 - 8, -- Remaining height after header
      gap = 5,
    })

    local textContent = Gui.new({
      id = "textContent" .. i,
      w = 345,
      h = 25,
    })

    itemContent:addChild(textContent)

    -- Some items have media
    if i % 3 == 0 then
      local mediaContainer = Gui.new({
        id = "mediaContainer" .. i,
        positioning = Positioning.FLEX,
        flexDirection = FlexDirection.VERTICAL,
        w = 345,
        h = 100,
        gap = 3,
      })

      local media = Gui.new({ id = "media" .. i, w = 345, h = 80 })
      local mediaCaption = Gui.new({ id = "mediaCaption" .. i, w = 300, h = 15 })

      mediaContainer:addChild(media)
      mediaContainer:addChild(mediaCaption)
      itemContent:addChild(mediaContainer)
    end

    -- Interaction bar
    local interactionBar = Gui.new({
      id = "interactionBar" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      justifyContent = JustifyContent.SPACE_BETWEEN,
      alignItems = AlignItems.CENTER,
      w = 345,
      h = 40,
      gap = 15,
    })

    local leftActions = Gui.new({
      id = "leftActions" .. i,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.HORIZONTAL,
      w = 150,
      h = 35,
      gap = 20,
    })

    local likeButton = Gui.new({ id = "likeButton" .. i, w = 35, h = 30 })
    local commentButton = Gui.new({ id = "commentButton" .. i, w = 35, h = 30 })
    local shareButton = Gui.new({ id = "shareButton" .. i, w = 35, h = 30 })

    leftActions:addChild(likeButton)
    leftActions:addChild(commentButton)
    leftActions:addChild(shareButton)

    local saveButton = Gui.new({ id = "saveButton" .. i, w = 35, h = 30 })

    interactionBar:addChild(leftActions)
    interactionBar:addChild(saveButton)

    itemContent:addChild(interactionBar)

    feedItem:addChild(itemHeader)
    feedItem:addChild(itemContent)
    contentArea:addChild(feedItem)
  end

  -- Bottom tab bar
  local tabBar = Gui.new({
    id = "tabBar",
    positioning = Positioning.FLEX,
    flexDirection = FlexDirection.HORIZONTAL,
    justifyContent = JustifyContent.SPACE_AROUND,
    alignItems = AlignItems.CENTER,
    w = 375,
    h = 83, -- Includes safe area
    gap = 0,
  })

  local tabItems = { "home", "search", "create", "activity", "profile" }
  for i, tabName in ipairs(tabItems) do
    local tab = Gui.new({
      id = "tab" .. tabName,
      positioning = Positioning.FLEX,
      flexDirection = FlexDirection.VERTICAL,
      alignItems = AlignItems.CENTER,
      w = 60,
      h = 60,
      gap = 3,
    })

    local tabIcon = Gui.new({ id = "tabIcon" .. tabName, w = 24, h = 24 })
    local tabLabel = Gui.new({ id = "tabLabel" .. tabName, w = 50, h = 12 })

    tab:addChild(tabIcon)
    tab:addChild(tabLabel)
    tabBar:addChild(tab)
  end

  mobileContainer:addChild(statusBar)
  mobileContainer:addChild(header)
  mobileContainer:addChild(contentArea)
  mobileContainer:addChild(tabBar)

  -- Verify mobile layout structure
  luaunit.assertEquals(statusBar.y, mobileContainer.y)
  luaunit.assertEquals(header.y, statusBar.y + statusBar.height)
  luaunit.assertEquals(contentArea.y, header.y + header.height)
  luaunit.assertEquals(tabBar.y, contentArea.y + contentArea.height)

  -- Verify feed item structure
  local firstFeedItem = contentArea.children[1]
  local secondFeedItem = contentArea.children[2]

  luaunit.assertEquals(firstFeedItem.y, contentArea.y)
  luaunit.assertEquals(secondFeedItem.y, firstFeedItem.y + firstFeedItem.height + contentArea.gap)

  -- Verify nested interaction structure
  local itemHeader = firstFeedItem.children[1]
  local itemContent = firstFeedItem.children[2]
  local interactionBar = itemContent.children[#itemContent.children] -- Last child

  luaunit.assertEquals(itemHeader.y, firstFeedItem.y)
  luaunit.assertEquals(itemContent.y, itemHeader.y + itemHeader.height + firstFeedItem.gap)

  -- Verify tab structure
  local firstTab = tabBar.children[1]
  local tabIcon = firstTab.children[1]
  local tabLabel = firstTab.children[2]

  luaunit.assertEquals(tabIcon.y, firstTab.y)
  luaunit.assertEquals(tabLabel.y, tabIcon.y + tabIcon.height + firstTab.gap)
end

-- Run the tests
luaunit.LuaUnit.run()
