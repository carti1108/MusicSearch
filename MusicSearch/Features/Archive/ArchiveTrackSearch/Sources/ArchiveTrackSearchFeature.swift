import Foundation
import ComposableArchitecture
import TrackSearchDomain
import MSDomain

@Reducer
public struct ArchiveTrackSearchFeature {

	@ObservableState
	public struct State: Equatable {
		public var query: String = ""
		public var results: [Track] = []
		public var isLoading: Bool = false

		public init() {}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case onAppear
		case closeButtonTapped
		case clearQueryTapped
		case trackSelected(Track)
		case searchResponse(TaskResult<TrackSearchResponse>)
		case delegate(DelegateAction)
	}

	public struct TrackSearchResponse: Equatable {
		public let tracks: [Track]
		public let totalResults: Int
		public init(tracks: [Track], totalResults: Int) {
			self.tracks = tracks
			self.totalResults = totalResults
		}
	}

	public enum DelegateAction {
		case trackSelected(Track)
	}

	private let searchTracksUseCase: SearchTracksUseCase
	private let onDelegate: (DelegateAction) -> Void
	private enum CancelID { case search }

	public init(
		searchTracksUseCase: SearchTracksUseCase,
		onDelegate: @escaping (DelegateAction) -> Void
	) {
		self.searchTracksUseCase = searchTracksUseCase
		self.onDelegate = onDelegate
	}

	public var body: some ReducerOf<Self> {
		BindingReducer()

		Reduce { state, action in
			switch action {
			case .binding(\.query):
				let currentQuery = state.query
				guard !currentQuery.isEmpty else {
					state.results = []
					return .cancel(id: CancelID.search)
				}

				state.isLoading = true
				return .run { send in
					try await self.clock.sleep(for: .milliseconds(500))
					let result = try await searchTracksUseCase.execute(query: currentQuery, limit: 20, page: 1)
					await send(.searchResponse(TaskResult {
						TrackSearchResponse(tracks: result.tracks, totalResults: result.totalResults)
					}))
				}
				.cancellable(id: CancelID.search, cancelInFlight: true)

			case .binding:
				return .none

			case .onAppear:
				return .none

			case .clearQueryTapped:
				state.query = ""
				state.results = []
				return .cancel(id: CancelID.search)

			case let .searchResponse(.success(response)):
				state.isLoading = false
				state.results = response.tracks
				return .none

			case .searchResponse(.failure):
				state.isLoading = false
				return .none

			case let .trackSelected(track):
				return .send(.delegate(.trackSelected(track)))

			case .closeButtonTapped:
				return .none

			case let .delegate(delegateAction):
				return .run { @MainActor _ in
					onDelegate(delegateAction)
				}
			}
		}
	}

	@Dependency(\.continuousClock) var clock
}
