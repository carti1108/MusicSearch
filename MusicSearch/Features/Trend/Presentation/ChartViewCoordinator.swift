//
//  ChartViewCoordinator.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit

final class ChartViewCoordinator<T: TrendDependency>: Coordinator, ChartViewCoordinatorAction, MusicAppRouting {
	var navigationController: UINavigationController
	var childCoordinators: [Coordinator] = .init()

	private let component: TrendComponent<T>
	
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.component.fetchMusicAppDeepLinkUseCase
	}

	init(navigationController: UINavigationController, component: TrendComponent<T>) {
		self.navigationController = navigationController
		self.component = component
	}

	func start() {
		let vc = self.component.makeChartViewController(coordinator: self)
		self.navigationController.setViewControllers([vc], animated: false)
	}
	
	func didSelect(item: ChartItem) {
		if item.type == .tracks {
			let track = Track(title: item.title, artist: item.subtitle, imageURL: item.imageURL)
			self.openMusicApp(for: track)
		} else {
			self.openMusicApp(for: item.title)
		}
	}
}
