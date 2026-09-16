import Foundation

/// An ellipsoid seen square on, which projects to an ellipse.
struct AshcanEllipse {
    let center: SIMD2<Float>
    let radii: SIMD2<Float>

    func path(segments: Int) -> [SIMD2<Float>] {
        let count = max(segments, 3)

        return (0 ... count).map { step in
            let angle = Float(step) / Float(count) * 2 * Float.pi
            return center + SIMD2<Float>(cos(angle) * radii.x, sin(angle) * radii.y)
        }
    }
}
