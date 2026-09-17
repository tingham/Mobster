/// A named set of the four targets a figure is posed by. A figure opening in a T pose is one the user has to build before they can begin, so a pose is somewhere to start and nudge from. Nothing interpolates between two of them: the limbs walked from standing to seated pass through the torso on the way.
public struct FigurePose: Hashable, Sendable {
    public let name: String
    /// Design space, where zero to one spans the design rectangle. Left is the lesser x of it.
    public let leftHand: SIMD2<Float>
    public let rightHand: SIMD2<Float>
    public let leftFoot: SIMD2<Float>
    public let rightFoot: SIMD2<Float>

    public init(name: String, leftHand: SIMD2<Float>, rightHand: SIMD2<Float>, leftFoot: SIMD2<Float>, rightFoot: SIMD2<Float>) {
        self.name = name
        self.leftHand = leftHand
        self.rightHand = rightHand
        self.leftFoot = leftFoot
        self.rightFoot = rightFoot
    }

    /// The poses on offer, held as data so that adding one is a line rather than a case.
    public static let named: [FigurePose] = [
        FigurePose(name: "Standing",
                   leftHand: SIMD2<Float>(0.31, 0.5),
                   rightHand: SIMD2<Float>(0.69, 0.5),
                   leftFoot: SIMD2<Float>(0.42, 1),
                   rightFoot: SIMD2<Float>(0.58, 1)),
        FigurePose(name: "Contrapposto",
                   leftHand: SIMD2<Float>(0.29, 0.53),
                   rightHand: SIMD2<Float>(0.66, 0.47),
                   leftFoot: SIMD2<Float>(0.47, 1),
                   rightFoot: SIMD2<Float>(0.63, 0.97)),
        FigurePose(name: "Seated",
                   leftHand: SIMD2<Float>(0.33, 0.62),
                   rightHand: SIMD2<Float>(0.67, 0.62),
                   leftFoot: SIMD2<Float>(0.4, 0.78),
                   rightFoot: SIMD2<Float>(0.6, 0.78)),
        FigurePose(name: "Reach",
                   leftHand: SIMD2<Float>(0.22, 0.08),
                   rightHand: SIMD2<Float>(0.78, 0.08),
                   leftFoot: SIMD2<Float>(0.42, 1),
                   rightFoot: SIMD2<Float>(0.58, 1)),
        FigurePose(name: "Wave",
                   leftHand: SIMD2<Float>(0.22, 0.08),
                   rightHand: SIMD2<Float>(0.68, 0.48),
                   leftFoot: SIMD2<Float>(0.44, 1),
                   rightFoot: SIMD2<Float>(0.58, 1)),
    ]
}
