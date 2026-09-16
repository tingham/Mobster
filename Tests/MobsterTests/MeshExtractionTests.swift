import Metal
import Testing
@testable import Mobster

struct MeshExtractionTests {
    /// Five hundred and twelve square, which the derived resolution makes one fragment to the scene unit, so a hand derivation reads the same in fragments and in scene units.
    private let square = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(512, 512))
    /// Straight out of the near face of the box.
    private let axis = SIMD3<Float>(0, 0, 1)
    /// Down the body diagonal of the box: forty five degrees of rise on an azimuth whose sine is a third root, which stands all three visible faces at the same depth and so projects the regular hexagon.
    private let diagonal = SIMD3<Float>(1, Float(3).squareRoot(), Float(2).squareRoot())
    /// A boundary sample sits half a fragment from each of the fragments it separates and a fragment is a scene unit here, so a hand derived corner is met within a fragment and a half.
    private let tolerance: Float = 1.5

    // A half sized box in this Frame is two hundred and fifty six across, so its half edge is one hundred and twenty eight and its centre is the middle of the Frame. The diagonal view carries the plane axes 0.8165 across and 0.4082 in depth and breadth, and 0.7071 down for breadth and depth alike, which puts a corner of the box at one hundred and twenty eight times those sums.

    /// The corner of the box nearest the viewer, where the three visible faces meet. Its opposite projects onto the same location, which is what makes the projection read as a hexagon of three faces.
    private static let nearCorner = SIMD2<Float>(256, 256)
    /// The upper left vertex, 256 - 104.512 across and 256 - 181.019 down.
    private static let a = SIMD2<Float>(151.488, 74.981)
    /// The upper right vertex.
    private static let b = SIMD2<Float>(360.512, 74.981)
    /// The right vertex, 256 + 209.023 across and level with the centre.
    private static let c = SIMD2<Float>(465.023, 256)
    /// The lower right vertex.
    private static let d = SIMD2<Float>(360.512, 437.019)
    /// The lower left vertex.
    private static let e = SIMD2<Float>(151.488, 437.019)
    /// The left vertex.
    private static let f = SIMD2<Float>(46.977, 256)

    private func extracted(_ target: SIMD3<Float>) throws -> [[SIMD2<Float>]] {
        let device = try #require(MTLCreateSystemDefaultDevice())
        let mesh = CubeMesh(position: SIMD2<Float>(0.5, 0.5), size: 0.5, target: target).mesh(in: square)

        return MeshExtraction(mesh: mesh, frame: square).paths(device: device)
    }

    private func meets(_ path: [SIMD2<Float>], _ first: SIMD2<Float>, _ second: SIMD2<Float>) -> Bool {
        guard let start = path.first, let end = path.last else { return false }

        return (near(start, first) && near(end, second)) || (near(start, second) && near(end, first))
    }

    private func holds(_ path: [SIMD2<Float>], _ location: SIMD2<Float>) -> Bool {
        path.contains { near($0, location) }
    }

    private func near(_ location: SIMD2<Float>, _ other: SIMD2<Float>) -> Bool {
        let offset = location - other

        return (offset * offset).sum().squareRoot() < tolerance
    }

    /// The near face alone stands toward the viewer, so the only boundary is where it meets the background and it runs the square from one hundred and twenty eight to three hundred and eighty four on both axes.
    @Test func aBoxViewedAlongAnAxisIsASquare() throws {
        let paths = try extracted(axis)

        #expect(paths.count == 1)
        #expect(holds(paths[0], SIMD2<Float>(128, 128)))
        #expect(holds(paths[0], SIMD2<Float>(384, 128)))
        #expect(holds(paths[0], SIMD2<Float>(384, 384)))
        #expect(holds(paths[0], SIMD2<Float>(128, 384)))
        #expect(paths[0].allSatisfy { location in
            abs(location.x - 128) < tolerance || abs(location.x - 384) < tolerance || abs(location.y - 128) < tolerance || abs(location.y - 384) < tolerance
        })
    }

    /// Three faces stand toward the viewer and each meets the other two and the background, which is three interior seams and three stretches of outline.
    @Test func aBoxViewedOnItsDiagonalIsAHexagonOfThreeSeams() throws {
        let paths = try extracted(diagonal)

        #expect(paths.count == 6)
        #expect(meets(paths[0], Self.nearCorner, Self.a))
        #expect(meets(paths[1], Self.nearCorner, Self.e))
        #expect(meets(paths[3], Self.nearCorner, Self.c))
    }

    /// The seams are the three edges the visible faces share, so all three end at the corner those faces meet at.
    @Test func theSeamsMeetAtTheNearCorner() throws {
        let paths = try extracted(diagonal)
        let seams = [paths[0], paths[1], paths[3]]

        #expect(seams.allSatisfy { seam in near(seam.first ?? .zero, Self.nearCorner) || near(seam.last ?? .zero, Self.nearCorner) })
    }

    /// Each visible face contributes two edges of the hexagon, so each stretch of outline runs between two of the vertices the seams reach and turns at the one between them.
    @Test func theOutlineIsTheHexagonOfTheBox() throws {
        let paths = try extracted(diagonal)

        #expect(meets(paths[2], Self.a, Self.e))
        #expect(holds(paths[2], Self.f))
        #expect(meets(paths[4], Self.a, Self.c))
        #expect(holds(paths[4], Self.b))
        #expect(meets(paths[5], Self.e, Self.c))
        #expect(holds(paths[5], Self.d))
    }

    @Test func everyPathHoldsTheCountAskedFor() throws {
        #expect(try extracted(diagonal).allSatisfy { $0.count == MeshFit.count })
        #expect(try extracted(axis).allSatisfy { $0.count == MeshFit.count })
    }

    /// The same three faces stand toward the viewer across the sweep, so what moves is where the paths are and not how many there are or how long each one is.
    @Test func turningTheBoxMovesItsPathsWithoutRebuildingThem() throws {
        let opening = try extracted(diagonal)

        for run: Float in [0.8, 0.9, 1.1, 1.2, 1.3] {
            let turned = try extracted(SIMD3<Float>(run, Float(3).squareRoot(), Float(2).squareRoot()))

            #expect(turned.count == opening.count)
            #expect(turned.map(\.count) == opening.map(\.count))
            #expect(zip(turned, opening).contains(where: { pair in pair.0 != pair.1 }))
        }
    }
}
