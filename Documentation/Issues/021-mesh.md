# Cut 20: The mesh source

## Requirements covered

mesh.source, mesh.component, mesh.low, mesh.render, mesh.render.device, mesh.render.resolution, mesh.boundary, mesh.boundary.identity, mesh.boundary.midpoint, mesh.path.fit, mesh.path.lossy, mobster.dependency.whiplash, preset.cube, preset.cube.place, preset.cube.target

## Deliverable

A Guide may take a mesh as its source, and its paths are extracted from a projection of that mesh rather than plotted analytically.

The pipeline: render the mesh opaque with depth into an offscreen target where every fragment carries the identity of its component; find the boundaries where adjacent fragments differ; trace them; fit them with Whiplash.

**The cube is the first mesh and it is a real guide, not a fixture.** A box is the construction a figure or an object is built inside. It takes a position and a size within the Frame, and a target it points at so it can be turned.

## Why the identity buffer rather than geometric silhouette extraction

Occlusion follows from the depth test. There is no hidden line removal to write.

And an identity per component gives every interior seam, not only the outline. Where an upper arm's identity meets a forearm's is a boundary in the buffer though it is nowhere near the silhouette, and that seam is a construction line. A guide built from silhouette alone would be an outline; built from identities it is a construction.

## Rules that are easy to break

An identity is never interpolated, averaged or filtered. Averaging two identities yields a third that means nothing. Point sample, whole numbers.

A boundary sits **midway between the two differing fragments**, because that is where it is. Half a fragment of accuracy for no cost.

The target's resolution follows from the Frame. It is not supplied and the consumer never sees it.

The consumer supplies the device. Mobster creates none, and a Guide with a preset source needs none.

## Whiplash

This is the package's first dependency. Whiplash fits and decimates, is stateless as Mobster is, and carries `fit(path:count:tension:)`, `decimation(path:count:)`, `reach(path:)`, `residual(fitted:against:)` and `Tessellation.points(of:)`. Ask it for a **fixed count per component** rather than a tolerance, so a turning cube deforms its curve rather than rebuilding it.

## Lossy is acceptable

A fitted path need not reproduce the traced boundary exactly. Any silhouette of a form serves a person drawing over it better than none. Do not spend effort on fidelity beyond what reads.

## Acceptance

`swift build` and `swift test` green, `xcodebuild` on the harness succeeds. The cube appears in the harness with position, size and target controls.

A cube viewed along an axis produces a square; from a general view it produces a hexagonal outline with three interior seams meeting at the near corner. Assert both against positions derived by hand.

A Guide given a mesh source without a device refuses rather than producing nothing silently. A Guide given a preset source needs no device and must still work with none supplied.
