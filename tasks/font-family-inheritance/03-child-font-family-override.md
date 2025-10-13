# Child Font Family Override Handling

## Objective
Implement logic to handle cases where child elements explicitly set their own font family, overriding inherited values.

## Key Requirements
- Children should be able to explicitly set fontFamily without inheriting from parent
- Explicit font family settings on children should take precedence over inherited values
- The override mechanism should work both for direct settings and theme-based settings
- Inheritance should still work when no explicit font family is set on child

## Implementation Plan
1. Add logic to check if child has explicitly set fontFamily
2. Implement override priority system (explicit > inherited)
3. Ensure the override works with theme system
4. Create tests for override scenarios

## Files to Modify
- FlexLove.lua (layout system core)
- Theme system files (space.lua, themes/README.md)

## Acceptance Criteria
- Explicit font family settings on children override inherited values
- Override works when child has themeComponent set and explicit fontFamily
- Inheritance still works when child doesn't explicitly set fontFamily