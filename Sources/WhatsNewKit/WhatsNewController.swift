import Foundation
import Observation

/// Owns the portfolio-wide rules for selecting, presenting, and acknowledging
/// release highlights. The host owns only its current content and app-wide
/// surface coordination.
@MainActor
@Observable
public final class WhatsNewController {
    public private(set) var presentedContent: WhatsNewContent?

    private let currentReleaseID: String
    private let content: WhatsNewContent?
    private let presentationStore: WhatsNewPresentationStore

    public init(
        content: WhatsNewContent? = nil,
        legacyWatermarkKeys: [String] = [],
        userDefaults: UserDefaults = .standard
    ) {
        currentReleaseID = WhatsNewContent.currentAppReleaseID
        self.content = content
        presentationStore = WhatsNewPresentationStore(
            userDefaults: userDefaults,
            legacyWatermarkKeys: legacyWatermarkKeys
        )
    }

    init(
        currentReleaseID: String,
        content: WhatsNewContent?,
        legacyWatermarkKeys: [String] = [],
        userDefaults: UserDefaults
    ) {
        self.currentReleaseID = currentReleaseID
        self.content = content
        presentationStore = WhatsNewPresentationStore(
            userDefaults: userDefaults,
            legacyWatermarkKeys: legacyWatermarkKeys
        )
    }

    /// Returns the current release's non-empty content when it has not already
    /// been acknowledged.
    ///
    /// This method never mutates the seen watermark, so a surface coordinator
    /// can evaluate the candidate without consuming it.
    public func eligibleContent() -> WhatsNewContent? {
        guard let content,
              !content.highlights.isEmpty,
              WhatsNewPresentationStore.compareReleaseIDs(
                content.releaseID,
                currentReleaseID
              ) == .orderedSame,
              presentationStore.shouldPresent(content) else {
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

}
