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

@MainActor
final class WeatherRecommendationViewModel: WeatherRecommendationViewableListener {
	private static let loadingFailureMessage = "날씨 추천을 불러오지 못했습니다."

	var view: WeatherRecommendationViewable?
	weak var coordinator: WeatherRecommendationCoordinatorAction?
	private let fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase
	private var loadTask: Task<Void, Never>?

	private var currentCuration: WeatherMusicCuration?

	init(
		view: WeatherRecommendationViewable,
		fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase
	) {
		self.view = view
		self.fetchMusicForWeatherUseCase = fetchMusicForWeatherUseCase
		self.view?.listener = self
	}

	deinit {
		self.loadTask?.cancel()
	}

	func viewDidLoad() {
		if let currentCuration {
			self.view?.update(weather: currentCuration.weather, tracks: currentCuration.tracks)
		} else {
			self.loadData()
		}
	}

	func didTapRefresh() {
		self.loadData()
	}

	func didSelectTrack(at index: Int) {
		guard let currentCuration, currentCuration.tracks.indices.contains(index) else { return }
		self.coordinator?.didSelect(track: currentCuration.tracks[index])
	}

	private func loadData() {
		self.loadTask?.cancel()
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
				let curation = try await self.fetchMusicForWeatherUseCase.execute()
				guard !Task.isCancelled else { return }

				self.currentCuration = curation
				self.view?.update(weather: curation.weather, tracks: curation.tracks)
			} catch is CancellationError {
				return
			} catch {
				guard !Task.isCancelled else { return }
				self.view?.showError(
					error.userMessage(fallback: Self.loadingFailureMessage)
				)
			}
		}
	}
}
