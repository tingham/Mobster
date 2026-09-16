/// A limb as two segments, with the joint between them taken from the closed form solve. Each segment divides at its own middle, so the two mid slices and the joint seam between the segments all come from the one mechanism and a limb carries four identities.
struct AshcanLimb {
    /// Identities a limb takes, which is two a segment.
    static let identities: UInt32 = 4

    let upper: AshcanFrustum
    let lower: AshcanFrustum

    init(root: SIMD2<Float>, target: SIMD2<Float>, pole: SIMD2<Float>, upperLength: Float, lowerLength: Float, rootWidth: Float, jointWidth: Float, endWidth: Float) {
        let solve = AshcanSolve(root: root, target: target, upper: upperLength, lower: lowerLength, pole: pole)
        upper = AshcanFrustum(start: root, end: solve.joint, startWidth: rootWidth, endWidth: jointWidth)
        lower = AshcanFrustum(start: solve.joint, end: solve.end, startWidth: jointWidth, endWidth: endWidth)
    }

    func bands(from identity: UInt32) -> [MeshBand] {
        upper.bands(first: MeshIdentity(identity), second: MeshIdentity(identity + 1))
            + lower.bands(first: MeshIdentity(identity + 2), second: MeshIdentity(identity + 3))
    }
}
