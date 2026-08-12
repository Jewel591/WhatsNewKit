# WhatsNewKit

A small SwiftUI component for presenting release highlights with an optional footer and a persistent "seen release" store.

WhatsNewKit owns and localizes its fixed "What's New" title and "Continue" action. The host app localizes release-specific highlights and footer copy in its own String Catalog before passing them to the package.

## Requirements

- iOS 17+
- macOS 14+
- visionOS 1+
- Swift 6

## Usage

```swift
import SwiftUI
import WhatsNewKit

let content = WhatsNewContent(
    releaseID: "2.0.0",
    highlights: [
        .init(
            symbol: "sparkles",
            title: String(localized: "A New Experience"),
            detail: String(localized: "Everything feels faster and more familiar.")
        )
    ],
    footer: .init(
        symbol: "lock.shield",
        message: String(localized: "Your data stays private.")
    )
)

WhatsNewView(content: content) {
    dismiss()
}
```

The package renders injected release copy verbatim, while its two fixed strings are resolved from the package bundle. This keeps product-specific localization in the host app without duplicating the component's standard labels across projects.

## Presentation state

```swift
@MainActor
func presentIfNeeded(_ content: WhatsNewContent) {
    let store = WhatsNewPresentationStore()
    guard store.shouldPresent(content) else { return }
    // Present WhatsNewView.
}
```

The host app remains responsible for presentation timing and coordination with onboarding, paywalls, and other sheets.
