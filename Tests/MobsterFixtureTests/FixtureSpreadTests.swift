import Mobster
import Testing
@testable import MobsterFixture

struct FixtureSpreadTests {
    /// The Frame the sequence below was recorded against.
    private let frame = Frame(origin: SIMD2<Float>(-30, 15), size: SIMD2<Float>(640, 480))

    private func parameters(spread: Float) -> FixtureParameters {
        FixtureParameters(seed: 5, lineCount: 6, vertsPerLine: 20, step: 0.04, turn: 45, margin: 0.12, spread: spread)
    }

    private func verts(spread: Float, in frame: Frame? = nil) -> [Vert] {
        LineFixture(parameters: parameters(spread: spread)).lines(in: frame ?? self.frame).flatMap(\.verts)
    }

    @Test func aSpreadOfNothingLeavesEveryVertUnattributed() {
        let population = verts(spread: 0)

        #expect(population.count == 120)
        #expect(population.allSatisfy { $0.mass == nil && $0.drag == nil })
    }

    @Test func aSpreadGivesEachVertItsOwnMassAndDrag() {
        let population = verts(spread: 0.75)
        let masses = population.compactMap(\.mass)
        let drags = population.compactMap(\.drag)

        #expect(masses.count == population.count)
        #expect(drags.count == population.count)
        #expect(Set(masses.map(\.bitPattern)).count > population.count / 2)
        #expect(Set(drags.map(\.bitPattern)).count > population.count / 2)
        #expect(masses.allSatisfy { $0 >= 0 })
        #expect(drags.allSatisfy { $0 >= -1 && $0 <= 1 })
    }

    @Test func theSpreadLeavesTheWalkWhereItStood() {
        let plain = verts(spread: 0)
        let spread = verts(spread: 1)

        #expect(plain.map(\.identifier) == spread.map(\.identifier))
        for (sample, twin) in zip(plain, spread) {
            #expect(sample.location.x.bitPattern == twin.location.x.bitPattern)
            #expect(sample.location.y.bitPattern == twin.location.y.bitPattern)
        }
    }

    /// Recorded by a separate process from the one asserting them. Both attributes fall out of integer arithmetic on the identifier, so an agreement here is exact rather than within a tolerance.
    @Test func theSeedReproducesItsRecordedAttributes() {
        let lines = LineFixture(parameters: parameters(spread: 0.75)).lines(in: frame)
        let recorded: [(UInt64, Float, Float)] = [
            (2, 0.76993334, -0.08953035),
            (11, 1.0779065, 0.84922826),
            (21, 0.93436944, -0.27113438),
            (44, 0.8957896, -0.34150648),
            (53, 0.891369, 0.64038754),
            (63, 0.85125095, 0.55295897),
            (107, 1.5042517, 0.46288246),
            (116, 0.29594922, -0.14189076),
            (126, 0.5284244, -0.34003544),
        ]
        let sampled = [0, 2, 5].flatMap { stroke in [0, 9, 19].map { lines[stroke].verts[$0] } }

        for (vert, entry) in zip(sampled, recorded) {
            #expect(vert.identifier?.value == entry.0)
            #expect(vert.mass?.bitPattern == entry.1.bitPattern)
            #expect(vert.drag?.bitPattern == entry.2.bitPattern)
        }
    }

    @Test func aVertCarriesTheSameAttributesUnderAnotherFrame() {
        let elsewhere = Frame(origin: SIMD2<Float>(400, -200), size: SIMD2<Float>(100, 900))
        let here = verts(spread: 0.75)
        let there = verts(spread: 0.75, in: elsewhere)

        #expect(here.map(\.identifier) == there.map(\.identifier))
        #expect(here.compactMap(\.mass).map(\.bitPattern) == there.compactMap(\.mass).map(\.bitPattern))
        #expect(here.compactMap(\.drag).map(\.bitPattern) == there.compactMap(\.drag).map(\.bitPattern))
    }

    @Test func aWiderSpreadStraysFurtherFromThePlainTravel() {
        let narrow = verts(spread: 0.25)
        let wide = verts(spread: 1)

        #expect(stray(narrow, of: \.mass) < stray(wide, of: \.mass))
        #expect(stray(narrow, of: \.drag) < stray(wide, of: \.drag))
    }

    /// One is the plain travel for both attributes, so how far the population strays from it is the width of the spread.
    private func stray(_ population: [Vert], of attribute: KeyPath<Vert, Float?>) -> Float {
        population.compactMap { $0[keyPath: attribute] }.map { abs($0 - 1) }.max() ?? 0
    }
}
