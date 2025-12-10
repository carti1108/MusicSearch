//
//  HomeComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import Foundation

final class HomeComponent<T: HomeDependency>: Component {
	typealias DependencyType = T
	
	private let dependency: T
	
	init(dependency: T) {
		self.dependency = dependency
	}
	
	var fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
		FetchMusicForWeatherUseCaseImpl(
			fetchCurrentWeatherUseCase: dependency.fetchCurrentWeatherUseCase,
			fetchTracksByTagUseCase: dependency.fetchTracksByTagUseCase
		)
	}
	
	func makeWeatherRecommendationViewController() -> WeatherRecommendationViewController {
		WeatherRecommendationViewController()
	}
}

