import Foundation
import Testing
@testable import WhatsNewKit

@MainActor
struct WhatsNewControllerTests {
    @Test
    func productionInitializerUsesTheHostReleaseIdentity() throws {
        let defaults = try testDefaults()
        let content = WhatsNewContent(
            highlights: [
                .init(
                    symbol: "sparkles",
                    title: "Feature",
                    detail: "Detail"
                )
            ]
        )
        let controller = WhatsNewController(
            content: content,
            userDefaults: defaults
        )

        #expect(controller.eligibleContent() == content)
    }

    @Test
    func returnsCurrentReleaseContentOnFreshInstall() throws {
        let defaults = try testDefaults()
        let controller = WhatsNewController(
            currentReleaseID: "1.11",
            content: content("1.11"),
            userDefaults: defaults
        )

        #expect(controller.eligibleContent()?.releaseID == "1.11")
        #expect(lastSeenVersion(in: defaults) == nil)
    }

    @Test
    func nilAndEmptyContentAreNotEligible() throws {
        let defaults = try testDefaults()
        let missingController = WhatsNewController(
            currentReleaseID: "1.11",
            content: nil,
            userDefaults: defaults
        )
        let emptyController = WhatsNewController(
            currentReleaseID: "1.11",
            content: WhatsNewContent(releaseID: "1.11", highlights: []),
            userDefaults: defaults
        )

        #expect(missingController.eligibleContent() == nil)
        #expect(emptyController.eligibleContent() == nil)
    }

    @Test
    func contentForAnotherReleaseIsNotEligible() throws {
        let defaults = try testDefaults()
        let controller = WhatsNewController(
            currentReleaseID: "1.11",
            content: content("1.10"),
            userDefaults: defaults
        )

        #expect(controller.eligibleContent() == nil)
    }

    @Test
    func dismissalMarksOnlyActuallyPresentedContent() throws {
        let defaults = try testDefaults()
        let controller = WhatsNewController(
            currentReleaseID: "1.11",
            content: content("1.11"),
            userDefaults: defaults
        )

        controller.dismissPresentedRelease()
        #expect(lastSeenVersion(in: defaults) == nil)

        let candidate = try #require(controller.eligibleContent())
        controller.present(candidate)
        #expect(lastSeenVersion(in: defaults) == nil)

        controller.dismissPresentedRelease()
        #expect(lastSeenVersion(in: defaults) == "1.11")
        #expect(controller.presentedContent == nil)
    }

    @Test
    func contentRemainsEligibleUntilItIsActuallyDismissed() throws {
        let defaults = try testDefaults()
        let controller = WhatsNewController(
            currentReleaseID: "1.11",
            content: content("1.11"),
            userDefaults: defaults
        )

        controller.presentWhatsNewIfNeeded()
        #expect(controller.presentedContent?.releaseID == "1.11")
        #expect(lastSeenVersion(in: defaults) == nil)

        let relaunchedController = WhatsNewController(
            currentReleaseID: "1.11",
            content: content("1.11"),
            userDefaults: defaults
        )
        #expect(relaunchedController.eligibleContent()?.releaseID == "1.11")
    }

    @Test
    func equivalentShortWatermarkDoesNotRepeatCurrentContent() throws {
        let defaults = try testDefaults()
        defaults.set("1.11", forKey: WhatsNewPresentationStore.defaultStorageKey)
        let controller = WhatsNewController(
            currentReleaseID: "1.11.0",
            content: content("1.11.0"),
            userDefaults: defaults
        )

        #expect(controller.eligibleContent() == nil)
    }

    @Test
    func legacyWatermarkSeedsCanonicalStateWithoutDeletingLegacyKey() throws {
        let defaults = try testDefaults()
        defaults.set("1.11", forKey: "legacy.lastSeen")
        let controller = WhatsNewController(
            currentReleaseID: "1.11",
            content: content("1.11"),
            legacyWatermarkKeys: ["legacy.lastSeen"],
            userDefaults: defaults
        )

        #expect(controller.eligibleContent() == nil)
        #expect(lastSeenVersion(in: defaults) == "1.11")
        #expect(defaults.string(forKey: "legacy.lastSeen") == "1.11")
    }

    @Test
    func newestWatermarkWinsAcrossCanonicalAndLegacyKeys() throws {
        let defaults = try testDefaults()
        defaults.set("1.10", forKey: WhatsNewPresentationStore.defaultStorageKey)
        defaults.set("1.12", forKey: "legacy.lastSeen")
        let controller = WhatsNewController(
            currentReleaseID: "1.11",
            content: content("1.11"),
            legacyWatermarkKeys: ["legacy.lastSeen"],
            userDefaults: defaults
        )

        #expect(controller.eligibleContent() == nil)
        #expect(lastSeenVersion(in: defaults) == "1.12")
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
