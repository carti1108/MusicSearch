//
//  FeatureWeatherRecommendationTesting.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import FeatureWeatherRecommendationInterface
import Foundation
import MSDomain
import MSUtil
import WeatherRecommendationDomain

@MainActor
public final class MockFetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
	public var result = WeatherMusicCuration(
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
	public var errorToThrow: Error?
	public var executeCallCount = 0

	public init() {}

	public func execute() async throws -> WeatherMusicCuration {
		self.executeCallCount += 1

		if let error = self.errorToThrow {
			throw error
		}

		return self.result
	}
}

@MainActor
public final class MockWeatherRecommendationListener: WeatherRecommendationListener {
	public init() {}
}

@MainActor
public final class MockWeatherRecommendationDependency: WeatherRecommendationDependency {
	public let fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase
	public let fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase
	public let urlOpener: URLOpening

	public init(
		fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase,
		fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase,
		urlOpener: URLOpening = MockURLOpener()
	) {
		self.fetchMusicForWeatherUseCase = fetchMusicForWeatherUseCase
		self.fetchTrackDeepLinkUseCase = fetchTrackDeepLinkUseCase
		self.urlOpener = urlOpener
	}
}

public final class MockURLOpener: URLOpening {
	public var openedURLs: [URL] = []

	public init() {}

	@MainActor
	public func open(_ url: URL) {
		self.openedURLs.append(url)
	}
}

@MainActor
public final class MockFetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase {
	public init() {}
	public func execute(track: Track) async -> URL? { nil }
}
