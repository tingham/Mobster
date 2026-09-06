import Foundation

/// The line a ruler or a curve spans, taken from two degrees swept about a center out to the edge of the design rectangle.
struct PresetChord {
    let start: SIMD2<Float>
    let end: SIMD2<Float>

    private let designSize: SIMD2<Float>

    init(center: SIMD2<Float>, firstDegree: Float, secondDegree: Float, designSize: SIMD2<Float>) {
        self.designSize = designSize
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

    /// Both ends are carried back onto the edge along their own terminal direction, so an offset run reaches the edge instead of floating short of it or sitting off it entirely. A run displaced clear of the design rectangle has no crossing and keeps its displaced ends.
    func offset(_ path: [SIMD2<Float>], by distance: Float) -> [SIMD2<Float>] {
        let displacement = normal * distance
        var run = path.map { $0 + displacement }
        guard run.count > 1 else { return run }

        if let head = edgeCrossing(from: run[1], toward: run[0]) {
            run[0] = head
        }
        if let tail = edgeCrossing(from: run[run.count - 2], toward: run[run.count - 1]) {
            run[run.count - 1] = tail
        }

        return run
    }

    /// Where the line through the two locations leaves the design rectangle on the far side of the anchor.
    private func edgeCrossing(from anchor: SIMD2<Float>, toward location: SIMD2<Float>) -> SIMD2<Float>? {
        let run = location - anchor
        let length = (run.x * run.x + run.y * run.y).squareRoot()
        guard length > 0 else { return nil }

        let direction = run / length
        var entry = -Float.greatestFiniteMagnitude
        var exit = Float.greatestFiniteMagnitude

        for axis in 0 ... 1 {
            let origin = anchor[axis]
            let step = direction[axis]
            let extent = designSize[axis]

            guard step != 0 else {
                guard origin >= 0, origin <= extent else { return nil }
                continue
            }

            let near = (0 - origin) / step
            let far = (extent - origin) / step
            entry = max(entry, min(near, far))
            exit = min(exit, max(near, far))
        }

        guard entry <= exit else { return nil }
        return anchor + direction * exit
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
