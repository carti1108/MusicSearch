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
				print("🚨 ViewModel Error: \(error.localizedDescription)")
				state.errorMessage = error.localizedDescription
			}

			state.isLoading = false
		}
	}

	private func handleTrackSelection(at index: Int) {}
}
