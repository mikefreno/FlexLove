# NineSlice Corner Scaling

Objective: Add configurable scaling algorithms (nearest/bilinear) for non-stretched corner and edge regions in 9-slice theme components

Status legend: [ ] todo, [~] in-progress, [x] done

Tasks
- [x] 01 — add-scaling-params-to-theme-component → `01-add-scaling-params-to-theme-component.md`
- [x] 02 — implement-nearest-neighbor-scaling → `02-implement-nearest-neighbor-scaling.md`
- [ ] 03 — implement-bilinear-scaling → `03-implement-bilinear-scaling.md`
- [ ] 04 — integrate-scaling-into-nineslice-renderer → `04-integrate-scaling-into-nineslice-renderer.md`
- [ ] 05 — add-tests-and-examples → `05-add-tests-and-examples.md`

Dependencies
- 02 depends on 01
- 03 depends on 01
- 04 depends on 02, 03
- 05 depends on 04

Exit criteria
- The feature is complete when:
  - ThemeComponent definition includes `scaleCorners` boolean parameter (default: false)
  - ThemeComponent definition includes `scalingAlgorithm` string parameter (default: "bilinear")
  - Nearest-neighbor scaling algorithm correctly scales corner/edge regions
  - Bilinear interpolation algorithm correctly scales corner/edge regions with smooth filtering
  - NineSlice.draw applies scaling when `scaleCorners = true`
  - Corners and non-stretched edges scale using the specified algorithm
  - All existing tests pass without modification
  - New tests validate both scaling algorithms
  - Example demo showcases the feature with visual comparison
