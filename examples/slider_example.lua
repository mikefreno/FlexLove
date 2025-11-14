--- Example demonstrating how to create sliders using FlexLove
-- This example shows the implementation pattern used in SettingsMenu.lua
local FlexLove = require("libs.FlexLove")
local Theme = FlexLove.Theme
local Color = FlexLove.Color
local helpers = require("utils.helperFunctions")
local round = helpers.round

---@class SliderExample
local SliderExample = {}
SliderExample.__index = SliderExample

local instance

---@return SliderExample
function SliderExample.init()
    if instance == nil then
        local self = setmetatable({}, SliderExample)
        instance = self
    end
    return instance
end

--- Create a slider control like in SettingsMenu
---@param parent Element The parent element
---@param label string The control label
---@param min number Minimum value
---@param max number Maximum value
---@param initial_value number? Initial value (defaults to min)
---@param display_multiplier number? Multiplier for display (e.g., 100 for percentage)
function SliderExample:create_slider(parent, label, min, max, initial_value, display_multiplier)
    display_multiplier = display_multiplier or 1
    initial_value = initial_value or min

    local row = FlexLove.new({
        parent = parent,
        width = "100%",
        height = "5vh",
        positioning = "flex",
        flexDirection = "horizontal",
        justifyContent = "space-between",
        alignItems = "center",
        gap = 10,
    })

    -- Label
    FlexLove.new({
        parent = row,
        text = label,
        textAlign = "start",
        textSize = "md",
        width = "30%",
    })

    local slider_container = FlexLove.new({
        parent = row,
        width = "50%",
        height = "100%",
        positioning = "flex",
        flexDirection = "horizontal",
        alignItems = "center",
        gap = 5,
    })

    local value = initial_value
    local normalized = (value - min) / (max - min)

    local function convert_x_to_percentage(mx, parentX, parentWidth)
        local val = (mx - parentX) / parentWidth
        if val < 0.01 then
            val = 0
        elseif val > 0.99 then
            val = 1
        else
            val = round(val, 2)
        end
        -- In a real app, you'd update the actual setting here
        value = min + (val * (max - min))
        -- Update the display value
        value_display.text = string.format("%d", value * display_multiplier)
    end

    local slider_track = FlexLove.new({
        parent = slider_container,
        width = "80%",
        height = "75%",
        positioning = "flex",
        flexDirection = "horizontal",
        themeComponent = "framev3",
        onEvent = function(elem, event)
            convert_x_to_percentage(event.x, elem.x, elem.width)
        end,
    })

    local fill_bar = FlexLove.new({
        parent = slider_track,
        width = (normalized * 100) .. "%",
        height = "100%",
        themeComponent = "buttonv1",
        onEvent = function(_, event)
            convert_x_to_percentage(event.x, slider_track.x, slider_track.width)
        end,
    })

    local value_display = FlexLove.new({
        parent = slider_container,
        text = string.format("%d", value * display_multiplier),
        textAlign = "center",
        textSize = "md",
        width = "15%",
    })
end

--- Create an example UI with multiple sliders
function SliderExample:render_example()
    -- Create a window for our example
    local window = FlexLove.new({
        x = "10%",
        y = "10%",
        width = "80%",
        height = "80%",
        themeComponent = "framev3",
        positioning = "flex",
        flexDirection = "vertical",
        justifySelf = "center",
        justifyContent = "flex-start",
        alignItems = "center",
        scaleCorners = 3,
        padding = { horizontal = "5%", vertical = "3%" },
        gap = 20,
    })

    FlexLove.new({
        parent = window,
        text = "Slider Example",
        textAlign = "center",
        textSize = "3xl",
        width = "100%",
        margin = { top = "-4%", bottom = "4%" },
    })

    -- Content container
    local content = FlexLove.new({
        parent = window,
        width = "100%",
        height = "100%",
        positioning = "flex",
        flexDirection = "vertical",
        padding = { top = "4%" },
        gap = 20,
    })

    -- Create a few example sliders
    self:create_slider(content, "Volume", 0, 100, 75, 1)
    self:create_slider(content, "Brightness", 0, 100, 50, 1)
    self:create_slider(content, "Sensitivity", 0.1, 2.0, 1.0, 100)
end

return SliderExample.init()