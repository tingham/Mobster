/// Two bone inverse kinematics in closed form. The law of cosines places the joint and the pole picks one solution out of the circle of them the two lengths admit.
struct AshcanSolve {
    let joint: SIMD2<Float>
    let end: SIMD2<Float>

    /// A target further off than the two bones reach is answered by extending them straight toward it rather than by refusing it or by moving it nearer.
    init(root: SIMD2<Float>, target: SIMD2<Float>, upper: Float, lower: Float, pole: SIMD2<Float>) {
        let run = target - root
        let reach = Self.length(run)
        let direction = reach > 0 ? run / reach : Self.direction(pole)

        if reach >= upper + lower || reach <= 0 {
            joint = root + direction * upper
        } else {
            let cosine = min(max((upper * upper + reach * reach - lower * lower) / (2 * upper * reach), -1), 1)
            let sine = (1 - cosine * cosine).squareRoot()
            joint = root + direction * (upper * cosine) + Self.bend(direction: direction, pole: pole) * (upper * sine)
        }

        let carry = target - joint
        let span = Self.length(carry)
        end = joint + (span > 0 ? carry / span : direction) * lower
    }

    /// The component of the pole across the line to the target. A pole lying along that line, or no pole at all, leaves the choice to the lesser turn from the line.
    private static func bend(direction: SIMD2<Float>, pole: SIMD2<Float>) -> SIMD2<Float> {
        let along = pole.x * direction.x + pole.y * direction.y
        let across = pole - direction * along
        let length = length(across)

        return length > 0 ? across / length : SIMD2<Float>(-direction.y, direction.x)
    }

    private static func direction(_ pole: SIMD2<Float>) -> SIMD2<Float> {
        let length = length(pole)

        return length > 0 ? pole / length : SIMD2<Float>(0, 1)
    }

    private static func length(_ run: SIMD2<Float>) -> Float {
        (run.x * run.x + run.y * run.y).squareRoot()
    }
}
