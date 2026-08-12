import Foundation

@MainActor
public final class WhatsNewPresentationStore {
    public static let defaultStorageKey = "WhatsNewKit.lastSeenRelease"

    private let userDefaults: UserDefaults
    private let storageKey: String

    public init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = WhatsNewPresentationStore.defaultStorageKey
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    public func shouldPresent(releaseID: String) -> Bool {
        userDefaults.string(forKey: storageKey) != releaseID
    }

    public func shouldPresent(_ content: WhatsNewContent) -> Bool {
        shouldPresent(releaseID: content.releaseID)
    }

    public func markPresented(releaseID: String) {
        userDefaults.set(releaseID, forKey: storageKey)
    }

    public func markPresented(_ content: WhatsNewContent) {
        markPresented(releaseID: content.releaseID)
    }
}
