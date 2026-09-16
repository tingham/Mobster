import Testing
@testable import Mobster

struct HeadPresetTests {
    /// A hundred square, so a design fraction reads as a percentage and the construction keeps true proportion.
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(100, 100))

    @Test func theConstructionEmitsItsPartsInOrder() {
        let paths = HeadPreset(sex: .male, view: 0.5).paths(in: square)

        #expect(paths.count == 8)
        #expect(paths.map(\.count) == [65, 33, 33, 65, 65, 5, 5, 5])
    }

    /// Head breadth over head height puts the cranial mass 26.034 either side of the middle, vertex to nasion puts the brow line at 37.586 and the underside at 75.172, and the temple breadth puts a side plane at 69.138.
    @Test func faceForwardReadsAsFrontal() {
        let paths = HeadPreset(sex: .male, view: 1).paths(in: square)

        #expect(abs(paths[0].map(\.x).max()! - 76.034) < 0.01)
        #expect(abs(paths[0].map(\.x).min()! - 23.966) < 0.01)
        #expect(abs(paths[1].first!.x - 23.966) < 0.01)
        #expect(abs(paths[1].last!.x - 76.034) < 0.01)
        #expect(paths[1].allSatisfy { abs($0.y - 37.586) < 0.01 })
        #expect(paths[2].allSatisfy { abs($0.x - 50) < 0.001 })
        #expect(abs(paths[2].last!.y - 75.172) < 0.01)
        #expect(paths[3].allSatisfy { abs($0.x - 69.138) < 0.01 })
        #expect(paths[4].allSatisfy { abs($0.x - 30.862) < 0.01 })
    }

    /// Head length over head height puts the cranial mass 33.621 either side of the middle, which the centre line now reaches because it has become the front of the outline. The brow line runs from the middle out into the depth and back.
    @Test func aViewOfZeroReadsAsProfile() {
        let paths = HeadPreset(sex: .male, view: 0).paths(in: square)

        #expect(abs(paths[0].map(\.x).max()! - 83.621) < 0.01)
        #expect(abs(paths[0].map(\.x).min()! - 16.379) < 0.01)
        #expect(abs(paths[2].map(\.x).max()! - 83.621) < 0.01)
        #expect(abs(paths[1].first!.x - 50) < 0.01)
        #expect(abs(paths[1].last!.x - 50) < 0.01)
        #expect(abs(paths[1][16].x - 83.621) < 0.01)
        #expect(zip(paths[3], paths[4]).allSatisfy { abs($0.x - $1.x) < 0.01 && abs($0.y - $1.y) < 0.01 })
    }

    /// The brow line sits at the vertex to nasion fraction of the head height, which is 0.470 of it for a man and 0.486 for a woman, and bigonial breadth carries the jaw angle 18.276 off the middle for a man and 17.982 for a woman.
    @Test func sexChangesTheProportions() {
        let male = HeadPreset(sex: .male, view: 1).paths(in: square)
        let female = HeadPreset(sex: .female, view: 1).paths(in: square)

        #expect(abs(male[1].first!.y - 37.586) < 0.01)
        #expect(abs(female[1].first!.y - 38.899) < 0.01)
        #expect(abs(male[5].first!.x - 68.276) < 0.01)
        #expect(abs(female[5].first!.x - 67.982) < 0.01)
    }
}
