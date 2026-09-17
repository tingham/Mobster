# Cut 21: The figure and the head as meshes

Four fixes to the mesh source, then the figure and the head rebuilt on it.

## Part one, the mesh source

**The dependency breaks in every worktree.** `.package(path: "../Whiplash")` is correct from the repository root and resolves to `.worktrees/Whiplash` from any worktree, which is why a symlink is currently propping it up. Whiplash has a remote at `git@github.com:tingham/Whiplash.git` and a `v1.0.0` tag. Depend on it by URL and version and delete the symlink.

**A Metal failure is silent.** A library that will not compile or a texture that will not allocate makes the render nil and `paths` return empty. That is the fourth silent nothing this package has produced and each previous one was corrected on the same principle: a library that does nothing and says nothing is worse than one that answers wrongly, because nothing on screen tells them apart. Give it a refusal the consumer receives.

**The shader recompiles on every construction**, 116ms the first time and 48ms after, per replot. On a slider drag that is felt. Compile once.

**Two baked magnitudes.** The identity raster is 512 fragments across the wider axis and a boundary fits to 12 locations. Neither is derived and neither is dialled. `mesh.render.resolution` says the resolution follows from the Frame; make it, and put the fit count on a harness control so the principal can find it.

## Part two, the figure

`AshcanPreset` is rebuilt as a mesh. **The canon does not change.** Every proportion sourced from Loomis stays exactly as it is; this cut changes the forms, not their dimensions.

- A limb segment is **two stacked cylinders sharing one identity boundary at its middle**, so the mid slice showing the form's roundness and the joint seam at the elbow come from the same mechanism. Eight points to a ring.
- The existing limb widths serve as radii unchanged. A limb is circular in section and needs no new number.
- Ribcage, pelvis and head mass become solids. **Torso depth and pelvis depth are the only two numbers the canon lacks.** Source them or say plainly that you could not, the way the figure's own canon was sourced rather than invented.
- An identity marks structure, not tessellation. Subdivision never multiplies identities, or every arm becomes a corduroy tube.
- Two bone inverse kinematics is unchanged. Pose stays in the figure's own plane; a single view target orbits the whole construction. Do not make the four pose targets three dimensional — placing five points in space with sliders is unusable.

## Part three, the head

`HeadPreset` moves onto the mesh source too. `HeadCanon` does not change. It already carries a sourced depth in the Farkas head length, so the head mass is a true ellipsoid rather than a guess.

The head keeps its target, its roll and its tilt limit.

## Part four

Cross sections wherever a form's roundness should read, by the division above.

## Constraints

- One type per file, filename matching. No protocol declared with a conformer. No extension block appended to a declaration in the same file.
- Comments carry only the non-obvious reason, ONE physical line each, no hard wrapping, no hyphenated compound words.
- A mesh is low in triangles. The whole figure should be a few hundred. Do not build a scene graph, a material system or an asset importer.
- The slight curve a fit leaves on a straight edge is wanted. Do not straighten it.

## Acceptance

`swift build` and `swift test` green, `xcodebuild` on the harness succeeds, and the harness builds from a worktree without a symlink.

The figure and the head hold their proportions on a Frame wider than it is tall, as they do today. A limb shows a seam at its joint and a slice at its middle. Turning the figure holds the path count and the point counts steady and moves them.

A Metal failure produces a refusal the consumer can read rather than an empty result.
