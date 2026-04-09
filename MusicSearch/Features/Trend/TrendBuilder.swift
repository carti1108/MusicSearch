//
//  TrendBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import MicroRIBs

protocol TrendDependency: Dependency {
	var fetchChartTopTracksUseCase: FetchChartTopTracksUseCase { get }
	var fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase { get }
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase { get }
}

final class TrendComponent: Component<TrendDependency> {
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

protocol TrendBuildable: Buildable {
	func build(withListener listener: TrendListener) -> TrendRouting
}

final class TrendBuilder: Builder<TrendDependency>, TrendBuildable {
	override init(dependency: TrendDependency) {
		super.init(dependency: dependency)
	}

	func build(withListener listener: TrendListener) -> TrendRouting {
		MainActor.assumeIsolated {
			let component = TrendComponent(dependency: self.dependency)
			let viewController = ChartViewController()
			let interactor = TrendInteractor(
				presenter: viewController,
				fetchChartTopTracksUseCase: component.fetchChartTopTracksUseCase,
				fetchChartTopArtistsUseCase: component.fetchChartTopArtistsUseCase,
				fetchMusicAppDeepLinkUseCase: component.fetchMusicAppDeepLinkUseCase
			)
			interactor.listener = listener
			return TrendRouter(interactor: interactor, viewController: viewController)
		}
	}
}
