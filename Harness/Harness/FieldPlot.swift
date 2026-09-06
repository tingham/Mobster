import Mobster

/// The grayscale the Guide vends of its field and the time the bake took, which is the cost the resolution dial buys.
struct FieldPlot {
    /// Nil for a field holding no path location, which vends no grayscale.
    let raster: FieldRaster?
    let duration: Duration

    static let idle = FieldPlot(raster: nil, duration: .zero)
}
