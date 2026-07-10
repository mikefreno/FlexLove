# 05. Registry-Driven setProperty Dispatch

meta:
  id: reduce-loc-simplify-architecture-05
  feature: reduce-loc-simplify-architecture
  priority: P0
  depends_on: [reduce-loc-simplify-architecture-02]
  tags: [implementation, refactor, tests-required]

objective:

- Replace the inline if-chain special cases in `setProperty` (dimension units, themeComponent, parent, layout invalidation, transition wiring) with a single dispatch driven by schema flags so adding a prop requires no new branch.

deliverables:

- `Element:setProperty` rewritten to: (1) check schema for `affectsLayout`/`isDimension`/`syncsTheme`/`hasDeferred` flags, (2) route dimension/unit props through `_resolveDimensionProperty`, (3) route `parent` and `themeComponent` via a small explicit handler map, (4) handle transitions generically, (5) invalidate/sync based on flags — all without inline hardcoded property-name checks.
- Removal of the per-call `layoutProperties`/`dimensionProperties` table construction.
- Tests confirming setProperty behavior parity for transitions, units, layout invalidation, and theme sync.

steps:

- Map each existing `if property == "..."` special case in `setProperty` to a schema flag or an explicit handler-map entry.
- Introduce a `_specialSetHandlers` table (module scope) keyed by prop name for the ~3 genuinely-special cases (parent→setParent, themeComponent→_syncThemeAndRenderer, dimension units→resolve). Everything else is generic.
- Rewrite `setProperty` body to consult schema flags for layout invalidation and theme sync.
- Ensure transition logic consults `self.transitions[property] or self.transitions["all"]` as before, driven by schema `hasTransition` flag or the existing check.
- Run the full suite.

tests:

- Unit: setting a dimension prop with a unit string resolves to pixels and invalidates; setting a layout prop invalidates; setting a non-layout prop does not; transition fires when configured.
- Integration: `transition_test.lua`, `flex_grow_shrink_test.lua`, `theme_test.lua`, `element_test.lua` pass unchanged.

acceptance_criteria:

- `grep -n "if property ==" modules/Element.lua` within `setProperty` returns ≤3 matches (only the explicit handler-map delegates).
- No per-call table literal in `setProperty`.
- `setProperty` body is ≤ ~60 LOC (down from ~120).
- Test suite matches baseline.

validation:

- `lua testing/__tests__/transition_test.lua` exits 0.
- `lua testing/__tests__/element_test.lua` exits 0.
- `lua testing/runAll.lua --no-coverage` matches baseline.

notes:

- Coordinate with task 04 — this task subsumes it if done first. Don't duplicate effort; whoever lands second should mark 04 as completed-by-inclusion.
- The explicit handler map is acceptable: the goal is no *new* ad-hoc branches, not zero special cases for genuinely-different semantics.
