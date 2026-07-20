//
//  FeatureWeatherRecommendationInterface.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import MicroRIBs
import MSDomain
import MSUtil
import WeatherRecommendationDomain

@MainActor
public protocol WeatherRecommendationBuildable: Buildable {
	func build(withListener listener: WeatherRecommendationListener) -> WeatherRecommendationRouting
}

@MainActor
public protocol WeatherRecommendationRouting: ViewableRouting {}

@MainActor
public protocol WeatherRecommendationListener: AnyObject {}

@MainActor
public protocol WeatherRecommendationDependency: Dependency {
	var fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase { get }
	var fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase { get }
	var urlOpener: URLOpening { get }
}
