/// The inverse distance squared falloff a Guide resolves a target through.
public struct Adherence: Hashable, Sendable {
    /// Scene units, the distance at which a vert is carried half the way to its nearest path location. A Guide derives it from its adhesion, so there is no default here.
    public let reach: Float

    public init(reach: Float) {
        self.reach = reach
    }

    /// The residual the falloff leaves is distance cubed over reach squared plus distance squared, solved here for the reach the epsilon demands. Zero where the worst case is already inside it.
    public static func reach(settling distance: Float, within epsilon: Float) -> Float {
        guard epsilon > 0, distance > epsilon else { return 0 }
        return distance * (distance / epsilon - 1).squareRoot()
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
