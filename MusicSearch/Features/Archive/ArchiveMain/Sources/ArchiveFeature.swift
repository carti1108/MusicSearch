import Foundation
import ComposableArchitecture
import ArchiveDomain
import OSLog

@Reducer
public struct ArchiveFeature {

    @ObservableState
    public struct State: Equatable {
        public var totalTracksCount: Int = 0
        public var topGenreName: String = "없음"
        public var recentTracks: [ArchivedTrack] = []

        public init() {}
    }

    public enum Action {
        case onAppear
        case loadDataResponse(tracks: [ArchivedTrack])
        case onAddTapped
        case onSearchTapped
        case onFolderTapped
        case onTrackTapped(track: ArchivedTrack)
        case onDeleteTapped(track: ArchivedTrack)
        case delegate(DelegateAction)
    }

    public enum DelegateAction: Equatable {
        case routeToAddArchive
        case routeToSearch
        case routeToFolder
        case routeToEditArchive(track: ArchivedTrack)
    }

    private let archiveRepository: ArchiveRepository
    private let onDelegate: (DelegateAction) -> Void

    public init(
        archiveRepository: ArchiveRepository,
        onDelegate: @escaping (DelegateAction) -> Void
    ) {
        self.archiveRepository = archiveRepository
        self.onDelegate = onDelegate
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
                return .run { @MainActor _ in
                    onDelegate(.routeToAddArchive)
                }

            case .onSearchTapped:
                return .run { @MainActor _ in
                    onDelegate(.routeToSearch)
                }

            case .onFolderTapped:
                return .run { @MainActor _ in
                    onDelegate(.routeToFolder)
                }

            case let .onTrackTapped(track):
                return .run { @MainActor _ in
                    onDelegate(.routeToEditArchive(track: track))
                }

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

            case .delegate:
                return .none
            }
        }
    }
}
