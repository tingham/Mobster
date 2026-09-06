/// Bakes paths into a field. Every texel is solved against every segment rather than propagated from its neighbours: a propagated location is only ever as good as the locations its neighbours happened to compute, and a path outside the Frame is computed by no texel at all.
public struct FieldBake: Sendable {
    /// Scene coordinates, one entry per interpreted path.
    public let paths: [[SIMD2<Float>]]
    public let frame: Frame
    /// Texels across the wider axis of the Frame. The other axis takes the count its share of the Frame rounds to.
    public let resolution: Int

    public init(paths: [[SIMD2<Float>]], frame: Frame, resolution: Int) {
        self.paths = paths
        self.frame = frame
        self.resolution = resolution
    }

    public func field() -> Field {
        let span = max(frame.size.x, frame.size.y)
        guard resolution > 0, frame.size.x > 0, frame.size.y > 0 else {
            return Field(frame: frame, columns: 0, rows: 0, locations: [])
        }

        let columns = max(1, Int((frame.size.x / span * Float(resolution)).rounded()))
        let rows = max(1, Int((frame.size.y / span * Float(resolution)).rounded()))
        let grid = FieldGrid(frame: frame, columns: columns, rows: rows)
        let runs = paths.flatMap(segments)
        guard !runs.isEmpty else { return Field(frame: frame, columns: columns, rows: rows, locations: []) }

        let tolerance = length(grid.texel) * 1e-4
        var locations = [SIMD2<Float>]()
        locations.reserveCapacity(columns * rows)

        for row in 0 ..< rows {
            for column in 0 ..< columns {
                locations.append(nearest(to: grid.center(column: column, row: row), among: runs, settled: locations.last, tolerance: tolerance))
            }
        }

        return Field(frame: frame, columns: columns, rows: rows, locations: locations)
    }

    /// The location already settled for the preceding texel bounds the search for this one, because a path location any texel resolved to is a path location this one could resolve to. It is a bound and never a candidate, so a texel's answer follows from the paths alone. Squared lengths carry the comparison until a candidate is close enough to matter, which keeps the square root off the rejected majority.
    private func nearest(to center: SIMD2<Float>, among runs: [(SIMD2<Float>, SIMD2<Float>)], settled: SIMD2<Float>?, tolerance: Float) -> SIMD2<Float> {
        var best = settled ?? SIMD2<Float>(0, 0)
        var found = false
        var reach = settled.map { length($0 - center) } ?? .greatestFiniteMagnitude

        for (start, end) in runs {
            let limit = reach + tolerance
            let ceiling = limit * limit
            guard square(gap(from: center, toward: start, and: end)) <= ceiling else { continue }

            let candidate = nearest(on: start, end, to: center)
            let distance = square(candidate - center)
            guard distance <= ceiling else { continue }

            let separation = distance.squareRoot()
            if !found || separation < reach - tolerance || prefers(candidate, over: best, at: center, tolerance: tolerance) {
                best = candidate
                found = true
            }
            reach = min(reach, separation)
        }

        return best
    }

    private func square(_ run: SIMD2<Float>) -> Float {
        run.x * run.x + run.y * run.y
    }

    private func square(_ value: Float) -> Float {
        value * value
    }

    /// The run from a location to the box the two ends span, which no location on the segment can beat and which rejects a distant segment for four comparisons.
    private func gap(from location: SIMD2<Float>, toward start: SIMD2<Float>, and end: SIMD2<Float>) -> SIMD2<Float> {
        let low = SIMD2<Float>(min(start.x, end.x), min(start.y, end.y)) - location
        let high = location - SIMD2<Float>(max(start.x, end.x), max(start.y, end.y))
        return SIMD2<Float>(max(max(low.x, high.x), 0), max(max(low.y, high.y), 0))
    }

    /// Nearer wins. An equidistant pair resolves toward the centre of the Frame, and a pair equidistant from the centre as well resolves to the lesser x and then the lesser y, so the answer does not follow from the order the paths were supplied in.
    private func prefers(_ candidate: SIMD2<Float>, over incumbent: SIMD2<Float>, at center: SIMD2<Float>, tolerance: Float) -> Bool {
        let candidateDistance = length(candidate - center)
        let incumbentDistance = length(incumbent - center)
        if candidateDistance < incumbentDistance - tolerance { return true }
        if candidateDistance > incumbentDistance + tolerance { return false }

        let middle = frame.origin + frame.size / 2
        let candidateReach = length(candidate - middle)
        let incumbentReach = length(incumbent - middle)
        if candidateReach < incumbentReach - tolerance { return true }
        if candidateReach > incumbentReach + tolerance { return false }

        if candidate.x != incumbent.x { return candidate.x < incumbent.x }
        return candidate.y < incumbent.y
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

    private func length(_ run: SIMD2<Float>) -> Float {
        (run.x * run.x + run.y * run.y).squareRoot()
    }
}
