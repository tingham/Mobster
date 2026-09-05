import Testing
@testable import Mobster

/// Two parallel paths straddling a texel centre, which is the medial line a Columns preset runs down the middle of every column.
struct FieldTiebreakTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))

    private func column(_ x: Float) -> [SIMD2<Float>] {
        [SIMD2<Float>(x, 0), SIMD2<Float>(x, 100)]
    }

    /// The centre of the Frame is at fifty, the equidistant texel centre at fifty and a half, so the nearer of the two paths to the centre is the one at thirty.
    @Test func anEquidistantLocationResolvesTowardTheCentreOfTheFrame() {
        let field = FieldBake(paths: [column(30), column(71)], frame: frame, resolution: 100).field()

        #expect(abs(field.distance(at: SIMD2<Float>(50.5, 50.5)) - 20.5) < 0.001)
        #expect(field.direction(at: SIMD2<Float>(50.5, 50.5)) == SIMD2<Float>(-1, 0))
        #expect(abs(field.locations[50 * 100 + 50].x - 30) < 0.001)
    }

    /// The mirror of the case above: the equidistant texel centre at forty nine and a half puts the path at seventy nearer the centre of the Frame.
    @Test func theMirrorOfThatCaseResolvesTowardTheCentreAsWell() {
        let field = FieldBake(paths: [column(29), column(70)], frame: frame, resolution: 100).field()

        #expect(abs(field.distance(at: SIMD2<Float>(49.5, 49.5)) - 20.5) < 0.001)
        #expect(field.direction(at: SIMD2<Float>(49.5, 49.5)) == SIMD2<Float>(1, 0))
        #expect(abs(field.locations[49 * 100 + 49].x - 70) < 0.001)
    }
}
