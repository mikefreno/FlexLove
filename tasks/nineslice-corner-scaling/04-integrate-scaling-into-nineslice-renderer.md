# 04. Integrate Scaling into NineSlice Renderer

meta:
  id: nineslice-corner-scaling-04
  feature: nineslice-corner-scaling
  priority: P2
  depends_on: [nineslice-corner-scaling-02, nineslice-corner-scaling-03]
  tags: [implementation, tests-required]

objective:
- Modify NineSlice.draw to apply scaling algorithms to non-stretched regions when enabled

deliverables:
- Updated NineSlice.draw function that checks for scaleCorners parameter
- Scaled corners and edges rendered using specified algorithm
- Cache for scaled ImageData to avoid re-scaling every frame
- Proper cleanup of cached scaled images

steps:
- Locate NineSlice.draw function in FlexLove.lua (around line 905)
- Add logic to check if `component.scaleCorners` is true
- If scaleCorners is enabled:
  - Determine target scale factors based on base scale (Gui.scaleFactors)
  - For each corner region (topLeft, topRight, bottomLeft, bottomRight):
    - Check if cached scaled version exists in component._scaledRegionCache
    - If not cached, extract region from atlas using ImageData
    - Scale using component.scalingAlgorithm ("nearest" or "bilinear", default "bilinear")
    - Convert scaled ImageData to Image and cache it in component._scaledRegionCache
    - Draw scaled Image instead of using quad with scale transform
  - For edge regions (when not in stretch direction):
    - Apply same scaling logic for the non-stretch dimension
- If scaleCorners is false, use existing rendering logic (no changes)
- Add cache invalidation on window resize (clear component._scaledRegionCache)
- Ensure cache keys include scale factor to handle different scales

tests:
- Unit: Verify NineSlice.draw calls scaling functions when scaleCorners=true
- Unit: Verify cache is populated and reused on subsequent draws
- Unit: Verify cache is cleared on resize
- Integration: Test with actual theme components at different window sizes
- Integration: Verify both "nearest" and "bilinear" algorithms work correctly
- Visual: Compare scaled vs non-scaled rendering side-by-side

acceptance_criteria:
- NineSlice.draw respects component.scaleCorners parameter
- Corners scale using specified algorithm when scaleCorners=true
- Scaling algorithm selection works ("nearest" vs "bilinear")
- Scaled images are cached to avoid redundant scaling operations
- Cache is properly invalidated on window resize
- Non-scaled rendering still works (backward compatibility)
- Performance is acceptable (no noticeable lag during rendering)
- All existing tests pass without modification

validation:
- Run: `cd testing && lua runAll.lua`
- Verify: All existing tests still pass
- Create visual demo showing scaled vs non-scaled corners
- Test at multiple window sizes to verify cache invalidation
- Profile rendering performance with scaling enabled

notes:
- Cache key format: `{scaleFactor}_{algorithm}_{regionName}`
- Consider memory usage: cache only currently needed scales
- On resize, Gui.resize should trigger cache clearing for all components
- Extract ImageData region using: atlas:getData() then copy region
- Convert to Image using: love.graphics.newImage(scaledImageData)
- Remember to handle both component-level and state-level atlases
- Corners are: topLeft, topRight, bottomLeft, bottomRight (never stretched)
- Edges partially scale: topCenter/bottomCenter scale horizontally, middleLeft/middleRight scale vertically
- For edges, only scale the non-stretch dimension
