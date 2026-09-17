import Testing
@testable import Mobster

struct MeshTraceTests {
    /// Four samples of one horizontal boundary, handed over out of order as a raster scan would gather them.
    private let scattered = [SIMD2<Float>(2.5, 1), SIMD2<Float>(0.5, 1), SIMD2<Float>(3.5, 1), SIMD2<Float>(1.5, 1)]

    @Test func aBoundaryComesBackInOrderAlongItself() {
        let runs = MeshTrace(locations: scattered).ordered()

        #expect(runs.count == 1)
        #expect(runs[0] == [SIMD2<Float>(0.5, 1), SIMD2<Float>(1.5, 1), SIMD2<Float>(2.5, 1), SIMD2<Float>(3.5, 1)])
    }

    /// A boundary running diagonally alternates the two lattices its samples sit on, and the walk follows it across both.
    @Test func aDiagonalBoundaryIsFollowedAcrossBothLattices() {
        let diagonal = [SIMD2<Float>(1, 0.5), SIMD2<Float>(1.5, 1), SIMD2<Float>(2, 1.5), SIMD2<Float>(2.5, 2)]

        #expect(MeshTrace(locations: diagonal.reversed()).ordered() == [diagonal])
    }

    /// A pair of components meeting in two separate places yields a run for each rather than one run joined across the gap.
    @Test func eachMeetingOfAPairYieldsARunOfItsOwn() {
        let near = [SIMD2<Float>(0.5, 1), SIMD2<Float>(1.5, 1), SIMD2<Float>(2.5, 1)]
        let far = [SIMD2<Float>(10.5, 1), SIMD2<Float>(11.5, 1), SIMD2<Float>(12.5, 1)]
        let runs = MeshTrace(locations: near + far).ordered()

        #expect(runs.count == 2)
        #expect(Set(runs.map { $0.count }) == [3])
        #expect(runs.contains(near) || runs.contains(near.reversed()))
        #expect(runs.contains(far) || runs.contains(far.reversed()))
    }

    /// A form grazing another leaves a run of two fragments beside the run that is its silhouette, and the graze is dropped where the silhouette is kept.
    @Test func aRunShorterThanTheFloorIsDropped() {
        let grazed = (0 ..< 20).map { SIMD2<Float>(Float($0) + 0.5, 6) } + [SIMD2<Float>(9.5, 40), SIMD2<Float>(10.5, 40)]
        let runs = MeshTrace(locations: grazed).ordered()

        #expect(runs.count == 1)
        #expect(runs[0].count == 20)
        #expect(runs[0].first == SIMD2<Float>(0.5, 6))
    }

    /// A run standing at the floor is geometry rather than a graze, so the floor is the shortest run kept and not the shortest one dropped.
    @Test func aRunStandingAtTheFloorIsKept() {
        let held = (0 ..< MeshTrace.floor).map { SIMD2<Float>(Float($0) + 0.5, 2) }

        #expect(MeshTrace(locations: held).ordered() == [held])
    }

    @Test func aLoneSampleIsNoRun() {
        #expect(MeshTrace(locations: [SIMD2<Float>(4, 0.5)]).ordered().isEmpty)
    }
}
