import Testing
@testable import Mobster

struct MeshFitTests {
    /// Two hundred samples of a straight run, which is more than any count Mobster asks for.
    private let traced = (0 ..< 200).map { SIMD2<Float>(Float($0), 0) }

    /// A count is asked for rather than a tolerance, so what comes back holds the same number of locations whatever the boundary looked like.
    @Test func aBoundaryIsFittedToTheCountAskedFor() {
        #expect(MeshFit(locations: traced).path().count == MeshFit.count)
    }

    @Test func theEndsOfTheBoundaryAreKept() {
        let fitted = MeshFit(locations: traced).path()

        #expect(fitted.first == traced.first)
        #expect(fitted.last == traced.last)
    }

    /// The fit only ever removes, so every location it hands back is one that was traced.
    @Test func everyLocationFittedIsOneThatWasTraced() {
        let traced = (0 ..< 60).map { SIMD2<Float>(Float($0), Float($0 * $0) / 60) }

        #expect(MeshFit(locations: traced).path().allSatisfy { fitted in traced.contains { $0 == fitted } })
    }

    @Test func aBoundaryShorterThanTheCountKeepsWhatItHas() {
        let short = [SIMD2<Float>(0, 0), SIMD2<Float>(1, 0), SIMD2<Float>(2, 0)]

        #expect(MeshFit(locations: short).path() == short)
    }
}
