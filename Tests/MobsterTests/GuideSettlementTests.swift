import Testing
@testable import Mobster

struct GuideSettlementTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    private func field() -> Field {
        FieldBake(paths: [[SIMD2<Float>(64.5, 0), SIMD2<Float>(64.5, 128)]], frame: frame, resolution: 128).field()
    }

    private func guide() -> Guide {
        let guide = Guide(adherence: Adherence(reach: .infinity), settleEpsilon: 1)
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

        // The change lands well after the play, so a segment left dated from the play would carry the points home on the next call and settle them early.
        let moved = FieldBake(paths: [[SIMD2<Float>(0.5, 0), SIMD2<Float>(0.5, 128)]], frame: frame, resolution: 128).field()
        guide.update(field: moved, time: 1500)
        _ = guide.play(speed: 10, time: 1501)
        #expect(guide.tokens[PointIdentifier(1)]?.location == SIMD2<Float>(54.5, 64.5))
        #expect(count.value == 1)
        _ = guide.play(speed: 10, time: 2000)
        #expect(count.value == 2)
    }

    @Test func settlementFiresForAMembershipAlreadyAtItsTargets() {
        let guide = Guide(adherence: Adherence(reach: 0), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(field: field(), time: 0)

        let count = SettleCount()
        guide.addSettleListener { count.value += 1 }
        #expect(count.value == 1)

        _ = guide.play(speed: 10, time: 1000)
        #expect(count.value == 1)
    }

    @Test func settlementFiresForAnEmptyMembership() {
        let guide = Guide(adherence: Adherence(reach: 40), settleEpsilon: 1)
        guide.initialize(frame: frame)

        let count = SettleCount()
        guide.addSettleListener { count.value += 1 }
        #expect(count.value == 1)
    }

    @Test func settlementFiresForAMembershipWithNoFieldToChase() {
        let guide = Guide(adherence: Adherence(reach: 40), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])

        let count = SettleCount()
        guide.addSettleListener { count.value += 1 }
        #expect(count.value == 1)
    }

    @Test func aPointOneEpsilonOutSettlesOnThePlayThatCarriesIt() {
        let guide = Guide(adherence: Adherence(reach: .infinity), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(63.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(field: field(), time: 0)

        let count = SettleCount()
        guide.addSettleListener { count.value += 1 }
        #expect(count.value == 0)

        let advance = guide.play(speed: 10, time: 1)
        #expect(guide.tokens[PointIdentifier(1)]?.location == SIMD2<Float>(64.5, 64.5))
        #expect(advance.displacements.count == 1)
        #expect(count.value == 1)
    }

    @Test func aFieldChangeThatLeavesEveryPointSettledDoesNotFireAgain() {
        let guide = guide()
        let count = SettleCount()
        guide.addSettleListener { count.value += 1 }

        _ = guide.play(speed: 10, time: 1000)
        #expect(count.value == 1)

        guide.update(field: field(), time: 1500)
        _ = guide.play(speed: 10, time: 1501)
        #expect(count.value == 1)
    }

    @Test func aListenerAttachedBeforeTheMembershipHearsItsFirstSettlement() {
        let guide = Guide(adherence: Adherence(reach: 40), settleEpsilon: 1)
        let count = SettleCount()
        guide.addSettleListener { count.value += 1 }
        #expect(count.value == 0)

        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])

        #expect(count.value == 1)
    }
}
