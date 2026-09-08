/// Three columns and three rows, so two dividers on each axis.
public struct ThirdsPreset: Hashable, Preset {
    private static let designSize = SIMD2<Float>(1, 1)

    public let mode: PresetPlotMode

    public init(mode: PresetPlotMode = .aspect) {
        self.mode = mode
    }

    public func paths(in frame: Frame) -> [[SIMD2<Float>]] {
        let projection = PresetProjection(mode: mode, frame: frame, designSize: Self.designSize)
        let fractions: [Float] = [1.0 / 3.0, 2.0 / 3.0]

        let verticals = fractions.map { x in
            [SIMD2<Float>(x, 0), SIMD2<Float>(x, Self.designSize.y)]
        }
        let horizontals = fractions.map { y in
            [SIMD2<Float>(0, y), SIMD2<Float>(Self.designSize.x, y)]
        }

        return projection.paths(verticals + horizontals)
    }
}
