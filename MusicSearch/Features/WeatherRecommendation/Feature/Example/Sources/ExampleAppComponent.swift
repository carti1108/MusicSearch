//
//  ExampleAppComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import UIKit
import MSDomain
import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface
import MSUtil
import WeatherRecommendationDomain
import FeatureWeatherRecommendationTesting

@MainActor
final class ExampleAppComponent: WeatherRecommendationDependency {
    let scenario: DemoScenario
    
    init(scenario: DemoScenario) {
        self.scenario = scenario
    }
    
    var fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
        switch scenario {
        case .sunny:
            let mock = MockFetchMusicForWeatherUseCase()
            let mockWeather = Weather(temperature: 24.5, condition: .clear, description: "맑음", iconCode: "01d", cityName: "Seoul")
            let mockTracks = (1...10).map { i in
                Track(title: "Sunny Day Track \(i)", artist: "Sun Artist", imageURL: nil)
            }
            mock.result = WeatherMusicCuration(weather: mockWeather, moodTag: "Happy", tracks: mockTracks)
            return mock
            
        case .rain:
            let mock = MockFetchMusicForWeatherUseCase()
            let mockWeather = Weather(temperature: 15.0, condition: .rain, description: "비", iconCode: "09d", cityName: "Seoul")
            mock.result = WeatherMusicCuration(weather: mockWeather, moodTag: "Gloomy", tracks: [])
            return mock
            
        case .snow:
            let mock = MockFetchMusicForWeatherUseCase()
            mock.errorToThrow = NSError(domain: "NetworkError", code: -1009, userInfo: [NSLocalizedDescriptionKey: "인터넷 연결이 끊어졌습니다."])
            return mock
            
        case .thunderstorm:
            return MockDelayedFetchMusicForWeatherUseCase()
        }
    }
    
    var fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase {
        MockFetchTrackDeepLinkUseCaseForWeatherRecommendationInteractor()
    }
    
    var urlOpener: URLOpening {
        AlertingURLOpener()
    }
}

// MARK: - Custom Mocks for Demo

@MainActor
final class MockDelayedFetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
    func execute() async throws -> WeatherMusicCuration {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        let mockWeather = Weather(temperature: 18.0, condition: .thunderstorm, description: "천둥번개", iconCode: "11d", cityName: "Seoul")
        let mockTracks = [
            Track(title: "Thunder Track", artist: "Thunder Artist", imageURL: nil)
        ]
        return WeatherMusicCuration(weather: mockWeather, moodTag: "Intense", tracks: mockTracks)
    }
}

final class AlertingURLOpener: URLOpening {
    @MainActor
    func open(_ url: URL) {
        let alert = UIAlertController(title: "URL Opened", message: url.absoluteString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        
        // Find topmost view controller to present alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(alert, animated: true)
        }
    }
}
