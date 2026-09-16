import Metal
import Testing
@testable import Mobster

struct GuideMeshSourceTests {
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512))
    private let diagonal = SIMD3<Float>(1, Float(3).squareRoot(), Float(2).squareRoot())
    private let fit = 12

    /// A mesh source has its lines extracted from a projection of the mesh, which the box view puts at six.
    @Test func aMeshSourceIsExtractedIntoLines() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let mesh = CubeMesh(position: SIMD2<Float>(0.5, 0.5), size: 0.5, target: diagonal).mesh(in: square)
        let guide = Guide(frame: square)

        try guide.initialize(source: .mesh(mesh, device: device, fit: fit), frame: square, adhesion: 1, duration: 1, settleEpsilon: 4, budget: .max)

        #expect(guide.lines.count == 6)
        #expect(guide.lines.allSatisfy { $0.verts.count == fit })
    }

    /// Nothing keys a mesh, so the verts of an extracted line carry no identifier.
    @Test func anExtractedLineCarriesNoIdentifier() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let mesh = CubeMesh(position: SIMD2<Float>(0.5, 0.5), size: 0.5, target: diagonal).mesh(in: square)
        let guide = Guide(frame: square)

        try guide.initialize(source: .mesh(mesh, device: device, fit: fit), frame: square, adhesion: 1, duration: 1, settleEpsilon: 4, budget: .max)

        #expect(guide.lines.allSatisfy { $0.identifier == nil })
        #expect(guide.lines.allSatisfy { line in line.verts.allSatisfy { $0.identifier == nil } })
    }

    /// A preset needs no mesh and so needs no device, which is what carrying the device on the mesh source alone leaves it free of.
    @Test func aPresetSourceIsInitializedWithNoDeviceInSight() throws {
        let guide = Guide(frame: square)

        try guide.initialize(source: .preset(ThirdsPreset()), frame: square, adhesion: 1, duration: 1, settleEpsilon: 4, budget: .max)

        #expect(guide.lines.count == 4)
    }
}
