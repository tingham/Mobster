import Testing
@testable import Mobster

struct CubeMeshTests {
    /// Five hundred and twelve square, which puts the centre of the Frame on a whole number and a half sized box on two more.
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512))
    /// Half again wider than it is tall, so a box sized to the wider axis would read as a slab.
    private let wide = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(600, 400))
    /// Straight out of the near face, which reads the box as a square.
    private let axis = SIMD3<Float>(0, 0, 1)

    private func box(_ position: SIMD2<Float>, _ size: Float, _ target: SIMD3<Float>) -> Mesh {
        CubeMesh(position: position, size: size, target: target).mesh(in: square)
    }

    @Test func theBoxIsTwelveTriangles() {
        #expect(box(SIMD2<Float>(0.5, 0.5), 0.5, axis).triangles.count == 12)
    }

    /// Six faces are six identities and the two triangles of a face share one, an identity marking structure rather than tessellation.
    @Test func aFaceIsOneIdentityAndItsTessellationIsNot() {
        let counts = Dictionary(grouping: box(SIMD2<Float>(0.5, 0.5), 0.5, axis).triangles, by: \.identity).mapValues(\.count)

        #expect(counts.count == 6)
        #expect(counts.values.allSatisfy { $0 == 2 })
    }

    /// Half of a five hundred and twelve square is two hundred and fifty six, centred on the middle of the Frame, so the near face stands between one hundred and twenty eight and three hundred and eighty four on both axes.
    @Test func theBoxIsPlacedAndSizedWithinTheFrame() {
        let locations = box(SIMD2<Float>(0.5, 0.5), 0.5, axis).triangles.flatMap { [$0.first, $0.second, $0.third] }

        #expect(locations.map(\.x).min() == 128)
        #expect(locations.map(\.x).max() == 384)
        #expect(locations.map(\.y).min() == 128)
        #expect(locations.map(\.y).max() == 384)
    }

    /// A quarter across and three quarters down, which the Frame carries to one hundred and twenty eight and three hundred and eighty four.
    @Test func thePositionLocatesTheCentreOfTheBox() {
        let locations = box(SIMD2<Float>(0.25, 0.75), 0.25, axis).triangles.flatMap { [$0.first, $0.second, $0.third] }

        #expect(locations.map(\.x).min() == 64)
        #expect(locations.map(\.x).max() == 192)
        #expect(locations.map(\.y).min() == 320)
        #expect(locations.map(\.y).max() == 448)
    }

    /// The lesser axis sizes the box, so four hundred rather than six hundred decides a half sized edge and the box stays a box.
    @Test func theLesserAxisOfTheFrameSizesTheBox() {
        let locations = CubeMesh(position: SIMD2<Float>(0.5, 0.5), size: 0.5, target: axis).mesh(in: wide).triangles.flatMap { [$0.first, $0.second, $0.third] }

        #expect(locations.map(\.x).max()! - locations.map(\.x).min()! == 200)
        #expect(locations.map(\.y).max()! - locations.map(\.y).min()! == 200)
    }

    /// The near face stands at the depth the box is half wide by, and the far face the same distance behind the centre.
    @Test func theBoxCarriesItsDepthTowardTheNearSide() {
        let locations = box(SIMD2<Float>(0.5, 0.5), 0.5, axis).triangles.flatMap { [$0.first, $0.second, $0.third] }

        #expect(locations.map(\.z).max() == 128)
        #expect(locations.map(\.z).min() == -128)
    }

    /// The target turns the box, so a view down the diagonal projects no face as a square.
    @Test func theTargetTurnsTheBox() {
        let turned = box(SIMD2<Float>(0.5, 0.5), 0.5, SIMD3<Float>(1, 1, 1)).triangles.flatMap { [$0.first, $0.second, $0.third] }
        let square = box(SIMD2<Float>(0.5, 0.5), 0.5, axis).triangles.flatMap { [$0.first, $0.second, $0.third] }

        #expect(Set(turned.map(\.x)).count > Set(square.map(\.x)).count)
    }
}
