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

`WhatsNewContent` uses the host app's `CFBundleShortVersionString` as its release
identity automatically. Pass `releaseID:` explicitly only for tests, staged
content, or custom version mapping:

```swift
let content = WhatsNewContent(
    releaseID: "spring-2027",
    highlights: highlights
)
```

The native presentation is the default. To use the MONO presentation with the
same content model, pass the host app's icon and inherit or apply the desired tint:

```swift
WhatsNewView(
    content: content,
    variant: .mono(appIcon: Image("AppIcon"))
) {
    dismiss()
}
.tint(.accentColor)
.presentationDetents([.height(600)])
.presentationDragIndicator(.hidden)
```

The sheet detent remains host-owned because presentation containers differ by app
and platform; the MONO example uses the same 600-point detent as the original design.

The package renders injected release copy verbatim, while its two fixed strings are resolved from the package bundle. This keeps product-specific localization in the host app without duplicating the component's standard labels across projects.

## Presentation state and release selection

```swift
let controller = WhatsNewController(
    catalog: [contentForVersion1_2, contentForVersion1_3]
)

// Safe to call while app-wide surface arbitration is collecting candidates.
let candidate = controller.eligibleContent()

// Call only for the winning surface.
if let candidate {
    controller.present(candidate)
}

// Call only after the user closes the actual presentation.
controller.dismissPresentedRelease()
```

`WhatsNewController` selects the newest non-empty catalog entry not newer than
the running app, compares versions numerically, preserves a monotonic seen
watermark, and marks content seen only after a real dismissal. On a fresh install,
call `markInstalledVersionSeen()` when onboarding completes so historical release
notes are not presented as an upgrade.

The host app remains responsible only for its localized content catalog and for
presentation timing/coordination with onboarding, paywalls, and other sheets.
