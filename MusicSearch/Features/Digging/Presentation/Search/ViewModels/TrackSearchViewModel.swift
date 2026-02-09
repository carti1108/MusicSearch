//
//  TrackSearchViewModel.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation
import Combine

protocol TrackSearchViewCoordinatorAction: AnyObject {
	func didSelect(_ track: Track)
}

struct TrackSearchState: Equatable {
	var isLoading: Bool = false
	var tracks: [Track] = []
	var errorMessage: String? = nil
}

enum TrackSearchAction {
	case search(keyword: String)
	case select(track: Track)
}

@MainActor
final class TrackSearchViewModel {
	@Published private(set) var state: TrackSearchState = .init()

	private let searchSubject: PassthroughSubject<String, Never> = .init()
	private var cancellables: Set<AnyCancellable> = .init()

	private let debounceSeconds: TimeInterval
	private let searchTracksUseCase: SearchTracksUseCase

	weak var coordinator: TrackSearchViewCoordinatorAction?

	init(debounceSeconds: TimeInterval = 0.5, searchTracksUseCase: SearchTracksUseCase) {
		self.debounceSeconds = debounceSeconds
		self.searchTracksUseCase = searchTracksUseCase
		self.bindSearchInput()
	}

	func process(action: TrackSearchAction) {
		switch action {
		case .search(let keyword):
			self.searchSubject.send(keyword)
		case .select(let track):
			self.coordinator?.didSelect(track)
		}
	}

	private func bindSearchInput() {
		self.searchSubject
			.debounce(for: .seconds(self.debounceSeconds), scheduler: RunLoop.main)
			.removeDuplicates()
			.sink { [weak self] keyword in
				self?.performSearch(keyword: keyword)
			}
			.store(in: &self.cancellables)
	}

	private func performSearch(keyword: String) {
		guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			self.state.tracks = []
			self.state.isLoading = false
			self.state.errorMessage = nil
			return
		}

		Task {
			self.state.isLoading = true
			self.state.errorMessage = nil

			do {
				let tracks = try await self.searchTracksUseCase.execute(query: keyword)
				self.state.tracks = tracks
			} catch {
				self.state.errorMessage = "검색 중 오류가 발생했습니다."
				self.state.tracks = []
			}

			self.state.isLoading = false
		}
	}
}


