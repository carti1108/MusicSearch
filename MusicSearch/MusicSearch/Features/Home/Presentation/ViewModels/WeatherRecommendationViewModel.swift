//
//  WeatherRecommendationViewModel.swift
//  MusicSearch
//
//  Created by Kiseok on 12/8/25.
//

import Foundation
import Combine

struct WeatherRecommendationState {
	var isLoading: Bool
	var weather: Weather
	var tracks: [Track]
	var errorMessage: String?

	static var initial: Self {
		.init(
			isLoading: false,
			weather: .init(
				temperature: 0.0,
				condition: .unknown,
				description: "",
				iconCode: "",
				cityName: ""
			),
			tracks: [],
			errorMessage: nil
		)
	}
}

enum WeatherRecommendationAction {
	case viewWillAppear
	case refresh
	case trackCardSelected(index: Int)
}

@MainActor
final class WeatherRecommendationViewModel {

	@Published private(set) var state: WeatherRecommendationState = .initial

	private let fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase

	init(fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase) {
		self.fetchMusicForWeatherUseCase = fetchMusicForWeatherUseCase
	}

	func process(action: WeatherRecommendationAction) {
		switch action {
		case .viewWillAppear:
			if self.state.tracks.isEmpty {
				self.loadData()
			}
		case .refresh:
			self.loadData()
		case .trackCardSelected(let index):
			self.handleTrackSelection(at: index)
		}
	}
}

extension WeatherRecommendationViewModel {
	private func loadData() {
		Task {
			self.state.isLoading = true
			self.state.errorMessage = nil

			do {
				let result = try await self.fetchMusicForWeatherUseCase.execute()

				state.weather = result.weather
				state.tracks = result.tracks
			} catch {
				if let localized = error as? LocalizedError, let message = localized.errorDescription {
					state.errorMessage = message
				} else {
					state.errorMessage = "날씨 추천을 불러오지 못했습니다."
				}
			}

			state.isLoading = false
		}
	}

	private func handleTrackSelection(at index: Int) {}
}
