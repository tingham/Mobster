import Testing
@testable import Mobster

/// The stored location against an exhaustive search of the paths, which is the standard the bake approximates.
struct FieldToleranceTests {
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

    private func truth(_ paths: [[SIMD2<Float>]], _ location: SIMD2<Float>) -> SIMD2<Float> {
        var best = SIMD2<Float>(0, 0)
        var reach = Float.infinity

        for path in paths {
            let pairs: [(SIMD2<Float>, SIMD2<Float>)] = path.count > 1 ? Array(zip(path, path.dropFirst())) : path.map { ($0, $0) }
            for (start, end) in pairs {
                let candidate = nearest(on: start, end, to: location)
                let distance = length(candidate - location)
                if distance < reach {
                    reach = distance
                    best = candidate
                }
            }
        }

        return best
    }

    /// A tie is not counted: where two locations are the same distance away both are a true nearest and the tie break, not the bound, decides which is stored.
    private func breaches(_ paths: [[SIMD2<Float>]], _ frame: Frame, _ resolution: Int) -> Int {
        let field = FieldBake(paths: paths, frame: frame, resolution: resolution).field()
        let grid = FieldGrid(frame: frame, columns: field.columns, rows: field.rows)
        let bound = length(grid.texel)
        var count = 0

        for row in 0 ..< field.rows {
            for column in 0 ..< field.columns {
                let centre = grid.center(column: column, row: row)
                let stored = field.locations[grid.slot(column: column, row: row)]
                let expected = truth(paths, centre)
                guard abs(length(stored - centre) - length(expected - centre)) > bound * 0.001 else { continue }
                if length(stored - expected) > bound { count += 1 }
            }
        }

        return count
    }

    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))
    private let placed = Frame(origin: SIMD2<Float>(-30, 15), size: SIMD2<Float>(200, 100))

    @Test func aStoredLocationIsWithinATexelOfTheTrueNearestOnPlainGeometry() {
        #expect(breaches([[SIMD2<Float>(0, 0), SIMD2<Float>(100, 100)]], square, 100) == 0)
        #expect(breaches([[SIMD2<Float>(30, 0), SIMD2<Float>(30, 100)], [SIMD2<Float>(70, 0), SIMD2<Float>(70, 100)]], square, 100) == 0)
        #expect(breaches([[SIMD2<Float>(10, 30), SIMD2<Float>(70, 30), SIMD2<Float>(70, 90)]], square, 100) == 0)
        #expect(breaches([[SIMD2<Float>(30, 70)], [SIMD2<Float>(70, 30)]], square, 100) == 0)
    }

    @Test func aStoredLocationIsWithinATexelOfTheTrueNearestOnExteriorGeometry() {
        #expect(breaches([[SIMD2<Float>(-10, 0), SIMD2<Float>(-10, 100)], [SIMD2<Float>(90, 0), SIMD2<Float>(90, 100)]], square, 100) == 0)
        #expect(breaches([[SIMD2<Float>(-50, -50), SIMD2<Float>(50, 150)]], square, 100) == 0)
        #expect(breaches([[SIMD2<Float>(-60, -10), SIMD2<Float>(-10, -60)]], square, 100) == 0)
        #expect(breaches([[SIMD2<Float>(-60, 50), SIMD2<Float>(40, 50)]], square, 100) == 0)
    }

    @Test func aStoredLocationIsWithinATexelOfTheTrueNearestOnEveryPreset() {
        #expect(breaches(ColumnsPreset(count: 4, gutter: 0.05).paths(in: square, mode: .aspect), square, 64) == 0)
        #expect(breaches(RowsPreset(count: 3, gutter: 0.02).paths(in: square, mode: .aspect), square, 64) == 0)
        #expect(breaches(ThirdsPreset().paths(in: square, mode: .aspect), square, 64) == 0)
        #expect(breaches(RulerPreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08).paths(in: square, mode: .aspect), square, 64) == 0)
        #expect(breaches(CurvePreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08, control: SIMD2<Float>(0.55, 0.7), resolution: 32).paths(in: square, mode: .aspect), square, 64) == 0)
    }

    /// Golden Ratio in bounds mode keeps its own proportions against a square Frame, so part of the spiral is necessarily outside it.
    @Test func aStoredLocationIsWithinATexelOfTheTrueNearestOnGoldenRatio() {
        #expect(breaches(GoldenRatioPreset().paths(in: square, mode: .bounds), square, 64) == 0)
        #expect(breaches(GoldenRatioPreset().paths(in: placed, mode: .bounds), placed, 64) == 0)
    }

    @Test func aStoredLocationIsWithinATexelOfTheTrueNearestAgainstAPlacedFrame() {
        #expect(breaches(RulerPreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08).paths(in: placed, mode: .aspect), placed, 64) == 0)
        #expect(breaches([[SIMD2<Float>(-200, 40), SIMD2<Float>(-150, 90)]], placed, 64) == 0)
    }
}
