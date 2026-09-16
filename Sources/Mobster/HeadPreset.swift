import Foundation

/// A head plotted as the construction primitives a drawing is built over: the cranial ellipsoid, its two side planes, the brow line and the centre line as great circles of that ellipsoid, the underside and the front of the jaw wedge, and the plotted portion of the neck. Paths are emitted in that order, the side planes taking the subject's right before the left.
public struct HeadPreset: Hashable, Preset {
    private static let designSize = SIMD2<Float>(1, 1)
    /// Segments a closed section is sampled into.
    private static let ringSegments = 64
    /// Segments a half great circle is sampled into.
    private static let arcSegments = 32

    public let sex: HeadSex
    /// Zero is full profile and one is face forward.
    public let view: Float
    public let mode: PresetPlotMode

    public init(sex: HeadSex, view: Float, mode: PresetPlotMode = .aspect) {
        self.sex = sex
        self.view = view
        self.mode = mode
    }

    public func paths(in frame: Frame) -> [[SIMD2<Float>]] {
        let canon = HeadCanon(sex: sex)
        let yaw = HeadYaw(view: view)
        let projection = PresetProjection(mode: mode, frame: frame, designSize: Self.designSize)
        let solid = [Self.browLine(canon),
                     Self.centreLine(canon),
                     Self.sidePlane(canon, offset: canon.sidePlaneOffset),
                     Self.sidePlane(canon, offset: -canon.sidePlaneOffset),
                     Self.jaw(canon),
                     Self.chin(canon)]
        let flat = [Self.cranium(canon, yaw)] + solid.map { $0.map(yaw.projected) } + [Self.neck(canon)]

        return projection.paths(flat.map { $0.map { Self.design($0, canon) } })
    }

    /// The orthographic outline of an ellipsoid is an ellipse, so the cranial mass is emitted from its projected semi axes rather than from a sampled rim.
    private static func cranium(_ canon: HeadCanon, _ yaw: HeadYaw) -> [SIMD2<Float>] {
        let across = canon.halfWidth * yaw.cosine
        let through = canon.halfDepth * yaw.sine
        let width = (across * across + through * through).squareRoot()

        return (0 ... ringSegments).map { step in
            let turn = Float(step) / Float(ringSegments) * 2 * .pi
            return SIMD2<Float>(width * cos(turn), canon.browLevel * (1 + sin(turn)))
        }
    }

    /// The horizontal great circle of the cranial mass, taken across the front half an artist can see.
    private static func browLine(_ canon: HeadCanon) -> [SIMD3<Float>] {
        (0 ... arcSegments).map { step in
            let sweep = Float(step) / Float(arcSegments) * .pi - .pi / 2
            return SIMD3<Float>(canon.halfWidth * sin(sweep), canon.browLevel, canon.halfDepth * cos(sweep))
        }
    }

    /// The sagittal great circle of the cranial mass, taken across the front half from the crown down to the underside.
    private static func centreLine(_ canon: HeadCanon) -> [SIMD3<Float>] {
        (0 ... arcSegments).map { step in
            let sweep = Float(step) / Float(arcSegments) * .pi
            return SIMD3<Float>(0, canon.browLevel * (1 - cos(sweep)), canon.halfDepth * sin(sweep))
        }
    }

    /// A plane section of the ellipsoid, which is the ellipse the cut leaves behind.
    private static func sidePlane(_ canon: HeadCanon, offset: Float) -> [SIMD3<Float>] {
        let reach = offset / canon.halfWidth
        let section = (1 - reach * reach).squareRoot()

        return (0 ... ringSegments).map { step in
            let turn = Float(step) / Float(ringSegments) * 2 * .pi
            return SIMD3<Float>(offset, canon.browLevel * (1 + section * sin(turn)), canon.halfDepth * section * cos(turn))
        }
    }

    /// The underside of the jaw wedge, whose back edge spans the jaw angles under the depth centre of the cranial mass and whose front edge is the bottom of the chin.
    private static func jaw(_ canon: HeadCanon) -> [SIMD3<Float>] {
        let angle = SIMD3<Float>(canon.jawHalfWidth, canon.jawLevel, 0)
        let corner = SIMD3<Float>(canon.chinHalfWidth, canon.chinLevel, canon.halfDepth)

        return [angle,
                corner,
                SIMD3<Float>(-corner.x, corner.y, corner.z),
                SIMD3<Float>(-angle.x, angle.y, angle.z),
                angle]
    }

    /// The front of the jaw wedge, rising from gnathion to sublabiale. A balanced profile carries pogonion under glabella, which the head length puts at the front of the cranial mass.
    private static func chin(_ canon: HeadCanon) -> [SIMD3<Float>] {
        let top = canon.chinLevel - canon.chinFaceHeight

        return [SIMD3<Float>(canon.chinHalfWidth, top, canon.halfDepth),
                SIMD3<Float>(canon.chinHalfWidth, canon.chinLevel, canon.halfDepth),
                SIMD3<Float>(-canon.chinHalfWidth, canon.chinLevel, canon.halfDepth),
                SIMD3<Float>(-canon.chinHalfWidth, top, canon.halfDepth),
                SIMD3<Float>(canon.chinHalfWidth, top, canon.halfDepth)]
    }

    /// The outline of a circular cylinder standing on the yaw axis does not move as the construction turns, so the neck is emitted from its radius alone. It starts at the jaw angles, the lowest level the head still covers it at.
    private static func neck(_ canon: HeadCanon) -> [SIMD2<Float>] {
        [SIMD2<Float>(canon.neckRadius, canon.jawLevel),
         SIMD2<Float>(canon.neckRadius, canon.neckLevel),
         SIMD2<Float>(-canon.neckRadius, canon.neckLevel),
         SIMD2<Float>(-canon.neckRadius, canon.jawLevel),
         SIMD2<Float>(canon.neckRadius, canon.jawLevel)]
    }

    /// The construction is laid into the design rectangle by its full height, crown to shoulder line, and centred across it. One scale serves both axes, so a square Frame carries true proportion and any other carries the Frame's aspect ratio as every aspect mode preset does.
    private static func design(_ location: SIMD2<Float>, _ canon: HeadCanon) -> SIMD2<Float> {
        let scale = designSize.y / canon.neckLevel

        return SIMD2<Float>(designSize.x / 2 + location.x * scale, location.y * scale)
    }
}
