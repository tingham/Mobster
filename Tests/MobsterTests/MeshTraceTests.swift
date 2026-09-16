import Testing
@testable import Mobster

struct MeshTraceTests {
    /// Four samples of one horizontal boundary, handed over out of order as a raster scan would gather them.
    private let scattered = [SIMD2<Float>(2.5, 1), SIMD2<Float>(0.5, 1), SIMD2<Float>(3.5, 1), SIMD2<Float>(1.5, 1)]

    @Test func aBoundaryComesBackInOrderAlongItself() {
        let ordered = MeshTrace(locations: scattered).ordered()

        #expect(ordered.count == 4)
        #expect(ordered == [SIMD2<Float>(0.5, 1), SIMD2<Float>(1.5, 1), SIMD2<Float>(2.5, 1), SIMD2<Float>(3.5, 1)])
    }

    /// A boundary running diagonally alternates the two lattices its samples sit on, and the walk follows it across both.
    @Test func aDiagonalBoundaryIsFollowedAcrossBothLattices() {
        let diagonal = [SIMD2<Float>(1, 0.5), SIMD2<Float>(1.5, 1), SIMD2<Float>(2, 1.5), SIMD2<Float>(2.5, 2)]
        let ordered = MeshTrace(locations: diagonal.reversed()).ordered()

        #expect(ordered == diagonal)
    }

    /// A pair of components meeting in two separate places keeps the run its seed stands on rather than joining the two across the gap.
    @Test func aRunIsNotJoinedAcrossAGap() {
        let split = [SIMD2<Float>(0.5, 1), SIMD2<Float>(1.5, 1), SIMD2<Float>(10.5, 1), SIMD2<Float>(11.5, 1)]

        #expect(MeshTrace(locations: split).ordered() == [SIMD2<Float>(0.5, 1), SIMD2<Float>(1.5, 1)])
    }

    @Test func aLoneSampleIsAlreadyInOrder() {
        #expect(MeshTrace(locations: [SIMD2<Float>(4, 0.5)]).ordered() == [SIMD2<Float>(4, 0.5)])
    }
}
