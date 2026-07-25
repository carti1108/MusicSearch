import Foundation
import ComposableArchitecture
import ArchiveDomain
import OSLog
import FeatureArchiveInterface
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface
import FeatureAddArchiveInterface
import FeatureArchiveSearch
import FeatureArchiveFolder
import FeatureArchiveFolderDetail
import FeatureAddArchive

@ObservableState
public struct ArchiveState: Equatable, Sendable {
    public var totalTracksCount: Int = 0
    public var topGenreName: String = "없음"
    public var recentTracks: [ArchivedTrack] = []

    public var path = StackState<ArchiveFeature.Path.State>()
    @Presents public var destination: ArchiveFeature.Destination.State?

    public var showFilterSheet: Bool = false
    public var filterIntroGood: Bool = false
    public var filterMiddleGood: Bool = false
    public var filterEndGood: Bool = false

    public init() {}
}

@CasePathable
public enum ArchiveAction: BindableAction, Sendable {
    case binding(BindingAction<ArchiveState>)
    case onAppear
    case loadDataResponse(tracks: [ArchivedTrack])
    case onAddTapped
    case onSearchTapped
    case onFolderTapped
    case onTrackTapped(track: ArchivedTrack)
    case onDeleteTapped(track: ArchivedTrack)
    case path(StackAction<ArchiveFeature.Path.State, ArchiveFeature.Path.Action>)
    case destination(PresentationAction<ArchiveFeature.Destination.Action>)
}

@Reducer
public struct ArchiveFeature {

    public typealias State = ArchiveState
    public typealias Action = ArchiveAction

    @Reducer(state: .equatable)
    public enum Destination {
        case addArchive(AddArchiveFeature)
        case editArchive(AddArchiveFeature)
    }

    @Reducer(state: .equatable)
    public enum Path {
        case search(ArchiveSearchFeature)
        case folder(ArchiveFolderFeature)
        case folderDetail(ArchiveFolderDetailFeature)
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

            case let .path(.element(_, .search(.delegate(.didTapTrack(track))))),
                 let .path(.element(_, .folderDetail(.delegate(.didTapTrack(track))))):
                state.destination = .editArchive(AddArchiveState(editTrack: track))
                return .none

            case let .path(.element(_, .folder(.delegate(.didTapFolder(folder))))),
                 let .path(.element(_, .folderDetail(.delegate(.didTapFolder(folder))))):
                state.path.append(.folderDetail(ArchiveFolderDetailState(folderItem: folder)))
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
