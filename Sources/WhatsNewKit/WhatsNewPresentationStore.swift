import Foundation

@MainActor
final class WhatsNewPresentationStore {
    static let defaultStorageKey = "WhatsNewKit.lastSeenRelease"

    private let userDefaults: UserDefaults

    init(
        userDefaults: UserDefaults,
        legacyWatermarkKeys: [String]
    ) {
        self.userDefaults = userDefaults
        seedCanonicalWatermark(from: legacyWatermarkKeys)
    }

    func shouldPresent(releaseID: String) -> Bool {
        guard let lastSeenReleaseID = userDefaults.string(forKey: Self.defaultStorageKey) else {
            return true
        }

        return Self.compareReleaseIDs(
            releaseID,
            lastSeenReleaseID
        ) == .orderedDescending
    }

    func shouldPresent(_ content: WhatsNewContent) -> Bool {
        shouldPresent(releaseID: content.releaseID)
    }

    func markPresented(releaseID: String) {
        let watermark: String
        if let lastSeenReleaseID = userDefaults.string(forKey: Self.defaultStorageKey),
           Self.compareReleaseIDs(releaseID, lastSeenReleaseID) != .orderedDescending {
            watermark = lastSeenReleaseID
        } else {
            watermark = releaseID
        }

        userDefaults.set(watermark, forKey: Self.defaultStorageKey)
    }

    func markPresented(_ content: WhatsNewContent) {
        markPresented(releaseID: content.releaseID)
    }

    static func compareReleaseIDs(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let lhsComponents = lhs.split(separator: ".", omittingEmptySubsequences: false)
        let rhsComponents = rhs.split(separator: ".", omittingEmptySubsequences: false)

        for index in 0..<max(lhsComponents.count, rhsComponents.count) {
            let lhsComponent = index < lhsComponents.count ? String(lhsComponents[index]) : "0"
            let rhsComponent = index < rhsComponents.count ? String(rhsComponents[index]) : "0"
            let result = lhsComponent.compare(rhsComponent, options: .numeric)
            if result != .orderedSame {
                return result
            }
        }

        return .orderedSame
    }

    private func seedCanonicalWatermark(from legacyWatermarkKeys: [String]) {
        let candidates = [Self.defaultStorageKey] + legacyWatermarkKeys
        let watermark = candidates
            .compactMap { userDefaults.string(forKey: $0) }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .max {
                Self.compareReleaseIDs($0, $1) == .orderedAscending
            }

        if let watermark,
           userDefaults.string(forKey: Self.defaultStorageKey) != watermark {
            userDefaults.set(watermark, forKey: Self.defaultStorageKey)
        }
    }
}
