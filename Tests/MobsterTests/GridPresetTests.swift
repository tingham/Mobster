import Testing
@testable import Mobster

struct GridPresetTests {
    /// Not square, so a gutter resolved against the wrong axis lands somewhere the recorded positions below do not.
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 200))

    @Test func fourByFourWithOneGutterWidthYieldsTwelveLines() {
        let paths = GridPreset(count: 4, gutter: 0.05).paths(in: frame)

        #expect(paths.count == 12)
        #expect(paths.filter { $0[0].x == $0[1].x }.count == 6)
        #expect(paths.filter { $0[0].y == $0[1].y }.count == 6)
    }

    @Test func eachInteriorGutterContributesTwoEdgesOnEachAxis() {
        for count in 2 ... 8 {
            #expect(GridPreset(count: count, gutter: 0.01).paths(in: frame).count == 4 * (count - 1))
        }
    }

    @Test func oneDivisionHasNoInteriorGutter() {
        #expect(GridPreset(count: 1, gutter: 0.05).paths(in: frame).isEmpty)
    }

    @Test func edgesSitAtTheirDerivedPositions() {
        let paths = GridPreset(count: 4, gutter: 0.05).paths(in: frame)
        let derivedColumns: [Float] = [21.25, 26.25, 47.5, 52.5, 73.75, 78.75]
        let derivedRows: [Float] = [42.5, 52.5, 95, 105, 147.5, 157.5]

        #expect(paths.count == derivedColumns.count + derivedRows.count)
        for (path, expected) in zip(paths.prefix(6), derivedColumns) {
            #expect(abs(path[0].x - expected) < 0.001)
        }
        for (path, expected) in zip(paths.suffix(6), derivedRows) {
            #expect(abs(path[0].y - expected) < 0.001)
        }
    }

    @Test func aWiderGutterSitsAtItsDerivedPositions() {
        let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))
        let paths = GridPreset(count: 4, gutter: 0.1).paths(in: square)
        let derived: [Float] = [17.5, 27.5, 45, 55, 72.5, 82.5]

        for (path, expected) in zip(paths.prefix(6), derived) {
            #expect(abs(path[0].x - expected) < 0.001)
        }
        for (path, expected) in zip(paths.suffix(6), derived) {
            #expect(abs(path[0].y - expected) < 0.001)
        }
    }

    @Test func theTwoEdgesOfAGutterAreTheGutterWidthApart() {
        let paths = GridPreset(count: 4, gutter: 0.05).paths(in: frame)
        let columns = paths.prefix(6).map { $0[0].x }
        let rows = paths.suffix(6).map { $0[0].y }

        for pair in stride(from: 0, to: 6, by: 2) {
            #expect(abs((columns[pair + 1] - columns[pair]) - 5) < 0.001)
            #expect(abs((rows[pair + 1] - rows[pair]) - 10) < 0.001)
        }
    }

    @Test func columnsSpanTheHeightAndRowsSpanTheWidth() {
        let paths = GridPreset(count: 4, gutter: 0.05).paths(in: frame)

        #expect(paths.allSatisfy { $0.count == 2 })
        for path in paths.prefix(6) {
            #expect(path[0].y == frame.origin.y)
            #expect(path[1].y == frame.origin.y + frame.size.y)
        }
        for path in paths.suffix(6) {
            #expect(path[0].x == frame.origin.x)
            #expect(path[1].x == frame.origin.x + frame.size.x)
        }
    }

    @Test func edgesAscendAcrossTheFrame() {
        let paths = GridPreset(count: 4, gutter: 0.05).paths(in: frame)
        let columns = paths.prefix(6).map { $0[0].x }
        let rows = paths.suffix(6).map { $0[0].y }

        #expect(columns == columns.sorted())
        #expect(rows == rows.sorted())
        #expect(columns.allSatisfy { $0 > frame.origin.x && $0 < frame.origin.x + frame.size.x })
        #expect(rows.allSatisfy { $0 > frame.origin.y && $0 < frame.origin.y + frame.size.y })
    }

    @Test func itConstructsInAspectMode() {
        #expect(GridPreset(count: 4, gutter: 0.05).mode == .aspect)
    }

    /// The origin is off zero so a sequence recorded from a preset that ignored it would not match.
    @Test func itMatchesItsRecordedSequence() {
        let offset = Frame(origin: SIMD2<Float>(-30, 15), size: SIMD2<Float>(640, 480))
        let recorded: [[SIMD2<Float>]] = [
            [SIMD2<Float>(106, 15), SIMD2<Float>(106, 495)],
            [SIMD2<Float>(138, 15), SIMD2<Float>(138, 495)],
            [SIMD2<Float>(274, 15), SIMD2<Float>(274, 495)],
            [SIMD2<Float>(306, 15), SIMD2<Float>(306, 495)],
            [SIMD2<Float>(442, 15), SIMD2<Float>(442, 495)],
            [SIMD2<Float>(474, 15), SIMD2<Float>(474, 495)],
            [SIMD2<Float>(-30, 117), SIMD2<Float>(610, 117)],
            [SIMD2<Float>(-30, 141), SIMD2<Float>(610, 141)],
            [SIMD2<Float>(-30, 243), SIMD2<Float>(610, 243)],
            [SIMD2<Float>(-30, 267), SIMD2<Float>(610, 267)],
            [SIMD2<Float>(-30, 369), SIMD2<Float>(610, 369)],
            [SIMD2<Float>(-30, 393), SIMD2<Float>(610, 393)],
        ]
        let paths = GridPreset(count: 4, gutter: 0.05).paths(in: offset)

        #expect(paths.count == recorded.count)
        for (path, expected) in zip(paths, recorded) {
            for (location, target) in zip(path, expected) {
                #expect(abs(location.x - target.x) < 0.01)
                #expect(abs(location.y - target.y) < 0.01)
            }
        }
    }

    @Test func repeatedPlotsAreIdentical() {
        let preset = GridPreset(count: 5, gutter: 0.03)

        #expect(preset.paths(in: frame) == preset.paths(in: frame))
    }
}
