import Metal

/// The paths of a mesh, extracted from a projection of it rather than plotted. The mesh is rendered opaque with depth into an identity target whose resolution follows from the Frame, and the boundaries where adjacent fragments differ are traced and fitted.
public struct MeshExtraction: Sendable {
    public let mesh: Mesh
    public let frame: Frame

    public init(mesh: Mesh, frame: Frame) {
        self.mesh = mesh
        self.frame = frame
    }

    /// One path a boundary, in the order the pairs of identities that meet along them fall. The consumer supplies the device; Mobster creates none. A device that will not run the pass refuses, because no path and no render read the same on a canvas.
    public func paths(device: any MTLDevice) throws(MeshRefusal) -> [[SIMD2<Float>]] {
        let resolution = MeshResolution(frame: frame)
        let render = try MeshRender(device: device)

        guard let raster = try render.raster(of: mesh, in: frame, resolution: resolution) else { return [] }

        return MeshBoundary(raster: raster).seams().map { seam in
            MeshFit(locations: seam.locations.map { scene($0, raster) }).path()
        }
    }

    /// A fragment coordinate is a location in the identity target, whose lattice covers the Frame.
    private func scene(_ fragment: SIMD2<Float>, _ raster: MeshIdentityRaster) -> SIMD2<Float> {
        frame.origin + SIMD2<Float>(fragment.x / Float(raster.columns), fragment.y / Float(raster.rows)) * frame.size
    }
}
