//
//  TrendComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit

final class TrendComponent<T: TrendDependency>: Component {

	typealias DependencyType = T
	
	private let dependency: T

	init(dependency: T) {
		self.dependency = dependency
	}

	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.dependency.fetchMusicAppDeepLinkUseCase
	}

	@MainActor
	func makeChartViewModel() -> ChartViewModel {
		ChartViewModel(
			fetchChartTopTracksUseCase: self.dependency.fetchChartTopTracksUseCase,
			fetchChartTopArtistsUseCase: self.dependency.fetchChartTopArtistsUseCase
		)
	}

	@MainActor
	func makeChartViewCoordinator(navigationController: UINavigationController) -> ChartViewCoordinator<T> {
		ChartViewCoordinator(navigationController: navigationController, component: self)
	}

	@MainActor
	func makeChartViewController(coordinator: ChartViewCoordinatorAction) -> ChartViewController {
		let vm = self.makeChartViewModel()
		vm.coordinator = coordinator
		return ChartViewController(viewModel: vm)
	}
}
