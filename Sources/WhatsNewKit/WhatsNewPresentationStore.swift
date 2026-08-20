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
        guard let lastSeenReleaseID = userDefaults.string(forKey: storageKey) else {
            return true
        }

        return Self.compareReleaseIDs(
            releaseID,
            lastSeenReleaseID
        ) == .orderedDescending
    }

    public func shouldPresent(_ content: WhatsNewContent) -> Bool {
        shouldPresent(releaseID: content.releaseID)
    }

    public func markPresented(releaseID: String) {
        let watermark: String
        if let lastSeenReleaseID = userDefaults.string(forKey: storageKey),
           Self.compareReleaseIDs(releaseID, lastSeenReleaseID) != .orderedDescending {
            watermark = lastSeenReleaseID
        } else {
            watermark = releaseID
        }

        userDefaults.set(watermark, forKey: storageKey)
    }

    public func markPresented(_ content: WhatsNewContent) {
        markPresented(releaseID: content.releaseID)
    }

    static func compareReleaseIDs(_ lhs: String, _ rhs: String) -> ComparisonResult {
        lhs.compare(rhs, options: .numeric)
    }
}
