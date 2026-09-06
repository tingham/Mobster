import Testing
@testable import Mobster

/// Two paths straddling a texel centre. The pairs below are deliberately asymmetric about the Frame, because a pair symmetric about it is equidistant from the centre too and is decided by the stable rule rather than by this one.
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

    /// The Frame carries a position, so the centre the tie break measures against is the centre of the placed Frame at twenty by sixty five and not half its size. Texel fifty by fifty is centred on twenty and a half by sixty five and a half, equidistant from both paths, and the path at zero is the nearer of the two to that centre.
    @Test func theTieBreakHoldsAgainstAFrameAwayFromTheOrigin() {
        let placed = Frame(origin: SIMD2<Float>(-30, 15), size: SIMD2<Float>(100, 100))
        let paths = [[SIMD2<Float>(0, 15), SIMD2<Float>(0, 115)], [SIMD2<Float>(41, 15), SIMD2<Float>(41, 115)]]
        let field = FieldBake(paths: paths, frame: placed, resolution: 100).field()

        #expect(abs(field.distance(at: SIMD2<Float>(20.5, 65.5)) - 20.5) < 0.001)
        #expect(field.direction(at: SIMD2<Float>(20.5, 65.5)) == SIMD2<Float>(-1, 0))
        #expect(abs(field.locations[50 * 100 + 50].x - 0) < 0.001)
    }

    /// Two single point paths equidistant from the centre of the Frame as well as from every texel on the medial line between them, where the rule is the lesser x. Sweep order would answer with the greater one.
    @Test func aPairEquidistantFromTheCentreResolvesToTheLesserCoordinate() {
        let forward = FieldBake(paths: [[SIMD2<Float>(30, 70)], [SIMD2<Float>(70, 30)]], frame: frame, resolution: 100).field()
        let reversed = FieldBake(paths: [[SIMD2<Float>(70, 30)], [SIMD2<Float>(30, 70)]], frame: frame, resolution: 100).field()

        for step in [30, 40, 50, 60, 70] {
            #expect(forward.locations[step * 100 + step] == SIMD2<Float>(30, 70))
            #expect(reversed.locations[step * 100 + step] == SIMD2<Float>(30, 70))
        }
    }

    /// The lesser of the two is up and to the left of the corner texel, at forty five degrees off the run between them.
    @Test func thatPairAnswersTheSameWithThePathsSuppliedInEitherOrder() {
        let forward = FieldBake(paths: [[SIMD2<Float>(30, 70)], [SIMD2<Float>(70, 30)]], frame: frame, resolution: 100).field()
        let reversed = FieldBake(paths: [[SIMD2<Float>(70, 30)], [SIMD2<Float>(30, 70)]], frame: frame, resolution: 100).field()
        let direction = forward.direction(at: SIMD2<Float>(0.5, 0.5))

        #expect(forward.locations == reversed.locations)
        #expect(abs(direction.x - 0.39071991) < 0.0001)
        #expect(abs(direction.y - 0.92050962) < 0.0001)
    }
}
