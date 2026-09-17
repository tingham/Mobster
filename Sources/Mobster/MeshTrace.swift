/// A boundary's samples put in order by walking the lattice they stand on. A sample sits midway between two fragments, so doubling its coordinates makes that lattice integral and the walk exact.
struct MeshTrace {
    /// The farthest a step reaches, on the doubled lattice. A boundary turning a corner leaves a gap of one fragment and nothing belonging to the same run stands further off than that.
    private static let reach: Int32 = 3
    /// The steps a walk tries, nearest first, so a run follows its boundary rather than cutting across it.
    private static let steps: [SIMD2<Int32>] = {
        var offsets: [SIMD2<Int32>] = []

        for across in -reach ... reach {
            for down in -reach ... reach where across != 0 || down != 0 {
                if across * across + down * down <= reach * reach { offsets.append(SIMD2<Int32>(across, down)) }
            }
        }

        return offsets.sorted { first, second in
            let near = first.x * first.x + first.y * first.y
            let far = second.x * second.x + second.y * second.y

            return near != far ? near < far : precedes(first, second)
        }
    }()

    /// The fewest samples a run is kept at. A form grazing another for one or two fragments would otherwise stand in for the whole silhouette of that form.
    static let floor = 3

    let locations: [SIMD2<Float>]

    /// Walking out of one sample in both directions is what puts a boundary in order from a seed standing anywhere along it, and a pair of components meeting in more than one place yields a run for each meeting rather than one joined across the gaps.
    func ordered() -> [[SIMD2<Float>]] {
        var remaining: [SIMD2<Int32>: SIMD2<Float>] = [:]
        for location in locations { remaining[Self.key(location)] = location }

        var runs: [[SIMD2<Float>]] = []

        while let seed = Self.seed(remaining) {
            guard let standing = remaining.removeValue(forKey: seed) else { break }
            let forward = walk(from: seed, &remaining)
            let backward = walk(from: seed, &remaining)
            let run = backward.reversed() + [standing] + forward

            if run.count >= Self.floor { runs.append(run) }
        }

        return runs
    }

    /// The sample farthest from the middle of what is left, which is an end of a run wherever the run is open and a corner of it wherever it closes.
    private static func seed(_ remaining: [SIMD2<Int32>: SIMD2<Float>]) -> SIMD2<Int32>? {
        guard remaining.isEmpty == false else { return nil }

        let centre = remaining.values.reduce(SIMD2<Float>.zero, +) / Float(remaining.count)
        var chosen: SIMD2<Int32>?
        var farthest: Float = -1

        for (key, location) in remaining {
            let offset = location - centre
            let distance = (offset * offset).sum()

            if distance > farthest || (distance == farthest && precedes(key, chosen ?? key)) {
                farthest = distance
                chosen = key
            }
        }

        return chosen
    }

    private func walk(from start: SIMD2<Int32>, _ remaining: inout [SIMD2<Int32>: SIMD2<Float>]) -> [SIMD2<Float>] {
        var run: [SIMD2<Float>] = []
        var standing = start

        while true {
            guard let step = Self.steps.lazy.map({ standing &+ $0 }).first(where: { remaining[$0] != nil }),
                  let location = remaining.removeValue(forKey: step) else { return run }
            run.append(location)
            standing = step
        }
    }

    private static func key(_ location: SIMD2<Float>) -> SIMD2<Int32> {
        SIMD2<Int32>(Int32((location.x * 2).rounded()), Int32((location.y * 2).rounded()))
    }

    private static func precedes(_ first: SIMD2<Int32>, _ second: SIMD2<Int32>) -> Bool {
        first.y != second.y ? first.y < second.y : first.x < second.x
    }
}
