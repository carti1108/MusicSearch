//
//  RootRouter.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs
import FeatureChart
import FeatureChartInterface
import FeatureMusicDigging
import FeatureMusicDiggingInterface
import FeatureTrackSearch
import FeatureTrackSearchInterface
import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface

@MainActor
protocol RootInteractable: Interactable, WeatherRecommendationListener, TrackSearchListener, ChartListener {
	var router: RootRouting? { get set }
	var listener: RootListener? { get set }
}

@MainActor
protocol RootViewControllable: ViewControllable {
	func setTabs(_ viewControllers: [UIViewController])
}

@MainActor
final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {
	private let weatherRecommendationBuilder: WeatherRecommendationBuildable
	private let trackSearchBuilder: TrackSearchBuildable
	private let chartBuilder: ChartBuildable

	private var weatherRecommendationRouter: WeatherRecommendationRouting?
	private var trackSearchRouter: TrackSearchRouting?
	private var chartRouter: ChartRouting?

	init(
		interactor: RootInteractable,
		viewController: RootViewControllable,
		weatherRecommendationBuilder: WeatherRecommendationBuildable,
		trackSearchBuilder: TrackSearchBuildable,
		chartBuilder: ChartBuildable
	) {
		self.weatherRecommendationBuilder = weatherRecommendationBuilder
		self.trackSearchBuilder = trackSearchBuilder
		self.chartBuilder = chartBuilder
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}

	override func didLoad() {
		super.didLoad()

		let weatherRecommendationRouter = self.weatherRecommendationBuilder.build(withListener: self.interactor)
		self.attachChild(weatherRecommendationRouter)
		self.weatherRecommendationRouter = weatherRecommendationRouter

		let weatherRecommendationNavigationController = UINavigationController(
			rootViewController: weatherRecommendationRouter.viewControllable.uiViewController
		)
		weatherRecommendationNavigationController.tabBarItem = UITabBarItem(
			title: "Weather",
			image: UIImage(systemName: "house.fill"),
			selectedImage: nil
		)

		let trackSearchNavigationController = UINavigationController()
		let trackSearchRouter = self.trackSearchBuilder.build(
			withListener: self.interactor,
			navigationController: trackSearchNavigationController
		)
		self.attachChild(trackSearchRouter)
		self.trackSearchRouter = trackSearchRouter
		trackSearchNavigationController.tabBarItem = UITabBarItem(
			title: "Search",
			image: UIImage(systemName: "magnifyingglass"),
			selectedImage: nil
		)

		let chartRouter = self.chartBuilder.build(withListener: self.interactor)
		self.attachChild(chartRouter)
		self.chartRouter = chartRouter

		let chartNavigationController = UINavigationController(rootViewController: chartRouter.viewControllable.uiViewController)
		chartNavigationController.tabBarItem = UITabBarItem(
			title: "Chart",
			image: UIImage(systemName: "chart.bar.fill"),
			selectedImage: nil
		)

		self.viewController.setTabs([
			weatherRecommendationNavigationController,
			trackSearchNavigationController,
			chartNavigationController
		])
	}
}
