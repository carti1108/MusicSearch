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
    func execute() async throws -> WeatherMusicCuration {
        let mockWeather = Weather(temperature: 24.5, condition: .clear, description: "Clear Sky", iconCode: "01d", cityName: "Seoul")
        let mockTracks = [
            Track(title: "Sunny Day Track", artist: "Sun Artist", imageURL: nil)
        ]
        return WeatherMusicCuration(weather: mockWeather, moodTag: "Happy", tracks: mockTracks)
    }
}

final class MockFetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
    func execute(track: Track) async -> URL? { nil }
    func execute(artist: String) async -> URL? { nil }
}

final class MockURLOpener: URLOpening {
    func open(_ url: URL) {}
}
