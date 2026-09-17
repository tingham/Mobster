import Testing
@testable import Mobster

struct MeshPerspectiveTests {
    @Test func theFieldOpensAtTheConeOfVision() {
        #expect(MeshPerspective.opening == 60)
        #expect(MeshPerspective().fieldOfView == 60)
    }

    /// Below the range the projection is the orthographic one it replaces and above it the near of a form swells into a fisheye, so both cases are removed rather than answered.
    @Test func theFieldIsHeldWithinTheRangeThatReads() {
        #expect(MeshPerspective(fieldOfView: 0).fieldOfView == MeshPerspective.range.lowerBound)
        #expect(MeshPerspective(fieldOfView: -40).fieldOfView == MeshPerspective.range.lowerBound)
        #expect(MeshPerspective(fieldOfView: 179).fieldOfView == MeshPerspective.range.upperBound)
        #expect(MeshPerspective(fieldOfView: 45).fieldOfView == 45)
    }

    /// Half the transverse bounds over the tangent of half the field, which four hundred across puts at two hundred over tan thirty and at two hundred over tan forty five.
    @Test func theRemoveFollowsFromTheFieldAndTheBounds() {
        #expect(abs(MeshPerspective(fieldOfView: 60).distance(across: 400) - 346.410) < 0.001)
        #expect(abs(MeshPerspective(fieldOfView: 90).distance(across: 400) - 200) < 0.001)
    }

    /// A wider field stands the viewer nearer the same construction, which is what makes the far side of it pull in further.
    @Test func aWiderFieldStandsTheViewerNearer() {
        #expect(MeshPerspective(fieldOfView: 90).distance(across: 400) < MeshPerspective(fieldOfView: 20).distance(across: 400))
    }

    /// The nearest location keeps the place the orthographic projection gave it, which is what holds a construction that fitted the Frame inside it.
    @Test func theNearestLocationIsNotMagnified() {
        #expect(MeshPerspective().magnification(behind: 0, across: 400) == 1)
    }

    /// At the remove itself the depth of the triangle has doubled, so the location reads half the size.
    @Test func aLocationAsFarBehindAsTheRemoveIsHalved() {
        #expect(abs(MeshPerspective(fieldOfView: 90).magnification(behind: 200, across: 400) - 0.5) < 0.0001)
    }

    /// A construction with no transverse extent carries no remove to view it from, so it projects as it stood rather than dividing by nothing.
    @Test func aConstructionWithNoBoundsIsNotMagnified() {
        #expect(MeshPerspective().magnification(behind: 10, across: 0) == 1)
    }
}
