import Metal

/// The paths of a mesh, extracted from a projection of it rather than plotted. The mesh is rendered opaque with depth into an identity target whose resolution follows from the Frame, and the boundaries where adjacent fragments differ are traced and fitted.
public struct MeshExtraction: Sendable {
    public let mesh: Mesh
    public let frame: Frame
    /// Locations each boundary is fitted to. A count rather than a tolerance is what makes a turning form deform its path instead of rebuilding it with a different one each view.
    public let fit: Int
    /// The field of view the mesh is projected through.
    public let perspective: MeshPerspective

    public init(mesh: Mesh, frame: Frame, fit: Int, perspective: MeshPerspective) {
        self.mesh = mesh
        self.frame = frame
        self.fit = fit
        self.perspective = perspective
    }

    /// One path a place two components meet, in the order the pairs of identities fall, so a pair meeting more than once vends a path for each. The consumer supplies the device; Mobster creates none. A device that will not run the pass refuses, because no path and no render read the same on a canvas.
    public func paths(device: any MTLDevice) throws(MeshRefusal) -> [[SIMD2<Float>]] {
        guard let raster = try raster(device: device) else { return [] }

        return MeshBoundary(raster: raster).seams().map { seam in
            MeshFit(locations: seam.locations.map { scene($0, raster) }, count: fit).path()
        }
    }

    /// The identity target the paths are traced from, vended on demand for display as the field's grayscale is. Nil where there is nothing to draw, which a Frame with no extent and a mesh of no triangles both are.
    public func raster(device: any MTLDevice) throws(MeshRefusal) -> MeshIdentityRaster? {
        let render = try MeshRenderCache.shared.render(device: device)

        return try render.raster(of: mesh, in: frame, resolution: MeshResolution(frame: frame), perspective: perspective)
    }

    /// A fragment coordinate is a location in the identity target, whose lattice covers the Frame.
    private func scene(_ fragment: SIMD2<Float>, _ raster: MeshIdentityRaster) -> SIMD2<Float> {
        frame.origin + SIMD2<Float>(fragment.x / Float(raster.columns), fragment.y / Float(raster.rows)) * frame.size
    }
}
