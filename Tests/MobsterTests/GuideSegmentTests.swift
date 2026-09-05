import Testing
@testable import Mobster

struct GuideSegmentTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    private func field(at x: Float) -> Field {
        FieldBake(paths: [[SIMD2<Float>(x, 0), SIMD2<Float>(x, 128)]], frame: frame, resolution: 128).field()
    }

    @Test func fieldChangeReanchorsTheSegmentAtTheCurrentLocation() {
        let guide = Guide(adherence: Adherence(reach: 40))
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(field: field(at: 64.5), time: 0)
        #expect(guide.tokens[PointIdentifier(1)]?.target == SIMD2<Float>(44.5, 64.5))

        _ = guide.play(speed: 10, time: 1)
        #expect(guide.tokens[PointIdentifier(1)]?.location == SIMD2<Float>(34.5, 64.5))

        guide.update(field: field(at: 0.5), time: 1)
        let token = guide.tokens[PointIdentifier(1)]

        #expect(token?.location == SIMD2<Float>(34.5, 64.5))
        #expect(token?.origin == 1)
        // Resolved from where the point actually is; the location it set out from would have yielded 6.853.
        #expect(abs((token?.target.x ?? 0) - 14.76126) < 1e-3)
    }

    @Test func theNextSegmentRunsFromTheReanchoredLocation() {
        let guide = Guide(adherence: Adherence(reach: 40))
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(field: field(at: 64.5), time: 0)
        _ = guide.play(speed: 10, time: 1)
        guide.update(field: field(at: 0.5), time: 5)
        _ = guide.play(speed: 5, time: 6)

        // A segment still dated from the play would have run five times as far and arrived.
        #expect(guide.tokens[PointIdentifier(1)]?.location == SIMD2<Float>(29.5, 64.5))
    }
}
