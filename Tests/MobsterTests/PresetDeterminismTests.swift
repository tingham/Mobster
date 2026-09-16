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
        { frame in HeadPreset(sex: .male, target: SIMD3<Float>(0.8, 0.4, 1), roll: 0.25).paths(in: frame) },
        { frame in PresetDeterminismTests.ashcan().paths(in: frame) },
    ]

    /// One arm reaching past what it can span and one within it, so a sequence recorded here covers both answers the solve gives.
    static func ashcan() -> AshcanPreset {
        AshcanPreset(sex: .male,
                     heads: 8,
                     leftHand: SIMD2<Float>(0.18, 0.62),
                     rightHand: SIMD2<Float>(0.69, 0.5),
                     leftFoot: SIMD2<Float>(0.42, 1),
                     rightFoot: SIMD2<Float>(0.58, 0.94),
                     leftElbowPole: SIMD2<Float>(-1, 0),
                     rightElbowPole: SIMD2<Float>(1, 0),
                     leftKneePole: SIMD2<Float>(-1, 0),
                     rightKneePole: SIMD2<Float>(1, 0),
                     headLines: true)
    }

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

    /// Taken off level, off centre and rolled, so the recorded sequence stands on the basis and on the near clip as well as on the proportions.
    @Test func headMatchesItsRecordedSequence() {
        let paths = HeadPreset(sex: .male, target: SIMD3<Float>(0.8, 0.4, 1), roll: 0.25).paths(in: frame)

        #expect(paths.map(\.count) == [65, 11, 22, 27, 6, 5, 16, 17, 28, 3, 5, 5])
        #expect(matches(sampled(paths[0], at: [0, 16, 32, 48]), [[
            SIMD2<Float>(428.8667, 201.93372),
            SIMD2<Float>(296.51993, 371.43658),
            SIMD2<Float>(151.1333, 188.8939),
            SIMD2<Float>(283.4801, 19.391006),
        ]]))
        #expect(matches(sampled(paths[1], at: [0, 5, 10]), [[
            SIMD2<Float>(386.22803, 243.5278),
            SIMD2<Float>(422.14963, 223.93523),
            SIMD2<Float>(426.8631, 197.6071),
        ]]))
        #expect(matches(sampled(paths[2], at: [0, 10, 21]), [[
            SIMD2<Float>(156.17612, 198.75928),
            SIMD2<Float>(246.89929, 244.1209),
            SIMD2<Float>(386.228, 243.52783),
        ]]))
        #expect(matches(sampled(paths[3], at: [0, 13, 26]), [[
            SIMD2<Float>(287.703, 28.558525),
            SIMD2<Float>(381.4177, 193.02051),
            SIMD2<Float>(345.37134, 360.87958),
        ]]))
        #expect(matches(sampled(paths[8], at: [0, 13, 27]), [[
            SIMD2<Float>(157.99539, 135.01463),
            SIMD2<Float>(227.46494, 112.523415),
            SIMD2<Float>(281.5036, 249.72656),
        ]]))
        #expect(matches([paths[9], paths[10], paths[11]], [
            [
                SIMD2<Float>(424.02692, 421.4559),
                SIMD2<Float>(353.61322, 442.17215),
                SIMD2<Float>(221.16681, 330.93872),
            ],
            [
                SIMD2<Float>(423.0997, 354.10147),
                SIMD2<Float>(424.02692, 421.4559),
                SIMD2<Float>(353.61322, 442.17215),
                SIMD2<Float>(352.68597, 374.81772),
                SIMD2<Float>(423.0997, 354.10147),
            ],
            [
                SIMD2<Float>(390.103, 319.55176),
                SIMD2<Float>(390.103, 495.0),
                SIMD2<Float>(189.89702, 495.0),
                SIMD2<Float>(189.89702, 319.55176),
                SIMD2<Float>(390.103, 319.55176),
            ],
        ]))
    }
}
