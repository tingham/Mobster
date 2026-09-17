# Cut 16: Head preset

## Requirements covered

preset.head, preset.head.sex, preset.head.view

## Deliverable

A head plotted as the Loomis construction: the sphere, its side planes, the brow line, the centre line, the jaw, the chin and a portion of the neck.

Parameters: sex, and a view angle from zero at full profile to one at face forward.

## The view angle

The angle is a yaw rotation of the construction, projected. The brow line and centre line are great circle arcs on the sphere and sweep as a function of it.

The middle of the slider must land on the three quarter view, which sits nearer forty degrees of yaw than forty five. A mapping linear in angle puts the middle slightly off the view an artist means, so the mapping is not linear.

## No art is needed

The construction is primitives and published ratios. The sphere, the side plane cut at a fraction of the radius, and the jaw and chin proportions are all derivable. Do not attempt an appealing silhouette; this is a construction diagram and that is what it is for.

## Constraints

- Swift only. One type per file, filename matching.
- It constructs in aspect mode as the other Frame relative presets do.
- Every value a user could tune is a parameter with no baked magnitude. Ratios that define the construction itself are structural and stay.
- Deterministic: the same Frame and parameters yield an identical sequence every time.

## Acceptance

`swift build` and `swift test` green. Registered in `PresetDeterminismTests.plotters` and in the tolerance sweep, as every preset is. Wired into the harness with sliders for sex and view. At a view of zero the construction reads as a profile and at one as frontal, asserted on hand derived positions rather than on a property a wrong implementation would also satisfy. A test fails when the view mapping changes.
