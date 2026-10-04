import Mobster
import Testing

/// The roster a consumer offers a person to choose from and the keys it stores that choice by, read through the public surface rather than through a testable import.
struct PresetKindTests {
    /// Pinned case by case rather than as an ordered run, because the key survives a reorder as well as a rename.
    @Test func everyCaseCarriesItsStableKey() {
        for kind in PresetKind.allCases {
            #expect(kind.rawValue == Self.key(kind))
        }
    }

    /// What a consumer wrote down comes back as the case the person picked.
    @Test func aStoredKeyResolvesBackToTheCaseItWasTakenFrom() {
        #expect(PresetKind.allCases.count == 10)
        #expect(Set(PresetKind.allCases.map(\.rawValue)).count == PresetKind.allCases.count)
        #expect(PresetKind.allCases.allSatisfy { PresetKind(rawValue: $0.rawValue) == $0 })
    }

    /// An unknown key is nothing the roster holds, which a consumer reading a stored choice from an older release needs told rather than substituted for.
    @Test func aKeyTheRosterDoesNotHoldResolvesToNothing() {
        #expect(PresetKind(rawValue: "ashcan") == nil)
    }

    /// The switch is exhaustive, so a case added to the roster fails to compile here until its key is pinned.
    private static func key(_ kind: PresetKind) -> String {
        switch kind {
        case .goldenRatio: "goldenRatio"
        case .thirds: "thirds"
        case .columns: "columns"
        case .rows: "rows"
        case .grid: "grid"
        case .ruler: "ruler"
        case .curve: "curve"
        case .head: "head"
        case .figure: "figure"
        case .cube: "cube"
        }
    }
}
