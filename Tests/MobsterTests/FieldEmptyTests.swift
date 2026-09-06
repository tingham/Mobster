import Testing
@testable import Mobster

struct FieldEmptyTests {
    private let frame = Frame(origin: SIMD2<Float>(-30, 15), size: SIMD2<Float>(200, 100))

    @Test func aFieldWithNoPathReportsThatItHoldsNone() {
        let field = FieldFixture.field(paths: [], frame: frame, count: 32)

        #expect(field.isEmpty)
        #expect(field.distance(at: SIMD2<Float>(0, 0)) == .infinity)
        #expect(field.direction(at: SIMD2<Float>(0, 0)) == SIMD2<Float>(0, 0))
    }

    /// A raster of uniform maximum distance cannot be told apart from a legitimate one, so an empty field vends none.
    @Test func anEmptyFieldVendsNoGrayscale() {
        #expect(FieldFixture.field(paths: [], frame: frame, count: 32).grayscale() == nil)
    }

    /// The counts follow from the Frame and the epsilon alone, so a consumer sizing a view from them is not told a different size by a bake that found nothing.
    @Test func texelCountsDoNotVaryWithWhetherTheBakeFoundAPath() {
        let bare = FieldFixture.field(paths: [], frame: frame, count: 32)
        let plotted = FieldFixture.field(paths: [[SIMD2<Float>(0, 40), SIMD2<Float>(120, 90)]], frame: frame, count: 32)

        #expect(bare.columns == plotted.columns)
        #expect(bare.rows == plotted.rows)
        #expect(bare.columns == 32)
        #expect(bare.rows == 16)
    }

    @Test func aFrameWithNoExtentOnEitherAxisBakesAnEmptyField() {
        let paths = [[SIMD2<Float>(0, 40), SIMD2<Float>(120, 90)]]
        let flat = FieldFixture.field(paths: paths, frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 0)), count: 10)
        let thin = FieldFixture.field(paths: paths, frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(0, 100)), count: 10)
        let none = FieldFixture.field(paths: paths, frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(0, 0)), count: 10)

        #expect(flat.isEmpty)
        #expect(thin.isEmpty)
        #expect(none.isEmpty)
        #expect(flat.distance(at: SIMD2<Float>(50, 0)) == .infinity)
        #expect(flat.grayscale() == nil)
    }
}
