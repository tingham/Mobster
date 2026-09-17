import Mobster

/// The design rectangle a construction is laid into. The lesser axis of the Frame sizes it and it is centred, which is how a preset that fits inside the Frame meets it, so a target held in design space is drawn through this and dragged back through it.
struct DesignSquare {
    let frame: Frame

    private var fit: Float {
        min(frame.size.x, frame.size.y)
    }

    private var corner: SIMD2<Float> {
        frame.origin + (frame.size - SIMD2<Float>(fit, fit)) / 2
    }

    func location(_ design: SIMD2<Float>) -> SIMD2<Float> {
        design * fit + corner
    }

    func design(_ location: SIMD2<Float>) -> SIMD2<Float> {
        fit > 0 ? (location - corner) / fit : .zero
    }
}
