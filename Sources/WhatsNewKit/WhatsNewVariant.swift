import SwiftUI

/// The visual presentation used by ``WhatsNewView``.
///
/// Both variants render the same ``WhatsNewContent``. The MONO variant adds
/// an app-icon header, staged entrance animation, and its branded hierarchy.
public enum WhatsNewVariant {
    /// The system-oriented presentation used by default.
    case native

    /// The presentation designed for MONO, using an image supplied by the host app.
    case mono(appIcon: Image)
}

extension WhatsNewVariant {
    var defaultStyle: WhatsNewStyle {
        switch self {
        case .native:
            .standard
        case .mono:
            .mono
        }
    }
}
