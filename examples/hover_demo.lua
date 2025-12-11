-- Example demonstrating hover and unhover events in FlexLöve
-- This shows how to use the new hover/unhover events for interactive UI elements

local FlexLove = require("FlexLove")

function love.load()
  FlexLove.init({
    baseScale = { width = 1920, height = 1080 },
    immediateMode = true,
    autoFrameManagement = false,
  })
end

-- State to track hover status
local hoverStatus = "Not hovering"
local hoverCount = 0
local unhoverCount = 0
local lastEventTime = 0

function love.update(dt)
  FlexLove.beginFrame()

  -- Create a container
  FlexLove.new({
    width = "100vw",
    height = "100vh",
    backgroundColor = FlexLove.Color.fromHex("#1a1a2e"),
    positioning = "flex",
    flexDirection = "vertical",
    justifyContent = "center",
    alignItems = "center",
    gap = 30,
  })

  -- Title
  FlexLove.new({
    text = "Hover Event Demo",
    textSize = "4xl",
    textColor = FlexLove.Color.fromHex("#ffffff"),
  })

  -- Instructions
  FlexLove.new({
    text = "Move your mouse over the boxes below to see hover events",
    textSize = "lg",
    textColor = FlexLove.Color.fromHex("#a0a0a0"),
  })

  -- Status display
  FlexLove.new({
    text = hoverStatus,
    textSize = "xl",
    textColor = FlexLove.Color.fromHex("#4ecca3"),
    padding = 20,
  })

  -- Event counters
  FlexLove.new({
    text = string.format("Hover events: %d | Unhover events: %d", hoverCount, unhoverCount),
    textSize = "md",
    textColor = FlexLove.Color.fromHex("#ffffff"),
  })

  -- Container for hover boxes
  local boxContainer = FlexLove.new({
    positioning = "flex",
    flexDirection = "horizontal",
    gap = 30,
  })

  -- Hover Box 1
  FlexLove.new({
    parent = boxContainer,
    width = 200,
    height = 200,
    backgroundColor = FlexLove.Color.fromHex("#e94560"),
    cornerRadius = 15,
    positioning = "flex",
    justifyContent = "center",
    alignItems = "center",
    text = "Hover Me!",
    textSize = "xl",
    textColor = FlexLove.Color.fromHex("#ffffff"),
    onEvent = function(element, event)
      if event.type == "hover" then
        hoverStatus = "Hovering over RED box!"
        hoverCount = hoverCount + 1
        lastEventTime = love.timer.getTime()
      elseif event.type == "unhover" then
        hoverStatus = "Left RED box"
        unhoverCount = unhoverCount + 1
        lastEventTime = love.timer.getTime()
      elseif event.type == "click" then
        print("Clicked RED box!")
      end
    end,
  })

  -- Hover Box 2
  FlexLove.new({
    parent = boxContainer,
    width = 200,
    height = 200,
    backgroundColor = FlexLove.Color.fromHex("#4ecca3"),
    cornerRadius = 15,
    positioning = "flex",
    justifyContent = "center",
    alignItems = "center",
    text = "Hover Me!",
    textSize = "xl",
    textColor = FlexLove.Color.fromHex("#1a1a2e"),
    onEvent = function(element, event)
      if event.type == "hover" then
        hoverStatus = "Hovering over GREEN box!"
        hoverCount = hoverCount + 1
        lastEventTime = love.timer.getTime()
      elseif event.type == "unhover" then
        hoverStatus = "Left GREEN box"
        unhoverCount = unhoverCount + 1
        lastEventTime = love.timer.getTime()
      elseif event.type == "click" then
        print("Clicked GREEN box!")
      end
    end,
  })

  -- Hover Box 3
  FlexLove.new({
    parent = boxContainer,
    width = 200,
    height = 200,
    backgroundColor = FlexLove.Color.fromHex("#0f3460"),
    cornerRadius = 15,
    positioning = "flex",
    justifyContent = "center",
    alignItems = "center",
    text = "Hover Me!",
    textSize = "xl",
    textColor = FlexLove.Color.fromHex("#ffffff"),
    onEvent = function(element, event)
      if event.type == "hover" then
        hoverStatus = "Hovering over BLUE box!"
        hoverCount = hoverCount + 1
        lastEventTime = love.timer.getTime()
      elseif event.type == "unhover" then
        hoverStatus = "Left BLUE box"
        unhoverCount = unhoverCount + 1
        lastEventTime = love.timer.getTime()
      elseif event.type == "click" then
        print("Clicked BLUE box!")
      end
    end,
  })

  -- Reset button
  FlexLove.new({
    width = 200,
    height = 50,
    backgroundColor = FlexLove.Color.fromHex("#e94560"),
    cornerRadius = 25,
    positioning = "flex",
    justifyContent = "center",
    alignItems = "center",
    text = "Reset Counters",
    textSize = "md",
    textColor = FlexLove.Color.fromHex("#ffffff"),
    margin = { top = 30 },
    onEvent = function(element, event)
      if event.type == "click" then
        hoverCount = 0
        unhoverCount = 0
        hoverStatus = "Counters reset!"
      end
    end,
  })

  FlexLove.endFrame()
end

function love.draw()
  FlexLove.draw()
end

function love.resize(w, h)
  FlexLove.resize(w, h)
end
