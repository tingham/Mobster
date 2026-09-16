import Testing
@testable import Mobster

struct PresetDeterminismTests {
    static let plotters: [@Sendable (Frame) -> [[SIMD2<Float>]]] = [
        { frame in GoldenRatioPreset(focus: .maxXMinY).paths(in: frame) },
        { frame in ThirdsPreset().paths(in: frame) },
        { frame in ColumnsPreset(count: 4, gutter: 0.05).paths(in: frame) },
        { frame in RowsPreset(count: 3, gutter: 0.02).paths(in: frame) },
        { frame in GridPreset(count: 4, gutter: 0.05).paths(in: frame) },
        { frame in RulerPreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08).paths(in: frame) },
        { frame in CurvePreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08, control: SIMD2<Float>(0.55, 0.7), resolution: 16).paths(in: frame) },
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
        let stored = GoldenRatioPreset(focus: .maxXMinY).paths(in: frame)
        let mirrored = GoldenRatioPreset(focus: .minXMaxY).paths(in: frame)

        #expect(stored.count == 13)
        #expect(stored.map(\.count) == [289, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5])
        #expect(matches(sampled(stored[0], at: indices), [[
            SIMD2<Float>(-98.328156, 15.0),
            SIMD2<Float>(494.98447, 15.0),
            SIMD2<Float>(494.98447, 155.0621),
            SIMD2<Float>(461.92026, 155.0621),
            SIMD2<Float>(461.92026, 147.25673),
        ]]))
        #expect(matches([stored[1]], [[
            SIMD2<Float>(-98.328156, 15.0),
            SIMD2<Float>(678.3281, 15.0),
            SIMD2<Float>(678.3281, 495.0),
            SIMD2<Float>(-98.328156, 495.0),
            SIMD2<Float>(-98.328156, 15.0),
        ]]))
        #expect(matches(sampled(mirrored[0], at: indices), [[
            SIMD2<Float>(678.3281, 495.0),
            SIMD2<Float>(85.01552, 495.0),
            SIMD2<Float>(85.01552, 354.93787),
            SIMD2<Float>(118.07974, 354.93787),
            SIMD2<Float>(118.07974, 362.74326),
        ]]))
    }

    @Test func thirdsMatchesItsRecordedSequence() {
        #expect(matches(ThirdsPreset().paths(in: frame), [
            [SIMD2<Float>(183.33334, 15.0), SIMD2<Float>(183.33334, 495.0)],
            [SIMD2<Float>(396.6667, 15.0), SIMD2<Float>(396.6667, 495.0)],
            [SIMD2<Float>(-30.0, 175.0), SIMD2<Float>(610.0, 175.0)],
            [SIMD2<Float>(-30.0, 335.0), SIMD2<Float>(610.0, 335.0)],
        ]))
    }

    @Test func columnsMatchesItsRecordedSequence() {
        #expect(matches(ColumnsPreset(count: 4, gutter: 0.05).paths(in: frame), [
            [SIMD2<Float>(106.0, 15.0), SIMD2<Float>(106.0, 495.0)],
            [SIMD2<Float>(138.0, 15.0), SIMD2<Float>(138.0, 495.0)],
            [SIMD2<Float>(274.0, 15.0), SIMD2<Float>(274.0, 495.0)],
            [SIMD2<Float>(306.0, 15.0), SIMD2<Float>(306.0, 495.0)],
            [SIMD2<Float>(442.0, 15.0), SIMD2<Float>(442.0, 495.0)],
            [SIMD2<Float>(474.0, 15.0), SIMD2<Float>(474.0, 495.0)],
        ]))
    }

    @Test func rowsMatchesItsRecordedSequence() {
        #expect(matches(RowsPreset(count: 3, gutter: 0.02).paths(in: frame), [
            [SIMD2<Float>(-30.0, 168.6), SIMD2<Float>(610.0, 168.6)],
            [SIMD2<Float>(-30.0, 178.2), SIMD2<Float>(610.0, 178.2)],
            [SIMD2<Float>(-30.0, 331.8), SIMD2<Float>(610.0, 331.8)],
            [SIMD2<Float>(-30.0, 341.4), SIMD2<Float>(610.0, 341.4)],
        ]))
    }

    @Test func rulerMatchesItsRecordedSequence() {
        let ruler = RulerPreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08)

        #expect(matches(ruler.paths(in: frame), [
            [SIMD2<Float>(610.0, 391.05045), SIMD2<Float>(-30.0, 183.0251)],
            [SIMD2<Float>(610.0, 349.19934), SIMD2<Float>(-30.0, 141.17398)],
            [SIMD2<Float>(610.0, 432.90155), SIMD2<Float>(-30.0, 224.87624)],
        ]))
    }

    @Test func curveMatchesItsRecordedSequence() {
        let indices = [0, 8, 16]
        let curve = CurvePreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08, control: SIMD2<Float>(0.55, 0.7), resolution: 16).paths(in: frame)

        #expect(curve.allSatisfy { $0.count == 17 })
        #expect(matches(curve.flatMap { sampled($0, at: indices) }, [
            [SIMD2<Float>(610.0, 391.05045), SIMD2<Float>(306.0, 319.0189), SIMD2<Float>(-30.0, 183.0251)],
            [SIMD2<Float>(610.0, 352.72458), SIMD2<Float>(326.35956, 283.78543), SIMD2<Float>(-30.0, 138.25305)],
            [SIMD2<Float>(610.0, 429.37628), SIMD2<Float>(285.64038, 354.25232), SIMD2<Float>(-30.0, 227.79715)],
        ]))
    }
}
