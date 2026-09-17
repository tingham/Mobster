import Mobster

/// A location a user places, drawn on the preview and dragged there. A target with no mark on screen is a coordinate rather than a handle.
struct PresetHandle: Identifiable {
    let id: String
    /// Scene coordinates, which is what the canvas draws in.
    let location: SIMD2<Float>
    /// Takes a scene location back into whatever space the target it stands for is held in.
    let move: (SIMD2<Float>) -> Void
}
