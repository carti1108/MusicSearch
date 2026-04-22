//
//  WeatherRecommendationInteractor.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs

@MainActor
protocol WeatherRecommendationRouting: ViewableRouting {}

@MainActor
protocol WeatherRecommendationPresentableListener: AnyObject {
	func viewDidLoad()
	func didTapRefresh()
	func didSelectTrack(at index: Int)
}

@MainActor
protocol WeatherRecommendationPresentable: Presentable {
	var listener: WeatherRecommendationPresentableListener? { get set }
	func update(weather: Weather, tracks: [Track])
	func showLoading(_ isShow: Bool)
	func showError(_ message: String?)
}

@MainActor
protocol WeatherRecommendationListener: AnyObject {}

@MainActor
final class WeatherRecommendationInteractor: PresentableInteractor<WeatherRecommendationPresentable>, WeatherRecommendationInteractable, WeatherRecommendationPresentableListener {
	weak var router: WeatherRecommendationRouting?
	weak var listener: WeatherRecommendationListener?

	private let fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase
	private let fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
	private let urlOpener: URLOpening
	private var loadTask: Task<Void, Never>?

	private var currentWeather: Weather = .init(
		temperature: 0.0,
		condition: .unknown,
		description: "",
		iconCode: "",
		cityName: ""
	)
	private var currentTracks: [Track] = []

	init(
		presenter: WeatherRecommendationPresentable,
		fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase,
		fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase,
		urlOpener: URLOpening
	) {
		self.fetchMusicForWeatherUseCase = fetchMusicForWeatherUseCase
		self.fetchMusicAppDeepLinkUseCase = fetchMusicAppDeepLinkUseCase
		self.urlOpener = urlOpener
		super.init(presenter: presenter)
		presenter.listener = self
	}

	func viewDidLoad() {
		guard self.currentTracks.isEmpty else {
			self.presenter.update(weather: self.currentWeather, tracks: self.currentTracks)
			return
		}
		self.loadData()
	}

	func didTapRefresh() {
		self.loadData()
	}

	func didSelectTrack(at index: Int) {
		guard index < self.currentTracks.count else { return }
		self.openMusicApp(for: self.currentTracks[index])
	}

	private func loadData() {
		self.loadTask?.cancel()
		self.presenter.showLoading(true)
		self.presenter.showError(nil)

		self.loadTask = Task { [weak self] in
			guard let self else { return }

			do {
				let result = try await self.fetchMusicForWeatherUseCase.execute()
				guard !Task.isCancelled else { return }

				self.currentWeather = result.weather
				self.currentTracks = result.tracks

				self.presenter.update(weather: self.currentWeather, tracks: self.currentTracks)
				self.presenter.showLoading(false)
			} catch is CancellationError {
				return
			} catch {
				guard !Task.isCancelled else { return }
				if let localized = error as? LocalizedError, let message = localized.errorDescription {
					self.presenter.showError(message)
				} else {
					self.presenter.showError("날씨 추천을 불러오지 못했습니다.")
				}
				self.presenter.showLoading(false)
			}
		}
	}

	private func openMusicApp(for track: Track) {
		Task {
			guard let url = await self.fetchMusicAppDeepLinkUseCase.execute(track: track) else { return }
			await self.urlOpener.open(url)
		}
	}
}
