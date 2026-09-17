/// A wedge, which the pelvis is. Its lower corners are where the legs are hung. A wedge reads by its edges rather than by a cross section, so nothing divides it.
struct FigureWedge {
    let center: Float
    let top: Float
    let bottom: Float
    let topWidth: Float
    let bottomWidth: Float
    let topDepth: Float
    let bottomDepth: Float

    var leftCorner: SIMD2<Float> {
        SIMD2<Float>(center - bottomWidth / 2, bottom)
    }

    var rightCorner: SIMD2<Float> {
        SIMD2<Float>(center + bottomWidth / 2, bottom)
    }

    /// The four sides and the two caps, which close the form so that the depth test reads it as solid rather than through it.
    func bands(identity: MeshIdentity) -> [MeshBand] {
        let upper = ring(level: top, width: topWidth, depth: topDepth)
        let lower = ring(level: bottom, width: bottomWidth, depth: bottomDepth)

        return [MeshBand(first: upper, second: lower, identity: identity),
                MeshBand(first: upper, second: cap(level: top), identity: identity),
                MeshBand(first: lower, second: cap(level: bottom), identity: identity)]
    }

    private func ring(level: Float, width: Float, depth: Float) -> [SIMD3<Float>] {
        [SIMD3<Float>(center - width / 2, level, depth / 2),
         SIMD3<Float>(center + width / 2, level, depth / 2),
         SIMD3<Float>(center + width / 2, level, -depth / 2),
         SIMD3<Float>(center - width / 2, level, -depth / 2)]
    }

    private func cap(level: Float) -> [SIMD3<Float>] {
        [SIMD3<Float>](repeating: SIMD3<Float>(center, level, 0), count: 4)
    }
}
