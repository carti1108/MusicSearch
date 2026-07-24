import SwiftUI
import ComposableArchitecture
import MSDesignSystem
import ArchiveDomain
import FeatureArchiveInterface
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface
import FeatureAddArchiveInterface

public struct ArchiveView: View {
    @Bindable var store: Store<ArchiveState, ArchiveAction>

    let destinationViews: ArchiveDestinationViews

    @State private var showFilterSheet = false
    @State private var filterIntroGood = false
    @State private var filterMiddleGood = false
    @State private var filterEndGood = false

    public init(
        store: Store<ArchiveState, ArchiveAction>,
        destinationViews: ArchiveDestinationViews
    ) {
        self.store = store
        self.destinationViews = destinationViews
    }

    private var filteredTracks: [ArchivedTrack] {
        store.recentTracks.filter { track in
            (!filterIntroGood || track.isIntroGood) &&
            (!filterMiddleGood || track.isGoodUntilMiddle) &&
            (!filterEndGood || track.isGoodUntilEnd)
        }
    }

    public var body: some View {
        let addArchiveBinding: Binding<Store<AddArchiveState, AddArchiveAction>?> = $store.scope(state: \.destination?[case: \.addArchive], action: \.destination.addArchive)
        let editArchiveBinding: Binding<Store<AddArchiveState, AddArchiveAction>?> = $store.scope(state: \.destination?[case: \.editArchive], action: \.destination.editArchive)

        NavigationStack(path: $store.scope(state: \ArchiveState.path, action: \ArchiveAction.Cases.path)) {
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

                List {
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
                            Button(action: { showFilterSheet = true }) {
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
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())

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
                .padding(.bottom, 80)

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
            .sheet(isPresented: $showFilterSheet) {
                ArchiveFilterSheetView(
                    filterIntroGood: $filterIntroGood,
                    filterMiddleGood: $filterMiddleGood,
                    filterEndGood: $filterEndGood,
                    showFilterSheet: $showFilterSheet
                )
                    .presentationDetents([.height(300)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: addArchiveBinding) { store in
                destinationViews.addArchive(store)
            }
            .sheet(item: editArchiveBinding) { store in
                destinationViews.editArchive(store)
            }
            .onAppear {
                store.send(.onAppear)
            }
        } destination: { (store: Store<ArchivePathState, ArchivePathAction>) in
            switch store.state {
            case .search:
                if let scopedStore = store.scope(state: \.[case: \.search], action: \ArchivePathAction.Cases.search) {
                    destinationViews.search(scopedStore)
                }
            case .folder:
                if let scopedStore = store.scope(state: \.[case: \.folder], action: \ArchivePathAction.Cases.folder) {
                    destinationViews.folder(scopedStore)
                }
            case .folderDetail:
                if let scopedStore = store.scope(state: \.[case: \.folderDetail], action: \ArchivePathAction.Cases.folderDetail) {
                    destinationViews.folderDetail(scopedStore)
                }
            }
        }
    }
}
