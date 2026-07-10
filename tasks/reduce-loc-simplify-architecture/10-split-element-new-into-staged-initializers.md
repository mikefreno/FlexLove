# 10. Split Element.new Into Staged Initializers

meta:
  id: reduce-loc-simplify-architecture-10
  feature: reduce-loc-simplify-architecture
  priority: P0
  depends_on: [reduce-loc-simplify-architecture-03, reduce-loc-simplify-architecture-05, reduce-loc-simplify-architecture-06, reduce-loc-simplify-architecture-07, reduce-loc-simplify-architecture-08]
  tags: [implementation, refactor, architecture, tests-required]

objective:

- Break the 1,647-line `Element.new` god-constructor (lines 274–1920) into a sequence of focused, individually-testable phases so no single function exceeds ~400 LOC.

deliverables:

- `Element.new` reduced to an orchestrator (≤ ~80 LOC) that calls, in order:
  - `Element:_construct(props)` — metatable, deps, ID generation, default tables (`children`, `_deferredMethods`).
  - `self:_applyProps(props)` — schema-driven binding (from task 03).
  - `self:_initSubsystems(props)` — instantiate EventHandler, Renderer, LayoutEngine, TextEditor, ScrollManager via their deps tables (deduplicated, not rebuilt inline).
  - `self:_initVisualState(props)` — border/cornerRadius/opacity/visibility/display/theme normalization.
  - `self:_initImageAndContent(props)` — image loading, content measurement, deferred-image handling.
  - `self:_restoreState()` — immediate-mode StateManager hydration (textEditor, select, scroll state).
- Dep tables (`eventHandlerDeps`, `rendererDeps`, etc.) hoisted to module scope or `Element.init`, not rebuilt per construction.
- Updated tests.

steps:

- Map the current `Element.new` body into the 6 phases above by line range.
- Extract each phase into its own method, moving code verbatim first (no logic change).
- Replace the `Element.new` body with the orchestration calls.
- Hoist the 5 `*Deps` tables out of the per-construction path.
- Decompose any phase still >400 LOC (likely `_initVisualState` or `_initImageAndContent`) into sub-methods.
- Run the full suite — behavioral parity required.

tests:

- Unit: each phase method callable in isolation with a constructed `self` and minimal props (where feasible).
- Integration: `element_test.lua`, `init_queue_test.lua`, `element_mode_override_test.lua`, full suite green — identical behavioral output.

acceptance_criteria:

- `Element.new` body ≤ ~80 LOC.
- No single Element method/f phase > ~400 LOC.
- The 5 `*Deps` tables are created once, not per `new()` call.
- Test suite matches baseline.
- `wc -l modules/Element.lua` shows significant reduction vs baseline (cumulative with 06–08).

validation:

- `lua testing/__tests__/element_test.lua` exits 0.
- `lua testing/__tests__/init_queue_test.lua` exits 0.
- `lua testing/runAll.lua --no-coverage` matches baseline.
- `awk '/^function Element.new/,/^end/' modules/Element.lua | wc -l` ≤ ~100.

notes:

- This is the capstone refactor — depends on the extraction tasks (03, 05, 06–08) landing first so the phases have clean seams.
- Resist the urge to "improve" logic while extracting; preserve behavior exactly. Refactor ≠ rewrite.
- If a phase is stubbornly large, the likely culprit is inline theme/image normalization — those are candidates for a ThemeNormalizer / ImageInit helper, but only if needed to hit the LOC target.
