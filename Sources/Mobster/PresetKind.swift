/// The guide types a consumer offers a person to choose from. No display text is carried, because a package that vends a title vends a language.
public enum PresetKind: CaseIterable, Hashable, Sendable {
    case goldenRatio
    case thirds
    case columns
    case rows
    case grid
    case ruler
    case curve
    case head
    case figure
    case cube
}
