# 03. Fix Flex Layout Calculations and Justify Content

meta:
  id: flexlove-test-fixes-03
  feature: flexlove-test-fixes
  priority: P1
  depends_on: [flexlove-test-fixes-02]
  tags: [flexbox, layout-calculations, justify-content, css-compliance]

objective:
- Fix flex layout calculations for justify-content spacing and positioning
- Ensure flexbox layout follows CSS flexbox specification for item positioning

deliverables:
- Updated flex layout calculation algorithms in FlexLove.lua
- Fixed justify-content positioning for flex-start, center, space-between, space-around, space-evenly
- Corrected flex item positioning and spacing calculations
- Enhanced flex layout validation and edge case handling

steps:
- Examine failing justify-content tests to identify calculation errors
- Review FlexLove.lua flex layout calculation functions
- Fix justify-content algorithms for horizontal and vertical flex directions
- Update spacing calculations for space-between, space-around, space-evenly
- Fix center alignment calculations for flex containers
- Verify flex-start and flex-end positioning calculations
- **CRITICAL: Ensure all flexbox calculations follow CSS flexbox specification exactly**

tests:
- Unit: Test justify-content calculations for all alignment values
- Unit: Test flex item positioning in horizontal and vertical containers
- Integration: Run testHorizontalFlexJustifyContentFlexStart and verify positioning
- Integration: Run testHorizontalFlexJustifyContentCenter and verify centering
- Integration: Run all justify-content tests and verify spacing calculations

acceptance_criteria:
- All justify-content test failures are resolved
- Flex items positioned correctly according to CSS flexbox specification
- Spacing calculations accurate for space-between, space-around, space-evenly
- Center alignment correctly positions items in available space
- Horizontal and vertical flex layouts calculate positions correctly
- Gap property correctly affects spacing between flex items

validation:
- Run: lua testing/__tests__/05_justify_content_tests.lua
- Verify: All justify-content tests pass without assertion errors
- Run: lua testing/__tests__/03_flex_direction_horizontal_tests.lua
- Verify: Horizontal flex layout tests pass
- Run: lua testing/__tests__/04_flex_direction_vertical_tests.lua
- Verify: Vertical flex layout tests pass
- Test: Create flex container with justify-content center, verify items are centered

notes:
- CSS flexbox specification defines exact algorithms for justify-content positioning
- Available space calculation: container size minus sum of item sizes minus gaps
- Space-between: equal space between items, no space at start/end
- Space-around: equal space around each item (half-space at start/end)
- Space-evenly: equal space between items and at start/end
- **REMEMBER: All flex layout must assume proper CSS flexbox logic and specification compliance**