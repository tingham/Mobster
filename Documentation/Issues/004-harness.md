> **Superseded.** This is a historical record of what was asked for at the time. The authority is [Design/Mobster.md](../Design/Mobster.md). Requirement identifiers cited below may no longer exist.

# Cut 4: Harness

A macOS application that draws what Mobster produces, so magnitudes can be derived by eye instead of by projection.

## Requirements covered

harness.platform, harness.preview, harness.timing, harness.sliders

## Deliverables

- An Xcode project targeting macOS, in the repository, referencing the Mobster package locally.
- A preview surface drawing a Frame and the paths a selected preset produces inside it.
- A preset picker.
- A slider for every parameter the selected preset exposes. Column count, gutter width, ruler degrees, ruler distance, ruler center, curve tension. The sliders are the point of the harness; a parameter without a dial is a parameter the principal cannot answer questions about.
- A timing readout reporting how long preset generation takes.

## Constraints

- SwiftUI. Draw with Canvas. No Metal in this cut.
- The harness consumes Mobster through its public surface only. If something the harness needs is not public, report it rather than reaching around it.
- Guide paths draw in cyan.
- One type per file. No structural UI declared inline as nested closures in a parent body. Each discrete component is a named type in its own file.

## Acceptance

The application builds and runs on macOS. Selecting each preset draws its paths. Moving a slider changes the drawing. Four columns with a visible gutter draws six lines, countable on screen.
