import Testing
@testable import Mobster

struct FieldResolutionTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(200, 100))

    /// A texel side of the epsilon times root two, so two hundred across at an epsilon of two is seventy one texels and not seventy, the count being rounded up rather than to.
    @Test func theCountFollowsFromTheSpanAndTheEpsilon() {
        #expect(FieldResolution(frame: frame, settleEpsilon: 2).count == 71)
        #expect(FieldResolution(frame: frame, settleEpsilon: 1).count == 142)
        #expect(FieldResolution(frame: frame, settleEpsilon: 0.5).count == 283)
    }

    /// The whole of the coupling: a read snaps to the containing texel, so the half diagonal it can be out by has to stay inside the tolerance the verts settle within.
    @Test func halfATexelDiagonalStaysWithinTheEpsilon() {
        for epsilon in [Float(0.25), 1, 3, 12] {
            let resolution = FieldResolution(frame: frame, settleEpsilon: epsilon)
            let texel = FieldGrid(frame: frame, columns: resolution.columns, rows: resolution.rows).texel

            #expect((texel.x * texel.x + texel.y * texel.y).squareRoot() / 2 <= epsilon)
        }
    }

    @Test func theCountLandsOnTheWiderAxisAndTheOtherTakesItsShare() {
        let resolution = FieldResolution(frame: frame, settleEpsilon: 1)

        #expect(resolution.columns == 142)
        #expect(resolution.rows == 71)
        #expect(resolution.texels == 142 * 71)
    }

    /// A degenerate Frame or a nonpositive epsilon counts no texels at all, which bakes an empty field rather than trapping the conversion.
    @Test func aDegenerateFrameOrEpsilonCountsNoTexels() {
        #expect(FieldResolution(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(200, 0)), settleEpsilon: 1).texels == 0)
        #expect(FieldResolution(frame: Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(0, 100)), settleEpsilon: 1).texels == 0)
        #expect(FieldResolution(frame: frame, settleEpsilon: 0).texels == 0)
        #expect(FieldResolution(frame: frame, settleEpsilon: -1).texels == 0)
    }

    /// An epsilon coarser than the whole Frame still asks for a field, of the one texel that answers it.
    @Test func anEpsilonCoarserThanTheFrameCountsOneTexel() {
        #expect(FieldResolution(frame: frame, settleEpsilon: 1000).count == 1)
    }

    /// An infinite epsilon is the answer a refusal gives when no epsilon is affordable, and it counts no texels rather than the one a coarse epsilon counts.
    @Test func anInfiniteEpsilonCountsNoTexels() {
        #expect(FieldResolution(frame: frame, settleEpsilon: .infinity).texels == 0)
    }

    @Test func theEpsilonForACountDerivesThatSameCount() {
        for count in [1, 7, 64, 71, 128, 1000, 4097] {
            #expect(FieldResolution(frame: frame, settleEpsilon: FieldResolution.epsilon(count: count, frame: frame)).count == count)
        }
    }
}
