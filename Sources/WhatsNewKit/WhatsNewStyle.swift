import SwiftUI

public struct WhatsNewStyle: Sendable {
    public var titleFont: Font
    public var highlightTitleFont: Font
    public var highlightDetailFont: Font
    public var footerFont: Font

    public init(
        titleFont: Font = .title.bold(),
        highlightTitleFont: Font = .headline.weight(.semibold),
        highlightDetailFont: Font = .body,
        footerFont: Font = .footnote
    ) {
        self.titleFont = titleFont
        self.highlightTitleFont = highlightTitleFont
        self.highlightDetailFont = highlightDetailFont
        self.footerFont = footerFont
    }

    public static let standard = WhatsNewStyle()
}
