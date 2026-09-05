# Mobster
*Because he pushes things around*

## Overview

Drawing is hard. Drawing on an iPad or Wacom tablet is harder. Mobster provides modifiers that, allow guidance for user gestures that produce consistent results, and generate additional points when points are made based on a common set of rules.

## Workflow

This project will utilize the following process for implementation.

- Discussion with principal regarding requirements and changes should result in an update to the requirements document (this file.)
- Tasks to produce source based on those requirements will be itemized as Github issues via the `gh` command.
- Coding agents will be managed and dispatched by the "chat host" agent using the material of those tasks in combination with this requirements document where necessary.
    - Agents will be segregated using `cycleworktree`
    - Agents will deliver code to the "chat host" agent, the "chat host" agent will dispatch a `requirements-analyst` to provide whole changeset reconciliation against the dispatch for that work.
    - Implementation agents should be kept open and accessible for re-tasking on an open task until it is accepted by the "chat host" as the result of a favorable reading from the `requirements-analyst`. New github issues are not required for this task compliance work.
    - Accepted code will be merged into a `develop` branch by the "chat host" agent and the principal will be notified of changes - and if UAT is required, a summary of the work that needs to be reviewed and / or tested.
    - Issues will be closed and `cycleworktree` will be used to clean up completed worktree branches
- The results of UAT that require fixing, omission recovery, or change orders from the principal will be submitted as new github issues against the original issue (where applicable)
- When a substantial amount of work is complete (user's discretion) develop will be submitted for PR merge to `main` and the "chat host" agent will issue a release tag with change notes and any updated documentation for downstream consumers.

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
* Ruler: Parameters for two circular degrees create a line across the region frame between two points derived from those degrees. A "distance" parameter creates paired parallel lines at the specific offset from the originating line. A parameter for the "center" is specified in x,y coordinates.
* Curve: Identical in structure to the ruler, the curve includes a position for the mid-point between the start and end for controlling the tension of the interpreted spline.

##### Parameters

**Adherence**
Point locations are normalized across the target's Frame. Then, by an inverse distance squared falloff using adherence as the master control, points are modulated transiently to "move toward" the nearest guide point in the field.

The total number of "steps" for a given point to reach its destination (ids * (1- adherence)) is calculated when the point's token is created.

**???**
Presets may include additional parameters.

##### Fields

Points on the layer with the Guide applied are submitted through the Guide modifier prior to being delivered to the gpu for rasterization. A token within the guide is created for each point in the unified collection of points from strokes on the layer that references points by identifer and tracks a progressive value. If a token previously exists for a given point it is reused, otherwise a token is created (for example on a new stroke's first point).

##### Point Token

The point token contains fields for:

- Stroke Identifier  
Maintained as a qualifier for points such that advancing a point within a stroke during a `skip-take` (extemporaneous event) can accomodate advancing all points in the stroke, or all points proportionally against the point under advancement.
- Point Identifier  
This is the link to the point as provided from the query store to be sent to the rasterizer for display.
- Point Progress: simd3  
Where the point has been displaced to since the last reset
- Point Target: simd3
Where the point will "land"

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

When all points have achieved their targets (within epsilon equivalent to one half pixel) a `.settled` notification is sent from the Guide to any listeners. Settled state is not tracked inside of the Guide. It is the responsibility of the Consumer application to cease invocation of advancement based on this notification, rather than an internally tracked boolean state that might disagree with the facts; or a dynamic getter that must walk all points for epsilon equality on a value that is already resolved.

##### Guide Display

**Field**

Mobster provides a nominal dataset.  Whether or not this is visible for a given guide is of no consequence to Mobster. It provides a rasterized 8 bit map of its `field` on demand.  

**Path**

Mobster receives point input from Layer Sources or point data from presets. It may then vend this data to a consumer for purposes that fall outside the scope of this module's concern.
