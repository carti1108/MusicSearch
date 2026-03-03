//
//  HomeComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import UIKit

final class HomeComponent<T: HomeDependency>: Component {
	typealias DependencyType = T
	
	private let dependency: T
	
	init(dependency: T) {
		self.dependency = dependency
	}

	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.dependency.fetchMusicAppDeepLinkUseCase
	}

	@MainActor
	func makeWeatherRecommendationViewModel(view: WeatherRecommendationViewable) -> WeatherRecommendationViewModel {
		WeatherRecommendationViewModel(
			view: view,
			fetchMusicForWeatherUseCase: self.dependency.fetchMusicForWeatherUseCase
		)
	}

	@MainActor
	func makeHomeViewCoordinator(navigationController: UINavigationController) -> HomeViewCoordinator<T> {
		HomeViewCoordinator(navigationController: navigationController, component: self)
	}
}
