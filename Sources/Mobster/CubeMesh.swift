/// The box construction a figure or an object is built inside, as a mesh of twelve triangles. Each of its six faces is a plane a viewer reads as a distinct surface and so carries an identity of its own, emitted in the order minus x, plus x, minus y, plus y, minus z, plus z.
public struct CubeMesh: Hashable, Sendable {
    /// The corners of each face in a ring, keyed into the eight corners of the box by which side of each axis a corner stands on.
    private static let faces = [[0, 2, 6, 4], [1, 5, 7, 3], [0, 4, 5, 1], [2, 3, 7, 6], [0, 1, 3, 2], [4, 6, 7, 5]]

    /// A fraction of the Frame on each axis, locating the centre of the box.
    public let position: SIMD2<Float>
    /// The edge of the box as a fraction of the lesser axis of the Frame, so a box in a Frame that is not square is still a box.
    public let size: Float
    /// The location the box points at, measured from its centre: x across, y downward, z out of the near face.
    public let target: SIMD3<Float>

    public init(position: SIMD2<Float>, size: Float, target: SIMD3<Float>) {
        self.position = position
        self.size = size
        self.target = target
    }

    public func mesh(in frame: Frame) -> Mesh {
        let space = SpaceProjection(basis: SpaceBasis(target: target, roll: 0))
        let centre = frame.origin + position * frame.size
        let half = size * min(frame.size.x, frame.size.y) / 2
        let corners = (0 ..< 8).map { corner in
            Self.located(SIMD3<Float>(corner & 1 == 0 ? -half : half,
                                      corner & 2 == 0 ? -half : half,
                                      corner & 4 == 0 ? -half : half), space, centre)
        }

        return Mesh(triangles: Self.faces.indices.flatMap { face in
            let ring = Self.faces[face]
            let identity = MeshIdentity(UInt32(face + 1))

            return [MeshTriangle(first: corners[ring[0]], second: corners[ring[1]], third: corners[ring[2]], identity: identity),
                    MeshTriangle(first: corners[ring[0]], second: corners[ring[2]], third: corners[ring[3]], identity: identity)]
        })
    }

    /// The plane of the projection carries the scene location and the third axis of it carries the depth, which is what a mesh holds in its z.
    private static func located(_ local: SIMD3<Float>, _ space: SpaceProjection, _ centre: SIMD2<Float>) -> SIMD3<Float> {
        let plane = space.location(local) + centre

        return SIMD3<Float>(plane.x, plane.y, (space.depth * local).sum())
    }
}
