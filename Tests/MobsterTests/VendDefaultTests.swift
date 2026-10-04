import Metal
import Mobster
import Testing

/// The values the package vends for what a consumer must supply to construct, read through the public surface rather than through a testable import.
struct VendDefaultTests {
    /// Five hundred and twelve square, which the derived resolution makes one fragment to the scene unit.
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512))
    /// Straight out of the near face of the box, which stands one face toward the viewer and so puts one boundary against the background.
    private let axis = SIMD3<Float>(0, 0, 1)

    /// The count the package vends is one it extracts at: every boundary comes back fitted to it, so a consumer reading it needs no count of its own.
    @Test func theVendedFitIsWhatABoundaryComesBackAt() throws {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let mesh = CubeMesh(position: SIMD2<Float>(0.5, 0.5), size: 0.5, target: axis).mesh(in: square)
        let paths = try MeshExtraction(mesh: mesh, frame: square, fit: MeshExtraction.fit, perspective: MeshPerspective()).paths(device: device).map { $0.verts.map(\.location) }

        #expect(!paths.isEmpty)
        #expect(paths.allSatisfy { $0.count == MeshExtraction.fit })
    }
}
