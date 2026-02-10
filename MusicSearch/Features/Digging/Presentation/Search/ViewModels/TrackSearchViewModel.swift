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
	var currentPage: Int = 1
	var totalResults: Int = 0
	var isLoadingMore: Bool = false
	
	var canLoadMore: Bool {
		return !isLoading && !isLoadingMore && tracks.count < totalResults
	}
}

enum TrackSearchAction {
	case search(keyword: String)
	case select(track: Track)
	case retry
	case loadMore
}

@MainActor
final class TrackSearchViewModel {
	@Published private(set) var state: TrackSearchState = .init()

	private let searchSubject: PassthroughSubject<String, Never> = .init()
	private var cancellables: Set<AnyCancellable> = .init()

	private var lastKeyword: String?
	
	private let limit: Int = 20

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

		case .retry:
			guard let lastKeyword = self.lastKeyword else { return }
			self.performSearch(keyword: lastKeyword)
			
		case .loadMore:
			self.loadMore()
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
			self.state.currentPage = 1
			self.state.totalResults = 0
			return
		}

		self.lastKeyword = keyword
		self.state.currentPage = 1

		Task {
			self.state.isLoading = true
			self.state.errorMessage = nil

			do {
				let result = try await self.searchTracksUseCase.execute(query: keyword, limit: self.limit, page: 1)
				self.state.tracks = result.tracks
				self.state.totalResults = result.totalResults
			} catch {
				print("TrackSearchViewModel Error: \(error)")
				self.state.errorMessage = "검색 중 오류가 발생했습니다."
				self.state.tracks = []
				self.state.totalResults = 0
			}

			self.state.isLoading = false
		}
	}
	
	private func loadMore() {
		guard self.state.canLoadMore, let keyword = self.lastKeyword else { return }
		
		let nextPage = self.state.currentPage + 1
		
		Task {
			self.state.isLoadingMore = true
			
			do {
				let result = try await self.searchTracksUseCase.execute(query: keyword, limit: self.limit, page: nextPage)
				self.state.tracks.append(contentsOf: result.tracks)
				self.state.currentPage = nextPage
				// Total results might change, updating it is safe
				self.state.totalResults = result.totalResults
			} catch {
				print("TrackSearchViewModel LoadMore Error: \(error)")
				// Silent fail for load more, or maybe show a toast
			}
			
			self.state.isLoadingMore = false
		}
	}
}
