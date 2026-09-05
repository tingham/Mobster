/// The inverse distance squared falloff a Guide resolves a target through.
public struct Adherence: Hashable, Sendable {
    /// Scene units. The mapping from an adherence dial to a reach is derived in the harness, so there is no default here.
    public let reach: Float

    public init(reach: Float) {
        self.reach = reach
    }

    /// One over one plus the square of distance over reach. A collapsed reach yields no weight at any distance, which leaves every displacement zero.
    public func weight(distance: Float) -> Float {
        guard reach > 0 else { return 0 }
        let ratio = distance / reach
        return 1 / (1 + ratio * ratio)
    }

    /// Two reads at the location: how far the nearest path location is, and which way it lies.
    public func target(for location: SIMD2<Float>, in field: Field) -> SIMD2<Float> {
        let distance = field.distance(at: location)
        guard distance.isFinite, distance > 0 else { return location }
        return location + field.direction(at: location) * (weight(distance: distance) * distance)
    }
}
