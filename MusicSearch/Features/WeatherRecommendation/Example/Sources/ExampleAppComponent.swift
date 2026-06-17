import Foundation
import UIKit
import MSDomain
import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface
import MSUtil
import WeatherRecommendationDomain

@MainActor
final class ExampleAppComponent: WeatherRecommendationDependency {
    var fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
        MockFetchMusicForWeatherUseCase()
    }
    var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
        MockFetchMusicAppDeepLinkUseCase()
    }
    var urlOpener: URLOpening {
        MockURLOpener()
    }
}

final class MockFetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
    func execute() async throws -> (Weather, [Track]) {
        let mockWeather = Weather(temperature: 24.5, description: "Clear Sky", iconCode: "01d")
        let mockTracks = [
            Track(title: "Sunny Day Track", artist: "Sun Artist", imageURL: nil)
        ]
        return (mockWeather, mockTracks)
    }
}

final class MockFetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
    func execute(track: Track) async -> URL? { nil }
    func execute(artist: String) async -> URL? { nil }
}

final class MockURLOpener: URLOpening {
    func open(_ url: URL) {}
}
