//
//  ArchiveFolderView.swift
//  MusicSearch
//
//  Created by Kiseok on 7/16/26.
//

import SwiftUI
import ComposableArchitecture
import MSDesignSystem
import ArchiveDomain
import ArchiveSharedPresentation

public struct ArchiveFolderView: View {
    @Bindable var store: StoreOf<ArchiveFolderFeature>

    public init(store: StoreOf<ArchiveFolderFeature>) {
        self.store = store
    }

    private var currentFolders: [FolderItem] {
        switch store.selectedTab {
        case 0: return store.releaseYearFolders
        case 1: return store.listenYearFolders
        case 2: return store.genreFolders
        case 3: return store.ratingFolders
        default: return []
        }
    }

    public var body: some View {
        ZStack {
            CustomColor.background.ignoresSafeArea()
            VStack(spacing: 0) {
                Picker("Folders", selection: $store.selectedTab) {
                    Text("발매연도").tag(0)
                    Text("청취연도").tag(1)
                    Text("장르별").tag(2)
                    Text("별점별").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, CustomSpacing.containerMargin)
                .padding(.top, CustomSpacing.base)
                .padding(.bottom, CustomSpacing.containerMargin)

                ScrollView {
                    if currentFolders.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "folder")
                                .font(.system(size: 40))
                                .foregroundStyle(CustomColor.outline)
                            Text("폴더가 없습니다.")
                                .customText(.bodyMd)
                                .foregroundStyle(CustomColor.outline)
                        }
                        .padding(.top, 100)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CustomSpacing.gutter) {
                            ForEach(currentFolders) { folder in
                                FolderTileView(title: folder.title, subtitle: folder.subtitle)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        store.send(.folderTapped(folder))
                                    }
                            }
                        }
                        .padding(.horizontal, CustomSpacing.containerMargin)
                    }
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
