# Generators

**Problem statement. Not an implementation target for this package.**

## Radial Symmetry

A user paints one gesture and expects marks to appear repeated about an origin, at a chosen number of rotations. An origin, an angle and a count describe it: the count is repetitions beyond the original, and the pattern closes on itself when the angle times one more than the count is a full turn.

Mirror symmetry is a separate problem and this parameterization cannot express it. A reflection has determinant minus one and no composition of rotations reaches it, so a half turn gives point symmetry rather than a mirror. Whether a reflection axis belongs in this model is open.

The repetitions have to be real content rather than a display effect. Source over compositing is order dependent, so a repeated mark drawn as geometry in its turn and a repeated mark synthesized by sampling the composited result are not the same image wherever paint is translucent, and the difference is largest where the repetitions overlap near the origin.

The repetitions must not be duplicated marks either. A twelve fold symmetry would cost twelve times the data for content wholly derivable from one gesture and a rotation, and every subsequent edit would have to find and maintain eleven copies.

What that leaves is a document model able to say that a stroke appears more than once, under transform. That capability is OneBrush's rather than this package's, and it is the prerequisite for any generator at all.

## Open

What addressing a single repetition means. Erasing one arm, selecting it, or painting over it forces a decision between materializing that repetition into an ordinary stroke at the moment it is touched, and carrying per repetition state. Both are defensible and they are different products.

Where the transforms come from. A generator producing them and the document model holding them are separate questions, and only the second is answered above.
