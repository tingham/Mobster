import Testing
@testable import Mobster

struct ColumnsPresetTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 200))

    @Test func fourColumnsWithOneGutterWidthYieldSixLines() {
        let preset = ColumnsPreset(count: 4, gutter: 0.05)
        let paths = preset.paths(in: frame, mode: .aspect)

        #expect(paths.count == 6)
    }

    @Test func eachInteriorGutterContributesTwoEdges() {
        for count in 2 ... 8 {
            let preset = ColumnsPreset(count: count, gutter: 0.01)
            #expect(preset.paths(in: frame, mode: .aspect).count == 2 * (count - 1))
        }
    }

    @Test func oneColumnHasNoInteriorGutter() {
        #expect(ColumnsPreset(count: 1, gutter: 0.05).paths(in: frame, mode: .aspect).isEmpty)
    }

    @Test func edgesAscendAcrossTheFrame() {
        let paths = ColumnsPreset(count: 4, gutter: 0.05).paths(in: frame, mode: .aspect)
        let positions = paths.map { $0[0].x }

        #expect(positions == positions.sorted())
        #expect(positions.allSatisfy { $0 > frame.origin.x && $0 < frame.origin.x + frame.size.x })
    }

    @Test func theTwoEdgesOfAGutterAreTheGutterWidthApart() {
        let paths = ColumnsPreset(count: 4, gutter: 0.05).paths(in: frame, mode: .aspect)
        let positions = paths.map { $0[0].x }

        #expect(abs((positions[1] - positions[0]) - 5) < 0.001)
        #expect(abs((positions[3] - positions[2]) - 5) < 0.001)
        #expect(abs((positions[5] - positions[4]) - 5) < 0.001)
    }

    @Test func columnsAreEvenlySpread() {
        let paths = ColumnsPreset(count: 4, gutter: 0.05).paths(in: frame, mode: .aspect)
        let positions = paths.map { $0[0].x }
        let firstStride = positions[2] - positions[0]
        let secondStride = positions[4] - positions[2]

        #expect(abs(firstStride - secondStride) < 0.001)
    }

    @Test func linesSpanTheFullHeight() {
        let paths = ColumnsPreset(count: 4, gutter: 0.05).paths(in: frame, mode: .aspect)

        #expect(paths.allSatisfy { $0.count == 2 })
        #expect(paths.allSatisfy { $0[0].y == frame.origin.y })
        #expect(paths.allSatisfy { $0[1].y == frame.origin.y + frame.size.y })
    }
}
