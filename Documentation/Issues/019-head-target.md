# Cut 18: Head as a projection

## Requirements covered

form.space.depth, form.space.depth.near, preset.head.target, preset.head.basis, preset.head.roll, preset.head.tilt.limit, and the removal of preset.head.view

## Deliverable

The head construction is expressed in three dimensions and projected, replacing the hand derived per form projections that exist today.

- A small three dimensional core: a location, a basis, an orthographic projection. Nothing else in the package gains a third dimension by it; a preset opts in.
- The head points at a **target location** rather than taking a view angle. Forward runs from the head toward its target, up and right derive from forward, and roll is one scalar about forward.
- Forward is held within forty five degrees either side of level, which removes the case where forward approaches parallel with up and a basis cannot be derived.
- A projected construction is clipped to its near half by depth, so the far side of a curve stops projecting as a second lobe over the near one.

## This should be less code than it replaces

The existing head folds the yaw into each form analytically. In three dimensions the curves are written once in head space — the brow line and centre line as great circles, the side planes as sections, the jaw and chin as edges — and the transform does that work. The one thing that stays view dependent is the cranial silhouette, because an ellipsoid's outline is a different curve for every direction, and that has a closed form.

If this cut makes the head larger, something has gone wrong.

## What goes

`preset.head.view` and its mapping. `cos ψ = 1 − (1 − view)²` existed to make a one dimensional slider land on the three quarter view, and a target needs no mapping because the view is wherever the target is. Delete it rather than keeping it as a second way in.

## What stays exactly as it is

Every proportion in `HeadCanon`. This cut changes how the construction is projected and nothing about its dimensions.

## Constraints

- Swift only. One type per file, filename matching. No protocol declared with a conformer. No extension block appended to a declaration in the same file.
- Deterministic: the same Frame and parameters yield an identical sequence every time.
- This is a guide and a starting point. Do not build a scene graph, a camera model, a perspective divide, or an animation system. A location, a basis, a projection.

## Acceptance

`swift build` and `swift test` green, `xcodebuild` on the harness succeeds. The harness drives a target location and a roll scalar rather than a view slider. A target placed level and to the side gives a profile, and one placed level and in front gives a frontal view, asserted against hand derived positions. No curve projects a second lobe. A test fails when the depth clip is removed, and another when the tilt limit is removed.
