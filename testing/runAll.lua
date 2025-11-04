package.path = package.path .. ";./?.lua;./game/?.lua;./game/utils/?.lua;./game/components/?.lua;./game/systems/?.lua"

local luaunit = require("testing.luaunit")

-- Run all tests in the __tests__ directory
local testFiles = {
  "testing/__tests__/01_absolute_positioning_basic_tests.lua",
  "testing/__tests__/02_absolute_positioning_child_layout_tests.lua",
  "testing/__tests__/03_flex_direction_horizontal_tests.lua",
  "testing/__tests__/04_flex_direction_vertical_tests.lua",
  "testing/__tests__/05_justify_content_tests.lua",
  "testing/__tests__/06_align_items_tests.lua",
  "testing/__tests__/07_flex_wrap_tests.lua",
  "testing/__tests__/08_comprehensive_flex_tests.lua",
  "testing/__tests__/09_layout_validation_tests.lua",
  "testing/__tests__/10_performance_tests.lua",
  "testing/__tests__/11_auxiliary_functions_tests.lua",
  "testing/__tests__/12_units_system_tests.lua",
  "testing/__tests__/13_relative_positioning_tests.lua",
  "testing/__tests__/14_text_scaling_basic_tests.lua",
  "testing/__tests__/15_grid_layout_tests.lua",
  "testing/__tests__/16_event_system_tests.lua",
  "testing/__tests__/17_sibling_space_reservation_tests.lua",
  "testing/__tests__/18_font_family_inheritance_tests.lua",
  "testing/__tests__/19_negative_margin_tests.lua",
  "testing/__tests__/20_padding_resize_tests.lua",
  "testing/__tests__/21_image_scaler_nearest_tests.lua",
  "testing/__tests__/22_image_scaler_bilinear_tests.lua",
  "testing/__tests__/23_blur_effects_tests.lua",
  "testing/__tests__/24_keyboard_input_tests.lua",
  "testing/__tests__/25_image_cache_tests.lua",
  "testing/__tests__/26_object_fit_modes_tests.lua",
  "testing/__tests__/27_object_position_tests.lua",
  "testing/__tests__/28_element_image_integration_tests.lua",
  "testing/__tests__/29_drag_event_tests.lua",
  "testing/__tests__/30_scrollbar_features_tests.lua",
  "testing/__tests__/31_immediate_mode_basic_tests.lua",
}

local success = true
print("========================================")
print("Running ALL tests")
print("========================================")
for _, testFile in ipairs(testFiles) do
  print("========================================")
  print("Running test file: " .. testFile)
  print("========================================")
  local status, err = pcall(dofile, testFile)
  if not status then
    print("Error running test " .. testFile .. ": " .. tostring(err))
    success = false
  end
end

print("========================================")
print("All tests completed")
print("========================================")

local result = luaunit.LuaUnit.run()
os.exit(success and result or 1)
