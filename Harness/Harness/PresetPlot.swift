import Mobster

/// The paths on screen and the time the preset took to produce those same paths.
struct PresetPlot {
    let paths: [[SIMD2<Float>]]
    let duration: Duration

    init(kind: PresetKind, parameters: PresetParameters, frame: Frame, mode: PresetPlotMode, focus: PresetFocus) {
        var produced: [[SIMD2<Float>]] = []
        let elapsed = ContinuousClock().measure {
            produced = Self.generate(kind: kind, parameters: parameters, frame: frame, mode: mode, focus: focus)
        }
        paths = produced
        duration = elapsed
    }

    private static func generate(kind: PresetKind, parameters: PresetParameters, frame: Frame, mode: PresetPlotMode, focus: PresetFocus) -> [[SIMD2<Float>]] {
        switch kind {
        case .goldenRatio:
            GoldenRatioPreset(focus: focus).paths(in: frame)
        case .thirds:
            ThirdsPreset(mode: mode).paths(in: frame)
        case .columns:
            ColumnsPreset(count: parameters.columnCount, gutter: parameters.columnGutter, mode: mode).paths(in: frame)
        case .rows:
            RowsPreset(count: parameters.rowCount, gutter: parameters.rowGutter, mode: mode).paths(in: frame)
        case .grid:
            GridPreset(count: parameters.gridCount, gutter: parameters.gridGutter, mode: mode).paths(in: frame)
        case .ruler:
            RulerPreset(center: parameters.rulerCenter,
                        firstDegree: parameters.rulerFirstDegree,
                        secondDegree: parameters.rulerSecondDegree,
                        distance: parameters.rulerDistance,
                        mode: mode).paths(in: frame)
        case .curve:
            CurvePreset(center: parameters.curveCenter,
                        firstDegree: parameters.curveFirstDegree,
                        secondDegree: parameters.curveSecondDegree,
                        distance: parameters.curveDistance,
                        control: parameters.curveControl,
                        resolution: parameters.curveResolution,
                        mode: mode).paths(in: frame)
        }
    }
}
