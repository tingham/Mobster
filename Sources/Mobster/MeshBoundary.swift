/// The boundaries of an identity raster, which run wherever adjacent fragments carry different identities. A fragment covering no component carries the background, so where a component meets nothing is a boundary as much as where two components meet.
struct MeshBoundary {
    let raster: MeshIdentityRaster

    /// One seam a pair of identities, ordered by that pair. A sample sits midway between the two fragments that differ, because that is where the boundary between them is.
    func seams() -> [MeshSeam] {
        var gathered: [SIMD2<UInt32>: [SIMD2<Float>]] = [:]

        for row in 0 ..< raster.rows {
            for column in 0 ..< raster.columns {
                let standing = raster.identity(column: column, row: row)

                if column + 1 < raster.columns {
                    let across = raster.identity(column: column + 1, row: row)
                    if across != standing {
                        gathered[Self.pair(standing, across), default: []].append(SIMD2<Float>(Float(column) + 1, Float(row) + 0.5))
                    }
                }

                if row + 1 < raster.rows {
                    let down = raster.identity(column: column, row: row + 1)
                    if down != standing {
                        gathered[Self.pair(standing, down), default: []].append(SIMD2<Float>(Float(column) + 0.5, Float(row) + 1))
                    }
                }
            }
        }

        return gathered.keys.sorted { $0.x != $1.x ? $0.x < $1.x : $0.y < $1.y }.map { pair in
            MeshSeam(identities: pair, locations: MeshTrace(locations: gathered[pair] ?? []).ordered())
        }
    }

    private static func pair(_ first: UInt32, _ second: UInt32) -> SIMD2<UInt32> {
        SIMD2<UInt32>(min(first, second), max(first, second))
    }
}
