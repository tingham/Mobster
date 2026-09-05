import Testing
@testable import Mobster

struct IdentifierTests {
    @Test func pointIdentifierEquality() {
        #expect(PointIdentifier(7) == PointIdentifier(7))
        #expect(PointIdentifier(7) != PointIdentifier(8))
    }

    @Test func strokeIdentifierEquality() {
        #expect(StrokeIdentifier(7) == StrokeIdentifier(7))
        #expect(StrokeIdentifier(7) != StrokeIdentifier(8))
    }

    @Test func pointIdentifierHashing() {
        #expect(PointIdentifier(7).hashValue == PointIdentifier(7).hashValue)

        var seen: Set<PointIdentifier> = []
        seen.insert(PointIdentifier(7))
        seen.insert(PointIdentifier(7))
        seen.insert(PointIdentifier(8))
        #expect(seen.count == 2)
    }

    @Test func strokeIdentifierHashing() {
        #expect(StrokeIdentifier(7).hashValue == StrokeIdentifier(7).hashValue)

        var keyed: [StrokeIdentifier: Int] = [:]
        keyed[StrokeIdentifier(7)] = 1
        keyed[StrokeIdentifier(7)] = 2
        keyed[StrokeIdentifier(8)] = 3
        #expect(keyed.count == 2)
        #expect(keyed[StrokeIdentifier(7)] == 2)
    }
}
