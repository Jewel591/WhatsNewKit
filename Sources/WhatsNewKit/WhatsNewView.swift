import SwiftUI

public struct WhatsNewView: View {
    private let content: WhatsNewContent
    private let variant: WhatsNewVariant
    private let style: WhatsNewStyle
    private let onContinue: () -> Void

    public init(
        content: WhatsNewContent,
        variant: WhatsNewVariant = .native,
        style: WhatsNewStyle? = nil,
        onContinue: @escaping () -> Void
    ) {
        self.content = content
        self.variant = variant
        self.style = style ?? variant.defaultStyle
        self.onContinue = onContinue
    }

    @ViewBuilder
    public var body: some View {
        switch variant {
        case .native:
            NativeWhatsNewView(
                content: content,
                style: style,
                onContinue: onContinue
            )
        case .mono(let appIcon):
            MonoWhatsNewView(
                content: content,
                appIcon: appIcon,
                style: style,
                onContinue: onContinue
            )
        }
    }
}

private struct NativeWhatsNewView: View {
    private enum Layout {
        static let compactSpacing: CGFloat = 4
        static let smallSpacing: CGFloat = 12
        static let standardSpacing: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let pageSpacing: CGFloat = 32
        static let iconColumnWidth: CGFloat = 32
        static let supplementaryHorizontalInset: CGFloat = 8
    }

    let content: WhatsNewContent
    let style: WhatsNewStyle
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Layout.pageSpacing) {
                    Text("What's New", bundle: .module)
                        .font(style.titleFont)
                        .multilineTextAlignment(.center)

                    VStack(spacing: Layout.sectionSpacing) {
                        ForEach(content.highlights) { highlight in
                            HStack(alignment: .top, spacing: Layout.standardSpacing) {
                                Image(systemName: highlight.symbol)
                                    .font(.largeTitle)
                                    .foregroundStyle(.tint)
                                    .frame(width: Layout.iconColumnWidth)

                                VStack(alignment: .leading, spacing: Layout.compactSpacing) {
                                    Text(verbatim: highlight.title)
                                        .font(style.highlightTitleFont)

                                    Text(verbatim: highlight.detail)
                                        .font(style.highlightDetailFont)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }

                    Spacer(minLength: Layout.pageSpacing)
                }
                .frame(minHeight: geometry.size.height, alignment: .top)
                .scenePadding(.horizontal)
                .safeAreaPadding(.horizontal)
                .padding(.horizontal, Layout.supplementaryHorizontalInset)
                .padding(.top, Layout.pageSpacing)
                .safeAreaPadding(.top, Layout.pageSpacing)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: Layout.standardSpacing) {
                if let footer = content.footer {
                    VStack(alignment: .leading, spacing: Layout.smallSpacing) {
                        Image(systemName: footer.symbol)
                            .font(.title2)
                            .foregroundStyle(.tint)

                        Text(verbatim: footer.message)
                            .font(style.footerFont)
                            .foregroundStyle(.secondary)
                    }
                }

                Button(action: onContinue) {
                    Text("Continue", bundle: .module)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
            }
            .scenePadding(.horizontal)
            .safeAreaPadding(.horizontal)
            .padding(.horizontal, Layout.supplementaryHorizontalInset)
            .padding(.vertical)
        }
    }
}

private struct MonoWhatsNewView: View {
    private enum Layout {
        static let compactSpacing: CGFloat = 4
        static let headerTextSpacing: CGFloat = 6
        static let scrollTopInset: CGFloat = 8
        static let buttonBottomInset: CGFloat = 20
        static let headerSpacing: CGFloat = 16
        static let rowSpacing: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let contentSpacing: CGFloat = 32
        static let scrollHorizontalInset: CGFloat = 28
        static let buttonHorizontalInset: CGFloat = 32
        static let iconSize: CGFloat = 100
        static let featureIconSize: CGFloat = 40
    }

    let content: WhatsNewContent
    let appIcon: Image
    let style: WhatsNewStyle
    let onContinue: () -> Void

    @State private var showHeader = false
    @State private var showHighlights = false
    @State private var showButton = false
    @State private var didComplete = false

    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(.background)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: Layout.contentSpacing) {
                            header
                                .opacity(showHeader ? 1 : 0)
                                .offset(y: showHeader ? 0 : Layout.headerSpacing)

                            VStack(spacing: Layout.sectionSpacing) {
                                ForEach(content.highlights) { highlight in
                                    highlightRow(highlight)
                                }

                                if let footer = content.footer {
                                    footerView(footer)
                                }
                            }
                            .opacity(showHighlights ? 1 : 0)
                            .offset(y: showHighlights ? 0 : Layout.headerSpacing)
                        }
                        .padding(.horizontal, Layout.scrollHorizontalInset)
                        .padding(.top, Layout.scrollTopInset)
                        .padding(.bottom, Layout.sectionSpacing)
                    }

                    Button(action: complete) {
                        Text("Get Started", bundle: .module)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .opacity(showButton ? 1 : 0)
                    .offset(y: showButton ? 0 : Layout.headerSpacing)
                    .padding(.horizontal, Layout.buttonHorizontalInset)
                    .padding(.bottom, Layout.buttonBottomInset)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: complete) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: showHeader)
        .sensoryFeedback(.success, trigger: didComplete)
        .task {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showHeader = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15)) {
                showHighlights = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
                showButton = true
            }
        }
    }

    private var header: some View {
        VStack(spacing: Layout.headerSpacing) {
            appIcon
                .resizable()
                .scaledToFit()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .shadow(radius: 8, y: 4)

            VStack(spacing: Layout.headerTextSpacing) {
                Text("What's New", tableName: "Mono", bundle: .module)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tint)

                Text("What's new in this version", bundle: .module)
                    .font(style.titleFont)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func highlightRow(_ highlight: WhatsNewContent.Highlight) -> some View {
        HStack(alignment: .top, spacing: Layout.rowSpacing) {
            Image(systemName: highlight.symbol)
                .font(.title)
                .foregroundStyle(.tint)
                .symbolRenderingMode(.hierarchical)
                .frame(width: Layout.featureIconSize, height: Layout.featureIconSize)

            VStack(alignment: .leading, spacing: Layout.compactSpacing) {
                Text(verbatim: highlight.title)
                    .font(style.highlightTitleFont)

                Text(verbatim: highlight.detail)
                    .font(style.highlightDetailFont)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func footerView(_ footer: WhatsNewContent.Footer) -> some View {
        HStack(alignment: .top, spacing: Layout.rowSpacing) {
            Image(systemName: footer.symbol)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: Layout.featureIconSize)

            Text(verbatim: footer.message)
                .font(style.footerFont)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func complete() {
        didComplete = true
        onContinue()
    }
}
