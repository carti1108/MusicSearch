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
	
	var spotifyService: SpotifyServiceProtocol {
		self.dependency.spotifyService
	}

	@MainActor
	func makeWeatherRecommendationViewModel() -> WeatherRecommendationViewModel {
		WeatherRecommendationViewModel(
			fetchMusicForWeatherUseCase: self.dependency.fetchMusicForWeatherUseCase
		)
	}

	@MainActor
	func makeHomeViewCoordinator(navigationController: UINavigationController) -> HomeViewCoordinator<T> {
		HomeViewCoordinator(navigationController: navigationController, component: self)
	}

	@MainActor
	func makeWeatherRecommendationViewController(coordinator: WeatherRecommendationCoordinatorAction) -> WeatherRecommendationViewController {
		let vm = self.makeWeatherRecommendationViewModel()
		vm.coordinator = coordinator
		return WeatherRecommendationViewController(viewModel: vm)
	}
}

