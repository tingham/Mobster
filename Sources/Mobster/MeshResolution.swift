/// The fragment lattice the Frame demands of the identity target. It decides the fidelity of every path extracted, the way the field's texel size does.
struct MeshResolution: Sendable {
    /// Fragments across the wider axis of the Frame. A boundary is traced at one sample a fragment and fitted lossily afterward, so what this buys is the shape of a trace rather than the precision of one.
    static let count = 512

    let columns: Int
    let rows: Int

    init(frame: Frame) {
        guard frame.size.x > 0, frame.size.y > 0 else {
            columns = 0
            rows = 0
            return
        }

        let span = max(frame.size.x, frame.size.y)
        columns = max(1, Int((frame.size.x / span * Float(Self.count)).rounded()))
        rows = max(1, Int((frame.size.y / span * Float(Self.count)).rounded()))
    }

    var fragments: Int {
        columns * rows
    }
}
