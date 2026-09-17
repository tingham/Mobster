/// A tapered cuboid, which a hand and a foot both are. It reads by its edges rather than by a cross section, so nothing divides it.
struct FigureBlock {
    let start: SIMD3<Float>
    let end: SIMD3<Float>
    let startWidth: Float
    let endWidth: Float

    /// The four sides and the two caps, which close the form so that the depth test reads it as solid rather than through it.
    func bands(identity: MeshIdentity) -> [MeshBand] {
        let run = end - start
        let length = (run * run).sum().squareRoot()
        // A block whose ends coincide has no axis to lay a ring across, so it takes the depth rather than dividing by zero.
        let forward = length > 0 ? run / length : SIMD3<Float>(0, 0, 1)
        let across = Self.across(forward)
        let up = Self.cross(forward, across)
        let root = ring(at: start, width: startWidth, across: across, up: up)
        let tip = ring(at: end, width: endWidth, across: across, up: up)

        return [MeshBand(first: root, second: tip, identity: identity),
                MeshBand(first: root, second: [SIMD3<Float>](repeating: start, count: root.count), identity: identity),
                MeshBand(first: tip, second: [SIMD3<Float>](repeating: end, count: tip.count), identity: identity)]
    }

    /// A block is square in section, so its width serves on both axes across the run and needs no new number.
    private func ring(at centre: SIMD3<Float>, width: Float, across: SIMD3<Float>, up: SIMD3<Float>) -> [SIMD3<Float>] {
        let half = width / 2

        return [centre - across * half - up * half,
                centre + across * half - up * half,
                centre + across * half + up * half,
                centre - across * half + up * half]
    }

    /// One axis across the run. A run standing along the depth has no component to turn about it, so that case takes the breadth instead.
    private static func across(_ forward: SIMD3<Float>) -> SIMD3<Float> {
        let turned = cross(forward, SIMD3<Float>(0, 0, 1))
        let length = (turned * turned).sum().squareRoot()

        return length > 0 ? turned / length : SIMD3<Float>(1, 0, 0)
    }

    private static func cross(_ first: SIMD3<Float>, _ second: SIMD3<Float>) -> SIMD3<Float> {
        SIMD3<Float>(first.y * second.z - first.z * second.y,
                     first.z * second.x - first.x * second.z,
                     first.x * second.y - first.y * second.x)
    }
}
