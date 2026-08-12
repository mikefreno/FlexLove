package = "flexlove"
version = "0.15.1-1"

source = {
  url = "git://github.com/mikefreno/FlexLove.git",
  tag = "v0.15.1",
}

description = {
  summary = "UI Library for LÖVE Framework based on flexbox",
  detailed = [[
FlexLöve is a comprehensive UI library providing flexbox/grid layouts,
theming, animations, and event handling for LÖVE2D games. It supports
both immediate mode (rapid prototyping) and retained mode (production)
rendering, with CSS-familiar layout primitives.
  ]],
  homepage = "https://github.com/mikefreno/FlexLove",
  license = "MIT",
}

-- LÖVE2D is required at runtime but is not available as a LuaRocks
-- dependency; install LÖVE2D separately from https://love2d.org.
dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    ["FlexLove"] = "FlexLove.lua",
    ["modules.Animation"] = "modules/Animation.lua",
    ["modules.Behavior"] = "modules/Behavior.lua",
    ["modules.behaviors.Animated"] = "modules/behaviors/Animated.lua",
    ["modules.behaviors.Clickable"] = "modules/behaviors/Clickable.lua",
    ["modules.behaviors.Imageable"] = "modules/behaviors/Imageable.lua",
    ["modules.behaviors.Persistable"] = "modules/behaviors/Persistable.lua",
    ["modules.behaviors.Scrollable"] = "modules/behaviors/Scrollable.lua",
    ["modules.behaviors.Selectable"] = "modules/behaviors/Selectable.lua",
    ["modules.behaviors.TextEditable"] = "modules/behaviors/TextEditable.lua",
    ["modules.behaviors.Themed"] = "modules/behaviors/Themed.lua",
    ["modules.Blur"] = "modules/Blur.lua",
    ["modules.Calc"] = "modules/Calc.lua",
    ["modules.Color"] = "modules/Color.lua",
    ["modules.Context"] = "modules/Context.lua",
    ["modules.Element"] = "modules/Element.lua",
    ["modules.Enums"] = "modules/Enums.lua",
    ["modules.ErrorHandler"] = "modules/ErrorHandler.lua",
    ["modules.EventHandler"] = "modules/EventHandler.lua",
    ["modules.FocusIndicator"] = "modules/FocusIndicator.lua",
    ["modules.FontCache"] = "modules/FontCache.lua",
    ["modules.GestureRecognizer"] = "modules/GestureRecognizer.lua",
    ["modules.Grid"] = "modules/Grid.lua",
    ["modules.ImageCache"] = "modules/ImageCache.lua",
    ["modules.ImageRenderer"] = "modules/ImageRenderer.lua",
    ["modules.ImageScaler"] = "modules/ImageScaler.lua",
    ["modules.InputEvent"] = "modules/InputEvent.lua",
    ["modules.KeyboardNavigation"] = "modules/KeyboardNavigation.lua",
    ["modules.LayoutEngine"] = "modules/LayoutEngine.lua",
    ["modules.MemoryScanner"] = "modules/MemoryScanner.lua",
    ["modules.ModuleLoader"] = "modules/ModuleLoader.lua",
    ["modules.NinePatch"] = "modules/NinePatch.lua",
    ["modules.NumberValidation"] = "modules/NumberValidation.lua",
    ["modules.PathValidator"] = "modules/PathValidator.lua",
    ["modules.Performance"] = "modules/Performance.lua",
    ["modules.PropertySchema"] = "modules/PropertySchema.lua",
    ["modules.Renderer"] = "modules/Renderer.lua",
    ["modules.RoundedRect"] = "modules/RoundedRect.lua",
    ["modules.ScrollManager"] = "modules/ScrollManager.lua",
    ["modules.Select"] = "modules/Select.lua",
    ["modules.StateManager"] = "modules/StateManager.lua",
    ["modules.TextEditor"] = "modules/TextEditor.lua",
    ["modules.TextSanitizer"] = "modules/TextSanitizer.lua",
    ["modules.Theme"] = "modules/Theme.lua",
    ["modules.types"] = "modules/types.lua",
    ["modules.Units"] = "modules/Units.lua",
    ["modules.UTF8"] = "modules/UTF8.lua",
    ["modules.utils"] = "modules/utils.lua",
    ["modules.ZIndex"] = "modules/ZIndex.lua"
  },
}
