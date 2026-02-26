//
//  WeatherRecommendationViewModel.swift
//  MusicSearch
//
//  Created by Kiseok on 12/8/25.
//

import Foundation

@MainActor
protocol WeatherRecommendationViewable: AnyObject {
	var listener: WeatherRecommendationViewableListener? { get set }

	func update(weather: Weather, tracks: [Track])
	func showLoading(_ isShow: Bool)
	func showError(_ message: String?)
}

@MainActor
protocol WeatherRecommendationCoordinatorAction: AnyObject {
	func didSelect(track: Track)
}

final class WeatherRecommendationViewModel: WeatherRecommendationViewableListener {

	var view: WeatherRecommendationViewable?
	weak var coordinator: WeatherRecommendationCoordinatorAction?
	private let fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase
	private var loadTask: Task<Void, Never>?

	private var currentWeather: Weather = .init(
		temperature: 0.0,
		condition: .unknown,
		description: "",
		iconCode: "",
		cityName: ""
	)
	private var currentTracks: [Track] = []

	init(fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase) {
		self.fetchMusicForWeatherUseCase = fetchMusicForWeatherUseCase
	}

	deinit {
		self.loadTask?.cancel()
	}

	func viewDidLoad() {
		guard self.currentTracks.isEmpty else {
			self.view?.update(weather: self.currentWeather, tracks: self.currentTracks)
			return
		}
		self.loadData()
	}

	func didTapRefresh() {
		self.loadData()
	}

	func didSelectTrack(at index: Int) {
		guard index < self.currentTracks.count else { return }
		self.coordinator?.didSelect(track: self.currentTracks[index])
	}

	private func loadData() {
		self.loadTask?.cancel()
		self.view?.showLoading(true)
		self.view?.showError(nil)

		self.loadTask = Task { [weak self] in
			guard let self else { return }

			do {
				let result = try await self.fetchMusicForWeatherUseCase.execute()
				guard !Task.isCancelled else { return }

				self.currentWeather = result.weather
				self.currentTracks = result.tracks

				self.view?.update(weather: self.currentWeather, tracks: self.currentTracks)
				self.view?.showLoading(false)
			} catch is CancellationError {
				return
			} catch {
				guard !Task.isCancelled else { return }
				if let localized = error as? LocalizedError, let message = localized.errorDescription {
					self.view?.showError(message)
				} else {
					self.view?.showError("날씨 추천을 불러오지 못했습니다.")
				}
				self.view?.showLoading(false)
			}
		}
	}
}
