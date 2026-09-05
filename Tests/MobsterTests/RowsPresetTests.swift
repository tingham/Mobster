import Testing
@testable import Mobster

struct RowsPresetTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(200, 100))

    @Test func fourRowsWithOneGutterWidthYieldSixLines() {
        let preset = RowsPreset(count: 4, gutter: 0.05)
        let paths = preset.paths(in: frame, mode: .aspect)

        #expect(paths.count == 6)
    }

    @Test func eachInteriorGutterContributesTwoEdges() {
        for count in 2 ... 8 {
            let preset = RowsPreset(count: count, gutter: 0.01)
            #expect(preset.paths(in: frame, mode: .aspect).count == 2 * (count - 1))
        }
    }

    @Test func edgesAscendAcrossTheFrame() {
        let paths = RowsPreset(count: 4, gutter: 0.05).paths(in: frame, mode: .aspect)
        let positions = paths.map { $0[0].y }

        #expect(positions == positions.sorted())
        #expect(positions.allSatisfy { $0 > frame.origin.y && $0 < frame.origin.y + frame.size.y })
    }

    @Test func linesSpanTheFullWidth() {
        let paths = RowsPreset(count: 4, gutter: 0.05).paths(in: frame, mode: .aspect)

        #expect(paths.allSatisfy { $0.count == 2 })
        #expect(paths.allSatisfy { $0[0].x == frame.origin.x })
        #expect(paths.allSatisfy { $0[1].x == frame.origin.x + frame.size.x })
    }
}
