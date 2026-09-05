import Testing
@testable import Mobster

struct FieldReadTests {
    /// A hundred texels across a hundred units puts a texel centre on every half unit, so the locations below are exact rather than nearby.
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))
    private let diagonal = [[SIMD2<Float>(0, 0), SIMD2<Float>(100, 100)]]
    private let vertical = [[SIMD2<Float>(20, 0), SIMD2<Float>(20, 100)]]

    @Test func distanceAtALocationOffThePathIsTheLengthToTheNearestPathLocation() {
        let field = FieldBake(paths: diagonal, frame: frame, resolution: 100).field()

        #expect(abs(field.distance(at: SIMD2<Float>(80.5, 20.5)) - 42.426407) < 0.001)
    }

    @Test func directionAtALocationOffThePathPointsAtTheNearestPathLocation() {
        let field = FieldBake(paths: diagonal, frame: frame, resolution: 100).field()
        let direction = field.direction(at: SIMD2<Float>(80.5, 20.5))

        #expect(abs(direction.x - -0.70710678) < 0.001)
        #expect(abs(direction.y - 0.70710678) < 0.001)
    }

    /// Measured from the query and not from the centre of the texel it falls in: the query sits four tenths below the centre of texel sixty by fifty, whose stored location is twenty by fifty and a half, so the run is minus forty and nine tenths by four tenths.
    @Test func aReadIsTakenFromTheQueryAndNotFromTheCentreOfItsTexel() {
        let field = FieldBake(paths: vertical, frame: frame, resolution: 100).field()
        let query = SIMD2<Float>(60.9, 50.1)
        let direction = field.direction(at: query)

        #expect(abs(field.distance(at: query) - 40.901956) < 0.001)
        #expect(abs(direction.x - -0.99995218) < 0.0001)
        #expect(abs(direction.y - 0.00977948) < 0.0001)
    }

    /// The Frame carries a position, so a read subtracts the origin before it indexes. Texel sixty by forty of this Frame is centred on thirty and a half by fifty five and a half.
    @Test func aReadHoldsAgainstAFrameAwayFromTheOrigin() {
        let placed = Frame(origin: SIMD2<Float>(-30, 15), size: SIMD2<Float>(100, 100))
        let field = FieldBake(paths: [[SIMD2<Float>(-10, 15), SIMD2<Float>(-10, 115)]], frame: placed, resolution: 100).field()
        let query = SIMD2<Float>(30.5, 55.5)

        #expect(abs(field.distance(at: query) - 40.5) < 0.001)
        #expect(field.direction(at: query) == SIMD2<Float>(-1, 0))
        #expect(abs(field.locations[40 * 100 + 60].x - -10) < 0.001)
        #expect(abs(field.locations[40 * 100 + 60].y - 55.5) < 0.001)
    }

    /// A query beyond the Frame reads the texel it lies nearest. It does not wrap onto the far side, which would answer from the opposite end of the field.
    @Test func aQueryBeyondTheFrameClampsToTheNearestTexel() {
        let field = FieldBake(paths: diagonal, frame: frame, resolution: 100).field()
        let beyond = SIMD2<Float>(1000, 50.5)
        let before = SIMD2<Float>(-1000, 50.5)

        #expect(abs(field.distance(at: beyond) - 925.3244) < 0.01)
        #expect(abs(field.direction(at: beyond).x - -0.99964942) < 0.0001)
        #expect(abs(field.direction(at: beyond).y - 0.0264772) < 0.0001)
        #expect(abs(field.distance(at: before) - 1025.8047) < 0.01)
        #expect(abs(field.direction(at: before).x - 0.99970298) < 0.0001)
        #expect(abs(field.direction(at: before).y - -0.02437111) < 0.0001)
    }

    @Test func theStoredLocationIsTheNearestLocationOnThePath() {
        let field = FieldBake(paths: diagonal, frame: frame, resolution: 100).field()
        let stored = field.locations[20 * 100 + 80]

        #expect(abs(stored.x - 50.5) < 0.001)
        #expect(abs(stored.y - 50.5) < 0.001)
    }

    @Test func aLocationOnThePathReportsWithinATexelOfZero() {
        let field = FieldBake(paths: diagonal, frame: frame, resolution: 400).field()

        for step in stride(from: Float(5), through: 95, by: 5) {
            #expect(field.distance(at: SIMD2<Float>(step, step)) < 0.36)
        }
    }

    @Test func aLocationOnAPresetPathReportsWithinATexelOfZero() {
        let preset = RulerPreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08, mode: .aspect)
        let paths = preset.paths(in: frame)
        let field = FieldBake(paths: paths, frame: frame, resolution: 400).field()

        for path in paths {
            for travel in stride(from: Float(0.1), through: 0.9, by: 0.1) {
                let location = path[0] + (path[1] - path[0]) * travel
                #expect(field.distance(at: location) < 0.36)
            }
        }
    }

    @Test func directionAtAStoredLocationHasNoDirectionToReport() {
        let field = FieldBake(paths: diagonal, frame: frame, resolution: 100).field()

        #expect(field.direction(at: SIMD2<Float>(50.5, 50.5)) == SIMD2<Float>(0, 0))
    }
}
