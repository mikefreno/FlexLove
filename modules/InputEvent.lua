---@class InputEvent
---@field type "click"|"press"|"release"|"rightclick"|"middleclick"|"drag"
---@field button number -- Mouse button: 1 (left), 2 (right), 3 (middle)
---@field x number -- Mouse X position
---@field y number -- Mouse Y position
---@field dx number? -- Delta X from drag start (only for drag events)
---@field dy number? -- Delta Y from drag start (only for drag events)
---@field modifiers {shift:boolean, ctrl:boolean, alt:boolean, super:boolean}
---@field clickCount number -- Number of clicks (for double/triple click detection)
---@field timestamp number -- Time when event occurred
local InputEvent = {}
InputEvent.__index = InputEvent

---@class InputEventProps
---@field type "click"|"press"|"release"|"rightclick"|"middleclick"|"drag"
---@field button number
---@field x number
---@field y number
---@field dx number?
---@field dy number?
---@field modifiers {shift:boolean, ctrl:boolean, alt:boolean, super:boolean}
---@field clickCount number?
---@field timestamp number?

--- Create a new input event
---@param props InputEventProps
---@return InputEvent
function InputEvent.new(props)
  local self = setmetatable({}, InputEvent)
  self.type = props.type
  self.button = props.button
  self.x = props.x
  self.y = props.y
  self.dx = props.dx
  self.dy = props.dy
  self.modifiers = props.modifiers
  self.clickCount = props.clickCount or 1
  self.timestamp = props.timestamp or love.timer.getTime()
  return self
end

return InputEvent
