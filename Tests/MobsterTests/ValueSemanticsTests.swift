import Testing
@testable import Mobster

struct ValueSemanticsTests {
    @Test func sampleIsAStruct() {
        let sample = Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(10, 20))

        #expect(Mirror(reflecting: sample).displayStyle == .struct)
    }

    @Test func strokeIsAStruct() {
        let stroke = Stroke(identifier: StrokeIdentifier(9), samples: [])

        #expect(Mirror(reflecting: stroke).displayStyle == .struct)
    }

    @Test func frameIsAStruct() {
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 200))

        #expect(Mirror(reflecting: frame).displayStyle == .struct)
    }

    @Test func strokeRetainsSampleOrder() {
        let samples = (0 ..< 4).map { index in
            Sample(identifier: PointIdentifier(UInt64(index)), location: SIMD2<Float>(Float(index), 0))
        }
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: samples)

        #expect(stroke.samples.map(\.identifier) == samples.map(\.identifier))
    }
}
