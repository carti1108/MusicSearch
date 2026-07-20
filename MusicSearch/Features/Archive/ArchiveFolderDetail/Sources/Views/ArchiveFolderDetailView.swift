//
//  ArchiveFolderDetailView.swift
//  MusicSearch
//
//  Created by Kiseok on 7/16/26.
//

import SwiftUI
import ComposableArchitecture
import MSDesignSystem
import ArchiveDomain

public struct ArchiveFolderDetailView: View {
    @Bindable var store: StoreOf<ArchiveFolderDetailFeature>

    @State private var showingExportAlert = false
    @State private var exportResultMessage = ""

    public init(store: StoreOf<ArchiveFolderDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            CustomColor.background.ignoresSafeArea()

            if let folders = store.folders {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CustomSpacing.gutter) {
                        ForEach(folders) { folder in
                            FolderTileView(title: folder.title, subtitle: folder.subtitle)
                                .onTapGesture {
                                    store.send(.folderTapped(folder))
                                }
                        }
                    }
                    .padding(.horizontal, CustomSpacing.containerMargin)
                    .padding(.top, CustomSpacing.base)
                }
            } else if let tracks = store.tracks {
                List {
                    ForEach(tracks) { track in
                        DetailTrackRowItemView(track: track)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(Visibility.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: CustomSpacing.containerMargin, bottom: CustomSpacing.gutter, trailing: CustomSpacing.containerMargin))
                            .onTapGesture {
                                store.send(.trackTapped(track))
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }

            if case .exporting(let progress) = store.exportState {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack(spacing: CustomSpacing.base) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: CustomColor.primary))
                        .scaleEffect(1.5)

                    Text("Spotify로 내보내는 중...")
                        .customText(.bodyLg)
                        .foregroundStyle(CustomColor.onSurface)

                    Text("\(progress.currentCount) / \(progress.totalCount) 곡 처리 완료")
                        .customText(.bodyMd)
                        .foregroundStyle(CustomColor.onSurfaceVariant)
                }
                .padding(32)
                .background(CustomColor.surfaceContainer)
                .clipShape(.rect(cornerRadius: CustomRadius.lg))
                .shadow(radius: 10)
            }
        }
        .onChange(of: store.exportState) { _, newValue in
            if case .completed(let success, let failed) = newValue {
                exportResultMessage = "성공: \(success)곡, 실패: \(failed)곡"
                showingExportAlert = true
            }
        }
        .alert(isPresented: $showingExportAlert) {
            Alert(
                title: Text("내보내기 완료"),
                message: Text(exportResultMessage),
                dismissButton: .default(Text("확인"))
            )
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

