//
//  RootRouter.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs

protocol RootInteractable: Interactable, HomeListener, TrackSearchListener, TrendListener {
	var router: RootRouting? { get set }
	var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {
	func setTabs(_ viewControllers: [UIViewController])
}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {
	private let homeBuilder: HomeBuildable
	private let trackSearchBuilder: TrackSearchBuildable
	private let trendBuilder: TrendBuildable

	private var homeRouter: HomeRouting?
	private var trackSearchRouter: TrackSearchRouting?
	private var trendRouter: TrendRouting?

	init(
		interactor: RootInteractable,
		viewController: RootViewControllable,
		homeBuilder: HomeBuildable,
		trackSearchBuilder: TrackSearchBuildable,
		trendBuilder: TrendBuildable
	) {
		self.homeBuilder = homeBuilder
		self.trackSearchBuilder = trackSearchBuilder
		self.trendBuilder = trendBuilder
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}

	override func didLoad() {
		super.didLoad()

		let homeRouter = self.homeBuilder.build(withListener: self.interactor)
		self.attachChild(homeRouter)
		self.homeRouter = homeRouter

		let homeNavigationController = UINavigationController(rootViewController: homeRouter.viewControllable.uiViewController)
		homeNavigationController.tabBarItem = UITabBarItem(
			title: "Home",
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

		let trendRouter = self.trendBuilder.build(withListener: self.interactor)
		self.attachChild(trendRouter)
		self.trendRouter = trendRouter

		let trendNavigationController = UINavigationController(rootViewController: trendRouter.viewControllable.uiViewController)
		trendNavigationController.tabBarItem = UITabBarItem(
			title: "Chart",
			image: UIImage(systemName: "chart.bar.fill"),
			selectedImage: nil
		)

		self.viewController.setTabs([
			homeNavigationController,
			trackSearchNavigationController,
			trendNavigationController
		])
	}
}
