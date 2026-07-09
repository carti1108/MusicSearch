import MSDomain
import Foundation
import UIKit
import MicroRIBs
import MSDomain
import MSUtil
@testable import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface
import WeatherRecommendationDomain
import FeatureWeatherRecommendationTesting

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
final class MockFetchTrackDeepLinkUseCaseForWeatherRecommendationInteractor: FetchMusicAppDeepLinkUseCase {
	func execute(track: Track) async -> URL? { nil }
	
}

@MainActor
final class MockWeatherRecommendationInteractableForRouter: Interactor, WeatherRecommendationInteractable {
	weak var router: WeatherRecommendationRouting?
	weak var listener: WeatherRecommendationListener?
}

@MainActor
final class MockWeatherRecommendationViewControllerForRouter: UIViewController, WeatherRecommendationViewControllable {}

