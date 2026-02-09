//
//  ChartViewCoordinator.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit

final class ChartViewCoordinator<T: TrendDependency>: Coordinator {
	var navigationController: UINavigationController
	var childCoordinators: [Coordinator] = .init()

	private let component: TrendComponent<T>

	init(navigationController: UINavigationController, component: TrendComponent<T>) {
		self.navigationController = navigationController
		self.component = component
	}

	func start() {
		let vc = self.component.makeChartViewController()
		self.navigationController.setViewControllers([vc], animated: false)
	}
}
