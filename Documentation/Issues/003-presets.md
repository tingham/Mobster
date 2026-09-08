> **Superseded.** This is a historical record of what was asked for at the time. The authority is [Design/Mobster.md](../Design/Mobster.md). Requirement identifiers cited below may no longer exist.

# Cut 3: Presets

Region frame responsive prototypes that plot guide paths from a Frame. No source layer, no field, no tokens.

## Requirements covered

preset.storage.static, preset.storage.generated, preset.frame.aspect, preset.frame.bounds, preset.goldenRatio, preset.thirds, preset.columns, preset.rows, preset.gutter.band, preset.ruler, preset.curve

## Deliverables

A preset produces paths given a Frame. A path is an ordered sequence of locations in scene coordinates.

- **Golden Ratio.** A spiral populating the standard ratio frame. Its geometry is fixed, so it is stored as a JSON resource and read, not computed.
- **Thirds.** Three columns and three rows conforming to the aspect ratio of the Frame.
- **Columns.** Columnar dividers spread evenly across the Frame with a parameterized gutter.
- **Rows.** Row lines spread evenly across the Frame with a parameterized gutter.
- **Ruler.** Two circular degrees derive two locations. A line crosses the Frame between them. A distance parameter creates paired parallel lines offset from that line. A center is specified in x and y.
- **Curve.** Identical in structure to the ruler, with a location between the start and the end controlling the tension of the interpreted spline.

Each preset plots in ONE mode, fixed by the preset. Aspect mode takes the Frame as the design rectangle. Bounds mode scales the preset uniformly to a minimum bounds encompassing the Frame, preserving the preset's own proportions. Thirds, Columns, Rows, Ruler and Curve are aspect. Golden Ratio is bounds. The mode is not a parameter of the request.

## The gutter, read this twice

A gutter is a band with two edges, not a divider line. A count of four columns with one gutter width yields **six** lines: each interior gutter contributes two edges. Three interior gutters, two edges each. A test must assert this count directly.

## Constraints

- Swift only. No Metal.
- One type per file. No extension islands. Filename matches the type.
- Every parameter is a parameter. Do not bake a magnitude in as a constant; the principal derives magnitudes in the harness and needs the dial.
- Preset output is deterministic. Same Frame and same parameters yield an identical sequence every time.

## Acceptance

`swift build` and `swift test` green. The gutter count test passes. Every preset produces paths for both a wide Frame and a tall Frame without special casing either.
