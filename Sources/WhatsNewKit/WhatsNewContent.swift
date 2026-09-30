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

    /// Creates content for the release it was written for.
    ///
    /// `release` is the marketing version whose release notes this content
    /// introduces. Keep it unchanged while later releases carry the same
    /// content: users who already saw it are not shown it again, and users who
    /// upgrade from an earlier release still see it. Update it together with the
    /// highlights whenever the content changes.
    public init(
        release: String,
        highlights: [Highlight],
        footer: Footer? = nil
    ) {
        self.releaseID = release
        self.highlights = highlights
        self.footer = footer
    }

    /// Creates content that claims the running app version as its release.
    ///
    /// Content left unchanged across an app update is presented again as the
    /// new release's content, even to users who already saw it.
    @available(
        *,
        deprecated,
        message: "Declare the release this content was written for with init(release:highlights:footer:). Removed in 1.0.0."
    )
    public init(
        highlights: [Highlight],
        footer: Footer? = nil
    ) {
        self.init(
            release: Self.currentAppReleaseID,
            highlights: highlights,
            footer: footer
        )
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
