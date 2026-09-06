import Testing
@testable import Mobster

/// A path outside the Frame still participates. A source Frame maps absolutely rather than being fitted, and a preset scaled to encompass the Frame lies partly outside it, so exterior geometry is ordinary rather than exceptional.
struct FieldExteriorTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))

    /// Texel five by fifty is centred on five and a half by fifty and a half. The path outside the Frame at minus ten is fifteen and a half away and the one inside it at ninety is eighty four and a half away.
    @Test func aQueryResolvesToAPathOutsideTheFrameWhenThatIsTheNearest() {
        let paths = [[SIMD2<Float>(-10, 0), SIMD2<Float>(-10, 100)], [SIMD2<Float>(90, 0), SIMD2<Float>(90, 100)]]
        let field = FieldFixture.field(paths: paths, frame: frame, count: 100)
        let query = SIMD2<Float>(5.5, 50.5)

        #expect(abs(field.distance(at: query) - 15.5) < 0.001)
        #expect(field.direction(at: query) == SIMD2<Float>(-1, 0))
        #expect(abs(field.locations[50 * 100 + 5].x - -10) < 0.001)
        #expect(abs(field.locations[50 * 100 + 5].y - 50.5) < 0.001)
    }

    /// A segment crossing the Frame, read at a texel whose nearest location lies on the part of it that is outside. The foot at forty six and three tenths along the run is minus three and seven tenths by forty two and six tenths, and the run to it is perpendicular to the segment.
    @Test func aQueryResolvesOntoTheExteriorPortionOfACrossingSegment() {
        let paths = [[SIMD2<Float>(-50, -50), SIMD2<Float>(50, 150)]]
        let field = FieldFixture.field(paths: paths, frame: frame, count: 100)
        let query = SIMD2<Float>(60.5, 10.5)
        let direction = field.direction(at: query)

        #expect(abs(field.distance(at: query) - 71.777782) < 0.01)
        #expect(abs(direction.x - -0.89442719) < 0.001)
        #expect(abs(direction.y - 0.44721360) < 0.001)
        #expect(abs(field.locations[10 * 100 + 60].x - -3.7) < 0.02)
        #expect(abs(field.locations[10 * 100 + 60].y - 42.6) < 0.02)
    }

    /// A path lying wholly outside the Frame is the same case again, and it is the one that used to bake nothing at all.
    @Test func aPathWhollyOutsideTheFrameStillBakesAField() {
        let paths = [[SIMD2<Float>(-30, 4), SIMD2<Float>(4, -30)]]
        let field = FieldFixture.field(paths: paths, frame: frame, count: 100)

        #expect(!field.isEmpty)
        #expect(field.distance(at: SIMD2<Float>(0.5, 0.5)) < 20)
    }
}
