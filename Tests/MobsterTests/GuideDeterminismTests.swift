import Testing
@testable import Mobster

struct GuideDeterminismTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    private func guide() -> Guide {
        let guide = Guide(frame: frame, settleEpsilon: 1)
        guide.initialize(source: .preset(ThirdsPreset()), frame: frame, adhesion: 0.3, duration: 4, resolution: 128)
        return guide
    }

    private func population() -> [Line] {
        (0 ..< 4).map { line in
            Line(verts: (0 ..< 8).map { vert in
                let index = line * 8 + vert
                return Vert(location: SIMD2<Float>(3.5 + Float(index) * 3, 7.5 + Float(vert) * 11), identifier: VertIdentifier(UInt64(index)))
            }, identifier: LineIdentifier(UInt64(line)))
        }
    }

    private func landings(_ lines: [Line]) -> [UInt32] {
        lines.flatMap(\.verts).flatMap { [$0.location.x.bitPattern, $0.location.y.bitPattern] }
    }

    @Test func twoGuidesBuiltAlikeAgreeOnEveryVert() {
        #expect(landings(guide().evaluate(population(), at: 2.5)) == landings(guide().evaluate(population(), at: 2.5)))
    }

    @Test func theOrderTimesWereAskedForDoesNotEnterTheResult() {
        let forward = guide()
        let scattered = guide()

        let expected = (0 ... 8).map { step in landings(forward.evaluate(population(), at: Double(step) / 2)) }
        for step in [5, 0, 8, 3, 1, 7, 2, 6, 4] {
            #expect(landings(scattered.evaluate(population(), at: Double(step) / 2)) == expected[step])
        }
    }

    @Test func aRebakeOfTheSameSourceAgreesWithTheFirst() {
        let guide = guide()
        let first = landings(guide.evaluate(population(), at: 2.5))
        guide.initialize(source: .preset(ThirdsPreset()), frame: frame, adhesion: 0.3, duration: 4, resolution: 128)

        #expect(landings(guide.evaluate(population(), at: 2.5)) == first)
    }
}
