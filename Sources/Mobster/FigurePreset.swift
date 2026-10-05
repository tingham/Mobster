/// A human figure built as construction solids and extracted from a projection of them. The masses are emitted first, head then ribcage then pelvis, then the limbs: left arm, right arm, left leg, right leg, and last the two hands and the two feet. A limb carries four identities and a mass carries two, the division of each being where its cross section reads.
public struct FigurePreset: Hashable, Sendable {
    private static let headIdentity: UInt32 = 1
    private static let ribcageIdentity: UInt32 = 3
    private static let pelvisIdentity: UInt32 = 5
    private static let limbIdentity: UInt32 = 6
    private static let handIdentity: UInt32 = 22
    private static let footIdentity: UInt32 = 24
    /// The level of the figure the view turns about, so a target off level tips the figure about its own middle rather than about its crown.
    private static let pivotLevel: Float = 0.5

    public let sex: FigureSex
    /// A height outside the tabled four through eight is plotted at the nearest tabled height, there being no canon beyond them.
    public let heads: Float
    /// The location the whole figure is turned toward, measured from its middle: x across, y downward, z out of the chest. One target orbits the construction; the pose is not turned with it.
    public let target: SIMD3<Float>
    /// Radians about forward. It turns the figure as constructed, the pose having been solved against its targets before the view carries any of it.
    public let roll: Float
    /// The location the head points at, measured from the centre of the cranial mass in head heights: x across, y downward, z out of the face. It turns the head within the figure where the figure's own target turns everything.
    public let headTarget: SIMD3<Float>
    /// Design space, where zero to one spans the design rectangle. Left is the lesser x of it.
    public let leftHand: SIMD2<Float>
    public let rightHand: SIMD2<Float>
    public let leftFoot: SIMD2<Float>
    public let rightFoot: SIMD2<Float>
    public let headLines: Bool

    public init(sex: FigureSex,
                heads: Float,
                target: SIMD3<Float>,
                roll: Float,
                headTarget: SIMD3<Float>,
                leftHand: SIMD2<Float>,
                rightHand: SIMD2<Float>,
                leftFoot: SIMD2<Float>,
                rightFoot: SIMD2<Float>,
                headLines: Bool) {
        self.sex = sex
        self.heads = heads
        self.target = target
        self.roll = roll
        self.headTarget = headTarget
        self.leftHand = leftHand
        self.rightHand = rightHand
        self.leftFoot = leftFoot
        self.rightFoot = rightFoot
        self.headLines = headLines
    }

    public func mesh(in frame: Frame) -> Mesh {
        let figure = Figure(heads: heads, sex: sex)
        let pelvis = figure.pelvis
        let placement = Self.placement(figure, target: target, roll: roll, frame: frame)
        let head = figure.head.bands(upper: MeshIdentity(Self.headIdentity), lower: MeshIdentity(Self.headIdentity + 1))
        let facing = Self.facing(figure.head, target: headTarget)
        var bands = figure.ribcage.bands(upper: MeshIdentity(Self.ribcageIdentity), lower: MeshIdentity(Self.ribcageIdentity + 1))
        bands += pelvis.bands(identity: MeshIdentity(Self.pelvisIdentity))
        let arms = [figure.arm(root: figure.leftShoulder, target: leftHand), figure.arm(root: figure.rightShoulder, target: rightHand)]
        let legs = [figure.leg(root: pelvis.leftCorner, target: leftFoot), figure.leg(root: pelvis.rightCorner, target: rightFoot)]
        bands += arms.indices.flatMap { arms[$0].bands(from: Self.limbIdentity + FigureLimb.identities * UInt32($0)) }
        bands += legs.indices.flatMap { legs[$0].bands(from: Self.limbIdentity + FigureLimb.identities * UInt32($0 + 2)) }
        bands += arms.indices.flatMap { figure.hand(arms[$0]).bands(identity: MeshIdentity(Self.handIdentity + UInt32($0))) }
        bands += legs.indices.flatMap { figure.foot(legs[$0]).bands(identity: MeshIdentity(Self.footIdentity + UInt32($0))) }

        return Mesh(triangles: head.flatMap { band in band.triangles { placement.location(facing($0)) } }
            + bands.flatMap { $0.triangles(placement.location) })
    }

    /// Where a pose target stands in the Frame, carried through the placement the limb it poses is carried through, so a mark laid down for it stands on the hand or the foot however the figure is turned.
    public func poseLocation(of target: SIMD2<Float>, in frame: Frame) -> SIMD2<Float> {
        let figure = Figure(heads: heads, sex: sex)
        let carried = Self.placement(figure, target: self.target, roll: roll, frame: frame).location(SIMD3<Float>(target.x, target.y, 0))

        return SIMD2<Float>(carried.x, carried.y)
    }

    /// The pose target a location in the Frame stands for, and nil where the view has turned the plane the targets stand on edge on, a location on the preview then standing for every target along the axis that vanished.
    public func poseTarget(at location: SIMD2<Float>, in frame: Frame) -> SIMD2<Float>? {
        let figure = Figure(heads: heads, sex: sex)

        return Self.placement(figure, target: target, roll: roll, frame: frame).plane(location)
    }

    /// The head's own turn, taken about the centre of the cranial mass so the mass turns in place before the figure's view carries the whole construction.
    private static func facing(_ head: FigureEllipse, target: SIMD3<Float>) -> (SIMD3<Float>) -> SIMD3<Float> {
        let space = SpaceProjection(basis: SpaceBasis(target: target, roll: 0))
        let centre = SIMD3<Float>(head.center.x, head.center.y, 0)

        return { location in centre + space.turned(location - centre) }
    }

    /// Half width lines to either side of the figure at each head break. They measure the figure rather than belonging to it, so nothing turns them and they are paths rather than solids.
    public func breakLines(in frame: Frame) -> [Line] {
        guard headLines else { return [] }

        let figure = Figure(heads: heads, sex: sex)
        let placement = Self.placement(figure, target: target, roll: roll, frame: frame)

        return figure.breakLines.map { line in
            Line(verts: line.map { Vert(location: placement.flat($0)) }, role: .construction)
        }
    }

    private static func placement(_ figure: Figure, target: SIMD3<Float>, roll: Float, frame: Frame) -> MeshPlacement {
        MeshPlacement(target: target,
                      roll: roll,
                      origin: SIMD2<Float>(figure.center, pivotLevel),
                      pivot: SIMD2<Float>(figure.center, pivotLevel),
                      unit: 1,
                      frame: frame)
    }
}
