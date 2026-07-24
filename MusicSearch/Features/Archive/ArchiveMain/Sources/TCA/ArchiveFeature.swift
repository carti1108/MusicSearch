import Foundation
import ComposableArchitecture
import ArchiveDomain
import OSLog
import FeatureArchiveInterface
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface
import FeatureAddArchiveInterface

@Reducer
public struct ArchiveFeature<
    Search: Reducer,
    Folder: Reducer,
    FolderDetail: Reducer,
    AddArchive: Reducer
> where Search.State == ArchiveSearchState, Search.Action == ArchiveSearchAction,
        Folder.State == ArchiveFolderState, Folder.Action == ArchiveFolderAction,
        FolderDetail.State == ArchiveFolderDetailState, FolderDetail.Action == ArchiveFolderDetailAction,
        AddArchive.State == AddArchiveState, AddArchive.Action == AddArchiveAction {

    public typealias State = ArchiveState
    public typealias Action = ArchiveAction

    /// `addArchive`와 `editArchive`는 동일한 State/Action 타입을 공유하므로,
    /// 주입된 `addArchive` Reducer 하나를 두 케이스에서 재사용합니다.
    public struct DestinationReducer: Reducer {
        public typealias State = ArchiveDestinationState
        public typealias Action = ArchiveDestinationAction

        let addArchive: AddArchive

        public var body: some ReducerOf<Self> {
            EmptyReducer()
                .ifCaseLet(\.addArchive, action: \.addArchive) { addArchive }
                .ifCaseLet(\.editArchive, action: \.editArchive) { addArchive }
        }
    }

    public struct PathReducer: Reducer {
        public typealias State = ArchivePathState
        public typealias Action = ArchivePathAction

        let search: Search
        let folder: Folder
        let folderDetail: FolderDetail

        public var body: some ReducerOf<Self> {
            EmptyReducer()
                .ifCaseLet(\.search, action: \.search) { search }
                .ifCaseLet(\.folder, action: \.folder) { folder }
                .ifCaseLet(\.folderDetail, action: \.folderDetail) { folderDetail }
        }
    }

    private let archiveRepository: ArchiveRepository
    private let search: Search
    private let folder: Folder
    private let folderDetail: FolderDetail
    private let addArchive: AddArchive

    public init(
        archiveRepository: ArchiveRepository,
        search: Search,
        folder: Folder,
        folderDetail: FolderDetail,
        addArchive: AddArchive
    ) {
        self.archiveRepository = archiveRepository
        self.search = search
        self.folder = folder
        self.folderDetail = folderDetail
        self.addArchive = addArchive
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    do {
                        let tracks = try await archiveRepository.fetchArchivedTracks()
                        await send(.loadDataResponse(tracks: tracks))
                    } catch {
                        Logger(subsystem: "MusicSearch", category: "ArchiveFeature")
                            .error("Failed to fetch archived tracks: \(error.localizedDescription)")
                    }
                }

            case let .loadDataResponse(tracks):
                state.recentTracks = tracks
                state.totalTracksCount = tracks.count

                if !tracks.isEmpty {
                    let genreCounts = tracks.reduce(into: [String: Int]()) { counts, track in
                        counts[track.genre, default: 0] += 1
                    }
                    if let maxGenre = genreCounts.max(by: { $0.value < $1.value })?.key {
                        state.topGenreName = maxGenre
                    }
                } else {
                    state.topGenreName = "없음"
                }
                return .none

            case .onAddTapped:
                state.destination = .addArchive(AddArchiveState())
                return .none

            case .onSearchTapped:
                state.path.append(.search(ArchiveSearchState()))
                return .none

            case .onFolderTapped:
                state.path.append(.folder(ArchiveFolderState()))
                return .none

            case let .onTrackTapped(track):
                state.destination = .editArchive(AddArchiveState(editTrack: track))
                return .none

            case let .onDeleteTapped(track):
                return .run { send in
                    do {
                        try await archiveRepository.deleteArchivedTrack(id: track.id)
                        await send(.onAppear)
                    } catch {
                        Logger(subsystem: "MusicSearch", category: "ArchiveFeature")
                            .error("Failed to delete archived track: \(error.localizedDescription)")
                    }
                }

            case let .path(.element(_, .search(.delegate(.archiveSearchDidTapTrack(track))))),
                 let .path(.element(_, .folderDetail(.delegate(.didTapTrack(track))))):
                state.destination = .editArchive(AddArchiveState(editTrack: track))
                return .none

            case let .path(.element(_, .folder(.delegate(.didTapFolder(folder))))),
                 let .path(.element(_, .folderDetail(.delegate(.didTapFolder(folder))))):
                state.path.append(.folderDetail(ArchiveFolderDetailState(folderItem: folder)))
                return .none

            case .path(.element(_, .search(.delegate(.archiveSearchDidTapClose)))),
                 .path(.element(_, .folder(.delegate(.didTapClose)))),
                 .path(.element(_, .folderDetail(.delegate(.didTapClose)))):
                state.path.removeLast()
                return .send(.onAppear)
                
            case .destination(.presented(.addArchive(.delegate(.didCloseAddArchive)))),
                 .destination(.presented(.editArchive(.delegate(.didCloseAddArchive)))):
                state.destination = nil
                return .send(.onAppear)

            case .path, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            DestinationReducer(
                addArchive: addArchive
            )
        }
        .forEach(\.path, action: \.path) {
            PathReducer(
                search: search,
                folder: folder,
                folderDetail: folderDetail
            )
        }
    }
}
