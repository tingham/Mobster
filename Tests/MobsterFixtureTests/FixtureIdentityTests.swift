import Mobster
import Testing
@testable import MobsterFixture

struct FixtureIdentityTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 400))
    private let parameters = FixtureParameters(seed: 3, strokeCount: 16, pointsPerStroke: 32, step: 0.02, turn: 30, margin: 0.08)

    @Test func pointIdentifiersAreUniqueAcrossTheWholePopulation() {
        let strokes = LineFixture(parameters: parameters).lines(in: frame)
        let identifiers = strokes.flatMap { $0.verts.map(\.identifier) }

        #expect(identifiers.count == 16 * 32)
        #expect(Set(identifiers).count == identifiers.count)
    }

    @Test func strokeIdentifiersAreUnique() {
        let identifiers = LineFixture(parameters: parameters).lines(in: frame).map(\.identifier)

        #expect(identifiers.count == 16)
        #expect(Set(identifiers).count == identifiers.count)
    }

    @Test func aVertIdentifierNeverCollidesWithALineIdentifier() {
        let strokes = LineFixture(parameters: parameters).lines(in: frame)
        let points = Set(strokes.flatMap { $0.verts.map(\.identifier?.value) })
        let owners = Set(strokes.map(\.identifier?.value))

        #expect(points.isDisjoint(with: owners))
    }

    @Test func theSequenceIssuesEachValueOnce() {
        var sequence = FixtureIdentitySequence()
        var issued: [UInt64] = []

        for _ in 0 ..< 64 {
            issued.append(sequence.line().value)
            issued.append(sequence.vert().value)
        }

        #expect(Set(issued).count == issued.count)
    }
}
