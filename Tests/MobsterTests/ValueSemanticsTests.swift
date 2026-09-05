import Testing
@testable import Mobster

struct ValueSemanticsTests {
    @Test func sampleCopyIsIndependent() {
        let original = Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(10, 20))
        var copy = original
        copy = Sample(identifier: PointIdentifier(2), location: SIMD2<Float>(30, 40))

        #expect(original.identifier == PointIdentifier(1))
        #expect(original.location == SIMD2<Float>(10, 20))
        #expect(copy.identifier == PointIdentifier(2))
    }

    @Test func strokeCopyIsIndependent() {
        let samples = [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(0, 0)),
            Sample(identifier: PointIdentifier(2), location: SIMD2<Float>(1, 1)),
        ]
        let original = Stroke(identifier: StrokeIdentifier(9), samples: samples)
        var copy = original
        copy = Stroke(identifier: StrokeIdentifier(9), samples: [])

        #expect(original.samples.count == 2)
        #expect(copy.samples.isEmpty)
    }

    @Test func strokeRetainsSampleOrder() {
        let samples = (0 ..< 4).map { index in
            Sample(identifier: PointIdentifier(UInt64(index)), location: SIMD2<Float>(Float(index), 0))
        }
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: samples)

        #expect(stroke.samples.map(\.identifier) == samples.map(\.identifier))
    }

    @Test func frameCopyIsIndependent() {
        let original = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 200))
        var copy = original
        copy = Frame(origin: SIMD2<Float>(5, 5), size: SIMD2<Float>(1, 1))

        #expect(original.size == SIMD2<Float>(100, 200))
        #expect(copy.size == SIMD2<Float>(1, 1))
    }

    @Test func equalValuesCompareEqual() {
        let left = Stroke(identifier: StrokeIdentifier(3), samples: [Sample(identifier: PointIdentifier(4), location: SIMD2<Float>(2, 2))])
        let right = Stroke(identifier: StrokeIdentifier(3), samples: [Sample(identifier: PointIdentifier(4), location: SIMD2<Float>(2, 2))])

        #expect(left == right)
    }
}
