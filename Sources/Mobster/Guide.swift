/// Evaluates content between two frames.
public final class Guide {
    /// Supplied at construction, so there is no window in which a workload precedes it.
    public private(set) var frame: Frame
    /// Scene units. Supplied rather than fixed here, because what a pixel is worth in the scene is the consumer's to know.
    public let settleEpsilon: Float
    /// The reach it maps onto does not cross the boundary.
    public private(set) var adhesion: Float
    /// The time at which every vert has arrived.
    public private(set) var duration: Double
    /// Interpreted from the source at initialize.
    public private(set) var lines: [Line]
    private var field: Field

    public init(frame: Frame, settleEpsilon: Float) {
        self.frame = frame
        self.settleEpsilon = settleEpsilon
        adhesion = 0
        duration = 0
        lines = []
        field = Field(frame: frame, columns: 0, rows: 0, locations: [])
    }

    /// Resolution is a parameter here only until it is derived from the Frame and the epsilon.
    public func initialize(source: GuideSource, frame: Frame, adhesion: Float, duration: Double, resolution: Int) {
        self.frame = frame
        self.adhesion = min(max(adhesion, 0), 1)
        self.duration = duration
        lines = Self.interpret(source, in: frame)
        field = FieldBake(paths: lines.map { $0.verts.map(\.location) }, frame: frame, resolution: resolution).field()
    }

    public func evaluate(_ content: [Line], at time: Double) -> [Line] {
        let carried = progress(at: time)
        let adherence = Adherence(reach: adhesion * fullAdherenceReach)

        return content.map { line in
            Line(verts: line.verts.map { displaced($0, progress: carried, adherence: adherence) }, identifier: line.identifier)
        }
    }

    /// An approximation for display, which is the only form the field takes across the boundary.
    public func raster() -> FieldRaster? {
        field.grayscale()
    }

    /// The reach at which every vert in the Frame settles within the epsilon. The worst case is the diagonal, a vert in one corner of the Frame whose nearest path location is the far corner.
    public var fullAdherenceReach: Float {
        Adherence.reach(settling: length(frame.size), within: settleEpsilon)
    }

    /// Attributes are carried through untouched, because what consumes them is a later cycle.
    private func displaced(_ vert: Vert, progress: Float, adherence: Adherence) -> Vert {
        let target = adherence.target(for: vert.location, in: field)
        return Vert(
            location: vert.location + (target - vert.location) * progress,
            identifier: vert.identifier,
            mass: vert.mass,
            drag: vert.drag,
            coupling: vert.coupling
        )
    }

    /// Arrival is tested first, so a duration of zero has arrived at every time the run covers rather than dividing by it.
    private func progress(at time: Double) -> Float {
        guard time < duration else { return 1 }
        guard time > 0 else { return 0 }
        return Float(time / duration)
    }

    /// Nothing keys a guide, so an interpreted vert carries no identifier.
    private static func interpret(_ source: GuideSource, in frame: Frame) -> [Line] {
        switch source {
        case let .lines(lines):
            return lines
        case let .preset(preset):
            return preset.paths(in: frame).map { path in
                Line(verts: path.map { Vert(location: $0) })
            }
        }
    }

    private func length(_ run: SIMD2<Float>) -> Float {
        (run.x * run.x + run.y * run.y).squareRoot()
    }
}
