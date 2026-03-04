//
//  ChartViewCoordinator.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit

final class ChartViewCoordinator<T: TrendDependency>: Coordinator, ChartViewCoordinatorAction, MusicAppRouting {
	private let component: TrendComponent<T>
	private var chartViewModel: ChartViewModel?

	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.component.fetchMusicAppDeepLinkUseCase
	}

	init(navigationController: UINavigationController, component: TrendComponent<T>) {
		self.component = component
		super.init(navigationController: navigationController)
	}

	override func start() {
		let vc = ChartViewController()
		let viewModel = self.component.makeChartViewModel(view: vc)
		viewModel.coordinator = self
		self.chartViewModel = viewModel
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
