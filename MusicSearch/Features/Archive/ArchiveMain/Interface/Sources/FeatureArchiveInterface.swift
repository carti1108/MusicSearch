import ComposableArchitecture
import ArchiveDomain
import TrackSearchDomain
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface
import FeatureAddArchiveInterface

@CasePathable
public enum ArchiveDestinationState: Equatable, Sendable {
    case search(ArchiveSearchState)
    case folder(ArchiveFolderState)
    case addArchive(AddArchiveState)
    case editArchive(AddArchiveState)
}

@CasePathable
public enum ArchiveDestinationAction: Sendable {
    case search(ArchiveSearchAction)
    case folder(ArchiveFolderAction)
    case addArchive(AddArchiveAction)
    case editArchive(AddArchiveAction)
}

@ObservableState
public struct ArchiveState: Equatable, Sendable {
    public var totalTracksCount: Int = 0
    public var topGenreName: String = "없음"
    public var recentTracks: [ArchivedTrack] = []

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
    case destination(PresentationAction<ArchiveDestinationAction>)
}




