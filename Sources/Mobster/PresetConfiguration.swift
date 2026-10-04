/// A guide type's parameters paired with the production context its plotting needs. Constructing one names the guide type, and nothing in that construction says whether its paths are plotted analytically or extracted from a mesh.
public protocol PresetConfiguration: Sendable {
    /// A production that cannot complete refuses and says why, which only an extraction can do: an analytic call site carries a `try` it will never take.
    func lines(in frame: Frame) throws(MeshRefusal) -> [Line]
}
