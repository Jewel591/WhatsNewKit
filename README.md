# WhatsNewKit

A small SwiftUI component for presenting release highlights with an optional footer and a persistent "seen release" store.

WhatsNewKit deliberately contains no user-facing copy or localization resources. The host app localizes every string in its own String Catalog before passing it to the package.

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
    title: String(localized: "What's New"),
    actionTitle: String(localized: "Continue"),
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

The package renders injected strings verbatim. This keeps product copy and localization ownership in the host app and prevents package bundle lookup from interfering with the app's String Catalog.

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
