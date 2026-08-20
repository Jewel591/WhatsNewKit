import Foundation
import Observation

/// Owns the portfolio-wide rules for selecting, presenting, and acknowledging
/// release highlights. The host owns only its content catalog and app-wide
/// surface coordination.
@MainActor
@Observable
public final class WhatsNewController {
    public private(set) var presentedContent: WhatsNewContent?

    private let currentReleaseID: String
    private let catalog: [WhatsNewContent]
    private let presentationStore: WhatsNewPresentationStore

    public init(
        currentReleaseID: String = WhatsNewContent.currentAppReleaseID,
        catalog: [WhatsNewContent],
        userDefaults: UserDefaults = .standard
    ) {
        self.currentReleaseID = currentReleaseID
        self.catalog = catalog
        presentationStore = WhatsNewPresentationStore(userDefaults: userDefaults)
    }

    /// Returns the newest non-empty catalog entry that is not newer than the
    /// running app and has not already been acknowledged.
    ///
    /// This method never mutates the seen watermark, so a surface coordinator
    /// can evaluate the candidate without consuming it.
    public func eligibleContent() -> WhatsNewContent? {
        guard let content = Self.latestContent(
            notNewerThan: currentReleaseID,
            in: catalog
        ), presentationStore.shouldPresent(content) else {
            return nil
        }

        return content
    }

    /// Records that the host actually presented the selected surface.
    public func present(_ content: WhatsNewContent) {
        presentedContent = content
    }

    /// Convenience for hosts without a separate surface coordinator.
    public func presentWhatsNewIfNeeded() {
        guard let content = eligibleContent() else { return }
        present(content)
    }

    /// Acknowledges only content that was actually presented.
    public func dismissPresentedRelease() {
        guard let content = presentedContent else { return }
        presentationStore.markPresented(content)
        presentedContent = nil
    }

    /// Seeds a fresh install through the running release so historical catalog
    /// entries are not presented as an upgrade immediately after onboarding.
    public func markInstalledVersionSeen() {
        presentationStore.markPresented(releaseID: currentReleaseID)
        presentedContent = nil
    }

    static func latestContent(
        notNewerThan currentReleaseID: String,
        in catalog: [WhatsNewContent]
    ) -> WhatsNewContent? {
        catalog
            .filter {
                !$0.highlights.isEmpty
                    && WhatsNewPresentationStore.compareReleaseIDs(
                        $0.releaseID,
                        currentReleaseID
                    ) != .orderedDescending
            }
            .max {
                WhatsNewPresentationStore.compareReleaseIDs(
                    $0.releaseID,
                    $1.releaseID
                ) == .orderedAscending
            }
    }
}
