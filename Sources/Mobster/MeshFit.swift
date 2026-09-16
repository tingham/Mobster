import Whiplash

/// A traced boundary fitted to a count of locations Mobster asks for. A count rather than a tolerance is what makes a turning form deform its path instead of rebuilding it with a different one each view.
struct MeshFit {
    /// Locations a boundary is fitted to. Low, because a path is drawn over rather than measured against.
    static let count = 12
    /// The derived floor on removal is turned off, a floor that climbs with the sample count refusing the count asked for on any long boundary.
    private static let floor: Float = 0
    /// Faithful to the samples that were traced, only the anchors of the fit being kept.
    private static let tension: Float = 1

    let locations: [SIMD2<Float>]

    /// A path carries locations and no curvature, so what is kept of the fit is its anchors. They are input samples, the fit only ever removing.
    func path() -> [SIMD2<Float>] {
        let traced = Whiplash.Path(marks: locations)
        let available = Whiplash.reach(traced, floor: Self.floor)
        let wanted = min(max(Self.count, available.lowerBound), available.upperBound)
        // The count is held inside what this path reaches, so the fit cannot refuse it and the fallback cannot be taken.
        let fitted = (try? Whiplash.fit(traced, count: wanted, tension: Self.tension, floor: Self.floor)) ?? traced

        return fitted.vertices.map(\.position)
    }
}
