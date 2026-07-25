import ArchiveDomain
//
//  ArchiveTrackSearchFeature.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import ComposableArchitecture
import TrackSearchDomain
import MSDomain
import FeatureArchiveTrackSearchInterface

@Reducer
public struct ArchiveTrackSearchFeature: Sendable {

    public struct TrackSearchResponse: Equatable, Sendable {
        public let tracks: [Track]
        public let totalResults: Int
        public init(tracks: [Track], totalResults: Int) {
            self.tracks = tracks
            self.totalResults = totalResults
        }
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        public var query: String = ""
        public var results: [Track] = []
        public var isLoading: Bool = false

        public init() {}
    }

    @CasePathable
    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
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

	@Dependency(\.searchTracksUseCase) var searchTracksUseCase
	private enum CancelID { case search }

	public init() {}

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
					await send(
						.searchResponse(
							TaskResult {
								let result = try await searchTracksUseCase.execute(query: currentQuery, limit: 20, offset: 0)
								return TrackSearchResponse(tracks: result.tracks, totalResults: result.totalResults)
							}
						)
					)
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

			case .delegate:
				return .none
			}
		}
	}

	@Dependency(\.continuousClock) var clock
}
