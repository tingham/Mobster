/// A canon row resolved into the forms and the chains of one figure, laid down the unit design square with the top of the head at zero and the soles at one.
struct Figure {
    /// Two thirds as wide as it is tall, measured across the plates.
    private static let headWidth: Float = 0.667
    /// Glabella to opisthocranion over vertex to gnathion, which is Farkas's North American adult male mean of 195 over 232. No Loomis plate carries a depth; his female mean of 184 over 218 differs by four thousandths and the plates give one head whatever the sex.
    private static let headDepth: Float = 0.840
    /// Fractions of the figure's width, which is a measure across the shoulders. The woman's plate prints a head and a half of hip and the man is given the same across his wider figure; the chest clears his one head of nipple span and stays inside her thighs.
    private static let ribcageWidth: Float = 0.65
    private static let malePelvisWidth: Float = 0.643
    private static let femalePelvisWidth: Float = 0.75
    /// The wedge taper and the limb girths are form rather than proportion, no canon carrying them, and the girths are in head units.
    private static let pelvisTaper: Float = 0.6
    private static let shoulderGirth: Float = 0.34
    private static let elbowGirth: Float = 0.26
    private static let wristGirth: Float = 0.16
    private static let hipGirth: Float = 0.46
    private static let kneeGirth: Float = 0.30
    private static let ankleGirth: Float = 0.16

    let canon: FigureCanon
    let sex: FigureSex

    init(heads: Float, sex: FigureSex) {
        canon = FigureProportion.canon(heads: heads, sex: sex)
        self.sex = sex
    }

    var headUnit: Float {
        1 / canon.heads
    }

    var center: Float {
        0.5
    }

    var figureWidth: Float {
        canon.width * headUnit
    }

    var head: FigureEllipse {
        FigureEllipse(center: SIMD2<Float>(center, canon.chin / 2),
                      radii: SIMD3<Float>(Self.headWidth * headUnit / 2, canon.chin / 2, Self.headDepth * headUnit / 2))
    }

    /// The depth follows the width, no canon carrying a torso depth and a form read as circular in section needing no new number, which is the licence the limbs take.
    var ribcage: FigureEllipse {
        let width = Self.ribcageWidth * figureWidth

        return FigureEllipse(center: SIMD2<Float>(center, (canon.shoulder + canon.waist) / 2),
                             radii: SIMD3<Float>(width / 2, (canon.waist - canon.shoulder) / 2, width / 2))
    }

    /// The depth follows the width at each level for the reason the ribcage's does.
    var pelvis: FigureWedge {
        let width = (sex == .male ? Self.malePelvisWidth : Self.femalePelvisWidth) * figureWidth

        return FigureWedge(center: center,
                           top: canon.waist,
                           bottom: canon.crotch,
                           topWidth: width,
                           bottomWidth: width * Self.pelvisTaper,
                           topDepth: width,
                           bottomDepth: width * Self.pelvisTaper)
    }

    /// Set in from the figure's width by the arm's own half girth, so the shoulder form ends on the width rather than beyond it.
    private var shoulderReach: Float {
        figureWidth / 2 - Self.shoulderGirth * headUnit / 2
    }

    var leftShoulder: SIMD2<Float> {
        SIMD2<Float>(center - shoulderReach, canon.shoulder)
    }

    var rightShoulder: SIMD2<Float> {
        SIMD2<Float>(center + shoulderReach, canon.shoulder)
    }

    var upperArm: Float {
        canon.elbow - canon.shoulder
    }

    var forearm: Float {
        canon.wrist - canon.elbow
    }

    var thigh: Float {
        canon.knee - canon.crotch
    }

    var shin: Float {
        1 - canon.knee
    }

    /// Which way a joint turns out of the line to its target. The figure's own plane carries no forward, so the anatomical bend reads as the turn away from the middle and the side a limb hangs from is what decides it.
    private func bend(_ root: SIMD2<Float>) -> SIMD2<Float> {
        SIMD2<Float>(root.x < center ? -1 : 1, 0)
    }

    func arm(root: SIMD2<Float>, target: SIMD2<Float>) -> FigureLimb {
        FigureLimb(root: root,
                   target: target,
                   pole: bend(root),
                   upperLength: upperArm,
                   lowerLength: forearm,
                   rootWidth: Self.shoulderGirth * headUnit,
                   jointWidth: Self.elbowGirth * headUnit,
                   endWidth: Self.wristGirth * headUnit)
    }

    func leg(root: SIMD2<Float>, target: SIMD2<Float>) -> FigureLimb {
        FigureLimb(root: root,
                   target: target,
                   pole: bend(root),
                   upperLength: thigh,
                   lowerLength: shin,
                   rootWidth: Self.hipGirth * headUnit,
                   jointWidth: Self.kneeGirth * headUnit,
                   endWidth: Self.ankleGirth * headUnit)
    }

    /// A partial head at the soles has no break of its own, so the last break is the last whole head.
    var breakLines: [[SIMD2<Float>]] {
        let breaks = Int(canon.heads)
        let half = figureWidth / 2

        return (0 ... breaks).flatMap { index -> [[SIMD2<Float>]] in
            let level = Float(index) * headUnit
            return [[SIMD2<Float>(center - half - half, level), SIMD2<Float>(center - half, level)],
                    [SIMD2<Float>(center + half, level), SIMD2<Float>(center + half + half, level)]]
        }
    }
}
