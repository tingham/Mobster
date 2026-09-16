/// A human figure built as construction solids and extracted from a projection of them. The masses are emitted first, head then ribcage then pelvis, and then the limbs: left arm, right arm, left leg, right leg. A limb carries four identities and a mass carries two, the division of each being where its cross section reads.
public struct AshcanPreset: Hashable, Sendable {
    private static let headIdentity: UInt32 = 1
    private static let ribcageIdentity: UInt32 = 3
    private static let pelvisIdentity: UInt32 = 5
    private static let limbIdentity: UInt32 = 6
    /// The level of the figure the view turns about, so a target off level tips the figure about its own middle rather than about its crown.
    private static let pivotLevel: Float = 0.5

    public let sex: AshcanSex
    /// A height outside the tabled four through eight is plotted at the nearest tabled height, there being no canon beyond them.
    public let heads: Float
    /// The location the whole figure is turned toward, measured from its middle: x across, y downward, z out of the chest. One target orbits the construction; the pose is not turned with it.
    public let target: SIMD3<Float>
    /// Design space, where zero to one spans the design rectangle. Left is the lesser x of it.
    public let leftHand: SIMD2<Float>
    public let rightHand: SIMD2<Float>
    public let leftFoot: SIMD2<Float>
    public let rightFoot: SIMD2<Float>
    /// Design space directions. Each says which way its elbow or knee turns out of the line between the joint it hangs from and its target.
    public let leftElbowPole: SIMD2<Float>
    public let rightElbowPole: SIMD2<Float>
    public let leftKneePole: SIMD2<Float>
    public let rightKneePole: SIMD2<Float>
    public let headLines: Bool

    public init(sex: AshcanSex,
                heads: Float,
                target: SIMD3<Float>,
                leftHand: SIMD2<Float>,
                rightHand: SIMD2<Float>,
                leftFoot: SIMD2<Float>,
                rightFoot: SIMD2<Float>,
                leftElbowPole: SIMD2<Float>,
                rightElbowPole: SIMD2<Float>,
                leftKneePole: SIMD2<Float>,
                rightKneePole: SIMD2<Float>,
                headLines: Bool) {
        self.sex = sex
        self.heads = heads
        self.target = target
        self.leftHand = leftHand
        self.rightHand = rightHand
        self.leftFoot = leftFoot
        self.rightFoot = rightFoot
        self.leftElbowPole = leftElbowPole
        self.rightElbowPole = rightElbowPole
        self.leftKneePole = leftKneePole
        self.rightKneePole = rightKneePole
        self.headLines = headLines
    }

    public func mesh(in frame: Frame) -> Mesh {
        let figure = AshcanFigure(heads: heads, sex: sex)
        let pelvis = figure.pelvis
        let placement = Self.placement(figure, target: target, frame: frame)
        var bands = figure.head.bands(upper: MeshIdentity(Self.headIdentity), lower: MeshIdentity(Self.headIdentity + 1))
        bands += figure.ribcage.bands(upper: MeshIdentity(Self.ribcageIdentity), lower: MeshIdentity(Self.ribcageIdentity + 1))
        bands += pelvis.bands(identity: MeshIdentity(Self.pelvisIdentity))
        bands += figure.arm(root: figure.leftShoulder, target: leftHand, pole: leftElbowPole).bands(from: Self.limbIdentity)
        bands += figure.arm(root: figure.rightShoulder, target: rightHand, pole: rightElbowPole).bands(from: Self.limbIdentity + AshcanLimb.identities)
        bands += figure.leg(root: pelvis.leftCorner, target: leftFoot, pole: leftKneePole).bands(from: Self.limbIdentity + AshcanLimb.identities * 2)
        bands += figure.leg(root: pelvis.rightCorner, target: rightFoot, pole: rightKneePole).bands(from: Self.limbIdentity + AshcanLimb.identities * 3)

        return Mesh(triangles: bands.flatMap { $0.triangles(placement.location) })
    }

    /// Half width lines to either side of the figure at each head break. They measure the figure rather than belonging to it, so nothing turns them and they are paths rather than solids.
    public func breakLines(in frame: Frame) -> [[SIMD2<Float>]] {
        guard headLines else { return [] }

        let figure = AshcanFigure(heads: heads, sex: sex)
        let placement = Self.placement(figure, target: target, frame: frame)

        return figure.breakLines.map { line in line.map(placement.flat) }
    }

    private static func placement(_ figure: AshcanFigure, target: SIMD3<Float>, frame: Frame) -> MeshPlacement {
        MeshPlacement(target: target,
                      roll: 0,
                      origin: SIMD2<Float>(figure.center, pivotLevel),
                      pivot: SIMD2<Float>(figure.center, pivotLevel),
                      unit: 1,
                      frame: frame)
    }
}
