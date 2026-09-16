/// A wedge seen square on, which projects to a trapezoid. Its lower corners are where the legs are hung.
struct AshcanWedge {
    let center: Float
    let top: Float
    let bottom: Float
    let topWidth: Float
    let bottomWidth: Float

    var leftCorner: SIMD2<Float> {
        SIMD2<Float>(center - bottomWidth / 2, bottom)
    }

    var rightCorner: SIMD2<Float> {
        SIMD2<Float>(center + bottomWidth / 2, bottom)
    }

    var path: [SIMD2<Float>] {
        let leading = SIMD2<Float>(center - topWidth / 2, top)
        let trailing = SIMD2<Float>(center + topWidth / 2, top)

        return [leading, trailing, rightCorner, leftCorner, leading]
    }
}
