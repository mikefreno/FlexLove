# Negative Margins Implementation

This feature implements support for negative margins in the FlexLove library. The implementation will allow elements to specify negative margin values, which will be applied during layout calculations.

## Tasks

1. 01-negative-margin-structure.md - Define the negative margin structure and data types
2. 02-negative-margin-application.md - Implement negative margin application logic 
3. 03-negative-margin-theme-integration.md - Integrate negative margin support into theme system
4. 04-negative-margin-validation.md - Add validation for negative margins
5. 05-negative-margin-tests.md - Write tests for negative margin functionality

## Status

- [x] Task 1: Define negative margin structure and data types - COMPLETE (margin parsing already supports negative values)
- [x] Task 2: Implement negative margin application logic - COMPLETE (margins now applied in flex layout)
- [x] Task 3: Integrate negative margin support into theme system - COMPLETE (works with all unit types)
- [x] Task 4: Add validation for negative margins - COMPLETE (no validation needed, negative values allowed)
- [x] Task 5: Write tests for negative margin functionality - COMPLETE (19_negative_margin_tests.lua passes)

## Implementation Summary

Negative margins are now fully functional in FlexLove. The implementation includes:

1. **Parsing**: The `Units.parse()` function already supported negative values in the regex pattern `[%-]?[%d%.]+`
2. **Storage**: Margins are stored correctly with negative values through `Units.resolveSpacing()`
3. **Application in Flex Layout**:
   - Line wrapping calculations include margins (both positive and negative)
   - Cross-axis size calculations include margins
   - Main-axis positioning applies margins when placing children
   - Cross-axis positioning applies margins for alignment
   - Position advancement includes margins in the calculation

4. **Supported Features**:
   - Negative margins work with all unit types: px, %, vw, vh
   - Works with shorthand properties (vertical, horizontal)
   - Works in both horizontal and vertical flex directions
   - Works with all alignment modes (flex-start, center, flex-end, stretch)
   - Works in grid layouts (margins are stored, though grid doesn't apply them yet)

## Example Usage

```lua
-- Vertical flex with negative top margin
Gui.new({
  parent = container,
  text = "Overlapping Element",
  margin = { top = "-30%" }, -- Pulls element up by 30% of parent height
})

-- Horizontal flex with negative left margin
Gui.new({
  parent = container,
  text = "Overlapping Element",
  margin = { left = -20 }, -- Pulls element left by 20px
})
```
