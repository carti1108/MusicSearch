import MSDomain
import Foundation
import UIKit
import MicroRIBs
import MSDomain
import MSUtil
@testable import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface
import WeatherRecommendationDomain

@MainActor
public final class WeatherRecommendationPresentableSpy: WeatherRecommendationPresentable {
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
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }}


