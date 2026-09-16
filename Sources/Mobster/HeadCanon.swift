/// Adult head and neck norms in millimetres, from which every proportion of the construction is taken. The landmark names are Farkas's and the measurements are his North American adult means; the neck is the standard anthropometric neck circumference.
struct HeadCanon: Sendable {
    /// Vertex to gnathion.
    let headHeight: Float
    /// Euryon to euryon, the widest breadth of the skull.
    let headBreadth: Float
    /// Glabella to opisthocranion.
    let headLength: Float
    /// Nasion to gnathion.
    let faceHeight: Float
    /// Subnasale to gnathion.
    let lowerFaceHeight: Float
    /// Frontotemporale to frontotemporale, which is the breadth of the temple flat.
    let foreheadBreadth: Float
    /// Gonion to gonion, the breadth across the jaw angles.
    let bigonialBreadth: Float
    /// Cheilion to cheilion.
    let mouthBreadth: Float
    /// Sublabiale to gnathion.
    let chinHeight: Float
    let neckCircumference: Float

    static let male = HeadCanon(headHeight: 232,
                                headBreadth: 151,
                                headLength: 195,
                                faceHeight: 123,
                                lowerFaceHeight: 72,
                                foreheadBreadth: 111,
                                bigonialBreadth: 106,
                                mouthBreadth: 53,
                                chinHeight: 44,
                                neckCircumference: 380)

    static let female = HeadCanon(headHeight: 218,
                                  headBreadth: 144,
                                  headLength: 184,
                                  faceHeight: 112,
                                  lowerFaceHeight: 65,
                                  foreheadBreadth: 106,
                                  bigonialBreadth: 98,
                                  mouthBreadth: 50,
                                  chinHeight: 40,
                                  neckCircumference: 325)

    /// The eight head figure canon puts the pit of the neck a quarter head below the chin, which is where the plotted portion of the neck stops.
    static let shoulderDrop: Float = 0.25

    init(sex: HeadSex) {
        switch sex {
        case .male: self = .male
        case .female: self = .female
        }
    }

    private init(headHeight: Float,
                 headBreadth: Float,
                 headLength: Float,
                 faceHeight: Float,
                 lowerFaceHeight: Float,
                 foreheadBreadth: Float,
                 bigonialBreadth: Float,
                 mouthBreadth: Float,
                 chinHeight: Float,
                 neckCircumference: Float) {
        self.headHeight = headHeight
        self.headBreadth = headBreadth
        self.headLength = headLength
        self.faceHeight = faceHeight
        self.lowerFaceHeight = lowerFaceHeight
        self.foreheadBreadth = foreheadBreadth
        self.bigonialBreadth = bigonialBreadth
        self.mouthBreadth = mouthBreadth
        self.chinHeight = chinHeight
        self.neckCircumference = neckCircumference
    }

    // Every level and every extent below is a fraction of the head height, a level being measured from the vertex downward.

    /// Vertex to nasion, which is where the brow line sits and so also the vertical semi axis of a cranial mass carrying the brow line as its equator.
    var browLevel: Float { (headHeight - faceHeight) / headHeight }

    var halfWidth: Float { headBreadth / 2 / headHeight }

    var halfDepth: Float { headLength / 2 / headHeight }

    /// The side planes cut the cranial mass at the breadth of the temple flat, which is close to the two thirds of the radius Loomis cuts his ball at.
    var sidePlaneOffset: Float { foreheadBreadth / 2 / headHeight }

    /// Gnathion, which normalizing by the head height puts at one.
    var chinLevel: Float { 1 }

    var jawHalfWidth: Float { bigonialBreadth / 2 / headHeight }

    /// The jaw angle sits level with the mouth, which the equal thirds of the lower face put one third of the way from subnasale down to gnathion.
    var jawLevel: Float { chinLevel - lowerFaceHeight / headHeight * 2 / 3 }

    /// The chin block is taken as wide as the mouth, there being no tabulated breadth for the bony chin itself.
    var chinHalfWidth: Float { mouthBreadth / 2 / headHeight }

    var chinFaceHeight: Float { chinHeight / headHeight }

    /// The neck is read as a circular section, so its breadth follows from its circumference alone.
    var neckRadius: Float { neckCircumference / (2 * Float.pi) / headHeight }

    var neckLevel: Float { chinLevel + Self.shoulderDrop }
}
