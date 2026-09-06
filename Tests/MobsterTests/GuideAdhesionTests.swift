import Testing
@testable import Mobster

struct GuideAdhesionTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))
    /// A path of one location, so every texel holds it and the distance a vert reads does not follow from the lattice the epsilon derived.
    private let corner = SIMD2<Float>(0.5, 0.5)
    private let far = SIMD2<Float>(127.5, 127.5)

    private func guide(adhesion: Float, epsilon: Float = 1, in region: Frame? = nil) throws -> Guide {
        let operating = region ?? frame
        let guide = Guide(frame: operating)
        try guide.initialize(source: .lines([Line(verts: [Vert(location: corner)])]), frame: operating, adhesion: adhesion, duration: 1, settleEpsilon: epsilon, budget: .max)
        return guide
    }

    private func residual(adhesion: Float) throws -> Float {
        let settled = try guide(adhesion: adhesion).evaluate([Line(verts: [Vert(location: far)])], at: 1)
        let run = settled[0].verts[0].location - corner
        return (run.x * run.x + run.y * run.y).squareRoot()
    }

    @Test func theFullAdherenceReachFollowsFromTheFrameAndTheEpsilon() throws {
        // The diagonal of the Frame is 181.01933, and 181.01933 times the square root of 180.01933.
        #expect(try abs(guide(adhesion: 1).fullAdherenceReach - 2428.7598) < 1e-2)
    }

    @Test func theFullAdherenceReachFollowsTheEpsilonSupplied() throws {
        #expect(try abs(guide(adhesion: 1, epsilon: 4).fullAdherenceReach - 1204.2185) < 1e-2)
    }

    @Test func theFullAdherenceReachGrowsFasterThanTheFrame() throws {
        let small = try guide(adhesion: 1)
        let large = try guide(adhesion: 1, in: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(256, 256)))

        #expect(abs(large.fullAdherenceReach - 6879.1025) < 1e-1)
        // Twice the Frame, two and five sixths the reach.
        #expect(large.fullAdherenceReach / small.fullAdherenceReach > 2.8)
    }

    @Test func theLeastAdhesionDisplacesNoVert() throws {
        let settled = try guide(adhesion: 0).evaluate([Line(verts: [Vert(location: far)])], at: 1)

        #expect(settled[0].verts[0].location == far)
    }

    @Test func aFullAdhesionSettlesTheWorstCaseVertWithinTheEpsilon() throws {
        let guide = try guide(adhesion: 1)

        #expect(try abs(residual(adhesion: 1) - 0.9768142) < 1e-3)
        #expect(try residual(adhesion: 1) < guide.settleEpsilon)
    }

    @Test func aMiddlingAdhesionLeavesTheWorstCaseVertShortOfThePath() throws {
        #expect(try abs(residual(adhesion: 0.5) - 3.8445728) < 1e-3)
        #expect(try residual(adhesion: 0.5) > 1)
    }

    @Test func anAdhesionOutsideItsRangeIsHeldToIt() throws {
        #expect(try guide(adhesion: 4).adhesion == 1)
        #expect(try guide(adhesion: -4).adhesion == 0)
    }
}
