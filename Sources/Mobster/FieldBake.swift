/// Bakes paths into a field. The propagation is the dead reckoning transform of Grevera 2004, carrying the nearest location rather than the nearest distance.
public struct FieldBake: Sendable {
    /// Scene coordinates, one entry per interpreted path.
    public let paths: [[SIMD2<Float>]]
    public let frame: Frame
    /// Texels across the wider axis of the Frame. The other axis takes the count that keeps a texel square.
    public let resolution: Int

    /// The neighbours already settled when a sweep reaches a texel, ascending then descending.
    private static let forwardMask = [(-1, -1), (0, -1), (1, -1), (-1, 0)]
    private static let backwardMask = [(1, 0), (-1, 1), (0, 1), (1, 1)]

    public init(paths: [[SIMD2<Float>]], frame: Frame, resolution: Int) {
        self.paths = paths
        self.frame = frame
        self.resolution = resolution
    }

    public func field() -> Field {
        let span = max(frame.size.x, frame.size.y)
        guard resolution > 0, span > 0 else {
            return Field(frame: frame, columns: 0, rows: 0, locations: [])
        }

        let columns = max(1, Int((frame.size.x / span * Float(resolution)).rounded()))
        let rows = max(1, Int((frame.size.y / span * Float(resolution)).rounded()))
        let texel = frame.size / SIMD2<Float>(Float(columns), Float(rows))
        let empty = Field(frame: frame, columns: columns, rows: rows, locations: [])

        var carried = [SIMD2<Float>?](repeating: nil, count: columns * rows)
        seed(&carried, columns: columns, rows: rows, texel: texel)
        guard carried.contains(where: { $0 != nil }) else { return empty }

        sweep(&carried, columns: columns, rows: rows, texel: texel)

        let locations = carried.compactMap { $0 }
        guard locations.count == carried.count else { return empty }

        return Field(frame: frame, columns: columns, rows: rows, locations: locations)
    }

    /// Every texel within reach of a segment takes the exact nearest location on it, which is the band the sweeps propagate outward.
    private func seed(_ carried: inout [SIMD2<Float>?], columns: Int, rows: Int, texel: SIMD2<Float>) {
        let reach = length(texel)
        let tolerance = reach * 1e-4

        for path in paths {
            for (start, end) in segments(of: path) {
                let low = SIMD2<Float>(min(start.x, end.x), min(start.y, end.y)) - reach
                let high = SIMD2<Float>(max(start.x, end.x), max(start.y, end.y)) + reach
                let firstColumn = index(low.x, origin: frame.origin.x, texel: texel.x, count: columns)
                let lastColumn = index(high.x, origin: frame.origin.x, texel: texel.x, count: columns)
                let firstRow = index(low.y, origin: frame.origin.y, texel: texel.y, count: rows)
                let lastRow = index(high.y, origin: frame.origin.y, texel: texel.y, count: rows)

                for row in firstRow ... lastRow {
                    for column in firstColumn ... lastColumn {
                        let center = center(column: column, row: row, texel: texel)
                        let candidate = nearest(on: start, end, to: center)
                        guard length(candidate - center) <= reach else { continue }

                        let slot = row * columns + column
                        guard let incumbent = carried[slot] else {
                            carried[slot] = candidate
                            continue
                        }
                        if prefers(candidate, over: incumbent, at: center, tolerance: tolerance) {
                            carried[slot] = candidate
                        }
                    }
                }
            }
        }
    }

    /// The chamfer bound of the original is dropped because it discards an equidistant candidate before the tie break can weigh it.
    private func sweep(_ carried: inout [SIMD2<Float>?], columns: Int, rows: Int, texel: SIMD2<Float>) {
        let tolerance = length(texel) * 1e-4

        for row in 0 ..< rows {
            for column in 0 ..< columns {
                take(&carried, column: column, row: row, columns: columns, rows: rows, texel: texel, mask: Self.forwardMask, tolerance: tolerance)
            }
        }

        for row in stride(from: rows - 1, through: 0, by: -1) {
            for column in stride(from: columns - 1, through: 0, by: -1) {
                take(&carried, column: column, row: row, columns: columns, rows: rows, texel: texel, mask: Self.backwardMask, tolerance: tolerance)
            }
        }
    }

    private func take(_ carried: inout [SIMD2<Float>?], column: Int, row: Int, columns: Int, rows: Int, texel: SIMD2<Float>, mask: [(Int, Int)], tolerance: Float) {
        let center = center(column: column, row: row, texel: texel)
        let slot = row * columns + column

        for (columnStep, rowStep) in mask {
            let neighbourColumn = column + columnStep
            let neighbourRow = row + rowStep
            guard neighbourColumn >= 0, neighbourColumn < columns, neighbourRow >= 0, neighbourRow < rows else { continue }
            guard let candidate = carried[neighbourRow * columns + neighbourColumn] else { continue }

            guard let incumbent = carried[slot] else {
                carried[slot] = candidate
                continue
            }
            if prefers(candidate, over: incumbent, at: center, tolerance: tolerance) {
                carried[slot] = candidate
            }
        }
    }

    /// Nearer wins. An equidistant pair resolves toward the centre of the Frame, and a pair equidistant from that too leaves the incumbent standing.
    private func prefers(_ candidate: SIMD2<Float>, over incumbent: SIMD2<Float>, at center: SIMD2<Float>, tolerance: Float) -> Bool {
        let candidateDistance = length(candidate - center)
        let incumbentDistance = length(incumbent - center)
        if candidateDistance < incumbentDistance - tolerance { return true }
        if candidateDistance > incumbentDistance + tolerance { return false }

        let middle = frame.origin + frame.size / 2
        return length(candidate - middle) < length(incumbent - middle) - tolerance
    }

    private func segments(of path: [SIMD2<Float>]) -> [(SIMD2<Float>, SIMD2<Float>)] {
        guard path.count > 1 else { return path.map { ($0, $0) } }
        return zip(path, path.dropFirst()).map { ($0, $1) }
    }

    private func nearest(on start: SIMD2<Float>, _ end: SIMD2<Float>, to location: SIMD2<Float>) -> SIMD2<Float> {
        let run = end - start
        let square = run.x * run.x + run.y * run.y
        guard square > 0 else { return start }

        let reach = location - start
        let travel = min(max((reach.x * run.x + reach.y * run.y) / square, 0), 1)
        return start + run * travel
    }

    private func center(column: Int, row: Int, texel: SIMD2<Float>) -> SIMD2<Float> {
        frame.origin + SIMD2<Float>(Float(column) + 0.5, Float(row) + 0.5) * texel
    }

    private func index(_ position: Float, origin: Float, texel: Float, count: Int) -> Int {
        min(max(Int(((position - origin) / texel).rounded(.down)), 0), count - 1)
    }

    private func length(_ run: SIMD2<Float>) -> Float {
        (run.x * run.x + run.y * run.y).squareRoot()
    }
}
