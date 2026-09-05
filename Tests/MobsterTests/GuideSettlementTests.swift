import Testing
@testable import Mobster

private final class SettleCount {
    var value = 0
}

struct GuideSettlementTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    private func field() -> Field {
        FieldBake(paths: [[SIMD2<Float>(64.5, 0), SIMD2<Float>(64.5, 128)]], frame: frame, resolution: 128).field()
    }

    private func guide() -> Guide {
        let guide = Guide(adherence: Adherence(reach: .infinity))
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
            Sample(identifier: PointIdentifier(2), location: SIMD2<Float>(54.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(field: field(), time: 0)
        return guide
    }

    @Test func settlementFiresOnceWhenTheLastPointArrives() {
        let guide = guide()
        let count = SettleCount()
        guide.addSettleListener { count.value += 1 }

        _ = guide.play(speed: 10, time: 1)
        #expect(count.value == 0)
        _ = guide.play(speed: 10, time: 2)
        #expect(count.value == 0)
        _ = guide.play(speed: 10, time: 3)
        #expect(count.value == 0)
        _ = guide.play(speed: 10, time: 4)
        #expect(count.value == 1)
        _ = guide.play(speed: 10, time: 5)
        #expect(count.value == 1)
    }

    @Test func settlementFiresAgainAfterAFieldChangeSendsThePointsOutAgain() {
        let guide = guide()
        let count = SettleCount()
        guide.addSettleListener { count.value += 1 }

        _ = guide.play(speed: 10, time: 1000)
        #expect(count.value == 1)

        let moved = FieldBake(paths: [[SIMD2<Float>(0.5, 0), SIMD2<Float>(0.5, 128)]], frame: frame, resolution: 128).field()
        guide.update(field: moved, time: 1000)
        _ = guide.play(speed: 10, time: 1001)
        #expect(count.value == 1)
        _ = guide.play(speed: 10, time: 2000)
        #expect(count.value == 2)
    }

    @Test func settlementDoesNotFireForAMembershipThatNeverMoved() {
        let guide = Guide(adherence: Adherence(reach: 0))
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(field: field(), time: 0)

        let count = SettleCount()
        guide.addSettleListener { count.value += 1 }
        _ = guide.play(speed: 10, time: 1000)

        #expect(count.value == 0)
    }
}
