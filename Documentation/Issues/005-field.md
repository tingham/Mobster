> **Superseded.** This is a historical record of what was asked for at the time. The authority is [Design/Mobster.md](../Design/Mobster.md). Requirement identifiers cited below may no longer exist.

# Cut 5: Field

Bakes guide paths into a field that answers two questions at a location: how far, and which way.

## Requirements covered

field.bake, field.store.location, field.read.distance, field.read.direction, field.gradient.never, field.unsigned, field.tiebreak.center, field.vend.grayscale

## The governing idea

The field stores the NEAREST PATH LOCATION per texel. It does not store a distance. Distance is recovered as the length from the query location to the stored location, and direction is that same vector normalized. Both are exact, because the stored value is a coordinate rather than a sampled scalar, so no derivative is taken anywhere.

Do not compute a gradient. The tree carries a measured warning against deriving direction from a sampled distance field, and storing the location makes the derivative unnecessary rather than merely avoidable.

The field is unsigned. A guide path is open and has no interior, so there is no sign to recover.

## Deliverables

- A bake taking paths and a Frame and producing the field. Swift on the host, no Metal.
- A read for distance at a location.
- A read for direction at a location.
- Tie breaking toward the center of the Frame where two path locations are equidistant.
- A grayscale rasterization vended on demand as an approximation for display. This is a conversion at the vending edge and NOT the storage format.
- Tests.

## Prior art

`~/Source/References/metal-by-example-sample-code/objc/12-TextRendering/TextRendering/MBEFontAtlas.m:292` implements Dead Reckoning, Grevera 2004, cited in place. It is a two pass chamfer propagation that carries the nearest boundary point alongside the distance, which is exactly the property this cut needs. It is Objective C and needs a Swift port. Read it before writing anything.

`~/Source/Repos/Jerome/Sources/Jerome/Kernels/ShapeField.metal` is the same property by jump flooding on the GPU. Reference only; this cut is Swift on the host.

Both are hard copies or ports. Do not add a package dependency.

## Constraints

- Swift only. No Metal.
- One type per file. No extension islands.
- The bake is deterministic. Same paths and same Frame produce an identical field every time.
- Field resolution is a parameter, not a constant. It couples to the settle epsilon and the principal derives it in the harness.

## Acceptance

`swift build` and `swift test` green. A path baked and then read back reports near zero distance at locations on the path. Direction at a location off the path points at the path, verified against a hand computed case. The tie break resolves toward the Frame center for a location equidistant between two paths, asserted with literal positions rather than a translation invariant property.
