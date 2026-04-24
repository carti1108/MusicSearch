//
//  AppRoot.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import UIKit

@MainActor
final class AppRoot {

	private let appComponent: AppComponent

	private lazy var diggingComponent: DiggingComponent = {
		DiggingComponent(dependency: self.appComponent)
	}()

	private lazy var homeComponent: HomeComponent = {
		return HomeComponent(dependency: self.appComponent)
	}()

	private lazy var trendComponent: TrendComponent = {
		return TrendComponent(dependency: self.appComponent)
	}()

	private var homeCoordinator: HomeViewCoordinator<AppComponent>?
	private var trackSearchCoordinator: TrackSearchViewCoordinator<AppComponent>?
	private var chartCoordinator: ChartViewCoordinator<AppComponent>?

	init(appComponent: AppComponent = AppComponent()) {
		self.appComponent = appComponent
	}

	@MainActor
	func makeRootTabBarController() -> UITabBarController {
		let tabBarController = UITabBarController()

		let homeNavigationController = UINavigationController()
		let homeViewCoordinator = self.homeComponent.makeHomeViewCoordinator(
			navigationController: homeNavigationController
		)
		self.homeCoordinator = homeViewCoordinator
		homeViewCoordinator.start()
		homeNavigationController.tabBarItem = UITabBarItem(
			title: "Home",
			image: UIImage(systemName: "house.fill"),
			selectedImage: nil
		)

		let musicNavigationController = UINavigationController()
		let musicCoordinator = self.diggingComponent.makeTrackSearchCoordinator(
			navigationController: musicNavigationController
		)
		self.trackSearchCoordinator = musicCoordinator
		musicCoordinator.start()
		musicNavigationController.tabBarItem = UITabBarItem(
			title: "Search",
			image: UIImage(systemName: "magnifyingglass"),
			selectedImage: nil
		)

		let chartNavigationController = UINavigationController()
		let chartViewCoordinator = self.trendComponent.makeChartViewCoordinator(
			navigationController: chartNavigationController
		)
		self.chartCoordinator = chartViewCoordinator
		chartViewCoordinator.start()
		chartNavigationController.tabBarItem = UITabBarItem(
			title: "Chart",
			image: UIImage(systemName: "chart.bar.fill"),
			selectedImage: nil
		)

		tabBarController.viewControllers = [
			homeNavigationController,
			musicNavigationController,
			chartNavigationController
		]

		return tabBarController
	}
}
