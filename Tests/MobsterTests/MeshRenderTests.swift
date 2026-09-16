import Metal
import Testing
@testable import Mobster

struct MeshRenderTests {
    /// Five hundred and twelve square, which the derived resolution makes one fragment to the scene unit.
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512))

    private func raster(of mesh: Mesh) throws -> MeshIdentityRaster {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let render = try MeshRender(device: device)

        return try #require(try render.raster(of: mesh, in: square, resolution: MeshResolution(frame: square)))
    }

    @Test func theTargetTakesItsResolutionFromTheFrame() throws {
        let wide = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 400))
        let device = try #require(MTLCreateSystemDefaultDevice())
        let render = try MeshRender(device: device)
        let mesh = CubeMesh(position: SIMD2<Float>(0.5, 0.5), size: 0.5, target: SIMD3<Float>(0, 0, 1)).mesh(in: wide)
        let drawn = try #require(try render.raster(of: mesh, in: wide, resolution: MeshResolution(frame: wide)))

        #expect(drawn.columns == MeshResolution(frame: wide).columns)
        #expect(drawn.rows == MeshResolution(frame: wide).rows)
        #expect(drawn.identities.count == MeshResolution(frame: wide).fragments)
    }

    /// Two components meeting along a diagonal, ten and twenty, so anything averaged between them would read as a third identity that means nothing.
    @Test func anIdentityIsNeverInterpolated() throws {
        let mesh = Mesh(triangles: [
            MeshTriangle(first: SIMD3<Float>(0, 0, 0), second: SIMD3<Float>(512, 0, 0), third: SIMD3<Float>(0, 512, 0), identity: MeshIdentity(10)),
            MeshTriangle(first: SIMD3<Float>(512, 0, 0), second: SIMD3<Float>(512, 512, 0), third: SIMD3<Float>(0, 512, 0), identity: MeshIdentity(20)),
        ])

        #expect(Set(try raster(of: mesh).identities) == [10, 20])
    }

    /// The near face of the box covers the far one exactly, so what the far one loses it loses to the depth test and to nothing else.
    @Test func theDepthTestDecidesWhatIsSeen() throws {
        let mesh = CubeMesh(position: SIMD2<Float>(0.5, 0.5), size: 0.5, target: SIMD3<Float>(0, 0, 1)).mesh(in: square)

        #expect(Set(try raster(of: mesh).identities) == [6, MeshIdentityRaster.background])
    }

    /// The box is sized to a quarter of the Frame and centred, so the corner of the target stands well clear of it.
    @Test func aFragmentCoveringNoComponentCarriesTheBackground() throws {
        let mesh = CubeMesh(position: SIMD2<Float>(0.5, 0.5), size: 0.25, target: SIMD3<Float>(0, 0, 1)).mesh(in: square)

        #expect(try raster(of: mesh).identity(column: 0, row: 0) == MeshIdentityRaster.background)
    }

    @Test func aMeshOfNoTrianglesIsNotRendered() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let render = try MeshRender(device: device)

        #expect(try render.raster(of: Mesh(triangles: []), in: square, resolution: MeshResolution(frame: square)) == nil)
    }
}
