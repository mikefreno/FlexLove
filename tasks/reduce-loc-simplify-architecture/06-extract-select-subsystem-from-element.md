# 06. Extract Select Subsystem from Element

meta:
  id: reduce-loc-simplify-architecture-06
  feature: reduce-loc-simplify-architecture
  priority: P1
  depends_on: [reduce-loc-simplify-architecture-03]
  tags: [implementation, refactor, tests-required]

objective:

- Move the 31 Select-related methods and managed-frame logic currently defined directly on the Element class into `Select.lua`, leaving Element as a thin delegate (`element:openSelect()` → `Select.open(self)`).

deliverables:

- All `Element:openSelect/closeSelect/toggleSelect/...` and `Element._rebuildSelectOptionLookup`/`_syncSelectOptionStates` plus the ~20 private `_...Select...` helpers moved into `Select.lua` as functions taking `element` as first arg (or a Select mixin table mixed into Element).
- Element retains only thin delegation or a mixin composition: `function Element:openSelect() return Select.open(self) end` (or `Element:openSelect = Select.open`).
- The `_adjustAutoWidthChildBorderBoxForManagedSelect` special case in layout (line ~2823) routed through Select.
- Updated `select_test.lua` passing.

steps:

- Inventory all Select methods on Element (grep `Select` in Element.lua — ~31 functions, lines ~2417–2830).
- Move each into `Select.lua` (which already holds `Select.initSelectParent` etc.), converting `self` → `element` parameter.
- In Element, replace method bodies with delegates to `Select.<fn>(self)` OR assign `Element.openSelect = Select.open` style.
- Move the managed-frame layout special-case behind a `Select.adjustAutoWidthChild(...)` call invoked from the layout path.
- Update `Select.init` deps if it needs additional references (Element/LayoutEngine).
- Run select tests + full suite.

tests:

- Unit: `Select.open(element)`, `Select.toggle(element)`, `Select.getValue(element)` exercise state transitions identically to baseline.
- Integration: `select_test.lua`, `scrollbar_placement_test.lua` (if select+scroll interaction), full suite green.

acceptance_criteria:

- `grep -c "function Element:.*Select\|function Element:.*select" modules/Element.lua` drops to 0 (or only 1-line delegates).
- `Select.lua` is the sole owner of select state-machine logic.
- `select_test.lua` passes unchanged.
- Element.lua LOC reduced by the moved methods (~400–500 LOC).

validation:

- `lua testing/__tests__/select_test.lua` exits 0.
- `wc -l modules/Element.lua` shows reduction vs baseline.
- `lua testing/runAll.lua --no-coverage` matches baseline.

notes:

- `Select.lua` already exists and holds some logic — this task completes the extraction. Check it isn't already half-done.
- Preserve the `_selectState` table structure on elements; only move the *methods*, not the per-instance state.
