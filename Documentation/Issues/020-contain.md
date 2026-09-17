# Cut 19: Subsume the plot mode

## Requirements covered

preset.frame.mode, preset.frame.aspect, preset.frame.bounds, preset.frame.bounds.center, preset.frame.contain, preset.frame.mode.each, preset.goldenRatio.proportion, preset.gutter.fraction, preset.ashcan.proportion, preset.head.proportion

## What is wrong now

Ashcan and Head plot into a unit square and default to aspect mode, which scales the axes independently. On the harness Frame of 600 by 400 the whole figure is half again too wide — which is why the head reads round, the shoulders and hips read wide, and the torso reads blocky.

Bounds does not serve either, because it covers: a unit square on a wider Frame scales past the shorter axis and the crown and soles fall outside. A figure wants to fit inside.

## Deliverable

**The plot mode leaves the consumer's surface entirely.** It is not a parameter, not a construction argument, and not a public type. How a preset answers a Frame is a property of what that preset is.

- Thirds, Columns, Rows, Grid and Ruler take the Frame as their design rectangle.
- Golden Ratio covers the Frame, as it already does.
- Head and Ashcan **fit inside** it, scaled by the lesser of its axes and centred, with their proportions intact. That is the new behaviour.

## What falls out

`PresetPlotMode` stops being public and stops being an argument on five presets. The harness loses its plot mode control. `PresetDeterminismTests.plotters` roughly halves, and `aspectPlotters` goes entirely — that list exists to say "this entry's successor is the same preset in bounds mode", and with no twins there is nothing to track. `FieldToleranceTests` loses its bounds variants.

`preset.gutter.fraction` becomes true without a qualifier. It carried one only because a consumer could flip a preset into a mode where the design rectangle was larger than the Frame.

## Constraints

- Swift only. One type per file, filename matching.
- Do not change any preset's geometry. This cut changes how a preset meets the Frame and nothing about what it plots.
- Recorded sequences will move for every preset that changes mode. Re record them rather than loosening a tolerance to absorb the difference.

## Acceptance

`swift build` and `swift test` green, `xcodebuild` on the harness succeeds. No preset takes a mode at any call site, proved by grep. On a Frame of 600 by 400 the figure and the head are as wide as they are tall in proportion, asserted against hand derived positions — a head's breadth against its height, and the figure's shoulder span against its stature. A test fails if a contained preset is stretched to an axis.
