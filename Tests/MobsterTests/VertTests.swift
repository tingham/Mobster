import Testing
@testable import Mobster

struct VertTests {
    private let location = SIMD2<Float>(10, 20)

    @Test func aVertWithNoAttributesIsNotAVertWhoseAttributesAreZero() {
        let absent = Vert(location: location)
        let zeroed = Vert(location: location, mass: 0, drag: 0, coupling: 0)

        #expect(absent.mass == nil)
        #expect(absent.drag == nil)
        #expect(absent.coupling == nil)
        #expect(zeroed.mass == 0)
        #expect(zeroed.drag == 0)
        #expect(zeroed.coupling == 0)
        #expect(absent.mass != zeroed.mass)
        #expect(absent.drag != zeroed.drag)
        #expect(absent.coupling != zeroed.coupling)
    }

    @Test func aVertNeedsNoIdentifier() {
        #expect(Vert(location: location).identifier == nil)
    }

    @Test func anAttributeSuppliedIsTheAttributeCarried() {
        let vert = Vert(location: location, identifier: VertIdentifier(7), mass: 2.5, drag: -1, coupling: -0.25)

        #expect(vert.identifier == VertIdentifier(7))
        #expect(vert.mass == 2.5)
        #expect(vert.drag == -1)
        #expect(vert.coupling == -0.25)
    }

    @Test func aVertStandsWhereItWasPut() {
        #expect(Vert(location: location).location == location)
    }
}
