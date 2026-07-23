import ComposableArchitecture
import MSDomain

@ObservableState
public struct ArchiveTrackSearchState: Equatable, Sendable {
    public var query: String = ""
    public var results: [Track] = []
    public var isLoading: Bool = false

    public init() {}
}

public struct TrackSearchResponse: Equatable, Sendable {
    public let tracks: [Track]
    public let totalResults: Int
    public init(tracks: [Track], totalResults: Int) {
        self.tracks = tracks
        self.totalResults = totalResults
    }
}

public enum ArchiveTrackSearchAction: BindableAction, Sendable {
    case binding(BindingAction<ArchiveTrackSearchState>)
    case onAppear
    case closeButtonTapped
    case clearQueryTapped
    case trackSelected(Track)
    case searchResponse(TaskResult<TrackSearchResponse>)
    case delegate(DelegateAction)

    public enum DelegateAction: Equatable, Sendable {
        case trackSelected(Track)
    }
}
