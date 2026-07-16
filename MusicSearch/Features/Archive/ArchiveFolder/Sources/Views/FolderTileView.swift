import SwiftUI
import MSDesignSystem

struct FolderTileView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: CustomSpacing.base) {
            Rectangle()
                .fill(CustomColor.surfaceContainerLow)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(.rect(cornerRadius: CustomRadius.md))
                .overlay(
                    Image(systemName: "folder.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(CustomColor.surfaceContainerHigh)
                )

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
