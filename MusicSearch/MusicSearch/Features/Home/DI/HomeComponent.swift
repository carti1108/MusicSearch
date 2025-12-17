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

	@MainActor
	var weatherRecommendationViewModel: WeatherRecommendationViewModel {
		WeatherRecommendationViewModel(
			fetchMusicForWeatherUseCase: self.dependency.fetchMusicForWeatherUseCase
		)
	}

	@MainActor
	func makeHomeViewCoordinator(navigationController: UINavigationController) -> HomeViewCoordinator<T> {
		HomeViewCoordinator(navigationController: navigationController, component: self)
	}

	@MainActor
	func makeWeatherRecommendationViewController() -> WeatherRecommendationViewController {
		WeatherRecommendationViewController(viewModel: self.weatherRecommendationViewModel)
	}
}

