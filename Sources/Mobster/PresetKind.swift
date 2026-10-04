/// The guide types a consumer offers a person to choose from. No display text is carried, because a package that vends a title vends a language.
public enum PresetKind: String, CaseIterable, Hashable, Sendable {
    /// The keys are written out rather than taken from the case names, so renaming a case cannot change what a stored choice resolves to.
    case goldenRatio = "goldenRatio"
    case thirds = "thirds"
    case columns = "columns"
    case rows = "rows"
    case grid = "grid"
    case ruler = "ruler"
    case curve = "curve"
    case head = "head"
    case figure = "figure"
    case cube = "cube"
}
