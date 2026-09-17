# Cut 22: Figure, chin, boundaries

## Requirements covered

preset.figure and its renamed members, preset.figure.bend, preset.figure.hand, preset.figure.foot, preset.head.chin, mesh.boundary.sample, mesh.raster.vend

## The rename

`AshcanPreset` and everything named for it becomes `Figure`. It was named for a mugshot and it is a figure now.

## The chin, which is the only problematic part of the head

The principal estimated seventy percent male and fifty five female for the chin block's width and asked for better data. The Farkas figures already in `HeadCanon` give, as fractions of head breadth: forehead and ear caps 0.735 male and 0.736 female, jaw angles 0.702 and 0.681, chin at the mouth 0.351 and 0.347.

So seventy percent is the **jaw angle** width, right for male and 0.68 rather than 0.55 for female. The chin itself is about **0.35 for both** — half again narrower than estimated, a much stronger taper, and the sexes differ by less than a hundredth at either end.

Geometry as the principal gave it: the block centres vertically on the underside of the cranial mass and rises halfway to its middle.

## Boundaries dropping out

Thin grazes produce boundaries of one or two fragments that flicker in and out as the view turns. The implementer of the mesh cut reported this of the head; the figure has twenty one identities meeting each other and suffers worse.

Resolve a boundary from a **neighbourhood** of fragments rather than a single pair, and resolve that neighbourhood to one location. The principal proposed a two by two and that is a sound shape; use it unless you find better.

## Show the identity raster

The field vends a grayscale so its state can be seen. The identity raster vends nothing, so the principal diagnosed the dropouts by speculation and so did I. Vend it and draw it in the harness.

## Poles come out

An elbow bends back and a knee bends forward. That is anatomy, not a control. Delete the four pole parameters and their harness dials. Do not replace them with anything; pinning is Poser and we are not writing Poser.

## Hands and feet

Tapered cuboids. The hand is about the length of the face, the foot about one head. Both are in the canon already.

## Constraints

- One type per file, filename matching. Comments one physical line, only the non-obvious reason.
- The canon does not change. This cut renames, corrects one construction, and makes boundaries hold.
- The slight curve a fit leaves on a straight edge is wanted. Do not straighten it.

## Acceptance

`swift build` and `swift test` green, `xcodebuild` on the harness succeeds. No symbol named Ashcan survives. The chin block's widths are asserted against the fractions above. Turning the figure through a wide sweep holds its path count steady where it does not today. The identity raster appears in the harness.
