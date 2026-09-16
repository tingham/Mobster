import Testing
@testable import Mobster

struct MeshBoundaryTests {
    private func raster(_ columns: Int, _ rows: Int, _ identities: [UInt32]) -> MeshIdentityRaster {
        MeshIdentityRaster(columns: columns, rows: rows, identities: identities)
    }

    /// Two components side by side, the right of them meeting the background, so the boundary between them sits at column two and the silhouette at column three.
    @Test func adjacentFragmentsThatDifferAreABoundaryAndOnesThatAgreeAreNot() {
        let seams = MeshBoundary(raster: raster(4, 2, [1, 1, 2, .max,
                                                      1, 1, 2, .max])).seams()

        #expect(seams.count == 2)
        #expect(seams[0].identities == SIMD2<UInt32>(1, 2))
        #expect(seams[1].identities == SIMD2<UInt32>(2, .max))
    }

    /// The fragments either side of a boundary have their centres a fragment apart, so what sits between them is half a fragment from each.
    @Test func aBoundaryStandsMidwayBetweenTheFragmentsThatDiffer() {
        let seams = MeshBoundary(raster: raster(4, 2, [1, 1, 2, .max,
                                                      1, 1, 2, .max])).seams()

        #expect(seams[0].locations.sorted { $0.y < $1.y } == [SIMD2<Float>(2, 0.5), SIMD2<Float>(2, 1.5)])
        #expect(seams[1].locations.sorted { $0.y < $1.y } == [SIMD2<Float>(3, 0.5), SIMD2<Float>(3, 1.5)])
    }

    @Test func aBoundaryBetweenRowsStandsMidwayToo() {
        let seams = MeshBoundary(raster: raster(2, 2, [1, 1,
                                                      2, 2])).seams()

        #expect(seams.count == 1)
        #expect(seams[0].locations.sorted { $0.x < $1.x } == [SIMD2<Float>(0.5, 1), SIMD2<Float>(1.5, 1)])
    }

    @Test func oneIdentityThroughoutCarriesNoBoundary() {
        #expect(MeshBoundary(raster: raster(3, 3, Array(repeating: 4, count: 9))).seams().isEmpty)
    }

    /// An interior seam is a boundary as much as a silhouette is, so a component wholly surrounded by another still emits one.
    @Test func anInteriorSeamIsFoundWhereNothingDrawsIt() {
        let seams = MeshBoundary(raster: raster(3, 3, [1, 1, 1,
                                                      1, 2, 1,
                                                      1, 1, 1])).seams()

        #expect(seams.count == 1)
        #expect(seams[0].identities == SIMD2<UInt32>(1, 2))
        #expect(seams[0].locations.count == 4)
    }

    /// The pair of identities that meet orders the seams, lesser first, so a consumer telling one path from another by position gets the same order every time.
    @Test func theSeamsComeOutInTheOrderOfTheirIdentities() {
        let seams = MeshBoundary(raster: raster(4, 1, [7, 3, 5, 3])).seams()

        #expect(seams.map(\.identities) == [SIMD2<UInt32>(3, 5), SIMD2<UInt32>(3, 7)])
    }
}
