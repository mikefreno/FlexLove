# 08. Extract TextEditor Selection from Element

meta:
  id: reduce-loc-simplify-architecture-08
  feature: reduce-loc-simplify-architecture
  priority: P1
  depends_on: [reduce-loc-simplify-architecture-03]
  tags: [implementation, refactor, tests-required]

objective:

- Move the 7 TextEditor text-selection methods currently on Element (`setSelection`, `getSelection`, `hasSelection`, `clearSelection`, `selectAll`, `getSelectedText`, `deleteSelection`) into `TextEditor.lua`, with Element delegating.

deliverables:

- All 7 selection methods moved to `TextEditor.lua` as `TextEditor.setSelection(element, ...)` etc.
- Element methods replaced with 1-line delegates or direct assignment.
- `TextEditor.lua` is the sole owner of text-selection state and operations.
- Text editor tests passing.

steps:

- Inventory selection methods on Element (lines ~3682–3740).
- Move each into `TextEditor.lua`, converting `self` → `element` and routing through `self._textEditor` where internal state lives.
- Replace Element method bodies with delegates.
- Update any `EventHandler`/keyboard-navigation call sites that invoke these on element directly.
- Run text editor + keyboard nav tests + full suite.

tests:

- Unit: `TextEditor.setSelection` sets [start,end]; `getSelectedText` returns substring; `deleteSelection` removes range; `selectAll` spans full text.
- Integration: `text_editor_test.lua`, `keyboard_navigation_test.lua` pass unchanged.

acceptance_criteria:

- `grep -c "function Element:.*[Ss]election\|function Element:selectAll" modules/Element.lua` drops to 0 (or 1-line delegates).
- `TextEditor.lua` is the sole owner of selection logic.
- Test suite matches baseline.
- Element.lua LOC reduced by the moved methods (~50–100 LOC).

validation:

- `lua testing/__tests__/text_editor_test.lua` exits 0.
- `lua testing/__tests__/keyboard_navigation_test.lua` exits 0.
- `lua testing/runAll.lua --no-coverage` matches baseline.

notes:

- `TextEditor.lua` already exists (1772 LOC) and holds most logic — this finishes the extraction for the selection cluster.
- `KeyboardNavigation.lua` may call `element:selectAll` etc. — update those call sites to delegate or keep the 1-line delegate.
