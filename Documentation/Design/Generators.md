# Generators

**Problem statements. Not an implementation target for this package.**

Both problems below need the same thing from the document model and nothing else: the ability to say that a stroke appears more than once, under transform. That capability is OneBrush's. Neither can be a display effect, because source over compositing is order dependent and a repetition drawn as geometry in its turn is not the same image as one synthesized from the composited result wherever paint is translucent. Neither can be duplicated marks, because the copies are derivable from one gesture and a transform, and every later edit would have to find and maintain them.

## Radial Symmetry

A user paints one gesture and expects it repeated about a point, turned by a fixed angle each time.

An origin, an angle and a count describe it. The count is repetitions beyond the original. The pattern closes on itself when the angle times one more than the count is a full turn; any other value leaves a gap or overlaps.

Every transform it produces is a rotation, so handedness is preserved and a brush that reads a direction along the stroke renders correctly on every repetition without special handling.

## Axial Symmetry

A user paints one gesture and expects it mirrored across a line. Drawing half a face and receiving the other half is the case that matters, and it is the symmetry most people mean when they say the word.

An axis describes it, which is an origin and a direction. More than one axis is meaningful.

This is a reflection, not a turn. It cannot be expressed as a rotation at any angle: a reflection has determinant minus one, and no composition of rotations reaches it. A half turn is point symmetry, inverting both axes, which is a different picture. Attempting one parameterization for both problems is attempting to describe a cartesian operation and a polar one with the same three numbers, and that was the error this document previously carried.

Two consequences follow from the determinant.

A brush that reads a direction along the stroke will render backwards on a mirrored repetition unless its heading is negated with the transform. This reads as a shader defect and is not one.

Two axes generate more than two repetitions. Composing two reflections yields a rotation, so a pair of perpendicular axes produces four images, not three: the original, one per axis, and a half turn nobody asked for. Any count the interface reports has to account for it.

## Open

What addressing a single repetition means. Erasing one arm, selecting it, or painting over it forces a decision between materializing that repetition into an ordinary stroke the moment it is touched, and carrying per repetition state. Both are defensible and they are different products.

Where the transforms come from. A generator producing them and the document model holding them are separate questions, and only the second is answered here.
