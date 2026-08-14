//
//  DetailTrackRowItemView.swift
//  MusicSearch
//
//  Created by Kiseok on 7/16/26.
//

import SwiftUI
import MSDesignSystem
import ArchiveDomain

public struct DetailTrackRowItemView: View {
    public let track: ArchivedTrack
    @State private var isPressed: Bool = false

    public init(track: ArchivedTrack) {
        self.track = track
    }

    public var body: some View {
        HStack(spacing: CustomSpacing.base) {
            Group {
                if let data = track.coverImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(gradient: Gradient(colors: [CustomColor.primary.opacity(0.6), CustomColor.tertiary.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .overlay {
                            Image(systemName: "music.quarternote.3")
                                .font(.system(size: CustomSpacing.base))
                                .foregroundStyle(CustomColor.onPrimary)
                        }
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(.rect(cornerRadius: CustomRadius.md))
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .customText(.bodyLg)
                    .foregroundStyle(CustomColor.onSurface)
                    .lineLimit(1)

                Text(track.artist)
                    .customText(.bodyMd)
                    .foregroundStyle(CustomColor.onSurfaceVariant)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                HStack(spacing: 4) {
                    if let firstGenre = track.genres.first {
                        Text(firstGenre)
                            .customText(.monoLabel)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(CustomColor.surfaceContainerHighest)
                            .foregroundStyle(CustomColor.onSurface)
                            .clipShape(Capsule())
                    }
                    if track.genres.count > 1 {
                        Text("+\(track.genres.count - 1)")
                            .customText(.monoLabel)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(CustomColor.surfaceContainerHighest)
                            .foregroundStyle(CustomColor.onSurface)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(CustomColor.tertiary)
                    Text(track.rating, format: .number.precision(.fractionLength(1)))
                        .customText(.labelSm)
                        .foregroundStyle(CustomColor.onSurfaceVariant)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.001))
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
