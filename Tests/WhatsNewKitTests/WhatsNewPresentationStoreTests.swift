import Foundation
import Testing
@testable import WhatsNewKit

@MainActor
@Test
func presentationStoreTracksThePresentedRelease() throws {
    let suiteName = "WhatsNewKitTests.\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }

    let store = WhatsNewPresentationStore(userDefaults: defaults)

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

    let store = WhatsNewPresentationStore(userDefaults: defaults)
    store.markPresented(releaseID: "1.10")
    store.markPresented(releaseID: "1.9")

    #expect(
        defaults.string(forKey: WhatsNewPresentationStore.defaultStorageKey)
            == "1.10"
    )
}

@MainActor
@Test
func customStorageKeysKeepIndependentFeeds() throws {
    let suiteName = "WhatsNewKitTests.\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }

    let primary = WhatsNewPresentationStore(
        userDefaults: defaults,
        storageKey: "primary"
    )
    let secondary = WhatsNewPresentationStore(
        userDefaults: defaults,
        storageKey: "secondary"
    )

    primary.markPresented(releaseID: "2.0")

    #expect(!primary.shouldPresent(releaseID: "2.0"))
    #expect(secondary.shouldPresent(releaseID: "2.0"))
}
