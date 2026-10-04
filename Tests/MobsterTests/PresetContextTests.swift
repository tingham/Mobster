import Metal
import Mobster
import Testing

/// The production context against the parameters it stands beside: a consumer stores the parameters and builds the context again each time it produces.
struct PresetContextTests {
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512))
    private let frontal = SIMD3<Float>(0, 0, 1)
    private let diagonal = SIMD3<Float>(1, Float(3).squareRoot(), Float(2).squareRoot())

    /// Equal parameters are equal and hash alike, which a held device reference could not synthesize at all.
    @Test func theParametersOfAMeshGuideTypeStayStorable() {
        #expect(Set([cube(), cube()]).count == 1)
        #expect(Set([head(), head()]).count == 1)
        #expect(Set([figure(), figure()]).count == 1)
    }

    /// The parameters build their mesh with no device in sight, the device arriving only where the production happens.
    @Test func theParametersOfAMeshGuideTypeCarryNoDevice() {
        #expect(!cube().mesh(in: square).triangles.isEmpty)
        #expect(!head().mesh(in: square).triangles.isEmpty)
        #expect(!figure().mesh(in: square).triangles.isEmpty)
    }

    /// A consumer that kept only the parameters and built the context again produces what it produced before.
    @Test func aRebuiltContextProducesTheSameLines() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let parameters = cube()
        let first = try CubeConfiguration(parameters: parameters, context: context(device)).lines(in: square)
        let second = try CubeConfiguration(parameters: parameters, context: context(device)).lines(in: square)

        #expect(!first.isEmpty)
        #expect(first.map { $0.verts.map(\.location) } == second.map { $0.verts.map(\.location) })
    }

    /// The count every boundary comes back at is the context's to carry and the package's to answer, so a consumer reads the offer rather than holding one of its own.
    @Test func theContextCarriesTheFitTheExtractionReadsAt() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let production = context(device)
        let lines = try CubeConfiguration(parameters: cube(), context: production).lines(in: square)

        #expect(production.fit == MeshExtraction.fit)
        #expect(lines.allSatisfy { $0.verts.count == production.fit })
    }

    private func context(_ device: any MTLDevice) -> PresetContext {
        PresetContext(device: device, fit: MeshExtraction.fit, perspective: MeshPerspective(fieldOfView: MeshPerspective.opening))
    }

    private func cube() -> CubeMesh {
        CubeMesh(position: SIMD2<Float>(0.5, 0.5), size: 0.5, target: diagonal)
    }

    private func head() -> HeadPreset {
        HeadPreset(sex: .male, target: SIMD3<Float>(1, 0, 1), roll: 0)
    }

    private func figure() -> FigurePreset {
        FigurePreset(sex: .male,
                     heads: 8,
                     target: frontal,
                     headTarget: frontal,
                     leftHand: SIMD2<Float>(0.1, 0.5),
                     rightHand: SIMD2<Float>(0.9, 0.5),
                     leftFoot: SIMD2<Float>(0.4, 1),
                     rightFoot: SIMD2<Float>(0.6, 1),
                     headLines: false)
    }
}
