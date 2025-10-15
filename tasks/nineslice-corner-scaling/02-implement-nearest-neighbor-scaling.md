# 02. Implement Nearest-Neighbor Scaling

meta:
  id: nineslice-corner-scaling-02
  feature: nineslice-corner-scaling
  priority: P2
  depends_on: [nineslice-corner-scaling-01]
  tags: [implementation, tests-required]

objective:
- Implement a nearest-neighbor scaling algorithm for upscaling image regions in LÖVE

deliverables:
- New `ImageScaler` module in FlexLove.lua with `scaleNearest` function
- Function takes ImageData source region and produces scaled ImageData output
- Proper handling of RGBA pixel data with correct indexing

steps:
- Create new `ImageScaler` module section in FlexLove.lua (after NinePatchParser, before Theme System)
- Implement `ImageScaler.scaleNearest(sourceImageData, srcX, srcY, srcW, srcH, destW, destH)` function
- Function creates new ImageData with destW x destH dimensions
- For each destination pixel, calculate source pixel using floor(destX * srcW / destW)
- Use ImageData:getPixel() to read source RGBA values
- Use ImageData:setPixel() to write destination RGBA values
- Return the scaled ImageData
- Add proper error handling for invalid dimensions

tests:
- Unit: Test scaling 2x2 region to 4x4 (2x scale factor)
- Unit: Test scaling 3x3 region to 9x9 (3x scale factor)
- Unit: Test scaling with non-uniform factors (2x3 to 6x9)
- Unit: Verify pixel values match expected nearest-neighbor results
- Unit: Test edge cases (1x1 scaling, same size scaling)

acceptance_criteria:
- ImageScaler.scaleNearest function exists and is properly documented
- Function correctly samples source pixels using nearest-neighbor logic
- Scaled output maintains sharp, pixelated edges (no interpolation)
- Function handles all RGBA channels correctly
- Edge pixels are correctly sampled without off-by-one errors
- Performance is acceptable for typical 9-slice corner sizes (8x8 to 32x32)

validation:
- Create test file: `testing/__tests__/22_image_scaler_nearest_tests.lua`
- Run: `cd testing && lua testing/__tests__/22_image_scaler_nearest_tests.lua`
- Verify: All nearest-neighbor tests pass
- Visual: Create small test image and verify scaled output looks correct

notes:
- Nearest-neighbor formula: srcX = floor(destX * srcW / destW), srcY = floor(destY * srcH / destH)
- LÖVE ImageData uses 0-based indexing for pixel coordinates
- ImageData:getPixel() returns r, g, b, a in range [0, 1]
- ImageData:setPixel() expects r, g, b, a in range [0, 1]
- For performance, consider caching scale ratios outside inner loops
- This algorithm is simpler but produces "blocky" results - good for pixel art
