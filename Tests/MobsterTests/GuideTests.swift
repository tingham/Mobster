import Testing
@testable import Mobster

struct GuideTests {
    @Test func initializeEstablishesSceneSpace() {
        let guide = Guide()
        let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(1024, 768))
        guide.initialize(frame: frame)

        #expect(guide.frame == frame)
    }

    @Test func initializeReplacesPriorFrame() {
        let guide = Guide()
        guide.initialize(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(1024, 768)))

        let replacement = Frame(origin: SIMD2<Float>(-50, -50), size: SIMD2<Float>(200, 200))
        guide.initialize(frame: replacement)

        #expect(guide.frame == replacement)
    }
}
