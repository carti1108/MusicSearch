import SwiftUI
import ComposableArchitecture
import MSDesignSystem
import ArchiveDomain
import FeatureArchiveInterface
import FeatureArchiveSearch
import FeatureArchiveFolder
import FeatureArchiveFolderDetail
import FeatureAddArchive

public struct ArchiveView: View {
    @Bindable var store: StoreOf<ArchiveFeature>

    public init(
        store: StoreOf<ArchiveFeature>
    ) {
        self.store = store
    }

    private var filteredTracks: [ArchivedTrack] {
        store.recentTracks.filter { track in
            (!store.filterIntroGood || track.isIntroGood) &&
            (!store.filterMiddleGood || track.isGoodUntilMiddle) &&
            (!store.filterEndGood || track.isGoodUntilEnd)
        }
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \ArchiveFeature.State.path, action: \ArchiveFeature.Action.Cases.path)) {
            ZStack(alignment: .bottom) {
                ZStack {
                    CustomColor.background
                    Circle()
                        .fill(CustomColor.surfaceContainerHighest.opacity(0.4))
                        .frame(width: 400, height: 400)
                        .blur(radius: 120)
                        .offset(x: -150, y: -200)
                    Circle()
                        .fill(CustomColor.surfaceContainer.opacity(0.5))
                        .frame(width: 350, height: 350)
                        .blur(radius: 100)
                        .offset(x: 200, y: 150)
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: CustomSpacing.containerMargin) {
                        ArchiveHeaderView(
                            onSearchTapped: { store.send(.onSearchTapped) },
                            onFolderTapped: { store.send(.onFolderTapped) }
                        )

                        ArchiveDashboardCardsView(
                            totalTracksCount: store.totalTracksCount,
                            topGenreName: store.topGenreName
                        )

                        HStack(alignment: .bottom) {
                            Text("최근 기록한 음악")
                                .customText(.headlineMd)
                                .foregroundStyle(CustomColor.onBackground)
                            Spacer()
                            Button(action: { store.showFilterSheet = true }) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(CustomColor.primary)
                            }
                            .buttonStyle(BouncyButtonStyle())
                        }
                        .padding(.horizontal, CustomSpacing.containerMargin)
                        .padding(.top, CustomSpacing.containerMargin)
                        .padding(.bottom, 16)
                    }

                    List {
                        ForEach(filteredTracks) { track in
                            Button(action: {
                                store.send(.onTrackTapped(track: track))
                            }) {
                                TrackRowItemView(track: track)
                            }
                            .buttonStyle(BouncyButtonStyle())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: CustomSpacing.containerMargin, bottom: CustomSpacing.gutter, trailing: CustomSpacing.containerMargin))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    store.send(.onDeleteTapped(track: track))
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
                    .scrollContentBackground(.hidden)
                    .safeAreaPadding(.bottom, 80)
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { store.send(.onAddTapped) }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(CustomColor.onPrimary)
                                .padding(16)
                                .background(CustomColor.primary)
                                .clipShape(Circle())
                                .shadow(color: CustomColor.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(BouncyButtonStyle())
                        .padding(.trailing, CustomSpacing.containerMargin)
                        .padding(.bottom, CustomSpacing.containerMargin)
                    }
                }
            }
            .sheet(isPresented: $store.showFilterSheet) {
                ArchiveFilterSheetView(
                    store: store
                )
                    .presentationDetents([.height(300)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $store.scope(state: \.destination, action: \.destination)) { store in
                switch store.case {
                case let .addArchive(scopedStore):
                    AddArchiveView(store: scopedStore)
                case let .editArchive(scopedStore):
                    AddArchiveView(store: scopedStore)
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        } destination: { store in
            switch store.case {
            case let .search(scopedStore):
                ArchiveSearchView(store: scopedStore)
            case let .folder(scopedStore):
                ArchiveFolderView(store: scopedStore)
            case let .folderDetail(scopedStore):
                ArchiveFolderDetailView(store: scopedStore)
            }
        }
    }
}
