# 03. Implement Bilinear Interpolation Scaling

meta:
  id: nineslice-corner-scaling-03
  feature: nineslice-corner-scaling
  priority: P2
  depends_on: [nineslice-corner-scaling-01]
  tags: [implementation, tests-required]

objective:
- Implement a bilinear interpolation scaling algorithm for smooth upscaling of image regions in LÖVE

deliverables:
- `ImageScaler.scaleBilinear` function in FlexLove.lua
- Function takes ImageData source region and produces smoothly scaled ImageData output
- Proper 2D linear interpolation between 4 neighboring pixels

steps:
- Add `ImageScaler.scaleBilinear(sourceImageData, srcX, srcY, srcW, srcH, destW, destH)` function to ImageScaler module
- Function creates new ImageData with destW x destH dimensions
- For each destination pixel:
  - Calculate fractional source position: srcX_f = destX * srcW / destW, srcY_f = destY * srcH / destH
  - Get integer coordinates: x0 = floor(srcX_f), y0 = floor(srcY_f), x1 = min(x0+1, srcW-1), y1 = min(y0+1, srcH-1)
  - Get fractional parts: fx = srcX_f - x0, fy = srcY_f - y0
  - Sample 4 neighboring pixels: topLeft, topRight, bottomLeft, bottomRight
  - Interpolate horizontally: top = lerp(topLeft, topRight, fx), bottom = lerp(bottomLeft, bottomRight, fx)
  - Interpolate vertically: final = lerp(top, bottom, fy)
  - Apply to all RGBA channels independently
- Return the scaled ImageData
- Add helper function `lerp(a, b, t)` for linear interpolation: a + (b - a) * t

tests:
- Unit: Test scaling 2x2 region to 4x4 with known color gradient
- Unit: Test scaling 3x3 region to 9x9 with checkerboard pattern
- Unit: Verify smooth color transitions between pixels
- Unit: Test edge pixel handling (no out-of-bounds access)
- Unit: Compare against nearest-neighbor to verify smoothness
- Unit: Test pure white/black regions maintain values

acceptance_criteria:
- ImageScaler.scaleBilinear function exists and is properly documented
- Function correctly interpolates between 4 neighboring pixels
- Scaled output has smooth color gradients (no blocky edges)
- Function handles all RGBA channels correctly with independent interpolation
- Edge cases handled: boundary pixels, same-size scaling, 1x1 input
- No artifacts or color bleeding at edges
- Performance acceptable for typical corner sizes (8x8 to 32x32)

validation:
- Create test file: `testing/__tests__/23_image_scaler_bilinear_tests.lua`
- Run: `cd testing && lua testing/__tests__/23_image_scaler_bilinear_tests.lua`
- Verify: All bilinear interpolation tests pass
- Visual: Create gradient test image and verify smooth transitions

notes:
- Bilinear interpolation formula: lerp(lerp(p00, p10, fx), lerp(p01, p11, fx), fy)
- Handle edge pixels carefully: clamp x1, y1 to valid range to avoid out-of-bounds
- LÖVE ImageData pixel values are in [0, 1] range, perfect for lerp
- Interpolate each RGBA channel independently
- This algorithm produces smoother results than nearest-neighbor but is more computationally expensive
- For alpha channel, interpolation prevents harsh edges on semi-transparent pixels
- Default algorithm for better visual quality
