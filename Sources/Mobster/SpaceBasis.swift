import Foundation

/// The axes a three dimensional construction is carried onto. Forward runs from the origin of the construction toward the location it points at, right and up follow from forward, and roll turns those two about it.
struct SpaceBasis: Hashable, Sendable {
    /// A level is measured downward in the spaces these axes are derived in, so up runs against y.
    private static let vertical = SIMD3<Float>(0, -1, 0)
    /// The least run a target is read at, a thousandth of the construction's own unit.
    private static let runFloor: Float = 0.001

    let forward: SIMD3<Float>
    let right: SIMD3<Float>
    let up: SIMD3<Float>

    /// Forty five degrees off level is one of rise to one of run, so holding the rise within the run keeps forward clear of the vertical it is crossed with. Holding the run itself above a floor keeps forward off zero, atan2 answering the azimuth of a target that has none as the depth of the construction.
    init(target: SIMD3<Float>, roll: Float) {
        let azimuth = atan2(target.x, target.z)
        let run = max((target.x * target.x + target.z * target.z).squareRoot(), Self.runFloor)
        let held = SIMD3<Float>(run * sin(azimuth), min(max(target.y, -run), run), run * cos(azimuth))
        let ahead = Self.normalized(held)
        let across = Self.normalized(Self.crossed(ahead, Self.vertical))
        let over = Self.crossed(across, ahead)

        forward = ahead
        right = across * cos(roll) + over * sin(roll)
        up = over * cos(roll) - across * sin(roll)
    }

    private static func crossed(_ first: SIMD3<Float>, _ second: SIMD3<Float>) -> SIMD3<Float> {
        SIMD3<Float>(first.y * second.z - first.z * second.y,
                     first.z * second.x - first.x * second.z,
                     first.x * second.y - first.y * second.x)
    }

    private static func normalized(_ run: SIMD3<Float>) -> SIMD3<Float> {
        run / (run * run).sum().squareRoot()
    }
}
