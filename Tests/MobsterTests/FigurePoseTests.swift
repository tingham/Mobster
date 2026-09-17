import Testing
@testable import Mobster

struct FigurePoseTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(800, 800))

    private func figure(_ pose: FigurePose) -> Mesh {
        FigurePreset(sex: .male,
                     heads: 8,
                     target: SIMD3<Float>(0, 0, 1),
                     leftHand: pose.leftHand,
                     rightHand: pose.rightHand,
                     leftFoot: pose.leftFoot,
                     rightFoot: pose.rightFoot,
                     headLines: false).mesh(in: frame)
    }

    /// The poses are held as data and named by a string, so adding one is a line rather than a case.
    @Test func thePosesAreNamedAndHeldAsData() {
        let names = FigurePose.named.map(\.name)

        #expect(names == ["Standing", "Contrapposto", "Seated", "Reaching"])
        #expect(Set(names).count == names.count)
    }

    /// Every pose carries all four targets, the left of a pair standing at the lesser x and a hand above the foot below it.
    @Test func everyPoseSetsAllFourTargets() {
        for pose in FigurePose.named {
            #expect(pose.leftHand.x < pose.rightHand.x)
            #expect(pose.leftFoot.x < pose.rightFoot.x)
            #expect(pose.leftHand.y < pose.leftFoot.y)
            #expect(pose.rightHand.y < pose.rightFoot.y)
        }
    }

    /// A pose sets every target at once, so no two of them plot the same figure.
    @Test func eachPosePlotsADifferentFigure() {
        let plotted = FigurePose.named.map { figure($0) }

        #expect(Set(plotted).count == FigurePose.named.count)
        #expect(plotted.allSatisfy { $0.triangles.count == 432 })
    }
}
