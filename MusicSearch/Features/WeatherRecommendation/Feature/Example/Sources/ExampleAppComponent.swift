import Foundation
import UIKit
import MSDomain
import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface
import MSUtil
import WeatherRecommendationDomain

struct ExampleWeatherState {
    static var currentCondition: WeatherCondition = .clear
}

@MainActor
final class ExampleAppComponent: WeatherRecommendationDependency {
    var fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
        MockFetchMusicForWeatherUseCase()
    }
    var fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase {
        MockFetchTrackDeepLinkUseCase()
    }
    var urlOpener: URLOpening {
        MockURLOpener()
    }
}

final class MockFetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
    func execute() async throws -> WeatherMusicCuration {
        let mockWeather = Weather(temperature: 24.5, condition: ExampleWeatherState.currentCondition, description: "Debug Weather", iconCode: "01d", cityName: "Seoul")
        let mockTracks = [
            Track(title: "Sunny Day Track", artist: "Sun Artist", imageURL: nil),
			Track(title: "Sunny Day Track", artist: "Sun Artist", imageURL: nil),
			Track(title: "Sunny Day Track", artist: "Sun Artist", imageURL: nil),
			Track(title: "Sunny Day Track", artist: "Sun Artist", imageURL: nil),
			Track(title: "Sunny Day Track", artist: "Sun Artist", imageURL: nil),
			Track(title: "Sunny Day Track", artist: "Sun Artist", imageURL: nil),
			Track(title: "Sunny Day Track", artist: "Sun Artist", imageURL: nil)
        ]
        return WeatherMusicCuration(weather: mockWeather, moodTag: "Happy", tracks: mockTracks)
    }
}

final class MockFetchTrackDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
    func execute(track: Track) async -> URL? { nil }
    
}

final class MockURLOpener: URLOpening {
    func open(_ url: URL) {}
}
