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

    @Test func divisionsAndGuttersFillTheExtent() {
        let count = 5
        let gutter: Float = 0.04
        let edges = PresetGutter(count: count, gutter: gutter, extent: 1).edges()
        let division = (1 - Float(count - 1) * gutter) / Float(count)

        #expect(abs(edges.first! - division) < 0.0001)
        #expect(abs(edges.last! - (1 - division)) < 0.0001)
    }

    @Test func fewerThanTwoDivisionsHaveNoGutter() {
        #expect(PresetGutter(count: 1, gutter: 0.05, extent: 1).edges().isEmpty)
        #expect(PresetGutter(count: 0, gutter: 0.05, extent: 1).edges().isEmpty)
    }
}
