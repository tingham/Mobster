/// One row of a published proportion table. Each landmark is a fraction of the figure's height measured down from the top of the head, and the width is the figure's widest measure in head units.
struct FigureCanon {
    let heads: Float
    let chin: Float
    let shoulder: Float
    let nipple: Float
    let elbow: Float
    let wrist: Float
    let crotch: Float
    let knee: Float
    let width: Float

    /// No waist is marked on the child plates, and the midpoint of the nipple and the crotch lands within a hundredth of the navel on both adult plates.
    var waist: Float {
        (nipple + crotch) / 2
    }

    static func blended(_ lower: FigureCanon, _ upper: FigureCanon, _ travel: Float) -> FigureCanon {
        FigureCanon(heads: mix(lower.heads, upper.heads, travel),
                    chin: mix(lower.chin, upper.chin, travel),
                    shoulder: mix(lower.shoulder, upper.shoulder, travel),
                    nipple: mix(lower.nipple, upper.nipple, travel),
                    elbow: mix(lower.elbow, upper.elbow, travel),
                    wrist: mix(lower.wrist, upper.wrist, travel),
                    crotch: mix(lower.crotch, upper.crotch, travel),
                    knee: mix(lower.knee, upper.knee, travel),
                    width: mix(lower.width, upper.width, travel))
    }

    private static func mix(_ lower: Float, _ upper: Float, _ travel: Float) -> Float {
        lower + (upper - lower) * travel
    }
}
