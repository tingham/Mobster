/// The canon rows a figure's proportions are read from, and the blend between the two rows a requested height falls between. Heights are Loomis, Figure Drawing for All It's Worth, 1943: the adult rows from the ideal proportion plates on pages 26 and 27, the shorter rows from the ideal proportions at various ages plate on page 29, where four heads is one year, five is three years, six is five years, seven is ten years and seven and a half is fifteen.
struct FigureProportion {
    /// Outside the tabled heights there is no canon to follow, so the nearest tabled height answers instead.
    static func canon(heads: Float, sex: FigureSex) -> FigureCanon {
        let table = table(for: sex)

        guard let upper = table.firstIndex(where: { $0.heads >= heads }) else { return table[table.count - 1] }
        guard upper > 0 else { return table[0] }

        let below = table[upper - 1]
        let above = table[upper]
        let span = above.heads - below.heads

        return FigureCanon.blended(below, above, span > 0 ? (heads - below.heads) / span : 0)
    }

    private static func table(for sex: FigureSex) -> [FigureCanon] {
        switch sex {
        case .male: male
        case .female: female
        }
    }

    /// The page 29 plate is a boy's, so the four to seven head rows are read from it and the seven and a half row from its fifteen year figure against the normal standard on page 28.
    private static let male: [FigureCanon] = [
        FigureCanon(heads: 4, chin: 0.250, shoulder: 0.325, nipple: 0.400, elbow: 0.530, wrist: 0.663, crotch: 0.713, knee: 0.825, width: 1.60),
        FigureCanon(heads: 5, chin: 0.200, shoulder: 0.260, nipple: 0.326, elbow: 0.450, wrist: 0.574, crotch: 0.580, knee: 0.766, width: 1.90),
        FigureCanon(heads: 6, chin: 0.167, shoulder: 0.217, nipple: 0.317, elbow: 0.437, wrist: 0.558, crotch: 0.583, knee: 0.767, width: 1.90),
        FigureCanon(heads: 7, chin: 0.143, shoulder: 0.186, nipple: 0.286, elbow: 0.429, wrist: 0.576, crotch: 0.543, knee: 0.736, width: 1.90),
        FigureCanon(heads: 7.5, chin: 0.133, shoulder: 0.178, nipple: 0.267, elbow: 0.400, wrist: 0.540, crotch: 0.540, knee: 0.750, width: 2.00),
        FigureCanon(heads: 8, chin: 0.125, shoulder: 0.167, nipple: 0.250, elbow: 0.375, wrist: 0.500, crotch: 0.500, knee: 0.750, width: 2.333),
    ]

    /// Loomis publishes no shorter female figure, so the shorter rows are the ones the page 29 plate gives and only the adult row is the page 27 woman.
    private static let female: [FigureCanon] = [
        FigureCanon(heads: 4, chin: 0.250, shoulder: 0.325, nipple: 0.400, elbow: 0.530, wrist: 0.663, crotch: 0.713, knee: 0.825, width: 1.60),
        FigureCanon(heads: 5, chin: 0.200, shoulder: 0.260, nipple: 0.326, elbow: 0.450, wrist: 0.574, crotch: 0.580, knee: 0.766, width: 1.90),
        FigureCanon(heads: 6, chin: 0.167, shoulder: 0.217, nipple: 0.317, elbow: 0.437, wrist: 0.558, crotch: 0.583, knee: 0.767, width: 1.90),
        FigureCanon(heads: 7, chin: 0.143, shoulder: 0.186, nipple: 0.286, elbow: 0.429, wrist: 0.576, crotch: 0.543, knee: 0.736, width: 1.90),
        FigureCanon(heads: 8, chin: 0.125, shoulder: 0.167, nipple: 0.271, elbow: 0.375, wrist: 0.542, crotch: 0.542, knee: 0.750, width: 2.00),
    ]
}
