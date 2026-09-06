/// Row lines spread evenly across the Frame, separated by gutters.
public struct RowsPreset: Hashable, Preset {
    private static let designSize = SIMD2<Float>(1, 1)

    public let count: Int
    /// A fraction of the design height, which is the Frame height in aspect mode.
    public let gutter: Float
    public let mode: PresetPlotMode

    public init(count: Int, gutter: Float, mode: PresetPlotMode = .aspect) {
        self.count = count
        self.gutter = gutter
        self.mode = mode
    }

    public func paths(in frame: Frame) -> [[SIMD2<Float>]] {
        let projection = PresetProjection(mode: mode, frame: frame, designSize: Self.designSize)
        let edges = PresetGutter(count: count, gutter: gutter, extent: Self.designSize.y).edges()

        return projection.paths(edges.map { y in
            [SIMD2<Float>(0, y), SIMD2<Float>(Self.designSize.x, y)]
        })
    }
}
