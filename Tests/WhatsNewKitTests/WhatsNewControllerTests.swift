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

    // Issue #4 回归：fresh install 走完 Onboarding 后预标记运行版本为已看，
    // 否则引导刚讲完三大卖点，下一轮启动弹层就把同一版本的 What's New 再弹一次。
    @Test
    func markingInstalledVersionSeenRetiresTheRunningReleaseWithoutPresenting() throws {
        let defaults = try testDefaults()
        let controller = WhatsNewController(
            currentReleaseID: "1.11",
            content: content("1.11"),
            userDefaults: defaults
        )

        controller.markInstalledVersionSeen()

        #expect(controller.eligibleContent() == nil)
        #expect(lastSeenVersion(in: defaults) == "1.11")
    }

    // Issue #4 回归：水位只升不降，宿主误在升级路径上调用也不能把用户推过未看内容。
    @Test
    func markingInstalledVersionSeenNeverLowersAnExistingWatermark() throws {
        let defaults = try testDefaults()
        defaults.set("1.12", forKey: WhatsNewPresentationStore.defaultStorageKey)
        let controller = WhatsNewController(
            currentReleaseID: "1.11",
            content: content("1.11"),
            userDefaults: defaults
        )

        controller.markInstalledVersionSeen()

        #expect(lastSeenVersion(in: defaults) == "1.12")
    }

    // Issue #4 回归：预标记同时取消已排队但尚未真正展示的内容，
    // 否则宿主会在引导落幕后拿着 presentedContent 继续把它渲染出来。
    @Test
    func markingInstalledVersionSeenCancelsQueuedContent() throws {
        let defaults = try testDefaults()
        let queued = content("1.11")
        let controller = WhatsNewController(
            currentReleaseID: "1.11",
            content: queued,
            userDefaults: defaults
        )
        controller.present(queued)

        controller.markInstalledVersionSeen()

        #expect(controller.presentedContent == nil)
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
