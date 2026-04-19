//
//  MusicDiggingViewModel.swift
//  MusicSearch
//
//  Created by Kiseok on 12/11/25.
//

import Foundation

@MainActor
protocol MusicDiggingViewable: AnyObject {
	var listener: MusicDiggingViewableListener? { get set }
	func updateSeedTrack(_ track: Track)
	func updateRecommendations(_ tracks: [Track])
	func showLoading(_ isShow: Bool)
	func showError(_ message: String?)
}

@MainActor
final class MusicDiggingViewModel: MusicDiggingViewableListener {
	private static let recommendationFailureMessage = "추천 곡을 불러오지 못했습니다."

	var view: MusicDiggingViewable?
	weak var coordinator: MusicDiggingViewCoordinatorAction?

	private let fetchSimilarTracksUseCase: FetchSimilarTracksUseCase
	private var loadTask: Task<Void, Never>?

	private var currentSeedTrack: Track
	private var currentRecommendations: [Track] = []

	init(
		seedTrack: Track,
		view: MusicDiggingViewable,
		fetchSimilarTracksUseCase: FetchSimilarTracksUseCase
	) {
		self.currentSeedTrack = seedTrack
		self.view = view
		self.fetchSimilarTracksUseCase = fetchSimilarTracksUseCase
		self.view?.listener = self
	}

	deinit {
		self.loadTask?.cancel()
	}

	func viewDidAppear() {
		self.view?.updateSeedTrack(self.currentSeedTrack)
		if self.currentRecommendations.isEmpty {
			self.loadRecommendations(basedOn: self.currentSeedTrack)
		} else {
			self.view?.updateRecommendations(self.currentRecommendations)
		}
	}

	func didTapRetry() {
		self.loadRecommendations(basedOn: self.currentSeedTrack)
	}

	func didTapSeedTrack() {
		self.coordinator?.didTapSeedTrack(self.currentSeedTrack)
	}

	func didSelectRecommendation(at indexPath: IndexPath) {
		guard self.currentRecommendations.indices.contains(indexPath.item) else { return }

		let selectedTrack = self.currentRecommendations[indexPath.item]
		self.currentSeedTrack = selectedTrack
		self.view?.updateSeedTrack(selectedTrack)
		self.loadRecommendations(basedOn: selectedTrack)
	}

	private func loadRecommendations(basedOn track: Track) {
		self.loadTask?.cancel()
		self.currentRecommendations = []
		self.view?.updateRecommendations([])
		self.view?.showLoading(true)
		self.view?.showError(nil)

		self.loadTask = Task { [weak self] in
			guard let self else { return }
			defer {
				if !Task.isCancelled {
					self.view?.showLoading(false)
				}
			}

			do {
				let recommendations = try await self.fetchSimilarTracksUseCase.execute(
					targetTrack: track
				)
				guard !Task.isCancelled else { return }
				guard recommendations.isEmpty == false else {
					self.view?.showError(Self.recommendationFailureMessage)
					return
				}

				self.currentRecommendations = recommendations
				self.view?.updateRecommendations(recommendations)
			} catch is CancellationError {
				return
			} catch {
				guard !Task.isCancelled else { return }
				self.view?.showError(
					error.userMessage(fallback: Self.recommendationFailureMessage)
				)
			}
		}
	}
}
