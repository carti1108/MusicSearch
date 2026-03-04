//
//  RootBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import RIBs

protocol RootDependency: Dependency, HomeDependency, DiggingDependency, TrendDependency {}

final class RootComponent: Component<RootDependency>, HomeDependency, DiggingDependency, TrendDependency {
	var fetchMusicForWeatherUseCase: any FetchMusicForWeatherUseCase {
		self.dependency.fetchMusicForWeatherUseCase
	}

	var fetchMusicAppDeepLinkUseCase: any FetchMusicAppDeepLinkUseCase {
		self.dependency.fetchMusicAppDeepLinkUseCase
	}

	var searchTracksUseCase: any SearchTracksUseCase {
		self.dependency.searchTracksUseCase
	}

	var fetchTracksByTagUseCase: any FetchTracksByTagUseCase {
		self.dependency.fetchTracksByTagUseCase
	}

	var fetchSimilarTrackUseCase: any FetchSimilarTracksUseCase {
		self.dependency.fetchSimilarTrackUseCase
	}

	var fetchChartTopTracksUseCase: any FetchChartTopTracksUseCase {
		self.dependency.fetchChartTopTracksUseCase
	}

	var fetchChartTopArtistsUseCase: any FetchChartTopArtistsUseCase {
		self.dependency.fetchChartTopArtistsUseCase
	}

	var homeBuilder: HomeBuildable {
		HomeBuilder(dependency: self)
	}

	var trackSearchBuilder: TrackSearchBuildable {
		TrackSearchBuilder(dependency: self)
	}

	var trendBuilder: TrendBuildable {
		TrendBuilder(dependency: self)
	}
}

protocol RootBuildable: Buildable {
	func build() -> LaunchRouting
}

final class RootBuilder: Builder<RootDependency>, RootBuildable {
	override init(dependency: RootDependency) {
		super.init(dependency: dependency)
	}

	func build() -> LaunchRouting {
		MainActor.assumeIsolated {
			let component = RootComponent(dependency: self.dependency)
			let viewController = RootViewController()
			let interactor = RootInteractor(presenter: viewController)

			return RootRouter(
				interactor: interactor,
				viewController: viewController,
				homeBuilder: component.homeBuilder,
				trackSearchBuilder: component.trackSearchBuilder,
				trendBuilder: component.trendBuilder
			)
		}
	}
}
