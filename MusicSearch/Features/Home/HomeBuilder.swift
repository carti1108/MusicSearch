//
//  HomeBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import RIBs

protocol HomeDependency: Dependency {
	var fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase { get }
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase { get }
}

protocol HomeBuildable: Buildable {
	func build() -> HomeRouting
}

final class HomeBuilder: Builder<HomeDependency>, HomeBuildable {
	override init(dependency: HomeDependency) {
		super.init(dependency: dependency)
	}

	func build() -> HomeRouting {
		MainActor.assumeIsolated {
			let viewController = WeatherRecommendationViewController()
			let interactor = HomeInteractor(
				presenter: viewController,
				fetchMusicForWeatherUseCase: self.dependency.fetchMusicForWeatherUseCase,
				fetchMusicAppDeepLinkUseCase: self.dependency.fetchMusicAppDeepLinkUseCase
			)
			return HomeRouter(interactor: interactor, viewController: viewController)
		}
	}
}
