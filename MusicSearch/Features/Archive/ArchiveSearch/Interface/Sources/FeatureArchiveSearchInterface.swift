import ComposableArchitecture
import ArchiveDomain

@ObservableState
public struct ArchiveSearchState: Equatable, Sendable {
    public var searchText: String = ""
    public var recentSearches: [String] = []
    public var recommendedTracks: [ArchivedTrack] = []
    public var allTracks: [ArchivedTrack] = []

    public init() {}
}

public enum ArchiveSearchAction: BindableAction, Sendable {
    case binding(BindingAction<ArchiveSearchState>)
    case onAppear
    case clearRecentSearches
    case removeRecentSearch(String)
    case closeButtonTapped
    case trackTapped(ArchivedTrack)
    case tracksLoaded(TaskResult<[ArchivedTrack]>)
    case delegate(DelegateAction)

    public enum DelegateAction: Equatable, Sendable {
        case archiveSearchDidTapClose
        case archiveSearchDidTapTrack(ArchivedTrack)
    }
}
