import SwiftUI
import MSDesignSystem

public struct FolderTileView: View {
    public let title: String
    public let subtitle: String

    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CustomSpacing.base) {
            Rectangle()
                .fill(CustomColor.surfaceContainerLow)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(.rect(cornerRadius: CustomRadius.md))
                .overlay {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(CustomColor.surfaceContainerHigh)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .customText(.bodyMd)
                    .foregroundStyle(CustomColor.onSurface)
                Text(subtitle)
                    .customText(.labelSm)
                    .foregroundStyle(CustomColor.outline)
            }
        }
    }
}
