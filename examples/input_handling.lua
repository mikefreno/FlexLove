-- Example: Input Handling System
-- This demonstrates how to handle various input events in FlexLove

local FlexLove = require("libs.FlexLove")

local InputExample = {}

function InputExample:new()
    local obj = {
        -- State variables for input handling example
        mousePosition = { x = 0, y = 0 },
        keyPressed = "",
        touchPosition = { x = 0, y = 0 },
        isMouseOver = false,
        hoverCount = 0
    }
    setmetatable(obj, {__index = self})
    return obj
end

function InputExample:render()
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
        text = "Input Handling System Example",
        textAlign = "center",
        textSize = "2xl",
        width = "100%",
        height = "10%",
    })
    
    -- Mouse interaction section
    local mouseSection = FlexLove.new({
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
        parent = mouseSection,
        text = "Mouse Position: (" .. self.mousePosition.x .. ", " .. self.mousePosition.y .. ")",
        textAlign = "left",
        textSize = "md",
        width = "60%",
    })
    
    -- Hoverable area
    local hoverArea = FlexLove.new({
        parent = mouseSection,
        positioning = "flex",
        justifyContent = "center",
        alignItems = "center",
        width = "30%",
        height = "100%",
        backgroundColor = "#4a5568",
        borderRadius = 8,
        padding = { horizontal = 10 },
        onEvent = function(_, event)
            if event.type == "mousemoved" then
                self.mousePosition.x = event.x
                self.mousePosition.y = event.y
            elseif event.type == "mouseenter" then
                self.isMouseOver = true
                self.hoverCount = self.hoverCount + 1
            elseif event.type == "mouseleave" then
                self.isMouseOver = false
            end
        end,
    })
    
    FlexLove.new({
        parent = hoverArea,
        text = "Hover over me!",
        textAlign = "center",
        textSize = "md",
        width = "100%",
        height = "100%",
        color = self.isMouseOver and "#48bb78" or "#a0aec0",  -- Green when hovered
    })
    
    -- Keyboard input section
    local keyboardSection = FlexLove.new({
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
        parent = keyboardSection,
        text = "Last Key Pressed: " .. (self.keyPressed or "None"),
        textAlign = "left",
        textSize = "md",
        width = "60%",
    })
    
    -- Input field for typing
    local inputField = FlexLove.new({
        parent = keyboardSection,
        themeComponent = "inputv2",
        text = "",
        textAlign = "left",
        textSize = "md",
        width = "30%",
        onEvent = function(_, event)
            if event.type == "textinput" then
                self.keyPressed = event.text
            elseif event.type == "keypressed" then
                self.keyPressed = event.key
            end
        end,
    })
    
    -- Touch input section
    local touchSection = FlexLove.new({
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
        parent = touchSection,
        text = "Touch Position: (" .. self.touchPosition.x .. ", " .. self.touchPosition.y .. ")",
        textAlign = "left",
        textSize = "md",
        width = "60%",
    })
    
    -- Touchable area
    local touchArea = FlexLove.new({
        parent = touchSection,
        positioning = "flex",
        justifyContent = "center",
        alignItems = "center",
        width = "30%",
        height = "100%",
        backgroundColor = "#4a5568",
        borderRadius = 8,
        padding = { horizontal = 10 },
        onEvent = function(_, event)
            if event.type == "touch" then
                self.touchPosition.x = event.x
                self.touchPosition.y = event.y
            end
        end,
    })
    
    FlexLove.new({
        parent = touchArea,
        text = "Touch me!",
        textAlign = "center",
        textSize = "md",
        width = "100%",
        height = "100%",
    })
    
    -- Status section showing interaction counts
    local statusSection = FlexLove.new({
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
        parent = statusSection,
        text = "Hover Count: " .. self.hoverCount,
        textAlign = "left",
        textSize = "md",
        width = "30%",
    })
    
    -- Reset button
    FlexLove.new({
        parent = statusSection,
        themeComponent = "buttonv2",
        text = "Reset All",
        textAlign = "center",
        width = "30%",
        onEvent = function(_, event)
            if event.type == "release" then
                self.mousePosition = { x = 0, y = 0 }
                self.keyPressed = ""
                self.touchPosition = { x = 0, y = 0 }
                self.hoverCount = 0
                self.isMouseOver = false
                print("All input states reset")
            end
        end,
    })
    
    return flex
end

return InputExample