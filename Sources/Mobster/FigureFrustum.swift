import Foundation

/// A limb segment, standing as two stacked cylinders that share the ring at its middle. That shared ring is the cross section showing the form's roundness, and where two segments meet it is the joint seam, both falling out of the one division.
struct FigureFrustum {
    /// Locations to a ring. An arm segment is a ring of eight points joined into a cylinder and no anatomy is modelled.
    static let points = 8

    let start: SIMD2<Float>
    let end: SIMD2<Float>
    let startWidth: Float
    let endWidth: Float

    var middle: SIMD2<Float> {
        (start + end) / 2
    }

    func bands(first: MeshIdentity, second: MeshIdentity) -> [MeshBand] {
        let root = ring(at: start, width: startWidth)
        let waist = ring(at: middle, width: (startWidth + endWidth) / 2)
        let tip = ring(at: end, width: endWidth)

        return [MeshBand(first: root, second: waist, identity: first),
                MeshBand(first: waist, second: tip, identity: second)]
    }

    /// A limb is circular in section, so its width serves as a diameter on both axes and needs no new number. A form whose ends coincide has no axis to lay a ring across, so it takes the axis of the plane rather than dividing by zero.
    private func ring(at centre: SIMD2<Float>, width: Float) -> [SIMD3<Float>] {
        let run = end - start
        let length = (run.x * run.x + run.y * run.y).squareRoot()
        let across = length > 0 ? SIMD2<Float>(-run.y, run.x) / length : SIMD2<Float>(1, 0)

        return (0 ..< Self.points).map { step in
            let turn = Float(step) / Float(Self.points) * 2 * .pi
            let reach = across * (width / 2 * cos(turn))

            return SIMD3<Float>(centre.x + reach.x, centre.y + reach.y, width / 2 * sin(turn))
        }
    }
}
