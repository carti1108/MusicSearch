//
//  WeatherRecommendationBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import MicroRIBs

@MainActor
protocol WeatherRecommendationDependency: Dependency {
	var fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase { get }
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase { get }
}

@MainActor
final class WeatherRecommendationComponent: Component<WeatherRecommendationDependency> {
	fileprivate var fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
		self.dependency.fetchMusicForWeatherUseCase
	}

	fileprivate var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.dependency.fetchMusicAppDeepLinkUseCase
	}
}

@MainActor
protocol WeatherRecommendationBuildable: Buildable {
	func build(withListener listener: WeatherRecommendationListener) -> WeatherRecommendationRouting
}

@MainActor
final class WeatherRecommendationBuilder: Builder<WeatherRecommendationDependency>, WeatherRecommendationBuildable {
	override init(dependency: WeatherRecommendationDependency) {
		super.init(dependency: dependency)
	}

	func build(withListener listener: WeatherRecommendationListener) -> WeatherRecommendationRouting {
		MainActor.assumeIsolated {
			let component = WeatherRecommendationComponent(dependency: self.dependency)
			let viewController = WeatherRecommendationViewController()
			let interactor = WeatherRecommendationInteractor(
				presenter: viewController,
				fetchMusicForWeatherUseCase: component.fetchMusicForWeatherUseCase,
				fetchMusicAppDeepLinkUseCase: component.fetchMusicAppDeepLinkUseCase
			)
			interactor.listener = listener
			return WeatherRecommendationRouter(interactor: interactor, viewController: viewController)
		}
	}
}
