import Foundation
import Testing
@testable import Mobster

struct HeadPresetTests {
    /// A hundred square, so a design fraction reads as a percentage and the construction keeps true proportion.
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))
    /// Half again wider than it is tall, so a construction stretched to the axes would read fifty percent broad.
    private let wide = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 400))
    /// Level and out of the face, which reads the head frontally.
    private let frontal = SIMD3<Float>(0, 0, 1)

    /// The locations an identity carries, which reports rather than trapping where a division that should exist does not.
    private func locations(_ mesh: Mesh, identities: ClosedRange<UInt32>) throws -> [SIMD3<Float>] {
        let standing = mesh.triangles.filter { identities.contains($0.identity.value) }.flatMap { [$0.first, $0.second, $0.third] }

        return try #require(standing.isEmpty ? nil : standing, "the construction carries these identities")
    }

    /// The breadth a form spans at one of its levels.
    private func width(_ locations: [SIMD3<Float>], at level: Float) -> Float {
        let standing = locations.filter { abs($0.y - level) < 0.01 }.map(\.x)

        return (standing.max() ?? 0) - (standing.min() ?? 0)
    }

    /// The breadth of the chin block where it meets the jaw angles and at its base, each as a fraction of the head's own breadth.
    private func chinBreadths(_ sex: HeadSex) throws -> (top: Float, base: Float) {
        let mesh = HeadPreset(sex: sex, target: frontal, roll: 0).mesh(in: square)
        let block = try locations(mesh, identities: 10 ... 10)
        let mass = try locations(mesh, identities: 1 ... 8).map(\.x)
        let across = mass.max()! - mass.min()!

        return (width(block, at: block.map(\.y).min()!) / across, width(block, at: block.map(\.y).max()!) / across)
    }

    /// Four bands of breadth divided at the brow, a jaw, a chin and two halves of neck.
    @Test func theConstructionIsAFewScoreTriangles() {
        let mesh = HeadPreset(sex: .male, target: frontal, roll: 0).mesh(in: square)

        #expect(mesh.triangles.count == 90)
        #expect(Set(mesh.triangles.map(\.identity.value)) == Set(1 ... 12))
    }

    /// Head breadth over head height is 151 over 232, and the shoulder drop lays that height into eight tenths of the design square, so the mass stands 26.034 either side of the middle. Vertex to nasion puts the brow at 37.586 and the underside of the mass at 75.172, and head length puts it 33.621 deep.
    @Test func theCranialMassStandsWhereTheCanonPutsIt() throws {
        let mass = try locations(HeadPreset(sex: .male, target: frontal, roll: 0).mesh(in: square), identities: 1 ... 8)

        #expect(abs(mass.map(\.x).min()! - 23.966) < 0.01)
        #expect(abs(mass.map(\.x).max()! - 76.034) < 0.01)
        #expect(abs(mass.map(\.y).min()!) < 0.01)
        #expect(abs(mass.map(\.y).max()! - 75.172) < 0.01)
        #expect(abs(mass.map(\.z).max()! - 33.621) < 0.01)
    }

    /// The cut at the temple breadth is a division rather than a truncation, so the mass keeps the euryon breadth. Frontotemporale over head height stands the side planes 19.138 either side of the middle, which is 0.678 of the mass across.
    @Test func theSidePlanesDivideTheMassRatherThanTruncatingIt() throws {
        let mesh = HeadPreset(sex: .male, target: frontal, roll: 0).mesh(in: square)
        let right = try locations(mesh, identities: 3 ... 4)
        let cap = try locations(mesh, identities: 1 ... 2)

        #expect(abs(right.map(\.x).max()! - 69.138) < 0.01)
        #expect(abs(right.map(\.x).min()! - 50) < 0.01)
        #expect(abs(cap.map(\.x).max()! - 76.034) < 0.01)
        #expect(abs(cap.map(\.x).min()! - 69.138) < 0.01)
    }

    /// The brow divides every band of breadth, so the half below it reaches the underside of the mass and the half above it reaches the crown, both meeting at the level of nasion.
    @Test func theBrowDividesEveryBandOfBreadth() throws {
        let mesh = HeadPreset(sex: .male, target: frontal, roll: 0).mesh(in: square)
        let under = try locations(mesh, identities: 5 ... 5)
        let over = try locations(mesh, identities: 6 ... 6)


        #expect(abs(under.map(\.y).min()! - 37.586) < 0.01)
        #expect(abs(under.map(\.y).max()! - 75.172) < 0.01)
        #expect(abs(over.map(\.y).min()!) < 0.01)
        #expect(abs(over.map(\.y).max()! - 37.586) < 0.01)
    }

    /// Bigonial breadth carries the jaw angle 18.276 off the middle at a level of 63.448. The chin block stands at the front of the mass and runs from 56.379, which is halfway from the underside of the mass at 75.172 to its middle at 37.586, down to gnathion at 80.
    @Test func theJawAndTheChinStandWhereTheCanonPutsThem() throws {
        let mesh = HeadPreset(sex: .male, target: frontal, roll: 0).mesh(in: square)
        let jaw = try locations(mesh, identities: 9 ... 9)
        let chin = try locations(mesh, identities: 10 ... 10)

        #expect(abs(jaw.map(\.x).max()! - 68.276) < 0.01)
        #expect(abs(jaw.map(\.y).min()! - 56.379) < 0.01)
        #expect(abs(jaw.map(\.y).max()! - 80) < 0.01)
        #expect(abs(chin.map(\.x).max()! - 68.276) < 0.01)
        #expect(abs(chin.map(\.y).min()! - 56.379) < 0.01)
        #expect(abs(chin.map(\.y).max()! - 80) < 0.01)
        #expect(abs(chin.map(\.z).min()! - 33.621) < 0.01)
    }

    /// As fractions of the head's own breadth the jaw angles are 0.702 for a man and 0.681 for a woman and the mouth is 0.351 and 0.347, so the block is half again narrower at its base than where it meets the jaw angles and the sexes differ by less than a hundredth at either end.
    @Test func theChinBlockIsAsWideAsTheJawAnglesAboveAndTheMouthBelow() throws {
        let man = try chinBreadths(.male)
        let woman = try chinBreadths(.female)

        #expect(abs(man.top - 0.702) < 0.001)
        #expect(abs(man.base - 0.351) < 0.001)
        #expect(abs(woman.top - 0.681) < 0.001)
        #expect(abs(woman.base - 0.347) < 0.001)
    }

    /// The neck circumference read as a circular section puts its radius 20.855 off the middle, and it runs from the jaw angles to the shoulder line the design square is measured to.
    @Test func theNeckStandsOnItsCircumferenceAlone() throws {
        let neck = try locations(HeadPreset(sex: .male, target: frontal, roll: 0).mesh(in: square), identities: 11 ... 12)

        #expect(abs(neck.map(\.x).min()! - 29.145) < 0.01)
        #expect(abs(neck.map(\.x).max()! - 70.855) < 0.01)
        #expect(abs(neck.map(\.y).min()! - 63.448) < 0.01)
        #expect(abs(neck.map(\.y).max()! - 100) < 0.01)
    }

    /// A neck does not turn when the head within it does, so it is the one part the basis does not carry.
    @Test func theNeckDoesNotTurnWithTheHead() throws {
        let straight = HeadPreset(sex: .male, target: frontal, roll: 0).mesh(in: square)
        let turned = HeadPreset(sex: .male, target: SIMD3<Float>(1, 0, 1), roll: 0.5).mesh(in: square)
        let standing = try locations(straight, identities: 11 ... 12)
        let carried = try locations(turned, identities: 11 ... 12)
        let straightMass = try locations(straight, identities: 1 ... 8)
        let turnedMass = try locations(turned, identities: 1 ... 8)

        #expect(standing == carried)
        #expect(straightMass != turnedMass)
    }

    /// The brow line sits at the vertex to nasion fraction of the head height, which is 0.470 of it for a man and 0.486 for a woman, and bigonial breadth carries the jaw angle 18.276 off the middle for a man and 17.982 for a woman.
    @Test func sexChangesTheProportions() throws {
        let male = HeadPreset(sex: .male, target: frontal, roll: 0).mesh(in: square)
        let female = HeadPreset(sex: .female, target: frontal, roll: 0).mesh(in: square)
        let maleBrow = try locations(male, identities: 6 ... 6)
        let femaleBrow = try locations(female, identities: 6 ... 6)
        let maleJaw = try locations(male, identities: 9 ... 9)
        let femaleJaw = try locations(female, identities: 9 ... 9)

        #expect(abs(maleBrow.map(\.y).max()! - 37.586) < 0.01)
        #expect(abs(femaleBrow.map(\.y).max()! - 38.899) < 0.01)
        #expect(abs(maleJaw.map(\.x).max()! - 68.276) < 0.01)
        #expect(abs(femaleJaw.map(\.x).max()! - 67.982) < 0.01)
    }

    /// Head breadth over head height is 151 over 232 and the shoulder drop lays that height into eight tenths of the design square, so a Frame six hundred by four hundred carries vertex to gnathion at 320 and the breadth at 208.276, the mass standing from 195.862 to 404.138 about the middle. Stretching to the axes would put that breadth at 312.414.
    @Test func theBreadthHoldsAgainstTheHeightOnAFrameWiderThanItIsTall() throws {
        let mesh = HeadPreset(sex: .male, target: frontal, roll: 0).mesh(in: wide)
        let mass = try locations(mesh, identities: 1 ... 8)
        let chin = try locations(mesh, identities: 10 ... 10)

        #expect(abs(mass.map(\.x).min()! - 195.862) < 0.01)
        #expect(abs(mass.map(\.x).max()! - 404.138) < 0.01)
        #expect(abs(mass.map(\.x).max()! - mass.map(\.x).min()! - 208.276) < 0.01)
        #expect(abs(chin.map(\.y).max()! - mass.map(\.y).min()! - 320) < 0.01)
    }

    /// A target forty five degrees above level and one steeper than it give the same construction, the steeper one being held at the limit, where one inside the limit gives another.
    @Test func forwardIsHeldWithinFortyFiveDegreesOfLevel() {
        let held = HeadPreset(sex: .male, target: SIMD3<Float>(0, -1, 1), roll: 0).mesh(in: square)
        let steeper = HeadPreset(sex: .male, target: SIMD3<Float>(0, -4, 1), roll: 0).mesh(in: square)
        let shallower = HeadPreset(sex: .male, target: SIMD3<Float>(0, -0.5, 1), roll: 0).mesh(in: square)

        #expect(held == steeper)
        #expect(held != shallower)
    }

    /// A target on the vertical through the head carries no azimuth to face, and one at the head's own location carries no direction at all. The held run stands both of them out along the depth, where an unheld run leaves every location of the construction a NaN.
    @Test(arguments: [SIMD3<Float>(0, -1, 0), SIMD3<Float>(0, 1, 0), SIMD3<Float>(0, 0, 0)])
    func aTargetWithNoRunIsHeldOffTheVertical(target: SIMD3<Float>) {
        let mesh = HeadPreset(sex: .male, target: target, roll: 0).mesh(in: square)

        #expect(mesh.triangles.count == 90)
        #expect(mesh.triangles.allSatisfy { [$0.first, $0.second, $0.third].allSatisfy { $0.x.isFinite && $0.y.isFinite && $0.z.isFinite } })
    }

    /// A quarter turn about forward stands the brow plane up the middle of a frontal view, so the mass reaches the design breadth down the middle rather than across it.
    @Test func rollTurnsTheConstructionAboutForward() throws {
        let rolled = HeadPreset(sex: .male, target: frontal, roll: .pi / 2).mesh(in: square)
        let mass = try locations(rolled, identities: 1 ... 8)

        #expect(abs(mass.map(\.y).min()! - 11.552) < 0.01)
        #expect(abs(mass.map(\.y).max()! - 63.621) < 0.01)
        #expect(abs(mass.map(\.x).min()! - 12.414) < 0.01)
        #expect(abs(mass.map(\.x).max()! - 87.586) < 0.01)
    }
}
