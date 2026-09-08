import Testing
@testable import Mobster

struct FieldBakeTests {
    private let frame = Frame(origin: SIMD2<Float>(-30, 15), size: SIMD2<Float>(200, 100))

    @Test func theDerivedCountLiesAcrossTheWiderAxisOfTheFrame() {
        let paths = [[SIMD2<Float>(-30, 15), SIMD2<Float>(170, 115)]]

        for count in [10, 40, 128] {
            let field = FieldFixture.field(paths: paths, frame: frame, count: count)

            #expect(field.columns == count)
            #expect(field.rows == count / 2)
            #expect(field.locations.count == field.columns * field.rows)
        }
    }

    /// Half the epsilon is half the texel on each axis, so the field is four times the texels of the one before it.
    @Test func aHalvedEpsilonBakesAFinerField() throws {
        let paths = [[SIMD2<Float>(-30, 15), SIMD2<Float>(170, 115)]]
        let coarse = try FieldBake(paths: paths, frame: frame, settleEpsilon: 2, budget: .max).field()
        let fine = try FieldBake(paths: paths, frame: frame, settleEpsilon: 1, budget: .max).field()

        #expect(coarse.columns == 71)
        #expect(fine.columns == 142)
        #expect(coarse.locations.count == 71 * 36)
        #expect(fine.locations.count == 142 * 71)
        #expect(fine.locations.count > coarse.locations.count * 3)
    }

    /// The narrower count is rounded, so a Frame whose ratio does not divide the count has a texel taller than it is wide. Ten by three and a half rounds to ten by four.
    @Test func theNarrowerCountIsRoundedAndLeavesATexelOffSquare() {
        let oblong = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 35))
        let field = FieldFixture.field(paths: [[SIMD2<Float>(0, 0), SIMD2<Float>(100, 35)]], frame: oblong, count: 10)
        let grid = FieldGrid(frame: oblong, columns: field.columns, rows: field.rows)

        #expect(field.columns == 10)
        #expect(field.rows == 4)
        #expect(grid.texel == SIMD2<Float>(10, 8.75))
    }

    @Test func theSamePathsAndFrameBakeAnIdenticalField() {
        let paths = ColumnsPreset(count: 4, gutter: 0.05, mode: .aspect).paths(in: frame)
        let first = FieldFixture.field(paths: paths, frame: frame, count: 64)
        let second = FieldFixture.field(paths: paths, frame: frame, count: 64)

        #expect(first.locations == second.locations)
    }

    /// A single upright path gives every texel a nearest location of the path's own x at the texel's own y, which a field storing any other location on that path fails.
    @Test func everyStoredLocationIsTheNearestOnThePath() {
        let paths = [[SIMD2<Float>(40, 15), SIMD2<Float>(40, 115)]]
        let field = FieldFixture.field(paths: paths, frame: frame, count: 60)
        let grid = FieldGrid(frame: frame, columns: field.columns, rows: field.rows)

        for row in 0 ..< field.rows {
            for column in 0 ..< field.columns {
                let stored = field.locations[grid.slot(column: column, row: row)]

                #expect(abs(stored.x - 40) < 0.001)
                #expect(abs(stored.y - grid.center(column: column, row: row).y) < 0.001)
            }
        }
    }

    @Test func noPathsBakeNoLocations() {
        let field = FieldFixture.field(paths: [], frame: frame, count: 32)

        #expect(field.locations.isEmpty)
        #expect(field.distance(at: SIMD2<Float>(0, 0)) == .infinity)
    }
}
