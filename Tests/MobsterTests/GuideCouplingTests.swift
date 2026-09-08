import Testing
@testable import Mobster

struct GuideCouplingTests {
    /// An epsilon of 0.71 derives a lattice of one unit texels across this Frame, so every vert below sits on a texel center and reads a target exactly forty units away along positive x.
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))
    private let duration: Double = 4
    private let epsilon: Float = 0.71
    private let anchor: Float = 24.5
    /// Forty units out against a reach of 288.4728, so the falloff carries all but 0.7545 of it.
    private let displacement: Float = 39.245476

    private func guide() throws -> Guide {
        let guide = Guide(frame: frame)
        let source = GuideSource.lines([Line(verts: [Vert(location: SIMD2<Float>(64.5, 0)), Vert(location: SIMD2<Float>(64.5, 128))])])
        try guide.initialize(source: source, frame: frame, adhesion: 0.1, duration: duration, settleEpsilon: epsilon, budget: .max)
        return guide
    }

    /// Every vert stands the same distance from the path, so a difference between two of them is a difference in how far along its travel each stands.
    private func line(_ couplings: [Float?], masses: [Float?]? = nil) -> [Line] {
        let verts = couplings.indices.map { index in
            Vert(
                location: SIMD2<Float>(anchor, Float(index) * 8 + 32.5),
                identifier: VertIdentifier(UInt64(index + 1)),
                mass: masses?[index],
                coupling: couplings[index]
            )
        }
        return [Line(verts: verts, identifier: LineIdentifier(1))]
    }

    private func xs(_ lines: [Line]) -> [Float] {
        lines[0].verts.map(\.location.x)
    }

    @Test func aLineOfUncoupledVertsIsUntouchedByTheFeature() throws {
        let guide = try guide()
        let supplied = line([nil, nil, nil, nil, nil])
        let together = xs(guide.evaluate(supplied, at: duration / 2))
        let apart = supplied[0].verts.map { guide.evaluate([Line(verts: [$0])], at: duration / 2)[0].verts[0].location.x }

        #expect(together.map(\.bitPattern) == apart.map(\.bitPattern))
        for standing in together {
            #expect(abs(standing - (anchor + displacement * 0.5)) < 1e-3)
        }
    }

    @Test func aCouplingAdvancesItsNeighboursAlongTheirOwnTravel() throws {
        let guide = try guide()
        let standing = xs(guide.evaluate(line([nil, 0.5, nil]), at: duration / 2))

        #expect(abs(standing[1] - 44.122738) < 1e-3)
        #expect(abs(standing[0] - 49.028423) < 1e-3)
        #expect(abs(standing[2] - 49.028423) < 1e-3)
    }

    @Test func theAdvanceDecaysWithDistanceAlongTheLine() throws {
        let guide = try guide()
        let standing = xs(guide.evaluate(line([nil, nil, 0.5, nil, nil]), at: duration / 2))

        #expect(abs(standing[1] - 49.028423) < 1e-3)
        #expect(abs(standing[3] - 49.028423) < 1e-3)
        #expect(abs(standing[0] - 46.575580) < 1e-3)
        #expect(abs(standing[4] - 46.575580) < 1e-3)
        #expect(standing[0] < standing[1])
        #expect(standing[4] < standing[3])
    }

    @Test func aNegativeCouplingRetardsItsNeighbours() throws {
        let guide = try guide()
        let standing = xs(guide.evaluate(line([nil, -0.5, nil]), at: duration / 2))

        #expect(abs(standing[0] - 39.217054) < 1e-3)
        #expect(abs(standing[2] - 39.217054) < 1e-3)
        #expect(standing[0] < 44.122738)
        #expect(standing[2] < 44.122738)
    }

    @Test func everyVertIsHomeAtTheDurationAcrossASpreadOfCouplings() throws {
        let guide = try guide()

        for coupling: Float in [-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1] {
            let uniform = [Float?](repeating: coupling, count: 5)
            for standing in xs(guide.evaluate(line(uniform), at: duration)) {
                #expect(abs(standing - (anchor + displacement)) < 1e-3)
            }
            for standing in xs(guide.evaluate(line(uniform), at: duration * 2)) {
                #expect(abs(standing - (anchor + displacement)) < 1e-3)
            }
        }
    }

    @Test func aVertReachedFromBothSidesAnswersTheSameWayWhicheverWayTheLineIsWalked() throws {
        let guide = try guide()
        let couplings: [Float?] = [0.75, nil, 0.5, -0.25, 0.9]
        let masses: [Float?] = [2, nil, 0.5, 3, 1]
        let forward = line(couplings, masses: masses)
        let backward = [Line(verts: forward[0].verts.reversed(), identifier: forward[0].identifier)]

        let walked = xs(guide.evaluate(forward, at: duration / 2))
        let unwalked = Array(xs(guide.evaluate(backward, at: duration / 2)).reversed())

        #expect(walked.map(\.bitPattern) == unwalked.map(\.bitPattern))
        #expect(walked[2] != walked[0])
    }
}
