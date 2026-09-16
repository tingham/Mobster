/// The yaw the head construction is turned by, and the orthographic projection that turn resolves to.
struct HeadYaw {
    /// The fraction of its frontal breadth the turned construction still projects, which is the cosine of the yaw.
    let cosine: Float
    /// The fraction of its depth the turned construction projects across, which is the sine of the yaw.
    let sine: Float

    /// A view of zero is full profile and a view of one is face forward. The dial is linear in the chord of the turn rather than in its angle, which lands the middle of the range where three quarters of the frontal breadth still projects: the three quarter view, at a yaw of forty one and a half degrees rather than the forty five a dial linear in angle would give.
    init(view: Float) {
        let turn = 1 - min(max(view, 0), 1)
        cosine = 1 - turn * turn
        sine = (1 - cosine * cosine).squareRoot()
    }

    /// Depth is dropped rather than divided through, the construction being a diagram and not a camera.
    func projected(_ location: SIMD3<Float>) -> SIMD2<Float> {
        SIMD2<Float>(location.x * cosine + location.z * sine, location.y)
    }
}
