import Testing
@testable import Mobster

struct GuideTests {
    @Test func initializeEstablishesTheFrame() {
        let guide = Guide(adherence: Adherence(reach: 10), settleEpsilon: 1)
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(1024, 768))
        guide.initialize(frame: frame)

        #expect(guide.frame?.origin == frame.origin)
        #expect(guide.frame?.size == frame.size)
    }

    @Test func initializeReplacesPriorFrame() {
        let guide = Guide(adherence: Adherence(reach: 10), settleEpsilon: 1)
        guide.initialize(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(1024, 768)))

        let replacement = Frame(origin: SIMD2<Float>(-50, -50), size: SIMD2<Float>(200, 200))
        guide.initialize(frame: replacement)

        #expect(guide.frame?.origin == replacement.origin)
        #expect(guide.frame?.size == replacement.size)
    }

    @Test func initializeDiscardsEveryToken() {
        let guide = Guide(adherence: Adherence(reach: 10), settleEpsilon: 1)
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(10, 10)),
            Sample(identifier: PointIdentifier(2), location: SIMD2<Float>(20, 20)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        #expect(guide.tokens.count == 2)

        let replacement = Stroke(identifier: StrokeIdentifier(2), samples: [
            Sample(identifier: PointIdentifier(3), location: SIMD2<Float>(30, 30)),
        ])
        guide.initialize(frame: frame, membership: [replacement])

        #expect(guide.tokens.count == 1)
        #expect(guide.membership == [PointIdentifier(3)])
    }

    @Test func tokenizeBeforeInitializeCreatesNothing() {
        let guide = Guide(adherence: Adherence(reach: 40), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.tokenize(membership: [stroke], time: 0)

        #expect(guide.tokens.isEmpty)
        #expect(guide.membership.isEmpty)
    }

    @Test func aFieldBeforeInitializeIsNotTaken() {
        let guide = Guide(adherence: Adherence(reach: 40), settleEpsilon: 1)
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))
        guide.update(field: FieldBake(paths: [[SIMD2<Float>(64.5, 0), SIMD2<Float>(64.5, 128)]], frame: frame, resolution: 128).field(), time: 0)

        #expect(guide.field == nil)
    }

    @Test func playBeforeInitializeAdvancesNothingAndSettlesNothing() {
        let guide = Guide(adherence: Adherence(reach: 40), settleEpsilon: 1)
        let count = SettleCount()
        guide.addSettleListener { count.value += 1 }

        #expect(guide.play(speed: 10, time: 1).displacements.isEmpty)
        #expect(count.value == 0)
    }
}
