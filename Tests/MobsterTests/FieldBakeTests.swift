import Testing
@testable import Mobster

struct FieldBakeTests {
    private let frame = Frame(origin: SIMD2<Float>(-30, 15), size: SIMD2<Float>(200, 100))

    @Test func resolutionCountsTexelsAcrossTheWiderAxisAndKeepsATexelSquare() {
        let paths = [[SIMD2<Float>(-30, 15), SIMD2<Float>(170, 115)]]

        for resolution in [10, 40, 128] {
            let field = FieldBake(paths: paths, frame: frame, resolution: resolution).field()

            #expect(field.columns == resolution)
            #expect(field.rows == resolution / 2)
            #expect(field.locations.count == field.columns * field.rows)
        }
    }

    @Test func theSamePathsAndFrameBakeAnIdenticalField() {
        let paths = ColumnsPreset(count: 4, gutter: 0.05).paths(in: frame, mode: .aspect)
        let first = FieldBake(paths: paths, frame: frame, resolution: 64).field()
        let second = FieldBake(paths: paths, frame: frame, resolution: 64).field()

        #expect(first.locations == second.locations)
    }

    @Test func everyStoredLocationSitsOnAPath() {
        let paths = [[SIMD2<Float>(0, 40), SIMD2<Float>(120, 90)]]
        let field = FieldBake(paths: paths, frame: frame, resolution: 60).field()
        let start = paths[0][0]
        let run = paths[0][1] - start

        for stored in field.locations {
            let reach = stored - start
            let travel = (reach.x * run.x + reach.y * run.y) / (run.x * run.x + run.y * run.y)
            let projected = start + run * min(max(travel, 0), 1)

            #expect(abs(stored.x - projected.x) < 0.001)
            #expect(abs(stored.y - projected.y) < 0.001)
        }
    }

    @Test func noPathsBakeNoLocations() {
        let field = FieldBake(paths: [], frame: frame, resolution: 32).field()

        #expect(field.locations.isEmpty)
        #expect(field.distance(at: SIMD2<Float>(0, 0)) == .infinity)
    }
}
