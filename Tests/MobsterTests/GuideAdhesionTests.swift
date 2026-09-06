import Testing
@testable import Mobster

struct GuideAdhesionTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))
    /// The texel centres in opposite corners of a 128 by 128 Frame baked at resolution 128, the furthest a vert in this Frame can be from this path.
    private let corner = SIMD2<Float>(0.5, 0.5)
    private let far = SIMD2<Float>(127.5, 127.5)

    private func guide(adhesion: Float, epsilon: Float = 1) -> Guide {
        let guide = Guide(frame: frame, settleEpsilon: epsilon)
        guide.initialize(source: .lines([Line(verts: [Vert(location: corner)])]), frame: frame, adhesion: adhesion, duration: 1, resolution: 128)
        return guide
    }

    private func residual(adhesion: Float) -> Float {
        let settled = guide(adhesion: adhesion).evaluate([Line(verts: [Vert(location: far)])], at: 1)
        let run = settled[0].verts[0].location - corner
        return (run.x * run.x + run.y * run.y).squareRoot()
    }

    @Test func theFullAdherenceReachFollowsFromTheFrameAndTheEpsilon() {
        // The diagonal of the Frame is 181.01933, and 181.01933 times the square root of 180.01933.
        #expect(abs(Guide(frame: frame, settleEpsilon: 1).fullAdherenceReach - 2428.7598) < 1e-2)
    }

    @Test func theFullAdherenceReachFollowsTheEpsilonSupplied() {
        #expect(abs(Guide(frame: frame, settleEpsilon: 4).fullAdherenceReach - 1204.2185) < 1e-2)
    }

    @Test func theFullAdherenceReachGrowsFasterThanTheFrame() {
        let small = Guide(frame: frame, settleEpsilon: 1)
        let large = Guide(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(256, 256)), settleEpsilon: 1)

        #expect(abs(large.fullAdherenceReach - 6879.1025) < 1e-1)
        // Twice the Frame, two and five sixths the reach.
        #expect(large.fullAdherenceReach / small.fullAdherenceReach > 2.8)
    }

    @Test func theLeastAdhesionDisplacesNoVert() {
        let settled = guide(adhesion: 0).evaluate([Line(verts: [Vert(location: far)])], at: 1)

        #expect(settled[0].verts[0].location == far)
    }

    @Test func aFullAdhesionSettlesTheWorstCaseVertWithinTheEpsilon() {
        let guide = guide(adhesion: 1)

        #expect(abs(residual(adhesion: 1) - 0.9768142) < 1e-3)
        #expect(residual(adhesion: 1) < guide.settleEpsilon)
    }

    @Test func aMiddlingAdhesionLeavesTheWorstCaseVertShortOfThePath() {
        #expect(abs(residual(adhesion: 0.5) - 3.8445728) < 1e-3)
        #expect(residual(adhesion: 0.5) > 1)
    }

    @Test func anAdhesionOutsideItsRangeIsHeldToIt() {
        #expect(guide(adhesion: 4).adhesion == 1)
        #expect(guide(adhesion: -4).adhesion == 0)
    }
}
