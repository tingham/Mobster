import Testing
@testable import Mobster

struct GuideDeterminismTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    private func field(at x: Float) -> Field {
        FieldBake(paths: [[SIMD2<Float>(x, 0), SIMD2<Float>(x, 128)]], frame: frame, resolution: 128).field()
    }

    private func population() -> [Stroke] {
        (0 ..< 4).map { stroke in
            Stroke(identifier: StrokeIdentifier(UInt64(stroke)), samples: (0 ..< 8).map { point in
                let index = stroke * 8 + point
                return Sample(
                    identifier: PointIdentifier(UInt64(index)),
                    location: SIMD2<Float>(3.5 + Float(index) * 3, 7.5 + Float(point) * 11)
                )
            })
        }
    }

    private func run() -> [SIMD2<Float>] {
        let guide = Guide(adherence: Adherence(reach: 37), settleEpsilon: 1)
        guide.initialize(frame: frame, membership: population())
        guide.update(field: field(at: 64.5), time: 0)
        _ = guide.play(speed: 9, time: 0.5)
        _ = guide.play(speed: 9, time: 1.25)
        // Distinct from the plays either side of it, so a segment left dated from the last play would run a different distance here.
        guide.update(field: field(at: 12.5), time: 1.5)
        _ = guide.play(speed: 3, time: 2)
        _ = guide.play(speed: 3, time: 4)
        return guide.membership.compactMap { guide.tokens[$0]?.location }
    }

    @Test func theSameSequenceOfPlaysAndFieldChangesYieldsIdenticalLocations() {
        let first = run()
        let second = run()

        #expect(first.count == 32)
        #expect(first == second)
    }

    @Test func steppingASegmentMatchesArrivingAtItInOneCall() {
        let stepped = Guide(adherence: Adherence(reach: 37), settleEpsilon: 1)
        stepped.initialize(frame: frame, membership: population())
        stepped.update(field: field(at: 64.5), time: 0)
        for step in 1 ... 8 {
            _ = stepped.play(speed: 9, time: Double(step) * 0.5)
        }

        let single = Guide(adherence: Adherence(reach: 37), settleEpsilon: 1)
        single.initialize(frame: frame, membership: population())
        single.update(field: field(at: 64.5), time: 0)
        _ = single.play(speed: 9, time: 4)

        let steppedLocations = stepped.membership.compactMap { stepped.tokens[$0]?.location }
        let singleLocations = single.membership.compactMap { single.tokens[$0]?.location }
        #expect(steppedLocations.count == 32)
        for (left, right) in zip(steppedLocations, singleLocations) {
            #expect(abs(left.x - right.x) < 1e-3)
            #expect(abs(left.y - right.y) < 1e-3)
        }
    }
}
