import Testing
@testable import Mobster

struct MeshResolutionTests {
    /// A fragment to the scene unit, so a Frame six hundred by four hundred is read at six hundred by four hundred.
    @Test func theLatticeIsAFragmentToTheSceneUnit() {
        let resolution = MeshResolution(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 400)))

        #expect(resolution.columns == 600)
        #expect(resolution.rows == 400)
        #expect(resolution.fragments == 240_000)
    }

    /// The Frame's own position does not enter it, only its extent.
    @Test func thePositionOfTheFrameDoesNotEnterTheLattice() {
        let placed = MeshResolution(frame: Frame(origin: SIMD2<Float>(-300, 175), size: SIMD2<Float>(512, 512)))

        #expect(placed.columns == 512)
        #expect(placed.rows == 512)
    }

    /// A scene unit is not whole, so the lattice rounds to the nearest fragment and never falls below one.
    @Test func aFrameSmallerThanAFragmentStillDemandsOne() {
        let slight = MeshResolution(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(0.4, 1.6)))

        #expect(slight.columns == 1)
        #expect(slight.rows == 2)
    }

    /// Twenty thousand outruns the platform ceiling, so both axes scale by the same 16384 over 20000 and the lattice keeps the shape of the Frame.
    @Test func aFrameOutrunningTheCeilingScalesBothAxesAlike() {
        let vast = MeshResolution(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(20_000, 10_000)))

        #expect(vast.columns == MeshResolution.ceiling)
        #expect(vast.rows == MeshResolution.ceiling / 2)
    }

    @Test func aFrameWithNoExtentDemandsNoTarget() {
        let resolution = MeshResolution(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(0, 400)))

        #expect(resolution.columns == 0)
        #expect(resolution.rows == 0)
        #expect(resolution.fragments == 0)
    }
}
