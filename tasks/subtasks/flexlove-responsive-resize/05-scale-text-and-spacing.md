# 05. Scale Text Size, Padding, Margins, and Gap

meta:
  id: flexlove-responsive-resize-05
  feature: flexlove-responsive-resize
  priority: P2
  depends_on: [flexlove-responsive-resize-04]
  tags: [implementation, text-scaling, spacing-scaling]

objective:
- Implement proportional scaling for text size, padding, margins, and gap properties during window resize
- Ensure typography and spacing maintain visual consistency across different screen sizes
- Provide smooth responsive behavior for all spacing and text elements

deliverables:
- Updated Element:resize() method to scale text size proportionally
- Proportional scaling for padding (top, right, bottom, left) properties
- Proportional scaling for margin (top, right, bottom, left) properties  
- Proportional scaling for gap property used in flex layouts
- Maintained text readability and spacing relationships after resize

steps:
- Add text size scaling logic to Element:resize() method using window scale factors
- Implement padding scaling that maintains proportional spacing around content
- Implement margin scaling that maintains proportional spacing between elements
- Add gap scaling for flex containers to maintain consistent child spacing
- Update font cache system to handle scaled font sizes efficiently
- Ensure scaled text sizes remain within readable bounds (min/max constraints)
- Update spacing calculations in layout system to use scaled values
- Add support for viewport-relative text and spacing units (em, rem-like behavior)

tests:
- Unit: Test text size scaling with different window resize ratios (Arrange–Act–Assert)
- Unit: Test padding scaling maintains proportional spacing around content
- Unit: Test margin scaling maintains proportional spacing between siblings
- Unit: Test gap scaling in flex containers maintains consistent child spacing
- Integration: Test complex layouts with mixed text sizes and spacing scale together
- Integration: Test nested elements inherit scaled spacing appropriately

acceptance_criteria:
- Text sizes scale proportionally maintaining legibility and visual hierarchy
- Padding scales proportionally maintaining content spacing relationships
- Margins scale proportionally maintaining element spacing relationships
- Gap property scales proportionally maintaining flex child spacing
- Scaled text sizes remain within reasonable bounds (not too small/large)
- Font cache handles scaled font sizes efficiently without performance issues
- All spacing and typography maintains visual consistency after resize
- Mixed unit types (px, %, viewport units) for spacing work correctly

validation:
- Test: Element with textSize=16 at 800px width scales to textSize=32 at 1600px width
- Test: Padding of {top=10, left=20} scales to {top=20, left=40} with 2x window scale
- Test: Gap of 15px in flex container scales to 30px with 2x window scale
- Test: Complex layouts maintain visual balance and hierarchy after resize
- Verify: Text remains readable at all common screen sizes and scale factors

notes:
- Consider implementing min/max constraints for text sizes (e.g., 8px to 72px)
- Font cache should efficiently handle fractional font sizes from scaling
- Spacing scaling should work with existing layout calculations without conflicts
- Text scaling should preserve relative size relationships between different text elements