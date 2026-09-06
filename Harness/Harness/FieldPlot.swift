import Mobster

/// The grayscale of a baked field and the time the bake itself took, which is the cost the settle epsilon buys.
struct FieldPlot {
    /// The tokens resolve against this, so it is held rather than discarded once the grayscale has been taken from it.
    let field: Field
    /// Nil for a field holding no path location, which vends no grayscale.
    let raster: FieldRaster?
    /// What the bake refused, held so the harness can say so: an empty canvas cannot be told apart from a field nothing is drawn against.
    let refusal: FieldRefusal?
    let duration: Duration

    init(paths: [[SIMD2<Float>]], frame: Frame, settleEpsilon: Float, budget: Int) {
        var baked = Field(frame: frame, columns: 0, rows: 0, locations: [])
        var refused: FieldRefusal?
        let elapsed = ContinuousClock().measure {
            do throws(FieldRefusal) {
                baked = try FieldBake(paths: paths, frame: frame, settleEpsilon: settleEpsilon, budget: budget).field()
            } catch {
                refused = error
            }
        }
        field = baked
        raster = baked.grayscale()
        refusal = refused
        duration = elapsed
    }
}
