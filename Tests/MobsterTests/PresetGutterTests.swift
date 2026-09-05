import Testing
@testable import Mobster

struct PresetGutterTests {
    @Test func fourColumnsWithOneGutterWidthYieldSixEdges() {
        #expect(PresetGutter(count: 4, gutter: 0.05, extent: 1).edges().count == 6)
    }

    @Test func aGutterIsABandWithTwoEdges() {
        let edges = PresetGutter(count: 2, gutter: 0.2, extent: 1).edges()

        #expect(edges.count == 2)
        #expect(abs(edges[0] - 0.4) < 0.0001)
        #expect(abs(edges[1] - 0.6) < 0.0001)
    }

    @Test func edgesSitAtTheirDerivedPositions() {
        let edges = PresetGutter(count: 5, gutter: 0.04, extent: 1).edges()
        let derived: [Float] = [0.168, 0.208, 0.376, 0.416, 0.584, 0.624, 0.792, 0.832]

        #expect(edges.count == derived.count)
        for (edge, expected) in zip(edges, derived) {
            #expect(abs(edge - expected) < 0.0001)
        }
    }

    @Test func fewerThanTwoDivisionsHaveNoGutter() {
        #expect(PresetGutter(count: 1, gutter: 0.05, extent: 1).edges().isEmpty)
        #expect(PresetGutter(count: 0, gutter: 0.05, extent: 1).edges().isEmpty)
    }
}
