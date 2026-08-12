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

    public let releaseID: String
    public let title: String
    public let actionTitle: String
    public let highlights: [Highlight]
    public let footer: Footer?

    public var id: String { releaseID }

    public init(
        releaseID: String,
        title: String,
        actionTitle: String,
        highlights: [Highlight],
        footer: Footer? = nil
    ) {
        self.releaseID = releaseID
        self.title = title
        self.actionTitle = actionTitle
        self.highlights = highlights
        self.footer = footer
    }
}
