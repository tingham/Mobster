import Foundation

/// A head plotted as the construction primitives a drawing is built over: the cranial ellipsoid, its two side planes, the brow line and the centre line as great circles of that ellipsoid, the underside and the front of the jaw wedge, and the plotted portion of the neck. Paths are emitted in that order, the side planes taking the subject's right before the left. A primitive reaching into the far side emits only the stretches of it that stand nearer, so the count of paths follows from where the head points.
public struct HeadPreset: Hashable, Preset {
    private static let designSize = SIMD2<Float>(1, 1)
    /// Segments a closed curve is sampled into.
    private static let ringSegments = 64

    public let sex: HeadSex
    /// The location the head points at, measured from the centre of the cranial mass in head heights: x across the breadth, y downward, z out of the face.
    public let target: SIMD3<Float>
    /// Radians about forward.
    public let roll: Float
    public let mode: PresetPlotMode

    public init(sex: HeadSex, target: SIMD3<Float>, roll: Float, mode: PresetPlotMode = .aspect) {
        self.sex = sex
        self.target = target
        self.roll = roll
        self.mode = mode
    }

    public func paths(in frame: Frame) -> [[SIMD2<Float>]] {
        let canon = HeadCanon(sex: sex)
        let space = SpaceProjection(basis: SpaceBasis(target: target, roll: roll))
        let projection = PresetProjection(mode: mode, frame: frame, designSize: Self.designSize)
        let solid = [Self.browLine(canon),
                     Self.centreLine(canon),
                     Self.sidePlane(canon, offset: canon.sidePlaneOffset),
                     Self.sidePlane(canon, offset: -canon.sidePlaneOffset),
                     Self.jaw(canon),
                     Self.chin(canon)]
        let flat = [[Self.cranium(canon, space)]] + solid.map(space.runs) + [[Self.neck(canon)]]

        return projection.paths(flat.flatMap { $0 }.map { $0.map { Self.design($0, canon) } })
    }

    /// The orthographic outline of an ellipsoid is an ellipse, so the cranial mass is emitted from a closed form rather than from a sampled rim. The plane axes scaled by the semi axes leave a two by two form, and the square root of that form carries the unit circle onto the outline.
    private static func cranium(_ canon: HeadCanon, _ space: SpaceProjection) -> [SIMD2<Float>] {
        let semi = SIMD3<Float>(canon.halfWidth, canon.browLevel, canon.halfDepth)
        let across = space.across * semi
        let down = space.down * semi
        let first = (across * across).sum()
        let second = (down * down).sum()
        let mixed = (across * down).sum()
        let area = (first * second - mixed * mixed).squareRoot()
        let scale = (first + second + 2 * area).squareRoot()

        return (0 ... ringSegments).map { step in
            let turn = Float(step) / Float(ringSegments) * 2 * .pi
            let unit = SIMD2<Float>(cos(turn), sin(turn))
            return SIMD2<Float>((first + area) * unit.x + mixed * unit.y, mixed * unit.x + (second + area) * unit.y) / scale
        }
    }

    /// The horizontal great circle of the cranial mass, which its brow level makes the equator of.
    private static func browLine(_ canon: HeadCanon) -> [SIMD3<Float>] {
        ring { turn in SIMD3<Float>(canon.halfWidth * sin(turn), 0, canon.halfDepth * cos(turn)) }
    }

    /// The sagittal great circle of the cranial mass, running from the crown down to the underside.
    private static func centreLine(_ canon: HeadCanon) -> [SIMD3<Float>] {
        ring { turn in SIMD3<Float>(0, -canon.browLevel * cos(turn), canon.halfDepth * sin(turn)) }
    }

    /// A plane section of the ellipsoid, which is the ellipse the cut leaves behind.
    private static func sidePlane(_ canon: HeadCanon, offset: Float) -> [SIMD3<Float>] {
        let reach = offset / canon.halfWidth
        let section = (1 - reach * reach).squareRoot()

        return ring { turn in SIMD3<Float>(offset, canon.browLevel * section * sin(turn), canon.halfDepth * section * cos(turn)) }
    }

    /// The underside of the jaw wedge, whose back edge spans the jaw angles under the depth centre of the cranial mass and whose front edge is the bottom of the chin.
    private static func jaw(_ canon: HeadCanon) -> [SIMD3<Float>] {
        let angle = SIMD3<Float>(canon.jawHalfWidth, canon.jawLevel - canon.browLevel, 0)
        let corner = SIMD3<Float>(canon.chinHalfWidth, canon.chinLevel - canon.browLevel, canon.halfDepth)

        return [angle,
                corner,
                SIMD3<Float>(-corner.x, corner.y, corner.z),
                SIMD3<Float>(-angle.x, angle.y, angle.z),
                angle]
    }

    /// The front of the jaw wedge, rising from gnathion to sublabiale. A balanced profile carries pogonion under glabella, which the head length puts at the front of the cranial mass.
    private static func chin(_ canon: HeadCanon) -> [SIMD3<Float>] {
        let base = canon.chinLevel - canon.browLevel
        let top = base - canon.chinFaceHeight

        return [SIMD3<Float>(canon.chinHalfWidth, top, canon.halfDepth),
                SIMD3<Float>(canon.chinHalfWidth, base, canon.halfDepth),
                SIMD3<Float>(-canon.chinHalfWidth, base, canon.halfDepth),
                SIMD3<Float>(-canon.chinHalfWidth, top, canon.halfDepth),
                SIMD3<Float>(canon.chinHalfWidth, top, canon.halfDepth)]
    }

    /// The outline of a circular cylinder standing upright does not move as the head turns within it, so the neck is emitted from its radius alone and is the one part the basis does not carry. It starts at the jaw angles, the lowest level the head still covers it at.
    private static func neck(_ canon: HeadCanon) -> [SIMD2<Float>] {
        let top = canon.jawLevel - canon.browLevel
        let base = canon.neckLevel - canon.browLevel

        return [SIMD2<Float>(canon.neckRadius, top),
                SIMD2<Float>(canon.neckRadius, base),
                SIMD2<Float>(-canon.neckRadius, base),
                SIMD2<Float>(-canon.neckRadius, top),
                SIMD2<Float>(canon.neckRadius, top)]
    }

    private static func ring(_ location: (Float) -> SIMD3<Float>) -> [SIMD3<Float>] {
        (0 ... ringSegments).map { step in location(Float(step) / Float(ringSegments) * 2 * .pi) }
    }

    /// The construction is laid into the design rectangle by its full height, crown to shoulder line, and centred across it. Levels run from the centre of the cranial mass, which the brow level carries back to the crown. One scale serves both axes, so a square Frame carries true proportion and any other carries the Frame's aspect ratio as every aspect mode preset does.
    private static func design(_ location: SIMD2<Float>, _ canon: HeadCanon) -> SIMD2<Float> {
        let scale = designSize.y / canon.neckLevel

        return SIMD2<Float>(designSize.x / 2 + location.x * scale, (location.y + canon.browLevel) * scale)
    }
}
