import Testing
@testable import Mobster

struct GuideDeterminismTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    private func guide() throws -> Guide {
        let guide = Guide(frame: frame)
        try guide.initialize(source: .preset(ThirdsPreset()), frame: frame, adhesion: 0.3, duration: 4, settleEpsilon: 1, budget: .max)
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

    @Test func twoGuidesBuiltAlikeAgreeOnEveryVert() throws {
        #expect(landings(try guide().evaluate(population(), at: 2.5)) == landings(try guide().evaluate(population(), at: 2.5)))
    }

    @Test func theOrderTimesWereAskedForDoesNotEnterTheResult() throws {
        let forward = try guide()
        let scattered = try guide()

        let expected = (0 ... 8).map { step in landings(forward.evaluate(population(), at: Double(step) / 2)) }
        for step in [5, 0, 8, 3, 1, 7, 2, 6, 4] {
            #expect(landings(scattered.evaluate(population(), at: Double(step) / 2)) == expected[step])
        }
    }

    @Test func aRebakeOfTheSameSourceAgreesWithTheFirst() throws {
        let guide = try guide()
        let first = landings(guide.evaluate(population(), at: 2.5))
        try guide.initialize(source: .preset(ThirdsPreset()), frame: frame, adhesion: 0.3, duration: 4, settleEpsilon: 1, budget: .max)

        #expect(landings(guide.evaluate(population(), at: 2.5)) == first)
    }
}
