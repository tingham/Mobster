import Mobster

/// The grayscale of a baked field and the time the bake itself took, which is the cost the resolution dial buys.
struct FieldPlot {
    /// The tokens resolve against this, so it is held rather than discarded once the grayscale has been taken from it.
    let field: Field
    /// Nil for a field holding no path location, which vends no grayscale.
    let raster: FieldRaster?
    let duration: Duration

    init(paths: [[SIMD2<Float>]], frame: Frame, resolution: Int) {
        var baked = Field(frame: frame, columns: 0, rows: 0, locations: [])
        let elapsed = ContinuousClock().measure {
            baked = FieldBake(paths: paths, frame: frame, resolution: resolution).field()
        }
        field = baked
        raster = baked.grayscale()
        duration = elapsed
    }
}
