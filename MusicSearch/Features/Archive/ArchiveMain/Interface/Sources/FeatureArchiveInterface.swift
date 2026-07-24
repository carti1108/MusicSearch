import ComposableArchitecture
import ArchiveDomain
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface
import FeatureAddArchiveInterface

@ObservableState
@CasePathable
public enum ArchiveDestinationState: Equatable, Sendable {
    case addArchive(AddArchiveState)
    case editArchive(AddArchiveState)
}

@CasePathable
public enum ArchiveDestinationAction: Sendable {
    case addArchive(AddArchiveAction)
    case editArchive(AddArchiveAction)
}

@ObservableState
@CasePathable
public enum ArchivePathState: Equatable, Sendable {
    case search(ArchiveSearchState)
    case folder(ArchiveFolderState)
    case folderDetail(ArchiveFolderDetailState)
}

@CasePathable
public enum ArchivePathAction: Sendable {
    case search(ArchiveSearchAction)
    case folder(ArchiveFolderAction)
    case folderDetail(ArchiveFolderDetailAction)
}

@ObservableState
public struct ArchiveState: Equatable, Sendable {
    public var totalTracksCount: Int = 0
    public var topGenreName: String = "없음"
    public var recentTracks: [ArchivedTrack] = []

    public var path = StackState<ArchivePathState>()
    @Presents public var destination: ArchiveDestinationState?

    public init() {}
}

@CasePathable
public enum ArchiveAction: Sendable {
    case onAppear
    case loadDataResponse(tracks: [ArchivedTrack])
    case onAddTapped
    case onSearchTapped
    case onFolderTapped
    case onTrackTapped(track: ArchivedTrack)
    case onDeleteTapped(track: ArchivedTrack)
    case path(StackAction<ArchivePathState, ArchivePathAction>)
    case destination(PresentationAction<ArchiveDestinationAction>)
}
