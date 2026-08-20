import Foundation
import Testing
@testable import WhatsNewKit

@MainActor
struct WhatsNewControllerTests {
    @Test
    func resolvesLatestNonEmptyContentNotNewerThanRunningVersion() {
        let controller = WhatsNewController(
            currentReleaseID: "1.11",
            catalog: [
                content("1.5"),
                content("1.10"),
                content("2.0"),
                WhatsNewContent(releaseID: "1.11", highlights: []),
            ]
        )

        #expect(controller.eligibleContent()?.releaseID == "1.10")
    }

    @Test
    func dismissalMarksOnlyActuallyPresentedContent() throws {
        let defaults = try testDefaults()
        let controller = WhatsNewController(
            currentReleaseID: "1.11",
            catalog: [content("1.10")],
            userDefaults: defaults
        )

        controller.dismissPresentedRelease()
        #expect(lastSeenVersion(in: defaults) == nil)

        let candidate = try #require(controller.eligibleContent())
        controller.present(candidate)
        #expect(lastSeenVersion(in: defaults) == nil)

        controller.dismissPresentedRelease()
        #expect(lastSeenVersion(in: defaults) == "1.10")
        #expect(controller.presentedContent == nil)
    }

    @Test
    func freshInstallSeedsRunningVersionAndCancelsQueuedContent() throws {
        let defaults = try testDefaults()
        let controller = WhatsNewController(
            currentReleaseID: "1.11",
            catalog: [content("1.10")],
            userDefaults: defaults
        )

        controller.presentWhatsNewIfNeeded()
        #expect(controller.presentedContent?.releaseID == "1.10")

        controller.markInstalledVersionSeen()

        #expect(lastSeenVersion(in: defaults) == "1.11")
        #expect(controller.presentedContent == nil)
        #expect(controller.eligibleContent() == nil)
    }

    @Test
    func existingNewerWatermarkIsNeverDowngraded() throws {
        let defaults = try testDefaults()
        defaults.set("1.12", forKey: WhatsNewPresentationStore.defaultStorageKey)
        let controller = WhatsNewController(
            currentReleaseID: "1.11",
            catalog: [content("1.10")],
            userDefaults: defaults
        )

        controller.markInstalledVersionSeen()

        #expect(lastSeenVersion(in: defaults) == "1.12")
        #expect(controller.eligibleContent() == nil)
    }

    private func content(_ releaseID: String) -> WhatsNewContent {
        WhatsNewContent(
            releaseID: releaseID,
            highlights: [
                .init(
                    id: "feature",
                    symbol: "sparkles",
                    title: "Feature",
                    detail: "Detail"
                )
            ]
        )
    }

    private func testDefaults() throws -> UserDefaults {
        let suiteName = "WhatsNewControllerTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    private func lastSeenVersion(in defaults: UserDefaults) -> String? {
        defaults.string(forKey: WhatsNewPresentationStore.defaultStorageKey)
    }
}
