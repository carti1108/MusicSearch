//
//  RootTestDoubles.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//  

import Foundation
import UIKit
import MicroRIBs
@testable import MusicSearch

@MainActor
final class RootPresentableSpy: RootPresentable {
	weak var listener: RootPresentableListener?
}

@MainActor
final class RootRouterPresentableSpy: RootPresentable {
	weak var listener: RootPresentableListener?
}

@MainActor
final class RootViewControllableSpy: UIViewController, RootViewControllable {
	var capturedTabs: [UIViewController] = []

	func setTabs(_ viewControllers: [UIViewController]) {
		self.capturedTabs = viewControllers
	}
}

@MainActor
final class MockRootWeatherRecommendationInteractable: Interactor, WeatherRecommendationInteractable {
	weak var router: WeatherRecommendationRouting?
	weak var listener: WeatherRecommendationListener?
}

@MainActor
final class MockRootWeatherRecommendationViewController: UIViewController, WeatherRecommendationViewControllable {}

@MainActor
final class RootWeatherRecommendationRoutingSpy: ViewableRouter<MockRootWeatherRecommendationInteractable, MockRootWeatherRecommendationViewController>, WeatherRecommendationRouting {}

@MainActor
final class WeatherRecommendationBuilderSpy: WeatherRecommendationBuildable {
	var buildCallCount = 0
	var receivedListener: WeatherRecommendationListener?
	var buildHandler: ((WeatherRecommendationListener) -> WeatherRecommendationRouting)?

	func build(withListener listener: WeatherRecommendationListener) -> WeatherRecommendationRouting {
		self.buildCallCount += 1
		self.receivedListener = listener
		if let buildHandler {
			return buildHandler(listener)
		}
		return RootWeatherRecommendationRoutingSpy(
			interactor: MockRootWeatherRecommendationInteractable(),
			viewController: MockRootWeatherRecommendationViewController()
		)
	}
}

@MainActor
final class MockRootTrackSearchInteractable: Interactor, TrackSearchInteractable {
	weak var router: TrackSearchRouting?
	weak var listener: TrackSearchListener?
}

@MainActor
final class MockRootTrackSearchViewController: UIViewController, TrackSearchViewControllable {}

@MainActor
final class RootTrackSearchRoutingSpy: ViewableRouter<MockRootTrackSearchInteractable, MockRootTrackSearchViewController>, TrackSearchRouting {
	func attachMusicDigging(seedTrack: Track) {}
}

@MainActor
final class TrackSearchBuilderSpy: TrackSearchBuildable {
	var buildCallCount = 0
	var receivedListener: TrackSearchListener?
	var receivedNavigationController: UINavigationController?
	var buildHandler: ((TrackSearchListener, UINavigationController) -> TrackSearchRouting)?

	func build(
		withListener listener: TrackSearchListener,
		navigationController: UINavigationController
	) -> TrackSearchRouting {
		self.buildCallCount += 1
		self.receivedListener = listener
		self.receivedNavigationController = navigationController
		if let buildHandler {
			return buildHandler(listener, navigationController)
		}
		return RootTrackSearchRoutingSpy(
			interactor: MockRootTrackSearchInteractable(),
			viewController: MockRootTrackSearchViewController()
		)
	}
}

@MainActor
final class MockRootChartInteractable: Interactor, ChartInteractable {
	weak var router: ChartRouting?
	weak var listener: ChartListener?
}

@MainActor
final class MockRootChartViewController: UIViewController, ChartViewControllable {}

@MainActor
final class RootChartRoutingSpy: ViewableRouter<MockRootChartInteractable, MockRootChartViewController>, ChartRouting {}

@MainActor
final class ChartBuilderSpy: ChartBuildable {
	var buildCallCount = 0
	var receivedListener: ChartListener?
	var buildHandler: ((ChartListener) -> ChartRouting)?

	func build(withListener listener: ChartListener) -> ChartRouting {
		self.buildCallCount += 1
		self.receivedListener = listener
		if let buildHandler {
			return buildHandler(listener)
		}
		return RootChartRoutingSpy(
			interactor: MockRootChartInteractable(),
			viewController: MockRootChartViewController()
		)
	}
}

@MainActor
final class RootMockFetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
	func execute() async throws -> WeatherMusicCuration {
		WeatherMusicCuration(
			weather: Weather(
				temperature: 20,
				condition: .clear,
				description: "맑음",
				iconCode: "01d",
				cityName: "Seoul"
			),
			moodTag: "happy",
			tracks: []
		)
	}
}

@MainActor
final class RootMockFetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
	func execute(track: Track) async -> URL? { nil }
	func execute(artist: String) async -> URL? { nil }
}

@MainActor
final class RootMockSearchTracksUseCase: SearchTracksUseCase {
	func execute(query: String, limit: Int, page: Int) async throws -> (tracks: [Track], totalResults: Int) {
		([], 0)
	}
}

@MainActor
final class RootMockFetchTracksByTagUseCase: FetchTracksByTagUseCase {
	func execute(tag: String) async throws -> [Track] { [] }
}

@MainActor
final class RootMockFetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
	func execute(targetTrack: Track) async throws -> [Track] { [] }
}

@MainActor
final class RootMockFetchChartTopTracksUseCase: FetchChartTopTracksUseCase {
	func execute() async throws -> [Track] { [] }
}

@MainActor
final class RootMockFetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase {
	func execute() async throws -> [Artist] { [] }
}

@MainActor
final class MockRootDependency: RootDependency {
	let fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase
	let fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
	let searchTracksUseCase: SearchTracksUseCase
	let fetchTracksByTagUseCase: FetchTracksByTagUseCase
	let fetchSimilarTracksUseCase: FetchSimilarTracksUseCase
	let fetchChartTopTracksUseCase: FetchChartTopTracksUseCase
	let fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase
	let urlOpener: URLOpening

	init(
		fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase,
		fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase,
		searchTracksUseCase: SearchTracksUseCase,
		fetchTracksByTagUseCase: FetchTracksByTagUseCase,
		fetchSimilarTracksUseCase: FetchSimilarTracksUseCase,
		fetchChartTopTracksUseCase: FetchChartTopTracksUseCase,
		fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase,
		urlOpener: URLOpening = MockURLOpener()
	) {
		self.fetchMusicForWeatherUseCase = fetchMusicForWeatherUseCase
		self.fetchMusicAppDeepLinkUseCase = fetchMusicAppDeepLinkUseCase
		self.searchTracksUseCase = searchTracksUseCase
		self.fetchTracksByTagUseCase = fetchTracksByTagUseCase
		self.fetchSimilarTracksUseCase = fetchSimilarTracksUseCase
		self.fetchChartTopTracksUseCase = fetchChartTopTracksUseCase
		self.fetchChartTopArtistsUseCase = fetchChartTopArtistsUseCase
		self.urlOpener = urlOpener
	}
}
