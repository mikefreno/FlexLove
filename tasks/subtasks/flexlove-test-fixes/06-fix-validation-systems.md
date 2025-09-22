# 06. Fix Input Validation and Units System

meta:
  id: flexlove-test-fixes-06
  feature: flexlove-test-fixes
  priority: P2
  depends_on: [flexlove-test-fixes-01]
  tags: [validation, units-system, input-validation, css-compliance]

objective:
- Fix input validation systems for colors, circular references, and edge cases
- Fix units system to correctly identify and convert unit types

deliverables:
- Updated input validation functions in FlexLove.lua
- Fixed color hex string validation algorithms
- Fixed circular reference detection for element hierarchies
- Corrected units system unit type identification and conversion
- Enhanced validation error handling and reporting

steps:
- Examine failing validation tests to identify specific issues
- Review FlexLove.lua validation and units system functions
- Fix color hex validation for proper CSS color format support
- Update circular reference detection algorithms
- Fix units system to return correct unit types ("px", "em", "%", etc.)
- Ensure proper unit conversion and calculation
- **CRITICAL: Ensure all validation follows CSS specification standards**

tests:
- Unit: Test color hex validation with valid and invalid formats
- Unit: Test circular reference detection with various element hierarchies
- Unit: Test units system with different unit types and values
- Integration: Run layout validation tests and verify validation functions
- Integration: Run units system tests and verify correct unit identification

acceptance_criteria:
- All color hex validation test failures are resolved
- Circular reference detection correctly identifies invalid hierarchies
- Units system returns correct unit types for all supported formats
- Input validation properly handles edge cases and invalid inputs
- Validation error messages are clear and helpful
- All validation functions follow CSS specification requirements

validation:
- Run: lua testing/__tests__/09_layout_validation_tests.lua
- Verify: All validation tests pass without assertion errors
- Run: lua testing/__tests__/12_units_system_tests.lua
- Verify: All units system tests pass with correct unit identification
- Test: Validate color "#FF0000", "#invalid", "rgb(255,0,0)" with validation functions
- Test: Create circular element hierarchy, verify detection works
- Run: lua testing/runAll.lua
- Verify: Validation-related test failures are eliminated

notes:
- Color validation should support hex (#RGB, #RRGGBB), rgb(), rgba(), hsl(), hsla() formats
- Circular reference detection critical for preventing infinite loops in layout
- Units system should handle px, em, rem, %, vh, vw, and other CSS units
- Validation should provide clear error messages for debugging
- **REMEMBER: All validation logic must assume proper CSS standards and specification compliance**