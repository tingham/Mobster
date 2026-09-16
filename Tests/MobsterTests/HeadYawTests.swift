import Foundation
import Testing
@testable import Mobster

struct HeadYawTests {
    private func degrees(_ view: Float) -> Float {
        acos(HeadYaw(view: view).cosine) * 180 / .pi
    }

    @Test func theEndsOfTheRangeAreProfileAndFaceForward() {
        #expect(abs(degrees(0) - 90) < 0.001)
        #expect(abs(degrees(1)) < 0.001)
    }

    /// Three quarters of the frontal breadth still projecting is the three quarter view, and the yaw that leaves sits nearer forty degrees than the forty five a dial linear in angle would put here.
    @Test func theMiddleOfTheRangeIsTheThreeQuarterView() {
        #expect(abs(HeadYaw(view: 0.5).cosine - 0.75) < 0.0001)
        #expect(abs(degrees(0.5) - 41.4096) < 0.001)
    }

    @Test func theTurnCarriesTheSineOfItsYaw() {
        #expect(abs(HeadYaw(view: 0).sine - 1) < 0.0001)
        #expect(abs(HeadYaw(view: 0.5).sine - 0.661438) < 0.0001)
        #expect(abs(HeadYaw(view: 1).sine) < 0.0001)
    }

    @Test func faceForwardProjectsBreadthAndProfileProjectsDepth() {
        #expect(HeadYaw(view: 1).projected(SIMD3<Float>(3, 5, 7)) == SIMD2<Float>(3, 5))
        #expect(HeadYaw(view: 0).projected(SIMD3<Float>(3, 5, 7)) == SIMD2<Float>(7, 5))
    }
}
