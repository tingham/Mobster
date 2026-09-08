import Mobster

/// The grayscale the Guide vends of its field and the time the bake took, which is the cost the settle epsilon buys.
struct FieldPlot {
    /// Nil for a field holding no path location, which vends no grayscale.
    let raster: FieldRaster?
    /// What the bake refused, held so the harness can say so: an empty canvas cannot be told apart from a field nothing is drawn against.
    let refusal: FieldRefusal?
    let duration: Duration

    static let idle = FieldPlot(raster: nil, refusal: nil, duration: .zero)
}
