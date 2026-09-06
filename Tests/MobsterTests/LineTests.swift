import Testing
@testable import Mobster

struct LineTests {
    private func verts() -> [Vert] {
        (0 ..< 4).map { index in
            Vert(location: SIMD2<Float>(Float(index), 0), identifier: VertIdentifier(UInt64(index)))
        }
    }

    @Test func aLineRetainsTheOrderItsVertsArrivedIn() {
        let line = Line(verts: verts(), identifier: LineIdentifier(1))

        #expect(line.verts.map(\.identifier) == verts().map(\.identifier))
        #expect(line.verts.map(\.location) == verts().map(\.location))
    }

    @Test func aLineNeedsNoIdentifier() {
        #expect(Line(verts: verts()).identifier == nil)
    }

    @Test func aLineCarriesTheIdentifierItWasGiven() {
        #expect(Line(verts: [], identifier: LineIdentifier(9)).identifier == LineIdentifier(9))
    }
}
