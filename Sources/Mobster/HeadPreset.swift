import Foundation

/// A head built as the construction solids a drawing is made over: the cranial ellipsoid, the jaw wedge, the block of the chin and the plotted portion of the neck. The cranial mass is divided at the sagittal plane, at each side plane and at the brow, so the centre line, the side planes and the brow line are boundaries the division leaves rather than curves anything draws. Identities run from the subject's right to the left, below the brow before above it, then the jaw, the chin and the two halves of the neck.
public struct HeadPreset: Hashable, Sendable {
    /// Locations to a ring, the division every form of a construction takes.
    private static let points = 8
    private static let craniumIdentity: UInt32 = 1
    private static let jawIdentity: UInt32 = 9
    private static let chinIdentity: UInt32 = 10
    private static let neckIdentity: UInt32 = 11
    /// Design space. The construction is laid in by its full height, crown to shoulder line, and centred across it.
    private static let designCentre: Float = 0.5

    public let sex: HeadSex
    /// The location the head points at, measured from the centre of the cranial mass in head heights: x across the breadth, y downward, z out of the face.
    public let target: SIMD3<Float>
    /// Radians about forward.
    public let roll: Float

    public init(sex: HeadSex, target: SIMD3<Float>, roll: Float) {
        self.sex = sex
        self.target = target
        self.roll = roll
    }

    public func mesh(in frame: Frame) -> Mesh {
        let canon = HeadCanon(sex: sex)
        let placement = Self.placement(canon, target: target, roll: roll, frame: frame)
        let turned = Self.cranium(canon) + [Self.jaw(canon), Self.chin(canon)]

        return Mesh(triangles: turned.flatMap { $0.triangles(placement.location) }
            + Self.neck(canon).flatMap { $0.triangles(placement.upright) })
    }

    /// The mass in four bands of breadth, cut at each side plane and at the sagittal plane, each band divided again at the brow. The cut is a construction element rather than a truncation, so the mass keeps the euryon breadth the canon gives it.
    private static func cranium(_ canon: HeadCanon) -> [MeshBand] {
        let breadths = [canon.halfWidth, canon.sidePlaneOffset, 0, -canon.sidePlaneOffset, -canon.halfWidth]
        let sections = breadths.map { section(canon, at: $0) }

        return sections.indices.dropLast().flatMap { index -> [MeshBand] in
            let identity = craniumIdentity + UInt32(index) * 2

            return [MeshBand(first: below(sections[index]), second: below(sections[index + 1]), identity: MeshIdentity(identity), closed: false),
                    MeshBand(first: above(sections[index]), second: above(sections[index + 1]), identity: MeshIdentity(identity + 1), closed: false)]
        }
    }

    /// The section of the mass at a breadth, which is the ellipse the cut leaves. Turn zero stands at the front of the brow line and a half turn at the back of it, so the first half of the ring runs below the brow and the second half above it. A section at the full breadth collapses onto the pole.
    private static func section(_ canon: HeadCanon, at breadth: Float) -> [SIMD3<Float>] {
        let reach = min(max(breadth / canon.halfWidth, -1), 1)
        let scale = (1 - reach * reach).squareRoot()

        return (0 ..< points).map { step in
            let turn = Float(step) / Float(points) * 2 * .pi

            return SIMD3<Float>(breadth, canon.browLevel * scale * sin(turn), canon.halfDepth * scale * cos(turn))
        }
    }

    private static func below(_ section: [SIMD3<Float>]) -> [SIMD3<Float>] {
        Array(section[0 ... points / 2])
    }

    private static func above(_ section: [SIMD3<Float>]) -> [SIMD3<Float>] {
        Array(section[(points / 2)...]) + [section[0]]
    }

    /// The jaw wedge, its back edge spanning the jaw angles under the depth centre of the mass and its front standing at the front of the mass. The front face is left to the chin, the two carrying their own identities because the underside of a jaw and the front of a chin are surfaces a viewer reads apart.
    private static func jaw(_ canon: HeadCanon) -> MeshBand {
        let angle = SIMD3<Float>(canon.jawHalfWidth, canon.jawLevel - canon.browLevel, 0)
        let back = [angle, angle, SIMD3<Float>(-angle.x, angle.y, angle.z), SIMD3<Float>(-angle.x, angle.y, angle.z)]

        return MeshBand(first: chinFace(canon), second: back, identity: MeshIdentity(jawIdentity))
    }

    /// The front of the jaw wedge. A balanced profile carries pogonion under glabella, which the head length puts at the front of the mass.
    private static func chin(_ canon: HeadCanon) -> MeshBand {
        let face = chinFace(canon)
        let middle = SIMD3<Float>(0, (face[0].y + face[1].y) / 2, canon.halfDepth)

        return MeshBand(first: face, second: [SIMD3<Float>](repeating: middle, count: face.count), identity: MeshIdentity(chinIdentity))
    }

    /// The block of the chin, standing at the front of the mass and tapering from the jaw angles it meets above to the mouth at gnathion. The corners run from the subject's right at the top, down that side and back up the left.
    private static func chinFace(_ canon: HeadCanon) -> [SIMD3<Float>] {
        let base = canon.chinLevel - canon.browLevel
        let top = canon.chinTopLevel - canon.browLevel

        return [SIMD3<Float>(canon.jawHalfWidth, top, canon.halfDepth),
                SIMD3<Float>(canon.chinHalfWidth, base, canon.halfDepth),
                SIMD3<Float>(-canon.chinHalfWidth, base, canon.halfDepth),
                SIMD3<Float>(-canon.jawHalfWidth, top, canon.halfDepth)]
    }

    /// A circular cylinder standing upright, divided at its middle for the cross section the roundness asks for. It starts at the jaw angles, the lowest level the head still covers it at, and the basis does not carry it: a neck does not turn when the head within it does.
    private static func neck(_ canon: HeadCanon) -> [MeshBand] {
        let top = canon.jawLevel - canon.browLevel
        let base = canon.neckLevel - canon.browLevel
        let middle = (top + base) / 2

        return [MeshBand(first: ring(canon.neckRadius, at: top), second: ring(canon.neckRadius, at: middle), identity: MeshIdentity(neckIdentity)),
                MeshBand(first: ring(canon.neckRadius, at: middle), second: ring(canon.neckRadius, at: base), identity: MeshIdentity(neckIdentity + 1))]
    }

    private static func ring(_ radius: Float, at level: Float) -> [SIMD3<Float>] {
        (0 ..< points).map { step in
            let turn = Float(step) / Float(points) * 2 * .pi

            return SIMD3<Float>(radius * cos(turn), level, radius * sin(turn))
        }
    }

    /// Levels run from the centre of the cranial mass, which the brow level carries back to the crown, and the shoulder line is what the full height is measured to.
    private static func placement(_ canon: HeadCanon, target: SIMD3<Float>, roll: Float, frame: Frame) -> MeshPlacement {
        let unit = 1 / canon.neckLevel

        return MeshPlacement(target: target,
                             roll: roll,
                             origin: SIMD2<Float>(0, 0),
                             pivot: SIMD2<Float>(designCentre, canon.browLevel * unit),
                             unit: unit,
                             frame: frame)
    }
}
