import Foundation
import Testing
@testable import Mobster

struct HeadPresetTests {
    /// A hundred square, so a design fraction reads as a percentage and the construction keeps true proportion.
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))
    /// Off level and off centre, so no axis of the basis falls out of the symmetry of the construction and no sample sits on the clip.
    private let oblique = SIMD3<Float>(0.8, 0.4, 1)

    private func climbs(_ run: [Float]) -> Bool {
        zip(run, run.dropFirst()).allSatisfy { $1 >= $0 - 0.0001 }
    }

    private func level(_ paths: [[SIMD2<Float>]], _ y: Float) -> [[SIMD2<Float>]] {
        paths.filter { path in path.allSatisfy { abs($0.y - y) < 0.01 } }
    }

    private func upright(_ paths: [[SIMD2<Float>]], _ x: Float) -> [[SIMD2<Float>]] {
        paths.filter { path in path.allSatisfy { abs($0.x - x) < 0.01 } }
    }

    @Test func theConstructionEmitsItsPartsInOrder() {
        let paths = HeadPreset(sex: .male, target: oblique, roll: 0.25).paths(in: square)

        #expect(paths.count == 12)
        #expect(paths.map(\.count) == [65, 11, 22, 27, 6, 5, 16, 17, 28, 3, 5, 5])
    }

    /// Head breadth over head height puts the cranial mass 26.034 either side of the middle, vertex to nasion puts the brow line at 37.586 and the underside at 75.172, and the temple breadth puts a side plane at 69.138.
    @Test func aTargetLevelAndInFrontReadsAsFrontal() {
        let paths = HeadPreset(sex: .male, target: SIMD3<Float>(0, 0, 1), roll: 0).paths(in: square)
        let brow = level(paths, 37.586)
        let centre = upright(paths, 50)

        #expect(abs(paths[0].map(\.x).max()! - 76.034) < 0.01)
        #expect(abs(paths[0].map(\.x).min()! - 23.966) < 0.01)
        #expect(abs(paths[0].map(\.y).max()! - 75.172) < 0.01)
        #expect(brow.count == 2)
        #expect(abs(brow.flatMap { $0.map(\.x) }.max()! - 76.034) < 0.01)
        #expect(abs(brow.flatMap { $0.map(\.x) }.min()! - 23.966) < 0.01)
        #expect(centre.count == 1)
        #expect(abs(centre[0].map(\.y).max()! - 75.172) < 0.01)
        #expect(upright(paths, 69.138).count == 2)
        #expect(upright(paths, 30.862).count == 2)
    }

    /// Head length over head height puts the cranial mass 33.621 either side of the middle, half of which the sagittal great circle stands in for, its plane standing edge on to the view. The brow circle flattens onto the level of nasion and crosses that depth once, gnathion at 80 and sublabiale at 64.828 stand at the front of it, the near side plane is cut to 0.678 of the cranial mass by the temple breadth, and the far side plane does not project at all.
    @Test func aTargetLevelAndToTheSideReadsAsProfile() {
        let paths = HeadPreset(sex: .male, target: SIMD3<Float>(1, 0, 0), roll: 0).paths(in: square)

        #expect(paths.count == 7)
        #expect(abs(paths[0].map(\.x).max()! - 83.621) < 0.01)
        #expect(abs(paths[0].map(\.x).min()! - 16.379) < 0.01)
        #expect(abs(paths[2].map(\.x).min()! - 16.379) < 0.01)
        #expect(abs(paths[2].map(\.x).max()! - 50) < 0.01)
        #expect(abs(paths[2].map(\.y).min()!) < 0.01)
        #expect(paths[1].allSatisfy { abs($0.y - 37.586) < 0.01 })
        #expect(climbs(paths[1].map(\.x)))
        #expect(paths[5].allSatisfy { abs($0.x - 83.621) < 0.01 })
        #expect(abs(paths[5].map(\.y).max()! - 80) < 0.01)
        #expect(abs(paths[5].map(\.y).min()! - 64.828) < 0.01)
        #expect(abs(paths[3].map(\.x).max()! - 72.793) < 0.01)
        #expect(abs(paths[3].map(\.y).min()! - 12.104) < 0.01)
    }

    /// The brow line sits at the vertex to nasion fraction of the head height, which is 0.470 of it for a man and 0.486 for a woman, and bigonial breadth carries the jaw angle 18.276 off the middle for a man and 17.982 for a woman.
    @Test func sexChangesTheProportions() {
        let male = HeadPreset(sex: .male, target: SIMD3<Float>(0, 0, 1), roll: 0).paths(in: square)
        let female = HeadPreset(sex: .female, target: SIMD3<Float>(0, 0, 1), roll: 0).paths(in: square)

        #expect(abs(male[1].first!.y - 37.586) < 0.01)
        #expect(abs(female[1].first!.y - 38.899) < 0.01)
        #expect(abs(male[8].map(\.x).max()! - 68.276) < 0.01)
        #expect(abs(female[8].map(\.x).max()! - 67.982) < 0.01)
    }

    /// A great circle seen from the level of its own plane projects onto a line, so the half of it standing away folds back over the half standing near and each surviving stretch crosses once.
    @Test func theFarHalfOfAGreatCircleDoesNotProject() {
        let paths = HeadPreset(sex: .male, target: SIMD3<Float>(0, 0, 1), roll: 0).paths(in: square)
        let brow = level(paths, 37.586)
        let centre = upright(paths, 50)

        #expect(brow.map(\.count).reduce(0, +) <= 34)
        #expect(brow.allSatisfy { climbs($0.map(\.x)) })
        #expect(centre.map(\.count).reduce(0, +) <= 34)
        #expect(centre.allSatisfy { climbs($0.map(\.y)) })
    }

    /// A target forty five degrees above level and one steeper than it give the same construction, the steeper one being held at the limit, where one inside the limit gives another.
    @Test func forwardIsHeldWithinFortyFiveDegreesOfLevel() {
        let held = HeadPreset(sex: .male, target: SIMD3<Float>(0, -1, 1), roll: 0).paths(in: square)
        let steeper = HeadPreset(sex: .male, target: SIMD3<Float>(0, -4, 1), roll: 0).paths(in: square)
        let shallower = HeadPreset(sex: .male, target: SIMD3<Float>(0, -0.5, 1), roll: 0).paths(in: square)

        #expect(held == steeper)
        #expect(held != shallower)
    }

    /// A target on the vertical through the head carries no azimuth to face, and one at the head's own location carries no direction at all. The held run stands both of them out along the depth, where an unheld run leaves every location of the construction a NaN.
    @Test(arguments: [SIMD3<Float>(0, -1, 0), SIMD3<Float>(0, 1, 0), SIMD3<Float>(0, 0, 0)])
    func aTargetWithNoRunIsHeldOffTheVertical(target: SIMD3<Float>) {
        let paths = HeadPreset(sex: .male, target: target, roll: 0).paths(in: square)

        #expect(!paths.isEmpty)
        #expect(paths.allSatisfy { $0.allSatisfy { $0.x.isFinite && $0.y.isFinite } })
    }

    /// A quarter turn about forward stands the brow line up the middle of a frontal view and lays the centre line across it.
    @Test func rollTurnsTheConstructionAboutForward() {
        let paths = HeadPreset(sex: .male, target: SIMD3<Float>(0, 0, 1), roll: .pi / 2).paths(in: square)
        let brow = upright(paths, 50)
        let centre = level(paths, 37.586)

        #expect(brow.count == 2)
        #expect(abs(brow.flatMap { $0.map(\.y) }.min()! - 11.552) < 0.01)
        #expect(abs(brow.flatMap { $0.map(\.y) }.max()! - 63.621) < 0.01)
        #expect(centre.count == 1)
        #expect(abs(centre[0].map(\.x).min()! - 12.414) < 0.01)
        #expect(abs(centre[0].map(\.x).max()! - 87.586) < 0.01)
    }
}
