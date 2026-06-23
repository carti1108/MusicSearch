import SwiftUI
import ComposableArchitecture
import MSDesignSystem
import ArchiveDomain

public struct ArchiveSearchView: View {
    @Bindable var store: StoreOf<ArchiveSearchFeature>
    
    public init(store: StoreOf<ArchiveSearchFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            CustomColor.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(CustomColor.outline)
                    TextField("곡명, 아티스트 또는 장르 검색", text: $store.searchText)
                        .customText(.bodyMd)
                        .foregroundColor(CustomColor.onSurface)
                }
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(CustomColor.surfaceContainerLow)
                .cornerRadius(10)
                .padding(.horizontal, CustomSpacing.containerMargin)
                .padding(.top, CustomSpacing.containerMargin)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        if !store.recentSearches.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("최근 검색어")
                                        .customText(.headlineMd)
                                        .foregroundColor(CustomColor.onSurface)
                                    Spacer()
                                    Button(action: {
                                        store.send(.clearRecentSearches)
                                    }) {
                                        Text("지우기")
                                            .customText(.labelSm)
                                            .foregroundColor(CustomColor.primary)
                                    }
                                    .buttonStyle(BouncyButtonStyle())
                                }
                                
                                VStack(spacing: 16) {
                                    ForEach(store.recentSearches, id: \.self) { term in
                                        HStack {
                                            Image(systemName: "clock")
                                                .foregroundColor(CustomColor.outlineVariant)
                                            Text(term)
                                                .customText(.bodyLg)
                                                .foregroundColor(CustomColor.onSurface)
                                            Spacer()
                                            Button(action: { store.send(.removeRecentSearch(term)) }) {
                                                Image(systemName: "xmark")
                                                    .foregroundColor(CustomColor.outlineVariant)
                                                    .padding(8)
                                            }
                                            .buttonStyle(BouncyButtonStyle())
                                        }
                                        .background(Color.black.opacity(0.001))
                                    }
                                }
                            }
                        }
                        
                        if !store.recommendedTracks.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("검색 결과")
                                    .customText(.headlineMd)
                                    .foregroundColor(CustomColor.onSurface)
                                
                                VStack(spacing: 16) {
                                    ForEach(store.recommendedTracks, id: \.id) { track in
                                        HStack(spacing: 16) {
                                            Group {
                                                if let data = track.coverImageData, let uiImage = UIImage(data: data) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFill()
                                                } else {
                                                    Rectangle()
                                                        .fill(CustomColor.surfaceContainerHighest)
                                                        .overlay(
                                                            Image(systemName: "music.note")
                                                                .foregroundColor(CustomColor.outlineVariant)
                                                        )
                                                }
                                            }
                                            .frame(width: 56, height: 56)
                                            .cornerRadius(6)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(track.title)
                                                    .customText(.bodyLg)
                                                    .foregroundColor(CustomColor.onSurface)
                                                Text(track.artist)
                                                    .customText(.bodyMd)
                                                    .foregroundColor(CustomColor.outline)
                                            }
                                            
                                            Spacer()
                                        }
                                        .background(Color.black.opacity(0.001))
                                    }
                                }
                            }
                        } else if !store.searchText.isEmpty {
                            Text("검색 결과가 없습니다.")
                                .customText(.bodyMd)
                                .foregroundColor(CustomColor.outline)
                                .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal, CustomSpacing.containerMargin)
                    .padding(.bottom, 80)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
