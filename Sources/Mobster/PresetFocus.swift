/// The corner of the design rectangle a spiral converges toward. Selecting one mirrors the stored geometry across an axis, which is an orientation and never a scale.
public enum PresetFocus: Hashable, Sendable {
    case minXMinY
    case maxXMinY
    case minXMaxY
    case maxXMaxY
}
