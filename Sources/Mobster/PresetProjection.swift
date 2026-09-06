/// Maps a preset's design space onto scene space.
struct PresetProjection {
    private let scale: SIMD2<Float>
    private let translation: SIMD2<Float>

    /// The design rectangle runs from zero to designSize on each axis.
    init(mode: PresetPlotMode, frame: Frame, designSize: SIMD2<Float>) {
        switch mode {
        case .aspect:
            scale = frame.size / designSize
            translation = frame.origin
        case .bounds:
            let cover = max(frame.size.x / designSize.x, frame.size.y / designSize.y)
            scale = SIMD2<Float>(cover, cover)
            translation = frame.origin + (frame.size - designSize * cover) / 2
        }
    }

    func location(_ designLocation: SIMD2<Float>) -> SIMD2<Float> {
        designLocation * scale + translation
    }

    func path(_ designPath: [SIMD2<Float>]) -> [SIMD2<Float>] {
        designPath.map(location)
    }

    func paths(_ designPaths: [[SIMD2<Float>]]) -> [[SIMD2<Float>]] {
        designPaths.map(path)
    }
}
