/// Columnar dividers and row lines together across the Frame, one count and one gutter serving both axes.
public struct GridPreset: Hashable, Preset {
    private static let designSize = SIMD2<Float>(1, 1)

    public let count: Int
    /// A fraction of the design extent of whichever axis it divides, which is the Frame extent of that axis in aspect mode.
    public let gutter: Float
    public let mode: PresetPlotMode

    public init(count: Int, gutter: Float, mode: PresetPlotMode = .aspect) {
        self.count = count
        self.gutter = gutter
        self.mode = mode
    }

    public func paths(in frame: Frame) -> [[SIMD2<Float>]] {
        let projection = PresetProjection(mode: mode, frame: frame, designSize: Self.designSize)
        let columnEdges = PresetGutter(count: count, gutter: gutter, extent: Self.designSize.x).edges()
        let rowEdges = PresetGutter(count: count, gutter: gutter, extent: Self.designSize.y).edges()

        let verticals = columnEdges.map { x in
            [SIMD2<Float>(x, 0), SIMD2<Float>(x, Self.designSize.y)]
        }
        let horizontals = rowEdges.map { y in
            [SIMD2<Float>(0, y), SIMD2<Float>(Self.designSize.x, y)]
        }

        return projection.paths(verticals + horizontals)
    }
}
