# 03. Data-Driven Prop Binding in Element.new

meta:
  id: reduce-loc-simplify-architecture-03
  feature: reduce-loc-simplify-architecture
  priority: P0
  depends_on: [reduce-loc-simplify-architecture-02]
  tags: [implementation, refactor, tests-required]

objective:

- Replace the 96 hand-written `self.X = props.X` assignment lines and 27 `onXDeferred` boilerplate pairs in `Element.new` with a single schema-driven binding loop.

deliverables:

- A `Element:_applyProps(props)` method (or local function) that iterates `PropertySchema` entries, applies defaults, runs normalizers, and stores values — including auto-wiring `onX` + `onXDeferred` pairs generically.
- Reduced `Element.new` body: the props-binding section shrinks from ~350 reads to a loop call.
- Updated/added tests verifying that props bind identically to the baseline behavior.

steps:

- Identify the prop-binding region of `Element.new` (roughly lines 317–560 plus scattered assignments through 1920).
- Extract `_applyProps(props)` that: (a) iterates schema entries, (b) reads `props[name]` or `default`, (c) calls `normalizer(value)` if present, (d) calls `validator` if present, (e) stores at `storageKey` or `name`, (f) generically handles `hasDeferred` entries by also reading `name.."Deferred"`.
- Handle the handful of props that need side-effects (parent, themeComponent, border table-shape) by routing them through a `specialHandler` map keyed by prop name — small, explicit, documented.
- Replace the inline binding in `Element.new` with `self:_applyProps(props)`.
- Run the full element test suite; fix any behavioral drift.

tests:

- Unit: `_applyProps` correctly applies defaults when prop absent; respects explicit overrides; normalizers transform values (padding single-value → table, flexDirection row→horizontal); Deferred companions default to false when omitted.
- Integration: `element_test.lua` passes unchanged (behavioral parity); `test_children_prop.lua`, `element_mode_override_test.lua` green.

acceptance_criteria:

- `grep -c "self\.[a-zA-Z_]* = props\." modules/Element.lua` drops from ~96 to ≤15 (only genuinely-special props remain).
- `grep -c "Deferred" modules/Element.lua` drops significantly (auto-wired, not hand-listed).
- No test regressions vs baseline.
- Adding a new prop requires only a schema entry, not an Element.new edit.

validation:

- `lua testing/__tests__/element_test.lua` exits 0.
- `lua testing/runAll.lua --no-coverage` matches baseline pass/fail.
- `grep -c "self\.[a-zA-Z_]* = props\." modules/Element.lua` shows the reduction.

notes:

- Border/cornerRadius/scrollbar shape-normalization (number vs table vs nil) are legitimate special handlers — keep them in the explicit map, don't force them into generic binding.
- This is the highest-risk task for behavior drift; run the full suite immediately after.
