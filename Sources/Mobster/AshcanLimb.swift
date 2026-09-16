/// A limb as two tapered forms, with the joint between them taken from the closed form solve.
struct AshcanLimb {
    let upper: AshcanFrustum
    let lower: AshcanFrustum

    init(root: SIMD2<Float>, target: SIMD2<Float>, pole: SIMD2<Float>, upperLength: Float, lowerLength: Float, rootWidth: Float, jointWidth: Float, endWidth: Float) {
        let solve = AshcanSolve(root: root, target: target, upper: upperLength, lower: lowerLength, pole: pole)
        upper = AshcanFrustum(start: root, end: solve.joint, startWidth: rootWidth, endWidth: jointWidth)
        lower = AshcanFrustum(start: solve.joint, end: solve.end, startWidth: jointWidth, endWidth: endWidth)
    }

    var paths: [[SIMD2<Float>]] {
        [upper.path, lower.path]
    }
}
