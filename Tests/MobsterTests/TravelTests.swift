import Testing
@testable import Mobster

struct TravelTests {
    private let masses: [Float] = [0, 0.5, 1, 2, 8]
    private let drags: [Float] = [-1, -0.5, 0, 0.5, 1]

    @Test func neitherEndMovesWhateverTheAttributesAsk() {
        for mass in masses {
            for drag in drags {
                let travel = Travel(mass: mass, drag: drag)

                #expect(travel.fraction(at: 0) == 0)
                #expect(travel.fraction(at: 1) == 1)
            }
        }
    }

    @Test func aVertCarryingNoAttributesMakesThePlainTravel() {
        let travel = Travel(mass: nil, drag: nil)

        #expect(travel.fraction(at: 0.25) == 0.25)
        #expect(travel.fraction(at: 0.5) == 0.5)
        #expect(travel.fraction(at: 0.75) == 0.75)
    }

    @Test func anAbsentMassIsNotAMassOfZero() {
        #expect(Travel(mass: nil, drag: nil).fraction(at: 0.5) == 0.5)
        #expect(Travel(mass: 0, drag: nil).fraction(at: 0.5) == 1)
    }

    @Test func anAbsentDragIsNotADragOfZero() {
        #expect(Travel(mass: nil, drag: nil).fraction(at: 0.5) == 0.5)
        #expect(Travel(mass: nil, drag: 0).fraction(at: 0.5) == 0.25)
    }

    @Test func aHeavierVertStandsBehindALighterOne() {
        let standing = masses.map { Travel(mass: $0, drag: nil).fraction(at: 0.5) }

        #expect(standing[0] == 1)
        #expect(abs(standing[1] - Float(0.5).squareRoot()) < 1e-6)
        #expect(standing[2] == 0.5)
        #expect(standing[3] == 0.25)
        #expect(standing[4] == 0.00390625)
        #expect(zip(standing, standing.dropFirst()).allSatisfy { $0 > $1 })
    }

    @Test func aDragHoldsAVertBackAgainstThePlainTravel() {
        for drag in drags where drag < 1 {
            #expect(Travel(mass: nil, drag: drag).fraction(at: 0.5) < 0.5)
        }
    }

    @Test func aDragOfMinusOneLeadsAwayBeforeItReturns() {
        let travel = Travel(mass: nil, drag: -1)

        #expect(travel.fraction(at: 0.25) == -0.125)
        #expect(travel.fraction(at: 0.5) == 0)
        #expect(travel.fraction(at: 0.75) == 0.375)
        #expect(travel.fraction(at: 1) == 1)
    }

    @Test func theWeightIsSpentBeforeTheResistanceIsApplied() {
        #expect(Travel(mass: 2, drag: -1).fraction(at: 0.5) == -0.125)
    }
}
