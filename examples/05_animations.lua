--[[
  FlexLove Example 05: Animations
  
  This example demonstrates animation system in FlexLove:
  - Fade animations
  - Scale animations
  - Custom animations with different easing functions
  - Animation timing and interpolation
  
  Run with: love /path/to/libs/examples/05_animations.lua
]]

local Lv = love

local FlexLove = require("../FlexLove")
local Gui = FlexLove.Gui
local Color = FlexLove.Color
local Animation = FlexLove.Animation
local enums = FlexLove.enums

-- Animation control variables
local fadeBox, scaleBox, easingBoxes

function Lv.load()
  Gui.init({
    baseScale = { width = 1920, height = 1080 }
  })
  
  -- Title
  Gui.new({
    x = "2vw",
    y = "2vh",
    width = "96vw",
    height = "6vh",
    text = "FlexLove Example 05: Animations",
    textSize = "4vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
  })
  
  -- ========================================
  -- Section 1: Fade Animation
  -- ========================================
  
  Gui.new({
    x = "2vw",
    y = "10vh",
    width = "46vw",
    height = "3vh",
    text = "Fade Animation - Click to trigger",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  fadeBox = Gui.new({
    x = "2vw",
    y = "14vh",
    width = "46vw",
    height = "20vh",
    backgroundColor = Color.new(0.3, 0.6, 0.9, 1),
    text = "Click me to fade out and back in",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 10,
    callback = function(element, event)
      if event.type == "click" then
        -- Fade out then fade in
        local fadeOut = Animation.fade(1.0, 1.0, 0.0)
        fadeOut.easing = function(t) return t * t end -- easeInQuad
        element.animation = fadeOut
        
        -- Queue fade in after fade out completes
        local startTime = Lv.timer.getTime()
        element._fadeCallback = function(el, dt)
          if Lv.timer.getTime() - startTime >= 1.0 then
            local fadeIn = Animation.fade(1.0, 0.0, 1.0)
            fadeIn.easing = function(t) return t * (2 - t) end -- easeOutQuad
            el.animation = fadeIn
            el._fadeCallback = nil
          end
        end
      end
    end,
  })
  
  -- ========================================
  -- Section 2: Scale Animation
  -- ========================================
  
  Gui.new({
    x = "50vw",
    y = "10vh",
    width = "48vw",
    height = "3vh",
    text = "Scale Animation - Click to trigger",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  scaleBox = Gui.new({
    x = "50vw",
    y = "14vh",
    width = 400,
    height = 200,
    backgroundColor = Color.new(0.9, 0.4, 0.4, 1),
    text = "Click me to scale up",
    textSize = "2vh",
    textColor = Color.new(1, 1, 1, 1),
    textAlign = enums.TextAlign.CENTER,
    cornerRadius = 10,
    callback = function(element, event)
      if event.type == "click" then
        -- Scale up
        local scaleUp = Animation.scale(
          0.5,
          { width = element.width, height = element.height },
          { width = element.width * 1.5, height = element.height * 1.5 }
        )
        scaleUp.easing = function(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end -- easeInOutQuad
        element.animation = scaleUp
        
        -- Queue scale down
        local startTime = Lv.timer.getTime()
        element._scaleCallback = function(el, dt)
          if Lv.timer.getTime() - startTime >= 0.5 then
            local scaleDown = Animation.scale(
              0.5,
              { width = el.width, height = el.height },
              { width = 400, height = 200 }
            )
            scaleDown.easing = function(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end
            el.animation = scaleDown
            el._scaleCallback = nil
          end
        end
      end
    end,
  })
  
  -- ========================================
  -- Section 3: Easing Functions Comparison
  -- ========================================
  
  Gui.new({
    x = "2vw",
    y = "36vh",
    width = "96vw",
    height = "3vh",
    text = "Easing Functions - Click any box to see different easing",
    textSize = "2.5vh",
    textColor = Color.new(0.9, 0.9, 0.9, 1),
  })
  
  local easingContainer = Gui.new({
    x = "2vw",
    y = "40vh",
    width = "96vw",
    height = "56vh",
    positioning = enums.Positioning.GRID,
    gridRows = 3,
    gridColumns = 3,
    rowGap = "2vh",
    columnGap = "2vw",
    backgroundColor = Color.new(0.08, 0.08, 0.12, 1),
    border = { top = true, right = true, bottom = true, left = true },
    borderColor = Color.new(0.25, 0.25, 0.35, 1),
    padding = { top = 20, right = 20, bottom = 20, left = 20 },
  })
  
  -- Different easing functions
  local easings = {
    { name = "Linear", func = function(t) return t end },
    { name = "EaseInQuad", func = function(t) return t * t end },
    { name = "EaseOutQuad", func = function(t) return t * (2 - t) end },
    { name = "EaseInOutQuad", func = function(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end },
    { name = "EaseInCubic", func = function(t) return t * t * t end },
    { name = "EaseOutCubic", func = function(t) local t1 = t - 1; return t1 * t1 * t1 + 1 end },
    { name = "EaseInQuart", func = function(t) return t * t * t * t end },
    { name = "EaseOutQuart", func = function(t) local t1 = t - 1; return 1 - t1 * t1 * t1 * t1 end },
    { name = "EaseInExpo", func = function(t) return t == 0 and 0 or math.pow(2, 10 * (t - 1)) end },
  }
  
  easingBoxes = {}
  
  for i, easing in ipairs(easings) do
    local hue = (i - 1) / 8
    local box = Gui.new({
      parent = easingContainer,
      backgroundColor = Color.new(0.2 + hue * 0.6, 0.4 + math.sin(hue * 3.14) * 0.4, 0.8 - hue * 0.4, 1),
      text = easing.name,
      textSize = "2vh",
      textColor = Color.new(1, 1, 1, 1),
      textAlign = enums.TextAlign.CENTER,
      cornerRadius = 8,
      callback = function(element, event)
        if event.type == "click" then
          -- Fade out and in with this easing
          local fadeOut = Animation.fade(0.8, 1.0, 0.2)
          fadeOut.easing = easing.func
          element.animation = fadeOut
          
          local startTime = Lv.timer.getTime()
          element._easingCallback = function(el, dt)
            if Lv.timer.getTime() - startTime >= 0.8 then
              local fadeIn = Animation.fade(0.8, 0.2, 1.0)
              fadeIn.easing = easing.func
              el.animation = fadeIn
              el._easingCallback = nil
            end
          end
        end
      end,
    })
    table.insert(easingBoxes, box)
  end
end

function Lv.update(dt)
  -- Handle fade callback
  if fadeBox and fadeBox._fadeCallback then
    fadeBox._fadeCallback(fadeBox, dt)
  end
  
  -- Handle scale callback
  if scaleBox and scaleBox._scaleCallback then
    scaleBox._scaleCallback(scaleBox, dt)
  end
  
  -- Handle easing callbacks
  for _, box in ipairs(easingBoxes) do
    if box._easingCallback then
      box._easingCallback(box, dt)
    end
  end
  
  Gui.update(dt)
end

function Lv.draw()
  Lv.graphics.clear(0.05, 0.05, 0.08, 1)
  Gui.draw()
end

function Lv.resize(w, h)
  Gui.resize(w, h)
end
