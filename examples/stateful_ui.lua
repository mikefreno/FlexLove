-- Example: Stateful Interactive UI
-- This demonstrates how to create interactive UI elements with state management

local FlexLove = require("libs.FlexLove")

local StatefulUIExample = {}

function StatefulUIExample:new()
  local obj = {
    -- State variables for the example
    counter = 0,
    isToggled = false,
    inputValue = "",
    selectedOption = "option1",
  }
  setmetatable(obj, { __index = self })
  return obj
end

function StatefulUIExample:render()
  local flex = FlexLove.new({
    x = "10%",
    y = "10%",
    width = "80%",
    height = "80%",
    positioning = "flex",
    flexDirection = "vertical",
    gap = 10,
    padding = { horizontal = 10, vertical = 10 },
  })

  -- Title
  FlexLove.new({
    parent = flex,
    text = "Stateful Interactive UI Example",
    textAlign = "center",
    textSize = "2xl",
    width = "100%",
    height = "10%",
  })

  -- Counter section
  local counterSection = FlexLove.new({
    parent = flex,
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "space-between",
    alignItems = "center",
    width = "100%",
    height = "20%",
    backgroundColor = "#2d3748",
    borderRadius = 8,
    padding = { horizontal = 15 },
  })

  FlexLove.new({
    parent = counterSection,
    text = "Counter: " .. self.counter,
    textAlign = "left",
    textSize = "lg",
    width = "40%",
  })

  -- Increment button
  FlexLove.new({
    parent = counterSection,
    themeComponent = "buttonv2",
    text = "Increment",
    textAlign = "center",
    width = "25%",
    onEvent = function(_, event)
      if event.type == "release" then
        self.counter = self.counter + 1
        print("Counter incremented to: " .. self.counter)
      end
    end,
  })

  -- Reset button
  FlexLove.new({
    parent = counterSection,
    themeComponent = "buttonv2",
    text = "Reset",
    textAlign = "center",
    width = "25%",
    onEvent = function(_, event)
      if event.type == "release" then
        self.counter = 0
        print("Counter reset to: " .. self.counter)
      end
    end,
  })

  -- Toggle switch section
  local toggleSection = FlexLove.new({
    parent = flex,
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "space-between",
    alignItems = "center",
    width = "100%",
    height = "20%",
    backgroundColor = "#4a5568",
    borderRadius = 8,
    padding = { horizontal = 15 },
  })

  FlexLove.new({
    parent = toggleSection,
    text = "Toggle Switch: " .. tostring(self.isToggled),
    textAlign = "left",
    textSize = "lg",
    width = "40%",
  })

  -- Toggle button
  local toggleButton = FlexLove.new({
    parent = toggleSection,
    positioning = "flex",
    width = 60,
    height = 30,
    backgroundColor = self.isToggled and "#48bb78" or "#a0aec0", -- Green when on, gray when off
    borderRadius = 15,
    padding = { horizontal = 5 },
  })

  FlexLove.new({
    parent = toggleButton,
    text = self.isToggled and "ON" or "OFF",
    textAlign = "center",
    textSize = "sm",
    width = "100%",
    height = "100%",
    color = "#ffffff", -- White text
  })

  -- Toggle event handler
  toggleButton.onEvent = function(_, event)
    if event.type == "release" then
      self.isToggled = not self.isToggled
      print("Toggle switched to: " .. tostring(self.isToggled))
      -- This would normally update the visual state, but we'll do it manually for this example
    end
  end

  -- Input section
  local inputSection = FlexLove.new({
    parent = flex,
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "space-between",
    alignItems = "center",
    width = "100%",
    height = "20%",
    backgroundColor = "#2d3748",
    borderRadius = 8,
    padding = { horizontal = 15 },
  })

  FlexLove.new({
    parent = inputSection,
    text = "Input Value:",
    textAlign = "left",
    textSize = "lg",
    width = "30%",
  })

  FlexLove.new({
    parent = inputSection,
    themeComponent = "inputv2",
    text = self.inputValue,
    textAlign = "left",
    textSize = "md",
    width = "50%",
    onEvent = function(_, event)
      if event.type == "textinput" then
        self.inputValue = event.text
        print("Input value changed to: " .. self.inputValue)
      end
    end,
  })

  -- Dropdown section
  local dropdownSection = FlexLove.new({
    parent = flex,
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "space-between",
    alignItems = "center",
    width = "100%",
    height = "20%",
    backgroundColor = "#4a5568",
    borderRadius = 8,
    padding = { horizontal = 15 },
  })

  FlexLove.new({
    parent = dropdownSection,
    text = "Selected Option:",
    textAlign = "left",
    textSize = "lg",
    width = "30%",
  })

  FlexLove.new({
    parent = dropdownSection,
    themeComponent = "dropdownv2",
    text = self.selectedOption,
    textAlign = "left",
    textSize = "md",
    width = "50%",
    options = { "option1", "option2", "option3" },
    onEvent = function(_, event)
      if event.type == "select" then
        self.selectedOption = event.value
        print("Selected option changed to: " .. self.selectedOption)
      end
    end,
  })

  -- Status indicator at the bottom
  local statusIndicator = FlexLove.new({
    parent = flex,
    positioning = "flex",
    flexDirection = "horizontal",
    justifyContent = "space-between",
    alignItems = "center",
    width = "100%",
    height = "10%",
    backgroundColor = "#2d3748",
    borderRadius = 8,
    padding = { horizontal = 15 },
  })

  FlexLove.new({
    parent = statusIndicator,
    text = "Current State - Counter: " .. self.counter .. ", Toggle: " .. tostring(self.isToggled),
    textAlign = "left",
    textSize = "sm",
    width = "70%",
  })

  return flex
end

return StatefulUIExample

