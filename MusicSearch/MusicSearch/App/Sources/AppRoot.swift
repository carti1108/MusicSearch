//
//  AppRoot.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import UIKit

final class AppRoot {

	private let appComponent: AppComponent

	private lazy var weatherComponent: WeatherComponent = {
		WeatherComponent(dependency: self.appComponent)
	}()

	private lazy var musicComponent: MusicComponent = {
		MusicComponent(dependency: self.appComponent)
	}()

	private lazy var homeComponent: HomeComponent = {
		let dependency = CombinedHomeDependency(
			weatherComponent: self.weatherComponent,
			musicComponent: self.musicComponent
		)
		return HomeComponent(dependency: dependency)
	}()

	init(appComponent: AppComponent = AppComponent()) {
		self.appComponent = appComponent
	}

	@MainActor
	func makeWeatherRecommendationViewController() -> UIViewController {
		self.homeComponent.makeWeatherRecommendationViewController()
	}

	@MainActor
	func makeRootTabBarController() -> UITabBarController {
		let tabBarController = UITabBarController()

		let weatherVC = self.makeWeatherRecommendationViewController()
		weatherVC.tabBarItem = UITabBarItem(title: "Weather", image: UIImage(systemName: "cloud.sun.fill"), selectedImage: nil)

		let musicVC = Self.makePlaceholderViewController(title: "Music", systemImage: "music.note.list")
		let settingsVC = Self.makePlaceholderViewController(title: "Settings", systemImage: "gearshape")

		tabBarController.viewControllers = [weatherVC, musicVC, settingsVC]
		return tabBarController
	}

	private static func makePlaceholderViewController(title: String, systemImage: String) -> UIViewController {
		let vc = UIViewController()
		vc.view.backgroundColor = .systemBackground
		vc.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: systemImage), selectedImage: nil)
		return vc
	}
}

private struct CombinedHomeDependency: HomeDependency {
	let weatherComponent: WeatherComponent<AppComponent>
	let musicComponent: MusicComponent<AppComponent>

	var fetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase {
		self.weatherComponent.fetchCurrentWeatherUseCase
	}

	var fetchTracksByTagUseCase: FetchTracksByTagUseCase {
		self.musicComponent.fetchTracksByTagUseCase
	}
}

