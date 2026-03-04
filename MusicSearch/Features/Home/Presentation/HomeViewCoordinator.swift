//
//  HomeViewCoordinator.swift
//  MusicSearch
//
//  Created by Kiseok on 12/14/25.
//

import UIKit

final class HomeViewCoordinator<T: HomeDependency>: Coordinator, WeatherRecommendationCoordinatorAction, MusicAppRouting {
	private let component: HomeComponent<T>
	
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.component.fetchMusicAppDeepLinkUseCase
	}

	init(navigationController: UINavigationController, component: HomeComponent<T>) {
		self.component = component
		super.init(navigationController: navigationController)
	}

	override func start() {
		let vc = self.component.makeWeatherRecommendationViewController(coordinator: self)
		self.navigationController.setViewControllers([vc], animated: false)
	}
	
	func didSelect(track: Track) {
		self.openMusicApp(for: track)
	}
}
