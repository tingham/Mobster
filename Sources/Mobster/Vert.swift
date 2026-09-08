public struct Vert: Sendable {
    /// Scene coordinates.
    public let location: SIMD2<Float>
    /// The consumer's, returned untouched.
    public let identifier: VertIdentifier?
    public let mass: Float?
    public let drag: Float?
    public let coupling: Float?

    public init(
        location: SIMD2<Float>,
        identifier: VertIdentifier? = nil,
        mass: Float? = nil,
        drag: Float? = nil,
        coupling: Float? = nil
    ) {
        self.location = location
        self.identifier = identifier
        self.mass = mass
        self.drag = drag
        self.coupling = coupling
    }
}
