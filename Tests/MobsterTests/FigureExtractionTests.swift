import Metal
import Testing
@testable import Mobster

struct FigureExtractionTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(800, 800))
    private let fit = 12
    /// The left arm's four identities, in the order a limb emits them: the upper segment's two halves then the forearm's two.
    private static let leftArm: UInt32 = 6

    private func figure(target: SIMD3<Float>) -> FigurePreset {
        FigurePreset(sex: .male,
                     heads: 8,
                     target: target,
                     leftHand: SIMD2<Float>(0.24, 0.62),
                     rightHand: SIMD2<Float>(0.76, 0.62),
                     leftFoot: SIMD2<Float>(0.42, 1),
                     rightFoot: SIMD2<Float>(0.58, 1),
                     leftElbowPole: SIMD2<Float>(-1, 0),
                     rightElbowPole: SIMD2<Float>(1, 0),
                     leftKneePole: SIMD2<Float>(-1, 0),
                     rightKneePole: SIMD2<Float>(1, 0),
                     headLines: false)
    }

    private func seams(_ target: SIMD3<Float>) throws -> [MeshSeam] {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let render = try MeshRenderCache.shared.render(device: device)
        let mesh = figure(target: target).mesh(in: frame)
        let raster = try #require(try render.raster(of: mesh, in: frame, resolution: MeshResolution(frame: frame), perspective: MeshPerspective()))

        return MeshBoundary(raster: raster).seams()
    }

    private func extracted(_ target: SIMD3<Float>) throws -> [[SIMD2<Float>]] {
        let device = try #require(MTLCreateSystemDefaultDevice())

        return try MeshExtraction(mesh: figure(target: target).mesh(in: frame), frame: frame, fit: fit, perspective: MeshPerspective()).paths(device: device)
    }

    /// The division at a segment's middle is the slice showing its roundness, and where two segments meet the halves either side of the joint are the seam at the elbow. Both come from the one mechanism and nothing draws either.
    @Test func aLimbShowsASeamAtItsJointAndASliceAtItsMiddle() throws {
        let pairs = Set(try seams(SIMD3<Float>(0, 0, 1)).map { $0.identities })

        #expect(pairs.contains(SIMD2<UInt32>(Self.leftArm, Self.leftArm + 1)))
        #expect(pairs.contains(SIMD2<UInt32>(Self.leftArm + 1, Self.leftArm + 2)))
        #expect(pairs.contains(SIMD2<UInt32>(Self.leftArm + 2, Self.leftArm + 3)))
    }

    /// A cross section runs across the form rather than along it, so the slice at a segment's middle is the shorter run of the two boundaries the segment carries.
    @Test func aMidSliceRunsAcrossTheFormRatherThanAlongIt() throws {
        let gathered = try seams(SIMD3<Float>(0, 0, 1))
        let slice = try #require(gathered.first { $0.identities == SIMD2<UInt32>(Self.leftArm, Self.leftArm + 1) })
        let silhouette = try #require(gathered.first { $0.identities == SIMD2<UInt32>(Self.leftArm, MeshIdentityRaster.background) })

        #expect(slice.locations.count < silhouette.locations.count)
    }

    /// The same forms stand toward the viewer across the sweep, so what moves is where the paths are and not how many there are or how long each one is.
    @Test func turningTheFigureHoldsThePathCountAndMovesThem() throws {
        let opening = try extracted(SIMD3<Float>(0, 0, 1))

        #expect(opening.allSatisfy { $0.count == fit })

        for run: Float in [-0.2, -0.1, 0.1, 0.2] {
            let turned = try extracted(SIMD3<Float>(run, 0, 1))

            #expect(turned.count == opening.count)
            #expect(turned.map(\.count) == opening.map(\.count))
            #expect(zip(turned, opening).contains { $0 != $1 })
        }
    }
}
