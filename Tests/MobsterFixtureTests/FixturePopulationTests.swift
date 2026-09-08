import Mobster
import Testing
@testable import MobsterFixture

struct FixturePopulationTests {
    private let frame = Frame(origin: SIMD2<Float>(-30, 15), size: SIMD2<Float>(640, 480))

    private func parameters(seed: UInt64 = 7, lineCount: Int = 12, vertsPerLine: Int = 40) -> FixtureParameters {
        FixtureParameters(seed: seed, lineCount: lineCount, vertsPerLine: vertsPerLine, step: 0.03, turn: 35, margin: 0.1, spread: 0)
    }

    @Test func theCountsFollowTheParameters() {
        let strokes = LineFixture(parameters: parameters(lineCount: 9, vertsPerLine: 23)).lines(in: frame)

        #expect(strokes.count == 9)
        #expect(strokes.allSatisfy { $0.verts.count == 23 })
    }

    @Test func everyPointLandsInsideTheFrame() {
        let strokes = LineFixture(parameters: parameters()).lines(in: frame)
        let low = frame.origin
        let high = frame.origin + frame.size

        #expect(!strokes.isEmpty)
        for sample in strokes.flatMap(\.verts) {
            #expect(sample.location.x >= low.x && sample.location.x <= high.x)
            #expect(sample.location.y >= low.y && sample.location.y <= high.y)
        }
    }

    @Test func aLongerStepSpreadsTheStrokeFurther() {
        var tight = parameters(lineCount: 1)
        tight.step = 0.005
        var loose = tight
        loose.step = 0.05

        #expect(span(LineFixture(parameters: loose).lines(in: frame)) > span(LineFixture(parameters: tight).lines(in: frame)))
    }

    @Test func theMarginHoldsTheFirstPointOffTheEdge() {
        var parameters = parameters(lineCount: 40)
        parameters.margin = 0.25
        let inset = frame.size * parameters.margin
        let strokes = LineFixture(parameters: parameters).lines(in: frame)

        #expect(strokes.count == 40)
        for start in strokes.compactMap({ $0.verts.first }) {
            #expect(start.location.x >= frame.origin.x + inset.x)
            #expect(start.location.y >= frame.origin.y + inset.y)
            #expect(start.location.x <= frame.origin.x + frame.size.x - inset.x)
            #expect(start.location.y <= frame.origin.y + frame.size.y - inset.y)
        }
    }

    @Test func aTurnOfZeroWalksInAStraightLine() {
        var parameters = parameters(lineCount: 1, vertsPerLine: 4)
        parameters.turn = 0
        parameters.step = 0.01
        let samples = LineFixture(parameters: parameters).lines(in: frame)[0].verts
        let first = samples[1].location - samples[0].location
        let last = samples[3].location - samples[2].location

        #expect(abs(first.x - last.x) < 0.01)
        #expect(abs(first.y - last.y) < 0.01)
    }

    private func span(_ strokes: [Line]) -> Float {
        let locations = strokes.flatMap(\.verts).map(\.location)
        guard let seed = locations.first else { return 0 }
        var low = seed
        var high = seed
        for location in locations {
            low = low.replacing(with: location, where: location .< low)
            high = high.replacing(with: location, where: location .> high)
        }
        let extent = high - low
        return extent.x + extent.y
    }
}
