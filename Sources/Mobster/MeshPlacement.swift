/// Where a construction's own space lands in the Frame. A location is turned toward the view, laid into the design rectangle that runs from zero to one on each axis, and scaled onto the Frame by its lesser axis so the construction keeps its own proportions.
struct MeshPlacement {
    /// The least the two plane axes may span the Frame by before a location on it is read back, a thousandth of the span they hold square on. Below it the read amplifies a point of a drag into a reach of design space.
    private static let edgeOn: Float = 0.001

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

    /// The design location on the construction's own plane that a location in the Frame stands for, which is location run backwards for a construction standing at no depth. Nil where the view has turned that plane edge on and the two axes of it no longer span the plane of the Frame, so one scene location stands for every design location along the axis that vanished.
    func plane(_ scene: SIMD2<Float>) -> SIMD2<Float>? {
        let determinant = space.across.x * space.down.y - space.across.y * space.down.x
        guard fit > 0, unit != 0, abs(determinant) > Self.edgeOn else { return nil }
        let carried = (design(scene) - pivot) / unit

        return SIMD2<Float>((space.down.y * carried.x - space.across.y * carried.y) / determinant + origin.x,
                            (space.across.x * carried.y - space.down.x * carried.x) / determinant + origin.y)
    }
}
