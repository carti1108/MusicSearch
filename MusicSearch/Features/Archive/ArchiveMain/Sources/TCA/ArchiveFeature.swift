import Foundation
import ComposableArchitecture
import ArchiveDomain
import OSLog
import FeatureArchiveInterface
import FeatureArchiveSearch
import FeatureArchiveFolder
import FeatureArchiveFolderDetail
import FeatureAddArchive

@Reducer
public struct ArchiveFeature: Sendable {

    @Reducer
    public enum Destination {
        case addArchive(AddArchiveFeature)
        case editArchive(AddArchiveFeature)
    }

    @Reducer
    public enum Path {
        case search(ArchiveSearchFeature)
        case folder(ArchiveFolderFeature)
        case folderDetail(ArchiveFolderDetailFeature)
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        public var totalTracksCount: Int = 0
        public var topGenreName: String = "없음"
        public var recentTracks: [ArchivedTrack] = []

        public var path = StackState<Path.State>()
        @Presents public var destination: Destination.State?

        public var showFilterSheet: Bool = false
        public var filterIntroGood: Bool = false
        public var filterMiddleGood: Bool = false
        public var filterEndGood: Bool = false

        public init() {}
    }

    @CasePathable
    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case onAppear
        case loadDataResponse(tracks: [ArchivedTrack])
        case onAddTapped
        case onSearchTapped
        case onFolderTapped
        case onTrackTapped(track: ArchivedTrack)
        case onDeleteTapped(track: ArchivedTrack)
        case resetFilter
        case path(StackAction<Path.State, Path.Action>)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.archiveRepository) var archiveRepository

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

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
                state.destination = .addArchive(AddArchiveFeature.State())
                return .none

            case .onSearchTapped:
                state.path.append(.search(ArchiveSearchFeature.State()))
                return .none

            case .onFolderTapped:
                state.path.append(.folder(ArchiveFolderFeature.State()))
                return .none

            case let .onTrackTapped(track):
                state.destination = .editArchive(AddArchiveFeature.State(editTrack: track))
                return .none

            case let .onDeleteTapped(track):
                state.recentTracks.removeAll { $0.id == track.id }
                state.totalTracksCount = state.recentTracks.count
                return .run { send in
                    do {
                        try await archiveRepository.deleteArchivedTrack(id: track.id)
                    } catch {
                        Logger(subsystem: "MusicSearch", category: "ArchiveFeature")
                            .error("Failed to delete archived track: \(error.localizedDescription)")
                        await send(.onAppear)
                    }
                }

            case .resetFilter:
                state.filterIntroGood = false
                state.filterMiddleGood = false
                state.filterEndGood = false
                return .none

            case let .path(.element(_, .search(.delegate(.didTapTrack(track))))),
                 let .path(.element(_, .folderDetail(.delegate(.didTapTrack(track))))):
                state.destination = .editArchive(AddArchiveFeature.State(editTrack: track))
                return .none

            case let .path(.element(_, .folder(.delegate(.didTapFolder(folder))))),
                 let .path(.element(_, .folderDetail(.delegate(.didTapFolder(folder))))):
                state.path.append(.folderDetail(ArchiveFolderDetailFeature.State(folderItem: folder)))
                return .none

            case .path(.element(_, .search(.delegate(.didTapClose)))),
                 .path(.element(_, .folder(.delegate(.didTapClose)))),
                 .path(.element(_, .folderDetail(.delegate(.didTapClose)))):
                state.path.removeLast()
                return .send(.onAppear)
                
            case .destination(.presented(.addArchive(.delegate(.didCloseAddArchive)))),
                 .destination(.presented(.editArchive(.delegate(.didCloseAddArchive)))):
                state.destination = nil
                return .send(.onAppear)

            case .path, .destination, .binding:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.path, action: \.path)
    }
}

extension ArchiveFeature.Destination.State: Identifiable {
    public var id: String {
        switch self {
        case .addArchive: return "addArchive"
        case .editArchive: return "editArchive"
        }
    }
}

extension ArchiveFeature.Destination.State: Equatable, Sendable {}
extension ArchiveFeature.Destination.Action: Sendable {}
extension ArchiveFeature.Path.State: Equatable, Sendable {}
extension ArchiveFeature.Path.Action: Sendable {}
