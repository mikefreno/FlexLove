# 07. Extract Scrollbar Handling from Element

meta:
  id: reduce-loc-simplify-architecture-07
  feature: reduce-loc-simplify-architecture
  priority: P1
  depends_on: [reduce-loc-simplify-architecture-03]
  tags: [implementation, refactor, tests-required]

objective:

- Move the 16 scrollbar/scroll methods living on the Element class into `ScrollManager.lua`, so Element only delegates (`element:scrollToTop()` → `ScrollManager.scrollToTop(element)`).

deliverables:

- Methods moved out of Element: `_syncScrollManagerState`, `_detectOverflow`, `setScrollPosition`, `_calculateScrollbarDimensions`, `_getScrollbarAtPosition`, `_handleScrollbarPress`, `_handleScrollbarDrag`, `_handleScrollbarRelease`, `_handleWheelScroll`, `getScrollPosition`, `getMaxScroll`, `getScrollPercentage`, `hasOverflow`, `getContentSize`, `scrollBy`, `scrollToTop/Bottom/Left/Right`.
- Element retains 1-line delegates or direct method assignment (`Element.scrollToTop = ScrollManager.scrollToTop`).
- `ScrollManager.lua` owns the scrollbar interaction lifecycle.
- Updated scroll tests passing.

steps:

- Inventory the 16 scroll/scrollbar methods on Element (lines ~1988–2305).
- Move each into `ScrollManager.lua` as `ScrollManager.<fn>(element, ...)`, converting `self` → `element`.
- In Element, replace bodies with delegates or direct assignment.
- Handle the scrollbar press/drag/release routing in `EventHandler` so it calls `ScrollManager` directly rather than `element:_handleScrollbar...`.
- Run scroll tests + full suite.

tests:

- Unit: `ScrollManager.scrollToTop(element)` clamps correctly; `getMaxScroll` returns expected bounds; `_handleScrollbarDrag` updates scroll position within bounds.
- Integration: `scroll_manager_test.lua`, `scrollbar_placement_test.lua`, `touch_test.lua` pass unchanged.

acceptance_criteria:

- `grep -c "function Element:.*[Ss]croll\|function Element:.*Scrollbar" modules/Element.lua` drops to 0 (or 1-line delegates).
- `ScrollManager.lua` is the sole owner of scrollbar interaction logic.
- Scroll-related tests pass unchanged.
- Element.lua LOC reduced by the moved methods (~250–350 LOC).

validation:

- `lua testing/__tests__/scroll_manager_test.lua` exits 0.
- `lua testing/__tests__/scrollbar_placement_test.lua` exits 0.
- `lua testing/runAll.lua --no-coverage` matches baseline.

notes:

- `ScrollManager.lua` already exists (1084 LOC) — this completes the extraction. Some of these methods may already be thin delegates; check before moving.
- Event routing in `EventHandler` or `GestureHandler` may call element methods directly — update call sites.
