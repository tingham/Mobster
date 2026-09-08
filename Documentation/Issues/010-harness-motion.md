> **Superseded.** This is a historical record of what was asked for at the time. The authority is [Design/Mobster.md](../Design/Mobster.md). Requirement identifiers cited below may no longer exist.

# Cut 9: Motion

Wires the Guide into the harness. The first time the package does what it is for.

## Requirements covered

harness.preview, harness.sliders, harness.timing, against guide.play, guide.adherence.reach, guide.settle.notify, guide.rect.dirty

## Deliverables

- The harness bakes a field from the selected preset's paths, tokenizes the fixture population against it, and draws the displaced points.
- A transport for time. Play advances it, pause holds it, a scrub returns to any time. Time is a value the harness owns and hands to the Guide, not a clock the Guide reads.
- A slider for adherence reach and a slider for speed.
- The settled notification is surfaced. When every point has arrived the harness says so rather than leaving the principal to judge stillness by eye.
- Dirty rectangles are drawn when shown, so the region the Guide reports as advanced can be compared against what visibly moved.
- Timing for the play step, alongside the existing generation and bake figures.

## What the principal is looking for

This harness exists so magnitudes get answered by eye. Three are unanswered and this cut is where they get decided: the mapping from the adherence dial to a reach, the speed, and whether the motion reads as alive at all. The principal has said the sweet spot may turn out to be very fast, or that animation may not work. Make all three easy to try and do not pre empt any of them with a chosen feel.

## Constraints

- SwiftUI. Canvas. No Metal.
- One type per file. No structural UI declared inline as nested closures in a parent body.
- Consume Mobster through its public surface only. Report anything missing rather than reaching around it.
- Guide paths draw in cyan, the field in achromatic gray beneath, fixture points in amber. Displaced points must be distinguishable from their original locations; choose a treatment and say what you chose.
- Time is deterministic. The transport supplies a value; nothing in the draw path reads a wall clock to decide where a point is.

## Acceptance

`xcodebuild` on the harness succeeds. Moving the reach slider visibly changes where points settle. Points far from every guide visibly settle short of it, which is the intended behaviour and not a defect. Scrubbing back to an earlier time returns the same picture that time produced going forward.
