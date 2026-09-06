import Foundation
import Mobster

/// A population of wandering strokes for a Guide to act on, minted and plotted by the consumer's stand in.
public struct StrokeFixture: Sendable {
    public let parameters: FixtureParameters

    public init(parameters: FixtureParameters) {
        self.parameters = parameters
    }

    public func strokes(in frame: Frame) -> [Stroke] {
        var random = FixtureRandom(seed: parameters.seed)
        var identity = FixtureIdentitySequence()
        let count = max(parameters.strokeCount, 0)
        var population: [Stroke] = []
        population.reserveCapacity(count)

        for _ in 0 ..< count {
            population.append(stroke(in: frame, random: &random, identity: &identity))
        }

        return population
    }

    private func stroke(in frame: Frame, random: inout FixtureRandom, identity: inout FixtureIdentitySequence) -> Stroke {
        let identifier = identity.stroke()
        let inset = frame.size * parameters.margin
        let usable = frame.size - inset * 2
        let step = min(frame.size.x, frame.size.y) * parameters.step
        let turn = parameters.turn * Float.pi / 180
        var location = frame.origin + inset + SIMD2<Float>(random.unit() * usable.x, random.unit() * usable.y)
        var heading = random.unit() * 2 * Float.pi
        let count = max(parameters.pointsPerStroke, 0)
        var samples: [Sample] = []
        samples.reserveCapacity(count)

        for index in 0 ..< count {
            if index > 0 {
                heading += (random.unit() * 2 - 1) * turn
                let advanced = location + SIMD2<Float>(cos(heading), sin(heading)) * step
                (location, heading) = Self.reflected(advanced, heading: heading, in: frame)
            }
            samples.append(Sample(identifier: identity.point(), location: location))
        }

        return Stroke(identifier: identifier, samples: samples)
    }

    /// A step leaving the Frame mirrors on the edge it crossed, so a run turns back instead of piling along the edge. The clamp catches a step long enough to clear the far edge in one move.
    private static func reflected(_ location: SIMD2<Float>, heading: Float, in frame: Frame) -> (SIMD2<Float>, Float) {
        let low = frame.origin
        let high = frame.origin + frame.size
        var landed = location
        var direction = SIMD2<Float>(cos(heading), sin(heading))

        for axis in 0 ... 1 {
            if landed[axis] < low[axis] {
                landed[axis] = low[axis] + (low[axis] - landed[axis])
                direction[axis] = -direction[axis]
            } else if landed[axis] > high[axis] {
                landed[axis] = high[axis] - (landed[axis] - high[axis])
                direction[axis] = -direction[axis]
            }
        }

        return (landed.clamped(lowerBound: low, upperBound: high), atan2(direction.y, direction.x))
    }
}
