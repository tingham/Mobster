import Foundation

/// The orthographic projection of a three dimensional construction onto the plane it is plotted on. Each axis of the plane reads one direction of the construction's space and a third reads depth, which is dropped rather than divided through, the construction being a diagram and not a camera.
struct SpaceProjection: Hashable, Sendable {
    /// The direction of the construction that the x of the plane reads.
    let across: SIMD3<Float>
    /// The direction of the construction that the y of the plane reads.
    let down: SIMD3<Float>
    /// The direction of the construction that runs toward the near side.
    let depth: SIMD3<Float>

    /// A level is measured downward, so the y of a construction runs against up.
    init(basis: SpaceBasis) {
        across = SIMD3<Float>(basis.right.x, -basis.up.x, basis.forward.x)
        down = SIMD3<Float>(basis.right.y, -basis.up.y, basis.forward.y)
        depth = SIMD3<Float>(basis.right.z, -basis.up.z, basis.forward.z)
    }

    func location(_ location: SIMD3<Float>) -> SIMD2<Float> {
        SIMD2<Float>((across * location).sum(), (down * location).sum())
    }

    /// The stretches of a path that stand on the near side of the construction's centre, each projected. A curve reaching into the far side emits what is left of it on either side of that reach rather than one path folded over itself, and a lone sample is no stretch of a curve.
    func runs(_ path: [SIMD3<Float>]) -> [[SIMD2<Float>]] {
        var kept: [[SIMD2<Float>]] = []
        var run: [SIMD2<Float>] = []

        for location in path {
            if (depth * location).sum() < 0 {
                if run.count > 1 { kept.append(run) }
                run = []
            } else {
                run.append(self.location(location))
            }
        }

        if run.count > 1 { kept.append(run) }

        return kept
    }
}
