import Testing
@testable import Mobster

struct GuideEvaluateTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))
    private let duration: Double = 4

    /// A vertical path down the middle of the Frame, forty units from the vert every test below evaluates.
    private var source: GuideSource {
        .lines([Line(verts: [Vert(location: SIMD2<Float>(64.5, 0)), Vert(location: SIMD2<Float>(64.5, 128))])])
    }

    private func guide(adhesion: Float = 0.1) -> Guide {
        let guide = Guide(frame: frame, settleEpsilon: 1)
        guide.initialize(source: source, frame: frame, adhesion: adhesion, duration: duration, resolution: 128)
        return guide
    }

    private func content() -> [Line] {
        [Line(verts: [Vert(location: SIMD2<Float>(24.5, 64.5), identifier: VertIdentifier(1))], identifier: LineIdentifier(1))]
    }

    private func x(_ lines: [Line]) -> Float {
        lines[0].verts[0].location.x
    }

    @Test func atTheDurationAVertStandsAtItsTarget() {
        // Forty units out against a reach of 242.876, so the falloff carries all but 1.0563 of it.
        #expect(abs(x(guide().evaluate(content(), at: duration)) - 63.443699) < 1e-3)
    }

    @Test func halfTheDurationCarriesAVertHalfTheWay() {
        let guide = guide()
        let half = x(guide.evaluate(content(), at: duration / 2)) - 24.5
        let whole = x(guide.evaluate(content(), at: duration)) - 24.5

        #expect(abs(half * 2 - whole) < 1e-3)
    }

    @Test func aTimeBeforeTheRunLeavesTheVertWhereItStands() {
        let guide = guide()

        #expect(x(guide.evaluate(content(), at: 0)) == 24.5)
        #expect(x(guide.evaluate(content(), at: -10)) == 24.5)
    }

    @Test func everyVertHasArrivedByTheDuration() {
        let guide = guide()

        #expect(x(guide.evaluate(content(), at: duration * 10)) == x(guide.evaluate(content(), at: duration)))
    }

    @Test func aTimeYieldsTheSameResultWhateverTimesPrecededIt() {
        let guide = guide()
        let direct = x(guide.evaluate(content(), at: 2))

        _ = guide.evaluate(content(), at: duration)
        _ = guide.evaluate(content(), at: 0)
        _ = guide.evaluate(content(), at: duration * 3)

        #expect(x(guide.evaluate(content(), at: 2)) == direct)
    }

    @Test func contentHeldUndisplacedAnswersTheSameWayEveryTime() {
        let guide = guide()
        let landings = (0 ..< 10).map { _ in x(guide.evaluate(content(), at: duration)) }

        #expect(Set(landings.map(\.bitPattern)).count == 1)
    }

    @Test func aVertFarFromEveryPathSettlesShortAndStaysShort() {
        let guide = guide()
        let settled = x(guide.evaluate(content(), at: duration))

        #expect(64.5 - settled > guide.settleEpsilon)
        for _ in 0 ..< 10 {
            #expect(x(guide.evaluate(content(), at: duration)) == settled)
        }
    }

    @Test func aResultFedBackInIsAFurtherDisplacement() {
        let guide = guide()
        let once = guide.evaluate(content(), at: duration)
        let twice = guide.evaluate(once, at: duration)

        #expect(x(twice) > x(once))
        #expect(64.5 - x(twice) < 64.5 - x(once))
    }

    @Test func theAttributesAreCarriedThroughUntouched() {
        let guide = guide()
        let supplied = [Line(verts: [
            Vert(location: SIMD2<Float>(24.5, 64.5), identifier: VertIdentifier(1), mass: 0, drag: -1, coupling: 0.5),
            Vert(location: SIMD2<Float>(34.5, 64.5)),
        ], identifier: LineIdentifier(1))]

        let returned = guide.evaluate(supplied, at: duration)

        #expect(returned[0].verts[0].mass == 0)
        #expect(returned[0].verts[0].drag == -1)
        #expect(returned[0].verts[0].coupling == 0.5)
        #expect(returned[0].verts[1].mass == nil)
        #expect(returned[0].verts[1].drag == nil)
        #expect(returned[0].verts[1].coupling == nil)
    }

    @Test func theIdentifiersAndTheVertOrderSurviveTheEvaluation() {
        let guide = guide()
        let supplied = [Line(verts: [
            Vert(location: SIMD2<Float>(24.5, 64.5), identifier: VertIdentifier(1)),
            Vert(location: SIMD2<Float>(24.5, 32.5), identifier: VertIdentifier(2)),
        ], identifier: LineIdentifier(7))]

        let returned = guide.evaluate(supplied, at: duration)

        #expect(returned.count == 1)
        #expect(returned[0].identifier == LineIdentifier(7))
        #expect(returned[0].verts.map(\.identifier) == [VertIdentifier(1), VertIdentifier(2)])
    }

    @Test func aVertNeedingNoIdentifierIsStillEvaluated() {
        let guide = guide()
        let supplied = [Line(verts: [Vert(location: SIMD2<Float>(24.5, 64.5))])]

        #expect(x(guide.evaluate(supplied, at: duration)) > 24.5)
    }
}
