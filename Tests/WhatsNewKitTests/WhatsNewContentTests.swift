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

// Issue #6 回归：内容身份来自宿主声明的版本，而不是正在运行的 App 版本。
@Test
func contentUsesTheDeclaredRelease() {
    let content = WhatsNewContent(release: "26.35.0", highlights: [])

    #expect(content.releaseID == "26.35.0")
}

@available(*, deprecated)
@Test
func contentDefaultsToTheHostAppRelease() {
    let content = WhatsNewContent(highlights: [])

    #expect(content.releaseID == WhatsNewContent.currentAppReleaseID)
}

@Test(arguments: [
    ("2.1.0", "42", "2.1.0"),
    (nil, "42", "42"),
    ("  ", "42", "42"),
    (nil, nil, "unversioned"),
])
func releaseIdentityFallbacks(
    marketingVersion: String?,
    buildVersion: String?,
    expected: String
) {
    #expect(
        WhatsNewContent.resolvedReleaseID(
            marketingVersion: marketingVersion,
            buildVersion: buildVersion
        ) == expected
    )
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
