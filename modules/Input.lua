-- modules/Input.lua
--
-- Input indirection for headless driving and testing.
--
-- FlexLove's interaction code polls the OS mouse/keyboard state every frame
-- (`love.mouse.isDown` / `love.mouse.getPosition` / `love.keyboard.isDown`).
-- That makes automated driving awkward: a caller cannot inject a press and
-- have the next frame observe it. This module gives those polling sites a
-- single seam:
--
--   * By default it mirrors `love` directly, so interactive play is unchanged.
--   * `Input.useVirtual()` swaps the backing to an in-memory source whose
--     position/buttons/keys the harness controls synchronously. Nothing else
--     in the library or host app changes.
--
-- The module is intentionally tiny: it owns no event routing, no timing, and
-- no layout. It only answers "what is the input state RIGHT NOW".
--
-- Keyboard key naming follows love conventions ("lshift", "lctrl", "a", ...).
-- Mouse buttons are the love integers (1=left, 2=right, 3=middle).

---@class Input
local Input = {}

local VirtualState = {
  x = 0,
  y = 0,
  buttons = {}, -- [1|2|3] = true
  keys = {}, -- ["lshift"] = true
}

local virtual = false

---Set whether Input reads the virtual source instead of `love`.
---@param enabled boolean
function Input.useVirtual(enabled)
  virtual = enabled == true
end

---Whether the virtual source is active.
---@return boolean
function Input.isVirtual()
  return virtual
end

---Replace the whole virtual input state.
---Fields are merged; omitted tables are kept as-is.
---@param state {x?: number, y?: number, buttons?: table<integer, boolean>, keys?: table<string, boolean>}
function Input.setVirtualState(state)
  VirtualState.x = state.x or VirtualState.x
  VirtualState.y = state.y or VirtualState.y
  if state.buttons ~= nil then
    VirtualState.buttons = state.buttons
  end
  if state.keys ~= nil then
    VirtualState.keys = state.keys
  end
end

---Whether a mouse button is currently down.
---@param button integer 1=left 2=right 3=middle
---@return boolean
function Input.isDown(button)
  if virtual then
    return VirtualState.buttons[button] == true
  end
  return love.mouse.isDown(button)
end

---Current mouse position.
---@return number x
---@return number y
function Input.getPosition()
  if virtual then
    return VirtualState.x, VirtualState.y
  end
  return love.mouse.getPosition()
end

---Whether all given keys are currently down (logical AND, like love).
---@param key string first key
---@param ... string more keys
---@return boolean
function Input.isKeyDown(key, ...)
  if virtual then
    if VirtualState.keys[key] ~= true then
      return false
    end
    for i = 1, select("#", ...) do
      if VirtualState.keys[select(i, ...)] ~= true then
        return false
      end
    end
    return true
  end
  return love.keyboard.isDown(key, ...)
end

---Current keyboard modifiers.
---@return {shift: boolean, ctrl: boolean, alt: boolean, super: boolean}
function Input.getModifiers()
  if virtual then
    return {
      shift = VirtualState.keys["lshift"] == true or VirtualState.keys["rshift"] == true,
      ctrl = VirtualState.keys["lctrl"] == true or VirtualState.keys["rctrl"] == true,
      alt = VirtualState.keys["lalt"] == true or VirtualState.keys["ralt"] == true,
      super = VirtualState.keys["lgui"] == true or VirtualState.keys["rgui"] == true,
    }
  end
  return {
    shift = love.keyboard.isDown("lshift", "rshift"),
    ctrl = love.keyboard.isDown("lctrl", "rctrl"),
    alt = love.keyboard.isDown("lalt", "ralt"),
    super = love.keyboard.isDown("lgui", "rgui"),
  }
end

return Input
