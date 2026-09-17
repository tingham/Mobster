import Metal
import Testing
@testable import Mobster

struct HeadExtractionTests {
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512))
    private let fit = 12
    /// Off to the side and level, which is the three quarter view the divisions of the mass read at. The subject's left stands toward the viewer here, the depth of this basis running against the breadth.
    private let quarter = SIMD3<Float>(0.96, 0, 2)

    private func seams(_ target: SIMD3<Float>) throws -> Set<SIMD2<UInt32>> {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let render = try MeshRenderCache.shared.render(device: device)
        let mesh = HeadPreset(sex: .male, target: target, roll: 0).mesh(in: square)
        let raster = try #require(try render.raster(of: mesh, in: square, resolution: MeshResolution(frame: square), perspective: MeshPerspective()))

        return Set(MeshBoundary(raster: raster).seams().map { $0.identities })
    }

    private func extracted(_ target: SIMD3<Float>) throws -> [[SIMD2<Float>]] {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let mesh = HeadPreset(sex: .male, target: target, roll: 0).mesh(in: square)

        return try MeshExtraction(mesh: mesh, frame: square, fit: fit, perspective: MeshPerspective()).paths(device: device)
    }

    /// The brow line, the centre line and a side plane are what the divisions of the mass leave behind. Nothing draws any of them: the brow divides a band of breadth, the sagittal plane divides the middle two bands from each other, and a side plane divides a cap from the band beside it. The cap on the far side of this view carries no boundary at all, being wholly behind the mass.
    @Test func theBrowLineTheCentreLineAndASidePlaneAreBoundaries() throws {
        let pairs = try seams(quarter)

        #expect(pairs.contains(SIMD2<UInt32>(5, 6)))
        #expect(pairs.contains(SIMD2<UInt32>(3, 5)))
        #expect(pairs.contains(SIMD2<UInt32>(5, 7)))
    }

    /// A cross section reads on the neck as it does on a limb, the division at its middle being the one mechanism.
    @Test func theNeckShowsASliceAtItsMiddle() throws {
        #expect(try seams(quarter).contains(SIMD2<UInt32>(11, 12)))
    }

    /// The same divisions stand toward the viewer across the sweep, so what moves is where the paths are rather than how many of them there are. The boundaries shorter than the count asked for keep what they traced, which is the fit taking a count rather than a tolerance, and they are where the chin block crosses the brow line and where the neck grazes the mass: a graze a fragment or two long lengthens and shortens with the view, so it is the paths at the full count that hold.
    @Test func turningTheHeadHoldsThePathCountAndMovesThem() throws {
        let opening = try extracted(quarter)
        let held = opening.filter { $0.count == fit }.count

        #expect(opening.allSatisfy { $0.count <= fit })
        #expect(held == opening.count - 2)

        for run: Float in [0.94, 0.95, 0.98, 0.99] {
            let turned = try extracted(SIMD3<Float>(run, 0, 2))

            #expect(turned.filter { $0.count == fit }.count == held)
            #expect(zip(turned, opening).contains { $0 != $1 })
        }
    }
}
