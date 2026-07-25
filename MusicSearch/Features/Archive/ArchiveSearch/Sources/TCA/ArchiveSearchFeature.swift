//
//  ArchiveSearchFeature.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import ComposableArchitecture
import ArchiveDomain

@Reducer
public struct ArchiveSearchFeature: Sendable {

	@ObservableState
	public struct State: Equatable, Sendable {
		public var searchText: String = ""
		public var recentSearches: [String] = []
		public var recommendedTracks: [ArchivedTrack] = []
		public var allTracks: [ArchivedTrack] = []

		public init() {}
	}

	@CasePathable
	public enum Action: BindableAction, Sendable {
		case binding(BindingAction<State>)
		case onAppear
		case clearRecentSearches
		case removeRecentSearch(String)
		case closeButtonTapped
		case trackTapped(ArchivedTrack)
		case tracksLoaded(TaskResult<[ArchivedTrack]>)
		case delegate(DelegateAction)

		public enum DelegateAction: Equatable, Sendable {
			case didTapClose
			case didTapTrack(ArchivedTrack)
		}
	}

	@Dependency(\.archiveRepository) var archiveRepository
	private enum CancelID { case search }

	public init() {}

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

            case let .trackTapped(track):
                return .send(.delegate(.didTapTrack(track)))

			case .closeButtonTapped:
				return .send(.delegate(.didTapClose))

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
