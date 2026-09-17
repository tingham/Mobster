import Metal
import Testing
@testable import Mobster

struct MeshRunTests {
    /// Five hundred and twelve square, which the derived resolution makes one fragment to the scene unit.
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512))
    private let fit = 12
    /// One component standing in two places, which is the same pair of identities meeting the background twice. A flat mesh has no depth to foreshorten, so both plates land where they were laid.
    private let plates = Mesh(triangles: MeshRunTests.plate(from: SIMD2<Float>(100, 100), to: SIMD2<Float>(200, 200))
        + MeshRunTests.plate(from: SIMD2<Float>(300, 100), to: SIMD2<Float>(400, 200)))

    private static func plate(from least: SIMD2<Float>, to most: SIMD2<Float>) -> [MeshTriangle] {
        let corners = [SIMD3<Float>(least.x, least.y, 0),
                       SIMD3<Float>(most.x, least.y, 0),
                       SIMD3<Float>(most.x, most.y, 0),
                       SIMD3<Float>(least.x, most.y, 0)]

        return [MeshTriangle(first: corners[0], second: corners[1], third: corners[2], identity: MeshIdentity(1)),
                MeshTriangle(first: corners[0], second: corners[2], third: corners[3], identity: MeshIdentity(1))]
    }

    private func extraction() -> MeshExtraction {
        MeshExtraction(mesh: plates, frame: square, fit: fit, perspective: MeshPerspective())
    }

    private func seams() throws -> [MeshSeam] {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let raster = try #require(try extraction().raster(device: device))

        return MeshBoundary(raster: raster).seams()
    }

    private func paths() throws -> [[SIMD2<Float>]] {
        let device = try #require(MTLCreateSystemDefaultDevice())

        return try extraction().paths(device: device)
    }

    /// The two plates carry one identity between them, so the pair that meets the background meets it twice and each meeting is traced and fitted on its own.
    @Test func aPairMeetingInTwoPlacesYieldsAPathForEach() throws {
        let pair = SIMD2<UInt32>(1, MeshIdentityRaster.background)
        let extracted = try paths()

        #expect(try seams().map(\.identities) == [pair, pair])
        #expect(extracted.count == 2)
        #expect(extracted.allSatisfy { $0.count == fit })
    }

    /// Neither path is joined across the gap between the plates, so each one stands wholly on the plate it was traced from.
    @Test func neitherPathRunsAcrossTheGapBetweenThem() throws {
        let across = try paths().map { path in path.map(\.x) }

        #expect(across.contains { run in run.allSatisfy { $0 > 90 && $0 < 210 } })
        #expect(across.contains { run in run.allSatisfy { $0 > 290 && $0 < 410 } })
    }
}
