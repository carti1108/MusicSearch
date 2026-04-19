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

@MainActor
final class TrackSearchViewModel: TrackSearchViewableListener {
	private static let searchFailureMessage = "검색 중 오류가 발생했습니다."

	private struct SearchRequest {
		let keyword: String
		let limit: Int
		let page: Int
	}

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
		self.searchTask?.cancel()
		self.loadMoreTask?.cancel()

		guard let request = self.prepareSearchRequest(from: keyword) else {
			self.publishResetSearch()
			return
		}

		self.beginInitialSearch(with: request)
	}

	private func loadMore() {
		self.loadMoreTask?.cancel()

		guard let request = self.prepareLoadMoreRequest() else { return }
		self.beginLoadMore(with: request)
	}

	private func prepareSearchRequest(from keyword: String) -> SearchRequest? {
		self.normalizedKeyword(from: keyword)
			.map { SearchRequest(keyword: $0, limit: self.limit, page: 1) }
	}

	private func normalizedKeyword(from keyword: String) -> String? {
		let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
		return trimmedKeyword.isEmpty ? nil : trimmedKeyword
	}

	private func prepareLoadMoreRequest() -> SearchRequest? {
		self.lastKeyword
			.flatMap { keyword in self.canLoadMore ? keyword : nil }
			.map { SearchRequest(keyword: $0, limit: self.limit, page: self.currentPage + 1) }
			.flatMap { request in self.loadingPage == request.page ? nil : request }
	}

	private func beginInitialSearch(with request: SearchRequest) {
		self.beginInitialSearchState(with: request)

		self.searchTask = Task { [weak self] in
			guard let self else { return }
			defer {
				if !Task.isCancelled {
					self.finishSearch()
					self.view?.showLoading(false)
				}
			}

			do {
				let result = try await self.executeSearch(for: request)
				guard !Task.isCancelled else { return }
				self.view?.updateTracks(self.applyInitialSearchResult(result))
			} catch is CancellationError {
				return
			} catch {
				guard !Task.isCancelled else { return }
				self.view?.updateTracks(self.failInitialSearch())
				self.view?.showError(
					error.userMessage(fallback: Self.searchFailureMessage)
				)
			}
		}
	}

	private func beginLoadMore(with request: SearchRequest) {
		self.beginLoadMoreState(with: request)

		self.loadMoreTask = Task { [weak self] in
			guard let self else { return }
			defer {
				if !Task.isCancelled {
					self.finishLoadMore(for: request.page)
				}
			}

			do {
				let result = try await self.executeSearch(for: request)
				guard !Task.isCancelled else { return }
				self.view?.updateTracks(
					self.applyLoadMoreResult(result, page: request.page)
				)
			} catch is CancellationError {
				return
			} catch {
				guard !Task.isCancelled else { return }
			}
		}
	}

	private func beginInitialSearchState(with request: SearchRequest) {
		self.lastKeyword = request.keyword
		self.currentPage = 1
		self.loadingPage = nil
		self.isLoadingMore = false
		self.isLoading = true
		self.view?.showLoading(true)
		self.view?.showError(nil)
	}

	private func beginLoadMoreState(with request: SearchRequest) {
		self.loadingPage = request.page
		self.isLoadingMore = true
	}

	private func executeSearch(
		for request: SearchRequest
	) async throws -> (tracks: [Track], totalResults: Int) {
		try await self.searchTracksUseCase.execute(
			query: request.keyword,
			limit: request.limit,
			page: request.page
		)
	}

	private func publishResetSearch() {
		self.view?.updateTracks(self.resetSearchState())
		self.view?.showLoading(false)
		self.view?.showError(nil)
	}

	private func resetSearchState() -> [Track] {
		self.lastKeyword = nil
		self.currentTracks = []
		self.currentPage = 1
		self.totalResults = 0
		self.isLoading = false
		self.isLoadingMore = false
		self.loadingPage = nil
		return self.currentTracks
	}

	private func finishSearch() {
		self.isLoading = false
	}

	private func applyInitialSearchResult(
		_ result: (tracks: [Track], totalResults: Int)
	) -> [Track] {
		self.currentTracks = result.tracks
		self.totalResults = result.totalResults
		self.currentPage = 1
		return self.currentTracks
	}

	private func failInitialSearch() -> [Track] {
		self.currentTracks = []
		self.totalResults = 0
		self.currentPage = 1
		return self.currentTracks
	}

	private func finishLoadMore(for page: Int) {
		self.isLoadingMore = false
		if self.loadingPage == page {
			self.loadingPage = nil
		}
	}

	private func applyLoadMoreResult(
		_ result: (tracks: [Track], totalResults: Int),
		page: Int
	) -> [Track] {
		self.currentTracks.append(contentsOf: result.tracks)
		self.currentPage = page
		self.totalResults = result.totalResults
		return self.currentTracks
	}
}
