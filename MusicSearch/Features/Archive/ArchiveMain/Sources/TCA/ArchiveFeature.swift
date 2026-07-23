import Foundation
import ComposableArchitecture
import ArchiveDomain
import OSLog
import FeatureArchiveInterface
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface
import FeatureAddArchiveInterface

@Reducer
public struct ArchiveFeature<
    Search: Reducer,
    Folder: Reducer,
    AddArchive: Reducer,
    EditArchive: Reducer
> where Search.State == ArchiveSearchState, Search.Action == ArchiveSearchAction,
        Folder.State == ArchiveFolderState, Folder.Action == ArchiveFolderAction,
        AddArchive.State == AddArchiveState, AddArchive.Action == AddArchiveAction,
        EditArchive.State == AddArchiveState, EditArchive.Action == AddArchiveAction {

    public typealias State = ArchiveState
    public typealias Action = ArchiveAction

    public struct DestinationReducer: Reducer {
        public typealias State = ArchiveDestinationState
        public typealias Action = ArchiveDestinationAction

        let search: Search
        let folder: Folder
        let addArchive: AddArchive
        let editArchive: EditArchive

        public var body: some ReducerOf<Self> {
            EmptyReducer()
                .ifCaseLet(\.search, action: \.search) { search }
                .ifCaseLet(\.folder, action: \.folder) { folder }
                .ifCaseLet(\.addArchive, action: \.addArchive) { addArchive }
                .ifCaseLet(\.editArchive, action: \.editArchive) { editArchive }
        }
    }

    private let archiveRepository: ArchiveRepository
    private let search: Search
    private let folder: Folder
    private let addArchive: AddArchive
    private let editArchive: EditArchive

    public init(
        archiveRepository: ArchiveRepository,
        search: Search,
        folder: Folder,
        addArchive: AddArchive,
        editArchive: EditArchive
    ) {
        self.archiveRepository = archiveRepository
        self.search = search
        self.folder = folder
        self.addArchive = addArchive
        self.editArchive = editArchive
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
                state.destination = .search(ArchiveSearchState())
                return .none

            case .onFolderTapped:
                state.destination = .folder(ArchiveFolderState())
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

            case .destination(.presented(.search(.delegate(.archiveSearchDidTapClose)))),
                 .destination(.presented(.folder(.delegate(.didTapClose)))),
                 .destination(.presented(.addArchive(.delegate(.didCloseAddArchive)))),
                 .destination(.presented(.editArchive(.delegate(.didCloseAddArchive)))):
                state.destination = nil
                return .send(.onAppear) // Refresh after edit/add

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            DestinationReducer(
                search: search,
                folder: folder,
                addArchive: addArchive,
                editArchive: editArchive
            )
        }
    }
}
