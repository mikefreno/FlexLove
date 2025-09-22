# 05. Fix Text Scaling and Size Calculations

meta:
  id: flexlove-test-fixes-05
  feature: flexlove-test-fixes
  priority: P2
  depends_on: [flexlove-test-fixes-01]
  tags: [text-scaling, size-calculations, css-compliance]

objective:
- Fix text scaling calculations and size determination for text elements
- Ensure text sizing follows CSS text rendering and scaling specifications

deliverables:
- Updated text scaling algorithms in FlexLove.lua
- Fixed text size calculations for different font sizes and scales
- Corrected text measurement and layout integration
- Enhanced text rendering validation and edge case handling

steps:
- Examine failing text scaling tests to identify calculation errors
- Review FlexLove.lua text scaling and measurement functions
- Fix font size scaling calculations
- Update text width and height measurement algorithms
- Fix text baseline calculations for alignment
- Ensure proper integration with flex layout for text elements
- **CRITICAL: Ensure all text calculations follow CSS text rendering specifications**

tests:
- Unit: Test text size calculations for various font sizes
- Unit: Test text scaling with different scale factors
- Integration: Run text scaling basic tests and verify measurements
- Integration: Test text element integration with flex layout
- Integration: Verify text baseline calculations for alignment

acceptance_criteria:
- All text scaling test failures are resolved
- Text size calculations accurate for different font sizes
- Text scaling properly handles scale factors and DPI
- Text width and height measurements correct
- Text baseline calculations work for alignment
- Text elements integrate properly with flex layout system
- Font loading and measurement functions work correctly

validation:
- Run: lua testing/__tests__/14_text_scaling_basic_tests.lua
- Verify: All text scaling tests pass without assertion errors
- Test: Create text element with specific font size, verify calculated dimensions
- Test: Apply scaling factor to text, verify scaled dimensions
- Run: lua testing/runAll.lua
- Verify: Text-related test failures are eliminated

notes:
- Text scaling should account for font size, scale factor, and DPI
- Text measurements need accurate width/height calculations
- Baseline calculations critical for text alignment in flex containers
- Font loading and measurement require LOVE2D font system integration
- **REMEMBER: All text calculations must assume proper CSS text rendering logic and specification compliance**