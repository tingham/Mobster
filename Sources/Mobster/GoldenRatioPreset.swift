/// A spiral populating the standard ratio frame, optionally plotted with the nested rectangles it is derived from. Its geometry is fixed, so it is read rather than computed.
public struct GoldenRatioPreset: Hashable, Preset {
    private static let resourceName = "GoldenRatio"
    /// The corner the stored spiral already converges toward, so every other focus is a mirror away from it.
    private static let storedFocus = PresetFocus.maxXMinY

    public let focus: PresetFocus
    public let quadlines: Bool

    /// The default repeats the stored focus as a literal because a private member cannot serve as a public default argument.
    public init(focus: PresetFocus = .maxXMinY, quadlines: Bool = true) {
        self.focus = focus
        self.quadlines = quadlines
    }

    /// Bounds always. A spiral stretched to a Frame's aspect ratio is no longer the golden ratio.
    public func paths(in frame: Frame) -> [Line] {
        let resource = PresetResource.load(Self.resourceName)
        let projection = PresetProjection(mode: .bounds, frame: frame, designSize: resource.size)
        // The spiral is the first path the resource holds, and the projection is taken from the design size, so dropping the rest leaves the spiral where it stood.
        let spiral = projection.lines(oriented(Array(resource.paths.prefix(1)), within: resource.size), role: .form)

        guard quadlines else { return spiral }

        return spiral + projection.lines(oriented(Array(resource.paths.dropFirst()), within: resource.size), role: .construction)
    }

    private func oriented(_ paths: [[SIMD2<Float>]], within designSize: SIMD2<Float>) -> [[SIMD2<Float>]] {
        paths.map { path in
            path.map { Self.oriented($0, within: designSize, toward: focus) }
        }
    }

    private static func oriented(_ location: SIMD2<Float>, within designSize: SIMD2<Float>, toward focus: PresetFocus) -> SIMD2<Float> {
        guard focus != storedFocus else { return location }

        let mirrorX = focus == .minXMinY || focus == .minXMaxY
        let mirrorY = focus == .minXMaxY || focus == .maxXMaxY

        return SIMD2<Float>(mirrorX ? designSize.x - location.x : location.x,
                            mirrorY ? designSize.y - location.y : location.y)
    }
}
