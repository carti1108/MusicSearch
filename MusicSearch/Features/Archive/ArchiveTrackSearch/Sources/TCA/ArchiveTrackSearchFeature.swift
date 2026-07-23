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
public struct ArchiveTrackSearchFeature: Reducer {

	public typealias State = ArchiveTrackSearchState
	public typealias Action = ArchiveTrackSearchAction

	private let searchTracksUseCase: SearchTracksUseCase
	private enum CancelID { case search }

	public init(
		searchTracksUseCase: SearchTracksUseCase
	) {
		self.searchTracksUseCase = searchTracksUseCase
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
