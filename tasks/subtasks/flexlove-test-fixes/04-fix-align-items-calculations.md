# 04. Fix Align Items and Cross-Axis Alignment

meta:
  id: flexlove-test-fixes-04
  feature: flexlove-test-fixes
  priority: P1
  depends_on: [flexlove-test-fixes-03]
  tags: [flexbox, align-items, cross-axis, css-compliance]

objective:
- Fix align-items calculations for cross-axis alignment in flex containers
- Ensure proper stretch, center, flex-start, flex-end, and baseline alignment

deliverables:
- Updated align-items calculation algorithms in FlexLove.lua
- Fixed cross-axis positioning for all align-items values
- Corrected stretch behavior to fill cross-axis space
- Enhanced baseline alignment calculations

steps:
- Examine failing align-items tests to identify calculation errors
- Review FlexLove.lua align-items calculation functions
- Fix stretch alignment to make items fill cross-axis space
- Update center alignment for cross-axis positioning
- Fix flex-start and flex-end cross-axis positioning
- Implement proper baseline alignment calculations
- Handle align-self property overrides correctly
- **CRITICAL: Ensure all align-items calculations follow CSS flexbox specification exactly**

tests:
- Unit: Test align-items calculations for all alignment values
- Unit: Test cross-axis positioning in horizontal and vertical containers
- Integration: Run align-items tests for stretch behavior
- Integration: Run align-items tests for center alignment
- Integration: Run all align-items tests and verify positioning

acceptance_criteria:
- All align-items test failures are resolved
- Stretch alignment correctly fills available cross-axis space
- Center alignment positions items in middle of cross-axis
- Flex-start and flex-end position items correctly on cross-axis
- Baseline alignment aligns items by text baseline
- Align-self property correctly overrides container align-items
- Horizontal and vertical flex containers handle cross-axis correctly

validation:
- Run: lua testing/__tests__/06_align_items_tests.lua
- Verify: All align-items tests pass without assertion errors
- Run: lua testing/__tests__/03_flex_direction_horizontal_tests.lua
- Verify: Cross-axis alignment works in horizontal layouts
- Run: lua testing/__tests__/04_flex_direction_vertical_tests.lua  
- Verify: Cross-axis alignment works in vertical layouts
- Test: Create flex container with align-items stretch, verify items fill height/width

notes:
- Cross-axis is perpendicular to main axis: height for horizontal, width for vertical
- Stretch is default align-items value and should fill available cross-axis space
- Center positions item center at cross-axis center
- Flex-start positions at cross-axis start, flex-end at cross-axis end
- Baseline aligns items by their text baseline (complex calculation)
- **REMEMBER: All alignment calculations must assume proper CSS flexbox logic and specification compliance**