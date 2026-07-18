import Foundation
import ComposableArchitecture
import ArchiveDomain

@Reducer
public struct ArchiveSearchFeature {

	@ObservableState
	public struct State: Equatable {
		public var searchText: String = ""
		public var recentSearches: [String] = []
		public var recommendedTracks: [ArchivedTrack] = []
		public var allTracks: [ArchivedTrack] = []

		public init() {}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case onAppear
		case clearRecentSearches
		case removeRecentSearch(String)
		case closeButtonTapped
		case tracksLoaded(TaskResult<[ArchivedTrack]>)
		case delegate(DelegateAction)
	}

	public enum DelegateAction: Equatable {
		case archiveSearchDidTapClose
	}

	private let archiveRepository: ArchiveRepository
	private enum CancelID { case search }

	public init(archiveRepository: ArchiveRepository) {
		self.archiveRepository = archiveRepository
	}

	public var body: some ReducerOf<Self> {
		BindingReducer()

		Reduce { state, action in
			switch action {
			case .binding(\.searchText):
				let query = state.searchText.lowercased()
				if query.isEmpty {
					state.recommendedTracks = []
					return .cancel(id: CancelID.search)
				}

				return .run { [allTracks = state.allTracks] send in
					try await self.clock.sleep(for: .milliseconds(300))

					let filtered = allTracks.filter { track in
						track.title.lowercased().contains(query) ||
						track.artist.lowercased().contains(query) ||
						track.genre.lowercased().contains(query)
					}

					await send(.tracksLoaded(.success(filtered)))
				}
				.cancellable(id: CancelID.search, cancelInFlight: true)

			case .binding:
				return .none

			case .onAppear:
				return .run { send in
					await send(.tracksLoaded(TaskResult {
						try await archiveRepository.fetchArchivedTracks()
					}))
				}

			case .clearRecentSearches:
				state.recentSearches.removeAll()
				return .none

			case let .removeRecentSearch(term):
				state.recentSearches.removeAll { $0 == term }
				return .none

			case .closeButtonTapped:
				return .send(.delegate(.archiveSearchDidTapClose))

			case let .tracksLoaded(.success(tracks)):
				if state.allTracks.isEmpty {
					state.allTracks = tracks
				} else {
					state.recommendedTracks = tracks
				}
				return .none

			case .tracksLoaded(.failure):
				return .none

			case .delegate:
				return .none
			}
		}
	}

	@Dependency(\.continuousClock) var clock
}
