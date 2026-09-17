# Mobster
*A vertex manipulation toolset for OneBrush*

## What it does

Mobster draws points toward guide paths. You give it a guide — lines you supply, or one of seven presets plotted against a frame — along with the content you want moved and a time. It gives that content back with its points displaced.

```swift
let guide = Guide(frame: frame)
try guide.initialize(source: .preset(GridPreset(count: 4, gutter: 0.05)),
                     frame: frame, adhesion: 0.4, duration: 1,
                     settleEpsilon: 1, budget: budget)
let moved = guide.evaluate(lines, at: t)
```

Adhesion between zero and one is the only control that decides how strongly points are drawn. A point far from every guide settles short of it rather than arriving; that is the dial doing its job, not a defect.

## What it does not do

Mobster evaluates between two frames and retains nothing between calls. Carrying positions across successive guides is the consuming application's work.

It declares no document model and imports none. Identifiers cross the boundary as opaque integers it never dereferences and never mints. It does not interpret, smooth or decimate the geometry it is given.

## Presets

Golden Ratio, Thirds, Columns, Rows, Grid, Ruler, Curve.

## Reading further

[Design requirements](./Documentation/Design/Mobster.md) is the authority on what the package must do.
[Integration](./Documentation/Integration.md) is the guide to consuming it, including what a guide costs to bake.
[Generators](./Documentation/Design/Generators.md) is a problem statement for symmetry, which is not built.
