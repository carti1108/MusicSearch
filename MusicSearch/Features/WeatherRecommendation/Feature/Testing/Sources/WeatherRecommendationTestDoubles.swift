//
//  WeatherRecommendationTestDoubles.swift
//  MusicSearch
//
//  Created by Kiseok on 7/10/26.
//

@testable import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface
import Foundation
import MSDomain
import MSUtil
import MicroRIBs
import UIKit
import WeatherRecommendationDomain

@MainActor
public final class WeatherRecommendationPresentableSpy: WeatherRecommendationPresentable {
	public init() {}
	public weak var listener: WeatherRecommendationPresentableListener?

	public var updatedWeatherHistory: [Weather] = []
	public var updatedTracksHistory: [[Track]] = []
	public var loadingStates: [Bool] = []
	public var errorMessages: [String?] = []

	public func update(weather: Weather, tracks: [Track]) {
		self.updatedWeatherHistory.append(weather)
		self.updatedTracksHistory.append(tracks)
	}

	public func showLoading(_ isShow: Bool) {
		self.loadingStates.append(isShow)
	}

	public func showError(_ message: String?) {
		self.errorMessages.append(message)
	}
}

@MainActor
public final class MockFetchMusicForWeatherUseCaseForInteractor: FetchMusicForWeatherUseCase {
	public init() {}
	public var result = WeatherMusicCuration(
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
	public var executeCallCount = 0

	public func execute() async throws -> WeatherMusicCuration {
		self.executeCallCount += 1
		return self.result
	}
}

@MainActor
public final class MockFetchTrackDeepLinkUseCaseForWeatherRecommendationInteractor: FetchTrackDeepLinkUseCase {
	public init() {}
	public func execute(track: Track) async -> URL? { nil }
}

@MainActor
public final class MockWeatherRecommendationInteractableForRouter: Interactor, WeatherRecommendationInteractable {
	public override init() {}
	public weak var router: WeatherRecommendationRouting?
	public weak var listener: WeatherRecommendationListener?
}

@MainActor
public final class MockWeatherRecommendationViewControllerForRouter: UIViewController, WeatherRecommendationViewControllable {
	public init() { super.init(nibName: nil, bundle: nil) }
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

@MainActor
public final class MockDelayedFetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
	public init() {}
	public func execute() async throws -> WeatherMusicCuration {
		try await Task.sleep(nanoseconds: 2_000_000_000)
		let mockWeather = Weather(temperature: 18.0, condition: .thunderstorm, description: "천둥번개", iconCode: "11d", cityName: "Seoul")
		let mockTracks = [
			Track(title: "Thunder Track", artist: "Thunder Artist", imageURL: nil)
		]
		return WeatherMusicCuration(weather: mockWeather, moodTag: "Intense", tracks: mockTracks)
	}
}
