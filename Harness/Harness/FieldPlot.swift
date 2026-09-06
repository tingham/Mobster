import Mobster

/// The grayscale of a baked field and the time the bake itself took, which is the cost the settle epsilon buys.
struct FieldPlot {
    /// The tokens resolve against this, so it is held rather than discarded once the grayscale has been taken from it.
    let field: Field
    /// Nil for a field holding no path location, which vends no grayscale.
    let raster: FieldRaster?
    let duration: Duration

    init(paths: [[SIMD2<Float>]], frame: Frame, settleEpsilon: Float, budget: Int) {
        var baked = Field(frame: frame, columns: 0, rows: 0, locations: [])
        let elapsed = ContinuousClock().measure {
            // A refused bake stands as the empty field, which the canvas already draws as nothing, rather than as the stall the refusal exists to prevent.
            baked = (try? FieldBake(paths: paths, frame: frame, settleEpsilon: settleEpsilon, budget: budget).field()) ?? baked
        }
        field = baked
        raster = baked.grayscale()
        duration = elapsed
    }
}
