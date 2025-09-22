# 02. Fix Default Positioning and Absolute Positioning Logic

meta:
  id: flexlove-test-fixes-02
  feature: flexlove-test-fixes
  priority: P1
  depends_on: [flexlove-test-fixes-01]
  tags: [positioning, css-compliance, absolute-positioning]

objective:
- Fix default positioning to return "relative" instead of "absolute" per CSS standards
- Fix absolute positioning logic to not affect parent auto-sizing calculations

deliverables:
- Updated FlexLove.lua positioning default logic to follow CSS specification
- Fixed Element constructor to set default positioning to "relative"
- Fixed absolute child auto-sizing behavior to not affect parent dimensions
- Updated positioning validation and handling functions

steps:
- Examine FlexLove.lua Element constructor and identify default positioning logic
- Change default positioning from "absolute" to "relative" to match CSS standards
- Locate absolute positioning handling in layout calculations
- Fix testAbsoluteChildNoParentAutoSizeAffect by ensuring absolute children don't affect parent auto-size
- Review and update any positioning-related validation functions
- **CRITICAL: Ensure all positioning behavior follows CSS flexbox and positioning specifications**

tests:
- Unit: Test Element constructor sets default positioning to "relative"
- Unit: Test absolute positioned elements do not affect parent auto-sizing
- Integration: Run testDefaultAbsolutePositioning and verify it returns "relative"
- Integration: Run testAbsoluteChildNoParentAutoSizeAffect and verify it returns nil for parent auto-size

acceptance_criteria:
- testDefaultAbsolutePositioning passes (expected "relative", gets "relative")
- testAbsoluteChildNoParentAutoSizeAffect passes (expected nil, gets nil)
- Default Element positioning returns "relative" per CSS standards
- Absolute positioned children do not contribute to parent auto-sizing calculations
- All positioning behavior follows CSS specification requirements

validation:
- Run: lua testing/__tests__/01_absolute_positioning_basic_tests.lua
- Verify: testDefaultAbsolutePositioning passes without assertion errors
- Verify: testAbsoluteChildNoParentAutoSizeAffect passes without assertion errors  
- Run: lua testing/runAll.lua
- Verify: Failure count related to positioning issues decreases
- Test: Create new element without positioning parameter, confirm positioning == "relative"

notes:
- CSS specification: default positioning should be "relative", not "absolute"
- Absolute positioned elements are removed from normal document flow and don't affect parent sizing
- **REMEMBER: All positioning logic must assume proper CSS behavior and specification compliance**
- Review CSS flexbox specification for absolute positioning interaction with flex containers