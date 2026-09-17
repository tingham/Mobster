> **Superseded.** This is a historical record of what was asked for at the time. The authority is [Design/Mobster.md](../Design/Mobster.md). Requirement identifiers cited below may no longer exist.

# Cut 7: Consolidation sweep

Reconciles the merged tree. Three branches were written in parallel against signatures that changed underneath two of them.

## What is broken and why

`cycle/field` and `cycle/fixture` both branched before plot mode moved from a request parameter to a construction parameter. The package builds; the test target and the harness do not.

## Deliverables

- Field tests calling `paths(in:mode:)` move to `paths(in:)` with the mode supplied at construction. Affected: `FieldToleranceTests`, `FieldBakeTests`, `FieldReadTests`. Preserve the intent of each call: a test that meant aspect gets a preset constructed in aspect.
- `GoldenRatioPreset` call sites take the focus parameter. Give `focus` a construction default at the stored orientation so a caller that does not care need not choose, matching how the other presets default their mode.
- The harness plot mode control rebuilds the preset rather than passing a mode to `paths`. Golden Ratio leaves the mode control entirely, since it has no mode, and gains a four way focus control.
- The harness draws the field. The grayscale the field vends is the point of `field.vend.grayscale` and nothing displays it yet. A control to show or hide it, and a slider for field resolution, which is the magnitude `field.store.location.exact` trades against bake time.
- A timing readout for the bake, separate from the existing preset generation figure. Bake cost is the number the principal is deciding resolution against.

## Constraints

- Swift only. One type per file. No structural UI inline as nested closures in a parent body.
- The harness consumes Mobster through its public surface only. Report anything missing rather than reaching around it.
- Guide paths draw in cyan. Fixture points draw in amber. Choose a treatment for the field that reads underneath both and say what you chose.
- An empty field vends no grayscale. Handle that without drawing a black rectangle that looks like a baked field.

## Acceptance

`swift build` and `swift test` green. `xcodebuild` on the harness succeeds. No call site anywhere passes a mode to `paths`. The field displays, and moving the resolution slider visibly changes it.
