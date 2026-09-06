import Testing
@testable import Mobster

struct GuideAbsoluteTimeTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    private func field(at x: Float) -> Field {
        FieldFixture.field(paths: [[SIMD2<Float>(x, 0), SIMD2<Float>(x, 128)]], frame: frame, count: 128)
    }

    private func guide(at x: Float) -> Guide {
        let guide = Guide(frame: frame, adherence: Adherence(reach: .infinity), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(x, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(field: field(at: 64.5), time: 0)
        return guide
    }

    @Test func aTimeYieldsTheSameLocationWhateverTimesCameBefore() {
        let direct = guide(at: 24.5)
        _ = direct.play(speed: 10, time: 2)

        let visited = guide(at: 24.5)
        _ = visited.play(speed: 10, time: 1)
        _ = visited.play(speed: 10, time: 3)
        _ = visited.play(speed: 10, time: 0)
        _ = visited.play(speed: 10, time: 2)

        #expect(direct.tokens[PointIdentifier(1)]?.location == SIMD2<Float>(44.5, 64.5))
        #expect(visited.tokens[PointIdentifier(1)]?.location == direct.tokens[PointIdentifier(1)]?.location)
    }

    @Test func scrubbingBackReturnsThePictureThatTimeProduced() {
        let guide = guide(at: 24.5)
        _ = guide.play(speed: 10, time: 1)
        let early = guide.tokens[PointIdentifier(1)]?.location

        _ = guide.play(speed: 10, time: 3)
        _ = guide.play(speed: 10, time: 1)

        #expect(early == SIMD2<Float>(34.5, 64.5))
        #expect(guide.tokens[PointIdentifier(1)]?.location == early)
    }

    @Test func evaluationDoesNotWriteTheOrigin() {
        let guide = guide(at: 24.5)
        _ = guide.play(speed: 10, time: 1)
        _ = guide.play(speed: 10, time: 2)

        #expect(guide.tokens[PointIdentifier(1)]?.origin == 0)
    }

    @Test func tokenizationAndAFieldChangeWriteTheOrigin() {
        let guide = Guide(frame: frame, adherence: Adherence(reach: .infinity), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke], time: 3)
        #expect(guide.tokens[PointIdentifier(1)]?.origin == 3)

        guide.update(field: field(at: 64.5), time: 7)
        #expect(guide.tokens[PointIdentifier(1)]?.origin == 7)
    }

    @Test func theEndTimeSettlesEveryTokenFromAnyState() {
        let guide = Guide(frame: frame, adherence: Adherence(reach: .infinity), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(0.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(field: field(at: 127.5), time: 0)

        for step in 1 ... 999 {
            _ = guide.play(speed: 0.01, time: Double(step))
        }
        _ = guide.play(speed: 1, time: 1000)

        #expect(guide.tokens[PointIdentifier(1)]?.location == SIMD2<Float>(127.5, 64.5))
    }

    @Test func aSteppedRunAndADirectRunAgreeAcrossAFieldChange() {
        let stepped = Guide(frame: frame, adherence: Adherence(reach: 40), settleEpsilon: 1)
        let direct = Guide(frame: frame, adherence: Adherence(reach: 40), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])

        for guide in [stepped, direct] {
            guide.initialize(frame: frame, membership: [stroke])
            guide.update(field: field(at: 64.5), time: 0)
        }
        for step in 1 ... 4 {
            _ = stepped.play(speed: 3, time: Double(step) * 0.25)
        }
        _ = direct.play(speed: 3, time: 1)
        #expect(stepped.tokens[PointIdentifier(1)]?.location == direct.tokens[PointIdentifier(1)]?.location)

        for guide in [stepped, direct] {
            guide.update(field: field(at: 0.5), time: 2)
        }
        _ = stepped.play(speed: 3, time: 2.5)
        _ = stepped.play(speed: 3, time: 2.25)
        _ = stepped.play(speed: 3, time: 3)
        _ = direct.play(speed: 3, time: 3)

        #expect(stepped.tokens[PointIdentifier(1)]?.location == direct.tokens[PointIdentifier(1)]?.location)
    }
}
