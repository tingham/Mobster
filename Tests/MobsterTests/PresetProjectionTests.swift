import Testing
@testable import Mobster

struct PresetProjectionTests {
    private let frame = Frame(origin: SIMD2<Float>(10, 20), size: SIMD2<Float>(200, 100))

    @Test func aspectStretchesTheDesignOntoTheFrame() {
        let projection = PresetProjection(mode: .aspect, frame: frame, designSize: SIMD2<Float>(1, 1))

        #expect(projection.location(SIMD2<Float>(0, 0)) == SIMD2<Float>(10, 20))
        #expect(projection.location(SIMD2<Float>(1, 1)) == SIMD2<Float>(210, 120))
        #expect(projection.location(SIMD2<Float>(0.5, 0.5)) == SIMD2<Float>(110, 70))
    }

    @Test func boundsScalesUniformlyAndCentres() {
        let projection = PresetProjection(mode: .bounds, frame: frame, designSize: SIMD2<Float>(1, 1))
        let low = projection.location(SIMD2<Float>(0, 0))
        let high = projection.location(SIMD2<Float>(1, 1))

        #expect(abs((high.x - low.x) - (high.y - low.y)) < 0.001)
        #expect(low.x <= frame.origin.x)
        #expect(high.x >= frame.origin.x + frame.size.x)
        #expect(low.y <= frame.origin.y)
        #expect(high.y >= frame.origin.y + frame.size.y)
    }

    @Test func boundsIsTheSmallestEncompassingScale() {
        let projection = PresetProjection(mode: .bounds, frame: frame, designSize: SIMD2<Float>(1, 1))
        let low = projection.location(SIMD2<Float>(0, 0))
        let high = projection.location(SIMD2<Float>(1, 1))

        #expect(abs((high.x - low.x) - 200) < 0.001)
    }
}
