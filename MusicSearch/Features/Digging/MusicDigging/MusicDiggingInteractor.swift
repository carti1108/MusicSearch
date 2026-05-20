//
//  MusicDiggingInteractor.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs

@MainActor
protocol MusicDiggingRouting: ViewableRouting {}

@MainActor
protocol MusicDiggingPresentableListener: AnyObject {
	func viewDidAppear()
	func didTapRetry()
	func didTapSeedTrack()
	func didSelectRecommendation(at indexPath: IndexPath)
}

@MainActor
protocol MusicDiggingPresentable: Presentable {
	var listener: MusicDiggingPresentableListener? { get set }
	func updateSeedTrack(_ track: Track)
	func updateRecommendations(_ tracks: [Track])
	func showLoading(_ isShow: Bool)
	func showError(_ message: String?)
}

@MainActor
protocol MusicDiggingListener: AnyObject {}

@MainActor
final class MusicDiggingInteractor: PresentableInteractor<MusicDiggingPresentable>, MusicDiggingInteractable, MusicDiggingPresentableListener {
	weak var router: MusicDiggingRouting?
	weak var listener: MusicDiggingListener?

	private let fetchSimilarTracksUseCase: FetchSimilarTracksUseCase
	private let fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
	private let urlOpener: URLOpening
	private var loadTask: Task<Void, Never>?

	private var currentSeedTrack: Track
	private var currentRecommendations: [Track] = []

	init(
		seedTrack: Track,
		presenter: MusicDiggingPresentable,
		fetchSimilarTracksUseCase: FetchSimilarTracksUseCase,
		fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase,
		urlOpener: URLOpening
	) {
		self.currentSeedTrack = seedTrack
		self.fetchSimilarTracksUseCase = fetchSimilarTracksUseCase
		self.fetchMusicAppDeepLinkUseCase = fetchMusicAppDeepLinkUseCase
		self.urlOpener = urlOpener
		super.init(presenter: presenter)
		presenter.listener = self
	}

	func viewDidAppear() {
		self.presenter.updateSeedTrack(self.currentSeedTrack)
		if self.currentRecommendations.isEmpty {
			self.loadRecommendations(basedOn: self.currentSeedTrack)
		} else {
			self.presenter.updateRecommendations(self.currentRecommendations)
		}
	}

	func didTapRetry() {
		self.loadRecommendations(basedOn: self.currentSeedTrack)
	}

	func didTapSeedTrack() {
		self.openMusicApp(for: self.currentSeedTrack)
	}

	func didSelectRecommendation(at indexPath: IndexPath) {
		let index = indexPath.item
		guard index < self.currentRecommendations.count else { return }

		let selectedTrack = self.currentRecommendations[index]
		self.currentSeedTrack = selectedTrack
		self.presenter.updateSeedTrack(selectedTrack)
		self.loadRecommendations(basedOn: selectedTrack)
	}

	private func loadRecommendations(basedOn track: Track) {
		self.loadTask?.cancel()
		self.currentRecommendations = []
		self.presenter.updateRecommendations([])
		self.presenter.showLoading(true)
		self.presenter.showError(nil)

		let fetchSimilarTracksUseCase = self.fetchSimilarTracksUseCase
		self.loadTask = Task { [weak self] in
			do {
				let tracks = try await fetchSimilarTracksUseCase.execute(targetTrack: track)
				guard !Task.isCancelled, let self else { return }

				self.currentRecommendations = tracks
				self.presenter.updateRecommendations(tracks)
				if tracks.isEmpty {
					self.presenter.showError("추천 곡을 불러오지 못했습니다.")
				}
				self.presenter.showLoading(false)
			} catch is CancellationError {
				return
			} catch {
				guard !Task.isCancelled, let self else { return }
				self.currentRecommendations = []
				self.presenter.updateRecommendations([])
				self.presenter.showError("추천 곡을 불러오지 못했습니다.")
				self.presenter.showLoading(false)
			}
		}
	}

	private func openMusicApp(for track: Track) {
		let fetchMusicAppDeepLinkUseCase = self.fetchMusicAppDeepLinkUseCase
		let urlOpener = self.urlOpener
		Task {
			guard let url = await fetchMusicAppDeepLinkUseCase.execute(track: track) else { return }
			urlOpener.open(url)
		}
	}
}
