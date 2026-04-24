//
//  RootBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs

@MainActor
protocol RootDependency: Dependency, WeatherRecommendationDependency, TrackSearchDependency, ChartDependency {}

@MainActor
final class RootComponent: Component<RootDependency>, WeatherRecommendationDependency, TrackSearchDependency, ChartDependency {
	var fetchMusicForWeatherUseCase: any FetchMusicForWeatherUseCase {
		self.dependency.fetchMusicForWeatherUseCase
	}

	var fetchMusicAppDeepLinkUseCase: any FetchMusicAppDeepLinkUseCase {
		self.dependency.fetchMusicAppDeepLinkUseCase
	}

	var urlOpener: URLOpening {
		self.dependency.urlOpener
	}

	var searchTracksUseCase: any SearchTracksUseCase {
		self.dependency.searchTracksUseCase
	}

	var fetchTracksByTagUseCase: any FetchTracksByTagUseCase {
		self.dependency.fetchTracksByTagUseCase
	}

	var fetchSimilarTracksUseCase: any FetchSimilarTracksUseCase {
		self.dependency.fetchSimilarTracksUseCase
	}

	var fetchChartTopTracksUseCase: any FetchChartTopTracksUseCase {
		self.dependency.fetchChartTopTracksUseCase
	}

	var fetchChartTopArtistsUseCase: any FetchChartTopArtistsUseCase {
		self.dependency.fetchChartTopArtistsUseCase
	}

	var weatherRecommendationBuilder: WeatherRecommendationBuildable {
		WeatherRecommendationBuilder(dependency: self)
	}

	var trackSearchBuilder: TrackSearchBuildable {
		TrackSearchBuilder(dependency: self)
	}

	var chartBuilder: ChartBuildable {
		ChartBuilder(dependency: self)
	}
}

@MainActor
protocol RootBuildable: Buildable {
	func build() -> LaunchRouting
}

@MainActor
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
				weatherRecommendationBuilder: component.weatherRecommendationBuilder,
				trackSearchBuilder: component.trackSearchBuilder,
				chartBuilder: component.chartBuilder
			)
		}
	}
}
