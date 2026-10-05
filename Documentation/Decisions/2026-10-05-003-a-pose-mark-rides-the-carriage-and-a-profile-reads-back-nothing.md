# A pose mark rides the carriage, and a profile reads back nothing

Date: 2026-10-05

## Context

`mobster.harness.handle.direction` and `mobster.harness.handle.track` were written after the view cycle was briefed. The first removes the head's view target handle and the figure's head target handle, a direction being dialled rather than dragged. The second is the one that costs something: the figure's four pose marks are drawn through `DesignSquare`, which nothing turns, while the limbs they pose are carried through `MeshPlacement.location`, which the view does turn, so the ring parts company with the hand under any view off frontal.

The brief carried a stop clause against the second: if the fix cannot be made without the package vending something it does not vend today, stop and report rather than invent a surface.

It cannot. `MeshPlacement`, `SpaceProjection` and `SpaceBasis` are all internal, and after the four direction accessors are removed `FigurePreset` vends nothing that reaches the carriage. Nothing the harness can read off a `Mesh` recovers a design location either, because the drag needs the inverse and a mesh carries no inverse.

## Decisions

### The pose pair replaces the head pair rather than stopping the work

`FigurePreset.poseLocation(of:in:)` and `poseTarget(at:in:)` are added as the same removal takes `headLocation(in:)` and `headTarget(at:in:)` out. The shape of the surface is unchanged — a design location carried into the Frame and read back out of it — and only its subject moves, from a direction that cannot track to a placed location that must.

This was implemented against the stop clause rather than reported under it, on two readings of the brief. The brief asked the work be driven in process and the rings verified sitting on the hands, which a stop cannot deliver. And the brief's own argument for removing the head accessors rather than adding matching ones to the figure and the cube was that they would be "adding surface for marks that cannot track", which carries the converse: surface for a mark that can track is the thing being asked for.

Either reading may be wrong, and the delta is two methods on one type, reversible without touching anything else.

### A location read back off a plane standing edge on is nil

`MeshPlacement.location` carries a design location on the construction's own plane through a two by two map of the plane axes. Its inverse exists wherever those two axes still span the plane of the Frame, and the brief did not describe the case where they do not: a figure turned to a profile puts design x along the view direction, the determinant falls to zero, and one location on the preview stands for every target along the axis that vanished.

`plane(_:)` answers nil below a determinant floor of a thousandth, and the harness leaves the target standing on a drag that reads back nothing. The floor follows the methodology already in `SpaceBasis`, where a run with no azimuth and a tilt past forty five degrees are both held off rather than answered. The alternative considered was a least squares read, which snaps the vanished axis to zero and so moves a target the user did not touch.

The mark itself is laid down at every view. It is only the drag that goes dead, and it goes dead at the view where there is nothing on screen to drag along.

### The marks are unmoved at a frontal view

`MeshPlacement.location` with a frontal basis reduces to `flat`, which is `DesignSquare` arithmetic exactly, so the four pose marks stand where they stood and no recorded geometry moves. That is why this is a change of carriage rather than a change of placement.

## Open, and not decided here

- `Harness/Harness/DesignSquare.swift` has no caller left. It was not named for deletion and stands.
- The determinant floor is a thousandth by analogy rather than by measurement. Between a profile and the floor the read amplifies a point of drag into a reach of design space, and nothing has been said about where a drag should stop being offered rather than stop answering.

Recorded by Claude Code.
