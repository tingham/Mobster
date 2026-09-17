/// Where a construction's own space lands in the Frame. A location is turned toward the view, laid into the design rectangle that runs from zero to one on each axis, and scaled onto the Frame by its lesser axis so the construction keeps its own proportions.
struct MeshPlacement {
    private let space: SpaceProjection
    /// The location in the construction's own coordinates that the view turns about.
    private let origin: SIMD3<Float>
    /// Where that location sits in the design rectangle.
    private let pivot: SIMD2<Float>
    /// Design units a construction unit is worth.
    private let unit: Float
    private let fit: Float
    private let translation: SIMD2<Float>

    init(target: SIMD3<Float>, roll: Float, origin: SIMD2<Float>, pivot: SIMD2<Float>, unit: Float, frame: Frame) {
        space = SpaceProjection(basis: SpaceBasis(target: target, roll: roll))
        self.origin = SIMD3<Float>(origin.x, origin.y, 0)
        self.pivot = pivot
        self.unit = unit
        fit = min(frame.size.x, frame.size.y)
        translation = frame.origin + (frame.size - SIMD2<Float>(fit, fit)) / 2
    }

    /// A location in the construction's own space. The depth takes the same scale as the plane, so a mesh holds one set of units.
    func location(_ construction: SIMD3<Float>) -> SIMD3<Float> {
        let local = construction - origin
        let plane = (space.location(local) * unit + pivot) * fit + translation

        return SIMD3<Float>(plane.x, plane.y, (space.depth * local).sum() * unit * fit)
    }

    /// A location standing in the space the construction is placed in rather than in its own, which the view does not turn. The neck of a head stands upright whatever the head does within it.
    func upright(_ construction: SIMD3<Float>) -> SIMD3<Float> {
        let local = construction - origin
        let plane = (SIMD2<Float>(local.x, local.y) * unit + pivot) * fit + translation

        return SIMD3<Float>(plane.x, plane.y, local.z * unit * fit)
    }

    /// A location already in the design rectangle, which nothing turns and nothing scales but the Frame.
    func flat(_ design: SIMD2<Float>) -> SIMD2<Float> {
        design * fit + translation
    }

    /// The design location a location in the Frame stands for, which is what a consumer dragging a handle hands back.
    func design(_ scene: SIMD2<Float>) -> SIMD2<Float> {
        fit > 0 ? (scene - translation) / fit : .zero
    }
}
