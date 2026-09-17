> **Superseded.** This is a historical record of what was asked for at the time. The authority is [Design/Mobster.md](../Design/Mobster.md). Requirement identifiers cited below may no longer exist.

# Cut 3 follow up: Plot mode and Golden Ratio

Applies the principal's rulings. Changes public signatures.

## Requirements covered

preset.frame.mode, preset.frame.mode.default, preset.goldenRatio.proportion, preset.goldenRatio.quadlines, preset.goldenRatio.focus

## Deliverables

- Plot mode moves from a request parameter to a CONSTRUCTION parameter. `paths(in frame: Frame)` loses its `mode:` argument; each preset holds the mode it was constructed with. Aspect is the construction default for Thirds, Columns, Rows, Ruler and Curve.
- Golden Ratio preserves its own proportions. It constructs in bounds mode and does not plot in aspect mode. A distorted spiral is not the golden ratio.
- `GoldenRatioPresetTests.aspectPlottingFillsTheFrame` asserts the distortion this now forbids. DELETE it. Do not adjust it. A test that passes only against an implementation violating a requirement defends the defect and will report the correction as a regression.
- Golden Ratio plots the nested rectangles the spiral is derived from, alongside the spiral.
- The corner the spiral converges toward is selectable.

## Harness sweep, same change

The macOS harness on branch `cycle/harness` is built against the old signatures. Its plot mode picker becomes a control on the constructed preset rather than a per call argument, and Golden Ratio gains a focus corner control. The harness must build after this lands.

## Constraints

- Swift only.
- One type per file. No extension islands.
- Selecting a focus corner must not distort the spiral. It is an orientation, not a scale.
- Every new value the user could tune is a parameter with no baked magnitude.

## Acceptance

`swift build` and `swift test` green. `xcodebuild` on the harness succeeds. No preset accepts a mode at the call site. Golden Ratio cannot be plotted distorted. The quadlines and the spiral share the same projection, verified by asserting that a quadline corner coincides with a spiral location.
