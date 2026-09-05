/// A line crossing the Frame between two locations derived from two degrees, flanked by a parallel pair at an offset.
public struct RulerPreset: Hashable, Sendable {
    private static let designSize = SIMD2<Float>(1, 1)

    /// Design space, where zero to one spans the Frame.
    public let center: SIMD2<Float>
    public let firstDegree: Float
    public let secondDegree: Float
    /// A fraction of the design extent, measured perpendicular to the line.
    public let distance: Float
    public let mode: PresetPlotMode

    public init(center: SIMD2<Float>, firstDegree: Float, secondDegree: Float, distance: Float, mode: PresetPlotMode = .aspect) {
        self.center = center
        self.firstDegree = firstDegree
        self.secondDegree = secondDegree
        self.distance = distance
        self.mode = mode
    }

    public func paths(in frame: Frame) -> [[SIMD2<Float>]] {
        let projection = PresetProjection(mode: mode, frame: frame, designSize: Self.designSize)
        let chord = PresetChord(center: center, firstDegree: firstDegree, secondDegree: secondDegree, designSize: Self.designSize)
        let line = [chord.start, chord.end]

        return projection.paths([line, chord.offset(line, by: distance), chord.offset(line, by: -distance)])
    }
}
