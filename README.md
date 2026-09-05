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

`WhatsNewContent` automatically uses the host app's
`CFBundleShortVersionString` as its release identity. Each app binary supplies
only its current release content; historical release catalogs are intentionally
not part of the public API.

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
    content: currentReleaseContent
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

`WhatsNewController` presents only the running app version's current, non-empty
content. Content is shown once and is marked seen only after a real dismissal.
Pass `nil` when a release has no highlights worth presenting; don't construct
empty content and don't carry historical content forward.

A fresh install is the one explicit exception. Onboarding has already told the
user what the app does, so replaying the same release as "what's new" straight
after it is a duplicate. The host calls `markInstalledVersionSeen()` on the
fresh-install onboarding completion path, before it releases any other launch
surface:

```swift
// Fresh install only. Never call this on an upgrade path.
controller.markInstalledVersionSeen()
```

It retires the running release, drops anything already queued by `present(_:)`,
and — because the watermark only ever moves forward — cannot push an upgrading
user past content they have not seen.

When migrating an app that previously stored a last-seen version under its own
UserDefaults key, let the package seed its canonical watermark without deleting
the legacy value:

```swift
let controller = WhatsNewController(
    content: currentReleaseContent,
    legacyWatermarkKeys: ["legacy.whats-new.last-seen"]
)
```

The host app remains responsible only for its localized current content and for
presentation timing/coordination with onboarding, paywalls, and other sheets.
