//
//  HomeViewCoordinator.swift
//  MusicSearch
//
//  Created by Kiseok on 12/14/25.
//

import UIKit

final class HomeViewCoordinator<T: HomeDependency>: Coordinator, WeatherRecommendationCoordinatorAction, MusicAppRouting {

	private let component: HomeComponent<T>
	private var weatherRecommendationViewModel: WeatherRecommendationViewModel?
	
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.component.fetchMusicAppDeepLinkUseCase
	}

	init(navigationController: UINavigationController, component: HomeComponent<T>) {
		self.component = component
		super.init(navigationController: navigationController)
	}

	override func start() {
		let vc = WeatherRecommendationViewController()
		let viewModel = self.component.makeWeatherRecommendationViewModel(view: vc)
		viewModel.coordinator = self
		self.weatherRecommendationViewModel = viewModel
		self.navigationController.setViewControllers([vc], animated: false)
	}
	
	func didSelect(track: Track) {
		self.openMusicApp(for: track)
	}
}
