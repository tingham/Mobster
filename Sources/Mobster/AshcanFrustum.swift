/// A tapered cylinder between two joints, which projects to a trapezoid about its axis.
struct AshcanFrustum {
    let start: SIMD2<Float>
    let end: SIMD2<Float>
    let startWidth: Float
    let endWidth: Float

    /// A form whose ends coincide has no axis to lay a width across, so it collapses onto its own location rather than dividing by zero.
    var path: [SIMD2<Float>] {
        let run = end - start
        let length = (run.x * run.x + run.y * run.y).squareRoot()
        guard length > 0 else { return [start, start, start, start, start] }

        let across = SIMD2<Float>(-run.y, run.x) / length
        let head = across * (startWidth / 2)
        let tail = across * (endWidth / 2)

        return [start - head, start + head, end + tail, end - tail, start - head]
    }
}
