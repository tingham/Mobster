import Mobster
import Testing
@testable import MobsterFixture

struct FixturePopulationTests {
    private let frame = Frame(origin: SIMD2<Float>(-30, 15), size: SIMD2<Float>(640, 480))

    private func parameters(seed: UInt64 = 7, strokeCount: Int = 12, pointsPerStroke: Int = 40) -> FixtureParameters {
        FixtureParameters(seed: seed, strokeCount: strokeCount, pointsPerStroke: pointsPerStroke, step: 0.03, turn: 35, margin: 0.1)
    }

    @Test func theCountsFollowTheParameters() {
        let strokes = StrokeFixture(parameters: parameters(strokeCount: 9, pointsPerStroke: 23)).strokes(in: frame)

        #expect(strokes.count == 9)
        #expect(strokes.allSatisfy { $0.samples.count == 23 })
    }

    @Test func everyPointLandsInsideTheFrame() {
        let strokes = StrokeFixture(parameters: parameters()).strokes(in: frame)
        let low = frame.origin
        let high = frame.origin + frame.size

        #expect(!strokes.isEmpty)
        for sample in strokes.flatMap(\.samples) {
            #expect(sample.location.x >= low.x && sample.location.x <= high.x)
            #expect(sample.location.y >= low.y && sample.location.y <= high.y)
        }
    }

    @Test func aLongerStepSpreadsTheStrokeFurther() {
        var tight = parameters(strokeCount: 1)
        tight.step = 0.005
        var loose = tight
        loose.step = 0.05

        #expect(span(StrokeFixture(parameters: loose).strokes(in: frame)) > span(StrokeFixture(parameters: tight).strokes(in: frame)))
    }

    @Test func theMarginHoldsTheFirstPointOffTheEdge() {
        var parameters = parameters(strokeCount: 40)
        parameters.margin = 0.25
        let inset = frame.size * parameters.margin
        let strokes = StrokeFixture(parameters: parameters).strokes(in: frame)

        #expect(strokes.count == 40)
        for start in strokes.compactMap({ $0.samples.first }) {
            #expect(start.location.x >= frame.origin.x + inset.x)
            #expect(start.location.y >= frame.origin.y + inset.y)
            #expect(start.location.x <= frame.origin.x + frame.size.x - inset.x)
            #expect(start.location.y <= frame.origin.y + frame.size.y - inset.y)
        }
    }

    @Test func aTurnOfZeroWalksInAStraightLine() {
        var parameters = parameters(strokeCount: 1, pointsPerStroke: 4)
        parameters.turn = 0
        parameters.step = 0.01
        let samples = StrokeFixture(parameters: parameters).strokes(in: frame)[0].samples
        let first = samples[1].location - samples[0].location
        let last = samples[3].location - samples[2].location

        #expect(abs(first.x - last.x) < 0.01)
        #expect(abs(first.y - last.y) < 0.01)
    }

    private func span(_ strokes: [Stroke]) -> Float {
        let locations = strokes.flatMap(\.samples).map(\.location)
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
