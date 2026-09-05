import Testing
@testable import Mobster

struct AdherenceTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))
    /// A texel centre forty units to the left of the vertical path below, so the field reports a distance of forty exactly.
    private let point = SIMD2<Float>(24.5, 64.5)
    private let onPath = SIMD2<Float>(64.5, 64.5)

    private func field() -> Field {
        FieldBake(paths: [[SIMD2<Float>(64.5, 0), SIMD2<Float>(64.5, 128)]], frame: frame, resolution: 128).field()
    }

    private func near(_ value: SIMD2<Float>, _ expected: SIMD2<Float>) -> Bool {
        abs(value.x - expected.x) < 1e-3 && abs(value.y - expected.y) < 1e-3
    }

    @Test func fieldReportsTheDistanceTheDerivationAssumes() {
        #expect(abs(field().distance(at: point) - 40) < 1e-3)
        #expect(near(field().direction(at: point), SIMD2<Float>(1, 0)))
    }

    @Test func weightIsOneOverOnePlusTheSquareOfDistanceOverReach() {
        let adherence = Adherence(reach: 40)

        #expect(adherence.weight(distance: 0) == 1)
        #expect(abs(adherence.weight(distance: 40) - 0.5) < 1e-6)
        #expect(abs(adherence.weight(distance: 80) - 0.2) < 1e-6)
    }

    @Test func pointFarFromEveryPathSettlesShortOfIt() {
        #expect(near(Adherence(reach: 40).target(for: point, in: field()), SIMD2<Float>(44.5, 64.5)))
        #expect(near(Adherence(reach: 20).target(for: point, in: field()), SIMD2<Float>(32.5, 64.5)))
    }

    @Test func fullReachSnapsOntoTheNearestPathLocation() {
        #expect(near(Adherence(reach: .infinity).target(for: point, in: field()), onPath))
    }

    @Test func collapsedReachDisplacesNothing() {
        let adherence = Adherence(reach: 0)

        #expect(adherence.weight(distance: 40) == 0)
        #expect(adherence.target(for: point, in: field()) == point)
        #expect(adherence.target(for: onPath, in: field()) == onPath)
    }

    @Test func pointAtAPathLocationResolvesToItself() {
        #expect(Adherence(reach: 40).target(for: onPath, in: field()) == onPath)
    }

    @Test func emptyFieldResolvesToTheLocation() {
        let empty = FieldBake(paths: [], frame: frame, resolution: 128).field()

        #expect(Adherence(reach: 40).target(for: point, in: empty) == point)
    }
}
