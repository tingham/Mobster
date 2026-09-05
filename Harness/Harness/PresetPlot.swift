import Mobster

/// The paths on screen and the time the preset took to produce those same paths.
struct PresetPlot {
    let paths: [[SIMD2<Float>]]
    let duration: Duration

    init(kind: PresetKind, parameters: PresetParameters, frame: Frame, mode: PresetPlotMode) {
        var produced: [[SIMD2<Float>]] = []
        let elapsed = ContinuousClock().measure {
            produced = Self.generate(kind: kind, parameters: parameters, frame: frame, mode: mode)
        }
        paths = produced
        duration = elapsed
    }

    private static func generate(kind: PresetKind, parameters: PresetParameters, frame: Frame, mode: PresetPlotMode) -> [[SIMD2<Float>]] {
        switch kind {
        case .goldenRatio:
            GoldenRatioPreset().paths(in: frame, mode: mode)
        case .thirds:
            ThirdsPreset().paths(in: frame, mode: mode)
        case .columns:
            ColumnsPreset(count: parameters.columnCount, gutter: parameters.columnGutter).paths(in: frame, mode: mode)
        case .rows:
            RowsPreset(count: parameters.rowCount, gutter: parameters.rowGutter).paths(in: frame, mode: mode)
        case .ruler:
            RulerPreset(center: parameters.rulerCenter,
                        firstDegree: parameters.rulerFirstDegree,
                        secondDegree: parameters.rulerSecondDegree,
                        distance: parameters.rulerDistance).paths(in: frame, mode: mode)
        case .curve:
            CurvePreset(center: parameters.curveCenter,
                        firstDegree: parameters.curveFirstDegree,
                        secondDegree: parameters.curveSecondDegree,
                        distance: parameters.curveDistance,
                        control: parameters.curveControl,
                        resolution: parameters.curveResolution).paths(in: frame, mode: mode)
        }
    }
}
