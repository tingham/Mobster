import Testing
@testable import Mobster

struct MeshResolutionTests {
    /// Four hundred over six hundred of the count across, which rounds to three hundred and forty one.
    @Test func theResolutionFollowsTheWiderAxisOfTheFrame() {
        let resolution = MeshResolution(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 400)))

        #expect(resolution.columns == MeshResolution.count)
        #expect(resolution.rows == 341)
    }

    @Test func aTallFrameTakesItsCountDown() {
        let resolution = MeshResolution(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(400, 600)))

        #expect(resolution.rows == MeshResolution.count)
        #expect(resolution.columns == 341)
    }

    @Test func aSquareFrameIsSquareInFragments() {
        let resolution = MeshResolution(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512)))

        #expect(resolution.columns == MeshResolution.count)
        #expect(resolution.rows == MeshResolution.count)
        #expect(resolution.fragments == MeshResolution.count * MeshResolution.count)
    }

    @Test func aFrameWithNoExtentDemandsNoTarget() {
        let resolution = MeshResolution(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(0, 400)))

        #expect(resolution.columns == 0)
        #expect(resolution.rows == 0)
        #expect(resolution.fragments == 0)
    }
}
