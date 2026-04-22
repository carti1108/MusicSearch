//
//  WeatherRecommendationTestDoubles.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//  

import Foundation
import UIKit
import MicroRIBs
@testable import MusicSearch

@MainActor
final class WeatherRecommendationPresentableSpy: WeatherRecommendationPresentable {
	weak var listener: WeatherRecommendationPresentableListener?

	var updatedWeatherHistory: [Weather] = []
	var updatedTracksHistory: [[Track]] = []
	var loadingStates: [Bool] = []
	var errorMessages: [String?] = []

	func update(weather: Weather, tracks: [Track]) {
		self.updatedWeatherHistory.append(weather)
		self.updatedTracksHistory.append(tracks)
	}

	func showLoading(_ isShow: Bool) {
		self.loadingStates.append(isShow)
	}

	func showError(_ message: String?) {
		self.errorMessages.append(message)
	}
}

@MainActor
final class MockFetchMusicForWeatherUseCaseForInteractor: FetchMusicForWeatherUseCase {
	var result = WeatherMusicCuration(
		weather: Weather(
			temperature: 18,
			condition: .clouds,
			description: "흐림",
			iconCode: "03d",
			cityName: "Seoul"
		),
		moodTag: "indie",
		tracks: [
			Track(title: "Track 1", artist: "Artist 1", imageURL: nil)
		]
	)
	var executeCallCount = 0

	func execute() async throws -> WeatherMusicCuration {
		self.executeCallCount += 1
		return self.result
	}
}

@MainActor
final class MockFetchMusicAppDeepLinkUseCaseForWeatherRecommendationInteractor: FetchMusicAppDeepLinkUseCase {
	func execute(track: Track) async -> URL? { nil }
	func execute(artist: String) async -> URL? { nil }
}

@MainActor
final class MockWeatherRecommendationInteractableForRouter: Interactor, WeatherRecommendationInteractable {
	weak var router: WeatherRecommendationRouting?
	weak var listener: WeatherRecommendationListener?
}

@MainActor
final class MockWeatherRecommendationViewControllerForRouter: UIViewController, WeatherRecommendationViewControllable {}

@MainActor
final class MockFetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
	var result = WeatherMusicCuration(
		weather: Weather(
			temperature: 22,
			condition: .clear,
			description: "맑음",
			iconCode: "01d",
			cityName: "Seoul"
		),
		moodTag: "happy",
		tracks: [
			Track(title: "Yellow", artist: "Coldplay", imageURL: nil)
		]
	)
	var errorToThrow: Error?
	var executeCallCount = 0

	func execute() async throws -> WeatherMusicCuration {
		self.executeCallCount += 1

		if let error = self.errorToThrow {
			throw error
		}

		return self.result
	}
}

@MainActor
final class MockFetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
	func execute(track: Track) async -> URL? { nil }
	func execute(artist: String) async -> URL? { nil }
}

@MainActor
final class MockWeatherRecommendationListener: WeatherRecommendationListener {}

@MainActor
final class MockWeatherRecommendationDependency: WeatherRecommendationDependency {
	let fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase
	let fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
	let urlOpener: URLOpening

	init(
		fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase,
		fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase,
		urlOpener: URLOpening = MockURLOpener()
	) {
		self.fetchMusicForWeatherUseCase = fetchMusicForWeatherUseCase
		self.fetchMusicAppDeepLinkUseCase = fetchMusicAppDeepLinkUseCase
		self.urlOpener = urlOpener
	}
}
