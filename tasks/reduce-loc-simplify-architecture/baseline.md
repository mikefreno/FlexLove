# Baseline Metrics and Audit — `reduce-loc-simplify-architecture`

> Captured by Task 01. **Read-only reference point** — no source was modified to produce this artifact. Every later task should measure its delta against the numbers recorded here.
>
> All metrics are for the FlexLove library located at `game/libs/` (a git submodule of `station_alpha`). Paths below are relative to `game/libs/`.

Capture date: 2026-07-10
Lua: 5.4.4
Test command: `lua testing/runAll.lua --no-coverage`

---

## 1. Per-file LOC (non-test source)

Source set = `modules/*.lua` + `FlexLove.lua`. Test files (`testing/__tests__/*.lua`) and demo/profiling sources are excluded.

### Totals

| Metric | Value |
|---|---|
| Total non-test source LOC | **27,893** |
| File count (`modules/*.lua` + `FlexLove.lua`) | 34 |
| `Element.lua` LOC | **4,748** |
| `Element.lua` exit-criteria target | ≤ 3,100 (≥ 35% reduction) |
| Total non-test source LOC exit-criteria target | ≥ 20% reduction → ≤ 22,314 |

### Top 15 largest files (sorted desc)

| Rank | File | LOC |
|---:|---|---:|
| 1 | `modules/Element.lua` | 4,748 |
| 2 | `FlexLove.lua` | 1,879 |
| 3 | `modules/TextEditor.lua` | 1,772 |
| 4 | `modules/Theme.lua` | 1,655 |
| 5 | `modules/LayoutEngine.lua` | 1,653 |
| 6 | `modules/Animation.lua` | 1,520 |
| 7 | `modules/utils.lua` | 1,335 |
| 8 | `modules/Renderer.lua` | 1,276 |
| 9 | `modules/ErrorHandler.lua` | 1,149 |
| 10 | `modules/ScrollManager.lua` | 1,084 |
| 11 | `modules/KeyboardNavigation.lua` | 983 |
| 12 | `modules/EventHandler.lua` | 850 |
| 13 | `modules/MemoryScanner.lua` | 697 |
| 14 | `modules/Blur.lua` | 686 |
| 15 | `modules/Select.lua` | 674 |

### Complete per-file LOC (all sources, sorted desc)

| File | LOC |
|---|---:|
| `modules/Element.lua` | 4,748 |
| `FlexLove.lua` | 1,879 |
| `modules/TextEditor.lua` | 1,772 |
| `modules/Theme.lua` | 1,655 |
| `modules/LayoutEngine.lua` | 1,653 |
| `modules/Animation.lua` | 1,520 |
| `modules/utils.lua` | 1,335 |
| `modules/Renderer.lua` | 1,276 |
| `modules/ErrorHandler.lua` | 1,149 |
| `modules/ScrollManager.lua` | 1,084 |
| `modules/KeyboardNavigation.lua` | 983 |
| `modules/EventHandler.lua` | 850 |
| `modules/MemoryScanner.lua` | 697 |
| `modules/Blur.lua` | 686 |
| `modules/Select.lua` | 674 |
| `modules/StateManager.lua` | 664 |
| `modules/types.lua` | 662 |
| `modules/GestureRecognizer.lua` | 615 |
| `modules/Performance.lua` | 566 |
| `modules/Calc.lua` | 385 |
| `modules/ImageRenderer.lua` | 380 |
| `modules/Context.lua` | 355 |
| `modules/Color.lua` | 346 |
| `modules/Grid.lua` | 336 |
| `modules/Units.lua` | 335 |
| `modules/FocusIndicator.lua` | 244 |
| `modules/NinePatch.lua` | 217 |
| `modules/ModuleLoader.lua` | 202 |
| `modules/ImageScaler.lua` | 174 |
| `modules/ImageCache.lua` | 160 |
| `modules/RoundedRect.lua` | 124 |
| `modules/InputEvent.lua` | 88 |
| `modules/UTF8.lua` | 44 |
| `modules/ZIndex.lua` | 35 |
| **TOTAL** | **27,893** |

---

## 2. Element.lua metrics

| Metric | Value | Notes |
|---|---:|---|
| Total LOC | 4,748 | file via `wc -l` |
| Total methods (`grep -c "^function Element:"`) | 143 | `Element:method` instance methods |
| `Element.new` LOC | 1,651 | lines 259–1909 (a single monolith) |
| `props.X` reads in `Element.new` | **350** | `props.` occurrences within lines 259–1909 |
| `self.X = props.X` copy pairs | **96** | hand-written `self.<f> = props.<f>` boilerplate within `Element.new` |
| `Deferred` boilerplate lines (whole file) | 27 | of which **14** are inside `Element.new` |
| `ErrorHandler` call sites (whole file) | 45 | of which **25** are inside `Element.new` |

### `Element.new` is the dominant monolith

`Element.new(props)` spans lines **259 → 1909 = 1,651 LOC**, far exceeding the exit-criteria cap of "no function > ~400 LOC". It is the single largest function in the file and the primary target of Task 10 (split into staged initializers) and Task 03 (data-driven prop binding).

### Largest functions in `Element.lua` (by LOC span to next `function Element` definition)

| Rank | LOC | Function |
|---:|---:|---|
| 1 | 1,651 | `Element.new(props)` |
| 2 | 343 | `Element:update(dt)` |
| 3 | 197 | `Element:draw(backdropCanvas)` |
| 4 | 127 | `Element:setProperty(property, value)` |
| 5 | 103 | `Element.init(deps)` |
| 6 | 100 | `Element:addChild(child)` |
| 7 | 63 | `Element:saveState()` |
| 8 | 55 | `Element:_loadImage()` |
| 9 | 53 | `Element:setParent(newParent)` |
| 10 | 53 | `Element:restoreState(state)` |
| 11 | 47 | `Element:destroy()` |
| 12 | 45 | `Element:_resolveDimensionProperty(property, value)` |
| 13 | 44 | `Element:removeChild(child)` |
| 14 | 42 | `Element:resize(newGameWidth, newGameHeight)` |
| 15 | 37 | `Element:isFocusable()` |

### `setProperty` special-case branches (Task 05 target)

`Element:setProperty` (lines 4291–4417, 127 LOC) currently contains **inline special-case branches** that the exit criteria require be driven by schema flags instead:

1. **Dimension/unit branch** — `if dimensionProperties[property] and isUnitValue then ...` resolves width/height unit strings inline, calls `_resolveDimensionProperty`, and short-circuits layout invalidation. The `dimensionProperties` lookup table is defined *inside* `setProperty` on every call.
2. **`themeComponent` branch** — `if property == "themeComponent" then ...` directly assigns `self.themeComponent = value` and calls `_syncThemeAndRenderer`, with no registry/hook indirection.
3. **`parent` branch** — `if property == "parent" then self:setParent(value); return end` is another inline special case.
4. **Layout-properties branch** — `if layoutProperties[property] then self:invalidateLayout() end` with the `layoutProperties` table rebuilt inside the function each call (16 layout-affecting keys: `width`, `height`, `padding`, `margin`, `gap`, `flexDirection`, `flexWrap`, `justifyContent`, `alignItems`, `alignContent`, `positioning`, `gridRows`, `gridColumns`, `top`, `right`, `bottom`, `left`).

All four are candidates for removal in Task 05 (`registry-driven-setproperty-dispatch`) once the schema registry (Task 02) and data-driven prop binding (Task 03) land.

### Deferred boilerplate pairs (Task 03 target)

Inside `Element.new`, the `Deferred` pattern appears as hand-written `self.<cb> = props.<cb>; self.<cb>Deferred = props.<cb>Deferred or false` pairs. Current occurrences (lines relative to `Element.new` start = file line 259):

| File line | Field |
|---:|---|
| 89 | `onFocusDeferred` |
| 92 | `onBlurDeferred` |
| 94 | `onTextInputDeferred` |
| 96 | `onTextChangeDeferred` |
| 98 | `onEnterDeferred` |
| 100 | `onCreateDeferred` |
| 106 | `onTouchEventDeferred` |
| 108 | `onGestureDeferred` |
| 579 | `onImageLoadDeferred` |
| 581 | `onImageErrorDeferred` |

Plus an `onEventDeferred`-style block around file lines 118–122 that assembles a delegated event table. These pairs are the explicit "zero boilerplate" exit-criteria target — Task 03 must route them through the schema registry instead.

### `ErrorHandler` call sites (Task 11 target)

`Element.lua` has **45** `ErrorHandler` references (whole file), **25** of which are inside `Element.new`. Task 11 (`trim-defensive-errorhandler-instrumentation`) will prune the defensive ones.

---

## 3. Element method categorization by subsystem

For the extraction tasks (06 select, 07 scrollbar, 08 text-selection). Method counts are subsets of the 143 total `Element:` methods.

### Select subsystem — Task 06 (`extract-select-subsystem-from-element`)

23 methods are select-specific and should be delegated to a `Select`-backed subsystem rather than living on `Element`:

`_resetSelectOptions`, `_isValidSelectFrame`, `_warnSelectFrame`, `_trackManagedSelectFrame`, `_getOrCreateManagedSelectAnchor`, `_applyManagedSelectFrameLayout`, `_adoptSelectFrame`, `_ensureSelectFrameState`, `_syncManagedSelectFrameVisibility`, `_findOwningSelectParent`, `_registerWithSelectParent`, `_attachSelectOptionToManagedFrame`, `_unregisterFromSelectParent`, `_saveSelectStateToStateManager`, `openSelect`, `closeSelect`, `toggleSelect`, `isSelectOpen`, `getSelectValue`, `getSelectLabel`, `isSelectedSelectOption`, `setSelectValue`, `_handleSelectRelease`, `_adjustAutoWidthChildBorderBoxForManagedSelect`.

(Existing `modules/Select.lua` = 674 LOC is the likely delegation target.)

### Scrollbar / scroll subsystem — Task 07 (`extract-scrollbar-handling-from-element`)

20 methods handle scroll state, overflow detection, scrollbar geometry, and wheel/drag:

`_syncScrollManagerState`, `_detectOverflow`, `setScrollPosition`, `_calculateScrollbarDimensions`, `_getScrollbarAtPosition`, `_handleScrollbarPress`, `_handleScrollbarDrag`, `_handleScrollbarRelease`, `_handleWheelScroll`, `getScrollPosition`, `getMaxScroll`, `getScrollPercentage`, `hasOverflow`, `getContentSize`, `scrollBy`, `scrollToTop`, `scrollToBottom`, `scrollToLeft`, `scrollToRight`, `_deferMethod`.

(Existing `modules/ScrollManager.lua` = 1,084 LOC is the likely delegation target.)

### Text-selection / cursor subsystem — Task 08 (`extract-texteditor-selection-from-element`)

29 methods implement text editing, cursor movement, selection, and text measurement directly on `Element`:

`setCursorPosition`, `getCursorPosition`, `moveCursorBy`, `moveCursorToStart`, `moveCursorToEnd`, `moveCursorToLineStart`, `moveCursorToLineEnd`, `moveCursorToPreviousWord`, `moveCursorToNextWord`, `setSelection`, `getSelection`, `hasSelection`, `clearSelection`, `selectAll`, `getSelectedText`, `deleteSelection`, `getText`, `setText`, `insertText`, `deleteText`, `replaceText`, `_wrapLine`, `_getFont`, `_handleTextClick`, `_handleTextDrag`, `textinput`, `keypressed`, `calculateTextWidth`, `calculateTextHeight`, `calculateAutoWidth`, `calculateAutoHeight`, `updateText`.

(Existing `modules/TextEditor.lua` = 1,772 LOC is the likely delegation target.)

### Subsystem overlap notes

- `_adjustAutoWidthChildBorderBoxForManagedSelect` ties select to layout and may need shared ownership with the layout path — flag for Task 06 review.
- `_deferMethod` is currently used by scroll methods (`scrollToTop`, `scrollToBottom`, etc.) and may belong with the scroll subsystem (Task 07) rather than Element core.
- `textinput` / `keypressed` are input-entry points currently on `Element`; Task 08 should ensure they delegate into a `TextEditor` instance.
- `calculateTextWidth` / `calculateTextHeight` / `calculateAutoWidth` / `calculateAutoHeight` double as layout helpers, so Task 08 should expose them on the delegated `TextEditor` rather than delete them outright.

---

## 4. `utils.lua` metrics (Task 09 target)

| Metric | Value |
|---|---:|
| `modules/utils.lua` LOC | **1,335** |
| Exit-criteria target | split into ≥ 3 focused modules; no single utils file > ~400 LOC |

Task 09 (`split-utils-into-focused-modules`) will break `utils.lua` into at least three focused modules each ≤ ~400 LOC.

---

## 5. Test results snapshot (regression baseline)

Command: `lua testing/runAll.lua --no-coverage`
Working dir: `game/libs/`
Exit code: **0**

| Metric | Value |
|---|---|
| Total assertions/tests | **1,764** |
| Successes | **1,764** |
| Failures | **0** |
| Skips | **0** |
| Wall time | ~47.7–48.3 s |
| Test files | 39 |

Suite status: **all green**, no pre-existing failures. No pre-existing failures need to be documented or exempted — later tasks must keep this count at 1,764 / 0 / 0 (or explicitly justify deltas in Task 12).

### Per-test-file result (all ✓)

1. `absolute_positioning_test.lua`
2. `animation_chaining_test.lua`
3. `animation_group_test.lua`
4. `animation_test.lua`
5. `blur_test.lua`
6. `calc_test.lua`
7. `critical_failures_test.lua`
8. `deferred_image_loading_test.lua`
9. `element_mode_override_test.lua`
10. `element_test.lua`
11. `event_handler_test.lua`
12. `flex_grow_shrink_test.lua`
13. `flexlove_test.lua`
14. `grid_test.lua`
15. `image_cache_test.lua`
16. `image_renderer_test.lua`
17. `image_scaler_test.lua`
18. `init_queue_test.lua`
19. `input_event_test.lua`
20. `keyboard_navigation_test.lua`
21. `layout_engine_test.lua`
22. `module_loader_test.lua`
23. `ninepatch_test.lua`
24. `performance_test.lua`
25. `release_variants_test.lua`
26. `renderer_test.lua`
27. `roundedrect_test.lua`
28. `scroll_manager_test.lua`
29. `scrollbar_placement_test.lua`
30. `select_test.lua`
31. `test_children_prop.lua`
32. `test_display.lua`
33. `test_textalign.lua`
34. `text_editor_test.lua`
35. `theme_test.lua`
36. `touch_test.lua`
37. `transition_test.lua`
38. `units_test.lua`
39. `utils_test.lua`

> Repo: this list is the full set of test files discovered by `runAll.lua` under `testing/__tests__/`. Task 12 should compare coverage parity against this exact set.

---

## 6. Measurement methodology (for reproducibility)

- **LOC**: `wc -l` against `modules/*.lua FlexLove.lua` (non-test source only).
- **Element method count**: `grep -c "^function Element:" modules/Element.lua`.
- **`Element.new` span**: line of `function Element.new(props)` (259) through the line before the next `function Element` definition (`Element:getBounds` at 1910) → 1,651 LOC.
- **`props.X` reads in `Element.new`**: `sed -n '259,1909p' | grep -c "props\."` = 350.
- **`self.X = props.X` copies in `Element.new`**: `sed -n '259,1909p' | grep -cE "self\.[a-zA-Z_]+ = props\."` = 96.
- **`Deferred` lines**: `grep -c "Deferred"`; scoped variant `sed -n '259,1909p' | grep -c "Deferred"`.
- **`ErrorHandler` call sites**: `grep -c "ErrorHandler"`; scoped variant for `Element.new`.
- **Largest functions**: span = line of a `function Element` definition through the line before the next one.
- **Tests**: `lua testing/runAll.lua --no-coverage`; pass/fail counts taken from the final `All tests passed` line plus the intermediate per-suite `Ran N tests …` lines.

To reproduce the baseline:

```sh
cd game/libs
lua testing/runAll.lua --no-coverage
wc -l modules/*.lua FlexLove.lua | sort -rn
grep -c "^function Element:" modules/Element.lua
```

---

## 7. Notes for downstream tasks

- The exit-criteria number for `Element.lua` in the feature brief is "≤3,100 LOC from 4,757". The actual baseline LOC is **4,748** (the 4,757 figure is slightly stale). Use **4,748** as the reduction denominator; a 35% cut yields a target of **≤ 3,086**, comfortably under the 3,100 cap.
- The total non-test source LOC baseline of **27,893** is the denominator for the ≥20% reduction exit criterion → target ≤ **22,314**.
- `Element.new` (1,651 LOC) alone accounts for ~35% of `Element.lua`. Splitting it (Task 10) and removing prop/Deferred boilerplate (Tasks 03, 11) will do most of the Element LOC reduction.
- `setProperty` (127 LOC, 4 inline special-case branches) is fully covered by Task 05; the layout/affecting and dimension properties tables currently live inside the function and should be hoisted/registered (Task 04 + Task 02).
- The test suite has **zero** pre-existing failures, so any failure introduced by a later task is a regression attributable to that task.
