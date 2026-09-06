import Mobster
import Testing
@testable import MobsterFixture

struct FixtureDeterminismTests {
    /// The Frame the sequence below was recorded against. Its origin is off zero, so a population that ignored the origin would not match.
    private let frame = Frame(origin: SIMD2<Float>(-30, 15), size: SIMD2<Float>(640, 480))
    private let parameters = FixtureParameters(seed: 5, lineCount: 6, vertsPerLine: 20, step: 0.04, turn: 45, margin: 0.12)

    /// Wide enough to absorb a difference in float rounding between architectures and far narrower than any change in the walk.
    private func matches(_ location: SIMD2<Float>, _ recorded: SIMD2<Float>) -> Bool {
        abs(location.x - recorded.x) <= 0.01 && abs(location.y - recorded.y) <= 0.01
    }

    /// Recorded by a separate process from the one asserting them, so agreement is evidence the seed alone carries the population across a process boundary.
    @Test func theSeedReproducesItsRecordedPopulation() {
        let strokes = LineFixture(parameters: parameters).lines(in: frame)
        let recorded: [(UInt64, [(UInt64, SIMD2<Float>)])] = [
            (1, [(2, SIMD2<Float>(234.92398, 347.0416)), (11, SIMD2<Float>(361.72775, 452.75098)), (21, SIMD2<Float>(466.78876, 393.59494))]),
            (43, [(44, SIMD2<Float>(363.69464, 350.58264)), (53, SIMD2<Float>(407.27072, 491.30862)), (63, SIMD2<Float>(480.35907, 329.0688))]),
            (106, [(107, SIMD2<Float>(388.9328, 401.8793)), (116, SIMD2<Float>(471.77744, 482.1059)), (126, SIMD2<Float>(487.0954, 300.03998))]),
        ]
        let strokeIndices = [0, 2, 5]
        let sampleIndices = [0, 9, 19]

        #expect(strokes.count == 6)
        for (position, entry) in zip(strokeIndices, recorded) {
            let stroke = strokes[position]
            #expect(stroke.identifier?.value == entry.0)
            for (index, expected) in zip(sampleIndices, entry.1) {
                #expect(stroke.verts[index].identifier?.value == expected.0)
                #expect(matches(stroke.verts[index].location, expected.1))
            }
        }
    }

    @Test func twoRunsOfTheSameSeedAgreeOnEveryPoint() {
        let first = LineFixture(parameters: parameters).lines(in: frame)
        let second = LineFixture(parameters: parameters).lines(in: frame)

        #expect(first.count == second.count)
        for (left, right) in zip(first, second) {
            #expect(left.identifier == right.identifier)
            #expect(left.verts.count == right.verts.count)
            for (sample, twin) in zip(left.verts, right.verts) {
                #expect(sample.identifier == twin.identifier)
                #expect(sample.location.x.bitPattern == twin.location.x.bitPattern)
                #expect(sample.location.y.bitPattern == twin.location.y.bitPattern)
            }
        }
    }

    @Test func anotherSeedMovesEveryPoint() {
        var other = parameters
        other.seed = parameters.seed + 1
        let first = LineFixture(parameters: parameters).lines(in: frame)
        let second = LineFixture(parameters: other).lines(in: frame)
        var agreements = 0

        for (left, right) in zip(first, second) {
            for (sample, twin) in zip(left.verts, right.verts) where matches(sample.location, twin.location) {
                agreements += 1
            }
        }

        #expect(agreements == 0)
    }

    @Test func theSameSeedKeepsTheSameIdentifiersUnderAnotherFrame() {
        let elsewhere = Frame(origin: SIMD2<Float>(400, -200), size: SIMD2<Float>(100, 900))
        let first = LineFixture(parameters: parameters).lines(in: frame)
        let second = LineFixture(parameters: parameters).lines(in: elsewhere)

        #expect(first.map(\.identifier) == second.map(\.identifier))
        #expect(first.flatMap { $0.verts.map(\.identifier) } == second.flatMap { $0.verts.map(\.identifier) })
    }

    @Test func theGeneratorReplaysItsStream() {
        var first = FixtureRandom(seed: 99)
        var second = FixtureRandom(seed: 99)
        var third = FixtureRandom(seed: 100)
        let run = (0 ..< 8).map { _ in first.next() }

        #expect(run == (0 ..< 8).map { _ in second.next() })
        #expect(run != (0 ..< 8).map { _ in third.next() })
    }

    @Test func theGeneratorStaysWithinTheUnit() {
        var random = FixtureRandom(seed: 12345)

        for _ in 0 ..< 4096 {
            let value = random.unit()
            #expect(value >= 0 && value < 1)
        }
    }
}
