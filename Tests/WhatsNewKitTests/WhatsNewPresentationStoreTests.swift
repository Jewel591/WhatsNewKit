import Foundation
import Testing
@testable import WhatsNewKit

@MainActor
@Test
func presentationStoreTracksThePresentedRelease() throws {
    let suiteName = "WhatsNewKitTests.\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }

    let store = WhatsNewPresentationStore(
        userDefaults: defaults,
        legacyWatermarkKeys: []
    )

    #expect(store.shouldPresent(releaseID: "2.0"))
    store.markPresented(releaseID: "2.0")
    #expect(!store.shouldPresent(releaseID: "2.0"))
    #expect(store.shouldPresent(releaseID: "2.1"))
    #expect(!store.shouldPresent(releaseID: "1.9"))
}

@MainActor
@Test
func presentationWatermarkNeverMovesBackwards() throws {
    let suiteName = "WhatsNewKitTests.\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }

    let store = WhatsNewPresentationStore(
        userDefaults: defaults,
        legacyWatermarkKeys: []
    )
    store.markPresented(releaseID: "1.10")
    store.markPresented(releaseID: "1.9")

    #expect(
        defaults.string(forKey: WhatsNewPresentationStore.defaultStorageKey)
            == "1.10"
    )
}

@MainActor
@Test(arguments: [
    ("1.2", "1.2.0"),
    ("1.2.0", "1.2.0.0"),
    ("26.18", "26.18.0"),
])
func equivalentReleaseIDsCompareEqual(lhs: String, rhs: String) {
    #expect(
        WhatsNewPresentationStore.compareReleaseIDs(lhs, rhs) == .orderedSame
    )
}
