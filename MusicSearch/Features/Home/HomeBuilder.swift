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

final class HomeComponent: Component<HomeDependency> {
	fileprivate var fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
		self.dependency.fetchMusicForWeatherUseCase
	}

	fileprivate var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.dependency.fetchMusicAppDeepLinkUseCase
	}
}

protocol HomeBuildable: Buildable {
	func build(withListener listener: HomeListener) -> HomeRouting
}

final class HomeBuilder: Builder<HomeDependency>, HomeBuildable {
	override init(dependency: HomeDependency) {
		super.init(dependency: dependency)
	}

	func build(withListener listener: HomeListener) -> HomeRouting {
		MainActor.assumeIsolated {
			let component = HomeComponent(dependency: self.dependency)
			let viewController = WeatherRecommendationViewController()
			let interactor = HomeInteractor(
				presenter: viewController,
				fetchMusicForWeatherUseCase: component.fetchMusicForWeatherUseCase,
				fetchMusicAppDeepLinkUseCase: component.fetchMusicAppDeepLinkUseCase
			)
			interactor.listener = listener
			return HomeRouter(interactor: interactor, viewController: viewController)
		}
	}
}
