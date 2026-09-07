/// Evaluates content between two frames.
public final class Guide {
    /// Supplied at construction, so there is no window in which a workload precedes it.
    public private(set) var frame: Frame
    /// The reach it maps onto does not cross the boundary.
    public private(set) var adhesion: Float
    /// The time at which every vert has arrived.
    public private(set) var duration: Double
    /// Scene units, deciding arrival, deriving the field resolution and setting the reach full adhesion requires. It arrives where the bake happens, so those three cannot be answered by different epsilons.
    public private(set) var settleEpsilon: Float
    /// Interpreted from the source at initialize.
    public private(set) var lines: [Line]
    private var field: Field

    public init(frame: Frame) {
        self.frame = frame
        adhesion = 0
        duration = 0
        settleEpsilon = 0
        lines = []
        field = Field(frame: frame, columns: 0, rows: 0, locations: [])
    }

    /// The bake happens here and once, so a refusal surfaces here. Nothing is replaced until the bake is in hand, which leaves a refused Guide as it stood rather than half changed.
    public func initialize(source: GuideSource, frame: Frame, adhesion: Float, duration: Double, settleEpsilon: Float, budget: Int) throws(FieldRefusal) {
        let interpreted = Self.interpret(source, in: frame)
        let baked = try FieldBake(paths: interpreted.map { $0.verts.map(\.location) }, frame: frame, settleEpsilon: settleEpsilon, budget: budget).field()

        self.frame = frame
        self.adhesion = min(max(adhesion, 0), 1)
        self.duration = duration
        self.settleEpsilon = settleEpsilon
        lines = interpreted
        field = baked
    }

    public func evaluate(_ content: [Line], at time: Double) -> [Line] {
        let carried = progress(at: time)
        let adherence = Adherence(reach: adhesion * fullAdherenceReach)

        return content.map { line in
            Line(verts: displaced(line.verts, progress: carried, adherence: adherence), identifier: line.identifier)
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

    /// The whole line's offsets are resolved before any vert is placed, because what a peer takes a share of is the motion its neighbour makes at this progress.
    private func displaced(_ verts: [Vert], progress: Float, adherence: Adherence) -> [Vert] {
        let travels = verts.map { Travel(mass: $0.mass, drag: $0.drag) }
        let fractions = travels.map { $0.fraction(at: progress) }
        let offsets = Coupling(strengths: verts.map(\.coupling), fractions: fractions).offsets(at: progress)

        return verts.indices.map { index in
            let vert = verts[index]
            let target = adherence.target(for: vert.location, in: field)
            // An offset shifts where a vert stands on its own travel, so the shape its mass and drag ask for is spent from the shifted stance rather than added to.
            let carried = travels[index].fraction(at: min(max(progress + offsets[index], 0), 1))
            return Vert(
                location: vert.location + (target - vert.location) * carried,
                identifier: vert.identifier,
                mass: vert.mass,
                drag: vert.drag,
                coupling: vert.coupling
            )
        }
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
