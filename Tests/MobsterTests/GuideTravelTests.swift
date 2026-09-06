import Testing
@testable import Mobster

struct GuideTravelTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))
    private let duration: Double = 4
    /// The vert every test below stands forty units from the path, and the falloff at an adhesion of a tenth carries all but 1.0563 of that.
    private let displacement: Float = 38.943698
    private let anchor: Float = 24.5

    private func guide() throws -> Guide {
        let guide = Guide(frame: frame)
        let source = GuideSource.lines([Line(verts: [Vert(location: SIMD2<Float>(64.5, 0)), Vert(location: SIMD2<Float>(64.5, 128))])])
        try guide.initialize(source: source, frame: frame, adhesion: 0.1, duration: duration, settleEpsilon: 1, budget: .max)
        return guide
    }

    private func content(mass: Float? = nil, drag: Float? = nil) -> [Line] {
        [Line(verts: [Vert(location: SIMD2<Float>(anchor, 64.5), identifier: VertIdentifier(1), mass: mass, drag: drag)], identifier: LineIdentifier(1))]
    }

    private func x(_ lines: [Line]) -> Float {
        lines[0].verts[0].location.x
    }

    @Test func everyVertStandsOnItsTargetAtTheDurationWhateverItCarries() throws {
        let guide = try guide()

        for mass: Float in [0, 0.5, 1, 2, 8] {
            for drag: Float in [-1, -0.5, 0, 0.5, 1] {
                let settled = x(guide.evaluate(content(mass: mass, drag: drag), at: duration))

                #expect(abs(settled - (anchor + displacement)) < 1e-3)
            }
        }
    }

    @Test func aHeavierVertIsBehindALighterOneAtHalfTheDuration() throws {
        let guide = try guide()
        let standing = [Float(1), 2, 3].map { x(guide.evaluate(content(mass: $0), at: duration / 2)) }

        #expect(abs(standing[0] - 43.971849) < 1e-3)
        #expect(abs(standing[1] - 34.235924) < 1e-3)
        #expect(abs(standing[2] - 29.367962) < 1e-3)
        #expect(standing[0] > standing[1])
        #expect(standing[1] > standing[2])
    }

    @Test func aDragHoldsAVertBackAtTheStartOfItsTravel() throws {
        let guide = try guide()
        let plain = x(guide.evaluate(content(), at: duration / 4))

        #expect(x(guide.evaluate(content(drag: 0.5), at: duration / 4)) < plain)
        #expect(abs(x(guide.evaluate(content(drag: 0), at: duration / 4)) - 26.934231) < 1e-3)
    }

    @Test func aVertWithADragOfMinusOneLeadsAwayAndIsHomeAtTheDuration() throws {
        let guide = try guide()
        let early = x(guide.evaluate(content(drag: -1), at: duration / 4))

        #expect(abs(early - 19.632038) < 1e-3)
        #expect(early < anchor)
        #expect(abs(x(guide.evaluate(content(drag: -1), at: duration)) - (anchor + displacement)) < 1e-3)
    }

    @Test func anAbsentAttributeIsNotAZeroedOne() throws {
        let guide = try guide()

        #expect(abs(x(guide.evaluate(content(), at: duration / 2)) - 43.971849) < 1e-3)
        #expect(abs(x(guide.evaluate(content(mass: 0), at: duration / 2)) - 63.443698) < 1e-3)
        #expect(abs(x(guide.evaluate(content(drag: 0), at: duration / 2)) - 34.235924) < 1e-3)
    }

    @Test func anAttributedVertAnswersTheSameWayWhateverTimesPrecededIt() throws {
        let guide = try guide()
        let direct = x(guide.evaluate(content(mass: 2, drag: -1), at: 1))

        _ = guide.evaluate(content(mass: 2, drag: -1), at: duration)
        _ = guide.evaluate(content(mass: 8, drag: 1), at: 0)

        #expect(x(guide.evaluate(content(mass: 2, drag: -1), at: 1)) == direct)
    }
}
