# 04. Hoist Lookup Tables to Module Scope

meta:
  id: reduce-loc-simplify-architecture-04
  feature: reduce-loc-simplify-architecture
  priority: P2
  depends_on: [reduce-loc-simplify-architecture-01]
  tags: [implementation, performance, refactor]

objective:

- Eliminate per-call construction of `layoutProperties` and `dimensionProperties` tables inside `setProperty` (and any other hot-path in-function table literals) by hoisting them to module-level upvalues / the PropertySchema registry.

deliverables:

- `layoutProperties` and `dimensionProperties` removed from `setProperty`; replaced by `PropertySchema.affectsLayout(name)` / `PropertySchema.isDimension(name)` lookups (schema-driven) or module-scope constant tables.
- Any other in-function literal tables used for dispatch on hot paths identified and hoisted.
- No behavioral change; tests unchanged and green.

steps:

- In `setProperty` (line ~4277), find the two locally declared tables `layoutProperties` and `dimensionProperties`.
- Replace membership checks with `PropertySchema` flag lookups (task 02 metadata: `affectsLayout`, `isDimension`) — if task 05 lands first, this is already done; otherwise use module-scope `local` tables.
- Audit `Element.new` and `Renderer:draw` for other per-call table literals used purely for membership/dispatch; hoist any found.
- Run tests to confirm no regressions.

tests:

- Unit: `setProperty("width", "100px")` still resolves units and invalidates layout; `setProperty("opacity", 0.5)` does not invalidate layout.
- Integration: `flex_grow_shrink_test.lua`, `layout_engine_test.lua`, `units_test.lua` pass unchanged.

acceptance_criteria:

- `grep -n "local layoutProperties\|local dimensionProperties" modules/Element.lua` returns zero matches.
- No new table allocated per `setProperty` call for dispatch/membership.
- Test suite matches baseline.

validation:

- `lua testing/__tests__/flex_grow_shrink_test.lua` exits 0.
- `lua testing/runAll.lua --no-coverage` matches baseline.

notes:

- This task is a quick win and can be done early/independently. If task 05 (registry-driven setProperty) is done first, it subsumes this — mark completed by inclusion.
- Coordinate with task 05 to avoid double-editing the same region.
