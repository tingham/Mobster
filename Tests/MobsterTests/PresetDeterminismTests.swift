import Testing
@testable import Mobster

struct PresetDeterminismTests {
    static let plotters: [@Sendable (Frame) -> [[SIMD2<Float>]]] = [
        { frame in GoldenRatioPreset(focus: .maxXMinY).paths(in: frame) },
        { frame in ThirdsPreset().paths(in: frame) },
        { frame in ThirdsPreset(mode: .bounds).paths(in: frame) },
        { frame in ColumnsPreset(count: 4, gutter: 0.05).paths(in: frame) },
        { frame in ColumnsPreset(count: 4, gutter: 0.05, mode: .bounds).paths(in: frame) },
        { frame in RowsPreset(count: 3, gutter: 0.02).paths(in: frame) },
        { frame in RowsPreset(count: 3, gutter: 0.02, mode: .bounds).paths(in: frame) },
        { frame in GridPreset(count: 4, gutter: 0.05).paths(in: frame) },
        { frame in GridPreset(count: 4, gutter: 0.05, mode: .bounds).paths(in: frame) },
        { frame in RulerPreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08).paths(in: frame) },
        { frame in RulerPreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08, mode: .bounds).paths(in: frame) },
        { frame in CurvePreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08, control: SIMD2<Float>(0.55, 0.7), resolution: 16).paths(in: frame) },
        { frame in CurvePreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08, control: SIMD2<Float>(0.55, 0.7), resolution: 16, mode: .bounds).paths(in: frame) },
        { frame in HeadPreset(sex: .male, target: SIMD3<Float>(0.8, 0.4, 1), roll: 0.25).paths(in: frame) },
        { frame in HeadPreset(sex: .male, target: SIMD3<Float>(0.8, 0.4, 1), roll: 0.25, mode: .bounds).paths(in: frame) },
        { frame in PresetDeterminismTests.ashcan(mode: .aspect).paths(in: frame) },
        { frame in PresetDeterminismTests.ashcan(mode: .bounds).paths(in: frame) },
    ]

    /// Indices in plotters whose immediate successor is the same preset in bounds mode.
    static let aspectPlotters = [1, 3, 5, 7, 9, 11, 13, 15]

    /// One arm reaching past what it can span and one within it, so a sequence recorded here covers both answers the solve gives.
    static func ashcan(mode: PresetPlotMode) -> AshcanPreset {
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
                     headLines: true,
                     mode: mode)
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
        #expect(matches(ThirdsPreset(mode: .bounds).paths(in: frame), [
            [SIMD2<Float>(183.33334, -65.0), SIMD2<Float>(183.33334, 575.0)],
            [SIMD2<Float>(396.6667, -65.0), SIMD2<Float>(396.6667, 575.0)],
            [SIMD2<Float>(-30.0, 148.33334), SIMD2<Float>(610.0, 148.33334)],
            [SIMD2<Float>(-30.0, 361.6667), SIMD2<Float>(610.0, 361.6667)],
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
        #expect(matches(ColumnsPreset(count: 4, gutter: 0.05, mode: .bounds).paths(in: frame), [
            [SIMD2<Float>(106.0, -65.0), SIMD2<Float>(106.0, 575.0)],
            [SIMD2<Float>(138.0, -65.0), SIMD2<Float>(138.0, 575.0)],
            [SIMD2<Float>(274.0, -65.0), SIMD2<Float>(274.0, 575.0)],
            [SIMD2<Float>(306.0, -65.0), SIMD2<Float>(306.0, 575.0)],
            [SIMD2<Float>(442.0, -65.0), SIMD2<Float>(442.0, 575.0)],
            [SIMD2<Float>(474.0, -65.0), SIMD2<Float>(474.0, 575.0)],
        ]))
    }

    @Test func rowsMatchesItsRecordedSequence() {
        #expect(matches(RowsPreset(count: 3, gutter: 0.02).paths(in: frame), [
            [SIMD2<Float>(-30.0, 168.6), SIMD2<Float>(610.0, 168.6)],
            [SIMD2<Float>(-30.0, 178.2), SIMD2<Float>(610.0, 178.2)],
            [SIMD2<Float>(-30.0, 331.8), SIMD2<Float>(610.0, 331.8)],
            [SIMD2<Float>(-30.0, 341.4), SIMD2<Float>(610.0, 341.4)],
        ]))
        #expect(matches(RowsPreset(count: 3, gutter: 0.02, mode: .bounds).paths(in: frame), [
            [SIMD2<Float>(-30.0, 139.8), SIMD2<Float>(610.0, 139.8)],
            [SIMD2<Float>(-30.0, 152.6), SIMD2<Float>(610.0, 152.6)],
            [SIMD2<Float>(-30.0, 357.4), SIMD2<Float>(610.0, 357.4)],
            [SIMD2<Float>(-30.0, 370.2), SIMD2<Float>(610.0, 370.2)],
        ]))
    }

    @Test func rulerMatchesItsRecordedSequence() {
        let aspect = RulerPreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08)
        let bounds = RulerPreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08, mode: .bounds)

        #expect(matches(aspect.paths(in: frame), [
            [SIMD2<Float>(610.0, 391.05045), SIMD2<Float>(-30.0, 183.0251)],
            [SIMD2<Float>(610.0, 349.19934), SIMD2<Float>(-30.0, 141.17398)],
            [SIMD2<Float>(610.0, 432.90155), SIMD2<Float>(-30.0, 224.87624)],
        ]))
        #expect(matches(bounds.paths(in: frame), [
            [SIMD2<Float>(610.0, 436.4006), SIMD2<Float>(-30.0, 159.03348)],
            [SIMD2<Float>(610.0, 380.59912), SIMD2<Float>(-30.0, 103.23198)],
            [SIMD2<Float>(610.0, 492.2021), SIMD2<Float>(-30.0, 214.83496)],
        ]))
    }

    @Test func curveMatchesItsRecordedSequence() {
        let indices = [0, 8, 16]
        let aspect = CurvePreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08, control: SIMD2<Float>(0.55, 0.7), resolution: 16).paths(in: frame)
        let bounds = CurvePreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08, control: SIMD2<Float>(0.55, 0.7), resolution: 16, mode: .bounds).paths(in: frame)

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

    /// Taken off level, off centre and rolled, so the recorded sequence stands on the basis and on the near clip as well as on the proportions.
    @Test func headMatchesItsRecordedSequence() {
        let paths = HeadPreset(sex: .male, target: SIMD3<Float>(0.8, 0.4, 1), roll: 0.25).paths(in: frame)

        #expect(paths.map(\.count) == [65, 11, 22, 27, 6, 5, 16, 17, 28, 3, 5, 5])
        #expect(matches(sampled(paths[0], at: [0, 16, 32, 48]), [[
            SIMD2<Float>(475.1556, 201.93372),
            SIMD2<Float>(298.69324, 371.43658),
            SIMD2<Float>(104.84439, 188.8939),
            SIMD2<Float>(281.3068, 19.391006),
        ]]))
        #expect(matches(sampled(paths[1], at: [0, 5, 10]), [[
            SIMD2<Float>(418.30402, 243.5278),
            SIMD2<Float>(466.1995, 223.93523),
            SIMD2<Float>(472.48413, 197.6071),
        ]]))
        #expect(matches(sampled(paths[2], at: [0, 10, 21]), [[
            SIMD2<Float>(111.56816, 198.75928),
            SIMD2<Float>(232.53238, 244.1209),
            SIMD2<Float>(418.304, 243.52783),
        ]]))
        #expect(matches(sampled(paths[3], at: [0, 13, 26]), [[
            SIMD2<Float>(286.93732, 28.558525),
            SIMD2<Float>(411.89026, 193.02051),
            SIMD2<Float>(363.82846, 360.87958),
        ]]))
        #expect(matches(sampled(paths[8], at: [0, 13, 27]), [[
            SIMD2<Float>(113.99385, 135.01463),
            SIMD2<Float>(206.6199, 112.523415),
            SIMD2<Float>(278.67145, 249.72656),
        ]]))
        #expect(matches([paths[9], paths[10], paths[11]], [
            [
                SIMD2<Float>(468.70255, 421.4559),
                SIMD2<Float>(374.81763, 442.17215),
                SIMD2<Float>(198.22241, 330.93872),
            ],
            [
                SIMD2<Float>(467.46628, 354.10147),
                SIMD2<Float>(468.70255, 421.4559),
                SIMD2<Float>(374.81763, 442.17215),
                SIMD2<Float>(373.5813, 374.81772),
                SIMD2<Float>(467.46628, 354.10147),
            ],
            [
                SIMD2<Float>(423.47064, 319.55176),
                SIMD2<Float>(423.47064, 495.0),
                SIMD2<Float>(156.52936, 495.0),
                SIMD2<Float>(156.52936, 319.55176),
                SIMD2<Float>(423.47064, 319.55176),
            ],
        ]))
    }

    @Test(arguments: PresetDeterminismTests.aspectPlotters)
    func theTwoPlotModesDiffer(index: Int) {
        let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(640, 480))

        #expect(Self.plotters[index](square) != Self.plotters[index + 1](square))
    }
}
