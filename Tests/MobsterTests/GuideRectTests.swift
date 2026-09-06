import Testing
@testable import Mobster

struct GuideRectTests {
    @Test func coveringSpansTwoLocationsInEitherOrder() {
        let forward = GuideRect(covering: SIMD2<Float>(10, 20), SIMD2<Float>(30, 5))
        let backward = GuideRect(covering: SIMD2<Float>(30, 5), SIMD2<Float>(10, 20))

        #expect(forward.origin == SIMD2<Float>(10, 5))
        #expect(forward.size == SIMD2<Float>(20, 15))
        #expect(forward == backward)
    }

    @Test func unionContainsBoth() {
        let first = GuideRect(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(10, 10))
        let second = GuideRect(origin: SIMD2<Float>(20, 5), size: SIMD2<Float>(5, 20))

        let combined = first.union(second)
        #expect(combined.origin == SIMD2<Float>(0, 0))
        #expect(combined.size == SIMD2<Float>(25, 25))
    }

    @Test func unionOfNoRectsIsNil() {
        #expect(GuideRect.union(of: []) == nil)
    }

    @Test func unionOfOneRectIsThatRect() {
        let only = GuideRect(origin: SIMD2<Float>(3, 4), size: SIMD2<Float>(5, 6))

        #expect(GuideRect.union(of: [only]) == only)
    }
}
