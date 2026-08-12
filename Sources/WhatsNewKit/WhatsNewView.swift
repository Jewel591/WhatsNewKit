import SwiftUI

public struct WhatsNewView: View {
    private enum Layout {
        static let compactSpacing: CGFloat = 4
        static let smallSpacing: CGFloat = 12
        static let standardSpacing: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let pageSpacing: CGFloat = 32
        static let iconColumnWidth: CGFloat = 32
        static let supplementaryHorizontalInset: CGFloat = 8
    }

    private let content: WhatsNewContent
    private let style: WhatsNewStyle
    private let onContinue: () -> Void

    public init(
        content: WhatsNewContent,
        style: WhatsNewStyle = .standard,
        onContinue: @escaping () -> Void
    ) {
        self.content = content
        self.style = style
        self.onContinue = onContinue
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Layout.pageSpacing) {
                    Text(verbatim: content.title)
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
                    Text(verbatim: content.actionTitle)
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
