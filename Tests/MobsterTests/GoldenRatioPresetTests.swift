import Testing
@testable import Mobster

struct GoldenRatioPresetTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))
    private let everyFocus: [PresetFocus] = [.minXMinY, .maxXMinY, .minXMaxY, .maxXMaxY]

    private func spiral(_ paths: [[SIMD2<Float>]]) -> [SIMD2<Float>] { paths[0] }
    private func quadlines(_ paths: [[SIMD2<Float>]]) -> [[SIMD2<Float>]] { Array(paths.dropFirst()) }

    private func extent(_ paths: [[SIMD2<Float>]]) -> (low: SIMD2<Float>, high: SIMD2<Float>) {
        let locations = paths.flatMap { $0 }
        return (SIMD2<Float>(locations.map(\.x).min()!, locations.map(\.y).min()!),
                SIMD2<Float>(locations.map(\.x).max()!, locations.map(\.y).max()!))
    }

    private func length(_ path: [SIMD2<Float>]) -> Float {
        zip(path, path.dropFirst()).reduce(0) { total, pair in
            let run = pair.1 - pair.0
            return total + (run.x * run.x + run.y * run.y).squareRoot()
        }
    }

    @Test func theSpiralIsReadFromTheResource() {
        let paths = GoldenRatioPreset(focus: .maxXMinY).paths(in: frame)

        #expect(spiral(paths).count == 289)
    }

    @Test func theNestedRectanglesArePlottedAlongsideTheSpiral() {
        let paths = GoldenRatioPreset(focus: .maxXMinY).paths(in: frame)

        #expect(quadlines(paths).count == 12)
        #expect(quadlines(paths).allSatisfy { $0.count == 5 })
        #expect(quadlines(paths).allSatisfy { $0.first! == $0.last! })
        #expect(quadlines(paths).allSatisfy { Set($0.map(\.x)).count == 2 && Set($0.map(\.y)).count == 2 })
    }

    @Test func eachNestedRectangleSitsInsideTheOneBefore() {
        let paths = GoldenRatioPreset(focus: .maxXMinY).paths(in: frame)

        #expect(!quadlines(paths).isEmpty)
        for (outer, inner) in zip(quadlines(paths), quadlines(paths).dropFirst()) {
            let outside = extent([outer])
            let inside = extent([inner])

            #expect(inside.low.x >= outside.low.x - 0.01)
            #expect(inside.low.y >= outside.low.y - 0.01)
            #expect(inside.high.x <= outside.high.x + 0.01)
            #expect(inside.high.y <= outside.high.y + 0.01)
        }
    }

    @Test(arguments: [PresetFocus.minXMinY, .maxXMinY, .minXMaxY, .maxXMaxY])
    func aQuadlineCornerCoincidesWithASpiralLocation(focus: PresetFocus) {
        let paths = GoldenRatioPreset(focus: focus).paths(in: frame)
        let locations = Set(spiral(paths).map { SIMD2<Float>(($0.x * 100).rounded(), ($0.y * 100).rounded()) })

        #expect(!quadlines(paths).isEmpty)
        for quadline in quadlines(paths) {
            let corners = quadline.map { SIMD2<Float>(($0.x * 100).rounded(), ($0.y * 100).rounded()) }
            #expect(corners.contains { locations.contains($0) })
        }
    }

    @Test func boundsPlottingEncompassesTheFrame() {
        let bounds = extent(GoldenRatioPreset(focus: .maxXMinY).paths(in: frame))

        #expect(bounds.low.x <= 0.01)
        #expect(bounds.low.y <= 0.01)
        #expect(bounds.high.x >= 99.99)
        #expect(bounds.high.y >= 99.99)
    }

    @Test(arguments: [PresetFocus.minXMinY, .maxXMinY, .minXMaxY, .maxXMaxY])
    func everyFocusHoldsTheStandardRatio(focus: PresetFocus) {
        let wide = Frame(origin: SIMD2<Float>(10, 20), size: SIMD2<Float>(300, 200))
        let bounds = extent(GoldenRatioPreset(focus: focus).paths(in: wide))

        #expect(abs((bounds.high.x - bounds.low.x) / (bounds.high.y - bounds.low.y) - 1.618034) < 0.001)
    }

    @Test func focusOrientsRatherThanScales() {
        let reference = GoldenRatioPreset(focus: .maxXMinY).paths(in: frame)

        for focus in everyFocus {
            let paths = GoldenRatioPreset(focus: focus).paths(in: frame)

            #expect(paths.map(\.count) == reference.map(\.count))
            #expect(abs(length(spiral(paths)) - length(spiral(reference))) < 0.01)
            #expect(abs((extent(paths).high.x - extent(paths).low.x) - (extent(reference).high.x - extent(reference).low.x)) < 0.01)
            #expect(abs((extent(paths).high.y - extent(paths).low.y) - (extent(reference).high.y - extent(reference).low.y)) < 0.01)
        }
    }

    @Test(arguments: [PresetFocus.minXMinY, .maxXMinY, .minXMaxY, .maxXMaxY])
    func theSpiralConvergesTowardTheSelectedCorner(focus: PresetFocus) {
        let paths = GoldenRatioPreset(focus: focus).paths(in: frame)
        let bounds = extent(paths)
        let middle = (bounds.low + bounds.high) / 2
        let eye = spiral(paths).last!

        #expect((eye.x < middle.x) == (focus == .minXMinY || focus == .minXMaxY))
        #expect((eye.y < middle.y) == (focus == .minXMinY || focus == .maxXMinY))
    }
}
