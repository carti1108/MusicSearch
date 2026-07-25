//
//  ArchiveHeaderView.swift
//  MusicSearch
//
//  Created by Kiseok on 7/16/26.
//

import SwiftUI
import MSDesignSystem

public struct ArchiveHeaderView: View {
    public let onSearchTapped: () -> Void
    public let onFolderTapped: () -> Void

    public init(onSearchTapped: @escaping () -> Void, onFolderTapped: @escaping () -> Void) {
        self.onSearchTapped = onSearchTapped
        self.onFolderTapped = onFolderTapped
    }

    public var body: some View {
        HStack {
            Text("Archive")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(CustomColor.onBackground)

            Spacer()

            HStack(spacing: 16) {
                Button(action: onSearchTapped) {
                    Image(systemName: "magnifyingglass")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 20))
                        .foregroundStyle(CustomColor.onSurfaceVariant)
                        .padding(8)
                        .background(CustomColor.surfaceContainer)
                        .clipShape(Circle())
                }
                .accessibilityLabel("음악 검색")
                .buttonStyle(BouncyButtonStyle())

                Button(action: onFolderTapped) {
                    Image(systemName: "folder.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 20))
                        .foregroundStyle(CustomColor.onSurfaceVariant)
                        .padding(8)
                        .background(CustomColor.surfaceContainer)
                        .clipShape(Circle())
                }
                .accessibilityLabel("폴더 보기")
                .buttonStyle(BouncyButtonStyle())
            }
        }
        .padding(.horizontal, CustomSpacing.containerMargin)
        .padding(.top, CustomSpacing.containerMargin)
        .padding(.bottom, 8)
    }
}
