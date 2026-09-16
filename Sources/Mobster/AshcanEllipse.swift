import Foundation

/// An ellipsoid mass, divided at its equator so the cross section showing the form's roundness falls out of the division rather than out of a band of its own.
struct AshcanEllipse {
    /// Locations to a ring, the division every form of the figure takes.
    static let points = 8
    /// Rings of latitude either side of the equator. Two puts the equator halfway from pole to pole, which is where a mass is divided.
    static let stacks = 2

    let center: SIMD2<Float>
    let radii: SIMD3<Float>

    /// The poles are laid down rather than sampled, the sine of a half turn in single precision standing eight hundredths of a millionth off zero and spreading a pole into a ring of facets with no area.
    func bands(upper: MeshIdentity, lower: MeshIdentity) -> [MeshBand] {
        let crown = [SIMD3<Float>](repeating: SIMD3<Float>(center.x, center.y - radii.y, 0), count: Self.points)
        let sole = [SIMD3<Float>](repeating: SIMD3<Float>(center.x, center.y + radii.y, 0), count: Self.points)
        let latitudes = [crown] + (1 ..< Self.stacks * 2).map { ring(at: Float($0) / Float(Self.stacks * 2) * .pi) } + [sole]

        return latitudes.indices.dropLast().map { index in
            MeshBand(first: latitudes[index], second: latitudes[index + 1], identity: index < Self.stacks ? upper : lower)
        }
    }

    /// A level is measured downward, so the pole at a polar angle of zero is the crown of the mass.
    private func ring(at polar: Float) -> [SIMD3<Float>] {
        (0 ..< Self.points).map { step in
            let turn = Float(step) / Float(Self.points) * 2 * .pi

            return SIMD3<Float>(center.x + radii.x * sin(polar) * cos(turn),
                                center.y - radii.y * cos(polar),
                                radii.z * sin(polar) * sin(turn))
        }
    }
}
