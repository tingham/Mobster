import Testing
@testable import Mobster

struct IdentifierTests {
    /// Opacity is a negative property no runtime assertion reaches, so the conformance list stands in for it: an identifier that gained an ordering or an arithmetic still keys a dictionary and still passes an equality test.
    private let identifierTypes: [Any.Type] = [VertIdentifier.self, LineIdentifier.self]

    private func requireSendable<T: Sendable>(_ type: T.Type) {}

    @Test func identifiersKey() {
        for type in identifierTypes {
            #expect(type is any Hashable.Type)
        }
    }

    @Test func identifiersCrossTheBoundary() {
        requireSendable(VertIdentifier.self)
        requireSendable(LineIdentifier.self)
    }

    @Test func identifiersDoNotOrder() {
        for type in identifierTypes {
            #expect(!(type is any Comparable.Type))
            #expect(!(type is any Strideable.Type))
        }
    }

    @Test func identifiersDoNotCalculate() {
        for type in identifierTypes {
            #expect(!(type is any AdditiveArithmetic.Type))
            #expect(!(type is any Numeric.Type))
            #expect(!(type is any BinaryInteger.Type))
            #expect(!(type is any FixedWidthInteger.Type))
        }
    }
}
