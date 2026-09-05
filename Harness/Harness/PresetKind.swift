/// The presets the harness can plot.
enum PresetKind: String, CaseIterable, Identifiable, Hashable, Sendable {
    case goldenRatio
    case thirds
    case columns
    case rows
    case ruler
    case curve

    var id: String { rawValue }

    var title: String {
        switch self {
        case .goldenRatio: "Golden Ratio"
        case .thirds: "Thirds"
        case .columns: "Columns"
        case .rows: "Rows"
        case .ruler: "Ruler"
        case .curve: "Curve"
        }
    }
}
