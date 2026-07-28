//
//  ExampleAppComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import UIKit
import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface
import FeatureWeatherRecommendationTesting
import MSDomain
import MSTesting
import MSUtil
import WeatherRecommendationDomain

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
        MockURLOpener()
    }
}


