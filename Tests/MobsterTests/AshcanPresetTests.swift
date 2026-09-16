import Testing
@testable import Mobster

struct AshcanPresetTests {
    /// Eight hundred on a side, so a fraction of the height reads as a round number of scene units.
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(800, 800))
    /// Half again wider than it is tall, so a figure stretched to the axes would read fifty percent broad.
    private let wide = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 400))
    private let forms = 11

    private func figure(sex: AshcanSex, heads: Float, headLines: Bool = false) -> AshcanPreset {
        AshcanPreset(sex: sex,
                     heads: heads,
                     leftHand: SIMD2<Float>(0.31, 0.5),
                     rightHand: SIMD2<Float>(0.69, 0.5),
                     leftFoot: SIMD2<Float>(0.42, 1),
                     rightFoot: SIMD2<Float>(0.58, 1),
                     leftElbowPole: SIMD2<Float>(-1, 0),
                     rightElbowPole: SIMD2<Float>(1, 0),
                     leftKneePole: SIMD2<Float>(-1, 0),
                     rightKneePole: SIMD2<Float>(1, 0),
                     headLines: headLines)
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
        let above = AshcanSolve(root: SIMD2<Float>(0, 0), target: SIMD2<Float>(5, 0), upper: 3, lower: 4, pole: SIMD2<Float>(0, 1))
        let below = AshcanSolve(root: SIMD2<Float>(0, 0), target: SIMD2<Float>(5, 0), upper: 3, lower: 4, pole: SIMD2<Float>(0, -1))

        #expect(matches([above.joint], [SIMD2<Float>(1.8, 2.4)]))
        #expect(matches([above.end], [SIMD2<Float>(5, 0)]))
        #expect(matches([below.joint], [SIMD2<Float>(1.8, -2.4)]))
        #expect(matches([below.end], [SIMD2<Float>(5, 0)]))
    }

    @Test func aPoleAcrossTheLineDecidesWhichWayTheJointTurns() {
        let leaning = AshcanSolve(root: SIMD2<Float>(0, 0), target: SIMD2<Float>(5, 0), upper: 3, lower: 4, pole: SIMD2<Float>(3, 1))
        let along = AshcanSolve(root: SIMD2<Float>(0, 0), target: SIMD2<Float>(5, 0), upper: 3, lower: 4, pole: SIMD2<Float>(1, 0))

        #expect(matches([leaning.joint], [SIMD2<Float>(1.8, 2.4)]))
        #expect(matches([along.joint], [SIMD2<Float>(1.8, 2.4)]))
    }

    @Test func aTargetOutOfReachExtendsTheLimbTowardIt() {
        let solve = AshcanSolve(root: SIMD2<Float>(0, 0), target: SIMD2<Float>(10, 0), upper: 3, lower: 4, pole: SIMD2<Float>(0, 1))

        #expect(matches([solve.joint], [SIMD2<Float>(3, 0)]))
        #expect(matches([solve.end], [SIMD2<Float>(7, 0)]))
    }

    @Test func aFigureReachingBeyondItsLimbsPlotsTheSameFormsAsOneWithinReach() {
        let reaching = AshcanPreset(sex: .male,
                                    heads: 8,
                                    leftHand: SIMD2<Float>(-4, -3),
                                    rightHand: SIMD2<Float>(6, 9),
                                    leftFoot: SIMD2<Float>(0.42, 1),
                                    rightFoot: SIMD2<Float>(0.58, 1),
                                    leftElbowPole: SIMD2<Float>(-1, 0),
                                    rightElbowPole: SIMD2<Float>(1, 0),
                                    leftKneePole: SIMD2<Float>(-1, 0),
                                    rightKneePole: SIMD2<Float>(1, 0),
                                    headLines: false).paths(in: frame)

        #expect(reaching.count == forms)
        #expect(reaching.allSatisfy { $0.allSatisfy { $0.x.isFinite && $0.y.isFinite } })
    }

    @Test func headBreakLinesSitAtTheFractionsTheHeightImplies() {
        let plain = figure(sex: .male, heads: 8).paths(in: frame)
        let measured = figure(sex: .male, heads: 8, headLines: true).paths(in: frame)
        let levels = measured.dropFirst(forms).map { $0[0].y }

        #expect(plain.count == forms)
        #expect(measured.count == forms + 18)
        #expect(levels == [0, 0, 100, 100, 200, 200, 300, 300, 400, 400, 500, 500, 600, 600, 700, 700, 800, 800])
        #expect(matches(measured[forms], [SIMD2<Float>(166.7, 0), SIMD2<Float>(283.35, 0)]))
        #expect(matches(measured[forms + 1], [SIMD2<Float>(516.65, 0), SIMD2<Float>(633.3, 0)]))
    }

    /// A partial head at the soles is not a head break, so seven and a half heads breaks seven times below the top of the head and not eight.
    @Test func aPartialHeadAtTheSolesCarriesNoBreak() {
        let measured = figure(sex: .male, heads: 7.5, headLines: true).paths(in: frame)
        let levels = measured.dropFirst(forms).map { $0[0].y }

        #expect(measured.count == forms + 16)
        #expect(abs((levels.last ?? 0) - 800 * 7 / 7.5) < 0.01)
    }

    @Test func theAdultFormsSitWhereTheAdultTableSaysTheyDo() {
        let male = figure(sex: .male, heads: 8).paths(in: frame)
        let female = figure(sex: .female, heads: 8).paths(in: frame)

        #expect(matches([male[0][0]], [SIMD2<Float>(433.35, 50)]))
        #expect(matches(male[2], [SIMD2<Float>(324.994, 300),
                                  SIMD2<Float>(475.006, 300),
                                  SIMD2<Float>(445.0036, 400),
                                  SIMD2<Float>(354.9964, 400),
                                  SIMD2<Float>(324.994, 300)]))
        #expect(matches(female[2], [SIMD2<Float>(325, 325.2),
                                    SIMD2<Float>(475, 325.2),
                                    SIMD2<Float>(445, 433.6),
                                    SIMD2<Float>(355, 433.6),
                                    SIMD2<Float>(325, 325.2)]))
    }

    /// Eight heads of male canon are 2.333 heads wide and each shoulder is set in by half a shoulder girth, which puts the shoulder span at 0.249125 of the stature. A Frame six hundred by four hundred carries the stature at the four hundred of its shorter axis and the span at 99.65, where stretching to the axes would put that span at 149.475.
    @Test func theShoulderSpanHoldsAgainstTheStatureOnAFrameWiderThanItIsTall() {
        let paths = figure(sex: .male, heads: 8, headLines: true).paths(in: wide)
        let levels = paths.dropFirst(forms).map { $0[0].y }
        let span = (paths[5][0].x + paths[5][1].x) / 2 - (paths[3][0].x + paths[3][1].x) / 2

        #expect(abs(levels.last! - levels.first! - 400) < 0.01)
        #expect(abs(span - 99.65) < 0.01)
    }

    /// The shorter table is a child's rather than the adult's scaled down, so its cranium takes a quarter of the height where the adult's takes an eighth and its legs are the shorter for it.
    @Test func theShorterTableIsAChildsRatherThanASmallAdults() {
        let child = AshcanFigure(heads: 4, sex: .male)
        let adult = AshcanFigure(heads: 8, sex: .male)

        #expect(child.canon.chin == 0.25)
        #expect(adult.canon.chin == 0.125)
        #expect(child.canon.crotch > adult.canon.crotch)
        #expect(child.thigh + child.shin < adult.thigh + adult.shin)
        #expect(child.canon.width < adult.canon.width)
    }

    @Test func theChildFormsSitWhereTheChildTableSaysTheyDo() {
        let child = figure(sex: .male, heads: 4).paths(in: frame)

        #expect(matches([child[0][0]], [SIMD2<Float>(466.7, 100)]))
        #expect(matches(child[2], [SIMD2<Float>(297.12, 445.2),
                                   SIMD2<Float>(502.88, 445.2),
                                   SIMD2<Float>(461.728, 570.4),
                                   SIMD2<Float>(338.272, 570.4),
                                   SIMD2<Float>(297.12, 445.2)]))
    }

    /// Outside the tabled heights there is no canon, so the nearest tabled height answers.
    @Test func aHeightOutsideTheTableAnswersWithTheNearestTabledHeight() {
        #expect(figure(sex: .male, heads: 2).paths(in: frame) == figure(sex: .male, heads: 4).paths(in: frame))
        #expect(figure(sex: .male, heads: 12).paths(in: frame) == figure(sex: .male, heads: 8).paths(in: frame))
    }
}
