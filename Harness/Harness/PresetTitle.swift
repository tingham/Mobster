import Mobster

/// Display text for a guide type. The package names the guide types and vends no language, so the words are the harness's.
func presetTitle(_ kind: PresetKind) -> String {
    switch kind {
    case .goldenRatio: "Golden Ratio"
    case .thirds: "Thirds"
    case .columns: "Columns"
    case .rows: "Rows"
    case .grid: "Grid"
    case .ruler: "Ruler"
    case .curve: "Curve"
    case .head: "Head"
    case .figure: "Figure"
    case .cube: "Cube"
    }
}
