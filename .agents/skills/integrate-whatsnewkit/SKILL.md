---
name: integrate-whatsnewkit
description: 在任何 Apple App 里实现、迁移或排查「新版本功能介绍 / What's New 弹窗」能力时必须先加载：一律接 WhatsNewKit（Jewel591/WhatsNewKit），⛔ 不再手写 What's New sheet、"seen version" UserDefaults 标记或高亮列表组件。覆盖标准接入姿势、CI lint（whats-new-check-lint）的装配证据、native 与 mono 两种 UI 变体、show-once 状态与弹层协调。触发词：What's New、更新亮点、新功能介绍、release highlights、WhatsNewKit。
---

# WhatsNewKit 接入 skill

（本文件是 skill 正身；各机器 `~/.agents/skills/integrate-whatsnewkit/` 只放指向这里的壳。）

全线 Apple App 的「已安装用户新功能介绍」唯一正身是
**[Jewel591/WhatsNewKit](https://github.com/Jewel591/WhatsNewKit)**。
用法读 `README.md`；playbook 裁决在 `tech-stack TOOL-15`。

## 何时触发

- 新版本要向老用户展示更新亮点
- 存量项目里看到自研 What's New view / "上次看过的版本" 标记逻辑
- `whats-new-check-lint` 红灯
- 排查 What's New 重复弹出 / 新装用户不该弹却弹了

## 硬性规则

1. ⛔ 不手写 What's New。固定标题与 Continue 按钮的本地化、seen-release 持久化、
   两种标准 UI 全在 kit 内；宿主只在自己的 String Catalog 本地化 release 专属文案。
2. 接入 = lint 证据齐全（`whats-new-check-lint`，validation 起硬闸）：
   - canonical URL + `Up to Next Major Version`（`from:`）依赖声明
   - application target 生产源码 `import WhatsNewKit`
   - **模块限定**构造 `WhatsNewKit.WhatsNewContent(...)` 与 `WhatsNewKit.WhatsNewView(...)`
     （只加依赖、只写 import、同名本地 View 都不算证据；测试 / Preview / DEBUG 不算）
3. 每个 App 二进制只提供**当前版本的一份** `WhatsNewContent?`；有值得介绍的内容就构造
   `WhatsNewContent(highlights:)`，没有就传 `nil`。release 身份固定读取宿主
   `CFBundleShortVersionString`；⛔ 不维护历史 catalog、不补播旧版本、不构造空 highlights。
4. UI 变体：默认 `.native`；MONO 用 `.mono(appIcon:)`。sheet detent 由宿主持有
   （MONO 惯例 600pt + 隐藏 drag indicator）。
5. 用一个 composition-root `WhatsNewController(content:)` 持有固定门控：
   `eligibleContent()` 只产出候选且不记 seen，宿主仲裁胜出后才 `present(_:)`，
   用户实际关闭后才 `dismissPresentedRelease()`。新安装与升级走同一规则：onboarding
   结束后重新仲裁，有当前内容就展示一次；⛔ 不在 onboarding 完成时预标记已读。
   展示属 App 发起的 surface，经宿主 SheetCoordinator / SurfaceCoordinatorKit 仲裁。
6. 迁移存量 App 时，把真实旧水位 key 传给 `legacyWatermarkKeys:`；Kit 取 canonical 与
   legacy 中的最高版本 seed 到 canonical key，保留旧 key 不删。⛔ 宿主不要直接读写
   `WhatsNewKit.lastSeenRelease`，也不要另建 gate/store。
7. 零配置是不变式：⛔ 不给 kit 加主题 / 布局 / 文案模板参数；
   要改标准 UI 就在 kit 内全线一起改。

## 宿主测试边界

- 宿主只测试自己的当前内容、项目特有的 surface 优先级/路由，以及真实历史 key 到 Kit 的一次性迁移。
- 当前版本匹配、空内容跳过、新安装展示、单调 seen watermark 与 dismiss 后标记属于 WhatsNewKit；不要在每个 App 重写一套 gate 测试。
- 不在 XCTest 中扫描 `project.pbxproj`、import、构造器字符串或旧 View 文件；装配和残留实现由 `whats-new-check-lint` 负责。
- 测迁移时使用隔离的 `UserDefaults(suiteName:)` 与真实已发布 key；不要访问 `.standard`。两个 App 若需要相同的 gate helper，直接补进 Kit，而不是复制测试模板。
