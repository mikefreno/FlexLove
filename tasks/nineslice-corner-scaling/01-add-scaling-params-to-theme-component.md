# 01. Add Scaling Parameters to ThemeComponent

meta:
  id: nineslice-corner-scaling-01
  feature: nineslice-corner-scaling
  priority: P2
  depends_on: []
  tags: [implementation, documentation]

objective:
- Add `scaleCorners` and `scalingAlgorithm` parameters to ThemeComponent type definition
- Update documentation to reflect new parameters

deliverables:
- Updated `@class ThemeComponent` annotation in FlexLove.lua with new fields
- Updated `@class ElementProps` annotation to include theme scaling options
- Documentation in themes/README.md explaining the new parameters

steps:
- Locate the `@class ThemeComponent` definition in FlexLove.lua (around line 345)
- Add `scaleCorners` field: `---@field scaleCorners boolean? -- Optional: scale non-stretched regions (corners/edges). Default: false`
- Add `scalingAlgorithm` field: `---@field scalingAlgorithm "nearest"|"bilinear"? -- Optional: scaling algorithm for non-stretched regions. Default: "bilinear"`
- Update themes/README.md with a new section explaining corner scaling feature
- Add example usage showing how to enable corner scaling in theme definitions

tests:
- Unit: None required (type definition only)
- Integration: Verify theme loading doesn't break with new optional fields
- Manual: Check that existing themes continue to work without changes

acceptance_criteria:
- ThemeComponent type includes `scaleCorners` boolean field (optional, default false)
- ThemeComponent type includes `scalingAlgorithm` string field (optional, "nearest"|"bilinear", default "bilinear")
- Documentation clearly explains when and why to use corner scaling
- All existing tests pass without modification

validation:
- Run: `cd testing && lua runAll.lua`
- Verify: All tests pass
- Check: No warnings about undefined fields for scaleCorners or scalingAlgorithm

notes:
- scaleCorners defaults to false to maintain backward compatibility
- scalingAlgorithm defaults to "bilinear" for smoother visual quality
- These parameters can be set per-component or per-state
- The scaling only affects corners and non-stretched edge regions (topLeft, topRight, bottomLeft, bottomRight, and edges when not in stretch direction)
