> **Superseded.** This is a historical record of what was asked for at the time. The authority is [Design/Mobster.md](../Design/Mobster.md). Requirement identifiers cited below may no longer exist.

# Cut 2: Path interpretation

Turns ordered source locations into the paths a field is later baked from.

## Requirements covered

path.interpret, path.decimate, path.complexity.cap, path.vend, harness.copy

## Deliverables

- Interpretation of ordered locations into paths with curvature. The interpretation is Mobster's own and does not reproduce the source representation.
- Decimation of interpreted paths.
- A complexity cap. A path exceeding it is reduced by removing entries until it conforms. It is neither truncated nor rejected. The cap is a parameter, not a constant chosen here.
- Vending of interpreted paths to a consumer on demand.
- A fixture dataset of nominally complex source data for tests.
- Tests covering decimation determinism, cap conformance, and that interpretation of the same input twice yields identical output.

## Prior art to hard copy

These are copies. Do not link, reference by path, or add a package dependency.

- `~/Source/Repos/Jerome/Sources/Jerome/Finding/ContourFinder.swift:84-106` Ramer Douglas Peucker, stack based.
- `~/Source/Repos/Jerome/Sources/Jerome/Finding/ContourFinder.swift:108-114` point to segment distance.
- `~/Source/Repos/Jerome/Sources/Jerome/Finding/Loop.swift:26-60` centripetal Catmull Rom resampling with a tension blend.
- `~/Source/Repos/onebrush/Packages/helios/Sources/Helios/Interpreters/SplineFitInterpreter.swift:103-374` Schneider piecewise cubic Bezier fit. Lift the statics only. The surrounding shell returns a persistence record and drags in a document model.

Read the source before copying. Each carries documented deviations from its reference implementation that are load bearing.

## Constraints

- Swift only. No Metal in this cut.
- One type per file. No extension islands.
- Interpretation must be deterministic. Same input, same output, every time.

## Acceptance

`swift build` and `swift test` green. Determinism test passes over the fixture. No dependency added to `Package.swift`.
