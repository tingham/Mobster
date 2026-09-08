/// What a Guide takes its lines from and bakes its field from.
public enum GuideSource: Sendable {
    case lines([Line])
    case preset(any Preset)
}
