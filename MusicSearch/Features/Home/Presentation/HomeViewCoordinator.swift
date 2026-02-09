//
//  HomeViewCoordinator.swift
//  MusicSearch
//
//  Created by Kiseok on 12/14/25.
//

import UIKit

final class HomeViewCoordinator<T: HomeDependency>: Coordinator, WeatherRecommendationCoordinatorAction {
	var navigationController: UINavigationController
	var childCoordinators: [Coordinator] = .init()

	private let component: HomeComponent<T>

	init(navigationController: UINavigationController, component: HomeComponent<T>) {
		self.navigationController = navigationController
		self.component = component
	}

	func start() {
		let vc = self.component.makeWeatherRecommendationViewController(coordinator: self)
		self.navigationController.setViewControllers([vc], animated: false)
	}
	
	func didSelect(track: Track) {
		self.component.spotifyService.openSpotify(for: track)
	}
}
