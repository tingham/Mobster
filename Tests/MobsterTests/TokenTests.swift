import Testing
@testable import Mobster

struct TokenTests {
    private let frame = Frame(origin: SIMD2<Float>(0, 0), size: SIMD2<Float>(128, 128))

    private func field() -> Field {
        FieldBake(paths: [[SIMD2<Float>(64.5, 0), SIMD2<Float>(64.5, 128)]], frame: frame, resolution: 128).field()
    }

    @Test func tokenIsCreatedForEveryPointInTheMembership() {
        let guide = Guide(frame: frame, adherence: Adherence(reach: 40), settleEpsilon: 1)
        let strokes = [
            Stroke(identifier: StrokeIdentifier(1), samples: [
                Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
                Sample(identifier: PointIdentifier(2), location: SIMD2<Float>(24.5, 32.5)),
            ]),
            Stroke(identifier: StrokeIdentifier(2), samples: [
                Sample(identifier: PointIdentifier(3), location: SIMD2<Float>(100.5, 64.5)),
            ]),
        ]
        guide.initialize(frame: frame, membership: strokes)

        #expect(guide.tokens.count == 3)
        #expect(guide.membership == [PointIdentifier(1), PointIdentifier(2), PointIdentifier(3)])
    }

    @Test func tokenCarriesBothIdentifiersAndTheLocation() {
        let guide = Guide(frame: frame, adherence: Adherence(reach: 40), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(7), samples: [
            Sample(identifier: PointIdentifier(11), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])

        let token = guide.tokens[PointIdentifier(11)]
        #expect(token?.point == PointIdentifier(11))
        #expect(token?.stroke == StrokeIdentifier(7))
        #expect(token?.location == SIMD2<Float>(24.5, 64.5))
        #expect(token?.origin == 0)
    }

    @Test func existingTokenIsReused() {
        let guide = Guide(frame: frame, adherence: Adherence(reach: .infinity), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(field: field(), time: 0)
        _ = guide.play(speed: 10, time: 1)

        let advanced = guide.tokens[PointIdentifier(1)]?.location
        guide.tokenize(membership: [stroke], time: 5)

        #expect(guide.tokens.count == 1)
        #expect(guide.membership.count == 1)
        #expect(guide.tokens[PointIdentifier(1)]?.location == advanced)
        // The segment began at tokenization and neither the play nor the redelivery starts another.
        #expect(guide.tokens[PointIdentifier(1)]?.origin == 0)
    }

    @Test func newPointJoinsTheMembershipWithoutDisturbingTheRest() {
        let guide = Guide(frame: frame, adherence: Adherence(reach: 40), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])

        let joined = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(0, 0)),
            Sample(identifier: PointIdentifier(2), location: SIMD2<Float>(40.5, 64.5)),
        ])
        guide.tokenize(membership: [joined], time: 3)

        #expect(guide.membership == [PointIdentifier(1), PointIdentifier(2)])
        #expect(guide.tokens[PointIdentifier(1)]?.location == SIMD2<Float>(24.5, 64.5))
        #expect(guide.tokens[PointIdentifier(2)]?.origin == 3)
    }

    @Test func aTokenizedPointResolvesItsTargetAgainstThePresentField() {
        let guide = Guide(frame: frame, adherence: Adherence(reach: 30), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])
        guide.update(field: field(), time: 0)

        let joined = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(2), location: SIMD2<Float>(24.5, 32.5)),
        ])
        guide.tokenize(membership: [joined], time: 1)

        // Forty units out, a reach of thirty, so nine twenty fifths of the distance: 24.5 + 14.4.
        #expect(abs((guide.tokens[PointIdentifier(2)]?.target.x ?? 0) - 38.9) < 1e-3)
        #expect(guide.tokens[PointIdentifier(2)]?.target.y == 32.5)
    }

    @Test func aStrokeRedeliveredWithoutAPointKeepsEveryToken() {
        let guide = Guide(frame: frame, adherence: Adherence(reach: 40), settleEpsilon: 1)
        let stroke = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
            Sample(identifier: PointIdentifier(2), location: SIMD2<Float>(24.5, 32.5)),
        ])
        guide.initialize(frame: frame, membership: [stroke])

        let dropped = Stroke(identifier: StrokeIdentifier(1), samples: [
            Sample(identifier: PointIdentifier(1), location: SIMD2<Float>(24.5, 64.5)),
        ])
        guide.tokenize(membership: [dropped], time: 1)

        #expect(guide.tokens.count == 2)
        #expect(guide.membership == [PointIdentifier(1), PointIdentifier(2)])
    }
}
