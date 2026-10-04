import Testing
@testable import Mobster

struct PathRoleTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    @Test func aLineDeclaringNoRoleIsForm() {
        #expect(Line(verts: [Vert(location: SIMD2<Float>(0, 0))]).role == .form)
        #expect(Line(verts: [Vert(location: SIMD2<Float>(0, 0))], identifier: LineIdentifier(1)).role == .form)
    }

    @Test func aDeclaredRoleIsCarried() {
        #expect(Line(verts: [], role: .construction).role == .construction)
        #expect(Line(verts: [], identifier: LineIdentifier(2), role: .construction).role == .construction)
    }

    /// The spiral is the first path and the rectangles are the rest, so the roles fall in the order the preset emits.
    @Test func theGoldenRatioSpiralIsFormAndItsQuadlinesAreConstruction() {
        let plotted = GoldenRatioPreset(quadlines: true).paths(in: frame)

        #expect(plotted.count > 1)
        #expect(plotted[0].role == .form)
        #expect(plotted.dropFirst().allSatisfy { $0.role == .construction })
    }

    @Test func theGoldenRatioWithoutQuadlinesVendsFormAlone() {
        let plotted = GoldenRatioPreset(quadlines: false).paths(in: frame)

        #expect(plotted.count == 1)
        #expect(plotted[0].role == .form)
    }

    @Test func everyOtherPresetVendsForm() {
        let presets: [any Preset] = [ThirdsPreset(),
                                     ColumnsPreset(count: 4, gutter: 0.05),
                                     RowsPreset(count: 3, gutter: 0.02),
                                     GridPreset(count: 4, gutter: 0.05),
                                     RulerPreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08),
                                     CurvePreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08, control: SIMD2<Float>(0.55, 0.7), resolution: 16)]

        for preset in presets {
            let plotted = preset.paths(in: frame)

            #expect(!plotted.isEmpty)
            #expect(plotted.allSatisfy { $0.role == .form })
        }
    }
}
