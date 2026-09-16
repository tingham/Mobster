/// The fragment lattice the Frame demands of the identity target. It decides the fidelity of every path extracted, the way the field's texel size does.
struct MeshResolution: Sendable {
    /// The largest two dimensional target the platform permits on either axis. A descriptor past it is trapped rather than refused, so the lattice is held inside it rather than handed over.
    static let ceiling = 16384

    let columns: Int
    let rows: Int

    /// A fragment to the scene unit, which is the Frame read at its own grain. A boundary is traced at one sample a fragment and fitted lossily afterward, so what this buys is the shape of a trace rather than the precision of one. A Frame outrunning the ceiling scales both axes alike, an anisotropic lattice reading one direction finer than the other.
    init(frame: Frame) {
        guard frame.size.x > 0, frame.size.y > 0 else {
            columns = 0
            rows = 0
            return
        }

        let held = min(1, Float(Self.ceiling) / max(frame.size.x, frame.size.y))
        columns = max(1, Int((frame.size.x * held).rounded()))
        rows = max(1, Int((frame.size.y * held).rounded()))
    }

    var fragments: Int {
        columns * rows
    }
}
