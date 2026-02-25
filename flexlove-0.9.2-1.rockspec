package = "flexlove"
version = "0.9.2-1"

source = {
  url = "git+https://github.com/mikefreno/FlexLove.git",
  tag = "v0.9.2",
}

description = {
  summary = "A comprehensive UI library providing flexbox/grid layouts, theming, animations, and event handling for LÖVE2D games",
  detailed = [[
      FlexLöve is a lightweight, flexible GUI library for LÖVE2D that implements a
      flexbox-based layout system. The goals of this project are two-fold: first,
      anyone with basic CSS knowledge should be able to use this library with minimal
      learning curve. Second, this library should take you from early prototyping to
      production.

      Features:
      - Flexbox and Grid Layout systems
      - Modern theming with 9-patch support
      - Animations and transitions
      - Image rendering with CSS-like object-fit
      - Touch events and gesture recognition
      - Text input with rich editing features
      - Responsive design with viewport units
      - Both immediate and retained rendering modes

      Going this route, you will need to link the luarocks path to your project:
      (for mac/linux)
      ```lua
      package.path = package.path .. ";/Users/<username>/.luarocks/share/lua/<version>/?.lua"
      package.path = package.path .. ";/Users/<username>/.luarocks/share/lua/<version>/?/init.lua"
      package.cpath = package.cpath .. ";/Users/<username>/.luarocks/lib/lua/<version>/?.so"
      ```
   ]],
  homepage = "https://mikefreno.github.io/FlexLove/",
  license = "MIT",
  maintainer = "Mike Freno",
}

dependencies = {
  "lua >= 5.1",
  "luautf8 >= 0.1.3",
}

build = {
  type = "builtin",
  modules = {
    ["FlexLove"] = "FlexLove.lua",
    ["FlexLove.modules.Animation"] = "modules/Animation.lua",
    ["FlexLove.modules.Blur"] = "modules/Blur.lua",
    ["FlexLove.modules.Calc"] = "modules/Calc.lua",
    ["FlexLove.modules.Color"] = "modules/Color.lua",
    ["FlexLove.modules.Context"] = "modules/Context.lua",
    ["FlexLove.modules.Element"] = "modules/Element.lua",
    ["FlexLove.modules.ErrorHandler"] = "modules/ErrorHandler.lua",
    ["FlexLove.modules.EventHandler"] = "modules/EventHandler.lua",
    ["FlexLove.modules.FFI"] = "modules/FFI.lua",
    ["FlexLove.modules.GestureRecognizer"] = "modules/GestureRecognizer.lua",
    ["FlexLove.modules.Grid"] = "modules/Grid.lua",
    ["FlexLove.modules.ImageCache"] = "modules/ImageCache.lua",
    ["FlexLove.modules.ImageRenderer"] = "modules/ImageRenderer.lua",
    ["FlexLove.modules.ImageScaler"] = "modules/ImageScaler.lua",
    ["FlexLove.modules.InputEvent"] = "modules/InputEvent.lua",
    ["FlexLove.modules.LayoutEngine"] = "modules/LayoutEngine.lua",
    ["FlexLove.modules.MemoryScanner"] = "modules/MemoryScanner.lua",
    ["FlexLove.modules.ModuleLoader"] = "modules/ModuleLoader.lua",
    ["FlexLove.modules.NinePatch"] = "modules/NinePatch.lua",
    ["FlexLove.modules.Performance"] = "modules/Performance.lua",
    ["FlexLove.modules.Renderer"] = "modules/Renderer.lua",
    ["FlexLove.modules.RoundedRect"] = "modules/RoundedRect.lua",
    ["FlexLove.modules.ScrollManager"] = "modules/ScrollManager.lua",
    ["FlexLove.modules.StateManager"] = "modules/StateManager.lua",
    ["FlexLove.modules.TextEditor"] = "modules/TextEditor.lua",
    ["FlexLove.modules.Theme"] = "modules/Theme.lua",
    ["FlexLove.modules.types"] = "modules/types.lua",
    ["FlexLove.modules.Units"] = "modules/Units.lua",
    ["FlexLove.modules.UTF8"] = "modules/UTF8.lua",
    ["FlexLove.modules.utils"] = "modules/utils.lua",
  },
  --copy_directories = {
  --"docs",
  --"examples",
  --},
}
