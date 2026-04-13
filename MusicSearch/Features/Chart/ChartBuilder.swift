//
//  ChartBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import MicroRIBs

protocol ChartDependency: Dependency {
	var fetchChartTopTracksUseCase: FetchChartTopTracksUseCase { get }
	var fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase { get }
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase { get }
}

final class ChartComponent: Component<ChartDependency> {
	fileprivate var fetchChartTopTracksUseCase: FetchChartTopTracksUseCase {
		self.dependency.fetchChartTopTracksUseCase
	}

	fileprivate var fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase {
		self.dependency.fetchChartTopArtistsUseCase
	}

	fileprivate var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.dependency.fetchMusicAppDeepLinkUseCase
	}
}

protocol ChartBuildable: Buildable {
	func build(withListener listener: ChartListener) -> ChartRouting
}

final class ChartBuilder: Builder<ChartDependency>, ChartBuildable {
	override init(dependency: ChartDependency) {
		super.init(dependency: dependency)
	}

	func build(withListener listener: ChartListener) -> ChartRouting {
		MainActor.assumeIsolated {
			let component = ChartComponent(dependency: self.dependency)
			let viewController = ChartViewController()
			let interactor = ChartInteractor(
				presenter: viewController,
				fetchChartTopTracksUseCase: component.fetchChartTopTracksUseCase,
				fetchChartTopArtistsUseCase: component.fetchChartTopArtistsUseCase,
				fetchMusicAppDeepLinkUseCase: component.fetchMusicAppDeepLinkUseCase
			)
			interactor.listener = listener
			return ChartRouter(interactor: interactor, viewController: viewController)
		}
	}
}
