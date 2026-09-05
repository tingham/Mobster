import Testing
@testable import Mobster

struct PresetDeterminismTests {
    static let plotters: [@Sendable (Frame, PresetPlotMode) -> [[SIMD2<Float>]]] = [
        { frame, mode in GoldenRatioPreset().paths(in: frame, mode: mode) },
        { frame, mode in ThirdsPreset().paths(in: frame, mode: mode) },
        { frame, mode in ColumnsPreset(count: 4, gutter: 0.05).paths(in: frame, mode: mode) },
        { frame, mode in RowsPreset(count: 3, gutter: 0.02).paths(in: frame, mode: mode) },
        { frame, mode in RulerPreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08).paths(in: frame, mode: mode) },
        { frame, mode in CurvePreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08, control: SIMD2<Float>(0.55, 0.7), resolution: 16).paths(in: frame, mode: mode) },
    ]

    @Test(arguments: 0 ..< PresetDeterminismTests.plotters.count)
    func repeatedPlottingIsIdentical(index: Int) {
        let frame = Frame(origin: SIMD2<Float>(-30, 15), size: SIMD2<Float>(640, 480))
        let plot = Self.plotters[index]

        #expect(plot(frame, .aspect) == plot(frame, .aspect))
        #expect(plot(frame, .bounds) == plot(frame, .bounds))
    }

    @Test(arguments: 0 ..< PresetDeterminismTests.plotters.count)
    func theTwoPlotModesDiffer(index: Int) {
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(640, 480))
        let plot = Self.plotters[index]

        #expect(plot(frame, .aspect) != plot(frame, .bounds))
    }
}
