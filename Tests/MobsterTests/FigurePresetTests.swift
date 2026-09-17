import Testing
@testable import Mobster

struct FigurePresetTests {
    /// Eight hundred on a side, so a fraction of the height reads as a round number of scene units.
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(800, 800))
    /// Half again wider than it is tall, so a figure stretched to the axes would read fifty percent broad.
    private let wide = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 400))
    /// Straight out of the chest, which reads the figure frontally.
    private let frontal = SIMD3<Float>(0, 0, 1)

    private func figure(sex: FigureSex, heads: Float, target: SIMD3<Float>? = nil, headTarget: SIMD3<Float>? = nil, headLines: Bool = false) -> FigurePreset {
        FigurePreset(sex: sex,
                     heads: heads,
                     target: target ?? frontal,
                     headTarget: headTarget ?? frontal,
                     leftHand: SIMD2<Float>(0.31, 0.5),
                     rightHand: SIMD2<Float>(0.69, 0.5),
                     leftFoot: SIMD2<Float>(0.42, 1),
                     rightFoot: SIMD2<Float>(0.58, 1),
                     headLines: headLines)
    }

    private func locations(_ mesh: Mesh, identity: UInt32) -> [SIMD3<Float>] {
        mesh.triangles.filter { $0.identity == MeshIdentity(identity) }.flatMap { [$0.first, $0.second, $0.third] }
    }

    private func spans(_ locations: [SIMD3<Float>]) -> (SIMD3<Float>, SIMD3<Float>) {
        (SIMD3<Float>(locations.map(\.x).min()!, locations.map(\.y).min()!, locations.map(\.z).min()!),
         SIMD3<Float>(locations.map(\.x).max()!, locations.map(\.y).max()!, locations.map(\.z).max()!))
    }

    /// A level a form actually stands at, so a form that moved off it reports rather than trapping on an empty run.
    private func level(_ locations: [SIMD3<Float>], _ y: Float) throws -> [SIMD3<Float>] {
        let standing = locations.filter { abs($0.y - y) < 0.01 }

        return try #require(standing.isEmpty ? nil : standing, "a form stands at this level")
    }

    private func meets(_ location: SIMD3<Float>, _ expected: SIMD3<Float>) -> Bool {
        let offset = location - expected

        return abs(offset.x) < 0.01 && abs(offset.y) < 0.01 && abs(offset.z) < 0.01
    }

    private func matches(_ path: [SIMD2<Float>], _ expected: [SIMD2<Float>]) -> Bool {
        guard path.count == expected.count else { return false }

        for (location, target) in zip(path, expected) where abs(location.x - target.x) > 0.01 || abs(location.y - target.y) > 0.01 {
            return false
        }

        return true
    }

    /// Lengths of three and four to a target five away is the right triangle whose joint lies eighteen thirtieths of the way along the line and eight tenths of three across it.
    @Test func aTwoBoneSolveMatchesTheTriangleTheLawOfCosinesGives() {
        let above = FigureSolve(root: SIMD2<Float>(0, 0), target: SIMD2<Float>(5, 0), upper: 3, lower: 4, pole: SIMD2<Float>(0, 1))
        let below = FigureSolve(root: SIMD2<Float>(0, 0), target: SIMD2<Float>(5, 0), upper: 3, lower: 4, pole: SIMD2<Float>(0, -1))

        #expect(abs(above.joint.x - 1.8) < 0.01)
        #expect(abs(above.joint.y - 2.4) < 0.01)
        #expect(abs(above.end.x - 5) < 0.01)
        #expect(abs(below.joint.y + 2.4) < 0.01)
    }

    @Test func aPoleAcrossTheLineDecidesWhichWayTheJointTurns() {
        let leaning = FigureSolve(root: SIMD2<Float>(0, 0), target: SIMD2<Float>(5, 0), upper: 3, lower: 4, pole: SIMD2<Float>(3, 1))
        let along = FigureSolve(root: SIMD2<Float>(0, 0), target: SIMD2<Float>(5, 0), upper: 3, lower: 4, pole: SIMD2<Float>(1, 0))

        #expect(abs(leaning.joint.y - 2.4) < 0.01)
        #expect(abs(along.joint.y - 2.4) < 0.01)
    }

    @Test func aTargetOutOfReachExtendsTheLimbTowardIt() {
        let solve = FigureSolve(root: SIMD2<Float>(0, 0), target: SIMD2<Float>(10, 0), upper: 3, lower: 4, pole: SIMD2<Float>(0, 1))

        #expect(abs(solve.joint.x - 3) < 0.01)
        #expect(abs(solve.end.x - 7) < 0.01)
    }

    /// An elbow and a knee turn away from the middle of the figure. Nothing is passed to say which way either bends, the direction being anatomical rather than a control.
    @Test func aLimbBendsAwayFromTheMiddleAndNothingSaysWhichWay() {
        let standing = Figure(heads: 8, sex: .male)
        let leftArm = standing.arm(root: standing.leftShoulder, target: SIMD2<Float>(0.31, 0.45))
        let rightArm = standing.arm(root: standing.rightShoulder, target: SIMD2<Float>(0.69, 0.45))
        let leftLeg = standing.leg(root: standing.pelvis.leftCorner, target: SIMD2<Float>(0.42, 0.95))
        let rightLeg = standing.leg(root: standing.pelvis.rightCorner, target: SIMD2<Float>(0.58, 0.95))

        #expect(leftArm.upper.end.x < standing.leftShoulder.x)
        #expect(rightArm.upper.end.x > standing.rightShoulder.x)
        #expect(leftLeg.upper.end.x < standing.pelvis.leftCorner.x)
        #expect(rightLeg.upper.end.x > standing.pelvis.rightCorner.x)
    }

    /// Two masses of four bands each, a pelvis of a side band and two caps, four limbs of two segments each divided in two, and four blocks of a side band and two caps. A facet with no area is dropped, which is what a ring closing onto a pole costs a fan rather than a band.
    @Test func theWholeFigureIsAFewHundredTriangles() {
        #expect(figure(sex: .male, heads: 8).mesh(in: frame).triangles.count == 432)
    }

    /// An identity marks structure. A mass carries two for the division at its equator, a pelvis one, a limb four being two a segment, and a hand or a foot one.
    @Test func anIdentityMarksStructureRatherThanTessellation() {
        let identities = Set(figure(sex: .male, heads: 8).mesh(in: frame).triangles.map(\.identity.value))

        #expect(identities == Set(1 ... 25))
    }

    /// Farkas puts nasion to gnathion at 123 of the 232 of head height, so the hand is 0.5302 of a head long, and the foot is one head. Both taper, and the foot runs out of the ankle along the depth where the hand carries on the line of the forearm.
    @Test func theHandIsTheLengthOfTheFaceAndTheFootOneHead() {
        let standing = Figure(heads: 8, sex: .male)
        let arm = standing.arm(root: standing.leftShoulder, target: SIMD2<Float>(0.31, 0.45))
        let leg = standing.leg(root: standing.pelvis.leftCorner, target: SIMD2<Float>(0.42, 0.95))
        let hand = standing.hand(arm)
        let foot = standing.foot(leg)
        let reach = hand.end - hand.start

        #expect(abs((reach * reach).sum().squareRoot() - Float(123) / 232 * standing.headUnit) < 0.0001)
        #expect(hand.start == SIMD3<Float>(arm.lower.end.x, arm.lower.end.y, 0))
        #expect(hand.endWidth < hand.startWidth)
        #expect(foot.start == SIMD3<Float>(leg.lower.end.x, leg.lower.end.y, 0))
        #expect(foot.end == SIMD3<Float>(leg.lower.end.x, leg.lower.end.y, standing.headUnit))
        #expect(foot.endWidth < foot.startWidth)
    }

    /// Two thirds as wide as tall puts the head mass 0.0416875 of the stature either side of the middle, its own height is the eighth of the stature the chin level gives, and Farkas's head length puts it 0.0525 deep. Eight hundred of stature carries those to 366.65 through 433.35, zero through a hundred, and forty two either side of the plane.
    @Test func theHeadMassStandsWhereTheAdultTablePutsIt() {
        let (least, most) = spans(locations(figure(sex: .male, heads: 8).mesh(in: frame), identity: 1)
            + locations(figure(sex: .male, heads: 8).mesh(in: frame), identity: 2))

        #expect(meets(least, SIMD3<Float>(366.65, 0, -42)))
        #expect(meets(most, SIMD3<Float>(433.35, 100, 42)))
    }

    /// Eight heads of male canon are 2.333 heads wide, so the figure is 0.291625 of its stature across and the ribcage is 0.65 of that. The shoulder at 0.167 and the waist at 0.375 bound it, and the depth follows the width, no canon carrying a torso depth.
    @Test func theRibcageStandsWhereTheAdultTablePutsIt() {
        let (least, most) = spans(locations(figure(sex: .male, heads: 8).mesh(in: frame), identity: 3)
            + locations(figure(sex: .male, heads: 8).mesh(in: frame), identity: 4))

        #expect(meets(least, SIMD3<Float>(324.1775, 133.6, -75.8225)))
        #expect(meets(most, SIMD3<Float>(475.8225, 300, 75.8225)))
    }

    /// The man's pelvis is 0.643 of the figure's width across at the waist and six tenths of that at the crotch, which 800 of stature carries to 75.006 and 45.0036 either side of the middle between the levels 300 and 400. Its depth follows its width at each level.
    @Test func thePelvisStandsWhereTheAdultTablePutsIt() throws {
        let corners = locations(figure(sex: .male, heads: 8).mesh(in: frame), identity: 5)
        let waist = try level(corners, 300)
        let crotch = try level(corners, 400)

        #expect(abs(waist.map(\.x).min()! - 324.994) < 0.01)
        #expect(abs(waist.map(\.x).max()! - 475.006) < 0.01)
        #expect(abs(waist.map(\.z).max()! - 75.006) < 0.01)
        #expect(abs(crotch.map(\.x).min()! - 354.9964) < 0.01)
        #expect(abs(crotch.map(\.x).max()! - 445.0036) < 0.01)
        #expect(abs(crotch.map(\.z).max()! - 45.0036) < 0.01)
    }

    /// The woman's pelvis is 0.75 of the figure's width where the man's is 0.643, and her eight head canon is two heads wide where his is 2.333.
    @Test func sexChangesTheProportionsOfThePelvis() throws {
        let man = locations(figure(sex: .male, heads: 8).mesh(in: frame), identity: 5)
        let woman = locations(figure(sex: .female, heads: 8).mesh(in: frame), identity: 5)

        #expect(abs(man.map(\.x).max()! - 475.006) < 0.01)
        #expect(abs(woman.map(\.x).max()! - 475) < 0.01)
        #expect(abs(try level(woman, 325.2).map(\.x).min()! - 325) < 0.01)
    }

    /// A Frame six hundred by four hundred carries the stature at the four hundred of its shorter axis and centres the figure across it, which puts the pelvis 37.50298 either side of three hundred at a waist level of 150. Stretching to the axes would put that half width at 56.25 instead.
    @Test func theFigureHoldsItsProportionsOnAFrameWiderThanItIsTall() throws {
        let corners = locations(figure(sex: .male, heads: 8).mesh(in: wide), identity: 5)
        let waist = try level(corners, 150)
        let head = locations(figure(sex: .male, heads: 8).mesh(in: wide), identity: 1)

        #expect(abs(waist.map(\.x).min()! - 262.497) < 0.01)
        #expect(abs(waist.map(\.x).max()! - 337.503) < 0.01)
        #expect(abs(corners.map(\.y).max()! - 200) < 0.01)
        #expect(abs(head.map(\.y).min()!) < 0.01)
        #expect(abs(head.map(\.x).min()! - 283.325) < 0.01)
    }

    /// The pose stays in the figure's own plane, so a turn moves every form and the hands and feet keep the design locations they were given.
    @Test func theTargetTurnsTheWholeFigureAndNotThePose() {
        let straight = figure(sex: .male, heads: 8).mesh(in: frame)
        let turned = figure(sex: .male, heads: 8, target: SIMD3<Float>(1, 0, 1)).mesh(in: frame)

        #expect(straight.triangles.count == turned.triangles.count)
        #expect(straight != turned)
        #expect(turned.triangles.allSatisfy { [$0.first, $0.second, $0.third].allSatisfy { $0.x.isFinite && $0.y.isFinite && $0.z.isFinite } })
    }

    /// The head points at a location of its own, so it turns within a figure the figure's own target leaves frontal. The mass is what turns and nothing else moves with it.
    @Test func theHeadTargetTurnsTheHeadAndNothingElse() {
        let ahead = figure(sex: .male, heads: 8).mesh(in: frame)
        let looking = figure(sex: .male, heads: 8, headTarget: SIMD3<Float>(1, 0, 1)).mesh(in: frame)
        let mass: Set<UInt32> = [1, 2]

        #expect(ahead.triangles.count == looking.triangles.count)
        #expect(ahead.triangles.filter { mass.contains($0.identity.value) } != looking.triangles.filter { mass.contains($0.identity.value) })
        #expect(ahead.triangles.filter { mass.contains($0.identity.value) == false } == looking.triangles.filter { mass.contains($0.identity.value) == false })
    }

    /// The target is a location on the preview a consumer drags, so it stands somewhere in the Frame and a location in the Frame stands for a target. One head to the right of the head's centre is a twelfth of eight hundred across from it.
    @Test func theHeadTargetStandsInTheFrameAndComesBackFromIt() {
        let looking = figure(sex: .male, heads: 8, headTarget: SIMD3<Float>(1, 0, 1))
        let standing = looking.headLocation(in: frame)

        #expect(abs(standing.x - 500) < 0.01)
        #expect(abs(standing.y - 50) < 0.01)
        #expect(meets(SIMD3<Float>(looking.headTarget(at: standing, in: frame)), SIMD3<Float>(1, 0, 1)))
        #expect(meets(SIMD3<Float>(looking.headTarget(at: SIMD2<Float>(400, 50), in: frame)), SIMD3<Float>(0, 0, 1)))
    }

    @Test func headBreakLinesSitAtTheFractionsTheHeightImplies() {
        let measured = figure(sex: .male, heads: 8, headLines: true).breakLines(in: frame)

        #expect(figure(sex: .male, heads: 8).breakLines(in: frame).isEmpty)
        #expect(measured.count == 18)
        #expect(measured.map { $0[0].y } == [0, 0, 100, 100, 200, 200, 300, 300, 400, 400, 500, 500, 600, 600, 700, 700, 800, 800])
        #expect(matches(measured[0], [SIMD2<Float>(166.7, 0), SIMD2<Float>(283.35, 0)]))
        #expect(matches(measured[1], [SIMD2<Float>(516.65, 0), SIMD2<Float>(633.3, 0)]))
    }

    /// A partial head at the soles is not a head break, so seven and a half heads breaks seven times below the top of the head and not eight.
    @Test func aPartialHeadAtTheSolesCarriesNoBreak() {
        let measured = figure(sex: .male, heads: 7.5, headLines: true).breakLines(in: frame)

        #expect(measured.count == 16)
        #expect(abs(measured.map { $0[0].y }.last! - 800 * 7 / 7.5) < 0.01)
    }

    /// The shorter table is a child's rather than the adult's scaled down, so its cranium takes a quarter of the height where the adult's takes an eighth and its legs are the shorter for it.
    @Test func theShorterTableIsAChildsRatherThanASmallAdults() {
        let child = Figure(heads: 4, sex: .male)
        let adult = Figure(heads: 8, sex: .male)

        #expect(child.canon.chin == 0.25)
        #expect(adult.canon.chin == 0.125)
        #expect(child.canon.crotch > adult.canon.crotch)
        #expect(child.thigh + child.shin < adult.thigh + adult.shin)
        #expect(child.canon.width < adult.canon.width)
    }

    /// A four head child's chin is a quarter of the stature down, so the head mass takes the top two hundred of eight hundred, and 1.6 heads of width puts the waist of the pelvis 102.88 either side of the middle at a level of 445.2.
    @Test func theChildFormsSitWhereTheChildTableSaysTheyDo() throws {
        let mesh = figure(sex: .male, heads: 4).mesh(in: frame)
        let head = locations(mesh, identity: 1) + locations(mesh, identity: 2)
        let waist = try level(locations(mesh, identity: 5), 445.2)

        #expect(abs(head.map(\.y).min()!) < 0.01)
        #expect(abs(head.map(\.y).max()! - 200) < 0.01)
        #expect(abs(waist.map(\.x).min()! - 297.12) < 0.01)
        #expect(abs(waist.map(\.x).max()! - 502.88) < 0.01)
    }

    /// Outside the tabled heights there is no canon, so the nearest tabled height answers.
    @Test func aHeightOutsideTheTableAnswersWithTheNearestTabledHeight() {
        #expect(figure(sex: .male, heads: 2).mesh(in: frame) == figure(sex: .male, heads: 4).mesh(in: frame))
        #expect(figure(sex: .male, heads: 12).mesh(in: frame) == figure(sex: .male, heads: 8).mesh(in: frame))
    }

    @Test func aFigureReachingBeyondItsLimbsPlotsTheSameFormsAsOneWithinReach() {
        let reaching = FigurePreset(sex: .male,
                                    heads: 8,
                                    target: frontal,
                                    headTarget: frontal,
                                    leftHand: SIMD2<Float>(-4, -3),
                                    rightHand: SIMD2<Float>(6, 9),
                                    leftFoot: SIMD2<Float>(0.42, 1),
                                    rightFoot: SIMD2<Float>(0.58, 1),
                                    headLines: false).mesh(in: frame)

        #expect(reaching.triangles.count == 432)
        #expect(reaching.triangles.allSatisfy { [$0.first, $0.second, $0.third].allSatisfy { $0.x.isFinite && $0.y.isFinite } })
    }
}
