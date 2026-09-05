import Testing
@testable import Mobster

struct FieldRasterTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))
    private let diagonal = [[SIMD2<Float>(0, 0), SIMD2<Float>(100, 100)]]

    @Test func theRasterCarriesOneSamplePerTexel() {
        let field = FieldBake(paths: diagonal, frame: frame, resolution: 100).field()
        let raster = field.grayscale()

        #expect(raster.columns == field.columns)
        #expect(raster.rows == field.rows)
        #expect(raster.samples.count == field.columns * field.rows)
    }

    /// A texel centre on the diagonal is white, and the two corners the diagonal is furthest from are black.
    @Test func aPathIsWhiteAndTheFurthestTexelIsBlack() {
        let raster = FieldBake(paths: diagonal, frame: frame, resolution: 100).field().grayscale()

        #expect(raster.samples[50 * 100 + 50] == 255)
        #expect(raster.samples[99 * 100 + 0] == 0)
        #expect(raster.samples[0 * 100 + 99] == 0)
    }

    /// A texel centre thirty five and a third out of a furthest seventy keeps just under half its intensity.
    @Test func intensityFallsWithDistance() {
        let raster = FieldBake(paths: diagonal, frame: frame, resolution: 100).field().grayscale()

        #expect(raster.samples[75 * 100 + 25] == 126)
    }
}
