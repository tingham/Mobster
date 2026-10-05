import Mobster
import Testing

/// The rosters a consumer offers a person to choose from, read through the public surface rather than through a testable import, because a conformance a consumer cannot see is one it keeps its own list against.
struct VendRosterTests {
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512))
    private let frontal = SIMD3<Float>(0, 0, 1)

    private func figure(sex: FigureSex) -> FigurePreset {
        FigurePreset(sex: sex,
                     heads: 8,
                     target: frontal,
                     roll: 0,
                     headTarget: frontal,
                     leftHand: SIMD2<Float>(0.1, 0.5),
                     rightHand: SIMD2<Float>(0.9, 0.5),
                     leftFoot: SIMD2<Float>(0.4, 1),
                     rightFoot: SIMD2<Float>(0.6, 1),
                     headLines: false)
    }

    /// Each plate in the roster plots, and plots a figure of its own, so a picker driven by the roster offers nothing that draws the same construction twice.
    @Test func everyFigureSexPlotsItsOwnPlate() {
        let meshes = FigureSex.allCases.map { figure(sex: $0).mesh(in: square) }

        #expect(FigureSex.allCases == [.male, .female])
        #expect(meshes.allSatisfy { !$0.triangles.isEmpty })
        #expect(Set(meshes).count == meshes.count)
    }

    @Test func everyHeadSexPlotsItsOwnProportions() {
        let meshes = HeadSex.allCases.map { HeadPreset(sex: $0, target: frontal, roll: 0).mesh(in: square) }

        #expect(HeadSex.allCases == [.male, .female])
        #expect(meshes.allSatisfy { !$0.triangles.isEmpty })
        #expect(Set(meshes).count == meshes.count)
    }

    @Test func everyPresetFocusPlotsItsOwnOrientation() {
        let plots = PresetFocus.allCases.map { GoldenRatioPreset(focus: $0, quadlines: GoldenRatioPreset.quadlines).paths(in: square).map { $0.verts.map(\.location) } }

        #expect(PresetFocus.allCases == [.minXMinY, .maxXMinY, .minXMaxY, .maxXMaxY])
        #expect(plots.allSatisfy { !$0.isEmpty })
        #expect(Set(plots).count == plots.count)
    }
}
