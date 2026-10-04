import Metal
import Testing
@testable import Mobster

struct MeshRoleTests {
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512))
    /// Straight out of the near face of the box.
    private let axis = SIMD3<Float>(0, 0, 1)
    /// Down the body diagonal of the box, which stands three faces toward the viewer and so puts three seams inside the outline.
    private let diagonal = SIMD3<Float>(1, Float(3).squareRoot(), Float(2).squareRoot())

    private func extracted(_ target: SIMD3<Float>) throws -> [Line] {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let mesh = CubeMesh(position: SIMD2<Float>(0.5, 0.5), size: 0.5, target: target).mesh(in: square)

        return try MeshExtraction(mesh: mesh, frame: square, fit: MeshExtraction.fit, perspective: MeshPerspective()).paths(device: device)
    }

    @Test func aSilhouetteAgainstTheBackgroundIsForm() throws {
        let paths = try extracted(axis)

        #expect(paths.count == 1)
        #expect(paths[0].role == .form)
    }

    /// The seams fall first, second and fourth in the order the pairs of identities stand, the rest being the three stretches of outline.
    @Test func aBoundaryBetweenTwoComponentsIsConstruction() throws {
        let paths = try extracted(diagonal)

        #expect(paths.map(\.role) == [.construction, .construction, .form, .construction, .form, .form])
    }

    @Test func aMeshVendsBothRolesWithoutBeingAuthored() throws {
        let roles = Set(try extracted(diagonal).map(\.role))

        #expect(roles == [.form, .construction])
    }

    /// The near corner is where the three seams meet, so a vert standing on it is already at a seam and is carried out to the outline rather than held.
    @Test func aGuideOverAMeshBakesTheSilhouetteAlone() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let mesh = CubeMesh(position: SIMD2<Float>(0.5, 0.5), size: 0.5, target: diagonal).mesh(in: square)
        let corner = SIMD2<Float>(256, 256)
        let guide = Guide(frame: square)
        try guide.initialize(source: .mesh(mesh, device: device, fit: MeshExtraction.fit, perspective: MeshPerspective()),
                             frame: square,
                             adhesion: 1,
                             duration: 1,
                             settleEpsilon: 4,
                             budget: .max)
        let settled = guide.evaluate([Line(verts: [Vert(location: corner)])], at: 1)[0].verts[0].location
        let run = settled - corner

        #expect(guide.lines.count == 6)
        #expect(guide.lines.filter { $0.role == .form }.count == 3)
        #expect((run * run).sum().squareRoot() > 50)
    }
}
