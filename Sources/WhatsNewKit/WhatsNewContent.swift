import Foundation

public struct WhatsNewContent: Identifiable, Hashable, Sendable {
    public struct Highlight: Identifiable, Hashable, Sendable {
        public let id: String
        public let symbol: String
        public let title: String
        public let detail: String

        public init(
            id: String? = nil,
            symbol: String,
            title: String,
            detail: String
        ) {
            self.id = id ?? title
            self.symbol = symbol
            self.title = title
            self.detail = detail
        }
    }

    public struct Footer: Hashable, Sendable {
        public let symbol: String
        public let message: String

        public init(symbol: String, message: String) {
            self.symbol = symbol
            self.message = message
        }
    }

    let releaseID: String
    public let highlights: [Highlight]
    public let footer: Footer?

    public var id: String { releaseID }

    /// The host app's marketing version, falling back to its build number when needed.
    ///
    /// This intentionally reads `Bundle.main`, not `Bundle.module`, because the
    /// release being presented belongs to the app embedding WhatsNewKit.
    static var currentAppReleaseID: String {
        resolvedReleaseID(
            marketingVersion: Bundle.main.object(
                forInfoDictionaryKey: "CFBundleShortVersionString"
            ) as? String,
            buildVersion: Bundle.main.object(
                forInfoDictionaryKey: "CFBundleVersion"
            ) as? String
        )
    }

    /// Creates content for the current host app version.
    public init(
        highlights: [Highlight],
        footer: Footer? = nil
    ) {
        self.init(
            releaseID: Self.currentAppReleaseID,
            highlights: highlights,
            footer: footer
        )
    }

    /// Test seam for exercising release identity without changing the host bundle.
    init(
        releaseID: String,
        highlights: [Highlight],
        footer: Footer? = nil
    ) {
        self.releaseID = releaseID
        self.highlights = highlights
        self.footer = footer
    }

    static func resolvedReleaseID(
        marketingVersion: String?,
        buildVersion: String?
    ) -> String {
        for candidate in [marketingVersion, buildVersion] {
            let value = candidate?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !value.isEmpty {
                return value
            }
        }

        return "unversioned"
    }
}
