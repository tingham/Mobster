/// A human figure plotted as construction forms against the Frame.
public struct AshcanPreset: Hashable, Preset {
    private static let designSize = SIMD2<Float>(1, 1)
    private static let segments = 48

    public let sex: AshcanSex
    /// A height outside the tabled four through eight is plotted at the nearest tabled height, there being no canon beyond them.
    public let heads: Float
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

    public func paths(in frame: Frame) -> [[SIMD2<Float>]] {
        let projection = PresetProjection(mode: .contain, frame: frame, designSize: Self.designSize)
        let figure = AshcanFigure(heads: heads, sex: sex)
        let pelvis = figure.pelvis

        var design = [figure.head.path(segments: Self.segments),
                      figure.ribcage.path(segments: Self.segments),
                      pelvis.path]

        design += figure.arm(root: figure.leftShoulder, target: leftHand, pole: leftElbowPole).paths
        design += figure.arm(root: figure.rightShoulder, target: rightHand, pole: rightElbowPole).paths
        design += figure.leg(root: pelvis.leftCorner, target: leftFoot, pole: leftKneePole).paths
        design += figure.leg(root: pelvis.rightCorner, target: rightFoot, pole: rightKneePole).paths

        if headLines {
            design += figure.breakLines
        }

        return projection.paths(design)
    }
}
