import Testing
@testable import WhatsNewKit

@Test
func contentUsesReleaseIDForIdentity() {
    let content = WhatsNewContent(
        releaseID: "2.0",
        title: "What's New",
        actionTitle: "Continue",
        highlights: []
    )

    #expect(content.id == "2.0")
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
