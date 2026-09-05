/// A spiral populating the standard ratio frame. Its geometry is fixed, so it is read rather than computed.
public struct GoldenRatioPreset: Hashable, Sendable {
    private static let resourceName = "GoldenRatio"

    public init() {}

    public func paths(in frame: Frame, mode: PresetPlotMode) -> [[SIMD2<Float>]] {
        let resource = PresetResource.load(Self.resourceName)
        let projection = PresetProjection(mode: mode, frame: frame, designSize: resource.size)

        return projection.paths(resource.paths)
    }
}
