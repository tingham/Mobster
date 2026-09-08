> **Superseded and kept deliberately.** This is the original narrative the requirements were distilled from, preserved verbatim as a record of intent. It is NOT current and must not be cited as authority on any requirement. The authority is [Mobster.md](./Mobster.md).

# Mobster
*Because he pushes things around*

## Overview

Drawing is hard. Drawing on an iPad or Wacom tablet is harder. Mobster provides modifiers that, allow guidance for user gestures that produce consistent results, and generate additional points when points are made based on a common set of rules.


## Prose (To be moved to pricinpal issue in github prior to task planning.)

### Test Harness

Similar to Jerome, Tempest, and Muslin (~/Source/Repos) this project will include a nominally complex dataset as "fixture", a method to present a preview to the screen, basic performance timing output, and any necessary parameter drivers as sliders via an Xcode project targeting macOS.

Data structures may be capitalized from any of those sources as hard copies only, and not linked or referenced by path to their origins.


### A Modifier

Modifiers exist as one (currently, with more planned.) distinct sub-types:

- Guide

#### What are Guides?

A layer may associate one or more Guides to itself. Guides consist of two primary attributes and a few secondary parameters.

##### Target

This is the layer to which the Guide is applied. Points inside Strokes on this layer are affected by the guide.

##### Sources

**Layer Source**

Much like a layer Mask, the user is asked to select a layer from among those containing strokes in the current document. When the source is selected the stroke data from that layer is reinterpreted within the Guide as simple paths with curvature. These paths in the guide are then utilized as a `field`.

Using a Layer as a source may have a frame that differs from the target. In this event we may wish to display a warning to the user (consumer concern) - but Mobster will map absolutely and not make an attempt to fit the source layer's bounds to the target's. What the user sees visually will match their intent.

**Preset Source**

Unlike layer Masks, guides provide a collection of region frame responsive prototypes that plot paths either consistent to the aspect ratio of the nearest Frame, or scaled to a minimum bounds to encompass the nearest Frame. Selecting a preset then utilizes the scaled (and potentially distorted) paths as a `field`.

* Golden Ratio: A spiral that populates the standard ratio frame
* Thirds: Three columns, three rows, conforms to aspect ratio of frame
* Columns: Parameterized columnar dividers spread evenly across region frame with parameterized gutter
* Rows: Parameterized row lines spread evenly across region frame with parameterized gutter
* Ruler: Parameters for two circular degrees create a line across the region frame between two locations derived from those degrees. A "distance" parameter creates paired parallel lines at the specific offset from the originating line. A parameter for the "center" is specified in x,y coordinates.
* Curve: Identical in structure to the ruler, the curve includes a location between the start and end for controlling the tension of the interpreted spline.

##### Parameters

**Adherence**
Point locations are normalized across the target's Frame. Adherence controls the reach of an inverse distance squared falloff against the field. At 1.0 the reach covers the Frame and every point snaps fully onto its nearest guide location. At 0.001 the reach collapses and only points already sitting on a guide location exhibit any magnetism at all.

The falloff yields a weight of `1 / (1 + (distance / reach) ^ 2)`. A point's target is its own location displaced toward the nearest guide location by that weight of the distance between them, so a point far from every guide settles short of the guide rather than arriving at it.

A target is resolved when the token is created and persists until a skip take changes the field. The rate at which a point travels to its target is deliberately unspecified here; it is an aesthetic concern for discovery to answer.

**Variable**
Presets may include additional parameters.

##### Fields

Points on the layer with the Guide applied are submitted through the Guide modifier prior to being delivered to the gpu for rasterization. A token within the guide is created for each point in the unified collection of points from strokes on the layer that references points by identifer and tracks a progressive value. If a token previously exists for a given point it is reused, otherwise a token is created (for example on a new stroke's first point).

##### Point Token

The point token contains fields for:

- Stroke Identifier  
Maintained as a qualifier for points such that advancing a point within a stroke during a `skip-take` (extemporaneous event) can accomodate advancing all points in the stroke, or all points proportionally against the point under advancement.
- Point Identifier  
This is the identifier supplied by the consumer. Mobster does not dereference it and holds no authority over what it addresses.
- Point Progress: simd2  
The location the point has been displaced to since the last reset
- Point Target: simd2  
The location the point will "land" on

Displacement is planar. A guide has no reason to move a point in depth, so the token does not carry it.

##### Modifier Workload

**Skip Takes**

Modifiers respond to stroke events from either the Source Layer (if specified) or the Target Layer and apply either an update to its field; or an update to its membership. During any of these events, regardless of the object under inspection, Mobster may advance the modulation step on any number of points within its membership.

During this workload, rectangles must be returned in scene coordinates for any advanced points or unions of advanced points. The consumer may then decide whether to include those updates as a function of its own rendering pipeline.

**At a Minimum:**

If a Source Layer is modified to have new data added; the target for all point tokens will be updated based on the new field state.

If the Target is updated to include new data, new points are tokenized and evaluated against the field.

These are the standard lifecycle events that Guide modifiers traffic in.

**Advancement**

The consumer application may, at its discretion (after a period of inactivity from the user) invoke an `.advance` method on a Guide. The advance method allows for the delivery of a "speed multiplier" to influence the advancement of all points in the Guide along their path to each points target.

**Settlement**

When all points have achieved their targets (within epsilon equivalent to one pixel) a `.settled` notification is sent from the Guide to any listeners. Settled state is not tracked inside of the Guide. It is the responsibility of the Consumer application to cease invocation of advancement based on this notification, rather than an internally tracked boolean state that might disagree with the facts; or a dynamic getter that must walk all points for epsilon equality on a value that is already resolved.

##### Destructive Workload

**Notes only. The live workload is the implementation target; this section records the shape of a second mode so it is not rediscovered.**

A Guide could apply destructively to the dataset it modulates rather than applying as a filter ahead of rasterization. The consumer yields a reduced result from Mobster and replaces the resolved points in the live stroke. If the animation effect proves out, this becomes a toggle on the Guide.

The internal logic is the same for both modes. OneBrush can achieve the destructive result with the live workload alone, so this is a convenience and not a capability gap.

Token lifetime is the consumer's to manage. A committed point is already at its target, so re-resolving it would compute a new target from the new location and pull it again. Because the mode is a toggle the consumer knows not to continually invoke, and routes only live strokes.

Identifiers are never minted here. Mobster produces a reduced set of existing identifiers and holds no authority over the DOM.

Open question: whether the destructive result is expected to differ from the settled live result. If it is not, this is an output path rather than a second workload.

##### Guide Display

**Field**

Mobster provides a nominal dataset.  Whether or not this is visible for a given guide is of no consequence to Mobster. It vends a grayscale rasterization on demand as an approximation of its `field`.  

**Path**

Mobster derives locations from Layer Sources and from presets. It may then vend this data to a consumer for purposes that fall outside the scope of this module's concern.
