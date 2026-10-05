import Foundation
import Testing
@testable import Mobster

/// The view every guide type built from a mesh carries, read the same way on each of them: the location it points at, the roll about the direction it points, and the two limits the derivation holds.
struct PresetViewTests {
    /// Five hundred and twelve square, which puts the centre of the Frame and a half sized box on whole numbers.
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512))
    /// Level and out of the construction, which reads it frontally.
    private let frontal = SIMD3<Float>(0, 0, 1)
    /// Radians. A quarter turn exchanges the axes of the plane, which is the plainest reading a roll gives.
    private let quarter = Float.pi / 2
    /// The centre of the Frame, which the cube's placement stands the box on.
    private let centre = SIMD3<Float>(256, 256, 0)
    /// Half the body diagonal of a half sized box on a five hundred and twelve square, which every corner stands at from the centre however the box is turned.
    private let diagonal: Float = 221.7025

    private func head(target: SIMD3<Float>, roll: Float) -> Mesh {
        HeadPreset(sex: .male, target: target, roll: roll).mesh(in: square)
    }

    private func figure(target: SIMD3<Float>, roll: Float) -> FigurePreset {
        FigurePreset(sex: .male,
                     heads: 8,
                     target: target,
                     roll: roll,
                     headTarget: frontal,
                     leftHand: SIMD2<Float>(0.31, 0.5),
                     rightHand: SIMD2<Float>(0.69, 0.5),
                     leftFoot: SIMD2<Float>(0.42, 1),
                     rightFoot: SIMD2<Float>(0.58, 1),
                     headLines: true)
    }

    private func cube(target: SIMD3<Float>, roll: Float) -> Mesh {
        CubeMesh(position: SIMD2<Float>(0.5, 0.5), size: 0.5, target: target, roll: roll).mesh(in: square)
    }

    private func locations(_ mesh: Mesh) -> [SIMD3<Float>] {
        mesh.triangles.flatMap { [$0.first, $0.second, $0.third] }
    }

    private func locations(_ mesh: Mesh, identities: ClosedRange<UInt32>) throws -> [SIMD3<Float>] {
        let standing = mesh.triangles.filter { identities.contains($0.identity.value) }.flatMap { [$0.first, $0.second, $0.third] }

        return try #require(standing.isEmpty ? nil : standing, "the construction carries these identities")
    }

    private func spans(_ locations: [SIMD3<Float>]) -> (SIMD3<Float>, SIMD3<Float>) {
        (SIMD3<Float>(locations.map(\.x).min()!, locations.map(\.y).min()!, locations.map(\.z).min()!),
         SIMD3<Float>(locations.map(\.x).max()!, locations.map(\.y).max()!, locations.map(\.z).max()!))
    }

    private func meets(_ location: SIMD3<Float>, _ expected: SIMD3<Float>) -> Bool {
        abs(location.x - expected.x) < 0.01 && abs(location.y - expected.y) < 0.01 && abs(location.z - expected.z) < 0.01
    }

    /// The spans recorded here are what the construction stood at before a roll was one of its parameters, so a roll of zero that moved anything reports.
    @Test func aRollOfZeroLeavesTheHeadWhereItStood() throws {
        let (least, most) = spans(try locations(head(target: frontal, roll: 0), identities: 1 ... 8))

        #expect(meets(least, SIMD3<Float>(122.7034, 0, -172.1379)))
        #expect(meets(most, SIMD3<Float>(389.2966, 384.8828, 172.1379)))
    }

    /// The spans recorded here are what the construction stood at before a roll was one of its parameters, so a roll of zero that moved anything reports.
    @Test func aRollOfZeroLeavesTheFigureWhereItStood() {
        let (least, most) = spans(locations(figure(target: frontal, roll: 0).mesh(in: square)))

        #expect(meets(least, SIMD3<Float>(149.7918, 0, -48.5264)))
        #expect(meets(most, SIMD3<Float>(362.2083, 516.8318, 64)))
    }

    /// The spans recorded here are what the construction stood at before a roll was one of its parameters, so a roll of zero that moved anything reports.
    @Test func aRollOfZeroLeavesTheCubeWhereItStood() {
        let (least, most) = spans(locations(cube(target: frontal, roll: 0)))

        #expect(meets(least, SIMD3<Float>(128, 128, -128)))
        #expect(meets(most, SIMD3<Float>(384, 384, 128)))
    }

    /// A neck does not turn when the head within it does, so it is the part of this construction a roll does not reach.
    @Test func aRollTurnsTheHeadAndLeavesTheNeckUpright() throws {
        let standing = head(target: frontal, roll: 0)
        let rolled = head(target: frontal, roll: quarter)

        #expect(try locations(rolled, identities: 11 ... 12) == locations(standing, identities: 11 ... 12))
        #expect(try locations(rolled, identities: 1 ... 8) != locations(standing, identities: 1 ... 8))
    }

    /// The head breaks measure the figure rather than belonging to it, so they are the part of this construction a roll does not reach. A quarter turn carries the ribcage onto the exchanged axes, which is the turn read without a recorded number.
    @Test func aRollTurnsTheFigureAndLeavesItsBreakLinesWhereTheyMeasure() throws {
        let standing = figure(target: frontal, roll: 0)
        let rolled = figure(target: frontal, roll: quarter)
        let (least, most) = spans(try locations(standing.mesh(in: square), identities: 3 ... 4))
        let (rolledLeast, rolledMost) = spans(try locations(rolled.mesh(in: square), identities: 3 ... 4))

        #expect(abs(rolledLeast.x - least.y) < 0.01)
        #expect(abs(rolledMost.x - most.y) < 0.01)
        #expect(abs(rolledLeast.y - least.x) < 0.01)
        #expect(abs(rolledMost.y - most.x) < 0.01)
        #expect(rolled.breakLines(in: square).map { $0.verts.map(\.location) } == standing.breakLines(in: square).map { $0.verts.map(\.location) })
    }

    /// The box is positioned and sized within the Frame rather than filling it, so that placement is the part of this construction a roll does not reach: every corner stands where it stood from the centre, and the triangles it stands on do not.
    @Test func aRollTurnsTheCubeAboutThePlacementItStandsOn() {
        let standing = cube(target: frontal, roll: 0)
        let rolled = cube(target: frontal, roll: quarter / 2)
        let reach = locations(rolled).map { ((($0 - centre) * ($0 - centre)).sum()).squareRoot() }

        #expect(reach.allSatisfy { abs($0 - diagonal) < 0.01 })
        #expect(locations(standing).allSatisfy { abs(((($0 - centre) * ($0 - centre)).sum()).squareRoot() - diagonal) < 0.01 })
        #expect(rolled != standing)
    }

    /// A target forty five degrees above level and one steeper than it give the same construction, the steeper one being held at the limit, where one inside the limit gives another.
    @Test func forwardIsHeldWithinFortyFiveDegreesOfLevelOnEveryConstruction() {
        let limit = SIMD3<Float>(0, -1, 1)
        let steeper = SIMD3<Float>(0, -4, 1)
        let shallower = SIMD3<Float>(0, -0.5, 1)

        #expect(head(target: limit, roll: 0) == head(target: steeper, roll: 0))
        #expect(head(target: limit, roll: 0) != head(target: shallower, roll: 0))
        #expect(figure(target: limit, roll: 0).mesh(in: square) == figure(target: steeper, roll: 0).mesh(in: square))
        #expect(figure(target: limit, roll: 0).mesh(in: square) != figure(target: shallower, roll: 0).mesh(in: square))
        #expect(cube(target: limit, roll: 0) == cube(target: steeper, roll: 0))
        #expect(cube(target: limit, roll: 0) != cube(target: shallower, roll: 0))
    }

    /// A target on the vertical through the construction carries no azimuth to face, and one at the construction's own location carries no direction at all. The held run stands both of them out along the depth, where an unheld run leaves every location a NaN.
    @Test(arguments: [SIMD3<Float>(0, -1, 0), SIMD3<Float>(0, 1, 0), SIMD3<Float>(0, 0, 0)])
    func aTargetWithNoRunIsHeldOffTheVerticalOnEveryConstruction(target: SIMD3<Float>) {
        let meshes = [head(target: target, roll: 0), figure(target: target, roll: 0).mesh(in: square), cube(target: target, roll: 0)]

        #expect(meshes.allSatisfy { !$0.triangles.isEmpty })
        #expect(meshes.allSatisfy { mesh in locations(mesh).allSatisfy { $0.x.isFinite && $0.y.isFinite && $0.z.isFinite } })
    }
}
