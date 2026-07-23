//
//  TrackSearchInteractor.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import Combine
import Foundation
import OSLog
import MicroRIBs
import FeatureTrackSearchInterface
import FeatureMusicDiggingInterface
import MSDomain
import TrackSearchDomain

@MainActor
protocol TrackSearchPresentable: Presentable {
	var listener: TrackSearchPresentableListener? { get set }

	func updateTracks(_ tracks: [Track])
	func showLoading(_ isShow: Bool)
	func showError(_ message: String?)
}

@MainActor
final class TrackSearchInteractor: PresentableInteractor<TrackSearchPresentable>, TrackSearchInteractable, TrackSearchPresentableListener {
	weak var router: TrackSearchRouting?
	weak var listener: TrackSearchListener?

	private let searchSubject: PassthroughSubject<String, Never> = .init()
	private var cancellables: Set<AnyCancellable> = .init()

	private var lastKeyword: String?
	private var currentTracks: [Track] = []
	private var currentOffset: Int = 0
	private var totalResults: Int = 0
	private var isLoading: Bool = false
	private var isLoadingMore: Bool = false
	private var loadingOffset: Int?

	private var searchTask: Task<Void, Never>?
	private var loadMoreTask: Task<Void, Never>?

	private let limit: Int = 20
	private let debounceSeconds: TimeInterval
	private let searchTracksUseCase: SearchTracksUseCase

	init(
		presenter: TrackSearchPresentable,
		debounceSeconds: TimeInterval = 0.5,
		searchTracksUseCase: SearchTracksUseCase
	) {
		self.debounceSeconds = debounceSeconds
		self.searchTracksUseCase = searchTracksUseCase
		super.init(presenter: presenter)
		self.bindSearchInput()
		presenter.listener = self
	}

	func didUpdateSearchText(_ keyword: String) {
		self.searchSubject.send(keyword)
	}

	func didTapRetry() {
		guard let lastKeyword else { return }
		self.performSearch(keyword: lastKeyword)
	}

	func didSelectTrack(_ track: Track) {
		self.router?.attachMusicDigging(seedTrack: track)
	}

	func didReachListBottom() {
		self.loadMore()
	}

	private var canLoadMore: Bool {
		!self.isLoading && !self.isLoadingMore && self.currentTracks.count < self.totalResults
	}

	private func bindSearchInput() {
		self.searchSubject
			.removeDuplicates()
			.debounce(for: .seconds(self.debounceSeconds), scheduler: DispatchQueue.main)
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
			self.loadingOffset = nil
			self.currentTracks = []
			self.currentOffset = 0
			self.totalResults = 0
			self.isLoading = false
			self.isLoadingMore = false

			self.presenter.updateTracks([])
			self.presenter.showLoading(false)
			self.presenter.showError(nil)
			return
		}

		self.lastKeyword = keyword
		self.currentOffset = 0
		self.searchTask?.cancel()
		self.loadMoreTask?.cancel()
		self.loadingOffset = nil
		self.isLoadingMore = false
		self.isLoading = true

		self.presenter.showLoading(true)
		self.presenter.showError(nil)

		let searchTracksUseCase = self.searchTracksUseCase
		let limit = self.limit
		self.searchTask = Task { [weak self] in
			defer {
				if !Task.isCancelled, let self {
					self.isLoading = false
					self.presenter.showLoading(false)
				}
			}

			do {
				let result = try await searchTracksUseCase.execute(
					query: keyword,
					limit: limit,
					offset: 0
				)
				guard !Task.isCancelled, let self else { return }

				self.currentTracks = result.tracks
				self.totalResults = result.totalResults
				self.currentOffset = 0
				self.presenter.updateTracks(self.currentTracks)
			} catch is CancellationError {
				return
			} catch {
				guard !Task.isCancelled, let self else { return }

				self.currentTracks = []
				self.totalResults = 0
				self.currentOffset = 0

				self.presenter.updateTracks([])
				self.presenter.showError("검색 중 오류가 발생했습니다.")
			}
		}
	}

	private func loadMore() {
		guard self.canLoadMore, let keyword = self.lastKeyword else { return }

		let nextOffset = self.currentOffset + self.limit
		guard self.loadingOffset != nextOffset else { return }

		self.loadingOffset = nextOffset
		self.isLoadingMore = true

		self.loadMoreTask?.cancel()
		let searchTracksUseCase = self.searchTracksUseCase
		let limit = self.limit
		self.loadMoreTask = Task { [weak self] in
			defer {
				if !Task.isCancelled, let self {
					self.isLoadingMore = false
				}
				if let self, self.loadingOffset == nextOffset {
					self.loadingOffset = nil
				}
			}

			do {
				let result = try await searchTracksUseCase.execute(
					query: keyword,
					limit: limit,
					offset: nextOffset
				)
				guard !Task.isCancelled, let self else { return }

				self.currentTracks.append(contentsOf: result.tracks)
				self.currentOffset = nextOffset
				self.totalResults = result.totalResults
				self.presenter.updateTracks(self.currentTracks)
			} catch is CancellationError {
				return
			} catch {
				Logger(subsystem: "MusicSearch", category: "TrackSearchInteractor")
					.error("loadMore failed: \(error.localizedDescription)")
				return
			}
		}
	}
}
