/// A ruler whose line is bowed by a control location, flanked by a parallel pair at an offset.
public struct CurvePreset: Hashable, Sendable {
    private static let designSize = SIMD2<Float>(1, 1)

    /// Design space, where zero to one spans the Frame.
    public let center: SIMD2<Float>
    public let firstDegree: Float
    public let secondDegree: Float
    /// A fraction of the design extent, measured perpendicular to the chord.
    public let distance: Float
    /// Design space. Its distance from the chord is the tension.
    public let control: SIMD2<Float>
    /// Segments the curve is sampled into.
    public let resolution: Int
    public let mode: PresetPlotMode

    public init(center: SIMD2<Float>, firstDegree: Float, secondDegree: Float, distance: Float, control: SIMD2<Float>, resolution: Int, mode: PresetPlotMode = .aspect) {
        self.center = center
        self.firstDegree = firstDegree
        self.secondDegree = secondDegree
        self.distance = distance
        self.control = control
        self.resolution = resolution
        self.mode = mode
    }

    public func paths(in frame: Frame) -> [[SIMD2<Float>]] {
        precondition(resolution >= 1, "A curve needs at least one segment")

        let projection = PresetProjection(mode: mode, frame: frame, designSize: Self.designSize)
        let chord = PresetChord(center: center, firstDegree: firstDegree, secondDegree: secondDegree, designSize: Self.designSize)
        let curve = (0 ... resolution).map { step in
            Self.location(at: Float(step) / Float(resolution), start: chord.start, control: control, end: chord.end)
        }

        return projection.paths([curve, chord.offset(curve, by: distance), chord.offset(curve, by: -distance)])
    }

    private static func location(at t: Float, start: SIMD2<Float>, control: SIMD2<Float>, end: SIMD2<Float>) -> SIMD2<Float> {
        let inverse = 1 - t
        return start * (inverse * inverse) + control * (2 * inverse * t) + end * (t * t)
    }
}
