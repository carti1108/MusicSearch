//
//  ArchiveDashboardCardsView.swift
//  MusicSearch
//
//  Created by Kiseok on 7/16/26.
//

import SwiftUI
import MSDesignSystem

public struct ArchiveDashboardCardsView: View {
    public let totalTracksCount: Int
    public let topGenreName: String

    public init(totalTracksCount: Int, topGenreName: String) {
        self.totalTracksCount = totalTracksCount
        self.topGenreName = topGenreName
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("총 \(totalTracksCount) 곡을 기록했어요.")
                    .customText(.bodyMd)
                    .foregroundStyle(CustomColor.onSurfaceVariant)
                Text("가장 즐겨듣는 장르: \(topGenreName)")
                    .customText(.labelSm)
                    .foregroundStyle(CustomColor.outline)
            }
            Spacer()
        }
        .padding(.horizontal, CustomSpacing.containerMargin)
        .padding(.vertical, 8)
    }
}
