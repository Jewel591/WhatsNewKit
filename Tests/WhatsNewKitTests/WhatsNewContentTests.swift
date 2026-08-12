import Testing
import SwiftUI
@testable import WhatsNewKit

@Test
func contentUsesReleaseIDForIdentity() {
    let content = WhatsNewContent(
        releaseID: "2.0",
        highlights: []
    )

    #expect(content.id == "2.0")
}

@MainActor
@Test
func viewSupportsNativeAndMonoVariantsWithTheSameContent() {
    let content = WhatsNewContent(releaseID: "2.0", highlights: [])

    _ = WhatsNewView(content: content) {}
    _ = WhatsNewView(
        content: content,
        variant: .mono(appIcon: Image(systemName: "app.fill"))
    ) {}
}

@Test
func highlightSupportsStableExplicitIdentity() {
    let highlight = WhatsNewContent.Highlight(
        id: "search",
        symbol: "magnifyingglass",
        title: "Faster Search",
        detail: "Find things more quickly."
    )

    #expect(highlight.id == "search")
}
