// Classes to INCLUDE in documentation (whitelist approach)
// Only these classes and their related types will appear in the docs
module.exports = {
  // Main user-facing classes
  include: [
    "Animation",
    "AnimationProps",
    //"Border",
    "Color",
    "Element",
    "ElementProps",
    "EventHandler",
    "FlexLove",
    "FontFamily",
    "InputEvent",
    //"InputEventProps",
    //"LayoutEngine",
    //"LayoutEngineProps",
    "Theme",
    "ThemeComponent",
    "ThemeDefinition",
    "TextEditor",
    "TextEditorConfig",
    "TransformProps",
    "TransitionProps",
  ],

  // Alternative: exclude specific classes (blacklist)
  exclude: [
    "Context",
    "Performance",
    "Trace",
    "Proto",
    "LuaLS",
    "ImageCache",
    "ImageRenderer",
    "Renderer",
    "StateManager",
    "ScrollManager",
    "ErrorCodes",
    "ThemeManager",
    "ThemeRegion",
  ],

  // Which mode to use: 'whitelist' or 'blacklist'
  mode: "whitelist",
};
