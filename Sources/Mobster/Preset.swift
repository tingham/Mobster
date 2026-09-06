/// A source that plots its own paths against the Frame a Guide operates within.
public protocol Preset: Sendable {
    func paths(in frame: Frame) -> [[SIMD2<Float>]]
}
