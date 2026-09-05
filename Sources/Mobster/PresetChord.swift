import Foundation

/// The line a ruler or a curve spans, taken from two degrees swept about a center out to the edge of the design rectangle.
struct PresetChord {
    let start: SIMD2<Float>
    let end: SIMD2<Float>

    init(center: SIMD2<Float>, firstDegree: Float, secondDegree: Float, designSize: SIMD2<Float>) {
        start = Self.edgeLocation(from: center, degree: firstDegree, designSize: designSize)
        end = Self.edgeLocation(from: center, degree: secondDegree, designSize: designSize)
    }

    /// Zero where the two degrees resolve to the same location, which collapses an offset pair onto the line rather than yielding a division by zero.
    var normal: SIMD2<Float> {
        let run = end - start
        let length = (run.x * run.x + run.y * run.y).squareRoot()
        guard length > 0 else { return SIMD2<Float>(0, 0) }
        return SIMD2<Float>(-run.y, run.x) / length
    }

    func offset(_ path: [SIMD2<Float>], by distance: Float) -> [SIMD2<Float>] {
        let displacement = normal * distance
        return path.map { $0 + displacement }
    }

    private static func edgeLocation(from center: SIMD2<Float>, degree: Float, designSize: SIMD2<Float>) -> SIMD2<Float> {
        let radians = degree * Float.pi / 180
        let direction = SIMD2<Float>(cos(radians), sin(radians))
        let reach = min(Self.reach(from: center.x, along: direction.x, extent: designSize.x),
                        Self.reach(from: center.y, along: direction.y, extent: designSize.y))
        return center + direction * reach
    }

    /// Distance travelled along one axis before leaving the design rectangle.
    private static func reach(from origin: Float, along direction: Float, extent: Float) -> Float {
        if direction > 0 { return (extent - origin) / direction }
        if direction < 0 { return -origin / direction }
        return .greatestFiniteMagnitude
    }
}
