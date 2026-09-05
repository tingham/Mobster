import Testing
@testable import Mobster

struct GuidePlayTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    private func field() -> Field {
        FieldBake(paths: [[SIMD2<Float>(64.5, 0), SIMD2<Float>(64.5, 128)]], frame: frame, resolution: 128).field()
    }

    private func guide() -> Guide {
        let guide = Guide(frame: frame, adherence: Adherence(reach: .infinity), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
            Sample(identifier: PointIdentifier(2), location: SIMD2<Float>(54.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(field: field(), time: 0)
        return guide
    }

    @Test func everyTokenIsEvaluatedAtTheSuppliedTime() {
        let guide = guide()
        let advance = guide.play(speed: 10, time: 1)

        #expect(guide.tokens[PointIdentifier(1)]?.location == SIMD2<Float>(34.5, 64.5))
        #expect(guide.tokens[PointIdentifier(2)]?.location == SIMD2<Float>(64.5, 64.5))
        #expect(advance.displacements.count == 2)
    }

    @Test func playingToTheEndTimeSettlesEveryTokenInOneCall() {
        let guide = guide()
        _ = guide.play(speed: 10, time: 1000)

        #expect(guide.tokens[PointIdentifier(1)]?.location == SIMD2<Float>(64.5, 64.5))
        #expect(guide.tokens[PointIdentifier(2)]?.location == SIMD2<Float>(64.5, 64.5))
    }

    @Test func settledTokenDirtiesNothing() {
        let guide = guide()
        _ = guide.play(speed: 10, time: 1000)

        #expect(guide.play(speed: 10, time: 1001).displacements.isEmpty)
    }

    @Test func pointAtAPathLocationDoesNotMove() {
        let guide = Guide(frame: frame, adherence: Adherence(reach: .infinity), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(64.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(field: field(), time: 0)

        let advance = guide.play(speed: 10, time: 1000)
        #expect(guide.tokens[PointIdentifier(1)]?.location == SIMD2<Float>(64.5, 64.5))
        #expect(advance.displacements.isEmpty)
    }

    @Test func advanceCarriesARectPerPointAndTheirUnion() {
        let guide = guide()
        let advance = guide.play(speed: 10, time: 1)

        #expect(advance.rects == [
            GuideRect(origin: SIMD2<Float>(24.5, 64.5), size: SIMD2<Float>(10, 0)),
            GuideRect(origin: SIMD2<Float>(54.5, 64.5), size: SIMD2<Float>(10, 0)),
        ])
        #expect(advance.union == GuideRect(origin: SIMD2<Float>(24.5, 64.5), size: SIMD2<Float>(40, 0)))
    }

    @Test func advanceIdentifiesThePointAndItsStroke() {
        let guide = guide()
        let advance = guide.play(speed: 10, time: 1)

        #expect(advance.displacements.first?.point == PointIdentifier(1))
        #expect(advance.displacements.first?.stroke == StrokeIdentifier(1))
        #expect(advance.displacements.first?.location == SIMD2<Float>(34.5, 64.5))
    }

    @Test func aTimeBeforeTheOriginPutsThePointBackWhereItsSegmentBegan() {
        let guide = guide()
        _ = guide.play(speed: 10, time: 1)
        let advance = guide.play(speed: 10, time: -5)

        #expect(guide.tokens[PointIdentifier(1)]?.location == SIMD2<Float>(24.5, 64.5))
        #expect(guide.tokens[PointIdentifier(2)]?.location == SIMD2<Float>(54.5, 64.5))
        #expect(advance.displacements.count == 2)
    }
}
