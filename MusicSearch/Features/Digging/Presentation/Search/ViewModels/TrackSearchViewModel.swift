//
//  TrackSearchViewModel.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation
import Combine

@MainActor
protocol TrackSearchViewable: AnyObject {
	var listener: TrackSearchViewableListener? { get set }
	func updateTracks(_ tracks: [Track])
	func showLoading(_ isShow: Bool)
	func showError(_ message: String?)
}

@MainActor
protocol TrackSearchViewCoordinatorAction: AnyObject {
	func didSelect(_ track: Track)
}

final class TrackSearchViewModel: TrackSearchViewableListener {

	var view: TrackSearchViewable?
	weak var coordinator: TrackSearchViewCoordinatorAction?
	private let searchSubject: PassthroughSubject<String, Never> = .init()
	private var cancellables: Set<AnyCancellable> = .init()

	private var lastKeyword: String?
	private var currentTracks: [Track] = []
	private var currentPage: Int = 1
	private var totalResults: Int = 0
	private var isLoading: Bool = false
	private var isLoadingMore: Bool = false
	private var loadingPage: Int?

	private var searchTask: Task<Void, Never>?
	private var loadMoreTask: Task<Void, Never>?

	private let limit: Int = 20
	private let debounceSeconds: TimeInterval
	private let searchTracksUseCase: SearchTracksUseCase

	init(
		view: TrackSearchViewable,
		debounceSeconds: TimeInterval = 0.5,
		searchTracksUseCase: SearchTracksUseCase
	) {
		self.view = view
		self.debounceSeconds = debounceSeconds
		self.searchTracksUseCase = searchTracksUseCase
		self.bindSearchInput()
		self.view?.listener = self
	}

	deinit {
		self.searchTask?.cancel()
		self.loadMoreTask?.cancel()
	}

	func didUpdateSearchText(_ keyword: String) {
		self.searchSubject.send(keyword)
	}

	func didTapRetry() {
		guard let lastKeyword else { return }
		self.performSearch(keyword: lastKeyword)
	}

	func didSelectTrack(_ track: Track) {
		self.coordinator?.didSelect(track)
	}

	func didReachListBottom() {
		self.loadMore()
	}

	private var canLoadMore: Bool {
		!self.isLoading && !self.isLoadingMore && self.currentTracks.count < self.totalResults
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
			self.searchTask?.cancel()
			self.loadMoreTask?.cancel()

			self.lastKeyword = nil
			self.loadingPage = nil
			self.currentTracks = []
			self.currentPage = 1
			self.totalResults = 0
			self.isLoading = false
			self.isLoadingMore = false

			self.view?.updateTracks([])
			self.view?.showLoading(false)
			self.view?.showError(nil)
			return
		}

		self.lastKeyword = keyword
		self.currentPage = 1
		self.searchTask?.cancel()
		self.loadMoreTask?.cancel()
		self.loadingPage = nil
		self.isLoadingMore = false
		self.isLoading = true

		self.view?.showLoading(true)
		self.view?.showError(nil)

		self.searchTask = Task { [weak self] in
			guard let self else { return }
			defer {
				if !Task.isCancelled {
					self.isLoading = false
					self.view?.showLoading(false)
				}
			}

			do {
				let result = try await self.searchTracksUseCase.execute(
					query: keyword,
					limit: self.limit,
					page: 1
				)
				guard !Task.isCancelled else { return }

				self.currentTracks = result.tracks
				self.totalResults = result.totalResults
				self.currentPage = 1
				self.view?.updateTracks(self.currentTracks)
			} catch is CancellationError {
				return
			} catch {
				guard !Task.isCancelled else { return }
				print("TrackSearchViewModel Error: \(error)")

				self.currentTracks = []
				self.totalResults = 0
				self.currentPage = 1

				self.view?.updateTracks([])
				self.view?.showError("검색 중 오류가 발생했습니다.")
			}
		}
	}

	private func loadMore() {
		guard self.canLoadMore, let keyword = self.lastKeyword else { return }

		let nextPage = self.currentPage + 1
		guard self.loadingPage != nextPage else { return }

		self.loadingPage = nextPage
		self.isLoadingMore = true

		self.loadMoreTask?.cancel()
		self.loadMoreTask = Task { [weak self] in
			guard let self else { return }
			defer {
				if !Task.isCancelled {
					self.isLoadingMore = false
				}
				if self.loadingPage == nextPage {
					self.loadingPage = nil
				}
			}

			do {
				let result = try await self.searchTracksUseCase.execute(
					query: keyword,
					limit: self.limit,
					page: nextPage
				)
				guard !Task.isCancelled else { return }

				self.currentTracks.append(contentsOf: result.tracks)
				self.currentPage = nextPage
				self.totalResults = result.totalResults
				self.view?.updateTracks(self.currentTracks)
			} catch is CancellationError {
				return
			} catch {
				guard !Task.isCancelled else { return }
				print("TrackSearchViewModel LoadMore Error: \(error)")
			}
		}
	}
}
