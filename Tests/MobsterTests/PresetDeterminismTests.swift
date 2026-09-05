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

    /// The Frame the recorded sequences below were taken against. Its origin is off zero so a sequence recorded from a preset that ignored the origin would not match.
    private let frame = Frame(origin: SIMD2<Float>(-30, 15), size: SIMD2<Float>(640, 480))

    /// Wide enough to absorb a difference in float rounding between architectures and far narrower than any change in geometry.
    private func matches(_ paths: [[SIMD2<Float>]], _ recorded: [[SIMD2<Float>]]) -> Bool {
        guard paths.count == recorded.count else { return false }

        for (path, expected) in zip(paths, recorded) {
            guard path.count == expected.count else { return false }
            for (location, target) in zip(path, expected) where abs(location.x - target.x) > 0.01 || abs(location.y - target.y) > 0.01 {
                return false
            }
        }

        return true
    }

    private func sampled(_ path: [SIMD2<Float>], at indices: [Int]) -> [[SIMD2<Float>]] {
        [indices.map { path[$0] }]
    }

    @Test func goldenRatioMatchesItsRecordedSequence() {
        let indices = [0, 72, 144, 216, 288]
        let aspect = GoldenRatioPreset().paths(in: frame, mode: .aspect)
        let bounds = GoldenRatioPreset().paths(in: frame, mode: .bounds)

        #expect(aspect.count == 1)
        #expect(aspect[0].count == 289)
        #expect(bounds[0].count == 289)
        #expect(matches(sampled(aspect[0], at: indices), [[
            SIMD2<Float>(-30.0, 15.0),
            SIMD2<Float>(458.9165, 15.0),
            SIMD2<Float>(458.9165, 155.0621),
            SIMD2<Float>(431.6701, 155.0621),
            SIMD2<Float>(431.6701, 147.25673),
        ]]))
        #expect(matches(sampled(bounds[0], at: indices), [[
            SIMD2<Float>(-98.328156, 15.0),
            SIMD2<Float>(494.98447, 15.0),
            SIMD2<Float>(494.98447, 155.0621),
            SIMD2<Float>(461.92026, 155.0621),
            SIMD2<Float>(461.92026, 147.25673),
        ]]))
    }

    @Test func thirdsMatchesItsRecordedSequence() {
        #expect(matches(ThirdsPreset().paths(in: frame, mode: .aspect), [
            [SIMD2<Float>(183.33334, 15.0), SIMD2<Float>(183.33334, 495.0)],
            [SIMD2<Float>(396.6667, 15.0), SIMD2<Float>(396.6667, 495.0)],
            [SIMD2<Float>(-30.0, 175.0), SIMD2<Float>(610.0, 175.0)],
            [SIMD2<Float>(-30.0, 335.0), SIMD2<Float>(610.0, 335.0)],
        ]))
        #expect(matches(ThirdsPreset().paths(in: frame, mode: .bounds), [
            [SIMD2<Float>(183.33334, -65.0), SIMD2<Float>(183.33334, 575.0)],
            [SIMD2<Float>(396.6667, -65.0), SIMD2<Float>(396.6667, 575.0)],
            [SIMD2<Float>(-30.0, 148.33334), SIMD2<Float>(610.0, 148.33334)],
            [SIMD2<Float>(-30.0, 361.6667), SIMD2<Float>(610.0, 361.6667)],
        ]))
    }

    @Test func columnsMatchesItsRecordedSequence() {
        #expect(matches(ColumnsPreset(count: 4, gutter: 0.05).paths(in: frame, mode: .aspect), [
            [SIMD2<Float>(106.0, 15.0), SIMD2<Float>(106.0, 495.0)],
            [SIMD2<Float>(138.0, 15.0), SIMD2<Float>(138.0, 495.0)],
            [SIMD2<Float>(274.0, 15.0), SIMD2<Float>(274.0, 495.0)],
            [SIMD2<Float>(306.0, 15.0), SIMD2<Float>(306.0, 495.0)],
            [SIMD2<Float>(442.0, 15.0), SIMD2<Float>(442.0, 495.0)],
            [SIMD2<Float>(474.0, 15.0), SIMD2<Float>(474.0, 495.0)],
        ]))
        #expect(matches(ColumnsPreset(count: 4, gutter: 0.05).paths(in: frame, mode: .bounds), [
            [SIMD2<Float>(106.0, -65.0), SIMD2<Float>(106.0, 575.0)],
            [SIMD2<Float>(138.0, -65.0), SIMD2<Float>(138.0, 575.0)],
            [SIMD2<Float>(274.0, -65.0), SIMD2<Float>(274.0, 575.0)],
            [SIMD2<Float>(306.0, -65.0), SIMD2<Float>(306.0, 575.0)],
            [SIMD2<Float>(442.0, -65.0), SIMD2<Float>(442.0, 575.0)],
            [SIMD2<Float>(474.0, -65.0), SIMD2<Float>(474.0, 575.0)],
        ]))
    }

    @Test func rowsMatchesItsRecordedSequence() {
        #expect(matches(RowsPreset(count: 3, gutter: 0.02).paths(in: frame, mode: .aspect), [
            [SIMD2<Float>(-30.0, 168.6), SIMD2<Float>(610.0, 168.6)],
            [SIMD2<Float>(-30.0, 178.2), SIMD2<Float>(610.0, 178.2)],
            [SIMD2<Float>(-30.0, 331.8), SIMD2<Float>(610.0, 331.8)],
            [SIMD2<Float>(-30.0, 341.4), SIMD2<Float>(610.0, 341.4)],
        ]))
        #expect(matches(RowsPreset(count: 3, gutter: 0.02).paths(in: frame, mode: .bounds), [
            [SIMD2<Float>(-30.0, 139.8), SIMD2<Float>(610.0, 139.8)],
            [SIMD2<Float>(-30.0, 152.6), SIMD2<Float>(610.0, 152.6)],
            [SIMD2<Float>(-30.0, 357.4), SIMD2<Float>(610.0, 357.4)],
            [SIMD2<Float>(-30.0, 370.2), SIMD2<Float>(610.0, 370.2)],
        ]))
    }

    @Test func rulerMatchesItsRecordedSequence() {
        let preset = RulerPreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08)

        #expect(matches(preset.paths(in: frame, mode: .aspect), [
            [SIMD2<Float>(610.0, 391.05045), SIMD2<Float>(-30.0, 183.0251)],
            [SIMD2<Float>(610.0, 349.19934), SIMD2<Float>(-30.0, 141.17398)],
            [SIMD2<Float>(610.0, 432.90155), SIMD2<Float>(-30.0, 224.87624)],
        ]))
        #expect(matches(preset.paths(in: frame, mode: .bounds), [
            [SIMD2<Float>(610.0, 436.4006), SIMD2<Float>(-30.0, 159.03348)],
            [SIMD2<Float>(610.0, 380.59912), SIMD2<Float>(-30.0, 103.23198)],
            [SIMD2<Float>(610.0, 492.2021), SIMD2<Float>(-30.0, 214.83496)],
        ]))
    }

    @Test func curveMatchesItsRecordedSequence() {
        let preset = CurvePreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08, control: SIMD2<Float>(0.55, 0.7), resolution: 16)
        let indices = [0, 8, 16]
        let aspect = preset.paths(in: frame, mode: .aspect)
        let bounds = preset.paths(in: frame, mode: .bounds)

        #expect(aspect.allSatisfy { $0.count == 17 })
        #expect(bounds.allSatisfy { $0.count == 17 })
        #expect(matches(aspect.flatMap { sampled($0, at: indices) }, [
            [SIMD2<Float>(610.0, 391.05045), SIMD2<Float>(306.0, 319.0189), SIMD2<Float>(-30.0, 183.0251)],
            [SIMD2<Float>(610.0, 352.72458), SIMD2<Float>(326.35956, 283.78543), SIMD2<Float>(-30.0, 138.25305)],
            [SIMD2<Float>(610.0, 429.37628), SIMD2<Float>(285.64038, 354.25232), SIMD2<Float>(-30.0, 227.79715)],
        ]))
        #expect(matches(bounds.flatMap { sampled($0, at: indices) }, [
            [SIMD2<Float>(610.0, 436.4006), SIMD2<Float>(306.0, 340.35852), SIMD2<Float>(-30.0, 159.03348)],
            [SIMD2<Float>(610.0, 385.29944), SIMD2<Float>(326.35956, 293.38058), SIMD2<Float>(-30.0, 99.3374)],
            [SIMD2<Float>(610.0, 487.5017), SIMD2<Float>(285.64038, 387.33643), SIMD2<Float>(-30.0, 218.72952)],
        ]))
    }

    @Test(arguments: 0 ..< PresetDeterminismTests.plotters.count)
    func theTwoPlotModesDiffer(index: Int) {
        let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(640, 480))
        let plot = Self.plotters[index]

        #expect(plot(square, .aspect) != plot(square, .bounds))
    }
}
