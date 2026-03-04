//
//  MusicDiggingViewModel.swift
//  MusicSearch
//
//  Created by Kiseok on 12/11/25.
//

import Foundation
import Combine

struct MusicDiggingState {
	var isLoading: Bool = false
	var seedTrack: Track
	var recommendations: [Track] = .init()
	var errorMessage: String? = nil
}

enum MusicDiggingAction {
	case viewWillAppear
	case selectTrack(track: Track)
	case retry
}

@MainActor
final class MusicDiggingViewModel {

	@Published private(set) var state: MusicDiggingState

	private let fetchSimilarTracksUseCase: FetchSimilarTracksUseCase
	private var loadTask: Task<Void, Never>?

	init(
		seedTrack: Track,
		fetchSimilarTracksUseCase: FetchSimilarTracksUseCase
	) {
		self.state = MusicDiggingState(seedTrack: seedTrack)
		self.fetchSimilarTracksUseCase = fetchSimilarTracksUseCase
	}

	func process(action: MusicDiggingAction) {
		switch action {
		case .viewWillAppear:
			if self.state.recommendations.isEmpty {
				self.loadRecommendations(basedOn: self.state.seedTrack)
			}
		case .selectTrack(let track):
			self.state.seedTrack = track
			self.loadRecommendations(basedOn: track)

		case .retry:
			self.loadRecommendations(basedOn: self.state.seedTrack)
		}
	}

	private func loadRecommendations(basedOn track: Track) {
		self.loadTask?.cancel()
		self.state.isLoading = true
		self.state.errorMessage = nil
		self.state.recommendations = []

		self.loadTask = Task {
			do {
				let tracks = try await self.fetchSimilarTracksUseCase.execute(targetTrack: track)
				guard !Task.isCancelled else { return }
				if tracks.isEmpty {
					state.errorMessage = "추천 곡을 불러오지 못했습니다."
				}
				self.state.recommendations = tracks
			} catch is CancellationError {
				return
			} catch {
				print("MusicDiggingViewModel Error: \(error)")
				state.errorMessage = "추천 곡을 불러오지 못했습니다."
				state.recommendations = []
			}

			self.state.isLoading = false
		}
	}
}
