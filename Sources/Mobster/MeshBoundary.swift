/// The boundaries of an identity raster, which run wherever fragments of a neighbourhood carry different identities. A fragment covering no component carries the background, so where a component meets nothing is a boundary as much as where two components meet.
struct MeshBoundary {
    /// Fragments to a side of the neighbourhood a boundary is resolved from.
    static let neighbourhood = 2

    let raster: MeshIdentityRaster

    /// One seam a pair of identities, ordered by that pair. A neighbourhood carrying a pair resolves to the one location at its middle, so a graze that wanders between the fragments of a neighbourhood as the view turns is the same boundary throughout.
    func seams() -> [MeshSeam] {
        var gathered: [SIMD2<UInt32>: [SIMD2<Float>]] = [:]

        for row in 0 ..< max(raster.rows - Self.neighbourhood + 1, 1) {
            for column in 0 ..< max(raster.columns - Self.neighbourhood + 1, 1) {
                // A raster narrower than the neighbourhood is read at the fragments it has rather than off its edge.
                let across = min(column + Self.neighbourhood - 1, raster.columns - 1)
                let down = min(row + Self.neighbourhood - 1, raster.rows - 1)
                let corners = [raster.identity(column: column, row: row),
                               raster.identity(column: across, row: row),
                               raster.identity(column: column, row: down),
                               raster.identity(column: across, row: down)]
                let middle = SIMD2<Float>(Float(column + across) / 2 + 0.5, Float(row + down) / 2 + 0.5)

                for pair in Self.pairs(corners) { gathered[pair, default: []].append(middle) }
            }
        }

        return gathered.keys.sorted { $0.x != $1.x ? $0.x < $1.x : $0.y < $1.y }.map { pair in
            MeshSeam(identities: pair, locations: MeshTrace(locations: gathered[pair] ?? []).ordered())
        }
    }

    /// The pairs the neighbourhood holds along its sides, lesser first. Fragments meeting only at a corner are left out: four forms meeting at one location carry two boundaries and not the four a corner would add.
    private static func pairs(_ corners: [UInt32]) -> Set<SIMD2<UInt32>> {
        var found: Set<SIMD2<UInt32>> = []

        for (first, second) in [(0, 1), (2, 3), (0, 2), (1, 3)] where corners[first] != corners[second] {
            found.insert(SIMD2<UInt32>(min(corners[first], corners[second]), max(corners[first], corners[second])))
        }

        return found
    }
}
