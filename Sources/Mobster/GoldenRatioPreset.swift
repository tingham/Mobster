/// A spiral populating the standard ratio frame, plotted with the nested rectangles it is derived from. Its geometry is fixed, so it is read rather than computed.
public struct GoldenRatioPreset: Hashable, Sendable {
    private static let resourceName = "GoldenRatio"
    /// The corner the stored spiral already converges toward, so every other focus is a mirror away from it.
    private static let storedFocus = PresetFocus.maxXMinY

    public let focus: PresetFocus

    /// The default repeats the stored focus as a literal because a private member cannot serve as a public default argument.
    public init(focus: PresetFocus = .maxXMinY) {
        self.focus = focus
    }

    /// Bounds always. A spiral stretched to a Frame's aspect ratio is no longer the golden ratio.
    public func paths(in frame: Frame) -> [[SIMD2<Float>]] {
        let resource = PresetResource.load(Self.resourceName)
        let projection = PresetProjection(mode: .bounds, frame: frame, designSize: resource.size)

        return projection.paths(resource.paths.map { path in
            path.map { Self.oriented($0, within: resource.size, toward: focus) }
        })
    }

    private static func oriented(_ location: SIMD2<Float>, within designSize: SIMD2<Float>, toward focus: PresetFocus) -> SIMD2<Float> {
        guard focus != storedFocus else { return location }

        let mirrorX = focus == .minXMinY || focus == .minXMaxY
        let mirrorY = focus == .minXMaxY || focus == .maxXMaxY

        return SIMD2<Float>(mirrorX ? designSize.x - location.x : location.x,
                            mirrorY ? designSize.y - location.y : location.y)
    }
}
