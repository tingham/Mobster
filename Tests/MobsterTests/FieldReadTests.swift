import Testing
@testable import Mobster

struct FieldReadTests {
    /// A hundred texels across a hundred units puts a texel centre on every half unit, so the locations below are exact rather than nearby.
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))
    private let diagonal = [[SIMD2<Float>(0, 0), SIMD2<Float>(100, 100)]]

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
        let preset = RulerPreset(center: SIMD2<Float>(0.4, 0.6), firstDegree: 17, secondDegree: 212, distance: 0.08)
        let paths = preset.paths(in: frame, mode: .aspect)
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
