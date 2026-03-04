//
//  HomeInteractor.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import RIBs

protocol HomeRouting: ViewableRouting {}

@MainActor
protocol HomePresentableListener: AnyObject {
	func viewDidLoad()
	func didTapRefresh()
	func didSelectTrack(at index: Int)
}

@MainActor
protocol HomePresentable: Presentable {
	var listener: HomePresentableListener? { get set }
	func update(weather: Weather, tracks: [Track])
	func showLoading(_ isShow: Bool)
	func showError(_ message: String?)
}

protocol HomeListener: AnyObject {}

@MainActor
final class HomeInteractor: PresentableInteractor<HomePresentable>, HomeInteractable, HomePresentableListener {
	weak var router: HomeRouting?
	weak var listener: HomeListener?

	private let fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase
	private let fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
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
		presenter: HomePresentable,
		fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase,
		fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
	) {
		self.fetchMusicForWeatherUseCase = fetchMusicForWeatherUseCase
		self.fetchMusicAppDeepLinkUseCase = fetchMusicAppDeepLinkUseCase
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
			await MainActor.run {
				UIApplication.shared.open(url)
			}
		}
	}
}
